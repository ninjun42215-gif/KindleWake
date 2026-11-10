class_name EmpireScreen
extends Control
## Campaign-facing management screen for already claimed locations.
## Captures remain governed by authored world objectives; this screen never claims remote holdings.

signal closed

const Economy = preload("res://scripts/core/empire_economy_system.gd")
const HOLDING = "house_dunmarrow"
const BG := Color(0.075, 0.065, 0.052, 0.98)
const PANEL := Color(0.16, 0.13, 0.09)
const GOLD := Color(0.91, 0.73, 0.35)
const TEXT := Color(0.94, 0.89, 0.76)
const DIM := Color(0.68, 0.63, 0.53)

var definitions: Array = []
var selected_id := ""
var list_box: VBoxContainer
var detail_box: VBoxContainer
var summary_label: Label
var result_label: Label
var governance_picker: OptionButton
var garrison_label: Label
var current_garrison := 0
var _building := false


func setup(p_definitions: Array) -> void:
    definitions = p_definitions.duplicate(true)
    if not definitions.is_empty():
        selected_id = str(definitions[0].get("id", ""))
    _build()
    visible = false


func open() -> void:
    visible = true
    _refresh()


func close() -> void:
    visible = false
    closed.emit()


func _style_panel(color: Color) -> StyleBoxFlat:
    var s := StyleBoxFlat.new()
    s.bg_color = color
    s.border_color = Color(0.55, 0.42, 0.24)
    s.set_border_width_all(2)
    s.set_corner_radius_all(9)
    s.set_content_margin_all(12)
    return s


func _label(value: String, size: int = 18, color: Color = TEXT) -> Label:
    var l := Label.new()
    l.text = value
    l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    l.add_theme_font_size_override("font_size", size)
    l.add_theme_color_override("font_color", color)
    l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    return l


func _button(value: String, callback: Callable) -> Button:
    var b := Button.new()
    b.text = value
    b.custom_minimum_size = Vector2(0, 48)
    b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    b.add_theme_font_size_override("font_size", 17)
    b.add_theme_color_override("font_color", TEXT)
    b.add_theme_stylebox_override("normal", _style_panel(PANEL))
    b.add_theme_stylebox_override("hover", _style_panel(PANEL.lightened(0.16)))
    b.add_theme_stylebox_override("pressed", _style_panel(PANEL.darkened(0.2)))
    b.pressed.connect(callback)
    return b


func _build() -> void:
    for child in get_children():
        child.queue_free()
    set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    var backdrop := ColorRect.new()
    backdrop.color = BG
    backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    backdrop.mouse_filter = Control.MOUSE_FILTER_STOP
    add_child(backdrop)

    var outer := MarginContainer.new()
    outer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    outer.add_theme_constant_override("margin_left", 14)
    outer.add_theme_constant_override("margin_top", 14)
    outer.add_theme_constant_override("margin_right", 14)
    outer.add_theme_constant_override("margin_bottom", 14)
    add_child(outer)
    var column := VBoxContainer.new()
    column.add_theme_constant_override("separation", 10)
    outer.add_child(column)

    var header := HBoxContainer.new()
    column.add_child(header)
    var title := _label("THE HOLDFASTS  •  HOUSE DUNMARROW", 24, GOLD)
    header.add_child(title)
    var close_button := _button("CLOSE", close)
    close_button.custom_minimum_size = Vector2(100, 46)
    close_button.size_flags_horizontal = Control.SIZE_SHRINK_END
    header.add_child(close_button)

    summary_label = _label("", 16, DIM)
    column.add_child(summary_label)
    var split := HBoxContainer.new()
    split.size_flags_vertical = Control.SIZE_EXPAND_FILL
    split.add_theme_constant_override("separation", 12)
    column.add_child(split)

    var list_panel := PanelContainer.new()
    list_panel.custom_minimum_size = Vector2(300, 0)
    list_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    list_panel.size_flags_stretch_ratio = 0.9
    list_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
    list_panel.add_theme_stylebox_override("panel", _style_panel(PANEL))
    split.add_child(list_panel)
    var list_scroll := ScrollContainer.new()
    list_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
    list_panel.add_child(list_scroll)
    list_box = VBoxContainer.new()
    list_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    list_box.add_theme_constant_override("separation", 6)
    list_scroll.add_child(list_box)

    var detail_panel := PanelContainer.new()
    detail_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    detail_panel.size_flags_stretch_ratio = 1.5
    detail_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
    detail_panel.add_theme_stylebox_override("panel", _style_panel(PANEL))
    split.add_child(detail_panel)
    var detail_scroll := ScrollContainer.new()
    detail_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
    detail_panel.add_child(detail_scroll)
    detail_box = VBoxContainer.new()
    detail_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    detail_box.add_theme_constant_override("separation", 10)
    detail_scroll.add_child(detail_box)

    var footer := HBoxContainer.new()
    column.add_child(footer)
    result_label = _label("A campaign turn is advanced only when you choose it.", 14, DIM)
    footer.add_child(result_label)
    var advance := _button("ADVANCE EMPIRE TURN", _advance_turn)
    advance.custom_minimum_size = Vector2(250, 50)
    footer.add_child(advance)


