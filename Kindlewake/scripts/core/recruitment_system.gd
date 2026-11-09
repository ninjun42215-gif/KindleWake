extends RefCounted
## Data-driven recruitment checks and atomic roster/flag/gold updates.

static func inspect(party: PartyState, character_id: String, definition: Dictionary, world_flags: Dictionary, spot: Dictionary = {}) -> Dictionary:
    if character_id == "" or definition.is_empty():
        return {"available": false, "cost": 0, "reason": "There is no available recruit."}
    if party == null:
        return {"available": false, "cost": 0, "reason": "The company is not available."}
    if party.roster.has(character_id) or bool(world_flags.get("recruited_" + character_id, false)):
        return {"available": false, "cost": 0, "reason": "This recruit has already joined your company."}
    var recruit_data: Dictionary = definition.get("recruit", {})
    var requirements: Dictionary = recruit_data.get("requirements", {})
    for raw_flag in requirements.get("flags_all", []):
        var flag: String = str(raw_flag)
        if not bool(world_flags.get(flag, false)):
            return {"available": false, "cost": 0, "reason": "This recruit is waiting for: " + flag.replace("_", " ") + "."}
    for raw_id in requirements.get("recruits_all", []):
        var required_id: String = str(raw_id)
        if not party.roster.has(required_id):
            return {"available": false, "cost": 0, "reason": "This recruit requires " + required_id.replace("_", " ") + " to join first."}
    var minimum_roster: int = maxi(0, int(requirements.get("min_roster", 0)))
    if party.roster.size() < minimum_roster:
        return {"available": false, "cost": 0, "reason": "The company needs at least %d members." % minimum_roster}
    var cost: int = maxi(0, int(spot.get("cost", recruit_data.get("cost", 0))))
    if party.gold < cost:
        return {"available": false, "cost": cost, "reason": "The company needs %d gold to secure this recruit." % cost}
    return {"available": true, "cost": cost, "reason": ""}


static func recruit(party: PartyState, character_id: String, definition: Dictionary, world_flags: Dictionary, spot: Dictionary = {}) -> Dictionary:
    var availability: Dictionary = inspect(party, character_id, definition, world_flags, spot)
    if not bool(availability.get("available", false)):
        availability["ok"] = false
        return availability
    var cost: int = int(availability.get("cost", 0))
    party.gold -= cost
    party.add_member(character_id, definition)
    world_flags["recruited_" + character_id] = true
    availability["ok"] = true
    availability["loyalty"] = party.sheet(character_id).loyalty
    return availability
