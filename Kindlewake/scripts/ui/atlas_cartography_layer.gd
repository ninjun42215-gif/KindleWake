extends Control
## Non-interactive cartographic finish for the seven-continent atlas.
## Uses the same normalized map rectangle as the map and heraldry layers.

const AtlasLayoutScript = preload("res://scripts/ui/atlas_layout.gd")
const INK := Color("#101b24")
const BRASS := Color("#b9955e")
const BRASS_LIGHT := Color("#e4c991")


func _ready() -> void:
    mouse_filter = Control.MOUSE_FILTER_IGNORE
    z_index = 2
    queue_redraw()


func _notification(what: int) -> void:
    if what == NOTIFICATION_RESIZED:
        queue_redraw()


static func compass_center_for(view_size: Vector2) -> Vector2:
    var rect: Rect2 = AtlasLayoutScript.map_rect_for_size(view_size)
    return rect.position + Vector2(rect.size.x * 0.09, rect.size.y * 0.12)


static func compass_radius_for(view_size: Vector2) -> float:
    var rect: Rect2 = AtlasLayoutScript.map_rect_for_size(view_size)
    return clampf(minf(rect.size.x, rect.size.y) * 0.055, 18.0, 28.0)


func _draw() -> void:
    var rect: Rect2 = AtlasLayoutScript.map_rect_for_size(size)
    if rect.size.x <= 0.0 or rect.size.y <= 0.0:
        return
    _draw_corner_marks(rect)
    _draw_compass(compass_center_for(size), compass_radius_for(size))


func _draw_corner_marks(rect: Rect2) -> void:
    var inset := 7.0
    var arm: float = clampf(minf(rect.size.x, rect.size.y) * 0.045, 14.0, 24.0)
    var tint := Color(BRASS.r, BRASS.g, BRASS.b, 0.72)
    # The north-west corner is deliberately reserved for the compass rose.
    var marks: Array[Dictionary] = [
        {"point": Vector2(rect.end.x - inset, rect.position.y + inset), "direction": Vector2(-1, 1)},
        {"point": Vector2(rect.position.x + inset, rect.end.y - inset), "direction": Vector2(1, -1)},
        {"point": rect.end - Vector2(inset, inset), "direction": Vector2(-1, -1)}
    ]
    for mark in marks:
        var point: Vector2 = mark["point"]
        var direction: Vector2 = mark["direction"]
        draw_line(point, point + Vector2(arm * direction.x, 0.0), tint, 1.4, true)
        draw_line(point, point + Vector2(0.0, arm * direction.y), tint, 1.4, true)
        draw_circle(point, 2.0, tint)


func _draw_compass(center: Vector2, radius: float) -> void:
    var dark := Color(INK.r, INK.g, INK.b, 0.86)
    draw_circle(center, radius + 5.0, dark)
    draw_arc(center, radius + 4.0, 0.0, TAU, 48, BRASS, 1.4, true)

    var points := PackedVector2Array()
    for index in range(16):
        var angle: float = -PI * 0.5 + TAU * float(index) / 16.0
        var reach: float = radius if index % 2 == 0 else radius * 0.30
        points.append(center + Vector2(cos(angle), sin(angle)) * reach)
    draw_colored_polygon(points, Color("#9e8052"))
    var outline := points.duplicate()
    outline.append(points[0])
    draw_polyline(outline, BRASS_LIGHT, 1.1, true)

    draw_line(center + Vector2(0.0, -radius * 0.68), center + Vector2(0.0, radius * 0.68), Color("#f2dfb5"), 1.0, true)
    draw_line(center + Vector2(-radius * 0.68, 0.0), center + Vector2(radius * 0.68, 0.0), Color("#f2dfb5"), 1.0, true)
    draw_circle(center, radius * 0.16, dark)
    draw_arc(center, radius * 0.16, 0.0, TAU, 24, BRASS_LIGHT, 1.0, true)

    var font: Font = ThemeDB.fallback_font
    draw_string(font, Vector2(center.x - 5.0, center.y - radius - 6.0), "N", HORIZONTAL_ALIGNMENT_CENTER, 10.0, 9, BRASS_LIGHT)
    draw_string(font, Vector2(center.x + radius + 1.0, center.y + 3.0), "E", HORIZONTAL_ALIGNMENT_LEFT, 9.0, 8, BRASS)
    draw_string(font, Vector2(center.x - radius - 9.0, center.y + 3.0), "W", HORIZONTAL_ALIGNMENT_RIGHT, 9.0, 8, BRASS)
    draw_string(font, Vector2(center.x - 4.0, center.y + radius + 12.0), "S", HORIZONTAL_ALIGNMENT_CENTER, 9.0, 8, BRASS)
