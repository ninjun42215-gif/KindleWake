extends RefCounted
## Presentation-only mapping from authored rune skills/statuses to lightweight battle effects.
## This file never changes combat resolution, hit chance, status duration or damage.

static func kind_for_skill(skill_id: String, status: String = "") -> String:
    var skill := skill_id.strip_edges().to_lower()
    var applied_status := status.strip_edges().to_lower()

    if skill == "fordbreaker_cleave":
        return "slash"
    if skill == "final_edict":
        return "arcane"
    if skill.begins_with("ember_"):
        return "fire"
    if skill.begins_with("frost_"):
        return "frost"
    if skill.begins_with("storm_"):
        return "shock"
    if skill.begins_with("holy_"):
        return "arcane"
    if skill.begins_with("shadow_"):
        return "shadow"

    match applied_status:
        "burn":
            return "fire"
        "chill":
            return "frost"
        "shock":
            return "shock"
        "exposed":
            return "arcane"
        "regen":
            return "heal"
        _:
            return "burst"


static func color_for_skill(skill_id: String, status: String = "") -> Color:
    var skill := skill_id.strip_edges().to_lower()
    var applied_status := status.strip_edges().to_lower()

    if skill == "fordbreaker_cleave":
        return Color("#f35a36")
    if skill == "final_edict" or skill.begins_with("holy_"):
        return Color("#f2d17a")
    if skill.begins_with("ember_") or applied_status == "burn":
        return Color("#ff793d")
    if skill.begins_with("frost_") or applied_status == "chill":
        return Color("#82d5ee")
    if skill.begins_with("storm_") or applied_status == "shock":
        return Color("#f6df70")
    if skill.begins_with("shadow_"):
        return Color("#b28be8")
    if applied_status == "exposed":
        return Color("#c39aee")
    if applied_status == "regen":
        return Color("#80dfa0")
    return Color("#e8c78c")
