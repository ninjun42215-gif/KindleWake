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
    draw_rect(Rect2(Vector2.ZERO, size), Color("#101720"), true)
    draw_rect(Rect2(Vector2(2, 2), size - Vector2(4, 4)), Color("#34404b"), false, 2.0)
    # Restrained vignette and a quiet heraldic backdrop; no cartoon outlines or oversized features.
    draw_rect(Rect2(Vector2(8, 8), size - Vector2(16, 16)), Color("#18222d"), true)
    var cx: float = w * 0.5
    var head_y: float = h * 0.29
    var skin: Color = _skin_color(str(profile.get("skin", "warm")))
    var hair: Color = _hair_color(str(profile.get("hair", "short_dark")))
    var coat: Color = _coat_color(str(profile.get("origin", "fallen_heir")))
    var build_id: String = str(profile.get("build", "athletic"))
    var body_w: float = 130.0
    if build_id == "lean":
        body_w = 108.0
    elif build_id == "sturdy":
        body_w = 154.0
    var body_top: float = h * 0.55
    # Neck and layered travelling coat.
    draw_rect(Rect2(Vector2(cx - 19.0, head_y + 42.0), Vector2(38.0, 62.0)), skin, true)
    draw_rect(Rect2(Vector2(cx - 15.0, head_y + 46.0), Vector2(30.0, 54.0)), skin.darkened(0.12), true)
    draw_colored_polygon(PackedVector2Array([
        Vector2(cx - body_w * 0.5, h), Vector2(cx - body_w * 0.43, body_top + 20.0),
        Vector2(cx - 39.0, body_top - 2.0), Vector2(cx + 39.0, body_top - 2.0),
        Vector2(cx + body_w * 0.43, body_top + 20.0), Vector2(cx + body_w * 0.5, h)
    ]), coat.darkened(0.18))
    draw_colored_polygon(PackedVector2Array([
        Vector2(cx - body_w * 0.43, h), Vector2(cx - body_w * 0.34, body_top + 23.0),
        Vector2(cx - 28.0, body_top + 5.0), Vector2(cx + 28.0, body_top + 5.0),
        Vector2(cx + body_w * 0.34, body_top + 23.0), Vector2(cx + body_w * 0.43, h)
    ]), coat)
    # Collar, shoulder seams, leather straps and a restrained metal clasp.
    draw_colored_polygon(PackedVector2Array([Vector2(cx - 30, body_top + 2), Vector2(cx, body_top + 42), Vector2(cx - 12, body_top + 57), Vector2(cx - 45, body_top + 15)]), Color("#b6a17a"))
    draw_colored_polygon(PackedVector2Array([Vector2(cx + 30, body_top + 2), Vector2(cx, body_top + 42), Vector2(cx + 12, body_top + 57), Vector2(cx + 45, body_top + 15)]), Color("#b6a17a"))
    draw_line(Vector2(cx - body_w * 0.34, body_top + 24), Vector2(cx + body_w * 0.30, h - 8), Color("#342d29"), 5.0)
    draw_circle(Vector2(cx + 2.0, body_top + 52.0), 5.0, Color("#c3a66b"))
    draw_circle(Vector2(cx + 2.0, body_top + 52.0), 2.0, Color("#51412e"))
    _draw_head(cx, head_y, skin, jaw_ratio_for_presentation(str(profile.get("presentation", "androgynous"))))
    _draw_hair(cx, head_y, hair, str(profile.get("hair", "short_dark")))
    # Eyes sit beneath brows; smaller iris and subtle catchlight keep the face grounded.
    var eye_y: float = head_y + 2.0
    for side in [-1.0, 1.0]:
        var ex: float = cx + side * 17.0
        draw_line(Vector2(ex - 8.0, eye_y - 5.0), Vector2(ex + 7.0, eye_y - 6.0), hair.darkened(0.22), 3.0)
        draw_line(Vector2(ex - 6.0, eye_y + 2.0), Vector2(ex + 6.0, eye_y + 2.0), Color("#493b35"), 2.0)
        draw_circle(Vector2(ex, eye_y + 2.0), 2.2, Color("#272a2b"))
        draw_circle(Vector2(ex + 0.8, eye_y + 1.2), 0.7, Color("#d6c4a5"))
    draw_line(Vector2(cx, head_y + 5.0), Vector2(cx - 3.0, head_y + 25.0), skin.darkened(0.25), 2.0)
    draw_line(Vector2(cx - 5.0, head_y + 28.0), Vector2(cx + 4.0, head_y + 29.0), skin.darkened(0.3), 1.5)
    draw_line(Vector2(cx - 7.0, head_y + 39.0), Vector2(cx + 7.0, head_y + 39.0), Color("#704c43"), 1.8)
    draw_line(Vector2(cx - 5.0, head_y + 43.0), Vector2(cx + 5.0, head_y + 43.0), skin.lightened(0.12), 1.2)
    _draw_face_details(cx, head_y, str(profile.get("face", "weathered")))
    # Ear shadows and cheek planes.
    draw_arc(Vector2(cx - 46.0, head_y + 14.0), 8.0, -PI * 0.5, PI * 0.5, 12, skin.darkened(0.22), 2.0)
    draw_arc(Vector2(cx + 46.0, head_y + 14.0), 8.0, PI * 0.5, PI * 1.5, 12, skin.darkened(0.22), 2.0)


