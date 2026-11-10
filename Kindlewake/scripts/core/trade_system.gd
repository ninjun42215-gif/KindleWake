class_name TradeSystem
extends RefCounted
## Offline merchant profession, regional markets, caravans, contracts, guilds and trade routes.

const DEFAULT_CARGO_CAPACITY := 120
const MAX_QUANTITY := 99
const MERCHANT_RANKS := [
    {"id":"novice","name":"Novice Trader","xp":0,"capacity":0,"fee_discount":0.0},
    {"id":"peddler","name":"Peddler","xp":100,"capacity":10,"fee_discount":0.01},
    {"id":"trader","name":"Established Trader","xp":350,"capacity":20,"fee_discount":0.025},
    {"id":"merchant","name":"Master Merchant","xp":800,"capacity":35,"fee_discount":0.05},
    {"id":"magnate","name":"Trade Magnate","xp":1600,"capacity":50,"fee_discount":0.08}
]

static func new_state() -> Dictionary:
    return {"markets": {}, "transactions": 0, "total_profit": 0, "merchant_xp": 0,
        "merchant_reputation": 0, "merchant_rank": "novice",
        "caravan": {"owned": false, "level": 0, "guards": 0, "name": "Wayfarer"},
        "guilds": {}, "active_contracts": [], "completed_contracts": [],
        "route_policies": {}, "tariffs": {}, "smuggling_heat": 0,
        "ambushes_survived": 0, "cargo_lost": 0, "tax_paid": 0}

static func normalize_state(raw: Dictionary, goods: Dictionary) -> Dictionary:
    var state := new_state()
    for key in state.keys():
        if raw.has(key):
            state[key] = raw[key].duplicate(true) if typeof(raw[key]) == TYPE_DICTIONARY or typeof(raw[key]) == TYPE_ARRAY else raw[key]
    for key in ["markets", "guilds", "route_policies", "tariffs"]:
        if typeof(state[key]) != TYPE_DICTIONARY: state[key] = {}
    for key in ["active_contracts", "completed_contracts"]:
        if typeof(state[key]) != TYPE_ARRAY: state[key] = []
    if typeof(state["caravan"]) != TYPE_DICTIONARY: state["caravan"] = new_state()["caravan"]
    _update_rank(state)
    return state

static func _rank_for_xp(xp: int) -> Dictionary:
    var result: Dictionary = MERCHANT_RANKS[0]
    for rank in MERCHANT_RANKS:
        if xp >= int(rank["xp"]): result = rank
    return result

static func _update_rank(state: Dictionary) -> void:
    state["merchant_rank"] = str(_rank_for_xp(int(state.get("merchant_xp", 0)))["id"])

static func add_merchant_xp(state: Dictionary, amount: int) -> void:
    state["merchant_xp"] = maxi(0, int(state.get("merchant_xp", 0)) + maxi(0, amount))
    state["merchant_reputation"] = clampi(int(state.get("merchant_reputation", 0)) + maxi(0, int(amount / 5)), 0, 1000)
    _update_rank(state)

static func merchant_profile(state: Dictionary) -> Dictionary:
    var xp := int(state.get("merchant_xp", 0))
    var next_rank: Dictionary = {}
    for rank in MERCHANT_RANKS:
        if xp < int(rank["xp"]):
            next_rank = rank.duplicate(true)
            break
    return {"xp":xp, "reputation":int(state.get("merchant_reputation", 0)),
        "rank":_rank_for_xp(xp).duplicate(true), "next_rank":next_rank}

static func cargo_capacity(goods: Dictionary, state: Dictionary = {}) -> int:
    var caravan: Dictionary = state.get("caravan", {})
    var rank := _rank_for_xp(int(state.get("merchant_xp", 0)))
    return maxi(1, int(goods.get("cargo_capacity", DEFAULT_CARGO_CAPACITY)) +
        int(rank.get("capacity", 0)) + int(caravan.get("level", 0)) * 50)

static func cargo_weight(party: PartyState, goods: Dictionary) -> int:
    var total := 0
    for id in goods.get("goods", {}).keys():
        total += party.item_count(str(id)) * int(goods["goods"][id].get("weight", 1))
    return total

