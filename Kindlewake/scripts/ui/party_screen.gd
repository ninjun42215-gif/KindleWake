class_name PartyScreen
extends Control

const CharacterSheetScript = preload("res://scripts/core/character_sheet.gd")
const PartyStateScript = preload("res://scripts/core/party_state.gd")
const RuneSystem = preload("res://scripts/core/rune_system.gd")
## Full-screen party management in one touch UI (v0.8.0 layout): a compact top bar, a roster of cards, a character
## sheet made of stat tiles, and a right panel with three tabs: Equipment, Sigils and Shop.
## It owns no rules: every action goes through PartyStateScript / CharacterSheetScript / ShopSystem, the same code paths the
## headless tests cover. It reads no autoloads, so it can be built in tests.
## Usage: setup(party, db, shop) then open(); listen to `closed`.
## db needs "classes", "weapons", "items", "runes", "skills" (GameData.party_db()).

signal closed()

const TAB_GEAR := 0
const TAB_SIGILS := 1
const TAB_SHOP := 2
const TAB_NAMES: Array[String] = ["Equipment", "runes", "Shop"]

const COL_BG := Color(0.106, 0.092, 0.07)
const COL_PANEL := Color(0.19, 0.155, 0.11)
const COL_CARD := Color(0.255, 0.205, 0.145)
const COL_CARD_SEL := Color(0.36, 0.27, 0.12)
const COL_TILE := Color(0.13, 0.11, 0.085)
const COL_BORDER := Color(0.72, 0.55, 0.32)
const COL_BORDER_DIM := Color(0.46, 0.36, 0.22)
const COL_TEXT := Color(0.94, 0.89, 0.74)
const COL_DIM := Color(0.74, 0.68, 0.55)
const COL_GOLD := Color(1.0, 0.86, 0.3)
const COL_GOOD := Color(0.55, 0.92, 0.55)
const COL_BAD := Color(1.0, 0.55, 0.45)
const RARITY_COLORS := {
    "common": Color(0.94, 0.89, 0.74),
    "uncommon": Color(0.55, 0.8, 1.0),
    "rare": Color(0.55, 0.78, 0.95),
    "epic": Color(0.72, 0.56, 0.92),
    "legendary": Color(0.95, 0.68, 0.28),
    "mythical": Color(0.95, 0.45, 0.68),
    "unique": Color(0.95, 0.82, 0.35),
    "fine": Color(0.55, 0.8, 1.0),
    "masterwork": Color(0.82, 0.62, 1.0),
    "heirloom": Color(1.0, 0.75, 0.3),
}

var party: PartyStateScript = null
var db: Dictionary = {}
var shop: Dictionary = {}
var shop_access_allowed: bool = true
var selected_id: String = ""
var tab: int = TAB_GEAR
var focus_slot: String = ""           # Equipment tab: the slot whose choices are open
var focus_group: String = ""          # Sigils tab: "weapon" or "armor"
var focus_index: int = -1             # Sigils tab: the socket whose choices are open
var shop_selling: bool = false
var shop_pick: String = ""            # Shop tab: the card that is open for compare + confirm ("buy:item:<id>", "sell:item:<id>", "sell:rune:<n>")
var message: String = ""
var message_ok: bool = false          # true when `message` reports something that worked (shown green, otherwise red)
var changed: bool = false             # true once anything was equipped, socketed, promoted, bought or sold
var right_scroll: ScrollContainer = null
var roster_scroll: ScrollContainer = null
var sheet_scroll: ScrollContainer = null
var keep_scroll: int = 0
var keep_roster: int = 0
var keep_sheet: int = 0
var reset_scroll: bool = false        # right panel back to the top on the next rebuild
var reset_sheet: bool = false         # character sheet back to the top on the next rebuild
var rune_rng := RandomNumberGenerator.new()
var builds: int = 0                   # how many times the layout was completely built (tests use it to catch half-built screens)


func setup(p_party: PartyStateScript, p_db: Dictionary, p_shop: Dictionary, allow_shop: bool = true) -> void:
    party = p_party
    db = p_db
    shop = p_shop
    rune_rng.randomize()
    shop_access_allowed = allow_shop
    if not shop_access_allowed and tab == TAB_SHOP:
        tab = TAB_GEAR
    if not party.sheets.has(selected_id) and not party.roster.is_empty():
        selected_id = party.roster[0]
    visible = false


func open() -> void:
    changed = false
    message = ""
    message_ok = false
    focus_slot = ""
    focus_group = ""
    focus_index = -1
    shop_pick = ""
    reset_scroll = true
    reset_sheet = true
    keep_roster = 0
    if not party.sheets.has(selected_id) and not party.roster.is_empty():
        selected_id = party.roster[0]
    visible = true
    _rebuild()


func close() -> void:
    visible = false
    closed.emit()


## The phone's Back button (and Esc on a keyboard) closes the screen.
func _unhandled_input(event: InputEvent) -> void:
    if visible and event.is_action_pressed("ui_cancel"):
        get_viewport().set_input_as_handled()
        close()


# ---------------------------------------------------------------- building blocks

func _style(bg: Color, border: Color, border_w: int = 2, radius: int = 8, margin: float = 10.0) -> StyleBoxFlat:
    var sb := StyleBoxFlat.new()
    sb.bg_color = bg
    sb.border_color = border
    sb.set_border_width_all(border_w)
    sb.set_corner_radius_all(radius)
    sb.set_content_margin_all(margin)
    return sb


func _panel(min_size: Vector2) -> PanelContainer:
    var p := PanelContainer.new()
    p.custom_minimum_size = min_size
    p.add_theme_stylebox_override("panel", _style(COL_PANEL, COL_BORDER))
    return p


## Body text: wraps and fills the row.
func _label(text: String, font_size: int = 18, color: Color = COL_TEXT) -> Label:
    var l := Label.new()
    l.text = text
    l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    l.add_theme_font_size_override("font_size", font_size)
    l.add_theme_color_override("font_color", color)
    return l


## Short text that must never wrap or collapse (numbers, prices, chips).
func _text(text: String, font_size: int = 18, color: Color = COL_TEXT) -> Label:
    var l := Label.new()
    l.text = text
    l.add_theme_font_size_override("font_size", font_size)
    l.add_theme_color_override("font_color", color)
    l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    return l


## Gives a button the parchment look: normal, hover, pressed and disabled states, no focus frame.
func _skin(b: Button, bg: Color, border: Color, text_col: Color = COL_TEXT) -> void:
    b.add_theme_stylebox_override("normal", _style(bg, border))
    b.add_theme_stylebox_override("hover", _style(bg.lightened(0.12), border))
    b.add_theme_stylebox_override("pressed", _style(bg.darkened(0.2), COL_GOLD))
    b.add_theme_stylebox_override("disabled", _style(bg.darkened(0.3), border.darkened(0.4)))
    b.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
    b.add_theme_color_override("font_color", text_col)
    b.add_theme_color_override("font_hover_color", text_col)
    b.add_theme_color_override("font_pressed_color", COL_GOLD)
    b.add_theme_color_override("font_disabled_color", COL_DIM.darkened(0.3))
    b.focus_mode = Control.FOCUS_NONE


