class_name ExplorationControls
extends RefCounted
## Shared controller/keyboard mapping for overworld, towns and dungeons.

static func configure() -> void:
    if not InputMap.has_action("sprint"):
        InputMap.add_action("sprint")
    if InputMap.action_get_events("sprint").is_empty():
        var shift := InputEventKey.new()
        shift.physical_keycode = KEY_SHIFT
        InputMap.action_add_event("sprint", shift)
        var pad := InputEventJoypadButton.new()
        pad.button_index = JOY_BUTTON_B
        InputMap.action_add_event("sprint", pad)


static func movement_vector() -> Vector2:
    return Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down", 0.18)


static func running() -> bool:
    return Input.is_action_pressed("sprint")
