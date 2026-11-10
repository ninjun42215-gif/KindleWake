extends RefCounted

const FactionSystem = preload("res://scripts/core/faction_system.gd")
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
		"buildings": {}, "armies": {}, "field_armies": {}, "sieges": {}, "trade_routes": {}, "rebellion_risk": 0, "rebellion_alerts": [], "war_exhaustion": 0, "next_army_id": 1, "next_battle_id": 1, "resolved_battle_ids": [], "turn": 0, "history": []
	}


static func normalize_state(raw: Dictionary) -> Dictionary:
	var state := new_state()
	for key in ["unlocked", "realm_name", "treasury", "food", "manpower", "stability", "legitimacy", "public_order", "turn"]:
		if raw.has(key):
			state[key] = raw[key]
	state["next_army_id"] = maxi(1, int(raw.get("next_army_id", 1)))
	state["next_battle_id"] = maxi(1, int(raw.get("next_battle_id", 1)))
	if typeof(raw.get("resolved_battle_ids", [])) == TYPE_ARRAY:
		state["resolved_battle_ids"] = (raw["resolved_battle_ids"] as Array).slice(-100)
	state["war_exhaustion"] = clampi(int(raw.get("war_exhaustion", 0)), 0, 100)
	for stat in ["treasury", "food", "manpower", "turn"]:
		state[stat] = maxi(0, int(state[stat]))
	for stat in ["stability", "legitimacy", "public_order"]:
		state[stat] = clampi(int(state[stat]), MIN_STAT, MAX_STAT)
	state["rebellion_risk"] = clampi(int(raw.get("rebellion_risk", 0)), 0, 100)
	if typeof(raw.get("rebellion_alerts", [])) == TYPE_ARRAY:
		state["rebellion_alerts"] = (raw["rebellion_alerts"] as Array).duplicate(true)
	state["tax_rate"] = str(raw.get("tax_rate", "normal"))
	if not TAX_RATES.has(state["tax_rate"]):
		state["tax_rate"] = "normal"
	for key in ["policies", "council", "governors", "provinces", "buildings", "armies", "field_armies", "sieges", "trade_routes"]:
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
	army["supplied"] = is_location_supplied(state, destination, controlled_provinces, adjacency)
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
static func advance_season(state: Dictionary, province_ids: Array, adjacency: Dictionary = {}, character_profiles: Dictionary = {}) -> Dictionary:
	if not bool(state.get("unlocked", false)):
		return {"ok": false, "reason": "realm_locked"}
	var tax_rate := str(state.get("tax_rate", "normal"))
	var tax_multiplier := {"low": 0.65, "normal": 1.0, "high": 1.45}.get(tax_rate, 1.0)
	var income := 0
	var food_gain := 0
	var trade_income := 0
	var trade_routes: Dictionary = state.get("trade_routes", {})
	for route_id in trade_routes.keys():
		var route: Dictionary = trade_routes[route_id]
		if not province_ids.has(str(route.get("origin", ""))) or not province_ids.has(str(route.get("destination", ""))):
			trade_routes.erase(route_id)
			_record(state, "trade_route_disrupted", {"route": str(route_id), "reason": "territory_lost"})
		else:
			trade_income += int(route.get("income", 20))
	state["trade_routes"] = trade_routes
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
	var council: Dictionary = council_effects(state, character_profiles)
	income += trade_income + int(council.get("income", 0))
	food_gain += int(council.get("food", 0))
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
	state["stability"] = clampi(int(state["stability"]) + int(council.get("stability", 0)), 0, 100)
	state["public_order"] = clampi(int(state["public_order"]) + int(council.get("public_order", 0)), 0, 100)
	state["war_exhaustion"] = clampi(int(state.get("war_exhaustion", 0)) + int(council.get("war_exhaustion", 0)), 0, 100)
	if int(state.get("war_exhaustion", 0)) >= 70:
		state["stability"] = maxi(0, int(state["stability"]) - 2)
		state["public_order"] = maxi(0, int(state["public_order"]) - 2)
	state["turn"] = int(state["turn"]) + 1
	var siege_report := _advance_sieges(state, province_ids)
	var unrest_report := rebellion_assessment(state, province_ids)
	var report := {"ok": true, "season": state["turn"], "sieges_advanced": siege_report["advanced"], "sieges_completed": siege_report["completed"], "war_exhaustion": int(state.get("war_exhaustion", 0)), "income": income, "upkeep": upkeep, "food_change": food_gain - province_ids.size() * 8 - military_food, "defence": defence, "military_upkeep": int(military["upkeep"]), "military_food": military_food, "troops": int(military["troops"]), "supply_losses": supply_losses, "trade_income": trade_income, "rebellion_risk": int(unrest_report.get("risk", 0)), "rebellion_alerts": unrest_report.get("alerts", []), "food_shortage": food_shortage}
	_record(state, "season", report)
	return report


