extends RefCounted
## Realm-level policy and administration. FactionSystem owns territory; EmpireEconomySystem
## owns holding settlement and party.gold. This layer never creates a second treasury.

const DEFAULT_TAX_RATE := 0.10
const MIN_TAX_RATE := 0.0
const MAX_TAX_RATE := 0.25
const HISTORY_LIMIT := 24
const POLICY_DEFINITIONS := {
    "granaries": {"name":"Royal Granaries","cost":300,"stability":2,"income_multiplier":1.0,"upkeep_per_region":0},
    "tax_relief": {"name":"Tax Relief","cost":250,"stability":3,"income_multiplier":1.0,"upkeep_per_region":0},
    "road_works": {"name":"Royal Roads","cost":400,"stability":0,"income_multiplier":1.10,"upkeep_per_region":0},
    "regional_garrisons": {"name":"Regional Garrisons","cost":350,"stability":1,"income_multiplier":1.0,"upkeep_per_region":15}
}

static func new_campaign_state(ruler_faction: String = "house_dunmarrow") -> Dictionary:
    return {
        "version": 1,
        "ruler_faction": ruler_faction,
        "tax_rate": DEFAULT_TAX_RATE,
        "stability": 65,
        "legitimacy": 50,
        "month_index": 0,
        "governors": {},
        "policies": {},
        "processed_months": [],
        "history": []
    }


static func normalize_state(raw: Dictionary, valid_factions: Array = [], faction_state: Dictionary = {}, eligible_roster: Array = []) -> Dictionary:
    var source: Dictionary = raw if raw is Dictionary else {}
    var ruler := str(source.get("ruler_faction", "house_dunmarrow"))
    if not valid_factions.is_empty() and not valid_factions.has(ruler):
        ruler = ""
    var state := new_campaign_state(ruler)
    state["tax_rate"] = clampf(float(source.get("tax_rate", DEFAULT_TAX_RATE)), MIN_TAX_RATE, MAX_TAX_RATE)
    state["stability"] = clampi(int(source.get("stability", 65)), 0, 100)
    state["legitimacy"] = clampi(int(source.get("legitimacy", 50)), 0, 100)
    state["month_index"] = maxi(0, int(source.get("month_index", 0)))
    var raw_governors: Dictionary = source.get("governors", {}) if source.get("governors", {}) is Dictionary else {}
    var territories: Dictionary = faction_state.get("territories", {})
    var governor_regions: Array = raw_governors.keys()
    governor_regions.sort()
    var assigned_governors: Dictionary = {}
    for region_value in governor_regions:
        var region_id := str(region_value)
        var character_id := str(raw_governors[region_value])
        if region_id == "" or character_id == "" or assigned_governors.has(character_id):
            continue
        if not faction_state.is_empty():
            var territory: Dictionary = territories.get(region_id, {})
            if str(territory.get("owner", "")) != ruler or str(territory.get("status", "")) != "held":
                continue
        if not eligible_roster.is_empty() and not eligible_roster.has(character_id):
            continue
        state["governors"][region_id] = character_id
        assigned_governors[character_id] = true
    var raw_policies: Dictionary = source.get("policies", {}) if source.get("policies", {}) is Dictionary else {}
    for policy_id in POLICY_DEFINITIONS:
        if bool(raw_policies.get(policy_id, false)):
            state["policies"][policy_id] = true
    var processed: Array = []
    for token in source.get("processed_months", []):
        var value := str(token)
        if value != "" and not processed.has(value):
            processed.append(value)
    state["processed_months"] = processed.slice(maxi(0, processed.size() - HISTORY_LIMIT))
    var history: Array = []
    for entry in source.get("history", []):
        if entry is Dictionary:
            history.append(entry.duplicate(true))
    state["history"] = history.slice(maxi(0, history.size() - HISTORY_LIMIT))
    return state


static func set_tax_rate(state: Dictionary, next_rate: float) -> bool:
    if next_rate < MIN_TAX_RATE or next_rate > MAX_TAX_RATE:
        return false
    state["tax_rate"] = snappedf(next_rate, 0.01)
    return true


static func appoint_governor(state: Dictionary, faction_state: Dictionary, region_id: String, character_id: String, eligible_roster: Array) -> bool:
    if region_id == "" or character_id == "" or not eligible_roster.has(character_id):
        return false
    var ruler := str(state.get("ruler_faction", ""))
    if ruler == "":
        return false
    var territories: Dictionary = faction_state.get("territories", {})
    var territory: Dictionary = territories.get(region_id, {})
    if str(territory.get("owner", "")) != ruler or str(territory.get("status", "")) != "held":
        return false
    var governors: Dictionary = state.get("governors", {}).duplicate(true)
    for assigned_region in governors:
        if str(assigned_region) != region_id and str(governors[assigned_region]) == character_id:
            return false
    governors[region_id] = character_id
    state["governors"] = governors
    return true


static func enact_policy(state: Dictionary, policy_id: String, available_gold: int) -> Dictionary:
    if not POLICY_DEFINITIONS.has(policy_id):
        return {"ok":false,"reason":"Unknown realm policy."}
    var policies: Dictionary = state.get("policies", {})
    if bool(policies.get(policy_id, false)):
        return {"ok":false,"reason":"This realm policy is already active."}
    var definition: Dictionary = POLICY_DEFINITIONS[policy_id]
    var cost := int(definition.get("cost", 0))
    if available_gold < cost:
        return {"ok":false,"reason":"Insufficient shared treasury. Need %d gold." % cost}
    var updated := policies.duplicate(true)
    updated[policy_id] = true
    state["policies"] = updated
    return {"ok":true,"policy":policy_id,"name":str(definition.get("name", policy_id)),"cost":cost,"treasury_after":available_gold-cost}


