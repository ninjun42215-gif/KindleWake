class_name WorldMap
extends RefCounted
## The overworld of the Sallow Marches (Milestone 7, first step). Generated from data/world.json with
## deterministic value noise, so the same seed always gives the same land and no big map file is needed.
## Pure logic (no nodes): the world scene draws it and tests/run_tests.gd checks it.

const GRASS := 0
const FOREST := 1
const HILL := 2
const FORD := 3
const WATER := 4
const MOUNTAIN := 5
const ROAD := 6
const BRIDGE := 7

const NAMES: Array[String] = ["Grass", "Forest", "Hill", "Ford", "Deep Water", "Mountain", "Road", "Bridge"]
## Walking speed multiplier and ambush danger per terrain type (0 speed = blocked).
const SPEED: Array[float] = [1.0, 0.6, 0.7, 0.5, 0.0, 0.0, 1.4, 1.2]
const DANGER: Array[float] = [1.0, 1.6, 1.0, 1.2, 0.0, 0.0, 0.3, 0.3]

var width: int = 0
var height: int = 0
var seed_value: int = 0
var tiles: PackedByteArray = PackedByteArray()
var places: Array = []                  # entries of data/world.json "places"
var start_cell: Vector2i = Vector2i.ZERO
var wrap_enabled: bool = true


static func hash01(x: int, y: int, s: int) -> float:
    var h: int = (x * 374761393 + y * 668265263 + s * 1442695041) & 0x7fffffff
    h = ((h ^ (h >> 13)) * 1274126177) & 0x7fffffff
    h = h ^ (h >> 16)
    return float(h & 0xffff) / 65535.0


static func noise(x: int, y: int, scale: float, s: int) -> float:
    var fx: float = float(x) / scale
    var fy: float = float(y) / scale
    var ix: int = floori(fx)
    var iy: int = floori(fy)
    var tx: float = fx - float(ix)
    var ty: float = fy - float(iy)
    tx = tx * tx * (3.0 - 2.0 * tx)
    ty = ty * ty * (3.0 - 2.0 * ty)
    var a: float = lerpf(hash01(ix, iy, s), hash01(ix + 1, iy, s), tx)
    var b: float = lerpf(hash01(ix, iy + 1, s), hash01(ix + 1, iy + 1, s), tx)
    return lerpf(a, b, ty)


static func generate(cfg: Dictionary) -> WorldMap:
    var m := WorldMap.new()
    m.width = maxi(8, int(cfg.get("width", 64)))
    m.height = maxi(8, int(cfg.get("height", 48)))
    m.seed_value = int(cfg.get("seed", 1))
    m.wrap_enabled = bool(cfg.get("wrap_world", true))
    m.places = (cfg.get("places", []) as Array).duplicate(true)
    m.tiles.resize(m.width * m.height)
    for y in range(m.height):
        for x in range(m.width):
            var e: float = noise(x, y, 10.0, m.seed_value) * 0.65 + noise(x, y, 5.0, m.seed_value + 7) * 0.35
            var wet: float = noise(x, y, 9.0, m.seed_value + 31) * 0.7 + noise(x, y, 4.0, m.seed_value + 53) * 0.3
            var t: int = GRASS
            if m.wrap_enabled and (x == 0 or y == 0 or x == m.width - 1 or y == m.height - 1):
                t = GRASS
            elif not m.wrap_enabled and (x == 0 or y == 0 or x == m.width - 1 or y == m.height - 1):
                t = MOUNTAIN
            elif e < 0.30:
                t = WATER
            elif e < 0.34:
                t = FORD
            elif e > 0.80:
                t = MOUNTAIN
            elif e > 0.68:
                t = HILL
            elif wet > 0.58:
                t = FOREST
            m.tiles[y * m.width + x] = t
    # clear a small meadow around every place, then lay the roads
    for p in m.places:
        var c: Vector2i = m.place_cell(str((p as Dictionary).get("id", "")))
        for dy in range(-2, 3):
            for dx in range(-2, 3):
                var cc := Vector2i(c.x + dx, c.y + dy)
                if not m.in_bounds(cc):
                    continue
                if m.terrain_at(cc) != MOUNTAIN or (absi(dx) <= 1 and absi(dy) <= 1):
                    m._set_tile(cc, GRASS)
    for r in (cfg.get("roads", []) as Array):
        var pair: Array = r
        m._carve_road(m.place_cell(str(pair[0])), m.place_cell(str(pair[1])))
    for p in m.places:
        m._set_tile(m.place_cell(str((p as Dictionary).get("id", ""))), ROAD)
    m.start_cell = m.place_cell(str(cfg.get("start", "")))
    return m


