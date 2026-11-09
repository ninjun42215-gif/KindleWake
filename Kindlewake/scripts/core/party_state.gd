class_name PartyState
extends RefCounted

const CharacterSheetScript = preload("res://scripts/core/character_sheet.gd")
const BattleUnitScript = preload("res://scripts/battle/battle_unit.gd")
const CombatCalcScript = preload("res://scripts/battle/combat_calc.gd")
const RuneSystemScript = preload("res://scripts/core/rune_system.gd")
## The persistent party: roster of CharacterSheets, shared inventory and gold.
## Pure data + rules (no nodes), so it is unit-testable headless; the GameState autoload just owns one.

## Battle rewards follow Final Fantasy VII: every DEFEATED enemy pays a fixed EXP / AP / gold amount (its own "reward" block).
## Total EXP is split equally between the player units still standing; each of them receives the FULL AP total;
## gold goes to the party. Fallen units get nothing, and a defeat pays nothing.
const BENCH_EXP_SHARE := 0.4     # undeployed roster members get 40% of one survivor's EXP share, never AP

var roster: Array[String] = []     # display order
var sheets: Dictionary = {}        # character id -> CharacterSheetScript
var inventory: Dictionary = {}     # item id -> count
var gold: int = 0
var sigil_inv: Array = []          # unequipped sigil instances ({"id","ap"[, "spawned"]})


## `characters` is the RAW characters.json dictionary (it carries equipment blocks), not GameData.as_db().
## Optional protagonist_definition replaces only the `torren` entry; every companion stays data-driven.
static func new_game(start: Dictionary, characters: Dictionary, protagonist_definition: Dictionary = {}) -> PartyState:
    var p := PartyState.new()
    p.gold = int(start.get("gold", 0))
    var ids: Array = start.get("party", [])
    for cid in ids:
        var id: String = str(cid)
        if characters.has(id):
            var cdef: Dictionary = characters[id]
            if id == "torren" and not protagonist_definition.is_empty():
                cdef = protagonist_definition
            p.add_member(id, cdef)
    var inv: Dictionary = start.get("inventory", {})
    for k in inv.keys():
        p.inventory[str(k)] = int(inv[k])
    for sg in (start.get("sigils", []) as Array):
        if typeof(sg) == TYPE_DICTIONARY:
            p.sigil_inv.append((sg as Dictionary).duplicate())
        else:
            p.add_sigil(str(sg))
    return p


func add_member(char_id: String, def: Dictionary) -> void:
    if sheets.has(char_id):
        return
    sheets[char_id] = CharacterSheetScript.from_def(char_id, def)
    roster.append(char_id)


func sheet(char_id: String) -> CharacterSheetScript:
    return sheets.get(char_id)


# ---------------------------------------------------------------- inventory and equipment

func item_count(item_id: String) -> int:
    return int(inventory.get(item_id, 0))


func add_item(item_id: String, n: int = 1) -> void:
    inventory[item_id] = item_count(item_id) + n


func remove_item(item_id: String, n: int = 1) -> bool:
    if item_count(item_id) < n:
        return false
    var left: int = item_count(item_id) - n
    if left <= 0:
        inventory.erase(item_id)
    else:
        inventory[item_id] = left
    return true


## Moves an item from the inventory into a slot (the old item goes back). Returns "" on success or a reason.
func equip(char_id: String, slot: String, item_id: String, db: Dictionary) -> String:
    var sh: CharacterSheetScript = sheet(char_id)
    if sh == null:
        return "Unknown character."
    if item_count(item_id) <= 0:
        return "That item is not in the inventory."
    var items: Dictionary = db.get("items", {})
    var problem: String = sh.equip_problem(slot, item_id, items)
    if problem != "":
        return problem
    var old: String = sh.item_in(slot)
    sh.equipment[slot] = item_id
    remove_item(item_id, 1)
    if old != "":
        add_item(old, 1)
    _refit_sockets(sh, slot, items)
    return ""


func unequip(char_id: String, slot: String, db: Dictionary = {}) -> String:
    var sh: CharacterSheetScript = sheet(char_id)
    if sh == null:
        return "Unknown character."
    var old: String = sh.item_in(slot)
    if old == "":
        return "Nothing is equipped there."
    sh.equipment[slot] = ""
    add_item(old, 1)
    _refit_sockets(sh, slot, db.get("items", {}))
    return ""


