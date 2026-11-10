extends Control
## First playable Chronicle of Houses interface. All state is offline and rules-driven.
const Dynasty = preload("res://scripts/core/chronicle_dynasty_system.gd")
const Politics = preload("res://scripts/core/chronicle_diplomacy_system.gd")
var state: Dictionary = {}
var selected_person := "heir_1"
var summary: Label
var members_box: VBoxContainer
var parent_picker: OptionButton
var child_name: LineEdit
var child_age: SpinBox
var member_name: LineEdit
var member_age: SpinBox
var spouse_a: OptionButton
var spouse_b: OptionButton
var trait_picker: OptionButton
var title_picker: OptionButton
var policy_picker: OptionButton
var title_rank_picker: OptionButton
var title_name: LineEdit
var domain_name: LineEdit
var domain_picker: OptionButton
var guardian_picker: OptionButton
var adoptive_parent_picker: OptionButton
var education_picker: OptionButton
var council_role_picker: OptionButton
var claim_title_picker: OptionButton
var claim_basis_picker: OptionButton
var diplomacy_target_picker: OptionButton
var diplomacy_summary: Label
var status: Label

func _ready() -> void:
 if not GameState.chronicle_unlocked():
  _blocked()
  return
 var saved: Variant = GameState.world_flags.get("chronicle_house_state",{})
 if typeof(saved) == TYPE_DICTIONARY and not saved.is_empty():
  state = Dynasty.normalize_state(saved)
 else:
  var founder: Dictionary = GameState.chronicle_state.get("founder_record",{})
  state = Dynasty.new_house(founder,str(GameState.creation_profile.get("name","The Founder")))
  if state.is_empty():
   _blocked()
   return
  _save()
 state = Politics.initialize(state)
 _save()
 _build()
 _refresh()

