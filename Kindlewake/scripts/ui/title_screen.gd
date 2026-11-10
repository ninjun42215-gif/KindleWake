extends Control
## Offline title screen and campaign slot browser.

const CREATOR_SCENE = preload("res://CharacterCreator.tscn")
const SETTINGS_PATH := "user://settings.cfg"

var root_box: VBoxContainer
var content_box: VBoxContainer
var status_label: Label
var master_slider: HSlider
var menu_buttons: Array[Button] = []
var creator_overlay: CharacterCreator


func _ready() -> void:
    var cfg := ConfigFile.new()
    cfg.load(SETTINGS_PATH)
    var volume := clampf(float(cfg.get_value("audio", "master", 0.8)), 0.0, 1.0)
    var master_bus := AudioServer.get_bus_index("Master")
    if master_bus >= 0:
        AudioServer.set_bus_volume_db(master_bus, linear_to_db(maxf(volume, 0.0001)))
        AudioServer.set_bus_mute(master_bus, volume <= 0.001)
    _build()


func _build() -> void:
    var backdrop := ColorRect.new()
    backdrop.color = Color("#080d13")
    backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    add_child(backdrop)

    var illustration := TextureRect.new()
    illustration.texture = load("res://assets/art/ui/title_illustration.svg")
    illustration.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    illustration.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
    illustration.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
    illustration.modulate = Color(0.72, 0.82, 0.78, 0.72)
    illustration.mouse_filter = Control.MOUSE_FILTER_IGNORE
    add_child(illustration)

    var wash := ColorRect.new()
    wash.color = Color("#17232a")
    wash.anchor_left = 0.0
    wash.anchor_top = 0.0
    wash.anchor_right = 1.0
    wash.anchor_bottom = 1.0
    wash.modulate.a = 0.48
    wash.mouse_filter = Control.MOUSE_FILTER_IGNORE
    add_child(wash)

    var center := CenterContainer.new()
    center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    add_child(center)

    var panel := PanelContainer.new()
    panel.custom_minimum_size = Vector2(maxf(300.0, minf(440.0, get_viewport_rect().size.x - 28.0)), 0)
    panel.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
    var style := StyleBoxFlat.new()
    style.bg_color = Color("#101820")
    style.border_color = Color("#8b7045")
    style.set_border_width_all(2)
    style.set_corner_radius_all(8)
    style.content_margin_left = 18 if get_viewport_rect().size.x < 480.0 else 34
    style.content_margin_right = 18 if get_viewport_rect().size.x < 480.0 else 34
    style.content_margin_top = 28
    style.content_margin_bottom = 28
    panel.add_theme_stylebox_override("panel", style)
    center.add_child(panel)

    root_box = VBoxContainer.new()
    root_box.add_theme_constant_override("separation", 13)
    panel.add_child(root_box)

    var title := Label.new()
    title.text = "K I N D L E W A K E"
    title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    title.add_theme_font_size_override("font_size", 28 if get_viewport_rect().size.x < 480.0 else 34)
    title.add_theme_color_override("font_color", Color("#e4c58a"))
    root_box.add_child(title)

    var subtitle := Label.new()
    subtitle.text = "THE SUNDERED VOW"
    subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    subtitle.add_theme_font_size_override("font_size", 15)
    subtitle.add_theme_color_override("font_color", Color("#aab6bc"))
    root_box.add_child(subtitle)

    var ornament := TextureRect.new()
    ornament.texture = load("res://assets/art/ui/ornament_divider.svg")
    ornament.custom_minimum_size = Vector2(320, 54)
    ornament.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
    ornament.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
    ornament.mouse_filter = Control.MOUSE_FILTER_IGNORE
    root_box.add_child(ornament)

    var divider := HSeparator.new()
    root_box.add_child(divider)
    content_box = VBoxContainer.new()
    content_box.add_theme_constant_override("separation", 10)
    root_box.add_child(content_box)
    status_label = Label.new()
    status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    status_label.add_theme_color_override("font_color", Color("#d3b77d"))
    root_box.add_child(status_label)
    _show_main()


func _button(label: String, callback: Callable, primary: bool = false) -> Button:
    var b := Button.new()
    b.text = label
    b.custom_minimum_size = Vector2(0, 54)
    b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    b.add_theme_font_size_override("font_size", 20)
    var normal := StyleBoxFlat.new()
    normal.bg_color = Color("#26333b") if not primary else Color("#59452b")
    normal.border_color = Color("#596873") if not primary else Color("#c09b5e")
    normal.set_border_width_all(1)
    normal.set_corner_radius_all(4)
    normal.content_margin_top = 8
    normal.content_margin_bottom = 8
    b.add_theme_stylebox_override("normal", normal)
    b.add_theme_color_override("font_color", Color("#eee4d0"))
    b.pressed.connect(callback)
    return b


func _clear_content() -> void:
    for child in content_box.get_children():
        child.queue_free()


func _show_main() -> void:
    _clear_content()
    var latest := GameState.newest_campaign_slot()
    var continue_btn := _button("CONTINUE", _continue_game, true)
    continue_btn.disabled = latest == ""
    content_box.add_child(continue_btn)
    content_box.add_child(_button("NEW GAME", _new_game))
    content_box.add_child(_button("LOAD GAME", _show_load))
    content_box.add_child(_button("SETTINGS", _show_settings))
    content_box.add_child(_button("EXIT GAME", _confirm_exit))
    status_label.text = "A chronicle awaits." if latest == "" else "A saved chronicle is ready."