func _button(text: String, handler: Callable, min_size: Vector2 = Vector2(0, 56), font_size: int = 20, primary: bool = false) -> Button:
    var b := Button.new()
    b.text = text
    b.custom_minimum_size = min_size
    b.clip_text = true
    b.add_theme_font_size_override("font_size", font_size)
    if primary:
        _skin(b, COL_CARD_SEL, COL_GOLD, COL_GOLD)
    else:
        _skin(b, COL_CARD, COL_BORDER_DIM)
    b.pressed.connect(handler)
    return b


## A tab-like button: the selected one is filled gold-brown.
func _tab_button(text: String, handler: Callable, selected: bool) -> Button:
    var b := Button.new()
    b.text = text
    b.custom_minimum_size = Vector2(0, 54)
    b.clip_text = true
    b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    b.add_theme_font_size_override("font_size", 21)
    if selected:
        _skin(b, COL_CARD_SEL, COL_GOLD, COL_GOLD)
    else:
        _skin(b, COL_TILE, COL_BORDER_DIM, COL_DIM)
    b.pressed.connect(handler)
    return b


## A tappable card (TapCard: a tap selects, a drag scrolls the list) with free-form content. Returns [holder, content_box].
## Add labels to content_box, then call _seal(holder) so the card receives every touch.
func _card(handler: Callable, selected: bool = false, disabled: bool = false) -> Array:
    var holder := TapCard.new()
    holder.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    var bg: Color = COL_CARD
    var border: Color = COL_BORDER_DIM
    var border_w: int = 1
    if selected:
        bg = COL_CARD_SEL
        border = COL_GOLD
        border_w = 2
    holder.set_styles(_style(bg, border, border_w, 8, 0.0), _style(bg.darkened(0.2), COL_GOLD, 2, 8, 0.0), _style(bg.darkened(0.25), border.darkened(0.4), border_w, 8, 0.0))
    holder.set_disabled(disabled)
    if not disabled:
        holder.tapped.connect(handler)
    var margin := MarginContainer.new()
    margin.add_theme_constant_override("margin_left", 14)
    margin.add_theme_constant_override("margin_right", 14)
    margin.add_theme_constant_override("margin_top", 9)
    margin.add_theme_constant_override("margin_bottom", 9)
    var box := VBoxContainer.new()
    box.add_theme_constant_override("separation", 3)
    margin.add_child(box)
    holder.add_child(margin)
    return [holder, box]


func _seal(holder: Control) -> void:
    for c in holder.get_children():
        _ignore_mouse(c)


## Panels, boxes and tiles must not swallow touches: only buttons, cards and scroll areas take them, so a finger that
## starts on a tile or a gap still scrolls the list.
func _relax_mouse(n: Node) -> void:
    if n is Control:
        var c: Control = n
        if not (c is Button or c is TapCard or c is ScrollContainer):
            c.mouse_filter = Control.MOUSE_FILTER_IGNORE
    if n is TapCard:
        return
    for ch in n.get_children():
        _relax_mouse(ch)


func _ignore_mouse(n: Node) -> void:
    if n is Control:
        (n as Control).mouse_filter = Control.MOUSE_FILTER_IGNORE
    for c in n.get_children():
        _ignore_mouse(c)


func _scroll_box(separation: int = 8) -> Array:
    var scroll := ScrollContainer.new()
    scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
    scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
    scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    var box := VBoxContainer.new()
    box.add_theme_constant_override("separation", separation)
    box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    scroll.add_child(box)
    return [scroll, box]


func _add_section(box: VBoxContainer, title: String) -> void:
    var l := _label(title, 20, COL_GOLD)
    l.custom_minimum_size = Vector2(0, 30)
    box.add_child(l)
    box.add_child(HSeparator.new())


## A small box with a dim caption above a value: the stat tiles of the character sheet.
func _tile(caption: String, value: String, value_color: Color = COL_TEXT, value_size: int = 22) -> Control:
    var p := PanelContainer.new()
    p.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    p.add_theme_stylebox_override("panel", _style(COL_TILE, COL_BORDER_DIM, 1, 6, 6.0))
    var v := VBoxContainer.new()
    v.add_theme_constant_override("separation", 0)
    var cap := _text(caption, 13, COL_DIM)
    cap.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    var val := _text(value, value_size, value_color)
    val.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    v.add_child(cap)
    v.add_child(val)
    p.add_child(v)
    return p


func _class_title(class_id: String) -> String:
    var cdef: Dictionary = (db.get("classes", {}) as Dictionary).get(class_id, {})
    return str(cdef.get("name", class_id))


func _item_name(item_id: String) -> String:
    var it: Dictionary = (db.get("items", {}) as Dictionary).get(item_id, {})
    return str(it.get("name", item_id))


func _rarity_color(item_id: String) -> Color:
    var it: Dictionary = (db.get("items", {}) as Dictionary).get(item_id, {})
    return RARITY_COLORS.get(str(it.get("rarity", "common")), COL_TEXT)


func _sigil_def(sigil_id: String) -> Dictionary:
    return (db.get("runes", {}) as Dictionary).get(sigil_id, {})


## Display name of bag sigil number `bag_index` ("rune" when the index is stale).
func _bag_sigil_name(bag_index: int) -> String:
    if bag_index < 0 or bag_index >= party.sigil_inv.size():
        return "rune"
    var inst: Dictionary = party.sigil_inv[bag_index]
    return str(_sigil_def(str(inst.get("id", ""))).get("name", "rune"))


## Green/red stat changes for an equip preview, wrapped onto several lines when needed.
func _delta_row(before: Dictionary, after: Dictionary) -> Control:
    var flow := HFlowContainer.new()
    flow.add_theme_constant_override("h_separation", 14)
    flow.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    var parts: Array = ItemInfo.delta_parts(before, after)
    if parts.is_empty():
        flow.add_child(_text("no change", 16, COL_DIM))
    for p in parts:
        var d: Dictionary = p
        var col: Color = COL_GOOD
        if int(d["sign"]) < 0:
            col = COL_BAD
        flow.add_child(_text(str(d["text"]), 17, col))
    return flow


# ---------------------------------------------------------------- whole-screen layout

