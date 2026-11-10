extends RefCounted
## Data-driven recruitment checks and atomic roster/flag/gold updates.

const RelationshipSystem = preload("res://scripts/core/relationship_system.gd")
const TraitSystem = preload("res://scripts/core/trait_system.gd")

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


static func recruit(party: PartyState, character_id: String, definition: Dictionary, world_flags: Dictionary, spot: Dictionary = {}, trait_definitions: Dictionary = {}) -> Dictionary:
    var availability: Dictionary = inspect(party, character_id, definition, world_flags, spot)
    if not bool(availability.get("available", false)):
        availability["ok"] = false
        return availability
    var cost: int = int(availability.get("cost", 0))
    party.gold -= cost
    party.add_member(character_id, definition)
    var member: CharacterSheet = party.sheet(character_id)
    var recruit_data: Dictionary = definition.get("recruit", {})
    var traits_applied := 0
    if not trait_definitions.is_empty():
        for raw_trait_id in recruit_data.get("traits_on_join", []):
            var trait_id := str(raw_trait_id)
            var trait_result: Dictionary = TraitSystem.acquire(member.traits, member.trait_history, trait_id, "recruitment:" + character_id, trait_definitions)
            if bool(trait_result.get("ok", false)):
                member.traits = TraitSystem.normalized_ids(trait_result.get("traits", []))
                member.trait_history = (trait_result.get("history", []) as Array).duplicate(true)
                traits_applied += 1
    world_flags["recruited_" + character_id] = true
    availability["ok"] = true
    availability["loyalty"] = member.loyalty
    availability["traits_applied"] = traits_applied
    return availability


## Apply optional, authored relationship effects when a recruit joins the company.
## The first roster member is supplied as the company lead; evidence keys are stable and cannot be farmed.
static func apply_relationship_on_join(state: Dictionary, leader_id: String, character_id: String, definition: Dictionary) -> int:
    if leader_id.strip_edges() == "" or character_id.strip_edges() == "" or leader_id == character_id:
        return 0
    var recruit_data: Dictionary = definition.get("recruit", {})
    var effects: Dictionary = recruit_data.get("relationship_on_join", {})
    var applied := 0
    for raw_dimension in effects.keys():
        var dimension := str(raw_dimension)
        var amount := int(effects[raw_dimension])
        var evidence_id := "recruit:%s:%s" % [character_id, dimension]
        if RelationshipSystem.adjust(state, leader_id, character_id, dimension, amount, evidence_id):
            applied += 1
    return applied
