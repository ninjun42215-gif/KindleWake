extends SceneTree

const CompanionQuestSystem = preload("res://scripts/core/companion_quest_system.gd")

var checks: int = 0
var failures: int = 0


func _initialize() -> void:
    var catalog := {
        "quests": {
            "sample": {
                "milestones": ["evidence_found", "witness_heard", "decision_recorded"],
                "outcomes": ["publish_record", "protect_witness"]
            }
        }
    }
    _test_valid_states(catalog)
    _test_incomplete_completion_recovery(catalog)
    _test_malformed_progress(catalog)
    _test_non_finite_progress(catalog)
    _test_runtime_guards(catalog)
    print("Companion quest normalization checks: %d   Failures: %d" % [checks, failures])
    quit(1 if failures > 0 else 0)


func check(condition: bool, label: String) -> void:
    checks += 1
    if condition:
        print("  ok    " + label)
    else:
        failures += 1
        print("  FAIL  " + label)


func _test_valid_states(catalog: Dictionary) -> void:
    var valid := CompanionQuestSystem.normalize_state({
        "sample": {
            "status": "complete",
            "progress": 3,
            "choices": {"witness_heard": "protected"},
            "outcome": "protect_witness"
        }
    }, catalog)
    var state: Dictionary = valid.get("sample", {})
    check(state.get("status", "") == "complete", "fully progressed quest with a known outcome remains complete")
    check(int(state.get("progress", -1)) == 3 and state.get("outcome", "") == "protect_witness",
        "valid completion preserves progress and its chosen outcome")
    check(state.get("choices", {}).get("witness_heard", "") == "protected",
        "valid milestone choices survive normalization")

    var active := CompanionQuestSystem.normalize_state({
        "sample": {"status": "active", "progress": 1, "outcome": "publish_record"}
    }, catalog)
    check(active.sample.status == "active" and active.sample.outcome == "",
        "active quest keeps its progress but clears a stale completion outcome")

    var ready := CompanionQuestSystem.normalize_state({
        "sample": {"status": "ready", "progress": 3}
    }, catalog)
    check(ready.sample.status == "ready", "fully progressed ready quest remains ready")


func _test_incomplete_completion_recovery(catalog: Dictionary) -> void:
    var incomplete := CompanionQuestSystem.normalize_state({
        "sample": {"status": "complete", "progress": 1, "outcome": "publish_record"}
    }, catalog)
    check(incomplete.sample.status == "active", "completed snapshot missing milestones is reopened as active")
    check(int(incomplete.sample.progress) == 1 and incomplete.sample.outcome == "",
        "incomplete completion recovery preserves earned progress and clears the forged outcome")

    var fractional_complete := CompanionQuestSystem.normalize_state({
        "sample": {"status": "complete", "progress": 3.5, "outcome": "publish_record"}
    }, catalog)
    check(fractional_complete.sample.status == "ready" and int(fractional_complete.sample.progress) == 3 and fractional_complete.sample.outcome == "",
        "fractional saved progress cannot retain a completed quest state")

    var invalid_outcome := CompanionQuestSystem.normalize_state({
        "sample": {"status": "complete", "progress": 3, "outcome": "invented_outcome"}
    }, catalog)
    check(invalid_outcome.sample.status == "ready" and invalid_outcome.sample.outcome == "",
        "fully progressed completion with an unknown outcome returns to the resolution step")

    var partial_ready := CompanionQuestSystem.normalize_state({
        "sample": {"status": "ready", "progress": 2}
    }, catalog)
    check(partial_ready.sample.status == "active", "ready snapshot with missing milestones returns to active progress")

    var full_active := CompanionQuestSystem.normalize_state({
        "sample": {"status": "active", "progress": 3}
    }, catalog)
    check(full_active.sample.status == "ready", "active snapshot with all milestones advances to ready")