func _build() -> void:
 var bg := ColorRect.new()
 bg.color = Color("#101820")
 bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 add_child(bg)
 var scroll := ScrollContainer.new()
 scroll.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 scroll.offset_left = 18
 scroll.offset_right = -18
 scroll.offset_top = 16
 scroll.offset_bottom = -16
 add_child(scroll)
 var col := VBoxContainer.new()
 col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
 col.add_theme_constant_override("separation",12)
 scroll.add_child(col)
 var heading := Label.new()
 heading.text = "CHRONICLE OF HOUSES"
 heading.add_theme_font_size_override("font_size",30)
 heading.add_theme_color_override("font_color",Color("#e4c58a"))
 col.add_child(heading)
 summary = Label.new()
 summary.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
 col.add_child(summary)
 _section(col,"THE FAMILY")
 members_box = VBoxContainer.new()
 col.add_child(members_box)
 _section(col,"RECORD A CHILD")
 parent_picker = OptionButton.new()
 col.add_child(parent_picker)
 child_name = LineEdit.new()
 child_name.placeholder_text = "Child's name"
 col.add_child(child_name)
 child_age = SpinBox.new()
 child_age.min_value = 0
 child_age.max_value = 60
 child_age.value = 1
 child_age.prefix = "Age "
 col.add_child(child_age)
 col.add_child(_button("Record child",_add_child))
 _section(col,"MARRIAGE AND HOUSEHOLD")
 spouse_a = OptionButton.new()
 spouse_b = OptionButton.new()
 col.add_child(spouse_a)
 col.add_child(spouse_b)
 col.add_child(_button("Record marriage",_marry))
 member_name = LineEdit.new()
 member_name.placeholder_text = "Unrelated adult / prospective spouse"
 col.add_child(member_name)
 member_age = SpinBox.new()
 member_age.min_value = 18
 member_age.max_value = 80
 member_age.value = 25
 member_age.prefix = "Age "
 col.add_child(member_age)
 col.add_child(_button("Record an allied adult",_add_member))
 _section(col,"CHARACTER TRAITS")
 trait_picker = OptionButton.new()
 for trait_id in Dynasty.TRAITS.keys():
  trait_picker.add_item(str(trait_id).replace("_"," ").capitalize())
 if trait_picker.item_count > 0:
  trait_picker.select(0)
 col.add_child(trait_picker)
 col.add_child(_button("Add selected trait",_add_trait))
 col.add_child(_button("Remove selected trait",_remove_trait))
 _section(col,"TITLES AND SUCCESSION")
 title_picker = OptionButton.new()
 col.add_child(title_picker)
 col.add_child(_button("Grant title to selected family member",_grant_title))
 title_rank_picker = OptionButton.new()
 for rank in Dynasty.RANKS:
  title_rank_picker.add_item(str(rank.name))
 if title_rank_picker.item_count > 0:
  title_rank_picker.select(0)
 col.add_child(title_rank_picker)
 title_name = LineEdit.new()
 title_name.placeholder_text = "New title name"
 col.add_child(title_name)
 col.add_child(_button("Establish next rank title",_create_title))
 domain_name = LineEdit.new()
 domain_name.placeholder_text = "New holding name"
 col.add_child(domain_name)
 col.add_child(_button("Found a new holding for selected member",_create_domain))
 domain_picker = OptionButton.new()
 col.add_child(domain_picker)
 policy_picker = OptionButton.new()
 for policy in Dynasty.SUCCESSION_POLICIES:
  policy_picker.add_item(str(policy).replace("_"," ").capitalize())
 if policy_picker.item_count > 0:
  policy_picker.select(0)
 col.add_child(policy_picker)
 col.add_child(_button("Set succession law",_set_policy))
 _section(col,"EDUCATION AND GUARDIANSHIP")
 guardian_picker = OptionButton.new()
 col.add_child(guardian_picker)
 col.add_child(_button("Appoint guardian to selected child",_assign_guardian))
 education_picker = OptionButton.new()
 for focus in Dynasty.EDUCATION_FOCUSES:
  education_picker.add_item(str(focus).capitalize())
 if education_picker.item_count > 0:
  education_picker.select(0)
 col.add_child(education_picker)
 col.add_child(_button("Begin selected education focus",_assign_education))
 col.add_child(_button("Complete education at age 16+",_complete_education))
 _section(col,"ADOPTION")
 adoptive_parent_picker = OptionButton.new()
 col.add_child(adoptive_parent_picker)
 col.add_child(_button("Record adoption for selected child",_adopt))
 _section(col,"HOUSEHOLD COUNCIL")
 council_role_picker = OptionButton.new()
 for role in Dynasty.COUNCIL_ROLES:
  council_role_picker.add_item(str(role).replace("_"," ").capitalize())
 if council_role_picker.item_count > 0:
  council_role_picker.select(0)
 col.add_child(council_role_picker)
 col.add_child(_button("Appoint selected person to council",_appoint_council))
 _section(col,"TITLE CLAIMS")
 claim_title_picker = OptionButton.new()
 col.add_child(claim_title_picker)
 claim_basis_picker = OptionButton.new()
 for basis in ["inheritance","grant","service"]:
  claim_basis_picker.add_item(str(basis).capitalize())
 if claim_basis_picker.item_count > 0:
  claim_basis_picker.select(0)
 col.add_child(claim_basis_picker)
 col.add_child(_button("Record title claim for selected person",_record_claim))
 col.add_child(_button("Recognize claim",_recognize_claim))
 col.add_child(_button("Reject claim",_reject_claim))
 _section(col,"INTER-HOUSE DIPLOMACY")
 diplomacy_summary = Label.new()
 diplomacy_summary.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
 col.add_child(diplomacy_summary)
 diplomacy_target_picker = OptionButton.new()
 col.add_child(diplomacy_target_picker)
 col.add_child(_button("Send envoy (-5 influence, +8 relation)",_diplomacy_envoy))
 col.add_child(_button("Offer public gift (-3 influence, +12 relation)",_diplomacy_gift))
 col.add_child(_button("Propose alliance",_diplomacy_alliance))
 col.add_child(_button("Declare feud",_diplomacy_feud))
 col.add_child(_button("Reconcile feud",_diplomacy_reconcile))
 col.add_child(_button("Break alliance",_diplomacy_break))
 _section(col,"DOMAIN STEWARDSHIP")
 col.add_child(_button("Improve food stores (+5)",_domain_food))
 col.add_child(_button("Improve security (+5)",_domain_security))
 col.add_child(_button("Improve prosperity (+5)",_domain_prosperity))
 _section(col,"PASSAGE OF YEARS")
 col.add_child(_button("Advance one year",_advance_year))
 col.add_child(_button("Save Chronicle",_save))
 status = Label.new()
 status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
 status.add_theme_color_override("font_color",Color("#d3b77d"))
 col.add_child(status)
 col.add_child(_button("Return to title",_return_title))

