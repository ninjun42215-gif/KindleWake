extends RefCounted
## Deterministic offline inter-house diplomacy for Chronicle of Houses.
const VERSION := 1
const MIN_RELATION := -100
const MAX_RELATION := 100
const ALLIANCE_THRESHOLD := 60
const RIVALRY_THRESHOLD := -50
const HOUSE_SEEDS := [
 {"id":"house_ashcombe","name":"House Ashcombe","leader":"Lady Ysabet Ashcombe","motto":"A just road outlasts a strong gate","influence":48,"legitimacy":62,"treasury":70,"food":58,"military":42},
 {"id":"house_merevale","name":"House Merevale","leader":"Count Owyn Merevale","motto":"Keep faith with the river","influence":55,"legitimacy":57,"treasury":54,"food":43,"military":51},
 {"id":"house_dunmar","name":"House Dunmar","leader":"Marquess Talia Dunmar","motto":"No oath without witnesses","influence":39,"legitimacy":68,"treasury":46,"food":61,"military":63}
]
const ACTIONS := ["envoy","gift","reconcile","declare_feud","propose_alliance","break_alliance"]

static func _key(a: String,b: String) -> String:
 var pair := [a,b]
 pair.sort()
 return "%s|%s" % [pair[0],pair[1]]

static func initialize(raw: Dictionary) -> Dictionary:
 var state := raw.duplicate(true)
 if typeof(state.get("politics",{})) == TYPE_DICTIONARY and not state.get("politics",{}).is_empty():
  return normalize(state)
 var houses := {"player_house":{"id":"player_house","name":str(state.get("house_name","House of the Open Hand")),"leader":"The Householder","motto":"Stewardship before dominion","influence":50,"legitimacy":60,"treasury":50,"food":50,"military":35}}
 for seed in HOUSE_SEEDS:
  houses[seed.id] = seed.duplicate(true)
 var relations := {}
 var ids: Array = houses.keys()
 ids.sort()
 for i in range(ids.size()):
  for j in range(i+1,ids.size()):
   var a := str(ids[i])
   var b := str(ids[j])
   var initial_score := 8 if a == "player_house" or b == "player_house" else (-18 if b == "house_dunmar" else 4)
   relations[_key(a,b)] = {"score":initial_score,"allied":false,"feud":false,"history":[]}
 state["politics"] = {"version":VERSION,"player_house":"player_house","houses":houses,"relations":relations,"influence":50,"reputation":50,"year":int(state.get("year",1)),"events":[]}
 return normalize(state)

static func normalize(raw: Dictionary) -> Dictionary:
 var state := raw.duplicate(true)
 var raw_politics: Variant = state.get("politics",{})
 if typeof(raw_politics) != TYPE_DICTIONARY:
  state.erase("politics")
  return initialize(state)
 var politics: Dictionary = raw_politics.duplicate(true)
 var raw_houses: Variant = politics.get("houses",{})
 var houses: Dictionary = raw_houses if typeof(raw_houses) == TYPE_DICTIONARY else {}
 for house_id in houses.keys():
  var raw_house: Variant = houses[house_id]
  if typeof(raw_house) != TYPE_DICTIONARY:
   houses.erase(house_id)
   continue
  var house: Dictionary = raw_house.duplicate(true)
  house["id"] = str(house_id)
  for metric in ["influence","legitimacy","treasury","food","military"]:
   house[metric] = clampi(int(house.get(metric,0)),0,100)
  houses[house_id] = house
 if houses.is_empty():
  state.erase("politics")
  return initialize(state)
 var player_house := str(politics.get("player_house","player_house"))
 if not houses.has(player_house):
  player_house = "player_house" if houses.has("player_house") else str(houses.keys()[0])
 var raw_relations: Variant = politics.get("relations",{})
 var relations: Dictionary = raw_relations if typeof(raw_relations) == TYPE_DICTIONARY else {}
 for relation_key in relations.keys():
  var parts: PackedStringArray = str(relation_key).split("|")
  if parts.size() != 2 or parts[0] == parts[1] or not houses.has(parts[0]) or not houses.has(parts[1]) or _key(parts[0],parts[1]) != str(relation_key):
   relations.erase(relation_key)
   continue
  var raw_relation: Variant = relations[relation_key]
  if typeof(raw_relation) != TYPE_DICTIONARY:
   relations.erase(relation_key)
   continue
  var relation: Dictionary = raw_relation.duplicate(true)
  relation["score"] = clampi(int(relation.get("score",0)),MIN_RELATION,MAX_RELATION)
  relation["feud"] = bool(relation.get("feud",false))
  relation["allied"] = bool(relation.get("allied",false)) and not bool(relation["feud"])
  var raw_history: Variant = relation.get("history",[])
  var history: Array = []
  if typeof(raw_history) == TYPE_ARRAY:
   for entry in raw_history:
    if typeof(entry) == TYPE_DICTIONARY:
     history.append(entry.duplicate(true))
  relation["history"] = history.slice(maxi(0,history.size()-20))
  relations[relation_key] = relation
 var house_ids: Array = houses.keys()
 house_ids.sort()
 for i in range(house_ids.size()):
  for j in range(i+1,house_ids.size()):
   var relation_key := _key(str(house_ids[i]),str(house_ids[j]))
   if not relations.has(relation_key):
    relations[relation_key] = {"score":0,"allied":false,"feud":false,"history":[]}
 var raw_events: Variant = politics.get("events",[])
 var events: Array = []
 if typeof(raw_events) == TYPE_ARRAY:
  for entry in raw_events:
   if typeof(entry) == TYPE_DICTIONARY:
    events.append(entry.duplicate(true))
 politics["version"] = VERSION
 politics["player_house"] = player_house
 politics["houses"] = houses
 politics["relations"] = relations
 politics["influence"] = clampi(int(politics.get("influence",50)),0,100)
 politics["reputation"] = clampi(int(politics.get("reputation",50)),0,100)
 politics["year"] = maxi(1,int(politics.get("year",state.get("year",1))))
 politics["events"] = events.slice(maxi(0,events.size()-100))
 state["politics"] = politics
 return state