## A connected supply network begins at owned depots and follows controlled atlas-region links;
## a field army on a hostile region can draw supply when it borders the connected network.
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
		if str(army.get("location", "")) != str(region):
			sieges.erase(region)
			_record(state, "siege_abandoned", {"region": str(region), "reason": "besieging_army_moved"})
			continue
		var strength := _troop_total(army.get("troops", {}))
		if strength <= 0:
			sieges.erase(region)
			_record(state, "siege_abandoned", {"region": str(region), "reason": "besieging_army_destroyed"})
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


static func build_tactical_battle(state: Dictionary, army_id: String, base_battle: Dictionary, region_id: String, defender_owner: String, siege_assault: bool = false, fort_level: int = 0, warfare_data: Dictionary = {}) -> Dictionary:
	var deployment := tactical_deployment(state, army_id)
	if not bool(deployment.get("ok", false)) or base_battle.is_empty():
		return {}
	var battle := base_battle.duplicate(true)
	var units: Array = []
	var commander_id := str(deployment.get("commander", ""))
	var commander_present := false
	for spawn in battle.get("units", []):
		if str(spawn.get("team", "")) == "player":
			var player_spawn: Dictionary = spawn.duplicate(true)
			if str(spawn.get("character_id", "")) == commander_id:
				player_spawn["commander"] = true
				commander_present = true
			units.append(player_spawn)
	if commander_id != "" and not commander_present:
		units.append({"character_id": commander_id, "team": "player", "cell": [6, 10], "facing": 0, "commander": true})
	var strategic_units: Dictionary = {}
	var cells: Array[Vector2i] = []
	for y in range(11, 14):
		for x in range(0, 7):
			if x == 6 and y == 13:
				continue
			cells.append(Vector2i(x, y))
	var cell_index := 0
	for entry in deployment.get("roster", []):
		var troop_type := str(entry.get("troop_type", "infantry"))
		var remaining := int(entry.get("count", 0))
		var cohort_index := 0
		while remaining > 0 and cell_index < cells.size():
			var cohort_count := mini(8, remaining)
			var unit_id := "strategic_%s_%s_%d" % [army_id, troop_type, cohort_index]
			var cell: Vector2i = cells[cell_index]
			units.append({"character_id": unit_id, "team": "player", "cell": [cell.x, cell.y], "facing": 0, "name": "%s Cohort" % troop_type.capitalize()})
			strategic_units[unit_id] = {"troop_type": troop_type, "count": cohort_count}
			remaining -= cohort_count
			cohort_index += 1
			cell_index += 1
		if remaining > 0:
			return {}
	var garrison_rules: Dictionary = warfare_data.get("garrisons", {})
	var defenders: Dictionary = garrison_rules.get("default", {"infantry": 10, "archers": 5, "cavalry": 0}).duplicate(true)
	var fortified_regions: Array = garrison_rules.get("fortified_regions", ["brennhallow_highlands", "quillon_heights", "aurelmont", "thorncrown", "ironvale"])
	if fortified_regions.has(region_id):
		var fortified_bonus: Dictionary = garrison_rules.get("fortified_bonus", {"infantry": 10, "archers": 5, "cavalry": 5})
		for troop_type in ["infantry", "archers", "cavalry"]:
			defenders[troop_type] = int(defenders.get(troop_type, 0)) + int(fortified_bonus.get(troop_type, 0))
	var faction_bonuses: Dictionary = garrison_rules.get("faction_bonus", {
		"tidebound_assembly": {"archers": 5},
		"nine_wells_compact": {"cavalry": 5},
		"hearthfjord_jarldoms": {"infantry": 5, "cavalry": 5},
		"lantern_synod": {"archers": 5}
	})
	var faction_bonus: Dictionary = faction_bonuses.get(defender_owner, {})
	for troop_type in ["infantry", "archers", "cavalry"]:
		defenders[troop_type] = int(defenders.get(troop_type, 0)) + int(faction_bonus.get(troop_type, 0))
	fort_level = clampi(fort_level, 0, 3)
	var fort_level_bonus: Dictionary = garrison_rules.get("fort_level_bonus", {"infantry": 5, "archers": 0, "cavalry": 0})
	for troop_type in ["infantry", "archers", "cavalry"]:
		defenders[troop_type] = int(defenders.get(troop_type, 0)) + int(fort_level_bonus.get(troop_type, 0)) * fort_level
	var enemy_cells: Array[Vector2i] = []
	for y in range(0, 4):
		for x in range(12, 20):
			enemy_cells.append(Vector2i(x, y))
	var enemy_index := 0
	var enemy_commander_assigned := false
	for troop_type in ["infantry", "archers", "cavalry"]:
		var remaining := int(defenders[troop_type])
		var cohort_index := 0
		while remaining > 0 and enemy_index < enemy_cells.size():
			var cohort_count := mini(5, remaining)
			var unit_id := "strategic_defender_%s_%d" % [troop_type, cohort_index]
			var cell: Vector2i = enemy_cells[enemy_index]
			units.append({"character_id": unit_id, "team": "enemy", "cell": [cell.x, cell.y], "facing": 2, "commander": not enemy_commander_assigned and troop_type == "infantry" and not siege_assault, "name": "%s Garrison" % troop_type.capitalize()})
			if troop_type == "infantry" and not siege_assault:
				enemy_commander_assigned = true
			remaining -= cohort_count
			cohort_index += 1
			enemy_index += 1
	if siege_assault:
		units.append({"character_id": "strategic_fort_wall_0", "team": "enemy", "cell": [17, 3], "facing": 2, "name": "Outer Wall"})
		units.append({"character_id": "strategic_fort_wall_1", "team": "enemy", "cell": [17, 7], "facing": 2, "name": "Inner Wall"})
		units.append({"character_id": "strategic_fort_tower", "team": "enemy", "cell": [17, 11], "facing": 2, "name": "Gate Tower"})
		units.append({"character_id": "strategic_fort_gate", "team": "enemy", "cell": [19, 3], "facing": 2, "commander": true, "name": "Fort Gate"})
		units.append({"character_id": "strategic_siege_engine", "team": "player", "cell": [6, 13], "facing": 0, "name": "Battering Ram"})
		units.append({"character_id": "strategic_siege_ballista", "team": "player", "cell": [3, 14], "facing": 0, "name": "Field Ballista"})
		units.append({"character_id": "strategic_siege_trebuchet", "team": "player", "cell": [1, 16], "facing": 0, "name": "Counterweight Trebuchet"})
		units.append({"character_id": "strategic_siege_engineer", "team": "player", "cell": [5, 15], "facing": 0, "name": "Siege Engineer"})
	var battle_sequence := int(state.get("next_battle_id", 1))
	state["next_battle_id"] = battle_sequence + 1
	battle["id"] = "field_army_%s_%s_%d" % [army_id, region_id, battle_sequence]
	battle.erase("reward_rune")
	battle.erase("reward_item")
	battle.erase("world_flag_on_victory")
	battle.erase("world_flag_on_defeat")
	battle["title"] = "Battle for %s" % region_id.replace("_", " ").capitalize()
	battle["briefing"] = ("The besieging army advances behind a battering ram. Break the garrison and take the breached walls." if siege_assault else "Your field army engages the regional garrison. Keep the company and levy cohorts alive; every cohort lost weakens the standing army.")
	battle["units"] = units
	battle["strategic_army_id"] = army_id
	battle["strategic_region_id"] = region_id
	battle["strategic_siege_assault"] = siege_assault
	battle["strategic_fort_level"] = fort_level
	battle["strategic_units"] = strategic_units
	battle["victory_text"] = "The garrison is broken. Your army holds the field."
	battle["defeat_text"] = "The field army is driven back. Survivors withdraw in disorder."
	return battle