func _rebuild() -> void:
    if party == null:
        return
    if right_scroll != null and is_instance_valid(right_scroll):
        keep_scroll = 0 if reset_scroll else right_scroll.scroll_vertical
    else:
        keep_scroll = 0
    if roster_scroll != null and is_instance_valid(roster_scroll):
        keep_roster = roster_scroll.scroll_vertical
    if sheet_scroll != null and is_instance_valid(sheet_scroll):
        keep_sheet = 0 if reset_sheet else sheet_scroll.scroll_vertical
    else:
        keep_sheet = 0
    reset_scroll = false
    reset_sheet = false
    right_scroll = null
    roster_scroll = null
    sheet_scroll = null
    for c in get_children():
        remove_child(c)
        c.queue_free()
    var bg := ColorRect.new()
    bg.color = COL_BG
    bg.mouse_filter = Control.MOUSE_FILTER_STOP
    add_child(bg)
    bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    var margin := MarginContainer.new()
    margin.add_theme_constant_override("margin_left", 14)
    margin.add_theme_constant_override("margin_right", 14)
    margin.add_theme_constant_override("margin_top", 10)
    margin.add_theme_constant_override("margin_bottom", 10)
    add_child(margin)
    margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    var root_box := VBoxContainer.new()
    root_box.add_theme_constant_override("separation", 10)
    margin.add_child(root_box)
    root_box.add_child(_build_header())
    var cols := HBoxContainer.new()
    cols.add_theme_constant_override("separation", 10)
    cols.size_flags_vertical = Control.SIZE_EXPAND_FILL
    root_box.add_child(cols)
    cols.add_child(_build_roster())
    cols.add_child(_build_sheet())
    cols.add_child(_build_right())
    _relax_mouse(margin)
    builds += 1
    _restore_scroll.call_deferred()


## Scroll positions are restored one frame later, when the new layout has its size.
func _restore_scroll() -> void:
    if not is_inside_tree():
        return
    await get_tree().process_frame
    if right_scroll != null and is_instance_valid(right_scroll):
        right_scroll.scroll_vertical = keep_scroll
    if roster_scroll != null and is_instance_valid(roster_scroll):
        roster_scroll.scroll_vertical = keep_roster
    if sheet_scroll != null and is_instance_valid(sheet_scroll):
        sheet_scroll.scroll_vertical = keep_sheet


func _build_header() -> Control:
    var bar := PanelContainer.new()
    bar.custom_minimum_size = Vector2(0, 62)
    bar.add_theme_stylebox_override("panel", _style(COL_PANEL, COL_BORDER, 2, 8, 6.0))
    var row := HBoxContainer.new()
    row.add_theme_constant_override("separation", 12)
    var title := _text("Company of Kaer Sethorn", 28, COL_GOLD)
    title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    title.clip_text = true
    title.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
    row.add_child(title)
    var chip := PanelContainer.new()
    chip.add_theme_stylebox_override("panel", _style(COL_TILE, COL_GOLD.darkened(0.3), 1, 20, 8.0))
    chip.add_child(_text("Gold  %d" % party.gold, 24, COL_GOLD))
    row.add_child(chip)
    row.add_child(_button("Close", close, Vector2(130, 50), 22, true))
    bar.add_child(row)
    return bar


func _build_roster() -> Control:
    var panel := _panel(Vector2(250, 0))
    var parts: Array = _scroll_box(8)
    var scroll: ScrollContainer = parts[0]
    var box: VBoxContainer = parts[1]
    roster_scroll = scroll
    var classes: Dictionary = db.get("classes", {})
    for id in party.roster:
        var sh: CharacterSheetScript = party.sheet(id)
        var cp: Array = _card(_on_select.bind(id), id == selected_id)
        var holder: PanelContainer = cp[0]
        var cbox: VBoxContainer = cp[1]
        var row := HBoxContainer.new()
        row.add_theme_constant_override("separation", 10)
        var badge := PanelContainer.new()
        badge.custom_minimum_size = Vector2(46, 46)
        badge.add_theme_stylebox_override("panel", _style(COL_TILE, COL_GOLD if id == selected_id else COL_BORDER_DIM, 2, 23, 4.0))
        var lv := _text("%d" % sh.level, 22, COL_GOLD)
        lv.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        badge.add_child(lv)
        row.add_child(badge)
        var info := VBoxContainer.new()
        info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        info.add_theme_constant_override("separation", 0)
        info.add_child(_label(sh.display_name, 19, COL_GOLD if id == selected_id else COL_TEXT))
        info.add_child(_label(_class_title(sh.class_id), 15, COL_DIM))
        row.add_child(info)
        if not sh.promotion_options(classes).is_empty():
            row.add_child(_text("PROMOTE", 12, COL_GOOD))
        cbox.add_child(row)
        _seal(holder)
        box.add_child(holder)
    panel.add_child(scroll)
    return panel


func _build_sheet() -> Control:
    var panel := _panel(Vector2(400, 0))
    var parts: Array = _scroll_box(8)
    var scroll: ScrollContainer = parts[0]
    var box: VBoxContainer = parts[1]
    sheet_scroll = scroll
    var sh: CharacterSheetScript = party.sheet(selected_id)
    if sh == null:
        box.add_child(_label("Nobody is selected."))
    else:
        _fill_sheet(box, sh)
    panel.add_child(scroll)
    return panel


