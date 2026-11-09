class_name CharacterSheet
extends RefCounted

const BattleUnitScript = preload("res://scripts/battle/battle_unit.gd")
const CombatCalcScript = preload("res://scripts/battle/combat_calc.gd")
## Persistent character: class, level, EXP, base stats, skills and equipment.
## A BattleUnit is a per-battle snapshot built from `to_battle_def()`; formulas stay in CombatCalcScript.
## `db` arguments are the dictionaries from GameData.as_db(): they need "items", "weapons" and "classes".

const SLOTS: Array[String] = ["weapon", "offhand", "armor", "helm", "accessory1", "accessory2"]
const SIGIL_GROUPS: Array[String] = ["weapon", "armor"]   # only these two items carry sockets (like FF7)
const MAX_LEVEL := 250
const EXP_BASE := 80
const EXP_PER_LEVEL := 20
const EXP_CURVE := 1
const PROMOTION_LEVEL_STEP := 10     # tier 1 -> 2 at level 10, tier 2 -> 3 at level 20 (GDD 4.1)
const HP_GAIN := 2                   # HP gained when the HP growth roll succeeds (every other stat gains 1)

var character_id: String = ""
var display_name: String = ""
var house: String = ""
var class_id: String = ""
var level: int = 1
var xp: int = 0
var base_stats: Dictionary = {}          # stat -> int, before equipment
var skills: Array[String] = []
var equipment: Dictionary = {}           # slot -> item id ("" = empty)
var natural_def: int = 0                 # only for characters without an equipment block (generic enemies)
var natural_res: int = 0
var fallback_weapon_id: String = ""      # same: weapon of characters without an equipment block
var sigils: Dictionary = {"weapon": [], "armor": []}   # group -> Array of sigil instances ({"id","ap"}; {} = empty socket)
var reward: Dictionary = {}              # enemies only: {"exp","ap","gold"} paid when defeated


static func from_def(char_id: String, def: Dictionary) -> CharacterSheet:
    var s := CharacterSheet.new()
    s.character_id = char_id
    s.display_name = str(def.get("name", char_id))
    s.house = str(def.get("house", ""))
    s.class_id = str(def.get("class_id", ""))
    s.level = clampi(int(def.get("level", 1)), 1, MAX_LEVEL)
    s.xp = clampi(int(def.get("xp", 0)), 0, maxi(0, exp_to_next_for(s.level) - 1))
    if s.level >= MAX_LEVEL:
        s.xp = 0
    var st: Dictionary = def.get("stats", {})
    for key in st.keys():
        s.base_stats[str(key)] = int(st[key])
    var sk: Array = def.get("skills", [])
    for x in sk:
        s.skills.append(str(x))
    for slot in SLOTS:
        s.equipment[slot] = ""
    if def.has("equipment"):
        var eq: Dictionary = def["equipment"]
        for slot in SLOTS:
            s.equipment[slot] = str(eq.get(slot, ""))
    else:
        s.natural_def = int(def.get("armor_def", 0))
        s.natural_res = int(def.get("armor_res", 0))
        s.fallback_weapon_id = str(def.get("weapon_id", ""))
    s.reward = (def.get("reward", {}) as Dictionary).duplicate()
    var sg: Dictionary = def.get("sigils", {})
    for group in SIGIL_GROUPS:
        var arr: Array = []
        for entry in (sg.get(group, []) as Array):
            if typeof(entry) == TYPE_DICTIONARY:
                arr.append((entry as Dictionary).duplicate())
            elif str(entry) != "":
                arr.append({"id": str(entry), "ap": 0})
            else:
                arr.append({})
        s.sigils[group] = arr
    return s


# ---------------------------------------------------------------- equipment-derived values

func item_in(slot: String) -> String:
    return str(equipment.get(slot, ""))


func weapon_id(items: Dictionary) -> String:
    var item_id: String = item_in("weapon")
    if item_id != "":
        var it: Dictionary = items.get(item_id, {})
        if it.has("weapon_id"):
            return str(it["weapon_id"])
    return fallback_weapon_id


