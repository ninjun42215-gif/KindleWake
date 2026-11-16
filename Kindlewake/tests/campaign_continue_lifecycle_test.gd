extends Node
## Runtime lifecycle regression: run as a scene (not --script) so project autoloads are active.
## Command: godot --headless --path . res://tests/campaign_continue_lifecycle_test.tscn

const TEST_SLOT := "campaign_lifecycle_tmp_20261110"
const BattleSceneScript = preload("res://scripts/ui/battle_scene.gd")

var failures: int = 0
var autosave_snapshot: Dictionary = {}
var owns_test_slot: bool = false


func _ready() -> void:
    call_deferred("_run_lifecycle")


func _run_lifecycle() -> void:
    await get_tree().process_frame
    if not SaveSystem.set_test_save_directory("user://campaign_lifecycle_test"):
        _fail("lifecycle test redirects all save writes into an isolated directory")
        _finish(false)
        return
    _snapshot_autosave_files()

    if bool(SaveSystem.slot_info(TEST_SLOT).get("exists", false)):
        _fail("reserved lifecycle-test save slot is already occupied; refusing to overwrite it")
        _finish(false)
        return

    owns_test_slot = true
    GameState.new_game()
    GameState.trade_state = {"markets":{"sethmarch":{"stock":{"trade_grain":17},"demand":{"trade_grain":3}}},"transactions":4,"total_sales":99}

    if not GameState.save_campaign(TEST_SLOT):
        _fail("new campaign can be saved through GameState")
        _finish(true)
        return

    GameState.new_game()
    if not GameState.load_campaign(TEST_SLOT):
        _fail("saved campaign restores through GameState after a fresh state")
        _finish(true)
        return

    if GameState.party.sheet("torren") == null:
        _fail("restored party contains the protagonist")
    if GameState.active_region_id.is_empty() or not GameState.from_world:
        _fail("restored campaign contains valid overworld hand-off state")
    if GameState.campaign_slot != TEST_SLOT:
        _fail("restored campaign records the selected save slot")
    if int(GameState.trade_state.get("transactions", 0)) != 4 or int(GameState.trade_state.get("markets", {}).get("sethmarch", {}).get("stock", {}).get("trade_grain", 0)) != 17:
        _fail("regional market stock and transaction history survive campaign save and Continue")

    var world_packed := load("res://World.tscn") as PackedScene
    if world_packed == null:
        _fail("World.tscn loads as a PackedScene")
        _finish(true)
        return

    var world := world_packed.instantiate()
    if world == null:
        _fail("World.tscn instantiates")
        _finish(true)
        return

    get_tree().root.add_child(world)
    await get_tree().process_frame

    if not is_instance_valid(world) or not world.is_inside_tree():
        _fail("restored campaign enters the World scene tree")
    elif world.get("wmap") == null:
        _fail("World scene completes startup and creates its regional map")
    else:
        print("  ok    restored campaign enters World and initializes its regional map")

    world.queue_free()
    await get_tree().process_frame

    var battle_scene := BattleSceneScript.new()
    get_tree().root.add_child(battle_scene)
    await get_tree().process_frame
    if not battle_scene.is_inside_tree() or battle_scene.controller.units.is_empty():
        _fail("battle scene initializes a resumable encounter")
    else:
        var player_unit_id := -1
        for value in battle_scene.controller.units:
            var unit = value
            if unit.team == "player":
                player_unit_id = unit.id
                break
        if player_unit_id <= 0:
            _fail("battle snapshot has a valid player turn owner")
        else:
            battle_scene.controller.active_id = player_unit_id
            battle_scene.prep_active = false
            battle_scene.input_locked = false
            _check(battle_scene._autosave(),
                "safe active-turn autosave succeeds and records a resumable campaign")
            var resume_slot := GameState.newest_campaign_slot()
            var resume_result: Dictionary = SaveSystem.load_slot(resume_slot)
            var resume_payload: Dictionary = resume_result.get("payload", {})
            _check(resume_slot != "" and bool(resume_result.get("ok", false))
                and bool(resume_payload.get("campaign", false))
                and typeof(resume_payload.get("battle_resume", {})) == TYPE_DICTIONARY,
                "the newest title-screen campaign slot contains the tactical resume snapshot")
            if resume_slot == "" or not GameState.load_campaign(resume_slot):
                _fail("campaign loader accepts the autosaved battle-resume slot")
            else:
                _check(not GameState.pending_battle_resume.is_empty(),
                    "campaign load restores the pending tactical battle snapshot")
                var resumed_scene := BattleSceneScript.new()
                get_tree().root.add_child(resumed_scene)
                await get_tree().process_frame
                var resumed_unit = resumed_scene.controller.active_unit()
                _check(resumed_scene.is_inside_tree() and resumed_unit != null and resumed_unit.team == "player",
                    "title Continue can restore the saved player turn into the battle scene")
                _check(str(resumed_scene.controller.def.get("id", "")) == "battle_01" and not resumed_scene.prep_active,
                    "resumed battle restores its encounter definition without returning to the briefing")
                _check(GameState.pending_battle_resume.is_empty(),
                    "battle scene consumes the resume snapshot exactly once")

                GameState.party.gold += 17
                resumed_scene.controller.result = "victory"
                _check(resumed_scene._save_before_return_to_title(),
                    "returning after a completed battle saves campaign rewards")
                var completed_save: Dictionary = SaveSystem.load_slot("auto_a")
                var completed_payload: Dictionary = completed_save.get("payload", {})
                var completed_party: Dictionary = completed_payload.get("party", {})
                _check(bool(completed_save.get("ok", false)) and bool(completed_payload.get("campaign", false))
                    and not completed_payload.has("battle_resume"),
                    "completed-battle title return writes a campaign save, not a stale battle snapshot")
                _check(int(completed_party.get("gold", -1)) == GameState.party.gold,
                    "completed-battle rewards remain in the title-screen campaign save")

                var blocker_path := "user://campaign_lifecycle_blocker"
                if FileAccess.file_exists(blocker_path):
                    DirAccess.remove_absolute(blocker_path)
                var blocker := FileAccess.open(blocker_path, FileAccess.WRITE)
                if blocker == null:
                    _fail("save-failure fixture creates its blocking file")
                else:
                    blocker.store_string("not a directory")
                    blocker.close()
                    if SaveSystem.set_test_save_directory(blocker_path):
                        var scene_before_return = get_tree().current_scene
                        resumed_scene._return_to_title()
                        await get_tree().process_frame
                        _check(get_tree().current_scene == scene_before_return,
                            "failed campaign save cancels Return to Title and keeps the battle scene active")
                    else:
                        _fail("save-failure fixture can redirect the isolated save directory")
                    SaveSystem.set_test_save_directory("user://campaign_lifecycle_test")
                    DirAccess.remove_absolute(blocker_path)

                resumed_scene.queue_free()
                await get_tree().process_frame

    battle_scene.queue_free()
    await get_tree().process_frame
    _finish(true)


