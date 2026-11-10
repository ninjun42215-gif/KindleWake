extends Control
## Post-escape arrival at Kaer Sethorn. The first keep priority is a persistent campaign decision.

const OpeningChapter = preload("res://scripts/core/opening_chapter_system.gd")

var body_label: Label
var status_label: Label
var choice_box: VBoxContainer
var continue_button: Button
var chosen := ""

func _ready() -> void:
    if not OpeningChapter.arrival_unlocked(GameState.world_flags):
        get_tree().change_scene_to_file("res://Escape.tscn")
        return
    _build()
    _show_intro()

func _build() -> void:
    var bg := ColorRect.new()
    bg.color = Color("#10191b")
    bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    add_child(bg)

    var margin := MarginContainer.new()
    margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    margin.add_theme_constant_override("margin_left", 24)
    margin.add_theme_constant_override("margin_right", 24)
    margin.add_theme_constant_override("margin_top", 20)
    margin.add_theme_constant_override("margin_bottom", 20)
    add_child(margin)

    var column := VBoxContainer.new()
    column.add_theme_constant_override("separation", 14)
    margin.add_child(column)

    status_label = Label.new()
    status_label.text = "CHAPTER I  /  COLD HEARTH"
    status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    status_label.add_theme_color_override("font_color", Color("#d9b879"))
    status_label.add_theme_font_size_override("font_size", 18)
    column.add_child(status_label)

    var spacer := Control.new()
    spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
    column.add_child(spacer)

    var panel := PanelContainer.new()
    var style := StyleBoxFlat.new()
    style.bg_color = Color("#172329")
    style.border_color = Color("#a17d4b")
    style.set_border_width_all(2)
    style.set_corner_radius_all(8)
    style.set_content_margin_all(22)
    panel.add_theme_stylebox_override("panel", style)
    column.add_child(panel)

    var content := VBoxContainer.new()
    content.add_theme_constant_override("separation", 14)
    panel.add_child(content)

    var heading := Label.new()
    heading.text = "KAER SETHORN"
    heading.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    heading.add_theme_color_override("font_color", Color("#e4c58a"))
    heading.add_theme_font_size_override("font_size", 26)
    content.add_child(heading)

    body_label = Label.new()
    body_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    body_label.custom_minimum_size = Vector2(0, 150)
    body_label.add_theme_color_override("font_color", Color("#eee7d9"))
    body_label.add_theme_font_size_override("font_size", 18)
    content.add_child(body_label)

    choice_box = VBoxContainer.new()
    choice_box.add_theme_constant_override("separation", 8)
    content.add_child(choice_box)

    continue_button = Button.new()
    continue_button.text = "BEGIN THE SETHMARCH"
    continue_button.custom_minimum_size = Vector2(0, 58)
    continue_button.add_theme_font_size_override("font_size", 18)
    continue_button.pressed.connect(_enter_world)
    continue_button.visible = false
    content.add_child(continue_button)

    var foot := Label.new()
    foot.text = "THE KEEP IS NOT A KINGDOM. IT IS A PROMISE THAT MUST BE KEPT."
    foot.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    foot.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    foot.add_theme_color_override("font_color", Color("#aeb9bd"))
    column.add_child(foot)

func _show_intro() -> void:
    var people := bool(GameState.world_flags.get("prologue_people_saved", false))
    var record := bool(GameState.world_flags.get("prologue_record_saved", false))
    var outcome := "The servants who survived gather beneath the gatehouse." if people else "The gatehouse is quiet; the names of those lost travel with you."
    var evidence := " Sela carries the sealed household record." if record else " The record is gone, but Wystan has memorized fragments of its testimony."
    body_label.text = "Rain follows the company into Kaer Sethorn. The keep's outer wall still stands, though weeds split the yard stones and the well has been sealed for years. " + outcome + evidence + "\n\nBram looks toward the empty watchtower. “We can mourn when the roof stops leaking. What do we save first?”"
    _add_choice("Repair the blocked well — secure clean water.", "repair_well")
    _add_choice("Secure the roof — shelter the wounded and the company.", "secure_roof")
    _add_choice("Organize the household ledger — learn our stores and missing names.", "organize_ledger")

func _add_choice(label: String, choice_id: String) -> void:
    var button := Button.new()
    button.text = label
    button.custom_minimum_size = Vector2(0, 54)
    button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    button.add_theme_font_size_override("font_size", 16)
    button.pressed.connect(_choose.bind(choice_id))
    choice_box.add_child(button)

func _choose(choice_id: String) -> void:
    if chosen != "":
        return
    var next_flags: Dictionary = OpeningChapter.apply_arrival_choice(GameState.world_flags, choice_id)
    if next_flags.is_empty():
        return
    chosen = choice_id
    GameState.world_flags = next_flags
    for child in choice_box.get_children():
        child.queue_free()
    body_label.text += "\n\n" + OpeningChapter.priority_acknowledgement(choice_id) + "\n\nThis priority is recorded in your chronicle. Other needs remain unresolved and can be addressed as the keep develops."
    status_label.text = "FIRST KEEP PRIORITY RECORDED"
    continue_button.visible = true
    GameState.save_campaign("auto_a")

func _enter_world() -> void:
    if chosen == "":
        return
    GameState.world_pos = Vector2.ZERO
    GameState.from_world = true
    GameState.save_campaign("auto_a")
    get_tree().change_scene_to_file("res://World.tscn")