## {"def": int, "res": int} summed over every equipped item (plus natural armor).
func armor_totals(items: Dictionary) -> Dictionary:
    var d: int = natural_def
    var r: int = natural_res
    for slot in SLOTS:
        var it: Dictionary = items.get(item_in(slot), {})
        d += int(it.get("armor_def", 0))
        r += int(it.get("armor_res", 0))
    return {"def": d, "res": r}


## Base stats plus every equipped item's "bonus" block (HP/MP max included).
func total_stats(items: Dictionary, sdefs: Dictionary = {}) -> Dictionary:
    var t: Dictionary = base_stats.duplicate()
    for slot in SLOTS:
        var it: Dictionary = items.get(item_in(slot), {})
        var bonus: Dictionary = it.get("bonus", {})
        for k in bonus.keys():
            t[str(k)] = int(t.get(str(k), 0)) + int(bonus[k])
    var mods: Dictionary = sigil_mods(items, sdefs)
    for k in mods.keys():
        var key: String = str(k)
        if key == "hp_pct" or key == "mp_pct":
            var stat_key: String = key.substr(0, 2)
            var cur: int = int(t.get(stat_key, 0))
            t[stat_key] = cur + int(round(float(cur) * float(mods[k]) / 100.0))
        elif key != "exp_pct" and key != "gold_pct":
            t[key] = int(t.get(key, 0)) + int(mods[k])
    for k in t.keys():
        t[k] = maxi(1 if str(k) == "hp" else 0, int(t[k]))
    return t


## The dictionary BattleUnitScript.create() consumes (same shape as an entry of characters.json).
func to_battle_def(db: Dictionary) -> Dictionary:
    var items: Dictionary = db.get("items", {})
    var sdefs: Dictionary = db.get("sigils", {})
    var arm: Dictionary = armor_totals(items)
    return {
        "name": display_name, "class_id": class_id, "level": level, "house": house,
        "weapon_id": weapon_id(items), "armor_def": int(arm["def"]), "armor_res": int(arm["res"]),
        "skills": all_skills(items, sdefs, db.get("classes", {})), "stats": total_stats(items, sdefs),
        "skill_mods": skill_mods(items, sdefs), "reward": reward.duplicate(),
    }


## Numbers for the character sheet screen. Uses CombatCalc so the formulas exist in one place only.
func derived(db: Dictionary) -> Dictionary:
    var classes: Dictionary = db.get("classes", {})
    var weapons: Dictionary = db.get("weapons", {})
    var bdef: Dictionary = to_battle_def(db)
    var cdef: Dictionary = classes.get(class_id, {})
    var u: BattleUnitScript = BattleUnit.create(0, character_id, bdef, cdef, "player", Vector2i.ZERO, 0)
    var w: Dictionary = weapons.get(str(bdef["weapon_id"]), {})
    return {
        "max_hp": u.max_hp(), "max_mp": u.stat("mp"),
        "attack": CombatCalc.attack_power(u, w),
        "defense": CombatCalc.defense(u, "physical"),
        "resistance": CombatCalc.defense(u, "magic"),
        "accuracy": u.stat("acc") + int(w.get("acc", 0)),
        "evasion": u.stat("eva"),
        "crit": CombatCalc.crit_chance(u, w, "front"),
        "spd": u.stat("spd"), "move": u.move, "jump": u.jump,
        "range_min": int(w.get("range_min", 1)), "range_max": int(w.get("range_max", 1)),
    }


## A throw-away copy of this character wearing `item_id` in `slot` (pass "" to take the slot's item off).
## Used by the party screen to preview what a change would do; the original sheet is never touched.
func with_item(slot: String, item_id: String, items: Dictionary) -> CharacterSheet:
    var copy: CharacterSheet = CharacterSheet.from_dict(to_dict())
    copy.equipment[slot] = item_id
    copy.fit_sockets(items)
    return copy


