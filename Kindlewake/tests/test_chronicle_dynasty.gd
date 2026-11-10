extends SceneTree
const Dynasty = preload("res://scripts/core/chronicle_dynasty_system.gd")
var checks := 0
var failures := 0

func _initialize() -> void:
 var founder := {"protagonist_id":"torren","age_at_death":87,"cause":"old_age","ending_id":"open_concord","recorded":true}
 check(Dynasty.new_house({"protagonist_id":"forged","age_at_death":30,"cause":"battle","recorded":false},"Forged").is_empty(),"unverified or non-natural founder record cannot seed Chronicle mode")
 var state := Dynasty.new_house(founder,"Torren Vale","House Vale")
 check(not state.is_empty(),"house initializes from verified founder record")
 check(state.people.has("heir_1") and state.people.has("heir_2"),"founder has two recorded successor branches")
 check(state.titles.has("founder_barony") and state.domains.has("kaer_sethorn"),"founding barony and Kaer Sethorn domain are established")
 check(state.people["torren"].spouse == "consort" and state.people["consort"].children.size() == 2,"founding consort and family links are reciprocal")
 check(Dynasty.TRAITS.size() >= 40 and Dynasty.TRAITS.has("brave") and Dynasty.TRAITS.has("cruel"),"large positive, negative and mixed trait catalogue is available")
 var child := Dynasty.add_child(state,"heir_1","Lysa Vale",12,["kind"])
 check(bool(child.ok),"child can be recorded with a parent and trait")
 state = child.state
 check(state.people.has(str(child.person_id)) and state.people["heir_1"].children.has(str(child.person_id)),"child and parent link persist")
 check(not Dynasty.add_child(state,"missing_parent","Bad Record",4).ok,"unknown parent is rejected")
 check(not Dynasty.add_child(state,"heir_1","",4).ok,"unnamed child is rejected")
 var outsider := Dynasty.add_house_member(state,"Tomas Reed",26,["honest"])
 check(bool(outsider.ok),"unrelated adult can be recorded as an allied house member")
 state = outsider.state
 var marriage := Dynasty.set_spouse(state,"heir_1",str(outsider.person_id))
 check(bool(marriage.ok),"marriage links two eligible unrelated adults")
 state = marriage.state
 check(str(state.people["heir_1"].spouse) == str(outsider.person_id),"marriage is reciprocal")
 var child_with_spouse := Dynasty.add_child(state,"heir_1","Nell Vale",3)
 check(child_with_spouse.state.people[str(child_with_spouse.person_id)].parents.has(str(outsider.person_id)),"child records both parents when a spouse is recorded")
 state = child_with_spouse.state
 var cousin_a := Dynasty.add_child(state,"heir_1","Branch A",20)
 state = cousin_a.state
 var cousin_b := Dynasty.add_child(state,"heir_2","Branch B",20)
 state = cousin_b.state
 check(not Dynasty.set_spouse(state,str(cousin_a.person_id),str(cousin_b.person_id)).ok,"marriage between branches with a shared ancestor is rejected")
 check(not Dynasty.set_spouse(state,"heir_1","heir_2").ok,"close relatives cannot be married")
 var trait_result: Dictionary = Dynasty.add_trait(state,"heir_1","curious")
 check(bool(trait_result.ok),"positive or negative traits can be acquired")
 state = trait_result.state
 check(not Dynasty.add_trait(state,"heir_1","curious").ok,"duplicate trait is rejected")
 var removed := Dynasty.remove_trait(state,"heir_1","curious")
 check(bool(removed.ok) and not removed.state.people["heir_1"].traits.has("curious"),"traits can be removed")
 state = removed.state
 check(not Dynasty.remove_trait(state,"heir_1","curious").ok,"missing trait removal is rejected")
 var policy := Dynasty.set_succession_policy(state,"designated_heir","heir_2")
 check(bool(policy.ok) and str(policy.state.designated_heir) == "heir_2","designated heir succession can be configured")
 state = policy.state
 check(not Dynasty.set_succession_policy(state,"unknown").ok,"unknown succession law is rejected")
 var domain := Dynasty.create_domain(state,"West Orchard","heir_2")
 check(bool(domain.ok),"new domain can be founded under a living steward")
 state = domain.state
 check(not Dynasty.create_domain(state,"","heir_2").ok,"unnamed domain is rejected")
 var title := Dynasty.create_title(state,"viscount","Viscount of the Western Orchards","heir_2",str(domain.domain_id))
 check(bool(title.ok),"next noble rank can be established with jurisdiction and duties")
 state = title.state
 check(not Dynasty.create_title(state,"count","Count of Nowhere","heir_2",str(domain.domain_id)).ok,"title rank cannot skip the intervening viscount rank")
 check(bool(Dynasty.assign_title(state,"founder_barony","heir_2").ok),"existing title can be granted to a living family member")
 var saved: Variant = JSON.parse_string(JSON.stringify(state))
 var restored := Dynasty.normalize_state(saved)
 check(not restored.is_empty() and restored.people.size() == state.people.size(),"family and relationship state survives JSON save normalization")
 var corrupt := Dynasty.normalize_state({"founder_id":"missing","people":{"bad":"not a person"},"titles":{"broken":"not a title"},"domains":[]})
 check(corrupt.is_empty(),"corrupted family saves without a founder anchor are rejected safely")
 var aged := restored.duplicate(true)
 aged.people["heir_2"].age = Dynasty.NATURAL_OLD_AGE-1
 var year := Dynasty.advance_year(aged)
 check(bool(year.ok) and year.state.people["heir_2"].alive == false,"natural old-age death is recorded by yearly simulation")
 check(str(year.state.last_succession.get("to","")) == "heir_1","title succession resolves to eligible heir under configured law")
 check(year.state.people["heir_1"].title_ids.size() >= 2,"succession preserves multiple titles held by the same heir")
 check(int(year.state.year) == 2,"house chronicle advances its calendar")
 check(int(year.state.domains["kaer_sethorn"].food) == 54 and int(year.state.domains["kaer_sethorn"].prosperity) == 51,"annual domain economy consumes food and improves stable holdings")
 check(year.state.chronicle.size() > 0,"yearly and family events enter the house chronicle")
 var partition_state := Dynasty.new_house(founder,"Torren Vale","House Vale")
 var first_child := Dynasty.add_child(partition_state,"heir_1","First Child",20)
 partition_state = first_child.state
 var second_child := Dynasty.add_child(partition_state,"heir_1","Second Child",18)
 partition_state = second_child.state
 var holding_a := Dynasty.create_domain(partition_state,"North Holding","heir_1")
 partition_state = holding_a.state
 var holding_b := Dynasty.create_domain(partition_state,"South Holding","heir_1")
 partition_state = holding_b.state
 var equal_law := Dynasty.set_succession_policy(partition_state,"equal_partition")
 partition_state = equal_law.state
 partition_state.people["heir_1"].age = Dynasty.NATURAL_OLD_AGE-1
 var divided := Dynasty.advance_year(partition_state)
 check(str(divided.state.domains[holding_a.domain_id].steward) != str(divided.state.domains[holding_b.domain_id].steward),"equal partition distributes separate holdings between eligible children")
 var elective_state := Dynasty.new_house(founder,"Torren Vale","House Vale")
 var elect_child_a := Dynasty.add_child(elective_state,"heir_1","Aster Vale",20)
 elective_state = elect_child_a.state
 var elect_child_b := Dynasty.add_child(elective_state,"heir_1","Briar Vale",19)
 elective_state = elect_child_b.state
 var elective_law := Dynasty.set_succession_policy(elective_state,"elective",str(elect_child_b.person_id))
 check(bool(elective_law.ok),"elective succession records the house's chosen candidate")
 elective_state = elective_law.state
 elective_state.people["heir_1"].age = Dynasty.NATURAL_OLD_AGE-1
 var elected := Dynasty.advance_year(elective_state)
 check(str(elected.state.titles["founder_barony"].holder) == str(elect_child_b.person_id),"elective succession honours the chosen eligible heir")
 print("Chronicle dynasty checks: %d   Failures: %d" % [checks,failures])
 quit(1 if failures > 0 else 0)

func check(condition: bool, label: String) -> void:
 checks += 1
 if condition:
  print("  ok  "+label)
 else:
  failures += 1
  print("  FAIL  "+label)
