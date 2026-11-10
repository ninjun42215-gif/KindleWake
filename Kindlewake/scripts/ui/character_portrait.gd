extends Control
## Council portrait renderer. Uses the exact idle soldier sheet and draw helper used by BattleScene.
## A vector fallback keeps the council readable when the optional sprite sheet is missing.

var character_id: String = ""


func set_character(value: String) -> void:
	character_id = value
	queue_redraw()


func _ready() -> void:
	custom_minimum_size = Vector2(72, 78)
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func _draw() -> void:
	var frame := Rect2(Vector2.ZERO, size)
	draw_rect(frame, Color(0.055, 0.075, 0.09, 0.95), true)
	draw_rect(frame, Color(0.36, 0.43, 0.48, 0.9), false, 1.0)
	var feet := Vector2(size.x * 0.5, size.y * 0.92)
	var scale_value := minf(size.x, size.y) / 100.0 * 0.94
	if Art.draw_unit(self, "soldier", "idle", 0.0, feet, scale_value, false, Color(0.88, 0.92, 0.98)):
		return
	var center := Vector2(size.x * 0.5, size.y * 0.43)
	draw_circle(center + Vector2(0, -11), 9.0, Color(0.72, 0.61, 0.49))
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-15, 24), center + Vector2(-10, -2),
		center + Vector2(10, -2), center + Vector2(15, 24)
	]), Color(0.34, 0.43, 0.55))
