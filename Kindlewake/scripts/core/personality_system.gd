class_name PersonalitySystem
extends RefCounted
## Campaign-level character development. Event-driven only: no per-frame stress drift or random permanent traits.
## Memories are bounded; behavior evidence is keyed by unique event IDs to prevent duplicate farming.

const MAX_MEMORIES := 40
const MAX_EVIDENCE := 1000
const STRESS_MAX := 100

static func stress_band(value: int) -> String:
    var stress := clampi(value, 0, STRESS_MAX)
    if stress < 20:
        return "Calm"
    if stress < 40:
        return "Uneasy"
    if stress < 60:
        return "Stressed"
    if stress < 80:
        return "Distressed"
    if stress < 100:
        return "Overwhelmed"
    return "Crisis"

static func adjust_stress(current: int, delta: int) -> int:
    return clampi(current + delta, 0, STRESS_MAX)

static func add_memory(memories: Array, entry: Dictionary) -> Array:
    var result := memories.duplicate(true)
    var event_id := str(entry.get("event_id", ""))
    if event_id != "":
        for old in result:
            if str((old as Dictionary).get("event_id", "")) == event_id:
                return result
    result.append(entry.duplicate(true))
    while result.size() > MAX_MEMORIES:
        result.pop_front()
    return result

static func record_behavior(behavior: Dictionary, behavior_id: String, amount: int, evidence_id: String) -> Dictionary:
    if behavior_id == "" or evidence_id == "":
        return behavior.duplicate(true)
    var result := behavior.duplicate(true)
    if amount <= 0:
        return result
    var seen: Array = result.get("seen_evidence", [])
    if seen.has(evidence_id):
        return result
    seen.append(evidence_id)
    while seen.size() > 128:
        seen.pop_front()
    result["seen_evidence"] = seen
    var current := int(result.get(behavior_id, 0))
    # Diminishing returns prevent repetitive low-value actions from farming a trait threshold.
    var gain := maxi(1, amount / (1 + current / 10))
    result[behavior_id] = clampi(current + gain, 0, MAX_EVIDENCE)
    return result

static func requirements_met(requirements: Dictionary, behavior: Dictionary) -> bool:
    if requirements.is_empty():
        return false
    for key in requirements:
        if int(behavior.get(str(key), 0)) < int(requirements[key]):
            return false
    return true

static func apply_event(state: Dictionary, event_id: String, event_definitions: Dictionary, trait_definitions: Dictionary, source: String = "campaign_event", instance_id: String = "") -> Dictionary:
    var definition: Dictionary = event_definitions.get(event_id, {})
    if definition.is_empty():
        return {"ok": false, "reason": "Unknown personality event.", "state": state.duplicate(true), "traits_gained": []}
    var next := state.duplicate(true)
    var memories: Array = next.get("memories", [])
    var memory_instance := instance_id if instance_id != "" else event_id + ":" + source
    var memory := {
        "event_id": memory_instance,
        "event_type": event_id,
        "type": str(definition.get("memory_type", "personal")),
        "summary": str(definition.get("memory", definition.get("description", definition.get("name", event_id)))),
        "timestamp": int(Time.get_unix_time_from_system()),
        "resolved": false,
        "source": source
    }
    next["memories"] = add_memory(memories, memory)
    next["stress"] = adjust_stress(int(next.get("stress", 0)), int(definition.get("stress_delta", 0)))
    var behavior: Dictionary = next.get("behavior", {})
    var evidence: Dictionary = definition.get("evidence", {})
    for behavior_id in evidence:
        behavior = record_behavior(behavior, str(behavior_id), int(evidence[behavior_id]), memory_instance + ":" + str(behavior_id))
    next["behavior"] = behavior
    var traits: Array = next.get("traits", [])
    var history: Array = next.get("trait_history", [])
    var gained: Array[String] = []
    if requirements_met(definition.get("requirements", {}), behavior):
        for trait_id in definition.get("trait_awards", []):
            var result: Dictionary = TraitSystem.acquire(traits, history, str(trait_id), memory_instance, trait_definitions)
            if bool(result.get("ok", false)):
                traits = result.traits
                history = result.history
                gained.append(str(trait_id))
    next["traits"] = traits
    next["trait_history"] = history
    return {"ok": true, "reason": "", "state": next, "traits_gained": gained}

static func default_state() -> Dictionary:
    return {"stress": 0, "memories": [], "behavior": {}, "traits": [], "trait_history": [], "ambition": {}}
