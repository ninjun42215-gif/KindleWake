class_name CharacterCreation
extends RefCounted
## Data-driven protagonist profile validation and definition builder used by creator UI and GameState.

const STAT_KEYS: Array[String] = ["hp", "mp", "str", "dex", "int", "vit", "spd", "lck", "acc", "eva", "ldr", "mor"]
## Each preference maps to a common, campaign-start weapon item. Keep these at a comparable power tier.
const STARTING_WEAPON_ITEMS: Dictionary = {
    "sword": "arming_sword",
    "axe": "hand_axe",
    "spear": "spear",
    "bow": "hunting_bow",
    "crossbow": "crossbow",
    "staff": "staff",
    "mace": "mace",
    "dagger": "dagger",
}

static func default_profile(config: Dictionary) -> Dictionary:
    return (config.get("defaults", {}) as Dictionary).duplicate(true)


## Returns an empty string when valid, otherwise a concise player-facing reason.
static func validate(profile: Dictionary, config: Dictionary, classes: Dictionary) -> String:
    var limits: Dictionary = config.get("limits", {})
    var name: String = str(profile.get("name", "")).strip_edges()
    if name.length() < int(limits.get("name_min", 2)) or name.length() > int(limits.get("name_max", 24)):
        return "Name must be between %d and %d characters." % [int(limits.get("name_min", 2)), int(limits.get("name_max", 24))]
    if not (config.get("presentations", []) as Array).has(str(profile.get("presentation", ""))):
        return "Choose a valid presentation."
    if not (config.get("faces", []) as Array).has(str(profile.get("face", ""))):
        return "Choose a valid face preset."
    if not (config.get("hair", []) as Array).has(str(profile.get("hair", ""))):
        return "Choose a valid hair preset."
    if not (config.get("skin", []) as Array).has(str(profile.get("skin", ""))):
        return "Choose a valid skin preset."
    if not (config.get("builds", []) as Array).has(str(profile.get("build", ""))):
        return "Choose a valid build preset."
    var origins: Dictionary = config.get("origins", {})
    if not origins.has(str(profile.get("origin", ""))):
        return "Choose a valid origin."
    var disciplines: Dictionary = config.get("disciplines", {})
    var discipline_id: String = str(profile.get("discipline", ""))
    if not disciplines.has(discipline_id):
        return "Choose a valid discipline."
    var discipline: Dictionary = disciplines[discipline_id]
    var class_id: String = str(discipline.get("class_id", ""))
    if not classes.has(class_id):
        return "The selected discipline has no valid class."
    if not (config.get("weapon_preferences", []) as Array).has(str(profile.get("weapon_preference", ""))):
        return "Choose a valid weapon preference."
    if not (discipline.get("weapon_preferences", []) as Array).has(str(profile.get("weapon_preference", ""))):
        return "That weapon preference does not fit the selected discipline."
    if not (config.get("temperaments", {}) as Dictionary).has(str(profile.get("temperament", ""))):
        return "Choose a valid temperament."
    var allocation: Dictionary = profile.get("stat_allocation", {})
    var points := 0
    for stat in ["str", "dex", "int", "vit", "spd", "lck"]:
        var value := int(allocation.get(stat, 0))
        if value < 0 or value > 5:
            return "Starting attribute allocations must be between 0 and 5."
        points += value
    if points != int(config.get("stat_points", 8)):
        return "Allocate all %d starting attribute points." % int(config.get("stat_points", 8))
    return ""


## Produces a fresh character definition; it never mutates the source character or config.
static func build_definition(base: Dictionary, profile: Dictionary, config: Dictionary, classes: Dictionary) -> Dictionary:
    var reason: String = validate(profile, config, classes)
    if reason != "":
        return {}
    var result: Dictionary = base.duplicate(true)
    var origin: Dictionary = (config.get("origins", {}) as Dictionary)[str(profile["origin"])]
    var discipline: Dictionary = (config.get("disciplines", {}) as Dictionary)[str(profile["discipline"])]
    var temperament: Dictionary = (config.get("temperaments", {}) as Dictionary)[str(profile["temperament"])]
    var stats: Dictionary = result.get("stats", {}).duplicate(true)
    _apply_stat_bonus(stats, origin.get("stat_bonus", {}))
    _apply_stat_bonus(stats, temperament.get("stat_bonus", {}))
    var allocation: Dictionary = profile.get("stat_allocation", {})
    for stat in ["str", "dex", "int", "vit", "spd", "lck"]:
        stats[stat] = int(stats.get(stat, 0)) + int(allocation.get(stat, 0))
    result["name"] = str(profile["name"]).strip_edges()
    result["class_id"] = str(discipline["class_id"])
    result["house"] = str(origin.get("house", "dunmarrow"))
    result["stats"] = stats
    var preference: String = str(profile["weapon_preference"])
    var starting_weapon: String = str(STARTING_WEAPON_ITEMS.get(preference, ""))
    if starting_weapon == "":
        return {}
    var equipment: Dictionary = result.get("equipment", {}).duplicate(true)
    equipment["weapon"] = starting_weapon
    # A starting weapon must never silently conflict with a two-handed/off-hand setup.
    if bool((config.get("starting_weapon_two_handed", {}) as Dictionary).get(preference, false)):
        equipment["offhand"] = ""
    result["equipment"] = equipment
    result["creation"] = {
        "schema_version": int(config.get("schema_version", 1)),
        "presentation": str(profile["presentation"]),
        "face": str(profile["face"]),
        "hair": str(profile["hair"]),
        "skin": str(profile["skin"]),
        "build": str(profile["build"]),
        "origin": str(profile["origin"]),
        "discipline": str(profile["discipline"]),
        "weapon_preference": preference,
        "starting_weapon_item": starting_weapon,
        "temperament": str(profile["temperament"]),
        "stat_allocation": allocation.duplicate(true),
        "origin_tags": (origin.get("tags", []) as Array).duplicate(),
    }
    return result


static func _apply_stat_bonus(stats: Dictionary, bonuses: Dictionary) -> void:
    for key in bonuses.keys():
        var stat: String = str(key)
        if STAT_KEYS.has(stat):
            stats[stat] = int(stats.get(stat, 0)) + int(bonuses[key])
