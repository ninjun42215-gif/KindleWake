class_name RegionSaveState
extends RefCounted
## Pure, dependency-free normalization for campaign region coordinates and legacy saves.

static func from_payload(payload: Dictionary) -> Dictionary:
    var raw_pos: Array = payload.get("world_pos", [0.0, 0.0])
    var pos := Vector2.ZERO
    if raw_pos.size() >= 2:
        pos = Vector2(float(raw_pos[0]), float(raw_pos[1]))
    var region_id: String = str(payload.get("active_region_id", "sethmarch"))
    var positions: Dictionary = (payload.get("world_positions", {}) as Dictionary).duplicate(true)
    if not positions.has("sethmarch"):
        positions["sethmarch"] = [pos.x, pos.y] if region_id == "sethmarch" else [0.0, 0.0]
    if region_id != "sethmarch" and not positions.has(region_id):
        positions[region_id] = [pos.x, pos.y]
    return {"active_region_id": region_id, "world_positions": positions, "world_pos": pos}

static func is_valid_campaign_payload(payload: Dictionary) -> bool:
    if not bool(payload.get("campaign", false)):
        return false
    if typeof(payload.get("party")) != TYPE_DICTIONARY:
        return false
    var party_data: Dictionary = payload["party"]
    if typeof(party_data.get("roster")) != TYPE_ARRAY or typeof(party_data.get("sheets")) != TYPE_DICTIONARY:
        return false
    if typeof(party_data.get("inventory", {})) != TYPE_DICTIONARY:
        return false
    if typeof(party_data.get("sigil_inv", [])) != TYPE_ARRAY:
        return false
    var roster: Array = party_data["roster"]
    var sheets: Dictionary = party_data["sheets"]
    if roster.is_empty():
        return false
    var seen: Dictionary = {}
    for entry in roster:
        var member_id := str(entry)
        if member_id == "" or seen.has(member_id) or typeof(sheets.get(member_id)) != TYPE_DICTIONARY:
            return false
        seen[member_id] = true
        var member: Dictionary = sheets[member_id]
        if str(member.get("character_id", member_id)) != member_id:
            return false
        if typeof(member.get("base_stats", {})) != TYPE_DICTIONARY:
            return false
        if typeof(member.get("skills", [])) != TYPE_ARRAY:
            return false
        if typeof(member.get("equipment", {})) != TYPE_DICTIONARY:
            return false
        if typeof(member.get("sigils", {})) != TYPE_DICTIONARY:
            return false
        if typeof(member.get("traits", [])) != TYPE_ARRAY or typeof(member.get("trait_history", [])) != TYPE_ARRAY:
            return false
        if typeof(member.get("enhancements", {})) != TYPE_DICTIONARY or typeof(member.get("reward", {})) != TYPE_DICTIONARY:
            return false
        var sigils: Dictionary = member.get("sigils", {})
        for group in ["weapon", "armor"]:
            if typeof(sigils.get(group, [])) != TYPE_ARRAY:
                return false
        var personality_value: Variant = member.get("personality", {})
        if typeof(personality_value) != TYPE_DICTIONARY:
            return false
        var personality: Dictionary = personality_value
        if typeof(personality.get("memories", [])) != TYPE_ARRAY:
            return false
        if typeof(personality.get("behavior", {})) != TYPE_DICTIONARY or typeof(personality.get("ambition", {})) != TYPE_DICTIONARY:
            return false
    if typeof(payload.get("creation_profile", {})) != TYPE_DICTIONARY:
        return false
    if typeof(payload.get("world_flags", {})) != TYPE_DICTIONARY:
        return false
    if typeof(payload.get("world_pos", [0.0, 0.0])) != TYPE_ARRAY:
        return false
    var pos: Array = payload.get("world_pos", [0.0, 0.0])
    if pos.size() < 2 or typeof(pos[0]) not in [TYPE_FLOAT, TYPE_INT] or typeof(pos[1]) not in [TYPE_FLOAT, TYPE_INT]:
        return false
    if typeof(payload.get("world_positions", {})) != TYPE_DICTIONARY:
        return false
    return true
