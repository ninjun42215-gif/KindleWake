extends Control

const TradeSystemScript = preload("res://scripts/core/trade_system.gd")
## Player-facing merchant ledger. All transactions delegate to the offline TradeSystem APIs.

signal closed

var panel: PanelContainer
var content: VBoxContainer
var status_label: Label
var scroll: ScrollContainer


func _ready() -> void:
    set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    mouse_filter = Control.MOUSE_FILTER_STOP
    var shade := ColorRect.new()
    shade.color = Color(0.015, 0.02, 0.025, 0.88)
    shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    add_child(shade)
    panel = PanelContainer.new()
    panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    panel.offset_left = 22
    panel.offset_top = 22
    panel.offset_right = -22
    panel.offset_bottom = -22
    add_child(panel)
    var margin := MarginContainer.new()
    margin.add_theme_constant_override("margin_left", 16)
    margin.add_theme_constant_override("margin_right", 16)
    margin.add_theme_constant_override("margin_top", 12)
    margin.add_theme_constant_override("margin_bottom", 12)
    panel.add_child(margin)
    var outer := VBoxContainer.new()
    outer.add_theme_constant_override("separation", 8)
    margin.add_child(outer)
    var header := HBoxContainer.new()
    var title := Label.new()
    title.text = "MERCHANT EXCHANGE"
    title.add_theme_font_size_override("font_size", 26)
    title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    header.add_child(title)
    var close_button := Button.new()
    close_button.text = "CLOSE"
    close_button.pressed.connect(_close)
    header.add_child(close_button)
    outer.add_child(header)
    status_label = Label.new()
    status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    status_label.add_theme_color_override("font_color", Color("#e5c98d"))
    outer.add_child(status_label)
    scroll = ScrollContainer.new()
    scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
    scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    outer.add_child(scroll)
    content = VBoxContainer.new()
    content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    content.add_theme_constant_override("separation", 8)
    scroll.add_child(content)
    visible = false


func open_exchange() -> void:
    visible = true
    refresh()


func _close() -> void:
    visible = false
    closed.emit()


func _clear_content() -> void:
    for child in content.get_children():
        child.queue_free()


func _section(title_text: String) -> void:
    var label := Label.new()
    label.text = title_text
    label.add_theme_font_size_override("font_size", 20)
    label.add_theme_color_override("font_color", Color("#e5c98d"))
    content.add_child(label)
    var rule := HSeparator.new()
    content.add_child(rule)


func _action_button(caption: String, action: Callable) -> Button:
    var button := Button.new()
    button.text = caption
    button.custom_minimum_size = Vector2(96, 42)
    button.pressed.connect(action)
    return button


func _notify_result(message: String) -> void:
    status_label.text = message if message != "" else "Transaction completed."
    refresh(false)


