class_name LocalMap
extends RefCounted
## A town or a building interior (data/locations.json). Rows of characters, one per tile:
##   .  grass        ,  dirt path     =  wood floor    +  carpet        E  exit to the overworld (towns and dungeons)
##   1-4 door (see "doors")           # stone wall      T  tree          F  fence         ~  pond
##   r  red roof     b  blue roof     w  building front
##   B bed  S shelf  K counter  X table  H hearth  U barrel  P pillar  N banner  C crate
## Pure logic (no nodes); the location scene draws it and tests/run_tests.gd validates every map.

const BLOCKED := "#TF~rbwBSKXHUPNC"
const ALLOWED := ".,=+E1234#TF~rbwBSKXHUPNC"

var id: String = ""
var name: String = ""
var kind: String = "interior"                # "town", "dungeon" or "interior"
var width: int = 0
var height: int = 0
var rows: Array[String] = []
var doors: Dictionary = {}                   # door char -> {"to": map id, "spawn": [x, y]}
var spots: Array = []                        # {"cell": [x, y], "kind": "text"|"party", "name", "text", "npc", "tint"}
var entry: Vector2i = Vector2i.ONE
var zoom: float = 0.0                        # 0 = automatic


static func from_def(map_id: String, def: Dictionary) -> LocalMap:
    var m := LocalMap.new()
    m.id = map_id
    m.name = str(def.get("name", map_id))
    m.kind = str(def.get("kind", "interior"))
    for r in (def.get("rows", []) as Array):
        m.rows.append(str(r))
    m.height = m.rows.size()
    m.width = 0 if m.rows.is_empty() else m.rows[0].length()
    m.doors = (def.get("doors", {}) as Dictionary).duplicate(true)
    m.spots = (def.get("spots", []) as Array).duplicate(true)
    var e: Array = def.get("entry", [1, 1])
    m.entry = Vector2i(int(e[0]), int(e[1]))
    m.zoom = float(def.get("zoom", 0.0))
    return m


static func load_all(cfg: Dictionary) -> Dictionary:
    var out: Dictionary = {}
    var maps: Dictionary = cfg.get("maps", {})
    for k in maps.keys():
        out[str(k)] = LocalMap.from_def(str(k), maps[k])
    return out


func in_bounds(c: Vector2i) -> bool:
    return c.x >= 0 and c.y >= 0 and c.y < height and c.x < width


func tile_at(c: Vector2i) -> String:
    if not in_bounds(c):
        return "#"
    return rows[c.y].substr(c.x, 1)


func walkable(c: Vector2i) -> bool:
    return not BLOCKED.contains(tile_at(c))


func door_at(c: Vector2i) -> Dictionary:
    return doors.get(tile_at(c), {})


func is_exit(c: Vector2i) -> bool:
    return tile_at(c) == "E"


func spot_cell(s: Dictionary) -> Vector2i:
    var a: Array = s.get("cell", [0, 0])
    return Vector2i(int(a[0]), int(a[1]))


func connected(a: Vector2i, b: Vector2i) -> bool:
    if not walkable(a) or not walkable(b):
        return false
    var seen: Dictionary = {a: true}
    var queue: Array[Vector2i] = [a]
    var head: int = 0
    while head < queue.size():
        var c: Vector2i = queue[head]
        head += 1
        if c == b:
            return true
        for d in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
            var n: Vector2i = c + d
            if in_bounds(n) and walkable(n) and not seen.has(n):
                seen[n] = true
                queue.append(n)
    return false


## First walkable tile within one step (8 directions) of `c`, reachable from the entry; (-1, -1) if there is none.
func reachable_neighbour(c: Vector2i) -> Vector2i:
    for dy in range(-1, 2):
        for dx in range(-1, 2):
            var n := Vector2i(c.x + dx, c.y + dy)
            if walkable(n) and connected(entry, n):
                return n
    return Vector2i(-1, -1)


## Every problem found in a set of maps (empty = all fine). Used by the tests.
static func validate(maps: Dictionary) -> Array[String]:
    var errs: Array[String] = []
    for k in maps.keys():
        var m: LocalMap = maps[k]
        if m.height < 4 or m.width < 4:
            errs.append("%s: too small" % m.id)
            continue
        for r in m.rows:
            if r.length() != m.width:
                errs.append("%s: rows differ in length" % m.id)
                break
        var has_exit: bool = false
        for y in range(m.height):
            for x in range(m.width):
                var ch: String = m.rows[y].substr(x, 1)
                if not ALLOWED.contains(ch):
                    errs.append("%s: unknown tile '%s' at %d,%d" % [m.id, ch, x, y])
                if ch == "E":
                    has_exit = true
                    if m.kind != "town" and m.kind != "dungeon":
                        errs.append("%s: only towns and dungeons have an exit" % m.id)
                if ch >= "1" and ch <= "4":
                    var d: Dictionary = m.doors.get(ch, {})
                    if d.is_empty():
                        errs.append("%s: door '%s' is not defined" % [m.id, ch])
                    elif not maps.has(str(d.get("to", ""))):
                        errs.append("%s: door '%s' leads to a missing map" % [m.id, ch])
                    else:
                        var target: LocalMap = maps[str(d["to"])]
                        var sp: Array = d.get("spawn", [-1, -1])
                        if not target.walkable(Vector2i(int(sp[0]), int(sp[1]))):
                            errs.append("%s: door '%s' spawns on a blocked tile" % [m.id, ch])
                    if not m.connected(m.entry, Vector2i(x, y)):
                        errs.append("%s: door '%s' cannot be reached from the entry" % [m.id, ch])
        if (m.kind == "town" or m.kind == "dungeon") and not has_exit:
            errs.append("%s: a town or dungeon needs an exit (E)" % m.id)
        if not m.walkable(m.entry):
            errs.append("%s: the entry is blocked" % m.id)
        for s in m.spots:
            var c: Vector2i = m.spot_cell(s)
            if not m.in_bounds(c) or m.reachable_neighbour(c) == Vector2i(-1, -1):
                errs.append("%s: spot '%s' cannot be reached" % [m.id, str((s as Dictionary).get("name", "?"))])
    return errs
