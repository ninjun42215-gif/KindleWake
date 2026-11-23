extends Control
## Non-interactive heraldry overlay for the seven-continent campaign atlas.
## The map and all labels remain owned by GlobalAtlas; this layer only adds
## original, scalable sigils and never intercepts touch or controller input.

const SIGIL_ATLAS: Texture2D = preload("res://assets/art/atlas/continent_sigils.svg")
const AtlasLayoutScript = preload("res://scripts/ui/atlas_layout.gd")
const SIGIL_CELL_SIZE := 128.0
const SIGIL_CELLS := {
    "eldrimar": 0,
    "thalassar": 1,
    "varakhan": 2,
    "nhalor": 3,
    "veyrwood": 4,
    "asterreach": 5,
    "ilyr": 6
}

const INK := Color("#101b24")
const BRASS := Color("#9d8b68")
const BRASS_LIGHT := Color("#e4c991")


func _ready() -> void:
    mouse_filter = Control.MOUSE_FILTER_IGNORE
    texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
    z_index = 1
    queue_redraw()


func _notification(what: int) -> void:
    if what == NOTIFICATION_RESIZED:
        queue_redraw()


func _draw() -> void:
    var continents: Array = GameData.continents.get("continents", [])
    if continents.is_empty():
        return

    var portrait_layout: bool = size.y > size.x
    var map_rect: Rect2 = AtlasLayoutScript.map_rect_for_size(size)
    var icon_size: float = 38.0 if portrait_layout else 46.0
    var medallion_radius: float = icon_size * 0.52

    for item in continents:
        if typeof(item) != TYPE_DICTIONARY:
            continue
        var continent: Dictionary = item
        var continent_id: String = str(continent.get("id", ""))
        var cell_index: int = int(SIGIL_CELLS.get(continent_id, -1))
        if cell_index < 0:
            continue

        var label_position: Array = continent.get("map_label", [0.5, 0.5])
        if label_position.size() < 2:
            continue
        var map_anchor := map_rect.position + Vector2(
            float(label_position[0]),
            float(label_position[1])
        ) * map_rect.size
        var center := map_anchor + Vector2(0.0, -icon_size * 0.56)

        draw_circle(center + Vector2(0.0, 2.0), medallion_radius + 1.5, Color(0.0, 0.0, 0.0, 0.34))
        draw_circle(center, medallion_radius, Color(INK.r, INK.g, INK.b, 0.96))
        var rim: Color = BRASS_LIGHT if bool(continent.get("current", false)) else BRASS
        draw_arc(center, medallion_radius, 0.0, TAU, 36, rim, 2.0, true)

        var source := Rect2(
            float(cell_index) * SIGIL_CELL_SIZE,
            0.0,
            SIGIL_CELL_SIZE,
            SIGIL_CELL_SIZE
        )
        var destination_size := Vector2(icon_size, icon_size)
        var destination := Rect2(center - destination_size * 0.5, destination_size)
        draw_texture_rect_region(SIGIL_ATLAS, destination, source, Color.WHITE)
