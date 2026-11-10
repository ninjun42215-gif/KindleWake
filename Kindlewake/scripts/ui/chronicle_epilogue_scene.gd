extends Control
## Authored founder epilogue. The player chooses legacy, then advances five-year passages.
const Epilogue = preload("res://scripts/core/chronicle_epilogue_system.gd")
var state: Dictionary = {}
var title_label: Label
var body_label: Label
var status_label: Label
var choices: VBoxContainer

func _ready() -> void:
	var flags: Dictionary = GameState.world_flags
	if not bool(flags.get("chapter_5_complete", false)) or not GameState.chronicle_state.get("milestones", {}).get("empire_dissolved", false):
		_show_blocked()
		return
	var saved: Variant = flags.get("chronicle_epilogue_state", {})
	if typeof(saved) == TYPE_DICTIONARY and not saved.is_empty():
		state = Epilogue.normalize_state(saved)
	else:
		var ending := str(flags.get("act5_ending_profile", ""))
		state = Epilogue.new_state("torren", int(GameState.creation_profile.get("age", 30)), ending)
		_save()
	_build()
	_render()

func _build() -> void:
	var bg := ColorRect.new()
	bg.color = Color("#101820")
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 30)
	margin.add_theme_constant_override("margin_right", 30)
	margin.add_theme_constant_override("margin_top", 26)
	margin.add_theme_constant_override("margin_bottom", 26)
	add_child(margin)
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 16)
	margin.add_child(col)
	title_label = Label.new()
	title_label.add_theme_font_size_override("font_size", 30)
	title_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	col.add_child(title_label)
	body_label = Label.new()
	body_label.add_theme_font_size_override("font_size", 20)
	body_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	col.add_child(body_label)
	status_label = Label.new()
	status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	col.add_child(status_label)
	choices = VBoxContainer.new()
	choices.add_theme_constant_override("separation", 10)
	col.add_child(choices)

func _render() -> void:
	for child in choices.get_children():
		choices.remove_child(child)
		child.queue_free()
	var gate: Dictionary = GameState.chronicle_state
	if not bool(state.get("epilogue_completed", false)):
		var reflections: Dictionary = state.get("reflection_choices", {})
		title_label.text = "THE YEARS OF THE OPEN HAND"
		var missing: Array[String] = []
		for key in Epilogue.REQUIRED_REFLECTIONS:
			if not reflections.has(key):
				missing.append(key)
		if not reflections.has("the_people"):
			body_label.text = "The imperial seal has been broken. You remain the last Emperor in memory, but no longer in law. At Kaer Sethorn, the people ask what should endure when your office does not. What legacy will you leave them?"
			_add("The people: leave authority in local assemblies", _reflection.bind("the_people", "local_assemblies"))
		elif not reflections.has("the_companions"):
			body_label.text = "The companions gather without banners. Some are older, some have gone home, and some cannot forgive every choice. They ask what their service meant beyond victory."
			_add("The companions: preserve their names and honest disagreements", _reflection.bind("the_companions", "honest_remembrance"))
		else:
			body_label.text = "The Concord is young and imperfect. Its delegates ask what safeguard matters most when the founder is no longer present to settle disputes."
			_add("The Concord: require public review of every realm's obligations", _reflection.bind("the_concord", "public_review"))
		_add("Save and return to title", _return_title)
		status_label.text = "Founder age: %d. Reflections remaining: %d." % [int(state.current_age), missing.size()]
		return
	if not bool(state.get("natural_death_recorded", false)):
		title_label.text = "A QUIETER KIND OF YEARS"
		body_label.text = "The Concord no longer waits for your judgment. You may visit old friends, hear how the realms have changed, and let the years pass. This is a narrative time passage, not a combat encounter. The founder's chronicle cannot close before a long natural life has run its course."
		status_label.text = "Founder age: %d / %d" % [int(state.current_age), Epilogue.MINIMUM_NATURAL_DEATH_AGE]
		if int(state.current_age) < Epilogue.MINIMUM_NATURAL_DEATH_AGE:
			_add("Let five years pass", _advance_years)
		else:
			_add("Record the founder's natural passing", _natural_death)
		_add("Save and return to title", _return_title)
		return
	title_label.text = "THE FIRST LEAF IN THE CHRONICLE"
	body_label.text = "The founder's life is complete. The Empire was dissolved, the Concord remains answerable to its realms, and the old imperial seal is kept as a witness rather than a claim. The Chronicle of Houses is now open—not as a restoration of the Empire, but as the story of families learning to serve within the Free Realms."
	status_label.text = "Founder: %s • Age at death: %d • Ending: %s" % [str(state.protagonist_id), int(state.current_age), str(state.ending_id)]
	_add("Begin Chronicle of Houses", _begin_chronicle)
	_add("Return to title", _return_title)

func _reflection(key: String, choice: String) -> void:
	var result := Epilogue.record_reflection(state, key, choice, GameState.chronicle_state)
	if not bool(result.ok):
		status_label.text = str(result.reason)
		return
	state = result.state
	if bool(result.complete):
		var completed := Epilogue.complete_epilogue(state, GameState.chronicle_state)
		if bool(completed.ok):
			state = completed.state
			GameState.record_chronicle_milestone("epilogue_completed")
	_save()
	_render()

func _advance_years() -> void:
	var result := Epilogue.pass_years(state, Epilogue.YEARS_PER_PASSAGE, GameState.chronicle_state)
	if bool(result.ok):
		state = result.state
	_save()
	_render()

func _natural_death() -> void:
	var result := Epilogue.record_natural_death(state, GameState.chronicle_state, Time.get_datetime_string_from_system(false, true))
	if not bool(result.ok):
		status_label.text = str(result.reason)
		return
	state = result.state
	if not GameState.record_chronicle_milestone("natural_old_age_death", result.founder_details):
		status_label.text = "The founder record was rejected by the Chronicle gate. Your save remains recoverable."
		return
	_save()
	_render()

func _save() -> void:
	GameState.world_flags["chronicle_epilogue_state"] = state.duplicate(true)
	GameState.save_campaign("auto_a")

func _add(label: String, callback: Callable) -> void:
	var button := Button.new()
	button.text = label
	button.custom_minimum_size.y = 58
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.add_theme_font_size_override("font_size", 18)
	button.pressed.connect(callback)
	choices.add_child(button)

func _return_title() -> void:
	_save()
	get_tree().change_scene_to_file("res://TitleScreen.tscn")

func _show_blocked() -> void:
	var label := Label.new()
	label.text = "The founder's epilogue is not available. Complete the five-act campaign and formally dissolve the Empire first."
	label.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	add_child(label)
	var button := Button.new()
	button.text = "Return to title"
	button.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM)
	button.pressed.connect(func(): get_tree().change_scene_to_file("res://TitleScreen.tscn"))
	add_child(button)

func _begin_chronicle() -> void:
	if not GameState.chronicle_unlocked():
		status_label.text = "The Chronicle remains sealed until the founder's natural death is recorded."
		return
	_save()
	get_tree().change_scene_to_file("res://ChronicleHouse.tscn")