func _draw_head(cx: float, head_y: float, skin: Color, jaw_ratio: float) -> void:
    var points := PackedVector2Array()
    for i in range(49):
        var angle: float = -PI * 0.5 + TAU * float(i) / 48.0
        var unit_y: float = sin(angle)
        var taper: float = 1.0
        if unit_y > 0.0:
            taper = lerpf(1.0, jaw_ratio, clampf(unit_y / 0.95, 0.0, 1.0))
        points.append(Vector2(cx + cos(angle) * 43.0 * taper, head_y + unit_y * 57.0))
    draw_colored_polygon(points, skin.darkened(0.13))
    draw_colored_polygon(PackedVector2Array([
        Vector2(cx - 39.0, head_y - 4.0), Vector2(cx - 30.0, head_y - 38.0),
        Vector2(cx + 25.0, head_y - 40.0), Vector2(cx + 39.0, head_y - 5.0),
        Vector2(cx + 28.0, head_y + 36.0), Vector2(cx, head_y + 55.0),
        Vector2(cx - 27.0, head_y + 35.0)
    ]), skin)
    draw_line(Vector2(cx - 32.0, head_y + 17.0), Vector2(cx - 24.0, head_y + 31.0), skin.lightened(0.12), 1.2)
    draw_line(Vector2(cx + 32.0, head_y + 17.0), Vector2(cx + 24.0, head_y + 31.0), skin.darkened(0.08), 1.2)


func _draw_face_details(cx: float, head_y: float, style: String) -> void:
    var ink := Color("#76564a")
    if style == "soft":
        draw_line(Vector2(cx - 28.0, head_y + 18.0), Vector2(cx - 21.0, head_y + 21.0), Color("#b98068"), 1.2)
        draw_line(Vector2(cx + 21.0, head_y + 21.0), Vector2(cx + 28.0, head_y + 18.0), Color("#b98068"), 1.2)
    elif style == "scarred":
        draw_line(Vector2(cx + 29.0, head_y - 17.0), Vector2(cx + 12.0, head_y + 24.0), Color("#78463f"), 2.2)
        draw_line(Vector2(cx + 18.0, head_y + 1.0), Vector2(cx + 27.0, head_y + 5.0), Color("#a66d5c"), 1.0)
    elif style == "sharp":
        draw_line(Vector2(cx - 24.0, head_y - 7.0), Vector2(cx - 8.0, head_y - 3.0), Color("#403633"), 2.4)
        draw_line(Vector2(cx + 8.0, head_y - 3.0), Vector2(cx + 24.0, head_y - 7.0), Color("#403633"), 2.4)
        draw_line(Vector2(cx - 28.0, head_y + 27.0), Vector2(cx - 18.0, head_y + 30.0), ink, 1.0)
        draw_line(Vector2(cx + 18.0, head_y + 30.0), Vector2(cx + 28.0, head_y + 27.0), ink, 1.0)
    else:
        # Weathering: brow creases and restrained age lines, not exaggerated caricature marks.
        draw_line(Vector2(cx - 14.0, head_y - 24.0), Vector2(cx - 6.0, head_y - 22.0), ink, 1.2)
        draw_line(Vector2(cx + 6.0, head_y - 22.0), Vector2(cx + 14.0, head_y - 24.0), ink, 1.2)
        draw_line(Vector2(cx - 31.0, head_y + 12.0), Vector2(cx - 26.0, head_y + 14.0), ink, 1.0)
        draw_line(Vector2(cx + 26.0, head_y + 14.0), Vector2(cx + 31.0, head_y + 12.0), ink, 1.0)


func _draw_hair(cx: float, head_y: float, color: Color, style: String) -> void:
    draw_arc(Vector2(cx, head_y - 4.0), 48.0, PI, TAU, 40, color.darkened(0.16), 16.0)
    draw_arc(Vector2(cx, head_y - 5.0), 46.0, PI, TAU, 40, color, 9.0)
    if style == "long_dark" or style == "tied_brown":
        draw_colored_polygon(PackedVector2Array([Vector2(cx - 45, head_y - 8), Vector2(cx - 42, head_y + 55), Vector2(cx - 34, head_y + 73), Vector2(cx - 32, head_y - 8)]), color.darkened(0.08))
        draw_colored_polygon(PackedVector2Array([Vector2(cx + 45, head_y - 8), Vector2(cx + 42, head_y + 55), Vector2(cx + 34, head_y + 73), Vector2(cx + 32, head_y - 8)]), color.darkened(0.08))
    elif style == "shaved":
        draw_arc(Vector2(cx, head_y - 2.0), 44.0, PI, TAU, 36, color.darkened(0.08), 4.0)
    elif style == "cropped_red":
        draw_colored_polygon(PackedVector2Array([Vector2(cx - 43, head_y - 5), Vector2(cx - 32, head_y - 47), Vector2(cx + 29, head_y - 49), Vector2(cx + 44, head_y - 7)]), color)
    else:
        draw_colored_polygon(PackedVector2Array([Vector2(cx - 44, head_y - 7), Vector2(cx - 30, head_y - 48), Vector2(cx + 24, head_y - 50), Vector2(cx + 43, head_y - 6)]), color)
    draw_line(Vector2(cx - 24.0, head_y - 37.0), Vector2(cx - 7.0, head_y - 43.0), color.lightened(0.12), 1.5)
    draw_line(Vector2(cx + 5.0, head_y - 43.0), Vector2(cx + 24.0, head_y - 36.0), color.darkened(0.15), 1.5)


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
