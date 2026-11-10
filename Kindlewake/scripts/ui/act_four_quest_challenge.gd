extends Control
## Act IV investigation, custodian negotiation and optional archive breach encounter.
const ActFourQuestSystem = preload("res://scripts/core/act_four_quest_system.gd")
const CHALLENGES := {
 "quillon_archive":{"title":"THE QUILLON ARCHIVE","intro":"The archive doors are barred by law, not by a monster. Three custodians hold different keys: one guards the original, one protects the witness index, and one fears that publication will turn a careful record into a weapon.","steps":[
  {"scene":"Read the prior record. The Orrowen hearing verified testimony but did not prove who authorised the levy. Act III deserter testimony may corroborate the route of the writ; a protected witness is not a public exhibit.","options":[["Lay out the verified record and ask for a custodian hearing","archive_evidence"],["Demand the sealed clause immediately","archive_demand"]]},
  {"scene":"The custodians will hear a petition, accept mediation through the river coalition, or refuse all access. Choose how to proceed. A forced entry will damage the archive and trigger a tactical fight; it is not the default route.","options":[["Petition the custodians under the archive charter","custodian_petition"],["Ask the coalition to mediate and witness the process","coalition_mediation"],["Break the seal and force entry","forced_entry"]]},
  {"scene":"The Quillon Warden blocks the inner stacks. Defeat the commander to secure the breach. The fight is avoidable if the company reached agreement with the custodians.","battle_id":"act4_quillon_warden","battle_flag":"act4_archive_warden_defeated","optional_battle":true},
  {"scene":"The missing revision is recovered. The original can be preserved, a verified copy published, or the record entrusted to a coalition of custodians. Each protects one value while placing another at risk.","options":[["Preserve the original under seal","preserve_original"],["Publish a verified copy with protected names withheld","publish_verified_copy"],["Entrust the original and custody rules to the coalition","entrust_custodians"]]}]},
 "witness_recanted":{"title":"THE WITNESS WHO RECANTED","intro":"The witness from Orrowen has withdrawn their account. Their family has received threats. They are frightened, angry that the company arrived late, and unwilling to be turned into a symbol. Wystan insists the first question must be what they want.","steps":[
  {"scene":"A courier's route and a torn order suggest the threats came from men paid to watch the family's home. The witness asks that their withdrawal be respected. How will the company respond?","options":[["Honor the withdrawal; do not use the earlier testimony","honor_withdrawal"],["Offer a safe haven and let the family decide whether to move","offer_safe_haven"],["Investigate the threat without asking the witness to testify again","investigate_threat"]]},
  {"scene":"The company records the witness's choice and the threat separately. No testimony is treated as reaffirmed unless the witness later chooses that freely. The archive evidence stands on its own.","options":[["Enter the witness's decision in the chronicle","record_witness"]]}]}
}
var quest_id := ""
var step := 0
var title_label: Label
var scene_label: Label
var progress_label: Label
var options_box: VBoxContainer
var feedback_label: Label
func _ready() -> void:
 quest_id = str(GameState.world_flags.get("_pending_act_four_challenge", ""))
 step = int(GameState.world_flags.get("_pending_act_four_challenge_step", 0))
 _build_ui()
 if not CHALLENGES.has(quest_id):
  _finish(false, "The Act IV challenge could not be loaded.")
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
 scene_label.custom_minimum_size.y = 160
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
  _finish(true,"The Act IV record has been saved.")
  return
 var data: Dictionary = steps[step]
 if str(data.get("battle_flag","")) != "":
  if bool(GameState.world_flags.get(str(data.battle_flag),false)):
   step += 1
   GameState.world_flags["_pending_act_four_challenge_step"] = step
   GameState.save_campaign("auto_a")
   _show_step()
  elif bool(data.get("optional_battle",false)):
   _show_optional_battle_prompt(data)
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
func _show_optional_battle_prompt(data: Dictionary) -> void:
 progress_label.text = "OPTIONAL ENCOUNTER"
 scene_label.text = str(data.scene)
 feedback_label.text = "The custodians may still be approached through lawful channels. This encounter only follows the decision to force the seal."
 for child in options_box.get_children():
  child.queue_free()
 var fight := Button.new()
 fight.text = "Enter the stacks and face the Warden"
 fight.custom_minimum_size.y = 60
 fight.pressed.connect(_launch_battle.bind(str(data.battle_id)))
 options_box.add_child(fight)
 var bypass := Button.new()
 bypass.text = "Withdraw and continue with the recovered evidence"
 bypass.custom_minimum_size.y = 60
 bypass.pressed.connect(_skip_optional_battle)
 options_box.add_child(bypass)
