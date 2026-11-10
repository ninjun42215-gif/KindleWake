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

static func deploy_recruits_to_battle(holding_id: String, battle_definition: Dictionary, flags: Dictionary) -> Dictionary:
    if not _player_holds(holding_id, flags):
        return battle_definition
    var troop_characters := {"levy":"frontier_levy", "archer":"march_archer", "knight":"household_knight"}
    var reserves: Dictionary = (flags.get("holding_recruits_" + holding_id, {}) as Dictionary).duplicate(true)
    var terrain: Array = battle_definition.get("terrain", [])
    if terrain.is_empty():
        return battle_definition
    var occupied: Dictionary = {}
    var spawns: Array = (battle_definition.get("units", []) as Array).duplicate(true)
    for spawn in spawns:
        var spawn_cell: Array = spawn.get("cell", [])
        if spawn_cell.size() >= 2:
            occupied[Vector2i(int(spawn_cell[0]), int(spawn_cell[1]))] = true
    var deployed: Dictionary = {}
    var added := 0
    for troop_id in ["levy", "archer", "knight"]:
        var available := mini(20, maxi(0, int(reserves.get(troop_id, 0))))
        while available > 0 and added < 4:
            var chosen := Vector2i(-1, -1)
            for y in range(8, terrain.size()):
                var row := str(terrain[y])
                for x in range(3, row.length()):
                    var candidate_cell := Vector2i(x, y)
                    var terrain_code := row.substr(x, 1)
                    if not occupied.has(candidate_cell) and not ["#", "~"].has(terrain_code):
                        chosen = candidate_cell
                        break
                if chosen.x >= 0:
                    break
            if chosen.x < 0:
                break
            spawns.append({"character_id":str(troop_characters[troop_id]),"team":"player","cell":[chosen.x,chosen.y],"facing":0})
            occupied[chosen] = true
            available -= 1
            added += 1
            deployed[troop_id] = int(deployed.get(troop_id, 0)) + 1
        reserves[troop_id] = available
    if added > 0:
        flags["holding_recruits_" + holding_id] = reserves
        battle_definition["units"] = spawns
        battle_definition["recruit_origin_holding"] = holding_id
        battle_definition["deployed_recruit_counts"] = deployed
    return battle_definition


static func recover_deployed_recruits(battle_units: Array, battle_definition: Dictionary, flags: Dictionary) -> Dictionary:
    var holding_id := str(battle_definition.get("recruit_origin_holding", ""))
    if holding_id == "":
        return {"recovered":0,"lost":0}
    var troop_characters := {"frontier_levy":"levy", "march_archer":"archer", "household_knight":"knight"}
    var deployed: Dictionary = battle_definition.get("deployed_recruit_counts", {})
    var recovered: Dictionary = {}
    for raw in battle_units:
        var unit = raw
        if unit.team == "player" and unit.is_alive() and troop_characters.has(unit.character_id):
            var troop_id := str(troop_characters[unit.character_id])
            recovered[troop_id] = int(recovered.get(troop_id, 0)) + 1
    var reserves: Dictionary = (flags.get("holding_recruits_" + holding_id, {}) as Dictionary).duplicate(true)
    var recovered_total := 0
    var deployed_total := 0
    for troop_id in deployed:
        var count := int(deployed[troop_id])
        deployed_total += count
        reserves[troop_id] = int(reserves.get(troop_id, 0)) + int(recovered.get(troop_id, 0))
        recovered_total += int(recovered.get(troop_id, 0))
    flags["holding_recruits_" + holding_id] = reserves
    return {"recovered":recovered_total,"lost":deployed_total-recovered_total}


static func capture_holding_after_siege(target_holding_id: String, source_holding_id: String, objective_id: String, flags: Dictionary, holding_definitions: Array) -> Dictionary:
    var siege: Dictionary = flags.get("siege_" + objective_id, {})
    if str(siege.get("status", "")) != "resolved" or str(siege.get("origin", "")) != source_holding_id:
        return {"ok":false,"reason":"A resolved victory from the recorded staging holding is required."}
    var target: Dictionary = {}
    for definition in holding_definitions:
        if str(definition.get("id", "")) == target_holding_id:
            target = definition
            break
    if target.is_empty():
        return {"ok":false,"reason":"Unknown holding."}
    if bool(flags.get("holding_claimed_" + target_holding_id, false)) and str(flags.get("holding_owner_" + target_holding_id, "")) == PLAYER_FACTION:
        return {"ok":false,"reason":"This holding is already administered by the player."}
    var old_owner := str(flags.get("holding_owner_" + target_holding_id, target.get("owner", "unknown")))
    flags["holding_claimed_" + target_holding_id] = true
    flags["holding_owner_" + target_holding_id] = PLAYER_FACTION
    flags["holding_status_" + target_holding_id] = "provisional"
    flags["holding_stability_" + target_holding_id] = 25
    flags["holding_governance_" + target_holding_id] = "appointed_warden"
    flags["holding_previous_owner_" + target_holding_id] = old_owner
    var history: Array = flags.get("holding_history", [])
    history.append({"holding":target_holding_id,"old_owner":old_owner,"new_owner":PLAYER_FACTION,"cause":"siege_victory","source":source_holding_id,"empire_turn":int(flags.get("empire_turn", 0))})
    flags["holding_history"] = history
    flags["holding_captured_by_siege_" + target_holding_id] = true
    return {"ok":true,"old_owner":old_owner,"new_owner":PLAYER_FACTION,"status":"provisional"}


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
