extends RefCounted
## Offline realm-administration rules. Story systems decide when the player gains authority.
## All mutations are deterministic and serializable; no background simulation or network service.

const MIN_STAT := 0
const MAX_STAT := 100
const HISTORY_LIMIT := 100
const BUILDINGS := {
	"farms": {"cost": 120, "food": 18, "tax": 2, "name": "Granaries & Farms"},
	"market": {"cost": 180, "food": 0, "tax": 12, "name": "Chartered Market"},
	"barracks": {"cost": 220, "food": 0, "tax": 0, "manpower": 15, "name": "Barracks"},
	"roads": {"cost": 160, "food": 0, "tax": 5, "name": "Road Network"},
	"fort": {"cost": 260, "food": 0, "tax": 0, "defence": 12, "name": "Border Keep"},
	"aqueduct": {"cost": 240, "food": 10, "tax": 0, "stability": 2, "name": "Aqueduct"},
	"depot": {"cost": 210, "food": 0, "tax": 0, "supply": 1, "name": "Supply Depot"}
}
const TAX_RATES := ["low", "normal", "high"]
const COUNCIL_ROLES := ["steward", "marshal", "spymaster", "chancellor", "high_priest"]
const POLICIES := ["relief", "development", "conscription", "mercantile", "tolerance"]


static func new_state() -> Dictionary:
	return {
		"version": 1, "unlocked": false, "realm_name": "The Crownlands",
		"treasury": 500, "food": 300, "manpower": 100, "stability": 60,
		"legitimacy": 45, "public_order": 60, "tax_rate": "normal",
		"policies": [], "council": {}, "governors": {}, "provinces": {},
		"buildings": {}, "armies": {}, "field_armies": {}, "sieges": {}, "war_exhaustion": 0, "next_army_id": 1, "turn": 0, "history": []
	}


static func normalize_state(raw: Dictionary) -> Dictionary:
	var state := new_state()
	for key in ["unlocked", "realm_name", "treasury", "food", "manpower", "stability", "legitimacy", "public_order", "turn"]:
		if raw.has(key):
			state[key] = raw[key]
	state["next_army_id"] = maxi(1, int(raw.get("next_army_id", 1)))
	state["war_exhaustion"] = clampi(int(raw.get("war_exhaustion", 0)), 0, 100)
	for stat in ["treasury", "food", "manpower", "turn"]:
		state[stat] = maxi(0, int(state[stat]))
	for stat in ["stability", "legitimacy", "public_order"]:
		state[stat] = clampi(int(state[stat]), MIN_STAT, MAX_STAT)
	state["tax_rate"] = str(raw.get("tax_rate", "normal"))
	if not TAX_RATES.has(state["tax_rate"]):
		state["tax_rate"] = "normal"
	for key in ["policies", "council", "governors", "provinces", "buildings", "armies", "field_armies", "sieges"]:
		if typeof(raw.get(key, {})) == TYPE_DICTIONARY:
			state[key] = (raw[key] as Dictionary).duplicate(true)
	if typeof(raw.get("policies", [])) == TYPE_ARRAY:
		state["policies"] = (raw["policies"] as Array).filter(func(p): return POLICIES.has(str(p)))
	if typeof(raw.get("history", [])) == TYPE_ARRAY:
		var entries: Array = raw["history"]
		state["history"] = entries.slice(maxi(0, entries.size() - HISTORY_LIMIT))
	return state


static func unlock(state: Dictionary, realm_name: String = "The Crownlands") -> bool:
	if bool(state.get("unlocked", false)):
		return false
	state["unlocked"] = true
	state["realm_name"] = realm_name if realm_name.strip_edges() != "" else "The Crownlands"
	_record(state, "realm_unlocked", {"realm": state["realm_name"]})
	return true


static func set_tax_rate(state: Dictionary, rate: String) -> bool:
	if not bool(state.get("unlocked", false)) or not TAX_RATES.has(rate):
		return false
	state["tax_rate"] = rate
	_record(state, "tax_policy", {"rate": rate})
	return true


