class_name EncounterBuilder
extends RefCounted
## Builds repeatable regional fights from data/bestiary.json. Pure and deterministic for tests.

static func group_count(encounters: Dictionary) -> int:
    var cfg: Dictionary = encounters.get("skirmish", {})
    return (cfg.get("groups", []) as Array).size()


static func build_group(encounters: Dictionary, battles: Dictionary, group_index: int) -> Dictionary:
    return _build_config_group(encounters.get("skirmish", {}) as Dictionary, battles, group_index, "Skirmish", "skirmish")


static func build_regional_skirmish(bestiary: Dictionary, region_id: String, battles: Dictionary, rand: RandomNumberGenerator) -> Dictionary:
    var regions: Dictionary = bestiary.get("regions", {})
    var cfg: Dictionary = regions.get(region_id, {})
    if cfg.is_empty():
        return {}
    var groups: Array = cfg.get("groups", [])
    if groups.is_empty():
        return {}
    var total := 0
    for entry in groups:
        total += maxi(0, int((entry as Dictionary).get("weight", 1)))
    if total <= 0:
        return {}
    var roll: int = rand.randi_range(1, total)
    var selected := 0
    for i in range(groups.size()):
        roll -= maxi(0, int((groups[i] as Dictionary).get("weight", 1)))
        if roll <= 0:
            selected = i
            break
    return _build_config_group(cfg, battles, selected, str(cfg.get("title", "Regional Encounter")), "regional_skirmish_" + region_id)


static func _build_config_group(cfg: Dictionary, battles: Dictionary, group_index: int, fallback_title: String, battle_id: String = "skirmish") -> Dictionary:
    var base_id := str(cfg.get("base_battle", "battle_01"))
    var base: Dictionary = (battles.get(base_id, {}) as Dictionary).duplicate(true)
    var groups: Array = cfg.get("groups", [])
    if base.is_empty() or group_index < 0 or group_index >= groups.size():
        return {}
    var chosen: Dictionary = groups[group_index]
    var spawns: Array = []
    for unit in (base.get("units", []) as Array):
        if str((unit as Dictionary).get("team", "")) == "player":
            spawns.append((unit as Dictionary).duplicate(true))
    var cells: Array = cfg.get("enemy_cells", [])
    var members: Array = chosen.get("units", [])
    if members.is_empty() or members.size() > cells.size():
        return {}
    for i in range(members.size()):
        var enemy_id := str(members[i])
        var entry: Dictionary = {"character_id": enemy_id, "team": "enemy", "cell": cells[i], "facing": 2}
        if str(chosen.get("commander", "")) == enemy_id:
            entry["commander"] = true
        spawns.append(entry)
    base["units"] = spawns
    base["id"] = battle_id
    base["title"] = str(cfg.get("title", fallback_title))
    base["briefing"] = str(cfg.get("briefing", "A hostile force blocks the road ahead."))
    return base


static func build_skirmish(encounters: Dictionary, battles: Dictionary, rand: RandomNumberGenerator) -> Dictionary:
    var cfg: Dictionary = encounters.get("skirmish", {})
    var groups: Array = cfg.get("groups", [])
    if groups.is_empty():
        return {}
    var total := 0
    for g in groups:
        total += int((g as Dictionary).get("weight", 1))
    var roll: int = rand.randi_range(1, maxi(1, total))
    var index := 0
    for i in range(groups.size()):
        roll -= int((groups[i] as Dictionary).get("weight", 1))
        if roll <= 0:
            index = i
            break
    return _build_config_group(cfg, battles, index, str(cfg.get("title", "Skirmish")))
