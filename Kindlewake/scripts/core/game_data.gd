extends Node

const CharacterSheetScript = preload("res://scripts/core/character_sheet.gd")
## Read-only content database (autoload "GameData"). Loads every local JSON file in res://data.
## No network, no external services. Content is data-driven so new heroes/maps cost data, not code.

const DATA_DIR := "res://data/"
## Listed explicitly (instead of scanning the folder) so it also works inside exported builds.
const BATTLE_FILES := ["battle_01", "battle_hollowroot", "battle_bell", "battle_catacombs", "battle_tideglass"]

var classes: Dictionary = {}
var terrain: Dictionary = {}
var weapons: Dictionary = {}
var skills: Dictionary = {}
var characters: Dictionary = {}
var items: Dictionary = {}
var item_rarities: Array = []
var runes: Dictionary = {}
var sigils: Dictionary = {}                # legacy alias; preserve existing saves
var encounters: Dictionary = {}
var shop: Dictionary = {}                # shop.json: stock lists and sell ratio
var start: Dictionary = {}               # campaign_start.json: starting party, gold, inventory
var locations: Dictionary = {}           # locations.json: town and interior maps
var character_creation: Dictionary = {}   # protagonist creator options and stat effects
var world: Dictionary = {}               # world.json: the Eldrimar regional overworld
var thalassar_world: Dictionary = {}     # thalassar_world.json: Brinegate Coast
var continents: Dictionary = {}          # continents.json: the seven-continent campaign atlas
var factions: Dictionary = {}            # factions.json: political powers and regional affiliations
var strategic_warfare: Dictionary = {}   # strategic_warfare.json: troop profiles, garrisons and siege engines
var battles: Dictionary = {}


func _ready() -> void:
    reload()


func reload() -> void:
    classes = _load_json("classes.json").get("classes", {})
    terrain = _load_json("terrain.json").get("terrain", {})
    weapons = _load_json("weapons.json").get("weapons", {})
    skills = _load_json("skills.json").get("skills", {})
    characters = _load_json("characters.json").get("characters", {})
    var item_data: Dictionary = _load_json("items.json")
    items = item_data.get("items", {})
    item_rarities = item_data.get("rarities", [])
    runes = _load_json("runes.json").get("runes", {})
    if runes.is_empty():
        runes = _load_json("sigils.json").get("sigils", {})
    sigils = runes
    encounters = _load_json("encounters.json")
    shop = _load_json("shop.json")
    start = _load_json("campaign_start.json")
    world = _load_json("world.json")
    thalassar_world = _load_json("thalassar_world.json")
    continents = _load_json("continents.json")
    factions = _load_json("factions.json")
    strategic_warfare = _load_json("strategic_warfare.json")
    locations = _load_json("locations.json")
    character_creation = _load_json("character_creation.json")
    battles.clear()
    for battle_file in BATTLE_FILES:
        var def: Dictionary = _load_json("battles/" + str(battle_file) + ".json")
        if def.has("id"):
            battles[str(def["id"])] = def


## Battle database. Every character is resolved through a CharacterSheet, so equipment (weapon, armor,
## stat bonuses) is already folded into the definitions the battle code reads.
func as_db() -> Dictionary:
    var db: Dictionary = {
        "classes": classes,
        "terrain": terrain,
        "weapons": weapons,
        "skills": skills,
        "items": items,
        "runes": runes,
        "sigils": runes,
    }
    var resolved: Dictionary = {}
    for k in characters.keys():
        var cid: String = str(k)
        var cdef: Dictionary = characters[k]
        resolved[cid] = CharacterSheetScript.from_def(cid, cdef).to_battle_def(db)
    db["characters"] = resolved
    return db


## The small database PartyState needs to pay rewards (classes for level-ups, items and sigils for bonuses).
func rules_db() -> Dictionary:
    return {"classes": classes, "items": items, "runes": runes, "sigils": runes}


## Everything the party screen needs to compute and describe gear, sigils and skills.
func party_db() -> Dictionary:
    return {"classes": classes, "weapons": weapons, "items": items, "runes": runes, "sigils": runes, "skills": skills}


func battle_def(battle_id: String) -> Dictionary:
    return battles.get(battle_id, {})


## Resolve the campaign region without mutating the canonical Eldrimar world data.
func world_for_region(region_id: String) -> Dictionary:
    return thalassar_world if region_id == "brinegate_coast" and not thalassar_world.is_empty() else world


func class_def(class_id: String) -> Dictionary:
    return classes.get(class_id, {})


func weapon_def(weapon_id: String) -> Dictionary:
    return weapons.get(weapon_id, {})


func item_def(item_id: String) -> Dictionary:
    return items.get(item_id, {})


func character_def(character_id: String) -> Dictionary:
    return characters.get(character_id, {})


func _load_json(rel_path: String) -> Dictionary:
    var path: String = DATA_DIR + rel_path
    if not FileAccess.file_exists(path):
        push_error("GameData: missing file " + path)
        return {}
    var file := FileAccess.open(path, FileAccess.READ)
    if file == null:
        push_error("GameData: cannot open " + path)
        return {}
    var parsed: Variant = JSON.parse_string(file.get_as_text())
    if typeof(parsed) != TYPE_DICTIONARY:
        push_error("GameData: invalid JSON in " + path)
        return {}
    return parsed