## Weapon/armor changes can remove sockets; sigils that lose their socket go back to the sigil inventory.
func _refit_sockets(sh: CharacterSheetScript, slot: String, items: Dictionary) -> void:
    if (slot != "weapon" and slot != "armor") or items.is_empty():
        return
    for inst in sh.fit_sockets(items):
        sigil_inv.append(inst)


# ---------------------------------------------------------------- sigils (FF7 Materia)

func add_rune(rune_id: String, ap: int = 0, grade: String = "") -> void:
    var inst: Dictionary = {"id": rune_id, "ap": ap}
    if grade != "":
        inst["grade"] = grade
    sigil_inv.append(inst)


func add_sigil(sigil_id: String, ap: int = 0) -> void:
    add_rune(sigil_id, ap)


func fuse_runes(rune_id: String, grade: String, db: Dictionary, rng: RandomNumberGenerator) -> Dictionary:
    return RuneSystemScript.combine(sigil_inv, rune_id, grade, db.get("runes", db.get("sigils", {})), rng)


## Moves sigil `inv_index` of the inventory into socket `index` of the weapon/armor (the old one goes back). "" = success.
func equip_sigil(char_id: String, group: String, index: int, inv_index: int, db: Dictionary) -> String:
    var sh: CharacterSheetScript = sheet(char_id)
    if sh == null:
        return "Unknown character."
    if not CharacterSheetScript.SIGIL_GROUPS.has(group):
        return "Runes go into the weapon or the armor."
    var items: Dictionary = db.get("items", {})
    for inst0 in sh.fit_sockets(items):
        sigil_inv.append(inst0)
    if index < 0 or index >= sh.socket_count(group, items):
        return "There is no such socket."
    if inv_index < 0 or inv_index >= sigil_inv.size():
        return "That rune is not in the inventory."
    var inst: Dictionary = sigil_inv[inv_index]
    if not (db.get("sigils", {}) as Dictionary).has(str(inst.get("id", ""))):
        return "Unknown rune."
    var old: Dictionary = sh.sigil_at(group, index)
    sigil_inv.remove_at(inv_index)
    if not old.is_empty():
        sigil_inv.append(old)
    (sh.sigils[group] as Array)[index] = inst
    return ""


func unequip_sigil(char_id: String, group: String, index: int, db: Dictionary) -> String:
    var sh: CharacterSheetScript = sheet(char_id)
    if sh == null:
        return "Unknown character."
    var items: Dictionary = db.get("items", {})
    for inst0 in sh.fit_sockets(items):
        sigil_inv.append(inst0)
    var old: Dictionary = sh.sigil_at(group, index)
    if old.is_empty():
        return "That socket is empty."
    sigil_inv.append(old)
    (sh.sigils[group] as Array)[index] = {}
    return ""


# ---------------------------------------------------------------- battle bridge

## Copy of the battle database in which every party member's definition comes from the live sheet
## (current level, stats and gear). The battle code needs no changes: it just sees different numbers.
func battle_db(base_db: Dictionary) -> Dictionary:
    var out: Dictionary = base_db.duplicate()
    var chars: Dictionary = (base_db.get("characters", {}) as Dictionary).duplicate()
    for id in roster:
        var sh: CharacterSheetScript = sheets[id]
        chars[id] = sh.to_battle_def(base_db)
    out["characters"] = chars
    return out