static func relation_between(raw: Dictionary,a: String,b: String) -> Dictionary:
 var s := normalize(raw)
 if a == b or not s.get("politics",{}).get("houses",{}).has(a) or not s.get("politics",{}).get("houses",{}).has(b):
  return {}
 return s.politics.relations.get(_key(a,b),{}).duplicate(true)

static func relation_state(r: Dictionary) -> String:
 if bool(r.get("feud",false)): return "feud"
 if bool(r.get("allied",false)): return "allied"
 var score := int(r.get("score",0))
 if score <= RIVALRY_THRESHOLD: return "rival"
 if score >= ALLIANCE_THRESHOLD: return "friendly"
 return "neutral"

static func _event(s: Dictionary,event_id: String,details: Dictionary) -> void:
 var events: Array = s.politics.get("events",[])
 events.append({"year":int(s.politics.year),"event":event_id,"details":details.duplicate(true)})
 if events.size() > 100: events.pop_front()
 s.politics.events = events

static func change_relation(raw: Dictionary,a: String,b: String,delta: int,reason: String) -> Dictionary:
 var s := normalize(raw)
 var key := _key(a,b)
 if a == b or not s.get("politics",{}).get("houses",{}).has(a) or not s.politics.houses.has(b) or not s.politics.relations.has(key):
  return {"ok":false,"reason":"No diplomatic record exists for these two houses."}
 var r: Dictionary = s.politics.relations[key]
 r.score = clampi(int(r.score)+delta,MIN_RELATION,MAX_RELATION)
 r.history.append({"year":int(s.politics.year),"delta":delta,"reason":reason})
 if r.history.size() > 20: r.history.pop_front()
 if int(r.score) >= ALLIANCE_THRESHOLD and not r.feud: r.allied = true
 if int(r.score) <= RIVALRY_THRESHOLD: r.allied = false
 s.politics.relations[key] = r
 _event(s,"relations_changed",{"houses":[a,b],"score":r.score,"reason":reason})
 return {"ok":true,"state":s,"relation":r}

