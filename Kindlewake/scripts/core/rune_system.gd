class_name RuneSystem
extends RefCounted
## Rune grades, levels, passive effects and chance-based cross-grade fusion.
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
    var ap: Array = d.get("ap", [])
    var lv := 1
    for threshold in ap:
        if int(inst.get("ap", 0)) >= int(threshold):
            lv += 1
    return lv
static func success_chance(grade: String) -> int:
    return int(SUCCESS_CHANCES.get(grade, 0))
static func grade_power_bonus(inst: Dictionary, rune_defs: Dictionary) -> int:
    var def: Dictionary = rune_defs.get(str(inst.get("id", "")), {})
    var base_grade := str(def.get("grade", "common"))
    return maxi(0, GRADES.find(grade_of(inst, rune_defs)) - GRADES.find(base_grade)) * 5
static func matching_indices(inventory: Array, rune_id: String, _grade: String, rune_defs: Dictionary) -> Array[int]:
    var out: Array[int] = []
    if not rune_defs.has(rune_id) or bool(rune_defs[rune_id].get("fusion_allowed", true)) == false:
        return out
    for i in range(inventory.size()):
        if str((inventory[i] as Dictionary).get("id", "")) == rune_id:
            out.append(i)
    return out
## Any three copies of a rune may combine regardless of grade. Average input grade and AP level determine odds.
static func combine(inventory: Array, rune_id: String, _grade: String, rune_defs: Dictionary, rng: RandomNumberGenerator) -> Dictionary:
    var def: Dictionary = rune_defs.get(rune_id, {})
    if def.is_empty() or bool(def.get("fusion_allowed", true)) == false or bool(def.get("heirloom", false)):
        return {"ok":false,"success":false,"error":"This rune is bound to its legacy and cannot be fused."}
    var matches := matching_indices(inventory, rune_id, "any", rune_defs)
    if matches.size() < 3:
        return {"ok":false,"success":false,"error":"Three copies of this rune are required. Their grades may differ."}
    var grade_sum := 0
    var level_sum := 0
    for i in range(3):
        var inst: Dictionary = inventory[matches[i]]
        grade_sum += maxi(0, GRADES.find(grade_of(inst, rune_defs)))
        level_sum += rune_level(inst, rune_defs)
    var avg_grade := int(floor(float(grade_sum) / 3.0))
    var base_grade := maxi(avg_grade, GRADES.find(str(def.get("grade", "common"))) - 1)
    var target_index := mini(base_grade + 1, GRADES.size() - 1)
    if target_index <= base_grade:
        return {"ok":false,"success":false,"error":"This rune has reached its maximum grade."}
    var target_grade := GRADES[target_index]
    var base_chance := success_chance(target_grade)
    var level_bonus := clampi(int(round(float(level_sum - 3) * 2.5)), 0, 25)
    var chance := mini(95, base_chance + level_bonus)
    var success := rng.randi_range(1, 100) <= chance
    var best_inst: Dictionary = inventory[matches[0]].duplicate(true)
    for i in range(3):
        if GRADES.find(grade_of(inventory[matches[i]], rune_defs)) > GRADES.find(grade_of(best_inst, rune_defs)):
            best_inst = inventory[matches[i]].duplicate(true)
    for i in range(2, -1, -1):
        inventory.remove_at(matches[i])
    var result_grade := target_grade if success else grade_of(best_inst, rune_defs)
    inventory.append({"id":rune_id,"ap":0,"grade":result_grade})
    return {"ok":true,"success":success,"grade":result_grade,"chance":chance,"level_bonus":level_bonus,
        "message":"Fusion succeeded: %s grade. Rune levels added +%d%% chance." % [target_grade.capitalize(), level_bonus] if success else "Fusion failed. One %s rune survived." % result_grade.capitalize()}
