class_name BattleController
extends RefCounted
## Authoritative battle state and rules. No rendering and no input handling here:
## the UI calls try_move / try_attack / try_skill / end_active_turn and listens to the signals.
## Fully deterministic for a given RNG seed, so battles can be simulated headless and saved/restored.

signal log_message(text: String)
signal state_changed()
signal unit_acted(unit_id: int, kind: String, data: Dictionary)
signal battle_ended(outcome: String)

var def: Dictionary = {}
var db: Dictionary = {}
var map: BattleMap = null
var units: Array[BattleUnit] = []
var rng := RandomNumberGenerator.new()
var weapons: Dictionary = {}
var skills: Dictionary = {}
var active_id: int = -1
var turn_count: int = 0
var next_unit_id: int = 1
var result: String = ""              # "" while running, then "victory" or "defeat"
var _skip_guard: int = 0


# ---------------------------------------------------------------- setup / persistence

func setup(battle_def: Dictionary, database: Dictionary, seed_value: int = 0) -> void:
    _init_static(battle_def, database)
    if seed_value != 0:
        rng.seed = seed_value
    else:
        rng.randomize()
    units.clear()
    next_unit_id = 1
    result = ""
    turn_count = 0
    active_id = -1
    _skip_guard = 0
    var chars: Dictionary = db.get("characters", {})
    var classes: Dictionary = db.get("classes", {})
    var spawns: Array = def.get("units", [])
    for spawn in spawns:
        var s: Dictionary = spawn
        var char_id: String = str(s.get("character_id", ""))
        var char_def: Dictionary = chars.get(char_id, {})
        var class_def: Dictionary = classes.get(str(char_def.get("class_id", "")), {})
        var cell_arr: Array = s.get("cell", [0, 0])
        var u := BattleUnit.create(next_unit_id, char_id, char_def, class_def, str(s.get("team", "enemy")),
            Vector2i(int(cell_arr[0]), int(cell_arr[1])), int(s.get("facing", 0)))
        next_unit_id += 1
        u.is_protagonist = bool(s.get("protagonist", false))
        u.is_commander = bool(s.get("commander", false))
        if s.has("name"):
            u.display_name = str(s["name"])
        u.ctb = TurnQueue.initial_ctb(u)
        units.append(u)


func _init_static(battle_def: Dictionary, database: Dictionary) -> void:
    def = battle_def
    db = database
    weapons = db.get("weapons", {})
    skills = db.get("skills", {})
    map = BattleMap.from_battle_def(def, db.get("terrain", {}))


func begin() -> void:
    log_message.emit("Battle begins: " + str(def.get("title", "")))
    _start_next_turn()


func to_dict() -> Dictionary:
    var arr: Array = []
    for o in units:
        var u: BattleUnit = o
        arr.append(u.to_dict())
    # 64-bit RNG values are stored as strings: JSON numbers are doubles and would lose precision.
    return {
        "battle_id": str(def.get("id", "")),
        "units": arr,
        "active_id": active_id,
        "turn_count": turn_count,
        "next_unit_id": next_unit_id,
        "result": result,
        "rng_seed": str(rng.seed),
        "rng_state": str(rng.state),
    }


func restore(battle_def: Dictionary, database: Dictionary, saved: Dictionary) -> bool:
    if not saved.has("units") or str(saved.get("battle_id", "")) != str(battle_def.get("id", "")):
        return false
    _init_static(battle_def, database)
    units.clear()
    var arr: Array = saved["units"]
    for d in arr:
        var ud: Dictionary = d
        units.append(BattleUnit.from_dict(ud))
    active_id = int(saved.get("active_id", -1))
    turn_count = int(saved.get("turn_count", 0))
    next_unit_id = int(saved.get("next_unit_id", units.size() + 1))
    result = str(saved.get("result", ""))
    rng.seed = str(saved.get("rng_seed", "1")).to_int()
    rng.state = str(saved.get("rng_state", "1")).to_int()
    _skip_guard = 0
    log_message.emit("Battle restored.")
    state_changed.emit()
    return true


