extends Control
## Campaign-scale atlas. Original vector continent silhouettes; regional exploration remains in World.tscn.
const WORLD_SCENE := "res://World.tscn"
const SELECTED_GOLD := Color("#f0cf88")
var selected_index: int = 0
var continent_buttons: Array[Button] = []
var detail_title: Label
var detail_epithet: Label
var detail_text: Label
var detail_status: Label
var detail_locations: Label

func _ready() -> void:
    _build_interface()
    var atlas: Array = GameData.continents.get("continents", [])
    for i in range(atlas.size()):
        if str((atlas[i] as Dictionary).get("id", "")) == str(GameData.continents.get("current_continent", "eldrimar")):
            selected_index = i
            break
    _refresh_selection()
    queue_redraw()

func _build_interface() -> void:
    var background := ColorRect.new()
    background.color = Color("#101c25")
    background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    background.mouse_filter = Control.MOUSE_FILTER_IGNORE
    add_child(background)
    var header := Label.new()
    header.text = "THE SEVENFOLD WORLD"
    header.position = Vector2(28, 18)
    header.add_theme_font_size_override("font_size", 32)
    header.add_theme_color_override("font_color", Color("#ead5a5"))
    add_child(header)
    var subtitle := Label.new()
    subtitle.text = "ELDRIMAR AND THE SIX GREAT CONTINENTS BEYOND"
    subtitle.position = Vector2(30, 56)
    subtitle.add_theme_font_size_override("font_size", 13)
    subtitle.add_theme_color_override("font_color", Color("#9eb3b9"))
    add_child(subtitle)
    var back := Button.new()
    back.text = "RETURN TO FRONTIER"
    back.custom_minimum_size = Vector2(210, 48)
    back.position = Vector2(28, 104)
    back.pressed.connect(_return_to_world)
    add_child(back)
    var side := PanelContainer.new()
    side.anchor_left = 0.69
    side.anchor_top = 0.04
    side.anchor_right = 0.98
    side.anchor_bottom = 0.96
    var style := StyleBoxFlat.new()
    style.bg_color = Color("#1d2c33")
    style.border_color = Color("#776747")
    style.set_border_width_all(2)
    style.set_corner_radius_all(8)
    style.set_content_margin_all(14)
    side.add_theme_stylebox_override("panel", style)
    add_child(side)
    var column := VBoxContainer.new()
    column.add_theme_constant_override("separation", 9)
    side.add_child(column)
    detail_title = Label.new()
    detail_title.add_theme_font_size_override("font_size", 26)
    detail_title.add_theme_color_override("font_color", Color("#f0d49a"))
    detail_title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    column.add_child(detail_title)
    detail_epithet = Label.new()
    detail_epithet.add_theme_font_size_override("font_size", 16)
    detail_epithet.add_theme_color_override("font_color", Color("#8fc0bd"))
    detail_epithet.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    column.add_child(detail_epithet)
    detail_status = Label.new()
    detail_status.add_theme_font_size_override("font_size", 13)
    column.add_child(detail_status)
    column.add_child(HSeparator.new())
    detail_text = Label.new()
    detail_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    detail_text.size_flags_vertical = Control.SIZE_EXPAND_FILL
    detail_text.add_theme_font_size_override("font_size", 15)
    column.add_child(detail_text)
    detail_locations = Label.new()
    detail_locations.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    detail_locations.add_theme_font_size_override("font_size", 14)
    detail_locations.add_theme_color_override("font_color", Color("#e2c58b"))
    column.add_child(detail_locations)
    var route_note := Label.new()
    route_note.text = "Study each continent's people, conflicts and routes. New regions become reachable through campaign decisions."
    route_note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    route_note.add_theme_font_size_override("font_size", 12)
    route_note.add_theme_color_override("font_color", Color("#a8b5b7"))
    column.add_child(route_note)
    var scroll := ScrollContainer.new()
    scroll.custom_minimum_size = Vector2(0, 190)
    scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
    column.add_child(scroll)
    var list := VBoxContainer.new()
    list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    list.add_theme_constant_override("separation", 5)
    scroll.add_child(list)
    var atlas: Array = GameData.continents.get("continents", [])
    for i in range(atlas.size()):
        var continent: Dictionary = atlas[i]
        var button := Button.new()
        button.text = "%02d   %s" % [i + 1, str(continent.get("name", "Unknown"))]
        button.custom_minimum_size = Vector2(0, 42)
        button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        button.pressed.connect(_select_continent.bind(i))
        list.add_child(button)
        continent_buttons.append(button)

