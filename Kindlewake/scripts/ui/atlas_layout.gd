extends RefCounted
## Shared normalized viewport geometry for the campaign atlas and its visual overlays.
## Keep this as the single source of truth so decorative layers never drift from the map.

static func map_rect_for_size(view_size: Vector2) -> Rect2:
    var portrait_layout: bool = view_size.y > view_size.x
    return Rect2(
        view_size.x * (0.04 if portrait_layout else 0.025),
        view_size.y * (0.16 if portrait_layout else 0.19),
        view_size.x * (0.92 if portrait_layout else 0.625),
        view_size.y * (0.40 if portrait_layout else 0.75)
    )
