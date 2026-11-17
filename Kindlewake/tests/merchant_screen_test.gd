extends Node
## Runtime UI regression: exercise the actual town market button and commodity exchange controls.

const LocationSceneScript = preload("res://scripts/ui/location_scene.gd")
const MerchantScreenScript = preload("res://scripts/ui/merchant_screen.gd")
const TradeSystemScript = preload("res://scripts/core/trade_system.gd")

var failures: int = 0


func _ready() -> void:
    call_deferred("_run_market_ui_test")


func _check(condition: bool, label: String) -> void:
    if condition:
        print("  ok    " + label)
    else:
        failures += 1
        push_error("FAIL: " + label)


func _find_good_row(screen: MerchantScreenScript, title_prefix: String) -> Control:
    for row_value in screen.goods_list.get_children():
        var row := row_value as Control
        if row == null or row.get_child_count() == 0:
            continue
        var body := row.get_child(0) as VBoxContainer
        if body == null or body.get_child_count() == 0:
            continue
        var heading := body.get_child(0) as Label
        if heading != null and heading.text.begins_with(title_prefix):
            return row
    return null


func _run_market_ui_test() -> void:
    await get_tree().process_frame
    GameState.new_game()
    GameState.active_region_id = "sethmarch"
    GameState.pending_location = "crossing_shop"
    GameState.party.gold = 10000
    GameState.trade_state = TradeSystemScript.new_state()

    var location := LocationSceneScript.new()
    get_tree().root.add_child(location)
    await get_tree().process_frame
    _check(location.current_map_id == "crossing_shop", "town scene opens the requested market map")
    _check(location.merchant_screen != null and not location.merchant_screen.visible, "town scene owns a hidden exchange screen")

    location.near_spot = {"kind":"party","name":"War Table","regional_exchange":false,"npc_active":true}
    location._on_prompt_pressed()
    _check(not location.spot_portrait.visible, "non-person party counters do not display a speaker portrait")
    var non_market_action := false
    for child in location.spot_buttons.get_children():
        if child is Button and (child as Button).text == "Open regional exchange":
            non_market_action = true
    _check(not non_market_action, "ordinary party counters do not expose regional trade access")

    location.near_spot = {
        "kind": "party",
        "name": "Shopkeeper Oswin",
        "npc": true,
        "regional_exchange": true,
        "npc_active": true
    }
    location._on_prompt_pressed()
    _check(location.spot_portrait.visible, "named shopkeeper dialogue displays a merchant portrait")
    var market_button: Button
    for child in location.spot_buttons.get_children():
        if child is Button and (child as Button).text == "Open regional exchange":
            market_button = child as Button
            break
    _check(market_button != null, "designated staffed market presents the regional exchange action")
    if market_button != null:
        market_button.emit_signal("pressed")
    await get_tree().process_frame

    var screen: MerchantScreenScript = location.merchant_screen
    _check(screen.visible, "market action opens the exchange overlay")
    _check(screen.merchant_portrait != null and screen.merchant_portrait.texture != null, "regional exchange displays a resolved merchant portrait")
    _check(screen.goods_list.get_child_count() == 12, "exchange renders all twelve authored commodities")

    var grain_row := _find_good_row(screen, "Frontier Grain")
    _check(grain_row != null, "commodity row renders the correct good")
    if grain_row != null:
        var body := grain_row.get_child(0) as VBoxContainer
        var actions := body.get_child(2) as HBoxContainer
        var quantity := actions.get_child(0) as SpinBox
        var buy_button := actions.get_child(1) as Button
        quantity.value = 2
        buy_button.emit_signal("pressed")
        await get_tree().process_frame
        _check(GameState.party.item_count("trade_grain") == 2, "mobile exchange Buy control adds the selected cargo")
        _check(int(GameState.trade_state.get("transactions", 0)) == 1, "mobile exchange Buy control records a transaction")
        _check(screen.status_label.text == "Purchase completed.", "successful purchase displays confirmation")

        grain_row = _find_good_row(screen, "Frontier Grain")
        if grain_row != null:
            body = grain_row.get_child(0) as VBoxContainer
            actions = body.get_child(2) as HBoxContainer
            quantity = actions.get_child(0) as SpinBox
            var sell_button := actions.get_child(2) as Button
            quantity.value = 1
            sell_button.emit_signal("pressed")
            await get_tree().process_frame
            _check(GameState.party.item_count("trade_grain") == 1, "mobile exchange Sell control removes the selected cargo")
            _check(int(GameState.trade_state.get("transactions", 0)) == 2, "mobile exchange Sell control records the transaction")
        else:
            _check(false, "commodity row remains after a purchase refresh")

    screen._close()
    await get_tree().process_frame
    _check(not screen.visible, "exchange Close control hides the overlay")
    location.queue_free()
    await get_tree().process_frame
    print("Merchant UI failures: %d" % failures)
    get_tree().quit(1 if failures > 0 else 0)
