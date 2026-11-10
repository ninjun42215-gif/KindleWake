extends SceneTree

const RuneSystem = preload("res://scripts/core/rune_system.gd")
const TraitSystemScript = preload("res://scripts/core/trait_system.gd")
const RelationshipSystemScript = preload("res://scripts/core/relationship_system.gd")
const CompanionBehaviorScript = preload("res://scripts/core/companion_behavior_system.gd")
const RecruitmentSystem = preload("res://scripts/core/recruitment_system.gd")
const PrologueSystem = preload("res://scripts/core/prologue_system.gd")
const EscapeMissionSystem = preload("res://scripts/core/escape_mission.gd")
const BrinegateQuestSystem = preload("res://scripts/core/brinegate_quest_system.gd")
const MarenQuestSystem = preload("res://scripts/core/maren_quest_system.gd")
const NerisQuestSystem = preload("res://scripts/core/neris_quest_system.gd")
const RegionSaveState = preload("res://scripts/core/region_save_state.gd")
const FactionSystem = preload("res://scripts/core/faction_system.gd")
const ArtScript = preload("res://scripts/ui/art.gd")
## Headless test-suite + AI-vs-AI battle simulator. Run from the project folder:
##   godot --headless --path . --script res://tests/run_tests.gd
## Exit code 0 = every check passed. (Autoloads are not available in --script mode, so the
## scripts are instantiated manually.)

var checks: int = 0
var failures: int = 0
var gd: Node
var ss: Node
var screen_closed: int = 0
var card_taps: int = 0


func _initialize() -> void:
    gd = load("res://scripts/core/game_data.gd").new()
    gd.reload()
    ss = load("res://scripts/core/save_system.gd").new()
    _test_data()
    _test_art_assets()
    _test_class_tree()
    _test_character_creation()
    _test_map()
    _test_combat()
    _test_turn_queue()
    _test_controller()
    _test_auto_battle()
    _test_progression()
    _test_trait_system()
    _test_companion_relationships()
    _test_companion_behavior()
    _test_recruitment()
    _test_prologue()
    _test_escape_mission()
    _test_escape_ui_layout()
    _test_sigils()
    _test_runes()
    _test_weapon_skills()
    _test_world()
    _test_world_atlas()
    _test_faction_politics()
    _test_thalassar_region()
    _test_wraparound_world()
    _test_brinegate_quest()
    _test_maren_companion_quest()
    _test_neris_companion_quest()
    _test_region_save_compatibility()
    _test_locations()
    _test_shop_and_screen()
    _test_save_system()
    _test_campaign_restore_validation()
    _simulate_battles(30)
    print("")
    print("Checks: %d   Failures: %d" % [checks, failures])
    quit(1 if failures > 0 else 0)


func check(cond: bool, label: String) -> void:
    checks += 1
    if cond:
        print("  ok    " + label)
    else:
        failures += 1
        print("  FAIL  " + label)


func _make_unit(uid: int, char_id: String, team: String, cell: Vector2i, facing: int) -> BattleUnit:
    var cdef: Dictionary = gd.characters[char_id]
    var cls: Dictionary = gd.classes[str(cdef["class_id"])]
    return BattleUnit.create(uid, char_id, cdef, cls, team, cell, facing)


func _test_data() -> void:
    print("[data]")
    check(gd.classes.size() >= 5, "classes loaded")
    check(gd.weapons.size() >= 5, "weapons loaded")
    var expected_rarities: Array = ["common", "uncommon", "rare", "epic", "legendary", "mythical"]
    check(gd.item_rarities.size() == 6, "six equipment rarity tiers are declared")
    var rarity_coverage := true
    var unique_coverage := true
    for item_id in gd.items.keys():
        var item: Dictionary = gd.items[item_id]
        if not expected_rarities.has(str(item.get("rarity", ""))) and str(item.get("rarity", "")) != "unique":
            rarity_coverage = false
        if str(item.get("rarity", "")) == "unique" and not bool(item.get("unique", false)) and not item.has("bound_to"):
            unique_coverage = false
    check(rarity_coverage, "every equipment item uses a supported rarity tier or Unique")
    check(unique_coverage, "Unique equipment is explicitly identified as a special grade")
    for rarity in expected_rarities:
        var has_tier := false
        for item_id in gd.items.keys():
            if str((gd.items[item_id] as Dictionary).get("rarity", "")) == str(rarity):
                has_tier = true
                break
        check(has_tier, "equipment data includes " + str(rarity) + " tier")
    check(gd.characters.has("torren"), "characters loaded")
    var def: Dictionary = gd.battle_def("battle_01")
    check(not def.is_empty(), "battle_01 loaded")
    var db: Dictionary = gd.as_db()
    var spawns: Array = def["units"]
    for spawn in spawns:
        var cid: String = str(spawn["character_id"])
        check(db["characters"].has(cid), "spawn character exists: " + cid)
        var cdef: Dictionary = db["characters"][cid]
        check(db["classes"].has(str(cdef["class_id"])), "class exists for " + cid)
        check(db["weapons"].has(str(cdef["weapon_id"])), "weapon exists for " + cid)


func _test_art_assets() -> void:
    print("[art asset integrity]")
    var world_names: Array = ["house_a", "house_b", "house_c", "hut", "keep", "tower_a", "tower_b", "tower_c"]
    for asset_name in world_names:
        var world_texture: Texture2D = ArtScript.world(str(asset_name))
        check(world_texture != null, "world vector asset loads: " + str(asset_name))
        if world_texture != null:
            var world_size: Vector2 = world_texture.get_size()
            check(world_size.x > 0.0 and world_size.y > 0.0, "world vector asset has a valid canvas: " + str(asset_name))

    var prop_texture: Texture2D = load("res://assets/art/props/field_props.svg") as Texture2D
    check(prop_texture != null, "environment prop atlas imports")
    if prop_texture != null:
        check(prop_texture.get_size() == Vector2(512.0, 512.0), "4x4 prop atlas matches sixteen 128px cells")

    for kind in ["soldier", "orc"]:
        for anim in ["idle", "walk", "attack", "hurt", "death"]:
            var frame_count: int = int(ArtScript.UNIT_FRAMES.get(anim, 0))
            var sheet: Texture2D = ArtScript.unit_sheet(kind, anim)
            check(sheet != null, "%s %s sprite sheet loads" % [kind, anim])
            if sheet == null:
                continue
            var expected_size := Vector2(float(frame_count) * ArtScript.UNIT_FRAME_SIZE, ArtScript.UNIT_FRAME_SIZE)
            check(sheet.get_size() == expected_size, "%s %s sheet is %dx%d for %d horizontal frames" % [kind, anim, int(expected_size.x), int(expected_size.y), frame_count])
            check(ArtScript.unit_frame(anim, 0.0) == 0, "%s animation begins at frame zero" % anim)
            var final_frame_time: float = ArtScript.unit_duration(anim) * 4.0
            var final_frame: int = ArtScript.unit_frame(anim, final_frame_time)
            if anim in ["attack", "hurt", "death"]:
                check(final_frame == frame_count - 1, "%s one-shot animation clamps at its final frame" % anim)
            else:
                check(final_frame >= 0 and final_frame < frame_count, "%s looping animation remains inside its frame range" % anim)


func _test_prologue() -> void:
    print("[prologue]")
    var prior: Dictionary = {"found_watch": true}
    var rescue: Dictionary = PrologueSystem.apply_choice(prior, "rescue_people")
    var record: Dictionary = PrologueSystem.apply_choice(prior, "recover_record")
    var split: Dictionary = PrologueSystem.apply_choice(prior, "split_company")
    check(bool(rescue.get("found_watch", false)), "prologue preserves pre-existing world flags")
    check(bool(rescue.get("prologue_people_saved", false)) and not bool(rescue.get("prologue_record_saved", true)), "rescue choice saves people and records the lost evidence")
    check(bool(record.get("prologue_record_saved", false)) and not bool(record.get("prologue_people_saved", true)), "record choice preserves evidence and records the human cost")
    check(bool(split.get("prologue_people_saved", false)) and bool(split.get("prologue_record_saved", false)) and bool(split.get("prologue_company_split", false)), "split choice preserves both outcomes and its distinct consequence")
    check(str(PrologueSystem.acknowledgement(rescue)).contains("people are alive"), "rescue choice receives a later narrative acknowledgement")
    check(str(PrologueSystem.acknowledgement(record)).contains("kept the record"), "record choice receives a later narrative acknowledgement")
    check(str(PrologueSystem.acknowledgement(split)).contains("both lives and truth"), "split choice receives a later narrative acknowledgement")
    check(PrologueSystem.apply_choice(prior, "unknown").is_empty(), "unknown prologue choices are rejected")


func _test_escape_mission() -> void:
    print("[escape mission]")
    var base: Dictionary = gd.battle_def("battle_01")
    var original_id: String = str(base.get("id", ""))
    var original_units: Array = (base.get("units", []) as Array).duplicate(true)
    var battle: Dictionary = EscapeMissionSystem.build_battle(base)
    check(str(battle.get("id", "")) == "east_gallery_escape", "escape mission has its own battle identity")
    check(str(battle.get("world_flag_on_victory", "")) == EscapeMissionSystem.CLEAR_FLAG, "escape victory is wired to a persistent campaign flag")
    check(str(battle.get("title", "")).contains("Burning Courtyard") and str(battle.get("victory_text", "")).contains("postern"), "escape encounter has authored briefing and victory narrative")
    check((battle.get("terrain", []) as Array).size() == 14 and str((battle["terrain"] as Array)[0]).length() == 20, "courtyard battlefield is a valid 20x14 grid")
    var spawn_ok := true
    var player_count := 0
    var enemy_count := 0
    for spawn in battle.get("units", []):
        var unit: Dictionary = spawn
        var cell: Array = unit.get("cell", [])
        if cell.size() != 2 or int(cell[0]) < 0 or int(cell[0]) >= 20 or int(cell[1]) < 0 or int(cell[1]) >= 14:
            spawn_ok = false
        if str(unit.get("team", "")) == "player":
            player_count += 1
        elif str(unit.get("team", "")) == "enemy":
            enemy_count += 1
    check(spawn_ok and player_count == 4 and enemy_count == 4, "all eight escape combatants spawn within the courtyard")
    check(str(base.get("id", "")) == original_id and (base.get("units", []) as Array) == original_units, "building the escape encounter never mutates canonical battle data")
    var controller := BattleController.new()
    controller.setup(battle, gd.as_db(), 77)
    check(controller.map.width == 20 and controller.map.height == 14 and controller.units.size() == 8, "escape encounter loads into the tactical battle controller")


func _test_escape_ui_layout() -> void:
    print("[escape UI layout]")
    var viewport_sizes: Array[Vector2] = [
        Vector2(360, 800),
        Vector2(390, 844),
        Vector2(1280, 720),
        Vector2(800, 360)
    ]
    for viewport_size in viewport_sizes:
        var playable: Rect2 = EscapeLayout.playable_rect_for_size(viewport_size)
        var gate: Vector2 = EscapeLayout.gate_position_for_size(viewport_size)
        check(playable.has_point(gate), "postern gate remains in the playable area at %dx%d" % [int(viewport_size.x), int(viewport_size.y)])
        var clamped: Vector2 = Vector2(-100.0, viewport_size.y + 100.0).clamp(playable.position, playable.end - Vector2.ONE)
        check(playable.has_point(clamped), "tap targets clamp inside the playable area at %dx%d" % [int(viewport_size.x), int(viewport_size.y)])


func _test_class_tree() -> void:
    print("[class tree]")
    var stat_keys: Array = ["hp", "mp", "str", "dex", "int", "vit", "spd", "lck", "acc", "eva", "ldr", "mor"]
    var targeted: Dictionary = {}
    for cid in gd.classes.keys():
        var cdef: Dictionary = gd.classes[cid]
        for t in cdef.get("promotes_to", []):
            targeted[str(t)] = str(cid)
    var growth_ok := true
    var fields_ok := true
    var tree_ok := true
    var reach_ok := true
    var bad: Array[String] = []
    for cid in gd.classes.keys():
        var cdef: Dictionary = gd.classes[cid]
        for f in ["name", "branch", "tier", "move", "jump", "growth", "promotes_to"]:
            if not cdef.has(f):
                fields_ok = false
                bad.append("%s lacks %s" % [cid, f])
        if int(cdef.get("tier", 0)) < 1 or int(cdef.get("tier", 0)) > 4 or int(cdef.get("move", 0)) < 1 or int(cdef.get("jump", 0)) < 1:
            fields_ok = false
            bad.append("%s has bad tier/move/jump" % cid)
        var growth: Dictionary = cdef.get("growth", {})
        if not growth.has("hp"):
            growth_ok = false
            bad.append("%s has no hp growth" % cid)
        for k in growth.keys():
            if not stat_keys.has(str(k)) or int(growth[k]) < 0 or int(growth[k]) > 100:
                growth_ok = false
                bad.append("%s growth %s" % [cid, str(k)])
        for t in cdef.get("promotes_to", []):
            var tdef: Dictionary = gd.classes.get(str(t), {})
            if tdef.is_empty():
                tree_ok = false
                bad.append("%s promotes to missing class %s" % [cid, str(t)])
                continue
            if int(tdef.get("tier", 0)) != int(cdef.get("tier", 0)) + 1 or str(tdef.get("branch", "")) != str(cdef.get("branch", "")):
                tree_ok = false
                bad.append("%s -> %s must be the next tier in the same branch" % [cid, str(t)])
        var is_root: bool = int(cdef.get("tier", 1)) == 1 or bool(cdef.get("story_only", false))
        if not is_root and not targeted.has(str(cid)):
            reach_ok = false
            bad.append("%s can never be reached" % cid)
    for line in bad:
        print("        " + line)
    check(gd.classes.size() >= 28, "the full class tree is in data (%d classes)" % gd.classes.size())
    check(fields_ok, "every class has name, branch, tier 1-4, move, jump, growth and promotes_to")
    check(growth_ok, "growth tables use known stats with chances from 0 to 100 and always include hp")
    check(tree_ok, "every promotion target exists, is one tier higher and stays in the same branch")
    check(reach_ok, "every class is a tier-1 start, a story-only class or the target of a promotion")
    for cid in ["berserker", "paladin"]:
        check(bool((gd.classes[cid] as Dictionary).get("locked", false)), cid + " is locked until its requirement can be checked")
    check(bool((gd.classes["commander"] as Dictionary).get("story_only", false)) and not targeted.has("commander"), "commander is story-only and nothing promotes into it")
    check(int((gd.classes["thief"] as Dictionary)["jump"]) == 2 and int((gd.classes["scout"] as Dictionary)["jump"]) == 2, "thieves and scouts jump 2 (GDD 3)")


func _test_character_creation() -> void:
    print("[character creation]")
    var cfg: Dictionary = gd.character_creation
    var profile: Dictionary = CharacterCreation.default_profile(cfg)
    var base: Dictionary = gd.characters.get("torren", {}).duplicate(true)
    var valid_reason: String = CharacterCreation.validate(profile, cfg, gd.classes)
    check(valid_reason == "", "default protagonist profile is valid")
    check(int(cfg.get("stat_points", 0)) == 8 and int(profile.get("stat_allocation", {}).get("str", 0)) + int(profile.get("stat_allocation", {}).get("dex", 0)) + int(profile.get("stat_allocation", {}).get("int", 0)) + int(profile.get("stat_allocation", {}).get("vit", 0)) + int(profile.get("stat_allocation", {}).get("spd", 0)) + int(profile.get("stat_allocation", {}).get("lck", 0)) == 8, "protagonist receives eight allocatable starting attribute points")
    var created: Dictionary = CharacterCreation.build_definition(base, profile, cfg, gd.classes)
    check(not created.is_empty() and str(created.get("name", "")) == "Torren Dunmarrow", "creator builds a protagonist definition")
    check(str(created.get("class_id", "")) == "swordsman" and created.has("creation"), "discipline and visual profile metadata are stored")
    check(int(created["stats"]["ldr"]) == int(base["stats"]["ldr"]) + 1 and int(created["stats"]["mor"]) == int(base["stats"]["mor"]) + 2, "origin and temperament bonuses are applied")
    check(int(created["stats"]["str"]) == int(base["stats"]["str"]) + 2 and int(created["stats"]["dex"]) == int(base["stats"]["dex"]) + 2, "allocated protagonist attributes are applied to starting stats")
    var bad_allocation: Dictionary = profile.duplicate(true)
    bad_allocation["stat_allocation"] = {"str": 5, "dex": 5, "int": 0, "vit": 0, "spd": 0, "lck": 0}
    check(CharacterCreation.validate(bad_allocation, cfg, gd.classes) != "", "creator rejects over-budget attribute allocation")
    check(int(base["stats"]["ldr"]) == 12 and str(base["name"]) == "Torren Dunmarrow", "building a profile does not mutate source character data")
    var archer: Dictionary = profile.duplicate(true)
    archer["name"] = "Ari Dunmarrow"
    archer["discipline"] = "archer"
    archer["weapon_preference"] = "bow"
    var archer_def: Dictionary = CharacterCreation.build_definition(base, archer, cfg, gd.classes)
    check(str(archer_def.get("class_id", "")) == "archer", "discipline can initialize a different tier-one class")
    check(str((archer_def.get("equipment", {}) as Dictionary).get("weapon", "")) == "hunting_bow", "bow preference equips a matching common bow")
    var preference_items: Dictionary = {
        "sword": "arming_sword", "axe": "hand_axe", "spear": "spear", "bow": "hunting_bow",
        "crossbow": "crossbow", "staff": "staff", "mace": "mace", "dagger": "dagger",
    }
    var preference_ok := true
    for discipline_id in cfg.get("disciplines", {}).keys():
        var discipline_def: Dictionary = cfg["disciplines"][discipline_id]
        for preference_id in discipline_def.get("weapon_preferences", []):
            var variant: Dictionary = profile.duplicate(true)
            variant["discipline"] = str(discipline_id)
            variant["weapon_preference"] = str(preference_id)
            var variant_def: Dictionary = CharacterCreation.build_definition(base, variant, cfg, gd.classes)
            var equipped: String = str((variant_def.get("equipment", {}) as Dictionary).get("weapon", ""))
            if equipped != str(preference_items.get(str(preference_id), "")) or not gd.items.has(equipped) or not gd.weapons.has(str(gd.items.get(equipped, {}).get("weapon_id", ""))):
                preference_ok = false
    check(preference_ok, "every compatible discipline preference equips a valid matching weapon")
    var custom_party: PartyState = PartyState.new_game(gd.start, gd.characters, archer_def)
    check(custom_party.roster.size() == 4 and str(custom_party.sheet("torren").class_id) == "archer", "custom protagonist joins the unchanged four-member starting party")
    check(str(custom_party.sheet("torren").display_name) == "Ari Dunmarrow" and str(custom_party.sheet("sela").class_id) == "archer", "custom name applies only to stable protagonist id; companions remain unchanged")
    var masculine_jaw: float = CharacterPreview.jaw_ratio_for_presentation("masculine")
    var androgynous_jaw: float = CharacterPreview.jaw_ratio_for_presentation("androgynous")
    var feminine_jaw: float = CharacterPreview.jaw_ratio_for_presentation("feminine")
    check(masculine_jaw > androgynous_jaw and androgynous_jaw > feminine_jaw, "creator preview silhouette reflects presentation")
    var invalid: Dictionary = profile.duplicate(true)
    invalid["weapon_preference"] = "staff"
    check(CharacterCreation.validate(invalid, cfg, gd.classes) != "", "incompatible weapon preference is rejected")
    invalid = profile.duplicate(true)
    invalid["name"] = " "
    check(CharacterCreation.build_definition(base, invalid, cfg, gd.classes).is_empty(), "invalid names cannot produce a protagonist")