static func toggle_policy(state: Dictionary, policy: String) -> bool:
	if not bool(state.get("unlocked", false)) or not POLICIES.has(policy):
		return false
	var policies: Array = state["policies"]
	if policies.has(policy):
		policies.erase(policy)
	else:
		policies.append(policy)
	_record(state, "policy", {"policy": policy, "enabled": policies.has(policy)})
	return true


static func appoint_councillor(state: Dictionary, role: String, character_id: String) -> bool:
	if not bool(state.get("unlocked", false)) or not COUNCIL_ROLES.has(role) or character_id.strip_edges() == "":
		return false
	state["council"][role] = character_id
	_record(state, "council_appointment", {"role": role, "character": character_id})
	return true



static func dismiss_councillor(state: Dictionary, role: String) -> bool:
	if not bool(state.get("unlocked", false)) or not COUNCIL_ROLES.has(role) or not state.get("council", {}).has(role):
		return false
	var previous := str(state["council"].get(role, ""))
	state["council"].erase(role)
	_record(state, "council_dismissal", {"role": role, "character": previous})
	return true


static func dismiss_governor(state: Dictionary, province_id: String) -> bool:
	if not bool(state.get("unlocked", false)) or not state.get("governors", {}).has(province_id):
		return false
	var previous := str(state["governors"].get(province_id, ""))
	state["governors"].erase(province_id)
	_record(state, "governor_recall", {"province": province_id, "character": previous})
	return true


static func appoint_governor(state: Dictionary, province_id: String, character_id: String, known_provinces: Array) -> bool:
	if not bool(state.get("unlocked", false)) or not known_provinces.has(province_id) or character_id.strip_edges() == "":
		return false
	state["governors"][province_id] = character_id
	_record(state, "governor_appointment", {"province": province_id, "character": character_id})
	return true


static func construct(state: Dictionary, province_id: String, building_id: String, known_provinces: Array) -> bool:
	if not bool(state.get("unlocked", false)) or not known_provinces.has(province_id) or not BUILDINGS.has(building_id):
		return false
	var key := province_id + ":" + building_id
	if state["buildings"].has(key):
		return false
	var definition: Dictionary = BUILDINGS[building_id]
	var cost := int(definition["cost"])
	if int(state["treasury"]) < cost:
		return false
	state["treasury"] = int(state["treasury"]) - cost
	state["buildings"][key] = {"province": province_id, "type": building_id, "level": 1}
	_record(state, "construction", {"province": province_id, "building": building_id, "cost": cost})
	return true




const TROOP_TYPES := {
	"infantry": {"name": "Levy Infantry", "manpower": 1, "cost": 4, "upkeep": 1, "food": 1},
	"archers": {"name": "March Archers", "manpower": 1, "cost": 6, "upkeep": 1, "food": 1},
	"cavalry": {"name": "Household Cavalry", "manpower": 2, "cost": 12, "upkeep": 2, "food": 2}
}


## Recruit a standing force into a controlled province. Barracks increase local capacity.
static func recruit_troops(state: Dictionary, province_id: String, troop_type: String, amount: int, known_provinces: Array) -> bool:
	if not bool(state.get("unlocked", false)) or not known_provinces.has(province_id) or not TROOP_TYPES.has(troop_type) or amount <= 0:
		return false
	var definition: Dictionary = TROOP_TYPES[troop_type]
	var armies: Dictionary = state.get("armies", {})
	var garrison: Dictionary = armies.get(province_id, {})
	var current_total := 0
	for count in garrison.values():
		current_total += maxi(0, int(count))
	var capacity := 50
	if state.get("buildings", {}).has(province_id + ":barracks"):
		capacity += 100
	if current_total + amount > capacity:
		return false
	var manpower_cost := int(definition["manpower"]) * amount
	var treasury_cost := int(definition["cost"]) * amount
	if int(state["manpower"]) < manpower_cost or int(state["treasury"]) < treasury_cost:
		return false
	state["manpower"] = int(state["manpower"]) - manpower_cost
	state["treasury"] = int(state["treasury"]) - treasury_cost
	garrison[troop_type] = int(garrison.get(troop_type, 0)) + amount
	armies[province_id] = garrison
	state["armies"] = armies
	_record(state, "recruitment", {"province": province_id, "type": troop_type, "amount": amount, "cost": treasury_cost})
	return true


