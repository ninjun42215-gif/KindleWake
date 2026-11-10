extends Control
## Opening cinematic: the wrong bell at Dunmarrow. Leads into the existing playable prologue.

var title_label: Label
var body_label: Label
var progress_label: Label
var next_button: Button
var page := 0

const PAGES := [
    {
        "title": "THE WRONG BELL",
        "body": "The first bell rings before dawn. It is not the hour bell. It is the old warning: three hard strokes, a pause, then one more. At Dunmarrow, every servant knows what it means. Someone has opened the outer gate."
    },
    {
        "title": "A HOUSE UNDER ASH",
        "body": "Torren wakes to smoke crawling beneath the chamber door. Boots cross the gallery below. A voice calls for the household seal; another answers with the name of Edmer Dunmarrow. The Covenant has come before the city watch."
    },
    {
        "title": "NO SAFE CORRIDOR",
        "body": "Bram Vosk reaches the landing first, shield split and one sleeve dark with blood. Sela Wrenfield has found the archive key. Brother Wystan is already leading the servants away from the west stair. The east gallery is burning, and the household record is still inside."
    },
    {
        "title": "THE LAST WAY OUT",
        "body": "Beyond the rain-streaked oath window, the postern road falls toward the Sallow Marches. If the company reaches it, the truth may survive. If it does not, the Covenant will write the only account anyone is allowed to remember."
    }
]

func _ready() -> void:
    GameState.world_flags["wrong_bell_seen"] = true
    _build()
    _show_page()

func _build() -> void:
    var bg := ColorRect.new()
    bg.color = Color("#090e14")
    bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    add_child(bg)

    var art := TextureRect.new()
    art.texture = load("res://assets/art/ui/title_illustration.svg")
    art.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
    art.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
    art.modulate = Color(0.34, 0.25, 0.20, 0.55)
    art.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    art.mouse_filter = Control.MOUSE_FILTER_IGNORE
    add_child(art)

    var shade := ColorRect.new()
    shade.color = Color(0.02, 0.03, 0.04, 0.68)
    shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
    add_child(shade)

    var margin := MarginContainer.new()
    margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    margin.add_theme_constant_override("margin_left", 24)
    margin.add_theme_constant_override("margin_right", 24)
    margin.add_theme_constant_override("margin_top", 24)
    margin.add_theme_constant_override("margin_bottom", 24)
    add_child(margin)

    var column := VBoxContainer.new()
    column.add_theme_constant_override("separation", 16)
    margin.add_child(column)

    progress_label = Label.new()
    progress_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    progress_label.add_theme_color_override("font_color", Color("#d9b879"))
    progress_label.add_theme_font_size_override("font_size", 16)
    column.add_child(progress_label)

    var spacer := Control.new()
    spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
    column.add_child(spacer)

    var panel := PanelContainer.new()
    var style := StyleBoxFlat.new()
    style.bg_color = Color(0.045, 0.065, 0.08, 0.97)
    style.border_color = Color("#a17d4b")
    style.set_border_width_all(2)
    style.set_corner_radius_all(8)
    style.set_content_margin_all(24)
    panel.add_theme_stylebox_override("panel", style)
    column.add_child(panel)

    var copy := VBoxContainer.new()
    copy.add_theme_constant_override("separation", 18)
    panel.add_child(copy)

    title_label = Label.new()
    title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    title_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    title_label.add_theme_color_override("font_color", Color("#e4c58a"))
    title_label.add_theme_font_size_override("font_size", 27)
    copy.add_child(title_label)

    body_label = Label.new()
    body_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    body_label.custom_minimum_size = Vector2(0, 180)
    body_label.add_theme_color_override("font_color", Color("#eee7d9"))
    body_label.add_theme_font_size_override("font_size", 20)
    copy.add_child(body_label)

    next_button = Button.new()
    next_button.custom_minimum_size = Vector2(0, 60)
    next_button.add_theme_font_size_override("font_size", 19)
    next_button.pressed.connect(_advance)
    copy.add_child(next_button)

    var foot := Label.new()
    foot.text = "DUNMARROW  •  THE NIGHT THE RECORDS BURNED"
    foot.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    foot.add_theme_color_override("font_color", Color("#aeb9bd"))
    column.add_child(foot)

func _show_page() -> void:
    var entry: Dictionary = PAGES[page]
    title_label.text = str(entry["title"])
    body_label.text = str(entry["body"])
    progress_label.text = "PROLOGUE  •  %d / %d" % [page + 1, PAGES.size()]
    next_button.text = "ENTER THE EAST GALLERY" if page == PAGES.size() - 1 else "CONTINUE"

func _advance() -> void:
    if page < PAGES.size() - 1:
        page += 1
        _show_page()
        return
    GameState.save_campaign("auto_a")
    get_tree().change_scene_to_file("res://Prologue.tscn")
