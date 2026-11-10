extends RefCounted
## Deterministic empire economy. A turn is advanced only by an explicit campaign action;
## this system never advances time in the background.

const PLAYER_FACTION := "house_dunmarrow"
const MIN_STABILITY := 0
const MAX_STABILITY := 100

static func assign_garrison(holding_id: String, unit_count: int, world_flags: Dictionary) -> Dictionary:
    if holding_id == "" or not bool(world_flags.get("holding_claimed_" + holding_id, false)):
        return {"ok": false, "reason": "Only a claimed holding can receive a garrison."}
    var count := clampi(unit_count, 0, 999)
    world_flags["holding_garrison_" + holding_id] = count
    return {"ok": true, "holding": holding_id, "garrison": count}


static func set_governance(holding_id: String, governance_id: String, world_flags: Dictionary) -> Dictionary:
    if holding_id == "" or not bool(world_flags.get("holding_claimed_" + holding_id, false)):
        return {"ok": false, "reason": "Only a claimed holding can be administered."}
    if not ["appointed_warden", "merchant_council", "local_compact", "military_command"].has(governance_id):
        return {"ok": false, "reason": "Unknown governance model."}
    world_flags["holding_governance_" + holding_id] = governance_id
    return {"ok": true, "holding": holding_id, "governance": governance_id}


static func advance_turn(definitions: Array, world_flags: Dictionary, treasury: int) -> Dictionary:
    var income := 0
    var upkeep := 0
    var stability_delta := 0
    var provisions := 0
    var materials := 0
    var reports: Array = []
    for raw in definitions:
        if not raw is Dictionary:
            continue
        var definition: Dictionary = raw
        var id := str(definition.get("id", ""))
        if id == "" or not bool(world_flags.get("holding_claimed_" + id, false)):
            continue
        if str(world_flags.get("holding_owner_" + id, PLAYER_FACTION)) != PLAYER_FACTION:
            continue
        var status := str(world_flags.get("holding_status_" + id, "provisional"))
        var economy: Dictionary = definition.get("economy", {})
        var base_income := maxi(0, int(definition.get("turn_income", economy.get("gold", 0))))
        var base_upkeep := maxi(0, int(definition.get("garrison_upkeep", 1)))
        var local_provisions := maxi(0, int(economy.get("provisions", definition.get("turn_provisions", 0))))
        var local_materials := maxi(0, int(economy.get("materials", definition.get("turn_materials", 0))))
        var garrison := maxi(0, int(world_flags.get("holding_garrison_" + id, 0)))
        var local_income := base_income
        var local_upkeep := base_upkeep + garrison
        var governance := str(world_flags.get("holding_governance_" + id, definition.get("governance", "appointed_warden")))
        if governance == "merchant_council":
            local_income += ceili(float(base_income) * 0.2)
            local_upkeep += 1
        elif governance == "local_compact":
            local_upkeep = maxi(0, local_upkeep - 1)
        elif governance == "military_command":
            local_upkeep += 2
        var stability := clampi(int(world_flags.get("holding_stability_" + id, 35)), MIN_STABILITY, MAX_STABILITY)
        var delta := 0
        if garrison >= int(definition.get("recommended_garrison", 2)):
            delta += 3
        elif garrison == 0:
            delta -= 4
        if status == "provisional":
            delta -= 1
        if governance == "local_compact":
            delta += 2
        elif governance == "military_command":
            delta -= 1
        if stability < 25 and garrison == 0:
            delta -= 2
        stability = clampi(stability + delta, MIN_STABILITY, MAX_STABILITY)
        world_flags["holding_stability_" + id] = stability
        world_flags["holding_last_income_" + id] = local_income
        world_flags["holding_last_upkeep_" + id] = local_upkeep
        income += local_income
        upkeep += local_upkeep
        provisions += local_provisions
        materials += local_materials
        stability_delta += delta
        reports.append({
            "holding": id, "income": local_income, "upkeep": local_upkeep,
            "net": local_income - local_upkeep, "stability": stability,
            "stability_delta": delta, "governance": governance,
            "garrison": garrison, "provisions": local_provisions, "materials": local_materials, "risk": "high" if stability < 25 else ("watch" if stability < 50 else "stable")
        })
    var net := income - upkeep
    var next_treasury := maxi(0, treasury + net)
    var total_provisions := maxi(0, int(world_flags.get("empire_stockpile_provisions", 0)) + provisions)
    var total_materials := maxi(0, int(world_flags.get("empire_stockpile_materials", 0)) + materials)
    world_flags["empire_stockpile_provisions"] = total_provisions
    world_flags["empire_stockpile_materials"] = total_materials
    return {
        "ok": true, "income": income, "upkeep": upkeep, "net": net,
        "treasury_before": treasury, "treasury_after": next_treasury,
        "provisions_gained": provisions, "materials_gained": materials,
        "provisions_total": total_provisions, "materials_total": total_materials,
        "stability_delta": stability_delta, "reports": reports, "holdings_processed": reports.size()
    }


static func stability_label(value: int) -> String:
    if value < 25:
        return "Unrest"
    if value < 50:
        return "Uneasy"
    if value < 75:
        return "Settling"
    return "Secure"
