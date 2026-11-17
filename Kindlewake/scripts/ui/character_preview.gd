class_name CharacterPreview
extends Control
## Protagonist portrait preview. Uses the selected authored portrait asset and a
## real character-atlas fallback; it never draws a geometric placeholder bust.

var profile: Dictionary = {}
var portrait_texture: Texture2D = null
var fallback_texture: Texture2D = null


static func jaw_ratio_for_presentation(presentation_id: String) -> float:
    if presentation_id == "masculine":
        return 0.84
    if presentation_id == "feminine":
        return 0.72
    return 0.78


func set_profile(value: Dictionary, registry: Dictionary = {}) -> void:
    profile = value.duplicate(true)
    var portrait_id := str(profile.get("portrait_id", ""))
    portrait_texture = Art.portrait_texture("torren", portrait_id, registry)
    fallback_texture = Art.character_portrait_texture("chronicle_hero")
    queue_redraw()


func _draw() -> void:
    if size.x < 20.0 or size.y < 20.0:
        return
    var frame := Rect2(Vector2.ZERO, size)
    draw_rect(frame, Color("#101720"), true)
    draw_rect(Rect2(Vector2(2, 2), size - Vector2(4, 4)), Color("#34404b"), false, 2.0)
    var target := Rect2(Vector2(8, 8), size - Vector2(16, 16))
    draw_rect(target, Color("#18222d"), true)
    var texture: Texture2D = portrait_texture if portrait_texture != null else fallback_texture
    if texture == null:
        # No invented portrait is drawn when both authored sources are absent.
        draw_rect(target, Color("#34404b"), false, 2.0)
        return
    var texture_size := texture.get_size()
    if texture_size.x <= 0.0 or texture_size.y <= 0.0:
        return
    var scale_to_fit := minf(target.size.x / texture_size.x, target.size.y / texture_size.y)
    var fitted := texture_size * scale_to_fit
    var destination := Rect2(target.position + (target.size - fitted) * 0.5, fitted)
    draw_texture_rect(texture, destination, false)
    draw_rect(target, Color("#c3a66b"), false, 2.0)