func _check(condition: bool, label: String) -> void:
    if condition:
        print("  ok    " + label)
    else:
        _fail(label)


func _fail(label: String) -> void:
    failures += 1
    push_error("FAIL: " + label)


func _snapshot_autosave_files() -> void:
    for slot in ["auto_a", "auto_b"]:
        var base_path: String = SaveSystem.slot_path(slot)
        for suffix in ["", ".bak", ".tmp"]:
            var path: String = base_path + suffix
            var exists := FileAccess.file_exists(path)
            autosave_snapshot[path] = {
                "exists": exists,
                "bytes": FileAccess.get_file_as_bytes(path) if exists else PackedByteArray()
            }


func _restore_autosave_files() -> void:
    for path_value in autosave_snapshot.keys():
        var path := str(path_value)
        var snapshot: Dictionary = autosave_snapshot[path]
        if not bool(snapshot.get("exists", false)):
            if FileAccess.file_exists(path):
                DirAccess.remove_absolute(path)
            continue
        var file := FileAccess.open(path, FileAccess.WRITE)
        if file != null:
            file.store_buffer(snapshot.get("bytes", PackedByteArray()))
            file.close()
        else:
            _fail("original autosave file can be restored: " + path)


func _finish(cleanup_test_slot: bool) -> void:
    if cleanup_test_slot and owns_test_slot:
        SaveSystem.delete_slot(TEST_SLOT)
    _restore_autosave_files()
    print("Campaign lifecycle failures: %d" % failures)
    get_tree().quit(1 if failures > 0 else 0)
