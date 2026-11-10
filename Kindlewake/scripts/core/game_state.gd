extends Node

const PartyStateScript = preload("res://scripts/core/party_state.gd")
const RegionSaveState = preload("res://scripts/core/region_save_state.gd")
const CharacterCreationScript = preload("res://scripts/core/character_creation.gd")
const EncounterBuilderScript = preload("res://scripts/core/encounter_builder.gd")
const FactionSystem = preload("res://scripts/core/faction_system.gd")
const EmpireEconomySystem = preload("res://scripts/core/empire_economy_system.gd")
const EmpireDevelopmentSystem = preload("res://scripts/core/empire_development_system.gd")
## Runtime campaign state (autoload "GameState"). Milestone 2: the persistent party.
## Autoload scripts have no class_name; tests use PartyState / EncounterBuilder / ShopSystem directly instead.

var party: PartyStateScript = PartyStateScript.new()
var rng := RandomNumberGenerator.new()

# Overworld state (Milestone 7). The world scene and the battle scene hand over through these fields.
var pending_battle: Dictionary = {}      # battle the battle scene should open next (empty = default story battle)
var from_world: bool = false             # true when the battle was started from the overworld
var world_pos: Vector2 = Vector2.ZERO    # active region position in pixels (ZERO = region start)
var active_region_id: String = "sethmarch"
var world_positions: Dictionary = {}       # region id -> [x, y], preserving each continent route
var world_flags: Dictionary = {}         # e.g. "camp_cleared", "found_watch"
var pending_location: String = ""        # town map the location scene opens next (set by the overworld)
var creation_profile: Dictionary = {}  # confirmed protagonist profile; stored with battle saves
var campaign_slot: String = ""
var faction_state: Dictionary = {}




func _ready() -> void:
    rng.randomize()
    new_game()


func new_game(profile: Dictionary = {}) -> void:
    var selected: Dictionary = profile.duplicate(true)
    if selected.is_empty():
        selected = CharacterCreationScript.default_profile(GameData.character_creation)
    var protagonist: Dictionary = CharacterCreationScript.build_definition(
        GameData.characters.get("torren", {}), selected, GameData.character_creation, GameData.classes
    )
    if protagonist.is_empty():
        push_error("GameState: invalid protagonist profile; using the default profile.")
        selected = CharacterCreationScript.default_profile(GameData.character_creation)
        protagonist = CharacterCreationScript.build_definition(
            GameData.characters.get("torren", {}), selected, GameData.character_creation, GameData.classes
        )
    creation_profile = selected.duplicate(true)
    party = PartyStateScript.new_game(GameData.start, GameData.characters, protagonist)
    pending_battle = {}
    from_world = false
    world_pos = Vector2.ZERO
    active_region_id = "sethmarch"
    world_positions = {}
    world_flags = {}
    pending_location = ""
    faction_state = FactionSystem.new_campaign_state(GameData.factions)


## Assign troops to a claimed holding. Garrison upkeep is charged only on an explicit empire turn.
func assign_holding_garrison(holding_id: String, unit_count: int) -> Dictionary:
    return EmpireEconomySystem.assign_garrison(holding_id, unit_count, world_flags)


## Change the local administration of a claimed holding.
func set_holding_governance(holding_id: String, governance_id: String) -> Dictionary:
    return EmpireEconomySystem.set_governance(holding_id, governance_id, world_flags)


## Advance one deliberate empire turn; exploration and offline time never trigger upkeep.
func advance_empire_turn(holding_definitions: Array) -> Dictionary:
    var result: Dictionary = EmpireEconomySystem.advance_turn(holding_definitions, world_flags, party.gold)
    if not bool(result.get("ok", false)):
        return result
    party.gold = int(result.get("treasury_after", party.gold))
    world_flags["empire_turn"] = int(world_flags.get("empire_turn", 0)) + 1
    world_flags["empire_last_report"] = result.get("reports", []).duplicate(true)
    return result


## Spend treasury and materials to improve a player-administered holding.
func upgrade_holding_building(holding_id: String, building_id: String) -> Dictionary:
    var result: Dictionary = EmpireDevelopmentSystem.upgrade_building(holding_id, building_id, world_flags, party.gold)
    if bool(result.get("ok", false)):
        party.gold = int(result.treasury_after)
    return result


## Recruit a strategic troop stack at a player-administered holding.
func recruit_holding_troops(holding_id: String, troop_id: String, amount: int = 1) -> Dictionary:
    var result: Dictionary = EmpireDevelopmentSystem.recruit(holding_id, troop_id, amount, world_flags, party.gold)
    if bool(result.get("ok", false)):
        party.gold = int(result.treasury_after)
    return result


