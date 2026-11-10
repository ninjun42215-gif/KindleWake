extends RefCounted
## Pure rules for the post-campaign Chronicle of Houses unlock gate.
## Story systems must call milestones only after their authored events are completed.
## This system does not simulate families or titles; it protects the transition into that mode.

const VERSION := 1
const REQUIRED_MILESTONES := [
    "campaign_completed",
    "became_last_emperor",
    "empire_dissolved",
    "epilogue_completed",
    "natural_old_age_death"
]

static func new_state() -> Dictionary:
    var milestones := {}
    for milestone in REQUIRED_MILESTONES:
        milestones[milestone] = false
    return {
        "version": VERSION,
        "milestones": milestones,
        "unlocked": false,
        "founder_record": {}
    }


## Marks one milestone in order. Death requires explicit natural old-age provenance.
static func record_milestone(state: Dictionary, milestone: String, details: Dictionary = {}) -> bool:
    if not REQUIRED_MILESTONES.has(milestone):
        return false
    var normalized := normalize_state(state)
    var index := REQUIRED_MILESTONES.find(milestone)
    var milestones: Dictionary = normalized["milestones"]
    if bool(milestones[milestone]):
        return false
    if index > 0 and not bool(milestones[REQUIRED_MILESTONES[index - 1]]):
        return false
    if milestone == "natural_old_age_death":
        if str(details.get("cause", "")) != "old_age":
            return false
        if str(details.get("protagonist_id", "")) == "":
            return false
    milestones[milestone] = true
    normalized["milestones"] = milestones
    if milestone == "natural_old_age_death":
        normalized["founder_record"] = {
            "protagonist_id": str(details["protagonist_id"]),
            "cause": "old_age",
            "age_at_death": int(details.get("age_at_death", 0)),
            "death_date": str(details.get("death_date", "")),
            "final_title": str(details.get("final_title", "Last Emperor")),
            "ending_id": str(details.get("ending_id", "")),
            "recorded": true
        }
        normalized["unlocked"] = true
    state.clear()
    state.merge(normalized, true)
    return true


## Rebuild from validated milestones; never trust a serialized unlocked=true flag.
static func normalize_state(raw: Dictionary) -> Dictionary:
    var clean := new_state()
    var saved: Variant = raw.get("milestones", {})
    if typeof(saved) != TYPE_DICTIONARY:
        return clean
    var founder: Variant = raw.get("founder_record", {})
    var founder_data: Dictionary = founder if typeof(founder) == TYPE_DICTIONARY else {}
    for milestone in REQUIRED_MILESTONES:
        if not bool(saved.get(milestone, false)):
            break
        var details: Dictionary = {}
        if milestone == "natural_old_age_death":
            details = founder_data
        if not record_milestone(clean, milestone, details):
            break
    return clean


static func is_unlocked(state: Dictionary) -> bool:
    var clean := normalize_state(state)
    return bool(clean.get("unlocked", false))


static func next_milestone(state: Dictionary) -> String:
    var clean := normalize_state(state)
    for milestone in REQUIRED_MILESTONES:
        if not bool(clean["milestones"].get(milestone, false)):
            return milestone
    return ""
