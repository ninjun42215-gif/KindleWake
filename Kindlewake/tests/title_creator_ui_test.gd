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
    _check(creator.presentation_buttons.size() == 3, "creator exposes all presentation radio choices")
    _check(creator.portrait_buttons.size() == 12, "creator exposes the complete twelve-portrait gallery")
    var all_portraits_load := true
    for portrait in GameData.character_creation.get("portraits", []):
        var portrait_path := "res://assets/art/portraits/%s.svg" % str(portrait.get("id", ""))
        if not ResourceLoader.exists(portrait_path) or load(portrait_path) == null:
            all_portraits_load = false
    _check(all_portraits_load, "all twelve portrait assets load as Godot textures")
    if creator.portrait_buttons.has("auburn_ranger"):
        creator._on_portrait_button_toggled(true, "auburn_ranger")
        _check(str(creator.profile.get("portrait_id", "")) == "auburn_ranger",
            "portrait selection updates the saved protagonist identity")
        _check(str(creator.profile.get("presentation", "")) == "feminine"
            and str(creator.profile.get("hair", "")) == "tied_brown"
            and str(creator.profile.get("skin", "")) == "fair",
            "selected portrait synchronizes presentation and physical appearance")
        _check((creator.presentation_buttons["feminine"] as CheckButton).button_pressed,
            "portrait selection synchronizes the presentation radio")
    creator._on_portrait_button_toggled(true, "torren_redcloak")
    if creator.choices.has("origin"):
        var origin_option: OptionButton = creator.choices["origin"]
        if origin_option.item_count > 1:
            creator._on_choice_selected(1, "origin", origin_option)
            _check(str(creator.profile.get("origin", "")) == str(origin_option.get_item_metadata(1)),
                "native dropdown selection updates the protagonist background")
    creator._on_stat_allocation_changed(5.0, "str")
    var allocated_after_clamp := 0
    for stat in ["str", "dex", "int", "vit", "spd", "lck"]:
        allocated_after_clamp += int(creator.profile.get("stat_allocation", {}).get(stat, 0))
    _check(allocated_after_clamp <= int(GameData.character_creation.get("stat_points", 8)),
        "attribute sliders cannot overspend the starting point budget")
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
        var protagonist_def: Dictionary = CharacterCreation.build_definition(GameData.characters.get("torren", {}), emitted_profiles[0], GameData.character_creation, GameData.classes)
        _check(str(protagonist_def.get("creation", {}).get("portrait_id", "")) == "torren_redcloak",
            "the selected portrait ID is embedded in the actual protagonist definition")
        var sheet = CharacterSheet.from_def("torren", protagonist_def)
        _check(str(protagonist_def.get("portrait_id", "")) == "torren_redcloak",
            "battle-ready protagonist definition carries the selected portrait identity")
        _check(sheet.portrait_id == "torren_redcloak", "the protagonist character sheet receives the selected portrait")
        var restored_sheet = CharacterSheet.from_dict(sheet.to_dict())
        _check(restored_sheet.portrait_id == "torren_redcloak", "the selected portrait survives character save serialization")

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