static func tactical_battle_database(base_db: Dictionary, battle: Dictionary, warfare_data: Dictionary, army_morale: int = 75) -> Dictionary:
	var db := base_db.duplicate(true)
	var chars: Dictionary = db.get("characters", {}).duplicate(true)
	var classes: Dictionary = db.get("classes", {}).duplicate(true)
	var troop_data: Dictionary = battle.get("strategic_units", {})
	var troop_templates: Dictionary = warfare_data.get("troops", {})
	var engine_templates: Dictionary = warfare_data.get("siege_engines", {})
	var garrison_rules: Dictionary = warfare_data.get("garrisons", {})
	var fortification_templates: Dictionary = warfare_data.get("fortifications", {})
	var engineer_templates: Dictionary = warfare_data.get("siege_engineers", {})
	var engineer_support := false
	for battle_spawn in battle.get("units", []):
		if str(battle_spawn.get("character_id", "")) == "strategic_siege_engineer":
			engineer_support = true
	for spawn in battle.get("units", []):
		var character_id := str(spawn.get("character_id", ""))
		if not character_id.begins_with("strategic_") or chars.has(character_id):
			continue
		var troop_type := ""
		var is_defender := character_id.begins_with("strategic_defender_")
		if troop_data.has(character_id):
			troop_type = str(troop_data[character_id].get("troop_type", "infantry"))
		elif is_defender:
			var parts := character_id.split("_")
			troop_type = str(parts[2]) if parts.size() > 2 else "infantry"
		if character_id.begins_with("strategic_fort_"):
			var fort_key := "fort_gate"
			if character_id == "strategic_fort_wall_0":
				fort_key = "outer_wall"
			elif character_id == "strategic_fort_wall_1":
				fort_key = "inner_wall"
			elif character_id == "strategic_fort_tower":
				fort_key = "gate_tower"
			var fort: Dictionary = fortification_templates.get(fort_key, fortification_templates.get("fort_gate", {}))
			fort = fort.duplicate(true)
			if engineer_support:
				var fort_stats: Dictionary = fort.get("stats", {}).duplicate(true)
				fort_stats["hp"] = maxi(1, int(fort_stats.get("hp", 80)) - 15)
				fort["stats"] = fort_stats
			var fort_class_id := str(fort.get("class_id", "fort_wall"))
			classes[fort_class_id] = (fort.get("class_def", {"name": "Fortification", "move": 0, "jump": 0}) as Dictionary).duplicate(true)
			chars[character_id] = {"name": str(fort.get("name", "Fortification")), "class_id": fort_class_id, "level": 1, "weapon_id": str(fort.get("weapon_id", "hand_axe")), "armor_def": int(fort.get("armor_def", 6)), "armor_res": int(fort.get("armor_res", 4)), "skills": [], "stats": (fort.get("stats", {}) as Dictionary).duplicate(true)}
			continue
		if character_id == "strategic_siege_engineer":
			var engineer: Dictionary = engineer_templates.get("siege_engineer", {})
			var engineer_class_id := str(engineer.get("class_id", "swordsman"))
			chars[character_id] = {"name": str(engineer.get("name", "Siege Engineer")), "class_id": engineer_class_id, "level": 1, "weapon_id": str(engineer.get("weapon_id", "arming_sword")), "armor_def": int(engineer.get("armor_def", 2)), "armor_res": int(engineer.get("armor_res", 2)), "skills": [], "stats": (engineer.get("stats", {}) as Dictionary).duplicate(true)}
			continue
		if character_id.begins_with("strategic_siege_") and character_id != "strategic_siege_engine":
			var engine_key := character_id.trim_prefix("strategic_siege_")
			var engine: Dictionary = engine_templates.get(engine_key, {})
			var engine_class_id := str(engine.get("class_id", "siege_engine"))
			classes[engine_class_id] = (engine.get("class_def", {"name": "Siege Engine", "move": 1, "jump": 0}) as Dictionary).duplicate(true)
			chars[character_id] = {"name": str(engine.get("name", "Siege Engine")), "class_id": engine_class_id, "level": 1, "weapon_id": str(engine.get("weapon_id", "battle_axe")), "armor_def": int(engine.get("armor_def", 4)), "armor_res": int(engine.get("armor_res", 2)), "skills": [], "stats": (engine.get("stats", {}) as Dictionary).duplicate(true)}
			continue
		if character_id == "strategic_siege_engine":
			var ram: Dictionary = engine_templates.get("battering_ram", {"name": "Battering Ram", "class_id": "siege_engine", "weapon_id": "battle_axe", "armor_def": 8, "armor_res": 2, "class_def": {"name": "Battering Ram", "move": 2, "jump": 0}, "stats": {"hp": 70, "mp": 0, "str": 12, "dex": 3, "int": 1, "vit": 14, "spd": 2, "lck": 1, "acc": 70, "eva": 0, "ldr": 0, "mor": 100}})
			if engineer_support:
				ram = ram.duplicate(true)
				var ram_stats: Dictionary = ram.get("stats", {}).duplicate(true)
				ram_stats["hp"] = int(ram_stats.get("hp", 70)) + 10
				ram["stats"] = ram_stats
			var ram_class_id := str(ram.get("class_id", "siege_engine"))
			classes[ram_class_id] = (ram.get("class_def", {"name": "Battering Ram", "move": 2, "jump": 0}) as Dictionary).duplicate(true)
			chars[character_id] = {"name": str(ram.get("name", "Battering Ram")), "class_id": ram_class_id, "level": 1, "weapon_id": str(ram.get("weapon_id", "battle_axe")), "armor_def": int(ram.get("armor_def", 8)), "armor_res": int(ram.get("armor_res", 2)), "skills": [], "stats": (ram.get("stats", {}) as Dictionary).duplicate(true)}
			continue
		var template: Dictionary = troop_templates.get(troop_type, troop_templates.get("infantry", {}))
		var class_id := str(template.get("class_id", "swordsman"))
		var weapon_id := str(template.get("weapon_id", "arming_sword"))
		var stats: Dictionary = template.get("stats", {"hp": 30, "mp": 0, "str": 8, "dex": 7, "int": 2, "vit": 8, "spd": 6, "lck": 3, "acc": 78, "eva": 10, "ldr": 2, "mor": army_morale}).duplicate(true)
		stats["mor"] = 65 if is_defender else clampi(army_morale, 0, 100)
		var armour := int(template.get("armor_def", 2))
		var resistance := int(template.get("armor_res", 1))
		if is_defender:
			var fort_bonus := int(battle.get("strategic_fort_level", 0)) * int(garrison_rules.get("fort_level_armor", 2))
			armour += fort_bonus
			stats["hp"] = int(stats.get("hp", 1)) + fort_bonus * int(garrison_rules.get("fort_level_hp", 2))
			stats["vit"] = int(stats.get("vit", 0)) + fort_bonus
		chars[character_id] = {"name": str(spawn.get("name", template.get("name", troop_type.capitalize()))), "class_id": class_id, "level": 1, "weapon_id": weapon_id, "armor_def": armour, "armor_res": resistance, "skills": [], "stats": stats}
	db["characters"] = chars
	db["classes"] = classes
	return db


