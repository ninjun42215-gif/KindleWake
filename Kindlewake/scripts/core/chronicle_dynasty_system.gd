extends RefCounted
## Offline generational house simulation. All mutations are deterministic and serializable.
const VERSION := 1
const ADULT_AGE := 18
const NATURAL_OLD_AGE := 85
const SUCCESSION_POLICIES := ["primogeniture", "equal_partition", "seniority", "elective", "designated_heir"]
const TRAITS := {
 "brave":{"polarity":"positive","description":"Stands firm when danger closes in."},
 "kind":{"polarity":"positive","description":"Treats dependants as people, not assets."},
 "diligent":{"polarity":"positive","description":"Keeps patient attention on difficult duties."},
 "ambitious":{"polarity":"mixed","description":"Seeks influence and can overreach."},
 "shrewd":{"polarity":"positive","description":"Reads motives and practical consequences."},
 "generous":{"polarity":"positive","description":"Shares wealth when others are in need."},
 "patient":{"polarity":"positive","description":"Waits for the right moment."},
 "loyal":{"polarity":"positive","description":"Keeps faith with people and promises."},
 "curious":{"polarity":"positive","description":"Seeks knowledge beyond familiar boundaries."},
 "charitable":{"polarity":"positive","description":"Makes relief a duty rather than a favour."},
 "disciplined":{"polarity":"positive","description":"Maintains order under pressure."},
 "witty":{"polarity":"positive","description":"Uses humour to ease difficult rooms."},
 "perceptive":{"polarity":"positive","description":"Notices details others overlook."},
 "resolute":{"polarity":"positive","description":"Does not abandon a difficult obligation."},
 "humble":{"polarity":"positive","description":"Accepts correction without humiliation."},
 "diplomatic":{"polarity":"positive","description":"Finds language that lets rivals negotiate."},
 "scholarly":{"polarity":"positive","description":"Studies records, law and history."},
 "inventive":{"polarity":"positive","description":"Finds practical solutions with limited means."},
 "honest":{"polarity":"positive","description":"Prefers candour even when costly."},
 "proud":{"polarity":"negative","description":"Finds compromise difficult."},
 "cruel":{"polarity":"negative","description":"Uses fear where trust would serve better."},
 "reckless":{"polarity":"negative","description":"Acts before weighing the cost."},
 "greedy":{"polarity":"negative","description":"Keeps too much and gives too little."},
 "cowardly":{"polarity":"negative","description":"May abandon a duty under threat."},
 "deceitful":{"polarity":"negative","description":"Conceals motives and distorts the record."},
 "melancholic":{"polarity":"negative","description":"Carries grief that can cloud judgement."},
 "stubborn":{"polarity":"mixed","description":"Resists pressure, including wise counsel."},
 "envious":{"polarity":"negative","description":"Measures worth against another person's fortune."},
 "vengeful":{"polarity":"negative","description":"Keeps old injuries alive."},
 "impatient":{"polarity":"negative","description":"Demands results before plans are ready."},
 "arrogant":{"polarity":"negative","description":"Mistakes rank for proof of wisdom."},
 "wasteful":{"polarity":"negative","description":"Consumes resources without regard for tomorrow."},
 "suspicious":{"polarity":"negative","description":"Sees hidden threats in ordinary disagreement."},
 "fanatical":{"polarity":"negative","description":"Treats compromise as betrayal."},
 "indolent":{"polarity":"negative","description":"Avoids duties that require sustained effort."},
 "fickle":{"polarity":"negative","description":"Changes allegiance when fortune turns."},
 "hot_tempered":{"polarity":"negative","description":"Lets anger outrun judgement."},
 "secretive":{"polarity":"mixed","description":"Protects confidences but withholds useful truth."},
 "ambivalent":{"polarity":"mixed","description":"Struggles to commit when duties conflict."},
 "world_weary":{"polarity":"mixed","description":"Has seen enough loss to distrust easy promises."},
 "zealous":{"polarity":"mixed","description":"Serves a cause with intensity that can narrow perspective."},
 "forgiving":{"polarity":"positive","description":"Allows repair after sincere wrongdoing."},
 "steadfast":{"polarity":"positive","description":"Remains dependable through long hardship."},
 "resourceful":{"polarity":"positive","description":"Makes good use of scarce supplies."},
 "empathetic":{"polarity":"positive","description":"Understands the fears behind another person's words."}
}
const RANKS = [
 {"id":"knight","name":"Knight / Dame","rank":1,"jurisdiction":"A sworn household or a small holding","duties":"Service, protection and attendance"},
 {"id":"baron","name":"Baron / Baroness","rank":2,"jurisdiction":"A barony and its villages","duties":"Local justice, roads, relief and levy accountability"},
 {"id":"viscount","name":"Viscount / Viscountess","rank":3,"jurisdiction":"A group of baronies","duties":"Oversight of local lords and courts"},
 {"id":"count","name":"Count / Countess","rank":4,"jurisdiction":"A county","duties":"County justice, market protections and defence"},
 {"id":"marquess","name":"Marquess / Marchioness","rank":5,"jurisdiction":"A defended frontier march","duties":"Border security without unlawful exactions"},
 {"id":"duke","name":"Duke / Duchess","rank":6,"jurisdiction":"A duchy","duties":"Regional coordination and accountable taxation"},
 {"id":"archduke","name":"Archduke / Archduchess","rank":7,"jurisdiction":"A major realm","duties":"Realm-wide stewardship and treaty obligations"},
 {"id":"high_protector","name":"High Protector / First Warden","rank":8,"jurisdiction":"A Concord mandate, never an empire","duties":"Limited-term protection under public review"}
]