func _diplomacy_overview(player_house: String) -> String:
 var lines: Array[String] = []
 for house_id in state.get("politics",{}).get("houses",{}).keys():
  if str(house_id) == player_house:
   continue
  var house: Dictionary = state.politics.houses[house_id]
  var relation: Dictionary = Politics.relation_between(state,player_house,str(house_id))
  lines.append("%s: %s (%d)%s" % [str(house.get("name",house_id)),Politics.relation_state(relation),int(relation.get("score",0))," • alliance" if bool(relation.get("allied",false)) else ""])
 return "\\n".join(lines)

func _diplomacy_target() -> String:
 if diplomacy_target_picker.item_count == 0 or diplomacy_target_picker.selected < 0:
  return ""
 return str(diplomacy_target_picker.get_item_metadata(diplomacy_target_picker.selected))

func _diplomacy_action(action: String) -> void:
 var target := _diplomacy_target()
 if target.is_empty():
  status.text = "No rival house is available for diplomacy."
  return
 var player_house := str(state.get("politics",{}).get("player_house","player_house"))
 var result := Politics.perform_action(state,player_house,target,action)
 if not bool(result.get("ok",false)):
  status.text = str(result.get("reason","Diplomatic action rejected."))
  return
 state = result.state
 _save()
 _refresh()
 status.text = "Diplomatic action recorded: %s." % action.replace("_"," ")

func _diplomacy_envoy() -> void:
 _diplomacy_action("envoy")

func _diplomacy_gift() -> void:
 _diplomacy_action("gift")

func _diplomacy_alliance() -> void:
 _diplomacy_action("propose_alliance")

func _diplomacy_feud() -> void:
 _diplomacy_action("declare_feud")

func _diplomacy_reconcile() -> void:
 _diplomacy_action("reconcile")

func _diplomacy_break() -> void:
 _diplomacy_action("break_alliance")

func _section(parent: VBoxContainer, text_value: String) -> void:
 var label := Label.new()
 label.text = text_value
 label.add_theme_font_size_override("font_size",21)
 label.add_theme_color_override("font_color",Color("#c09b5e"))
 parent.add_child(label)
 parent.add_child(HSeparator.new())

func _button(text_value: String, callback: Callable) -> Button:
 var button := Button.new()
 button.text = text_value
 button.custom_minimum_size.y = 50
 button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
 button.pressed.connect(callback)
 return button

func _refresh() -> void:
 var domain_lines: Array[String] = []
 for domain_id in state.domains.keys():
  var domain: Dictionary = state.domains[domain_id]
  domain_lines.append("%s — food %d / security %d / prosperity %d / legitimacy %d" % [str(domain.name),int(domain.food),int(domain.security),int(domain.prosperity),int(domain.legitimacy)])
 var council_lines: Array[String] = []
 for role in state.get("council",{}).keys():
  var council_id := str(state.council[role])
  council_lines.append("%s: %s" % [str(role).replace("_"," ").capitalize(),str(state.people.get(council_id,{}).get("name","Vacant"))])
 var recent_events: Array[String] = []
 var log: Array = state.get("chronicle",[])
 for event in log.slice(maxi(0,log.size()-4),log.size()):
  recent_events.append("Year %d: %s" % [int(event.get("year",0)),str(event.get("event","event")).replace("_"," ")])
 summary.text = "%s • Year %d • Law: %s\nThe Concord recognises titles as duties under review, not a claim to imperial sovereignty.\nCouncil: %s\n%s\nRecent record: %s" % [str(state.house_name),int(state.year),str(state.succession_policy).replace("_"," ").capitalize()," • ".join(council_lines) if not council_lines.is_empty() else "no appointments","\n".join(domain_lines)," • ".join(recent_events)]
 for child in members_box.get_children():
  members_box.remove_child(child)
  child.queue_free()
 var ids: Array = state.people.keys()
 ids.sort()
 for id in ids:
  var person: Dictionary = state.people[id]
  var button := Button.new()
  button.text = Dynasty.person_summary(person)
  button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
  button.custom_minimum_size.y = 54
  button.add_theme_font_size_override("font_size",15)
  button.pressed.connect(_select_person.bind(str(id)))
  members_box.add_child(button)
 _fill_people_picker(parent_picker,true)
 _fill_people_picker(spouse_a,false)
 _fill_people_picker(spouse_b,false)
 _fill_people_picker(guardian_picker,true)
 _fill_people_picker(adoptive_parent_picker,true)
 title_picker.clear()
 for title_id in state.titles.keys():
  title_picker.add_item(str(state.titles[title_id].get("name",title_id)))
  title_picker.set_item_metadata(title_picker.item_count-1,str(title_id))
 if title_picker.item_count > 0:
  title_picker.select(0)
 claim_title_picker.clear()
 for claim_title_id in state.titles.keys():
  claim_title_picker.add_item(str(state.titles[claim_title_id].get("name",claim_title_id)))
  claim_title_picker.set_item_metadata(claim_title_picker.item_count-1,str(claim_title_id))
 if claim_title_picker.item_count > 0:
  claim_title_picker.select(0)
 domain_picker.clear()
 for domain_id in state.domains.keys():
  domain_picker.add_item(str(state.domains[domain_id].get("name",domain_id)))
  domain_picker.set_item_metadata(domain_picker.item_count-1,str(domain_id))
 if domain_picker.item_count > 0:
  domain_picker.select(0)
 var politics: Dictionary = state.get("politics",{})
 var player_house := str(politics.get("player_house","player_house"))
 diplomacy_summary.text = "Influence: %d • Reputation: %d • Political year: %d\\n%s" % [int(politics.get("influence",0)),int(politics.get("reputation",0)),int(politics.get("year",state.year)),_diplomacy_overview(player_house)]
 diplomacy_target_picker.clear()
 var house_ids: Array = politics.get("houses",{}).keys()
 house_ids.sort()
 for house_id in house_ids:
  if str(house_id) == player_house:
   continue
  var house: Dictionary = politics.houses[house_id]
  var relation: Dictionary = Politics.relation_between(state,player_house,str(house_id))
  diplomacy_target_picker.add_item("%s — %s (%d)" % [str(house.get("name",house_id)),Politics.relation_state(relation),int(relation.get("score",0))])
  diplomacy_target_picker.set_item_metadata(diplomacy_target_picker.item_count-1,str(house_id))
 status.text = "Selected: %s. Kinship, titles and yearly events are preserved in this house chronicle." % str(state.people.get(selected_person,{}).get("name","None"))