static func resolve_siege_battle(state: Dictionary, region_id: String, won: bool) -> bool:
	if not state.get("sieges", {}).has(region_id):
		return false
	var siege: Dictionary = state["sieges"][region_id]
	if int(siege.get("progress", 0)) < 4 or bool(siege.get("captured", false)):
		return false
	if won:
		siege["captured"] = true
		siege["status"] = "captured"
		state["war_exhaustion"] = clampi(int(state.get("war_exhaustion", 0)) + 2, 0, 100)
	else:
		siege["progress"] = 2
		siege["status"] = "repulsed"
		state["war_exhaustion"] = clampi(int(state.get("war_exhaustion", 0)) + 7, 0, 100)
	state["sieges"][region_id] = siege
	_record(state, "siege_battle_result", {"region": region_id, "won": won, "progress": int(siege["progress"]), "captured": bool(siege.get("captured", false))})
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


## Resolves each generated tactical battle at most once, even if a result screen or save is replayed.
static func resolve_tactical_battle(state: Dictionary, battle_id: String, army_id: String, casualties: Dictionary, won: bool) -> bool:
	if battle_id == "" or state.get("resolved_battle_ids", []).has(battle_id):
		return false
	if not apply_tactical_result(state, army_id, casualties, won):
		return false
	var resolved: Array = state.get("resolved_battle_ids", [])
	resolved.append(battle_id)
	state["resolved_battle_ids"] = resolved.slice(maxi(0, resolved.size() - 100))
	_record(state, "strategic_battle_resolved", {"battle_id": battle_id, "army": army_id})
	return true


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

