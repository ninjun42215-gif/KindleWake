class_name ItemInfo
extends RefCounted
## Text helpers for the party screen and the tests: one place that decides how stats, items, sigils and skills read.

const STAT_NAMES := {
    "hp": "HP", "mp": "MP", "str": "STR", "dex": "DEX", "int": "INT", "vit": "VIT",
    "spd": "SPD", "lck": "LCK", "acc": "ACC", "eva": "EVA", "ldr": "LDR", "mor": "MOR",
}
const SLOT_NAMES := {
    "weapon": "Weapon", "offhand": "Off-hand", "armor": "Armor", "helm": "Helm",
    "accessory1": "Accessory 1", "accessory2": "Accessory 2",
}
const STAT_ORDER: Array[String] = ["str", "dex", "int", "vit", "spd", "lck", "acc", "eva", "ldr", "mor"]
## Keys of CharacterSheet.derived() that matter when comparing two pieces of gear, with their short labels.
const DELTA_KEYS: Array[String] = ["max_hp", "max_mp", "attack", "defense", "resistance", "accuracy", "evasion", "crit", "spd", "move"]
const DELTA_LABELS := {
    "max_hp": "HP", "max_mp": "MP", "attack": "ATK", "defense": "DEF", "resistance": "RES",
    "accuracy": "ACC", "evasion": "EVA", "crit": "CRIT", "spd": "SPD", "move": "MOV",
}


static func stat_name(key: String) -> String:
    return str(STAT_NAMES.get(key, key.to_upper()))


static func slot_name(slot: String) -> String:
    return str(SLOT_NAMES.get(slot, slot.capitalize()))


## "+3" or "-2" (zero shows as "+0").
static func signed(n: int) -> String:
    if n >= 0:
        return "+%d" % n
    return "%d" % n


## "+2 LDR, +5 MOR" from an item "bonus" block.
static func bonus_text(bonus: Dictionary) -> String:
    var keys: Array = bonus.keys()
    keys.sort()
    var parts: Array[String] = []
    for k in keys:
        parts.append("%s %s" % [signed(int(bonus[k])), stat_name(str(k))])
    return ", ".join(PackedStringArray(parts))


## Sigil "mods" block: flat stats ("+1 STR") and percentages ("+5% HP", "+10% EXP", "+10% gold").
static func mods_text(mods: Dictionary) -> String:
    var keys: Array = mods.keys()
    keys.sort()
    var parts: Array[String] = []
    for k in keys:
        var key: String = str(k)
        var v: int = int(mods[k])
        if key.ends_with("_pct"):
            var base: String = key.substr(0, key.length() - 4)
            var label: String = stat_name(base)
            if base == "exp":
                label = "EXP"
            elif base == "gold":
                label = "gold"
            parts.append("%s%% %s" % [signed(v), label])
        else:
            parts.append("%s %s" % [signed(v), stat_name(key)])
    return ", ".join(PackedStringArray(parts))


## One line describing an item: name, rarity, weapon/armor numbers, bonuses and sockets.
static func item_line(item_id: String, items: Dictionary, weapons: Dictionary, with_name: bool = true) -> String:
    var it: Dictionary = items.get(item_id, {})
    if it.is_empty():
        return "-"
    var parts: Array[String] = []
    if with_name:
        parts.append(str(it.get("name", item_id)))
    parts.append(str(it.get("rarity", "common")).capitalize())
    var w: Dictionary = weapons.get(str(it.get("weapon_id", "")), {})
    if not w.is_empty():
        parts.append("ATK %d, range %d-%d" % [int(w.get("power", 0)), int(w.get("range_min", 1)), int(w.get("range_max", 1))])
        if int(w.get("acc", 0)) != 0:
            parts.append("ACC %s" % signed(int(w["acc"])))
    if int(it.get("armor_def", 0)) != 0:
        parts.append("DEF +%d" % int(it["armor_def"]))
    if int(it.get("armor_res", 0)) != 0:
        parts.append("RES +%d" % int(it["armor_res"]))
    var bonus: Dictionary = it.get("bonus", {})
    if not bonus.is_empty():
        parts.append(bonus_text(bonus))
    if bool(it.get("two_handed", false)):
        parts.append("two-handed")
    if int(it.get("sockets", 0)) > 0:
        parts.append("%d sockets, AP x%d" % [int(it["sockets"]), int(it.get("ap_mult", 1))])
    if str(it.get("bound_to", "")) != "":
        parts.append("bound heirloom")
    return ", ".join(PackedStringArray(parts))


