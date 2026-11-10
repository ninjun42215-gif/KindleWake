extends Node
## Runtime lifecycle regression: run with
## godot --headless --path . res://tests/campaign_continue_lifecycle_test.tscn
## This scene runs with project autoloads enabled (unlike --script mode).

var failures: int = 0


func _ready() -> void:
    call_deferred("_run_lifecycle")


func _run_lifecycle() -> void:
    await get_tree().process_frame

    var slot := "campaign_lifecycle_test"
    SaveSystem.delete_slot(slot)
    GameState.new_game()

    if not GameState.save_campaign(slot):
        _fail("new campaign can be saved through GameState")
        _finish(slot)
        return

    GameState.new_game()
    if not GameState.load_campaign(slot):
        _fail("saved campaign restores through GameState after a fresh state")
        _finish(slot)
        return

    var world_packed := load("res://World.tscn") as PackedScene
    if world_packed == null:
        _fail("World.tscn loads as a PackedScene")
        _finish(slot)
        return

    var world := world_packed.instantiate()
    if world == null:
        _fail("World.tscn instantiates")
        _finish(slot)
        return

    get_tree().root.add_child(world)
    await get_tree().process_frame
    if not is_instance_valid(world) or not world.is_inside_tree():
        _fail("restored campaign enters the World scene tree")
    else:
        print("  ok    restored campaign enters the World scene tree")

    world.queue_free()
    await get_tree().process_frame
    _finish(slot)


func _fail(label: String) -> void:
    failures += 1
    push_error("FAIL: " + label)


func _finish(slot: String) -> void:
    SaveSystem.delete_slot(slot)
    print("Campaign lifecycle failures: %d" % failures)
    get_tree().quit(1 if failures > 0 else 0)
