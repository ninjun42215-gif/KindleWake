class_name TradeSystem
extends RefCounted
## Offline regional commodity trading. Cargo uses PartyState.inventory; market stock and demand
## live in a separate campaign payload so old saves remain compatible.

const DEFAULT_CARGO_CAPACITY := 120
const MAX_QUANTITY := 99

static func new_state() -> Dictionary:
    return {"markets": {}, "transactions": 0, "total_profit": 0}

static func cargo_weight(party: PartyState, goods: Dictionary) -> int:
    var total := 0
    var definitions: Dictionary = goods.get("goods", {})
    for id in definitions.keys():
        total += party.item_count(str(id)) * int((definitions[id] as Dictionary).get("weight", 1))
    return total

static func cargo_capacity(goods: Dictionary) -> int:
    return maxi(1, int(goods.get("cargo_capacity", DEFAULT_CARGO_CAPACITY)))

static func market_state(state: Dictionary, region_id: String, goods: Dictionary) -> Dictionary:
    if typeof(state.get("markets", {})) != TYPE_DICTIONARY:
        state["markets"] = {}
    var markets: Dictionary = state["markets"]
    if not markets.has(region_id):
        var market_def: Dictionary = (goods.get("markets", {}) as Dictionary).get(region_id, {})
        var stock: Dictionary = {}
        var initial := int(market_def.get("initial_stock", 20))
        for id in (goods.get("goods", {}) as Dictionary).keys():
            stock[str(id)] = initial
        markets[region_id] = {"stock": stock, "demand": {}}
    var current: Dictionary = markets[region_id]
    if typeof(current.get("stock", {})) != TYPE_DICTIONARY:
        current["stock"] = {}
    if typeof(current.get("demand", {})) != TYPE_DICTIONARY:
        current["demand"] = {}
    return current

static func unit_price(region_id: String, good_id: String, goods: Dictionary, state: Dictionary) -> int:
    var good: Dictionary = (goods.get("goods", {}) as Dictionary).get(good_id, {})
    if good.is_empty():
        return 0
    var market_def: Dictionary = (goods.get("markets", {}) as Dictionary).get(region_id, {})
    var modifiers: Dictionary = market_def.get("price_modifiers", {})
    var local: Dictionary = market_state(state, region_id, goods)
    var stock: Dictionary = local.get("stock", {})
    var demand: Dictionary = local.get("demand", {})
    var initial := int(market_def.get("initial_stock", 20))
    var quantity := int(stock.get(good_id, initial))
    var pressure := clampf(1.0 + float(int(demand.get(good_id, 0))) * 0.04 - float(quantity - initial) * 0.015, 0.65, 1.8)
    return maxi(1, roundi(float(int(good.get("base_price", 0))) * float(modifiers.get(good_id, 1.0)) * pressure))

static func quote(region_id: String, good_id: String, goods: Dictionary, state: Dictionary) -> Dictionary:
    var good: Dictionary = (goods.get("goods", {}) as Dictionary).get(good_id, {})
    if good.is_empty():
        return {}
    var local := market_state(state, region_id, goods)
    return {"id": good_id, "name": str(good.get("name", good_id)),
        "price": unit_price(region_id, good_id, goods, state),
        "stock": int((local.get("stock", {}) as Dictionary).get(good_id, 0)),
        "weight": int(good.get("weight", 1)), "category": str(good.get("category", "goods"))}

static func quotes(region_id: String, goods: Dictionary, state: Dictionary) -> Array:
    var out: Array = []
    for id in (goods.get("goods", {}) as Dictionary).keys():
        out.append(quote(region_id, str(id), goods, state))
    out.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return str(a["name"]) < str(b["name"]))
    return out

static func buy(party: PartyState, region_id: String, good_id: String, quantity: int,
        goods: Dictionary, state: Dictionary) -> String:
    if quantity < 1 or quantity > int(goods.get("max_transaction_quantity", MAX_QUANTITY)):
        return "Choose a valid quantity."
    var good: Dictionary = (goods.get("goods", {}) as Dictionary).get(good_id, {})
    if good.is_empty():
        return "Unknown trade good."
    var local := market_state(state, region_id, goods)
    var stock: Dictionary = local["stock"]
    if int(stock.get(good_id, 0)) < quantity:
        return "The market does not have enough stock."
    var weight := int(good.get("weight", 1)) * quantity
    if cargo_weight(party, goods) + weight > cargo_capacity(goods):
        return "Your cargo capacity is full."
    var price := unit_price(region_id, good_id, goods, state) * quantity
    if party.gold < price:
        return "Not enough gold."
    party.gold -= price
    party.add_item(good_id, quantity)
    stock[good_id] = int(stock.get(good_id, 0)) - quantity
    var demand: Dictionary = local["demand"]
    demand[good_id] = int(demand.get(good_id, 0)) + quantity
    state["transactions"] = int(state.get("transactions", 0)) + 1
    return ""

static func sell(party: PartyState, region_id: String, good_id: String, quantity: int,
        goods: Dictionary, state: Dictionary) -> String:
    if quantity < 1 or quantity > int(goods.get("max_transaction_quantity", MAX_QUANTITY)):
        return "Choose a valid quantity."
    var good: Dictionary = (goods.get("goods", {}) as Dictionary).get(good_id, {})
    if good.is_empty():
        return "Unknown trade good."
    if party.item_count(good_id) < quantity:
        return "You do not have enough cargo."
    var local := market_state(state, region_id, goods)
    var price := unit_price(region_id, good_id, goods, state) * quantity
    if not party.remove_item(good_id, quantity):
        return "You do not have enough cargo."
    party.gold += price
    var stock: Dictionary = local["stock"]
    stock[good_id] = int(stock.get(good_id, 0)) + quantity
    var demand: Dictionary = local["demand"]
    demand[good_id] = maxi(-20, int(demand.get(good_id, 0)) - quantity)
    state["transactions"] = int(state.get("transactions", 0)) + 1
    state["total_profit"] = int(state.get("total_profit", 0)) + price
    return ""

static func market_name(region_id: String, goods: Dictionary) -> String:
    var market: Dictionary = (goods.get("markets", {}) as Dictionary).get(region_id, {})
    return str(market.get("name", region_id))
