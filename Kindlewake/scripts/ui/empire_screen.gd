class_name EmpireScreen
extends Control
## Campaign-facing management screen for already claimed locations.
## Captures remain governed by authored world objectives; this screen never claims remote holdings.

signal closed

const Economy = preload("res://scripts/core/empire_economy_system.gd")
const EmpireSystemScript = preload("res://scripts/core/empire_system.gd")
const HOLDING = "house_dunmarrow"
const BG := Color(0.075, 0.065, 0.052, 0.98)
const PANEL := Color(0.16, 0.13, 0.09)
const GOLD := Color(0.91, 0.73, 0.35)
const TEXT := Color(0.94, 0.89, 0.76)
const DIM := Color(0.68, 0.63, 0.53)

var definitions: Array = []
var selected_id := ""
var tabs: TabContainer
var holding_picker: OptionButton
var detail_box: VBoxContainer
var realm_box: VBoxContainer
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
        remove_child(child)
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
    outer.add_theme_constant_override("margin_top", 12)
    outer.add_theme_constant_override("margin_right", 14)
    outer.add_theme_constant_override("margin_bottom", 12)
    add_child(outer)
    var column := VBoxContainer.new()
    column.add_theme_constant_override("separation", 8)
    outer.add_child(column)

    var header := HBoxContainer.new()
    column.add_child(header)
    var title := _label("DUNMARROW REALM", 21, GOLD)
    header.add_child(title)
    var close_button := _button("CLOSE", close)
    close_button.custom_minimum_size = Vector2(86, 44)
    close_button.size_flags_horizontal = Control.SIZE_SHRINK_END
    header.add_child(close_button)

    summary_label = _label("", 14, DIM)
    column.add_child(summary_label)

    tabs = TabContainer.new()
    tabs.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    tabs.size_flags_vertical = Control.SIZE_EXPAND_FILL
    column.add_child(tabs)

    var holdings_tab := VBoxContainer.new()
    holdings_tab.name = "HOLDINGS"
    holdings_tab.add_theme_constant_override("separation", 8)
    tabs.add_child(holdings_tab)
    holdings_tab.add_child(_label("SELECT A HOLDING", 13, DIM))
    holding_picker = OptionButton.new()
    holding_picker.custom_minimum_size = Vector2(0, 46)
    holding_picker.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    holding_picker.item_selected.connect(_on_holding_selected)
    holdings_tab.add_child(holding_picker)

    var detail_panel := PanelContainer.new()
    detail_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    detail_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
    detail_panel.add_theme_stylebox_override("panel", _style_panel(PANEL))
    holdings_tab.add_child(detail_panel)
    var detail_scroll := ScrollContainer.new()
    detail_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    detail_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
    detail_panel.add_child(detail_scroll)
    detail_box = VBoxContainer.new()
    detail_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    detail_box.add_theme_constant_override("separation", 9)
    detail_scroll.add_child(detail_box)

    var realm_scroll := ScrollContainer.new()
    realm_scroll.name = "REALM"
    realm_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    realm_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
    tabs.add_child(realm_scroll)
    realm_box = VBoxContainer.new()
    realm_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    realm_box.add_theme_constant_override("separation", 10)
    realm_scroll.add_child(realm_box)

    var footer := VBoxContainer.new()
    footer.add_theme_constant_override("separation", 6)
    column.add_child(footer)
    result_label = _label("A campaign turn advances only when you choose it.", 13, DIM)
    footer.add_child(result_label)
    var advance := _button("ADVANCE EMPIRE TURN", _advance_turn)
    advance.custom_minimum_size = Vector2(0, 48)
    footer.add_child(advance)


func _holding(id: String) -> Dictionary:
    for raw in definitions:
        if str(raw.get("id", "")) == id:
            return raw
    return {}


func _is_player_holding(id: String) -> bool:
    return bool(GameState.world_flags.get("holding_claimed_" + id, false)) and str(GameState.world_flags.get("holding_owner_" + id, HOLDING)) == HOLDING