# ---------------------------------------------------------------- queries

func active_unit() -> BattleUnit:
    return unit_by_id(active_id)


func unit_by_id(uid: int) -> BattleUnit:
    for o in units:
        var u: BattleUnit = o
        if u.id == uid:
            return u
    return null


func unit_at(cell: Vector2i) -> BattleUnit:
    for o in units:
        var u: BattleUnit = o
        if u.is_alive() and u.cell == cell:
            return u
    return null


func weapon_of(unit: BattleUnit) -> Dictionary:
    return weapons.get(unit.weapon_id, {})


func count_alive(team: String) -> int:
    var n := 0
    for o in units:
        var u: BattleUnit = o
        if u.team == team and u.is_alive():
            n += 1
    return n


func enemy_cell_map(unit: BattleUnit) -> Dictionary:
    var cells: Dictionary = {}
    for o in units:
        var other: BattleUnit = o
        if other.is_alive() and other.team != unit.team:
            cells[other.cell] = true
    return cells


func reach_for(unit: BattleUnit) -> Dictionary:
    var ally_cells: Dictionary = {}
    for o in units:
        var other: BattleUnit = o
        if other.is_alive() and other.team == unit.team and other.id != unit.id:
            ally_cells[other.cell] = true
    return map.compute_reach(unit.cell, unit.move, unit.jump, enemy_cell_map(unit), ally_cells)


func can_act(unit: BattleUnit) -> bool:
    return result == "" and unit != null and unit.id == active_id and unit.is_alive() and unit.morale > 0


func move_targets(unit: BattleUnit) -> Array[Vector2i]:
    var out: Array[Vector2i] = []
    if not can_act(unit) or unit.has_moved or unit.has_acted:
        return out
    var reach: Dictionary = reach_for(unit)
    var cost: Dictionary = reach["cost"]
    for k in cost.keys():
        var c: Vector2i = k
        if c != unit.cell and unit_at(c) == null:
            out.append(c)
    return out


func attack_targets(unit: BattleUnit, from_cell: Vector2i) -> Array[BattleUnit]:
    var out: Array[BattleUnit] = []
    var w: Dictionary = weapon_of(unit)
    var rmin: int = int(w.get("range_min", 1))
    var rmax: int = int(w.get("range_max", 1))
    var ranged: bool = bool(w.get("ranged", false))
    for o in units:
        var t: BattleUnit = o
        if not t.is_alive() or t.team == unit.team:
            continue
        var dist: int = BattleMap.manhattan(from_cell, t.cell)
        var eff_max: int = rmax
        if ranged and map.height_at(from_cell) - map.height_at(t.cell) >= 2:
            eff_max += 1                      # high ground extends bow range
        if dist < rmin or dist > eff_max:
            continue
        if ranged and not map.has_line_of_sight(from_cell, t.cell):
            continue
        out.append(t)
    return out


func skill_targets(unit: BattleUnit, skill_id: String) -> Array[BattleUnit]:
    var out: Array[BattleUnit] = []
    var sk: Dictionary = skills.get(skill_id, {})
    if sk.is_empty() or not unit.skills.has(skill_id) or unit.mp < int(sk.get("mp", 0)):
        return out
    var rmin: int = int(sk.get("range_min", 1))
    var rmax: int = int(sk.get("range_max", 1))
    var hostile: bool = str(sk.get("target", "ally")) == "enemy"
    for o in units:
        var t: BattleUnit = o
        if not t.is_alive():
            continue
        if hostile:
            if t.team == unit.team:
                continue
        elif t.team != unit.team or t.hp >= t.max_hp():
            continue
        var dist: int = BattleMap.manhattan(unit.cell, t.cell)
        if dist >= rmin and dist <= rmax:
            out.append(t)
    return out


func preview_attack(attacker: BattleUnit, target: BattleUnit) -> Dictionary:
    return CombatCalc.preview(attacker, target, weapon_of(attacker), map, units)


# ---------------------------------------------------------------- actions