static func estimate_monthly_finances(state: Dictionary, faction_state: Dictionary, base_income: int, base_upkeep: int) -> Dictionary:
    var owned := _owned_regions(state, faction_state)
    var tax_rate := clampf(float(state.get("tax_rate", DEFAULT_TAX_RATE)), MIN_TAX_RATE, MAX_TAX_RATE)
    var stability := clampi(int(state.get("stability", 65)), 0, 100)
    var tax_multiplier := 1.0 + (tax_rate - DEFAULT_TAX_RATE) * 2.0
    var stability_multiplier := 0.85 + float(stability) / 600.0
    var policies: Dictionary = state.get("policies", {})
    var income := roundi(float(maxi(0, base_income)) * tax_multiplier * stability_multiplier)
    var upkeep := maxi(0, base_upkeep)
    for policy_id in policies:
        if not bool(policies[policy_id]) or not POLICY_DEFINITIONS.has(policy_id):
            continue
        var policy: Dictionary = POLICY_DEFINITIONS[policy_id]
        income = roundi(float(income) * float(policy.get("income_multiplier", 1.0)))
        upkeep += owned.size() * int(policy.get("upkeep_per_region", 0))
    return {
        "owned_regions":owned.size(),
        "base_income":maxi(0, base_income),
        "base_upkeep":maxi(0, base_upkeep),
        "income":maxi(0, income),
        "upkeep":upkeep,
        "net":income-upkeep
    }


static func advance_month(state: Dictionary, faction_state: Dictionary, month_token: String, base_income: int, base_upkeep: int, shared_treasury: int) -> Dictionary:
    if month_token == "":
        return {"ok":false,"reason":"A unique month token is required."}
    var processed: Array = state.get("processed_months", [])
    if processed.has(month_token):
        return {"ok":false,"reason":"This realm month has already been settled."}
    var finances := estimate_monthly_finances(state, faction_state, base_income, base_upkeep)
    var treasury_before := maxi(0, shared_treasury)
    var treasury_after := maxi(0, treasury_before + int(finances.net))
    var stability_delta := 0
    var tax_rate := float(state.get("tax_rate", DEFAULT_TAX_RATE))
    if tax_rate >= 0.18:
        stability_delta -= 4
    elif tax_rate <= 0.05:
        stability_delta += 2
    var policies: Dictionary = state.get("policies", {})
    if bool(policies.get("granaries", false)):
        stability_delta += 2
    if bool(policies.get("tax_relief", false)):
        stability_delta += 3
    if int(finances.net) < 0:
        stability_delta -= 3
    state["stability"] = clampi(int(state.get("stability", 65)) + stability_delta, 0, 100)
    state["month_index"] = maxi(0, int(state.get("month_index", 0))) + 1
    processed.append(month_token)
    state["processed_months"] = processed.slice(maxi(0, processed.size() - HISTORY_LIMIT))
    var result := {
        "ok":true,
        "month_token":month_token,
        "month_index":int(state.month_index),
        "income":int(finances.income),
        "upkeep":int(finances.upkeep),
        "net":int(finances.net),
        "treasury_before":treasury_before,
        "treasury_after":treasury_after,
        "owned_regions":int(finances.owned_regions),
        "stability":int(state.stability),
        "stability_delta":stability_delta
    }
    _record(state, result)
    return result


static func realm_summary(state: Dictionary, faction_state: Dictionary, shared_treasury: int, base_income: int = 0, base_upkeep: int = 0) -> Dictionary:
    var owned := _owned_regions(state, faction_state)
    var finances := estimate_monthly_finances(state, faction_state, base_income, base_upkeep)
    var policies: Dictionary = state.get("policies", {})
    var active: Array = []
    for policy_id in policies:
        if bool(policies[policy_id]):
            active.append(policy_id)
    active.sort()
    return {
        "ruler_faction":str(state.get("ruler_faction", "")),
        "treasury":maxi(0, shared_treasury),
        "tax_rate":float(state.get("tax_rate", DEFAULT_TAX_RATE)),
        "stability":int(state.get("stability", 65)),
        "stability_label":stability_label(int(state.get("stability", 65))),
        "legitimacy":int(state.get("legitimacy", 50)),
        "owned_regions":owned,
        "governors":(state.get("governors", {}) as Dictionary).duplicate(true),
        "governor_count":(state.get("governors", {}) as Dictionary).size(),
        "active_policies":active,
        "monthly_income":int(finances.income),
        "monthly_upkeep":int(finances.upkeep),
        "monthly_net":int(finances.net),
        "month_index":int(state.get("month_index", 0))
    }


static func stability_label(value: int) -> String:
    if value < 25:
        return "Unrest"
    if value < 50:
        return "Uneasy"
    if value < 75:
        return "Settling"
    return "Secure"


static func _owned_regions(state: Dictionary, faction_state: Dictionary) -> Array[String]:
    var result: Array[String] = []
    var ruler := str(state.get("ruler_faction", ""))
    var territories: Dictionary = faction_state.get("territories", {})
    for region_id in territories:
        var territory: Dictionary = territories[region_id]
        if str(territory.get("owner", "")) == ruler and str(territory.get("status", "")) == "held":
            result.append(str(region_id))
    result.sort()
    return result


static func _record(state: Dictionary, entry: Dictionary) -> void:
    var history: Array = state.get("history", []).duplicate(true)
    history.append(entry.duplicate(true))
    state["history"] = history.slice(maxi(0, history.size() - HISTORY_LIMIT))
