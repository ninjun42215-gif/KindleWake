extends RefCounted
## Pure responsive layout math for the Chapter I escape traversal UI.

const PLAY_AREA_TOP := 168.0
const PLAY_AREA_BOTTOM := 128.0


static func playable_rect_for_size(viewport_size: Vector2) -> Rect2:
    var top: float = minf(PLAY_AREA_TOP, viewport_size.y * 0.35)
    var bottom_inset: float = minf(PLAY_AREA_BOTTOM, viewport_size.y * 0.28)
    var bottom: float = maxf(top + 1.0, viewport_size.y - bottom_inset)
    var side: float = minf(16.0, viewport_size.x * 0.05)
    return Rect2(Vector2(side, top), Vector2(maxf(1.0, viewport_size.x - side * 2.0), maxf(1.0, bottom - top)))


static func gate_position_for_size(viewport_size: Vector2) -> Vector2:
    var playable: Rect2 = playable_rect_for_size(viewport_size)
    var min_y: float = playable.position.y + minf(48.0, playable.size.y * 0.35)
    var max_y: float = playable.end.y - minf(48.0, playable.size.y * 0.35)
    return Vector2(
        clampf(viewport_size.x * 0.84, playable.position.x + 1.0, playable.end.x - 1.0),
        clampf(viewport_size.y * 0.30, min_y, max_y)
    )
