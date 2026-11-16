class_name TradeSystem
extends RefCounted
## Local, offline regional commodity markets. Route travel and government tariffs are intentionally
## not exposed until region ownership and canonical route gates are implemented.

const DEFAULT_CARGO_CAPACITY := 120
const DEFAULT_MAX_QUANTITY := 99
const MAX_MARKET_STOCK := 9999

static func new_state() -> Dictionary:
    return {
        "markets": {},
        "transactions": 0,
        "total_sales": 0
    }


static func normalize_state(raw: Dictionary, goods: Dictionary) -> Dictionary:
    var state := new_state()
    state["transactions"] = maxi(0, int(raw.get("transactions", 0)))
    state["total_sales"] = maxi(0, int(raw.get("total_sales", 0)))
    var raw_markets: Variant = raw.get("markets", {})
    if typeof(raw_markets) != TYPE_DICTIONARY:
        raw_markets = {}
    var normalized_markets: Dictionary = {}
    for region_value in goods.get("markets", {}).keys():
        var region_id := str(region_value)
        var definition: Dictionary = goods["markets"][region_id]
        var initial := clampi(int(definition.get("initial_stock", 20)), 0, MAX_MARKET_STOCK)
        var saved: Variant = raw_markets.get(region_id, {})
        if typeof(saved) != TYPE_DICTIONARY:
            saved = {}
        var raw_stock: Variant = saved.get("stock", {})
        var raw_demand: Variant = saved.get("demand", {})
        if typeof(raw_stock) != TYPE_DICTIONARY:
            raw_stock = {}
        if typeof(raw_demand) != TYPE_DICTIONARY:
            raw_demand = {}
        var stock: Dictionary = {}
        var demand: Dictionary = {}
        for good_value in goods.get("goods", {}).keys():
            var good_id := str(good_value)
            stock[good_id] = clampi(int(raw_stock.get(good_id, initial)), 0, MAX_MARKET_STOCK)
            demand[good_id] = clampi(int(raw_demand.get(good_id, 0)), -1000, 1000)
        normalized_markets[region_id] = {"stock": stock, "demand": demand}
    state["markets"] = normalized_markets
    return state


static func has_market(region_id: String, goods: Dictionary) -> bool:
    return region_id != "" and typeof(goods.get("markets", {})) == TYPE_DICTIONARY and goods.get("markets", {}).has(region_id)


static func market_state(state: Dictionary, region_id: String, goods: Dictionary) -> Dictionary:
    if not has_market(region_id, goods):
        return {}
    if typeof(state.get("markets", {})) != TYPE_DICTIONARY:
        state["markets"] = {}
    var markets: Dictionary = state["markets"]
    if typeof(markets.get(region_id, {})) != TYPE_DICTIONARY:
        markets[region_id] = {}
    var current: Dictionary = markets[region_id]
    var definition: Dictionary = goods["markets"][region_id]
    var initial := clampi(int(definition.get("initial_stock", 20)), 0, MAX_MARKET_STOCK)
    if typeof(current.get("stock", {})) != TYPE_DICTIONARY:
        current["stock"] = {}
    if typeof(current.get("demand", {})) != TYPE_DICTIONARY:
        current["demand"] = {}
    var stock: Dictionary = current["stock"]
    var demand: Dictionary = current["demand"]
    for good_value in goods.get("goods", {}).keys():
        var good_id := str(good_value)
        stock[good_id] = clampi(int(stock.get(good_id, initial)), 0, MAX_MARKET_STOCK)
        demand[good_id] = clampi(int(demand.get(good_id, 0)), -1000, 1000)
    current["stock"] = stock
    current["demand"] = demand
    markets[region_id] = current
    state["markets"] = markets
    return current


static func cargo_capacity(goods: Dictionary) -> int:
    return maxi(1, int(goods.get("cargo_capacity", DEFAULT_CARGO_CAPACITY)))


static func cargo_weight(party: Variant, goods: Dictionary) -> int:
    if party == null:
        return 0
    var total := 0
    var definitions: Dictionary = goods.get("goods", {})
    for good_value in definitions.keys():
        var good_id := str(good_value)
        var definition: Dictionary = definitions[good_id]
        total += maxi(0, party.item_count(good_id)) * maxi(0, int(definition.get("weight", 1)))
    return total


static func unit_price(region_id: String, good_id: String, goods: Dictionary, state: Dictionary) -> int:
    if not has_market(region_id, goods):
        return 0
    var good: Dictionary = goods.get("goods", {}).get(good_id, {})
    if good.is_empty():
        return 0
    var market_definition: Dictionary = goods["markets"][region_id]
    var local := market_state(state, region_id, goods)
    var stock: Dictionary = local.get("stock", {})
    var demand: Dictionary = local.get("demand", {})
    var initial := maxi(1, int(market_definition.get("initial_stock", 20)))
    var quantity := int(stock.get(good_id, initial))
    var pressure := clampf(
        1.0 + float(demand.get(good_id, 0)) * 0.02 - float(quantity - initial) * 0.01,
        0.65, 1.8
    )
    var modifiers: Dictionary = market_definition.get("price_modifiers", {})
    var modifier := clampf(float(modifiers.get(good_id, 1.0)), 0.25, 4.0)
    return maxi(1, roundi(float(good.get("base_price", 1)) * modifier * pressure))


