class_name CharacterCreator
extends Control
## Touch-first protagonist creator. Emits a validated profile; campaign reset is owned by the caller.

signal confirmed(profile: Dictionary)
signal cancelled

const PreviewScript = preload("res://scripts/ui/character_preview.gd")

var config: Dictionary = {}
var profile: Dictionary = {}
var choices: Dictionary = {}
var name_input: LineEdit
var preview: CharacterPreview
var preview_text: Label
var status_label: Label
var confirm_button: Button
var weapon_option: OptionButton
var allocation_labels: Dictionary = {}
var allocation_sliders: Dictionary = {}
var allocation_total_label: Label
var compact_preview_summary := false


func _ready() -> void:
    config = GameData.character_creation
    profile = CharacterCreation.default_profile(config)
    _build_ui()
    _refresh_preview()


func _build_ui() -> void:
    # One continuous scroll surface: on phones the entire creator (including
    # preview, options, attributes and actions) moves naturally as one page.
    var viewport_size: Vector2 = get_viewport_rect().size
    var narrow: bool = viewport_size.x < 900.0
    compact_preview_summary = false

    var backdrop := ColorRect.new()
    backdrop.color = Color("#080d13")
    backdrop.mouse_filter = Control.MOUSE_FILTER_STOP
    add_child(backdrop)
    backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

    var margin := MarginContainer.new()
    margin.add_theme_constant_override("margin_left", 16 if narrow else 28)
    margin.add_theme_constant_override("margin_top", 18 if narrow else 24)
    margin.add_theme_constant_override("margin_right", 16 if narrow else 28)
    margin.add_theme_constant_override("margin_bottom", 22 if narrow else 28)
    add_child(margin)
    margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

    var scroll := ScrollContainer.new()
    scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
    scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
    scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
    scroll.follow_focus = true
    margin.add_child(scroll)

    var page := VBoxContainer.new()
    page.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    page.add_theme_constant_override("separation", 18 if narrow else 22)
    scroll.add_child(page)

    var heading := Label.new()
    heading.text = "CREATE YOUR HERO"
    heading.add_theme_font_size_override("font_size", 27 if narrow else 34)
    heading.add_theme_color_override("font_color", Color("#e5c98d"))
    heading.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    page.add_child(heading)

    var subtitle := Label.new()
    subtitle.text = "Shape the heir who will reclaim Kaer Sethorn. Every choice helps define your place in the realm."
    subtitle.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    subtitle.add_theme_font_size_override("font_size", 14 if narrow else 16)
    subtitle.add_theme_color_override("font_color", Color("#b8c2cc"))
    page.add_child(subtitle)

    var preview_panel := PanelContainer.new()
    preview_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    var preview_style := StyleBoxFlat.new()
    preview_style.bg_color = Color("#111a24")
    preview_style.border_color = Color("#3c4855")
    preview_style.set_border_width_all(1)
    preview_style.set_corner_radius_all(12)
    preview_style.content_margin_left = 12
    preview_style.content_margin_right = 12
    preview_style.content_margin_top = 12
    preview_style.content_margin_bottom = 12
    preview_panel.add_theme_stylebox_override("panel", preview_style)
    page.add_child(preview_panel)

    var preview_content := VBoxContainer.new()
    preview_content.add_theme_constant_override("separation", 8)
    preview_panel.add_child(preview_content)
    var preview_title := Label.new()
    preview_title.text = "HERO PORTRAIT"
    preview_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    preview_title.add_theme_font_size_override("font_size", 16)
    preview_title.add_theme_color_override("font_color", Color("#e5c98d"))
    preview_content.add_child(preview_title)

    preview = PreviewScript.new()
    preview.custom_minimum_size = Vector2(260, 360) if narrow else Vector2(320, 400)
    preview.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
    preview.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
    preview_content.add_child(preview)
    preview_text = Label.new()
    preview_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    preview_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    preview_text.add_theme_font_size_override("font_size", 14 if narrow else 15)
    preview_text.add_theme_color_override("font_color", Color("#c8d0d8"))
    preview_content.add_child(preview_text)

    var form_panel := PanelContainer.new()
    form_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    var form_style := StyleBoxFlat.new()
    form_style.bg_color = Color("#0e151e")
    form_style.border_color = Color("#293744")
    form_style.set_border_width_all(1)
    form_style.set_corner_radius_all(12)
    form_style.content_margin_left = 12
    form_style.content_margin_right = 12
    form_style.content_margin_top = 14
    form_style.content_margin_bottom = 14
    form_panel.add_theme_stylebox_override("panel", form_style)
    page.add_child(form_panel)

    var form := VBoxContainer.new()
    form.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    form.add_theme_constant_override("separation", 12)
    form_panel.add_child(form)
    var identity_heading := Label.new()
    identity_heading.text = "IDENTITY & BACKGROUND"
    identity_heading.add_theme_font_size_override("font_size", 17)
    identity_heading.add_theme_color_override("font_color", Color("#e5c98d"))
    form.add_child(identity_heading)

    _add_name_field(form)
    _add_choice(form, "Presentation", "presentation", config.get("presentations", []))
    _add_choice(form, "Face", "face", config.get("faces", []))
    _add_choice(form, "Hair", "hair", config.get("hair", []))
    _add_choice(form, "Skin tone", "skin", config.get("skin", []))
    _add_choice(form, "Build", "build", config.get("builds", []))
    _add_choice(form, "Origin", "origin", _dictionary_options(config.get("origins", {})))

    var combat_heading := Label.new()
    combat_heading.text = "COMBAT & PERSONALITY"
    combat_heading.add_theme_font_size_override("font_size", 17)
    combat_heading.add_theme_color_override("font_color", Color("#e5c98d"))
    form.add_child(combat_heading)
    _add_choice(form, "Starting discipline", "discipline", _dictionary_options(config.get("disciplines", {})))
    weapon_option = _add_choice(form, "Weapon preference", "weapon_preference", [])
    _add_choice(form, "Temperament", "temperament", _dictionary_options(config.get("temperaments", {})))
    _refresh_weapon_options()

    _add_attribute_allocation(form)

    var actions := VBoxContainer.new()
    actions.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    actions.add_theme_constant_override("separation", 10)
    page.add_child(actions)
    status_label = Label.new()
    status_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    status_label.add_theme_font_size_override("font_size", 13 if narrow else 15)
    actions.add_child(status_label)

    var button_row := HBoxContainer.new()
    button_row.add_theme_constant_override("separation", 10)
    button_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    actions.add_child(button_row)
    var back_button := _make_button("BACK", 0)
    back_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    back_button.pressed.connect(_on_back)
    button_row.add_child(back_button)
    confirm_button = _make_button("BEGIN CHRONICLE", 0)
    confirm_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    confirm_button.pressed.connect(_on_confirm)
    button_row.add_child(confirm_button)


