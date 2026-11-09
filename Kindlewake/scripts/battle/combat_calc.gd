class_name CombatCalc
extends RefCounted

const BattleUnitScript = preload("res://scripts/battle/battle_unit.gd")
const BattleMapScript = preload("res://scripts/battle/battle_map.gd")
## Every combat formula lives here (see GDD section 3.5). Pure functions: easy to unit-test and balance.

const VARIANCE_MIN := 0.95
const VARIANCE_MAX := 1.05


static func attack_power(u: BattleUnitScript, weapon: Dictionary) -> float:
    var power := float(weapon.get("power", 0))
    var str_v := float(u.stat("str"))
    var dex_v := float(u.stat("dex"))
    var int_v := float(u.stat("int"))
    if str(weapon.get("damage_type", "physical")) == "magic":
        return power + 1.2 * int_v
    if bool(weapon.get("uses_dex", false)):
        return power + dex_v + 0.25 * str_v
    return power + str_v + 0.25 * dex_v


static func defense(u: BattleUnit, damage_type: String) -> float:
    if damage_type == "magic":
        return float(u.armor_res) + 0.3 * float(u.stat("int")) + 0.3 * float(u.stat("vit"))
    return float(u.armor_def) + 0.6 * float(u.stat("vit"))


## Smooth, never negative: damage = raw^2 / (raw + defense). Defense equal to raw halves the damage.
static func base_damage(raw: float, def_value: float) -> float:
    if raw <= 0.0:
        return 0.0
    return raw * raw / (raw + maxf(def_value, 0.0))


## "front" / "side" / "rear" depending on where the attacker stands relative to the defender's facing.
static func facing_class(attacker_cell: Vector2i, defender: BattleUnit) -> String:
    var delta := Vector2(attacker_cell - defender.cell)
    if delta == Vector2.ZERO:
        return "front"
    var fd: Vector2i = BattleMapScript.DIRS[defender.facing]
    var dot: float = Vector2(fd).dot(delta.normalized())
    if dot > 0.5:
        return "front"
    if dot < -0.5:
        return "rear"
    return "side"


## Flanked = adjacent melee attack while another unit of the attacker's team stands on the opposite side.
static func is_flanked(attacker: BattleUnit, defender: BattleUnit, units: Array) -> bool:
    if BattleMap.manhattan(attacker.cell, defender.cell) != 1:
        return false
    var opposite: Vector2i = defender.cell + (defender.cell - attacker.cell)
    for o in units:
        var other: BattleUnit = o
        if other.is_alive() and other.team == attacker.team and other.id != attacker.id and other.cell == opposite:
            return true
    return false


static func morale_mult(u: BattleUnit) -> float:
    if u.morale >= 80:
        return 1.05
    if u.morale < 30:
        return 0.85
    return 1.0


static func hit_chance(attacker: BattleUnit, defender: BattleUnit, weapon: Dictionary, map: BattleMapScript) -> int:
    var value: int = attacker.stat("acc") + int(weapon.get("acc", 0)) - defender.stat("eva") - map.cover_at(defender.cell)
    return clampi(value, 10, 98)


static func crit_chance(attacker: BattleUnit, weapon: Dictionary, facing_cls: String) -> int:
    var v: float = 5.0 + 0.5 * float(attacker.stat("lck")) + 0.3 * float(attacker.stat("dex")) + float(weapon.get("crit", 0))
    if facing_cls == "rear":
        v += 10.0
    return clampi(int(round(v)), 0, 60)


## Deterministic preview used by the UI (attack badge) and by the AI.
static func preview(attacker: BattleUnit, defender: BattleUnit, weapon: Dictionary, map: BattleMap, units: Array) -> Dictionary:
    var dtype: String = str(weapon.get("damage_type", "physical"))
    var raw: float = attack_power(attacker, weapon)
    var def_value: float = defense(defender, dtype) * (1.0 - float(weapon.get("armor_pierce", 0.0)))
    var base: float = base_damage(raw, def_value)
    var facing_cls: String = facing_class(attacker.cell, defender)
    var f_mult := 1.0
    if facing_cls == "side":
        f_mult = 1.10
    elif facing_cls == "rear":
        f_mult = 1.25
    var flank: bool = is_flanked(attacker, defender, units)
    var h_diff: int = clampi(map.height_at(attacker.cell) - map.height_at(defender.cell), -3, 3)
    var mult: float = (1.0 + 0.1 * float(h_diff)) * f_mult * (1.15 if flank else 1.0) * morale_mult(attacker)
    var normal: float = base * mult
    var crit_mult: float = float(weapon.get("crit_mult", 1.5))
    return {
        "hit": hit_chance(attacker, defender, weapon, map),
        "crit": crit_chance(attacker, weapon, facing_cls),
        "dmg_min": maxi(1, int(round(normal * VARIANCE_MIN))),
        "dmg_max": maxi(1, int(round(normal * VARIANCE_MAX))),
        "normal": normal,
        "crit_mult": crit_mult,
        "facing": facing_cls,
        "flank": flank,
        "height_diff": h_diff,
    }