func try_move(unit: BattleUnit, dest: Vector2i) -> bool:
    if not can_act(unit) or unit.has_moved or unit.has_acted:
        return false
    if dest == unit.cell or unit_at(dest) != null:
        return false
    var reach: Dictionary = reach_for(unit)
    var cost: Dictionary = reach["cost"]
    if not cost.has(dest):
        return false
    var path: Array[Vector2i] = map.path_from(reach, unit.cell, dest)
    if path.is_empty():
        return false
    var from: Vector2i = unit.cell
    var last_prev: Vector2i = from
    if path.size() >= 2:
        last_prev = path[path.size() - 2]
    unit.cell = dest
    unit.has_moved = true
    unit.facing = BattleMap.facing_from_delta(dest - last_prev)
    log_message.emit("%s moves to (%d,%d)." % [unit.display_name, dest.x, dest.y])
    unit_acted.emit(unit.id, "move", {"from": from, "to": dest})
    state_changed.emit()
    return true


func try_attack(unit: BattleUnit, target: BattleUnit) -> bool:
    if not can_act(unit) or unit.has_acted or target == null:
        return false
    if not attack_targets(unit, unit.cell).has(target):
        return false
    unit.facing = BattleMap.facing_from_delta(target.cell - unit.cell)
    var res: Dictionary = CombatCalc.resolve(unit, target, weapon_of(unit), map, units, rng)
    unit.has_acted = true
    var msg: String
    if bool(res["hit"]):
        msg = "%s hits %s for %d%s." % [unit.display_name, target.display_name, int(res["damage"]), " (CRITICAL)" if bool(res["crit"]) else ""]
    else:
        msg = "%s misses %s." % [unit.display_name, target.display_name]
    log_message.emit(msg)
    unit_acted.emit(unit.id, "attack", {"target_id": target.id, "result": res})
    _check_boss_phases(target)
    if bool(res["killed"]):
        log_message.emit("%s is defeated!" % target.display_name)
        unit.kills += 1
        unit.kill_exp += CombatCalc.kill_exp(target)
        _apply_kill_morale(unit, target)
    _check_end()
    state_changed.emit()
    return true


func try_skill(unit: BattleUnit, skill_id: String, target: BattleUnit) -> bool:
    if not can_act(unit) or unit.has_acted or target == null:
        return false
    if not skill_targets(unit, skill_id).has(target):
        return false
    var sk: Dictionary = skills.get(skill_id, {})
    if CombatCalc.is_damage_skill(sk):
        return _cast_damage(unit, skill_id, sk, target)
    if str(sk.get("type", "")) != "heal":
        return false
    var amount: int = CombatCalc.heal_amount(unit, sk, skill_id)
    var before: int = target.hp
    target.hp = mini(target.max_hp(), target.hp + amount)
    unit.mp -= int(sk.get("mp", 0))
    unit.has_acted = true
    unit.facing = BattleMap.facing_from_delta(target.cell - unit.cell) if target.cell != unit.cell else unit.facing
    var healed: int = target.hp - before
    log_message.emit("%s casts %s on %s (+%d HP)." % [unit.display_name, str(sk.get("name", skill_id)), target.display_name, healed])
    var heal_effect: Dictionary = sk.get("rune_effect", {})
    if not heal_effect.is_empty() and rng.randi_range(1, 100) <= int(heal_effect.get("chance", 100)):
        target.statuses[str(heal_effect.get("status", "regen"))] = {"turns": int(heal_effect.get("turns", 2)), "heal": int(heal_effect.get("heal", 2))}
    unit_acted.emit(unit.id, "heal", {"target_id": target.id, "amount": healed, "status": str(heal_effect.get("status", ""))})
    state_changed.emit()
    return true


