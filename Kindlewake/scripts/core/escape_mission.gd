extends RefCounted
class_name EscapeMission
## Builds the authored first escape encounter from the canonical battle database.
## The source definition is deep-copied so the campaign's reusable battle data is never mutated.

const CLEAR_FLAG := "east_gallery_escaped"


static func build_battle(base_definition: Dictionary) -> Dictionary:
    if base_definition.is_empty():
        return {}
    var battle: Dictionary = base_definition.duplicate(true)
    battle["id"] = "east_gallery_escape"
    battle["title"] = "The Burning Courtyard"
    battle["briefing"] = "The east gallery is behind you. A knot of Covenant raiders has seized the courtyard gate while the manor burns around them. Break their line and bring the company through the postern. The household record and the people you chose to save are still with you."
    battle["victory_text"] = "The last raider falls back from the postern. Bram shoulders the gate open as rain and cold night air rush into the courtyard. The company has escaped Dunmarrow — but the Covenant now knows someone survived with the truth."
    battle["defeat_text"] = "The raiders drive the company back beneath the burning gallery. The postern remains within reach. Regroup and try the courtyard again."
    battle["world_flag_on_victory"] = CLEAR_FLAG
    battle.erase("reward_rune")
    battle["terrain"] = [
        "####################",
        "#....f.......f.....#",
        "#....f.......f.....#",
        "#..rrr.......rrr...#",
        "#..r...........r...#",
        "#..r..fff......r...#",
        "#..r..f.f......r...#",
        "#..r..fff......r...#",
        "#..r...........r...#",
        "#..rrrrrrrrrrrrr...#",
        "#..................#",
        "#....f.......f.....#",
        "#..................#",
        "####################"
    ]
    battle["heights"] = [
        "00000000000000000000",
        "00000000000000000000",
        "00000000000000000000",
        "00000000000000000000",
        "00000000000000000000",
        "00000000000000000000",
        "00000000000000000000",
        "00000000000000000000",
        "00000000000000000000",
        "00000000000000000000",
        "00000000000000000000",
        "00000000000000000000",
        "00000000000000000000",
        "00000000000000000000"
    ]
    battle["units"] = [
        {"character_id": "torren", "team": "player", "cell": [8, 10], "facing": 0, "protagonist": true},
        {"character_id": "bram", "team": "player", "cell": [7, 9], "facing": 0},
        {"character_id": "sela", "team": "player", "cell": [9, 10], "facing": 0},
        {"character_id": "brother_wystan", "team": "player", "cell": [6, 10], "facing": 0},
        {"character_id": "hask_gravelteeth", "team": "enemy", "cell": [10, 3], "facing": 2, "commander": true},
        {"character_id": "roadreaver", "team": "enemy", "cell": [8, 4], "facing": 2},
        {"character_id": "roadreaver", "team": "enemy", "cell": [12, 4], "facing": 2},
        {"character_id": "roadbowman", "team": "enemy", "cell": [10, 2], "facing": 2}
    ]
    return battle
