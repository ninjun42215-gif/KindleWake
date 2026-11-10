extends Control
## Act V finale: route challenge, evidence conclave, three staged crises and final audience.
const System = preload("res://scripts/core/act_five_quest_system.gd")
var stage := 0
var title_label: Label
var body_label: Label
var buttons: VBoxContainer
var status_label: Label
func _ready() -> void:
 stage = int(GameState.world_flags.get("_pending_act_five_stage", 0))
 _build()
 _render()
func _build() -> void:
 var bg := ColorRect.new()
 bg.color = Color(0.045,0.055,0.075,1)
 bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 add_child(bg)
 var margin := MarginContainer.new()
 margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 margin.add_theme_constant_override("margin_left",32)
 margin.add_theme_constant_override("margin_right",32)
 margin.add_theme_constant_override("margin_top",28)
 margin.add_theme_constant_override("margin_bottom",28)
 add_child(margin)
 var col := VBoxContainer.new()
 col.add_theme_constant_override("separation",14)
 margin.add_child(col)
 title_label = Label.new()
 title_label.add_theme_font_size_override("font_size",30)
 title_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
 col.add_child(title_label)
 body_label = Label.new()
 body_label.custom_minimum_size.y = 210
 body_label.add_theme_font_size_override("font_size",21)
 body_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
 col.add_child(body_label)
 status_label = Label.new()
 status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
 col.add_child(status_label)
 buttons = VBoxContainer.new()
 buttons.add_theme_constant_override("separation",10)
 col.add_child(buttons)
 var spacer := Control.new()
 spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
 col.add_child(spacer)
func _render() -> void:
 for child in buttons.get_children():
  buttons.remove_child(child)
  child.queue_free()
 status_label.text = ""
 var f: Dictionary = GameState.world_flags
 if not bool(f.get("chapter_4_complete", false)):
  _end("The road is closed. Complete the Quillon witness decision first.")
  return
 if not bool(f.get("act5_route_chosen", false)):
  title_label.text = "THE ROAD TO AURELMONT"
  body_label.text = "Three roads lead to the capital. The River Compact offers ferries and civic support but costs time. The Veyrwood Canopy hides the company but consumes supplies. The Imperial Ash Road is fastest, but every gate remembers the Empire."
  _add("Take the River Compact", _choose_route.bind("river_compact"))
  _add("Take the Veyrwood Canopy", _choose_route.bind("veyrwood_canopy"))
  _add("Take the Imperial Ash Road", _choose_route.bind("imperial_ash_road"))
  return
 if bool(f.get("act5_route_action_required", false)):
  title_label.text = "THE ROAD'S PRICE"
  var route := str(f.get("act5_route", ""))
  body_label.text = "The chosen road demands a practical sacrifice. Decide how the company earns passage and what it leaves behind."
  if route == "river_compact":
   _add("Repair the ferry and delay the column", _route_action.bind("repair_ferry"))
   _add("Share rations to keep the convoy moving", _route_action.bind("share_rations"))
  elif route == "veyrwood_canopy":
   _add("Mark a safe trail for refugees", _route_action.bind("mark_safe_trail"))
   _add("Leave a supply cache for those following", _route_action.bind("leave_supply_cache"))
  else:
   _add("Negotiate passage with the gate wardens", _route_action.bind("negotiate_gate"))
   _add("Force the march and accept the political cost", _route_action.bind("march_at_cost"))
  return
 if not bool(f.get("act5_witness_conclave_complete", false)):
  title_label.text = "THE SEVEN WITNESSES"
  body_label.text = "Seven strands of evidence are placed before Aurelmont: the Sethmarch oath and road, Orrowen's boundary and hearing, the river evacuation, the Quillon record, Edmer's revision, the threat investigation and regional support. These are corroborating records and civic witnesses, not a demand that seven people risk their lives. A withdrawn account stays withdrawn."
  _add("Convene the evidence assembly", _convene)
  return
 var resolved := int(f.get("act5_fires_resolved", 0))
 if resolved < 3:
  var fire: String = str(System.FIRES[resolved])
  title_label.text = "THREE FIRES — %d / 3" % [resolved+1]
  if fire == "granary_fire":
   body_label.text = "Evidence corroboration: %d / 7 strands.\n\nThe granaries burn. Open them to feed the city and risk disorder, or save the grain stores and accept hunger through the night." % int(f.get("act5_evidence_count",0))
   _add("Open the granaries; feed the city", _resolve_fire.bind(fire,"open_granaries"))
   _add("Save the grain stores", _resolve_fire.bind(fire,"save_grain"))
  elif fire == "archive_fire":
   body_label.text = "Evidence corroboration: %d / 7 strands.\n\nFire reaches the record hall. Save the archive and its proof, or turn every hand toward the people trapped inside." % int(f.get("act5_evidence_count",0))
   _add("Carry the records to safety", _resolve_fire.bind(fire,"save_records"))
   _add("Rescue the people first", _resolve_fire.bind(fire,"save_people"))
  else:
   body_label.text = "Evidence corroboration: %d / 7 strands.\n\nThe river rises against the quays. Hold the bridge for the defenders or evacuate the waterfront before the flood takes it." % int(f.get("act5_evidence_count",0))
   _add("Hold the bridge", _resolve_fire.bind(fire,"hold_bridge"))
   _add("Evacuate the quays", _resolve_fire.bind(fire,"evacuate_quays"))
  return
 if not bool(f.get("chapter_5_complete", false)):
  title_label.text = "THE LAST AUDIENCE WITH MAELOR"
  body_label.text = "Maelor does not ask whether the Empire can survive. He asks whether its dissolution will leave anything strong enough to protect the people it once claimed. Your answers across five acts are now part of the record. Choose the Concord that can honestly follow."
  _add("Open Concord — broad local authority and public oversight", _audience.bind("open_concord"))
  _add("Guarded Concord — shared safeguards and cautious transition", _audience.bind("guarded_concord"))
  _add("Wounded Concord — peace secured after grave losses", _audience.bind("wounded_concord"))
  _add("Narrow Concord — a fragile compact with limited trust", _audience.bind("narrow_concord"))
  return
 title_label.text = "THE LAST EMPEROR"
 body_label.text = "The Empire is dissolved. The Concord of Free Realms stands, imperfect and answerable to those who must live beneath it. The Chronicle of Houses remains sealed until the founder's late-life epilogue and natural death."
 status_label.text = "Ending: " + str(f.get("act5_ending_profile",""))
 _add("Begin the founder's late-life epilogue", _begin_founder_epilogue)
 _add("Return to Aurelmont", _return_to_location)
