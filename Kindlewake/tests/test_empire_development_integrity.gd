extends SceneTree

const Development = preload("res://scripts/core/empire_development_system.gd")

var checks: int = 0
var failures: int = 0


func _initialize() -> void:
    _test_recruit_and_assign()
    _test_garrison_limit()
    _test_invalid_requests()
    _test_malformed_reserves()
    print("Empire development integrity checks: %d   Failures: %d" % [checks, failures])
    quit(1 if failures > 0 else 0)


func check(condition: bool, label: String) -> void:
    checks += 1
    if condition:
        print("  ok    " + label)
    else:
        failures += 1
        print("  FAIL  " + label)


func _base_flags() -> Dictionary:
    return {
        "holding_claimed_keep": true,
        "holding_owner_keep": "house_dunmarrow",
        "empire_stockpile_provisions": 100
    }


func _test_recruit_and_assign() -> void:
    var flags := _base_flags()
    var recruited := Development.recruit("keep", "archer", 3, flags, 1000)
    check(bool(recruited.get("ok", false)), "valid recruitment still creates a strategic reserve")
    check(int(flags.get("empire_stockpile_provisions", 0)) == 88 and int(flags["holding_recruits_keep"]["archer"]) == 3,
        "successful recruitment spends provisions once and records the exact reserve")
    var assigned := Development.assign_recruits_to_garrison("keep", "archer", 2, flags)
    check(bool(assigned.get("ok", false)) and int(assigned.get("assigned", 0)) == 2,
        "valid reserve assignment transfers the requested troop count")
    check(int(flags["holding_garrison_keep"]) == 2 and int(flags["holding_recruits_keep"]["archer"]) == 1,
        "assignment updates garrison and reserve atomically")


func _test_garrison_limit() -> void:
    var flags := _base_flags()
    flags["holding_garrison_keep"] = 998
    flags["holding_recruits_keep"] = {"archer": 3}
    var result := Development.assign_recruits_to_garrison("keep", "archer", 3, flags)
    check(bool(result.get("ok", false)) and int(result.get("assigned", 0)) == 1,
        "reserve assignment only transfers the remaining capacity below 999")
    check(int(flags["holding_garrison_keep"]) == 999 and int(flags["holding_recruits_keep"]["archer"]) == 2,
        "garrison never exceeds the 999-soldier cap and unassigned troops remain in reserve")


func _test_invalid_requests() -> void:
    var flags := _base_flags()
    flags["holding_recruits_keep"] = {"archer": 3}
    var before := flags.duplicate(true)
    var unknown := Development.assign_recruits_to_garrison("keep", "dragon", 1, flags)
    check(not bool(unknown.get("ok", true)) and flags == before,
        "unknown troop IDs cannot be converted into garrison soldiers")
    var zero := Development.assign_recruits_to_garrison("keep", "archer", 0, flags)
    var negative := Development.assign_recruits_to_garrison("keep", "archer", -1, flags)
    check(not bool(zero.get("ok", true)) and not bool(negative.get("ok", true)) and flags == before,
        "zero and negative assignment amounts are rejected without mutation")
    flags["holding_garrison_keep"] = "many"
    var malformed_garrison := flags.duplicate(true)
    var invalid_count := Development.assign_recruits_to_garrison("keep", "archer", 1, flags)
    check(not bool(invalid_count.get("ok", true)) and flags == malformed_garrison,
        "malformed garrison counts are rejected without consuming reserves")


func _test_malformed_reserves() -> void:
    var flags := _base_flags()
    flags["holding_recruits_keep"] = "corrupt"
    var before := flags.duplicate(true)
    var assign_result := Development.assign_recruits_to_garrison("keep", "archer", 1, flags)
    check(not bool(assign_result.get("ok", true)) and flags == before,
        "malformed reserve containers fail safely without mutation")
    var recruit_result := Development.recruit("keep", "archer", 1, flags, 1000)
    check(not bool(recruit_result.get("ok", true)) and flags == before,
        "recruitment refuses malformed reserve containers before spending resources")
    flags["holding_recruits_keep"] = {"archer": "three"}
    var malformed_count := flags.duplicate(true)
    var assign_count_result := Development.assign_recruits_to_garrison("keep", "archer", 1, flags)
    var recruit_count_result := Development.recruit("keep", "archer", 1, flags, 1000)
    check(not bool(assign_count_result.get("ok", true)) and not bool(recruit_count_result.get("ok", true)) and flags == malformed_count,
        "malformed troop counts fail safely and preserve the existing reserve")
