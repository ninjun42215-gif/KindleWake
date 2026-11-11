class_name Art
extends RefCounted
## Loads sprites from res://assets/art with a cache. Returns null when a file is missing, so every caller has a
## primitive-shape fallback and the game still runs without the art.

const WORLD_DIR := "res://assets/art/world/"
const UNIT_DIR := "res://assets/art/units/"
const PROP_ATLAS_PATH := "res://assets/art/props/field_props.svg"
const PROP_CELLS := {"arch":Vector2i(0,0), "column":Vector2i(1,0), "rune_stone":Vector2i(2,0), "torch":Vector2i(3,0), "reeds":Vector2i(0,1), "crystals":Vector2i(1,1), "grave":Vector2i(2,1), "banner":Vector2i(3,1), "mushrooms":Vector2i(0,2), "stump":Vector2i(1,2), "barrel":Vector2i(2,2), "crate":Vector2i(3,2), "campfire":Vector2i(0,3), "frost_pine":Vector2i(1,3), "statue":Vector2i(2,3), "flower":Vector2i(3,3)}
## Frames per animation in the 100x100 horizontal strips of the Tiny RPG Soldier / Orc sheets.
const UNIT_FRAMES := {"idle": 6, "walk": 8, "attack": 6, "hurt": 4, "death": 4}
const UNIT_FRAME_SIZE := 100.0
const UNIT_FOOT_Y := 60.0               # feet row inside a 100x100 frame (Soldier 60, Orc 57)
const UNIT_FPS := {"idle": 7.0, "walk": 12.0, "attack": 14.0, "hurt": 10.0, "death": 8.0}
## Original project-authored enemy atlases: 6 columns × 7 animation rows, 100px cells.
const ENEMY_ATLAS_DIR := UNIT_DIR + "enemies/"
const ENEMY_ANIM_ROWS := {"idle": 0, "walk": 1, "attack": 2, "hurt": 3, "cast": 4, "victory": 5, "death": 6}
const ENEMY_FRAME_SIZE := 100.0
const ENEMY_FRAME_COUNT := 6
const ENEMY_SCALES := {"rootbound_warden": 2.55, "bell_keeper": 2.3, "ashen_reeve": 2.3, "roadwolf_chieftain": 2.48, "roadwolf_reaver": 2.28, "roadwolf_bowman": 2.2}
const ENEMY_FPS := {"idle": 6.0, "walk": 10.0, "attack": 14.0, "hurt": 12.0, "cast": 10.0, "victory": 7.0, "death": 7.0}

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


## One original 600×700 atlas per named story boss.
static func enemy_sheet(kind: String) -> Texture2D:
    return _load(ENEMY_ATLAS_DIR + kind + ".svg")


## Existing soldier/orc strips do not have dedicated cast or victory rows. Keep their idle art,
## then layer a matching action pose and VFX in the battle renderer instead of requesting missing files.
static func unit_animation_for(kind: String, anim: String) -> String:
    if UNIT_FRAMES.has(anim) and unit_sheet(kind, anim) != null:
        return anim
    return "idle"


## Story-boss mapping is data-key based, not a fragile display-name-only heuristic.
static func enemy_kind_for(character_id: String, display_name: String = "") -> String:
    var key := (character_id + " " + display_name).to_lower()
    if key.contains("rootbound") or key.contains("warden"):
        return "rootbound_warden"
    if key.contains("bell_keeper") or key.contains("bell-keeper") or key.contains("bell keeper"):
        return "bell_keeper"
    if key.contains("ashen_reeve") or key.contains("ashen reeve") or key.contains("ashen"):
        return "ashen_reeve"
    if key.contains("hask_gravelteeth") or key.contains("hask gravelteeth") or key.contains("chieftain"):
        return "roadwolf_chieftain"
    if key.contains("roadbowman") or key.contains("roadwolf bowman") or key.contains("bowman"):
        return "roadwolf_bowman"
    if key.contains("roadreaver") or key.contains("roadwolf reaver"):
        return "roadwolf_reaver"
    return ""


## Frame index for an animation at `time` seconds. One-shot animations (attack, hurt, death) clamp on the last frame.
static func unit_frame(anim: String, time: float) -> int:
    var n: int = int(UNIT_FRAMES.get(anim, 1))
    var i: int = int(floor(time * float(UNIT_FPS.get(anim, 8.0))))
    if anim == "attack" or anim == "hurt" or anim == "death":
        return clampi(i, 0, n - 1)
    return posmod(i, n)


static func unit_duration(anim: String) -> float:
    if anim == "cast":
        return 0.72
    if anim == "victory":
        return 1.05
    return float(int(UNIT_FRAMES.get(anim, 1))) / float(UNIT_FPS.get(anim, 8.0))


static func enemy_frame_index(anim: String, time: float) -> int:
    var i := int(floor(time * float(ENEMY_FPS.get(anim, 8.0))))
    if anim == "idle" or anim == "walk":
        return posmod(i, ENEMY_FRAME_COUNT)
    return clampi(i, 0, ENEMY_FRAME_COUNT - 1)


static func enemy_frame_rect(anim: String, time: float) -> Rect2:
    if not ENEMY_ANIM_ROWS.has(anim):
        return Rect2(Vector2.ZERO, Vector2(ENEMY_FRAME_SIZE, ENEMY_FRAME_SIZE))
    var col := enemy_frame_index(anim, time)
    var row := int(ENEMY_ANIM_ROWS[anim])
    return Rect2(Vector2(float(col) * ENEMY_FRAME_SIZE, float(row) * ENEMY_FRAME_SIZE), Vector2(ENEMY_FRAME_SIZE, ENEMY_FRAME_SIZE))


static func enemy_duration(anim: String) -> float:
    return float(ENEMY_FRAME_COUNT) / float(ENEMY_FPS.get(anim, 8.0))


static func enemy_scale(kind: String) -> float:
    return float(ENEMY_SCALES.get(kind, 2.3))


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


## Draws a frame from an original 7-row boss atlas with the same 100px/60px-foot contract.
static func draw_enemy(canvas: CanvasItem, kind: String, anim: String, time: float, feet: Vector2, scale: float, flip: bool, tint: Color = Color.WHITE) -> bool:
    var tex: Texture2D = enemy_sheet(kind)
    if tex == null:
        return false
    var src := enemy_frame_rect(anim, time)
    var dest := Rect2(Vector2(-ENEMY_FRAME_SIZE * 0.5, -UNIT_FOOT_Y) * scale, Vector2(ENEMY_FRAME_SIZE, ENEMY_FRAME_SIZE) * scale)
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


## Draws one original 128px environmental prop from the 4x4 atlas.
static func draw_prop(canvas: CanvasItem, name: String, center: Vector2, scale: float = 0.5, tint: Color = Color.WHITE) -> bool:
    if not PROP_CELLS.has(name):
        return false
    var tex: Texture2D = _load(PROP_ATLAS_PATH)
    if tex == null:
        return false
    var cell: Vector2i = PROP_CELLS[name]
    var src := Rect2(Vector2(cell) * 128.0, Vector2(128.0, 128.0))
    var size := Vector2(128.0, 128.0) * scale
    canvas.draw_texture_rect_region(tex, Rect2(center - size * 0.5, size), src, tint)
    return true
