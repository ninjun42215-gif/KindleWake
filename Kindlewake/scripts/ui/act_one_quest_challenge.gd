extends Control
## Five distinct, offline Act I quest challenges. Each challenge writes only validated
## campaign flags and returns to the town map; no network or external service is used.

var quest_id := ""
var step := 0
var mistakes := 0
var title_label: Label
var scene_label: Label
var progress_label: Label
var options_box: VBoxContainer
var feedback_label: Label

const OpeningActOneQuestSystem = preload("res://scripts/core/opening_act_one_quest_system.gd")
const CHALLENGES = OpeningActOneQuestSystem.CHALLENGES

func _ready() -> void:
    quest_id = str(GameState.world_flags.get("_pending_act_one_challenge", ""))
    GameState.world_flags.erase("_pending_act_one_challenge")
    step = int(GameState.world_flags.get("_pending_act_one_challenge_step", 0))
    GameState.world_flags.erase("_pending_act_one_challenge_step")
    _build_ui()
    if not CHALLENGES.has(quest_id):
        _finish(false, "The challenge could not be loaded.")
        return
    var data: Dictionary = CHALLENGES[quest_id]
    title_label.text = str(data.title)
    scene_label.text = str(data.intro)
    _show_step()

func _build_ui() -> void:
    var bg := ColorRect.new()
    bg.color = Color(0.055, 0.065, 0.075, 1.0)
    bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    add_child(bg)
    var margin := MarginContainer.new()
    margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    margin.add_theme_constant_override("margin_left", 34)
    margin.add_theme_constant_override("margin_right", 34)
    margin.add_theme_constant_override("margin_top", 28)
    margin.add_theme_constant_override("margin_bottom", 28)
    add_child(margin)
    var column := VBoxContainer.new()
    column.add_theme_constant_override("separation", 16)
    margin.add_child(column)
    title_label = Label.new()
    title_label.add_theme_font_size_override("font_size", 30)
    title_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    column.add_child(title_label)
    progress_label = Label.new()
    progress_label.add_theme_font_size_override("font_size", 18)
    column.add_child(progress_label)
    scene_label = Label.new()
    scene_label.custom_minimum_size.y = 150
    scene_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    scene_label.add_theme_font_size_override("font_size", 22)
    column.add_child(scene_label)
    feedback_label = Label.new()
    feedback_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    feedback_label.add_theme_color_override("font_color", Color(0.75, 0.86, 0.72))
    column.add_child(feedback_label)
    options_box = VBoxContainer.new()
    options_box.add_theme_constant_override("separation", 12)
    column.add_child(options_box)
    var spacer := Control.new()
    spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
    column.add_child(spacer)
    var leave := Button.new()
    leave.text = "Leave challenge"
    leave.custom_minimum_size.y = 56
    leave.pressed.connect(_leave)
    column.add_child(leave)

func _show_step() -> void:
    var steps: Array = CHALLENGES[quest_id].steps
    if step >= steps.size():
        _complete_quest()
        return
    var data: Dictionary = steps[step]
    var battle_flag := str(data.get("battle_flag", ""))
    if battle_flag != "":
        if bool(GameState.world_flags.get(battle_flag, false)):
            step += 1
            _show_step()
            return
        _launch_tactical_boss(str(data.get("battle_id", "")))
        return
    progress_label.text = "STAGE %d / %d     MISSTEPS: %d" % [step + 1, steps.size(), mistakes]
    scene_label.text = str(data.scene)
    feedback_label.text = ""
    for child in options_box.get_children():
        options_box.remove_child(child)
        child.queue_free()
    for option in data.options:
        var entry: Array = option
        var button := Button.new()
        button.text = str(entry[0])
        button.custom_minimum_size.y = 64
        button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        button.add_theme_font_size_override("font_size", 18)
        button.pressed.connect(_choose.bind(str(entry[1])))
        options_box.add_child(button)


func _launch_tactical_boss(battle_id: String) -> void:
    var definition: Dictionary = GameData.battle_def(battle_id).duplicate(true)
    if definition.is_empty():
        feedback_label.text = "The tactical encounter could not be loaded."
        return
    GameState.world_flags["_pending_act_one_challenge"] = quest_id
    GameState.world_flags["_pending_act_one_challenge_step"] = step
    GameState.pending_battle = definition
    GameState.from_world = false
    get_tree().change_scene_to_file("res://Main.tscn")

func _choose(result: String) -> void:
    if result == "wrong":
        mistakes += 1
        feedback_label.text = "That choice puts the crew at risk. Reconsider the evidence and try again."
        progress_label.text = "STAGE %d / %d     MISSTEPS: %d" % [step + 1, CHALLENGES[quest_id].steps.size(), mistakes]
        return
    if quest_id == "toll_book" and (result == "public" or result == "seal"):
        GameState.world_flags["toll_book_public"] = result == "public"
        GameState.world_flags["toll_book_sealed"] = result == "seal"
    if quest_id == "first_oath" and (result == "people" or result == "law"):
        GameState.world_flags["chapter_1_oath_choice"] = "oath_people" if result == "people" else "oath_law"
        GameState.world_flags["sethmarch_people_first"] = result == "people"
        GameState.world_flags["sethmarch_law_first"] = result == "law"
    var success_text := str(CHALLENGES[quest_id].steps[step].get("success", "The stage is complete."))
    feedback_label.text = success_text
    step += 1
    if step >= CHALLENGES[quest_id].steps.size():
        _complete_quest()
    else:
        var next_button := Button.new()
        next_button.text = "Continue"
        next_button.custom_minimum_size.y = 58
        next_button.pressed.connect(_show_step)
        for child in options_box.get_children():
            options_box.remove_child(child)
            child.queue_free()
        options_box.add_child(next_button)

func _complete_quest() -> void:
    match quest_id:
        "blocked_well":
            GameState.world_flags["kaer_well_blockage_cleared"] = true
            GameState.world_flags["kaer_well_water_safe"] = true
            GameState.world_flags["kaer_well_repaired"] = true
        "roof_before_banner":
            GameState.world_flags["kaer_roof_timber_salvaged"] = true
            GameState.world_flags["kaer_roof_secured"] = true
        "last_convoy":
            GameState.world_flags["last_convoy_resolved"] = true
            GameState.world_flags["last_convoy_manifest_found"] = true
            GameState.world_flags["last_convoy_supplies_secured"] = true
            GameState.world_flags["last_convoy_families_sheltered"] = true
            GameState.world_flags["last_convoy_boss_defeated"] = true
        "toll_book":
            GameState.world_flags["toll_book_reviewed"] = true
            GameState.world_flags["toll_book_evidence_authenticated"] = true
        "first_oath":
            GameState.world_flags["chapter_1_first_oath"] = true
            GameState.world_flags["chapter_1_complete"] = true
    GameState.save_campaign("auto_a")
    _finish(true, "Quest complete. Your decisions have been recorded in the campaign chronicle.")

func _finish(success: bool, message: String) -> void:
    for child in options_box.get_children():
        options_box.remove_child(child)
        child.queue_free()
    scene_label.text = message
    feedback_label.text = "The campaign has been saved." if success else ""
    progress_label.text = "QUEST COMPLETE" if success else "CHALLENGE UNAVAILABLE"
    var back := Button.new()
    back.text = "Return to Kaer Sethorn"
    back.custom_minimum_size.y = 64
    back.pressed.connect(func(): get_tree().change_scene_to_file("res://Location.tscn"))
    options_box.add_child(back)

func _leave() -> void:
    get_tree().change_scene_to_file("res://Location.tscn")
