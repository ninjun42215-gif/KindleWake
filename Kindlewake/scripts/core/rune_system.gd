class_name RuneSystem
extends RefCounted
## Rune grade and chance-based fusion. Inventory entries remain compatible with legacy sigil saves.
const GRADES: Array[String] = ["common", "uncommon", "rare", "epic", "legendary", "mythical"]
const SUCCESS_CHANCES := {"uncommon":70,"rare":55,"epic":40,"legendary":25,"mythical":12}
const GRADE_POWER_BONUS := {"common":0,"uncommon":5,"rare":10,"epic":15,"legendary":20,"mythical":25}
static func grade_of(inst: Dictionary, rune_defs: Dictionary) -> String:
    var def: Dictionary = rune_defs.get(str(inst.get("id", "")), {})
    var grade := str(inst.get("grade", def.get("grade", "common")))
    return grade if GRADES.has(grade) else "common"
static func next_grade(grade: String) -> String:
    var i := GRADES.find(grade)
    return GRADES[i + 1] if i >= 0 and i + 1 < GRADES.size() else ""
static func success_chance(grade: String) -> int:
    return int(SUCCESS_CHANCES.get(grade, 0))
static func grade_power_bonus(inst: Dictionary, rune_defs: Dictionary) -> int:
    var def: Dictionary = rune_defs.get(str(inst.get("id", "")), {})
    var base_grade := str(def.get("grade", "common"))
    var current_grade := grade_of(inst, rune_defs)
    var extra_tiers: int = maxi(0, GRADES.find(current_grade) - GRADES.find(base_grade))
    return extra_tiers * 5
static func matching_indices(inventory: Array, rune_id: String, grade: String, rune_defs: Dictionary) -> Array[int]:
    var out: Array[int] = []
    if not rune_defs.has(rune_id):
        return out
    for i in range(inventory.size()):
        var inst: Dictionary = inventory[i]
        if str(inst.get("id", "")) == rune_id and grade_of(inst, rune_defs) == grade:
            out.append(i)
    return out
## Three matching runes are consumed; success raises the grade, failure returns one at the old grade.
static func combine(inventory: Array, rune_id: String, grade: String, rune_defs: Dictionary, rng: RandomNumberGenerator) -> Dictionary:
    var next := next_grade(grade)
    if next == "":
        return {"ok":false,"success":false,"error":"This rune is already at the highest grade."}
    var matches := matching_indices(inventory, rune_id, grade, rune_defs)
    if matches.size() < 3:
        return {"ok":false,"success":false,"error":"Three matching runes of the same grade are required."}
    var chance := success_chance(next)
    var success := rng.randi_range(1, 100) <= chance
    for i in range(2, -1, -1):
        inventory.remove_at(matches[i])
    var result_grade := next if success else grade
    inventory.append({"id":rune_id,"ap":0,"grade":result_grade})
    return {"ok":true,"success":success,"grade":result_grade,"chance":chance,
        "message":"Fusion succeeded: %s Rune." % next.capitalize() if success else "Fusion failed. One %s Rune survived." % grade.capitalize()}