## "" when `item_id` may go into `slot`; otherwise a short reason for the UI.
func equip_problem(slot: String, item_id: String, items: Dictionary) -> String:
    if not SLOTS.has(slot):
        return "Unknown slot."
    var it: Dictionary = items.get(item_id, {})
    if it.is_empty():
        return "Unknown item."
    var item_slot: String = str(it.get("slot", ""))
    var fits: bool = item_slot == slot or (item_slot == "accessory" and (slot == "accessory1" or slot == "accessory2"))
    if not fits:
        return "That item does not fit this slot."
    var bound: String = str(it.get("bound_to", ""))
    if bound != "" and bound != character_id:
        return "This heirloom belongs to someone else."
    if slot == "weapon" and bool(it.get("two_handed", false)) and item_in("offhand") != "":
        return "A two-handed weapon needs a free off-hand."
    if slot == "offhand":
        var wep: Dictionary = items.get(item_in("weapon"), {})
        if bool(wep.get("two_handed", false)):
            return "The two-handed weapon blocks the off-hand."
    return ""


# ---------------------------------------------------------------- experience and levels

static func exp_to_next_for(lvl: int) -> int:
    var safe_level: int = clampi(lvl, 1, MAX_LEVEL)
    var curve_level: int = maxi(0, safe_level - 2)
    return EXP_BASE + EXP_PER_LEVEL * safe_level + EXP_CURVE * curve_level * curve_level


func exp_to_next() -> int:
    return exp_to_next_for(level)


## Adds EXP and levels up as often as needed. Returns
## {"exp_gained": int, "levels": [{"level": int, "gains": {stat: int}}]}. At MAX_LEVEL EXP is ignored.
func add_exp(amount: int, rng: RandomNumberGenerator, class_def: Dictionary) -> Dictionary:
    var report: Dictionary = {"exp_gained": maxi(0, amount), "levels": []}
    if level >= MAX_LEVEL:
        xp = 0
        return report
    if amount <= 0:
        return report
    xp += amount
    var levels: Array = report["levels"]
    while level < MAX_LEVEL and xp >= exp_to_next():
        xp -= exp_to_next()
        level += 1
        var gains: Dictionary = _roll_growth(class_def, rng)
        for k in gains.keys():
            base_stats[k] = int(base_stats.get(k, 0)) + int(gains[k])
        levels.append({"level": level, "gains": gains})
    if level >= MAX_LEVEL:
        xp = 0
    return report


## One probability roll per stat in the class's growth table (percent). A level never gives nothing:
## if every roll fails, the class's strongest growth stat gains one point.
func _roll_growth(class_def: Dictionary, rng: RandomNumberGenerator) -> Dictionary:
    var growth: Dictionary = class_def.get("growth", {})
    var keys: Array = growth.keys()
    keys.sort()
    var gains: Dictionary = {}
    var best_key := ""
    var best_chance := -1
    for k in keys:
        var key: String = str(k)
        var chance: int = int(growth[k])
        if chance > best_chance:
            best_chance = chance
            best_key = key
        if rng.randi_range(1, 100) <= chance:
            gains[key] = HP_GAIN if key == "hp" else 1
    if gains.is_empty() and best_key != "":
        gains[best_key] = HP_GAIN if best_key == "hp" else 1
    return gains


# ---------------------------------------------------------------- promotion

## Classes this character may promote into right now: level gate (10 x current tier), the class must exist in data,
## and it must not be `locked` (locked classes need a requirement the game cannot check yet: status effects, bonds, relics).
func promotion_options(classes: Dictionary) -> Array[String]:
    var out: Array[String] = []
    var cur: Dictionary = classes.get(class_id, {})
    var tier: int = int(cur.get("tier", 1))
    if level < PROMOTION_LEVEL_STEP * tier:
        return out
    var targets: Array = cur.get("promotes_to", [])
    for t in targets:
        var tdef: Dictionary = classes.get(str(t), {})
        if tdef.is_empty() or bool(tdef.get("locked", false)):
            continue
        out.append(str(t))
    return out


