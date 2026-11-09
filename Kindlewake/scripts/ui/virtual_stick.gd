class_name VirtualStick
extends Control
## Compact floating-style touch stick. Controller and keyboard remain fully supported.
signal vector_changed(value: Vector2)

var value: Vector2 = Vector2.ZERO
var pointer_id: int = -1
var mouse_active: bool = false
var radius: float = 58.0
var knob_radius: float = 23.0


func _ready() -> void:
    custom_minimum_size = Vector2(156, 156)
    mouse_filter = Control.MOUSE_FILTER_STOP
    queue_redraw()


func _gui_input(event: InputEvent) -> void:
    if event is InputEventScreenTouch:
        var touch := event as InputEventScreenTouch
        if touch.pressed and pointer_id == -1:
            pointer_id = touch.index
            _update_value(touch.position)
        elif not touch.pressed and touch.index == pointer_id:
            pointer_id = -1
            _set_value(Vector2.ZERO)
    elif event is InputEventScreenDrag:
        var drag := event as InputEventScreenDrag
        if drag.index == pointer_id:
            _update_value(drag.position)
    elif event is InputEventMouseButton and (event as InputEventMouseButton).button_index == MOUSE_BUTTON_LEFT:
        var mb := event as InputEventMouseButton
        mouse_active = mb.pressed
        if mouse_active:
            _update_value(mb.position)
        else:
            _set_value(Vector2.ZERO)
    elif event is InputEventMouseMotion and mouse_active:
        _update_value((event as InputEventMouseMotion).position)


func _update_value(point: Vector2) -> void:
    var offset := point - size * 0.5
    _set_value(offset.limit_length(1.0) if offset.length() <= radius else offset.normalized())


func _set_value(next: Vector2) -> void:
    value = next
    vector_changed.emit(value)
    queue_redraw()


func _draw() -> void:
    var centre := size * 0.5
    draw_circle(centre, radius + 5.0, Color(0.025, 0.045, 0.055, 0.62))
    draw_arc(centre, radius, 0.0, TAU, 48, Color("#b9c5bc"), 2.0, true)
    draw_circle(centre + value * radius, knob_radius, Color("#d6bd88", 0.94))
    draw_arc(centre + value * radius, knob_radius, 0.0, TAU, 32, Color("#fff0cb"), 2.0, true)
