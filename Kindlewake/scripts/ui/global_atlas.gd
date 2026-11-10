extends Control
## Campaign-scale atlas. Original vector continent silhouettes; regional exploration remains in World.tscn.
const WORLD_SCENE := "res://World.tscn"
const FactionSystem = preload("res://scripts/core/faction_system.gd")
const SELECTED_GOLD := Color("#f0cf88")
var selected_index: int = 0
var continent_buttons: Array[Button] = []
var detail_title: Label
var detail_epithet: Label
var detail_text: Label
var detail_status: Label
var detail_locations: Label
var detail_action_btn: Button
var diplomacy_panel: PanelContainer
var diplomacy_body: VBoxContainer
var diplomacy_feedback: Label

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
    detail_action_btn = Button.new()
    detail_action_btn.custom_minimum_size = Vector2(0, 50)
    detail_action_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    detail_action_btn.pressed.connect(_travel_to_selected)
    column.add_child(detail_action_btn)
    var diplomacy_button := Button.new()
    diplomacy_button.text = "OPEN DIPLOMACY LEDGER"
    diplomacy_button.custom_minimum_size = Vector2(0, 46)
    diplomacy_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    diplomacy_button.pressed.connect(_open_diplomacy)
    column.add_child(diplomacy_button)
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
    _build_diplomacy_panel()


func _build_diplomacy_panel() -> void:
    diplomacy_panel = PanelContainer.new()
    diplomacy_panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    diplomacy_panel.offset_left = 34
    diplomacy_panel.offset_top = 30
    diplomacy_panel.offset_right = -34
    diplomacy_panel.offset_bottom = -30
    diplomacy_panel.z_index = 20
    diplomacy_panel.visible = false
    var style := StyleBoxFlat.new()
    style.bg_color = Color("#172832")
    style.border_color = Color("#d2b77d")
    style.set_border_width_all(2)
    style.set_corner_radius_all(10)
    style.set_content_margin_all(18)
    diplomacy_panel.add_theme_stylebox_override("panel", style)
    add_child(diplomacy_panel)
    var shell := VBoxContainer.new()
    shell.add_theme_constant_override("separation", 10)
    diplomacy_panel.add_child(shell)
    var header := HBoxContainer.new()
    shell.add_child(header)
    var title := Label.new()
    title.text = "CAMPAIGN DIPLOMACY & TERRITORIES"
    title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    title.add_theme_font_size_override("font_size", 23)
    title.add_theme_color_override("font_color", Color("#f0d49a"))
    header.add_child(title)
    var close := Button.new()
    close.text = "CLOSE"
    close.custom_minimum_size = Vector2(100, 42)
    close.pressed.connect(_close_diplomacy)
    header.add_child(close)
    var intro := Label.new()
    intro.text = "Standing is measured against House Dunmarrow. Relations change through authored campaign choices; alliances require %d relation and cannot be forced during war." % FactionSystem.ALLIANCE_THRESHOLD
    intro.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    intro.add_theme_color_override("font_color", Color("#b7c6c3"))
    shell.add_child(intro)
    diplomacy_feedback = Label.new()
    diplomacy_feedback.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    diplomacy_feedback.add_theme_color_override("font_color", Color("#e2c58b"))
    shell.add_child(diplomacy_feedback)
    var scroll := ScrollContainer.new()
    scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
    shell.add_child(scroll)
    diplomacy_body = VBoxContainer.new()
    diplomacy_body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    diplomacy_body.add_theme_constant_override("separation", 8)
    scroll.add_child(diplomacy_body)


func _open_diplomacy() -> void:
    _refresh_diplomacy()
    diplomacy_panel.visible = true


func _close_diplomacy() -> void:
    diplomacy_panel.visible = false