func _test_map() -> void:
    print("[map]")
    var m: BattleMap = BattleMap.from_battle_def(gd.battle_def("battle_01"), gd.terrain)
    check(m.width == 20 and m.height == 14, "battlefield expands to 20x14")
    check(m.terrain_id(Vector2i(9, 6)) == "bridge", "bridge at expanded coordinate (9,6)")
    check(m.move_cost(Vector2i(4, 6)) == -1, "deep water blocks movement")
    check(m.height_at(Vector2i(12, 3)) == 2, "hill height 2 at expanded coordinate (12,3)")
    var reach: Dictionary = m.compute_reach(Vector2i(9, 9), 5, 1, {}, {})
    var cost: Dictionary = reach["cost"]
    check(cost.has(Vector2i(9, 6)) and int(cost[Vector2i(9, 6)]) == 3, "bridge reachable at cost 3")
    check(not cost.has(Vector2i(4, 6)), "deep water not reachable")
    var path: Array[Vector2i] = m.path_from(reach, Vector2i(9, 9), Vector2i(9, 6))
    check(path.size() == 3 and path[2] == Vector2i(9, 6), "path to bridge has 3 steps")
    var blocked: Dictionary = m.compute_reach(Vector2i(9, 9), 5, 1, {Vector2i(9, 7): true}, {})
    var bcost: Dictionary = blocked["cost"]
    check(not bcost.has(Vector2i(9, 6)), "enemy on the bridge blocks the crossing")
    var hill: Dictionary = m.compute_reach(Vector2i(11, 5), 6, 1, {}, {})
    var hcost: Dictionary = hill["cost"]
    check(hcost.has(Vector2i(12, 3)), "hill top reachable by climbing one step at a time")
    var low: Dictionary = m.compute_reach(Vector2i(13, 4), 3, 1, {}, {})
    var lcost: Dictionary = low["cost"]
    check(not lcost.has(Vector2i(13, 3)), "jump 1 cannot climb a 2-high step")
    check(not m.has_line_of_sight(Vector2i(15, 4), Vector2i(13, 4)), "rock wall blocks line of sight")
    check(m.has_line_of_sight(Vector2i(9, 10), Vector2i(9, 3)), "river does not block line of sight")

func _test_combat() -> void:
    print("[combat]")
    check(is_equal_approx(CombatCalc.base_damage(20.0, 20.0), 10.0), "defense equal to attack halves damage")
    check(is_equal_approx(CombatCalc.base_damage(10.0, 0.0), 10.0), "no defense = full damage")
    var m: BattleMap = BattleMap.from_battle_def(gd.battle_def("battle_01"), gd.terrain)
    var a: BattleUnit = _make_unit(1, "bram", "player", Vector2i(9, 9), 0)
    var r: BattleUnit = _make_unit(2, "roadreaver", "enemy", Vector2i(9, 8), 2)
    var units: Array = [a, r]
    var w: Dictionary = gd.weapon_def(a.weapon_id)
    var front: Dictionary = CombatCalc.preview(a, r, w, m, units)
    check(str(front["facing"]) == "front", "attacker in front of the defender")
    r.facing = 0
    var rear: Dictionary = CombatCalc.preview(a, r, w, m, units)
    check(str(rear["facing"]) == "rear", "attacker behind the defender")
    check(int(rear["dmg_max"]) > int(front["dmg_max"]), "rear attacks deal more damage")
    check(int(rear["crit"]) == int(front["crit"]) + 10, "rear attacks gain +10 crit")
    var ally: BattleUnit = _make_unit(3, "torren", "player", Vector2i(9, 7), 0)
    units.append(ally)
    var flank: Dictionary = CombatCalc.preview(a, r, w, m, units)
    check(bool(flank["flank"]) and int(flank["dmg_max"]) > int(rear["dmg_max"]), "ally on the opposite side gives a flank bonus")
    var archer: BattleUnit = _make_unit(4, "sela", "player", Vector2i(12, 3), 2)
    var low_target: BattleUnit = _make_unit(5, "roadreaver", "enemy", Vector2i(12, 5), 0)
    var high: Dictionary = CombatCalc.preview(archer, low_target, gd.weapon_def(archer.weapon_id), m, [archer, low_target])
    check(int(high["height_diff"]) == 2, "height advantage detected (+2)")
    check(int(high["hit"]) >= 10 and int(high["hit"]) <= 98, "hit chance stays within 10-98")
    var rng1 := RandomNumberGenerator.new()
    var rng2 := RandomNumberGenerator.new()
    rng1.seed = 42
    rng2.seed = 42
    var d1: BattleUnit = _make_unit(6, "roadreaver", "enemy", Vector2i(9, 8), 0)
    var d2: BattleUnit = _make_unit(7, "roadreaver", "enemy", Vector2i(9, 8), 0)
    var res1: Dictionary = CombatCalc.resolve(a, d1, w, m, [a, d1], rng1)
    var res2: Dictionary = CombatCalc.resolve(a, d2, w, m, [a, d2], rng2)
    check(res1["hit"] == res2["hit"] and res1["damage"] == res2["damage"], "same RNG seed gives the same result")


func _test_turn_queue() -> void:
    print("[turn queue]")
    var fast: BattleUnit = _make_unit(1, "sela", "player", Vector2i(1, 1), 0)
    var slow: BattleUnit = _make_unit(2, "brother_wystan", "player", Vector2i(2, 2), 0)
    fast.ctb = TurnQueue.initial_ctb(fast)
    slow.ctb = TurnQueue.initial_ctb(slow)
    check(TurnQueue.peek_next([fast, slow]) == fast, "faster unit acts first")
    var order: Array = TurnQueue.timeline([fast, slow], 10)
    var fast_count := 0
    for o in order:
        var u: BattleUnit = o
        if u.id == 1:
            fast_count += 1
    check(fast_count > 10 - fast_count, "faster unit acts more often (%d of 10)" % fast_count)
    check(TurnQueue.delay_after_turn(fast, true, true, {}) > TurnQueue.delay_after_turn(fast, false, false, {}), "acting costs more time than waiting")


func _test_controller() -> void:
    print("[controller]")
    var c := BattleController.new()
    c.setup(gd.battle_def("battle_01"), gd.as_db(), 12345)
    check(c.units.size() == 8, "8 units spawned")
    c.begin()
    check(c.active_unit() != null, "someone is active after begin()")
    var guard := 0
    while c.active_unit().team != "player" and guard < 20:
        c.run_ai_turn()
        guard += 1
    var a: BattleUnit = c.active_unit()
    check(a.team == "player", "a player unit becomes active")
    var moves: Array[Vector2i] = c.move_targets(a)
    check(moves.size() > 0, "active unit has legal moves")
    check(c.try_move(a, moves[0]), "move succeeds")
    check(not c.try_move(a, moves[0]), "cannot move twice in one turn")
    var json: String = JSON.stringify(c.to_dict())
    var parsed: Dictionary = JSON.parse_string(json)
    var c2 := BattleController.new()
    check(c2.restore(gd.battle_def("battle_01"), gd.as_db(), parsed), "restore from JSON succeeds")
    var same := c2.units.size() == c.units.size() and c2.active_id == c.active_id and c2.turn_count == c.turn_count
    for i in range(c.units.size()):
        if c.units[i].cell != c2.units[i].cell or c.units[i].hp != c2.units[i].hp or c.units[i].has_moved != c2.units[i].has_moved:
            same = false
    check(same, "restored state equals saved state")
    check(c.rng.randi() == c2.rng.randi(), "RNG state restored exactly")
    var bad: Dictionary = parsed.duplicate(true)
    bad["battle_id"] = "other"
    check(not BattleController.new().restore(gd.battle_def("battle_01"), gd.as_db(), bad), "restore rejects a different battle id")
    var malformed: Dictionary = parsed.duplicate(true)
    malformed["units"][0]["cell"] = [0]
    var old_unit_count := c2.units.size()
    check(not c2.restore(gd.battle_def("battle_01"), gd.as_db(), malformed), "restore rejects malformed unit coordinates")
    check(c2.units.size() == old_unit_count, "failed battle restore leaves the current battle untouched")
    var duplicate_ids: Dictionary = parsed.duplicate(true)
    duplicate_ids["units"][1]["id"] = duplicate_ids["units"][0]["id"]
    check(not BattleController.new().restore(gd.battle_def("battle_01"), gd.as_db(), duplicate_ids), "restore rejects duplicate unit IDs")
    var outside_map: Dictionary = parsed.duplicate(true)
    outside_map["units"][0]["cell"] = [999, 999]
    check(not BattleController.new().restore(gd.battle_def("battle_01"), gd.as_db(), outside_map), "restore rejects unit coordinates outside the battlefield")
    var invalid_facing: Dictionary = parsed.duplicate(true)
    invalid_facing["units"][0]["facing"] = 99
    check(not BattleController.new().restore(gd.battle_def("battle_01"), gd.as_db(), invalid_facing), "restore rejects invalid facing directions")
    var invalid_active: Dictionary = parsed.duplicate(true)
    invalid_active["active_id"] = 999
    check(not BattleController.new().restore(gd.battle_def("battle_01"), gd.as_db(), invalid_active), "restore rejects an active unit ID absent from the snapshot")


## Auto Battle = the AI plays the player's units (run_ai_turn(true)); also covers the cleric's heal logic.
func _test_auto_battle() -> void:
    print("[auto battle]")
    var c := BattleController.new()
    c.setup(gd.battle_def("battle_01"), gd.as_db(), 777)
    c.begin()
    var cal: BattleUnit = null
    var bram: BattleUnit = null
    for o in c.units:
        var u: BattleUnit = o
        if u.character_id == "brother_wystan":
            cal = u
        elif u.character_id == "bram":
            bram = u
    check(cal != null and bram != null, "Brother Wystan and Sir Bram are in the battle")
    if cal == null or bram == null:
        return
    c.active_id = cal.id
    cal.has_moved = false
    cal.has_acted = false
    var idle_plan: Dictionary = BattleAI.decide(cal, c)
    check(str(idle_plan["action"]) != "skill", "cleric does not cast Mend when nobody is hurt")
    bram.hp = int(float(bram.max_hp()) * 0.3)
    var plan: Dictionary = BattleAI.decide(cal, c)
    check(str(plan["action"]) == "skill" and str(plan.get("skill_id", "")) == "mend", "cleric plans Mend for a badly hurt ally")
    check(plan["target"] == bram, "Mend is aimed at the wounded ally")
    var hp_before: int = bram.hp
    var mp_before: int = cal.mp
    var turns_before: int = c.turn_count
    c.run_ai_turn(true)
    check(bram.hp > hp_before, "auto turn heals the wounded ally")
    check(cal.mp < mp_before, "Mend spends MP")
    check(cal.has_acted, "the cleric's action is used up")
    check(c.turn_count == turns_before + 1, "the turn passes on after the auto turn")

    # Switching Auto on in the middle of a turn: a unit that already moved must not move again.
    var c2 := BattleController.new()
    c2.setup(gd.battle_def("battle_01"), gd.as_db(), 4242)
    c2.begin()
    var guard := 0
    while c2.active_unit().team != "player" and guard < 20:
        c2.run_ai_turn()
        guard += 1
    var a: BattleUnit = c2.active_unit()
    var moves: Array[Vector2i] = c2.move_targets(a)
    check(moves.size() > 0 and c2.try_move(a, moves[0]), "player unit moves by hand first")
    var cell_after_move: Vector2i = a.cell
    var turns2: int = c2.turn_count
    c2.run_ai_turn(true)
    check(a.cell == cell_after_move, "auto does not move a unit that already moved this turn")
    check(c2.turn_count == turns2 + 1, "auto finishes the part-played turn")

    # Without force the AI must still refuse to play the player's side.
    var c3 := BattleController.new()
    c3.setup(gd.battle_def("battle_01"), gd.as_db(), 99)
    c3.begin()
    guard = 0
    while c3.active_unit().team != "player" and guard < 20:
        c3.run_ai_turn()
        guard += 1
    var turns3: int = c3.turn_count
    c3.run_ai_turn()
    check(c3.turn_count == turns3, "run_ai_turn() without force leaves the player's unit alone")