func _holding(id: String) -> Dictionary:
    for raw in definitions:
        if str(raw.get("id", "")) == id:
            return raw
    return {}


func _is_player_holding(id: String) -> bool:
    return bool(GameState.world_flags.get("holding_claimed_" + id, false)) and str(GameState.world_flags.get("holding_owner_" + id, HOLDING)) == HOLDING


func _refresh() -> void:
    if list_box == null:
        return
    _building = true
    for child in list_box.get_children():
        child.queue_free()
    var claimed_count := 0
    for raw in definitions:
        var d: Dictionary = raw
        var id := str(d.get("id", ""))
        var claimed := _is_player_holding(id)
        if claimed:
            claimed_count += 1
        var status := "ADMINISTERED" if claimed else str(GameState.world_flags.get("holding_status_" + id, "NOT CLAIMED")).to_upper()
        var b := _button(("%s\n%s  •  %s" % [str(d.get("name", id)), str(d.get("region", "Unknown region")), status]), _select_holding.bind(id))
        if id == selected_id:
            b.add_theme_stylebox_override("normal", _style_panel(Color(0.31, 0.23, 0.12)))
        list_box.add_child(b)
    summary_label.text = "TURN %d   •   %d GOLD   •   %d PROVISIONS   •   %d MATERIALS   •   %d / %d HOLDINGS" % [int(GameState.world_flags.get("empire_turn", 0)), GameState.party.gold, int(GameState.world_flags.get("empire_stockpile_provisions", 0)), int(GameState.world_flags.get("empire_stockpile_materials", 0)), claimed_count, definitions.size()]
    _refresh_detail()
    _building = false


func _select_holding(id: String) -> void:
    selected_id = id
    _refresh()