## Paid direct trade links between controlled atlas regions produce seasonal treasury income.
static func establish_trade_route(state: Dictionary, origin: String, destination: String, controlled: Array, adjacency: Dictionary) -> bool:
	if not bool(state.get("unlocked", false)) or origin == destination:
		return false
	if not controlled.has(origin) or not controlled.has(destination) or not adjacency.get(origin, []).has(destination):
		return false
	var route_id := origin + "|" + destination if origin < destination else destination + "|" + origin
	if state.get("trade_routes", {}).has(route_id) or int(state.get("treasury", 0)) < 100:
		return false
	state["treasury"] = int(state["treasury"]) - 100
	state["trade_routes"][route_id] = {"origin": origin, "destination": destination, "income": 20}
	_record(state, "trade_route_established", {"route": route_id})
	return true

static func close_trade_route(state: Dictionary, route_id: String) -> bool:
	if not state.get("trade_routes", {}).has(route_id):
		return false
	state["trade_routes"].erase(route_id)
	_record(state, "trade_route_closed", {"route": route_id})
	return true

## NPC diplomacy is deterministic and excludes the player faction; it never transfers territory.
static func advance_faction_ai(faction_state: Dictionary, faction_ids: Array, player_faction: String = "house_dunmarrow") -> Dictionary:
	var declarations: Array = []
	var treaties: Array = []
	for i in range(faction_ids.size()):
		for j in range(i + 1, faction_ids.size()):
			var a := str(faction_ids[i])
			var b := str(faction_ids[j])
			if a == player_faction or b == player_faction:
				continue
			var relation_value := FactionSystem.relation(faction_state, a, b)
			var key := a + "|" + b if a < b else b + "|" + a
			var current := str(faction_state.get("diplomacy", {}).get(key, "neutral"))
			if relation_value <= -80 and current != "war":
				if FactionSystem.set_diplomatic_state(faction_state, a, b, "war"):
					declarations.append({"from": a, "against": b, "relation": relation_value})
			elif relation_value >= 70 and current == "neutral":
				if FactionSystem.set_diplomatic_state(faction_state, a, b, "trade_pact"):
					treaties.append({"factions": [a, b], "relation": relation_value})
	return {"declarations": declarations, "treaties": treaties}

