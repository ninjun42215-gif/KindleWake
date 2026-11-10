extends Control
const ActThreeQuestSystem = preload("res://scripts/core/act_three_quest_system.gd")
const CHALLENGES := {
 "three_bridges":{"title":"THREE BRIDGES — The River Road","intro":"Rain has swollen the river. The ford is exposed, the old bridge carries evacuees, and smoke rises from the downstream storehouse. Bram studies the bridge approaches; Sela has found a track through the reeds.","steps":[
  {"scene":"Choose the operation plan. Bram anchors the bridge while Sela scouts the reed track. The company must secure the ford, preserve the evacuation crossing and stop the storehouse fire.","options":[["Use Sela's reed-track report and keep Bram on the bridge","river_plan_balanced"],["Rush the ford and abandon the evacuation bridge","wrong"]]},
  {"scene":"Tactical operation — defeat the River Marshal and retainers. Secure the ford, keep the bridge approach open and protect the downstream storehouse.","battle_id":"act3_three_bridges","battle_flag":"act3_three_bridges_victory"},
  {"scene":"The operation is complete. Record the result and move to the reed-bank encounter.","options":[["Enter the river operation in the chronicle","record_bridges"]]}]},
 "banner_reeds":{"title":"THE BANNER IN THE REEDS — A False Standard","intro":"A hostile banner appears between the reed beds. Sela spots bare feet beneath the cloth and recognises a child's hand clutching the pole. The bearer is a deserter trying to draw pursuit away from civilians.","steps":[
  {"scene":"What is the first response?","options":[["Approach under truce and ask the deserter to lower the banner","approach_truce"],["Fire into the reeds before identifying the people","wrong"]]},
  {"scene":"Bram admits that an earlier retreat left a village behind after it was labelled enemy ground. He does not ask to be forgiven. What will the company do?","options":[["Protect the deserters and take testimony voluntarily","protect_deserters"],["Expose the banner deception to the pursuing command","expose_banner"],["Use the banner as leverage for a safe withdrawal","use_as_leverage"]]}]},
 "price_crossing":{"title":"THE PRICE OF A CROSSING — Who Goes First?","intro":"The road is open but narrow. A family cart has lost a wheel, two wounded soldiers need a litter, and the storehouse has only enough dry grain for one more convoy. Wystan asks that nobody be reduced to a tally.","steps":[
  {"scene":"The crossing can safely carry one priority convoy before the weather breaks. Choose where the first protected passage goes.","options":[["Evacuate the displaced families first","evacuate_families"],["Move the wounded soldiers first","prioritise_wounded"],["Protect the storehouse and secure the next supply convoy","protect_stores"]]}]}
}
var quest_id := ""
var step := 0
var title_label: Label
var scene_label: Label
var progress_label: Label
var options_box: VBoxContainer
var feedback_label: Label
func _ready() -> void:
 quest_id = str(GameState.world_flags.get("_pending_act_three_challenge", ""))
 step = int(GameState.world_flags.get("_pending_act_three_challenge_step", 0))
 _build_ui()
 if not CHALLENGES.has(quest_id):
  _finish(false, "The Act III challenge could not be loaded.")
  return
 title_label.text = str(CHALLENGES[quest_id].title)
 scene_label.text = str(CHALLENGES[quest_id].intro)
 _show_step()