func _fill_people_picker(picker: OptionButton, living_only: bool) -> void:
 picker.clear()
 var ids: Array = state.people.keys()
 ids.sort()
 var selected_index := 0
 for id in ids:
  var person: Dictionary = state.people[id]
  if living_only and not bool(person.alive):
   continue
  picker.add_item("%s (age %d)" % [str(person.name),int(person.age)])
  picker.set_item_metadata(picker.item_count-1,str(id))
  if str(id) == selected_person:
   selected_index = picker.item_count-1
 if picker.item_count > 0:
  picker.select(selected_index)

func _selected_id(picker: OptionButton) -> String:
 if picker.item_count == 0 or picker.selected < 0:
  return ""
 return str(picker.get_item_metadata(picker.selected))

func _select_person(id: String) -> void:
 selected_person = id
 _refresh()

func _add_child() -> void:
 var result := Dynasty.add_child(state,_selected_id(parent_picker),child_name.text,int(child_age.value),[])
 if not bool(result.get("ok",false)):
  status.text = str(result.get("reason","Child record rejected."))
  return
 state = result.state
 selected_person = str(result.person_id)
 child_name.clear()
 _save()
 _refresh()
 status.text = "Child recorded in the family tree."

func _add_member() -> void:
 var result := Dynasty.add_house_member(state,member_name.text,int(member_age.value),[])
 if not bool(result.get("ok",false)):
  status.text = str(result.get("reason","Could not add member."))
  return
 state = result.state
 selected_person = str(result.person_id)
 member_name.clear()
 _save()
 _refresh()
 status.text = "Allied adult recorded."

func _marry() -> void:
 var result := Dynasty.set_spouse(state,_selected_id(spouse_a),_selected_id(spouse_b))
 if not bool(result.get("ok",false)):
  status.text = str(result.get("reason","Marriage record rejected."))
  return
 state = result.state
 _save()
 _refresh()
 status.text = "Marriage recorded."

func _assign_guardian() -> void:
 _apply_result(Dynasty.assign_guardian(state,selected_person,_selected_id(guardian_picker)))

func _assign_education() -> void:
 var focus := str(Dynasty.EDUCATION_FOCUSES[education_picker.selected])
 _apply_result(Dynasty.assign_education(state,selected_person,focus))

func _complete_education() -> void:
 _apply_result(Dynasty.complete_education(state,selected_person))

func _adopt() -> void:
 _apply_result(Dynasty.record_adoption(state,selected_person,_selected_id(adoptive_parent_picker)))

func _appoint_council() -> void:
 var role := str(Dynasty.COUNCIL_ROLES[council_role_picker.selected])
 _apply_result(Dynasty.assign_council_role(state,role,selected_person))