## Rewards of a finished battle: {"exp": {char id: int}, "ap": {char id: int}, "gold": int, "defeated": int, "total_exp": int, "total_ap": int}.
## `db` needs "items" and "sigils" (for the Veteran's Mark / Coin Eye bonuses); it may be empty.
func battle_rewards(units: Array, result: String, db: Dictionary = {}) -> Dictionary:
    var out: Dictionary = {"exp": {}, "ap": {}, "gold": 0, "defeated": 0, "total_exp": 0, "total_ap": 0}
    if result != "victory":
        return out
    var tot_exp := 0
    var tot_ap := 0
    var tot_gold := 0
    var survivors: Array[String] = []
    var deployed: Dictionary = {}
    for o in units:
        var u: BattleUnitScript = o
        if u.team == "enemy" and not u.is_alive():
            var r: Dictionary = CombatCalcScript.enemy_reward(u)
            tot_exp += int(r["exp"])
            tot_ap += int(r["ap"])
            tot_gold += int(r["gold"])
            out["defeated"] = int(out["defeated"]) + 1
        elif u.team == "player" and sheets.has(u.character_id):
            deployed[u.character_id] = true
            if u.is_alive():
                survivors.append(u.character_id)
    out["total_exp"] = tot_exp
    out["total_ap"] = tot_ap
    if survivors.is_empty():
        return out
    var items: Dictionary = db.get("items", {})
    var sdefs: Dictionary = db.get("runes", db.get("sigils", {}))
    var share: int = int(float(tot_exp) / float(survivors.size()))
    if tot_exp > 0:
        share = maxi(1, share)
    var gold_pct := 0
    var exp_map: Dictionary = out["exp"]
    var ap_map: Dictionary = out["ap"]
    for id in survivors:
        var sh: CharacterSheetScript = sheets[id]
        var pct: int = sh.reward_pct("exp_pct", items, sdefs)
        exp_map[id] = int(float(share) * float(100 + pct) / 100.0)
        ap_map[id] = tot_ap
        gold_pct += sh.reward_pct("gold_pct", items, sdefs)
    for id in roster:
        if not deployed.has(id):
            exp_map[id] = roundi(float(share) * BENCH_EXP_SHARE)
    out["gold"] = int(float(tot_gold) * float(100 + gold_pct) / 100.0)
    return out


## Pays the rewards. Returns {"reports": [per character: character_id, name, exp_gained, levels, ap_gained, sigils],
## "gold": int, "spawned": [names of sigils that were mastered and spawned a fresh copy], "defeated": int, "total_exp": int, "total_ap": int}.
## `db` needs "classes", "items" and "sigils".
func apply_battle_result(units: Array, result: String, rng: RandomNumberGenerator, db: Dictionary) -> Dictionary:
    var rw: Dictionary = battle_rewards(units, result, db)
    var classes: Dictionary = db.get("classes", {})
    var items: Dictionary = db.get("items", {})
    var sdefs: Dictionary = db.get("runes", db.get("sigils", {}))
    var reports: Array = []
    var spawned: Array[String] = []
    var exp_map: Dictionary = rw["exp"]
    var ap_map: Dictionary = rw["ap"]
    for id in roster:
        if not exp_map.has(id) and not ap_map.has(id):
            continue
        var sh: CharacterSheetScript = sheets[id]
        var cdef: Dictionary = classes.get(sh.class_id, {})
        var rep: Dictionary = sh.add_exp(int(exp_map.get(id, 0)), rng, cdef)
        rep["character_id"] = id
        rep["name"] = sh.display_name
        var ap: int = int(ap_map.get(id, 0))
        rep["ap_gained"] = ap
        var srep: Array = sh.award_ap(ap, items, sdefs)
        for s in srep:
            var one: Dictionary = s
            if bool(one["spawn"]):
                add_sigil(str(one["id"]))
                spawned.append(str(one["name"]))
        rep["runes"] = srep
        rep["runes"] = srep
        rep["sigils"] = srep
        reports.append(rep)
    gold += int(rw["gold"])
    return {"reports": reports, "gold": int(rw["gold"]), "spawned": spawned, "defeated": int(rw["defeated"]),
        "total_exp": int(rw["total_exp"]), "total_ap": int(rw["total_ap"])}


# ---------------------------------------------------------------- persistence

func to_dict() -> Dictionary:
    var sd: Dictionary = {}
    for id in roster:
        var sh: CharacterSheetScript = sheets[id]
        sd[id] = sh.to_dict()
    return {"roster": roster.duplicate(), "sheets": sd, "inventory": inventory.duplicate(), "gold": gold, "sigil_inv": sigil_inv.duplicate(true)}


static func from_dict(d: Dictionary) -> PartyState:
    var p := PartyState.new()
    p.gold = int(d.get("gold", 0))
    var sd: Dictionary = d.get("sheets", {})
    var order: Array = d.get("roster", [])
    for id in order:
        var key: String = str(id)
        if sd.has(key):
            var one: Dictionary = sd[key]
            p.sheets[key] = CharacterSheetScript.from_dict(one)
            p.roster.append(key)
    var inv: Dictionary = d.get("inventory", {})
    for k in inv.keys():
        p.inventory[str(k)] = int(inv[k])
    for sg in (d.get("sigil_inv", []) as Array):
        if typeof(sg) == TYPE_DICTIONARY:
            p.sigil_inv.append((sg as Dictionary).duplicate(true))
        elif str(sg) != "":
            p.sigil_inv.append({"id": str(sg), "ap": 0})
    return p
