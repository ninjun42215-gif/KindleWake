extends Control
## Five distinct, offline Act I quest challenges. Each challenge writes only validated
## campaign flags and returns to the town map; no network or external service is used.

var quest_id := ""
var step := 0
var mistakes := 0
var title_label: Label
var scene_label: Label
var progress_label: Label
var options_box: VBoxContainer
var feedback_label: Label

const CHALLENGES := {
    "blocked_well": {
        "title": "THE BLOCKED WELL — Restore the Flow",
        "intro": "The shaft is open, but the first bucket carries grit and a bitter smell. Mira lays out the tools while Wystan examines the old stone lining.",
        "steps": [
            {"scene":"A fallen brace has left loose masonry above the waterline. What must be secured first?","options":[["Lower the bucket immediately","wrong"],["Brace the loose stones before anyone enters","right"],["Pour lamp oil into the shaft","wrong"]],"success":"Bram braces the shaft. No more stones fall."},
            {"scene":"The first sample is cloudy. Wystan finds a cracked clay filter and a clean copper basin. What is the safe test?","options":[["Filter a sample, boil it, then inspect the cooled water","right"],["Taste it to identify the bitterness","wrong"],["Declare it safe because it is clear","wrong"]],"success":"The filtered sample is boiled and checked. The water is safe; the first buckets go to the wounded and children."}
        ]
    },
    "roof_before_banner": {
        "title": "ROOF BEFORE BANNER — The Carpenter's Sequence",
        "intro": "A storm is gathering over Kaer Sethorn. Hobb asks you to direct the repair crew before the weakened rafters give way.",
        "steps": [
            {"scene":"Three beams remain in the collapsed stable. Which should the crew choose?","options":[["The cracked beam with the house crest","wrong"],["The straight, sound beam with an intact joint","right"],["The wet beam with a split end","wrong"]],"success":"The sound beam is selected and hauled to the hall."},
            {"scene":"The roof is shored but not yet safe. What is the correct order?","options":[["Hang the banner, then patch the roof","wrong"],["Brace the ridge, secure the rafters, then cover the gap","right"],["Remove the remaining supports to make room","wrong"]],"success":"The ridge is braced and the rafters secured. The hall will hold through the storm."}
        ]
    },
    "last_convoy": {
        "title": "THE LAST CONVOY — Ambush at Sallow Ford",
        "intro": "Carter's wagons are pinned at the ford. A roadwolf captain named Hask Gravelteeth blocks the ridge path. You must protect the families and break the ambush.",
        "steps": [
            {"scene":"The ridge archers have the wagons in range. How do you move the convoy?","options":[["Send the families across the exposed ford first","wrong"],["Use the reed path to move families while shields cover the wagons","right"],["Abandon the families and chase the archers","wrong"]],"success":"The families reach cover. Bram holds the narrow path while Sela marks the ridge."},
            {"scene":"Hask charges the wagon line. What is the best counter?","options":[["Keep the line tight and draw him into the muddy bottleneck","right"],["Scatter the guards across the open bank","wrong"],["Leave the wagons unguarded to pursue him","wrong"]],"success":"Hask's charge bogs down in the ford approach. The guards hold; the captain is forced to face you."},
            {"scene":"Cinematic boss encounter — Hask raises his axe and calls for a surrender. How do you answer?","options":[["Challenge Hask while the company keeps civilians behind cover","right"],["Order the company to abandon the crossing","wrong"],["Threaten the families to make him hesitate","wrong"]],"success":"Hask is disarmed and the roadwolves break. The convoy manifest is recovered; the families and supplies are accounted for."}
        ]
    },
    "toll_book": {
        "title": "A NAME ON THE TOLL BOOK — Evidence Room",
        "intro": "Elder Hale spreads the toll book and Carter's manifest across the table. Three entries contradict the road records. Find the pattern before deciding what to reveal.",
        "steps": [
            {"scene":"The manifest says the south road was closed on the 12th. The toll book records a convoy passing on the 14th. What does that establish?","options":[["The toll entry cannot be accepted as proof of passage","right"],["The families must have travelled through the closed road","wrong"],["The manifest should be destroyed","wrong"]],"success":"The date mismatch establishes that the entry is false or forged."},
            {"scene":"The toll mark belongs to an office whose seal was retired before the 12th. What is the strongest conclusion?","options":[["Someone used an obsolete authority to legitimise the charge","right"],["The retired office automatically regained authority","wrong"],["The missing families never existed","wrong"]],"success":"The retired seal links the false entry to an unauthorised order."},
            {"scene":"The names identify living families who may be targeted. What is the responsible next step?","options":[["Publish every name without warning","wrong"],["Preserve the original, corroborate the entries and protect the families","right"],["Alter the book to make the case simpler","wrong"]],"success":"The evidence is authenticated without exposing the families to immediate retaliation."}
        ]
    },
    "first_oath": {
        "title": "THE FIRST OATH — The Hall of Ash",
        "intro": "A cinematic scene: the household gathers beneath the repaired roof. A masked toll-enforcer, the Ash Bailiff, arrives with an obsolete imperial warrant and demands the keep's obedience.",
        "steps": [
            {"scene":"The Ash Bailiff declares that the old seal grants him the right to take the grain. Brannoch asks what gives an oath its authority. What do you answer?","options":[["A seal is enough; the people must obey","wrong"],["An oath is a duty witnessed by those who must live under it","right"],["Power decides which law is true","wrong"]],"success":"The household stands with you. The Bailiff tears the warrant and draws his blade."},
            {"scene":"Cinematic boss encounter — The Ash Bailiff attacks. He fights behind the warrant's authority, not merely with his blade. How do you break his hold?","options":[["Have Elder Hale read the retired-seal record while Bram disarms him","right"],["Burn the toll book and silence the witnesses","wrong"],["Offer the Bailiff the right to collect from the families","wrong"]],"success":"Hale names the retired seal; the warrant is void. Bram knocks the Bailiff's blade aside and the household refuses his command."},
            {"scene":"The hall waits for the first oath. Which promise will you bind yourself to?","options":[["Protect the people before the house","people"],["Uphold the road laws and keep honest records","law"]],"success":"The household answers one by one. Brannoch records the oath beneath the old seal."}
        ]
    }
}