static func new_house(founder_record: Dictionary, founder_name: String, house_name: String = "House of the Open Hand") -> Dictionary:
 var founder_id := str(founder_record.get("protagonist_id", ""))
 if founder_id == "" or str(founder_record.get("cause","")) != "old_age" or int(founder_record.get("age_at_death",0)) < 70 or not bool(founder_record.get("recorded",false)):
  return {}
 var founder_age := maxi(NATURAL_OLD_AGE, int(founder_record.get("age_at_death", NATURAL_OLD_AGE)))
 var people := {}
 people[founder_id] = _person(founder_id, founder_name if founder_name != "" else "The Founder", founder_age, "founder", [], [], false)
 people[founder_id]["death_cause"] = "old_age"
 people[founder_id]["title_id"] = ""
 people["heir_1"] = _person("heir_1", "Alden", 44, "child", [founder_id], ["brave","diligent"], true)
 people["heir_2"] = _person("heir_2", "Maren", 41, "child", [founder_id], ["kind","shrewd"], true)
 people["consort"] = _person("consort", "The Founder's Consort", 67, "spouse", [], ["patient"], false)
 people[founder_id]["children"] = ["heir_1","heir_2"]
 people[founder_id]["spouse"] = "consort"
 people["consort"]["spouse"] = founder_id
 people["consort"]["children"] = ["heir_1","heir_2"]
 people["heir_1"]["parents"] = [founder_id,"consort"]
 people["heir_2"]["parents"] = [founder_id,"consort"]
 people["heir_1"]["siblings"] = ["heir_2"]
 people["heir_2"]["siblings"] = ["heir_1"]
 people["heir_1"]["designated_heir"] = true
 people["heir_1"]["title_id"] = "founder_barony"
 people["heir_1"]["title_ids"] = ["founder_barony"]
 var domains := {"kaer_sethorn":{"id":"kaer_sethorn","name":"Kaer Sethorn and its holdings","steward":"heir_1","prosperity":50,"security":45,"food":55,"legitimacy":60,"notes":"A modest holding entrusted to the first branch; its duties are relief, roads and fair local judgement."}}
 var titles := {"founder_barony":{"id":"founder_barony","rank_id":"baron","name":"Baron of Kaer Sethorn","holder":"heir_1","domain_id":"kaer_sethorn","jurisdiction":"Kaer Sethorn and its villages","obligations":["maintain the well","keep the road passable","publish relief accounts"],"legitimacy":60}}
 return {
  "version":VERSION,"house_name":house_name,"year":1,"next_person_number":1,
  "founder_id":founder_id,"people":people,"titles":titles,"domains":domains,
  "succession_policy":"primogeniture","designated_heir":"heir_1",
  "chronicle":[],"last_succession":{}
 }