func _add_name_field(parent: VBoxContainer) -> void:
    var label := Label.new()
    label.text = "Protagonist name"
    label.add_theme_font_size_override("font_size", 16)
    parent.add_child(label)
    name_input = LineEdit.new()
    name_input.text = str(profile.get("name", ""))
    name_input.placeholder_text = "2–24 characters"
    name_input.custom_minimum_size = Vector2(0, 52)
    name_input.add_theme_font_size_override("font_size", 20)
    name_input.text_changed.connect(_on_name_changed)
    parent.add_child(name_input)


func _add_choice(parent: VBoxContainer, label_text: String, field: String, values: Array) -> OptionButton:
    var row := VBoxContainer.new()
    row.add_theme_constant_override("separation", 3)
    parent.add_child(row)
    var label := Label.new()
    label.text = label_text
    label.add_theme_font_size_override("font_size", 15)
    row.add_child(label)
    var option := OptionButton.new()
    option.custom_minimum_size = Vector2(0, 50)
    option.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    option.add_theme_font_size_override("font_size", 18)
    row.add_child(option)
    choices[field] = option
    _fill_option(option, field, values)
    option.item_selected.connect(_on_choice_selected.bind(field, option))
    return option


func _fill_option(option: OptionButton, field: String, values: Array) -> void:
    option.clear()
    var selected_id: String = str(profile.get(field, ""))
    var selected_index: int = 0
    for value in values:
        var id: String = str(value)
        var label: String = _display_name(field, id)
        option.add_item(label)
        option.set_item_metadata(option.item_count - 1, id)
        if id == selected_id:
            selected_index = option.item_count - 1
    if option.item_count > 0:
        option.select(selected_index)