func _select_continent(index: int) -> void:
    var atlas: Array = GameData.continents.get("continents", [])
    if atlas.is_empty():
        return
    selected_index = clampi(index, 0, atlas.size() - 1)
    _refresh_selection()
    queue_redraw()

func _refresh_selection() -> void:
    var atlas: Array = GameData.continents.get("continents", [])
    if atlas.is_empty():
        detail_title.text = "Atlas unavailable"
        detail_text.text = "The continent records could not be loaded."
        return
    var continent: Dictionary = atlas[selected_index]
    var is_current := bool(continent.get("current", false))
    var unlock_flag := str(continent.get("travel_unlock_flag", ""))
    var unlocked := is_current or (unlock_flag != "" and bool(GameState.world_flags.get(unlock_flag, false)))
    detail_title.text = str(continent.get("name", "Unknown"))
    detail_epithet.text = str(continent.get("epithet", ""))
    detail_status.text = "CURRENT FRONTIER" if is_current else ("ROUTE CHARTED" if unlocked else "UNREACHED — STORY ROUTE SEALED")
    detail_status.add_theme_color_override("font_color", Color("#9bc49d") if unlocked else Color("#d69a79"))
    detail_text.text = "%s\n\nCapital: %s\nRuling power: %s\nClimate: %s\n\nConflict: %s\n\nCampaign thread: %s" % [
        str(continent.get("identity", "")), str(continent.get("capital", "Unknown")),
        str(continent.get("ruling_power", "Unknown")), str(continent.get("climate", "Unknown")),
        str(continent.get("conflict", "")), str(continent.get("campaign_hook", ""))
    ]
    detail_locations.text = "SIGNATURE PLACES\n" + "  •  ".join(continent.get("signature_locations", []))
    for i in range(continent_buttons.size()):
        continent_buttons[i].add_theme_color_override("font_color", SELECTED_GOLD if i == selected_index else Color("#d6ded9"))
        continent_buttons[i].add_theme_color_override("font_hover_color", Color("#fff0c8"))

func _draw() -> void:
    var atlas: Array = GameData.continents.get("continents", [])
    var rect := Rect2(size.x * 0.025, size.y * 0.19, size.x * 0.625, size.y * 0.75)
    draw_rect(rect, Color("#132630"), true)
    for i in range(1, 9):
        var x := rect.position.x + rect.size.x * float(i) / 9.0
        draw_line(Vector2(x, rect.position.y), Vector2(x, rect.end.y), Color(0.55, 0.72, 0.75, 0.10), 1.0)
    for i in range(1, 6):
        var y := rect.position.y + rect.size.y * float(i) / 6.0
        draw_line(Vector2(rect.position.x, y), Vector2(rect.end.x, y), Color(0.55, 0.72, 0.75, 0.10), 1.0)
    draw_rect(rect, Color("#6f9ba0"), false, 2.0)
    for i in range(atlas.size()):
        var continent: Dictionary = atlas[i]
        var points := PackedVector2Array()
        for point in continent.get("map_shape", []):
            var pair: Array = point
            if pair.size() >= 2:
                points.append(rect.position + Vector2(float(pair[0]), float(pair[1])) * rect.size)
        if points.size() < 3:
            continue
        var color := Color(str(continent.get("map_color", "#82958a")))
        var selected := i == selected_index
        draw_colored_polygon(points, color.lightened(0.12) if selected else color.darkened(0.12))
        var outline := points.duplicate()
        outline.append(points[0])
        draw_polyline(outline, SELECTED_GOLD if selected else Color("#aab7a6"), 3.0 if selected else 1.5, true)
        var label_pair: Array = continent.get("map_label", [0.5, 0.5])
        if label_pair.size() >= 2:
            var label_pos := rect.position + Vector2(float(label_pair[0]), float(label_pair[1])) * rect.size
            draw_string(ThemeDB.fallback_font, label_pos - Vector2(42, -4), str(continent.get("name", "")), HORIZONTAL_ALIGNMENT_CENTER, 112, 16, Color("#102029"), 5)
            draw_string(ThemeDB.fallback_font, label_pos - Vector2(42, -5), str(continent.get("name", "")), HORIZONTAL_ALIGNMENT_CENTER, 112, 16, Color("#fff0cf"), 4)
    draw_string(ThemeDB.fallback_font, Vector2(rect.position.x + 16, rect.end.y - 18), "THE KNOWN WORLD  •  SEVEN CONTINENTS", HORIZONTAL_ALIGNMENT_LEFT, rect.size.x - 32, 14, Color("#b9d0cb"))

func _return_to_world() -> void:
    get_tree().change_scene_to_file(WORLD_SCENE)
