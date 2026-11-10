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
    if unit.is_commander and unit.character_id == "hask_convoy_champion" and str(ctl.def.get("id", "")) == "act1_hask_boss":
        return _decide_hask(unit, ctl)
    if unit.is_commander and unit.character_id == "ash_bailiff" and str(ctl.def.get("id", "")) == "act1_ash_bailiff_boss":
        return _decide_ash_bailiff(unit, ctl)
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




## Hask is a formation-breaker: he prefers exposed targets and spends his limited MP on a
## Power Strike only when it improves the attack from a legal reachable cell.
static func _decide_hask(unit: BattleUnit, ctl) -> Dictionary:
    var candidates := _candidate_cells(unit, ctl)
    var origin: Vector2i = unit.cell
    var best: Dictionary = {}
    var best_score := -1.0e9
    for candidate in candidates:
        unit.cell = candidate
        var targets: Array[BattleUnit] = ctl.skill_targets(unit, "power_strike")
        for target in targets:
            var preview: Dictionary = CombatCalc.skill_preview(unit, target, ctl.skills.get("power_strike", {}), "power_strike", ctl.weapon_of(unit))
            var average := (float(preview.get("dmg_min", 0)) + float(preview.get("dmg_max", 0))) * 0.5
            var score := average + _isolation_score(target, ctl) * 7.0
            score += 22.0 if float(preview.get("dmg_max", 0)) >= float(target.hp) else 0.0
            score += 9.0 if target.is_protagonist else 0.0
            score += 6.0 if target.is_commander else 0.0
            score += float(ctl.map.cover_at(candidate)) * 0.15
            score -= 1.5 * _threat_at(unit, candidate, ctl)
            score -= 0.6 * float(BattleMap.manhattan(origin, candidate))
            if score > best_score:
                best_score = score
                best = {"move_to": candidate, "action": "skill", "skill_id": "power_strike", "target": target}
        for target in ctl.attack_targets(unit, candidate):
            var score := _score_attack(unit, target, candidate, ctl) + _isolation_score(target, ctl) * 5.0
            score += 8.0 if target.is_protagonist else 0.0
            if score > best_score:
                best_score = score
                best = {"move_to": candidate, "action": "attack", "target": target}
    unit.cell = origin
    if not best.is_empty():
        return best
    return _generic_boss_approach(unit, ctl)


## The Bailiff protects his retainers, heals a badly wounded ally, then judges enemies
## threatening the formation. All choices still pass through BattleController actions.
static func _decide_ash_bailiff(unit: BattleUnit, ctl) -> Dictionary:
    var candidates := _candidate_cells(unit, ctl)
    var origin: Vector2i = unit.cell
    var best_heal: Dictionary = {}
    var heal_score := -1.0e9
    for candidate in candidates:
        unit.cell = candidate
        if unit.skills.has("mend_ii"):
            for ally in ctl.skill_targets(unit, "mend_ii"):
                var ratio := float(ally.hp) / float(ally.max_hp())
                if ratio > 0.72:
                    continue
                var score := (1.0 - ratio) * 95.0
                score += _ally_under_pressure_score(ally, ctl) * 5.0
                score += 8.0 if ally.character_id != "ash_bailiff" else 0.0
                score += float(ctl.map.cover_at(candidate)) * 0.2
                score -= 1.5 * _threat_at(unit, candidate, ctl)
                score -= 0.5 * float(BattleMap.manhattan(origin, candidate))
                if score > heal_score:
                    heal_score = score
                    best_heal = {"move_to": candidate, "action": "skill", "skill_id": "mend_ii", "target": ally}
    unit.cell = origin
    if not best_heal.is_empty() and heal_score >= 28.0:
        return best_heal

    var smite := _best_bolt(unit, ctl, candidates)
    if not smite.is_empty() and str(smite.get("skill_id", "")) == "holy_smite_ii":
        var target: BattleUnit = smite["target"]
        smite["score"] = float(smite["score"]) + _ally_under_pressure_score(target, ctl) * 4.0
        smite["score"] += 10.0 if target.is_protagonist else 0.0
        var attack_plan := _best_weapon_attack(unit, ctl, candidates)
        if attack_plan.is_empty() or float(smite["score"]) >= float(attack_plan.get("score", -1.0e9)):
            return {"move_to": smite["cell"], "action": "skill", "skill_id": "holy_smite_ii", "target": target}
        return {"move_to": attack_plan["cell"], "action": "attack", "target": attack_plan["target"]}
    var fallback := _best_weapon_attack(unit, ctl, candidates)
    if not fallback.is_empty():
        return {"move_to": fallback["cell"], "action": "attack", "target": fallback["target"]}
    return _generic_boss_approach(unit, ctl)


static func _candidate_cells(unit: BattleUnit, ctl) -> Array[Vector2i]:
    var out: Array[Vector2i] = [unit.cell]
    if unit.has_moved:
        return out
    var reach: Dictionary = ctl.reach_for(unit)
    var costs: Dictionary = reach.get("cost", {})
    for key in costs.keys():
        var cell: Vector2i = key
        if cell != unit.cell and ctl.unit_at(cell) == null:
            out.append(cell)
    return out


static func _best_weapon_attack(unit: BattleUnit, ctl, candidates: Array[Vector2i]) -> Dictionary:
    var origin: Vector2i = unit.cell
    var best: Dictionary = {}
    var best_score := -1.0e9
    for candidate in candidates:
        unit.cell = candidate
        for target in ctl.attack_targets(unit, candidate):
            var score := _score_attack(unit, target, candidate, ctl) + _ally_under_pressure_score(target, ctl) * 3.0
            if score > best_score:
                best_score = score
                best = {"cell": candidate, "target": target, "score": score}
    unit.cell = origin
    return best


static func _isolation_score(target: BattleUnit, ctl) -> float:
    var nearby_support := 0
    for other in ctl.units:
        if other.is_alive() and other.team == target.team and other.id != target.id and BattleMap.manhattan(other.cell, target.cell) <= 2:
            nearby_support += 1
    return 3.0 - float(mini(3, nearby_support))


static func _ally_under_pressure_score(target: BattleUnit, ctl) -> float:
    var pressure := 0.0
    for other in ctl.units:
        if not other.is_alive() or other.team == target.team:
            continue
        var distance := BattleMap.manhattan(other.cell, target.cell)
        if distance <= other.move + int(ctl.weapon_of(other).get("range_max", 1)):
            pressure += 1.0
    return pressure


static func _generic_boss_approach(unit: BattleUnit, ctl) -> Dictionary:
    var reach: Dictionary = ctl.reach_for(unit)
    return {"move_to": _approach_cell(unit, ctl, reach), "action": "wait", "target": null}


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