func _refresh_diplomacy() -> void:
    for child in diplomacy_body.get_children():
        diplomacy_body.remove_child(child)
        child.queue_free()
    var definitions: Dictionary = GameData.factions
    var player_faction := "house_dunmarrow"
    var territories: Dictionary = GameState.faction_state.get("territories", {})
    var faction_names: Dictionary = {}
    for entry in definitions.get("factions", []):
        var faction: Dictionary = entry
        faction_names[str(faction.get("id", ""))] = str(faction.get("name", faction.get("id", "Unknown")))
    for entry in definitions.get("factions", []):
        var faction: Dictionary = entry
        var faction_id := str(faction.get("id", ""))
        if faction_id == "" or faction_id == player_faction:
            continue
        var standing := FactionSystem.relation(GameState.faction_state, player_faction, faction_id)
        var pair_key := _faction_pair_key(player_faction, faction_id)
        var diplomatic_state := str(GameState.faction_state.get("diplomacy", {}).get(pair_key, "neutral"))
        var card := PanelContainer.new()
        var card_style := StyleBoxFlat.new()
        card_style.bg_color = Color("#21343c")
        card_style.border_color = Color("#596d6d")
        card_style.set_border_width_all(1)
        card_style.set_corner_radius_all(6)
        card_style.set_content_margin_all(10)
        card.add_theme_stylebox_override("panel", card_style)
        diplomacy_body.add_child(card)
        var column := VBoxContainer.new()
        column.add_theme_constant_override("separation", 4)
        card.add_child(column)
        var heading := Label.new()
        heading.text = "%s  ·  %s" % [str(faction.get("name", faction_id)), str(faction.get("continent", "unknown")).capitalize()]
        heading.add_theme_font_size_override("font_size", 17)
        heading.add_theme_color_override("font_color", Color("#f0d49a"))
        column.add_child(heading)
        var standing_label := Label.new()
        standing_label.text = "Standing: %s (%+d)     Treaty: %s" % [FactionSystem.relation_label(standing), standing, diplomatic_state.replace("_", " ").capitalize()]
        standing_label.add_theme_color_override("font_color", Color("#b9d0cb"))
        column.add_child(standing_label)
        var owned_regions: Array[String] = []
        for continent_entry in GameData.continents.get("continents", []):
            var continent: Dictionary = continent_entry
            for region_entry in continent.get("regions", []):
                var region: Dictionary = region_entry
                var region_id := str(region.get("id", ""))
                if str(territories.get(region_id, {}).get("owner", "")) == faction_id:
                    owned_regions.append(str(region.get("name", region_id)))
        var territory_label := Label.new()
        territory_label.text = "Territories (%d): %s" % [owned_regions.size(), ", ".join(owned_regions) if not owned_regions.is_empty() else "No recognized territory"]
        territory_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
        territory_label.add_theme_font_size_override("font_size", 13)
        territory_label.add_theme_color_override("font_color", Color("#d3ddd6"))
        column.add_child(territory_label)
        if diplomatic_state == "alliance":
            var allied := Label.new()
            allied.text = "Alliance established"
            allied.add_theme_color_override("font_color", Color("#9bc49d"))
            column.add_child(allied)
        elif FactionSystem.can_propose_alliance(GameState.faction_state, player_faction, faction_id):
            var propose := Button.new()
            propose.text = "PROPOSE ALLIANCE"
            propose.custom_minimum_size = Vector2(0, 38)
            propose.pressed.connect(_propose_alliance.bind(faction_id))
            column.add_child(propose)
        elif diplomatic_state == "war":
            var war_label := Label.new()
            war_label.text = "A formal state of war prevents an alliance proposal."
            war_label.add_theme_color_override("font_color", Color("#d69a79"))
            column.add_child(war_label)
        else:
            var threshold_label := Label.new()
            threshold_label.text = "Alliance threshold: %d relation" % FactionSystem.ALLIANCE_THRESHOLD
            threshold_label.add_theme_font_size_override("font_size", 12)
            threshold_label.add_theme_color_override("font_color", Color("#9aaeb0"))
            column.add_child(threshold_label)
    var history_heading := Label.new()
    history_heading.text = "RECENT DIPLOMATIC HISTORY"
    history_heading.add_theme_font_size_override("font_size", 18)
    history_heading.add_theme_color_override("font_color", Color("#f0d49a"))
    diplomacy_body.add_child(history_heading)
    var history: Array = GameState.faction_state.get("history", [])
    if history.is_empty():
        var empty := Label.new()
        empty.text = "No treaties, diplomatic shifts or territorial changes have been recorded yet."
        empty.add_theme_color_override("font_color", Color("#b7c6c3"))
        diplomacy_body.add_child(empty)
    else:
        var first_recent := maxi(0, history.size() - 8)
        for index in range(history.size() - 1, first_recent - 1, -1):
            var event: Dictionary = history[index]
            var line := Label.new()
            line.text = _describe_diplomatic_event(event, faction_names)
            line.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
            line.add_theme_font_size_override("font_size", 13)
            diplomacy_body.add_child(line)