func _refresh() -> void:
    if holding_picker == null:
        return
    _building = true
    holding_picker.clear()
    var selected_index := -1
    var claimed_count := 0
    for raw in definitions:
        var d: Dictionary = raw
        var id := str(d.get("id", ""))
        var claimed := _is_player_holding(id)
        if claimed:
            claimed_count += 1
        var status := "ADMINISTERED" if claimed else str(GameState.world_flags.get("holding_status_" + id, "NOT CLAIMED")).to_upper()
        holding_picker.add_item("%s  •  %s" % [str(d.get("name", id)), status])
        holding_picker.set_item_metadata(holding_picker.item_count - 1, id)
        if id == selected_id:
            selected_index = holding_picker.item_count - 1
    if holding_picker.item_count > 0:
        if selected_index < 0:
            selected_index = 0
            selected_id = str(holding_picker.get_item_metadata(0))
        holding_picker.select(selected_index)
    summary_label.text = "TURN %d  •  %d GOLD  •  %d PROVISIONS  •  %d MATERIALS  •  %d / %d HOLDINGS" % [int(GameState.world_flags.get("empire_turn", 0)), GameState.party.gold, int(GameState.world_flags.get("empire_stockpile_provisions", 0)), int(GameState.world_flags.get("empire_stockpile_materials", 0)), claimed_count, definitions.size()]
    _refresh_detail()
    _refresh_realm_admin()
    _building = false


func _on_holding_selected(index: int) -> void:
    if _building or index < 0 or index >= holding_picker.item_count:
        return
    selected_id = str(holding_picker.get_item_metadata(index))
    _refresh_detail()


func _refresh_realm_admin() -> void:
    if realm_box == null:
        return
    for child in realm_box.get_children():
        child.queue_free()
    if not GameState.empire_management_unlocked():
        realm_box.add_child(_label("REALM AUTHORITY NOT YET ESTABLISHED", 20, GOLD))
        realm_box.add_child(_label("Secure your first external stronghold through its authored world objective. Once the holding is under House Dunmarrow's banner, realm tax policy, governors and royal decrees become available.", 16, DIM))
        return

    var summary: Dictionary = GameState.empire_summary()
    realm_box.add_child(_label("THE ROYAL ADMINISTRATION", 22, GOLD))
    realm_box.add_child(_label("Shared treasury  •  %d gold\nOwned regions  •  %d\nStability  •  %d / 100 (%s)\nLegitimacy  •  %d / 100\nMonthly projection  •  %+d gold" % [
        int(summary.get("treasury", GameState.party.gold)),
        (summary.get("owned_regions", []) as Array).size(),
        int(summary.get("stability", 0)),
        str(summary.get("stability_label", "Unknown")),
        int(summary.get("legitimacy", 0)),
        int(summary.get("monthly_net", 0))
    ], 15))
    realm_box.add_child(_label("TAX POLICY", 18, GOLD))
    realm_box.add_child(_label("Higher taxes increase income but can weaken stability. The treasury is your existing party gold; there is no separate realm currency.", 14, DIM))
    var tax_picker := OptionButton.new()
    tax_picker.custom_minimum_size = Vector2(0, 46)
    tax_picker.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    var tax_values: Array[float] = [0.0, 0.05, 0.10, 0.15, 0.20, 0.25]
    var selected_tax := 2
    for i in range(tax_values.size()):
        var rate := tax_values[i]
        tax_picker.add_item("%d%% tax" % roundi(rate * 100.0))
        tax_picker.set_item_metadata(i, rate)
        if absf(rate - float(summary.get("tax_rate", 0.10))) < 0.001:
            selected_tax = i
    tax_picker.select(selected_tax)
    tax_picker.item_selected.connect(_on_tax_rate_selected.bind(tax_picker))
    realm_box.add_child(tax_picker)

    realm_box.add_child(_label("REGIONAL GOVERNORS", 18, GOLD))
    var owned_regions: Array = summary.get("owned_regions", [])
    var governors: Dictionary = summary.get("governors", {})
    if owned_regions.is_empty():
        realm_box.add_child(_label("No fully held region is available for a governor. Resolve a regional objective and establish recognised control first.", 14, DIM))
    else:
        for region_value in owned_regions:
            var region_id := str(region_value)
            var region_card := PanelContainer.new()
            region_card.add_theme_stylebox_override("panel", _style_panel(PANEL))
            var region_column := VBoxContainer.new()
            region_column.add_theme_constant_override("separation", 5)
            region_card.add_child(region_column)
            region_column.add_child(_label(region_id.replace("_", " ").capitalize(), 17, GOLD))
            var picker := OptionButton.new()
            picker.custom_minimum_size = Vector2(0, 44)
            picker.size_flags_horizontal = Control.SIZE_EXPAND_FILL
            var current_governor := str(governors.get(region_id, ""))
            picker.add_item("Select governor...")
            picker.set_item_metadata(0, "")
            var selected_governor := 0
            for character_value in GameState.party.roster:
                var character_id := str(character_value)
                var assigned_elsewhere := false
                for other_region in governors:
                    if str(other_region) != region_id and str(governors[other_region]) == character_id:
                        assigned_elsewhere = true
                        break
                if assigned_elsewhere and character_id != current_governor:
                    continue
                var character: Dictionary = GameData.characters.get(character_id, {})
                picker.add_item(str(character.get("name", character_id)))
                picker.set_item_metadata(picker.item_count - 1, character_id)
                if character_id == current_governor:
                    selected_governor = picker.item_count - 1
            if picker.item_count == 1:
                picker.set_item_text(0, "No eligible companions")
                picker.disabled = true
            else:
                picker.select(selected_governor)
            picker.item_selected.connect(_on_governor_selected.bind(region_id, picker))
            region_column.add_child(picker)
            realm_box.add_child(region_card)

    realm_box.add_child(_label("ROYAL POLICIES", 18, GOLD))
    var policy_copy := {
        "granaries":"Improve food security and realm stability.",
        "tax_relief":"Ease unrest and improve public confidence.",
        "road_works":"Increase income from the existing holding economy.",
        "regional_garrisons":"Strengthen security at an additional regional upkeep cost."
    }
    var active_policies: Array = summary.get("active_policies", [])
    for policy_id in ["granaries", "tax_relief", "road_works", "regional_garrisons"]:
        var definition: Dictionary = EmpireSystemScript.POLICY_DEFINITIONS[policy_id]
        var cost := int(definition.get("cost", 0))
        var active := active_policies.has(policy_id)
        var policy_card := PanelContainer.new()
        policy_card.add_theme_stylebox_override("panel", _style_panel(PANEL))
        var policy_column := VBoxContainer.new()
        policy_column.add_theme_constant_override("separation", 5)
        policy_card.add_child(policy_column)
        policy_column.add_child(_label("%s  •  %d GOLD" % [str(definition.get("name", policy_id)), cost], 16, GOLD))
        policy_column.add_child(_label(str(policy_copy.get(policy_id, "")), 14, DIM))
        var enact := _button("POLICY ACTIVE" if active else "ENACT POLICY", _enact_realm_policy.bind(policy_id))
        enact.disabled = active or GameState.party.gold < cost
        policy_column.add_child(enact)
        realm_box.add_child(policy_card)