static func market_state(state: Dictionary, region_id: String, goods: Dictionary) -> Dictionary:
    if typeof(state.get("markets", {})) != TYPE_DICTIONARY: state["markets"] = {}
    var markets: Dictionary = state["markets"]
    if not markets.has(region_id):
        var definition: Dictionary = goods.get("markets", {}).get(region_id, {})
        var stock: Dictionary = {}
        var initial := int(definition.get("initial_stock", 20))
        for id in goods.get("goods", {}).keys(): stock[str(id)] = initial
        markets[region_id] = {"stock":stock, "demand":{}}
    var current: Dictionary = markets[region_id]
    if typeof(current.get("stock", {})) != TYPE_DICTIONARY: current["stock"] = {}
    if typeof(current.get("demand", {})) != TYPE_DICTIONARY: current["demand"] = {}
    return current

static func unit_price(region_id: String, good_id: String, goods: Dictionary, state: Dictionary) -> int:
    var good: Dictionary = goods.get("goods", {}).get(good_id, {})
    if good.is_empty(): return 0
    var market: Dictionary = goods.get("markets", {}).get(region_id, {})
    var local := market_state(state, region_id, goods)
    var initial := int(market.get("initial_stock", 20))
    var quantity := int(local.get("stock", {}).get(good_id, initial))
    var demand := int(local.get("demand", {}).get(good_id, 0))
    var pressure := clampf(1.0 + float(demand) * 0.04 - float(quantity - initial) * 0.015, 0.65, 1.8)
    return maxi(1, roundi(float(good.get("base_price", 0)) * float(market.get("price_modifiers", {}).get(good_id, 1.0)) * pressure))

static func quote(region_id: String, good_id: String, goods: Dictionary, state: Dictionary) -> Dictionary:
    var good: Dictionary = goods.get("goods", {}).get(good_id, {})
    if good.is_empty(): return {}
    var local := market_state(state, region_id, goods)
    return {"id":good_id, "name":str(good.get("name", good_id)),
        "price":unit_price(region_id, good_id, goods, state),
        "stock":int(local.get("stock", {}).get(good_id, 0)),
        "weight":int(good.get("weight", 1)), "category":str(good.get("category", "goods")),
        "exclusive_guild":str(good.get("exclusive_guild", ""))}

static func quotes(region_id: String, goods: Dictionary, state: Dictionary) -> Array:
    var out: Array = []
    for id in goods.get("goods", {}).keys(): out.append(quote(region_id, str(id), goods, state))
    out.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return str(a["name"]) < str(b["name"]))
    return out

static func _guild_access(state: Dictionary, good: Dictionary) -> bool:
    var guild_id := str(good.get("exclusive_guild", ""))
    return guild_id == "" or int(state.get("guilds", {}).get(guild_id, {}).get("standing", 0)) >= 1

static func _tariff_rate(region_id: String, state: Dictionary, goods: Dictionary) -> float:
    return clampf(float(state.get("tariffs", {}).get(region_id, goods.get("economy", {}).get("default_tariff", 0.05))), 0.0, 0.5)

static func _fee_multiplier(state: Dictionary) -> float:
    var discount := float(_rank_for_xp(int(state.get("merchant_xp", 0))).get("fee_discount", 0.0))
    return 1.02 - discount


static func buy(party: PartyState, region_id: String, good_id: String, quantity: int, goods: Dictionary, state: Dictionary) -> String:
    if quantity < 1 or quantity > int(goods.get("max_transaction_quantity", MAX_QUANTITY)): return "Choose a valid quantity."
    var good: Dictionary = goods.get("goods", {}).get(good_id, {})
    if good.is_empty(): return "Unknown trade good."
    if not _guild_access(state, good): return "A merchant guild license is required for this commodity."
    var local := market_state(state, region_id, goods)
    var stock: Dictionary = local["stock"]
    if int(stock.get(good_id, 0)) < quantity: return "The market does not have enough stock."
    if cargo_weight(party, goods) + int(good.get("weight", 1)) * quantity > cargo_capacity(goods, state): return "Your cargo capacity is full."
    var unit := unit_price(region_id, good_id, goods, state)
    var tariff := _tariff_rate(region_id, state, goods)
    var total := roundi(float(unit * quantity) * (1.0 + tariff) * _fee_multiplier(state))
    if party.gold < total: return "Not enough gold, including local tariffs."
    party.gold -= total
    party.add_item(good_id, quantity)
    stock[good_id] = int(stock.get(good_id, 0)) - quantity
    var demand: Dictionary = local["demand"]
    demand[good_id] = int(demand.get(good_id, 0)) + quantity
    state["transactions"] = int(state.get("transactions", 0)) + 1
    state["tax_paid"] = int(state.get("tax_paid", 0)) + roundi(float(unit * quantity) * tariff)
    add_merchant_xp(state, maxi(1, quantity))
    return ""

