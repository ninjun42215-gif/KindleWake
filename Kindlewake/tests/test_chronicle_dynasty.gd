extends SceneTree
const Dynasty = preload("res://scripts/core/chronicle_dynasty_system.gd")
var checks := 0
var failures := 0

func _initialize() -> void:
 var founder := {"protagonist_id":"torren","age_at_death":87,"cause":"old_age","ending_id":"open_concord"}
 var state := Dynasty.new_house(founder,"Torren Vale","House Vale")
 check(not state.is_empty(),"house initializes from verified founder record")
 check(state.people.has("heir_1") and state.people.has("heir_2"),"founder has two recorded successor branches")
 check(state.titles.has("founder_barony") and state.domains.has("kaer_sethorn"),"founding barony and Kaer Sethorn domain are established")
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
 check(not Dynasty.set_spouse(state,"heir_1","heir_2").ok,"close relatives cannot be married")
 var trait := Dynasty.add_trait(state,"heir_1","brave")
 check(bool(trait.ok),"positive or negative traits can be acquired")
 state = trait.state
 check(not Dynasty.add_trait(state,"heir_1","brave").ok,"duplicate trait is rejected")
 var removed := Dynasty.remove_trait(state,"heir_1","brave")
 check(bool(removed.ok) and not removed.state.people["heir_1"].traits.has("brave"),"traits can be removed")
 state = removed.state
 check(not Dynasty.remove_trait(state,"heir_1","brave").ok,"missing trait removal is rejected")
 var policy := Dynasty.set_succession_policy(state,"designated_heir","heir_2")
 check(bool(policy.ok) and str(policy.state.designated_heir) == "heir_2","designated heir succession can be configured")
 state = policy.state
 check(not Dynasty.set_succession_policy(state,"unknown").ok,"unknown succession law is rejected")
 var domain := Dynasty.create_domain(state,"West Orchard","heir_2")
 check(bool(domain.ok),"new domain can be founded under a living steward")
 state = domain.state
 check(not Dynasty.create_domain(state,"","heir_2").ok,"unnamed domain is rejected")
 var title := Dynasty.create_title(state,"count","Count of the Western Orchards","heir_2",str(domain.domain_id))
 check(bool(title.ok),"higher noble title can be established with jurisdiction and duties")
 state = title.state
 check(not Dynasty.create_title(state,"knight","Knight of Nowhere","heir_2",str(domain.domain_id)).ok,"title rank cannot move backwards")
 check(bool(Dynasty.assign_title(state,"founder_barony","heir_2").ok),"existing title can be granted to a living family member")
 var saved := JSON.parse_string(JSON.stringify(state))
 var restored := Dynasty.normalize_state(saved)
 check(not restored.is_empty() and restored.people.size() == state.people.size(),"family and relationship state survives JSON save normalization")
 var aged := restored.duplicate(true)
 aged.people["heir_2"].age = Dynasty.NATURAL_OLD_AGE-1
 var year := Dynasty.advance_year(aged)
 check(bool(year.ok) and year.state.people["heir_2"].alive == false,"natural old-age death is recorded by yearly simulation")
 check(str(year.state.last_succession.get("to","")) == "heir_1","title succession resolves to eligible heir under configured law")
 check(int(year.state.year) == 2,"house chronicle advances its calendar")
 check(year.state.chronicle.size() > 0,"yearly and family events enter the house chronicle")
 print("Chronicle dynasty checks: %d   Failures: %d" % [checks,failures])
 quit(1 if failures > 0 else 0)

func check(condition: bool, label: String) -> void:
 checks += 1
 if condition:
  print("  ok  "+label)
 else:
  failures += 1
  print("  FAIL  "+label)
