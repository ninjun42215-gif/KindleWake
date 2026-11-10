extends RefCounted
## Location-level sovereignty. Taking one keep never silently transfers an entire atlas region.

const HISTORY_LIMIT := 100
const PLAYER_FACTION := "house_dunmarrow"


static func inspect(definition: Dictionary, world_flags: Dictionary) -> Dictionary:
    var id := str(definition.get("id", ""))
    if id == "":
        return {"ok": false, "available": false, "reason": "This holding has no valid identity."}
    var current_owner := str(world_flags.get("holding_owner_" + id, definition.get("owner", "")))
    var claimed := bool(world_flags.get("holding_claimed_" + id, false))
    var required_flag := str(definition.get("claim_requires_flag", ""))
    var requirement_met := required_flag == "" or bool(world_flags.get(required_flag, false))
    if claimed:
        return {"ok": true, "available": false, "claimed": true, "owner": current_owner, "status": str(world_flags.get("holding_status_" + id, "provisional")), "reason": "Your administration is already established."}
    if not requirement_met:
        return {"ok": true, "available": false, "claimed": false, "owner": current_owner, "status": "contested", "reason": str(definition.get("claim_requirement_text", "The local objective must be resolved before sovereignty can be negotiated."))}
    return {"ok": true, "available": true, "claimed": false, "owner": current_owner, "status": "contested", "reason": ""}


static func claim(definition: Dictionary, world_flags: Dictionary, player_faction: String = PLAYER_FACTION) -> Dictionary:
    var id := str(definition.get("id", ""))
    if id == "" or player_faction == "":
        return {"ok": false, "reason": "A holding and claimant are required."}
    var current := inspect(definition, world_flags)
    if not bool(current.get("ok", false)) or not bool(current.get("available", false)):
        return {"ok": false, "reason": str(current.get("reason", "This holding cannot be claimed."))}
    var owner_key := "holding_owner_" + id
    world_flags[owner_key] = player_faction
    world_flags["holding_status_" + id] = "provisional"
    world_flags["holding_claimed_" + id] = true
    world_flags["holding_stability_" + id] = 35
    world_flags["holding_governance_" + id] = str(definition.get("governance", "appointed_warden"))
    var history: Array = world_flags.get("holding_history", [])
    history.append({"holding": id, "from": str(current.get("owner", "")), "to": player_faction, "method": str(definition.get("capture_method", definition.get("capture", "occupation"))), "status": "provisional"})
    if history.size() > HISTORY_LIMIT:
        history.pop_front()
    world_flags["holding_history"] = history
    return {"ok": true, "owner": player_faction, "status": "provisional", "stability": 35, "governance": str(world_flags["holding_governance_" + id])}
