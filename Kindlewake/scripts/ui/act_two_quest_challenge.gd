extends Control
## Three offline Act II scenarios: boundary reconstruction, a testimony hearing and a tactical escort.
## Progress and consequences are saved in campaign world_flags. The escort uses the normal battle engine.

const ActTwoQuestSystem = preload("res://scripts/core/act_two_quest_system.gd")

const CHALLENGES := {
    "boundary_tree": {
        "title":"THE BOUNDARY TREE — Reconstruct the Line",
        "intro":"The old boundary tree lies split beside the coppice. Sela recognises three cuts in the stump; the tenants remember the stones, while the forester knows which paths were maintained.",
        "steps":[
            {"scene":"The stump has three old coppice cuts. What should be recorded first?","options":[["The age and direction of the cuts, without assigning ownership","right"],["The House steward's newest map as unquestionable truth","wrong"],["The nearest armed patrol's preferred boundary","wrong"]],"success":"Sela sketches the cuts and marks the uncertainty in the survey."},
            {"scene":"The tenant family points to foundation stones beneath the bracken. The forester says the stones mark a maintained path, not a property line. What is the useful next step?","options":[["Record both accounts and compare the stones with the coppice marks","right"],["Discard the tenant account because it is not written","wrong"],["Move the stones to make the map simpler","wrong"]],"success":"The stones and coppice marks establish an older shared-use boundary."},
            {"scene":"The steward's map places the tenant fields inside the House enclosure, but its ink is newer than the coppice cuts. Which conclusion is justified?","options":[["The map is evidence of a later claim, not proof of the original line","right"],["The newest document must always be correct","wrong"],["The forester alone can decide ownership","wrong"]],"success":"The company can now present a defensible record without pretending the evidence is perfect."},
            {"scene":"Choose the settlement to carry into the public hearing.","options":[["Create shared stewardship with tenant and forester witnesses","shared_stewardship"],["Order a temporary survey and postpone the final boundary","temporary_survey"]],"success":"The boundary record is witnessed and copied for the hearing."}
        ]
    },
    "orrowen_hearing": {
        "title":"THE ORROWEN HEARING — Four Incomplete Accounts",
        "intro":"A tenant, a forester, a House steward and a veteran have come to the hall. Their accounts overlap, but none can safely speak for everyone affected.",
        "steps":[
            {"scene":"The tenant says the levy was collected twice. The steward's account lists one payment, while the veteran remembers a second collection on a different road. What should be checked?","options":[["Compare dates, road locations and receipts before judging intent","right"],["Assume the tenant is lying because the steward has a seal","wrong"],["Treat the veteran's memory as a complete ledger","wrong"]],"success":"The dates show two collections, but not who authorised the second."},
            {"scene":"The forester confirms that the boundary path was used by both settlements. The House map excludes the path. What does this establish?","options":[["The map omits a shared-use practice that must be considered","right"],["The whole House claim is automatically void","wrong"],["The path belongs to whoever can guard it","wrong"]],"success":"The hearing records the difference between a legal map and lived use."},
            {"scene":"The veteran admits enforcing the second collection under an order he never saw signed. Which statement is fair?","options":[["The collection happened; the author and authority remain unproven","right"],["The veteran's admission proves the steward ordered it","wrong"],["The missing signature proves no order existed","wrong"]],"success":"The testimony is verified without inventing a culprit."},
            {"scene":"The tenant witness fears retaliation. Choose how to handle the verified record.","options":[["Protect the witness and keep identifying details sealed","protect_witness"],["Publish the verified record with names withheld","publish_verified_record"]],"success":"The hearing records both the verified facts and the limits placed on disclosure."}
        ]
    },
    "changed_escort": {
        "title":"THE ESCORT THAT CHANGED COURSE — Hold the Crossing",
        "intro":"A sealed writ orders the company to turn a supply train back. Sela spots children beneath the false banner. Wystan insists that sanctuary must be practical, not merely spoken.",
        "steps":[
            {"scene":"The narrow crossing is watched from the ridge. Which route keeps the families away from the exposed road?","options":[["Move civilians along the reed bank while the company screens the bridge","route_reeds"],["March the wagons and families together across the open ford","wrong"],["Send the civilians ahead without an escort","wrong"]],"success":"The families are moved behind the reed bank; the wagons remain covered."},
            {"scene":"Odran Vale's retainers are preparing to block the bridge. How should the company form?","options":[["Bram anchors the bridge while Sela covers the ridge and Wystan stays with civilians","formation_shield"],["Scatter the company across both banks","wrong"],["Leave the crossing to pursue the banner bearer","wrong"]],"success":"The company forms a defensive screen. The escort turns into a tactical fight."},
            {"scene":"Tactical encounter — defeat Writ-Captain Odran Vale. Keep the bridge approach open; protecting the families is the mission, not capturing a flag.","battle_id":"act2_changed_escort","battle_flag":"act2_escort_captain_defeated"},
            {"scene":"The writ is recovered. What will the company do with the families and the order?","options":[["Obey the writ and turn the families back","obey_writ"],["Grant sanctuary and accept the House's objection","grant_sanctuary"],["Negotiate temporary passage and accept a political debt","negotiate_passage"]],"success":"The crossing is secured and the decision is recorded."}
        ]
    }
}

