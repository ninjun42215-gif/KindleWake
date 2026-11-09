extends Control
## First playable narrative beat: the burning east gallery and the player's first consequential choice.

const Prologue = preload("res://scripts/core/prologue_system.gd")

var choice_buttons: VBoxContainer
var body_label: Label
var speaker_label: Label
var continue_button: Button
var selected_choice: String = ""

func _ready() -> void:
    _build()
    _show_opening()

func _build() -> void:
    var backdrop := ColorRect.new()
    backdrop.color = Color("#090e14")
    backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    add_child(backdrop)

    var art := TextureRect.new()
    art.texture = load("res://assets/art/ui/title_illustration.svg")
    art.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
    art.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
    art.modulate = Color(0.38, 0.29, 0.24, 0.48)
    art.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    art.mouse_filter = Control.MOUSE_FILTER_IGNORE
    add_child(art)

    var shade := ColorRect.new()
    shade.color = Color(0.025, 0.035, 0.045, 0.62)
    shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
    add_child(shade)

    var safe := MarginContainer.new()
    safe.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    safe.add_theme_constant_override("margin_left", 24)
    safe.add_theme_constant_override("margin_right", 24)
    safe.add_theme_constant_override("margin_top", 20)
    safe.add_theme_constant_override("margin_bottom", 20)
    add_child(safe)

    var column := VBoxContainer.new()
    column.add_theme_constant_override("separation", 12)
    safe.add_child(column)

    var chapter := Label.new()
    chapter.text = "PROLOGUE  /  SMOKE ON THE WIND"
    chapter.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    chapter.add_theme_font_size_override("font_size", 18)
    chapter.add_theme_color_override("font_color", Color("#d9b879"))
    column.add_child(chapter)

    var spacer := Control.new()
    spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
    column.add_child(spacer)

    var panel := PanelContainer.new()
    panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    var style := StyleBoxFlat.new()
    style.bg_color = Color(0.055, 0.075, 0.09, 0.96)
    style.border_color = Color("#a17d4b")
    style.set_border_width_all(2)
    style.set_corner_radius_all(8)
    style.content_margin_left = 22
    style.content_margin_right = 22
    style.content_margin_top = 18
    style.content_margin_bottom = 18
    panel.add_theme_stylebox_override("panel", style)
    column.add_child(panel)

    var content := VBoxContainer.new()
    content.add_theme_constant_override("separation", 12)
    panel.add_child(content)

    speaker_label = Label.new()
    speaker_label.add_theme_font_size_override("font_size", 22)
    speaker_label.add_theme_color_override("font_color", Color("#e4c58a"))
    content.add_child(speaker_label)

    body_label = Label.new()
    body_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    body_label.custom_minimum_size = Vector2(0, 116)
    body_label.add_theme_font_size_override("font_size", 19)
    body_label.add_theme_color_override("font_color", Color("#eee7d9"))
    content.add_child(body_label)

    choice_buttons = VBoxContainer.new()
    choice_buttons.add_theme_constant_override("separation", 8)
    content.add_child(choice_buttons)

    continue_button = Button.new()
    continue_button.text = "CONTINUE TO THE SETHMARCH"
    continue_button.custom_minimum_size = Vector2(0, 58)
    continue_button.add_theme_font_size_override("font_size", 18)
    continue_button.pressed.connect(_enter_world)
    content.add_child(continue_button)
    continue_button.visible = false

    var footer := Label.new()
    footer.text = "Your choices become part of this chronicle."
    footer.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    footer.add_theme_color_override("font_color", Color("#aeb9bd"))
    column.add_child(footer)

func _show_opening() -> void:
    speaker_label.text = "THE EAST GALLERY"
    body_label.text = "The roof is burning. Rain strikes the stained-glass oath window. Beyond the smoke, the west stair collapses. Somewhere behind the archive door, people are calling for help. On the table lies the sealed household record — the only proof that Edmer did not betray the Covenant."
    _add_line("Bram Vosk", "The west stair is gone. We have one clean passage, and it is closing.")
    _add_line("Sela Wrenfield", "Not clean. There are people behind the archive door.")
    _add_line("Brother Wystan", "And the household record. If it burns, Edmer dies a traitor in every telling.")
    _add_line("Bram Vosk", "The living are asking us to choose.")
    _show_choices()

func _add_line(speaker: String, line: String) -> void:
    body_label.text += "\n\n%s: “%s”" % [speaker, line]

func _show_choices() -> void:
    _clear_choices()
    _add_choice("Get the people out. The record can wait.", "rescue_people")
    _add_choice("Take the record. We need the truth.", "recover_record")
    _add_choice("Split. No one gets left if we move together.", "split_company")

func _add_choice(label: String, choice_id: String) -> void:
    var button := Button.new()
    button.text = label
    button.custom_minimum_size = Vector2(0, 58)
    button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    button.add_theme_font_size_override("font_size", 17)
    button.pressed.connect(_choose.bind(choice_id))
    choice_buttons.add_child(button)

func _clear_choices() -> void:
    for child in choice_buttons.get_children():
        child.queue_free()

func _choose(choice_id: String) -> void:
    if not Prologue.CHOICES.has(choice_id):
        return
    selected_choice = choice_id
    GameState.world_flags = Prologue.apply_choice(GameState.world_flags, choice_id)
    _clear_choices()
    speaker_label.text = "THE ESCAPE"
    match choice_id:
        "rescue_people":
            body_label.text = "Bram shoulders the archive door while Sela guides the household servants through the rain. The record blackens on the table. No one cheers. The people you carried out will remember who came back for them."
        "recover_record":
            body_label.text = "Sela wraps the household record beneath her cloak. The company escapes with the evidence, but the archive corridor disappears behind a wall of flame. The silence that follows is heavier than the rain."
        "split_company":
            body_label.text = "Bram and Sela divide the work. Wystan holds the passage while the servants and the sealed record are carried through together. The company emerges scattered, soaked and shaken — but neither the living nor the truth was abandoned."
    continue_button.visible = true
    GameState.save_campaign("auto_a")

func _enter_world() -> void:
    if selected_choice == "":
        return
    GameState.world_pos = Vector2.ZERO
    GameState.from_world = true
    GameState.save_campaign("auto_a")
    get_tree().change_scene_to_file("res://World.tscn")