static func _person(id: String, name: String, age: int, relation: String, parents: Array, traits: Array, alive: bool) -> Dictionary:
 return {"id":id,"name":name,"age":age,"relation":relation,"parents":parents.duplicate(),"children":[],"siblings":[],"spouse":"","traits":traits.duplicate(),"alive":alive,"death_cause":"","title_id":"","title_ids":[],"domain_ids":[],"designated_heir":false,"born_year":1}


static func normalize_state(raw: Dictionary) -> Dictionary:
 if str(raw.get("founder_id","")) == "" or typeof(raw.get("people",{})) != TYPE_DICTIONARY:
  return {}
 var state := raw.duplicate(true)
 state["version"] = VERSION
 state["year"] = maxi(1,int(state.get("year",1)))
 state["next_person_number"] = maxi(1,int(state.get("next_person_number",1)))
 state["house_name"] = str(state.get("house_name","House of the Open Hand"))
 if not SUCCESSION_POLICIES.has(str(state.get("succession_policy",""))):
  state["succession_policy"] = "primogeniture"
 var people: Dictionary = state["people"]
 for id in people.keys():
  if typeof(people[id]) != TYPE_DICTIONARY:
   people.erase(id)
 for id in people.keys():
  var person: Dictionary = people[id]
  person["id"] = str(id)
  person["age"] = maxi(0,int(person.get("age",0)))
  person["traits"] = _valid_traits(person.get("traits",[]))
  person["children"] = _valid_ids(person.get("children",[]),people)
  person["parents"] = _valid_ids(person.get("parents",[]),people)
  person["siblings"] = _valid_ids(person.get("siblings",[]),people)
  var spouse_id := str(person.get("spouse",""))
  person["spouse"] = spouse_id if people.has(spouse_id) else ""
  person["alive"] = bool(person.get("alive",false))
  people[id] = person
 state["people"] = people
 if not people.has(str(state.get("founder_id",""))):
  return {}
 var saved_titles: Variant = state.get("titles",{})
 var saved_domains: Variant = state.get("domains",{})
 state["titles"] = saved_titles.duplicate(true) if typeof(saved_titles) == TYPE_DICTIONARY else {}
 state["domains"] = saved_domains.duplicate(true) if typeof(saved_domains) == TYPE_DICTIONARY else {}
 for title_id in state["titles"].keys():
  if typeof(state["titles"][title_id]) != TYPE_DICTIONARY:
   state["titles"].erase(title_id)
 for domain_id in state["domains"].keys():
  if typeof(state["domains"][domain_id]) != TYPE_DICTIONARY:
   state["domains"].erase(domain_id)
 for title_id in state["titles"].keys():
  var title: Dictionary = state["titles"][title_id]
  if not people.has(str(title.get("holder",""))):
   title["holder"] = ""
  if not state["domains"].has(str(title.get("domain_id",""))):
   title["domain_id"] = ""
  state["titles"][title_id] = title
 for domain_id in state["domains"].keys():
  var domain: Dictionary = state["domains"][domain_id]
  if not people.has(str(domain.get("steward",""))):
   domain["steward"] = ""
  state["domains"][domain_id] = domain
 for person_id in people.keys():
  var person: Dictionary = people[person_id]
  person["title_ids"] = []
  person["title_id"] = ""
  people[person_id] = person
 for title_id in state["titles"].keys():
  var title: Dictionary = state["titles"][title_id]
  var holder_id := str(title.get("holder",""))
  if holder_id != "" and people.has(holder_id):
   var holder: Dictionary = people[holder_id]
   var title_ids: Array = holder.get("title_ids",[])
   title_ids.append(str(title_id))
   holder["title_ids"] = title_ids
   holder["title_id"] = str(title_id)
   people[holder_id] = holder
 state["people"] = people
 if typeof(state.get("chronicle",[])) != TYPE_ARRAY:
  state["chronicle"] = []
 return state


static func _valid_ids(values: Variant, people: Dictionary) -> Array:
 var result: Array = []
 if typeof(values) == TYPE_ARRAY:
  for value in values:
   if people.has(str(value)) and not result.has(str(value)):
    result.append(str(value))
 return result


static func _valid_traits(values: Variant) -> Array:
 var result: Array = []
 if typeof(values) == TYPE_ARRAY:
  for value in values:
   if TRAITS.has(str(value)) and not result.has(str(value)):
    result.append(str(value))
 return result


