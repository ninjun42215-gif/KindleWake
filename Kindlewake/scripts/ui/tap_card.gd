class_name TapCard
extends PanelContainer
## A tappable card that never fights the scrolling around it. A plain Button swallows the finger when a drag starts
## on it, so lists made of buttons are hard to scroll on a phone. A TapCard tells a tap from a drag: a short press
## and release emits `tapped`; moving further than DEADZONE scrolls the nearest ScrollContainer instead and cancels the tap.
## Children must have mouse_filter IGNORE (PartyScreen._seal does that). Mouse wheel scrolls too.

signal tapped()

const DEADZONE := 12.0
const WHEEL_STEP := 90

var disabled: bool = false
var style_normal: StyleBox = null
var style_pressed: StyleBox = null
var style_disabled: StyleBox = null
var _down: bool = false
var _dragging: bool = false
var _travel: float = 0.0
var _acc: float = 0.0
var _scroller: ScrollContainer = null


func _init() -> void:
    mouse_filter = Control.MOUSE_FILTER_STOP


func set_styles(normal: StyleBox, pressed: StyleBox, dimmed: StyleBox) -> void:
    style_normal = normal
    style_pressed = pressed
    style_disabled = dimmed
    _look(false)


func set_disabled(value: bool) -> void:
    disabled = value
    _look(false)


func _look(pressed: bool) -> void:
    var st: StyleBox = style_normal
    if disabled:
        st = style_disabled
    elif pressed:
        st = style_pressed
    if st != null:
        add_theme_stylebox_override("panel", st)


func _find_scroller() -> void:
    _scroller = null
    var n: Node = get_parent()
    while n != null:
        if n is ScrollContainer:
            _scroller = n as ScrollContainer
            return
        n = n.get_parent()


func _scroll_by(amount: int) -> void:
    if _scroller == null or not is_instance_valid(_scroller):
        _find_scroller()
    if _scroller != null:
        _scroller.scroll_vertical += amount


func _gui_input(event: InputEvent) -> void:
    if event is InputEventMouseButton:
        var mb: InputEventMouseButton = event
        if mb.button_index == MOUSE_BUTTON_LEFT:
            if mb.pressed:
                _down = true
                _dragging = false
                _travel = 0.0
                _acc = 0.0
                _find_scroller()
                _look(true)
            elif _down:
                var was_tap: bool = not _dragging
                _down = false
                _dragging = false
                _look(false)
                if was_tap and not disabled:
                    tapped.emit()
            accept_event()
        elif mb.pressed and mb.button_index == MOUSE_BUTTON_WHEEL_UP:
            _scroll_by(-WHEEL_STEP)
            accept_event()
        elif mb.pressed and mb.button_index == MOUSE_BUTTON_WHEEL_DOWN:
            _scroll_by(WHEEL_STEP)
            accept_event()
    elif event is InputEventMouseMotion and _down:
        var mm: InputEventMouseMotion = event
        _travel += mm.relative.length()
        if not _dragging and _travel > DEADZONE:
            _dragging = true
            _look(false)
        if _dragging:
            _acc -= mm.relative.y
            var whole: int = int(_acc)
            if whole != 0:
                _scroll_by(whole)
                _acc -= float(whole)
        accept_event()
