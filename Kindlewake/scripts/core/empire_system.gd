extends RefCounted
## Deterministic, offline realm administration rules. Story systems decide when a realm is founded;
## this module never starts wars, transfers land or invents political consequences.

const MIN_TAX_RATE := 0.0
const MAX_TAX_RATE := 0.25
const MIN_STABILITY := 0
const MAX_STABILITY := 100
const MIN_LEGITIMACY := 0
const MAX_LEGITIMACY := 100
const HISTORY_LIMIT := 100
const POLICY_COSTS := {
    "granaries": 300,
    "road_works": 450,
    "tax_relief": 500,
    "regional_garrisons": 600
}
const POLICY_NAMES := {
    "granaries": "Public Granaries",
    "road_works": "Royal Road Works",
    "tax_relief": "Seasonal Tax Relief",
    "regional_garrisons": "Regional Garrisons"
}


static func new_campaign_state(ruler_faction: String, starting_treasury: int = 1200) -> Dictionary:
    return {
        "version": 1,
        "ruler_faction": ruler_faction,
        "treasury": maxi(0, starting_treasury),
        "tax_rate": 0.10,
        "stability": 65,
        "legitimacy": 50,
        "month_index": 0,
        "governors": {},
        "policies": {},
        "processed_months": [],
        "history": []
    }


static func normalize_state(raw: Dictionary, valid_factions: Array = []) -> Dictionary:
    var faction := str(raw.get("ruler_faction", ""))
    if not valid_factions.is_empty() and not valid_factions.has(faction):
        faction = ""
    var state := new_campaign_state(faction, int(raw.get("treasury", 1200)))
    state["tax_rate"] = clampf(float(raw.get("tax_rate", 0.10)), MIN_TAX_RATE, MAX_TAX_RATE)
    state["stability"] = clampi(int(raw.get("stability", 65)), MIN_STABILITY, MAX_STABILITY)
    state["legitimacy"] = clampi(int(raw.get("legitimacy", 50)), MIN_LEGITIMACY, MAX_LEGITIMACY)
    state["month_index"] = maxi(0, int(raw.get("month_index", 0)))
    var governors: Variant = raw.get("governors", {})
    if typeof(governors) == TYPE_DICTIONARY:
        for region_id in governors:
            var character_id := str(governors[region_id])
            if str(region_id) != "" and character_id != "":
                state["governors"][str(region_id)] = character_id
    var policies: Variant = raw.get("policies", {})
    if typeof(policies) == TYPE_DICTIONARY:
        for policy_id in policies:
            if POLICY_COSTS.has(str(policy_id)) and bool(policies[policy_id]):
                state["policies"][str(policy_id)] = true
    var processed: Variant = raw.get("processed_months", [])
    if typeof(processed) == TYPE_ARRAY:
        state["processed_months"] = processed.duplicate(true).slice(maxi(0, processed.size() - HISTORY_LIMIT))
    var history: Variant = raw.get("history", [])
    if typeof(history) == TYPE_ARRAY:
        state["history"] = history.duplicate(true).slice(maxi(0, history.size() - HISTORY_LIMIT))
    return state


static func set_tax_rate(state: Dictionary, next_rate: float) -> bool:
    if not is_finite(next_rate) or next_rate < MIN_TAX_RATE or next_rate > MAX_TAX_RATE:
        return false
    state["tax_rate"] = snappedf(next_rate, 0.01)
    _record(state, {"kind":"tax_rate", "value":state["tax_rate"]})
    return true


static func appoint_governor(state: Dictionary, faction_state: Dictionary, region_id: String, character_id: String, eligible_roster: Array) -> bool:
    if character_id == "" or not eligible_roster.has(character_id):
        return false
    var territories: Dictionary = faction_state.get("territories", {})
    if not territories.has(region_id):
        return false
    if str(territories[region_id].get("owner", "")) != str(state.get("ruler_faction", "")):
        return false
    state["governors"][region_id] = character_id
    _record(state, {"kind":"governor", "region":region_id, "character":character_id})
    return true