static func add_child(raw: Dictionary, parent_id: String, child_name: String, age: int, traits: Array = []) -> Dictionary:
 var state := normalize_state(raw)
 if state.is_empty() or not state.people.has(parent_id) or not bool(state.people[parent_id].alive):
  return {"ok":false,"reason":"A living parent in this house is required."}
 if child_name.strip_edges().length() < 2 or age < 0 or age > 60:
  return {"ok":false,"reason":"Enter a name and a plausible age."}
 var parent: Dictionary = state.people[parent_id]
 var child_id := "person_%04d" % int(state.next_person_number)
 state.next_person_number = int(state.next_person_number) + 1
 var parents: Array = [parent_id]
 var spouse_id := str(parent.get("spouse",""))
 if spouse_id != "" and state.people.has(spouse_id):
  parents.append(spouse_id)
 var child := _person(child_id,child_name.strip_edges(),age,"child",parents,_valid_traits(traits),true)
 child["born_year"] = maxi(1,int(state.year)-age)
 state.people[child_id] = child
 parent.children.append(child_id)
 state.people[parent_id] = parent
 for other_parent in parents:
  if other_parent != parent_id and state.people.has(other_parent):
   var op: Dictionary = state.people[other_parent]
   if not op.children.has(child_id):
    op.children.append(child_id)
   state.people[other_parent] = op
 for sibling_id in parent.children:
  if sibling_id != child_id and state.people.has(sibling_id):
   var sibling: Dictionary = state.people[sibling_id]
   sibling.siblings.append(child_id)
   child.siblings.append(sibling_id)
   state.people[sibling_id] = sibling
 state.people[child_id] = child
 _log(state,"birth_recorded",{"person":child_id,"parent":parent_id})
 return {"ok":true,"state":state,"person_id":child_id}


static func add_house_member(raw: Dictionary, name: String, age: int, traits: Array = []) -> Dictionary:
 var state := normalize_state(raw)
 if state.is_empty() or name.strip_edges().length() < 2 or age < ADULT_AGE or age > 80:
  return {"ok":false,"reason":"An unrelated adult house member needs a name and an age from 18 to 80."}
 var person_id := "person_%04d" % int(state.next_person_number)
 state.next_person_number = int(state.next_person_number) + 1
 state.people[person_id] = _person(person_id,name.strip_edges(),age,"allied_member",[],_valid_traits(traits),true)
 _log(state,"house_member_recorded",{"person":person_id})
 return {"ok":true,"state":state,"person_id":person_id}


static func set_spouse(raw: Dictionary, person_a: String, person_b: String) -> Dictionary:
 var state := normalize_state(raw)
 if not state.people.has(person_a) or not state.people.has(person_b) or person_a == person_b:
  return {"ok":false,"reason":"Choose two different recorded people."}
 var a: Dictionary = state.people[person_a]
 var b: Dictionary = state.people[person_b]
 if not a.alive or not b.alive or int(a.age) < ADULT_AGE or int(b.age) < ADULT_AGE:
  return {"ok":false,"reason":"Both people must be living adults."}
 if str(a.spouse) != "" or str(b.spouse) != "":
  return {"ok":false,"reason":"One person is already married."}
 if _related(state,person_a,person_b):
  return {"ok":false,"reason":"Close family relationships cannot be entered as a marriage."}
 a.spouse = person_b
 b.spouse = person_a
 state.people[person_a] = a
 state.people[person_b] = b
 _log(state,"marriage_recorded",{"people":[person_a,person_b]})
 return {"ok":true,"state":state}


static func _related(state: Dictionary, a: String, b: String) -> bool:
 var pa: Dictionary = state.people[a]
 var pb: Dictionary = state.people[b]
 if pa.parents.has(b) or pb.parents.has(a) or pa.siblings.has(b) or pb.siblings.has(a):
  return true
 var ancestors_a := _ancestor_ids(state,a)
 var ancestors_b := _ancestor_ids(state,b)
 for ancestor_id in ancestors_a:
  if ancestors_b.has(ancestor_id):
   return true
 return false


