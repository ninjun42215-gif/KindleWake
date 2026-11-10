class_name EmpireAdministration
extends Control
## Touch-first royal administration overlay. All economy mutations route through EmpireSystem/GameState.
signal closed

const BUILDINGS := {
    "farms": "Granaries & Farms  ·  120",
    "market": "Chartered Market  ·  180",
    "barracks": "Barracks  ·  220",
    "roads": "Road Network  ·  160",
    "fort": "Border Keep  ·  260",
    "aqueduct": "Aqueduct  ·  240",
    "depot": "Supply Depot  ·  210"
}
const ROLES := {
    "steward": "Steward",
    "marshal": "Marshal",
    "spymaster": "Spymaster",
    "chancellor": "Chancellor",
    "high_priest": "High Priest"
}
const POLICIES := {
    "relief": "Relief & Granary Subsidies",
    "development": "Provincial Development",
    "conscription": "Expanded Conscription",
    "mercantile": "Mercantile Charters",
    "tolerance": "Religious Tolerance"
}
const C_BG := Color("#111a20")
const C_PANEL := Color("#202c31")
const C_CARD := Color("#2b393c")
const C_GOLD := Color("#d2ad70")
const C_TEXT := Color("#f0e6d1")
const C_DIM := Color("#b5b5a7")
const C_GREEN := Color("#9acb9b")
const C_RED := Color("#d98d7f")

var active_tab := "realm"
var selected_province := ""
var selected_commander := ""
var message := ""
var message_good := true
var body: VBoxContainer
var title_label: Label
var message_label: Label
var stats_label: Label
var scroll: ScrollContainer
var tabs: HBoxContainer
var tab_scroll: ScrollContainer


func _ready() -> void:
    set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    visible = false


func open() -> void:
    if not bool(GameState.empire_state.get("unlocked", false)):
        return
    active_tab = "realm"
    message = ""
    visible = true
    _rebuild()


func close() -> void:
    visible = false
    closed.emit()


func _unhandled_input(event: InputEvent) -> void:
    if visible and event.is_action_pressed("ui_cancel"):
        get_viewport().set_input_as_handled()
        close()


func _style(bg: Color, border: Color = C_GOLD) -> StyleBoxFlat:
    var s := StyleBoxFlat.new()
    s.bg_color = bg
    s.border_color = border
    s.set_border_width_all(1)
    s.set_corner_radius_all(7)
    s.set_content_margin_all(10)
    return s


func _label(text: String, size: int = 17, color: Color = C_TEXT) -> Label:
    var l := Label.new()
    l.text = text
    l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    l.add_theme_font_size_override("font_size", size)
    l.add_theme_color_override("font_color", color)
    return l


func _button(text: String, action: Callable, primary: bool = false) -> Button:
    var b := Button.new()
    b.text = text
    b.custom_minimum_size = Vector2(0, 48)
    b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    b.add_theme_font_size_override("font_size", 16)
    b.add_theme_color_override("font_color", C_TEXT)
    b.add_theme_stylebox_override("normal", _style(C_CARD if not primary else Color("#59452d")))
    b.add_theme_stylebox_override("pressed", _style(Color("#3c3327")))
    b.pressed.connect(action)
    return b


