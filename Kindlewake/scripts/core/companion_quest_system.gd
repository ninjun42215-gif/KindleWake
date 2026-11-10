class_name CompanionQuestSystem
extends RefCounted
## Pure, data-driven progression rules for optional recruitable-ally questlines.
## The world/UI layer owns presentation; this class owns validated campaign state only.

const ACTIVE := "active"
const READY := "ready"
const COMPLETE := "complete"


static func normalize_state(raw_state: Dictionary, catalog: Dictionary) -> Dictionary:
	var normalized: Dictionary = {}
	var definitions: Dictionary = catalog.get("quests", {})
	for raw_id in raw_state.keys():
		var quest_id := str(raw_id)
		if not definitions.has(quest_id) or typeof(raw_state[raw_id]) != TYPE_DICTIONARY:
			continue
		var definition: Dictionary = definitions[quest_id]
		var milestones: Array = definition.get("milestones", [])
		var saved: Dictionary = raw_state[raw_id]
		var status := str(saved.get("status", ""))
		if status not in [ACTIVE, READY, COMPLETE]:
			continue
		var progress := clampi(int(saved.get("progress", 0)), 0, milestones.size())
		if status == READY and progress < milestones.size():
			status = ACTIVE
		elif status == ACTIVE and progress >= milestones.size():
			status = READY
		var choices: Dictionary = saved.get("choices", {}) if typeof(saved.get("choices", {})) == TYPE_DICTIONARY else {}
		var outcome := str(saved.get("outcome", ""))
		if status == COMPLETE and not (definition.get("outcomes", []) as Array).has(outcome):
			status = READY
			outcome = ""
		normalized[quest_id] = {
			"status": status,
			"progress": progress,
			"choices": choices.duplicate(true),
			"outcome": outcome
		}
	return normalized


static func start(state: Dictionary, quest_id: String, roster: Array, catalog: Dictionary) -> Dictionary:
	var definitions: Dictionary = catalog.get("quests", {})
	if not definitions.has(quest_id):
		return {"ok": false, "reason": "Unknown companion quest."}
	if state.has(quest_id):
		return {"ok": false, "reason": "This companion quest has already started."}
	var definition: Dictionary = definitions[quest_id]
	var companion_id := str(definition.get("companion_id", ""))
	if companion_id == "" or not roster.has(companion_id):
		return {"ok": false, "reason": "Recruit this companion before starting their personal quest."}
	if (definition.get("milestones", []) as Array).is_empty() or (definition.get("outcomes", []) as Array).is_empty():
		return {"ok": false, "reason": "This companion quest is not fully authored."}
	state[quest_id] = {"status": ACTIVE, "progress": 0, "choices": {}, "outcome": ""}
	return {"ok": true, "quest_id": quest_id, "progress": 0, "status": ACTIVE}


static func advance(state: Dictionary, quest_id: String, milestone_id: String, catalog: Dictionary) -> Dictionary:
	var definitions: Dictionary = catalog.get("quests", {})
	if not definitions.has(quest_id) or not state.has(quest_id):
		return {"ok": false, "reason": "This companion quest is not active."}
	var quest_state: Dictionary = state[quest_id]
	if str(quest_state.get("status", "")) != ACTIVE:
		return {"ok": false, "reason": "This companion quest is not awaiting another milestone."}
	var milestones: Array = definitions[quest_id].get("milestones", [])
	var progress := int(quest_state.get("progress", 0))
	if progress < 0 or progress >= milestones.size() or str(milestones[progress]) != milestone_id:
		return {"ok": false, "reason": "That milestone is not the next objective."}
	progress += 1
	quest_state["progress"] = progress
	quest_state["status"] = READY if progress == milestones.size() else ACTIVE
	state[quest_id] = quest_state
	return {"ok": true, "progress": progress, "status": str(quest_state["status"])}


static func resolve(state: Dictionary, quest_id: String, outcome: String, catalog: Dictionary) -> Dictionary:
	var definitions: Dictionary = catalog.get("quests", {})
	if not definitions.has(quest_id) or not state.has(quest_id):
		return {"ok": false, "reason": "This companion quest is not active."}
	var quest_state: Dictionary = state[quest_id]
	if str(quest_state.get("status", "")) != READY:
		return {"ok": false, "reason": "Complete the quest milestones before choosing its resolution."}
	var outcomes: Array = definitions[quest_id].get("outcomes", [])
	if not outcomes.has(outcome):
		return {"ok": false, "reason": "Unknown resolution for this companion quest."}
	quest_state["status"] = COMPLETE
	quest_state["outcome"] = outcome
	state[quest_id] = quest_state
	return {"ok": true, "status": COMPLETE, "outcome": outcome}


static func status(state: Dictionary, quest_id: String) -> String:
	if not state.has(quest_id):
		return "not_started"
	return str((state[quest_id] as Dictionary).get("status", "not_started"))
