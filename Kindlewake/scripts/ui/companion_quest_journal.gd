class_name CompanionQuestJournal
extends Control
## Player-facing journal for recruitable companions' personal questlines.
## The journal presents authored progression metadata; story scenes and objective triggers remain content integrations.

const PANEL_BG := Color(0.12, 0.105, 0.08, 0.98)
const PANEL_EDGE := Color(0.72, 0.55, 0.32)
const TEXT_MAIN := Color(0.94, 0.89, 0.74)
const TEXT_DIM := Color(0.72, 0.66, 0.54)
const GOLD := Color(1.0, 0.82, 0.35)

var panel: PanelContainer
var list: VBoxContainer
var heading: Label
var status_label: Label


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	_build()
	visible = false


func open() -> void:
	_refresh()
	visible = true


func close() -> void:
	visible = false


func _build() -> void:
	var shade := ColorRect.new()
	shade.color = Color(0.015, 0.012, 0.008, 0.72)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shade.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(shade)
	panel = PanelContainer.new()
	panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	panel.offset_left = -minf(440.0, get_viewport_rect().size.x * 0.46)
	panel.offset_right = minf(440.0, get_viewport_rect().size.x * 0.46)
	panel.offset_top = -minf(360.0, get_viewport_rect().size.y * 0.43)
	panel.offset_bottom = minf(360.0, get_viewport_rect().size.y * 0.43)
	var style := StyleBoxFlat.new()
	style.bg_color = PANEL_BG
	style.border_color = PANEL_EDGE
	style.set_border_width_all(2)
	style.set_corner_radius_all(12)
	style.set_content_margin_all(18)
	panel.add_theme_stylebox_override("panel", style)
	add_child(panel)
	var outer := VBoxContainer.new()
	outer.add_theme_constant_override("separation", 12)
	panel.add_child(outer)
	var top := HBoxContainer.new()
	heading = Label.new()
	heading.text = "COMPANION CHRONICLE"
	heading.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	heading.add_theme_font_size_override("font_size", 25)
	heading.add_theme_color_override("font_color", GOLD)
	top.add_child(heading)
	var close_button := Button.new()
	close_button.text = "Close"
	close_button.pressed.connect(close)
	top.add_child(close_button)
	outer.add_child(top)
	status_label = Label.new()
	status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	status_label.add_theme_color_override("font_color", TEXT_DIM)
	outer.add_child(status_label)
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.custom_minimum_size = Vector2(0, 300)
	list = VBoxContainer.new()
	list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	list.add_theme_constant_override("separation", 10)
	scroll.add_child(list)
	outer.add_child(scroll)


func _refresh() -> void:
	for child in list.get_children():
		list.remove_child(child)
		child.queue_free()
	var catalogue: Dictionary = GameData.companion_quests
	var roster: Array = GameState.party.roster
	var visible_count := 0
	var active_count := 0
	for quest_id in catalogue.keys():
		var definition: Dictionary = catalogue[quest_id]
		var companion_id := str(definition.get("companion_id", ""))
		if not roster.has(companion_id):
			continue
		visible_count += 1
		var quest_state: Dictionary = GameState.companion_quests.get(str(quest_id), {})
		var state := str(quest_state.get("status", "not_started"))
		if state in ["active", "ready"]:
			active_count += 1
		_add_quest_card(str(quest_id), definition, quest_state, state)
	status_label.text = "%d recruited companion quest%s available • %d in progress or awaiting resolution" % [visible_count, "" if visible_count == 1 else "s", active_count]
	if visible_count == 0:
		var empty := Label.new()
		empty.text = "No personal quest has been unlocked yet. Recruit an ally to discover the story they carry."
		empty.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		empty.add_theme_color_override("font_color", TEXT_DIM)
		list.add_child(empty)


func _add_quest_card(quest_id: String, definition: Dictionary, quest_state: Dictionary, state: String) -> void:
	var card := PanelContainer.new()
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.20, 0.17, 0.125)
	style.border_color = PANEL_EDGE.darkened(0.25)
	style.set_border_width_all(1)
	style.set_corner_radius_all(8)
	style.set_content_margin_all(12)
	card.add_theme_stylebox_override("panel", style)
	list.add_child(card)
	var body := VBoxContainer.new()
	body.add_theme_constant_override("separation", 5)
	card.add_child(body)
	var title := Label.new()
	var companion_name := str(GameData.characters.get(str(definition.get("companion_id", "")), {}).get("name", definition.get("companion_id", "Companion")))
	title.text = "%s — %s" % [companion_name, str(definition.get("title", "Personal Quest"))]
	title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	title.add_theme_font_size_override("font_size", 19)
	title.add_theme_color_override("font_color", TEXT_MAIN)
	body.add_child(title)
	var chapter := Label.new()
	chapter.text = "Chapter %s • %s" % [str(definition.get("chapter", "?")), str(definition.get("required_region", "unknown region")).replace("_", " ").capitalize()]
	chapter.add_theme_color_override("font_color", TEXT_DIM)
	body.add_child(chapter)
	var summary := Label.new()
	summary.text = str(definition.get("journal_summary", "A personal story waiting to be uncovered."))
	summary.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	summary.add_theme_color_override("font_color", TEXT_MAIN.darkened(0.12))
	body.add_child(summary)
	var milestones: Array = definition.get("milestones", [])
	var progress := int(quest_state.get("progress", 0))
	var progress_text := Label.new()
	if state == "not_started":
		progress_text.text = "Not started — begin when you are ready to hear %s's story." % companion_name
	elif state == "complete":
		progress_text.text = "Completed • Resolution: %s" % str(quest_state.get("outcome", "")).replace("_", " ").capitalize()
	else:
		progress_text.text = "Progress: %d / %d objectives" % [progress, milestones.size()]
		if state == "ready":
			progress_text.text += " • Ready for its concluding choice"
		elif progress < milestones.size():
			progress_text.text += "\nNext objective: %s" % str(milestones[progress]).replace("_", " ").capitalize()
	progress_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	progress_text.add_theme_color_override("font_color", GOLD if state == "ready" else TEXT_DIM)
	body.add_child(progress_text)
	if state == "not_started":
		var start_button := Button.new()
		start_button.text = "Begin personal quest"
		start_button.pressed.connect(_start_quest.bind(quest_id))
		body.add_child(start_button)


func _start_quest(quest_id: String) -> void:
	var result: Dictionary = GameState.start_companion_quest(quest_id)
	if not bool(result.get("ok", false)):
		status_label.text = str(result.get("reason", "This quest cannot begin yet."))
		return
	_refresh()
