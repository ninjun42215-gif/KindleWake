extends RefCounted
class_name ActTwoQuestSystem
## Offline progression gates and explicit consequence records for Act II: Broken Seals.

const CHALLENGES := {
    "boundary_tree": {
        "title":"THE BOUNDARY TREE — Reconstruct the Line",
        "intro":"The old boundary tree lies split beside the coppice. Sela recognises three cuts in the stump; the tenants remember the stones, while the forester knows which paths were maintained.",
        "steps":[
            {"scene":"The stump has three old coppice cuts. What should be recorded first?","options":[["The age and direction of the cuts, without assigning ownership","right"],["The House steward's newest map as unquestionable truth","wrong"],["The nearest armed patrol's preferred boundary","wrong"]],"success":"Sela sketches the cuts and marks the uncertainty in the survey."},
            {"scene":"The tenant family points to foundation stones beneath the bracken. The forester says the stones mark a maintained path, not a property line. What is the useful next step?","options":[["Record both accounts and compare the stones with the coppice marks","right"],["Discard the tenant account because it is not written","wrong"],["Move the stones to make the map simpler","wrong"]],"success":"The stones and coppice marks establish an older shared-use boundary."},
            {"scene":"The steward's map places the tenant fields inside the House enclosure, but its ink is newer than the coppice cuts. Which conclusion is justified?","options":[["The map is evidence of a later claim, not proof of the original line","right"],["The newest document must always be correct","wrong"],["The forester alone can decide ownership","wrong"]],"success":"The company can now present a defensible record without pretending the evidence is perfect."},
            {"scene":"Choose the settlement to carry into the public hearing.","options":[["Create shared stewardship with tenant and forester witnesses","shared_stewardship"],["Order a temporary survey and postpone the final boundary","temporary_survey"]],"success":"The boundary record is witnessed and copied for the hearing."}
        ]
    },
    "orrowen_hearing": {
        "title":"THE ORROWEN HEARING — Four Incomplete Accounts",
        "intro":"A tenant, a forester, a House steward and a veteran have come to the hall. Their accounts overlap, but none can safely speak for everyone affected.",
        "steps":[
            {"scene":"The tenant says the levy was collected twice. The steward's account lists one payment, while the veteran remembers a second collection on a different road. What should be checked?","options":[["Compare dates, road locations and receipts before judging intent","right"],["Assume the tenant is lying because the steward has a seal","wrong"],["Treat the veteran's memory as a complete ledger","wrong"]],"success":"The dates show two collections, but not who authorised the second."},
            {"scene":"The forester confirms that the boundary path was used by both settlements. The House map excludes the path. What does this establish?","options":[["The map omits a shared-use practice that must be considered","right"],["The whole House claim is automatically void","wrong"],["The path belongs to whoever can guard it","wrong"]],"success":"The hearing records the difference between a legal map and lived use."},
            {"scene":"The veteran admits enforcing the second collection under an order he never saw signed. Which statement is fair?","options":[["The collection happened; the author and authority remain unproven","right"],["The veteran's admission proves the steward ordered it","wrong"],["The missing signature proves no order existed","wrong"]],"success":"The testimony is verified without inventing a culprit."},
            {"scene":"The tenant witness fears retaliation. Choose how to handle the verified record.","options":[["Protect the witness and keep identifying details sealed","protect_witness"],["Publish the verified record with names withheld","publish_verified_record"]],"success":"The hearing records both the verified facts and the limits placed on disclosure."}
        ]
    },
    "changed_escort": {
        "title":"THE ESCORT THAT CHANGED COURSE — Hold the Crossing",
        "intro":"A sealed writ orders the company to turn a supply train back. Sela spots children beneath the false banner. Wystan insists that sanctuary must be practical, not merely spoken.",
        "steps":[
            {"scene":"The narrow crossing is watched from the ridge. Which route keeps the families away from the exposed road?","options":[["Move civilians along the reed bank while the company screens the bridge","route_reeds"],["March the wagons and families together across the open ford","wrong"],["Send the civilians ahead without an escort","wrong"]],"success":"The families are moved behind the reed bank; the wagons remain covered."},
            {"scene":"Odran Vale's retainers are preparing to block the bridge. How should the company form?","options":[["Bram anchors the bridge while Sela covers the ridge and Wystan stays with civilians","formation_shield"],["Scatter the company across both banks","wrong"],["Leave the crossing to pursue the banner bearer","wrong"]],"success":"The company forms a defensive screen. The escort turns into a tactical fight."},
            {"scene":"Tactical encounter — defeat Writ-Captain Odran Vale. Keep the bridge approach open; protecting the families is the mission, not capturing a flag.","battle_id":"act2_changed_escort","battle_flag":"act2_escort_captain_defeated"},
            {"scene":"The writ is recovered. What will the company do with the families and the order?","options":[["Obey the writ and turn the families back","obey_writ"],["Grant sanctuary and accept the House's objection","grant_sanctuary"],["Negotiate temporary passage and accept a political debt","negotiate_passage"]],"success":"The crossing is secured and the decision is recorded."}
        ]
    }
}

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