## Milestone 2 (step 1): items, equipment, character sheets, EXP, promotion, the persistent party.
func _test_progression() -> void:
    print("[progression]")
    var db: Dictionary = gd.as_db()
    var items: Dictionary = db["items"]

    # --- data integrity
    var stat_keys: Array = ["hp", "mp", "str", "dex", "int", "vit", "spd", "lck", "acc", "eva", "ldr", "mor"]
    var item_slots: Array = ["weapon", "offhand", "armor", "helm", "accessory", "trade_good"]
    var rarities: Array = ["common", "uncommon", "rare", "epic", "legendary", "mythical", "unique"]
    var items_ok := items.size() >= 15
    for k in items.keys():
        var it: Dictionary = items[k]
        if not item_slots.has(str(it.get("slot", ""))) or not rarities.has(str(it.get("rarity", ""))):
            items_ok = false
        if str(it.get("slot", "")) == "trade_good" and not bool(it.get("trade_good", false)):
            items_ok = false
        if bool(it.get("trade_good", false)) and str(it.get("slot", "")) != "trade_good":
            items_ok = false
        if str(it.get("slot", "")) == "weapon" and not gd.weapons.has(str(it.get("weapon_id", ""))):
            items_ok = false
        var bonus: Dictionary = it.get("bonus", {})
        for b in bonus.keys():
            if not stat_keys.has(str(b)):
                items_ok = false
    check(items_ok, "every item has a valid slot, rarity, weapon link and stat-bonus keys")
    var party: PartyState = PartyState.new_game(gd.start, gd.characters)
    check(party.roster.size() == 4 and party.gold == 150, "new game: 4 party members and 150 gold")
    var gear_ok := true
    for k in party.inventory.keys():
        if not items.has(k):
            gear_ok = false
    for cid in party.roster:
        var sh0: CharacterSheet = party.sheet(cid)
        for slot in CharacterSheet.SLOTS:
            if sh0.item_in(slot) != "" and not items.has(sh0.item_in(slot)):
                gear_ok = false
    check(gear_ok, "starting inventory and starting equipment only use known items")
    var same := true
    for k in gd.characters.keys():
        var raw: Dictionary = gd.characters[k]
        var res: Dictionary = db["characters"][k]
        if int(res["armor_def"]) != int(raw["armor_def"]) or int(res["armor_res"]) != int(raw["armor_res"]) or str(res["weapon_id"]) != str(raw["weapon_id"]):
            same = false
        var rs: Dictionary = res["stats"]
        var ws: Dictionary = raw["stats"]
        for sk in ws.keys():
            if int(rs.get(sk, 0)) != int(ws[sk]):
                same = false
    check(same, "equipment-resolved characters keep the exact v0.2 weapon, armor and stat numbers")

    # --- equipping
    var torren: CharacterSheet = party.sheet("torren")
    var atk0: float = float(torren.derived(db)["attack"])
    check(party.equip("torren", "weapon", "fine_arming_sword", db) == "", "Torren equips the Fine Arming Sword")
    check(float(torren.derived(db)["attack"]) > atk0, "a better sword raises attack")
    check(party.item_count("fine_arming_sword") == 0 and party.item_count("arming_sword") == 1, "the old sword returns to the inventory")
    check(party.equip("torren", "weapon", "fine_arming_sword", db) != "", "cannot equip an item that is not in the inventory")
    check(party.equip("bram", "accessory1", "dunmarrow_signet", db) != "", "an heirloom refuses another owner")
    var mor0: int = int(torren.total_stats(items)["mor"])
    check(party.equip("torren", "accessory1", "dunmarrow_signet", db) == "", "Torren may wear the Dunmarrow Signet")
    check(int(torren.total_stats(items)["mor"]) == mor0 + 5, "the signet adds +5 morale")
    check(party.equip("torren", "helm", "pilgrim_medal", db) != "", "an accessory does not fit the helm slot")
    check(party.equip("torren", "accessory2", "hawk_feather", db) == "", "second accessory slot works")
    check(party.equip("torren", "weapon", "greatsword", db) != "", "a two-handed weapon is refused while a buckler is held")
    check(party.unequip("torren", "offhand") == "" and party.item_count("buckler") == 1, "unequip returns the buckler")
    check(party.equip("torren", "weapon", "greatsword", db) == "", "greatsword equips with a free off-hand")
    check(party.equip("torren", "offhand", "kite_shield", db) != "", "the two-hander blocks the off-hand")
    var d: Dictionary = torren.derived(db)
    check(d.has("attack") and d.has("defense") and d.has("crit") and d.has("move"), "derived stats are produced for the sheet screen")
    check(party.equip("torren", "weapon", "fine_arming_sword", db) == "", "swap back to the Fine Arming Sword")
    var bdb: Dictionary = party.battle_db(db)
    var bc := BattleController.new()
    bc.setup(gd.battle_def("battle_01"), bdb, 5)
    var torren_unit: BattleUnit = null
    for o in bc.units:
        var u: BattleUnit = o
        if u.character_id == "torren":
            torren_unit = u
    check(torren_unit != null and torren_unit.weapon_id == "fine_arming_sword", "a battle built from the party uses Torren's current weapon")

    # --- experience and levels
    var rng := RandomNumberGenerator.new()
    rng.seed = 5
    var sela: CharacterSheet = CharacterSheet.from_def("sela", gd.characters["sela"])
    var mira0: CharacterSheet = CharacterSheet.from_def("sela", gd.characters["sela"])
    var archer: Dictionary = gd.classes["archer"]
    check(sela.exp_to_next() == 120, "level 2 needs 120 EXP on the revised campaign curve")
    var rep: Dictionary = sela.add_exp(119, rng, archer)
    var lvls: Array = rep["levels"]
    check(sela.level == 2 and sela.xp == 119 and lvls.is_empty(), "119 EXP is not enough to level up")
    rep = sela.add_exp(1, rng, archer)
    lvls = rep["levels"]
    check(sela.level == 3 and sela.xp == 0 and lvls.size() == 1, "120 EXP reaches level 3 with nothing left over")
    var gains: Dictionary = (lvls[0] as Dictionary)["gains"]
    check(not gains.is_empty(), "a level-up always grants at least one stat point")
    rep = sela.add_exp(305, rng, archer)
    lvls = rep["levels"]
    check(sela.level == 5 and sela.xp == 0 and lvls.size() == 2, "305 EXP carries across two increasingly costly level-ups (141 + 164)")
    var grew := true
    for k in mira0.base_stats.keys():
        if int(sela.base_stats[k]) < int(mira0.base_stats[k]):
            grew = false
    check(grew and sela.base_stats != mira0.base_stats, "level-up growth never reduces a stat and always increases at least one")
    var ra := RandomNumberGenerator.new()
    var rb := RandomNumberGenerator.new()
    ra.seed = 9
    rb.seed = 9
    var sa: CharacterSheet = CharacterSheet.from_def("sela", gd.characters["sela"])
    var sb: CharacterSheet = CharacterSheet.from_def("sela", gd.characters["sela"])
    sa.add_exp(900, ra, archer)
    sb.add_exp(900, rb, archer)
    check(sa.level == sb.level and sa.base_stats == sb.base_stats, "level-up rolls are deterministic for a given seed")
    check(CharacterSheet.MAX_LEVEL == 250, "campaign level cap is 250")
    var over_cap: CharacterSheet = CharacterSheet.from_dict({"character_id": "legacy", "level": 999, "xp": 999999, "base_stats": {}})
    check(over_cap.level == 250 and over_cap.xp == 0, "legacy saves are safely clamped to the new 250-level cap")
    check(CharacterSheet.exp_to_next_for(100) > CharacterSheet.exp_to_next_for(10) * 10, "late-game levels require substantially more EXP than early levels")
    sa.level = CharacterSheet.MAX_LEVEL
    sa.xp = 17
    sa.add_exp(5000, ra, archer)
    check(sa.level == CharacterSheet.MAX_LEVEL and sa.xp == 0, "no EXP is stored at the level cap, including pre-existing overflow")
    var cal: CharacterSheet = CharacterSheet.from_def("brother_wystan", gd.characters["brother_wystan"])
    cal.add_exp(2500, rng, gd.classes["cleric"])
    check(cal.level > 5 and int(cal.base_stats["mp"]) > 14, "a cleric's MP grows with levels")

    # --- promotion
    var r2: CharacterSheet = CharacterSheet.from_def("torren", gd.characters["torren"])
    check(r2.promotion_options(gd.classes).is_empty(), "no promotion at level 2")
    r2.level = 10
    var opts: Array[String] = r2.promotion_options(gd.classes)
    check(opts.has("knight") and opts.has("duelist") and not opts.has("berserker"), "level 10 swordsman may become a knight or duelist; the locked berserker is not offered")
    check(not r2.promote("berserker", gd.classes), "a locked class cannot be taken")
    var fake: Dictionary = gd.classes.duplicate(true)
    var fake_sw: Dictionary = fake["swordsman"]
    var fake_targets: Array = fake_sw["promotes_to"]
    fake_targets.append("ghost_class")
    check(not r2.promotion_options(fake).has("ghost_class"), "classes missing from data are not offered")
    check(not r2.promote("ghost_class", gd.classes), "promotion to a class that does not exist is refused")
    check(r2.promote("knight", gd.classes) and r2.class_id == "knight", "promotion changes the class")
    r2.level = 19
    check(r2.promotion_options(gd.classes).is_empty(), "a knight needs level 20 for the next tier")
    r2.level = 20
    var knight_opts: Array[String] = r2.promotion_options(gd.classes)
    check(knight_opts.size() == 1 and knight_opts[0] == "heavy_knight", "a level 20 knight may become a heavy knight")

    # --- battle rewards (FF7 rules: fixed enemy rewards, EXP split among survivors, full AP each, gold to the party)
    var rules: Dictionary = {"classes": gd.classes, "items": gd.items, "runes": gd.sigils}
    var p2: PartyState = PartyState.new_game(gd.start, gd.characters)
    p2.add_member("roadreaver", gd.characters["roadreaver"])        # an undeployed bench member
    var bc2 := BattleController.new()
    bc2.setup(gd.battle_def("battle_01"), p2.battle_db(db), 6)
    for o in bc2.units:
        var u2: BattleUnit = o
        if u2.team == "enemy":
            u2.hp = 0
        if u2.character_id == "bram":
            u2.hp = 0
    var rw: Dictionary = p2.battle_rewards(bc2.units, "victory", rules)
    var rexp: Dictionary = rw["exp"]
    var rap: Dictionary = rw["ap"]
    check(int(rw["total_exp"]) == 250 and int(rw["total_ap"]) == 44 and int(rw["gold"]) == 162 and int(rw["defeated"]) == 4, "four defeated enemies pay 250 EXP, 44 AP and 162 gold in total")
    check(int(rexp["torren"]) == 83 and int(rexp["sela"]) == 83 and int(rexp["brother_wystan"]) == 83, "EXP is split equally between the 3 survivors (250 / 3 = 83)")
    check(not rexp.has("bram") and not rap.has("bram"), "a fallen unit earns neither EXP nor AP")
    check(int(rap["torren"]) == 44 and int(rap["brother_wystan"]) == 44, "every survivor receives the full AP total")
    check(int(rexp["roadreaver"]) == 33 and not rap.has("roadreaver"), "bench member gets 40% of a survivor's EXP share and no AP")
    var lost: Dictionary = p2.battle_rewards(bc2.units, "defeat", rules)
    check((lost["exp"] as Dictionary).is_empty() and int(lost["gold"]) == 0, "a defeat pays nothing")
    for o in bc2.units:
        var u2b: BattleUnit = o
        if u2b.team == "enemy" and u2b.is_commander == false:
            u2b.hp = 1
    var part: Dictionary = p2.battle_rewards(bc2.units, "victory", rules)
    check(int(part["total_exp"]) == 120 and int(part["defeated"]) == 1, "enemies that are still alive pay nothing (only the chief was defeated)")
    var gold0: int = p2.gold
    var applied: Dictionary = p2.apply_battle_result(bc2.units, "victory", rng, rules)
    var reps: Array = applied["reports"]
    check(p2.gold == gold0 + int(applied["gold"]) and reps.size() == 4, "gold is paid and every rewarded member gets a report")
    var wy: CharacterSheet = p2.sheet("brother_wystan")
    var wsig: Dictionary = wy.sigil_at("weapon", 0)
    check(int(wsig.get("ap", 0)) == 20, "Brother Wystan's equipped rune of Mending gained the AP")
    var c3 := BattleController.new()
    c3.setup(gd.battle_def("battle_01"), gd.as_db(), 321)
    c3.begin()
    var guard := 0
    while c3.result == "" and guard < 800:
        c3.run_ai_turn(true)
        guard += 1
    var earned := 0
    var expected := 0
    for o in c3.units:
        var u3: BattleUnit = o
        if u3.team == "player":
            earned += u3.kill_exp
        elif not u3.is_alive():
            expected += CombatCalc.kill_exp(u3)
    check(earned == expected, "controller still tracks the EXP value of every kill (statistic)")

    # --- persistence
    var parsed: Dictionary = JSON.parse_string(JSON.stringify(party.to_dict()))
    var p3: PartyState = PartyState.from_dict(parsed)
    var s_old: CharacterSheet = party.sheet("torren")
    var s_new: CharacterSheet = p3.sheet("torren")
    check(p3.roster == party.roster and p3.gold == party.gold and p3.inventory == party.inventory, "party roster, gold and inventory survive a JSON round trip")
    check(JSON.stringify(p3.sigil_inv) == JSON.stringify(party.sigil_inv) and JSON.stringify(p3.sheet("brother_wystan").sigils) == JSON.stringify(party.sheet("brother_wystan").sigils), "rune inventory and socketed runes survive a JSON round trip")
    check(s_new != null and s_new.equipment == s_old.equipment and s_new.base_stats == s_old.base_stats and s_new.level == s_old.level and s_new.xp == s_old.xp, "sheet equipment, stats, level and EXP survive a JSON round trip")


func _test_runes() -> void:
    print("[runes]")
    var defs: Dictionary = gd.runes
    check(defs.size() >= 70, "rune library includes 70+ active, passive, unique and heirloom types")
    var passive_count := 0
    var unique_count := 0
    var heirloom_count := 0
    for rd0 in defs.values():
        var rd0d: Dictionary = rd0
        if str(rd0d.get("kind", "")) == "passive": passive_count += 1
        if bool(rd0d.get("unique", false)): unique_count += 1
        if bool(rd0d.get("heirloom", false)): heirloom_count += 1
    check(passive_count >= 20 and unique_count >= 5 and heirloom_count >= 3, "passive, unique and heirloom rune families are populated")
    var grades_ok := true
    for id in defs.keys():
        var rd: Dictionary = defs[id]
        if not RuneSystem.GRADES.has(str(rd.get("grade", ""))) or str(rd.get("rune_type", "")) == "":
            grades_ok = false
    check(grades_ok, "every rune defines a type and supported starting grade")
    check(RuneSystem.next_grade("common") == "uncommon" and RuneSystem.next_grade("mythical") == "", "rune grade ladder has six tiers and a firm cap")
    check(RuneSystem.success_chance("uncommon") == 70 and RuneSystem.success_chance("mythical") == 12, "higher-grade fusion chances decrease")
    var saw_success := false
    var saw_failure := false
    for seed in range(1, 80):
        var bag: Array = [{"id":"ember","ap":0},{"id":"ember","ap":0},{"id":"ember","ap":0}]
        var rng := RandomNumberGenerator.new()
        rng.seed = seed
        var result: Dictionary = RuneSystem.combine(bag, "ember", "uncommon", defs, rng)
        if bool(result.get("success", false)):
            saw_success = true
            check(bag.size() == 1 and RuneSystem.grade_of(bag[0], defs) == "rare", "successful fusion returns one higher-grade rune")
        else:
            saw_failure = true
            check(bag.size() == 1 and RuneSystem.grade_of(bag[0], defs) == "uncommon", "failed fusion returns one rune at its original grade")
        if saw_success and saw_failure:
            break
    check(saw_success and saw_failure, "chance-based fusion can both succeed and fail")
    var few: Array = [{"id":"ember","ap":0},{"id":"ember","ap":0}]
    var rng2 := RandomNumberGenerator.new()
    rng2.seed = 4
    var refused: Dictionary = RuneSystem.combine(few, "ember", "uncommon", defs, rng2)
    check(not bool(refused.get("ok", false)) and few.size() == 2, "fusion refuses fewer than three runes without consuming them")
    check(ShopSystem.for_sale(gd.shop, "rune", "ember") and not ShopSystem.for_sale({"runes":[]}, "rune", "shadow"), "only explicitly stocked rune merchants sell runes")
    check(str(gd.skills["ember_bolt"].get("rune_effect", {}).get("status", "")) == "burn" and str(gd.skills["frost_shard"].get("rune_effect", {}).get("status", "")) == "chill", "elemental spells define special combat effects")
    var status_probe := BattleUnit.new()
    status_probe.stats = {"spd":100,"vit":10,"int":10}
    status_probe.armor_def = 10
    status_probe.armor_res = 5
    status_probe.statuses["chill"] = {"turns":2}
    check(is_equal_approx(status_probe.effective_spd(), 80.0), "Chill reduces the affected unit's effective speed by 20%")
    status_probe.statuses.erase("chill")
    var normal_defense: float = CombatCalc.defense(status_probe, "physical")
    status_probe.statuses["exposed"] = {"turns":2}
    check(is_equal_approx(CombatCalc.defense(status_probe, "physical"), normal_defense * 0.8), "Exposed reduces physical defense by 20%")
    var mixed: Array = [{"id":"ember","ap":0,"grade":"common"},{"id":"ember","ap":0,"grade":"uncommon"},{"id":"ember","ap":0,"grade":"rare"}]
    var mixed_preview: Dictionary = RuneSystem.preview(mixed, "ember", defs)
    check(bool(mixed_preview.get("ok", false)), "runes of mixed grades can be fused")
    var mastered: Array = [{"id":"ember","ap":520,"grade":"uncommon"},{"id":"ember","ap":520,"grade":"uncommon"},{"id":"ember","ap":520,"grade":"uncommon"}]
    var mastered_preview: Dictionary = RuneSystem.preview(mastered, "ember", defs)
    check(int(mastered_preview.get("chance", 0)) > int(RuneSystem.preview([{"id":"ember","ap":0,"grade":"uncommon"},{"id":"ember","ap":0,"grade":"uncommon"},{"id":"ember","ap":0,"grade":"uncommon"}], "ember", defs).get("chance", 0)), "rune mastery levels improve fusion chance")
    var locked: Array = [{"id":"worldtree","ap":0},{"id":"worldtree","ap":0},{"id":"worldtree","ap":0}]
    check(not bool(RuneSystem.preview(locked, "worldtree", defs).get("ok", false)), "heirloom runes cannot be fused")
    check(not bool(RuneSystem.preview([{"id":"dragon"},{"id":"dragon"},{"id":"dragon"}], "dragon", defs).get("ok", false)), "unique runes cannot be fused")
    check(RuneSystem.grade_power_bonus({"id":"ember","grade":"rare"}, defs) == 5, "one fusion grade above a rune's starting grade adds five percent power")
    var passive_party: PartyState = PartyState.new_game(gd.start, gd.characters)
    var passive_sheet: CharacterSheet = passive_party.sheet("torren")
    var passive_before: Dictionary = passive_sheet.total_stats(gd.items, defs)
    passive_sheet.sigils["weapon"] = [{"id":"thorn","ap":0}, {}]
    var passive_after: Dictionary = passive_sheet.total_stats(gd.items, defs)
    check(int(passive_after["vit"]) == int(passive_before["vit"]) + 2, "socketed passive runes apply their current-level stat modifiers")
    var protected_party: PartyState = PartyState.new_game(gd.start, gd.characters)
    protected_party.sigil_inv = [{"id":"dragon","ap":0},{"id":"phoenix_heirloom","ap":0}]
    var protected_count: int = protected_party.sigil_inv.size()
    check(ShopSystem.sell_sigil(protected_party, 0, gd.as_db(), gd.shop) != "" and ShopSystem.sell_sigil(protected_party, 1, gd.as_db(), gd.shop) != "" and protected_party.sigil_inv.size() == protected_count, "unique and heirloom runes cannot be sold")


func _test_weapon_skills() -> void:
    print("[weapon skills]")
    var db: Dictionary = gd.as_db()
    check(gd.skills.has("power_strike") and gd.skills.has("aimed_shot") and str(gd.skills["power_strike"]["type"]) == "strike", "Power Strike and Aimed Shot exist as strike skills")
    var ps: PartyState = PartyState.new_game(gd.start, gd.characters)
    var bc := BattleController.new()
    bc.setup(gd.battle_def("battle_01"), ps.battle_db(db), 21)
    bc.begin()
    var hero: BattleUnit = null
    var foe: BattleUnit = null
    var archer: BattleUnit = null
    for o in bc.units:
        var u: BattleUnit = o
        if u.character_id == "torren":
            hero = u
        elif u.character_id == "sela":
            archer = u
        elif u.team == "enemy" and foe == null:
            foe = u
    check(hero != null and foe != null and archer != null, "hero, archer and a foe exist")
    if hero == null or foe == null or archer == null:
        return
    check(hero.skills.has("power_strike") and archer.skills.has("aimed_shot"), "Torren (Swordsman) knows Power Strike and Sela (Archer) knows Aimed Shot from their classes")
    check((gd.characters["torren"]["skills"] as Array).is_empty(), "the skill comes from the class, not from the character file")
    var tsheet: CharacterSheet = ps.sheet("torren")
    check(tsheet.all_skills(db["items"], db["runes"]).is_empty() and tsheet.all_skills(db["items"], db["runes"], db["classes"]).has("power_strike"), "class skills need the class table; all_skills without it grants none")
    var ok_cs := true
    for k in gd.classes.keys():
        for sid in ((gd.classes[k] as Dictionary).get("class_skills", {}) as Dictionary).keys():
            if not gd.skills.has(str(sid)):
                ok_cs = false
    check(ok_cs, "every class skill exists in skills.json")
    foe.cell = hero.cell + Vector2i(1, 0)
    bc.active_id = hero.id
    hero.has_acted = false
    hero.has_moved = false
    var sk: Dictionary = gd.skills["power_strike"]
    var plain: Dictionary = CombatCalc.preview(hero, foe, bc.weapon_of(hero), bc.map, bc.units)
    var prev: Dictionary = CombatCalc.skill_preview(hero, foe, sk, "power_strike", bc.weapon_of(hero))
    check(float(prev["normal"]) > 0.0 and int(prev["dmg_max"]) >= int(plain["dmg_min"]), "Power Strike previews more damage than the plain minimum hit")
    check(bc.skill_targets(hero, "power_strike").has(foe) and not bc.skill_targets(hero, "power_strike").has(archer), "Power Strike hits an adjacent enemy only")
    var hp0: int = foe.hp
    var mp0: int = hero.mp
    check(bc.try_skill(hero, "power_strike", foe), "Power Strike succeeds")
    var dealt: int = hp0 - foe.hp
    check(dealt >= int(prev["dmg_min"]) and dealt <= int(prev["dmg_max"]) and hero.mp == mp0 - 3 and hero.has_acted, "damage is inside the preview range, 3 MP spent, turn used")
    check(ItemInfo.skill_line("power_strike", gd.skills).contains("weapon attack"), "the skill line describes a weapon skill")


