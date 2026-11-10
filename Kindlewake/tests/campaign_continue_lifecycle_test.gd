extends Node
## Runtime lifecycle regression: run as a scene (not --script) so project autoloads are active.
## Command: godot --headless --path . res://tests/campaign_continue_lifecycle_test.tscn

const TEST_SLOT := "campaign_lifecycle_tmp_20261110"

var failures: int = 0
var autosave_snapshot: Dictionary = {}
var owns_test_slot: bool = false


func _ready() -> void:
    call_deferred("_run_lifecycle")


func _run_lifecycle() -> void:
    await get_tree().process_frame
    _snapshot_autosave_files()

    if bool(SaveSystem.slot_info(TEST_SLOT).get("exists", false)):
        _fail("reserved lifecycle-test save slot is already occupied; refusing to overwrite it")
        _finish(false)
        return

    owns_test_slot = true
    GameState.new_game()

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
    _finish(true)


func _fail(label: String) -> void:
    failures += 1
    push_error("FAIL: " + label)


func _snapshot_autosave_files() -> void:
    var base_path: String = SaveSystem.slot_path("auto_a")
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
