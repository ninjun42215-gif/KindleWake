class_name NerisQuestSystem
extends RefCounted
## Pure, save-compatible rules for Neris Quell's second-beacon quest.

const MAREN_QUEST_FLAG := "maren_signal_completed"
const START_FLAG := "neris_beacon_started"
const PROGRESS_FLAG := "neris_beacon_progress"
const ATTEMPTS_FLAG := "neris_beacon_attempts"
const SOLVED_FLAG := "neris_beacon_solved"
const COMPLETE_FLAG := "neris_beacon_completed"
const ROUTE_SEQUENCE: Array[String] = ["east", "south", "east"]
const RelationshipSystem = preload("res://scripts/core/relationship_system.gd")


static func start_quest(flags: Dictionary, roster: Array) -> Dictionary:
    if not roster.has("neris_quell"):
        return {"ok": false, "reason": "Neris must join the company before she can chart the second beacon."}
    if not bool(flags.get(MAREN_QUEST_FLAG, false)):
        return {"ok": false, "reason": "Resolve Maren's Northstar quest before Neris reveals the hidden route."}
    if bool(flags.get(START_FLAG, false)):
        return {"ok": false, "reason": "Neris has already shared the second-beacon chart."}
    var updated: Dictionary = flags.duplicate(true)
    updated[START_FLAG] = true
    updated[PROGRESS_FLAG] = 0
    updated[ATTEMPTS_FLAG] = 0
    return {"ok": true, "world_flags": updated}


static func submit_route(flags: Dictionary, direction: String) -> Dictionary:
    if not bool(flags.get(START_FLAG, false)) or bool(flags.get(SOLVED_FLAG, false)):
        return {"ok": false, "reason": "The second-beacon route is not ready to be charted."}
    var updated: Dictionary = flags.duplicate(true)
    var progress := clampi(int(updated.get(PROGRESS_FLAG, 0)), 0, ROUTE_SEQUENCE.size() - 1)
    if direction != ROUTE_SEQUENCE[progress]:
        updated[PROGRESS_FLAG] = 0
        updated[ATTEMPTS_FLAG] = int(updated.get(ATTEMPTS_FLAG, 0)) + 1
        return {"ok": true, "correct": false, "complete": false, "world_flags": updated}
    progress += 1
    updated[PROGRESS_FLAG] = progress
    var complete := progress >= ROUTE_SEQUENCE.size()
    if complete:
        updated[SOLVED_FLAG] = true
    return {"ok": true, "correct": true, "complete": complete, "world_flags": updated}


static func resolve_quest(flags: Dictionary, choice: String) -> Dictionary:
    if not bool(flags.get(SOLVED_FLAG, false)) or bool(flags.get(COMPLETE_FLAG, false)):
        return {"ok": false, "reason": "Chart the three reef bearings before deciding who receives the route."}
    if not ["publish_route", "keep_private"].has(choice):
        return {"ok": false, "reason": "Unknown second-beacon route resolution."}
    var updated: Dictionary = flags.duplicate(true)
    updated[COMPLETE_FLAG] = true
    updated["neris_beacon_resolution"] = choice
    if choice == "publish_route":
        updated["neris_beacon_published"] = true
        updated["saltmere_trade_route_open"] = true
        return {"ok": true, "world_flags": updated, "gold": 100, "text": "The Tidebound Assembly receives the chart and opens a merchant passage through the shoals. The company is paid 100 gold for the route."}
    updated["neris_beacon_private"] = true
    updated["saltmere_fishers_route_open"] = true
    return {"ok": true, "world_flags": updated, "gold": 0, "text": "Neris keeps the chart with Saltmere's fishers. The hidden passage remains unlisted, but the coast's small boats can now travel safely."}


static func apply_relationships(state: Dictionary, leader_id: String, roster: Array, characters: Dictionary, choice: String) -> int:
    if leader_id.strip_edges() == "" or not ["publish_route", "keep_private"].has(choice):
        return 0
    var applied := 0
    for raw_character_id in roster:
        var character_id := str(raw_character_id)
        if character_id == "" or character_id == leader_id:
            continue
        var definition: Dictionary = characters.get(character_id, {})
        var recruit: Dictionary = definition.get("recruit", {})
        var authored: Dictionary = recruit.get("relationship_on_companion_quest", {})
        var reaction: Dictionary = authored.get(choice, {})
        for raw_dimension in reaction:
            var dimension := str(raw_dimension)
            var amount := int(reaction[raw_dimension])
            var evidence_id := "quest:neris-second-beacon:%s:%s:%s" % [choice, character_id, dimension]
            if RelationshipSystem.adjust(state, leader_id, character_id, dimension, amount, evidence_id):
                applied += 1
    return applied