## Disband troops and return a portion of their manpower to the realm pool.
static func disband_troops(state: Dictionary, province_id: String, troop_type: String, amount: int, known_provinces: Array) -> bool:
	if not bool(state.get("unlocked", false)) or not known_provinces.has(province_id) or not TROOP_TYPES.has(troop_type) or amount <= 0:
		return false
	var armies: Dictionary = state.get("armies", {})
	if not armies.has(province_id):
		return false
	var garrison: Dictionary = armies[province_id]
	var current := int(garrison.get(troop_type, 0))
	if current < amount:
		return false
	garrison[troop_type] = current - amount
	if int(garrison[troop_type]) == 0:
		garrison.erase(troop_type)
	if garrison.is_empty():
		armies.erase(province_id)
	else:
		armies[province_id] = garrison
	state["armies"] = armies
	var returned := int(floor(float(amount) * 0.75))
	state["manpower"] = mini(999999, int(state["manpower"]) + returned)
	_record(state, "disbandment", {"province": province_id, "type": troop_type, "amount": amount, "manpower_returned": returned})
	return true




## Mobilize part of a provincial garrison into a named field army.
static func mobilize_army(state: Dictionary, province_id: String, troop_counts: Dictionary, known_provinces: Array, commander_id: String = "") -> String:
	if not bool(state.get("unlocked", false)) or not known_provinces.has(province_id) or troop_counts.is_empty():
		return ""
	var garrisons: Dictionary = state.get("armies", {})
	var garrison: Dictionary = garrisons.get(province_id, {})
	var composition := {}
	var total := 0
	for troop_type in troop_counts.keys():
		var amount := int(troop_counts[troop_type])
		if not TROOP_TYPES.has(str(troop_type)) or amount <= 0 or int(garrison.get(troop_type, 0)) < amount:
			return ""
		composition[str(troop_type)] = amount
		total += amount
	if total <= 0:
		return ""
	for troop_type in composition.keys():
		garrison[troop_type] = int(garrison[troop_type]) - int(composition[troop_type])
		if int(garrison[troop_type]) == 0:
			garrison.erase(troop_type)
	if garrison.is_empty():
		garrisons.erase(province_id)
	else:
		garrisons[province_id] = garrison
	state["armies"] = garrisons
	var army_id := "field_%04d" % int(state.get("next_army_id", 1))
	state["next_army_id"] = int(state.get("next_army_id", 1)) + 1
	var field_armies: Dictionary = state.get("field_armies", {})
	field_armies[army_id] = {"id": army_id, "name": "Field Army %d" % (int(state["next_army_id"]) - 1), "location": province_id, "troops": composition, "commander": commander_id, "movement": 1, "supplied": true, "days_unsupplied": 0, "morale": 100}
	state["field_armies"] = field_armies
	_record(state, "army_mobilized", {"army": army_id, "province": province_id, "troops": composition})
	return army_id


## Move one strategic step along a real regional link from the seven-continent atlas.
static func move_field_army(state: Dictionary, army_id: String, destination: String, adjacency: Dictionary, controlled_provinces: Array) -> bool:
	if not bool(state.get("unlocked", false)) or not state.get("field_armies", {}).has(army_id):
		return false
	var field_armies: Dictionary = state["field_armies"]
	var army: Dictionary = field_armies[army_id]
	var origin := str(army.get("location", ""))
	if int(army.get("movement", 1)) <= 0 or destination == origin or not adjacency.get(origin, []).has(destination):
		return false
	army["location"] = destination
	army["movement"] = 0
	army["supplied"] = controlled_provinces.has(destination)
	army["days_unsupplied"] = 0
	field_armies[army_id] = army
	state["field_armies"] = field_armies
	_record(state, "army_moved", {"army": army_id, "from": origin, "to": destination, "supplied": army["supplied"]})
	return true