func _propose_alliance(faction_id: String) -> void:
    if GameState.set_faction_diplomacy("house_dunmarrow", faction_id, "alliance"):
        GameState.save_campaign("auto_a")
        diplomacy_feedback.text = "Alliance recorded with %s." % _faction_name(faction_id)
        _refresh_diplomacy()
    else:
        diplomacy_feedback.text = "The alliance threshold or current diplomatic state does not permit this proposal."
        _refresh_diplomacy()


func _faction_pair_key(faction_a: String, faction_b: String) -> String:
    var pair: Array[String] = [faction_a, faction_b]
    pair.sort()
    return pair[0] + "|" + pair[1]


func _faction_name(faction_id: String) -> String:
    for entry in GameData.factions.get("factions", []):
        var faction: Dictionary = entry
        if str(faction.get("id", "")) == faction_id:
            return str(faction.get("name", faction_id))
    return faction_id


func _describe_diplomatic_event(event: Dictionary, faction_names: Dictionary) -> String:
    var kind := str(event.get("kind", ""))
    if kind == "relation":
        var relation_pair: Array = event.get("factions", [])
        if relation_pair.size() >= 2:
            return "%s / %s: relation %s (%s)" % [str(faction_names.get(str(relation_pair[0]), relation_pair[0])), str(faction_names.get(str(relation_pair[1]), relation_pair[1])), str(event.get("value", 0)), str(event.get("reason", "campaign event"))]
    elif kind == "diplomacy":
        var diplomacy_pair: Array = event.get("factions", [])
        if diplomacy_pair.size() >= 2:
            return "%s / %s: %s" % [str(faction_names.get(str(diplomacy_pair[0]), diplomacy_pair[0])), str(faction_names.get(str(diplomacy_pair[1]), diplomacy_pair[1])), str(event.get("state", "neutral")).replace("_", " ").capitalize()]
    elif kind == "territory":
        return "%s transferred from %s to %s (%s)" % [str(event.get("region", "Unknown region")).replace("_", " ").capitalize(), str(faction_names.get(str(event.get("from", "")), event.get("from", ""))), str(faction_names.get(str(event.get("to", "")), event.get("to", ""))), str(event.get("cause", "campaign outcome"))]
    return "A diplomatic event was recorded."


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
    var unlock_flag := str(continent.get("unlock", ""))
    var unlocked := is_current or (unlock_flag != "" and bool(GameState.world_flags.get(unlock_flag, false)))
    detail_title.text = str(continent.get("name", "Unknown"))
    detail_epithet.text = str(continent.get("epithet", ""))
    detail_status.text = "CURRENT FRONTIER" if is_current else ("ROUTE CHARTED" if unlocked else "STORY ROUTE: " + str(continent.get("unlock", "unavailable")).replace("_", " ").to_upper())
    detail_status.add_theme_color_override("font_color", Color("#9bc49d") if unlocked else Color("#d69a79"))
    detail_text.text = "%s\n\nCapital: %s\nRuling power: %s\nClimate: %s\n\nConflict: %s\n\nCampaign thread: %s" % [
        str(continent.get("identity", "")), str(continent.get("capital", "Unknown")),
        str(continent.get("ruling_power", "Unknown")), str(continent.get("climate", "Unknown")),
        str(continent.get("conflict", "")), str(continent.get("campaign_hook", ""))
    ]
    detail_locations.text = "SIGNATURE PLACES\n" + "  •  ".join(continent.get("signature_locations", []))
    detail_action_btn.visible = false
    if str(continent.get("id", "")) == "thalassar" and unlocked:
        detail_action_btn.text = "SAIL TO BRINEGATE COAST"
        detail_action_btn.visible = true
    elif str(continent.get("id", "")) == "eldrimar":
        detail_action_btn.text = "RETURN TO SETHMARCH FRONTIER"
        detail_action_btn.visible = true
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

func _travel_to_selected() -> void:
    var atlas: Array = GameData.continents.get("continents", [])
    if selected_index < 0 or selected_index >= atlas.size():
        return
    var continent: Dictionary = atlas[selected_index]
    var cid: String = str(continent.get("id", ""))
    if cid == "thalassar" and bool(GameState.world_flags.get("chapter_2_sea_passage", false)):
        GameState.set_active_region("brinegate_coast")
    elif cid == "eldrimar":
        GameState.set_active_region("sethmarch")
    else:
        return
    GameState.save_campaign("auto_a")
    get_tree().change_scene_to_file(WORLD_SCENE)


func _return_to_world() -> void:
    get_tree().change_scene_to_file(WORLD_SCENE)
