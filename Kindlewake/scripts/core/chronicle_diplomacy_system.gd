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
 var p: Variant = state.get("politics",{})
 if typeof(p) != TYPE_DICTIONARY:
  state.erase("politics")
  return state
 p = p.duplicate(true)
 p["version"] = VERSION
 p["houses"] = p.get("houses",{}) if typeof(p.get("houses",{})) == TYPE_DICTIONARY else {}
 p["relations"] = p.get("relations",{}) if typeof(p.get("relations",{})) == TYPE_DICTIONARY else {}
 p["influence"] = clampi(int(p.get("influence",50)),0,100)
 p["reputation"] = clampi(int(p.get("reputation",50)),0,100)
 p["year"] = maxi(1,int(p.get("year",state.get("year",1))))
 p["events"] = p.get("events",[]) if typeof(p.get("events",[])) == TYPE_ARRAY else []
 for id in p.houses.keys():
  var h: Variant = p.houses[id]
  if typeof(h) != TYPE_DICTIONARY:
   p.houses.erase(id)
   continue
  h = h.duplicate(true)
  h["id"] = str(id)
  for metric in ["influence","legitimacy","treasury","food","military"]:
   h[metric] = clampi(int(h.get(metric,0)),0,100)
  p.houses[id] = h
 for key in p.relations.keys():
  var r: Variant = p.relations[key]
  if typeof(r) != TYPE_DICTIONARY:
   p.relations.erase(key)
   continue
  r = r.duplicate(true)
  r["score"] = clampi(int(r.get("score",0)),MIN_RELATION,MAX_RELATION)
  r["feud"] = bool(r.get("feud",false))
  r["allied"] = bool(r.get("allied",false)) and not r.feud
  r["history"] = r.get("history",[]) if typeof(r.get("history",[])) == TYPE_ARRAY else []
  p.relations[key] = r
 state["politics"] = p
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
   if int(s.politics.influence) < 3 or int(s.politics.houses[b].treasury) >= 100: return {"ok":false,"reason":"The gift is unaffordable or unnecessary."}
   s.politics.influence -= 3
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
 _event(s,"political_year_advanced",{"year":s.politics.year})
 return {"ok":true,"state":s}

static func summary(s: Dictionary,id: String) -> String:
 var h: Dictionary = s.get("politics",{}).get("houses",{}).get(id,{})
 if h.is_empty(): return "Unknown house"
 return "%s — %s | Influence %d | Legitimacy %d | Treasury %d | Food %d | Military %d" % [h.get("name",id),h.get("leader","Unknown"),int(h.influence),int(h.legitimacy),int(h.treasury),int(h.food),int(h.military)]