func _fill_sheet(box: VBoxContainer, sh: CharacterSheetScript) -> void:
    var items: Dictionary = db.get("items", {})
    var sdefs: Dictionary = db.get("runes", db.get("sigils", {}))
    var skills: Dictionary = db.get("skills", {})
    var classes: Dictionary = db.get("classes", {})
    var d: Dictionary = sh.derived(db)
    var total: Dictionary = sh.total_stats(items, sdefs)
    # name row with previous / next character buttons
    var head := HBoxContainer.new()
    head.add_theme_constant_override("separation", 8)
    head.add_child(_button("<", _on_step.bind(-1), Vector2(52, 52), 26))
    var title := VBoxContainer.new()
    title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    title.add_theme_constant_override("separation", 0)
    var name_label := _label(sh.display_name, 26, COL_GOLD)
    name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    title.add_child(name_label)
    var sub := _label("Lv %d  %s  -  house %s" % [sh.level, _class_title(sh.class_id), sh.house.capitalize()], 16, COL_DIM)
    sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    title.add_child(sub)
    head.add_child(title)
    head.add_child(_button(">", _on_step.bind(1), Vector2(52, 52), 26))
    box.add_child(head)
    # Experience is deliberately visible, but the 250-level cap is a campaign milestone.
    if sh.level >= CharacterSheetScript.MAX_LEVEL:
        box.add_child(_label("EXPERIENCE  •  MAX LEVEL REACHED", 15, COL_GOLD))
    else:
        box.add_child(_label("EXPERIENCE  %d / %d" % [sh.xp, sh.exp_to_next()], 15, COL_DIM))
    var bar := ProgressBar.new()
    bar.min_value = 0.0
    bar.max_value = float(maxi(1, sh.exp_to_next()))
    bar.value = float(sh.xp) if sh.level < CharacterSheetScript.MAX_LEVEL else 1.0
    if sh.level >= CharacterSheetScript.MAX_LEVEL:
        bar.max_value = 1.0
    bar.show_percentage = false
    bar.custom_minimum_size = Vector2(0, 14)
    bar.add_theme_stylebox_override("background", _style(COL_TILE, COL_BORDER_DIM, 1, 5, 0.0))
    bar.add_theme_stylebox_override("fill", _style(COL_GOLD.darkened(0.25), COL_GOLD.darkened(0.25), 0, 5, 0.0))
    box.add_child(bar)
    # vitals and combat numbers as tiles
    _add_section(box, "Combat")
    var vit := HBoxContainer.new()
    vit.add_theme_constant_override("separation", 8)
    vit.add_child(_tile("HP", "%d" % int(d["max_hp"]), COL_TEXT, 28))
    vit.add_child(_tile("MP", "%d" % int(d["max_mp"]), COL_TEXT, 28))
    box.add_child(vit)
    var grid := GridContainer.new()
    grid.columns = 3
    grid.add_theme_constant_override("h_separation", 8)
    grid.add_theme_constant_override("v_separation", 8)
    grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    grid.add_child(_tile("Attack", "%d" % roundi(float(d["attack"]))))
    grid.add_child(_tile("Defense", "%d" % roundi(float(d["defense"]))))
    grid.add_child(_tile("Resist", "%d" % roundi(float(d["resistance"]))))
    grid.add_child(_tile("Accuracy", "%d" % int(d["accuracy"])))
    grid.add_child(_tile("Evasion", "%d" % int(d["evasion"])))
    grid.add_child(_tile("Crit", "%d%%" % int(d["crit"])))
    grid.add_child(_tile("Speed", "%d" % int(d["spd"])))
    grid.add_child(_tile("Move", "%d" % int(d["move"])))
    grid.add_child(_tile("Range", "%d-%d" % [int(d["range_min"]), int(d["range_max"])]))
    box.add_child(grid)
    # attributes: green when gear adds to them, red when gear takes away
    _add_section(box, "Attributes")
    var attrs := GridContainer.new()
    attrs.columns = 5
    attrs.add_theme_constant_override("h_separation", 6)
    attrs.add_theme_constant_override("v_separation", 6)
    attrs.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    for key in ItemInfo.STAT_ORDER:
        var gear_bonus: int = int(total.get(key, 0)) - int(sh.base_stats.get(key, 0))
        var col: Color = COL_TEXT
        if gear_bonus > 0:
            col = COL_GOOD
        elif gear_bonus < 0:
            col = COL_BAD
        attrs.add_child(_tile(ItemInfo.stat_name(key), "%d" % int(total.get(key, 0)), col, 20))
    box.add_child(attrs)
    # skills
    var mods: Dictionary = sh.skill_mods(items, sdefs)
    var known: Array[String] = sh.all_skills(items, sdefs, classes)
    _add_section(box, "Skills")
    if known.is_empty():
        box.add_child(_label("None yet. Socket a magic rune to learn spells, or promote.", 16, COL_DIM))
    for sid in known:
        var text: String = ItemInfo.skill_line(sid, skills)
        var pieces: PackedStringArray = text.split(": ", true, 1)
        var sk_name: String = pieces[0]
        var sk_desc: String = ""
        if pieces.size() > 1:
            sk_desc = pieces[1]
        if int(mods.get(sid, 0)) != 0:
            sk_desc += "  (power %s%%)" % ItemInfo.signed(int(mods[sid]))
        var sp := PanelContainer.new()
        sp.add_theme_stylebox_override("panel", _style(COL_TILE, COL_BORDER_DIM, 1, 6, 8.0))
        var sv := VBoxContainer.new()
        sv.add_theme_constant_override("separation", 1)
        sv.add_child(_label(sk_name, 18, COL_GOLD))
        if sk_desc != "":
            sv.add_child(_label(sk_desc, 15, COL_DIM))
        sp.add_child(sv)
        box.add_child(sp)
    var options: Array[String] = sh.promotion_options(classes)
    if not options.is_empty():
        _add_section(box, "Promotion available")
        for cid in options:
            box.add_child(_button("Promote to %s" % _class_title(cid), _on_promote.bind(cid), Vector2(0, 56), 20, true))


func _hint() -> String:
    if tab == TAB_GEAR:
        return "Tap a slot to compare gear. Green is better, red is worse."
    if tab == TAB_SIGILS:
        return "Tap a socket to equip a rune. Linked sockets (=) amplify support effects."
    if tab == TAB_FORGE:
        return "Combine three matching runes for a chance at the next grade. Failure preserves one rune."
    if shop_selling:
        return "Tap an item, then press Confirm to sell it."
    return "Tap an item to compare it with your gear, then press Confirm to buy."


func _build_banner() -> Control:
    var p := PanelContainer.new()
    p.custom_minimum_size = Vector2(0, 46)
    var col: Color = COL_DIM
    var border: Color = COL_BORDER_DIM
    var text: String = message
    if message == "":
        text = _hint()
    elif message_ok:
        col = COL_GOOD
        border = COL_GOOD.darkened(0.35)
    else:
        col = COL_BAD
        border = COL_BAD.darkened(0.35)
    p.add_theme_stylebox_override("panel", _style(COL_TILE, border, 1, 6, 8.0))
    p.add_child(_label(text, 16, col))
    return p


func _build_right() -> Control:
    var panel := _panel(Vector2(460, 0))
    panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    var outer := VBoxContainer.new()
    outer.add_theme_constant_override("separation", 8)
    var tabs := HBoxContainer.new()
    tabs.add_theme_constant_override("separation", 8)
    var tab_count: int = TAB_NAMES.size() if shop_access_allowed else TAB_SHOP
    for t in range(tab_count):
        tabs.add_child(_tab_button(TAB_NAMES[t], _on_tab.bind(t), t == tab))
    outer.add_child(tabs)
    outer.add_child(_build_banner())
    var parts: Array = _scroll_box(8)
    var scroll: ScrollContainer = parts[0]
    var box: VBoxContainer = parts[1]
    right_scroll = scroll
    if tab == TAB_GEAR:
        _fill_gear(box)
    elif tab == TAB_SIGILS:
        _fill_sigils(box)
    elif tab == TAB_FORGE:
        _fill_forge(box)
    else:
        _fill_shop(box)
    outer.add_child(scroll)
    panel.add_child(outer)
    return panel


# ---------------------------------------------------------------- Equipment tab

func _fill_gear(box: VBoxContainer) -> void:
    var sh: CharacterSheetScript = party.sheet(selected_id)
    if sh == null:
        return
    var items: Dictionary = db.get("items", {})
    var weapons: Dictionary = db.get("weapons", {})
    var current: Dictionary = sh.derived(db)
    for slot in CharacterSheetScript.SLOTS:
        var iid: String = sh.item_in(slot)
        var is_open: bool = slot == focus_slot
        var cp: Array = _card(_on_slot.bind(slot), is_open)
        var holder: PanelContainer = cp[0]
        var cbox: VBoxContainer = cp[1]
        var row := HBoxContainer.new()
        row.add_theme_constant_override("separation", 8)
        var texts := VBoxContainer.new()
        texts.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        texts.add_theme_constant_override("separation", 1)
        texts.add_child(_label(ItemInfo.slot_name(slot).to_upper(), 13, COL_DIM))
        if iid == "":
            texts.add_child(_label("Empty - tap to choose", 19, COL_DIM))
        else:
            texts.add_child(_label(_item_name(iid), 21, _rarity_color(iid)))
            texts.add_child(_label(ItemInfo.item_line(iid, items, weapons, false), 14, COL_DIM))
        row.add_child(texts)
        row.add_child(_text("v" if is_open else ">", 22, COL_GOLD))
        cbox.add_child(row)
        _seal(holder)
        box.add_child(holder)
        if is_open:
            _fill_slot_choices(box, sh, slot, current)
    _fill_bag_overview(box)