func _rebuild() -> void:
    for child in get_children():
        child.queue_free()
    var backdrop := ColorRect.new()
    backdrop.color = Color(0.025, 0.04, 0.05, 0.94)
    backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    add_child(backdrop)
    var center := CenterContainer.new()
    center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    center.offset_left = 10
    center.offset_top = 10
    center.offset_right = -10
    center.offset_bottom = -10
    add_child(center)
    var panel := PanelContainer.new()
    panel.custom_minimum_size = Vector2(300, 0)
    panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
    panel.add_theme_stylebox_override("panel", _style(C_BG))
    center.add_child(panel)
    var outer := VBoxContainer.new()
    outer.add_theme_constant_override("separation", 8)
    panel.add_child(outer)
    var top := HBoxContainer.new()
    var heading := _label("ROYAL ADMINISTRATION", 22, C_GOLD)
    top.add_child(heading)
    var spacer := Control.new()
    spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    top.add_child(spacer)
    top.add_child(_button("✕", close))
    outer.add_child(top)
    stats_label = _label(_resource_summary(), 15, C_DIM)
    outer.add_child(stats_label)
    tab_scroll = ScrollContainer.new()
    tab_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
    tab_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
    tab_scroll.custom_minimum_size.y = 48
    outer.add_child(tab_scroll)
    tabs = HBoxContainer.new()
    tabs.add_theme_constant_override("separation", 5)
    tab_scroll.add_child(tabs)
    for tab in ["realm", "council", "provinces", "military", "economy", "chronicle"]:
        tabs.add_child(_button(tab.capitalize(), _select_tab.bind(tab), tab == active_tab))
    scroll = ScrollContainer.new()
    scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
    scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
    outer.add_child(scroll)
    body = VBoxContainer.new()
    body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    body.add_theme_constant_override("separation", 10)
    scroll.add_child(body)
    message_label = _label(message, 15, C_GREEN if message_good else C_RED)
    if message != "":
        outer.add_child(message_label)
    match active_tab:
        "realm": _build_realm()
        "council": _build_council()
        "provinces": _build_provinces()
        "military": _build_military()
        "economy": _build_economy()
        "chronicle": _build_chronicle()


func _select_tab(tab: String) -> void:
    active_tab = tab
    _rebuild()


func _resource_summary() -> String:
    var s: Dictionary = GameState.empire_state
    return "Treasury  %d   ·   Food  %d   ·   Manpower  %d   ·   Season  %d" % [
        int(s.get("treasury", 0)), int(s.get("food", 0)), int(s.get("manpower", 0)), int(s.get("turn", 0))
    ]


func _section(text: String) -> void:
    body.add_child(_label(text, 19, C_GOLD))


func _metric(label: String, value: String, detail: String = "") -> void:
    var panel := PanelContainer.new()
    panel.add_theme_stylebox_override("panel", _style(C_PANEL, Color("#65583f")))
    var box := VBoxContainer.new()
    panel.add_child(box)
    box.add_child(_label(label.to_upper(), 13, C_DIM))
    box.add_child(_label(value, 24, C_TEXT))
    if detail != "":
        box.add_child(_label(detail, 14, C_DIM))
    body.add_child(panel)


func _build_realm() -> void:
    var s: Dictionary = GameState.empire_state
    _section(str(s.get("realm_name", "The Crownlands")))
    _metric("Stability", "%d / 100" % int(s.get("stability", 0)), "Public order: %d / 100" % int(s.get("public_order", 0)))
    _metric("Legitimacy", "%d / 100" % int(s.get("legitimacy", 0)), "The people's confidence in the Crown")
    _metric("Treasury & stores", "%d gold  ·  %d food" % [int(s.get("treasury", 0)), int(s.get("food", 0))])
    _metric("Military reserves", "%d manpower" % int(s.get("manpower", 0)), "Available reserve, not an army in the field")
    _section("THE SEASONAL LEDGER")
    body.add_child(_label("Seasons advance only when you command it. Review the projected consequences before advancing.", 15, C_DIM))
    body.add_child(_button("ADVANCE ONE SEASON", _advance_season, true))
    body.add_child(_button("View council appointments", _select_tab.bind("council")))
    body.add_child(_button("Inspect provinces", _select_tab.bind("provinces")))


func _build_council() -> void:
    _section("THE FIVE OFFICES OF THE CROWN")
    body.add_child(_label("Appoint companions from your current company. Their traits and loyalty will shape their future effectiveness as the council system expands.", 15, C_DIM))
    var council: Dictionary = GameState.empire_state.get("council", {})
    for role in ROLES.keys():
        var assigned := str(council.get(role, ""))
        var name := _character_name(assigned) if assigned != "" else "Vacant"
        var panel := PanelContainer.new()
        panel.add_theme_stylebox_override("panel", _style(C_PANEL))
        var box := VBoxContainer.new()
        panel.add_child(box)
        box.add_child(_label(str(ROLES[role]), 18, C_GOLD))
        box.add_child(_label("Current officeholder: " + name, 15))
        var picker := OptionButton.new()
        picker.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        picker.add_item("Select a companion")
        for id in GameState.party.roster:
            picker.add_item(_character_name(id), picker.item_count)
            picker.set_item_metadata(picker.item_count - 1, id)
        box.add_child(picker)
        var appoint := _button("Appoint", _appoint_role.bind(role, picker))
        box.add_child(appoint)
        if assigned != "":
            box.add_child(_button("Dismiss officeholder", _dismiss_role.bind(role)))
        body.add_child(panel)


