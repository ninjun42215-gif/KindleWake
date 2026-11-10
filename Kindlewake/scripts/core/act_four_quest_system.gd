extends RefCounted
class_name ActFourQuestSystem
## Winter of Knives: archive truth, witness agency and the cost of publication.
static func inspect(story_id: String, flags: Dictionary) -> Dictionary:
    if not bool(flags.get("chapter_3_complete", false)):
        return _view("WINTER OF KNIVES", "The river road must be settled before the company can reach the Quillon Archive.", false, false)
    match story_id:
        "quillon_archive":
            return _view("THE QUILLON ARCHIVE", "The custodians disagree about releasing a missing Codicil clause. Their archive is a living institution, not a vault waiting to be robbed. Testimony, prior record-keeping and the company's conduct may open the doors.", true, bool(flags.get("act4_archive_resolved", false)))
        "witness_recanted":
            return _view("THE WITNESS WHO RECANTED", "A witness from the Orrowen hearing has withdrawn their testimony after threats against their family. The threat can be investigated, but the witness's consent cannot be replaced by the company's need for proof.", bool(flags.get("act4_archive_resolved", false)), bool(flags.get("act4_witness_resolved", false)))
    return _view("WINTER OF KNIVES", "No such Act IV scenario is recorded.", false, false)
static func apply_archive_access(flags_in: Dictionary, route: String) -> Dictionary:
    if not bool(flags_in.get("chapter_3_complete", false)) or bool(flags_in.get("act4_archive_access_resolved", false)):
        return _fail("Archive access is not ready or has already been resolved.")
    if not ["custodian_petition", "coalition_mediation", "forced_entry"].has(route):
        return _fail("That archive access route is not available.")
    var flags := flags_in.duplicate(true)
    flags["act4_archive_access_resolved"] = true
    flags["act4_archive_access_route"] = route
    flags["act4_archive_breach"] = route == "forced_entry"
    flags["act4_custodian_trust"] = "damaged" if route == "forced_entry" else ("coalition" if route == "coalition_mediation" else "conditional")
    return {"ok":true,"world_flags":flags,"text":"The archive doors open, but the manner of entry will shape who trusts the record that follows."}
static func apply_archive_record(flags_in: Dictionary, decision: String) -> Dictionary:
    if not bool(flags_in.get("act4_archive_access_resolved", false)) or bool(flags_in.get("act4_archive_resolved", false)):
        return _fail("The archive record cannot yet be settled.")
    if not ["preserve_original", "publish_verified_copy", "entrust_custodians"].has(decision):
        return _fail("That record decision is not available.")
    var flags := flags_in.duplicate(true)
    flags["act4_archive_resolved"] = true
    flags["act4_archive_record_decision"] = decision
    flags["act4_original_preserved"] = true
    flags["act4_verified_copy_published"] = decision == "publish_verified_copy"
    flags["act4_custodian_compact"] = decision == "entrust_custodians"
    flags["act4_edmer_revision_found"] = true
    flags["act4_edmer_clause_understood"] = true
    flags["act4_company_fracture_topic"] = "publication_and_responsibility"
    return {"ok":true,"world_flags":flags,"text":"The missing revision is found. Edmer concealed the clause to protect someone from an immediate injustice, but the omission weakened the public record and left later generations unable to test his judgment."}
static func apply_witness(flags_in: Dictionary, decision: String) -> Dictionary:
    if not bool(flags_in.get("act4_archive_resolved", false)) or bool(flags_in.get("act4_witness_resolved", false)):
        return _fail("The witness's account is not ready to be addressed.")
    if not ["honor_withdrawal", "offer_safe_haven", "investigate_threat"].has(decision):
        return _fail("That witness decision is not available.")
    var flags := flags_in.duplicate(true)
    flags["act4_witness_resolved"] = true
    flags["act4_witness_decision"] = decision
    flags["act4_witness_agency_respected"] = true
    flags["act4_family_protection_requested"] = decision != "honor_withdrawal"
    flags["act4_threat_evidence_found"] = decision == "investigate_threat"
    flags["act4_witness_testimony_reaffirmed"] = false
    flags["act4_witness_testimony_usable"] = false
    if decision == "offer_safe_haven":
        flags["act4_witness_relocation_offered"] = true
        flags["act4_witness_relocation_requires_consent"] = true
    if decision == "investigate_threat":
        flags["act4_threat_investigation_complete"] = true
    flags["chapter_4_complete"] = true
    return {"ok":true,"world_flags":flags,"text":"The threat is documented, but the witness is not made to testify. Their family receives a protection plan only with their knowledge and consent. The company must carry the truth it has, not the testimony it wishes it had."}
static func _view(title: String, body: String, available: bool, complete: bool) -> Dictionary:
    return {"title":title,"body":body,"available":available,"complete":complete}
static func _fail(reason: String) -> Dictionary:
    return {"ok":false,"reason":reason}
