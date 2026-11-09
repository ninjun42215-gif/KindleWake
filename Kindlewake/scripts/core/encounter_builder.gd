class_name EncounterBuilder
extends RefCounted
## Builds repeatable random fights (data/encounters.json). Pure and static, so tests and the balance report
## can use it without autoloads.


static func group_count(encounters: Dictionary) -> int:
    var cfg: Dictionary = encounters.get("skirmish", {})
    return (cfg.get("groups", []) as Array).size()


## A battle definition with id "skirmish" for enemy group number `group_index`: the base story map, the player's
## spawn points from it and that group's enemies placed on the encounter's enemy cells. {} when the data is missing.
static func build_group(encounters: Dictionary, battles: Dictionary, group_index: int) -> Dictionary:
    var cfg: Dictionary = encounters.get("skirmish", {})
    var base: Dictionary = (battles.get(str(cfg.get("base_battle", "battle_01")), {}) as Dictionary).duplicate(true)
    var groups: Array = cfg.get("groups", [])
    if base.is_empty() or group_index < 0 or group_index >= groups.size():
        return {}
    var chosen: Dictionary = groups[group_index]
    var spawns: Array = []
    for u in (base.get("units", []) as Array):
        if str((u as Dictionary).get("team", "")) == "player":
            spawns.append(u)
    var cells: Array = cfg.get("enemy_cells", [])
    var members: Array = chosen.get("units", [])
    for i in range(mini(members.size(), cells.size())):
        var entry: Dictionary = {"character_id": str(members[i]), "team": "enemy", "cell": cells[i], "facing": 2}
        if str(chosen.get("commander", "")) == str(members[i]):
            entry["commander"] = true
        spawns.append(entry)
    base["units"] = spawns
    base["id"] = "skirmish"
    base["title"] = str(cfg.get("title", "Skirmish"))
    base["briefing"] = str(cfg.get("briefing", ""))
    return base


## Picks a group by weight (data "weight") and builds it.
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
    return build_group(encounters, battles, index)