func _build_provinces() -> void:
    _section("PROVINCES OF THE KNOWN ATLAS")
    var territories: Dictionary = GameState.faction_state.get("territories", {})
    var region_ids: Array = GameData.factions.get("regions", {}).keys()
    region_ids.sort()
    if selected_province == "" and not region_ids.is_empty():
        selected_province = str(region_ids[0])
    for id_variant in region_ids:
        var id := str(id_variant)
        var territory: Dictionary = territories.get(id, {})
        var owner_id := str(territory.get("owner", ""))
        var owner := _faction_name(owner_id)
        var title := id.replace("_", " ").capitalize()
        var is_selected := id == selected_province
        body.add_child(_button("%s   ·   %s" % [title, owner], _select_province.bind(id), is_selected))
    if selected_province == "":
        return
    var province := selected_province
    _section(province.replace("_", " ").capitalize() + " — Administration")
    var governor := str(GameState.empire_state.get("governors", {}).get(province, ""))
    var controlled := GameState.player_controlled_provinces().has(province)
    body.add_child(_label("Governor: " + (_character_name(governor) if governor != "" else "Unappointed"), 16))
    if not controlled:
        body.add_child(_label("This province is not under your authority. Secure it through campaign events before appointing officials or commissioning works.", 15, C_RED))
    var picker := OptionButton.new()
    picker.add_item("Choose governor")
    for id in GameState.party.roster:
        picker.add_item(_character_name(id))
        picker.set_item_metadata(picker.item_count - 1, id)
    body.add_child(picker)
    var appoint_button := _button("Appoint governor", _appoint_governor.bind(province, picker))
    appoint_button.disabled = not controlled
    body.add_child(appoint_button)
    if governor != "":
        var recall_button := _button("Recall governor", _recall_governor.bind(province))
        recall_button.disabled = not controlled
        body.add_child(recall_button)
    _section("CONSTRUCTION")
    var built: Dictionary = GameState.empire_state.get("buildings", {})
    for building_id in BUILDINGS.keys():
        var key := province + ":" + building_id
        var exists := built.has(key)
        var build_button := _button(("Built  ·  " if exists else "Construct  ·  ") + str(BUILDINGS[building_id]), _construct.bind(province, building_id), not exists)
        build_button.disabled = exists or not controlled
        body.add_child(build_button)