static func _ancestor_ids(state: Dictionary, person_id: String, visited: Array = []) -> Array:
 if visited.has(person_id) or not state.people.has(person_id):
  return visited
 visited.append(person_id)
 var person: Dictionary = state.people[person_id]
 for parent_id in person.get("parents",[]):
  _ancestor_ids(state,str(parent_id),visited)
 return visited


static func add_trait(raw: Dictionary, person_id: String, trait_id: String) -> Dictionary:
 var state := normalize_state(raw)
 if not state.people.has(person_id) or not TRAITS.has(trait_id):
  return {"ok":false,"reason":"Unknown person or trait."}
 var person: Dictionary = state.people[person_id]
 if person.traits.has(trait_id):
  return {"ok":false,"reason":"That trait is already present."}
 person.traits.append(trait_id)
 state.people[person_id] = person
 _log(state,"trait_gained",{"person":person_id,"trait":trait_id})
 return {"ok":true,"state":state}


static func remove_trait(raw: Dictionary, person_id: String, trait_id: String) -> Dictionary:
 var state := normalize_state(raw)
 if not state.people.has(person_id) or not TRAITS.has(trait_id):
  return {"ok":false,"reason":"Unknown person or trait."}
 var person: Dictionary = state.people[person_id]
 if not person.traits.has(trait_id):
  return {"ok":false,"reason":"That trait is not present."}
 person.traits.erase(trait_id)
 state.people[person_id] = person
 _log(state,"trait_removed",{"person":person_id,"trait":trait_id})
 return {"ok":true,"state":state}


static func set_succession_policy(raw: Dictionary, policy: String, designated_heir: String = "") -> Dictionary:
 var state := normalize_state(raw)
 if not SUCCESSION_POLICIES.has(policy):
  return {"ok":false,"reason":"Unknown succession law."}
 if policy in ["designated_heir","elective"]:
  if not state.people.has(designated_heir) or not bool(state.people[designated_heir].alive):
   return {"ok":false,"reason":"The designated heir must be a living family member."}
 state.succession_policy = policy
 state.designated_heir = designated_heir
 _log(state,"succession_law_changed",{"policy":policy,"heir":designated_heir})
 return {"ok":true,"state":state}


static func assign_title(raw: Dictionary, title_id: String, person_id: String) -> Dictionary:
 var state := normalize_state(raw)
 if not state.titles.has(title_id) or not state.people.has(person_id) or not bool(state.people[person_id].alive):
  return {"ok":false,"reason":"A living house member and a recorded title are required."}
 var title: Dictionary = state.titles[title_id]
 var old_holder := str(title.get("holder",""))
 if state.people.has(old_holder):
  var former: Dictionary = state.people[old_holder]
  var former_titles: Array = former.get("title_ids",[])
  former_titles.erase(title_id)
  former["title_ids"] = former_titles
  former["title_id"] = str(former_titles.back()) if not former_titles.is_empty() else ""
  state.people[old_holder] = former
 title["holder"] = person_id
 state.titles[title_id] = title
 var person: Dictionary = state.people[person_id]
 var person_titles: Array = person.get("title_ids",[])
 if not person_titles.has(title_id):
  person_titles.append(title_id)
 person["title_ids"] = person_titles
 person["title_id"] = title_id
 state.people[person_id] = person
 _log(state,"title_granted",{"title":title_id,"holder":person_id})
 return {"ok":true,"state":state}


static func update_domain(raw: Dictionary, domain_id: String, field: String, value: int) -> Dictionary:
 var state := normalize_state(raw)
 if not state.domains.has(domain_id) or not ["prosperity","security","food","legitimacy"].has(field):
  return {"ok":false,"reason":"Unknown domain or stewardship measure."}
 var domain: Dictionary = state.domains[domain_id]
 domain[field] = clampi(value,0,100)
 state.domains[domain_id] = domain
 _log(state,"domain_stewardship",{"domain":domain_id,"field":field,"value":domain[field]})
 return {"ok":true,"state":state}