func _dictionary_options(source: Dictionary) -> Array:
    var result: Array = []
    for key in source.keys():
        result.append(str(key))
    return result


func _display_name(field: String, id: String) -> String:
    var source: Dictionary = {}
    if field == "origin":
        source = config.get("origins", {})
    elif field == "discipline":
        source = config.get("disciplines", {})
    elif field == "temperament":
        source = config.get("temperaments", {})
    if source.has(id):
        return str((source[id] as Dictionary).get("name", id))
    return id.replace("_", " ").capitalize()


func _add_attribute_allocation(parent: VBoxContainer) -> void:
    var heading := Label.new()
    heading.text = "Starting attributes"
    heading.add_theme_color_override("font_color", Color("#e5c98d"))
    heading.add_theme_font_size_override("font_size", 19)
    parent.add_child(heading)
    var allocation: Dictionary = profile.get("stat_allocation", {"str": 2, "dex": 2, "int": 1, "vit": 1, "spd": 1, "lck": 1})
    profile["stat_allocation"] = allocation.duplicate(true)
    for stat in ["str", "dex", "int", "vit", "spd", "lck"]:
        var row := HBoxContainer.new()
        row.add_theme_constant_override("separation", 8)
        parent.add_child(row)
        var caption := Label.new()
        caption.text = stat.to_upper()
        caption.custom_minimum_size = Vector2(48, 0)
        row.add_child(caption)
        var slider := HSlider.new()
        slider.min_value = 0
        slider.max_value = 5
        slider.step = 1
        slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        slider.value = int(allocation.get(stat, 0))
        row.add_child(slider)
        var value_label := Label.new()
        value_label.custom_minimum_size = Vector2(24, 0)
        value_label.text = str(int(slider.value))
        row.add_child(value_label)
        allocation_labels[stat] = value_label
        allocation_sliders[stat] = slider
        slider.value_changed.connect(_on_stat_allocation_changed.bind(stat))
    allocation_total_label = Label.new()
    allocation_total_label.add_theme_color_override("font_color", Color("#b8c2cc"))
    parent.add_child(allocation_total_label)
    _refresh_allocation_total()


func _on_stat_allocation_changed(value: float, stat: String) -> void:
    var allocation: Dictionary = profile.get("stat_allocation", {})
    allocation[stat] = int(value)
    profile["stat_allocation"] = allocation
    if allocation_labels.has(stat):
        (allocation_labels[stat] as Label).text = str(int(value))
    _refresh_allocation_total()
    _refresh_preview()


func _refresh_allocation_total() -> void:
    if allocation_total_label == null:
        return
    var allocation: Dictionary = profile.get("stat_allocation", {})
    var spent := 0
    for stat in ["str", "dex", "int", "vit", "spd", "lck"]:
        spent += int(allocation.get(stat, 0))
    var total := int(config.get("stat_points", 8))
    allocation_total_label.text = "Attribute points: %d / %d" % [spent, total]
    allocation_total_label.add_theme_color_override("font_color", Color("#a8c7a0") if spent == total else Color("#e6a18f"))


func _refresh_weapon_options() -> void:
    if weapon_option == null:
        return
    var discipline: Dictionary = (config.get("disciplines", {}) as Dictionary).get(str(profile.get("discipline", "")), {})
    var allowed: Array = discipline.get("weapon_preferences", [])
    if not allowed.has(str(profile.get("weapon_preference", ""))) and not allowed.is_empty():
        profile["weapon_preference"] = str(allowed[0])
    _fill_option(weapon_option, "weapon_preference", allowed)


