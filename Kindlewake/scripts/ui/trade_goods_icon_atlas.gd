class_name TradeGoodsIconAtlas
extends RefCounted
## Original 12-cell trade-goods icon atlas. Stable good IDs map to fixed cells.

const ATLAS_PATH := "res://assets/art/markets/trade_goods_atlas.svg"
const CELL_SIZE := 64
const COLUMNS := 6
const GOOD_CELLS := {
    "trade_grain": 0,
    "trade_salt": 1,
    "trade_dried_fish": 2,
    "trade_timber": 3,
    "trade_iron_ore": 4,
    "trade_herbs": 5,
    "trade_wool": 6,
    "trade_leather": 7,
    "trade_honey": 8,
    "trade_pearls": 9,
    "trade_glassware": 10,
    "trade_spices": 11
}

static var _atlas_texture: Texture2D


static func atlas_texture() -> Texture2D:
    if _atlas_texture == null:
        _atlas_texture = load(ATLAS_PATH) as Texture2D
    return _atlas_texture


static func texture_for(good_id: String) -> AtlasTexture:
    if not GOOD_CELLS.has(good_id):
        return null
    var texture := atlas_texture()
    if texture == null:
        return null
    var index: int = int(GOOD_CELLS[good_id])
    var cell := Vector2i(index % COLUMNS, int(index / COLUMNS))
    var region := Rect2(Vector2(cell) * CELL_SIZE, Vector2(CELL_SIZE, CELL_SIZE))
    var result := AtlasTexture.new()
    result.atlas = texture
    result.region = region
    return result


static func has_icon(good_id: String) -> bool:
    return GOOD_CELLS.has(good_id)
