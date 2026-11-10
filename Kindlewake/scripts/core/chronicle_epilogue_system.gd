extends RefCounted
## Rules for the founder's authored late-life transition into Chronicle of Houses.
## This is a post-campaign epilogue, not a playable combat or instant-death shortcut.

const MINIMUM_NATURAL_DEATH_AGE := 70
const YEARS_PER_PASSAGE := 5
const REQUIRED_REFLECTIONS := ["the_people", "the_companions", "the_concord"]

static func new_state(protagonist_id: String, starting_age: int, ending_id: String) -> Dictionary:
	return {
		"version": 1,
		"protagonist_id": protagonist_id,
		"starting_age": maxi(16, starting_age),
		"current_age": maxi(16, starting_age),
		"ending_id": ending_id,
		"reflection_choices": {},
		"epilogue_completed": false,
		"natural_death_recorded": false
	}


static func normalize_state(raw: Dictionary) -> Dictionary:
	var clean := new_state(
		str(raw.get("protagonist_id", "")),
		int(raw.get("starting_age", 30)),
		str(raw.get("ending_id", ""))
	)
	clean["current_age"] = maxi(int(clean["starting_age"]), int(raw.get("current_age", clean["starting_age"])))
	var choices: Variant = raw.get("reflection_choices", {})
	if typeof(choices) == TYPE_DICTIONARY:
		for reflection in REQUIRED_REFLECTIONS:
			var choice := str(choices.get(reflection, ""))
			if choice != "":
				clean["reflection_choices"][reflection] = choice
	clean["epilogue_completed"] = bool(raw.get("epilogue_completed", false)) and all_reflections_complete(clean)
	clean["natural_death_recorded"] = bool(raw.get("natural_death_recorded", false)) and bool(clean["epilogue_completed"]) and int(clean["current_age"]) >= MINIMUM_NATURAL_DEATH_AGE
	return clean


static func all_reflections_complete(state: Dictionary) -> bool:
	var choices: Dictionary = state.get("reflection_choices", {})
	for reflection in REQUIRED_REFLECTIONS:
		if str(choices.get(reflection, "")) == "":
			return false
	return true


static func record_reflection(raw: Dictionary, reflection: String, choice: String, founder_gate: Dictionary) -> Dictionary:
	var state := normalize_state(raw)
	if not _founder_gate_ready(founder_gate):
		return {"ok": false, "reason": "The Concord cannot begin its founder's epilogue before the Empire is dissolved."}
	if not REQUIRED_REFLECTIONS.has(reflection) or choice.strip_edges() == "":
		return {"ok": false, "reason": "That reflection or response is not recognized."}
	if bool(state["epilogue_completed"]):
		return {"ok": false, "reason": "The founder's reflections have already been sealed."}
	state["reflection_choices"][reflection] = choice
	return {"ok": true, "state": state, "complete": all_reflections_complete(state)}


static func complete_epilogue(raw: Dictionary, founder_gate: Dictionary) -> Dictionary:
	var state := normalize_state(raw)
	if not _founder_gate_ready(founder_gate) or not all_reflections_complete(state):
		return {"ok": false, "reason": "All three reflections and the imperial dissolution are required."}
	state["epilogue_completed"] = true
	return {"ok": true, "state": state}


static func pass_years(raw: Dictionary, years: int, founder_gate: Dictionary) -> Dictionary:
	var state := normalize_state(raw)
	if not _founder_gate_ready(founder_gate) or not bool(state["epilogue_completed"]):
		return {"ok": false, "reason": "The late-life years begin only after the epilogue is complete."}
	if years != YEARS_PER_PASSAGE:
		return {"ok": false, "reason": "The chronicle advances in five-year passages."}
	if int(state["current_age"]) >= MINIMUM_NATURAL_DEATH_AGE:
		return {"ok": false, "reason": "The founder has reached the final season of life."}
	state["current_age"] = mini(MINIMUM_NATURAL_DEATH_AGE, int(state["current_age"]) + years)
	return {"ok": true, "state": state}


static func record_natural_death(raw: Dictionary, founder_gate: Dictionary, death_date: String = "") -> Dictionary:
	var state := normalize_state(raw)
	if not _founder_gate_ready(founder_gate) or not bool(state["epilogue_completed"]):
		return {"ok": false, "reason": "The founder's epilogue must be complete before death can be recorded."}
	if int(state["current_age"]) < MINIMUM_NATURAL_DEATH_AGE:
		return {"ok": false, "reason": "The founder has not reached the natural end of a long life."}
	if str(state["protagonist_id"]) == "":
		return {"ok": false, "reason": "A founder identity is required for the house chronicle."}
	state["natural_death_recorded"] = true
	var details := {
		"cause": "old_age",
		"protagonist_id": str(state["protagonist_id"]),
		"age_at_death": int(state["current_age"]),
		"death_date": death_date,
		"final_title": "Last Emperor",
		"ending_id": str(state["ending_id"])
	}
	return {"ok": true, "state": state, "founder_details": details}


static func _founder_gate_ready(gate: Dictionary) -> bool:
	var milestones: Dictionary = gate.get("milestones", {})
	return bool(milestones.get("campaign_completed", false)) and bool(milestones.get("became_last_emperor", false)) and bool(milestones.get("empire_dissolved", false)) and not bool(gate.get("unlocked", false))