func _cast_damage(unit: BattleUnit, skill_id: String, sk: Dictionary, target: BattleUnit) -> bool:
    var res: Dictionary = CombatCalc.skill_resolve(unit, target, sk, skill_id, rng, weapon_of(unit))
    var rune_effect: Dictionary = sk.get("rune_effect", {})
    var applied_status := ""
    if not rune_effect.is_empty() and rng.randi_range(1, 100) <= int(rune_effect.get("chance", 0)):
        applied_status = str(rune_effect.get("status", ""))
        if applied_status != "":
            var status_data: Dictionary = {"turns": int(rune_effect.get("turns", 1))}
            if rune_effect.has("damage"):
                status_data["damage"] = int(rune_effect["damage"])
            if rune_effect.has("heal"):
                status_data["heal"] = int(rune_effect["heal"])
            target.statuses[applied_status] = status_data
    var drain_pct: int = int(rune_effect.get("drain_pct", 0))
    if drain_pct > 0:
        var drained: int = mini(unit.max_hp() - unit.hp, int(floor(float(res["damage"]) * float(drain_pct) / 100.0)))
        unit.hp += drained
        if drained > 0:
            log_message.emit("%s drains %d vitality." % [unit.display_name, drained])
    unit.mp -= int(sk.get("mp", 0))
    unit.has_acted = true
    unit.facing = BattleMap.facing_from_delta(target.cell - unit.cell)
    log_message.emit("%s uses %s on %s for %d." % [unit.display_name, str(sk.get("name", skill_id)), target.display_name, int(res["damage"])])
    unit_acted.emit(unit.id, "skill_damage", {"target_id": target.id, "damage": int(res["damage"]), "killed": bool(res["killed"]), "status": applied_status})
    _check_boss_phases(target)
    if bool(res["killed"]):
        log_message.emit("%s is defeated!" % target.display_name)
        unit.kills += 1
        unit.kill_exp += CombatCalc.kill_exp(target)
        _apply_kill_morale(unit, target)
    _check_end()
    state_changed.emit()
    return true


func end_active_turn() -> void:
    var u: BattleUnit = active_unit()
    if u == null or result != "":
        return
    u.ctb = TurnQueue.delay_after_turn(u, u.has_moved, u.has_acted, weapon_of(u))
    _start_next_turn()


## Runs the AI for the active unit. `force` lets the AI also play the player's side (Auto Battle, tests, simulations).
func run_ai_turn(force: bool = false) -> void:
    var u: BattleUnit = active_unit()
    if u == null or result != "" or (u.team == "player" and not force):
        return
    var plan: Dictionary = BattleAI.decide(u, self)
    var dest: Vector2i = plan["move_to"]
    if dest != u.cell:
        try_move(u, dest)
    var action: String = str(plan["action"])
    if action == "attack" and plan["target"] != null:
        var t: BattleUnit = plan["target"]
        try_attack(u, t)
    elif action == "skill" and plan["target"] != null:
        var st: BattleUnit = plan["target"]
        try_skill(u, str(plan.get("skill_id", "")), st)
    end_active_turn()


# ---------------------------------------------------------------- internals

func _start_next_turn() -> void:
    if result != "":
        return
    var nxt: BattleUnit = TurnQueue.peek_next(units)
    if nxt == null:
        return
    TurnQueue.advance_to(units, nxt)
    active_id = nxt.id
    nxt.has_moved = false
    nxt.has_acted = false
    turn_count += 1
    if _tick_rune_statuses(nxt):
        return
    if nxt.morale <= 0 and _skip_guard < 64:
        _skip_guard += 1
        log_message.emit("%s is routed and cannot act." % nxt.display_name)
        nxt.ctb = TurnQueue.ACTION_BASE / nxt.effective_spd()
        _start_next_turn()
        return
    _skip_guard = 0
    state_changed.emit()