## "Mend: heals 6 + INT, 4 MP, range 1-2" / "Ember Bolt: magic damage 7 + 1.2 x INT, 4 MP, range 2-4".
static func skill_line(skill_id: String, skills: Dictionary) -> String:
    var sk: Dictionary = skills.get(skill_id, {})
    if sk.is_empty():
        return skill_id
    var name: String = str(sk.get("name", skill_id))
    var tail: String = "%d MP, range %d-%d" % [int(sk.get("mp", 0)), int(sk.get("range_min", 1)), int(sk.get("range_max", 1))]
    if str(sk.get("type", "")) == "strike":
        return "%s: weapon attack x%.1f, never misses, %s" % [name, float(sk.get("mult", 1.0)), tail]
    if str(sk.get("type", "")) == "damage":
        return "%s: magic damage %d + 1.2 x INT, %s" % [name, int(sk.get("power", 0)), tail]
    return "%s: heals %d + INT, %s" % [name, int(sk.get("power", 0)), tail]


## What a sigil does at a given level. `skills` is the skills table (for spell names).
static func sigil_effect(sdef: Dictionary, lv: int, skills: Dictionary) -> String:
    var kind: String = str(sdef.get("kind", ""))
    var ld: Dictionary = CharacterSheet.sigil_level_data(sdef, lv)
    if kind == "magic":
        var names: Array[String] = []
        for sid in CharacterSheet.sigil_skills_at(sdef, lv):
            names.append(str((skills.get(sid, {}) as Dictionary).get("name", sid)))
        return "Spells: " + ", ".join(PackedStringArray(names))
    if kind == "support":
        var sup: Dictionary = ld.get("support", {})
        var parts: Array[String] = []
        if sup.has("skill_power_pct"):
            parts.append("+%d%% power to the linked spell" % int(sup["skill_power_pct"]))
        if sup.has("ap_pct"):
            parts.append("+%d%% AP to the linked sigil" % int(sup["ap_pct"]))
        return ", ".join(PackedStringArray(parts)) + " (works only in a linked socket)"
    return mods_text(ld.get("mods", {}))


## "Lv 2/4, 35 AP to next" or "Lv 4/4 MASTERED".
static func sigil_progress(inst: Dictionary, sdef: Dictionary) -> String:
    var lv: int = CharacterSheet.sigil_level(inst, sdef)
    var mx: int = CharacterSheet.sigil_max_level(sdef)
    if CharacterSheet.sigil_is_mastered(inst, sdef):
        return "Lv %d/%d MASTERED" % [lv, mx]
    return "Lv %d/%d, %d AP to next" % [lv, mx, CharacterSheet.sigil_ap_to_next(inst, sdef)]


## AP progress that fits on a socket button: "35/70 AP" or "MAX".
static func sigil_ap_text(inst: Dictionary, sdef: Dictionary) -> String:
    if CharacterSheet.sigil_is_mastered(inst, sdef):
        return "MAX"
    var th: Array = sdef.get("ap", [])
    var lv: int = CharacterSheet.sigil_level(inst, sdef)
    return "%d/%d AP" % [int(inst.get("ap", 0)), int(th[lv - 1])]


## Two or three words that fit on a socket button: "Embers Lv2".
static func sigil_short(inst: Dictionary, sdef: Dictionary) -> String:
    var nm: String = str(sdef.get("name", str(inst.get("id", "?"))))
    nm = nm.replace("Sigil of the ", "").replace("Sigil of ", "")
    return "%s Lv%d" % [nm, CharacterSheet.sigil_level(inst, sdef)]


## "ATK +3, DEF +1" comparing two CharacterSheet.derived() results; "no change" when nothing differs.
static func delta_text(before: Dictionary, after: Dictionary) -> String:
    var parts: Array[String] = []
    for key in DELTA_KEYS:
        var a: int = roundi(float(before.get(key, 0)))
        var b: int = roundi(float(after.get(key, 0)))
        if a != b:
            parts.append("%s %s" % [str(DELTA_LABELS[key]), signed(b - a)])
    if parts.is_empty():
        return "no change"
    return ", ".join(PackedStringArray(parts))


## Per-stat changes between two CharacterSheet.derived() results, for colouring: [{"text": "ATK +3", "sign": 1}, ...].
## sign is 1 for better and -1 for worse; the array is empty when nothing differs.
static func delta_parts(before: Dictionary, after: Dictionary) -> Array:
    var out: Array = []
    for key in DELTA_KEYS:
        var a: int = roundi(float(before.get(key, 0)))
        var b: int = roundi(float(after.get(key, 0)))
        if a != b:
            var sign_value: int = 1
            if b < a:
                sign_value = -1
            out.append({"text": "%s %s" % [str(DELTA_LABELS[key]), signed(b - a)], "sign": sign_value})
    return out
