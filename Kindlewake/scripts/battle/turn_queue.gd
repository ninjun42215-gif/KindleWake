class_name TurnQueue
extends RefCounted
## Charge-Time turn order: the lowest `ctb` acts next; faster units come around more often.

const ACTION_BASE := 1000.0


static func initial_ctb(unit: BattleUnit) -> float:
    return ACTION_BASE / unit.effective_spd() * 0.5


## Unit that acts next (ties broken by id), without changing any state.
static func peek_next(units: Array) -> BattleUnit:
    var best: BattleUnit = null
    for o in units:
        var u: BattleUnit = o
        if not u.is_alive():
            continue
        if best == null or u.ctb < best.ctb - 0.0001 or (absf(u.ctb - best.ctb) <= 0.0001 and u.id < best.id):
            best = u
    return best


## Moves time forward so that `next` reaches 0; everyone else loses the same amount.
static func advance_to(units: Array, next: BattleUnit) -> void:
    var dt: float = next.ctb
    for o in units:
        var u: BattleUnit = o
        if u.is_alive():
            u.ctb = maxf(0.0, u.ctb - dt)


## Delay until the unit's next turn: full after acting, 0.75 after only moving, 0.5 after only waiting.
static func delay_after_turn(unit: BattleUnit, moved: bool, acted: bool, weapon: Dictionary) -> float:
    var mult := 0.5
    if acted:
        mult = 1.0 * float(weapon.get("ctb_mult", 1.0))
    elif moved:
        mult = 0.75
    return ACTION_BASE / unit.effective_spd() * mult


## Predicts the next `count` actors (assuming full actions) for the HUD timeline.
static func timeline(units: Array, count: int) -> Array:
    var sim: Dictionary = {}
    var by_id: Dictionary = {}
    for o in units:
        var u: BattleUnit = o
        if u.is_alive():
            sim[u.id] = u.ctb
            by_id[u.id] = u
    var out: Array = []
    if sim.is_empty():
        return out
    for _i in range(count):
        var best_id := -1
        for k in sim.keys():
            var uid: int = k
            if best_id == -1:
                best_id = uid
                continue
            var a: float = sim[uid]
            var b: float = sim[best_id]
            if a < b - 0.0001 or (absf(a - b) <= 0.0001 and uid < best_id):
                best_id = uid
        var dt: float = sim[best_id]
        for k in sim.keys():
            sim[k] = maxf(0.0, float(sim[k]) - dt)
        var bu: BattleUnit = by_id[best_id]
        sim[best_id] = ACTION_BASE / bu.effective_spd()
        out.append(bu)
    return out
