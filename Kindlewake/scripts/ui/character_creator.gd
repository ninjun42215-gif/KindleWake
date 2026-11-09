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


func _ready() -> void:
    config = GameData.character_creation
    profile = CharacterCreation.default_profile(config)
    _build_ui()
    _refresh_preview()


func _build_ui() -> void:
    # The creator is designed for phones first. A narrow viewport gets one
    # vertical column; desktop keeps the form and preview side by side.
    var narrow: bool = get_viewport_rect().size.x < 900.0

    var backdrop := ColorRect.new()
    backdrop.color = Color("#080d13")
    backdrop.mouse_filter = Control.MOUSE_FILTER_STOP
    add_child(backdrop)
    backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

    var margin := MarginContainer.new()
    margin.add_theme_constant_override("margin_left", 14 if narrow else 22)
    margin.add_theme_constant_override("margin_top", 12 if narrow else 16)
    margin.add_theme_constant_override("margin_right", 14 if narrow else 22)
    margin.add_theme_constant_override("margin_bottom", 12 if narrow else 16)
    add_child(margin)
    margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

    var outer := VBoxContainer.new()
    outer.add_theme_constant_override("separation", 8)
    outer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    outer.size_flags_vertical = Control.SIZE_EXPAND_FILL
    margin.add_child(outer)

    var heading := Label.new()
    heading.text = "BEGIN A NEW CHRONICLE"
    heading.add_theme_font_size_override("font_size", 25 if narrow else 30)
    heading.add_theme_color_override("font_color", Color("#e5c98d"))
    heading.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    outer.add_child(heading)

    var subtitle := Label.new()
    subtitle.text = "Shape the heir who will reclaim Kaer Sethorn. Your choices affect starting stats and story flags."
    subtitle.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    subtitle.add_theme_font_size_override("font_size", 14 if narrow else 16)
    subtitle.add_theme_color_override("font_color", Color("#b8c2cc"))
    outer.add_child(subtitle)

    var scroll := ScrollContainer.new()
    scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
    scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
    outer.add_child(scroll)

    var body: Container = VBoxContainer.new() if narrow else HBoxContainer.new()
    body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    body.add_theme_constant_override("separation", 14 if narrow else 18)
    scroll.add_child(body)

    var form := VBoxContainer.new()
    form.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    form.add_theme_constant_override("separation", 9)
    if not narrow:
        form.custom_minimum_size = Vector2(470, 0)
    body.add_child(form)

    _add_name_field(form)
    _add_choice(form, "Presentation", "presentation", config.get("presentations", []))
    _add_choice(form, "Face", "face", config.get("faces", []))
    _add_choice(form, "Hair", "hair", config.get("hair", []))
    _add_choice(form, "Skin tone", "skin", config.get("skin", []))
    _add_choice(form, "Build", "build", config.get("builds", []))
    _add_choice(form, "Origin", "origin", _dictionary_options(config.get("origins", {})))
    _add_choice(form, "Starting discipline", "discipline", _dictionary_options(config.get("disciplines", {})))
    weapon_option = _add_choice(form, "Weapon preference", "weapon_preference", [])
    _add_choice(form, "Temperament", "temperament", _dictionary_options(config.get("temperaments", {})))
    _refresh_weapon_options()

    var preview_column := VBoxContainer.new()
    preview_column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    preview_column.add_theme_constant_override("separation", 8)
    if narrow:
        preview_column.custom_minimum_size = Vector2(0, 0)
    else:
        preview_column.custom_minimum_size = Vector2(280, 0)
        preview_column.size_flags_horizontal = Control.SIZE_SHRINK_END
    var preview_title := Label.new()
    preview_title.text = "PROTAGONIST PREVIEW"
    preview_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    preview_title.add_theme_font_size_override("font_size", 18)
    preview_title.add_theme_color_override("font_color", Color("#e5c98d"))
    preview_column.add_child(preview_title)
    preview = PreviewScript.new()
    preview.custom_minimum_size = Vector2(0, 250) if narrow else Vector2(280, 330)
    preview.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    preview.size_flags_vertical = Control.SIZE_EXPAND_FILL
    preview_column.add_child(preview)
    preview_text = Label.new()
    preview_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    preview_text.add_theme_font_size_override("font_size", 14 if narrow else 15)
    preview_text.add_theme_color_override("font_color", Color("#c8d0d8"))
    preview_column.add_child(preview_text)

    if narrow:
        body.add_child(preview_column)
    else:
        body.add_child(preview_column)

    var footer: Container = VBoxContainer.new() if narrow else HBoxContainer.new()
    footer.add_theme_constant_override("separation", 8)
    outer.add_child(footer)

    status_label = Label.new()
    status_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    status_label.custom_minimum_size = Vector2(0, 34)
    status_label.add_theme_font_size_override("font_size", 13 if narrow else 15)
    footer.add_child(status_label)

    var button_row := HBoxContainer.new()
    button_row.add_theme_constant_override("separation", 10)
    button_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    footer.add_child(button_row)
    var back_button := _make_button("BACK", 0 if narrow else 170)
    back_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL if narrow else Control.SIZE_SHRINK_BEGIN
    back_button.pressed.connect(_on_back)
    button_row.add_child(back_button)
    confirm_button = _make_button("BEGIN CHRONICLE", 0 if narrow else 250)
    confirm_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL if narrow else Control.SIZE_SHRINK_BEGIN
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
        preview_text.text = "%s\n%s presentation · %s build\n%s · %s\nWeapon: %s\nTemperament: %s\nOrigin: %s\nBonuses: %s / %s" % [
            str(profile.get("name", "")), str(profile.get("presentation", "")).capitalize(),
            str(profile.get("build", "")).capitalize(), str(origin.get("name", "")),
            str(discipline.get("name", "")), str(profile.get("weapon_preference", "")).capitalize(),
            str(temperament.get("name", "")), str(origin.get("description", "")), origin_bonus, temperament_bonus
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
