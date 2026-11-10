extends RefCounted
class_name OpeningChapterSystem
## Pure rules for the first playable chapter. Story flags live in GameState.world_flags
## so they remain compatible with existing offline campaign saves.

const ARRIVAL_CHOICES := ["repair_well", "secure_roof", "organize_ledger"]

static func arrival_unlocked(flags: Dictionary) -> bool:
    return bool(flags.get("east_gallery_escaped", false))

static func apply_arrival_choice(existing_flags: Dictionary, choice_id: String) -> Dictionary:
    if not ARRIVAL_CHOICES.has(choice_id):
        return {}
    var flags: Dictionary = existing_flags.duplicate(true)
    flags["kaer_sethorn_arrived"] = true
    flags["chapter_1_arrival_complete"] = true
    flags["kaer_sethorn_priority"] = choice_id
    flags["kaer_well_repaired"] = choice_id == "repair_well"
    flags["kaer_well_water_safe"] = choice_id == "repair_well"
    flags["kaer_roof_secured"] = choice_id == "secure_roof"
    flags["kaer_ledger_organized"] = choice_id == "organize_ledger"
    flags["chapter"] = "I"
    return flags

static func priority_acknowledgement(choice_id: String) -> String:
    match choice_id:
        "repair_well":
            return "The well comes first. Clean water means the wounded, the children and the watch can last through the next night."
        "secure_roof":
            return "The roof comes first. A dry hall will shelter the injured and give the company one safe place to plan."
        "organize_ledger":
            return "The records come first. Names, debts and stores will tell you who is missing — and what the keep can truly afford."
        _:
            return ""