static func field_army_summary(state: Dictionary) -> Dictionary:
	var count := 0
	var troops := 0
	var unsupplied := 0
	for army in state.get("field_armies", {}).values():
		if typeof(army) != TYPE_DICTIONARY:
			continue
		count += 1
		if not bool(army.get("supplied", false)):
			unsupplied += 1
		for amount in army.get("troops", {}).values():
			troops += maxi(0, int(amount))
	return {"armies": count, "troops": troops, "unsupplied": unsupplied}


static func army_summary(state: Dictionary) -> Dictionary:
	var total := 0
	var upkeep := 0
	var food := 0
	var provinces := 0
	for garrison in state.get("armies", {}).values():
		if typeof(garrison) != TYPE_DICTIONARY:
			continue
		if not garrison.is_empty():
			provinces += 1
		for troop_type in garrison.keys():
			var amount := maxi(0, int(garrison[troop_type]))
			var definition: Dictionary = TROOP_TYPES.get(str(troop_type), {})
			total += amount
			upkeep += amount * int(definition.get("upkeep", 0))
			food += amount * int(definition.get("food", 0))
	for field_army in state.get("field_armies", {}).values():
		if typeof(field_army) != TYPE_DICTIONARY:
			continue
		for troop_type in field_army.get("troops", {}).keys():
			var amount := maxi(0, int(field_army["troops"][troop_type]))
			var definition: Dictionary = TROOP_TYPES.get(str(troop_type), {})
			total += amount
			upkeep += amount * int(definition.get("upkeep", 0))
			food += amount * int(definition.get("food", 0))
	return {"troops": total, "upkeep": upkeep, "food": food, "garrisoned_provinces": provinces, "field_armies": state.get("field_armies", {}).size(), "readiness": 100 if total == 0 else clampi(int(state.get("food", 0) * 100 / maxi(1, food)), 0, 100)}


