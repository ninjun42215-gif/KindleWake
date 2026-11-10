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
	"aqueduct": {"cost": 240, "food": 10, "tax": 0, "stability": 2, "name": "Aqueduct"}
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
		"buildings": {}, "armies": {}, "turn": 0, "history": []
	}


static func normalize_state(raw: Dictionary) -> Dictionary:
	var state := new_state()
	for key in ["unlocked", "realm_name", "treasury", "food", "manpower", "stability", "legitimacy", "public_order", "turn"]:
		if raw.has(key):
			state[key] = raw[key]
	for stat in ["treasury", "food", "manpower", "turn"]:
		state[stat] = maxi(0, int(state[stat]))
	for stat in ["stability", "legitimacy", "public_order"]:
		state[stat] = clampi(int(state[stat]), MIN_STAT, MAX_STAT)
	state["tax_rate"] = str(raw.get("tax_rate", "normal"))
	if not TAX_RATES.has(state["tax_rate"]):
		state["tax_rate"] = "normal"
	for key in ["policies", "council", "governors", "provinces", "buildings", "armies"]:
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
	return {"troops": total, "upkeep": upkeep, "food": food, "garrisoned_provinces": provinces, "readiness": 100 if total == 0 else clampi(int(state.get("food", 0) * 100 / maxi(1, food)), 0, 100)}


## Advance one strategic season. The caller controls when story time advances.
static func advance_season(state: Dictionary, province_ids: Array) -> Dictionary:
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
	state["turn"] = int(state["turn"]) + 1
	var report := {"ok": true, "season": state["turn"], "income": income, "upkeep": upkeep, "food_change": food_gain - province_ids.size() * 8 - military_food, "defence": defence, "military_upkeep": int(military["upkeep"]), "military_food": military_food, "troops": int(military["troops"]), "food_shortage": food_shortage}
	_record(state, "season", report)
	return report


static func _record(state: Dictionary, kind: String, details: Dictionary) -> void:
	var history: Array = state.get("history", [])
	history.append({"kind": kind, "turn": int(state.get("turn", 0)), "details": details.duplicate(true)})
	state["history"] = history.slice(maxi(0, history.size() - HISTORY_LIMIT))