func _ready() -> void:
    quest_id = str(GameState.world_flags.get("_pending_act_one_challenge", ""))
    GameState.world_flags.erase("_pending_act_one_challenge")
    _build_ui()
    if not CHALLENGES.has(quest_id):
        _finish(false, "The challenge could not be loaded.")
        return
    var data: Dictionary = CHALLENGES[quest_id]
    title_label.text = str(data.title)
    scene_label.text = str(data.intro)
    _show_step()

func _build_ui() -> void:
    var bg := ColorRect.new()
    bg.color = Color(0.055, 0.065, 0.075, 1.0)
    bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    add_child(bg)
    var margin := MarginContainer.new()
    margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    margin.add_theme_constant_override("margin_left", 34)
    margin.add_theme_constant_override("margin_right", 34)
    margin.add_theme_constant_override("margin_top", 28)
    margin.add_theme_constant_override("margin_bottom", 28)
    add_child(margin)
    var column := VBoxContainer.new()
    column.add_theme_constant_override("separation", 16)
    margin.add_child(column)
    title_label = Label.new()
    title_label.add_theme_font_size_override("font_size", 30)
    title_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    column.add_child(title_label)
    progress_label = Label.new()
    progress_label.add_theme_font_size_override("font_size", 18)
    column.add_child(progress_label)
    scene_label = Label.new()
    scene_label.custom_minimum_size.y = 150
    scene_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    scene_label.add_theme_font_size_override("font_size", 22)
    column.add_child(scene_label)
    feedback_label = Label.new()
    feedback_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    feedback_label.add_theme_color_override("font_color", Color(0.75, 0.86, 0.72))
    column.add_child(feedback_label)
    options_box = VBoxContainer.new()
    options_box.add_theme_constant_override("separation", 12)
    column.add_child(options_box)
    var spacer := Control.new()
    spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
    column.add_child(spacer)
    var leave := Button.new()
    leave.text = "Leave challenge"
    leave.custom_minimum_size.y = 56
    leave.pressed.connect(_leave)
    column.add_child(leave)