static func create_domain(raw: Dictionary, name: String, steward_id: String) -> Dictionary:
 var state := normalize_state(raw)
 if name.strip_edges().length() < 3 or not state.people.has(steward_id) or not bool(state.people[steward_id].alive):
  return {"ok":false,"reason":"A named holding and living steward are required."}
 var domain_id := "domain_%02d" % (state.domains.size()+1)
 state.domains[domain_id] = {"id":domain_id,"name":name.strip_edges(),"steward":steward_id,"prosperity":35,"security":35,"food":40,"legitimacy":40,"notes":"A new holding under the Concord's duties of stewardship."}
 var person: Dictionary = state.people[steward_id]
 person.domain_ids.append(domain_id)
 state.people[steward_id] = person
 _log(state,"domain_founded",{"domain":domain_id,"steward":steward_id})
 return {"ok":true,"state":state,"domain_id":domain_id}


static func create_title(raw: Dictionary, rank_id: String, name: String, holder_id: String, domain_id: String) -> Dictionary:
 var state := normalize_state(raw)
 var rank: Dictionary = {}
 for item in RANKS:
  if str(item.id) == rank_id:
   rank = item
 if rank.is_empty() or name.strip_edges().length() < 3 or not state.people.has(holder_id) or not bool(state.people[holder_id].alive) or not state.domains.has(domain_id):
  return {"ok":false,"reason":"Choose a valid rank, title name, living holder and domain."}
 var highest := 0
 for existing in state.titles.values():
  var existing_rank := _rank_value(str(existing.get("rank_id","")))
  highest = maxi(highest,existing_rank)
 if int(rank.rank) != highest + 1:
  return {"ok":false,"reason":"Establish each intervening rank before advancing to a higher title."}
 var title_id := "title_%02d" % (state.titles.size()+1)
 state.titles[title_id] = {"id":title_id,"rank_id":rank_id,"name":name.strip_edges(),"holder":holder_id,"domain_id":domain_id,"jurisdiction":str(rank.jurisdiction),"obligations":[str(rank.duties)],"legitimacy":40}
 var person: Dictionary = state.people[holder_id]
 var person_titles: Array = person.get("title_ids",[])
 person_titles.append(title_id)
 person["title_ids"] = person_titles
 person["title_id"] = title_id
 state.people[holder_id] = person
 _log(state,"title_established",{"title":title_id,"rank":rank_id,"holder":holder_id})
 return {"ok":true,"state":state,"title_id":title_id}


static func _rank_value(rank_id: String) -> int:
 for rank in RANKS:
  if str(rank.id) == rank_id:
   return int(rank.rank)
 return 0


static func advance_year(raw: Dictionary) -> Dictionary:
 var state := normalize_state(raw)
 if state.is_empty():
  return {"ok":false,"reason":"No valid house chronicle is loaded."}
 state.year = int(state.year) + 1
 var deaths: Array = []
 var people: Dictionary = state.people
 for id in people.keys():
  var person: Dictionary = people[id]
  if bool(person.alive):
   person.age = int(person.age) + 1
   if int(person.age) >= NATURAL_OLD_AGE:
    person.alive = false
    person.death_cause = "old_age"
    deaths.append(str(id))
  people[id] = person
 state.people = people
 var domains: Dictionary = state.domains
 for domain_id in domains.keys():
  var domain: Dictionary = domains[domain_id]
  if int(domain.get("food",0)) > 20 and int(domain.get("security",0)) > 20:
   domain["prosperity"] = clampi(int(domain.get("prosperity",0))+1,0,100)
   domain["legitimacy"] = clampi(int(domain.get("legitimacy",0))+1,0,100)
  else:
   domain["prosperity"] = clampi(int(domain.get("prosperity",0))-2,0,100)
   domain["legitimacy"] = clampi(int(domain.get("legitimacy",0))-2,0,100)
  domain["food"] = clampi(int(domain.get("food",0))-1,0,100)
  domains[domain_id] = domain
 state.domains = domains
 for dead_id in deaths:
  _inherit_titles(state,dead_id)
 _log(state,"year_advanced",{"year":state.year,"deaths":deaths})
 return {"ok":true,"state":state,"deaths":deaths}