func _add(label: String, callback: Callable) -> void:
 var b := Button.new()
 b.text = label
 b.custom_minimum_size.y = 58
 b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
 b.add_theme_font_size_override("font_size",17)
 b.pressed.connect(callback)
 buttons.add_child(b)
func _apply(result: Dictionary) -> bool:
 if not bool(result.get("ok",false)):
  status_label.text = str(result.get("reason","The choice could not be recorded."))
  return false
 GameState.world_flags = result.world_flags
 GameState.save_campaign("auto_a")
 status_label.text = str(result.get("text",""))
 return true
func _choose_route(route: String) -> void:
 if _apply(System.choose_route(GameState.world_flags,route)):
  _render()
func _route_action(action: String) -> void:
 if _apply(System.resolve_route_action(GameState.world_flags,action)):
  GameState.pending_location = "aurelmont"
  GameState.save_campaign("auto_a")
  _render()
func _convene() -> void:
 if _apply(System.evidence_board(GameState.world_flags)):
  _render()
func _resolve_fire(fire: String, response: String) -> void:
 if _apply(System.resolve_fire(GameState.world_flags,fire,response)):
  _render()
func _audience(decision: String) -> void:
 var result: Dictionary = System.resolve_audience(GameState.world_flags,decision)
 if not bool(result.get("ok",false)):
  status_label.text = str(result.get("reason","The final audience could not be recorded."))
  return
 var previous_flags: Dictionary = GameState.world_flags.duplicate(true)
 var previous_chronicle: Dictionary = GameState.chronicle_state.duplicate(true)
 GameState.world_flags = result.world_flags
 var milestones := ["campaign_completed","became_last_emperor","empire_dissolved"]
 for milestone in milestones:
  if bool(GameState.chronicle_state.get("milestones",{}).get(milestone,false)):
   continue
  if not GameState.record_chronicle_milestone(milestone):
   GameState.world_flags = previous_flags
   GameState.chronicle_state = previous_chronicle
   status_label.text = "The ending could not be committed to the founder chronology: " + milestone
   return
 status_label.text = str(result.get("text",""))
 GameState.save_campaign("auto_a")
 _render()
func _end(message: String) -> void:
 title_label.text = "THE KINDLING"
 body_label.text = message
 _add("Return", _return_to_location)
func _return_to_location() -> void:
 if GameState.pending_location == "":
  GameState.pending_location = "aurelmont"
 GameState.save_campaign("auto_a")
 get_tree().change_scene_to_file("res://Location.tscn")

func _begin_founder_epilogue() -> void:
 if not bool(GameState.world_flags.get("chapter_5_complete", false)) or not bool(GameState.chronicle_state.get("milestones", {}).get("empire_dissolved", false)):
  status_label.text = "The founder's epilogue remains sealed until the Empire is formally dissolved."
  return
 GameState.pending_location = ""
 GameState.save_campaign("auto_a")
 get_tree().change_scene_to_file("res://ChronicleEpilogue.tscn")