func assign_recruits_to_holding_garrison(holding_id: String, troop_id: String, amount: int) -> Dictionary:
    return EmpireDevelopmentSystem.assign_recruits_to_garrison(holding_id, troop_id, amount, world_flags)


func begin_holding_siege(holding_id: String, objective_id: String, required_progress: int = 3) -> Dictionary:
    return EmpireDevelopmentSystem.start_siege(holding_id, objective_id, required_progress, world_flags)


func advance_siege_objective(objective_id: String, progress: int = 1) -> Dictionary:
    return EmpireDevelopmentSystem.progress_siege(objective_id, progress, world_flags)


func resolve_siege_objective(objective_id: String, won: bool) -> Dictionary:
    return EmpireDevelopmentSystem.resolve_siege(objective_id, won, world_flags)


## Resolve the continent for a canonical campaign region.
func continent_for_region(region_id: String) -> String:
    for continent in GameData.continents.get("continents", []):
        for region in continent.get("regions", []):
            if str(region.get("id", "")) == region_id:
                return str(continent.get("id", ""))
    return ""


## Regional guardians become challengeable after the player secures a local holding.
func regional_boss_available(region_id: String) -> bool:
    var continent_id := continent_for_region(region_id)
    if continent_id == "" or bool(world_flags.get("regional_boss_" + continent_id + "_cleared", false)):
        return false
    for holding in GameData.world_expansion.get("capturable_locations", []):
        if str(holding.get("region", "")) == region_id:
            var id := str(holding.get("id", ""))
            if bool(world_flags.get("holding_claimed_" + id, false)) and str(world_flags.get("holding_owner_" + id, "")) == "house_dunmarrow":
                return true
    return false


## Add up to four reserve troops from a local holding to a tactical encounter.
## Reserves are deducted at deployment; survivors return after the battle and casualties are lost.
func _deploy_holding_recruits(holding_id: String, battle_definition: Dictionary) -> Dictionary:
    return EmpireDevelopmentSystem.deploy_recruits_to_battle(holding_id, battle_definition, world_flags)


func recover_deployed_recruits(battle_units: Array, battle_definition: Dictionary) -> Dictionary:
    return EmpireDevelopmentSystem.recover_deployed_recruits(battle_units, battle_definition, world_flags)


func start_regional_boss_for_region(region_id: String) -> bool:
    var continent_id := continent_for_region(region_id)
    if continent_id == "" or not regional_boss_available(region_id):
        return false
    var boss_battle_ids := {
        "eldrimar":"hollow_hart",
        "thalassar":"drowned_crown",
        "varakhan":"ash_regent",
        "nhalor":"pale_matriarch",
        "veyrwood":"briar_sovereign",
        "asterreach":"star_eater",
        "ilyr":"last_cantor"
    }
    var battle_id := "battle_boss_" + str(boss_battle_ids.get(continent_id, ""))
    var def: Dictionary = GameData.battle_def(battle_id)
    if def.is_empty():
        return false
    var local_holding := ""
    for holding in GameData.world_expansion.get("capturable_locations", []):
        var hid := str(holding.get("id", ""))
        if str(holding.get("region", "")) == region_id and bool(world_flags.get("holding_claimed_" + hid, false)) and str(world_flags.get("holding_owner_" + hid, "")) == "house_dunmarrow":
            local_holding = hid
            break
    if local_holding != "":
        def = _deploy_holding_recruits(local_holding, def)
    start_battle_from_world(def)
    return true


