class_name BattleMap
extends RefCounted
## Grid, terrain, heights, Dijkstra movement and line of sight for one battle.

## Direction index: 0 = N (0,-1), 1 = E (1,0), 2 = S (0,1), 3 = W (-1,0) in grid space.
const DIRS := [Vector2i(0, -1), Vector2i(1, 0), Vector2i(0, 1), Vector2i(-1, 0)]
const FACING_NAMES := ["N", "E", "S", "W"]

var width: int = 0
var height: int = 0
var terrain_defs: Dictionary = {}
var terrain_ids: Dictionary = {}     # Vector2i -> String
var heights: Dictionary = {}         # Vector2i -> int


static func from_battle_def(def: Dictionary, p_terrain_defs: Dictionary) -> BattleMap:
    var m := BattleMap.new()
    m.terrain_defs = p_terrain_defs
    var rows: Array = def.get("terrain", [])
    var hrows: Array = def.get("heights", [])
    var legend: Dictionary = def.get("legend", {})
    m.height = rows.size()
    for y in range(rows.size()):
        var row: String = str(rows[y])
        m.width = maxi(m.width, row.length())
        for x in range(row.length()):
            var ch: String = row.substr(x, 1)
            m.terrain_ids[Vector2i(x, y)] = str(legend.get(ch, "grass"))
            var h := 0
            if y < hrows.size():
                var hrow: String = str(hrows[y])
                if x < hrow.length():
                    h = int(hrow.substr(x, 1))
            m.heights[Vector2i(x, y)] = h
    return m


static func manhattan(a: Vector2i, b: Vector2i) -> int:
    return absi(a.x - b.x) + absi(a.y - b.y)


static func facing_from_delta(delta: Vector2i) -> int:
    if absi(delta.x) >= absi(delta.y):
        return 1 if delta.x > 0 else 3
    return 2 if delta.y > 0 else 0


func in_bounds(c: Vector2i) -> bool:
    return c.x >= 0 and c.y >= 0 and c.x < width and c.y < height


func terrain_id(c: Vector2i) -> String:
    return str(terrain_ids.get(c, "grass"))


func terrain_def(c: Vector2i) -> Dictionary:
    return terrain_defs.get(terrain_id(c), {})


func height_at(c: Vector2i) -> int:
    return int(heights.get(c, 0))


## Cost to enter a cell, or -1 if it cannot be entered.
func move_cost(c: Vector2i) -> int:
    var d: Dictionary = terrain_def(c)
    if bool(d.get("blocks_move", false)):
        return -1
    return int(d.get("cost", 1))


func cover_at(c: Vector2i) -> int:
    return int(terrain_def(c).get("cover", 0))


func blocks_los(c: Vector2i) -> bool:
    return bool(terrain_def(c).get("blocks_los", false))


func all_cells() -> Array[Vector2i]:
    var out: Array[Vector2i] = []
    for y in range(height):
        for x in range(width):
            out.append(Vector2i(x, y))
    return out


## Dijkstra flood fill. enemy_cells block movement; ally_cells may be passed through (callers must
## not let a unit stop there). Returns {"cost": {cell: int}, "prev": {cell: cell}}.
func compute_reach(start: Vector2i, move_points: int, jump: int, enemy_cells: Dictionary, _ally_cells: Dictionary) -> Dictionary:
    var cost: Dictionary = {start: 0}
    var prev: Dictionary = {}
    var open: Array[Vector2i] = [start]
    while not open.is_empty():
        var best_i := 0
        for i in range(1, open.size()):
            if int(cost[open[i]]) < int(cost[open[best_i]]):
                best_i = i
        var cur: Vector2i = open[best_i]
        open.remove_at(best_i)
        var cur_cost: int = cost[cur]
        for d in DIRS:
            var n: Vector2i = cur + d
            if not in_bounds(n):
                continue
            if enemy_cells.has(n) or (block_ally_cells and ally_cells.has(n)):
                continue
            var step: int = move_cost(n)
            if step < 0:
                continue
            if absi(height_at(n) - height_at(cur)) > jump:
                continue
            var new_cost: int = cur_cost + step
            if new_cost > move_points:
                continue
            if not cost.has(n) or new_cost < int(cost[n]):
                cost[n] = new_cost
                prev[n] = cur
                if not open.has(n):
                    open.append(n)
    return {"cost": cost, "prev": prev}


## Cells from start (exclusive) to goal (inclusive); empty if unreachable.
func path_from(reach: Dictionary, start: Vector2i, goal: Vector2i) -> Array[Vector2i]:
    var path: Array[Vector2i] = []
    var prev: Dictionary = reach["prev"]
    if goal == start or not prev.has(goal):
        return path
    var cur: Vector2i = goal
    var guard := 0
    while cur != start and guard < 1000:
        path.push_front(cur)
        cur = prev[cur]
        guard += 1
    return path


## Bresenham line; rock walls (blocks_los) between the two cells stop ranged attacks.
func has_line_of_sight(a: Vector2i, b: Vector2i) -> bool:
    var dx: int = absi(b.x - a.x)
    var dy: int = absi(b.y - a.y)
    var sx: int = 1 if a.x < b.x else -1
    var sy: int = 1 if a.y < b.y else -1
    var err: int = dx - dy
    var x: int = a.x
    var y: int = a.y
    var guard := 0
    while not (x == b.x and y == b.y) and guard < 200:
        var e2: int = 2 * err
        if e2 > -dy:
            err -= dy
            x += sx
        if e2 < dx:
            err += dx
            y += sy
        if not (x == b.x and y == b.y) and blocks_los(Vector2i(x, y)):
            return false
        guard += 1
    return true