func in_bounds(c: Vector2i) -> bool:
    return c.x >= 0 and c.y >= 0 and c.x < width and c.y < height


## Canonical tile coordinate on the continuous, wraparound campaign world.
func wrap_cell(c: Vector2i) -> Vector2i:
    if not wrap_enabled:
        return c
    return Vector2i(posmod(c.x, width), posmod(c.y, height))


func wrap_position(p: Vector2) -> Vector2:
    if not wrap_enabled:
        return p
    return Vector2(fposmod(p.x, float(width * 48)), fposmod(p.y, float(height * 48)))


## Shortest signed displacement from one canonical cell to another across the seam.
func wrapped_delta(from_cell: Vector2i, to_cell: Vector2i) -> Vector2i:
    var d := to_cell - from_cell
    if wrap_enabled:
        if d.x > width / 2: d.x -= width
        elif d.x < -width / 2: d.x += width
        if d.y > height / 2: d.y -= height
        elif d.y < -height / 2: d.y += height
    return d


func terrain_at(c: Vector2i) -> int:
    var sample := wrap_cell(c)
    if not in_bounds(sample):
        return MOUNTAIN
    return int(tiles[sample.y * width + sample.x])


func _set_tile(c: Vector2i, t: int) -> void:
    var sample := wrap_cell(c)
    if in_bounds(sample):
        tiles[sample.y * width + sample.x] = t


func walkable(c: Vector2i) -> bool:
    return SPEED[terrain_at(c)] > 0.0


func speed_at(c: Vector2i) -> float:
    return SPEED[terrain_at(c)]


func danger_at(c: Vector2i) -> float:
    return DANGER[terrain_at(c)]


func terrain_name(c: Vector2i) -> String:
    return NAMES[terrain_at(c)]


func place_cell(id: String) -> Vector2i:
    for p in places:
        var d: Dictionary = p
        if str(d.get("id", "")) == id:
            var a: Array = d.get("cell", [0, 0])
            return Vector2i(int(a[0]), int(a[1]))
    return Vector2i.ZERO


func place_by_id(id: String) -> Dictionary:
    for p in places:
        if str((p as Dictionary).get("id", "")) == id:
            return p
    return {}


## Winding one-tile road from a to b. Water becomes a bridge, other blocked ground becomes road.
func _carve_road(a: Vector2i, b: Vector2i) -> void:
    var c: Vector2i = a
    var target := a + wrapped_delta(a, b)
    var guard: int = width * height
    while c != target and guard > 0:
        guard -= 1
        var dx: int = signi(target.x - c.x)
        var dy: int = signi(target.y - c.y)
        var step_x: bool = absi(target.x - c.x) > absi(target.y - c.y)
        var wobble: float = hash01(c.x, c.y, seed_value + 99)
        if wobble < 0.22 and dx != 0 and dy != 0:
            step_x = not step_x
        if dx == 0:
            step_x = false
        elif dy == 0:
            step_x = true
        c = Vector2i(c.x + dx, c.y) if step_x else Vector2i(c.x, c.y + dy)
        var t: int = terrain_at(c)
        _set_tile(c, BRIDGE if (t == WATER or t == FORD) else ROAD)


## True when b can be reached from a over walkable tiles (4-way). Used by the tests and by place checks.
func connected(a: Vector2i, b: Vector2i) -> bool:
    if not walkable(a) or not walkable(b):
        return false
    var seen: PackedByteArray = PackedByteArray()
    seen.resize(width * height)
    var queue: Array[Vector2i] = [a]
    seen[a.y * width + a.x] = 1
    var head: int = 0
    while head < queue.size():
        var c: Vector2i = queue[head]
        head += 1
        if c == b:
            return true
        for d in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
            var n: Vector2i = c + d
            n = wrap_cell(n)
            if in_bounds(n) and walkable(n) and seen[n.y * width + n.x] == 0:
                seen[n.y * width + n.x] = 1
                queue.append(n)
    return false


func walkable_fraction() -> float:
    var n: int = 0
    for i in range(tiles.size()):
        if SPEED[int(tiles[i])] > 0.0:
            n += 1
    return float(n) / float(maxi(1, tiles.size()))


## Next ambush threshold in "danger pixels" for a given random number 0..1.
static func encounter_threshold(cfg: Dictionary, r: float) -> float:
    var lo: float = float(cfg.get("encounter_min", 900))
    var hi: float = maxf(lo, float(cfg.get("encounter_max", 1800)))
    return lerpf(lo, hi, clampf(r, 0.0, 1.0))