func promote(new_class_id: String, classes: Dictionary) -> bool:
    if not promotion_options(classes).has(new_class_id):
        return false
    class_id = new_class_id
    return true


# ---------------------------------------------------------------- persistence

func to_dict() -> Dictionary:
    return {
        "character_id": character_id, "name": display_name, "house": house, "class_id": class_id,
        "level": level, "xp": xp, "base_stats": base_stats.duplicate(), "skills": skills.duplicate(),
        "equipment": equipment.duplicate(), "natural_def": natural_def, "natural_res": natural_res,
        "fallback_weapon_id": fallback_weapon_id, "sigils": sigils.duplicate(true), "reward": reward.duplicate(),
    }


static func from_dict(d: Dictionary) -> CharacterSheet:
    var s := CharacterSheet.new()
    s.character_id = str(d.get("character_id", ""))
    s.display_name = str(d.get("name", s.character_id))
    s.house = str(d.get("house", ""))
    s.class_id = str(d.get("class_id", ""))
    s.level = clampi(int(d.get("level", 1)), 1, MAX_LEVEL)
    s.xp = clampi(int(d.get("xp", 0)), 0, maxi(0, exp_to_next_for(s.level) - 1))
    if s.level >= MAX_LEVEL:
        s.xp = 0
    var bs: Dictionary = d.get("base_stats", {})
    for key in bs.keys():
        s.base_stats[str(key)] = int(bs[key])
    var sk: Array = d.get("skills", [])
    for x in sk:
        s.skills.append(str(x))
    for slot in SLOTS:
        s.equipment[slot] = ""
    var eq: Dictionary = d.get("equipment", {})
    for slot in SLOTS:
        s.equipment[slot] = str(eq.get(slot, ""))
    s.natural_def = int(d.get("natural_def", 0))
    s.natural_res = int(d.get("natural_res", 0))
    s.fallback_weapon_id = str(d.get("fallback_weapon_id", ""))
    s.reward = (d.get("reward", {}) as Dictionary).duplicate()
    var sg: Dictionary = d.get("sigils", {})
    for group in SIGIL_GROUPS:
        var arr: Array = []
        for entry in (sg.get(group, []) as Array):
            if typeof(entry) == TYPE_DICTIONARY:
                arr.append((entry as Dictionary).duplicate(true))
            elif str(entry) != "":
                arr.append({"id": str(entry), "ap": 0})
            else:
                arr.append({})
        s.sigils[group] = arr
    return s


# ---------------------------------------------------------------- sigils (the FF7 "Materia" system)
# Sockets live on the equipped weapon and armor ("sockets": N, "links": [[0,1]], "ap_mult": X in items.json).
# A sigil instance is {"id": String, "ap": int}. Level = 1 + number of AP thresholds reached.
# Magic sigils grant skills (cumulative over levels); stat/independent sigils apply the current level's "mods";
# support sigils act on the sigils linked to them (linked sockets share a pair in "links").

static func sigil_max_level(sdef: Dictionary) -> int:
    return (sdef.get("ap", []) as Array).size() + 1


static func sigil_level(inst: Dictionary, sdef: Dictionary) -> int:
    var lv := 1
    for th in (sdef.get("ap", []) as Array):
        if int(inst.get("ap", 0)) >= int(th):
            lv += 1
    return lv


static func sigil_is_mastered(inst: Dictionary, sdef: Dictionary) -> bool:
    return not sdef.is_empty() and sigil_level(inst, sdef) >= sigil_max_level(sdef)


## AP still needed for the next level; 0 when mastered.
static func sigil_ap_to_next(inst: Dictionary, sdef: Dictionary) -> int:
    var th: Array = sdef.get("ap", [])
    var lv: int = sigil_level(inst, sdef)
    if lv > th.size():
        return 0
    return int(th[lv - 1]) - int(inst.get("ap", 0))


