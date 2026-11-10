extends SceneTree
const Dynasty = preload("res://scripts/core/chronicle_dynasty_system.gd")
var checks := 0
var failures := 0

func _initialize() -> void:
 var founder := {"protagonist_id":"torren","age_at_death":87,"cause":"old_age","ending_id":"open_concord","recorded":true}
 var state := Dynasty.new_house(founder,"Torren Vale","House Vale")
 var child_result := Dynasty.add_child(state,"heir_1","Lysa Vale",10,[])
 state = child_result.state
 var child_id := str(child_result.person_id)
 check(not Dynasty.assign_education(state,child_id,"learning").ok,"education is blocked until a guardian is appointed")
 var guardian := Dynasty.assign_guardian(state,child_id,"heir_1")
 check(bool(guardian.ok),"a living adult can become a child's guardian")
 state = guardian.state
 check(not Dynasty.assign_guardian(state,child_id,child_id).ok,"a child cannot become their own guardian")
 var education := Dynasty.assign_education(state,child_id,"stewardship")
 check(bool(education.ok),"guardian can begin a child's education")
 state = education.state
 check(not Dynasty.complete_education(state,child_id).ok,"education cannot complete before age 16")
 state.people[child_id].age = 16
 var completed := Dynasty.complete_education(state,child_id)
 check(bool(completed.ok) and str(completed.earned_trait) == "diligent","stewardship education grants its defined trait at adulthood")
 state = completed.state
 check(not Dynasty.complete_education(state,child_id).ok,"education cannot be completed twice")
 var outsider := Dynasty.add_house_member(state,"Tomas Reed",30,[])
 state = outsider.state
 var adopted := Dynasty.record_adoption(state,child_id,str(outsider.person_id))
 check(bool(adopted.ok),"an unrelated adult can adopt a child")
 state = adopted.state
 check(str(state.people[child_id].adoptive_parent_id) == str(outsider.person_id),"adoptive parent is recorded separately")
 check(state.people[child_id].birth_parents.has("heir_1") and state.people[child_id].parents.has(str(outsider.person_id)),"adoption preserves birth parentage and adds legal parentage")
 check(not Dynasty.record_adoption(state,child_id,"heir_2").ok,"a child cannot receive a second adoptive parent in this model")
 var council := Dynasty.assign_council_role(state,"steward","heir_1")
 check(bool(council.ok),"living adult can be appointed steward")
 state = council.state
 check(not Dynasty.assign_council_role(state,"marshal","heir_1").ok,"one person cannot occupy two council offices")
 var second_office := Dynasty.assign_council_role(state,"marshal","heir_2")
 check(bool(second_office.ok),"another eligible adult can fill a separate council office")
 state = second_office.state
 var claim := Dynasty.record_title_claim(state,"heir_2","founder_barony","inheritance")
 check(bool(claim.ok),"family member can record a title claim with legal basis")
 state = claim.state
 check(not Dynasty.record_title_claim(state,"heir_2","founder_barony","inheritance").ok,"duplicate pending title claim is rejected")
 var rejected := Dynasty.resolve_title_claim(state,"heir_2","founder_barony","reject")
 check(bool(rejected.ok) and str(rejected.state.people["heir_2"].claims[0].status) == "rejected","title claim can be rejected and retained in the record")
 state = rejected.state
 var second_claim := Dynasty.record_title_claim(state,"heir_2","founder_barony","grant")
 state = second_claim.state
 var recognized := Dynasty.resolve_title_claim(state,"heir_2","founder_barony","recognize")
 check(bool(recognized.ok) and str(recognized.state.titles["founder_barony"].holder) == "heir_2","recognized claim transfers title and preserves the claim record")
 state = recognized.state
 var saved := JSON.parse_string(JSON.stringify(state))
 var restored := Dynasty.normalize_state(saved)
 check(restored.council.size() == 2 and restored.people[child_id].education.completed,"council and education survive offline save normalization")
 print("Chronicle family development checks: %d   Failures: %d" % [checks,failures])
 quit(1 if failures > 0 else 0)

func check(condition: bool, label: String) -> void:
 checks += 1
 if condition:
  print("  ok  "+label)
 else:
  failures += 1
  print("  FAIL  "+label)
