extends RefCounted
## Pure campaign-politics rules. This layer stores state only; authored story systems decide when
## diplomatic actions and territorial changes are offered to the player.

const MIN_RELATION := -100
const MAX_RELATION := 100
const ALLIANCE_THRESHOLD := 50
const DIPLOMATIC_STATES := ["neutral", "non_aggression", "trade_pact", "alliance", "war"]
const HISTORY_LIMIT := 100


static func new_campaign_state(definitions: Dictionary) -> Dictionary:
    var faction_ids: Array = []
    for entry in definitions.get("factions", []):
        if typeof(entry) == TYPE_DICTIONARY:
            var faction_id := str(entry.get("id", ""))
            if faction_id != "":
                faction_ids.append(faction_id)
    faction_ids.sort()
    var relations: Dictionary = {}
    var diplomacy: Dictionary = {}
    for i in range(faction_ids.size()):
        for j in range(i + 1, faction_ids.size()):
            var key := _pair_key(str(faction_ids[i]), str(faction_ids[j]))
            relations[key] = 0
            diplomacy[key] = "neutral"
    var territories: Dictionary = {}
    for region_id in definitions.get("regions", {}).keys():
        var region: Dictionary = definitions["regions"][region_id]
        territories[str(region_id)] = {
            "owner": str(region.get("owner", "")),
            "status": str(region.get("status", "held"))
        }
    return {
        "version": 1,
        "relations": relations,
        "diplomacy": diplomacy,
        "territories": territories,
        "claims": {},
        "history": []
    }


static func normalize_state(raw: Dictionary, definitions: Dictionary) -> Dictionary:
    var state := new_campaign_state(definitions)
    var saved_relations: Variant = raw.get("relations", {})
    var saved_diplomacy: Variant = raw.get("diplomacy", {})
    var saved_territories: Variant = raw.get("territories", {})
    if typeof(saved_relations) == TYPE_DICTIONARY:
        for key in saved_relations.keys():
            if state["relations"].has(str(key)):
                state["relations"][str(key)] = clampi(int(saved_relations[key]), MIN_RELATION, MAX_RELATION)
    if typeof(saved_diplomacy) == TYPE_DICTIONARY:
        for key in saved_diplomacy.keys():
            if state["diplomacy"].has(str(key)) and DIPLOMATIC_STATES.has(str(saved_diplomacy[key])):
                state["diplomacy"][str(key)] = str(saved_diplomacy[key])
    if typeof(saved_territories) == TYPE_DICTIONARY:
        for region_id in saved_territories.keys():
            if not state["territories"].has(str(region_id)) or typeof(saved_territories[region_id]) != TYPE_DICTIONARY:
                continue
            var saved: Dictionary = saved_territories[region_id]
            var owner := str(saved.get("owner", ""))
            if owner == "" or _has_faction(definitions, owner):
                state["territories"][str(region_id)] = {
                    "owner": owner,
                    "status": str(saved.get("status", "held"))
                }
    var saved_claims: Variant = raw.get("claims", {})
    if typeof(saved_claims) == TYPE_DICTIONARY:
        for region_id in saved_claims.keys():
            var claimant := str(saved_claims[region_id])
            if state["territories"].has(str(region_id)) and _state_has_faction(state, claimant):
                state["claims"][str(region_id)] = claimant
    var history: Variant = raw.get("history", [])
    if typeof(history) == TYPE_ARRAY:
        state["history"] = history.duplicate(true).slice(maxi(0, history.size() - HISTORY_LIMIT))
    return state


static func relation(state: Dictionary, faction_a: String, faction_b: String) -> int:
    if faction_a == faction_b or faction_a == "" or faction_b == "":
        return MAX_RELATION
    return int(state.get("relations", {}).get(_pair_key(faction_a, faction_b), 0))


static func adjust_relation(state: Dictionary, faction_a: String, faction_b: String, amount: int, reason: String = "") -> bool:
    var key := _pair_key(faction_a, faction_b)
    if faction_a == faction_b or not (state.get("relations", {}) as Dictionary).has(key):
        return false
    var relations: Dictionary = state["relations"]
    relations[key] = clampi(int(relations[key]) + amount, MIN_RELATION, MAX_RELATION)
    if reason != "":
        _record(state, {"kind":"relation", "factions":[faction_a, faction_b], "value":relations[key], "reason":reason})
    return true


static func set_diplomatic_state(state: Dictionary, faction_a: String, faction_b: String, next_state: String) -> bool:
    var key := _pair_key(faction_a, faction_b)
    if faction_a == faction_b or not DIPLOMATIC_STATES.has(next_state) or not (state.get("diplomacy", {}) as Dictionary).has(key):
        return false
    if next_state == "alliance" and relation(state, faction_a, faction_b) < ALLIANCE_THRESHOLD:
        return false
    state["diplomacy"][key] = next_state
    _record(state, {"kind":"diplomacy", "factions":[faction_a, faction_b], "state":next_state})
    return true


static func transfer_region(state: Dictionary, region_id: String, new_owner: String, cause: String) -> bool:
    if not (state.get("territories", {}) as Dictionary).has(region_id):
        return false
    if new_owner != "" and not _state_has_faction(state, new_owner):
        return false
    var territory: Dictionary = state["territories"][region_id]
    var old_owner := str(territory.get("owner", ""))
    if old_owner == new_owner:
        return false
    territory["owner"] = new_owner
    territory["status"] = "held" if new_owner != "" else "unclaimed"
    state.get("claims", {}).erase(region_id)
    _record(state, {"kind":"territory", "region":region_id, "from":old_owner, "to":new_owner, "cause":cause})
    return true


static func claim_region(state: Dictionary, faction_id: String, region_id: String, adjacency: Dictionary) -> bool:
    if not _state_has_faction(state, faction_id) or not state.get("territories", {}).has(region_id):
        return false
    var territory: Dictionary = state["territories"][region_id]
    if str(territory.get("owner", "")) == faction_id or state.get("claims", {}).has(region_id):
        return false
    var adjacent_hold := false
    for neighbor in adjacency.get(region_id, []):
        var neighbor_state: Dictionary = state.get("territories", {}).get(str(neighbor), {})
        if str(neighbor_state.get("owner", "")) == faction_id and str(neighbor_state.get("status", "held")) == "held":
            adjacent_hold = true
            break
    if not adjacent_hold:
        return false
    state["claims"][region_id] = faction_id
    _record(state, {"kind":"claim", "faction":faction_id, "region":region_id})
    return true


static func _pair_key(faction_a: String, faction_b: String) -> String:
    var pair: Array[String] = [faction_a, faction_b]
    pair.sort()
    return pair[0] + "|" + pair[1]


static func _has_faction(definitions: Dictionary, faction_id: String) -> bool:
    for entry in definitions.get("factions", []):
        if typeof(entry) == TYPE_DICTIONARY and str(entry.get("id", "")) == faction_id:
            return true
    return false


static func _state_has_faction(state: Dictionary, faction_id: String) -> bool:
    for key in state.get("relations", {}).keys():
        var parts := str(key).split("|")
        if parts.has(faction_id):
            return true
    return false


static func _record(state: Dictionary, event: Dictionary) -> void:
    var history: Array = state.get("history", [])
    history.append(event)
    if history.size() > HISTORY_LIMIT:
        history.pop_front()
    state["history"] = history
