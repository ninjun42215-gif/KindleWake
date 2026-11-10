extends RefCounted
## Deterministic territory administration rules. Story and battle systems decide when a
## region changes hands; this system handles the consequences of governing it.

const HISTORY_LIMIT := 100
const MIN_TAX := 0.0
const MAX_TAX := 0.25

static func new_state(faction_data: Dictionary) -> Dictionary:
    var territories: Dictionary = {}
    for region_id in faction_data.get("regions", {}).keys():
        var definition: Dictionary = faction_data["regions"][region_id]
        territories[str(region_id)] = {
            "owner": str(definition.get("owner", "")),
            "status": str(definition.get("status", "held")),
            "garrison": 0,
            "fortification": 0,
            "unrest": 10,
            "loyalty": 50,
            "prosperity": 50,
            "supply": 50,
            "tax_rate": 0.05,
            "turns_governed": 0
        }
    return {"version": 1, "territories": territories, "history": []}


static func normalize_state(raw: Dictionary, faction_data: Dictionary) -> Dictionary:
    var state := new_state(faction_data)
    var saved: Variant = raw.get("territories", {})
    if typeof(saved) != TYPE_DICTIONARY:
        return state
    for region_id_value in saved.keys():
        var region_id := str(region_id_value)
        if not state["territories"].has(region_id) or typeof(saved[region_id_value]) != TYPE_DICTIONARY:
            continue
        var source: Dictionary = saved[region_id_value]
        var target: Dictionary = state["territories"][region_id]
        var owner := str(source.get("owner", target["owner"]))
        if owner != "" and not _has_faction(faction_data, owner):
            owner = str(target["owner"])
        target["owner"] = owner
        target["status"] = str(source.get("status", target["status"]))
        target["garrison"] = clampi(int(source.get("garrison", 0)), 0, 10000)
        target["fortification"] = clampi(int(source.get("fortification", 0)), 0, 5)
        target["unrest"] = clampi(int(source.get("unrest", 10)), 0, 100)
        target["loyalty"] = clampi(int(source.get("loyalty", 50)), 0, 100)
        target["prosperity"] = clampi(int(source.get("prosperity", 50)), 0, 100)
        target["supply"] = clampi(int(source.get("supply", 50)), 0, 100)
        target["tax_rate"] = clampf(float(source.get("tax_rate", 0.05)), MIN_TAX, MAX_TAX)
        target["turns_governed"] = maxi(0, int(source.get("turns_governed", 0)))
    var history: Variant = raw.get("history", [])
    if typeof(history) == TYPE_ARRAY:
        state["history"] = history.duplicate(true).slice(maxi(0, history.size() - HISTORY_LIMIT))
    return state


static func set_policy(state: Dictionary, region_id: String, policy: Dictionary, faction_id: String) -> bool:
    var territories: Dictionary = state.get("territories", {})
    if not territories.has(region_id):
        return false
    var territory: Dictionary = territories[region_id]
    if str(territory.get("owner", "")) != faction_id or faction_id == "":
        return false
    if policy.has("tax_rate"):
        territory["tax_rate"] = clampf(float(policy["tax_rate"]), MIN_TAX, MAX_TAX)
    if policy.has("garrison"):
        territory["garrison"] = clampi(int(policy["garrison"]), 0, 10000)
    if policy.has("fortification"):
        territory["fortification"] = clampi(int(policy["fortification"]), 0, 5)
    return true


static func capture(state: Dictionary, region_id: String, new_owner: String, faction_data: Dictionary, cause: String) -> bool:
    var territories: Dictionary = state.get("territories", {})
    if not territories.has(region_id) or not _has_faction(faction_data, new_owner):
        return false
    var territory: Dictionary = territories[region_id]
    var previous_owner := str(territory.get("owner", ""))
    if previous_owner == new_owner:
        return false
    territory["owner"] = new_owner
    territory["status"] = "held"
    territory["garrison"] = 0
    territory["unrest"] = 55
    territory["loyalty"] = 25
    territory["supply"] = 30
    territory["turns_governed"] = 0
    _record(state, {"kind":"capture", "region":region_id, "from":previous_owner, "to":new_owner, "cause":cause})
    return true


static func advance_turn(state: Dictionary, faction_id: String) -> Dictionary:
    var summary := {"tax_income": 0, "unresting_regions": [], "rebellion_risk_regions": []}
    var territories: Dictionary = state.get("territories", {})
    for region_id in territories.keys():
        var territory: Dictionary = territories[region_id]
        if faction_id == "" or str(territory.get("owner", "")) != faction_id:
            continue
        var tax_rate := clampf(float(territory.get("tax_rate", 0.05)), MIN_TAX, MAX_TAX)
        var prosperity := int(territory.get("prosperity", 50))
        var supply := int(territory.get("supply", 50))
        var loyalty := int(territory.get("loyalty", 50))
        var unrest := int(territory.get("unrest", 10))
        var income := maxi(0, roundi(float(prosperity + supply) * tax_rate * 10.0))
        summary["tax_income"] += income
        var unrest_change := 0
        if tax_rate > 0.15:
            unrest_change += 8
        elif tax_rate < 0.06:
            unrest_change -= 3
        if supply < 25:
            unrest_change += 8
        elif supply > 70:
            unrest_change -= 2
        if loyalty >= 70:
            unrest_change -= 3
        unrest = clampi(unrest + unrest_change, 0, 100)
        loyalty = clampi(loyalty + (2 if unrest < 25 else (-3 if unrest >= 60 else 0)), 0, 100)
        prosperity = clampi(prosperity + (2 if tax_rate <= 0.1 and supply >= 40 else (-2 if tax_rate > 0.15 else 0)), 0, 100)
        territory["unrest"] = unrest
        territory["loyalty"] = loyalty
        territory["prosperity"] = prosperity
        territory["turns_governed"] = int(territory.get("turns_governed", 0)) + 1
        if unrest >= 50:
            summary["unresting_regions"].append(str(region_id))
        if unrest >= 85 and loyalty <= 20:
            summary["rebellion_risk_regions"].append(str(region_id))
    _record(state, {"kind":"governance_turn", "tax_income":summary["tax_income"]})
    return summary


static func _has_faction(faction_data: Dictionary, faction_id: String) -> bool:
    for faction in faction_data.get("factions", []):
        if typeof(faction) == TYPE_DICTIONARY and str(faction.get("id", "")) == faction_id:
            return true
    return false


static func _record(state: Dictionary, event: Dictionary) -> void:
    var history: Array = state.get("history", [])
    history.append(event)
    if history.size() > HISTORY_LIMIT:
        history.pop_front()
    state["history"] = history