static func enact_policy(state: Dictionary, policy_id: String) -> Dictionary:
    if not POLICY_COSTS.has(policy_id):
        return {"ok":false, "reason":"Unknown realm policy."}
    if bool(state.get("policies", {}).get(policy_id, false)):
        return {"ok":false, "reason":"That policy is already active."}
    var cost: int = int(POLICY_COSTS[policy_id])
    if int(state.get("treasury", 0)) < cost:
        return {"ok":false, "reason":"The royal treasury cannot afford this policy."}
    state["treasury"] = int(state["treasury"]) - cost
    state["policies"][policy_id] = true
    _record(state, {"kind":"policy", "policy":policy_id, "cost":cost})
    return {"ok":true, "cost":cost, "name":str(POLICY_NAMES[policy_id])}


static func estimate_monthly_finances(state: Dictionary, faction_state: Dictionary) -> Dictionary:
    var owned := _owned_regions(state, faction_state)
    var base_income := owned.size() * 100
    var tax_multiplier := 0.5 + float(state.get("tax_rate", 0.10)) * 5.0
    var stability_multiplier := 0.75 + float(state.get("stability", 65)) / 200.0
    var income := int(round(float(base_income) * tax_multiplier * stability_multiplier))
    if bool(state.get("policies", {}).get("road_works", false)):
        income = int(round(float(income) * 1.10))
    var upkeep := owned.size() * 20
    if bool(state.get("policies", {}).get("regional_garrisons", false)):
        upkeep += owned.size() * 15
    return {"regions":owned.size(), "income":income, "upkeep":upkeep, "net":income - upkeep}


static func advance_month(state: Dictionary, faction_state: Dictionary, month_token: String) -> Dictionary:
    if month_token == "" or (state.get("processed_months", []) as Array).has(month_token):
        return {"ok":false, "reason":"This month has already been processed or has no valid identifier."}
    var finances := estimate_monthly_finances(state, faction_state)
    var income := int(finances["income"])
    var upkeep := int(finances["upkeep"])
    state["treasury"] = maxi(0, int(state.get("treasury", 0)) + income - upkeep)
    var stability_delta := 0
    if float(state.get("tax_rate", 0.10)) >= 0.18:
        stability_delta -= 4
    elif float(state.get("tax_rate", 0.10)) <= 0.05:
        stability_delta += 2
    if bool(state.get("policies", {}).get("granaries", false)):
        stability_delta += 2
    if bool(state.get("policies", {}).get("tax_relief", false)):
        stability_delta += 3
    if int(finances["net"]) < 0:
        stability_delta -= 3
    state["stability"] = clampi(int(state.get("stability", 65)) + stability_delta, MIN_STABILITY, MAX_STABILITY)
    state["month_index"] = int(state.get("month_index", 0)) + 1
    var processed: Array = state.get("processed_months", [])
    processed.append(month_token)
    if processed.size() > HISTORY_LIMIT:
        processed.pop_front()
    state["processed_months"] = processed
    var result := {"ok":true, "month_index":state["month_index"], "income":income, "upkeep":upkeep, "net":income - upkeep, "stability_delta":stability_delta, "treasury":state["treasury"]}
    _record(state, {"kind":"monthly_settlement", "token":month_token, "income":income, "upkeep":upkeep, "stability":state["stability"]})
    return result


static func realm_summary(state: Dictionary, faction_state: Dictionary) -> Dictionary:
    var finances := estimate_monthly_finances(state, faction_state)
    return {
        "ruler_faction":str(state.get("ruler_faction", "")),
        "treasury":int(state.get("treasury", 0)),
        "tax_rate":float(state.get("tax_rate", 0.10)),
        "stability":int(state.get("stability", 65)),
        "legitimacy":int(state.get("legitimacy", 50)),
        "owned_regions":int(finances["regions"]),
        "monthly_income":int(finances["income"]),
        "monthly_upkeep":int(finances["upkeep"]),
        "monthly_net":int(finances["net"]),
        "governor_count":(state.get("governors", {}) as Dictionary).size(),
        "active_policies":(state.get("policies", {}) as Dictionary).keys()
    }


static func _owned_regions(state: Dictionary, faction_state: Dictionary) -> Array[String]:
    var owned: Array[String] = []
    var ruler := str(state.get("ruler_faction", ""))
    for region_id in faction_state.get("territories", {}):
        var territory: Dictionary = faction_state["territories"][region_id]
        if str(territory.get("owner", "")) == ruler and str(territory.get("status", "held")) == "held":
            owned.append(str(region_id))
    owned.sort()
    return owned


static func _record(state: Dictionary, event: Dictionary) -> void:
    var history: Array = state.get("history", [])
    history.append(event)
    if history.size() > HISTORY_LIMIT:
        history.pop_front()
    state["history"] = history
