class_name BattleAI
extends RefCounted
## Scoring AI. It is team-agnostic, so the test-suite can also run full AI-vs-AI battles.
## `ctl` is a BattleController (left untyped to avoid a script dependency cycle).


## Returns {"move_to": Vector2i, "action": "attack" | "skill" | "wait", "target": BattleUnit or null,
## "skill_id": String (only for "skill")}.
## Also used for Auto Battle on the player's side, so it respects a turn that is already part-played:
## after moving the unit may still act from where it stands, after acting it does nothing.
static func decide(unit: BattleUnit, ctl) -> Dictionary:
    var plan: Dictionary = {"move_to": unit.cell, "action": "wait", "target": null}
    if unit.morale <= 0 or unit.has_acted:
        return plan
    var reach: Dictionary = ctl.reach_for(unit)
    var cost: Dictionary = reach["cost"]
    var origin: Vector2i = unit.cell
    var candidates: Array[Vector2i] = [origin]
    if not unit.has_moved:
        for k in cost.keys():
            var c: Vector2i = k
            if c != origin and ctl.unit_at(c) == null:
                candidates.append(c)
    var heal: Dictionary = _best_heal(unit, ctl, candidates)
    if not heal.is_empty():
        plan["move_to"] = heal["cell"]
        plan["action"] = "skill"
        plan["skill_id"] = heal["skill_id"]
        plan["target"] = heal["target"]
        return plan
    var best_score := -1.0e9
    var best_cell: Vector2i = origin
    var best_target: BattleUnit = null
    for cand in candidates:
        var cell: Vector2i = cand
        unit.cell = cell                       # temporary: previews depend on the attacker's cell
        var targets: Array[BattleUnit] = ctl.attack_targets(unit, cell)
        for t in targets:
            var s: float = _score_attack(unit, t, cell, ctl)
            if s > best_score:
                best_score = s
                best_cell = cell
                best_target = t
    unit.cell = origin
    var bolt: Dictionary = _best_bolt(unit, ctl, candidates)
    if not bolt.is_empty() and (best_target == null or float(bolt["score"]) > best_score):
        plan["move_to"] = bolt["cell"]
        plan["action"] = "skill"
        plan["skill_id"] = bolt["skill_id"]
        plan["target"] = bolt["target"]
        return plan
    if best_target != null:
        plan["move_to"] = best_cell
        plan["action"] = "attack"
        plan["target"] = best_target
        return plan
    if not unit.has_moved:
        plan["move_to"] = _approach_cell(unit, ctl, reach)
    return plan


## Support behaviour: a unit with a heal skill tops up a badly hurt ally (at or below 50% HP) before fighting.
## Returns {"cell", "skill_id", "target"} or an empty dictionary when nobody needs healing.
static func _best_heal(unit: BattleUnit, ctl, candidates: Array[Vector2i]) -> Dictionary:
    var origin: Vector2i = unit.cell
    var best: Dictionary = {}
    var best_score := -1.0e9
    for sid in unit.skills:
        var skill_id: String = str(sid)
        var sk: Dictionary = ctl.skills.get(skill_id, {})
        if str(sk.get("type", "")) != "heal":
            continue
        for cand in candidates:
            var cell: Vector2i = cand
            unit.cell = cell                   # temporary: skill range depends on the caster's cell
            var targets: Array[BattleUnit] = ctl.skill_targets(unit, skill_id)
            for t in targets:
                var ratio: float = float(t.hp) / float(t.max_hp())
                if ratio > 0.5:
                    continue
                var score: float = (1.0 - ratio) * 100.0
                score += float(ctl.map.cover_at(cell)) * 0.15
                score -= 1.5 * _threat_at(unit, cell, ctl)
                score -= 0.5 * float(BattleMap.manhattan(origin, cell))
                if score > best_score:
                    best_score = score
                    best = {"cell": cell, "skill_id": skill_id, "target": t}
    unit.cell = origin
    return best


## Offensive magic: the best (cell, damage skill, enemy) by the same scoring scale as a weapon attack.
## Returns {"cell", "skill_id", "target", "score"} or an empty dictionary when no damage skill can be cast.
static func _best_bolt(unit: BattleUnit, ctl, candidates: Array[Vector2i]) -> Dictionary:
    var origin: Vector2i = unit.cell
    var best: Dictionary = {}
    var best_score := -1.0e9
    for sid in unit.skills:
        var skill_id: String = str(sid)
        var sk: Dictionary = ctl.skills.get(skill_id, {})
        if not CombatCalc.is_damage_skill(sk):
            continue
        for cand in candidates:
            var cell: Vector2i = cand
            unit.cell = cell
            var targets: Array[BattleUnit] = ctl.skill_targets(unit, skill_id)
            for t in targets:
                var p: Dictionary = CombatCalc.skill_preview(unit, t, sk, skill_id, ctl.weapon_of(unit))
                var avg: float = (float(p["dmg_min"]) + float(p["dmg_max"])) * 0.5
                var score: float = avg
                if float(p["dmg_max"]) >= float(t.hp):
                    score += 25.0
                if t.is_commander:
                    score += 8.0
                if t.is_protagonist:
                    score += 10.0
                score += 10.0 * (1.0 - float(t.hp) / float(t.max_hp()))
                score += float(ctl.map.cover_at(cell)) * 0.15 + float(ctl.map.height_at(cell)) * 1.5
                score -= 1.5 * _threat_at(unit, cell, ctl)
                score += 0.8 * float(BattleMap.manhattan(cell, t.cell))
                score -= 2.0 * float(int(sk.get("mp", 0))) * 0.25     # slight preference for saving MP
                if score > best_score:
                    best_score = score
                    best = {"cell": cell, "skill_id": skill_id, "target": t, "score": score}
    unit.cell = origin
    return best