func _on_tax_rate_selected(index: int, picker: OptionButton) -> void:
    var rate := float(picker.get_item_metadata(index))
    if GameState.set_empire_tax_rate(rate):
        result_label.text = "Realm tax policy updated."
        GameState.save_campaign("auto_a")
    else:
        result_label.text = "Tax policy could not be changed."
    _refresh()


func _on_governor_selected(index: int, region_id: String, picker: OptionButton) -> void:
    if index < 0:
        return
    var character_id := str(picker.get_item_metadata(index))
    if character_id == "":
        return
    if GameState.appoint_empire_governor(region_id, character_id):
        result_label.text = "%s appointed as governor of %s." % [character_id.capitalize(), region_id.replace("_", " ").capitalize()]
        GameState.save_campaign("auto_a")
    else:
        result_label.text = "That companion cannot govern this region."
    _refresh()


func _enact_realm_policy(policy_id: String) -> void:
    var result: Dictionary = GameState.enact_empire_policy(policy_id)
    result_label.text = "%s enacted." % str(result.get("name", policy_id)) if bool(result.get("ok", false)) else str(result.get("reason", "Policy could not be enacted."))
    if bool(result.get("ok", false)):
        GameState.save_campaign("auto_a")
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

    detail_box.add_child(_label("DEVELOPMENT  •  SPEND GOLD AND MATERIALS", 17, GOLD))
    for building_id in ["farm", "workshop", "trade_post", "fortifications"]:
        var tier := int(GameState.world_flags.get("holding_building_" + id + "_" + building_id, 0))
        var building_names := {"farm":"Granary Farms","workshop":"Civic Workshop","trade_post":"Trade Post","fortifications":"Fortifications"}
        var cost_gold := {"farm":45,"workshop":60,"trade_post":75,"fortifications":65}
        var cost_materials := {"farm":4,"workshop":6,"trade_post":5,"fortifications":8}
        var building_row := VBoxContainer.new()
        building_row.add_theme_constant_override("separation", 4)
        building_row.add_child(_label("%s  •  TIER %d/3" % [str(building_names[building_id]), tier], 14))
        building_row.add_child(_button("UPGRADE  %dG / %dM" % [int(cost_gold[building_id]) * (tier + 1), int(cost_materials[building_id]) * (tier + 1)], _develop_building.bind(building_id)))
        detail_box.add_child(building_row)

    detail_box.add_child(_label("RECRUITMENT  •  GOLD + PROVISIONS", 17, GOLD))
    var recruits: Dictionary = GameState.world_flags.get("holding_recruits_" + id, {})
    for troop_id in ["levy", "archer", "knight"]:
        var troop_names := {"levy":"Frontier Levy","archer":"March Archer","knight":"Household Knight"}
        var troop_cost := {"levy":18,"archer":32,"knight":65}
        var food_cost := {"levy":3,"archer":4,"knight":7}
        var troop_row := VBoxContainer.new()
        troop_row.add_theme_constant_override("separation", 4)
        troop_row.add_child(_label("%s  •  RESERVE %d" % [str(troop_names[troop_id]), int(recruits.get(troop_id, 0))], 14))
        var troop_actions := HBoxContainer.new()
        troop_actions.add_child(_button("RECRUIT 1  %dG / %dP" % [int(troop_cost[troop_id]), int(food_cost[troop_id])], _recruit_troop.bind(troop_id)))
        troop_actions.add_child(_button("GARRISON +1", _assign_recruit.bind(troop_id)))
        troop_row.add_child(troop_actions)
        detail_box.add_child(troop_row)

    detail_box.add_child(_label("TACTICAL OPERATIONS", 17, GOLD))
    detail_box.add_child(_label("Launch a siege exercise from this holding. Victory or defeat is recorded in the campaign; it does not transfer territory automatically.", 14, DIM))
    detail_box.add_child(_button("DEPLOY SIEGE ASSAULT", _launch_siege_assault))


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