static func sell(party: PartyState, region_id: String, good_id: String, quantity: int, goods: Dictionary, state: Dictionary) -> String:
    if quantity < 1 or quantity > int(goods.get("max_transaction_quantity", MAX_QUANTITY)): return "Choose a valid quantity."
    var good: Dictionary = goods.get("goods", {}).get(good_id, {})
    if good.is_empty(): return "Unknown trade good."
    if not _guild_access(state, good): return "A merchant guild license is required for this commodity."
    if party.item_count(good_id) < quantity: return "You do not have enough cargo."
    var local := market_state(state, region_id, goods)
    var gross := unit_price(region_id, good_id, goods, state) * quantity
    var tax := roundi(float(gross) * _tariff_rate(region_id, state, goods))
    var service_fee := roundi(float(gross) * maxf(0.0, _fee_multiplier(state) - 1.0))
    var payout := maxi(0, gross - tax - service_fee)
    if not party.remove_item(good_id, quantity): return "You do not have enough cargo."
    party.gold += payout
    var stock: Dictionary = local["stock"]
    stock[good_id] = int(stock.get(good_id, 0)) + quantity
    var demand: Dictionary = local["demand"]
    demand[good_id] = maxi(-20, int(demand.get(good_id, 0)) - quantity)
    state["transactions"] = int(state.get("transactions", 0)) + 1
    state["total_profit"] = int(state.get("total_profit", 0)) + payout
    state["tax_paid"] = int(state.get("tax_paid", 0)) + tax
    add_merchant_xp(state, maxi(2, quantity * 2))
    _record_contract_delivery(state, good_id, quantity, region_id, goods)
    return ""

static func _record_contract_delivery(state: Dictionary, good_id: String, quantity: int, region_id: String, goods: Dictionary) -> void:
    for active in state.get("active_contracts", []):
        var definition: Dictionary = goods.get("contracts", {}).get(str(active.get("id", "")), {})
        var destination := str(definition.get("destination", ""))
        if destination != "" and destination != region_id: continue
        var deliveries: Dictionary = active.get("deliveries", {})
        deliveries[good_id] = int(deliveries.get(good_id, 0)) + quantity
        active["deliveries"] = deliveries
        active["last_region"] = region_id

static func purchase_caravan(party: PartyState, state: Dictionary, goods: Dictionary) -> String:
    var caravan: Dictionary = state.get("caravan", {})
    if bool(caravan.get("owned", false)): return "You already own a caravan."
    var cost := int(goods.get("caravan", {}).get("purchase_cost", 1800))
    if party.gold < cost: return "A caravan costs %d gold." % cost
    party.gold -= cost
    caravan["owned"] = true
    state["caravan"] = caravan
    add_merchant_xp(state, 25)
    return ""

static func upgrade_caravan(party: PartyState, state: Dictionary, goods: Dictionary) -> String:
    var caravan: Dictionary = state.get("caravan", {})
    if not bool(caravan.get("owned", false)): return "Purchase a caravan first."
    var level := int(caravan.get("level", 0))
    if level >= int(goods.get("caravan", {}).get("max_level", 3)): return "Your caravan is fully upgraded."
    var cost := int(goods.get("caravan", {}).get("upgrade_base_cost", 900)) * (level + 1)
    if party.gold < cost: return "The caravan upgrade costs %d gold." % cost
    party.gold -= cost
    caravan["level"] = level + 1
    state["caravan"] = caravan
    return ""

static func hire_caravan_guard(party: PartyState, state: Dictionary, goods: Dictionary) -> String:
    var caravan: Dictionary = state.get("caravan", {})
    if not bool(caravan.get("owned", false)): return "Purchase a caravan first."
    var guards := int(caravan.get("guards", 0))
    if guards >= int(goods.get("caravan", {}).get("max_guards", 8)): return "Your caravan already has its maximum guard detail."
    var cost := int(goods.get("caravan", {}).get("guard_cost", 250))
    if party.gold < cost: return "Hiring a guard costs %d gold." % cost
    party.gold -= cost
    caravan["guards"] = guards + 1
    state["caravan"] = caravan
    return ""

static func join_guild(state: Dictionary, guild_id: String, goods: Dictionary) -> String:
    var guild: Dictionary = goods.get("guilds", {}).get(guild_id, {})
    if guild.is_empty(): return "Unknown merchant guild."
    if int(state.get("merchant_reputation", 0)) < int(guild.get("reputation_required", 0)): return "Your merchant reputation is too low to join this guild."
    var memberships: Dictionary = state.get("guilds", {})
    if memberships.has(guild_id): return "You already belong to this guild."
    memberships[guild_id] = {"standing":1, "joined":true, "contribution":0}
    state["guilds"] = memberships
    return ""