func _record_claim() -> void:
 if claim_title_picker.item_count == 0:
  status.text = "No title is available to claim."
  return
 var basis := ["inheritance","grant","service"][claim_basis_picker.selected]
 _apply_result(Dynasty.record_title_claim(state,selected_person,str(claim_title_picker.get_item_metadata(claim_title_picker.selected)),basis))

func _recognize_claim() -> void:
 _resolve_claim("recognize")

func _reject_claim() -> void:
 _resolve_claim("reject")

func _resolve_claim(outcome: String) -> void:
 if claim_title_picker.item_count == 0:
  status.text = "No title is available to resolve."
  return
 _apply_result(Dynasty.resolve_title_claim(state,selected_person,str(claim_title_picker.get_item_metadata(claim_title_picker.selected)),outcome))

func _add_trait() -> void:
 var keys: Array = Dynasty.TRAITS.keys()
 if keys.is_empty():
  return
 _apply_result(Dynasty.add_trait(state,selected_person,str(keys[trait_picker.selected])))

func _remove_trait() -> void:
 var keys: Array = Dynasty.TRAITS.keys()
 if keys.is_empty():
  return
 _apply_result(Dynasty.remove_trait(state,selected_person,str(keys[trait_picker.selected])))

func _grant_title() -> void:
 if title_picker.item_count == 0:
  return
 _apply_result(Dynasty.assign_title(state,str(title_picker.get_item_metadata(title_picker.selected)),selected_person))

func _create_title() -> void:
 if state.domains.is_empty():
  status.text = "Establish a holding before creating a title."
  return
 var rank_id := str(Dynasty.RANKS[title_rank_picker.selected].id)
 var result := Dynasty.create_title(state,rank_id,title_name.text,selected_person,_selected_id(domain_picker))
 if bool(result.get("ok",false)):
  title_name.clear()
 _apply_result(result)

func _create_domain() -> void:
 var result := Dynasty.create_domain(state,domain_name.text,selected_person)
 if bool(result.get("ok",false)):
  domain_name.clear()
 _apply_result(result)

func _set_policy() -> void:
 var policy := str(Dynasty.SUCCESSION_POLICIES[policy_picker.selected])
 var heir := selected_person if policy in ["designated_heir","elective"] else ""
 _apply_result(Dynasty.set_succession_policy(state,policy,heir))

func _domain_food() -> void:
 _domain_change("food")

func _domain_security() -> void:
 _domain_change("security")

func _domain_prosperity() -> void:
 _domain_change("prosperity")

func _domain_change(field: String) -> void:
 if domain_picker.item_count == 0:
  status.text = "No holding has been recorded."
  return
 var domain_id := _selected_id(domain_picker)
 var value := int(state.domains[domain_id].get(field,0))+5
 _apply_result(Dynasty.update_domain(state,domain_id,field,value))

func _advance_year() -> void:
 var result := Dynasty.advance_year(state)
 if not bool(result.get("ok",false)):
  status.text = str(result.get("reason","The year could not advance."))
  return
 state = result.state
 var political_result := Politics.advance_political_year(state)
 if bool(political_result.get("ok",false)):
  state = political_result.state
 var deaths: Array = result.get("deaths",[])
 var result_text := "Year %d recorded. Natural deaths: %s. Succession is resolved under %s." % [int(state.year),", ".join(deaths) if not deaths.is_empty() else "none",str(state.succession_policy)]
 _save()
 _refresh()
 status.text = result_text

func _apply_result(result: Dictionary) -> void:
 if not bool(result.get("ok",false)):
  status.text = str(result.get("reason","Action rejected."))
  return
 state = result.state
 _save()
 _refresh()
 status.text = "Change recorded in the house chronicle."

func _save() -> void:
 if state.is_empty():
  return
 GameState.world_flags["chronicle_house_state"] = state.duplicate(true)
 GameState.save_campaign("auto_a")

func _return_title() -> void:
 _save()
 get_tree().change_scene_to_file("res://TitleScreen.tscn")

func _blocked() -> void:
 var label := Label.new()
 label.text = "Chronicle of Houses is sealed. The founder must complete the five-act campaign, dissolve the Empire, finish the late-life epilogue and die naturally before this mode can begin."
 label.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
 label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
 add_child(label)
 var button := Button.new()
 button.text = "Return to title"
 button.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM)
 button.pressed.connect(func(): get_tree().change_scene_to_file("res://TitleScreen.tscn"))
 add_child(button)