static func sigil_level_data(sdef: Dictionary, lv: int) -> Dictionary:
    var levels: Array = sdef.get("levels", [])
    if lv < 1 or lv > levels.size():
        return {}
    return levels[lv - 1]


static func sigil_skills_at(sdef: Dictionary, lv: int) -> Array[String]:
    var out: Array[String] = []
    for i in range(1, mini(lv, (sdef.get("levels", []) as Array).size()) + 1):
        for sid in (sigil_level_data(sdef, i).get("skills", []) as Array):
            if not out.has(str(sid)):
                out.append(str(sid))
    return out


func socket_count(group: String, items: Dictionary) -> int:
    var it: Dictionary = items.get(item_in(group), {})
    return int(it.get("sockets", 0))


func socket_ap_mult(group: String, items: Dictionary) -> int:
    var it: Dictionary = items.get(item_in(group), {})
    return maxi(1, int(it.get("ap_mult", 1)))


## Indices linked to `index` on this item (links are pairs such as [0, 1]).
func linked_indices(group: String, index: int, items: Dictionary) -> Array[int]:
    var out: Array[int] = []
    var it: Dictionary = items.get(item_in(group), {})
    for pair in (it.get("links", []) as Array):
        var pr: Array = pair
        if int(pr[0]) == index:
            out.append(int(pr[1]))
        elif int(pr[1]) == index:
            out.append(int(pr[0]))
    return out


func sigil_at(group: String, index: int) -> Dictionary:
    var arr: Array = sigils.get(group, [])
    if index < 0 or index >= arr.size():
        return {}
    return arr[index]


## Makes the socket arrays match the equipped items. Sigils in sockets that no longer exist are returned
## (the caller puts them back in the inventory); arrays grow with empty sockets.
func fit_sockets(items: Dictionary) -> Array:
    var removed: Array = []
    for group in SIGIL_GROUPS:
        var arr: Array = sigils.get(group, [])
        var n: int = socket_count(group, items)
        while arr.size() > n:
            var last: Dictionary = arr.pop_back()
            if not last.is_empty():
                removed.append(last)
        while arr.size() < n:
            arr.append({})
        sigils[group] = arr
    return removed


## Every sigil that sits in a real socket: [{"group", "index", "inst"}].
func active_sigils(items: Dictionary) -> Array:
    var out: Array = []
    for group in SIGIL_GROUPS:
        var arr: Array = sigils.get(group, [])
        var n: int = mini(arr.size(), socket_count(group, items))
        for i in range(n):
            var inst: Dictionary = arr[i]
            if not inst.is_empty():
                out.append({"group": group, "index": i, "inst": inst})
    return out


## Sum of one support effect (e.g. "ap_pct") from the support sigils linked to a socket.
func linked_support(group: String, index: int, items: Dictionary, sdefs: Dictionary, key: String) -> int:
    var total := 0
    for j in linked_indices(group, index, items):
        var other: Dictionary = sigil_at(group, j)
        if other.is_empty():
            continue
        var od: Dictionary = sdefs.get(str(other.get("id", "")), {})
        if str(od.get("kind", "")) != "support":
            continue
        var ld: Dictionary = sigil_level_data(od, sigil_level(other, od))
        total += int((ld.get("support", {}) as Dictionary).get(key, 0))
    return total


## Skills from the class (`class_skills`: skill id -> level needed), the character's innate skills and the
## sigils (magic kind), without duplicates. `classes` is optional: without it no class skills are granted.
func all_skills(items: Dictionary, sdefs: Dictionary, classes: Dictionary = {}) -> Array[String]:
    var out: Array[String] = []
    var cs: Dictionary = (classes.get(class_id, {}) as Dictionary).get("class_skills", {})
    for k in cs.keys():
        if level >= int(cs[k]) and not out.has(str(k)):
            out.append(str(k))
    for s in skills:
        if not out.has(s):
            out.append(s)
    for e in active_sigils(items):
        var inst: Dictionary = e["inst"]
        var sd: Dictionary = sdefs.get(str(inst.get("id", "")), {})
        if str(sd.get("kind", "")) != "magic":
            continue
        for sid in sigil_skills_at(sd, sigil_level(inst, sd)):
            if not out.has(sid):
                out.append(sid)
    return out


