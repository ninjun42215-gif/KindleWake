class_name RelationshipSystem
extends RefCounted
## Pair-based companion relationships. Changes are authored by consequential events, never passive/random drift.
## All dimensions are independent, bounded, symmetric pair values; romance only changes when story code explicitly records it.

const DIMENSIONS: Array[String] = ["friendship", "trust", "respect", "rivalry", "affection", "romance"]
const MAX_VALUE := 100
const MAX_HISTORY := 50
const MAX_EVIDENCE := 128

static func _pair_key(character_a: String, character_b: String) -> String:
    var ids: Array[String] = [character_a, character_b]
    ids.sort()
    return ids[0] + "|" + ids[1]

static func normalize_state(raw: Dictionary) -> Dictionary:
    var result: Dictionary = {}
    for raw_key in raw:
        var key := str(raw_key)
        var pair_value: Variant = raw[raw_key]
        var pair: Dictionary = pair_value if typeof(pair_value) == TYPE_DICTIONARY else {}
        var metrics: Dictionary = {}
        var metrics_value: Variant = pair.get("metrics", {})
        var raw_metrics: Dictionary = metrics_value if typeof(metrics_value) == TYPE_DICTIONARY else {}
        for dimension in DIMENSIONS:
            metrics[dimension] = clampi(int(raw_metrics.get(dimension, 0)), 0, MAX_VALUE)
        var history_value: Variant = pair.get("history", [])
        var history: Array = history_value.duplicate(true) if typeof(history_value) == TYPE_ARRAY else []
        while history.size() > MAX_HISTORY:
            history.pop_front()
        var seen_value: Variant = pair.get("seen_evidence", [])
        var seen: Array = seen_value.duplicate() if typeof(seen_value) == TYPE_ARRAY else []
        while seen.size() > MAX_EVIDENCE:
            seen.pop_front()
        result[key] = {"metrics": metrics, "history": history, "seen_evidence": seen}
    return result

static func adjust(state: Dictionary, character_a: String, character_b: String, dimension: String, amount: int, evidence_id: String) -> bool:
    if character_a.strip_edges() == "" or character_b.strip_edges() == "" or character_a == character_b:
        return false
    if not DIMENSIONS.has(dimension) or amount == 0 or evidence_id.strip_edges() == "":
        return false
    var key := _pair_key(character_a, character_b)
    var pair: Dictionary = (state.get(key, {}) as Dictionary).duplicate(true)
    var seen: Array = pair.get("seen_evidence", [])
    if seen.has(evidence_id):
        return false
    var metrics: Dictionary = pair.get("metrics", {}).duplicate(true)
    var previous := int(metrics.get(dimension, 0))
    var next_value := clampi(previous + amount, 0, MAX_VALUE)
    if next_value == previous:
        return false
    metrics[dimension] = next_value
    seen.append(evidence_id)
    while seen.size() > MAX_EVIDENCE:
        seen.pop_front()
    var history: Array = pair.get("history", []).duplicate(true)
    history.append({"dimension": dimension, "delta": amount, "value": next_value, "evidence_id": evidence_id})
    while history.size() > MAX_HISTORY:
        history.pop_front()
    pair["metrics"] = metrics
    pair["seen_evidence"] = seen
    pair["history"] = history
    state[key] = pair
    return true

static func get_relationship(state: Dictionary, character_a: String, character_b: String) -> Dictionary:
    if character_a.strip_edges() == "" or character_b.strip_edges() == "" or character_a == character_b:
        return {}
    var pair: Dictionary = state.get(_pair_key(character_a, character_b), {})
    var metrics: Dictionary = {}
    var raw_metrics: Dictionary = pair.get("metrics", {})
    for dimension in DIMENSIONS:
        metrics[dimension] = clampi(int(raw_metrics.get(dimension, 0)), 0, MAX_VALUE)
    metrics["stage"] = _stage(metrics)
    metrics["history"] = (pair.get("history", []) as Array).duplicate(true)
    return metrics

static func _stage(metrics: Dictionary) -> String:
    var trust := int(metrics.get("trust", 0))
    var friendship := int(metrics.get("friendship", 0))
    var respect := int(metrics.get("respect", 0))
    if int(metrics.get("rivalry", 0)) >= 70:
        return "Rivals"
    if int(metrics.get("romance", 0)) >= 70 and trust >= 60:
        return "Romantic"
    if friendship >= 75 and trust >= 60:
        return "Close Friends"
    if trust >= 70:
        return "Trusted Allies"
    if respect >= 70:
        return "Mutual Respect"
    if friendship >= 40:
        return "Friendly"
    return "Acquaintances"