## Advance one strategic season. The caller controls when story time advances.
static func advance_season(state: Dictionary, province_ids: Array, adjacency: Dictionary = {}) -> Dictionary:
	if not bool(state.get("unlocked", false)):
		return {"ok": false, "reason": "realm_locked"}
	var tax_rate := str(state.get("tax_rate", "normal"))
	var tax_multiplier := {"low": 0.65, "normal": 1.0, "high": 1.45}.get(tax_rate, 1.0)
	var income := 0
	var food_gain := 0
	var upkeep := 0
	var defence := 0
	for province_id in province_ids:
		income += 20
		food_gain += 12
		upkeep += 5
	for building in state["buildings"].values():
		if typeof(building) != TYPE_DICTIONARY:
			continue
		var def: Dictionary = BUILDINGS.get(str(building.get("type", "")), {})
		income += int(def.get("tax", 0))
		food_gain += int(def.get("food", 0))
		defence += int(def.get("defence", 0))
	food_gain += 5 if state["policies"].has("development") else 0
	income = int(round(float(income) * tax_multiplier))
	upkeep += int(state["council"].size()) * 3
	if state["policies"].has("relief"):
		upkeep += 15
	var military := army_summary(state)
	upkeep += int(military["upkeep"])
	var military_food := int(military["food"])
	var deployed: Dictionary = state.get("field_armies", {})
	var supply_losses := 0
	var destroyed_armies: Array[String] = []
	for army_id in deployed.keys():
		var field_army: Dictionary = deployed[army_id]
		field_army["movement"] = 1
		field_army["supplied"] = is_location_supplied(state, str(field_army.get("location", "")), province_ids, adjacency)
		if bool(field_army["supplied"]):
			field_army["days_unsupplied"] = 0
			field_army["morale"] = mini(100, int(field_army.get("morale", 100)) + 6)
		else:
			field_army["days_unsupplied"] = int(field_army.get("days_unsupplied", 0)) + 1
			field_army["morale"] = maxi(0, int(field_army.get("morale", 100)) - 10)
			if int(field_army["days_unsupplied"]) >= 2:
				var troop_total := 0
				for troop_count in field_army.get("troops", {}).values():
					troop_total += maxi(0, int(troop_count))
				var casualties := mini(troop_total, maxi(1, int(ceil(float(troop_total) * 0.05))))
				var remaining := casualties
				for troop_type in ["cavalry", "archers", "infantry"]:
					var available := int(field_army.get("troops", {}).get(troop_type, 0))
					var lost := mini(available, remaining)
					if lost > 0:
						field_army["troops"][troop_type] = available - lost
						remaining -= lost
						supply_losses += lost
					if remaining <= 0:
						break
				if troop_total - casualties <= 0:
					destroyed_armies.append(str(army_id))
		deployed[army_id] = field_army
	for destroyed_id in destroyed_armies:
		deployed.erase(destroyed_id)
		_record(state, "army_lost", {"army": destroyed_id, "cause": "prolonged_supply_isolation"})
	state["field_armies"] = deployed
	if state["policies"].has("conscription"):
		state["manpower"] = mini(999999, int(state["manpower"]) + 12)
	else:
		state["manpower"] = mini(999999, int(state["manpower"]) + 4)
	if state["policies"].has("mercantile"):
		income += 15
	state["treasury"] = maxi(0, int(state["treasury"]) + income - upkeep)
	state["food"] = maxi(0, int(state["food"]) + food_gain - province_ids.size() * 8 - military_food)
	var food_shortage := int(state["food"]) == 0
	if food_shortage:
		state["stability"] = maxi(0, int(state["stability"]) - 12)
		state["public_order"] = maxi(0, int(state["public_order"]) - 10)
	else:
		state["stability"] = mini(100, int(state["stability"]) + 1)
	if tax_rate == "high":
		state["public_order"] = maxi(0, int(state["public_order"]) - 4)
		state["legitimacy"] = maxi(0, int(state["legitimacy"]) - 2)
	elif tax_rate == "low":
		state["public_order"] = mini(100, int(state["public_order"]) + 2)
	if state["policies"].has("tolerance"):
		state["stability"] = mini(100, int(state["stability"]) + 2)
	if int(state.get("war_exhaustion", 0)) >= 70:
		state["stability"] = maxi(0, int(state["stability"]) - 2)
		state["public_order"] = maxi(0, int(state["public_order"]) - 2)
	state["turn"] = int(state["turn"]) + 1
	var siege_report := _advance_sieges(state, province_ids)
	var report := {"ok": true, "season": state["turn"], "sieges_advanced": siege_report["advanced"], "sieges_completed": siege_report["completed"], "war_exhaustion": int(state.get("war_exhaustion", 0)), "income": income, "upkeep": upkeep, "food_change": food_gain - province_ids.size() * 8 - military_food, "defence": defence, "military_upkeep": int(military["upkeep"]), "military_food": military_food, "troops": int(military["troops"]), "supply_losses": supply_losses, "food_shortage": food_shortage}
	_record(state, "season", report)
	return report


## A connected supply network begins at owned depots. Roads make the network cheaper to extend;
## a field army on a hostile region can draw supply only when it borders the connected network.
static func supply_network(state: Dictionary, controlled_provinces: Array, adjacency: Dictionary) -> Array:
	var network: Array[String] = []
	var frontier: Array[String] = []
	for province in controlled_provinces:
		if state.get("buildings", {}).has(str(province) + ":depot"):
			frontier.append(str(province))
	while not frontier.is_empty():
		var current: String = frontier.pop_front()
		if network.has(current) or not controlled_provinces.has(current):
			continue
		network.append(current)
		for neighbor in adjacency.get(current, []):
			if controlled_provinces.has(str(neighbor)) and not network.has(str(neighbor)) and not frontier.has(str(neighbor)):
				frontier.append(str(neighbor))
	return network


static func is_location_supplied(state: Dictionary, location: String, controlled_provinces: Array, adjacency: Dictionary) -> bool:
	if controlled_provinces.has(location):
		return true
	if adjacency.is_empty():
		return false
	var network := supply_network(state, controlled_provinces, adjacency)
	for neighbor in adjacency.get(location, []):
		if network.has(str(neighbor)):
			return true
	return false