func _build_ui() -> void:
 var bg := ColorRect.new()
 bg.color = Color(0.055,0.065,0.075,1.0)
 bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 add_child(bg)
 var margin := MarginContainer.new()
 margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 for pair in [["margin_left",34],["margin_right",34],["margin_top",28],["margin_bottom",28]]:
  margin.add_theme_constant_override(str(pair[0]),int(pair[1]))
 add_child(margin)
 var column := VBoxContainer.new()
 column.add_theme_constant_override("separation",16)
 margin.add_child(column)
 title_label = Label.new()
 title_label.add_theme_font_size_override("font_size",30)
 title_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
 column.add_child(title_label)
 progress_label = Label.new()
 progress_label.add_theme_font_size_override("font_size",18)
 column.add_child(progress_label)
 scene_label = Label.new()
 scene_label.custom_minimum_size.y = 150
 scene_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
 scene_label.add_theme_font_size_override("font_size",22)
 column.add_child(scene_label)
 feedback_label = Label.new()
 feedback_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
 feedback_label.add_theme_color_override("font_color",Color(0.75,0.86,0.72))
 column.add_child(feedback_label)
 options_box = VBoxContainer.new()
 options_box.add_theme_constant_override("separation",12)
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
  _finish(true,"Scenario complete. The river campaign record has been saved.")
  return
 var data: Dictionary = steps[step]
 if str(data.get("battle_flag","")) != "":
  if bool(GameState.world_flags.get(str(data.battle_flag),false)):
   step += 1
   GameState.world_flags["_pending_act_three_challenge_step"] = step
   GameState.save_campaign("auto_a")
   _show_step()
  else:
   _launch_battle(str(data.get("battle_id","")))
  return
 progress_label.text = "STAGE %d / %d" % [step+1,steps.size()]
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
  button.add_theme_font_size_override("font_size",18)
  button.pressed.connect(_choose.bind(str(entry[1])))
  options_box.add_child(button)
func _launch_battle(battle_id: String) -> void:
 var definition: Dictionary = GameData.battle_def(battle_id).duplicate(true)
 if definition.is_empty():
  feedback_label.text = "The tactical encounter could not be loaded."
  return
 GameState.world_flags["_pending_act_three_challenge"] = quest_id
 GameState.world_flags["_pending_act_three_challenge_step"] = step
 GameState.pending_battle = definition
 GameState.from_world = false
 GameState.save_campaign("auto_a")
 get_tree().change_scene_to_file("res://Main.tscn")
func _choose(result: String) -> void:
 if result == "wrong":
  feedback_label.text = "That choice risks people whose situation is not yet known. Reconsider."
  return
 var flags: Dictionary = GameState.world_flags.duplicate(true)
 if result == "river_plan_balanced":
  flags["act3_river_plan"] = "balanced"
 elif result == "approach_truce":
  flags["act3_banner_truce_attempted"] = true
 elif result == "record_bridges":
  var bridge: Dictionary = ActThreeQuestSystem.apply_bridges(flags)
  if not bool(bridge.get("ok",false)):
   feedback_label.text = str(bridge.get("reason","The operation cannot be recorded."))
   return
  flags = bridge.world_flags
 elif result in ["protect_deserters","expose_banner","use_as_leverage"]:
  var banner: Dictionary = ActThreeQuestSystem.apply_banner(flags,result)
  if not bool(banner.get("ok",false)):
   feedback_label.text = str(banner.get("reason","The banner decision cannot be recorded."))
   return
  flags = banner.world_flags
 elif result in ["evacuate_families","prioritise_wounded","protect_stores"]:
  var crossing: Dictionary = ActThreeQuestSystem.apply_crossing(flags,result)
  if not bool(crossing.get("ok",false)):
   feedback_label.text = str(crossing.get("reason","The allocation cannot be recorded."))
   return
  flags = crossing.world_flags
 GameState.world_flags = flags
 step += 1
 GameState.world_flags["_pending_act_three_challenge_step"] = step
 GameState.save_campaign("auto_a")
 feedback_label.text = "The decision and its consequences are recorded."
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
  GameState.world_flags.erase("_pending_act_three_challenge")
  GameState.world_flags.erase("_pending_act_three_challenge_step")
  GameState.save_campaign("auto_a")
 var back := Button.new()
 back.text = "Return to the region"
 back.custom_minimum_size.y = 64
 back.pressed.connect(func(): get_tree().change_scene_to_file("res://Location.tscn"))
 options_box.add_child(back)
func _leave() -> void:
 GameState.world_flags["_pending_act_three_challenge"] = quest_id
 GameState.world_flags["_pending_act_three_challenge_step"] = step
 GameState.save_campaign("auto_a")
 get_tree().change_scene_to_file("res://Location.tscn")
