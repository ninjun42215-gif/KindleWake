class_name CompanionBehaviorSystem
extends RefCounted
## Converts authored character history into small, deterministic tactical preferences.
## This layer never changes stats, morale, or campaign relationship values.

static func risk_tolerance(trait_ids: Array, personality: Dictionary, trait_definitions: Dictionary) -> float:
    var score := 0.0
    for trait_id in trait_ids:
        var definition: Dictionary = trait_definitions.get(str(trait_id), {})
        var behavior: Dictionary = definition.get("battle_behavior", {})
        score += float(behavior.get("risk_tolerance", 0.0))
    var stress := clampi(int(personality.get("stress", 0)), 0, 100)
    if stress >= 80:
        score -= 0.2
    elif stress >= 60:
        score -= 0.1
    var memories: Array = personality.get("memories", [])
    var traumatic_count := 0
    var first_recent := maxi(0, memories.size() - 5)
    for index in range(first_recent, memories.size()):
        var memory: Dictionary = memories[index]
        if str(memory.get("type", "")) in ["traumatic", "betrayal"]:
            traumatic_count += 1
    score -= minf(0.2, float(traumatic_count) * 0.08)
    var ambition: Dictionary = personality.get("ambition", {})
    if str(ambition.get("status", "")) == "active":
        if str(ambition.get("combat_focus", "")) == "aggressive":
            score += 0.1
        elif str(ambition.get("combat_focus", "")) == "support":
            score -= 0.05
    return clampf(score, -0.5, 0.5)


static func threat_sensitivity(trait_ids: Array, personality: Dictionary, trait_definitions: Dictionary) -> float:
    return clampf(1.0 - risk_tolerance(trait_ids, personality, trait_definitions) * 0.5, 0.75, 1.25)


static func support_score(trait_ids: Array, personality: Dictionary, companion_bonds: Dictionary, target_id: String, trait_definitions: Dictionary) -> float:
    var score := 0.0
    for trait_id in trait_ids:
        var definition: Dictionary = trait_definitions.get(str(trait_id), {})
        var behavior: Dictionary = definition.get("battle_behavior", {})
        score += float(behavior.get("support_priority", 0.0))
    var ambition: Dictionary = personality.get("ambition", {})
    if str(ambition.get("status", "")) == "active" and str(ambition.get("combat_focus", "")) == "support":
        score += 4.0
    var bond: Dictionary = companion_bonds.get(target_id, {})
    if not bond.is_empty():
        var affinity := float(bond.get("friendship", 0)) * 0.25
        affinity += float(bond.get("trust", 0)) * 0.35
        affinity += float(bond.get("respect", 0)) * 0.2
        affinity += float(bond.get("affection", 0)) * 0.2
        affinity -= float(bond.get("rivalry", 0)) * 0.3
        score += clampf(affinity * 0.08, -8.0, 10.0)
    return clampf(score, -8.0, 24.0)


static func attack_drive(trait_ids: Array, personality: Dictionary, trait_definitions: Dictionary) -> float:
    var score := risk_tolerance(trait_ids, personality, trait_definitions) * 6.0
    var ambition: Dictionary = personality.get("ambition", {})
    if str(ambition.get("status", "")) == "active" and str(ambition.get("combat_focus", "")) == "aggressive":
        score += 5.0
    return clampf(score, -5.0, 8.0)