## Office bonuses are deterministic; known trait tags add role-specific benefits.
static func council_effects(state: Dictionary, character_profiles: Dictionary = {}) -> Dictionary:
	var effects := {"income": 0, "food": 0, "stability": 0, "public_order": 0, "war_exhaustion": 0}
	var role_bonus := {"steward": {"income": 8}, "marshal": {"war_exhaustion": -2}, "spymaster": {"public_order": 1}, "chancellor": {"stability": 2}, "high_priest": {"food": 2, "public_order": 1}}
	for role in state.get("council", {}).keys():
		var profile: Dictionary = character_profiles.get(str(state["council"][role]), {})
		var traits: Array = profile.get("traits", [])
		for trait_variant in traits:
			var trait_id := str(trait_variant).to_lower()
			if trait_id in ["administrator", "scholar", "diligent"] and role == "steward":
				effects["income"] += 5
			elif trait_id in ["strategist", "brave", "disciplined"] and role == "marshal":
				effects["war_exhaustion"] -= 2
			elif trait_id in ["silver_tongued", "diplomat", "charismatic"] and role == "chancellor":
				effects["stability"] += 2
			elif trait_id in ["devout", "compassionate"] and role == "high_priest":
				effects["public_order"] += 2
			elif trait_id in ["cunning", "observant"] and role == "spymaster":
				effects["public_order"] += 2
		for stat in role_bonus.get(role, {}).keys():
			effects[stat] += int(role_bonus[role][stat])
	return effects