func _test_world() -> void:
    print("[overworld]")
    var cfg: Dictionary = gd.world
    check(int(cfg.get("width", 0)) >= 32 and (cfg.get("places", []) as Array).size() >= 4, "world.json defines a map and at least four places")
    var w1: WorldMap = WorldMap.generate(cfg)
    var w2: WorldMap = WorldMap.generate(cfg)
    check(w1.width == int(cfg["width"]) and w1.height == int(cfg["height"]) and w1.tiles.size() == w1.width * w1.height, "the generated map has the configured size")
    check(w1.tiles == w2.tiles, "the same seed always gives the same land")
    var other: Dictionary = cfg.duplicate(true)
    other["seed"] = int(cfg["seed"]) + 1
    check(WorldMap.generate(other).tiles != w1.tiles, "a different seed gives different land")
    var frac: float = w1.walkable_fraction()
    check(frac > 0.5 and frac < 0.98, "most of the world is walkable but not all of it (%d%%)" % int(frac * 100.0))
    var all_ok := true
    for p in w1.places:
        var c: Vector2i = w1.place_cell(str((p as Dictionary)["id"]))
        if not w1.walkable(c):
            all_ok = false
    check(all_ok, "every place stands on walkable ground")
    var roads_ok := true
    for r in (cfg.get("roads", []) as Array):
        var pair: Array = r
        if not w1.connected(w1.place_cell(str(pair[0])), w1.place_cell(str(pair[1]))):
            roads_ok = false
    check(roads_ok, "every road in world.json really connects its two places")
    check(w1.connected(w1.start_cell, w1.place_cell("camp")), "the Roadwolf Camp can be reached on foot from Kaer Sethorn")
    check(w1.wrap_enabled and w1.walkable(Vector2i(-1, 0)) and w1.walkable(Vector2i(w1.width, 0)), "the campaign map wraps at every edge instead of blocking movement")
    check(w1.speed_at(w1.start_cell) > 1.0 and WorldMap.SPEED[WorldMap.FOREST] < 1.0 and WorldMap.SPEED[WorldMap.WATER] == 0.0, "roads are fast, forests slow and deep water blocks")
    check(WorldMap.DANGER[WorldMap.FOREST] > WorldMap.DANGER[WorldMap.GRASS] and WorldMap.DANGER[WorldMap.ROAD] < WorldMap.DANGER[WorldMap.GRASS], "forests are more dangerous than grass and roads are safer")
    check(WorldMap.encounter_threshold(cfg, 0.0) == float(cfg["encounter_min"]) and WorldMap.encounter_threshold(cfg, 1.0) == float(cfg["encounter_max"]), "the ambush threshold runs from encounter_min to encounter_max")
    check(not gd.battle_def(str(w1.place_by_id("camp")["battle"])).is_empty(), "the camp points at a real battle")
    var regional_ok := true
    for place in w1.places:
        var pd: Dictionary = place
        if str(pd.get("kind", "")) == "dungeon":
            var dungeon_id: String = str(pd.get("town", ""))
            var boss_battle: String = str(pd.get("battle", ""))
            if not gd.locations.get("maps", {}).has(dungeon_id) or gd.battle_def(boss_battle).is_empty():
                regional_ok = false
    check(regional_ok and w1.connected(w1.place_cell("crossing"), w1.place_cell("thornmere")) and w1.connected(w1.place_cell("crossing"), w1.place_cell("cindermead")), "Orrowen and Vessmoor roads connect to Sallow Crossing with playable dungeon entries")
    var skirmish: Dictionary = EncounterBuilder.build_skirmish(gd.encounters, gd.battles, rng_for_tests())
    check(not skirmish.is_empty() and str(skirmish.get("id", "")) == "skirmish", "an ambush can build a skirmish battle")


func _test_world_atlas() -> void:
    print("[world atlas]")
    var atlas: Array = gd.continents.get("continents", [])
    check(atlas.size() == 7, "global atlas defines exactly seven continents")
    var ids: Dictionary = {}
    var metadata_ok := true
    var shapes_ok := true
    var regions_ok := true
    var current_ok := false
    for entry in atlas:
        var continent: Dictionary = entry
        var cid := str(continent.get("id", ""))
        if cid == "" or ids.has(cid):
            metadata_ok = false
        ids[cid] = true
        for field in ["name", "epithet", "capital", "ruling_power", "climate", "identity", "conflict", "campaign_hook", "signature_locations", "regions", "map_color", "map_label", "map_shape"]:
            if not continent.has(field):
                metadata_ok = false
        var shape: Array = continent.get("map_shape", [])
        if shape.size() < 7:
            shapes_ok = false
        for point in shape:
            var pair: Array = point
            if pair.size() != 2 or float(pair[0]) < 0.0 or float(pair[0]) > 1.0 or float(pair[1]) < 0.0 or float(pair[1]) > 1.0:
                shapes_ok = false
        if (continent.get("regions", []) as Array).size() < 4:
            regions_ok = false
        if cid == "eldrimar" and bool(continent.get("current", false)) and not (continent.get("regions", []) as Array).is_empty() and str(((continent.get("regions", []) as Array)[0] as Dictionary).get("id", "")) == "sethmarch":
            current_ok = true
    check(ids.size() == 7 and metadata_ok, "all continents have unique ids and complete worldbuilding records")
    check(shapes_ok, "every continent has a valid normalized vector-map silhouette")
    check(regions_ok, "each continent has at least four named regional territories")
    check(current_ok and str(gd.continents.get("current_continent", "")) == "eldrimar", "existing Sethmarch Frontier remains anchored to current continent Eldrimar")
    check(str(gd.continents.get("world_age", "")) != "" and str(gd.continents.get("central_mystery", "")) != "", "global atlas establishes a shared campaign-age mystery")

func _test_faction_politics() -> void:
    print("[campaign factions and diplomacy]")
    var definitions: Dictionary = gd.factions
    var factions: Array = definitions.get("factions", [])
    check(factions.size() >= 15, "seven-continent faction data includes the major political powers and secret order")
    var faction_ids: Dictionary = {}
    for entry in factions:
        var faction: Dictionary = entry
        faction_ids[str(faction.get("id", ""))] = true
    var atlas_region_ids: Dictionary = {}
    for continent_entry in gd.continents.get("continents", []):
        for region_entry in (continent_entry as Dictionary).get("regions", []):
            atlas_region_ids[str((region_entry as Dictionary).get("id", ""))] = true
    var faction_regions: Dictionary = definitions.get("regions", {})
    var coverage_ok: bool = atlas_region_ids.size() == faction_regions.size()
    for region_id in atlas_region_ids.keys():
        var region: Dictionary = faction_regions.get(str(region_id), {})
        if region.is_empty() or not faction_ids.has(str(region.get("owner", ""))):
            coverage_ok = false
    check(coverage_ok, "every authored atlas region has a valid initial political affiliation")
    check(str(faction_regions.get("sethmarch", {}).get("owner", "")) == "house_dunmarrow", "Sethmarch begins under the contested Dunmarrow claim")
    var state: Dictionary = FactionSystem.new_campaign_state(definitions)
    check(FactionSystem.relation(state, "house_orrowen", "house_vessmoor") == 0 and FactionSystem.relation(state, "house_vessmoor", "house_orrowen") == 0, "new campaigns begin with neutral, symmetric diplomatic relations")
    check(not FactionSystem.set_diplomatic_state(state, "house_orrowen", "house_vessmoor", "alliance"), "an alliance cannot be formed below the required trust threshold")
    check(FactionSystem.relation_label(-60) == "Hostile" and FactionSystem.relation_label(-20) == "Strained" and FactionSystem.relation_label(0) == "Neutral" and FactionSystem.relation_label(30) == "Cordial" and FactionSystem.relation_label(60) == "Trusted", "diplomacy ledger presents consistent standing bands")
    check(not FactionSystem.can_propose_alliance(state, "house_orrowen", "house_vessmoor"), "alliance proposals stay locked below the authored threshold")
    var treaty_state: Dictionary = FactionSystem.new_campaign_state(definitions)
    check(not FactionSystem.can_propose_treaty(treaty_state, "house_orrowen", "house_vessmoor", "non_aggression"), "non-aggression requires its minimum relation threshold")
    FactionSystem.adjust_relation(treaty_state, "house_orrowen", "house_vessmoor", 20, "coastal patrol cooperation")
    check(FactionSystem.next_proposable_treaty(treaty_state, "house_orrowen", "house_vessmoor") == "non_aggression", "the first treaty tier unlocks at 20 relation")
    check(FactionSystem.propose_treaty(treaty_state, "house_orrowen", "house_vessmoor", "non_aggression"), "trusted neighbors can sign a non-aggression pact")
    check(not FactionSystem.can_propose_treaty(treaty_state, "house_orrowen", "house_vessmoor", "non_aggression"), "a treaty cannot be proposed twice")
    FactionSystem.adjust_relation(treaty_state, "house_orrowen", "house_vessmoor", 15, "shared merchant escort")
    check(FactionSystem.next_proposable_treaty(treaty_state, "house_orrowen", "house_vessmoor") == "trade_pact", "a trade pact unlocks at 35 relation after non-aggression")
    check(FactionSystem.propose_treaty(treaty_state, "house_orrowen", "house_vessmoor", "trade_pact"), "trusted neighbors can upgrade to a trade pact")
    check(FactionSystem.next_treaty_threshold("trade_pact") == FactionSystem.ALLIANCE_THRESHOLD, "the diplomacy ledger reports the next alliance threshold")
    FactionSystem.adjust_relation(treaty_state, "house_orrowen", "house_vessmoor", 15, "mutual defense")
    check(FactionSystem.next_proposable_treaty(treaty_state, "house_orrowen", "house_vessmoor") == "alliance", "an alliance unlocks at 50 relation after a trade pact")
    check(FactionSystem.propose_treaty(treaty_state, "house_orrowen", "house_vessmoor", "alliance"), "a trade pact can be upgraded to an alliance")
    FactionSystem.set_diplomatic_state(treaty_state, "house_orrowen", "house_vessmoor", "war")
    check(not FactionSystem.can_propose_treaty(treaty_state, "house_orrowen", "house_vessmoor", "non_aggression"), "war blocks all treaty proposals")
    check(FactionSystem.adjust_relation(state, "house_orrowen", "house_vessmoor", 60, "shared defence"), "authored events can change faction relations")
    check(FactionSystem.set_diplomatic_state(state, "house_vessmoor", "house_orrowen", "alliance"), "trusted factions can form an alliance regardless of argument order")
    check(not FactionSystem.can_propose_alliance(state, "house_orrowen", "house_vessmoor"), "an established alliance is not offered a duplicate proposal")
    check(FactionSystem.can_propose_alliance(state, "house_orrowen", "crownlands") == false, "the diplomacy ledger cannot propose an alliance with an untrusted faction")
    check(FactionSystem.set_diplomatic_state(state, "house_orrowen", "house_vessmoor", "war"), "campaign events can declare a diplomatic state of war")
    check(FactionSystem.adjust_relation(state, "house_orrowen", "house_vessmoor", 1000, "test clamp") and FactionSystem.relation(state, "house_orrowen", "house_vessmoor") == 100, "relations clamp safely to the positive bound")
    check(FactionSystem.transfer_region(state, "sethmarch", "crownlands", "authored succession outcome"), "authored outcomes can transfer a known atlas territory")
    check(not FactionSystem.transfer_region(state, "unknown_region", "crownlands", "invalid"), "unknown territories cannot be created by a transfer")
    check(not FactionSystem.transfer_region(state, "sethmarch", "invented_faction", "invalid"), "territory cannot be transferred to an unknown faction")
    check((state.get("history", []) as Array).size() >= 5, "diplomatic and territorial changes are recorded in bounded campaign history")
    var restored: Dictionary = FactionSystem.normalize_state(state, definitions)
    check(restored == state, "faction diplomacy and territorial ownership survive state normalization")
    var legacy: Dictionary = FactionSystem.normalize_state({}, definitions)
    check(legacy.get("territories", {}).size() == atlas_region_ids.size(), "legacy saves receive safe default political state for all atlas regions")


func _test_thalassar_region() -> void:
    print("[Thalassar / Brinegate Coast]")
    var cfg: Dictionary = gd.thalassar_world
    check(not cfg.is_empty() and str(cfg.get("name", "")) == "The Brinegate Coast", "Brinegate Coast is loaded as a separate regional world")
    var coast: WorldMap = WorldMap.generate(cfg)
    check(coast.width == 64 and coast.height == 48 and coast.tiles.size() == 64 * 48, "Brinegate Coast generates a deterministic 64x48 overworld")
    var routes_ok := true
    for raw in cfg.get("roads", []):
        var pair: Array = raw
        if not coast.connected(coast.place_cell(str(pair[0])), coast.place_cell(str(pair[1]))):
            routes_ok = false
    check(routes_ok, "all Brinegate coastal roads connect their authored destinations")
    var places_ok := true
    for raw in cfg.get("places", []):
        var place: Dictionary = raw
        if not coast.walkable(coast.place_cell(str(place.get("id", "")))):
            places_ok = false
    check(places_ok and coast.connected(coast.start_cell, coast.place_cell("tideglass_grotto")), "the harbour, settlements, ruins and Tideglass Grotto are reachable")
    var tideglass_battle: Dictionary = gd.battle_def("battle_tideglass")
    check(not tideglass_battle.is_empty(), "Tideglass Grotto resolves to its own tactical battle")
    var wreck_battle: Dictionary = gd.battle_def("battle_northstar_wreck")
    check(not wreck_battle.is_empty() and str(wreck_battle.get("world_flag_on_victory", "")) == "northstar_wreck_cleared", "Northstar Wreck resolves to its own boss battle and clear flag")
    check(gd.characters.has("blackwake_captain"), "the Northstar Wreck captain has an authored human enemy definition")
    var battle_roster_ok := true
    for battle_definition in [tideglass_battle, wreck_battle]:
        for spawn in (battle_definition as Dictionary).get("units", []):
            var cid: String = str((spawn as Dictionary).get("character_id", ""))
            var enemy_def: Dictionary = gd.character_def(cid)
            if enemy_def.is_empty() or not gd.classes.has(str(enemy_def.get("class_id", ""))) or not gd.weapons.has(str(enemy_def.get("weapon_id", ""))):
                battle_roster_ok = false
    check(battle_roster_ok, "every Tideglass and Northstar combatant resolves to an authored character, class and weapon")
    check(gd.world_for_region("brinegate_coast").get("name", "") == "The Brinegate Coast" and gd.world_for_region("sethmarch").get("name", "") == gd.world.get("name", ""), "region routing selects Thalassar without mutating Sethmarch data")
    check(gd.characters.has("maren_vey"), "Maren Vey has a complete recruit character definition")
    check(gd.characters.has("neris_quell") and gd.classes.has(str(gd.character_def("neris_quell").get("class_id", ""))) and gd.weapons.has(str(gd.character_def("neris_quell").get("weapon_id", ""))), "Neris Quell has a complete Thalassar scout character definition")
    var neris_party: PartyState = PartyState.new_game(gd.start, gd.characters)
    var neris_definition: Dictionary = gd.character_def("neris_quell")
    check(not bool(RecruitmentSystem.inspect(neris_party, "neris_quell", neris_definition, {}).get("available", true)), "Neris remains unavailable before the signal and wreck milestones")
    var neris_flags: Dictionary = {"maren_signal_solved": true, "northstar_wreck_cleared": true, "northstar_wreck_log_found": true}
    check(bool(RecruitmentSystem.inspect(neris_party, "neris_quell", neris_definition, neris_flags).get("available", false)), "Neris becomes recruitable after the Northstar Wreck is cleared and the log recovered")
    var neris_recruit: Dictionary = RecruitmentSystem.recruit(neris_party, "neris_quell", neris_definition, neris_flags, {}, gd.traits)
    check(bool(neris_recruit.get("ok", false)) and neris_party.roster.has("neris_quell"), "recruiting Neris adds her to the company without a gold fee")
    check(int(neris_recruit.get("traits_applied", 0)) == 4 and neris_party.sheet("neris_quell").traits.has("observant") and neris_party.sheet("neris_quell").traits.has("survivalist"), "Neris's authored traits are acquired on recruitment rather than altering base content stats")
    var neris_bonds: Dictionary = {}
    check(RecruitmentSystem.apply_relationship_on_join(neris_bonds, "torren", "neris_quell", neris_definition) == 2, "Neris's authored recruitment scene establishes trust and respect")
    var neris_bond: Dictionary = RelationshipSystemScript.get_relationship(neris_bonds, "torren", "neris_quell")
    check(int(neris_bond.get("trust", 0)) == 5 and int(neris_bond.get("respect", 0)) == 4, "Neris's first bond values are distinct from loyalty")

    var recruit_party: PartyState = PartyState.new_game(gd.start, gd.characters)
    var maren: Dictionary = gd.character_def("maren_vey")
    var locked: Dictionary = RecruitmentSystem.inspect(recruit_party, "maren_vey", maren, {})
    check(not bool(locked.get("available", true)), "Maren remains unavailable until the Tideglass ledger is recovered")
    var flags: Dictionary = {"tideglass_grotto_cleared": true, "tideglass_ledger_found": true}
    var unlocked: Dictionary = RecruitmentSystem.inspect(recruit_party, "maren_vey", maren, flags)
    check(bool(unlocked.get("available", false)), "recovering the Tideglass ledger unlocks Maren's recruitment")
    var maps: Dictionary = LocalMap.load_all(gd.locations)
    var coast_maps_ok := maps.has("brinegate") and maps.has("saltmere") and maps.has("lantern_quay") and maps.has("dungeon_tideglass") and maps.has("dungeon_northstar_wreck")
    check(coast_maps_ok, "Brinegate, Saltmere, Lantern Quay, Tideglass and Northstar Wreck have playable location maps")
    if maps.has("dungeon_northstar_wreck"):
        check((maps["dungeon_northstar_wreck"] as LocalMap).kind == "dungeon", "Northstar Wreck is an explorable dungeon with a boss encounter")
    if maps.has("lantern_quay"):
        var quay_map: LocalMap = maps["lantern_quay"]
        var neris_spot_found := false
        for spot in quay_map.spots:
            if str((spot as Dictionary).get("character_id", "")) == "neris_quell":
                neris_spot_found = true
        check(neris_spot_found, "Neris waits at Lantern Quay after the Northstar Wreck rescue")
    if maps.has("dungeon_tideglass"):
        check((maps["dungeon_tideglass"] as LocalMap).kind == "dungeon", "Tideglass is an explorable dungeon, not a static story panel")