static func guild_contribute(party: PartyState, state: Dictionary, guild_id: String, amount: int, goods: Dictionary) -> String:
    if amount < 1: return "Choose a positive contribution."
    var guild: Dictionary = state.get("guilds", {}).get(guild_id, {})
    if not bool(guild.get("joined", false)): return "Join this guild before contributing."
    if party.gold < amount: return "Not enough gold."
    party.gold -= amount
    guild["contribution"] = int(guild.get("contribution", 0)) + amount
    guild["standing"] = clampi(1 + int(guild["contribution"]) / int(goods.get("guilds", {}).get(guild_id, {}).get("standing_cost", 500)), 1, 5)
    state["guilds"][guild_id] = guild
    return ""

static func accept_contract(state: Dictionary, contract_id: String, goods: Dictionary) -> String:
    if not goods.get("contracts", {}).has(contract_id): return "Unknown trade contract."
    if state.get("completed_contracts", []).has(contract_id): return "This contract has already been completed."
    for active in state.get("active_contracts", []):
        if str(active.get("id", "")) == contract_id: return "This contract is already active."
    if state.get("active_contracts", []).size() >= int(goods.get("economy", {}).get("max_active_contracts", 3)): return "You cannot manage any more active contracts."
    state["active_contracts"].append({"id":contract_id, "deliveries":{}})
    return ""

static func complete_contract(party: PartyState, state: Dictionary, contract_id: String, goods: Dictionary) -> String:
    var definition: Dictionary = goods.get("contracts", {}).get(contract_id, {})
    if definition.is_empty(): return "Unknown trade contract."
    var index := -1
    for i in range(state.get("active_contracts", []).size()):
        if str(state["active_contracts"][i].get("id", "")) == contract_id: index = i
    if index < 0: return "Accept this contract before completing it."
    var good_id := str(definition.get("good", ""))
    if int(state["active_contracts"][index].get("deliveries", {}).get(good_id, 0)) < int(definition.get("quantity", 0)): return "Contract delivery is incomplete."
    party.gold += int(definition.get("reward", 0))
    add_merchant_xp(state, int(definition.get("reputation", 20)) * 2)
    var guild_id := str(definition.get("guild", ""))
    if guild_id != "" and state.get("guilds", {}).has(guild_id):
        state["guilds"][guild_id]["standing"] = mini(5, int(state["guilds"][guild_id].get("standing", 1)) + 1)
    state["active_contracts"].remove_at(index)
    state["completed_contracts"].append(contract_id)
    return ""

static func set_tariff(state: Dictionary, region_id: String, rate: float, authorized: bool = false) -> String:
    if not authorized: return "Only the territory's recognized authority can change tariffs."
    state["tariffs"][region_id] = clampf(rate, 0.0, 0.5)
    return ""

static func set_route_policy(state: Dictionary, route_id: String, policy: Dictionary, authorized: bool = false) -> String:
    if not authorized: return "Only the recognized government can issue trade-route policy."
    state["route_policies"][route_id] = {"open":bool(policy.get("open", true)),
        "tariff_modifier":clampf(float(policy.get("tariff_modifier", 1.0)), 0.0, 3.0),
        "protected":bool(policy.get("protected", false)), "toll":maxi(0, int(policy.get("toll", 0)))}
    return ""

static func route_quote(route_id: String, goods: Dictionary, state: Dictionary) -> Dictionary:
    var route: Dictionary = goods.get("routes", {}).get(route_id, {})
    if route.is_empty(): return {}
    var policy: Dictionary = state.get("route_policies", {}).get(route_id, {})
    return {"id":route_id, "name":str(route.get("name", route_id)),
        "from":str(route.get("from", "")), "to":str(route.get("to", "")),
        "open":bool(policy.get("open", true)), "protected":bool(policy.get("protected", false)),
        "toll":int(policy.get("toll", route.get("base_toll", 0)))}

static func travel_route(party: PartyState, state: Dictionary, route_id: String, goods: Dictionary) -> String:
    var route := route_quote(route_id, goods, state)
    if route.is_empty(): return "Unknown trade route."
    if not bool(route["open"]): return "This trade route is closed by local authorities."
    if not bool(state.get("caravan", {}).get("owned", false)): return "A caravan is required to travel this trade route."
    if party.gold < int(route["toll"]): return "Not enough gold to pay the route toll."
    party.gold -= int(route["toll"])
    return ""

