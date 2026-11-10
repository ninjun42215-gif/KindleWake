extends RefCounted
class_name ActTwoQuestSystem
## Offline progression gates and explicit consequence records for Act II: Broken Seals.

static func inspect(story_id: String, flags: Dictionary) -> Dictionary:
    if not bool(flags.get("chapter_1_complete", false)):
        return _view("BROKEN SEALS", "The Sethmarch oath must be witnessed before the company can take responsibility for the Orrowen dispute.", false, false)
    match story_id:
        "boundary_tree":
            var done := bool(flags.get("act2_boundary_resolved", false))
            return _view("THE BOUNDARY TREE", "A felled boundary marker has reopened the dispute between tenant families, foresters and House Orrowen. Reconstruct the old line from living testimony and the coppice marks; a sword cannot decide where the boundary belongs.", true, done)
        "orrowen_hearing":
            var ready := bool(flags.get("act2_boundary_resolved", false))
            var done := bool(flags.get("act2_hearing_resolved", false))
            return _view("THE ORROWEN HEARING", "Four accounts describe the same levy from different positions: a tenant, a forester, a House steward and a veteran who enforced the order. Each is partly true. Decide what can be made public without treating a witness as evidence to be spent.", ready, done)
        "changed_escort":
            var ready := bool(flags.get("act2_hearing_resolved", false))
            var done := bool(flags.get("act2_escort_resolved", false))
            return _view("THE ESCORT THAT CHANGED COURSE", "The escort's sealed writ orders the company to turn a marked supply train back. The wagons carry displaced families under a false banner. Hold the crossing, preserve the writ if possible, then decide whether to obey, shelter or negotiate.", ready, done)
    return _view("BROKEN SEALS", "No such Act II scenario is recorded.", false, false)


static func apply_boundary(flags_in: Dictionary, settlement: String) -> Dictionary:
    if not bool(flags_in.get("chapter_1_complete", false)):
        return {"ok":false,"reason":"The Sethmarch oath must be completed before Act II begins."}
    if bool(flags_in.get("act2_boundary_resolved", false)):
        return {"ok":false,"reason":"The boundary settlement has already been recorded."}
    if not ["shared_stewardship", "temporary_survey"].has(settlement):
        return {"ok":false,"reason":"That settlement is not available."}
    var flags := flags_in.duplicate(true)
    flags["act2_boundary_resolved"] = true
    flags["act2_boundary_evidence"] = ["coppice_marks", "tenant_stones", "forester_path", "steward_map"]
    flags["act2_boundary_settlement"] = settlement
    flags["orrowen_shared_stewardship"] = settlement == "shared_stewardship"
    flags["orrowen_temporary_survey"] = settlement == "temporary_survey"
    return {"ok":true,"world_flags":flags,"text":"The boundary is entered as a living record, not a claim of perfect certainty. The tenants and foresters receive a copy; the House steward signs as witness."}


static func apply_hearing(flags_in: Dictionary, outcome: String) -> Dictionary:
    if not bool(flags_in.get("act2_boundary_resolved", false)) or bool(flags_in.get("act2_hearing_resolved", false)):
        return {"ok":false,"reason":"The hearing is not ready or has already concluded."}
    if not ["protect_witness", "publish_verified_record"].has(outcome):
        return {"ok":false,"reason":"That hearing outcome is not available."}
    var flags := flags_in.duplicate(true)
    flags["act2_hearing_resolved"] = true
    flags["act2_hearing_outcome"] = outcome
    flags["act2_witness_protected"] = outcome == "protect_witness"
    flags["act2_record_published"] = outcome == "publish_verified_record"
    flags["act2_orrowen_testimony_verified"] = true
    return {"ok":true,"world_flags":flags,"text":"The hearing closes with the witnesses' limits recorded. The testimony is no longer a single convenient story, and the company is answerable for how it is used."}


static func apply_escort(flags_in: Dictionary, decision: String) -> Dictionary:
    if not bool(flags_in.get("act2_hearing_resolved", false)):
        return {"ok":false,"reason":"The Orrowen hearing must be completed before the escort scenario can conclude."}
    if not bool(flags_in.get("act2_escort_captain_defeated", false)) or bool(flags_in.get("act2_escort_resolved", false)):
        return {"ok":false,"reason":"The crossing must be secured before the escort decision can be recorded."}
    if not ["obey_writ", "grant_sanctuary", "negotiate_passage"].has(decision):
        return {"ok":false,"reason":"That escort decision is not available."}
    var flags := flags_in.duplicate(true)
    flags["act2_escort_resolved"] = true
    flags["act2_escort_decision"] = decision
    flags["act2_refugees_sheltered"] = decision != "obey_writ"
    flags["act2_political_debt_orrowen"] = decision == "negotiate_passage"
    flags["act2_writ_preserved"] = true
    flags["chapter_2_complete"] = true
    return {"ok":true,"world_flags":flags,"text":"The escort's order and the company's decision are entered into the chronicle. The families will remember who opened the crossing, and the Houses will remember the cost."}


static func _view(title: String, body: String, available: bool, complete: bool) -> Dictionary:
    return {"title":title,"body":body,"available":available,"complete":complete}