func _test_wraparound_world() -> void:
    print("[continuous wraparound world]")
    var cfg: Dictionary = gd.thalassar_world
    var coast: WorldMap = WorldMap.generate(cfg)
    check(coast.wrap_enabled, "campaign world is configured as a continuous wraparound surface")
    check(is_equal_approx(WorldMap.periodic_noise(0, 13, coast.width, coast.height, 10.0, coast.seed_value), WorldMap.periodic_noise(coast.width, 13, coast.width, coast.height, 10.0, coast.seed_value)), "periodic terrain noise matches exactly across the east/west seam")
    check(is_equal_approx(WorldMap.periodic_noise(13, 0, coast.width, coast.height, 10.0, coast.seed_value), WorldMap.periodic_noise(13, coast.height, coast.width, coast.height, 10.0, coast.seed_value)), "periodic terrain noise matches exactly across the north/south seam")
    check(coast.wrap_cell(Vector2i(-1, 7)) == Vector2i(coast.width - 1, 7), "west edge wraps to the east edge")
    check(coast.wrap_cell(Vector2i(coast.width, 7)) == Vector2i(0, 7), "east edge wraps to the west edge")
    check(coast.wrap_cell(Vector2i(7, -1)) == Vector2i(7, coast.height - 1), "north edge wraps to the south edge")
    check(coast.wrap_cell(Vector2i(7, coast.height)) == Vector2i(7, 0), "south edge wraps to the north edge")
    check(coast.wrap_cell(Vector2i(-1, -1)) == Vector2i(coast.width - 1, coast.height - 1), "north-west corner wraps diagonally to the south-east corner")
    check(coast.wrap_cell(Vector2i(coast.width, coast.height)) == Vector2i.ZERO, "south-east corner wraps diagonally to the north-west corner")
    check(coast.walkable(Vector2i(-1, 12)) and coast.walkable(Vector2i(coast.width, 12)), "the opposite map edges are traversable rather than blocked by a boundary wall")
    check(coast.connected(Vector2i(0, 12), Vector2i(coast.width - 1, 12)), "pathfinding connectivity crosses the horizontal world seam")
    check(coast.wrapped_delta(Vector2i(0, 10), Vector2i(coast.width - 1, 10)) == Vector2i(-1, 0), "navigation chooses the short route across the horizontal seam")
    check(coast.wrapped_delta(Vector2i(0, 0), Vector2i(coast.width - 1, coast.height - 1)) == Vector2i(-1, -1), "navigation chooses the diagonal short route across both seams")
    check(coast.terrain_at(Vector2i(-1, 12)) == coast.terrain_at(Vector2i(coast.width - 1, 12)), "terrain sampling is consistent for negative and canonical coordinates")
    var world_size := Vector2(float(coast.width) * 48.0, float(coast.height) * 48.0)
    var wrapped_origin := coast.wrap_position(Vector2(world_size.x, world_size.y))
    check(wrapped_origin == Vector2.ZERO, "exact world-size coordinates normalize to the origin on both axes")
    var wrapped_negative := coast.wrap_position(Vector2(-1.0, -1.0))
    check(wrapped_negative.x >= 0.0 and wrapped_negative.x < world_size.x and wrapped_negative.y >= 0.0 and wrapped_negative.y < world_size.y, "negative coordinates normalize safely on both axes")
    check(coast.wrap_position(wrapped_negative) == wrapped_negative, "canonical save coordinates remain stable when normalized more than once")
    var enclosed_cfg: Dictionary = cfg.duplicate(true)
    enclosed_cfg["wrap_world"] = false
    var enclosed: WorldMap = WorldMap.generate(enclosed_cfg)
    check(not enclosed.wrap_enabled and enclosed.wrap_cell(Vector2i(-1, 7)) == Vector2i(-1, 7), "authored non-wrapping maps retain hard boundaries")
    check(not enclosed.walkable(Vector2i(-1, 7)) and enclosed.wrap_position(Vector2(-1.0, 100.0)) == Vector2(-1.0, 100.0), "non-wrapping maps do not normalize out-of-bounds coordinates")

func _test_brinegate_quest() -> void:
    print("[Brinegate quest]")
    var empty: Dictionary = {}
    check(not BrinegateQuestSystem.can_report_ledger(empty), "the ledger cannot be reported before evidence and guardian are secured")
    var partial: Dictionary = {"tideglass_ledger_found": true}
    check(not BrinegateQuestSystem.can_report_ledger(partial), "finding the ledger alone does not complete the grotto operation")
    var ready_flags: Dictionary = {"tideglass_ledger_found": true, "tideglass_grotto_cleared": true}
    var public_result: Dictionary = BrinegateQuestSystem.resolve_ledger_choice(ready_flags, "public")
    var private_result: Dictionary = BrinegateQuestSystem.resolve_ledger_choice(ready_flags, "private")
    check(bool(public_result.get("ok", false)) and bool((public_result.get("world_flags", {}) as Dictionary).get("brinegate_ledger_shared", false)) and int(public_result.get("gold", -1)) == 0, "public disclosure records the trust outcome without a gold bribe")
    check(bool(private_result.get("ok", false)) and bool((private_result.get("world_flags", {}) as Dictionary).get("brinegate_ledger_withheld", false)) and int(private_result.get("gold", 0)) == 60, "private handling records a distinct outcome and its 60-gold payment")
    var public_bonds: Dictionary = {}
    var public_applied := BrinegateQuestSystem.apply_ledger_relationships(public_bonds, "torren", ["torren", "maren_vey"], gd.characters, "public")
    check(public_applied == 2, "public Brinegate disclosure applies only Maren's authored companion reaction")
    check(int(RelationshipSystemScript.get_relationship(public_bonds, "torren", "maren_vey").get("trust", 0)) == 5 and int(RelationshipSystemScript.get_relationship(public_bonds, "torren", "maren_vey").get("respect", 0)) == 3, "Maren gains trust and respect when the company makes the ledger public")
    check(BrinegateQuestSystem.apply_ledger_relationships(public_bonds, "torren", ["torren", "maren_vey"], gd.characters, "public") == 0, "the same Brinegate choice cannot award relationship evidence twice")
    var private_bonds: Dictionary = {}
    RelationshipSystemScript.adjust(private_bonds, "torren", "maren_vey", "trust", 20, "setup:existing-trust")
    RelationshipSystemScript.adjust(private_bonds, "torren", "maren_vey", "respect", 20, "setup:existing-respect")
    check(BrinegateQuestSystem.apply_ledger_relationships(private_bonds, "torren", ["torren", "maren_vey"], gd.characters, "private") == 2, "private Brinegate handling applies Maren's separately authored reaction")
    check(int(RelationshipSystemScript.get_relationship(private_bonds, "torren", "maren_vey").get("trust", 0)) == 16 and int(RelationshipSystemScript.get_relationship(private_bonds, "torren", "maren_vey").get("respect", 0)) == 18, "Maren's trust and respect respond independently to withholding the ledger")
    check(BrinegateQuestSystem.apply_ledger_relationships({}, "torren", ["torren", "unknown_companion"], gd.characters, "public") == 0, "companions without authored reactions receive no invented relationship changes")
    var duplicate: Dictionary = BrinegateQuestSystem.resolve_ledger_choice(public_result.get("world_flags", {}), "private")
    check(not bool(duplicate.get("ok", true)), "the harbour decision can only be recorded once")
    check(not bool(BrinegateQuestSystem.resolve_ledger_choice(ready_flags, "unknown").get("ok", true)), "unknown harbour choices are rejected")


func _test_maren_companion_quest() -> void:
    print("[Maren Vey companion quest]")
    check(not MarenQuestSystem.start_quest({}, ["torren", "maren_vey"]).get("ok", false), "Maren's personal quest stays locked until the harbour decision is settled")
    check(not MarenQuestSystem.start_quest({"brinegate_ledger_decision": true}, ["torren"]).get("ok", false), "Maren's personal quest stays locked until she joins")
    var started: Dictionary = MarenQuestSystem.start_quest({"brinegate_ledger_decision": true}, ["torren", "maren_vey"])
    check(bool(started.get("ok", false)), "the last sounding quest starts once its prerequisites are met")
    var flags: Dictionary = started.get("world_flags", {})
    var wrong: Dictionary = MarenQuestSystem.submit_signal(flags, "high")
    check(bool(wrong.get("ok", false)) and not bool(wrong.get("correct", true)) and int(wrong.world_flags.get(MarenQuestSystem.PROGRESS_FLAG, -1)) == 0, "an incorrect signal tone resets the sequence without awarding progress")
    flags = MarenQuestSystem.submit_signal(wrong.world_flags, "low").world_flags
    flags = MarenQuestSystem.submit_signal(flags, "high").world_flags
    var final_note: Dictionary = MarenQuestSystem.submit_signal(flags, "rising")
    check(bool(final_note.get("complete", false)), "the low-high-rising signal puzzle restores the Northstar sounding")
    flags = final_note.get("world_flags", {})
    var early_resolution: Dictionary = MarenQuestSystem.resolve_quest(flags, "return_log")
    check(not bool(early_resolution.get("ok", true)), "the quest cannot resolve before the Northstar Wreck is cleared and its logbook recovered")
    flags[MarenQuestSystem.WRECK_CLEARED_FLAG] = true
    flags[MarenQuestSystem.LOG_FOUND_FLAG] = true
    var resolved: Dictionary = MarenQuestSystem.resolve_quest(flags, "return_log")
    check(bool(resolved.get("ok", false)), "Maren's recovered log can be resolved after the wreck is cleared")
    var duplicate: Dictionary = MarenQuestSystem.resolve_quest(resolved.get("world_flags", {}), "publish_log")
    check(not bool(duplicate.get("ok", true)), "the companion quest resolution is one-time")
    check(not bool(MarenQuestSystem.resolve_quest(flags, "unknown").get("ok", true)), "unknown companion quest outcomes are rejected")
    var return_bonds: Dictionary = {}
    check(MarenQuestSystem.apply_relationships(return_bonds, "torren", ["torren", "maren_vey"], gd.characters, "return_log") == 3, "returning the log applies Maren's authored friendship, trust and affection")
    var returned: Dictionary = RelationshipSystemScript.get_relationship(return_bonds, "torren", "maren_vey")
    check(int(returned.get("friendship", 0)) == 8 and int(returned.get("trust", 0)) == 10 and int(returned.get("affection", 0)) == 4, "the private resolution strengthens Maren's bond with the company leader")
    check(MarenQuestSystem.apply_relationships(return_bonds, "torren", ["torren", "maren_vey"], gd.characters, "return_log") == 0, "Maren's personal quest relationship rewards cannot be farmed")
    var public_bonds: Dictionary = {}
    RelationshipSystemScript.adjust(public_bonds, "torren", "maren_vey", "trust", 20, "setup:trust")
    var published_count: int = MarenQuestSystem.apply_relationships(public_bonds, "torren", ["torren", "maren_vey"], gd.characters, "publish_log")
    var published_bond: Dictionary = RelationshipSystemScript.get_relationship(public_bonds, "torren", "maren_vey")
    check(published_count == 2 and int(published_bond.get("respect", 0)) == 8 and int(published_bond.get("trust", 0)) == 15, "publishing the log trades some trust for respect with Maren")
    var maps: Dictionary = LocalMap.load_all(gd.locations)
    var has_maren_quest := false
    for map_id in ["brinegate", "lantern_quay"]:
        for spot in (maps[map_id] as LocalMap).spots:
            if str((spot as Dictionary).get("quest_id", "")) == "maren_signal":
                has_maren_quest = true
    check(has_maren_quest, "Maren's personal quest is reachable from Brinegate and Lantern Quay")


func _test_neris_companion_quest() -> void:
    print("[Neris Quell companion quest]")
    check(not NerisQuestSystem.start_quest({}, ["torren", "neris_quell"]).get("ok", false), "Neris's second-beacon quest stays locked until Maren's quest is resolved")
    check(not NerisQuestSystem.start_quest({"maren_signal_completed": true}, ["torren"]).get("ok", false), "Neris's second-beacon quest requires Neris to be recruited")
    var started: Dictionary = NerisQuestSystem.start_quest({"maren_signal_completed": true}, ["torren", "neris_quell"])
    check(bool(started.get("ok", false)), "Neris can begin charting the second beacon after joining the company")
    var flags: Dictionary = started.get("world_flags", {})
    check(not bool(NerisQuestSystem.resolve_quest(flags, "publish_route").get("ok", true)), "Neris's route cannot be resolved before the charting sequence is complete")
    var wrong: Dictionary = NerisQuestSystem.submit_route(flags, "west")
    check(bool(wrong.get("ok", false)) and not bool(wrong.get("correct", true)) and int(wrong.world_flags.get(NerisQuestSystem.PROGRESS_FLAG, -1)) == 0, "an incorrect bearing resets the route without consuming resources")
    flags = NerisQuestSystem.submit_route(wrong.world_flags, "east").world_flags
    flags = NerisQuestSystem.submit_route(flags, "south").world_flags
    var final_bearing: Dictionary = NerisQuestSystem.submit_route(flags, "east")
    check(bool(final_bearing.get("complete", false)), "east-south-east bearings chart the hidden second beacon")
    flags = final_bearing.get("world_flags", {})
    var published: Dictionary = NerisQuestSystem.resolve_quest(flags, "publish_route")
    check(bool(published.get("ok", false)) and int(published.get("gold", 0)) == 100, "publishing the route opens the merchant passage and rewards the company")
    check(not bool(NerisQuestSystem.resolve_quest(published.get("world_flags", {}), "keep_private").get("ok", true)), "Neris's route can only be resolved once")
    var private_flags: Dictionary = final_bearing.get("world_flags", {})
    var private_result: Dictionary = NerisQuestSystem.resolve_quest(private_flags, "keep_private")
    check(bool(private_result.get("ok", false)) and bool(private_result.world_flags.get("saltmere_fishers_route_open", false)), "keeping the route private reserves it for local fishers")
    var public_bonds: Dictionary = {}
    RelationshipSystemScript.adjust(public_bonds, "torren", "neris_quell", "trust", 20, "setup:existing-trust")
    check(NerisQuestSystem.apply_relationships(public_bonds, "torren", ["torren", "neris_quell"], gd.characters, "publish_route") == 2, "publishing the route applies Neris's authored respect and trust consequences")
    var public_bond: Dictionary = RelationshipSystemScript.get_relationship(public_bonds, "torren", "neris_quell")
    check(int(public_bond.get("respect", 0)) == 8 and int(public_bond.get("trust", 0)) == 16, "public charting trades some trust for respect")
    var private_bonds: Dictionary = {}
    check(NerisQuestSystem.apply_relationships(private_bonds, "torren", ["torren", "neris_quell"], gd.characters, "keep_private") == 3, "keeping the route private applies Neris's authored friendship, trust and affection")
    var private_bond: Dictionary = RelationshipSystemScript.get_relationship(private_bonds, "torren", "neris_quell")
    check(int(private_bond.get("friendship", 0)) == 8 and int(private_bond.get("trust", 0)) == 10 and int(private_bond.get("affection", 0)) == 3, "the private route strengthens Neris's personal bond")
    check(NerisQuestSystem.apply_relationships(private_bonds, "torren", ["torren", "neris_quell"], gd.characters, "keep_private") == 0, "Neris's quest relationship rewards cannot be farmed")
    var maps: Dictionary = LocalMap.load_all(gd.locations)
    var quest_markers := 0
    for map_id in ["lantern_quay", "saltmere"]:
        for spot in (maps[map_id] as LocalMap).spots:
            if str((spot as Dictionary).get("quest_id", "")) == "neris_beacon":
                quest_markers += 1
    check(quest_markers == 2, "Neris's second-beacon quest connects Lantern Quay and Saltmere")
    var saltmere_market_found := false
    for spot in (maps["saltmere"] as LocalMap).spots:
        if str((spot as Dictionary).get("shopkeeper_id", "")) == "saltmere_factor":
            saltmere_market_found = true
    check(saltmere_market_found, "Saltmere's route market is physically located in the settlement")


func _test_region_save_compatibility() -> void:
    print("[region save compatibility]")
    var legacy: Dictionary = RegionSaveState.from_payload({"world_pos": [123.0, 456.0]})
    check(str(legacy.get("active_region_id", "")) == "sethmarch" and legacy.get("world_pos", Vector2.ZERO) == Vector2(123.0, 456.0), "schema-4 campaign saves restore to Sethmarch without losing their position")
    check((legacy.get("world_positions", {}) as Dictionary).get("sethmarch", []) == [123.0, 456.0], "legacy saves seed the per-region position table")
    var coastal: Dictionary = RegionSaveState.from_payload({"world_pos": [8.0, 9.0], "active_region_id": "brinegate_coast", "world_positions": {"sethmarch": [100.0, 200.0]}})
    check(str(coastal.get("active_region_id", "")) == "brinegate_coast" and coastal.get("world_pos", Vector2.ZERO) == Vector2(8.0, 9.0), "new saves restore the active Thalassar position")
    check((coastal.get("world_positions", {}) as Dictionary).get("sethmarch", []) == [100.0, 200.0], "switching continents preserves the other region's last position")


func _test_locations() -> void:
    print("[towns and interiors]")
    var maps: Dictionary = LocalMap.load_all(gd.locations)
    check(maps.size() >= 7, "locations.json defines the towns and houses (%d maps)" % maps.size())
    var errs: Array[String] = LocalMap.validate(maps)
    for e in errs:
        print("        " + e)
    check(errs.is_empty(), "every map is well formed: rectangular, known tiles, doors defined, spawns walkable, everything reachable")
    var towns_ok := true
    for p in (gd.world.get("places", []) as Array):
        var pd: Dictionary = p
        var kind: String = str(pd.get("kind", ""))
        if kind == "keep" or kind == "village":
            var tid: String = str(pd.get("town", ""))
            if not maps.has(tid) or (maps[tid] as LocalMap).kind != "town":
                towns_ok = false
    check(towns_ok, "every keep and village on the overworld opens a town map")
    var dungeons_ok := true
    for p in (gd.world.get("places", []) as Array):
        var pd: Dictionary = p
        if str(pd.get("kind", "")) == "dungeon":
            var dungeon_map: String = str(pd.get("town", ""))
            if not maps.has(dungeon_map) or (maps[dungeon_map] as LocalMap).kind != "dungeon":
                dungeons_ok = false
    check(dungeons_ok, "every regional dungeon opens its own explorable map")
    var round_trip := true
    for k in maps.keys():
        var m: LocalMap = maps[k]
        for dk in m.doors.keys():
            var target: LocalMap = maps[str((m.doors[dk] as Dictionary)["to"])]
            var back := false
            for d2 in target.doors.keys():
                if str((target.doors[d2] as Dictionary)["to"]) == m.id:
                    back = true
            if not back:
                round_trip = false
    check(round_trip, "every door has a way back through the map it leads to")
    var party_spots: int = 0
    for k in ["sethorn_hall", "crossing_shop"]:
        for sp in (maps[k] as LocalMap).spots:
            if str((sp as Dictionary).get("kind", "")) == "party":
                party_spots += 1
    check(party_spots >= 3, "the war table, shop counter and smithy open the party screen")
    var cm: LocalMap = maps["crossing"]
    check(cm.walkable(cm.entry) and cm.is_exit(Vector2i(11, 17)) and not cm.walkable(Vector2i(0, 0)) and not cm.walkable(Vector2i(-3, 4)), "walls and trees block, paths and exits are open, outside the map is blocked")
    check(not cm.door_at(Vector2i(4, 4)).is_empty() and cm.door_at(Vector2i(5, 4)).is_empty(), "door tiles lead somewhere and plain wall does not")