func _refresh_detail() -> void:
    for child in detail_box.get_children():
        child.queue_free()
    var d := _holding(selected_id)
    if d.is_empty():
        detail_box.add_child(_label("No holding selected.", 20))
        return
    var id := selected_id
    var claimed := _is_player_holding(id)
    var economy: Dictionary = d.get("economy", {})
    detail_box.add_child(_label(str(d.get("name", id)), 26, GOLD))
    detail_box.add_child(_label("%s  •  %s  •  %s" % [str(d.get("continent", "" )).capitalize(), str(d.get("region", "")).replace("_", " ").capitalize(), str(d.get("kind", "")).replace("_", " ").capitalize()], 14, DIM))
    detail_box.add_child(_label(str(d.get("description", "")), 16))
    var strategic_lines := PackedStringArray()
    for value in d.get("strategic_value", []):
        strategic_lines.append(str(value))
    detail_box.add_child(_label("STRATEGIC VALUE\n• " + "\n• ".join(strategic_lines), 15, DIM))
    detail_box.add_child(_label("LOCAL OUTPUT  •  %d GOLD  /  %d PROVISIONS  /  %d MATERIALS" % [int(economy.get("gold", 0)), int(economy.get("provisions", 0)), int(economy.get("materials", 0))], 15, GOLD))
    if not claimed:
        detail_box.add_child(_label("This location is not under your administration. Its capture must be resolved through the authored world objective, battle, or treaty. Remote holdings cannot be claimed from this screen.", 16, DIM))
        return

    var stability := int(GameState.world_flags.get("holding_stability_" + id, 35))
    var governance := str(GameState.world_flags.get("holding_governance_" + id, "appointed_warden"))
    current_garrison = int(GameState.world_flags.get("holding_garrison_" + id, 0))
    detail_box.add_child(_label("ADMINISTRATION  •  %s" % Economy.stability_label(stability).to_upper(), 18, GOLD))
    detail_box.add_child(_label("Stability %d / 100   •   %s   •   Garrison %d" % [stability, str(GameState.world_flags.get("holding_status_" + id, "provisional")).capitalize(), current_garrison], 15))
    var governance_row := HBoxContainer.new()
    detail_box.add_child(governance_row)
    governance_row.add_child(_label("GOVERNANCE", 15, DIM))
    governance_picker = OptionButton.new()
    governance_picker.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    var models := ["appointed_warden", "merchant_council", "local_compact", "military_command"]
    var labels := ["Appointed Warden", "Merchant Council", "Local Compact", "Military Command"]
    var selected_index := models.find(governance)
    if selected_index < 0:
        selected_index = 0
    for i in range(models.size()):
        governance_picker.add_item(labels[i], i)
    governance_picker.select(selected_index)
    governance_picker.item_selected.connect(_governance_changed.bind(models))
    governance_row.add_child(governance_picker)

    var garrison_row := HBoxContainer.new()
    detail_box.add_child(garrison_row)
    garrison_row.add_child(_button("−", _change_garrison.bind(-1)))
    garrison_label = _label("GARRISON  %d" % current_garrison, 18, GOLD)
    garrison_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    garrison_row.add_child(garrison_label)
    garrison_row.add_child(_button("+", _change_garrison.bind(1)))
    detail_box.add_child(_label("A soldier costs 1 gold per empire turn. A garrison at the recommended strength improves stability; an empty garrison increases unrest.", 14, DIM))
    detail_box.add_child(_label("GOVERNANCE EFFECTS\nWarden: standard administration\nMerchant Council: +20% gold income, +1 upkeep\nLocal Compact: −1 upkeep and +2 stability\nMilitary Command: +2 upkeep and −1 stability", 14, DIM))


func _governance_changed(index: int, models: Array) -> void:
    var result: Dictionary = GameState.set_holding_governance(selected_id, str(models[index]))
    if bool(result.get("ok", false)):
        result_label.text = "Governance updated and saved."
        GameState.save_campaign("auto_a")
    else:
        result_label.text = str(result.get("reason", "Could not change governance."))
    _refresh()


func _change_garrison(delta: int) -> void:
    var next_count := clampi(current_garrison + delta, 0, 99)
    var result: Dictionary = GameState.assign_holding_garrison(selected_id, next_count)
    if bool(result.get("ok", false)):
        current_garrison = next_count
        garrison_label.text = "GARRISON  %d" % current_garrison
        result_label.text = "Garrison updated and saved. Upkeep applies on the next empire turn."
        GameState.save_campaign("auto_a")
    else:
        result_label.text = str(result.get("reason", "Could not assign garrison."))


func _advance_turn() -> void:
    var result: Dictionary = GameState.advance_empire_turn(definitions)
    if not bool(result.get("ok", false)):
        result_label.text = str(result.get("reason", "The empire turn could not be advanced."))
        return
    var net := int(result.get("net", 0))
    result_label.text = "Turn %d resolved: %+d gold. Stability and holding reports updated." % [int(GameState.world_flags.get("empire_turn", 0)), net]
    GameState.save_campaign("auto_a")
    _refresh()
