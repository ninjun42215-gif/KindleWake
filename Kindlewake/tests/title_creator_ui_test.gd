extends Node
## Runtime UI regression for the title screen and touch-first protagonist creator.
## Run as a scene so all project autoloads and imported assets are available.

const TitleScreenScript = preload("res://scripts/ui/title_screen.gd")
const CharacterCreatorScript = preload("res://scripts/ui/character_creator.gd")

var failures := 0


func _ready() -> void:
    call_deferred("_run_ui_test")


func _check(condition: bool, label: String) -> void:
    if condition:
        print("  ok    " + label)
    else:
        failures += 1
        push_error("FAIL: " + label)


func _find_continue_button(title: TitleScreenScript) -> Button:
    for child in title.content_box.get_children():
        if child.is_queued_for_deletion():
            continue
        if child is Button and (child as Button).text == "CONTINUE":
            return child as Button
    return null


func _run_ui_test() -> void:
    await get_tree().process_frame

    _check(SaveSystem.set_test_save_directory("user://title_creator_ui_test"),
        "title UI test redirects saves to an isolated test directory")
    SaveSystem.delete_slot("1")
    GameState.new_game()

    var creator := CharacterCreatorScript.new()
    get_tree().root.add_child(creator)
    await get_tree().process_frame

    _check(creator.is_inside_tree(), "character creator enters the scene tree")
    _check(creator.preview != null and is_instance_valid(creator.preview), "creator builds its live portrait preview")
    _check(creator.name_input != null and creator.confirm_button != null, "creator builds identity input and confirmation action")
    _check(creator.allocation_sliders.size() == 6, "creator builds all six attribute allocation controls")
    _check(creator.confirm_button != null and not creator.confirm_button.disabled, "valid default profile enables Begin Chronicle")

    var emitted_profiles: Array = []
    creator.confirmed.connect(func(profile: Dictionary) -> void:
        emitted_profiles.append(profile)
    )
    creator.name_input.text = "QA Chronicle"
    creator.name_input.emit_signal("text_changed", "QA Chronicle")
    creator._on_confirm()
    _check(emitted_profiles.size() == 1, "valid creator profile emits exactly one confirmation")
    if not emitted_profiles.is_empty():
        _check(str(emitted_profiles[0].get("name", "")) == "QA Chronicle", "creator emits the edited protagonist identity")
        _check(CharacterCreation.validate(emitted_profiles[0], GameData.character_creation, GameData.classes) == "",
            "emitted protagonist profile passes the production validator")

    creator.queue_free()
    await get_tree().process_frame

    var title := TitleScreenScript.new()
    get_tree().root.add_child(title)
    await get_tree().process_frame
    _check(title.content_box != null and title.status_label != null, "title screen builds its menu and status region")
    _check(title.content_box.get_child_count() >= 5, "title screen exposes the primary campaign menu")
    var continue_button := _find_continue_button(title)
    _check(continue_button != null and continue_button.disabled,
        "Continue is disabled when no valid campaign save exists")

    _check(GameState.save_campaign("1"), "a valid campaign can be saved for the Continue menu test")
    title._show_main()
    await get_tree().process_frame
    continue_button = _find_continue_button(title)
    _check(continue_button != null and not continue_button.disabled,
        "Continue becomes available when a valid campaign save exists")

    title._new_game()
    await get_tree().process_frame
    var overlay = title.creator_overlay
    _check(overlay != null and is_instance_valid(overlay) and overlay.is_inside_tree(),
        "New Game opens the creator as a full-screen title-screen overlay")
    if overlay != null and is_instance_valid(overlay):
        _check(overlay.preview != null and overlay.confirm_button != null,
            "title-screen creator overlay finishes building its interactive controls")
        overlay._on_back()
        await get_tree().process_frame
    _check(title.creator_overlay == null, "creator cancellation releases the overlay")
    _check(title.content_box.get_child_count() >= 5, "creator cancellation restores the title menu")

    title.queue_free()
    await get_tree().process_frame
    SaveSystem.delete_slot("1")
    print("Title and creator UI failures: %d" % failures)
    get_tree().quit(1 if failures > 0 else 0)