func _launch_siege_assault() -> void:
    if not GameState.start_holding_siege_battle(selected_id):
        result_label.text = "A siege could not be staged from this holding."
        return
    GameState.save_campaign("auto_a")
    get_tree().change_scene_to_file("res://Main.tscn")


func _develop_building(building_id: String) -> void:
    var result: Dictionary = GameState.upgrade_holding_building(selected_id, building_id)
    result_label.text = "Development completed." if bool(result.get("ok", false)) else str(result.get("reason", "Could not upgrade."))
    if bool(result.get("ok", false)):
        GameState.save_campaign("auto_a")
    _refresh()


func _recruit_troop(troop_id: String) -> void:
    var result: Dictionary = GameState.recruit_holding_troops(selected_id, troop_id, 1)
    result_label.text = "Recruited %d %s." % [int(result.get("recruited", 0)), troop_id] if bool(result.get("ok", false)) else str(result.get("reason", "Recruitment failed."))
    if bool(result.get("ok", false)):
        GameState.save_campaign("auto_a")
    _refresh()


func _assign_recruit(troop_id: String) -> void:
    var result: Dictionary = GameState.assign_recruits_to_holding_garrison(selected_id, troop_id, 1)
    result_label.text = "One troop assigned to the garrison." if bool(result.get("ok", false)) else str(result.get("reason", "Assignment failed."))
    if bool(result.get("ok", false)):
        GameState.save_campaign("auto_a")
    _refresh()


func _advance_turn() -> void:
    var result: Dictionary = GameState.advance_empire_turn(definitions)
    if not bool(result.get("ok", false)):
        result_label.text = str(result.get("reason", "The empire turn could not be advanced."))
        return
    var net := int(result.get("net", 0))
    result_label.text = "Turn %d resolved: %+d gold. Stability and holding reports updated." % [int(GameState.world_flags.get("empire_turn", 0)), net]
    GameState.save_campaign("auto_a")
    _refresh()
