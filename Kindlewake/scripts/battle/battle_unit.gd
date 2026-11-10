class_name BattleUnit
extends RefCounted

const BattleMapScript = preload("res://scripts/battle/battle_map.gd")
## One combatant. Plain data + tiny helpers; all rules live in BattleController / CombatCalc.

var id: int = 0
var character_id: String = ""
var display_name: String = ""
var team: String = "player"          # "player" | "enemy"
var class_id: String = ""
var level: int = 1
var cell: Vector2i = Vector2i.ZERO
var facing: int = 0                  # index into BattleMapScript.DIRS
var stats: Dictionary = {}           # int values: hp (max), mp (max), str, dex, int, vit, spd, lck, acc, eva, ldr, mor
var hp: int = 1
var mp: int = 0
var morale: int = 50
var fatigue: int = 0                 # reserved (Milestone 2)
var weapon_id: String = ""
var armor_def: int = 0
var armor_res: int = 0
var skills: Array[String] = []
var is_protagonist: bool = false
var is_commander: bool = false
var boss_phase_index: int = 0       # next phase to trigger; persisted with the battle
var move: int = 4
var jump: int = 1
var ctb: float = 0.0                 # time until next turn (Charge-Time system)
var has_moved: bool = false
var has_acted: bool = false
var statuses: Dictionary = {}        # reserved (Milestone 2)
var kills: int = 0
var kill_exp: int = 0                # EXP value of this unit's kills (statistic only; rewards are paid by PartyState)
var skill_mods: Dictionary = {}      # skill id -> power bonus percent (support sigils)
var reward: Dictionary = {}          # {"exp","ap","gold"} paid to the party when this enemy is defeated
var traits: Array[String] = []
var personality: Dictionary = {}       # transient tactical context copied from the campaign character sheet
var companion_bonds: Dictionary = {}   # other deployed companions keyed by character ID


func stat(key: String) -> int:
    return int(stats.get(key, 0))


func max_hp() -> int:
    return maxi(1, stat("hp"))


func is_alive() -> bool:
    return hp > 0


func effective_spd() -> float:
    var penalty := 0.9 if fatigue >= 50 else 1.0
    if statuses.has("chill"):
        penalty *= 0.8
    return maxf(1.0, float(stat("spd")) * penalty)


static func create(p_id: int, char_id: String, char_def: Dictionary, class_def: Dictionary, p_team: String, p_cell: Vector2i, p_facing: int) -> BattleUnit:
    var u := BattleUnit.new()
    u.id = p_id
    u.character_id = char_id
    u.display_name = str(char_def.get("name", char_id))
    u.team = p_team
    u.class_id = str(char_def.get("class_id", ""))
    u.level = int(char_def.get("level", 1))
    u.cell = p_cell
    u.facing = p_facing
    var s: Dictionary = char_def.get("stats", {})
    for key in s.keys():
        u.stats[str(key)] = int(s[key])
    u.hp = int(u.stats.get("hp", 1))
    u.mp = int(u.stats.get("mp", 0))
    u.morale = int(u.stats.get("mor", 50))
    u.weapon_id = str(char_def.get("weapon_id", ""))
    u.armor_def = int(char_def.get("armor_def", 0))
    u.armor_res = int(char_def.get("armor_res", 0))
    var sk: Array = char_def.get("skills", [])
    for x in sk:
        u.skills.append(str(x))
    u.move = int(class_def.get("move", 4))
    u.jump = int(class_def.get("jump", 1))
    u.skill_mods = (char_def.get("skill_mods", {}) as Dictionary).duplicate()
    u.reward = (char_def.get("reward", {}) as Dictionary).duplicate()
    for trait_id in char_def.get("traits", []):
        u.traits.append(str(trait_id))
    u.personality = (char_def.get("personality", {}) as Dictionary).duplicate(true)
    u.companion_bonds = (char_def.get("companion_bonds", {}) as Dictionary).duplicate(true)
    return u


func to_dict() -> Dictionary:
    return {
        "id": id, "character_id": character_id, "name": display_name, "team": team,
        "class_id": class_id, "level": level, "cell": [cell.x, cell.y], "facing": facing,
        "stats": stats.duplicate(), "hp": hp, "mp": mp, "morale": morale, "fatigue": fatigue,
        "weapon_id": weapon_id, "armor_def": armor_def, "armor_res": armor_res,
        "skills": skills.duplicate(), "is_protagonist": is_protagonist, "is_commander": is_commander, "boss_phase_index": boss_phase_index,
        "move": move, "jump": jump, "ctb": ctb, "has_moved": has_moved, "has_acted": has_acted,
        "statuses": statuses.duplicate(true), "kills": kills, "kill_exp": kill_exp,
        "skill_mods": skill_mods.duplicate(), "reward": reward.duplicate(),
        "traits": traits.duplicate(), "personality": personality.duplicate(true), "companion_bonds": companion_bonds.duplicate(true),
    }


static func from_dict(d: Dictionary) -> BattleUnit:
    var u := BattleUnit.new()
    u.id = int(d.get("id", 0))
    u.character_id = str(d.get("character_id", ""))
    u.display_name = str(d.get("name", ""))
    u.team = str(d.get("team", "enemy"))
    u.class_id = str(d.get("class_id", ""))
    u.level = int(d.get("level", 1))
    var c: Array = d.get("cell", [0, 0])
    u.cell = Vector2i(int(c[0]), int(c[1]))
    u.facing = int(d.get("facing", 0))
    var s: Dictionary = d.get("stats", {})
    for key in s.keys():
        u.stats[str(key)] = int(s[key])
    u.hp = int(d.get("hp", 1))
    u.mp = int(d.get("mp", 0))
    u.morale = int(d.get("morale", 50))
    u.fatigue = int(d.get("fatigue", 0))
    u.weapon_id = str(d.get("weapon_id", ""))
    u.armor_def = int(d.get("armor_def", 0))
    u.armor_res = int(d.get("armor_res", 0))
    var sk: Array = d.get("skills", [])
    for x in sk:
        u.skills.append(str(x))
    u.is_protagonist = bool(d.get("is_protagonist", false))
    u.is_commander = bool(d.get("is_commander", false))
    u.boss_phase_index = maxi(0, int(d.get("boss_phase_index", 0)))
    u.move = int(d.get("move", 4))
    u.jump = int(d.get("jump", 1))
    u.ctb = float(d.get("ctb", 0.0))
    u.has_moved = bool(d.get("has_moved", false))
    u.has_acted = bool(d.get("has_acted", false))
    var st: Dictionary = d.get("statuses", {})
    u.statuses = st.duplicate(true)
    u.kills = int(d.get("kills", 0))
    u.kill_exp = int(d.get("kill_exp", 0))
    u.skill_mods = (d.get("skill_mods", {}) as Dictionary).duplicate()
    u.reward = (d.get("reward", {}) as Dictionary).duplicate()
    for trait_id in d.get("traits", []):
        u.traits.append(str(trait_id))
    u.personality = (d.get("personality", {}) as Dictionary).duplicate(true)
    u.companion_bonds = (d.get("companion_bonds", {}) as Dictionary).duplicate(true)
    return u