func _on_choice_selected(index: int, field: String, option: OptionButton) -> void:
    if index < 0 or index >= option.item_count:
        return
    profile[field] = str(option.get_item_metadata(index))
    if field == "discipline":
        _refresh_weapon_options()
    _refresh_preview()


func _on_name_changed(value: String) -> void:
    profile["name"] = value
    _refresh_preview()


func _refresh_preview() -> void:
    if preview != null:
        preview.set_profile(profile)
    if preview_text != null:
        var origin: Dictionary = (config.get("origins", {}) as Dictionary).get(str(profile.get("origin", "")), {})
        var discipline: Dictionary = (config.get("disciplines", {}) as Dictionary).get(str(profile.get("discipline", "")), {})
        var temperament: Dictionary = (config.get("temperaments", {}) as Dictionary).get(str(profile.get("temperament", "")), {})
        var origin_bonus: String = _format_bonuses(origin.get("stat_bonus", {}))
        var temperament_bonus: String = _format_bonuses(temperament.get("stat_bonus", {}))
        var allocation: Dictionary = profile.get("stat_allocation", {})
        var allocation_text: String = "Starting stats: STR %d · DEX %d · INT %d · VIT %d · SPD %d · LCK %d" % [
            int(allocation.get("str", 0)), int(allocation.get("dex", 0)), int(allocation.get("int", 0)),
            int(allocation.get("vit", 0)), int(allocation.get("spd", 0)), int(allocation.get("lck", 0))
        ]
        if compact_preview_summary:
            preview_text.text = "%s · %s · %s\n%s / %s · %s · %s" % [
                str(profile.get("name", "")), str(origin.get("name", "")),
                str(discipline.get("name", "")), str(profile.get("presentation", "")).capitalize(),
                str(profile.get("build", "")).capitalize(),
                str(profile.get("weapon_preference", "")).capitalize(),
                str(temperament.get("name", ""))
            ]
        else:
            preview_text.text = "%s\n%s presentation · %s build\n%s · %s\nWeapon: %s\nTemperament: %s\nOrigin: %s\nBonuses: %s / %s\n%s" % [
                str(profile.get("name", "")), str(profile.get("presentation", "")).capitalize(),
                str(profile.get("build", "")).capitalize(), str(origin.get("name", "")),
                str(discipline.get("name", "")), str(profile.get("weapon_preference", "")).capitalize(),
                str(temperament.get("name", "")), str(origin.get("description", "")), origin_bonus, temperament_bonus, allocation_text
            ]
    var reason: String = CharacterCreation.validate(profile, config, GameData.classes)
    if status_label != null:
        if reason == "":
            status_label.text = "Starting a new chronicle resets the current in-memory party. Existing save files are not deleted."
            status_label.add_theme_color_override("font_color", Color("#a8c7a0"))
        else:
            status_label.text = reason
            status_label.add_theme_color_override("font_color", Color("#e6a18f"))
    if confirm_button != null:
        confirm_button.disabled = reason != ""


func _format_bonuses(bonuses: Dictionary) -> String:
    var parts: Array[String] = []
    for key in bonuses.keys():
        var amount: int = int(bonuses[key])
        var sign_text: String = "+" if amount >= 0 else ""
        parts.append("%s%s %s" % [sign_text, str(amount), str(key).to_upper()])
    return ", ".join(PackedStringArray(parts)) if not parts.is_empty() else "No stat change"


func _make_button(caption: String, min_width: float) -> Button:
    var button := Button.new()
    button.text = caption
    button.custom_minimum_size = Vector2(min_width, 58)
    button.add_theme_font_size_override("font_size", 18)
    return button


func _on_confirm() -> void:
    var reason: String = CharacterCreation.validate(profile, config, GameData.classes)
    if reason != "":
        _refresh_preview()
        return
    confirmed.emit(profile.duplicate(true))


func _on_back() -> void:
    cancelled.emit()