static func should_trigger_ambush(state: Dictionary, goods: Dictionary, route_id: String, rng: RandomNumberGenerator) -> bool:
    var route := route_quote(route_id, goods, state)
    if route.is_empty() or not bool(route.get("open", true)) or bool(route.get("protected", false)): return false
    var base_risk := float(goods.get("routes", {}).get(route_id, {}).get("base_risk", 0.2))
    var guards := int(state.get("caravan", {}).get("guards", 0))
    var level := int(state.get("caravan", {}).get("level", 0))
    return rng.randf() < clampf(base_risk - float(guards) * 0.025 - float(level) * 0.03, 0.02, 0.8)


static func resolve_caravan_ambush(party: PartyState, state: Dictionary, goods: Dictionary, rng: RandomNumberGenerator, route_id: String = "") -> Dictionary:
    var caravan: Dictionary = state.get("caravan", {})
    if not bool(caravan.get("owned", false)): return {"status":"no_caravan"}
    var route := route_quote(route_id, goods, state) if route_id != "" else {}
    if bool(route.get("protected", false)): return {"status":"avoided", "reason":"protected_route"}
    var guards := int(caravan.get("guards", 0))
    var protection := clampf(0.15 + float(guards) * 0.1 + float(caravan.get("level", 0)) * 0.08, 0.0, 0.9)
    if rng.randf() < protection:
        state["ambushes_survived"] = int(state.get("ambushes_survived", 0)) + 1
        add_merchant_xp(state, 8)
        return {"status":"defended", "guards":guards, "cargo_lost":0}
    var carried: Array = []
    for id in goods.get("goods", {}).keys():
        if party.item_count(str(id)) > 0: carried.append(str(id))
    if carried.is_empty(): return {"status":"escaped", "cargo_lost":0}
    var stolen_id := str(carried[rng.randi_range(0, carried.size() - 1)])
    var stolen := maxi(1, int(ceil(float(party.item_count(stolen_id)) * 0.25)))
    party.remove_item(stolen_id, stolen)
    state["cargo_lost"] = int(state.get("cargo_lost", 0)) + stolen
    var casualties := 1 if guards > 0 and rng.randf() < 0.2 else 0
    caravan["guards"] = maxi(0, guards - casualties)
    state["caravan"] = caravan
    return {"status":"raided", "good_id":stolen_id, "cargo_lost":stolen, "guards_lost":casualties}

static func smuggle_sell(party: PartyState, state: Dictionary, region_id: String, good_id: String, quantity: int,
        goods: Dictionary, rng: RandomNumberGenerator) -> Dictionary:
    if quantity < 1 or party.item_count(good_id) < quantity: return {"ok":false, "message":"Not enough cargo."}
    if not goods.get("goods", {}).has(good_id): return {"ok":false, "message":"Unknown trade good."}
    var guards := int(state.get("caravan", {}).get("guards", 0))
    var heat := int(state.get("smuggling_heat", 0))
    var chance := clampf(0.18 + _tariff_rate(region_id, state, goods) * 0.9 + float(heat) * 0.01 - float(guards) * 0.035, 0.05, 0.9)
    if rng.randf() < chance:
        party.remove_item(good_id, quantity)
        var fine := mini(party.gold, maxi(25, unit_price(region_id, good_id, goods, state) * quantity))
        party.gold -= fine
        state["smuggling_heat"] = mini(100, heat + 15)
        state["cargo_lost"] = int(state.get("cargo_lost", 0)) + quantity
        return {"ok":false, "caught":true, "cargo_lost":quantity, "fine":fine, "message":"Customs seized the cargo and issued a fine."}
    var payout := unit_price(region_id, good_id, goods, state) * quantity
    party.remove_item(good_id, quantity)
    party.gold += payout
    state["smuggling_heat"] = mini(100, heat + 5)
    state["transactions"] = int(state.get("transactions", 0)) + 1
    add_merchant_xp(state, quantity)
    return {"ok":true, "caught":false, "payout":payout, "message":"The contraband sale succeeded."}

static func reduce_smuggling_heat(state: Dictionary, amount: int = 10) -> void:
    state["smuggling_heat"] = maxi(0, int(state.get("smuggling_heat", 0)) - maxi(0, amount))

static func market_name(region_id: String, goods: Dictionary) -> String:
    return str(goods.get("markets", {}).get(region_id, {}).get("name", region_id))
