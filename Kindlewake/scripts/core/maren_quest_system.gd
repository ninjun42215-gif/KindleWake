class_name MarenQuestSystem
extends RefCounted
## Pure, save-compatible rules for Maren Vey's first personal quest.

const START_FLAG := "maren_signal_started"
const PROGRESS_FLAG := "maren_signal_progress"
const ATTEMPTS_FLAG := "maren_signal_attempts"
const SOLVED_FLAG := "maren_signal_solved"
const COMPLETE_FLAG := "maren_signal_completed"
const RelationshipSystem = preload("res://scripts/core/relationship_system.gd")
const SIGNAL_SEQUENCE: Array[String] = ["low", "high", "rising"]


static func start_quest(flags: Dictionary, roster: Array) -> Dictionary:
    if not roster.has("maren_vey"):
        return {"ok": false, "reason": "Maren must join the company before this personal quest can begin."}
    if not bool(flags.get("brinegate_ledger_decision", false)):
        return {"ok": false, "reason": "Settle the Tideglass ledger decision before asking Maren to revisit the Northstar."}
    if bool(flags.get(START_FLAG, false)):
        return {"ok": false, "reason": "Maren has already shared the Northstar's last sounding."}
    var updated: Dictionary = flags.duplicate(true)
    updated[START_FLAG] = true
    updated[PROGRESS_FLAG] = 0
    updated[ATTEMPTS_FLAG] = 0
    return {"ok": true, "world_flags": updated}


static func submit_signal(flags: Dictionary, tone: String) -> Dictionary:
    if not bool(flags.get(START_FLAG, false)) or bool(flags.get(SOLVED_FLAG, false)):
        return {"ok": false, "reason": "The old signal is not ready to be sounded."}
    var updated: Dictionary = flags.duplicate(true)
    var progress := clampi(int(updated.get(PROGRESS_FLAG, 0)), 0, SIGNAL_SEQUENCE.size() - 1)
    if tone != SIGNAL_SEQUENCE[progress]:
        updated[PROGRESS_FLAG] = 0
        updated[ATTEMPTS_FLAG] = int(updated.get(ATTEMPTS_FLAG, 0)) + 1
        return {"ok": true, "correct": false, "complete": false, "world_flags": updated}
    progress += 1
    updated[PROGRESS_FLAG] = progress
    var complete := progress >= SIGNAL_SEQUENCE.size()
    if complete:
        updated[SOLVED_FLAG] = true
    return {"ok": true, "correct": true, "complete": complete, "world_flags": updated}


static func resolve_quest(flags: Dictionary, choice: String) -> Dictionary:
    if not bool(flags.get(SOLVED_FLAG, false)) or bool(flags.get(COMPLETE_FLAG, false)):
        return {"ok": false, "reason": "Restore the Northstar signal before deciding what becomes of its log."}
    if not ["return_log", "publish_log"].has(choice):
        return {"ok": false, "reason": "Unknown Northstar log resolution."}
    var updated: Dictionary = flags.duplicate(true)
    updated[COMPLETE_FLAG] = true
    updated["maren_signal_resolution"] = choice
    if choice == "return_log":
        return {"ok": true, "world_flags": updated, "gold": 0, "text": "Maren folds the final page into her own chart case. The log will stay with the people who remember the Northstar, not become another Assembly exhibit."}
    updated["maren_signal_published"] = true
    return {"ok": true, "world_flags": updated, "gold": 75, "text": "Maren gives the last sounding to the beacon crews. The truth reaches every darkened tower, and the quay pays the company 75 gold for restoring the signal record."}


static func apply_relationships(state: Dictionary, leader_id: String, roster: Array, characters: Dictionary, choice: String) -> int:
    if leader_id.strip_edges() == "" or not ["return_log", "publish_log"].has(choice):
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
            var evidence_id := "quest:maren-signal:%s:%s:%s" % [choice, character_id, dimension]
            if RelationshipSystem.adjust(state, leader_id, character_id, dimension, amount, evidence_id):
                applied += 1
    return applied
