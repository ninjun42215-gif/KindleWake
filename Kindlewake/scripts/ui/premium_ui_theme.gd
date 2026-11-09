class_name PremiumUITheme
extends RefCounted
## Shared premium exploration UI palette: deep ink, warm parchment and restrained brass.

const INK := Color("#101b24")
const INK_RAISED := Color("#1b2b35")
const BRASS := Color("#b9955e")
const BRASS_LIGHT := Color("#e4c991")
const PARCHMENT := Color("#f0e5ce")
const MUTED := Color("#aeb8b4")


static func panel_style(alpha: float = 0.9) -> StyleBoxFlat:
    var style := StyleBoxFlat.new()
    style.bg_color = Color(INK.r, INK.g, INK.b, alpha)
    style.border_color = Color(BRASS.r, BRASS.g, BRASS.b, 0.92)
    style.set_border_width_all(2)
    style.set_corner_radius_all(12)
    style.set_content_margin_all(12)
    style.shadow_color = Color(0.0, 0.0, 0.0, 0.34)
    style.shadow_size = 10
    style.shadow_offset = Vector2(0, 4)
    return style


static func apply_button(button: Button) -> void:
    var normal := StyleBoxFlat.new()
    normal.bg_color = INK_RAISED
    normal.border_color = BRASS
    normal.set_border_width_all(2)
    normal.set_corner_radius_all(10)
    normal.set_content_margin_all(10)
    var hover: StyleBoxFlat = normal.duplicate()
    hover.bg_color = Color("#29404a")
    hover.border_color = BRASS_LIGHT
    var pressed: StyleBoxFlat = normal.duplicate()
    pressed.bg_color = Color("#0b141a")
    pressed.border_color = BRASS_LIGHT
    var focus: StyleBoxFlat = normal.duplicate()
    focus.bg_color = Color("#223944")
    focus.border_color = Color("#f3dba9")
    focus.set_border_width_all(3)
    var disabled: StyleBoxFlat = normal.duplicate()
    disabled.bg_color = Color("#172129")
    disabled.border_color = Color("#59646a")
    button.add_theme_stylebox_override("normal", normal)
    button.add_theme_stylebox_override("hover", hover)
    button.add_theme_stylebox_override("pressed", pressed)
    button.add_theme_stylebox_override("focus", focus)
    button.add_theme_stylebox_override("disabled", disabled)
    button.add_theme_color_override("font_color", PARCHMENT)
    button.add_theme_color_override("font_hover_color", Color("#fff4dc"))
    button.add_theme_color_override("font_pressed_color", BRASS_LIGHT)
    button.add_theme_color_override("font_focus_color", Color("#fff4dc"))
    button.add_theme_color_override("font_disabled_color", MUTED)