func _test_companion_behavior() -> void:
    print("[companion tactical personality]")
    var definitions: Dictionary = gd.traits
    var calm_brave := CompanionBehaviorScript.risk_tolerance(["brave"], {"stress": 0, "memories": [], "ambition": {}}, definitions)
    check(calm_brave > 0.1, "brave traits increase tactical risk tolerance")
    var distressed := CompanionBehaviorScript.risk_tolerance(["brave"], {"stress": 90, "memories": [{"type":"traumatic"},{"type":"betrayal"}], "ambition": {}}, definitions)
    check(distressed < calm_brave and CompanionBehaviorScript.threat_sensitivity(["brave"], {"stress":90,"memories":[{"type":"traumatic"}]}, definitions) > 1.0, "high stress and traumatic memories make a companion more cautious")
    var protective_score := CompanionBehaviorScript.support_score(["protective","healer"], {"stress":0,"ambition":{"status":"active","combat_focus":"support"}}, {"ally":{"friendship":70,"trust":80,"respect":60,"affection":50,"rivalry":0}}, "ally", definitions)
    check(protective_score >= 20.0, "protective traits, support ambitions and trusted bonds increase ally support priority")
    var aggressive_drive := CompanionBehaviorScript.attack_drive(["reckless"], {"stress":0,"ambition":{"status":"active","combat_focus":"aggressive"}}, definitions)
    check(aggressive_drive > CompanionBehaviorScript.attack_drive([], {}, definitions), "an explicitly aggressive ambition increases attack drive")
    var unit := BattleUnit.create(99, "companion_test", {"name":"Companion","class_id":"knight","stats":{"hp":20,"mor":60},"traits":["protective"],"personality":{"stress":35,"memories":[{"type":"relationship"}],"ambition":{"status":"active","combat_focus":"support"}},"companion_bonds":{"ally":{"trust":40}}}, {"move":4,"jump":1}, "player", Vector2i.ZERO, 0)
    var restored := BattleUnit.from_dict(unit.to_dict())
    check(restored.traits == unit.traits and restored.personality == unit.personality and restored.companion_bonds == unit.companion_bonds, "battle snapshots preserve optional companion tactical context")
    var legacy := BattleUnit.from_dict({"id":1,"character_id":"legacy","stats":{"hp":10},"cell":[0,0]})
    check(legacy.traits.is_empty() and legacy.personality.is_empty() and legacy.companion_bonds.is_empty(), "legacy battle snapshots default safely without companion tactical context")


func _test_recruitment() -> void:
    print("[recruitment and loyalty]")
    var wave_one: int = 0
    for raw in gd.characters.values():
        if int((raw as Dictionary).get("roster_wave", 0)) == 1:
            wave_one += 1
    check(wave_one == 24, "all 24 Wave-1 named characters have complete data definitions")
    var valid_recruits: bool = true
    for cid in gd.characters.keys():
        var def: Dictionary = gd.characters[cid]
        if not def.has("recruit"):
            continue
        if not gd.classes.has(str(def.get("class_id", ""))) or not gd.weapons.has(str(def.get("weapon_id", ""))):
            valid_recruits = false
        if int(def.get("loyalty", -1)) < 0 or int(def.get("loyalty", 101)) > 100:
            valid_recruits = false
    check(valid_recruits, "every recruit has a valid class, weapon and 0-100 starting loyalty")

    var party: PartyState = PartyState.new_game(gd.start, gd.characters)
    var flags: Dictionary = {}
    var joss: Dictionary = gd.character_def("joss_harrow")
    var joss_check: Dictionary = RecruitmentSystem.inspect(party, "joss_harrow", joss, flags)
    check(bool(joss_check.get("available", false)) and int(joss_check.get("cost", -1)) == 50, "Joss is available at the data-defined 50-gold cost")
    party.gold = 40
    var poor_check: Dictionary = RecruitmentSystem.inspect(party, "joss_harrow", joss, flags)
    check(not bool(poor_check.get("available", true)) and party.roster.size() == 4 and not flags.has("recruited_joss_harrow"), "insufficient gold refuses recruitment without changing roster or flags")
    party.gold = 100
    var joined: Dictionary = RecruitmentSystem.recruit(party, "joss_harrow", joss, flags)
    check(bool(joined.get("ok", false)) and party.roster.has("joss_harrow") and party.gold == 50 and bool(flags.get("recruited_joss_harrow", false)), "successful recruitment adds the member, spends gold and records the one-time flag")
    var relationship_state: Dictionary = {}
    var maren_definition: Dictionary = gd.character_def("maren_vey")
    var relationship_count: int = RecruitmentSystem.apply_relationship_on_join(relationship_state, "torren", "maren_vey", maren_definition)
    check(relationship_count == 2, "Maren's authored recruitment event applies two relationship dimensions")
    check(int(RelationshipSystemScript.get_relationship(relationship_state, "torren", "maren_vey").get("trust", 0)) == 6, "Maren's recruitment establishes a small evidence-based trust bond")
    check(int(RelationshipSystemScript.get_relationship(relationship_state, "maren_vey", "torren").get("respect", 0)) == 8, "Maren's recruitment relationship is symmetric and records respect")
    check(RecruitmentSystem.apply_relationship_on_join(relationship_state, "torren", "maren_vey", maren_definition) == 0, "recruitment relationship evidence cannot be applied twice")
    check(party.sheet("joss_harrow").loyalty == 38, "a recruit receives their authored starting loyalty")
    var duplicate: Dictionary = RecruitmentSystem.recruit(party, "joss_harrow", joss, flags)
    check(not bool(duplicate.get("ok", true)) and party.gold == 50, "duplicate recruitment is refused without charging twice")

    party.gold = 500 # keep prerequisite tests independent from recruit affordability
    var verra: Dictionary = gd.character_def("verra_nightsong")
    var fresh_party: PartyState = PartyState.new_game(gd.start, gd.characters)
    var locked: Dictionary = RecruitmentSystem.inspect(fresh_party, "verra_nightsong", verra, flags)
    check(not bool(locked.get("available", true)) and str(locked.get("reason", "")).contains("joss harrow"), "recruit dependencies remain locked until their companion joins")
    var unlocked: Dictionary = RecruitmentSystem.inspect(party, "verra_nightsong", verra, flags)
    check(bool(unlocked.get("available", false)), "joining Joss unlocks Verra's recruitment")
    var bram: Dictionary = gd.character_def("bram_cullen")
    var camp_locked: Dictionary = RecruitmentSystem.inspect(party, "bram_cullen", bram, flags)
    check(not bool(camp_locked.get("available", true)), "story-flag requirements block Bram before the camp is cleared")
    flags["camp_cleared"] = true
    var camp_open: Dictionary = RecruitmentSystem.inspect(party, "bram_cullen", bram, flags)
    check(bool(camp_open.get("available", false)), "clearing the camp unlocks Bram's recruitment")

    check(party.adjust_loyalty("joss_harrow", 90) == 100 and party.adjust_loyalty("joss_harrow", -150) == 0, "loyalty adjustments clamp safely to 0-100")
    var restored: PartyState = PartyState.from_dict(party.to_dict())
    check(restored.sheet("joss_harrow").loyalty == 0, "character loyalty survives party save/load serialization")
    var legacy_sheet: Dictionary = {"character_id":"legacy","name":"Legacy Recruit","class_id":"knight","level":1,"base_stats":{},"skills":[],"equipment":{}}
    var legacy_party: Dictionary = {"roster":["legacy"],"sheets":{"legacy":legacy_sheet},"gold":10}
    var migrated: Dictionary = ss.migrate({"party":legacy_party}, 3)
    var migrated_sheets: Dictionary = (migrated.get("party", {}) as Dictionary).get("sheets", {})
    check(int((migrated_sheets.get("legacy", {}) as Dictionary).get("loyalty", -1)) == 50, "v3 saves migrate existing members to neutral loyalty 50")


func _test_sigils() -> void:
    print("[runes]")
    var db: Dictionary = gd.as_db()
    var items: Dictionary = db["items"]
    var sdefs: Dictionary = db["runes"]
    # --- data integrity
    var ok := sdefs.size() >= 8
    for k in sdefs.keys():
        var sd: Dictionary = sdefs[k]
        if (sd.get("levels", []) as Array).size() != (sd.get("ap", []) as Array).size() + 1:
            ok = false
        for lv in (sd.get("levels", []) as Array):
            for sid in ((lv as Dictionary).get("skills", []) as Array):
                if not gd.skills.has(str(sid)):
                    ok = false
    check(ok, "every rune has one level per AP threshold + 1 and only grants known skills")
    var socket_ok := true
    for k in items.keys():
        var it: Dictionary = items[k]
        if it.has("sockets"):
            for pair in (it.get("links", []) as Array):
                if int((pair as Array)[0]) >= int(it["sockets"]) or int((pair as Array)[1]) >= int(it["sockets"]):
                    socket_ok = false
    check(socket_ok, "every socket link points at a real socket")
    # --- levels and AP thresholds
    var mend: Dictionary = sdefs["mend"]
    check(CharacterSheet.sigil_level({"id": "mend", "ap": 59}, mend) == 1 and CharacterSheet.sigil_level({"id": "mend", "ap": 60}, mend) == 2, "Mending reaches level 2 at exactly 60 AP")
    check(CharacterSheet.sigil_level({"id": "mend", "ap": 480}, mend) == 4 and CharacterSheet.sigil_is_mastered({"id": "mend", "ap": 480}, mend), "480 AP masters the rune of Mending")
    check(CharacterSheet.sigil_ap_to_next({"id": "mend", "ap": 50}, mend) == 10, "10 AP remain to the next level")
    check(CharacterSheet.sigil_skills_at(mend, 1).size() == 1 and CharacterSheet.sigil_skills_at(mend, 1).has("mend") and CharacterSheet.sigil_skills_at(mend, 3).has("mend_ii") and CharacterSheet.sigil_skills_at(mend, 3).has("mend"), "skills accumulate with rune level")
    # --- skills come from sigils
    check((db["characters"]["brother_wystan"]["skills"] as Array).has("mend"), "Brother Wystan's Mend now comes from his socketed rune")
    var ps: PartyState = PartyState.new_game(gd.start, gd.characters)
    var torren: CharacterSheet = ps.sheet("torren")
    check(ps.sigil_inv.size() == 5, "the party starts with 5 runes in the bag")
    check(torren.socket_count("weapon", items) == 2 and torren.socket_count("armor", items) == 2, "Torren's sword and cuirass each have 2 linked sockets")
    var emb_i := _sigil_index(ps, "ember")
    check(ps.equip_sigil("torren", "weapon", 0, emb_i, db, true) == "", "equip the rune of Embers into socket 0")
    check((torren.to_battle_def(db)["skills"] as Array).has("ember_bolt"), "the rune grants Ember Bolt")
    check(ps.equip_sigil("torren", "weapon", 5, 0, db, true) != "" and ps.equip_sigil("torren", "helm", 0, 0, db, true) != "", "bad socket or group is refused")
    # Rejected socket operations must not normalize arrays or move overflow runes as a side effect.
    var guard_party: PartyState = PartyState.new_game(gd.start, gd.characters)
    var guard_sheet: CharacterSheet = guard_party.sheet("torren")
    guard_sheet.fit_sockets(items)
    (guard_sheet.sigils["weapon"] as Array).append({"id":"tutor","ap":0})
    var guard_bag_size: int = guard_party.sigil_inv.size()
    check(guard_party.equip_sigil("torren", "weapon", 99, 0, db, true) != "" and (guard_sheet.sigils["weapon"] as Array).size() == 3 and guard_party.sigil_inv.size() == guard_bag_size, "invalid socket selection leaves runes and inventory unchanged")
    check(guard_party.equip_sigil("torren", "weapon", 0, 0, db, false) != "" and (guard_sheet.sigils["weapon"] as Array).size() == 3 and guard_party.sigil_inv.size() == guard_bag_size, "missing service access leaves rune state unchanged")
    check(guard_party.unequip_sigil("torren", "invalid", 0, db, true) != "" and (guard_sheet.sigils["weapon"] as Array).size() == 3, "invalid removal group leaves socket state unchanged")
    var empty_bag_size: int = guard_party.sigil_inv.size()
    check(guard_party.unequip_sigil("torren", "weapon", 1, db, true) != "" and (guard_sheet.sigils["weapon"] as Array).size() == 3 and guard_party.sigil_inv.size() == empty_bag_size, "empty socket removal leaves overflow runes and inventory unchanged")
    (guard_sheet.sigils["weapon"] as Array).pop_back()
    var amp_i := _sigil_index(ps, "amp")
    check(ps.equip_sigil("torren", "weapon", 1, amp_i, db, true) == "", "equip the rune of Resonance into the linked socket")
    check(int((torren.to_battle_def(db)["skill_mods"] as Dictionary).get("ember_bolt", 0)) == 10, "a linked support adds +10% power to the linked magic skill")
    var tut_i := _sigil_index(ps, "tutor")
    check(ps.equip_sigil("torren", "weapon", 1, tut_i, db, true) == "" and _sigil_index(ps, "amp") >= 0, "swapping a rune returns the old one to the bag")
    check((torren.to_battle_def(db)["skill_mods"] as Dictionary).is_empty(), "with Resonance removed the skill bonus is gone")
    # --- AP growth: weapon multiplier and linked Tutor
    var rep: Array = torren.award_ap(40, items, sdefs)
    var ember_ap: int = int(torren.sigil_at("weapon", 0)["ap"])
    var tutor_ap: int = int(torren.sigil_at("weapon", 1)["ap"])
    check(ember_ap == 50 and tutor_ap == 40 and rep.size() == 2, "Tutor linked to Embers: 40 AP becomes 50 (+25%) for the Embers, 40 for the Tutor itself")
    # --- stat sigils
    var fresh: CharacterSheet = CharacterSheet.from_def("torren", gd.characters["torren"])
    fresh.fit_sockets(items)
    var base_hp: int = int(fresh.total_stats(items, sdefs)["hp"])
    (fresh.sigils["weapon"] as Array)[0] = {"id": "vigor", "ap": 0}
    (fresh.sigils["weapon"] as Array)[1] = {"id": "might", "ap": 0}
    var st: Dictionary = fresh.total_stats(items, sdefs)
    check(int(st["hp"]) == base_hp + int(round(float(base_hp) * 0.05)) and int(st["str"]) == int(fresh.total_stats(items)["str"]) + 1 and int(st["int"]) == int(fresh.total_stats(items)["int"]) - 1, "Vigor adds 5% HP and Might adds +1 STR at the cost of -1 INT at level 1")
    (fresh.sigils["weapon"] as Array)[0] = {"id": "veteran", "ap": 0}
    check(fresh.reward_pct("exp_pct", items, sdefs) == 10, "Veteran's Mark gives +10% EXP at level 1")
    # --- greatsword: more sockets, double AP growth; a smaller weapon returns the extra sigils
    var ps2: PartyState = PartyState.new_game(gd.start, gd.characters)
    var t2: CharacterSheet = ps2.sheet("torren")
    ps2.equip_sigil("torren", "weapon", 0, _sigil_index(ps2, "ember"), db, true)
    ps2.equip_sigil("torren", "weapon", 1, _sigil_index(ps2, "tutor"), db, true)
    check(ps2.unequip("torren", "offhand", db) == "" and ps2.equip("torren", "weapon", "greatsword", db) == "", "swap to the two-handed Hearthbreaker")
    check(t2.socket_count("weapon", items) == 4 and (t2.sigils["weapon"] as Array).size() == 4, "socket array grows to 4")
    check(not t2.sigil_at("weapon", 0).is_empty() and not t2.sigil_at("weapon", 1).is_empty(), "runes stay socketed when the new weapon has the sockets")
    t2.award_ap(10, items, sdefs)
    check(int(t2.sigil_at("weapon", 0)["ap"]) == 25, "weapon AP x2 with linked Tutor +25%: 10 AP becomes 25")
    ps2.add_item("short_bow")
    var bag_before: int = ps2.sigil_inv.size()
    check(ps2.equip("torren", "weapon", "short_bow", db) == "", "swap to the one-socket Reed Bow")
    check(ps2.sigil_inv.size() == bag_before + 1 and (t2.sigils["weapon"] as Array).size() == 1, "the rune that lost its socket returns to the bag")
    # --- mastery spawns a fresh copy, once
    var ps3: PartyState = PartyState.new_game(gd.start, gd.characters)
    var wy: CharacterSheet = ps3.sheet("brother_wystan")
    (wy.sigils["weapon"] as Array)[0]["ap"] = 470
    var mrep: Array = wy.award_ap(20, items, sdefs)
    var m0: Dictionary = mrep[0]
    check(bool(m0["mastered"]) and bool(m0["spawn"]) and int(wy.sigil_at("weapon", 0)["ap"]) == 480, "mastery caps the AP and asks for a new copy")
    check(wy.award_ap(50, items, sdefs).is_empty(), "a mastered rune stops gaining AP")
    (wy.sigils["weapon"] as Array)[0] = {"id": "mend", "ap": 470}
    var bag2: int = ps3.sigil_inv.size()
    var bcm := BattleController.new()
    bcm.setup(gd.battle_def("battle_01"), ps3.battle_db(db), 8)
    for o in bcm.units:
        var um: BattleUnit = o
        if um.team == "enemy":
            um.hp = 0
    var out: Dictionary = ps3.apply_battle_result(bcm.units, "victory", rng_for_tests(), {"classes": gd.classes, "items": items, "runes": sdefs})
    check((out["spawned"] as Array).size() == 1 and ps3.sigil_inv.size() == bag2 + 1, "winning a battle that masters a rune forges a fresh level-1 copy")
    check(bool(wy.sigil_at("weapon", 0).get("spawned", false)), "the mastered rune is flagged so it spawns only once")
    # --- offensive magic in battle
    var ps4: PartyState = PartyState.new_game(gd.start, gd.characters)
    ps4.equip_sigil("torren", "weapon", 0, _sigil_index(ps4, "ember"), db, true)
    var bcd := BattleController.new()
    bcd.setup(gd.battle_def("battle_01"), ps4.battle_db(db), 12)
    bcd.begin()
    var caster: BattleUnit = null
    var victim: BattleUnit = null
    for o in bcd.units:
        var ud: BattleUnit = o
        if ud.character_id == "torren":
            caster = ud
        elif ud.character_id == "roadreaver" and victim == null:
            victim = ud
    check(caster != null and victim != null, "caster and victim exist")
    if caster == null or victim == null:
        return
    victim.cell = caster.cell + Vector2i(0, -3)
    bcd.active_id = caster.id
    caster.has_acted = false
    caster.has_moved = false
    check(bcd.skill_targets(caster, "ember_bolt").has(victim), "Ember Bolt can target an enemy 3 tiles away")
    var prev: Dictionary = CombatCalc.skill_preview(caster, victim, gd.skills["ember_bolt"], "ember_bolt")
    var hp_v: int = victim.hp
    var mp_c: int = caster.mp
    check(bcd.try_skill(caster, "ember_bolt", victim), "casting Ember Bolt succeeds")
    var dealt: int = hp_v - victim.hp
    check(dealt >= int(prev["dmg_min"]) and dealt <= int(prev["dmg_max"]) and caster.mp == mp_c - 4 and caster.has_acted, "damage is inside the preview range, MP is spent and the turn is used")
    var ally: BattleUnit = null
    for o in bcd.units:
        var ua: BattleUnit = o
        if ua.team == "player" and ua != caster:
            ally = ua
    check(not bcd.skill_targets(caster, "ember_bolt").has(ally), "an offensive skill never targets allies")
    # --- the AI uses offensive magic
    caster.has_acted = false
    victim.hp = victim.max_hp()
    caster.mp = 8
    var ai_plan: Dictionary = BattleAI.decide(caster, bcd)
    check(str(ai_plan["action"]) == "skill" or str(ai_plan["action"]) == "attack", "AI plans an action with a damage skill available")
    # --- skirmish encounters
    var seen: Dictionary = {}
    var rr := RandomNumberGenerator.new()
    var sk_ok := true
    for seed_v in range(1, 25):
        rr.seed = seed_v
        var sdef: Dictionary = EncounterBuilder.build_skirmish(gd.encounters, gd.battles, rr)
        var enemies := 0
        var players := 0
        for u in (sdef.get("units", []) as Array):
            var ud2: Dictionary = u
            if str(ud2["team"]) == "enemy":
                enemies += 1
                if not gd.characters.has(str(ud2["character_id"])):
                    sk_ok = false
            else:
                players += 1
        if str(sdef.get("id", "")) != "skirmish" or players != 4 or enemies < 3:
            sk_ok = false
        seen[enemies] = true
    check(sk_ok, "every generated skirmish has the 4 heroes, 3+ known enemies and the id 'skirmish'")
    check(seen.size() >= 2, "different seeds produce different enemy groups")
    var sdef2: Dictionary = EncounterBuilder.build_skirmish(gd.encounters, gd.battles, rr)
    var bcs := BattleController.new()
    bcs.setup(sdef2, gd.as_db(), 99)
    bcs.begin()
    var g2 := 0
    while bcs.result == "" and g2 < 800:
        bcs.run_ai_turn(true)
        g2 += 1
    check(bcs.result != "", "an AI-vs-AI skirmish finishes")