func refresh(reset_status: bool = true) -> void:
    if not is_node_ready():
        return
    _clear_content()
    var state: Dictionary = GameState.trade_state
    var profile: Dictionary = GameState.merchant_profile()
    var rank: Dictionary = profile.get("rank", {})
    var caravan: Dictionary = state.get("caravan", {})
    var capacity := TradeSystemScript.cargo_capacity(GameData.trade_economy, state)
    var weight := TradeSystemScript.cargo_weight(GameState.party, GameData.trade_economy)
    if reset_status:
        status_label.text = "%s  •  Reputation %d  •  XP %d\n%s  •  Gold %d  •  Cargo %d/%d" % [
            str(rank.get("name", "Novice Trader")), int(profile.get("reputation", 0)),
            int(profile.get("xp", 0)), GameState.active_region_id, GameState.party.gold, weight, capacity
        ]

    _section("REGIONAL MARKET — " + TradeSystemScript.market_name(GameState.active_region_id, GameData.trade_economy))
    for quote in GameState.trade_quotes():
        var id := str(quote.get("id", ""))
        var row := HBoxContainer.new()
        var label := Label.new()
        label.text = "%s  •  %d gold  •  Stock %d" % [str(quote.get("name", id)), int(quote.get("price", 0)), int(quote.get("stock", 0))]
        label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        label.custom_minimum_size = Vector2(260, 0)
        row.add_child(label)
        var quantity := SpinBox.new()
        quantity.min_value = 1
        quantity.max_value = 99
        quantity.value = 1
        quantity.custom_minimum_size = Vector2(76, 0)
        row.add_child(quantity)
        var buy := Button.new()
        buy.text = "BUY"
        buy.pressed.connect(func(): _notify_result(GameState.trade_buy(id, int(quantity.value))))
        row.add_child(buy)
        var sell := Button.new()
        sell.text = "SELL"
        sell.pressed.connect(func(): _notify_result(GameState.trade_sell(id, int(quantity.value))))
        row.add_child(sell)
        var smuggle := Button.new()
        smuggle.text = "SMUGGLE"
        smuggle.pressed.connect(func():
            var result: Dictionary = GameState.merchant_smuggle(id, int(quantity.value))
            _notify_result(str(result.get("message", "No result.")))
        )
        row.add_child(smuggle)
        content.add_child(row)

    _section("CARAVAN AND GUARDS")
    var caravan_status := Label.new()
    caravan_status.text = "Owned: %s  •  Upgrade: %d/3  •  Guards: %d/8" % [
        "Yes" if bool(caravan.get("owned", false)) else "No",
        int(caravan.get("level", 0)), int(caravan.get("guards", 0))
    ]
    content.add_child(caravan_status)
    var caravan_row := HBoxContainer.new()
    caravan_row.add_child(_action_button("BUY CARAVAN", func(): _notify_result(GameState.merchant_buy_caravan())))
    caravan_row.add_child(_action_button("UPGRADE", func(): _notify_result(GameState.merchant_upgrade_caravan())))
    caravan_row.add_child(_action_button("HIRE GUARD", func(): _notify_result(GameState.merchant_hire_guard())))
    content.add_child(caravan_row)

    _section("DELIVERY CONTRACTS")
    for contract_id in GameData.trade_economy.get("contracts", {}).keys():
        var definition: Dictionary = GameData.trade_economy["contracts"][contract_id]
        var row := HBoxContainer.new()
        var label := Label.new()
        label.text = "%s  •  %s ×%d  •  Reward %d" % [
            str(definition.get("name", contract_id)), str(definition.get("good", "")),
            int(definition.get("quantity", 0)), int(definition.get("reward", 0))
        ]
        label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        row.add_child(label)
        row.add_child(_action_button("ACCEPT", func(): _notify_result(GameState.merchant_accept_contract(str(contract_id)))))
        row.add_child(_action_button("CLAIM", func(): _notify_result(GameState.merchant_complete_contract(str(contract_id)))))
        content.add_child(row)

    _section("MERCHANT GUILDS")
    for guild_id in GameData.trade_economy.get("guilds", {}).keys():
        var guild: Dictionary = GameData.trade_economy["guilds"][guild_id]
        var membership: Dictionary = state.get("guilds", {}).get(guild_id, {})
        var row := HBoxContainer.new()
        var label := Label.new()
        label.text = "%s  •  %s" % [str(guild.get("name", guild_id)), "Standing %d" % int(membership.get("standing", 0)) if membership.has("standing") else "Not joined"]
        label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        row.add_child(label)
        row.add_child(_action_button("JOIN", func(): _notify_result(GameState.merchant_join_guild(str(guild_id)))))
        row.add_child(_action_button("CONTRIBUTE 500", func(): _notify_result(GameState.merchant_guild_contribute(str(guild_id), 500))))
        content.add_child(row)

    _section("TRADE CORRIDORS")
    for route_id in GameData.trade_economy.get("routes", {}).keys():
        var route: Dictionary = GameData.trade_economy["routes"][route_id]
        var row := HBoxContainer.new()
        var label := Label.new()
        label.text = "%s  •  %s → %s  •  Toll %d" % [
            str(route.get("name", route_id)), str(route.get("from", "")),
            str(route.get("to", "")), int(route.get("base_toll", 0))
        ]
        label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        row.add_child(label)
        var travel_button := _action_button("TRAVEL", func(): _notify_result(GameState.merchant_travel_route(str(route_id))))
        travel_button.disabled = str(route.get("from", "")) != GameState.active_region_id
        row.add_child(travel_button)
        content.add_child(row)

    var travel_event: Dictionary = GameState.merchant_last_travel_event()
    if not travel_event.is_empty():
        var event_label := Label.new()
        event_label.text = "Last road event: " + str(travel_event.get("status", "safe")).to_upper()
        content.add_child(event_label)

    if bool(GameState.world_flags.get("empire_management_unlocked", false)):
        _section("IMPERIAL TRADE POLICY")
        for region_id in GameData.trade_economy.get("markets", {}).keys():
            var row := HBoxContainer.new()
            var label := Label.new()
            label.text = "Tariff — " + str(region_id)
            label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
            row.add_child(label)
            var rate := SpinBox.new()
            rate.min_value = 0
            rate.max_value = 50
            rate.step = 1
            rate.suffix = "%"
            rate.value = float(state.get("tariffs", {}).get(region_id, 0.05)) * 100.0
            row.add_child(rate)
            row.add_child(_action_button("SET", func():
                _notify_result(GameState.merchant_set_tariff(str(region_id), float(rate.value) / 100.0))
            ))
            content.add_child(row)
        for route_id in GameData.trade_economy.get("routes", {}).keys():
            var row := HBoxContainer.new()
            var label := Label.new()
            label.text = "Route policy — " + str(route_id)
            label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
            row.add_child(label)
            row.add_child(_action_button("PROTECT", func():
                _notify_result(GameState.merchant_set_route_policy(str(route_id), {"open":true,"protected":true}))
            ))
            row.add_child(_action_button("CLOSE", func():
                _notify_result(GameState.merchant_set_route_policy(str(route_id), {"open":false}))
            ))
            content.add_child(row)
