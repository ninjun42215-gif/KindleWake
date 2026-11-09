class_name BrinegateQuestSystem
extends RefCounted
## Pure campaign rules for the first Thalassar story arc.
const LEDGER_FLAG := "tideglass_ledger_found"
const DUNGEON_FLAG := "tideglass_grotto_cleared"
const DECISION_FLAG := "brinegate_ledger_decision"

static func can_report_ledger(flags: Dictionary) -> bool:
    return bool(flags.get(LEDGER_FLAG, false)) and bool(flags.get(DUNGEON_FLAG, false))

static func resolve_ledger_choice(flags: Dictionary, choice: String) -> Dictionary:
    if not can_report_ledger(flags):
        return {"ok": false, "reason": "The ledger and the grotto's guardian must both be dealt with first."}
    if bool(flags.get(DECISION_FLAG, false)):
        return {"ok": false, "reason": "The harbour council has already recorded this decision."}
    var updated: Dictionary = flags.duplicate(true)
    updated[DECISION_FLAG] = true
    if choice == "public":
        updated["brinegate_ledger_shared"] = true
        return {"ok": true, "world_flags": updated, "gold": 0, "text": "Ilyra reads the scraped oath aloud before the harbour council. The room falls silent; the Assembly can no longer claim the sea-lanes failed by accident. Your company earns the trust of the beacon crews."}
    if choice == "private":
        updated["brinegate_ledger_withheld"] = true
        return {"ok": true, "world_flags": updated, "gold": 60, "text": "Ilyra agrees to keep the Codicil seal out of the public record for now. A discreet Assembly patron pays 60 gold for the evidence to remain private. The truth is safer—but the beacon crews have not been heard."}
    return {"ok": false, "reason": "Unknown harbour decision."}
