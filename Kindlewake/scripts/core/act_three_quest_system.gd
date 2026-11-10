extends RefCounted
class_name ActThreeQuestSystem
## Act III: linked river operations and civilian-first regional consequences.
static func inspect(story_id: String, flags: Dictionary) -> Dictionary:
    if not bool(flags.get("chapter_2_complete", false)):
        return _view("THE RIVER CAMPAIGN", "The Orrowen crossing must be resolved before the company can commit to a wider river operation.", false, false)
    match story_id:
        "three_bridges":
            return _view("THREE BRIDGES", "Three linked objectives control the river road: take the ford, keep the old bridge open for evacuation, and prevent the downstream storehouse from burning.", true, bool(flags.get("act3_bridges_resolved", false)))
        "banner_reeds":
            return _view("THE BANNER IN THE REEDS", "A hostile banner moves through the reeds, but the people beneath it are civilians. Its bearer is a deserter who took the colours to draw pursuit away from them.", bool(flags.get("act3_bridges_resolved", false)), bool(flags.get("act3_banner_resolved", false)))
        "price_crossing":
            return _view("THE PRICE OF A CROSSING", "The river road is open, but wagons, wounded soldiers and displaced families all need it. Decide how to spend the secured supplies and who receives the first safe passage.", bool(flags.get("act3_banner_resolved", false)), bool(flags.get("act3_crossing_resolved", false)))
    return _view("THE RIVER CAMPAIGN", "No such Act III scenario is recorded.", false, false)
static func apply_bridges(flags_in: Dictionary) -> Dictionary:
    if not bool(flags_in.get("chapter_2_complete", false)) or bool(flags_in.get("act3_bridges_resolved", false)):
        return {"ok":false,"reason":"The river operation is not ready or has already been resolved."}
    if not bool(flags_in.get("act3_three_bridges_victory", false)):
        return {"ok":false,"reason":"The river operation must be secured in battle."}
    var flags := flags_in.duplicate(true)
    flags["act3_bridges_resolved"] = true
    flags["act3_ford_secured"] = true
    flags["act3_evacuation_bridge_held"] = true
    flags["act3_storehouse_saved"] = bool(flags.get("act3_storehouse_saved_in_battle", false))
    flags["act3_bram_bridge_command"] = true
    flags["act3_sela_recon_intelligence"] = true
    flags["act3_regional_control_river_road"] = "contested_secure"
    return {"ok":true,"world_flags":flags,"text":"The ford is held, the evacuation bridge remains usable, and the storehouse has been accounted for. Bram's report is blunt: holding a crossing is not the same as owning the road."}
static func apply_banner(flags_in: Dictionary, decision: String) -> Dictionary:
    if not bool(flags_in.get("act3_bridges_resolved", false)) or bool(flags_in.get("act3_banner_resolved", false)):
        return {"ok":false,"reason":"The reed-bank encounter is not ready or has already been resolved."}
    if not ["protect_deserters", "expose_banner", "use_as_leverage"].has(decision):
        return {"ok":false,"reason":"That banner decision is not available."}
    var flags := flags_in.duplicate(true)
    flags["act3_banner_resolved"] = true
    flags["act3_banner_decision"] = decision
    flags["act3_civilians_sheltered"] = decision != "expose_banner"
    flags["act3_deserter_testimony"] = decision == "protect_deserters"
    flags["act3_banner_leverage"] = decision == "use_as_leverage"
    flags["act3_bram_retreat_confession_heard"] = true
    flags["act3_bram_relationship_river_confession"] = "heard_without_absolution"
    return {"ok":true,"world_flags":flags,"text":"Bram admits that a village he once served was labelled enemy ground during a retreat. He does not ask to be forgiven. The company records what happened here without pretending it repairs what happened then."}
static func apply_crossing(flags_in: Dictionary, decision: String) -> Dictionary:
    if not bool(flags_in.get("act3_banner_resolved", false)) or bool(flags_in.get("act3_crossing_resolved", false)):
        return {"ok":false,"reason":"The river road allocation is not ready or has already been resolved."}
    if not ["evacuate_families", "prioritise_wounded", "protect_stores"].has(decision):
        return {"ok":false,"reason":"That allocation is not available."}
    var flags := flags_in.duplicate(true)
    flags["act3_crossing_resolved"] = true
    flags["act3_crossing_allocation"] = decision
    flags["act3_refugees_evacuated"] = decision == "evacuate_families"
    flags["act3_wounded_evacuated"] = decision == "prioritise_wounded"
    flags["act3_stores_protected"] = decision == "protect_stores"
    flags["chapter_3_complete"] = true
    flags["act3_regional_control_river_road"] = "company_administered" if decision == "protect_stores" else "shared_corridor"
    return {"ok":true,"world_flags":flags,"text":"The river-road allocation is entered in the campaign record. The choice changes who reaches safety first; it does not erase the needs left behind."}
static func _view(title: String, body: String, available: bool, complete: bool) -> Dictionary:
    return {"title":title,"body":body,"available":available,"complete":complete}