func _test_malformed_progress(catalog: Dictionary) -> void:
    var negative := CompanionQuestSystem.normalize_state({
        "sample": {"status": "active", "progress": -4}
    }, catalog)
    check(int(negative.sample.progress) == 0, "negative saved progress is clamped to zero")

    var excessive := CompanionQuestSystem.normalize_state({
        "sample": {"status": "active", "progress": 99}
    }, catalog)
    check(int(excessive.sample.progress) == 3 and excessive.sample.status == "ready",
        "saved progress above the milestone count is clamped and reconciled")

    var non_numeric := CompanionQuestSystem.normalize_state({
        "sample": {"status": "active", "progress": "not-a-number"}
    }, catalog)
    check(int(non_numeric.sample.progress) == 0, "non-numeric saved progress safely resets to zero")

    var malformed_choices := CompanionQuestSystem.normalize_state({
        "sample": {"status": "active", "progress": 1, "choices": ["not", "a", "dictionary"]}
    }, catalog)
    check(malformed_choices.sample.choices.is_empty(), "malformed saved choices are replaced with an empty dictionary")

    var discarded := CompanionQuestSystem.normalize_state({
        "unknown_quest": {"status": "complete", "progress": 3, "outcome": "publish_record"},
        "sample": {"status": "invalid", "progress": 3}
    }, catalog)
    check(discarded.is_empty(), "unknown quests and unsupported statuses are discarded")


func _test_runtime_guards(catalog: Dictionary) -> void:
    var forged_ready := {
        "sample": {"status": "ready", "progress": 1, "outcome": ""}
    }
    var rejected := CompanionQuestSystem.resolve(forged_ready, "sample", "publish_record", catalog)
    check(not bool(rejected.get("ok", false)) and forged_ready.sample.status == "ready",
        "runtime resolution rejects a ready flag that has not completed every milestone")

    var fractional_ready := {
        "sample": {"status": "ready", "progress": 3.5, "outcome": ""}
    }
    var fractional_result := CompanionQuestSystem.resolve(fractional_ready, "sample", "publish_record", catalog)
    check(not bool(fractional_result.get("ok", false)),
        "runtime resolution rejects fractional milestone progress")

    var valid_ready := {
        "sample": {"status": "ready", "progress": 3, "outcome": ""}
    }
    var accepted := CompanionQuestSystem.resolve(valid_ready, "sample", "publish_record", catalog)
    check(bool(accepted.get("ok", false)) and valid_ready.sample.status == "complete",
        "runtime resolution still accepts a fully completed quest")

    var malformed := {"sample": "corrupt"}
    check(CompanionQuestSystem.status(malformed, "sample") == "not_started",
        "status lookup safely handles a malformed quest record")
    var advance_result := CompanionQuestSystem.advance(malformed, "sample", "evidence_found", catalog)
    check(not bool(advance_result.get("ok", false)),
        "milestone advancement rejects a malformed quest record without a type error")


func _test_non_finite_progress(catalog: Dictionary) -> void:
	var non_finite_recovered := true
	for malformed_value in [NAN, INF, -INF]:
		var normalized := CompanionQuestSystem.normalize_state({
			"sample": {"status": "complete", "progress": malformed_value, "outcome": "publish_record"}
		}, catalog)
		non_finite_recovered = non_finite_recovered and normalized.sample.status == "active"
		non_finite_recovered = non_finite_recovered and int(normalized.sample.progress) == 0
		non_finite_recovered = non_finite_recovered and normalized.sample.outcome == ""
	check(non_finite_recovered, "NaN and positive/negative infinity reopen completion safely without integer conversion")

	var huge_finite := CompanionQuestSystem.normalize_state({
		"sample": {"status": "active", "progress": 1.0e300}
	}, catalog)
	check(huge_finite.sample.status == "ready" and int(huge_finite.sample.progress) == 3,
		"very large finite progress is clamped to milestone count before integer conversion")

	var runtime_rejected := true
	for malformed_value in [NAN, INF, -INF, 1.0e300]:
		var state := {"sample": {"status": "ready", "progress": malformed_value, "outcome": ""}}
		var result := CompanionQuestSystem.resolve(state, "sample", "publish_record", catalog)
		runtime_rejected = runtime_rejected and not bool(result.get("ok", true)) and state.sample.status == "ready"
	check(runtime_rejected, "runtime resolution rejects non-finite and out-of-range progress without mutating quest state")