func _item_fits_slot(it: Dictionary, slot: String) -> bool:
    var item_slot: String = str(it.get("slot", ""))
    return item_slot == slot or (item_slot == "accessory" and slot.begins_with("accessory"))


func _fill_slot_choices(box: VBoxContainer, sh: CharacterSheetScript, slot: String, current: Dictionary) -> void:
    var items: Dictionary = db.get("items", {})
    var weapons: Dictionary = db.get("weapons", {})
    var wrap := PanelContainer.new()
    wrap.add_theme_stylebox_override("panel", _style(COL_TILE, COL_BORDER, 1, 8, 8.0))
    var inner := VBoxContainer.new()
    inner.add_theme_constant_override("separation", 8)
    wrap.add_child(inner)
    inner.add_child(_label("Choose %s for %s" % [ItemInfo.slot_name(slot).to_lower(), sh.display_name], 17, COL_GOLD))
    var worn: String = sh.item_in(slot)
    if worn != "":
        inner.add_child(_button("Unequip %s (back to the bag)" % _item_name(worn), _on_unequip.bind(slot), Vector2(0, 50), 18))
    var ids: Array = party.inventory.keys()
    ids.sort()
    var count := 0
    for k in ids:
        var iid: String = str(k)
        var it: Dictionary = items.get(iid, {})
        if not _item_fits_slot(it, slot):
            continue
        count += 1
        var problem: String = sh.equip_problem(slot, iid, items)
        var cp: Array
        if problem == "":
            cp = _card(_on_equip.bind(slot, iid))
        else:
            cp = _card(_on_blocked.bind(problem))
        var holder: PanelContainer = cp[0]
        var cbox: VBoxContainer = cp[1]
        cbox.add_child(_label("%s   x%d" % [str(it.get("name", iid)), party.item_count(iid)], 19, _rarity_color(iid)))
        if problem == "":
            var after: Dictionary = sh.with_item(slot, iid, items).derived(db)
            cbox.add_child(_delta_row(current, after))
        else:
            cbox.add_child(_label("Cannot equip: %s" % problem, 15, COL_BAD))
            holder.modulate = Color(1.0, 1.0, 1.0, 0.7)
        cbox.add_child(_label(ItemInfo.item_line(iid, items, weapons, false), 14, COL_DIM))
        _seal(holder)
        inner.add_child(holder)
    if count == 0:
        inner.add_child(_label("Nothing in the bag fits this slot.", 16, COL_DIM))
        inner.add_child(_button("Open the Shop", _on_tab.bind(TAB_SHOP), Vector2(0, 50), 18))
    box.add_child(wrap)


## A read-only list of everything in the bag, so the player can see what they own without opening a slot.
func _fill_bag_overview(box: VBoxContainer) -> void:
    var items: Dictionary = db.get("items", {})
    var weapons: Dictionary = db.get("weapons", {})
    _add_section(box, "Bag")
    var ids: Array = party.inventory.keys()
    ids.sort()
    if ids.is_empty():
        box.add_child(_label("No spare gear. The Shop tab sells more.", 16, COL_DIM))
    for k in ids:
        var iid: String = str(k)
        var p := PanelContainer.new()
        p.add_theme_stylebox_override("panel", _style(COL_TILE, COL_BORDER_DIM, 1, 6, 8.0))
        var v := VBoxContainer.new()
        v.add_theme_constant_override("separation", 1)
        v.add_child(_label("%s   x%d" % [_item_name(iid), party.item_count(iid)], 17, _rarity_color(iid)))
        v.add_child(_label("%s: %s" % [ItemInfo.slot_name(str((items.get(iid, {}) as Dictionary).get("slot", ""))), ItemInfo.item_line(iid, items, weapons, false)], 14, COL_DIM))
        p.add_child(v)
        box.add_child(p)
    box.add_child(_label("runes in the bag: %d" % party.sigil_inv.size(), 15, COL_DIM))


# ---------------------------------------------------------------- Sigils tab

func _linked(sh: CharacterSheetScript, group: String, a: int, b: int, items: Dictionary) -> bool:
    return sh.linked_indices(group, a, items).has(b)


func _fill_sigils(box: VBoxContainer) -> void:
    var sh: CharacterSheetScript = party.sheet(selected_id)
    if sh == null:
        return
    var items: Dictionary = db.get("items", {})
    var sdefs: Dictionary = db.get("runes", {})
    for group in CharacterSheetScript.SIGIL_GROUPS:
        var item_id: String = sh.item_in(group)
        var n: int = sh.socket_count(group, items)
        var head: String = "%s: %s" % [ItemInfo.slot_name(group), "- nothing equipped -" if item_id == "" else _item_name(item_id)]
        _add_section(box, head)
        if n > 0:
            box.add_child(_label("%d sockets, AP x%d (a better item levels runes faster)" % [n, sh.socket_ap_mult(group, items)], 15, COL_DIM))
        if n == 0:
            box.add_child(_label("This item has no sockets.", 16, COL_DIM))
            continue
        var flow := HFlowContainer.new()
        flow.add_theme_constant_override("h_separation", 10)
        flow.add_theme_constant_override("v_separation", 8)
        flow.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        var i := 0
        while i < n:
            var unit := HBoxContainer.new()
            unit.add_theme_constant_override("separation", 4)
            unit.add_child(_socket_button(sh, group, i, sdefs))
            if i + 1 < n and _linked(sh, group, i, i + 1, items):
                unit.add_child(_text("=", 28, COL_GOLD))
                unit.add_child(_socket_button(sh, group, i + 1, sdefs))
                i += 2
            else:
                i += 1
            flow.add_child(unit)
        box.add_child(flow)
        if group == focus_group and focus_index >= 0 and focus_index < n:
            _fill_socket_choices(box, sh, group, focus_index)


func _socket_button(sh: CharacterSheetScript, group: String, index: int, sdefs: Dictionary) -> Control:
    var inst: Dictionary = sh.sigil_at(group, index)
    var is_open: bool = group == focus_group and index == focus_index
    var cp: Array = _card(_on_socket.bind(group, index), is_open)
    var holder: PanelContainer = cp[0]
    var cbox: VBoxContainer = cp[1]
    holder.custom_minimum_size = Vector2(140, 80)
    holder.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
    if inst.is_empty():
        cbox.add_child(_label("Empty", 18, COL_DIM))
        cbox.add_child(_label("socket %d" % (index + 1), 14, COL_DIM))
    else:
        var sd: Dictionary = sdefs.get(str(inst.get("id", "")), {})
        cbox.add_child(_rune_icon(inst, 40))
        cbox.add_child(_label("%s · %s" % [ItemInfo.sigil_short(inst, sd), RuneSystem.grade_of(inst, sdefs).capitalize()], 17, COL_GOLD))
        cbox.add_child(_label(ItemInfo.sigil_ap_text(inst, sd), 14, COL_DIM))
    _seal(holder)
    return holder