func _build_military() -> void:
    _section("THE REALM'S STANDING FORCES")
    var summary: Dictionary = GameState.empire_army_summary()
    _metric("Troop strength", "%d soldiers" % int(summary.get("troops", 0)), "%d provincial garrisons" % int(summary.get("garrisoned_provinces", 0)))
    var deployed: Dictionary = GameState.field_army_summary()
    _metric("Field deployments", "%d armies · %d soldiers" % [int(deployed.get("armies", 0)), int(deployed.get("troops", 0))], "%d unsupplied armies" % int(deployed.get("unsupplied", 0)))
    _metric("Seasonal military burden", "%d gold · %d food" % [int(summary.get("upkeep", 0)), int(summary.get("food", 0))], "Readiness estimate: %d%% based on current food reserves" % int(summary.get("readiness", 100)))
    _section("SELECT GARRISON PROVINCE")
    var region_ids: Array = GameData.factions.get("regions", {}).keys()
    region_ids.sort()
    if selected_province == "" and not region_ids.is_empty():
        selected_province = str(region_ids[0])
    for region_variant in region_ids:
        var province_id := str(region_variant)
        var territory: Dictionary = GameState.faction_state.get("territories", {}).get(province_id, {})
        var owner := _faction_name(str(territory.get("owner", "")))
        body.add_child(_button("%s · %s" % [province_id.replace("_", " ").capitalize(), owner], _select_province.bind(province_id), selected_province == province_id))
    if selected_province == "":
        return
    var controlled := GameState.player_controlled_provinces().has(selected_province)
    var garrison: Dictionary = GameState.empire_state.get("armies", {}).get(selected_province, {})
    _section(selected_province.replace("_", " ").capitalize() + " Garrison")
    body.add_child(_label("Infantry: %d · Archers: %d · Cavalry: %d" % [int(garrison.get("infantry", 0)), int(garrison.get("archers", 0)), int(garrison.get("cavalry", 0))], 16))
    if not controlled:
        body.add_child(_label("This province is not under your authority. Recruitment and disbandment are disabled.", 15, C_RED))
    for troop_type in ["infantry", "archers", "cavalry"]:
        var title := {"infantry": "Levy Infantry", "archers": "March Archers", "cavalry": "Household Cavalry"}[troop_type]
        var cost := {"infantry": "1 manpower · 4 gold", "archers": "1 manpower · 6 gold", "cavalry": "2 manpower · 12 gold"}[troop_type]
        body.add_child(_label(title + " — " + cost + " each", 15, C_GOLD))
        var actions := HBoxContainer.new()
        actions.add_child(_button("Recruit 5", _recruit_troops.bind(selected_province, troop_type, 5), true))
        actions.add_child(_button("Disband 5", _disband_troops.bind(selected_province, troop_type, 5)))
        for child in actions.get_children():
            child.disabled = not controlled or (child.text.begins_with("Disband") and int(garrison.get(troop_type, 0)) < 5)
        body.add_child(actions)
    if controlled and int(garrison.get("infantry", 0)) >= 5:
        var commander_picker := OptionButton.new()
        commander_picker.custom_minimum_size.y = 44
        commander_picker.add_item("No Commander")
        commander_picker.set_item_metadata(0, "")
        var commander_index := 0
        for character_id in GameState.party.roster:
            commander_picker.add_item(_character_name(str(character_id)))
            commander_picker.set_item_metadata(commander_picker.item_count - 1, str(character_id))
            if str(character_id) == selected_commander:
                commander_index = commander_picker.item_count - 1
        commander_picker.select(commander_index)
        commander_picker.item_selected.connect(_select_field_commander.bind(commander_picker))
        body.add_child(_label("Appoint a party character to command the new field army:", 14, C_DIM))
        body.add_child(commander_picker)
        body.add_child(_button("Mobilize 5 Infantry into Field Army", _mobilize_field_army.bind(selected_province, {"infantry": 5}), true))
    body.add_child(_label("Garrisons defend their province. Mobilized field armies travel one atlas region-link per strategic move. Armies outside controlled territory are unsupplied.", 14, C_DIM))
    _section("FIELD ARMIES")
    var field_armies: Dictionary = GameState.empire_state.get("field_armies", {})
    var adjacency: Dictionary = GameState.atlas_region_adjacency()
    if field_armies.is_empty():
        body.add_child(_label("No field armies have been mobilized.", 15, C_DIM))
    for army_id in field_armies.keys():
        var army: Dictionary = field_armies[army_id]
        var location := str(army.get("location", ""))
        var composition: Dictionary = army.get("troops", {})
        var total := 0
        for amount in composition.values():
            total += int(amount)
        _metric(str(army.get("name", army_id)), "%d soldiers · %s" % [total, location.replace("_", " ").capitalize()], "Commander: %s · %s" % [str(army.get("commander", "Unassigned")) if str(army.get("commander", "")) != "" else "Unassigned", "Supplied" if bool(army.get("supplied", false)) else "Unsupplied"])
        for destination in adjacency.get(location, []):
            body.add_child(_button("March to " + str(destination).replace("_", " ").capitalize(), _move_field_army.bind(str(army_id), str(destination)), true))
        if not GameState.player_controlled_provinces().has(location) and not GameState.empire_state.get("sieges", {}).has(location):
            body.add_child(_button("Begin siege of " + location.replace("_", " ").capitalize(), _start_siege.bind(str(army_id), location), true))
    _section("ACTIVE SIEGES")
    var sieges: Dictionary = GameState.empire_state.get("sieges", {})
    if sieges.is_empty():
        body.add_child(_label("No provinces are currently under siege.", 14, C_DIM))
    for region_id in sieges.keys():
        var siege: Dictionary = sieges[region_id]
        body.add_child(_label("%s · Progress %d/4 · %s" % [str(region_id).replace("_", " ").capitalize(), int(siege.get("progress", 0)), str(siege.get("status", "besieging")).replace("_", " ").capitalize()], 15, C_GOLD))
        if bool(siege.get("captured", false)):
            body.add_child(_button("Confirm occupation", _confirm_occupation.bind(str(region_id)), true))
        elif int(siege.get("progress", 0)) >= 4:
            body.add_child(_button("Assault breached defences", _assault_siege.bind(str(region_id)), true))