## Rolls the attack with the supplied RNG and applies damage to the defender.
static func resolve(attacker: BattleUnit, defender: BattleUnit, weapon: Dictionary, map: BattleMap, units: Array, rng: RandomNumberGenerator) -> Dictionary:
    var p: Dictionary = preview(attacker, defender, weapon, map, units)
    var hit: bool = rng.randi_range(1, 100) <= int(p["hit"])
    var result: Dictionary = {"hit": hit, "crit": false, "damage": 0, "killed": false, "preview": p}
    if not hit:
        return result
    var crit: bool = rng.randi_range(1, 100) <= int(p["crit"])
    var variance: float = rng.randf_range(VARIANCE_MIN, VARIANCE_MAX)
    var dmg_f: float = float(p["normal"]) * variance
    if crit:
        dmg_f *= float(p["crit_mult"])
    var damage: int = maxi(1, int(round(dmg_f)))
    defender.hp = maxi(0, defender.hp - damage)
    result["crit"] = crit
    result["damage"] = damage
    result["killed"] = defender.hp <= 0
    return result


## EXP the killer earns for defeating `victim`: 15 + 5 per level, doubled for a commander.
static func kill_exp(victim: BattleUnit) -> int:
    return (15 + 5 * victim.level) * (2 if victim.is_commander else 1)


## Power of a skill after support sigils (Resonance): +pct percent.
static func skill_power_mult(caster: BattleUnit, skill_id: String) -> float:
    return 1.0 + float(int(caster.skill_mods.get(skill_id, 0))) / 100.0


static func heal_amount(caster: BattleUnit, skill: Dictionary, skill_id: String = "") -> int:
    return int(round(float(int(skill.get("power", 0)) + caster.stat("int")) * skill_power_mult(caster, skill_id)))


## Magic damage range of a "damage" skill: never misses, uses INT and the target's magic defense.
## Returns {"dmg_min", "dmg_max", "normal"}.
## Skills of type "strike" are weapon skills: weapon attack power x `mult`, against physical defense, never miss.
## They need the caster's weapon (pass `weapon`); damage skills (spells) ignore it.
static func is_damage_skill(skill: Dictionary) -> bool:
    var t: String = str(skill.get("type", ""))
    return t == "damage" or t == "strike"


static func skill_preview(caster: BattleUnit, target: BattleUnit, skill: Dictionary, skill_id: String = "", weapon: Dictionary = {}) -> Dictionary:
    var raw: float = 0.0
    var def_value: float = 0.0
    if str(skill.get("type", "")) == "strike":
        raw = attack_power(caster, weapon) * float(skill.get("mult", 1.0)) * skill_power_mult(caster, skill_id)
        def_value = defense(target, "physical")
    else:
        raw = (float(skill.get("power", 0)) + 1.2 * float(caster.stat("int"))) * skill_power_mult(caster, skill_id)
        def_value = defense(target, "magic")
    var normal: float = base_damage(raw, def_value) * morale_mult(caster)
    return {"normal": normal, "dmg_min": maxi(1, int(round(normal * VARIANCE_MIN))), "dmg_max": maxi(1, int(round(normal * VARIANCE_MAX)))}


## Rolls and applies a damage skill. Returns {"damage": int, "killed": bool}.
static func skill_resolve(caster: BattleUnit, target: BattleUnit, skill: Dictionary, skill_id: String, rng: RandomNumberGenerator, weapon: Dictionary = {}) -> Dictionary:
    var p: Dictionary = skill_preview(caster, target, skill, skill_id, weapon)
    var damage: int = maxi(1, int(round(float(p["normal"]) * rng.randf_range(VARIANCE_MIN, VARIANCE_MAX))))
    target.hp = maxi(0, target.hp - damage)
    return {"damage": damage, "killed": target.hp <= 0}


## What an enemy pays when defeated: its own "reward" block, otherwise a level-based default
## (EXP 15 + 5 x level, AP 2 + level, gold 5 + 3 x level; commanders pay double).
static func enemy_reward(victim: BattleUnit) -> Dictionary:
    if not victim.reward.is_empty():
        return {"exp": int(victim.reward.get("exp", 0)), "ap": int(victim.reward.get("ap", 0)), "gold": int(victim.reward.get("gold", 0))}
    var mult: int = 2 if victim.is_commander else 1
    return {"exp": (15 + 5 * victim.level) * mult, "ap": (2 + victim.level) * mult, "gold": (5 + 3 * victim.level) * mult}
