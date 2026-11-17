extends RefCounted
## Compact, original item-category icon atlas used by the party equipment and shop UI.

const ICON_ATLAS = preload("res://assets/art/items/equipment_icons.svg")
const CELL_SIZE := 64
const CELLS := {
    "sword": Vector2i(0, 0),
    "greatsword": Vector2i(1, 0),
    "bow": Vector2i(2, 0),
    "spear": Vector2i(3, 0),
    "axe": Vector2i(0, 1),
    "mace": Vector2i(1, 1),
    "crossbow": Vector2i(2, 1),
    "staff": Vector2i(3, 1),
    "dagger": Vector2i(0, 2),
    "armor": Vector2i(1, 2),
    "shield": Vector2i(2, 2),
    "helm": Vector2i(3, 2),
    "accessory": Vector2i(0, 3),
    "trade_good": Vector2i(1, 3),
    "consumable": Vector2i(2, 3),
    "unknown": Vector2i(3, 3)
}

static func category_for_item(item_id: String, item_definition: Dictionary) -> String:
    if bool(item_definition.get("trade_good", false)) or str(item_definition.get("slot", "")) == "trade_good":
        return "trade_good"

    var slot := str(item_definition.get("slot", ""))
    if slot == "weapon":
        var weapon_id := str(item_definition.get("weapon_id", item_id))
        for prefix in ["common_", "uncommon_", "rare_", "epic_", "legendary_", "mythical_", "unique_"]:
            if weapon_id.begins_with(prefix):
                weapon_id = weapon_id.trim_prefix(prefix)
                break
        if weapon_id == "greatsword" or weapon_id == "kingbreaker":
            return "greatsword"
        if weapon_id.contains("crossbow"):
            return "crossbow"
        if weapon_id.contains("bow"):
            return "bow"
        if weapon_id.contains("spear"):
            return "spear"
        if weapon_id.contains("battle_axe") or weapon_id.contains("hand_axe") or weapon_id.contains("axe"):
            return "axe"
        if weapon_id.contains("mace"):
            return "mace"
        if weapon_id.contains("staff"):
            return "staff"
        if weapon_id.contains("dagger"):
            return "dagger"
        return "sword"
    if slot == "armor":
        return "armor"
    if slot == "offhand":
        return "shield"
    if slot == "helm":
        return "helm"
    if slot == "accessory" or slot.begins_with("accessory"):
        return "accessory"
    if slot == "consumable":
        return "consumable"
    return "unknown"


static func category_for_slot(slot: String) -> String:
    if slot == "weapon":
        return "sword"
    if slot == "armor":
        return "armor"
    if slot == "offhand":
        return "shield"
    if slot == "helm":
        return "helm"
    if slot == "accessory" or slot.begins_with("accessory"):
        return "accessory"
    return "unknown"


static func icon_for_item(item_id: String, item_definition: Dictionary, size: int = 40) -> TextureRect:
    return _icon(category_for_item(item_id, item_definition), size)


static func icon_for_slot(slot: String, size: int = 40) -> TextureRect:
    return _icon(category_for_slot(slot), size)


static func _icon(category: String, size: int) -> TextureRect:
    var cell: Vector2i = CELLS.get(category, CELLS["unknown"])
    var atlas_region := AtlasTexture.new()
    atlas_region.atlas = ICON_ATLAS
    atlas_region.region = Rect2(cell.x * CELL_SIZE, cell.y * CELL_SIZE, CELL_SIZE, CELL_SIZE)
    var icon := TextureRect.new()
    icon.texture = atlas_region
    icon.custom_minimum_size = Vector2(size, size)
    icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
    icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
    icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
    return icon