func _start_siege(army_id: String, region_id: String) -> void:
    var ok: bool = GameState.start_province_siege(army_id, region_id)
    _set_message("The siege lines are established." if ok else "Cannot establish a siege here. The army must occupy a hostile region adjacent to your supply network.", ok)
    GameState.save_campaign("auto_a")


func _assault_siege(region_id: String) -> void:
    var result: Dictionary = GameState.resolve_province_siege(region_id, 30, 1)
    var ok: bool = bool(result.get("ok", false))
    if ok:
        message = "Assault %s · %d casualties · war exhaustion %d." % ["succeeded" if bool(result.get("won", false)) else "repulsed", int(result.get("casualties", 0)), int(result.get("war_exhaustion", 0))]
    else:
        message = "The siege assault cannot proceed: " + str(result.get("reason", "unknown"))
    message_good = ok and bool(result.get("won", false))
    GameState.save_campaign("auto_a")
    _rebuild()


func _confirm_occupation(region_id: String) -> void:
    var ok: bool = GameState.confirm_siege_occupation(region_id)
    _set_message("The province is transferred to your faction." if ok else "Occupation transfer failed; check faction control.", ok)
    GameState.save_campaign("auto_a")


func _select_field_commander(index: int, picker: OptionButton) -> void:
    selected_commander = str(picker.get_item_metadata(index))


func _mobilize_field_army(province: String, composition: Dictionary) -> void:
    var army_id := GameState.mobilize_field_army(province, composition, selected_commander)
    _set_message("Mobilized %s from %s." % [army_id, province] if army_id != "" else "Mobilization rejected: check garrison strength and province control.", army_id != "")
    GameState.save_campaign("auto_a")


func _move_field_army(army_id: String, destination: String) -> void:
    var ok := GameState.move_field_army(army_id, destination)
    _set_message("Army marched to %s." % destination.replace("_", " ").capitalize() if ok else "March rejected: destination is not linked or the army has already moved.", ok)
    GameState.save_campaign("auto_a")


func _recruit_troops(province: String, troop_type: String, amount: int) -> void:
    var ok := GameState.recruit_provincial_troops(province, troop_type, amount)
    _set_message("Recruited %d %s." % [amount, troop_type] if ok else "Recruitment rejected: check manpower, treasury, capacity and province control.", ok)
    GameState.save_campaign("auto_a")


func _disband_troops(province: String, troop_type: String, amount: int) -> void:
    var ok := GameState.disband_provincial_troops(province, troop_type, amount)
    _set_message("Disbanded %d %s." % [amount, troop_type] if ok else "Disbandment rejected: not enough troops in this garrison.", ok)
    GameState.save_campaign("auto_a")


func _build_economy() -> void:
    var s: Dictionary = GameState.empire_state
    _section("TAXATION")
    body.add_child(_label("Current tax policy: " + str(s.get("tax_rate", "normal")).capitalize(), 16))
    for rate in ["low", "normal", "high"]:
        var effect := "Less income, improved public order" if rate == "low" else ("Balanced income and order" if rate == "normal" else "More income, but public order and legitimacy decline")
        body.add_child(_button(rate.capitalize() + " Tax  ·  " + effect, _set_tax.bind(rate), str(s.get("tax_rate", "normal")) == rate))
    _section("ROYAL EDICTS")
    var enabled: Array = s.get("policies", [])
    for policy in POLICIES.keys():
        var on: bool = enabled.has(policy)
        body.add_child(_button(("[ACTIVE]  " if on else "[INACTIVE]  ") + str(POLICIES[policy]), _toggle_policy.bind(policy), on))
    body.add_child(_label("Edicts are strategic trade-offs. Relief costs treasury; conscription and commerce change the seasonal balance.", 14, C_DIM))


