extends Node

const PartyStateScript = preload("res://scripts/core/party_state.gd")
const RegionSaveState = preload("res://scripts/core/region_save_state.gd")
const CharacterCreationScript = preload("res://scripts/core/character_creation.gd")
const EncounterBuilderScript = preload("res://scripts/core/encounter_builder.gd")
const FactionSystem = preload("res://scripts/core/faction_system.gd")
const ChronicleSystem = preload("res://scripts/core/chronicle_system.gd")
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
var chronicle_state: Dictionary = ChronicleSystem.new_state()




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
    chronicle_state = ChronicleSystem.new_state()


## Record a post-campaign milestone after its authored story event has truly completed.
## The Chronicle remains locked until the Last Emperor dissolves the Empire and dies of old age.
func record_chronicle_milestone(milestone: String, details: Dictionary = {}) -> bool:
    return ChronicleSystem.record_milestone(chronicle_state, milestone, details)


func chronicle_unlocked() -> bool:
    return ChronicleSystem.is_unlocked(chronicle_state)


## Change diplomatic standing after an authored campaign event.
func adjust_faction_relation(faction_a: String, faction_b: String, amount: int, reason: String = "") -> bool:
    return FactionSystem.adjust_relation(faction_state, faction_a, faction_b, amount, reason)


## Set a treaty or war state after story conditions have been resolved.
func set_faction_diplomacy(faction_a: String, faction_b: String, next_state: String) -> bool:
    return FactionSystem.set_diplomatic_state(faction_state, faction_a, faction_b, next_state)


## Transfer a known atlas region after a battle, treaty or authored story outcome.
func transfer_faction_region(region_id: String, new_owner: String, cause: String) -> bool:
    return FactionSystem.transfer_region(faction_state, region_id, new_owner, cause)


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
        "chronicle_state": chronicle_state.duplicate(true),
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
    chronicle_state = ChronicleSystem.normalize_state(payload.get("chronicle_state", {}))
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
