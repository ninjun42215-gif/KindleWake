class_name RuneSystem
extends RefCounted
## Rune grades, levels, passive effects and cross-grade fusion.
const GRADES: Array[String] = ["common", "uncommon", "rare", "epic", "legendary", "mythical"]
const SUCCESS_CHANCES := {"uncommon":70,"rare":55,"epic":40,"legendary":25,"mythical":12}
static func grade_of(inst: Dictionary, rune_defs: Dictionary) -> String:
    var def: Dictionary = rune_defs.get(str(inst.get("id", "")), {})
    var grade := str(inst.get("grade", def.get("grade", "common")))
    return grade if GRADES.has(grade) else "common"
static func next_grade(grade: String) -> String:
    var i := GRADES.find(grade)
    return GRADES[i + 1] if i >= 0 and i + 1 < GRADES.size() else ""
static func rune_level(inst: Dictionary, rune_defs: Dictionary) -> int:
    var d: Dictionary = rune_defs.get(str(inst.get("id", "")), {})
    var lv := 1
    for threshold in (d.get("ap", []) as Array):
        if int(inst.get("ap", 0)) >= int(threshold):
            lv += 1
    return lv
static func success_chance(grade: String) -> int:
    return int(SUCCESS_CHANCES.get(grade, 0))
static func grade_power_bonus(inst: Dictionary, rune_defs: Dictionary) -> int:
    var def: Dictionary = rune_defs.get(str(inst.get("id", "")), {})
    return maxi(0, GRADES.find(grade_of(inst, rune_defs)) - GRADES.find(str(def.get("grade", "common")))) * 5
static func matching_indices(inventory: Array, rune_id: String, _grade: String, rune_defs: Dictionary) -> Array[int]:
    var out: Array[int] = []
    if not rune_defs.has(rune_id) or not bool(rune_defs[rune_id].get("fusion_allowed", true)):
        return out
    for i in range(inventory.size()):
        if str((inventory[i] as Dictionary).get("id", "")) == rune_id:
            out.append(i)
    return out
static func preview(inventory: Array, rune_id: String, rune_defs: Dictionary) -> Dictionary:
    var def: Dictionary = rune_defs.get(rune_id, {})
    if def.is_empty() or not bool(def.get("fusion_allowed", true)) or bool(def.get("heirloom", false)):
        return {"ok":false,"error":"This rune is unique or heirloom-bound and cannot be fused."}
    var matches := matching_indices(inventory, rune_id, "any", rune_defs)
    if matches.size() < 3:
        return {"ok":false,"error":"Three copies of this rune are required."}
    var grade_sum := 0
    var level_sum := 0
    var best_grade := 0
    for i in range(3):
        var inst: Dictionary = inventory[matches[i]]
        var g := GRADES.find(grade_of(inst, rune_defs))
        grade_sum += maxi(0, g)
        best_grade = maxi(best_grade, g)
        level_sum += rune_level(inst, rune_defs)
    var average_grade := int(floor(float(grade_sum) / 3.0))
    var base_grade := maxi(average_grade, GRADES.find(str(def.get("grade", "common"))) - 1)
    var target_index := mini(base_grade + 1, GRADES.size() - 1)
    if target_index <= base_grade:
        return {"ok":false,"error":"This rune has reached its maximum grade."}
    var target_grade := GRADES[target_index]
    var level_bonus := clampi(int(round(float(level_sum - 3) * 2.5)), 0, 25)
    var chance := mini(95, success_chance(target_grade) + level_bonus)
    return {"ok":true,"indices":matches,"grade":target_grade,"failure_grade":GRADES[best_grade],"chance":chance,"level_bonus":level_bonus}
static func combine(inventory: Array, rune_id: String, _grade: String, rune_defs: Dictionary, rng: RandomNumberGenerator) -> Dictionary:
    var info := preview(inventory, rune_id, rune_defs)
    if not bool(info.get("ok", false)):
        return {"ok":false,"success":false,"error":str(info.get("error", "Fusion unavailable."))}
    var success := rng.randi_range(1, 100) <= int(info.chance)
    var indices: Array = info.indices
    for i in range(2, -1, -1):
        inventory.remove_at(int(indices[i]))
    var result_grade := str(info.grade) if success else str(info.failure_grade)
    inventory.append({"id":rune_id,"ap":0,"grade":result_grade})
    return {"ok":true,"success":success,"grade":result_grade,"chance":int(info.chance),"level_bonus":int(info.level_bonus),
        "message":"Fusion succeeded: %s grade. Rune mastery added +%d%% chance." % [str(info.grade).capitalize(), int(info.level_bonus)] if success else "Fusion failed. One %s rune survived." % result_grade.capitalize()}