## skill id -> power bonus percent from support sigils ("skill_power_pct") linked to the magic sigil that grants it.
func skill_mods(items: Dictionary, sdefs: Dictionary) -> Dictionary:
    var out: Dictionary = {}
    for e in active_sigils(items):
        var inst: Dictionary = e["inst"]
        var sd: Dictionary = sdefs.get(str(inst.get("id", "")), {})
        if str(sd.get("kind", "")) != "magic":
            continue
        var pct: int = linked_support(str(e["group"]), int(e["index"]), items, sdefs, "skill_power_pct")
        if pct == 0:
            continue
        for sid in sigil_skills_at(sd, sigil_level(inst, sd)):
            out[sid] = int(out.get(sid, 0)) + pct
    return out


## Summed "mods" of every stat/independent sigil at its current level (hp_pct, mp_pct, flat stats, exp_pct, gold_pct).
func sigil_mods(items: Dictionary, sdefs: Dictionary) -> Dictionary:
    var out: Dictionary = {}
    for e in active_sigils(items):
        var inst: Dictionary = e["inst"]
        var sd: Dictionary = sdefs.get(str(inst.get("id", "")), {})
        var kind: String = str(sd.get("kind", ""))
        if kind != "stat" and kind != "independent":
            continue
        var mods: Dictionary = sigil_level_data(sd, sigil_level(inst, sd)).get("mods", {})
        for k in mods.keys():
            out[str(k)] = int(out.get(str(k), 0)) + int(mods[k])
    return out


## Percent bonus to EXP ("exp_pct") or gold ("gold_pct") from this character's sigils.
func reward_pct(key: String, items: Dictionary, sdefs: Dictionary) -> int:
    return int(sigil_mods(items, sdefs).get(key, 0))


## Gives every equipped sigil AP (weapon/armor AP multiplier and linked Tutor support apply).
## Mastered sigils stop at their cap. Returns one report per sigil that gained AP:
## {"id","name","gained","before","after","mastered","new_skills","spawn"}; "spawn" is true exactly once per sigil,
## when it first becomes mastered (the caller adds a fresh level-1 copy to the inventory).
func award_ap(amount: int, items: Dictionary, sdefs: Dictionary) -> Array:
    var out: Array = []
    if amount <= 0:
        return out
    for e in active_sigils(items):
        var inst: Dictionary = e["inst"]
        var sd: Dictionary = sdefs.get(str(inst.get("id", "")), {})
        if sd.is_empty():
            continue
        var max_lv: int = sigil_max_level(sd)
        var before: int = sigil_level(inst, sd)
        if before >= max_lv:
            continue
        var group: String = str(e["group"])
        var pct: int = 100 + linked_support(group, int(e["index"]), items, sdefs, "ap_pct")
        var gain: int = int(ceil(float(amount) * float(socket_ap_mult(group, items)) * float(pct) / 100.0))
        var th: Array = sd.get("ap", [])
        var cap: int = int(th[th.size() - 1])
        var old_ap: int = int(inst.get("ap", 0))
        inst["ap"] = mini(cap, old_ap + gain)
        var after: int = sigil_level(inst, sd)
        var new_skills: Array[String] = []
        if after > before:
            for sid in sigil_skills_at(sd, after):
                if not sigil_skills_at(sd, before).has(sid):
                    new_skills.append(sid)
        var rep: Dictionary = {"id": str(inst.get("id", "")), "name": str(sd.get("name", "")), "gained": int(inst["ap"]) - old_ap,
            "before": before, "after": after, "mastered": after >= max_lv, "new_skills": new_skills, "spawn": false}
        if after >= max_lv and bool(sd.get("spawns_copy", true)) and not bool(inst.get("spawned", false)):
            inst["spawned"] = true
            rep["spawn"] = true
        out.append(rep)
    return out