var quest_id := ""
var step := 0
var mistakes := 0
var title_label: Label
var scene_label: Label
var progress_label: Label
var options_box: VBoxContainer
var feedback_label: Label

func _ready() -> void:
    quest_id = str(GameState.world_flags.get("_pending_act_two_challenge", ""))
    step = int(GameState.world_flags.get("_pending_act_two_challenge_step", 0))
    _build_ui()
    if not CHALLENGES.has(quest_id):
        _finish(false, "The Act II challenge could not be loaded.")
        return
    title_label.text = str(CHALLENGES[quest_id].title)
    scene_label.text = str(CHALLENGES[quest_id].intro)
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
        _finish(true, "Scenario complete. The consequences have been entered into the campaign chronicle.")
        return
    var data: Dictionary = steps[step]
    var battle_flag := str(data.get("battle_flag", ""))
    if battle_flag != "":
        if bool(GameState.world_flags.get(battle_flag, false)):
            step += 1
            GameState.world_flags["_pending_act_two_challenge_step"] = step
            GameState.save_campaign("auto_a")
            _show_step()
            return
        _launch_battle(str(data.get("battle_id", "")))
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

func _launch_battle(battle_id: String) -> void:
    var definition: Dictionary = GameData.battle_def(battle_id).duplicate(true)
    if definition.is_empty():
        feedback_label.text = "The tactical encounter could not be loaded."
        return
    GameState.world_flags["_pending_act_two_challenge"] = quest_id
    GameState.world_flags["_pending_act_two_challenge_step"] = step
    GameState.pending_battle = definition
    GameState.from_world = false
    GameState.save_campaign("auto_a")
    get_tree().change_scene_to_file("res://Main.tscn")

func _choose(result: String) -> void:
    if result == "wrong":
        mistakes += 1
        feedback_label.text = "That conclusion goes beyond the evidence or puts someone at unnecessary risk. Reconsider."
        progress_label.text = "STAGE %d / %d     MISSTEPS: %d" % [step + 1, CHALLENGES[quest_id].steps.size(), mistakes]
        return
    var flags: Dictionary = GameState.world_flags.duplicate(true)
    if result == "route_reeds":
        flags["act2_escort_route"] = "reed_bank"
    elif result == "formation_shield":
        flags["act2_escort_formation"] = "civilian_screen"
    elif result in ["shared_stewardship", "temporary_survey"]:
        var outcome: Dictionary = ActTwoQuestSystem.apply_boundary(flags, result)
        if not bool(outcome.get("ok", false)):
            feedback_label.text = str(outcome.get("reason", "The settlement could not be recorded."))
            return
        flags = outcome.world_flags
    elif result in ["protect_witness", "publish_verified_record"]:
        var outcome: Dictionary = ActTwoQuestSystem.apply_hearing(flags, result)
        if not bool(outcome.get("ok", false)):
            feedback_label.text = str(outcome.get("reason", "The hearing could not be recorded."))
            return
        flags = outcome.world_flags
    elif result in ["obey_writ", "grant_sanctuary", "negotiate_passage"]:
        var outcome: Dictionary = ActTwoQuestSystem.apply_escort(flags, result)
        if not bool(outcome.get("ok", false)):
            feedback_label.text = str(outcome.get("reason", "The escort decision could not be recorded."))
            return
        flags = outcome.world_flags
    GameState.world_flags = flags
    step += 1
    GameState.world_flags["_pending_act_two_challenge_step"] = step
    GameState.save_campaign("auto_a")
    feedback_label.text = str(CHALLENGES[quest_id].steps[step - 1].get("success", "The decision is recorded."))
    for child in options_box.get_children():
        options_box.remove_child(child)
        child.queue_free()
    var next := Button.new()
    next.text = "Continue"
    next.custom_minimum_size.y = 58
    next.pressed.connect(_show_step)
    options_box.add_child(next)

func _finish(success: bool, message: String) -> void:
    for child in options_box.get_children():
        options_box.remove_child(child)
        child.queue_free()
    scene_label.text = message
    feedback_label.text = "The campaign has been saved." if success else ""
    progress_label.text = "SCENARIO COMPLETE" if success else "CHALLENGE UNAVAILABLE"
    if success:
        GameState.world_flags.erase("_pending_act_two_challenge")
        GameState.world_flags.erase("_pending_act_two_challenge_step")
        GameState.save_campaign("auto_a")
    var back := Button.new()
    back.text = "Return to the region"
    back.custom_minimum_size.y = 64
    back.pressed.connect(func(): get_tree().change_scene_to_file("res://Location.tscn"))
    options_box.add_child(back)

func _leave() -> void:
    GameState.world_flags["_pending_act_two_challenge"] = quest_id
    GameState.world_flags["_pending_act_two_challenge_step"] = step
    GameState.save_campaign("auto_a")
    get_tree().change_scene_to_file("res://Location.tscn")
