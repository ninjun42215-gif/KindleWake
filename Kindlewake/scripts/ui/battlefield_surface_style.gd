extends RefCounted
## Cached, draw-only surface detail for the tactical isometric battlefield.
## The atlas overlays the existing terrain fill; it never changes movement, cover, height or line of sight.

const ATLAS_PATH := "res://assets/art/tiles/battlefield_surface_atlas.svg"
const CELL_WIDTH := 64
const CELL_HEIGHT := 32
const ATLAS_CELL_COUNT := 22
const TERRAIN_BASE_CELL := {
	"grass": 0,
	"forest": 2,
	"road": 4,
	"hill": 6,
	"ford": 8,
	"deep_water": 10,
	"water": 8,
	"marsh": 12,
	"snow": 14,
	"ash": 16,
	"ruins": 18,
	"cliff": 20
}

var _atlas: Texture2D


func _init() -> void:
	_atlas = load(ATLAS_PATH) as Texture2D


## Stable two-variant selection prevents the same micro-detail from repeating in a rigid grid.
## Bridge planks and raised rock walls keep their existing bespoke renderer and intentionally return -1.
static func cell_index_for(terrain_id: String, cell: Vector2i) -> int:
	var base: int = int(TERRAIN_BASE_CELL.get(terrain_id.strip_edges().to_lower(), -1))
	if base < 0:
		return -1
	var variant: int = posmod(cell.x * 17 + cell.y * 31 + cell.x * cell.y * 7, 2)
	return base + variant


func has_atlas() -> bool:
	return _atlas != null


## Draws one transparent 64x32 detail cell over the existing isometric diamond.
## The atlas is loaded once per battle scene; no per-tile texture construction or animation is used.
func draw_tile(canvas: CanvasItem, terrain_id: String, center: Vector2, cell: Vector2i) -> bool:
	if _atlas == null:
		return false
	var index: int = cell_index_for(terrain_id, cell)
	if index < 0 or index >= ATLAS_CELL_COUNT:
		return false
	var source := Rect2(Vector2(float(index * CELL_WIDTH), 0.0), Vector2(CELL_WIDTH, CELL_HEIGHT))
	var target := Rect2(center - Vector2(CELL_WIDTH * 0.5, CELL_HEIGHT * 0.5), Vector2(CELL_WIDTH, CELL_HEIGHT))
	var opacity: float = 0.66 + float(posmod(cell.x * 7 + cell.y * 11, 4)) * 0.06
	canvas.draw_texture_rect_region(_atlas, target, source, Color(1.0, 1.0, 1.0, opacity))
	return true