static func start_siege(state: Dictionary, army_id: String, target_region: String, controlled_provinces: Array, adjacency: Dictionary) -> bool:
	if not bool(state.get("unlocked", false)) or not state.get("field_armies", {}).has(army_id):
		return false
	if controlled_provinces.has(target_region) or state.get("sieges", {}).has(target_region):
		return false
	var army: Dictionary = state["field_armies"][army_id]
	if str(army.get("location", "")) != target_region:
		return false
	var total := _troop_total(army.get("troops", {}))
	if total <= 0:
		return false
	var adjacent_controlled := false
	for neighbor in adjacency.get(target_region, []):
		if controlled_provinces.has(str(neighbor)):
			adjacent_controlled = true
			break
	if not adjacent_controlled:
		return false
	state["sieges"][target_region] = {"region": target_region, "army_id": army_id, "progress": 0, "defence": 20, "started_turn": int(state.get("turn", 0)), "status": "besieging"}
	_record(state, "siege_started", {"region": target_region, "army": army_id})
	return true


static func _advance_sieges(state: Dictionary, controlled_provinces: Array) -> Dictionary:
	var advanced := 0
	var completed := 0
	var sieges: Dictionary = state.get("sieges", {})
	for region in sieges.keys():
		var siege: Dictionary = sieges[region]
		if bool(siege.get("captured", false)):
			continue
		if controlled_provinces.has(str(region)):
			sieges.erase(region)
			continue
		var army_id := str(siege.get("army_id", ""))
		if not state.get("field_armies", {}).has(army_id):
			sieges.erase(region)
			_record(state, "siege_abandoned", {"region": str(region), "reason": "besieging_army_lost"})
			continue
		var army: Dictionary = state["field_armies"][army_id]
		var strength := _troop_total(army.get("troops", {}))
		if strength <= 0:
			continue
		var supplied := bool(army.get("supplied", false))
		var gain := 1
		if strength >= int(siege.get("defence", 20)) * 2:
			gain += 1
		if supplied:
			gain += 1
		var progress := mini(4, int(siege.get("progress", 0)) + gain)
		siege["progress"] = progress
		siege["status"] = "breached" if progress >= 4 else "besieging"
		sieges[region] = siege
		advanced += 1
		if progress >= 4:
			completed += 1
			_record(state, "siege_breached", {"region": str(region), "army": army_id})
	state["sieges"] = sieges
	return {"advanced": advanced, "completed": completed}


static func resolve_siege_assault(state: Dictionary, target_region: String, defender_strength: int, fort_level: int = 0) -> Dictionary:
	if not state.get("sieges", {}).has(target_region):
		return {"ok": false, "reason": "no_siege"}
	var siege: Dictionary = state["sieges"][target_region]
	if int(siege.get("progress", 0)) < 4:
		return {"ok": false, "reason": "defences_not_breached"}
	var army_id := str(siege.get("army_id", ""))
	if not state.get("field_armies", {}).has(army_id):
		return {"ok": false, "reason": "army_missing"}
	var army: Dictionary = state["field_armies"][army_id]
	var attackers := _troop_total(army.get("troops", {}))
	var effective_defence := maxi(1, defender_strength + maxi(0, fort_level) * 10)
	var won := attackers >= effective_defence
	var casualties := mini(attackers, maxi(1, int(ceil(float(attackers) * (0.10 if won else 0.25)))))
	_apply_army_losses(army, casualties)
	if _troop_total(army.get("troops", {})) <= 0:
		state["field_armies"].erase(army_id)
	else:
		state["field_armies"][army_id] = army
	state["war_exhaustion"] = clampi(int(state.get("war_exhaustion", 0)) + (8 if won else 14), 0, 100)
	if won:
		siege["status"] = "captured_pending_transfer"
		siege["assault_casualties"] = casualties
		siege["captured"] = true
		state["sieges"][target_region] = siege
	else:
		siege["progress"] = 2
		siege["status"] = "repulsed"
		state["sieges"][target_region] = siege
	_record(state, "siege_assault", {"region": target_region, "won": won, "casualties": casualties, "war_exhaustion": state["war_exhaustion"]})
	return {"ok": true, "won": won, "casualties": casualties, "remaining": _troop_total(army.get("troops", {})), "war_exhaustion": int(state["war_exhaustion"]), "territory_transfer_required": won}