func _fill_socket_choices(box: VBoxContainer, sh: CharacterSheetScript, group: String, index: int) -> void:
    var items: Dictionary = db.get("items", {})
    var sdefs: Dictionary = db.get("runes", {})
    var skills: Dictionary = db.get("skills", {})
    var inst: Dictionary = sh.sigil_at(group, index)
    var wrap := PanelContainer.new()
    wrap.add_theme_stylebox_override("panel", _style(COL_TILE, COL_BORDER, 1, 8, 8.0))
    var inner := VBoxContainer.new()
    inner.add_theme_constant_override("separation", 8)
    wrap.add_child(inner)
    if inst.is_empty():
        inner.add_child(_label("Socket %d is empty. Choose a rune from the bag:" % (index + 1), 17, COL_GOLD))
    else:
        var sd: Dictionary = sdefs.get(str(inst.get("id", "")), {})
        var lv: int = CharacterSheetScript.sigil_level(inst, sd)
        inner.add_child(_label(str(sd.get("name", "?")), 19, COL_GOLD))
        inner.add_child(_label(ItemInfo.sigil_progress(inst, sd), 16))
        inner.add_child(_label(ItemInfo.sigil_effect(sd, lv, skills), 15, COL_DIM))
        var linked_ap: int = sh.linked_support(group, index, items, sdefs, "ap_pct")
        if linked_ap > 0:
            inner.add_child(_label("Linked Tutor: +%d%% AP" % linked_ap, 15, COL_GOOD))
        inner.add_child(_button("Remove (back to the bag)", _on_unsocket.bind(group, index), Vector2(0, 50), 18))
        inner.add_child(_label("Or swap with a rune from the bag:", 16, COL_DIM))
    if party.sigil_inv.is_empty():
        inner.add_child(_label("The bag holds no runes. Buy one in the Shop tab, or master a rune to forge a copy.", 16, COL_DIM))
        inner.add_child(_button("Open the Shop", _on_tab.bind(TAB_SHOP), Vector2(0, 50), 18))
    for bag_i in range(party.sigil_inv.size()):
        var bi: Dictionary = party.sigil_inv[bag_i]
        var bd: Dictionary = sdefs.get(str(bi.get("id", "")), {})
        var blv: int = CharacterSheetScript.sigil_level(bi, bd)
        var cp: Array = _card(_on_socket_sigil.bind(group, index, bag_i))
        var holder: PanelContainer = cp[0]
        var cbox: VBoxContainer = cp[1]
        cbox.add_child(_rune_icon(bi, 40))
        cbox.add_child(_label("%s · %s" % [str(bd.get("name", "?")), RuneSystem.grade_of(bi, sdefs).capitalize()], 18, COL_GOLD))
        cbox.add_child(_label(ItemInfo.sigil_progress(bi, bd), 15))
        cbox.add_child(_label(ItemInfo.sigil_effect(bd, blv, skills), 14, COL_DIM))
        _seal(holder)
        inner.add_child(holder)
    box.add_child(wrap)


func _fill_forge(box: VBoxContainer) -> void:
    var rune_defs: Dictionary = db.get("runes", db.get("sigils", {}))
    _add_section(box, "Rune Fusion")
    box.add_child(_label("Three identical runes of the same grade are consumed. Success creates the next grade; failure returns one rune at its original grade.", 15, COL_DIM))
    var grouped: Dictionary = {}
    for inst0 in party.sigil_inv:
        var inst: Dictionary = inst0
        var id: String = str(inst.get("id", ""))
        var grade: String = RuneSystem.grade_of(inst, rune_defs)
        var key := id + "|" + grade
        grouped[key] = int(grouped.get(key, 0)) + 1
    var keys: Array = grouped.keys()
    keys.sort()
    if keys.is_empty():
        box.add_child(_label("No spare runes to combine.", 17, COL_DIM))
    for key0 in keys:
        var parts := str(key0).split("|")
        var id: String = parts[0]
        var grade: String = parts[1]
        var count: int = int(grouped[key0])
        var rd: Dictionary = rune_defs.get(id, {})
        var next: String = RuneSystem.next_grade(grade)
        var chance: int = RuneSystem.success_chance(next)
        var cp: Array = _card(_on_fuse_rune.bind(id, grade), false, count < 3 or next == "")
        var holder: PanelContainer = cp[0]
        var inner: VBoxContainer = cp[1]
        inner.add_child(_label("%s — %s" % [str(rd.get("name", id)), grade.capitalize()], 18, _rune_grade_color(grade)))
        inner.add_child(_label("%d available · %s" % [count, "MAX GRADE" if next == "" else "%d%% chance to become %s" % [chance, next.capitalize()]], 15, COL_DIM))
        inner.add_child(_label("Requires 3 matching runes" if count < 3 else ("Failure keeps 1 rune" if next != "" else "Already at highest grade"), 14, COL_BAD if count < 3 else COL_DIM))
        _seal(holder)
        box.add_child(holder)


func _rune_grade_color(grade: String) -> Color:
    return RARITY_COLORS.get(grade, COL_TEXT)


func _rune_icon(inst: Dictionary, size: int = 40) -> TextureRect:
    var rune_defs: Dictionary = db.get("runes", db.get("sigils", {}))
    var rd: Dictionary = rune_defs.get(str(inst.get("id", "")), {})
    var rune_type: String = str(rd.get("rune_type", "arcane"))
    var columns := {"arcane":0,"vitality":1,"flame":2,"frost":3,"holy":4,"shadow":5,"storm":6,"earth":7,"wind":7,"fortune":1}
    var grades: Array[String] = ["common","uncommon","rare","epic","legendary","mythical"]
    var col: int = int(columns.get(rune_type, 0))
    var row: int = maxi(0, grades.find(RuneSystem.grade_of(inst, rune_defs)))
    var atlas := AtlasTexture.new()
    atlas.atlas = load("res://assets/art/runes/rune_atlas.svg")
    atlas.region = Rect2(col * 40, row * 40, 40, 40)
    var icon := TextureRect.new()
    icon.texture = atlas
    icon.custom_minimum_size = Vector2(size, size)
    icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
    return icon


func _on_fuse_rune(rune_id: String, grade: String) -> void:
    var result: Dictionary = party.fuse_runes(rune_id, grade, db, rune_rng)
    if not bool(result.get("ok", false)):
        _after(str(result.get("error", "Fusion could not be performed.")))
        return
    _after(str(result.get("message", "Fusion complete.")), bool(result.get("success", false)))


# ---------------------------------------------------------------- Shop tab