func _show_step() -> void:
    var steps: Array = CHALLENGES[quest_id].steps
    if step >= steps.size():
        _complete_quest()
        return
    var data: Dictionary = steps[step]
    progress_label.text = "STAGE %d / %d     MISSTEPS: %d" % [step + 1, steps.size(), mistakes]
    scene_label.text = str(data.scene)
    feedback_label.text = ""
    for child in options_box.get_children():
        options_box.remove_child(child)
        child.queue_free()
    for option in data.options:
        var entry: Array = option
        var button := Button.new()
        button.text = str(entry[0])
        button.custom_minimum_size.y = 64
        button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        button.add_theme_font_size_override("font_size", 18)
        button.pressed.connect(_choose.bind(str(entry[1])))
        options_box.add_child(button)

func _choose(result: String) -> void:
    if result == "wrong":
        mistakes += 1
        feedback_label.text = "That choice puts the crew at risk. Reconsider the evidence and try again."
        progress_label.text = "STAGE %d / %d     MISSTEPS: %d" % [step + 1, CHALLENGES[quest_id].steps.size(), mistakes]
        return
    if quest_id == "first_oath" and (result == "people" or result == "law"):
        GameState.world_flags["chapter_1_oath_choice"] = "oath_people" if result == "people" else "oath_law"
        GameState.world_flags["sethmarch_people_first"] = result == "people"
        GameState.world_flags["sethmarch_law_first"] = result == "law"
    var success_text := str(CHALLENGES[quest_id].steps[step].get("success", "The stage is complete."))
    feedback_label.text = success_text
    step += 1
    if step >= CHALLENGES[quest_id].steps.size():
        _complete_quest()
    else:
        var next_button := Button.new()
        next_button.text = "Continue"
        next_button.custom_minimum_size.y = 58
        next_button.pressed.connect(_show_step)
        for child in options_box.get_children():
            options_box.remove_child(child)
            child.queue_free()
        options_box.add_child(next_button)

func _complete_quest() -> void:
    match quest_id:
        "blocked_well":
            GameState.world_flags["kaer_well_blockage_cleared"] = true
            GameState.world_flags["kaer_well_water_safe"] = true
            GameState.world_flags["kaer_well_repaired"] = true
        "roof_before_banner":
            GameState.world_flags["kaer_roof_timber_salvaged"] = true
            GameState.world_flags["kaer_roof_secured"] = true
        "last_convoy":
            GameState.world_flags["last_convoy_resolved"] = true
            GameState.world_flags["last_convoy_manifest_found"] = true
            GameState.world_flags["last_convoy_supplies_secured"] = true
            GameState.world_flags["last_convoy_families_sheltered"] = true
            GameState.world_flags["last_convoy_boss_defeated"] = true
        "toll_book":
            GameState.world_flags["toll_book_reviewed"] = true
            GameState.world_flags["toll_book_evidence_authenticated"] = true
            GameState.world_flags["toll_book_sealed"] = true
            GameState.world_flags["toll_book_public"] = false
        "first_oath":
            GameState.world_flags["chapter_1_first_oath"] = true
            GameState.world_flags["chapter_1_complete"] = true
    GameState.save_campaign("auto_a")
    _finish(true, "Quest complete. Your decisions have been recorded in the campaign chronicle.")

func _finish(success: bool, message: String) -> void:
    for child in options_box.get_children():
        options_box.remove_child(child)
        child.queue_free()
    scene_label.text = message
    feedback_label.text = "The campaign has been saved." if success else ""
    progress_label.text = "QUEST COMPLETE" if success else "CHALLENGE UNAVAILABLE"
    var back := Button.new()
    back.text = "Return to Kaer Sethorn"
    back.custom_minimum_size.y = 64
    back.pressed.connect(func(): get_tree().change_scene_to_file("res://Location.tscn"))
    options_box.add_child(back)

func _leave() -> void:
    get_tree().change_scene_to_file("res://Location.tscn")