static func _inherit_titles(state: Dictionary, deceased_id: String) -> void:
 var titles: Dictionary = state.titles
 for title_id in titles.keys():
  var title: Dictionary = titles[title_id]
  if str(title.get("holder","")) != deceased_id:
   continue
  var heir := _select_heir(state,deceased_id)
  var former: Dictionary = state.people[deceased_id]
  var former_titles: Array = former.get("title_ids",[])
  former_titles.erase(title_id)
  former["title_ids"] = former_titles
  former["title_id"] = str(former_titles.back()) if not former_titles.is_empty() else ""
  state.people[deceased_id] = former
  title["holder"] = heir
  titles[title_id] = title
  if heir != "":
   var p: Dictionary = state.people[heir]
   var inherited_titles: Array = p.get("title_ids",[])
   if not inherited_titles.has(title_id):
    inherited_titles.append(title_id)
   p["title_ids"] = inherited_titles
   p["title_id"] = title_id
   state.people[heir] = p
  state.last_succession = {"title_id":title_id,"from":deceased_id,"to":heir,"policy":state.succession_policy,"year":state.year}
 state.titles = titles
 if str(state.succession_policy) == "equal_partition":
  var deceased: Dictionary = state.people[deceased_id]
  var heirs: Array = []
  for child_id in deceased.children:
   if state.people.has(child_id) and bool(state.people[child_id].alive):
    heirs.append(str(child_id))
  heirs.sort()
  if not heirs.is_empty():
   var domains: Dictionary = state.domains
   var share := 0
   for domain_id in domains.keys():
    var domain: Dictionary = domains[domain_id]
    if str(domain.get("steward","")) == deceased_id:
     domain["steward"] = heirs[share % heirs.size()]
     domains[domain_id] = domain
     share += 1
   state.domains = domains


static func _select_heir(state: Dictionary, deceased_id: String) -> String:
 var deceased: Dictionary = state.people[deceased_id]
 var candidates: Array = []
 for child_id in deceased.children:
  if state.people.has(child_id) and bool(state.people[child_id].alive):
   candidates.append(child_id)
 if candidates.is_empty():
  var spouse_id := str(deceased.get("spouse",""))
  if spouse_id != "" and state.people.has(spouse_id) and bool(state.people[spouse_id].alive):
   candidates.append(spouse_id)
 if candidates.is_empty():
  for sibling_id in deceased.get("siblings",[]):
   if state.people.has(str(sibling_id)) and bool(state.people[str(sibling_id)].alive):
    candidates.append(str(sibling_id))
 if candidates.is_empty():
  for parent_id in deceased.get("parents",[]):
   if state.people.has(str(parent_id)) and bool(state.people[str(parent_id)].alive):
    candidates.append(str(parent_id))
 if candidates.is_empty():
  return ""
 match str(state.succession_policy):
  "designated_heir":
   var designated := str(state.designated_heir)
   if candidates.has(designated):
    return designated
  "seniority":
   candidates.sort_custom(func(a,b): return int(state.people[a].age) > int(state.people[b].age))
  "elective":
   var elected := str(state.designated_heir)
   if candidates.has(elected):
    return elected
   candidates.sort_custom(func(a,b): return int(state.people[a].age) > int(state.people[b].age))
  "equal_partition":
   candidates.sort()
  _:
   candidates.sort_custom(func(a,b):
    var pa: Dictionary = state.people[a]
    var pb: Dictionary = state.people[b]
    if int(pa.get("born_year",0)) != int(pb.get("born_year",0)):
     return int(pa.get("born_year",0)) < int(pb.get("born_year",0))
    return str(a) < str(b))
 return str(candidates[0])


static func _log(state: Dictionary, event: String, details: Dictionary) -> void:
 var log: Array = state.get("chronicle",[])
 log.append({"year":int(state.get("year",1)),"event":event,"details":details.duplicate(true)})
 if log.size() > 500:
  log.pop_front()
 state.chronicle = log


static func person_summary(person: Dictionary) -> String:
 var traits: Array = person.get("traits",[])
 var trait_names: Array = []
 for trait_id in traits:
  trait_names.append(str(trait_id).replace("_"," ").capitalize())
 var spouse := str(person.get("spouse",""))
 var children: Array = person.get("children",[])
 var title_ids: Array = person.get("title_ids",[])
 var title_label := ", ".join(title_ids) if not title_ids.is_empty() else "none"
 return "%s, age %d • %s • %s • spouse: %s • children: %d • titles: %s" % [str(person.get("name","Unnamed")),int(person.get("age",0)),"living" if bool(person.get("alive",false)) else "deceased",", ".join(trait_names) if not trait_names.is_empty() else "no recorded traits",spouse if spouse != "" else "none",children.size(),title_label]