func _price_card(handler: Callable, title: String, title_color: Color, desc: String, price_text: String, price_color: Color, disabled: bool, note: String = "", selected: bool = false) -> Control:
    var cp: Array = _card(handler, selected, disabled)
    var holder: PanelContainer = cp[0]
    var cbox: VBoxContainer = cp[1]
    var row := HBoxContainer.new()
    row.add_theme_constant_override("separation", 10)
    var texts := VBoxContainer.new()
    texts.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    texts.add_theme_constant_override("separation", 1)
    texts.add_child(_label(title, 19, title_color))
    if desc != "":
        texts.add_child(_label(desc, 14, COL_DIM))
    row.add_child(texts)
    var right := VBoxContainer.new()
    right.add_theme_constant_override("separation", 0)
    var price := _text(price_text, 20, price_color)
    price.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
    right.add_child(price)
    if note != "":
        var nl := _text(note, 13, COL_BAD)
        nl.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
        right.add_child(nl)
    row.add_child(right)
    cbox.add_child(row)
    _seal(holder)
    return holder


func _fill_shop(box: VBoxContainer) -> void:
    var items: Dictionary = db.get("items", {})
    var sdefs: Dictionary = db.get("runes", {})
    var weapons: Dictionary = db.get("weapons", {})
    var skills: Dictionary = db.get("skills", {})
    var mode_row := HBoxContainer.new()
    mode_row.add_theme_constant_override("separation", 8)
    mode_row.add_child(_tab_button("Buy", _on_shop_mode.bind(false), not shop_selling))
    mode_row.add_child(_tab_button("Sell", _on_shop_mode.bind(true), shop_selling))
    box.add_child(mode_row)
    _add_section(box, str(shop.get("name", "Shop")))
    if not shop_selling:
        for entry in ShopSystem.stock(shop, db):
            var e: Dictionary = entry
            var kind: String = str(e["kind"])
            var id: String = str(e["id"])
            var price: int = int(e["price"])
            var afford: bool = party.gold >= price
            var desc: String = ""
            var name_col: Color = COL_TEXT
            if kind == "item":
                desc = ItemInfo.slot_name(str((items.get(id, {}) as Dictionary).get("slot", ""))) + ": " + ItemInfo.item_line(id, items, weapons, false)
                name_col = _rarity_color(id)
            else:
                var sd: Dictionary = sdefs.get(id, {})
                var th: Array = sd.get("ap", [])
                var ap_list: Array[String] = []
                for t in th:
                    ap_list.append(str(int(t)))
                desc = "%s.  AP to level up: %s" % [ItemInfo.sigil_effect(sd, 1, skills), " / ".join(PackedStringArray(ap_list))]
                name_col = COL_GOLD
            var note: String = ""
            var price_col: Color = COL_GOLD
            if not afford:
                note = "need %d more" % (price - party.gold)
                price_col = COL_BAD
            var key: String = "buy:%s:%s" % [kind, id]
            var picked: bool = shop_pick == key
            box.add_child(_price_card(_on_shop_pick.bind(key), str(e["name"]), name_col, desc, "%d g" % price, price_col, false, note, picked))
            if picked:
                var confirm_text: String = "Confirm: buy for %d g" % price
                if not afford:
                    confirm_text = "Not enough gold (need %d more)" % (price - party.gold)
                _fill_shop_detail(box, kind, id, _on_confirm_buy.bind(kind, id), confirm_text, afford, false)
        return
    box.add_child(_label("Selling pays %d%% of the price. Equipped gear is not listed; heirlooms cannot be sold." % roundi(ShopSystem.sell_ratio(shop) * 100.0), 15, COL_DIM))
    var ids: Array = party.inventory.keys()
    ids.sort()
    var listed := 0
    for k in ids:
        var iid: String = str(k)
        var it: Dictionary = items.get(iid, {})
        var base_price: int = int(it.get("price", 0))
        var sellable: bool = base_price > 0 and str(it.get("rarity", "")) != "heirloom" and str(it.get("bound_to", "")) == ""
        var sell_for: int = ShopSystem.sell_price(base_price, shop)
        var skey: String = "sell:item:" + iid
        var spicked: bool = shop_pick == skey
        var title: String = "%s   x%d" % [str(it.get("name", iid)), party.item_count(iid)]
        var price_text: String = "%d g" % sell_for
        var snote: String = ""
        if not sellable:
            price_text = "-"
            snote = "cannot be sold"
        box.add_child(_price_card(_on_shop_pick.bind(skey), title, _rarity_color(iid), ItemInfo.item_line(iid, items, weapons, false), price_text, COL_GOLD if sellable else COL_DIM, not sellable, snote, spicked))
        if spicked and sellable:
            _fill_shop_detail(box, "item", iid, _on_confirm_sell_item.bind(iid), "Confirm: sell for %d g" % sell_for, true, true)
        listed += 1
    for bag_i in range(party.sigil_inv.size()):
        var bi: Dictionary = party.sigil_inv[bag_i]
        var bd: Dictionary = sdefs.get(str(bi.get("id", "")), {})
        var sigil_for: int = ShopSystem.sell_price(int(bd.get("price", 0)), shop)
        var gkey: String = "sell:rune:%d" % bag_i
        var gpicked: bool = shop_pick == gkey
        box.add_child(_price_card(_on_shop_pick.bind(gkey), str(bd.get("name", "?")), COL_GOLD, ItemInfo.sigil_progress(bi, bd), "%d g" % sigil_for, COL_GOLD, false, "", gpicked))
        if gpicked:
            _fill_shop_detail(box, "rune", "", _on_confirm_sell_sigil.bind(bag_i), "Confirm: sell for %d g" % sigil_for, true, true)
        listed += 1
    if listed == 0:
        box.add_child(_label("Nothing to sell.", 17, COL_DIM))


## The open card's panel: a gear comparison (buying gear), a short note, and the Cancel / Confirm buttons.
func _fill_shop_detail(box: VBoxContainer, kind: String, id: String, confirm: Callable, confirm_text: String, can_confirm: bool, selling: bool) -> void:
    var wrap := PanelContainer.new()
    wrap.add_theme_stylebox_override("panel", _style(COL_TILE, COL_GOLD.darkened(0.2), 2, 8, 10.0))
    var inner := VBoxContainer.new()
    inner.add_theme_constant_override("separation", 8)
    wrap.add_child(inner)
    if selling:
        inner.add_child(_label("Selling removes it from the bag for good.", 15, COL_DIM))
    elif kind == "item":
        _add_compare(inner, id)
    else:
        inner.add_child(_label("runes go into the sockets of a weapon or armor (runes tab).", 15, COL_DIM))
    var row := HBoxContainer.new()
    row.add_theme_constant_override("separation", 8)
    var cancel := _button("Cancel", _on_shop_pick.bind(shop_pick), Vector2(130, 54), 19)
    row.add_child(cancel)
    var ok := _button(confirm_text, confirm, Vector2(0, 54), 19, true)
    ok.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    ok.disabled = not can_confirm
    row.add_child(ok)
    inner.add_child(row)
    box.add_child(wrap)