static func perform_action(raw: Dictionary,a: String,b: String,action: String) -> Dictionary:
 var s := normalize(raw)
 var key := _key(a,b)
 if not ACTIONS.has(action) or a == b or not s.get("politics",{}).get("relations",{}).has(key):
  return {"ok":false,"reason":"That diplomatic action or target is unavailable."}
 var r: Dictionary = s.politics.relations[key]
 match action:
  "envoy":
   if int(s.politics.influence) < 5: return {"ok":false,"reason":"Five influence is required."}
   s.politics.influence -= 5
   return change_relation(s,a,b,8,"envoy")
  "gift":
   var sender: Dictionary = s.politics.houses.get(a,{})
   var recipient: Dictionary = s.politics.houses.get(b,{})
   if int(s.politics.influence) < 3 or int(sender.get("treasury",0)) < 5 or int(recipient.get("treasury",0)) >= 100:
    return {"ok":false,"reason":"The gift requires three influence and five treasury, and the recipient must have room."}
   s.politics.influence -= 3
   sender.treasury = int(sender.get("treasury",0)) - 5
   recipient.treasury = mini(100,int(recipient.get("treasury",0))+5)
   s.politics.houses[a] = sender
   s.politics.houses[b] = recipient
   return change_relation(s,a,b,12,"gift")
  "reconcile":
   r.feud = false
   s.politics.relations[key] = r
   return change_relation(s,a,b,15,"reconciliation")
  "declare_feud":
   r.feud = true
   r.allied = false
   r.score = mini(-50,int(r.score))
   s.politics.relations[key] = r
   _event(s,"feud_declared",{"houses":[a,b]})
   return {"ok":true,"state":s,"relation":r}
  "propose_alliance":
   if r.feud or int(r.score) < ALLIANCE_THRESHOLD: return {"ok":false,"reason":"Alliance requires 60+ relation and no feud."}
   r.allied = true
   s.politics.relations[key] = r
   _event(s,"alliance_formed",{"houses":[a,b]})
   return {"ok":true,"state":s,"relation":r}
  "break_alliance":
   if not r.allied: return {"ok":false,"reason":"No alliance exists."}
   r.allied = false
   r.score = maxi(-100,int(r.score)-20)
   s.politics.relations[key] = r
   _event(s,"alliance_broken",{"houses":[a,b]})
   return {"ok":true,"state":s,"relation":r}
 return {"ok":false,"reason":"Action rejected."}

static func advance_political_year(raw: Dictionary) -> Dictionary:
 var s := normalize(raw)
 if not s.has("politics"): s = initialize(s)
 s.politics.year = int(s.politics.year)+1
 for id in s.politics.houses.keys():
  var h: Dictionary = s.politics.houses[id]
  if int(h.food) < 30:
   h.legitimacy = maxi(0,int(h.legitimacy)-3)
   h.influence = maxi(0,int(h.influence)-2)
  elif int(h.food) > 70:
   h.legitimacy = mini(100,int(h.legitimacy)+1)
  h.treasury = clampi(int(h.treasury)+(2 if int(h.legitimacy) >= 50 else -2),0,100)
  s.politics.houses[id] = h
 for key in s.politics.relations.keys():
  var r: Dictionary = s.politics.relations[key]
  if r.feud: r.score = maxi(-100,int(r.score)-2)
  elif int(r.score) > 0: r.score = mini(100,int(r.score)+1)
  elif int(r.score) < 0: r.score = maxi(-100,int(r.score)-1)
  if int(r.score) < ALLIANCE_THRESHOLD: r.allied = false
  s.politics.relations[key] = r
 var ai_result := resolve_rival_decisions(s)
 if bool(ai_result.get("ok",false)):
  s = ai_result.state
 _event(s,"political_year_advanced",{"year":s.politics.year})
 return {"ok":true,"state":s}

static func resolve_rival_decisions(raw: Dictionary) -> Dictionary:
 var s := normalize(raw)
 if not s.has("politics"):
  return {"ok":false,"reason":"Political records have not been initialized."}
 var player_house := str(s.politics.get("player_house","player_house"))
 var ids: Array = s.politics.houses.keys()
 ids.sort()
 for house_id_value in ids:
  var house_id := str(house_id_value)
  if house_id == player_house:
   continue
  for target_value in ids:
   var target_id := str(target_value)
   if target_id == house_id:
    continue
   var key := _key(house_id,target_id)
   if not s.politics.relations.has(key):
    continue
   var relation: Dictionary = s.politics.relations[key]
   var house: Dictionary = s.politics.houses[house_id]
   if bool(relation.feud) and int(relation.score) >= -35 and int(house.treasury) >= 40:
    relation.feud = false
    relation.score = mini(0,int(relation.score)+5)
    _event(s,"rival_house_reconciled",{"house":house_id,"target":target_id})
   elif not bool(relation.feud) and int(relation.score) >= ALLIANCE_THRESHOLD and not bool(relation.allied):
    relation.allied = true
    _event(s,"rival_house_alliance",{"house":house_id,"target":target_id})
   elif not bool(relation.feud) and int(relation.score) <= -65:
    relation.feud = true
    relation.allied = false
    _event(s,"rival_house_feud",{"house":house_id,"target":target_id})
   s.politics.relations[key] = relation
 return {"ok":true,"state":s}

static func summary(s: Dictionary,id: String) -> String:
 var h: Dictionary = s.get("politics",{}).get("houses",{}).get(id,{})
 if h.is_empty(): return "Unknown house"
 return "%s — %s | Influence %d | Legitimacy %d | Treasury %d | Food %d | Military %d" % [h.get("name",id),h.get("leader","Unknown"),int(h.influence),int(h.legitimacy),int(h.treasury),int(h.food),int(h.military)]
