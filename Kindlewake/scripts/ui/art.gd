class_name Art
extends RefCounted
## Loads sprites from res://assets/art with a cache. Returns null when a file is missing, so every caller has a
## primitive-shape fallback and the game still runs without the art.

const WORLD_DIR := "res://assets/art/world/"
const UNIT_DIR := "res://assets/art/units/"
## Frames per animation in the 100x100 horizontal strips of the Tiny RPG Soldier / Orc sheets.
const UNIT_FRAMES := {"idle": 6, "walk": 8, "attack": 6, "hurt": 4, "death": 4}
const UNIT_FRAME_SIZE := 100.0
const UNIT_FOOT_Y := 60.0               # feet row inside a 100x100 frame (Soldier 60, Orc 57)
const UNIT_FPS := {"idle": 7.0, "walk": 12.0, "attack": 14.0, "hurt": 10.0, "death": 8.0}

static var _cache: Dictionary = {}


static func _load(path: String) -> Texture2D:
    if _cache.has(path):
        return _cache[path] as Texture2D
    var tex: Texture2D = null
    if ResourceLoader.exists(path):
        tex = load(path) as Texture2D
    _cache[path] = tex
    return tex


static func world(name: String) -> Texture2D:
    return _load(WORLD_DIR + name + ".png")


static func unit_sheet(kind: String, anim: String) -> Texture2D:
    return _load(UNIT_DIR + kind + "_" + anim + ".png")


## Frame index for an animation at `time` seconds. One-shot animations (attack, hurt, death) clamp on the last frame.
static func unit_frame(anim: String, time: float) -> int:
    var n: int = int(UNIT_FRAMES.get(anim, 1))
    var i: int = int(floor(time * float(UNIT_FPS.get(anim, 8.0))))
    if anim == "attack" or anim == "hurt" or anim == "death":
        return clampi(i, 0, n - 1)
    return posmod(i, n)


static func unit_duration(anim: String) -> float:
    return float(int(UNIT_FRAMES.get(anim, 1))) / float(UNIT_FPS.get(anim, 8.0))


## Draws one unit frame with its feet at `feet`. scale = screen px per sprite px; `flip` mirrors it (sprites face right).
static func draw_unit(canvas: CanvasItem, kind: String, anim: String, time: float, feet: Vector2, scale: float, flip: bool, tint: Color = Color.WHITE) -> bool:
    var tex: Texture2D = unit_sheet(kind, anim)
    if tex == null:
        return false
    var idx: int = unit_frame(anim, time)
    var src := Rect2(float(idx) * UNIT_FRAME_SIZE, 0.0, UNIT_FRAME_SIZE, UNIT_FRAME_SIZE)
    var dest := Rect2(Vector2(-UNIT_FRAME_SIZE * 0.5, -UNIT_FOOT_Y) * scale, Vector2(UNIT_FRAME_SIZE, UNIT_FRAME_SIZE) * scale)
    canvas.draw_set_transform(feet, 0.0, Vector2(-1.0 if flip else 1.0, 1.0))
    canvas.draw_texture_rect_region(tex, dest, src, tint)
    canvas.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
    return true


## Draws a world sprite standing on `foot` (bottom centre), scaled.
static func draw_world(canvas: CanvasItem, name: String, foot: Vector2, scale: float = 1.0, tint: Color = Color.WHITE) -> bool:
    var tex: Texture2D = world(name)
    if tex == null:
        return false
    var size: Vector2 = tex.get_size() * scale
    canvas.draw_texture_rect(tex, Rect2(foot - Vector2(size.x * 0.5, size.y), size), false, tint)
    return true
