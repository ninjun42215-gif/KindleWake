extends RefCounted
class_name PrologueSystem
## Small, explicit prologue consequence model. Pure data transformation for reliable testing.

const CHOICES := ["rescue_people", "recover_record", "split_company"]


static func apply_choice(existing_flags: Dictionary, choice_id: String) -> Dictionary:
    if not CHOICES.has(choice_id):
        return {}
    var flags: Dictionary = existing_flags.duplicate(true)
    flags["prologue_complete"] = true
    flags["prologue_decision"] = choice_id
    flags["prologue_people_saved"] = choice_id != "recover_record"
    flags["prologue_record_saved"] = choice_id != "rescue_people"
    flags["prologue_company_split"] = choice_id == "split_company"
    flags["chapter"] = "I"
    return flags


static func acknowledgement(flags: Dictionary) -> String:
    match str(flags.get("prologue_decision", "")):
        "rescue_people":
            return "Bram: The people are alive. We will find another way to prove what happened."
        "recover_record":
            return "Sela: We kept the record. I only hope the people behind that door found another way out."
        "split_company":
            return "Wystan: We carried both lives and truth through the fire. Let us not waste either."
        _:
            return ""
