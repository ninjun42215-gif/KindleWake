extends Control

const PremiumUITheme = preload("res://scripts/ui/premium_ui_theme.gd")
const TradeGoodsIconAtlas = preload("res://scripts/ui/trade_goods_icon_atlas.gd")
## Scrollable mobile-first regional commodity exchange. All transactions are validated by GameState.

signal closed

var summary_label: Label
var status_label: Label
var goods_list: VBoxContainer
var scroll: ScrollContainer


func _ready() -> void:
    set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    mouse_filter = Control.MOUSE_FILTER_STOP

    var shade := ColorRect.new()
    shade.color = Color(0.015, 0.02, 0.025, 0.9)
    shade.mouse_filter = Control.MOUSE_FILTER_STOP
    shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    add_child(shade)

    var panel := PanelContainer.new()
    panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    panel.offset_left = 12
    panel.offset_top = 12
    panel.offset_right = -12
    panel.offset_bottom = -12
    panel.add_theme_stylebox_override("panel", PremiumUITheme.panel_style(0.98))
    add_child(panel)

    var margin := MarginContainer.new()
    for side in ["left", "right", "top", "bottom"]:
        margin.add_theme_constant_override("margin_" + side, 12)
    panel.add_child(margin)

    var outer := VBoxContainer.new()
    outer.add_theme_constant_override("separation", 8)
    margin.add_child(outer)

    var header := HBoxContainer.new()
    var title := Label.new()
    title.text = "REGIONAL EXCHANGE"
    title.add_theme_font_size_override("font_size", 24)
    title.add_theme_color_override("font_color", PremiumUITheme.BRASS_LIGHT)
    title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    header.add_child(title)
    var close_button := Button.new()
    close_button.action_mode = BaseButton.ACTION_MODE_BUTTON_PRESS
    close_button.focus_mode = Control.FOCUS_NONE
    close_button.text = "CLOSE"
    close_button.custom_minimum_size = Vector2(88, 44)
    PremiumUITheme.apply_button(close_button)
    close_button.pressed.connect(_close)
    header.add_child(close_button)
    outer.add_child(header)

    summary_label = Label.new()
    summary_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    summary_label.add_theme_color_override("font_color", PremiumUITheme.PARCHMENT)
    summary_label.add_theme_font_size_override("font_size", 15)
    outer.add_child(summary_label)

    status_label = Label.new()
    status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    status_label.add_theme_font_size_override("font_size", 15)
    status_label.add_theme_color_override("font_color", PremiumUITheme.MUTED)
    outer.add_child(status_label)

    scroll = ScrollContainer.new()
    scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
    scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
    scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
    scroll.scroll_vertical_custom_step = 64.0
    scroll.follow_focus = true
    outer.add_child(scroll)

    goods_list = VBoxContainer.new()
    goods_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    goods_list.add_theme_constant_override("separation", 8)
    scroll.add_child(goods_list)
    visible = false


func open_exchange() -> void:
    visible = true
    refresh()


func _close() -> void:
    visible = false
    closed.emit()


func _clear_goods() -> void:
    for child in goods_list.get_children():
        goods_list.remove_child(child)
        child.queue_free()


func refresh(reset_status: bool = true) -> void:
    if not is_node_ready():
        return
    _clear_goods()
    var region_name := str(GameData.trade_economy.get("markets", {}).get(GameState.active_region_id, {}).get("name", GameState.active_region_id))
    summary_label.text = "%s  •  Gold %d  •  Cargo %d/%d" % [
        region_name, GameState.party.gold, GameState.trade_cargo_weight(), GameState.trade_cargo_capacity()
    ]
    if reset_status:
        status_label.text = "Buy low, sell high. Prices shift as market stock changes."
    for quote_value in GameState.trade_quotes():
        var quote: Dictionary = quote_value
        goods_list.add_child(_build_good_row(quote))


func _build_good_row(quote: Dictionary) -> Control:
    var good_id := str(quote.get("id", ""))
    var card := PanelContainer.new()
    card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    card.add_theme_stylebox_override("panel", PremiumUITheme.panel_style(0.82))
    var outer := VBoxContainer.new()
    outer.add_theme_constant_override("separation", 5)
    card.add_child(outer)

    var heading_row := HBoxContainer.new()
    heading_row.add_theme_constant_override("separation", 10)
    outer.add_child(heading_row)

    var icon_texture := TradeGoodsIconAtlas.texture_for(good_id)
    if icon_texture != null:
        var icon := TextureRect.new()
        icon.texture = icon_texture
        icon.custom_minimum_size = Vector2(44, 44)
        icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
        icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
        icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
        heading_row.add_child(icon)

    var heading := Label.new()
    heading.text = "%s  •  Buy %d  •  Sell %d  •  Stock %d" % [
        str(quote.get("name", good_id)), int(quote.get("price", 0)),
        int(quote.get("sell_price", 0)), int(quote.get("stock", 0))
    ]
    heading.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    heading.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    heading.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    heading.add_theme_font_size_override("font_size", 16)
    heading.add_theme_color_override("font_color", PremiumUITheme.PARCHMENT)
    heading_row.add_child(heading)

    var detail := Label.new()
    detail.text = "%s  •  Weight %d each  •  Owned %d\n%s" % [
        str(quote.get("category", "Goods")), int(quote.get("weight", 1)),
        int(quote.get("owned", 0)), str(quote.get("description", ""))
    ]
    detail.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    detail.add_theme_font_size_override("font_size", 13)
    detail.add_theme_color_override("font_color", PremiumUITheme.MUTED)
    outer.add_child(detail)

    var actions := HBoxContainer.new()
    actions.add_theme_constant_override("separation", 6)
    outer.add_child(actions)
    var quantity := SpinBox.new()
    quantity.min_value = 1
    quantity.max_value = int(GameData.trade_economy.get("max_transaction_quantity", 99))
    quantity.value = 1
    quantity.custom_minimum_size = Vector2(72, 42)
    actions.add_child(quantity)

    var buy_button := Button.new()
    buy_button.action_mode = BaseButton.ACTION_MODE_BUTTON_PRESS
    buy_button.focus_mode = Control.FOCUS_NONE
    buy_button.text = "BUY"
    buy_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    buy_button.custom_minimum_size = Vector2(76, 42)
    buy_button.disabled = int(quote.get("stock", 0)) <= 0
    PremiumUITheme.apply_button(buy_button)
    buy_button.pressed.connect(func():
        _buy_good(good_id, int(quantity.value))
    )
    actions.add_child(buy_button)

    var sell_button := Button.new()
    sell_button.action_mode = BaseButton.ACTION_MODE_BUTTON_PRESS
    sell_button.focus_mode = Control.FOCUS_NONE
    sell_button.text = "SELL"
    sell_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    sell_button.custom_minimum_size = Vector2(76, 42)
    sell_button.disabled = int(quote.get("owned", 0)) <= 0
    PremiumUITheme.apply_button(sell_button)
    sell_button.pressed.connect(func():
        _sell_good(good_id, int(quantity.value))
    )
    actions.add_child(sell_button)
    return card


func _buy_good(good_id: String, quantity: int) -> void:
    var result := GameState.trade_buy(good_id, quantity)
    status_label.text = "Purchase completed." if result == "" else result
    refresh(false)


func _sell_good(good_id: String, quantity: int) -> void:
    var result := GameState.trade_sell(good_id, quantity)
    status_label.text = "Sale completed." if result == "" else result
    refresh(false)