static func quote(region_id: String, good_id: String, goods: Dictionary, state: Dictionary) -> Dictionary:
    if not has_market(region_id, goods):
        return {}
    var good: Dictionary = goods.get("goods", {}).get(good_id, {})
    if good.is_empty():
        return {}
    var local := market_state(state, region_id, goods)
    var market_definition: Dictionary = goods["markets"][region_id]
    var price := unit_price(region_id, good_id, goods, state)
    var sell_ratio := clampf(float(market_definition.get("sell_ratio", goods.get("sell_ratio", 0.68))), 0.1, 1.0)
    return {
        "id": good_id,
        "name": str(good.get("name", good_id)),
        "category": str(good.get("category", "Goods")),
        "description": str(good.get("description", "")),
        "price": price,
        "sell_price": maxi(1, roundi(float(price) * sell_ratio)),
        "stock": int(local.get("stock", {}).get(good_id, 0)),
        "owned": 0,
        "weight": maxi(0, int(good.get("weight", 1)))
    }


static func quotes(region_id: String, goods: Dictionary, state: Dictionary, party: Variant = null) -> Array:
    var out: Array = []
    if not has_market(region_id, goods):
        return out
    for good_value in goods.get("goods", {}).keys():
        var good_id := str(good_value)
        var row := quote(region_id, good_id, goods, state)
        if row.is_empty():
            continue
        row["owned"] = party.item_count(good_id) if party != null else 0
        out.append(row)
    out.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
        return str(a.get("name", "")) < str(b.get("name", ""))
    )
    return out


static func buy(party: Variant, region_id: String, good_id: String, quantity: int, goods: Dictionary, state: Dictionary) -> String:
    if quantity < 1 or quantity > int(goods.get("max_transaction_quantity", DEFAULT_MAX_QUANTITY)):
        return "Choose a quantity between 1 and %d." % int(goods.get("max_transaction_quantity", DEFAULT_MAX_QUANTITY))
    if not has_market(region_id, goods):
        return "There is no recognised commodity market in this region."
    var good: Dictionary = goods.get("goods", {}).get(good_id, {})
    if good.is_empty():
        return "Unknown trade good."
    var local := market_state(state, region_id, goods)
    var stock: Dictionary = local.get("stock", {})
    if int(stock.get(good_id, 0)) < quantity:
        return "The market does not have enough stock."
    var weight := maxi(0, int(good.get("weight", 1)))
    if cargo_weight(party, goods) + weight * quantity > cargo_capacity(goods):
        return "Your cargo capacity is full."
    var total := unit_price(region_id, good_id, goods, state) * quantity
    if int(party.gold) < total:
        return "Not enough gold."
    party.gold -= total
    party.add_item(good_id, quantity)
    stock[good_id] = int(stock.get(good_id, 0)) - quantity
    var demand: Dictionary = local.get("demand", {})
    demand[good_id] = clampi(int(demand.get(good_id, 0)) + quantity, -1000, 1000)
    local["stock"] = stock
    local["demand"] = demand
    state["transactions"] = maxi(0, int(state.get("transactions", 0))) + 1
    return ""


static func sell(party: Variant, region_id: String, good_id: String, quantity: int, goods: Dictionary, state: Dictionary) -> String:
    if quantity < 1 or quantity > int(goods.get("max_transaction_quantity", DEFAULT_MAX_QUANTITY)):
        return "Choose a quantity between 1 and %d." % int(goods.get("max_transaction_quantity", DEFAULT_MAX_QUANTITY))
    if not has_market(region_id, goods):
        return "There is no recognised commodity market in this region."
    var good: Dictionary = goods.get("goods", {}).get(good_id, {})
    if good.is_empty():
        return "Unknown trade good."
    if party.item_count(good_id) < quantity:
        return "You do not have enough cargo."
    var local := market_state(state, region_id, goods)
    var row := quote(region_id, good_id, goods, state)
    var payout := int(row.get("sell_price", 0)) * quantity
    if payout <= 0:
        return "This commodity has no valid sale price."
    if not party.remove_item(good_id, quantity):
        return "You do not have enough cargo."
    party.gold += payout
    var stock: Dictionary = local.get("stock", {})
    stock[good_id] = clampi(int(stock.get(good_id, 0)) + quantity, 0, MAX_MARKET_STOCK)
    var demand: Dictionary = local.get("demand", {})
    demand[good_id] = clampi(int(demand.get(good_id, 0)) - quantity, -1000, 1000)
    local["stock"] = stock
    local["demand"] = demand
    state["transactions"] = maxi(0, int(state.get("transactions", 0))) + 1
    state["total_sales"] = maxi(0, int(state.get("total_sales", 0))) + payout
    return ""