func _build_chronicle() -> void:
    _section("THE CROWN'S RECENT DECISIONS")
    var history: Array = GameState.empire_state.get("history", [])
    if history.is_empty():
        body.add_child(_label("No royal decisions have yet been entered into the chronicle.", 16, C_DIM))
        return
    for i in range(history.size() - 1, -1, -1):
        var entry: Dictionary = history[i]
        body.add_child(_label("Season %d  ·  %s\n%s" % [
            int(entry.get("turn", 0)), str(entry.get("kind", "event")).replace("_", " ").capitalize(),
            JSON.stringify(entry.get("details", {}))
        ], 14))


func _advance_season() -> void:
    var report: Dictionary = GameState.advance_empire_season()
    if not bool(report.get("ok", false)):
        _set_message("The realm is not yet unlocked.", false)
        return
    var result := "Season %d: +%d gold income, %d total upkeep (army: %d), food change %d (army rations: %d), %d soldiers maintained." % [
        int(report.get("season", 0)), int(report.get("income", 0)), int(report.get("upkeep", 0)), int(report.get("military_upkeep", 0)), int(report.get("food_change", 0)), int(report.get("military_food", 0)), int(report.get("troops", 0))
    ]
    if bool(report.get("food_shortage", false)):
        result += " Famine threatens public order!"
    if int(report.get("sieges_advanced", 0)) > 0:
        result += " %d siege operation(s) advanced; %d breached." % [int(report.get("sieges_advanced", 0)), int(report.get("sieges_completed", 0))]
    if int(report.get("supply_losses", 0)) > 0:
        result += " Supply attrition: %d soldiers lost." % int(report.get("supply_losses", 0))
    _set_message(result, not bool(report.get("food_shortage", false)))
    GameState.save_campaign("auto_a")


func _appoint_role(role: String, picker: OptionButton) -> void:
    var index := picker.selected
    if index <= 0:
        _set_message("Choose a companion first.", false)
        return
    var id := str(picker.get_item_metadata(index))
    _set_message("Appointed %s as %s." % [_character_name(id), str(ROLES[role])], GameState.appoint_empire_councillor(role, id))
    GameState.save_campaign("auto_a")


func _dismiss_role(role: String) -> void:
    var ok: bool = GameState.dismiss_empire_councillor(role)
    _set_message("The office is now vacant." if ok else "Could not dismiss this officeholder.", ok)
    GameState.save_campaign("auto_a")


func _select_province(id: String) -> void:
    selected_province = id
    _rebuild()


func _appoint_governor(province: String, picker: OptionButton) -> void:
    if picker.selected <= 0:
        _set_message("Choose a companion first.", false)
        return
    var id := str(picker.get_item_metadata(picker.selected))
    var ok := GameState.appoint_province_governor(province, id)
    _set_message("Governor appointed." if ok else "Appointment rejected. Check province and character.", ok)
    GameState.save_campaign("auto_a")


func _recall_governor(province: String) -> void:
    var ok := GameState.dismiss_province_governor(province)
    _set_message("Governor recalled." if ok else "Could not recall governor.", ok)
    GameState.save_campaign("auto_a")


func _construct(province: String, building: String) -> void:
    var ok := GameState.construct_province_building(province, building)
    _set_message("Construction commissioned." if ok else "Not enough treasury or this building already exists.", ok)
    GameState.save_campaign("auto_a")


func _set_tax(rate: String) -> void:
    var ok := GameState.set_empire_tax_rate(rate)
    _set_message("Tax policy changed to %s." % rate, ok)
    GameState.save_campaign("auto_a")


func _toggle_policy(policy: String) -> void:
    var ok := GameState.toggle_empire_policy(policy)
    _set_message("Royal edict updated." if ok else "Could not change this edict.", ok)
    GameState.save_campaign("auto_a")


func _set_message(text: String, good: bool) -> void:
    message = text
    message_good = good
    _rebuild()


func _faction_name(id: String) -> String:
    for faction in GameData.factions.get("factions", []):
        if str(faction.get("id", "")) == id:
            return str(faction.get("name", id))
    return "Unclaimed" if id == "" else id.replace("_", " ").capitalize()