static func rebellion_assessment(state: Dictionary, controlled: Array) -> Dictionary:
	var pressure := 0
	if int(state.get("public_order", 0)) < 35:
		pressure += int((35 - int(state["public_order"])) / 2)
	if int(state.get("stability", 0)) < 30:
		pressure += int((30 - int(state["stability"])) / 2)
	if int(state.get("legitimacy", 0)) < 25:
		pressure += int((25 - int(state["legitimacy"])) / 3)
	state["rebellion_risk"] = clampi(int(state.get("rebellion_risk", 0)) + pressure - (3 if pressure == 0 else 0), 0, 100)
	var alerts: Array = []
	if int(state["rebellion_risk"]) >= 60 and not controlled.is_empty():
		var candidates := controlled.duplicate()
		candidates.sort()
		var candidate := str(candidates[int(state.get("turn", 0)) % candidates.size()])
		alerts.append({"province": candidate, "risk": int(state["rebellion_risk"]), "status": "unrest"})
	state["rebellion_alerts"] = alerts
	return {"risk": int(state["rebellion_risk"]), "alerts": alerts}

## Pure forecast: run the exact seasonal rules against a deep copy and return the report without mutating the live campaign.
static func preview_season(state: Dictionary, province_ids: Array, adjacency: Dictionary = {}, character_profiles: Dictionary = {}) -> Dictionary:
	var projected: Dictionary = state.duplicate(true)
	var before_treasury := int(projected.get("treasury", 0))
	var before_food := int(projected.get("food", 0))
	var before_manpower := int(projected.get("manpower", 0))
	var report := advance_season(projected, province_ids, adjacency, character_profiles)
	if not bool(report.get("ok", false)):
		return report
	report["treasury_after"] = int(projected.get("treasury", 0))
	report["food_after"] = int(projected.get("food", 0))
	report["manpower_after"] = int(projected.get("manpower", 0))
	report["treasury_change"] = int(projected.get("treasury", 0)) - before_treasury
	report["food_change_actual"] = int(projected.get("food", 0)) - before_food
	report["manpower_change"] = int(projected.get("manpower", 0)) - before_manpower
	return report

static func suppress_rebellion(state: Dictionary, cost: int = 80) -> bool:
	if not bool(state.get("unlocked", false)) or cost <= 0 or int(state.get("rebellion_risk", 0)) < 20 or int(state.get("treasury", 0)) < cost:
		return false
	state["treasury"] = int(state["treasury"]) - cost
	state["rebellion_risk"] = maxi(0, int(state.get("rebellion_risk", 0)) - 25)
	state["public_order"] = mini(100, int(state.get("public_order", 0)) + 10)
	state["rebellion_alerts"] = []
	_record(state, "unrest_suppressed", {"cost": cost, "risk": state["rebellion_risk"]})
	return true

static func negotiate_peace(faction_state: Dictionary, empire_state: Dictionary, faction_a: String, faction_b: String, gold_offer: int = 0) -> bool:
	if gold_offer < 0 or int(empire_state.get("treasury", 0)) < gold_offer:
		return false
	var key := faction_a + "|" + faction_b if faction_a < faction_b else faction_b + "|" + faction_a
	if str(faction_state.get("diplomacy", {}).get(key, "neutral")) != "war":
		return false
	var relation_value := FactionSystem.relation(faction_state, faction_a, faction_b)
	var acceptance := relation_value + floori(float(empire_state.get("war_exhaustion", 0)) / 2.0) + floori(float(gold_offer) / 10.0)
	if acceptance < 25:
		return false
	if not FactionSystem.set_diplomatic_state(faction_state, faction_a, faction_b, "neutral"):
		return false
	empire_state["treasury"] = int(empire_state["treasury"]) - gold_offer
	empire_state["war_exhaustion"] = maxi(0, int(empire_state.get("war_exhaustion", 0)) - 10)
	FactionSystem.adjust_relation(faction_state, faction_a, faction_b, 10, "negotiated peace")
	_record(empire_state, "negotiated_peace", {"faction": faction_b, "gold": gold_offer})
	return true