static func _score_attack(unit: BattleUnit, target: BattleUnit, cell: Vector2i, ctl) -> float:
    var p: Dictionary = ctl.preview_attack(unit, target)
    var hit: float = float(p["hit"]) / 100.0
    var avg: float = (float(p["dmg_min"]) + float(p["dmg_max"])) * 0.5
    var crit_p: float = float(p["crit"]) / 100.0
    var score: float = hit * avg * (1.0 + crit_p * 0.5)
    if float(p["dmg_max"]) >= float(target.hp) and hit >= 0.6:
        score += 25.0
    if target.is_commander:
        score += 8.0
    if target.is_protagonist:
        score += 10.0
    score += 10.0 * (1.0 - float(target.hp) / float(target.max_hp()))
    if str(p["facing"]) == "rear":
        score += 4.0
    if bool(p["flank"]):
        score += 3.0
    score += float(ctl.map.cover_at(cell)) * 0.15
    score += float(ctl.map.height_at(cell)) * 1.5
    score -= 1.5 * _threat_at(unit, cell, ctl)
    var w: Dictionary = ctl.weapon_of(unit)
    if bool(w.get("ranged", false)):
        score += 0.8 * float(BattleMap.manhattan(cell, target.cell))
    return score


## Rough danger of a cell: opposing units that could reach and hit it next turn, weighted by offence.
static func _threat_at(unit: BattleUnit, cell: Vector2i, ctl) -> float:
    var threat := 0.0
    for o in ctl.units:
        var other: BattleUnit = o
        if not other.is_alive() or other.team == unit.team:
            continue
        var w: Dictionary = ctl.weapon_of(other)
        var reach_range: int = other.move + int(w.get("range_max", 1))
        if BattleMap.manhattan(cell, other.cell) <= reach_range:
            threat += float(other.stat("str") + other.stat("dex")) * 0.1
    return threat


## No attack possible this turn: walk along the shortest path toward a cell from which the nearest
## opposing unit can be attacked, stopping at the furthest legal cell within movement range.
static func _approach_cell(unit: BattleUnit, ctl, reach: Dictionary) -> Vector2i:
    var origin: Vector2i = unit.cell
    var target: BattleUnit = null
    var best_d := 9999
    for o in ctl.units:
        var other: BattleUnit = o
        if not other.is_alive() or other.team == unit.team:
            continue
        var d: int = BattleMap.manhattan(origin, other.cell)
        if d < best_d:
            best_d = d
            target = other
    if target == null:
        return origin
    var w: Dictionary = ctl.weapon_of(unit)
    var rmin: int = int(w.get("range_min", 1))
    var rmax: int = int(w.get("range_max", 1))
    var ranged: bool = bool(w.get("ranged", false))
    var full: Dictionary = ctl.map.compute_reach(origin, 99, unit.jump, ctl.enemy_cell_map(unit), {})
    var full_cost: Dictionary = full["cost"]
    var goal: Vector2i = origin
    var goal_cost := 100000
    for k in full_cost.keys():
        var c: Vector2i = k
        var dist: int = BattleMap.manhattan(c, target.cell)
        if dist < rmin or dist > rmax:
            continue
        if ranged and not ctl.map.has_line_of_sight(c, target.cell):
            continue
        var occupant: BattleUnit = ctl.unit_at(c)
        if occupant != null and occupant.id != unit.id:
            continue
        var cc: int = full_cost[c]
        if cc < goal_cost:
            goal_cost = cc
            goal = c
    var cost: Dictionary = reach["cost"]
    if goal == origin:
        # Target cannot be reached by any path: just get as close as possible.
        var close: Vector2i = origin
        var close_d: int = BattleMap.manhattan(origin, target.cell)
        for k in cost.keys():
            var c2: Vector2i = k
            var d2: int = BattleMap.manhattan(c2, target.cell)
            if d2 < close_d and ctl.unit_at(c2) == null:
                close_d = d2
                close = c2
        return close
    var path: Array[Vector2i] = ctl.map.path_from(full, origin, goal)
    var dest: Vector2i = origin
    for step in path:
        var s: Vector2i = step
        if not cost.has(s):
            break
        if ctl.unit_at(s) == null:
            dest = s
    return dest
