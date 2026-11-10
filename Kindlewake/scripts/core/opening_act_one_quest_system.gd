extends RefCounted
class_name OpeningActOneQuestSystem
## Offline, flag-backed Act I quest rules for Kaer Sethorn and Sallow Crossing.
## Every action is idempotent and returns a copied world_flags dictionary.

static func inspect(story_id: String, flags: Dictionary) -> Dictionary:
    match story_id:
        "blocked_well":
            if bool(flags.get("kaer_well_water_safe", false)):
                return _view("BLOCKED WELL", "The well has been cleared, tested and reopened. Brannoch has ordered the first clean buckets kept for the wounded and the children.", [])
            if not bool(flags.get("kaer_well_blockage_cleared", false)):
                return _view("BLOCKED WELL", "The old well is choked with fallen masonry and a rotten timber brace. A labourer refuses to lower anyone until the stones are cleared. The work is dangerous, but the keep cannot live on rainwater.", [{"id":"clear_well","label":"Clear the fallen stones and brace the shaft"}])
            return _view("BLOCKED WELL", "The shaft is open. The first bucket smells of iron and old leaves. The water must be tested before anyone drinks it.", [{"id":"test_well","label":"Test the water and reopen the well"}])
        "roof_before_banner":
            if bool(flags.get("kaer_roof_secured", false)):
                return _view("ROOF BEFORE BANNER", "The great hall roof is secured. The wounded have dry beds, and the company can meet without rain falling through the rafters.", [])
            if not bool(flags.get("kaer_roof_timber_salvaged", false)):
                return _view("ROOF BEFORE BANNER", "The eastern roof has split along its old beams. The keep's banner can wait; the next storm will soak the sick and ruin the grain. Salvage sound timber from the collapsed stable.", [{"id":"salvage_roof_timber","label":"Salvage beams from the collapsed stable"}])
            return _view("ROOF BEFORE BANNER", "The beams are stacked in the yard. Raise them before the weather turns, and leave the torn banner folded until the hall is dry.", [{"id":"secure_roof","label":"Raise the beams and secure the roof"}])
        "last_convoy":
            if bool(flags.get("last_convoy_resolved", false)):
                var ending := "The families are sheltered in the keep." if bool(flags.get("last_convoy_families_sheltered", false)) else "The supply wagons reached the crossing under guard."
                return _view("THE LAST CONVOY", ending + " Carter has given you the convoy manifest and the names of those who did not arrive.", [])
            return _view("THE LAST CONVOY", "Carter Wen has found the last Dunmarrow convoy stranded beyond the ford. The wagons carry flour, lamp oil and the names of families driven from the southern farms. The roadwolves have been seen on the ridge. Decide what the company will protect.", [{"id":"escort_convoy","label":"Escort the wagons and secure the supplies"},{"id":"shelter_families","label":"Bring the families to shelter first"}])
        "toll_book":
            if not bool(flags.get("last_convoy_resolved", false)):
                return _view("A NAME ON THE TOLL BOOK", "Elder Hale has an old toll book, but he will not open it until Carter's convoy account can be compared against the names of the missing.", [])
            if bool(flags.get("toll_book_reviewed", false)):
                var outcome := "The names were read before the village." if bool(flags.get("toll_book_public", false)) else "The names remain sealed with Elder Hale."
                return _view("A NAME ON THE TOLL BOOK", outcome + " The record links the missing convoy to a toll order issued under a seal that should have been retired.", [])
            return _view("A NAME ON THE TOLL BOOK", "The convoy manifest and the old toll book do not agree. Several families were marked as having passed the gate days after their wagons vanished. Someone collected a toll for a road that was already closed. Elder Hale asks whether the names should be read aloud or kept safe until the evidence is stronger.", [{"id":"read_names","label":"Read the names publicly at the crossing"},{"id":"seal_names","label":"Seal the names and preserve the evidence"}])
        "first_oath":
            if bool(flags.get("chapter_1_first_oath", false)):
                return _view("THE FIRST OATH", "The first oath has been witnessed. Kaer Sethorn is no longer merely a roof over the company: the keep has accepted a duty to the people of the Sethmarch.", [])
            if not _act_one_ready(flags):
                return _view("THE FIRST OATH", "Steward Brannoch has gathered the household, but will not ask them to swear to an empty promise. The well must be safe, the hall roof secured, the convoy accounted for and the toll book examined first.", [])
            return _view("THE FIRST OATH", "Brannoch lays the old house seal on the table. “Your ancestors asked these roads for obedience. You can ask for trust, but you must first promise what you will owe in return.” Choose the words that will define the restored household.", [{"id":"oath_people","label":"Swear to protect the people before the house"},{"id":"oath_law","label":"Swear to uphold the road laws and keep honest records"}])
    return _view("STORY", "There is nothing more to do here.", [])

