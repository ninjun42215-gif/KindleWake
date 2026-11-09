class_name ExplorationControls
extends RefCounted
## Shared controller/keyboard mapping for overworld, towns and dungeons.

static func configure() -> void:
    if not InputMap.has_action("sprint"):
        InputMap.add_action("sprint")
    if not InputMap.has_action("interact"):
        InputMap.add_action("interact")
    if InputMap.action_get_events("interact").is_empty():
        var key_e := InputEventKey.new()
        key_e.physical_keycode = KEY_E
        InputMap.action_add_event("interact", key_e)
        var pad_a := InputEventJoypadButton.new()
        pad_a.button_index = JOY_BUTTON_A
        InputMap.action_add_event("interact", pad_a)
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