func _on_card_tapped() -> void:
    card_taps += 1


func _on_screen_closed() -> void:
    screen_closed += 1


func _test_shop_and_screen() -> void:
    print("[shop, text helpers, gear preview, party screen]")
    var db: Dictionary = gd.party_db()
    var shop: Dictionary = gd.shop
    var items: Dictionary = db["items"]
    var sdefs: Dictionary = db["runes"]
    # --- data
    var shop_ok: bool = not shop.is_empty() and ShopSystem.sell_ratio(shop) > 0.0 and ShopSystem.sell_ratio(shop) <= 1.0
    for id in (shop.get("items", []) as Array):
        if not items.has(str(id)) or int((items[str(id)] as Dictionary).get("price", 0)) <= 0:
            shop_ok = false
    for id in (shop.get("runes", []) as Array):
        if not sdefs.has(str(id)) or int((sdefs[str(id)] as Dictionary).get("price", 0)) <= 0:
            shop_ok = false
    check(shop_ok, "shop stock only lists real items and runes that have a price")
    check(ShopSystem.stock(shop, db).size() == (shop["items"] as Array).size() + (shop["runes"] as Array).size(), "the stock list has one entry per shop line")
    var price_order_ok := true
    var rarity_price_floor := {"common": 0, "uncommon": 150, "rare": 800, "epic": 3000, "legendary": 12000, "mythical": 35000}
    for item_id in items.keys():
        var item_def: Dictionary = items[item_id]
        var rarity: String = str(item_def.get("rarity", "common"))
        if rarity_price_floor.has(rarity) and int(item_def.get("price", 0)) < int(rarity_price_floor[rarity]):
            price_order_ok = false
    check(price_order_ok, "rare through mythical equipment uses premium price bands")
    var regional_stock: Dictionary = shop.get("regional_stocks", {})
    check(regional_stock.has("crossing_shop") and regional_stock.has("milefort_market") and not (regional_stock["crossing_shop"]["items"] as Array).has("mythical_arming_sword"), "regional merchants have distinct gated stock")
    check(not ShopSystem.market_available(shop, "saltmere", {}) and ShopSystem.market_available(shop, "saltmere", {"saltmere_trade_route_open": true}) and ShopSystem.market_available(shop, "saltmere", {"saltmere_fishers_route_open": true}), "Saltmere's market unlocks only when one of Neris's routes is established")
    var merchant_stock: Dictionary = ShopSystem.regional_stock(shop, "saltmere", {"saltmere_trade_route_open": true})
    var fisher_stock: Dictionary = ShopSystem.regional_stock(shop, "saltmere", {"saltmere_fishers_route_open": true})
    check((merchant_stock.get("items", []) as Array).has("deepwater_spice") and not (merchant_stock.get("items", []) as Array).has("reef_salt"), "the public route unlocks merchant-only trade goods")
    check((fisher_stock.get("items", []) as Array).has("reef_salt") and not (fisher_stock.get("items", []) as Array).has("deepwater_spice"), "the private route unlocks fisher-only trade goods")
    check(ItemInfo.slot_name("trade_good") == "Trade good" and ItemInfo.item_line("deepwater_spice", items, db["weapons"]).contains("Trade good"), "trade goods are identified clearly in the shop and inventory")
    check(gd.skills.has("frost_shard") and gd.skills.has("frost_lance") and str(gd.skills["frost_shard"]["type"]) == "damage", "Frost skills exist as damage spells")
    check(CharacterSheet.sigil_skills_at(sdefs["frost"], 1).has("frost_shard") and CharacterSheet.sigil_skills_at(sdefs["frost"], 3).has("frost_lance"), "the rune of Frost teaches Frost Shard at level 1 and Frost Lance at level 3")
    # --- text helpers
    check(ItemInfo.signed(3) == "+3" and ItemInfo.signed(-2) == "-2" and ItemInfo.signed(0) == "+0", "signed() formats numbers")
    check(ItemInfo.bonus_text({"ldr": 2, "mor": 5}) == "+2 LDR, +5 MOR", "bonus text is sorted and labelled")
    check(ItemInfo.mods_text({"hp_pct": 5, "mp_pct": -10}) == "+5% HP, -10% MP", "percentage mods read as +5% HP, -10% MP")
    var text_ok := true
    for k in items.keys():
        if ItemInfo.item_line(str(k), items, db["weapons"]).length() < 4:
            text_ok = false
    for k in sdefs.keys():
        var sd: Dictionary = sdefs[k]
        for lv in range(1, CharacterSheet.sigil_max_level(sd) + 1):
            if ItemInfo.sigil_effect(sd, lv, db["skills"]) == "" or ItemInfo.sigil_short({"id": str(k), "ap": 0}, sd) == "":
                text_ok = false
    check(text_ok, "every item and every rune level has a description")
    check(ItemInfo.skill_line("mend", db["skills"]).begins_with("Mend") and ItemInfo.skill_line("ember_bolt", db["skills"]).contains("magic damage"), "skill lines describe heals and damage spells")
    var mend_def: Dictionary = sdefs["mend"]
    check(ItemInfo.sigil_ap_text({"id": "mend", "ap": 35}, mend_def) == "35/60 AP" and ItemInfo.sigil_ap_text({"id": "mend", "ap": 480}, mend_def) == "MAX", "AP text shows progress to the next level and MAX when mastered")
    check(ItemInfo.sigil_progress({"id": "mend", "ap": 50}, mend_def).contains("10 AP to next"), "rune progress names the AP still needed")
    # --- shop rules
    var ps: PartyState = PartyState.new_game(gd.start, gd.characters)
    var arming_price: int = ShopSystem.item_price("arming_sword", db)
    check(arming_price > 0, "the Wayfarer Blade has a price")
    ps.gold = arming_price - 1
    check(ShopSystem.buy_item(ps, "arming_sword", db, shop) == "Not enough gold." and ps.gold == arming_price - 1, "a purchase without enough gold is refused and costs nothing")
    ps.gold = arming_price + 10
    var count0: int = ps.item_count("arming_sword")
    check(ShopSystem.buy_item(ps, "arming_sword", db, shop) == "" and ps.gold == 10 and ps.item_count("arming_sword") == count0 + 1, "buying pays the price and adds the item")
    check(ShopSystem.buy_item(ps, "dunmarrow_signet", db, shop) == "Not for sale.", "an item the stall does not stock cannot be bought")
    var saltmere_market: Dictionary = ShopSystem.regional_stock(shop, "saltmere", {"saltmere_trade_route_open": true})
    saltmere_market["sell_ratio"] = 0.45
    var spice_price: int = ShopSystem.item_price("deepwater_spice", db)
    ps.gold = spice_price
    check(ShopSystem.buy_item(ps, "deepwater_spice", db, saltmere_market) == "" and ps.item_count("deepwater_spice") == 1 and ps.gold == 0, "the open merchant passage allows the company to buy regional trade goods")
    check(ShopSystem.sell_item(ps, "deepwater_spice", db, saltmere_market) == "" and ps.gold == ShopSystem.sell_price(spice_price, saltmere_market), "regional trade goods can be resold at the local market's sell ratio")
    var gold1: int = ps.gold
    check(ShopSystem.sell_item(ps, "arming_sword", db, shop) == "" and ps.item_count("arming_sword") == count0, "selling takes the item out of the bag")
    check(ps.gold == gold1 + ShopSystem.sell_price(arming_price, shop), "selling pays the sell ratio of the price")
    ps.gold = 500000
    for n in range(15):
        check(ps.enhance_equipment("torren", "weapon", db, true) == "", "blacksmith enhances equipment through +%d" % (n + 1))
    check(int(ps.sheet("torren").enhancements.get("weapon|" + ps.sheet("torren").item_in("weapon"), 0)) == 15 and ps.enhance_equipment("torren", "weapon", db) != "", "equipment enhancement caps at +15")
    check(ShopSystem.sell_item(ps, "arming_sword", db, shop) != "", "gear that is only equipped (not in the bag) cannot be sold")
    check(ShopSystem.sell_item(ps, "dunmarrow_signet", db, shop) == "That cannot be sold.", "heirlooms cannot be sold")
    # Use a sigil that is actually stocked by the starter merchant.
    ps.gold = ShopSystem.sigil_price("mend", db)
    var bag0: int = ps.sigil_inv.size()
    check(ShopSystem.buy_sigil(ps, "mend", db, shop) == "" and ps.gold == 0 and ps.sigil_inv.size() == bag0 + 1, "buying a rune puts a fresh copy into the bag")
    check(CharacterSheet.sigil_level(ps.sigil_inv[bag0], sdefs["mend"]) == 1, "a bought rune is level 1")
    check(ShopSystem.sell_sigil(ps, bag0, db, shop) == "" and ps.sigil_inv.size() == bag0 and ps.gold == ShopSystem.sell_price(ShopSystem.sigil_price("mend", db), shop), "selling a rune removes it and pays the sell ratio")
    check(ShopSystem.sell_sigil(ps, 99, db, shop) != "" and ShopSystem.sell_sigil(ps, -1, db, shop) != "", "selling a rune that is not in the bag is refused")
    # --- gear preview
    var torren: CharacterSheet = ps.sheet("torren")
    var worn: String = torren.item_in("weapon")
    torren.enhancements.clear() # Isolate item comparison from the +15 smithing test above.
    var before: Dictionary = torren.derived(db)
    var preview: CharacterSheet = torren.with_item("weapon", "fine_arming_sword", items)
    var after: Dictionary = preview.derived(db)
    check(torren.item_in("weapon") == worn and preview.item_in("weapon") == "fine_arming_sword", "with_item() changes only the copy")
    check(roundi(float(after["attack"])) > roundi(float(before["attack"])), "the Moonforged Wayfarer hits harder than the Wayfarer Blade")
    check(ItemInfo.delta_text(before, after).contains("ATK +") and ItemInfo.delta_text(before, before) == "no change", "delta text lists changes and says 'no change' otherwise")
    # --- party screen (headless smoke test: it must build, react to every action and keep the rules intact)
    var screen := PartyScreen.new()
    root.add_child(screen)
    screen.closed.connect(_on_screen_closed)
    var test_bonds: Dictionary = {}
    RelationshipSystemScript.adjust(test_bonds, "torren", "wystan", "trust", 25, "quest:screen-test")
    screen.setup(ps, db, shop, true, true, true, test_bonds)
    screen.open()
    check(screen.visible and screen.builds == 1 and screen.get_child_count() == 2, "the party screen builds its layout on open()")
    check(screen.relationship_state == test_bonds, "party screen receives campaign bond state explicitly")
    check(screen._relationship_event_label("quest:shared-watch") == "Shared quest" and screen._relationship_event_label("recruit:maren_vey:trust") == "Joined the company", "bond journal translates authored evidence into readable event labels")
    var b0: int = screen.builds
    var n_calls := 0
    for id in ps.roster:
        screen._on_select(id)
        n_calls += 1
        for t in range(PartyScreen.TAB_NAMES.size()):
            screen._on_tab(t)
            n_calls += 1
    check(screen.builds - b0 == n_calls and screen.get_child_count() == 2, "every roster member x every tab builds completely (%d builds)" % n_calls)
    ps.add_item("fine_arming_sword")
    screen._on_select("torren")
    screen._on_tab(PartyScreen.TAB_SIGILS)
    screen._on_socket("weapon", 0)
    check(screen.focus_group == "weapon" and screen.focus_index == 0, "tapping a socket opens its choices")
    var ember_i: int = _sigil_index(ps, "ember")
    var bag_before: int = ps.sigil_inv.size()
    screen._on_socket_sigil("weapon", 0, ember_i)
    check(str(ps.sheet("torren").sigil_at("weapon", 0).get("id", "")) == "ember" and ps.sigil_inv.size() == bag_before - 1 and screen.changed, "choosing a rune sockets it and takes it out of the bag")
    check(screen.message.begins_with("Socketed"), "the screen confirms the socketing")
    screen._on_unsocket("weapon", 0)
    check(ps.sheet("torren").sigil_at("weapon", 0).is_empty() and ps.sigil_inv.size() == bag_before, "Remove sends the rune back to the bag")
    screen._on_tab(PartyScreen.TAB_GEAR)
    screen._on_slot("weapon")
    check(screen.focus_slot == "weapon", "tapping a gear slot opens its choices")
    screen._on_equip("weapon", "fine_arming_sword")
    check(ps.sheet("torren").item_in("weapon") == "fine_arming_sword" and screen.message.begins_with("Equipped"), "choosing an item equips it")
    screen._on_equip("weapon", "greatsword")
    check(ps.sheet("torren").item_in("weapon") == "fine_arming_sword" or ps.sheet("torren").item_in("weapon") == "greatsword", "a refused or accepted swap never leaves the slot empty")
    screen._on_unequip("weapon")
    check(ps.sheet("torren").item_in("weapon") == "", "Unequip empties the slot")
    screen._on_tab(PartyScreen.TAB_SHOP)
    ps.gold = 1000
    var gold_before: int = ps.gold
    screen._on_buy("item", "mace")
    check(screen.message.begins_with("Bought") and ps.gold < gold_before, "buying in the shop tab spends gold")
    screen._on_shop_mode(true)
    screen._on_sell_item("mace")
    check(screen.message.begins_with("Sold") and screen.shop_selling, "selling in the shop tab pays gold")
    screen._on_sell_item("dunmarrow_signet")
    check(screen.message == "That cannot be sold.", "the shop tab explains why an heirloom cannot be sold")
    # --- compare before buying, confirm before buying or selling (v0.7.1)
    screen._on_shop_mode(false)
    ps.gold = 1000
    var picks: Array[String] = ["buy:item:mace", "buy:item:hawk_feather", "buy:item:kite_shield", "buy:rune:ember"]
    var builds_before: int = screen.builds
    for pk in picks:
        screen._on_shop_pick(pk)
    check(screen.builds - builds_before == picks.size() and screen.get_child_count() == 2 and ps.gold == 1000, "opening shop cards (gear compare, accessory, rune) builds completely and buys nothing")
    screen._on_shop_pick("buy:rune:ember")
    check(screen.shop_pick == "", "tapping an open shop card again closes it")
    screen._on_shop_pick("buy:item:mace")
    screen._on_confirm_buy("item", "mace")
    check(screen.shop_pick == "" and ps.gold < 1000 and screen.message.begins_with("Bought"), "Confirm buys the opened item and closes the card")
    screen._on_shop_mode(true)
    screen._on_shop_pick("sell:item:mace")
    var gold_mid: int = ps.gold
    check(screen.shop_pick == "sell:item:mace" and ps.gold == gold_mid and ps.item_count("mace") > 0, "opening a sell card sells nothing")
    screen._on_confirm_sell_item("mace")
    check(screen.shop_pick == "" and ps.gold > gold_mid and screen.message.begins_with("Sold"), "Confirm sells the opened item")
    check(not ItemInfo.delta_parts(before, after).is_empty() and ItemInfo.delta_parts(before, before).is_empty(), "delta_parts lists changed stats and is empty when nothing changes")
    # --- TapCard: a tap fires, a drag does not (so lists of cards can be scrolled by touch)
    var tcard := TapCard.new()
    tcard.tapped.connect(_on_card_tapped)
    var press := InputEventMouseButton.new()
    press.button_index = MOUSE_BUTTON_LEFT
    press.pressed = true
    var release := InputEventMouseButton.new()
    release.button_index = MOUSE_BUTTON_LEFT
    release.pressed = false
    var drag := InputEventMouseMotion.new()
    drag.relative = Vector2(0.0, -40.0)
    tcard._gui_input(press)
    tcard._gui_input(release)
    check(card_taps == 1, "a short press and release taps a TapCard")
    tcard._gui_input(press)
    tcard._gui_input(drag)
    tcard._gui_input(release)
    check(card_taps == 1, "pressing and dragging a TapCard scrolls instead of tapping")
    tcard.set_disabled(true)
    tcard._gui_input(press)
    tcard._gui_input(release)
    check(card_taps == 1, "a disabled TapCard never taps")
    tcard.free()
    screen.close()
    check(not screen.visible and screen_closed == 1, "Close hides the screen and emits closed")
    screen.queue_free()