func _continue_game() -> void:
    var slot := GameState.newest_campaign_slot()
    if slot == "" or not GameState.load_campaign(slot):
        status_label.text = "No valid campaign save was found."
        return
    get_tree().change_scene_to_file("res://World.tscn")


func _new_game() -> void:
    if is_instance_valid(creator_overlay):
        creator_overlay.queue_free()
    _clear_content()
    status_label.text = "Create the heir who will reclaim Kaer Sethorn."
    creator_overlay = CREATOR_SCENE.instantiate() as CharacterCreator
    creator_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    creator_overlay.offset_left = 0
    creator_overlay.offset_top = 0
    creator_overlay.offset_right = 0
    creator_overlay.offset_bottom = 0
    add_child(creator_overlay)
    move_child(creator_overlay, get_child_count() - 1)
    creator_overlay.confirmed.connect(_on_creator_confirmed)
    creator_overlay.cancelled.connect(_on_creator_cancelled)


func _on_creator_confirmed(profile: Dictionary) -> void:
    if is_instance_valid(creator_overlay):
        creator_overlay.queue_free()
        creator_overlay = null
    GameState.new_game(profile)
    GameState.campaign_slot = "auto_a"
    get_tree().change_scene_to_file("res://Prologue.tscn")


func _on_creator_cancelled() -> void:
    if is_instance_valid(creator_overlay):
        creator_overlay.queue_free()
        creator_overlay = null
    _show_main()


func _show_load() -> void:
    _clear_content()
    status_label.text = "Choose a chronicle to load."
    for slot in ["1", "2", "3", "auto_a", "auto_b"]:
        var info: Dictionary = SaveSystem.slot_info(slot)
        if not bool(info.get("exists", false)):
            continue
        var label := "%s  •  %s" % ["Autosave A" if slot == "auto_a" else "Autosave B" if slot == "auto_b" else "Slot " + slot, str(info.get("saved_at", "Unknown date"))]
        if str(info.get("summary", "")) != "":
            label += "\n" + str(info["summary"])
        var b := _button(label, _load_slot.bind(slot))
        var loaded: Dictionary = SaveSystem.load_slot(slot)
        b.disabled = not bool(loaded.get("ok", false)) or not bool((loaded.get("payload", {}) as Dictionary).get("campaign", false))
        content_box.add_child(b)
    content_box.add_child(_button("BACK", _show_main))


func _load_slot(slot: String) -> void:
    if GameState.load_campaign(slot):
        get_tree().change_scene_to_file("res://World.tscn")
    else:
        status_label.text = "That save is not a valid campaign."


func _show_settings() -> void:
    _clear_content()
    status_label.text = "Audio settings are saved on this device."
    var cfg := ConfigFile.new()
    cfg.load(SETTINGS_PATH)
    var row := HBoxContainer.new()
    var label := Label.new()
    label.text = "MASTER VOLUME"
    label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    row.add_child(label)
    master_slider = HSlider.new()
    master_slider.custom_minimum_size = Vector2(180, 36)
    master_slider.min_value = 0.0
    master_slider.max_value = 1.0
    master_slider.step = 0.05
    master_slider.value = float(cfg.get_value("audio", "master", 0.8))
    master_slider.value_changed.connect(_on_volume_changed)
    row.add_child(master_slider)
    content_box.add_child(row)

    var haptics_toggle := CheckButton.new()
    haptics_toggle.text = "HAPTIC FEEDBACK"
    haptics_toggle.button_pressed = KW.haptics
    haptics_toggle.toggled.connect(KW.set_haptics_enabled)
    content_box.add_child(haptics_toggle)

    var motion_toggle := CheckButton.new()
    motion_toggle.text = "REDUCE MOTION"
    motion_toggle.button_pressed = KW.reduce_motion
    motion_toggle.toggled.connect(KW.set_reduce_motion_enabled)
    content_box.add_child(motion_toggle)

    var sfx_toggle := CheckButton.new()
    sfx_toggle.text = "UI SOUND EFFECTS"
    sfx_toggle.button_pressed = KW.sfx_enabled
    sfx_toggle.toggled.connect(KW.set_sfx_enabled)
    content_box.add_child(sfx_toggle)
    content_box.add_child(_button("BACK", _show_main))


func _on_volume_changed(value: float) -> void:
    var bus := AudioServer.get_bus_index("Master")
    if bus >= 0:
        AudioServer.set_bus_volume_db(bus, linear_to_db(maxf(value, 0.0001)))
        AudioServer.set_bus_mute(bus, value <= 0.001)
    var cfg := ConfigFile.new()
    cfg.load(SETTINGS_PATH)
    cfg.set_value("audio", "master", value)
    cfg.save(SETTINGS_PATH)


func _confirm_exit() -> void:
    _clear_content()
    status_label.text = "Leave KindleWake? Unsaved progress may be lost."
    content_box.add_child(_button("QUIT TO DESKTOP", _quit_game, true))
    content_box.add_child(_button("CANCEL", _show_main))


func _quit_game() -> void:
    get_tree().quit()