## Launch an assault against a selected foreign holding from the nearest available player holding.
func start_campaign_siege(target_holding_id: String) -> bool:
    var target: Dictionary = {}
    for definition in GameData.world_expansion.get("capturable_locations", []):
        if str(definition.get("id", "")) == target_holding_id:
            target = definition
            break
    if target.is_empty() or (bool(world_flags.get("holding_claimed_" + target_holding_id, false)) and str(world_flags.get("holding_owner_" + target_holding_id, "")) == "house_dunmarrow"):
        return false
    var source_id := ""
    var source: Dictionary = {}
    for definition in GameData.world_expansion.get("capturable_locations", []):
        var id := str(definition.get("id", ""))
        if bool(world_flags.get("holding_claimed_" + id, false)) and str(world_flags.get("holding_owner_" + id, "")) == "house_dunmarrow" and str(definition.get("continent", "")) == str(target.get("continent", "")):
            source_id = id
            source = definition
            break
    if source_id == "":
        for definition in GameData.world_expansion.get("capturable_locations", []):
            var id := str(definition.get("id", ""))
            if bool(world_flags.get("holding_claimed_" + id, false)) and str(world_flags.get("holding_owner_" + id, "")) == "house_dunmarrow":
                source_id = id
                source = definition
                break
    if source_id == "":
        return false
    var objective_id := "capture_" + target_holding_id
    var staged := begin_holding_siege(source_id, objective_id, 3)
    if not bool(staged.get("ok", false)):
        return false
    var battle := GameData.battle_def("battle_holding_siege")
    if battle.is_empty():
        return false
    battle["siege_objective_id"] = objective_id
    battle["siege_target_holding_id"] = target_holding_id
    battle["siege_source_holding_id"] = source_id
    battle["title"] = "Assault: " + str(target.get("name", target_holding_id))
    battle["briefing"] = "The company marches from %s to assault %s. Break the defenders and secure the stronghold. Victory will establish provisional control; the region itself will not transfer automatically." % [str(source.get("name", source_id)), str(target.get("name", target_holding_id))]
    battle = _deploy_holding_recruits(source_id, battle)
    start_battle_from_world(battle)
    return true


## A victorious siege establishes provisional location-level control and records the displaced authority.
func capture_holding_after_siege(target_holding_id: String, source_holding_id: String, objective_id: String) -> bool:
    var result: Dictionary = EmpireDevelopmentSystem.capture_holding_after_siege(target_holding_id, source_holding_id, objective_id, world_flags, GameData.world_expansion.get("capturable_locations", []))
    if not bool(result.get("ok", false)):
        return false
    var old_owner := str(result.get("old_owner", ""))
    var displaced_faction := ""
    for faction in GameData.factions.get("factions", []):
        var faction_name := str(faction.get("name", "")).to_lower()
        var owner_name := old_owner.to_lower()
        if faction_name != "" and (faction_name.contains(owner_name) or owner_name.contains(faction_name) or (faction_name.contains("orrowen") and owner_name.contains("orrowen")) or (faction_name.contains("vessmoor") and owner_name.contains("vessmoor"))):
            displaced_faction = str(faction.get("id", ""))
            break
    if displaced_faction != "" and displaced_faction != "house_dunmarrow":
        FactionSystem.adjust_relation(faction_state, "house_dunmarrow", displaced_faction, -12, "holding_captured_by_siege")
    return true


func start_holding_siege_battle(holding_id: String) -> bool:
    if not bool(world_flags.get("holding_claimed_" + holding_id, false)) or str(world_flags.get("holding_owner_" + holding_id, "")) != "house_dunmarrow":
        return false
    var objective_id := "field_siege_" + holding_id
    var staged: Dictionary = begin_holding_siege(holding_id, objective_id, 3)
    if not bool(staged.get("ok", false)):
        return false
    var def: Dictionary = GameData.battle_def("battle_holding_siege")
    if def.is_empty():
        return false
    def = def.duplicate(true)
    def["siege_objective_id"] = objective_id
    def["title"] = "Siege Exercise: " + holding_id.replace("_", " ").capitalize()
    def = _deploy_holding_recruits(holding_id, def)
    start_battle_from_world(def)
    return true


## Change diplomatic standing after an authored campaign event.
func adjust_faction_relation(faction_a: String, faction_b: String, amount: int, reason: String = "") -> bool:
    return FactionSystem.adjust_relation(faction_state, faction_a, faction_b, amount, reason)


## Set a treaty or war state after story conditions have been resolved.
func set_faction_diplomacy(faction_a: String, faction_b: String, next_state: String) -> bool:
    return FactionSystem.set_diplomatic_state(faction_state, faction_a, faction_b, next_state)


## Transfer a known atlas region after a battle, treaty or authored story outcome.
func transfer_faction_region(region_id: String, new_owner: String, cause: String) -> bool:
    return FactionSystem.transfer_region(faction_state, region_id, new_owner, cause)




## Campaign/story systems call these methods with authored, consequential evidence; no random trait rolls occur.
func record_character_behavior(character_id: String, behavior_id: String, amount: int, evidence_id: String) -> bool:
    var member = party.sheet(character_id)
    if member == null:
        return false
    member.record_behavior(behavior_id, amount, evidence_id)
    return true


