class_name CharacterPreview
extends Control
## Original geometric bust preview for creator choices. This is a UI preview, not production portrait art.

var profile: Dictionary = {}


static func jaw_ratio_for_presentation(presentation_id: String) -> float:
    if presentation_id == "masculine":
        return 0.84
    if presentation_id == "feminine":
        return 0.72
    return 0.78


func set_profile(value: Dictionary) -> void:
    profile = value.duplicate(true)
    queue_redraw()


func _draw() -> void:
    var w: float = size.x
    var h: float = size.y
    if w < 20.0 or h < 20.0:
        return
    draw_rect(Rect2(Vector2.ZERO, size), Color("#111923"), true)
    draw_rect(Rect2(Vector2(2, 2), size - Vector2(4, 4)), Color("#293746"), false, 2.0)
    var cx: float = w * 0.5
    var head_y: float = h * 0.32
    var skin: Color = _skin_color(str(profile.get("skin", "warm")))
    var hair: Color = _hair_color(str(profile.get("hair", "short_dark")))
    var coat: Color = _coat_color(str(profile.get("origin", "fallen_heir")))
    var body_w: float = 112.0
    var build_id: String = str(profile.get("build", "athletic"))
    if build_id == "lean":
        body_w = 88.0
    elif build_id == "sturdy":
        body_w = 142.0
    var body_top: float = h * 0.57
    draw_rect(Rect2(Vector2(cx - 18.0, head_y + 42.0), Vector2(36.0, 42.0)), skin, true)
    draw_colored_polygon(PackedVector2Array([
        Vector2(cx - body_w * 0.5, h), Vector2(cx - body_w * 0.43, body_top + 20.0),
        Vector2(cx - 35.0, body_top), Vector2(cx + 35.0, body_top),
        Vector2(cx + body_w * 0.43, body_top + 20.0), Vector2(cx + body_w * 0.5, h)
    ]), coat)
    _draw_head(cx, head_y, skin, jaw_ratio_for_presentation(str(profile.get("presentation", "androgynous"))))
    _draw_hair(cx, head_y, hair, str(profile.get("hair", "short_dark")))
    var eye_y: float = head_y + 3.0
    draw_line(Vector2(cx - 20.0, eye_y), Vector2(cx - 8.0, eye_y), Color("#20252b"), 3.0)
    draw_line(Vector2(cx + 8.0, eye_y), Vector2(cx + 20.0, eye_y), Color("#20252b"), 3.0)
    draw_line(Vector2(cx - 3.0, head_y + 10.0), Vector2(cx + 2.0, head_y + 22.0), Color("#855f4d"), 2.0)
    _draw_face_details(cx, head_y, str(profile.get("face", "weathered")))
    draw_rect(Rect2(Vector2(cx - 3.0, h - 30.0), Vector2(6.0, 18.0)), Color("#c4a66a"), true)


func _draw_head(cx: float, head_y: float, skin: Color, jaw_ratio: float) -> void:
    var points := PackedVector2Array()
    for i in range(33):
        var angle: float = -PI * 0.5 + TAU * float(i) / 32.0
        var unit_y: float = sin(angle)
        var taper: float = 1.0
        if unit_y > 0.1:
            taper = lerpf(1.0, jaw_ratio, clampf((unit_y - 0.1) / 0.9, 0.0, 1.0))
        points.append(Vector2(cx + cos(angle) * 49.0 * taper, head_y + unit_y * 55.0))
    draw_colored_polygon(points, skin)


func _draw_face_details(cx: float, head_y: float, style: String) -> void:
    var ink := Color("#855f4d")
    if style == "soft":
        draw_line(Vector2(cx - 34.0, head_y + 17.0), Vector2(cx - 25.0, head_y + 21.0), Color("#c18e72"), 2.0)
        draw_line(Vector2(cx + 25.0, head_y + 21.0), Vector2(cx + 34.0, head_y + 17.0), Color("#c18e72"), 2.0)
        draw_line(Vector2(cx - 7.0, head_y + 31.0), Vector2(cx + 7.0, head_y + 31.0), ink, 1.5)
    elif style == "scarred":
        draw_line(Vector2(cx + 25.0, head_y - 12.0), Vector2(cx + 10.0, head_y + 20.0), Color("#8e514c"), 3.0)
        draw_line(Vector2(cx + 20.0, head_y + 2.0), Vector2(cx + 28.0, head_y + 5.0), Color("#8e514c"), 1.5)
    elif style == "sharp":
        draw_line(Vector2(cx - 22.0, head_y - 5.0), Vector2(cx - 7.0, head_y - 1.0), Color("#493a35"), 2.5)
        draw_line(Vector2(cx + 7.0, head_y - 1.0), Vector2(cx + 22.0, head_y - 5.0), Color("#493a35"), 2.5)
        draw_line(Vector2(cx - 31.0, head_y + 24.0), Vector2(cx - 17.0, head_y + 29.0), ink, 1.5)
        draw_line(Vector2(cx + 17.0, head_y + 29.0), Vector2(cx + 31.0, head_y + 24.0), ink, 1.5)
    else:
        draw_line(Vector2(cx - 15.0, head_y - 25.0), Vector2(cx - 5.0, head_y - 23.0), ink, 1.5)
        draw_line(Vector2(cx + 5.0, head_y - 23.0), Vector2(cx + 15.0, head_y - 25.0), ink, 1.5)
        draw_line(Vector2(cx - 31.0, head_y + 11.0), Vector2(cx - 25.0, head_y + 13.0), ink, 1.5)
        draw_line(Vector2(cx + 25.0, head_y + 13.0), Vector2(cx + 31.0, head_y + 11.0), ink, 1.5)


func _draw_hair(cx: float, head_y: float, color: Color, style: String) -> void:
    draw_arc(Vector2(cx, head_y - 2.0), 56.0, PI, TAU, 36, color, 15.0)
    if style == "long_dark" or style == "tied_brown":
        draw_rect(Rect2(Vector2(cx - 53.0, head_y - 4.0), Vector2(12.0, 86.0)), color, true)
        draw_rect(Rect2(Vector2(cx + 41.0, head_y - 4.0), Vector2(12.0, 86.0)), color, true)
    elif style == "shaved":
        draw_arc(Vector2(cx, head_y), 54.0, PI, TAU, 36, color.darkened(0.12), 5.0)
    elif style == "cropped_red":
        draw_rect(Rect2(Vector2(cx - 39.0, head_y - 49.0), Vector2(78.0, 13.0)), color, true)
    else:
        draw_rect(Rect2(Vector2(cx - 45.0, head_y - 47.0), Vector2(90.0, 16.0)), color, true)


func _skin_color(id: String) -> Color:
    if id == "fair":
        return Color("#e6c6a7")
    if id == "olive":
        return Color("#b98a65")
    if id == "deep":
        return Color("#81543e")
    return Color("#d2a17c")


func _hair_color(id: String) -> Color:
    if id == "tied_brown":
        return Color("#65422f")
    if id == "cropped_red":
        return Color("#9b493b")
    if id == "shaved":
        return Color("#393b3c")
    return Color("#282b35")


func _coat_color(id: String) -> Color:
    if id == "border_ward":
        return Color("#536d63")
    if id == "court_exile":
        return Color("#66556f")
    return Color("#785044")
