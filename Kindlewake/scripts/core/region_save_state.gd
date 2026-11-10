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
    if not _is_number(party_data.get("gold", 0)) or int(party_data.get("gold", 0)) < 0:
        return false

    var inventory: Dictionary = party_data.get("inventory", {})
    for item_id in inventory.keys():
        if str(item_id).is_empty() or not _is_number(inventory[item_id]) or int(inventory[item_id]) < 0:
            return false
    if not _is_valid_instance_array(party_data.get("sigil_inv", [])):
        return false

    var roster: Array = party_data["roster"]
    var sheets: Dictionary = party_data["sheets"]
    if roster.is_empty():
        return false
    var seen: Dictionary = {}
    for entry in roster:
        if typeof(entry) != TYPE_STRING:
            return false
        var member_id := str(entry)
        if member_id.is_empty() or seen.has(member_id) or typeof(sheets.get(member_id)) != TYPE_DICTIONARY:
            return false
        seen[member_id] = true

        var member: Dictionary = sheets[member_id]
        if str(member.get("character_id", member_id)) != member_id:
            return false
        if typeof(member.get("base_stats", {})) != TYPE_DICTIONARY or not _is_valid_numeric_dictionary(member.get("base_stats", {})):
            return false
        if not _is_string_array(member.get("skills", [])):
            return false
        if not _is_string_dictionary(member.get("equipment", {})):
            return false
        if not _is_string_array(member.get("traits", [])):
            return false
        if typeof(member.get("trait_history", [])) != TYPE_ARRAY:
            return false
        for history_entry in member.get("trait_history", []):
            if typeof(history_entry) != TYPE_DICTIONARY:
                return false
        for history_entry in member.get("trait_history", []):
            if typeof(history_entry) != TYPE_DICTIONARY:
                return false
        if typeof(member.get("enhancements", {})) != TYPE_DICTIONARY or not _is_valid_numeric_dictionary(member.get("enhancements", {})):
            return false
        if typeof(member.get("reward", {})) != TYPE_DICTIONARY or not _is_valid_numeric_dictionary(member.get("reward", {})):
            return false
        if not _is_number(member.get("level", 1)) or int(member.get("level", 1)) < 1 or int(member.get("level", 1)) > 250:
            return false
        if not _is_number(member.get("xp", 0)) or int(member.get("xp", 0)) < 0:
            return false
        if not _is_number(member.get("loyalty", 50)) or int(member.get("loyalty", 50)) < 0 or int(member.get("loyalty", 50)) > 100:
            return false
        if not _is_valid_sigils(member.get("sigils", {})):
            return false

        var personality_value: Variant = member.get("personality", {})
        if typeof(personality_value) != TYPE_DICTIONARY:
            return false
        var personality: Dictionary = personality_value
        if not _is_number(personality.get("stress", 0)) or int(personality.get("stress", 0)) < 0 or int(personality.get("stress", 0)) > 100:
            return false
        if typeof(personality.get("memories", [])) != TYPE_ARRAY:
            return false
        for memory in personality.get("memories", []):
            if typeof(memory) != TYPE_DICTIONARY:
                return false
        for memory in personality.get("memories", []):
            if typeof(memory) != TYPE_DICTIONARY:
                return false
        if typeof(personality.get("behavior", {})) != TYPE_DICTIONARY or typeof(personality.get("ambition", {})) != TYPE_DICTIONARY:
            return false
        var behavior: Dictionary = personality.get("behavior", {})
        if not _is_string_array(behavior.get("seen_evidence", [])):
            return false
        var behavior: Dictionary = personality.get("behavior", {})
        if not _is_string_array(behavior.get("seen_evidence", [])):
            return false
        for behavior_key in behavior.keys():
            if str(behavior_key) == "seen_evidence":
                continue
            if not _is_number(behavior[behavior_key]) or int(behavior[behavior_key]) < 0:
                return false

    if typeof(payload.get("creation_profile", {})) != TYPE_DICTIONARY:
        return false
    if typeof(payload.get("world_flags", {})) != TYPE_DICTIONARY:
        return false
    if typeof(payload.get("world_pos", [0.0, 0.0])) != TYPE_ARRAY:
        return false
    var pos: Array = payload.get("world_pos", [0.0, 0.0])
    if pos.size() < 2 or not _is_number(pos[0]) or not _is_number(pos[1]):
        return false
    if typeof(payload.get("world_positions", {})) != TYPE_DICTIONARY:
        return false
    var positions: Dictionary = payload.get("world_positions", {})
    for region_id in positions.keys():
        if typeof(region_id) != TYPE_STRING or str(region_id).is_empty():
            return false
        var region_pos: Variant = positions[region_id]
        if typeof(region_pos) != TYPE_ARRAY:
            return false
        if region_pos.size() < 2 or not _is_number(region_pos[0]) or not _is_number(region_pos[1]):
            return false
    if typeof(payload.get("active_region_id", "sethmarch")) != TYPE_STRING:
        return false
    if typeof(payload.get("faction_state", {})) != TYPE_DICTIONARY:
        return false
    if typeof(payload.get("companion_relationships", {})) != TYPE_DICTIONARY:
        return false
    return true


static func _is_number(value: Variant) -> bool:
    return typeof(value) in [TYPE_INT, TYPE_FLOAT]


static func _is_valid_numeric_dictionary(value: Variant) -> bool:
    if typeof(value) != TYPE_DICTIONARY:
        return false
    var data: Dictionary = value
    for key in data.keys():
        if not _is_number(data[key]):
            return false
    return true


static func _is_string_array(value: Variant) -> bool:
    if typeof(value) != TYPE_ARRAY:
        return false
    for entry in value:
        if typeof(entry) != TYPE_STRING:
            return false
    return true


static func _is_string_dictionary(value: Variant) -> bool:
    if typeof(value) != TYPE_DICTIONARY:
        return false
    var data: Dictionary = value
    for key in data.keys():
        if typeof(key) != TYPE_STRING or typeof(data[key]) != TYPE_STRING:
            return false
    return true


static func _is_valid_instance_array(value: Variant) -> bool:
    if typeof(value) != TYPE_ARRAY:
        return false
    for instance in value:
        if typeof(instance) not in [TYPE_DICTIONARY, TYPE_STRING]:
            return false
        if typeof(instance) == TYPE_DICTIONARY:
            if instance.has("ap") and not _is_number(instance["ap"]):
                return false
            if instance.has("id") and typeof(instance["id"]) != TYPE_STRING:
                return false
    return true


static func _is_valid_sigils(value: Variant) -> bool:
    if typeof(value) != TYPE_DICTIONARY:
        return false
    var sigils: Dictionary = value
    for group in ["weapon", "armor"]:
        if not _is_valid_instance_array(sigils.get(group, [])):
            return false
    return true