static func resolve(story_id: String, action_id: String, existing_flags: Dictionary) -> Dictionary:
    var current := inspect(story_id, existing_flags)
    var allowed := false
    for item in current.get("actions", []):
        if str(item.get("id", "")) == action_id:
            allowed = true
            break
    if not allowed:
        return {"ok":false,"reason":"That action is not currently available."}
    var flags: Dictionary = existing_flags.duplicate(true)
    var result_text := ""
    match story_id:
        "blocked_well":
            if action_id == "clear_well":
                flags["kaer_well_blockage_cleared"] = true
                result_text = "The stones come free after an hour of hauling. Beneath the last slab, the labourers find a cracked household cup wedged into the old brace. The shaft is open, but the water still needs testing."
            elif action_id == "test_well":
                flags["kaer_well_water_safe"] = true
                flags["kaer_well_repaired"] = true
                result_text = "Wystan tests the water and has the first bucket boiled. It is safe. The well rope creaks back into service, and the keep has clean water again."
        "roof_before_banner":
            if action_id == "salvage_roof_timber":
                flags["kaer_roof_timber_salvaged"] = true
                result_text = "The stable yields three sound beams. One bears the old Dunmarrow carpenter's mark. The company carries them to the hall before the rain returns."
            elif action_id == "secure_roof":
                flags["kaer_roof_secured"] = true
                result_text = "The beams are raised and the split rafters braced. The banner remains folded, but the hall is dry. Bram leaves his shield by the door and says the keep finally feels like somewhere a person might sleep."
        "last_convoy":
            flags["last_convoy_resolved"] = true
            flags["last_convoy_manifest_found"] = true
            if action_id == "escort_convoy":
                flags["last_convoy_supplies_secured"] = true
                flags["last_convoy_families_sheltered"] = false
                result_text = "The company forms a moving shield around the wagons. A warning horn sounds on the ridge, but the convoy reaches Sallow Crossing intact. Carter gives you the manifest and asks that the missing be remembered by name."
            elif action_id == "shelter_families":
                flags["last_convoy_supplies_secured"] = false
                flags["last_convoy_families_sheltered"] = true
                result_text = "The company leads the families through the reed path while Carter hides the wagons. The people reach shelter before dusk. Some flour is lost, but no child is left on the road. Carter gives you the manifest."
        "toll_book":
            flags["toll_book_reviewed"] = true
            if action_id == "read_names":
                flags["toll_book_public"] = true
                flags["toll_book_sealed"] = false
                result_text = "Elder Hale reads every name. The crowd does not cheer; it listens. The false toll entry is now public, and the families have a record that cannot quietly disappear."
            elif action_id == "seal_names":
                flags["toll_book_public"] = false
                flags["toll_book_sealed"] = true
                result_text = "Elder Hale seals the names in the household archive. The evidence is protected from those who profited from the false toll, though the village must wait for the truth to be made public."
        "first_oath":
            flags["chapter_1_first_oath"] = true
            flags["chapter_1_complete"] = true
            flags["chapter_1_oath_choice"] = action_id
            if action_id == "oath_people":
                flags["sethmarch_people_first"] = true
                result_text = "“The house exists to keep the road, the well and the hearth safe. No title excuses us from that duty.” The household answers one by one. Brannoch records the oath beneath the old seal."
            elif action_id == "oath_law":
                flags["sethmarch_law_first"] = true
                result_text = "“No toll shall be taken without a lawful road. No name shall be struck from the record by order or fear.” Elder Hale witnesses the words, and Brannoch records the oath beneath the old seal."
    if result_text == "":
        return {"ok":false,"reason":"The story action could not be resolved."}
    return {"ok":true,"world_flags":flags,"text":result_text}

static func _act_one_ready(flags: Dictionary) -> bool:
    return bool(flags.get("kaer_well_water_safe", false)) and bool(flags.get("kaer_roof_secured", false)) and bool(flags.get("last_convoy_resolved", false)) and bool(flags.get("toll_book_reviewed", false))

static func _view(title: String, body: String, actions: Array) -> Dictionary:
    return {"title":title,"body":body,"actions":actions}
