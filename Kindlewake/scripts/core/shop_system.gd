class_name ShopSystem
extends RefCounted
## The gold sink: buy and sell items and sigils. Pure rules on a PartyState (no nodes), so it is testable headless.
## `db` needs "items" and "sigils"; `shop` is data/shop.json ({"sell_ratio", "items": [ids], "sigils": [ids]}).
## Every method returns "" on success, otherwise a short reason for the UI.


static func sell_ratio(shop: Dictionary) -> float:
    return clampf(float(shop.get("sell_ratio", 0.5)), 0.0, 1.0)


static func sell_price(base_price: int, shop: Dictionary) -> int:
    return int(floor(float(base_price) * sell_ratio(shop)))


static func item_price(item_id: String, db: Dictionary) -> int:
    var it: Dictionary = (db.get("items", {}) as Dictionary).get(item_id, {})
    return int(it.get("price", 0))


static func sigil_price(sigil_id: String, db: Dictionary) -> int:
    var sd: Dictionary = (db.get("sigils", {}) as Dictionary).get(sigil_id, {})
    return int(sd.get("price", 0))


## kind is "item" or "sigil".
static func for_sale(shop: Dictionary, kind: String, id: String) -> bool:
    var list: Array = shop.get("items" if kind == "item" else "sigils", [])
    return list.has(id)


## Everything the stall sells: [{"kind", "id", "name", "price"}], items first, in the order of shop.json.
static func stock(shop: Dictionary, db: Dictionary) -> Array:
    var out: Array = []
    var items: Dictionary = db.get("items", {})
    var sigils: Dictionary = db.get("sigils", {})
    for id in (shop.get("items", []) as Array):
        var it: Dictionary = items.get(str(id), {})
        if not it.is_empty() and int(it.get("price", 0)) > 0:
            out.append({"kind": "item", "id": str(id), "name": str(it.get("name", id)), "price": int(it["price"])})
    for id in (shop.get("sigils", []) as Array):
        var sd: Dictionary = sigils.get(str(id), {})
        if not sd.is_empty() and int(sd.get("price", 0)) > 0:
            out.append({"kind": "sigil", "id": str(id), "name": str(sd.get("name", id)), "price": int(sd["price"])})
    return out


static func buy_item(party: PartyState, item_id: String, db: Dictionary, shop: Dictionary) -> String:
    var price: int = item_price(item_id, db)
    if not for_sale(shop, "item", item_id) or price <= 0:
        return "Not for sale."
    if party.gold < price:
        return "Not enough gold."
    party.gold -= price
    party.add_item(item_id, 1)
    return ""


static func buy_sigil(party: PartyState, sigil_id: String, db: Dictionary, shop: Dictionary) -> String:
    var price: int = sigil_price(sigil_id, db)
    if not for_sale(shop, "sigil", sigil_id) or price <= 0:
        return "Not for sale."
    if party.gold < price:
        return "Not enough gold."
    party.gold -= price
    party.add_sigil(sigil_id)
    return ""


## Only unequipped items can be sold (equipped ones are not in the inventory). Heirlooms and bound items never sell.
static func sell_item(party: PartyState, item_id: String, db: Dictionary, shop: Dictionary) -> String:
    var it: Dictionary = (db.get("items", {}) as Dictionary).get(item_id, {})
    if it.is_empty():
        return "Unknown item."
    if party.item_count(item_id) <= 0:
        return "You do not have that item."
    var price: int = int(it.get("price", 0))
    if price <= 0 or str(it.get("rarity", "")) == "heirloom" or str(it.get("bound_to", "")) != "":
        return "That cannot be sold."
    if not party.remove_item(item_id, 1):
        return "You do not have that item."
    party.gold += sell_price(price, shop)
    return ""


## Sells sigil number `inv_index` of the bag (flat price, whatever its level).
static func sell_sigil(party: PartyState, inv_index: int, db: Dictionary, shop: Dictionary) -> String:
    if inv_index < 0 or inv_index >= party.sigil_inv.size():
        return "That sigil is not in the bag."
    var inst: Dictionary = party.sigil_inv[inv_index]
    var price: int = sigil_price(str(inst.get("id", "")), db)
    if price <= 0:
        return "That cannot be sold."
    party.sigil_inv.remove_at(inv_index)
    party.gold += sell_price(price, shop)
    return ""
