class_name Art
extends RefCounted
## Loads sprites from res://assets/art with a cache. Returns null when a file is missing, so every caller has a
## primitive-shape fallback and the game still runs without the art.

const WORLD_DIR := "res://assets/art/world/"
const WORLD_VECTOR_NAMES := ["house_a", "house_b", "house_c", "hut", "keep", "tower_a", "tower_b", "tower_c"]
const UNIT_DIR := "res://assets/art/units/"
const PROP_ATLAS_PATH := "res://assets/art/props/field_props.svg"
const CHARACTER_ATLAS_PATH := "res://assets/art/units/character_atlas.svg"
const CHARACTER_CELLS := {"knight":Vector2i(0,0), "ranger":Vector2i(1,0), "paladin":Vector2i(2,0), "priestess":Vector2i(3,0), "mage":Vector2i(0,1), "rogue":Vector2i(1,1), "guard":Vector2i(2,1), "merchant":Vector2i(3,1), "goblin":Vector2i(0,2), "orc":Vector2i(1,2), "skeleton":Vector2i(2,2), "direwolf":Vector2i(3,2), "wraith":Vector2i(0,3), "cultist":Vector2i(1,3), "treant":Vector2i(2,3), "overlord":Vector2i(3,3)}
const PROP_CELLS := {"arch":Vector2i(0,0), "column":Vector2i(1,0), "rune_stone":Vector2i(2,0), "torch":Vector2i(3,0), "reeds":Vector2i(0,1), "crystals":Vector2i(1,1), "grave":Vector2i(2,1), "banner":Vector2i(3,1), "mushrooms":Vector2i(0,2), "stump":Vector2i(1,2), "barrel":Vector2i(2,2), "crate":Vector2i(3,2), "campfire":Vector2i(0,3), "frost_pine":Vector2i(1,3), "statue":Vector2i(2,3), "flower":Vector2i(3,3)}
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
    if WORLD_VECTOR_NAMES.has(name):
        return _load(WORLD_DIR + name + ".svg")
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


## Draws one of the original fantasy character designs from the 4x4 atlas.
static func draw_character(canvas: CanvasItem, archetype: String, feet: Vector2, scale: float = 0.8, tint: Color = Color.WHITE) -> bool:
    if not CHARACTER_CELLS.has(archetype):
        return false
    var tex: Texture2D = _load(CHARACTER_ATLAS_PATH)
    if tex == null:
        return false
    var cell: Vector2i = CHARACTER_CELLS[archetype]
    var src := Rect2(Vector2(cell.x * 128, cell.y * 160), Vector2(128, 160))
    var size := Vector2(128, 160) * scale
    canvas.draw_texture_rect_region(tex, Rect2(feet - Vector2(size.x * 0.5, size.y), size), src, tint)
    return true


static func character_for_npc(name: String, role: String = "") -> String:
    var key: String = (name + " " + role).to_lower()
    if key.contains("guard") or key.contains("soldier") or key.contains("watch"):
        return "guard"
    if key.contains("merchant") or key.contains("trader") or key.contains("innkeeper") or key.contains("carter"):
        return "merchant"
    if key.contains("priest") or key.contains("brother") or key.contains("sister") or key.contains("healer"):
        return "priestess"
    if key.contains("scout") or key.contains("ranger") or key.contains("bow") or key.contains("hunter"):
        return "ranger"
    if key.contains("mage") or key.contains("witch") or key.contains("seer"):
        return "mage"
    if key.contains("captain") or key.contains("knight") or key.contains("lord"):
        return "knight"
    var common: Array[String] = ["merchant", "guard", "ranger", "rogue", "priestess", "knight", "mage", "paladin"]
    return common[posmod(absi(hash(name)), common.size())]


static func character_for_enemy(character_id: String, display_name: String = "") -> String:
    var key: String = (character_id + " " + display_name).to_lower()
    if key.contains("rootbound") or key.contains("briar") or key.contains("treant"):
        return "treant"
    if key.contains("bell_keeper") or key.contains("wraith") or key.contains("ghost") or key.contains("spect"):
        return "wraith"
    if key.contains("ashen") or key.contains("cult") or key.contains("matriarch"):
        return "cultist"
    if key.contains("skeleton") or key.contains("bone") or key.contains("drowned"):
        return "skeleton"
    if key.contains("wolf") or key.contains("hart") or key.contains("beast"):
        return "direwolf"
    if key.contains("goblin"):
        return "goblin"
    if key.contains("orc") or key.contains("brute") or key.contains("ogre") or key.contains("troll"):
        return "orc"
    if key.contains("star_eater") or key.contains("overlord"):
        return "overlord"
    if key.contains("hask") or key.contains("boss") or key.contains("chieftain"):
        return "paladin"
    if key.contains("bow") or key.contains("archer") or key.contains("scout"):
        return "ranger"
    if key.contains("shaman") or key.contains("witch") or key.contains("mage"):
        return "mage"
    return "rogue"


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
