class_name TraitSystem
extends RefCounted
## Data-driven enduring traits. Temporary combat conditions remain in the existing status-effect system.
## Trait definitions are loaded from data/traits.json; this class never mutates base stats.

const MAX_HISTORY := 100

static func definitions_from_json(data: Dictionary) -> Dictionary:
    var definitions: Dictionary = (data.get("traits", {}) as Dictionary).duplicate(true)
    definitions["_synergies"] = (data.get("synergies", []) as Array).duplicate(true)
    return definitions

static func normalized_ids(values: Array) -> Array[String]:
    var out: Array[String] = []
    for value in values:
        var id := str(value).strip_edges()
        if id != "" and not out.has(id):
            out.append(id)
    return out

static func stat_effects(trait_ids: Array, definitions: Dictionary) -> Dictionary:
    var totals: Dictionary = {}
    for trait_id in normalized_ids(trait_ids):
        var definition: Dictionary = definitions.get(trait_id, {})
        var effects: Dictionary = definition.get("effects", {})
        for stat in effects:
            var key := str(stat)
            totals[key] = int(totals.get(key, 0)) + int(effects[stat])
    for synergy in definitions.get("_synergies", []):
        var synergy_def: Dictionary = synergy
        var required: Array = synergy_def.get("requires", [])
        var active := not required.is_empty()
        for required_id in required:
            if not trait_ids.has(str(required_id)):
                active = false
                break
        if active:
            var synergy_effects: Dictionary = synergy_def.get("effects", {})
            for stat in synergy_effects:
                var key := str(stat)
                totals[key] = int(totals.get(key, 0)) + int(synergy_effects[stat])
    return totals

static func active_synergies(trait_ids: Array, definitions: Dictionary) -> Array:
    var active: Array = []
    for synergy in definitions.get("_synergies", []):
        var synergy_def: Dictionary = synergy
        var required: Array = synergy_def.get("requires", [])
        var matches := not required.is_empty()
        for required_id in required:
            if not trait_ids.has(str(required_id)):
                matches = false
                break
        if matches:
            active.append(synergy_def.duplicate(true))
    return active

static func can_acquire(trait_ids: Array, trait_id: String, definitions: Dictionary) -> Dictionary:
    if not definitions.has(trait_id):
        return {"ok": false, "reason": "Unknown trait."}
    if trait_ids.has(trait_id):
        return {"ok": false, "reason": "This character already has that trait."}
    var candidate: Dictionary = definitions[trait_id]
    for conflict in candidate.get("conflicts", []):
        if trait_ids.has(str(conflict)):
            return {"ok": false, "reason": "Conflicts with " + str(definitions.get(str(conflict), {}).get("name", conflict)) + "."}
    for existing in trait_ids:
        var current: Dictionary = definitions.get(str(existing), {})
        if (current.get("conflicts", []) as Array).has(trait_id):
            return {"ok": false, "reason": "Conflicts with " + str(current.get("name", existing)) + "."}
    return {"ok": true, "reason": ""}

static func acquire(trait_ids: Array, history: Array, trait_id: String, source: String, definitions: Dictionary) -> Dictionary:
    var check: Dictionary = can_acquire(trait_ids, trait_id, definitions)
    if not bool(check.ok):
        return {"ok": false, "reason": str(check.reason), "traits": normalized_ids(trait_ids), "history": history.duplicate(true)}
    var updated := normalized_ids(trait_ids)
    updated.append(trait_id)
    var log := history.duplicate(true)
    log.append({"trait_id": trait_id, "action": "acquired", "source": source, "timestamp": int(Time.get_unix_time_from_system())})
    while log.size() > MAX_HISTORY:
        log.pop_front()
    return {"ok": true, "reason": "", "traits": updated, "history": log}

static func remove(trait_ids: Array, history: Array, trait_id: String, reason: String, definitions: Dictionary, allow_permanent: bool = false) -> Dictionary:
    if reason.strip_edges() == "":
        return {"ok": false, "reason": "A meaningful story or development reason is required.", "traits": normalized_ids(trait_ids), "history": history.duplicate(true)}
    if not trait_ids.has(trait_id):
        return {"ok": false, "reason": "Trait not found.", "traits": normalized_ids(trait_ids), "history": history.duplicate(true)}
    var definition: Dictionary = definitions.get(trait_id, {})
    if bool(definition.get("permanent", false)) and not allow_permanent:
        return {"ok": false, "reason": "This trait requires a dedicated story resolution.", "traits": normalized_ids(trait_ids), "history": history.duplicate(true)}
    var updated := normalized_ids(trait_ids)
    updated.erase(trait_id)
    var log := history.duplicate(true)
    log.append({"trait_id": trait_id, "action": "removed", "source": reason, "timestamp": int(Time.get_unix_time_from_system())})
    while log.size() > MAX_HISTORY:
        log.pop_front()
    return {"ok": true, "reason": "", "traits": updated, "history": log}

static func _requirements_met(requirements: Dictionary, behavior: Dictionary) -> bool:
    if requirements.is_empty():
        return false
    for key in requirements:
        if int(behavior.get(str(key), 0)) < int(requirements[key]):
            return false
    return true

static func evolve(trait_ids: Array, history: Array, trait_id: String, definitions: Dictionary, source: String, behavior: Dictionary = {}) -> Dictionary:
    var definition: Dictionary = definitions.get(trait_id, {})
    var next_id := str(definition.get("evolves_to", ""))
    if next_id == "":
        return {"ok": false, "reason": "This trait has no defined evolution.", "traits": normalized_ids(trait_ids), "history": history.duplicate(true)}
    if not trait_ids.has(trait_id):
        return {"ok": false, "reason": "The character does not have the required starting trait.", "traits": normalized_ids(trait_ids), "history": history.duplicate(true)}
    var requirements: Dictionary = definition.get("evolution_requirements", {})
    if not _requirements_met(requirements, behavior):
        return {"ok": false, "reason": "The character has not yet met the evolution requirements.", "traits": normalized_ids(trait_ids), "history": history.duplicate(true)}
    var removed := remove(trait_ids, history, trait_id, "evolved:" + source, definitions, true)
    var added := acquire(removed.traits, removed.history, next_id, "evolved:" + source, definitions)
    if not bool(added.ok):
        return {"ok": false, "reason": str(added.reason), "traits": normalized_ids(trait_ids), "history": history.duplicate(true)}
    return added

static func describe(trait_id: String, definitions: Dictionary) -> Dictionary:
    return definitions.get(trait_id, {})