static func complete_siege_transfer(state: Dictionary, target_region: String) -> bool:
	if not state.get("sieges", {}).has(target_region) or not bool(state["sieges"][target_region].get("captured", false)):
		return false
	state["sieges"].erase(target_region)
	_record(state, "siege_occupation_confirmed", {"region": target_region})
	return true


static func reduce_war_exhaustion(state: Dictionary, amount: int = 15) -> bool:
	if amount <= 0 or int(state.get("war_exhaustion", 0)) <= 0:
		return false
	state["war_exhaustion"] = maxi(0, int(state["war_exhaustion"]) - amount)
	_record(state, "war_exhaustion_reduced", {"amount": amount, "remaining": state["war_exhaustion"]})
	return true


static func tactical_deployment(state: Dictionary, army_id: String) -> Dictionary:
	if not state.get("field_armies", {}).has(army_id):
		return {"ok": false, "reason": "army_missing"}
	var army: Dictionary = state["field_armies"][army_id]
	var roster: Array[Dictionary] = []
	for troop_type in TROOP_TYPES.keys():
		var count := maxi(0, int(army.get("troops", {}).get(troop_type, 0)))
		if count > 0:
			roster.append({"troop_type": troop_type, "count": count, "unit_id": "strategic_%s_%s" % [army_id, troop_type]})
	return {"ok": true, "army_id": army_id, "commander": str(army.get("commander", "")), "morale": int(army.get("morale", 100)), "supplied": bool(army.get("supplied", false)), "roster": roster}


static func apply_tactical_result(state: Dictionary, army_id: String, casualties: Dictionary, won: bool) -> bool:
	if not state.get("field_armies", {}).has(army_id):
		return false
	var army: Dictionary = state["field_armies"][army_id]
	var total_losses := 0
	for troop_type in casualties.keys():
		if not TROOP_TYPES.has(str(troop_type)):
			return false
		var amount := int(casualties[troop_type])
		if amount < 0 or amount > int(army.get("troops", {}).get(troop_type, 0)):
			return false
		total_losses += amount
	for troop_type in casualties.keys():
		army["troops"][troop_type] = int(army["troops"].get(troop_type, 0)) - int(casualties[troop_type])
		if int(army["troops"][troop_type]) == 0:
			army["troops"].erase(troop_type)
	army["morale"] = clampi(int(army.get("morale", 100)) + (8 if won else -15), 0, 100)
	state["war_exhaustion"] = clampi(int(state.get("war_exhaustion", 0)) + (2 if won else 7), 0, 100)
	if _troop_total(army.get("troops", {})) <= 0:
		state["field_armies"].erase(army_id)
	else:
		state["field_armies"][army_id] = army
	_record(state, "tactical_battle_result", {"army": army_id, "won": won, "casualties": total_losses, "war_exhaustion": state["war_exhaustion"]})
	return true


static func _troop_total(composition: Dictionary) -> int:
	var total := 0
	for amount in composition.values():
		total += maxi(0, int(amount))
	return total


static func _apply_army_losses(army: Dictionary, amount: int) -> void:
	var remaining := amount
	for troop_type in ["cavalry", "archers", "infantry"]:
		var available := int(army.get("troops", {}).get(troop_type, 0))
		var lost := mini(available, remaining)
		if lost > 0:
			army["troops"][troop_type] = available - lost
			remaining -= lost
		if remaining <= 0:
			break


static func _record(state: Dictionary, kind: String, details: Dictionary) -> void:
	var history: Array = state.get("history", [])
	history.append({"kind": kind, "turn": int(state.get("turn", 0)), "details": details.duplicate(true)})
	state["history"] = history.slice(maxi(0, history.size() - HISTORY_LIMIT))
