class_name ShopSystem
extends RefCounted
## The gold sink: buy and sell items and runes. Pure rules on a PartyState (no nodes), so it is testable headless.
## `db` needs "items" and "runes"; `shop` is data/shop.json ({"sell_ratio", "items": [ids], "sigils": [ids]}).
## Every method returns "" on success, otherwise a short reason for the UI.


static func sell_ratio(shop: Dictionary) -> float:
    return clampf(float(shop.get("sell_ratio", 0.5)), 0.0, 1.0)


static func sell_price(base_price: int, shop: Dictionary) -> int:
    return int(floor(float(base_price) * sell_ratio(shop)))


static func item_price(item_id: String, db: Dictionary) -> int:
    var it: Dictionary = (db.get("items", {}) as Dictionary).get(item_id, {})
    return int(it.get("price", 0))


static func sigil_price(sigil_id: String, db: Dictionary) -> int:
    var sd: Dictionary = (db.get("runes", db.get("sigils", {})) as Dictionary).get(sigil_id, {})
    return int(sd.get("price", 0))


## kind is "item" or "rune".
static func for_sale(shop: Dictionary, kind: String, id: String) -> bool:
    var list: Array = shop.get("items", []) if kind == "item" else shop.get("runes", shop.get("sigils", []))
    return list.has(id)


## Everything the stall sells: [{"kind", "id", "name", "price"}], items first, in the order of shop.json.
static func stock(shop: Dictionary, db: Dictionary) -> Array:
    var out: Array = []
    var items: Dictionary = db.get("items", {})
    var runes: Dictionary = db.get("runes", db.get("sigils", {}))
    for id in (shop.get("items", []) as Array):
        var it: Dictionary = items.get(str(id), {})
        if not it.is_empty() and int(it.get("price", 0)) > 0:
            out.append({"kind": "item", "id": str(id), "name": str(it.get("name", id)), "price": int(it["price"])})
    for id in (shop.get("runes", shop.get("sigils", [])) as Array):
        var rd: Dictionary = runes.get(str(id), {})
        if not rd.is_empty() and int(rd.get("price", 0)) > 0:
            out.append({"kind": "rune", "id": str(id), "name": str(rd.get("name", id)), "price": int(rd["price"])})
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


static func buy_rune(party: PartyState, rune_id: String, db: Dictionary, shop: Dictionary) -> String:
    var price: int = sigil_price(rune_id, db)
    if not for_sale(shop, "rune", rune_id) or price <= 0:
        return "Not for sale."
    if party.gold < price:
        return "Not enough gold."
    party.gold -= price
    party.add_rune(rune_id)
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
static func sell_rune(party: PartyState, inv_index: int, db: Dictionary, shop: Dictionary) -> String:
    if inv_index < 0 or inv_index >= party.sigil_inv.size():
        return "That rune is not in the bag."
    var inst: Dictionary = party.sigil_inv[inv_index]
    var rune_def: Dictionary = (db.get("runes", db.get("sigils", {})) as Dictionary).get(str(inst.get("id", "")), {})
    if bool(rune_def.get("unique", false)) or bool(rune_def.get("heirloom", false)):
        return "Unique and heirloom runes cannot be sold."
    var price: int = sigil_price(str(inst.get("id", "")), db)
    if price <= 0:
        return "That cannot be sold."
    party.sigil_inv.remove_at(inv_index)
    party.gold += sell_price(price, shop)
    return ""


## Compatibility wrappers for older scripts and v0.9.0 inventory saves.
static func buy_sigil(party: PartyState, rune_id: String, db: Dictionary, shop: Dictionary) -> String:
    return buy_rune(party, rune_id, db, shop)

static func sell_sigil(party: PartyState, inv_index: int, db: Dictionary, shop: Dictionary) -> String:
    return sell_rune(party, inv_index, db, shop)