func resolve_character_event(character_id: String, event_id: String, source: String = "campaign_event", instance_id: String = "") -> Dictionary:
    var member = party.sheet(character_id)
    if member == null:
        return {"ok": false, "reason": "Unknown character.", "traits_gained": []}
    return member.apply_personality_event(event_id, GameData.trait_events, GameData.traits, source, instance_id)


func progress_character_ambition(character_id: String, amount: int) -> Dictionary:
    var member = party.sheet(character_id)
    if member == null:
        return {"ok": false, "completed": false, "progress": 0}
    return member.advance_ambition(amount)


## Battle database with the party's current sheets (level, stats, equipment) substituted in.
func battle_db() -> Dictionary:
    return party.battle_db(GameData.as_db())


## Pays EXP, AP and gold after a battle (FF7 rules, see PartyState.battle_rewards).
## Returns {"reports", "gold", "spawned", "defeated", "total_exp", "total_ap"}; an empty report list on defeat.
func award_battle(units: Array, result: String) -> Dictionary:
    return party.apply_battle_result(units, result, rng, GameData.rules_db())


## A road ambush generated during campaign travel; encounters are part of the world, not a separate mode.
func travel_encounter_def() -> Dictionary:
    return EncounterBuilderScript.build_skirmish(GameData.encounters, GameData.battles, rng)


## Switch regions while preserving the last safe position in each one.
func set_active_region(region_id: String) -> void:
    if region_id == "" or region_id == active_region_id:
        return
    world_positions[active_region_id] = [world_pos.x, world_pos.y]
    active_region_id = region_id
    var saved: Array = world_positions.get(region_id, [])
    world_pos = Vector2(float(saved[0]), float(saved[1])) if saved.size() >= 2 else Vector2.ZERO


## Called by the overworld: the battle scene picks `def` up when it loads.
func start_battle_from_world(def: Dictionary) -> void:
    pending_battle = def
    from_world = true


## Called by the battle scene once: returns the queued battle (or {}) and clears it.
func take_pending_battle() -> Dictionary:
    var d: Dictionary = pending_battle
    pending_battle = {}
    return d


## Campaign-level save data is separate from the tactical battle snapshot.
func campaign_payload() -> Dictionary:
    return {
        "campaign": true,
        "party": party.to_dict(),
        "creation_profile": creation_profile.duplicate(true),
        "world_pos": [world_pos.x, world_pos.y],
        "active_region_id": active_region_id,
        "world_positions": world_positions.duplicate(true),
        "world_flags": world_flags.duplicate(true),
        "faction_state": faction_state.duplicate(true),
        "from_world": true
    }


func save_campaign(slot_id: String = "auto_a") -> bool:
    return SaveSystem.save_slot(slot_id, campaign_payload(), "Kindlewake • %d gold • %d companions" % [party.gold, party.roster.size()])


func load_campaign(slot_id: String) -> bool:
    var result: Dictionary = SaveSystem.load_slot(slot_id)
    if not bool(result.get("ok", false)):
        return false
    var payload: Dictionary = result.get("payload", {})
    if not RegionSaveState.is_valid_campaign_payload(payload):
        push_warning("GameState: refusing malformed campaign save in slot " + slot_id)
        return false

    # Build and verify all replacement state before touching the live campaign.
    var restored_party: PartyStateScript = PartyStateScript.from_dict(payload["party"])
    if restored_party.roster.is_empty():
        return false
    var region_state: Dictionary = RegionSaveState.from_payload(payload)
    party = restored_party
    creation_profile = (payload.get("creation_profile", {}) as Dictionary).duplicate(true)
    world_flags = (payload.get("world_flags", {}) as Dictionary).duplicate(true)
    faction_state = FactionSystem.normalize_state(payload.get("faction_state", {}), GameData.factions)
    world_pos = region_state["world_pos"]
    active_region_id = str(region_state["active_region_id"])
    world_positions = region_state["world_positions"]
    from_world = true
    pending_battle = {}
    pending_location = ""
    campaign_slot = slot_id
    return true


func newest_campaign_slot() -> String:
    var best := ""
    var newest := -1.0
    for slot in ["auto_a", "auto_b", "1", "2", "3"]:
        var info: Dictionary = SaveSystem.slot_info(slot)
        if bool(info.get("exists", false)) and float(info.get("unix", 0.0)) > newest:
            var loaded: Dictionary = SaveSystem.load_slot(slot)
            if bool(loaded.get("ok", false)) and bool((loaded.get("payload", {}) as Dictionary).get("campaign", false)):
                newest = float(info.get("unix", 0.0))
                best = slot
    return best
