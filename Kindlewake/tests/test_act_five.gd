extends SceneTree
const System = preload("res://scripts/core/act_five_quest_system.gd")
var failures := 0
func _initialize() -> void:
 var flags := {"chapter_1_complete":true,"chapter_2_complete":true,"chapter_3_complete":true,"chapter_4_complete":true,"act4_archive_resolved":true,"act4_original_preserved":true,"act4_edmer_revision_found":true,"act4_witness_agency_respected":true,"act4_witness_testimony_usable":false,"act4_threat_investigation_complete":true}
 _check(not bool(System.inspect({}).available),"Act V remains locked before Act IV")
 _check(bool(System.inspect(flags).available),"Act V opens after Act IV")
 var route := System.choose_route(flags,"veyrwood_canopy")
 _check(bool(route.ok),"Veyrwood route can be selected")
 flags = route.world_flags
 var action := System.resolve_route_action(flags,"mark_safe_trail")
 _check(bool(action.ok) and bool(action.world_flags.act5_aurelmont_reached),"route action reaches Aurelmont")
 flags = System.evidence_board(action.world_flags).world_flags
 _check(bool(flags.act5_witness_conclave_complete) and not bool(flags.act5_withdrawn_testimony_used),"evidence assembly respects withdrawn testimony")
 for pair in [["granary_fire","open_granaries"],["archive_fire","save_records"],["river_fire","evacuate_quays"]]:
  var result: Dictionary = System.resolve_fire(flags,str(pair[0]),str(pair[1]))
  _check(bool(result.ok),"crisis resolves in order: "+str(pair[0]))
  flags = result.world_flags
 var ending := System.resolve_audience(flags,"open_concord")
 _check(bool(ending.ok),"final audience accepts a valid Concord")
 flags = ending.world_flags
 _check(bool(flags.campaign_completed) and bool(flags.became_last_emperor) and bool(flags.empire_dissolved) and bool(flags.concord_of_free_realms_established),"ending preserves last Emperor, dissolution and Concord sequence")
 _check(not bool(flags.chronicle_unlocked),"Chronicle remains locked until old-age death")
 var skipped := System.resolve_fire(flags,"river_fire","hold_bridge")
 _check(not bool(skipped.ok),"duplicate or out-of-sequence crises are rejected")
 print("Act V checks complete. Failures: %d" % failures)
 quit(1 if failures > 0 else 0)
func _check(value: bool, label: String) -> void:
 if value:
  print("  ok  "+label)
 else:
  failures += 1
  print("  FAIL  "+label)