## The slot an item would go into for this hero: the item's own slot, or the first free (else first) accessory slot.
func _best_slot(sh: CharacterSheetScript, item_slot: String) -> String:
    if item_slot != "accessory":
        return item_slot
    if sh.item_in("accessory1") == "" or sh.item_in("accessory2") != "":
        return "accessory1"
    return "accessory2"


## Stat changes if the selected hero wore `item_id` (every slot it fits), then a line per other hero.
func _add_compare(inner: VBoxContainer, item_id: String) -> void:
    var items: Dictionary = db.get("items", {})
    var sh: CharacterSheetScript = party.sheet(selected_id)
    var it: Dictionary = items.get(item_id, {})
    if sh == null or it.is_empty():
        return
    var item_slot: String = str(it.get("slot", ""))
    var slots: Array = [item_slot]
    if item_slot == "accessory":
        slots = ["accessory1", "accessory2"]
    var current: Dictionary = sh.derived(db)
    inner.add_child(_label("If %s wore it (use < > on the sheet to pick another hero):" % sh.display_name, 16, COL_GOLD))
    for slot in slots:
        var worn: String = sh.item_in(slot)
        var worn_text: String = "empty slot"
        if worn != "":
            worn_text = "replaces " + _item_name(worn)
        inner.add_child(_label("%s - %s" % [ItemInfo.slot_name(slot), worn_text], 15, COL_DIM))
        var problem: String = sh.equip_problem(slot, item_id, items)
        if problem != "":
            inner.add_child(_label("Cannot be used: %s" % problem, 15, COL_BAD))
        else:
            inner.add_child(_delta_row(current, sh.with_item(slot, item_id, items).derived(db)))
    if party.roster.size() > 1:
        inner.add_child(_label("Other heroes", 16, COL_GOLD))
        for rid in party.roster:
            if rid == selected_id:
                continue
            var other: CharacterSheetScript = party.sheet(rid)
            var oslot: String = _best_slot(other, item_slot)
            var line := HBoxContainer.new()
            line.add_theme_constant_override("separation", 10)
            var nm := _text(other.display_name, 15, COL_TEXT)
            nm.custom_minimum_size = Vector2(130, 0)
            nm.clip_text = true
            line.add_child(nm)
            var oproblem: String = other.equip_problem(oslot, item_id, items)
            if oproblem != "":
                line.add_child(_label("cannot use it", 15, COL_BAD))
            else:
                line.add_child(_delta_row(other.derived(db), other.with_item(oslot, item_id, items).derived(db)))
            inner.add_child(line)


# ---------------------------------------------------------------- actions (each ends in a rebuild)

func _after(text: String, did_change: bool = false) -> void:
    message = text
    message_ok = did_change
    if did_change:
        changed = true
    _rebuild()


func _on_select(id: String) -> void:
    selected_id = id
    focus_slot = ""
    focus_group = ""
    focus_index = -1
    shop_pick = ""
    reset_scroll = true
    reset_sheet = true
    _after("")


## The < and > buttons on the sheet: previous / next character in the roster.
func _on_step(direction: int) -> void:
    if party.roster.is_empty():
        return
    var idx: int = party.roster.find(selected_id)
    if idx < 0:
        idx = 0
    _on_select(party.roster[posmod(idx + direction, party.roster.size())])


func _on_tab(t: int) -> void:
    if t == TAB_SHOP and not shop_access_allowed:
        return
    tab = t
    focus_slot = ""
    focus_group = ""
    focus_index = -1
    shop_pick = ""
    reset_scroll = true
    _after("")


func _on_slot(slot: String) -> void:
    focus_slot = "" if focus_slot == slot else slot
    _after("")


func _on_equip(slot: String, item_id: String) -> void:
    var problem: String = party.equip(selected_id, slot, item_id, db)
    if problem != "":
        _after(problem)
        return
    focus_slot = ""
    _after("Equipped %s." % _item_name(item_id), true)


func _on_unequip(slot: String) -> void:
    var old: String = party.sheet(selected_id).item_in(slot)
    var problem: String = party.unequip(selected_id, slot, db)
    if problem != "":
        _after(problem)
        return
    focus_slot = ""
    _after("Took off %s." % _item_name(old), true)


func _on_blocked(reason: String) -> void:
    _after(reason)


func _on_socket(group: String, index: int) -> void:
    if focus_group == group and focus_index == index:
        focus_group = ""
        focus_index = -1
    else:
        focus_group = group
        focus_index = index
    _after("")


func _on_socket_sigil(group: String, index: int, bag_index: int) -> void:
    var sigil_name: String = _bag_sigil_name(bag_index)
    var problem: String = party.equip_sigil(selected_id, group, index, bag_index, db)
    if problem != "":
        _after(problem)
        return
    _after("Socketed %s." % sigil_name, true)


func _on_unsocket(group: String, index: int) -> void:
    var problem: String = party.unequip_sigil(selected_id, group, index, db)
    if problem != "":
        _after(problem)
        return
    _after("rune returned to the bag.", true)


func _on_shop_mode(selling: bool) -> void:
    shop_selling = selling
    shop_pick = ""
    reset_scroll = true
    _after("")


func _on_buy(kind: String, id: String) -> void:
    var problem: String = ""
    var shown: String = id
    if kind == "item":
        problem = ShopSystem.buy_item(party, id, db, shop)
        shown = _item_name(id)
    else:
        problem = ShopSystem.buy_rune(party, id, db, shop)
        shown = str(_sigil_def(id).get("name", id))
    if problem != "":
        _after(problem)
        return
    _after("Bought %s." % shown, true)


## Opens (or closes) a shop card: its comparison and its Confirm / Cancel buttons.
func _on_shop_pick(key: String) -> void:
    if shop_pick == key:
        shop_pick = ""
    else:
        shop_pick = key
    _after("")


func _on_confirm_buy(kind: String, id: String) -> void:
    shop_pick = ""
    _on_buy(kind, id)


func _on_confirm_sell_item(item_id: String) -> void:
    shop_pick = ""
    _on_sell_item(item_id)


func _on_confirm_sell_sigil(bag_index: int) -> void:
    shop_pick = ""
    _on_sell_sigil(bag_index)


func _on_sell_item(item_id: String) -> void:
    var shown: String = _item_name(item_id)
    var problem: String = ShopSystem.sell_item(party, item_id, db, shop)
    if problem != "":
        _after(problem)
        return
    _after("Sold %s." % shown, true)


func _on_sell_sigil(bag_index: int) -> void:
    var shown: String = _bag_sigil_name(bag_index)
    var problem: String = ShopSystem.sell_rune(party, bag_index, db, shop)
    if problem != "":
        _after(problem)
        return
    _after("Sold %s." % shown, true)


func _on_promote(class_id: String) -> void:
    var sh: CharacterSheetScript = party.sheet(selected_id)
    if sh != null and sh.promote(class_id, db.get("classes", {})):
        _after("%s is now a %s." % [sh.display_name, _class_title(class_id)], true)
    else:
        _after("Promotion is not possible.")