func _skip_optional_battle() -> void:
 GameState.world_flags["act4_archive_warden_avoided"] = true
 step += 1
 GameState.world_flags["_pending_act_four_challenge_step"] = step
 GameState.save_campaign("auto_a")
 _show_step()
func _launch_battle(battle_id: String) -> void:
 var definition: Dictionary = GameData.battle_def(battle_id).duplicate(true)
 if definition.is_empty():
  feedback_label.text = "The tactical encounter could not be loaded."
  return
 GameState.world_flags["_pending_act_four_challenge"] = quest_id
 GameState.world_flags["_pending_act_four_challenge_step"] = step
 GameState.pending_battle = definition
 GameState.from_world = false
 GameState.save_campaign("auto_a")
 get_tree().change_scene_to_file("res://Main.tscn")
func _choose(result: String) -> void:
 if result == "archive_evidence":
  GameState.world_flags["act4_archive_evidence_presented"] = true
  GameState.world_flags["act4_verified_record_referenced"] = true
 elif result == "archive_demand":
  GameState.world_flags["act4_custodian_resistance_increased"] = true
 elif result == "record_witness":
  step += 1
  GameState.world_flags["_pending_act_four_challenge_step"] = step
  GameState.save_campaign("auto_a")
  _show_step()
  return
 elif result in ["custodian_petition","coalition_mediation","forced_entry"]:
  var access: Dictionary = ActFourQuestSystem.apply_archive_access(GameState.world_flags,result)
  if not bool(access.get("ok",false)):
   feedback_label.text = str(access.get("reason","The archive access route failed."))
   return
  GameState.world_flags = access.world_flags
 elif result in ["preserve_original","publish_verified_copy","entrust_custodians"]:
  var record: Dictionary = ActFourQuestSystem.apply_archive_record(GameState.world_flags,result)
  if not bool(record.get("ok",false)):
   feedback_label.text = str(record.get("reason","The record decision failed."))
   return
  GameState.world_flags = record.world_flags
 elif result in ["honor_withdrawal","offer_safe_haven","investigate_threat"]:
  var witness: Dictionary = ActFourQuestSystem.apply_witness(GameState.world_flags,result)
  if not bool(witness.get("ok",false)):
   feedback_label.text = str(witness.get("reason","The witness decision failed."))
   return
  GameState.world_flags = witness.world_flags
 GameState.world_flags["_pending_act_four_challenge"] = quest_id
 step += 1
 GameState.world_flags["_pending_act_four_challenge_step"] = step
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
  GameState.world_flags.erase("_pending_act_four_challenge")
  GameState.world_flags.erase("_pending_act_four_challenge_step")
  GameState.save_campaign("auto_a")
 var back := Button.new()
 back.text = "Return to the region"
 back.custom_minimum_size.y = 64
 back.pressed.connect(func(): get_tree().change_scene_to_file("res://Location.tscn"))
 options_box.add_child(back)
func _leave() -> void:
 GameState.world_flags["_pending_act_four_challenge"] = quest_id
 GameState.world_flags["_pending_act_four_challenge_step"] = step
 GameState.save_campaign("auto_a")
 get_tree().change_scene_to_file("res://Location.tscn")
