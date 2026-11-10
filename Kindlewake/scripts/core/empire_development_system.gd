extends RefCounted
## Resource-backed holding development, recruitment and objective siege progression.
## All mutations are deterministic and stored in the existing campaign world_flags.

const BUILDINGS := {
    "farm": {"name":"Granary Farms","cost_gold":45,"cost_materials":4,"yield_provisions":3,"yield_gold":0,"defense":0},
    "workshop": {"name":"Civic Workshop","cost_gold":60,"cost_materials":6,"yield_provisions":0,"yield_gold":2,"defense":0},
    "trade_post": {"name":"Chartered Trade Post","cost_gold":75,"cost_materials":5,"yield_provisions":0,"yield_gold":5,"defense":0},
    "fortifications": {"name":"Stone Fortifications","cost_gold":65,"cost_materials":8,"yield_provisions":0,"yield_gold":0,"defense":2}
}
const TROOPS := {
    "levy": {"name":"Frontier Levy","gold":18,"provisions":3,"power":1},
    "archer": {"name":"March Archer","gold":32,"provisions":4,"power":2},
    "knight": {"name":"Household Knight","gold":65,"provisions":7,"power":4}
}

static func _player_holds(id: String, flags: Dictionary) -> bool:
    return id != "" and bool(flags.get("holding_claimed_" + id, false)) and str(flags.get("holding_owner_" + id, "house_dunmarrow")) == "house_dunmarrow"

static func upgrade_building(holding_id: String, building_id: String, flags: Dictionary, treasury: int) -> Dictionary:
    if not _player_holds(holding_id, flags):
        return {"ok":false,"reason":"Only a player-administered holding can be developed."}
    if not BUILDINGS.has(building_id):
        return {"ok":false,"reason":"Unknown building."}
    var def: Dictionary = BUILDINGS[building_id]
    var key := "holding_building_" + holding_id + "_" + building_id
    var tier := clampi(int(flags.get(key, 0)), 0, 3)
    if tier >= 3:
        return {"ok":false,"reason":"This building has reached its maximum tier."}
    var multiplier := tier + 1
    var gold_cost := int(def.cost_gold) * multiplier
    var material_cost := int(def.cost_materials) * multiplier
    var materials := int(flags.get("empire_stockpile_materials", 0))
    if treasury < gold_cost or materials < material_cost:
        return {"ok":false,"reason":"Insufficient gold or materials. Need %d gold and %d materials." % [gold_cost, material_cost]}
    flags[key] = tier + 1
    flags["empire_stockpile_materials"] = materials - material_cost
    return {"ok":true,"holding":holding_id,"building":building_id,"tier":tier + 1,"gold_cost":gold_cost,"materials_cost":material_cost,"treasury_after":treasury-gold_cost}

static func recruit(holding_id: String, troop_id: String, amount: int, flags: Dictionary, treasury: int) -> Dictionary:
    if not _player_holds(holding_id, flags):
        return {"ok":false,"reason":"Recruitment requires a player-administered holding."}
    if not TROOPS.has(troop_id):
        return {"ok":false,"reason":"Unknown troop type."}
    if amount <= 0:
        return {"ok":false,"reason":"Recruitment amount must be at least one."}
    var count := mini(amount, 20)
    var troop: Dictionary = TROOPS[troop_id]
    var gold_cost := int(troop.gold) * count
    var provisions_cost := int(troop.provisions) * count
    var provisions := int(flags.get("empire_stockpile_provisions", 0))
    if treasury < gold_cost or provisions < provisions_cost:
        return {"ok":false,"reason":"Insufficient gold or provisions. Need %d gold and %d provisions." % [gold_cost, provisions_cost]}
    var army_key := "holding_recruits_" + holding_id
    var army: Dictionary = flags.get(army_key, {})
    army = army.duplicate(true)
    army[troop_id] = int(army.get(troop_id, 0)) + count
    flags[army_key] = army
    flags["empire_stockpile_provisions"] = provisions - provisions_cost
    return {"ok":true,"holding":holding_id,"troop":troop_id,"recruited":count,"gold_cost":gold_cost,"provisions_cost":provisions_cost,"treasury_after":treasury-gold_cost,"army":army}

static func assign_recruits_to_garrison(holding_id: String, troop_id: String, amount: int, flags: Dictionary) -> Dictionary:
    if not _player_holds(holding_id, flags):
        return {"ok":false,"reason":"Only a player holding can receive troops."}
    var key := "holding_recruits_" + holding_id
    var army: Dictionary = flags.get(key, {}).duplicate(true)
    var available := int(army.get(troop_id, 0))
    var count := clampi(amount, 0, available)
    if count <= 0:
        return {"ok":false,"reason":"No recruited troops are available to assign."}
    army[troop_id] = available - count
    flags[key] = army
    flags["holding_garrison_" + holding_id] = int(flags.get("holding_garrison_" + holding_id, 0)) + count
    return {"ok":true,"assigned":count,"garrison":int(flags["holding_garrison_" + holding_id])}

static func start_siege(holding_id: String, objective_id: String, required_progress: int, flags: Dictionary) -> Dictionary:
    if not _player_holds(holding_id, flags):
        return {"ok":false,"reason":"A siege can only be organized from a player holding."}
    if objective_id == "" or required_progress < 1:
        return {"ok":false,"reason":"A valid siege objective is required."}
    var key := "siege_" + objective_id
    if flags.has(key) and not ["resolved", "repelled"].has(str(flags[key].get("status", ""))):
        return {"ok":false,"reason":"This siege is already in progress."}
    flags[key] = {"origin":holding_id,"progress":0,"required":clampi(required_progress,1,20),"status":"in_progress","history":[]}
    return {"ok":true,"siege":flags[key].duplicate(true)}

static func progress_siege(objective_id: String, progress: int, flags: Dictionary) -> Dictionary:
    var key := "siege_" + objective_id
    if not flags.has(key) or progress <= 0:
        return {"ok":false,"reason":"No active siege accepts that progress."}
    var state: Dictionary = flags[key].duplicate(true)
    if str(state.get("status","")) != "in_progress":
        return {"ok":false,"reason":"This siege is not active."}
    var before := int(state.get("progress",0))
    state["progress"] = mini(int(state.get("required",1)), before + progress)
    state["history"].append({"from":before,"to":int(state.progress)})
    if int(state.progress) >= int(state.required):
        state["status"] = "objective_complete"
    flags[key] = state
    return {"ok":true,"siege":state.duplicate(true),"completed":str(state.status)=="objective_complete"}

static func resolve_siege(objective_id: String, won: bool, flags: Dictionary) -> Dictionary:
    var key := "siege_" + objective_id
    if not flags.has(key):
        return {"ok":false,"reason":"Unknown siege objective."}
    var state: Dictionary = flags[key].duplicate(true)
    if won and str(state.get("status","")) != "objective_complete":
        return {"ok":false,"reason":"Complete the siege objective before recording a victory."}
    if not won and str(state.get("status","")) != "in_progress":
        return {"ok":false,"reason":"Only an active siege can be recorded as repelled."}
    state["status"] = "resolved" if won else "repelled"
    flags[key] = state
    return {"ok":true,"status":str(state.status),"origin":str(state.get("origin",""))}