func _tick_rune_statuses(unit: BattleUnit) -> bool:
    var skip_turn := false
    var keys: Array = unit.statuses.keys()
    for key in keys:
        var status: String = str(key)
        var data: Dictionary = unit.statuses.get(status, {})
        if status == "burn":
            var damage: int = int(data.get("damage", 2))
            unit.hp = maxi(0, unit.hp - damage)
            log_message.emit("%s takes %d burn damage." % [unit.display_name, damage])
        elif status == "regen":
            var healing: int = mini(unit.max_hp() - unit.hp, int(data.get("heal", 2)))
            unit.hp += healing
            if healing > 0:
                log_message.emit("%s recovers %d HP." % [unit.display_name, healing])
        elif status == "shock":
            skip_turn = true
        var turns: int = int(data.get("turns", 1)) - 1
        if turns <= 0:
            unit.statuses.erase(status)
        else:
            data["turns"] = turns
            unit.statuses[status] = data
    if not unit.is_alive():
        log_message.emit("%s falls from rune affliction." % unit.display_name)
        _check_end()
        return true
    if skip_turn:
        log_message.emit("%s is stunned by the Storm Rune and loses the turn." % unit.display_name)
        unit.ctb = TurnQueue.ACTION_BASE / unit.effective_spd()
        _start_next_turn()
        return true
    return false

## Health-threshold boss transitions. Markers are serialized with BattleUnit.statuses.
func _check_boss_phases(target: BattleUnit) -> void:
    if target == null or not target.is_alive() or not target.is_commander:
        return
    var phases: Array = def.get("boss_phases", [])
    for i in range(phases.size()):
        var phase: Dictionary = phases[i]
        if str(phase.get("character_id", "")) != target.character_id:
            continue
        var marker := "_boss_phase_%d" % i
        if bool(target.statuses.get(marker, false)):
            continue
        var threshold := clampi(int(phase.get("threshold_percent", 0)), 1, 99)
        var hp_percent := int(floor(float(target.hp) * 100.0 / float(target.max_hp())))
        if hp_percent > threshold:
            continue
        target.statuses[marker] = true
        var bonuses: Dictionary = phase.get("stat_bonuses", {})
        for stat_key in bonuses.keys():
            var key := str(stat_key)
            target.stats[key] = target.stat(key) + int(bonuses[stat_key])
        for skill_id in phase.get("add_skills", []):
            var skill := str(skill_id)
            if skills.has(skill) and not target.skills.has(skill):
                target.skills.append(skill)
        var heal_percent := clampi(int(phase.get("heal_percent", 0)), 0, 50)
        if heal_percent > 0:
            target.hp = mini(target.max_hp(), target.hp + maxi(1, int(ceil(float(target.max_hp()) * float(heal_percent) / 100.0))))
        target.morale = clampi(target.morale + int(phase.get("morale_restore", 0)), 0, 100)
        log_message.emit(str(phase.get("message", "%s changes tactics!" % target.display_name)))
        unit_acted.emit(target.id, "boss_phase", {"phase": i + 1, "character_id": target.character_id, "threshold_percent": threshold})

func _apply_kill_morale(killer: BattleUnit, victim: BattleUnit) -> void:
    for o in units:
        var u: BattleUnit = o
        if not u.is_alive():
            continue
        var before: int = u.morale
        if u.team == victim.team:
            u.morale = clampi(u.morale - (35 if victim.is_commander else 10), 0, 100)
        elif u.team == killer.team:
            u.morale = clampi(u.morale + 5, 0, 100)
        if before > 0 and u.morale <= 0:
            log_message.emit("%s's courage breaks!" % u.display_name)


func _check_end() -> void:
    if result != "":
        return
    var enemies := 0
    var players := 0
    var protagonist_down := false
    var commander_down := false
    for o in units:
        var u: BattleUnit = o
        if u.team == "enemy" and u.is_alive():
            enemies += 1
        if u.team == "player" and u.is_alive():
            players += 1
        if u.team == "player" and u.is_protagonist and not u.is_alive():
            protagonist_down = true
        if u.team == "enemy" and u.is_commander and not u.is_alive():
            commander_down = true
    var rules: Array = def.get("victory", ["rout_all"])
    if enemies == 0 or (commander_down and rules.has("defeat_commander")):
        result = "victory"
        log_message.emit("VICTORY! The road to Eldrimar is open.")
    elif players == 0 or protagonist_down:
        result = "defeat"
        log_message.emit("DEFEAT. The Dunmarrow company has fallen.")
    if result != "":
        battle_ended.emit(result)