func rng_for_tests() -> RandomNumberGenerator:
    var r := RandomNumberGenerator.new()
    r.seed = 4242
    return r


func _sigil_index(party: PartyState, sigil_id: String) -> int:
    for i in range(party.sigil_inv.size()):
        if str((party.sigil_inv[i] as Dictionary).get("id", "")) == sigil_id:
            return i
    return -1



func _test_campaign_restore_validation() -> void:
    print("[campaign restore validation]")
    var member := {
        "character_id": "torren",
        "base_stats": {"hp": 100, "str": 10},
        "skills": [],
        "equipment": {},
        "sigils": {},
    }
    var payload := {
        "campaign": true,
        "party": {
            "roster": ["torren"],
            "sheets": {"torren": member},
            "inventory": {},
            "sigil_inv": [],
        },
        "creation_profile": {},
        "world_flags": {},
        "world_pos": [0.0, 0.0],
        "world_positions": {},
    }
    check(RegionSaveState.is_valid_campaign_payload(payload), "a structurally valid new campaign can be restored")
    var missing_party: Dictionary = payload.duplicate(true)
    missing_party.erase("party")
    check(not RegionSaveState.is_valid_campaign_payload(missing_party), "campaign restore rejects a missing party")
    var missing_sheet: Dictionary = payload.duplicate(true)
    missing_sheet["party"]["sheets"] = {}
    check(not RegionSaveState.is_valid_campaign_payload(missing_sheet), "campaign restore rejects roster entries without character sheets")
    var malformed_position: Dictionary = payload.duplicate(true)
    malformed_position["world_pos"] = ["north", null]
    check(not RegionSaveState.is_valid_campaign_payload(malformed_position), "campaign restore rejects malformed world coordinates")
    var malformed_inventory: Dictionary = payload.duplicate(true)
    malformed_inventory["party"]["inventory"] = []
    check(not RegionSaveState.is_valid_campaign_payload(malformed_inventory), "campaign restore rejects invalid inventory structures")

func _test_save_system() -> void:
    print("[save system]")
    var payload := {"hello": "world", "n": 5, "arr": [1, 2, 3], "creation_profile": {"origin": "border_ward"}}
    ss.delete_slot("test")
    check(ss.save_slot("test", payload, "unit test"), "save succeeds")
    var res: Dictionary = ss.load_slot("test")
    check(bool(res["ok"]) and int(res["payload"]["n"]) == 5 and str(res["payload"]["hello"]) == "world", "load returns the saved payload")
    check(str(res["payload"]["creation_profile"]["origin"]) == "border_ward", "creation profile survives save/load")
    var legacy: Dictionary = ss.migrate({"battle": {"turn": 3}, "party": {"gold": 12}}, 1)
    check(legacy.has("creation_profile") and (legacy["creation_profile"] as Dictionary).is_empty(), "v1 saves migrate by adding an empty creation profile")
    check(int((legacy["battle"] as Dictionary)["turn"]) == 3 and int((legacy["party"] as Dictionary)["gold"]) == 12, "v1 migration preserves existing battle and party data")
    var legacy_payload_text: String = JSON.stringify({"battle": {"turn": 7}, "party": {"gold": 25}})
    var legacy_envelope: Dictionary = {"meta": {"save_version": 1}, "payload": legacy_payload_text, "checksum": ss.checksum_of(legacy_payload_text)}
    var legacy_file := FileAccess.open(ss.slot_path("legacy"), FileAccess.WRITE)
    legacy_file.store_string(JSON.stringify(legacy_envelope))
    legacy_file.close()
    var legacy_loaded: Dictionary = ss.load_slot("legacy")
    check(bool(legacy_loaded.get("ok", false)) and legacy_loaded["payload"].has("creation_profile"), "loading a real v1 save applies the v2 migration")
    check(int(legacy_loaded["payload"]["battle"]["turn"]) == 7 and int(legacy_loaded["payload"]["party"]["gold"]) == 25, "loaded v1 save retains its existing game state")
    var v2_regional: Dictionary = ss.migrate({"battle": {"turn": 9}, "party": {"gold": 41}}, 2)
    check(v2_regional.has("world_flags") and (v2_regional["world_flags"] as Dictionary).is_empty() and v2_regional.has("world_pos") and v2_regional.has("from_world"), "v2 saves migrate through v4 with safe regional-context defaults")
    check(int(v2_regional["battle"]["turn"]) == 9 and int(v2_regional["party"]["gold"]) == 41, "v2-to-v4 migration preserves existing battle and party data")
    var v3_member: Dictionary = {"roster":["old"],"sheets":{"old":{"character_id":"old","name":"Old","class_id":"knight","level":1,"base_stats":{},"skills":[],"equipment":{}}}}
    var v3_to_v4: Dictionary = ss.migrate({"party":v3_member,"world_flags":{"camp_cleared":true}},3)
    check(int(v3_to_v4["party"]["sheets"]["old"].get("loyalty",-1)) == 50 and bool(v3_to_v4["world_flags"]["camp_cleared"]), "v3-to-v4 migration adds neutral loyalty and preserves world flags")
    ss.delete_slot("legacy")
    check(bool(ss.save_slot("test", {"hello": "again"}, "second")), "second save succeeds")
    check(FileAccess.file_exists(ss.slot_path("test") + ".bak"), "previous save kept as .bak")
    var f := FileAccess.open(ss.slot_path("test"), FileAccess.WRITE)
    f.store_string("{garbage")
    f.close()
    res = ss.load_slot("test")
    check(bool(res["ok"]) and bool(res["from_backup"]) and str(res["payload"]["hello"]) == "world", "corrupt save falls back to the backup")
    ss.delete_slot("test")
    check(not bool(ss.slot_info("test")["exists"]), "delete removes the slot")
    var env := {"meta": {"save_version": 1}, "payload": "{\"a\":1}", "checksum": "deadbeef"}
    ss.save_slot("tamper", {"a": 1}, "x")
    var tf := FileAccess.open(ss.slot_path("tamper"), FileAccess.WRITE)
    tf.store_string(JSON.stringify(env))
    tf.close()
    check(not bool(ss.load_slot("tamper")["ok"]), "wrong checksum is rejected")
    ss.delete_slot("tamper")
    var newer := {"meta": {"save_version": 99}, "payload": "{}", "checksum": ss.checksum_of("{}")}
    var nf := FileAccess.open(ss.slot_path("future"), FileAccess.WRITE)
    nf.store_string(JSON.stringify(newer))
    nf.close()
    check(not bool(ss.load_slot("future")["ok"]), "saves from a newer version are refused")
    ss.delete_slot("future")
    # --- save slot identifiers and envelope field types are treated as untrusted input
    check(not ss.save_slot("../outside", {"unsafe": true}, "invalid"), "save rejects traversal-style slot identifiers")
    check(not bool(ss.load_slot("../outside").get("ok", false)), "load rejects traversal-style slot identifiers")
    check(not bool(ss.slot_info("../outside").get("exists", true)), "slot metadata rejects traversal-style identifiers")
    check(ss.slot_path("../outside") == "", "invalid identifiers never produce a filesystem path")
    ss.delete_slot("../outside")
    var malformed_envelope := {"meta": "not-a-dictionary", "payload": "{}", "checksum": ss.checksum_of("{}")}
    var malformed_file := FileAccess.open(ss.slot_path("bad_meta"), FileAccess.WRITE)
    malformed_file.store_string(JSON.stringify(malformed_envelope))
    malformed_file.close()
    check(not bool(ss.load_slot("bad_meta").get("ok", false)), "save loader rejects a checksum-valid envelope with malformed metadata")
    ss.delete_slot("bad_meta")
    var malformed_migration: Dictionary = ss.migrate({"party": {"sheets": ["not", "a", "dictionary"]}}, 3)
    check(typeof(malformed_migration.get("party")) == TYPE_DICTIONARY, "legacy migration safely normalizes malformed nested party data")
    ss.delete_slot("auto_a")
    ss.delete_slot("auto_b")
    ss.autosave({"i": 1}, "first")
    ss.autosave({"i": 2}, "second")
    check(bool(ss.slot_info("auto_a")["exists"]) and bool(ss.slot_info("auto_b")["exists"]), "autosave rotates between two slots")
    ss.delete_slot("auto_a")
    ss.delete_slot("auto_b")


## AI controls BOTH sides here, so this is a smoke test (does every battle terminate?) and a rough balance probe.
func _simulate_battles(n: int) -> void:
    print("[simulation]")
    var wins := 0
    var total_turns := 0
    var unfinished := 0
    for i in range(n):
        var c := BattleController.new()
        c.setup(gd.battle_def("battle_01"), gd.as_db(), 1000 + i)
        c.begin()
        var guard := 0
        while c.result == "" and guard < 800:
            c.run_ai_turn(true)
            guard += 1
        if c.result == "":
            unfinished += 1
        elif c.result == "victory":
            wins += 1
        total_turns += c.turn_count
    check(unfinished == 0, "all %d simulated battles reach a result" % n)
    print("  info  AI vs AI: player side won %d/%d, average %.1f turns per battle" % [wins, n, float(total_turns) / float(n)])


func _test_trait_system() -> void:
    print("[trait and personality system]")
    var defs: Dictionary = gd.traits
    check(defs.size() >= 60, "data-driven trait catalogue loads a broad initial library")
    var categories: Dictionary = {}
    var valid_trait_links := true
    for trait_id in defs:
        if str(trait_id) == "_synergies":
            continue
        var trait_def: Dictionary = defs[trait_id]
        categories[str(trait_def.get("category", ""))] = true
        for conflict_id in trait_def.get("conflicts", []):
            if not defs.has(str(conflict_id)):
                valid_trait_links = false
        var evolution_id := str(trait_def.get("evolves_to", ""))
        if evolution_id != "" and not defs.has(evolution_id):
            valid_trait_links = false
    for category_id in ["personality", "intelligence", "combat", "social", "physical", "psychological", "leadership", "lifestyle", "morality", "magical"]:
        check(categories.has(category_id), "trait catalogue includes " + category_id + " category")
    check(valid_trait_links, "all opposing and evolution links resolve to defined traits")
    var valid_event_awards := true
    for event_id in gd.trait_events:
        var event_def: Dictionary = gd.trait_events[event_id]
        for award_id in event_def.get("trait_awards", []):
            if not defs.has(str(award_id)):
                valid_event_awards = false
    check(valid_event_awards, "all event trait awards resolve to defined trait IDs")
    check(defs.has("brave") and defs.has("scholar") and defs.has("battle_trauma") and defs.has("magical_affinity"), "catalogue covers personality, knowledge, psychological and rare magical traits")
    var sheet := CharacterSheet.from_def("trait_test", {"name":"Test Hero","class_id":"swordsman","level":1,"stats":{"hp":20,"mp":5,"str":5,"dex":5,"int":5,"vit":5,"spd":5,"lck":5,"acc":70,"eva":5,"ldr":5,"mor":50}})
    var base: Dictionary = sheet.base_stats.duplicate(true)
    var gained: Dictionary = sheet.acquire_trait("brave", "unit_test", defs)
    check(bool(gained.get("ok", false)) and sheet.traits.has("brave"), "valid trait acquisition records an enduring trait")
    check(int(sheet.base_stats.get("mor", 0)) == int(base.get("mor", 0)), "trait effects never mutate permanent base stats")
    var trait_stats: Dictionary = sheet.total_stats({}, {}, defs)
    check(int(trait_stats.get("mor", 0)) == int(base.get("mor", 0)) + 2, "trait stat effects are applied through derived stats")
    var synergy_sheet := CharacterSheet.from_def("synergy_test", {"name":"Synergy Hero","class_id":"knight","level":1,"traits":["brave","battle_hardened"],"stats":{"hp":20,"mp":5,"str":5,"dex":5,"int":5,"vit":5,"spd":5,"lck":5,"acc":70,"eva":5,"ldr":5,"mor":50}})
    var synergy_stats: Dictionary = synergy_sheet.total_stats({}, {}, defs)
    check(int(synergy_stats.get("mor", 0)) == 54 and TraitSystemScript.active_synergies(synergy_sheet.traits, defs).size() == 1, "compatible traits unlock a derived synergy without adding a duplicate trait")
    var conflict: Dictionary = sheet.acquire_trait("cowardly", "unit_test", defs)
    check(not bool(conflict.get("ok", false)) and sheet.traits.has("brave"), "opposing traits cannot be acquired together")
    var duplicate: Dictionary = sheet.acquire_trait("brave", "unit_test", defs)
    check(not bool(duplicate.get("ok", false)), "duplicate trait acquisition is rejected")
    var premature_evolve: Dictionary = sheet.evolve_trait("brave", defs, "unit_test")
    check(not bool(premature_evolve.get("ok", false)) and sheet.traits.has("brave"), "trait evolution is blocked until its behavior evidence threshold is met")
    sheet.record_behavior("brave_actions", 3, "evolution:courage-1")
    var evolve: Dictionary = sheet.evolve_trait("brave", defs, "unit_test")
    check(bool(evolve.get("ok", false)) and sheet.traits.has("fearless") and not sheet.traits.has("brave"), "eligible traits evolve without stacking their predecessor")
    var permanent: Dictionary = sheet.acquire_trait("magical_affinity", "unit_test", defs)
    var blocked: Dictionary = sheet.remove_trait("magical_affinity", "unit_test", defs)
    check(bool(permanent.get("ok", false)) and not bool(blocked.get("ok", false)), "permanent traits require an explicit story-resolution override to remove")
    sheet.record_behavior("ally_protection", 1, "event:protect-1")
    var evidence_before: int = int(sheet.behavior.get("ally_protection", 0))
    sheet.record_behavior("ally_protection", 1, "event:protect-1")
    check(int(sheet.behavior.get("ally_protection", 0)) == evidence_before, "the same evidence identifier cannot be farmed twice")
    var event_result: Dictionary = sheet.apply_personality_event("protected_companion", gd.trait_events, defs, "unit_test", "event:protect-companion-unique")
    check(bool(event_result.get("ok", false)) and sheet.traits.has("protective"), "qualifying event evidence awards a contextual protective trait")
    check(sheet.memories.size() == 1 and sheet.stress == 0, "personality event records a memory and applies stress recovery")
    var restored := CharacterSheet.from_dict(sheet.to_dict())
    check(restored.traits == sheet.traits and restored.trait_history.size() == sheet.trait_history.size(), "trait IDs and history survive character serialization")
    check(restored.memories.size() == sheet.memories.size() and restored.behavior == sheet.behavior and restored.stress == sheet.stress, "stress, memories and behavior evidence survive character serialization")
    check(sheet.adjust_stress(150) == 100 and sheet.adjust_stress(-200) == 0, "stress remains bounded between calm and crisis")
    check(sheet.begin_ambition("prove_courage", "Prove My Courage", "Face the danger threatening the frontier.", 3), "character can receive a structured ambition")
    var progress := sheet.advance_ambition(2)
    check(bool(progress.ok) and not bool(progress.completed) and int(progress.progress) == 2, "ambition progress advances without premature completion")
    var completion := sheet.advance_ambition(2)
    check(bool(completion.completed) and str(sheet.ambition.get("status", "")) == "completed", "ambition completes exactly at its target")
    var legacy := CharacterSheet.from_dict({"character_id":"legacy","name":"Legacy","class_id":"swordsman","level":1,"base_stats":{"hp":10,"str":4},"skills":[],"equipment":{}})
    check(legacy.traits.is_empty() and legacy.trait_history.is_empty(), "legacy character saves load safely without trait fields")


func _test_companion_relationships() -> void:
    print("[companion relationship system]")
    var state: Dictionary = {}
    check(RelationshipSystemScript.adjust(state, "torren", "wystan", "friendship", 25, "quest:shared-watch"), "authored event creates a companion relationship")
    check(int(RelationshipSystemScript.get_relationship(state, "wystan", "torren").get("friendship", 0)) == 25, "pair relationships are symmetric regardless of lookup order")
    check(not RelationshipSystemScript.adjust(state, "torren", "wystan", "friendship", 25, "quest:shared-watch"), "duplicate evidence cannot farm relationship gains")
    check(RelationshipSystemScript.adjust(state, "torren", "wystan", "trust", 70, "quest:kept-secret"), "trust develops independently from friendship")
    check(str(RelationshipSystemScript.get_relationship(state, "torren", "wystan").get("stage", "")) == "Trusted Allies", "relationship stage reflects distinct trust and friendship dimensions")
    check(RelationshipSystemScript.adjust(state, "torren", "wystan", "rivalry", 150, "duel:final"), "rivalry can be authored as a separate relationship dimension")
    check(int(RelationshipSystemScript.get_relationship(state, "torren", "wystan").get("rivalry", 0)) == 100, "relationship dimensions are bounded at 100")
    check(not RelationshipSystemScript.adjust(state, "torren", "wystan", "loyalty", 10, "invalid:dimension"), "unknown relationship dimensions are rejected")
    check(not RelationshipSystemScript.adjust(state, "torren", "torren", "friendship", 10, "invalid:self"), "self-relationships are rejected")
    var restored: Dictionary = RelationshipSystemScript.normalize_state(state)
    check(RelationshipSystemScript.normalize_state(restored) == restored, "relationship state remains stable after save normalization")
    check(RelationshipSystemScript.normalize_state({}).is_empty(), "legacy campaigns default safely without relationship data")
