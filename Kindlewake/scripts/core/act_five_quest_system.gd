extends RefCounted
class_name ActFiveQuestSystem
## The Kindling: route strategy, corroboration, simultaneous crises and the final constitutional choice.
const ROUTES := ["river_compact", "veyrwood_canopy", "imperial_ash_road"]
const ROUTE_ACTIONS := {
 "river_compact":["repair_ferry","share_rations"],
 "veyrwood_canopy":["mark_safe_trail","leave_supply_cache"],
 "imperial_ash_road":["negotiate_gate","march_at_cost"]
}
const FIRES := ["granary_fire", "archive_fire", "river_fire"]
static func inspect(flags: Dictionary) -> Dictionary:
 var ready := bool(flags.get("chapter_4_complete", false))
 return {"title":"THE KINDLING","available":ready and not bool(flags.get("chapter_5_complete", false)),"complete":bool(flags.get("chapter_5_complete", false)),"body":"Aurelmont is close enough to see its smoke. Three roads remain, each carrying a different debt. The final campaign is gated behind the Quillon witness decision." if ready else "The Quillon Archive and witness account must be resolved before the road to Aurelmont opens."}
static func choose_route(flags_in: Dictionary, route: String) -> Dictionary:
 if not bool(flags_in.get("chapter_4_complete", false)) or bool(flags_in.get("act5_route_chosen", false)):
  return _fail("The road to Aurelmont is not ready.")
 if not ROUTES.has(route):
  return _fail("That route is not available.")
 var flags := flags_in.duplicate(true)
 flags["act5_route_chosen"] = true
 flags["act5_route"] = route
 flags["act5_route_action_required"] = true
 flags["act5_route_support"] = 1
 flags["act5_route_cost"] = {"river_compact": "time", "veyrwood_canopy": "supplies", "imperial_ash_road": "political_trust"}[route]
 return _ok(flags, "The route is chosen. Its local challenge will decide what support reaches the capital.")
static func resolve_route_action(flags_in: Dictionary, action: String) -> Dictionary:
 var route := str(flags_in.get("act5_route", ""))
 if not bool(flags_in.get("act5_route_action_required", false)) or not ROUTE_ACTIONS.get(route, []).has(action):
  return _fail("That route action does not match the chosen road.")
 var flags := flags_in.duplicate(true)
 flags["act5_route_action_required"] = false
 flags["act5_route_action"] = action
 flags["act5_route_support"] = 2 if action in ["repair_ferry","mark_safe_trail","negotiate_gate"] else 1
 flags["act5_route_cost_paid"] = true
 flags["act5_aurelmont_reached"] = true
 return _ok(flags, "The company reaches Aurelmont. The road's help and cost are recorded.")
static func evidence_board(flags_in: Dictionary) -> Dictionary:
 if not bool(flags_in.get("act5_aurelmont_reached", false)):
  return _fail("The Seven Witnesses cannot be convened before the company reaches Aurelmont.")
 var flags := flags_in.duplicate(true)
 var evidence := {
  "sethmarch_people_and_road": bool(flags.get("chapter_1_complete", false)),
  "orrowen_boundary_and_hearing": bool(flags.get("chapter_2_complete", false)),
  "river_crossing_and_evacuation": bool(flags.get("chapter_3_complete", false)),
  "quillon_original_or_verified_copy": bool(flags.get("act4_original_preserved", false)) or bool(flags.get("act4_verified_copy_published", false)) or bool(flags.get("act4_custodian_compact", false)),
  "edmer_revision_context": bool(flags.get("act4_edmer_revision_found", false)),
  "threat_investigation": bool(flags.get("act4_threat_investigation_complete", false)),
  "regional_support": int(flags.get("act5_route_support", 0)) >= 2
 }
 flags["act5_evidence_board"] = evidence
 flags["act5_evidence_count"] = _count_true(evidence)
 flags["act5_witness_conclave_complete"] = true
 flags["act5_witness_withdrawal_respected"] = true
 flags["act5_withdrawn_testimony_used"] = false
 return _ok(flags, "Seven independent strands are laid before the assembly. No withdrawn testimony is presented as consent.")
static func resolve_fire(flags_in: Dictionary, fire_id: String, response: String) -> Dictionary:
 if not bool(flags_in.get("act5_witness_conclave_complete", false)) or bool(flags_in.get("act5_three_fires_complete", false)):
  return _fail("The three crises are not ready to be resolved.")
 var idx := FIRES.find(fire_id)
 if idx < 0:
  return _fail("Unknown crisis.")
 var expected := int(flags_in.get("act5_fires_resolved", 0))
 if idx != expected:
  return _fail("Resolve the crises in the order they reach the council.")
 var valid := {
  "granary_fire":["save_grain","open_granaries"],
  "archive_fire":["save_records","save_people"],
  "river_fire":["hold_bridge","evacuate_quays"]
 }
 if not valid[fire_id].has(response):
  return _fail("That response is not available for this crisis.")
 var flags := flags_in.duplicate(true)
 flags["act5_fire_" + fire_id] = response
 flags["act5_fires_resolved"] = expected + 1
 if fire_id == "granary_fire":
  flags["act5_food_security"] = "preserved" if response == "open_granaries" else "damaged"
 elif fire_id == "archive_fire":
  flags["act5_public_record"] = "preserved" if response == "save_records" else "people_first"
 else:
  flags["act5_civilian_safety"] = "held" if response == "evacuate_quays" else "contested"
 if expected + 1 == FIRES.size():
  flags["act5_three_fires_complete"] = true
 return _ok(flags, "The crisis response is entered. The other fronts continue to demand attention.")
static func resolve_audience(flags_in: Dictionary, decision: String) -> Dictionary:
 if not bool(flags_in.get("act5_three_fires_complete", false)) or bool(flags_in.get("chapter_5_complete", false)):
  return _fail("Maelor's final audience is not ready.")
 if not ["open_concord","guarded_concord","wounded_concord","narrow_concord"].has(decision):
  return _fail("That settlement is not available.")
 var flags := flags_in.duplicate(true)
 flags["act5_final_decision"] = decision
 flags["act5_ending_profile"] = decision
 flags["campaign_completed"] = true
 flags["became_last_emperor"] = true
 flags["empire_dissolved"] = true
 flags["concord_of_free_realms_established"] = true
 flags["chapter_5_complete"] = true
 flags["epilogue_pending"] = true
 flags["chronicle_unlocked"] = false
 flags["chronicle_founder_gate_complete"] = false
 return _ok(flags, "The protagonist becomes the last Emperor, dissolves the Empire and establishes the Concord. The settlement's character reflects the choices made along the road; the Chronicle remains sealed until a later-life epilogue and natural old-age death.")
static func _count_true(values: Dictionary) -> int:
 var count := 0
 for value in values.values():
  if bool(value):
   count += 1
 return count
static func _ok(flags: Dictionary, message: String) -> Dictionary:
 return {"ok":true,"world_flags":flags,"text":message}
static func _fail(reason: String) -> Dictionary:
 return {"ok":false,"reason":reason}
