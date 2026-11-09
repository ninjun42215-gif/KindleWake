extends Node
## Runtime campaign state (autoload "GameState"). Milestone 2: the persistent party.
## Autoload scripts have no class_name; tests use PartyState / EncounterBuilder / ShopSystem directly instead.

var party: PartyState = PartyState.new()
var rng := RandomNumberGenerator.new()

# Overworld state (Milestone 7). The world scene and the battle scene hand over through these fields.
var pending_battle: Dictionary = {}      # battle the battle scene should open next (empty = default story battle)
var from_world: bool = false             # true when the battle was started from the overworld
var world_pos: Vector2 = Vector2.ZERO    # last overworld position in pixels (ZERO = start at the keep)
var world_flags: Dictionary = {}         # e.g. "camp_cleared", "found_watch"
var pending_location: String = ""        # town map the location scene opens next (set by the overworld)
var creation_profile: Dictionary = {}  # confirmed protagonist profile; stored with battle saves


func _ready() -> void:
    rng.randomize()
    new_game()


func new_game(profile: Dictionary = {}) -> void:
    var selected: Dictionary = profile.duplicate(true)
    if selected.is_empty():
        selected = CharacterCreation.default_profile(GameData.character_creation)
    var protagonist: Dictionary = CharacterCreation.build_definition(
        GameData.characters.get("torren", {}), selected, GameData.character_creation, GameData.classes
    )
    if protagonist.is_empty():
        push_error("GameState: invalid protagonist profile; using the default profile.")
        selected = CharacterCreation.default_profile(GameData.character_creation)
        protagonist = CharacterCreation.build_definition(
            GameData.characters.get("torren", {}), selected, GameData.character_creation, GameData.classes
        )
    creation_profile = selected.duplicate(true)
    party = PartyState.new_game(GameData.start, GameData.characters, protagonist)
    pending_battle = {}
    from_world = false
    world_pos = Vector2.ZERO
    world_flags = {}
    pending_location = ""


## Battle database with the party's current sheets (level, stats, equipment) substituted in.
func battle_db() -> Dictionary:
    return party.battle_db(GameData.as_db())


## Pays EXP, AP and gold after a battle (FF7 rules, see PartyState.battle_rewards).
## Returns {"reports", "gold", "spawned", "defeated", "total_exp", "total_ap"}; an empty report list on defeat.
func award_battle(units: Array, result: String) -> Dictionary:
    return party.apply_battle_result(units, result, rng, GameData.rules_db())


## A road ambush generated during campaign travel; encounters are part of the world, not a separate mode.
func travel_encounter_def() -> Dictionary:
    return EncounterBuilder.build_skirmish(GameData.encounters, GameData.battles, rng)


## Called by the overworld: the battle scene picks `def` up when it loads.
func start_battle_from_world(def: Dictionary) -> void:
    pending_battle = def
    from_world = true


## Called by the battle scene once: returns the queued battle (or {}) and clears it.
func take_pending_battle() -> Dictionary:
    var d: Dictionary = pending_battle
    pending_battle = {}
    return d
