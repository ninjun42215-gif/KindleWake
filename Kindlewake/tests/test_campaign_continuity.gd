extends SceneTree
const ActOne = preload("res://scripts/core/opening_act_one_quest_system.gd")
const ActTwo = preload("res://scripts/core/act_two_quest_system.gd")
const ActThree = preload("res://scripts/core/act_three_quest_system.gd")
const ActFour = preload("res://scripts/core/act_four_quest_system.gd")
const ActFive = preload("res://scripts/core/act_five_quest_system.gd")
const Chronicle = preload("res://scripts/core/chronicle_system.gd")
var failures := 0
var checks := 0
func _initialize() -> void:
 var flags: Dictionary = {}
 _check(not bool(ActTwo.inspect("boundary_tree",flags).available),"Act II is locked before Act I")
 _check(not bool(ActThree.inspect("three_bridges",flags).available),"Act III is locked before Act II")
 _check(not bool(ActFour.inspect("quillon_archive",flags).available),"Act IV is locked before Act III")
 _check(not bool(ActFive.inspect(flags).available),"Act V is locked before Act IV")
 for pair in [["blocked_well","clear_well"],["blocked_well","test_well"],["roof_before_banner","salvage_roof_timber"],["roof_before_banner","secure_roof"],["last_convoy","escort_convoy"],["toll_book","seal_names"],["first_oath","oath_people"]]:
  var result: Dictionary = ActOne.resolve(str(pair[0]),str(pair[1]),flags)
  _check(bool(result.get("ok",false)),"Act I action: "+str(pair[1]))
  if bool(result.get("ok",false)):
   flags = result.world_flags
 _check(bool(flags.get("chapter_1_complete",false)),"Act I completion flag opens next chapter")
 var two := ActTwo.apply_boundary(flags,"shared_stewardship")
 _check(bool(two.ok),"Act II boundary resolves")
 flags = two.world_flags
 two = ActTwo.apply_hearing(flags,"protect_witness")
 _check(bool(two.ok),"Act II hearing resolves")
 flags = two.world_flags
 flags["act2_escort_captain_defeated"] = true
 two = ActTwo.apply_escort(flags,"grant_sanctuary")
 _check(bool(two.ok) and bool(two.world_flags.get("chapter_2_complete",false)),"Act II escort completes and opens Act III")
 flags = two.world_flags
 flags["act3_three_bridges_victory"] = true
 var three := ActThree.apply_bridges(flags)
 _check(bool(three.ok),"Act III bridge battle victory is accepted")
 flags = three.world_flags
 three = ActThree.apply_banner(flags,"protect_deserters")
 _check(bool(three.ok),"Act III banner choice resolves")
 flags = three.world_flags
 three = ActThree.apply_crossing(flags,"evacuate_families")
 _check(bool(three.ok) and bool(three.world_flags.get("chapter_3_complete",false)),"Act III crossing completes and opens Act IV")
 flags = three.world_flags
 var four := ActFour.apply_archive_access(flags,"coalition_mediation")
 _check(bool(four.ok),"Act IV archive access resolves")
 flags = four.world_flags
 four = ActFour.apply_archive_record(flags,"publish_verified_copy")
 _check(bool(four.ok),"Act IV record decision resolves")
 flags = four.world_flags
 four = ActFour.apply_witness(flags,"investigate_threat")
 _check(bool(four.ok) and bool(four.world_flags.get("chapter_4_complete",false)),"Act IV witness choice completes and opens Act V")
 flags = four.world_flags
 _check(not bool(flags.get("act4_witness_testimony_usable",true)),"Act IV withdrawn testimony is not made usable")
 var five := ActFive.choose_route(flags,"river_compact")
 _check(bool(five.ok),"Act V route selected")
 flags = five.world_flags
 five = ActFive.resolve_route_action(flags,"repair_ferry")
 _check(bool(five.ok),"Act V route action reaches Aurelmont")
 flags = five.world_flags
 five = ActFive.evidence_board(flags)
 _check(bool(five.ok) and int(five.world_flags.get("act5_evidence_count",0)) >= 6,"Act V evidence board carries prior act consequences")
 flags = five.world_flags
 for pair in [["granary_fire","open_granaries"],["archive_fire","save_records"],["river_fire","evacuate_quays"]]:
  five = ActFive.resolve_fire(flags,str(pair[0]),str(pair[1]))
  _check(bool(five.ok),"Act V crisis: "+str(pair[0]))
  if bool(five.ok):
   flags = five.world_flags
 _check(not bool(ActFive.resolve_fire(flags,"granary_fire","save_grain").ok),"Act V rejects replaying an already resolved crisis")
 five = ActFive.resolve_audience(flags,"open_concord")
 _check(bool(five.ok),"Act V final audience resolves")
 flags = five.world_flags
 _check(bool(flags.campaign_completed) and bool(flags.became_last_emperor) and bool(flags.empire_dissolved) and bool(flags.concord_of_free_realms_established),"ending records the last Emperor, dissolution and Concord")
 var state := Chronicle.new_state()
 _check(not Chronicle.is_unlocked(state),"Chronicle starts locked")
 _check(Chronicle.record_milestone(state,"campaign_completed"),"Chronicle records campaign completion")
 _check(Chronicle.record_milestone(state,"became_last_emperor"),"Chronicle records last Emperor milestone")
 _check(Chronicle.record_milestone(state,"empire_dissolved"),"Chronicle records dissolution milestone")
 _check(not Chronicle.record_milestone(state,"natural_old_age_death",{"cause":"battle","protagonist_id":"torren"}),"Chronicle rejects battle death as founder unlock")
 _check(not Chronicle.is_unlocked(state),"Chronicle remains locked after imperial dissolution")
 _check(Chronicle.record_milestone(state,"epilogue_completed"),"Chronicle requires and records late-life epilogue")
 _check(not Chronicle.record_milestone(state,"natural_old_age_death",{"cause":"old_age"}),"Chronicle requires founder identity")
 _check(Chronicle.record_milestone(state,"natural_old_age_death",{"cause":"old_age","protagonist_id":"torren","age_at_death":87,"ending_id":"open_concord"}),"Chronicle accepts verified natural old-age death")
 _check(Chronicle.is_unlocked(state),"Chronicle unlocks only after all founder milestones")
 var serialized := JSON.parse_string(JSON.stringify(state))
 _check(Chronicle.is_unlocked(Chronicle.normalize_state(serialized)),"Chronicle gate survives JSON save/load normalization")
 var forged := {"milestones":{},"unlocked":true,"founder_record":{"cause":"old_age","protagonist_id":"torren"}}
 _check(not Chronicle.is_unlocked(Chronicle.normalize_state(forged)),"Chronicle ignores forged unlocked flag")
 print("Campaign continuity checks: %d   Failures: %d" % [checks,failures])
 quit(1 if failures > 0 else 0)
func _check(ok: bool, label: String) -> void:
 checks += 1
 if ok:
  print("  ok  "+label)
 else:
  failures += 1
  print("  FAIL  "+label)
