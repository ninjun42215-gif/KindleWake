extends Node

const PartyStateScript = preload("res://scripts/core/party_state.gd")
const RegionSaveState = preload("res://scripts/core/region_save_state.gd")
const CharacterCreationScript = preload("res://scripts/core/character_creation.gd")
const EncounterBuilderScript = preload("res://scripts/core/encounter_builder.gd")
const FactionSystem = preload("res://scripts/core/faction_system.gd")
const EmpireSystem = preload("res://scripts/core/empire_management_system.gd")
## Runtime campaign state (autoload "GameState"). Milestone 2: the persistent party.
## Autoload scripts have no class_name; tests use PartyState / EncounterBuilder / ShopSystem directly instead.

var party: PartyStateScript = PartyStateScript.new()
var rng := RandomNumberGenerator.new()

# Overworld state (Milestone 7). The world scene and the battle scene hand over through these fields.
var pending_battle: Dictionary = {}      # battle the battle scene should open next (empty = default story battle)
var from_world: bool = false             # true when the battle was started from the overworld
var world_pos: Vector2 = Vector2.ZERO    # active region position in pixels (ZERO = region start)
var active_region_id: String = "sethmarch"
var world_positions: Dictionary = {}       # region id -> [x, y], preserving each continent route
var world_flags: Dictionary = {}         # e.g. "camp_cleared", "found_watch"
var pending_location: String = ""        # town map the location scene opens next (set by the overworld)
var creation_profile: Dictionary = {}  # confirmed protagonist profile; stored with battle saves
var campaign_slot: String = ""
var faction_state: Dictionary = {}
var empire_state: Dictionary = EmpireSystem.new_state()




func _ready() -> void:
    rng.randomize()
    new_game()


func new_game(profile: Dictionary = {}) -> void:
    var selected: Dictionary = profile.duplicate(true)
    if selected.is_empty():
        selected = CharacterCreationScript.default_profile(GameData.character_creation)
    var protagonist: Dictionary = CharacterCreationScript.build_definition(
        GameData.characters.get("torren", {}), selected, GameData.character_creation, GameData.classes
    )
    if protagonist.is_empty():
        push_error("GameState: invalid protagonist profile; using the default profile.")
        selected = CharacterCreationScript.default_profile(GameData.character_creation)
        protagonist = CharacterCreationScript.build_definition(
            GameData.characters.get("torren", {}), selected, GameData.character_creation, GameData.classes
        )
    creation_profile = selected.duplicate(true)
    party = PartyStateScript.new_game(GameData.start, GameData.characters, protagonist)
    pending_battle = {}
    from_world = false
    world_pos = Vector2.ZERO
    active_region_id = "sethmarch"
    world_positions = {}
    world_flags = {}
    pending_location = ""
    faction_state = FactionSystem.new_campaign_state(GameData.factions)
    empire_state = EmpireSystem.new_state()


## Change diplomatic standing after an authored campaign event.
func adjust_faction_relation(faction_a: String, faction_b: String, amount: int, reason: String = "") -> bool:
    return FactionSystem.adjust_relation(faction_state, faction_a, faction_b, amount, reason)


## Set a treaty or war state after story conditions have been resolved.
func set_faction_diplomacy(faction_a: String, faction_b: String, next_state: String) -> bool:
    return FactionSystem.set_diplomatic_state(faction_state, faction_a, faction_b, next_state)


## Transfer a known atlas region after a battle, treaty or authored story outcome.
func transfer_faction_region(region_id: String, new_owner: String, cause: String) -> bool:
    return FactionSystem.transfer_region(faction_state, region_id, new_owner, cause)


## Unlock realm administration only when an authored story outcome grants governing authority.
func unlock_empire_management(realm_name: String = "The Crownlands") -> bool:
    return EmpireSystem.unlock(empire_state, realm_name)

## Story scripts call this only after the authored Crown Authority milestone resolves.
func complete_story_milestone(milestone_id: String) -> bool:
    if milestone_id != "crown_authority_granted" or bool(empire_state.get("unlocked", false)):
        return false
    world_flags["crown_authority_granted"] = true
    return unlock_empire_management("The Crownlands")

func set_empire_tax_rate(rate: String) -> bool:
    return EmpireSystem.set_tax_rate(empire_state, rate)

func toggle_empire_policy(policy: String) -> bool:
    return EmpireSystem.toggle_policy(empire_state, policy)

func appoint_empire_councillor(role: String, character_id: String) -> bool:
    if not party.sheets.has(character_id):
        return false
    return EmpireSystem.appoint_councillor(empire_state, role, character_id)

func dismiss_empire_councillor(role: String) -> bool:
    return EmpireSystem.dismiss_councillor(empire_state, role)


func player_controlled_provinces() -> Array:
    var owned: Array = []
    var territories: Dictionary = faction_state.get("territories", {})
    for province_id in territories.keys():
        var territory: Dictionary = territories[province_id]
        if str(territory.get("owner", "")) in ["house_dunmarrow", "crownlands"] and str(territory.get("status", "held")) == "held":
            owned.append(str(province_id))
    owned.sort()
    return owned


func appoint_province_governor(province_id: String, character_id: String) -> bool:
    if not party.sheets.has(character_id) or not player_controlled_provinces().has(province_id):
        return false
    return EmpireSystem.appoint_governor(empire_state, province_id, character_id, player_controlled_provinces())


func dismiss_province_governor(province_id: String) -> bool:
    if not player_controlled_provinces().has(province_id):
        return false
    return EmpireSystem.dismiss_governor(empire_state, province_id)


func construct_province_building(province_id: String, building_id: String) -> bool:
    return EmpireSystem.construct(empire_state, province_id, building_id, player_controlled_provinces())


func establish_empire_trade_route(origin: String, destination: String) -> bool:
    return EmpireSystem.establish_trade_route(empire_state, origin, destination, player_controlled_provinces(), atlas_region_adjacency())

func close_empire_trade_route(route_id: String) -> bool:
    return EmpireSystem.close_trade_route(empire_state, route_id)

func preview_empire_season() -> Dictionary:
    return EmpireSystem.preview_season(empire_state, player_controlled_provinces(), atlas_region_adjacency(), GameData.characters)


func suppress_empire_unrest() -> bool:
    return EmpireSystem.suppress_rebellion(empire_state)


func negotiate_faction_peace(faction_id: String, gold_offer: int = 100) -> bool:
    return EmpireSystem.negotiate_peace(faction_state, empire_state, "house_dunmarrow", faction_id, gold_offer)


func advance_empire_season() -> Dictionary:
    var report: Dictionary = EmpireSystem.advance_season(empire_state, player_controlled_provinces(), atlas_region_adjacency(), GameData.characters)
    if not bool(report.get("ok", false)):
        return report
    var faction_ids: Array = []
    for faction in GameData.factions.get("factions", []):
        faction_ids.append(str(faction.get("id", "")))
    var diplomacy_report: Dictionary = EmpireSystem.advance_faction_ai(faction_state, faction_ids, "house_dunmarrow")
    report["faction_declarations"] = diplomacy_report.get("declarations", [])
    report["faction_treaties"] = diplomacy_report.get("treaties", [])
    return report

func recruit_provincial_troops(province_id: String, troop_type: String, amount: int) -> bool:
    return EmpireSystem.recruit_troops(empire_state, province_id, troop_type, amount, player_controlled_provinces())


func disband_provincial_troops(province_id: String, troop_type: String, amount: int) -> bool:
    return EmpireSystem.disband_troops(empire_state, province_id, troop_type, amount, player_controlled_provinces())


func start_province_siege(army_id: String, target_region: String) -> bool:
	return EmpireSystem.start_siege(empire_state, army_id, target_region, player_controlled_provinces(), atlas_region_adjacency())


func resolve_province_siege(target_region: String, defender_strength: int, fort_level: int = 0) -> Dictionary:
	return EmpireSystem.resolve_siege_assault(empire_state, target_region, defender_strength, fort_level)


func confirm_siege_occupation(target_region: String, new_owner: String = "house_dunmarrow") -> bool:
	if not faction_state.get("territories", {}).has(target_region):
		return false
	if not empire_state.get("sieges", {}).has(target_region) or not bool(empire_state["sieges"][target_region].get("captured", false)):
		return false
	if not FactionSystem.transfer_region(faction_state, target_region, new_owner, "strategic siege occupation"):
		return false
	return EmpireSystem.complete_siege_transfer(empire_state, target_region)


func field_army_battle_deployment(army_id: String) -> Dictionary:
	return EmpireSystem.tactical_deployment(empire_state, army_id)


func apply_field_army_battle_result(army_id: String, casualties: Dictionary, won: bool) -> bool:
	return EmpireSystem.apply_tactical_result(empire_state, army_id, casualties, won)


func reduce_campaign_war_exhaustion(amount: int = 15) -> bool:
	return EmpireSystem.reduce_war_exhaustion(empire_state, amount)


func campaign_supply_network() -> Array:
	return EmpireSystem.supply_network(empire_state, player_controlled_provinces(), atlas_region_adjacency())


func empire_army_summary() -> Dictionary:
    return EmpireSystem.army_summary(empire_state)

func atlas_region_adjacency() -> Dictionary:
    var adjacency: Dictionary = {}
    var known: Dictionary = {}
    for continent in GameData.continents.get("continents", []):
        for region in continent.get("regions", []):
            known[str(region.get("id", ""))] = true
    for continent in GameData.continents.get("continents", []):
        for region in continent.get("regions", []):
            var region_id := str(region.get("id", ""))
            adjacency[region_id] = []
            for linked in region.get("links", []):
                var linked_id := str(linked)
                if known.has(linked_id) and not (adjacency[region_id] as Array).has(linked_id):
                    adjacency[region_id].append(linked_id)
    for region_id in adjacency.keys():
        for linked_id in adjacency[region_id]:
            if not adjacency.has(linked_id):
                adjacency[linked_id] = []
            if not (adjacency[linked_id] as Array).has(region_id):
                adjacency[linked_id].append(region_id)
    return adjacency


func mobilize_field_army(province_id: String, troop_counts: Dictionary, commander_id: String = "") -> String:
    if commander_id != "" and not party.sheets.has(commander_id):
        return ""
    return EmpireSystem.mobilize_army(empire_state, province_id, troop_counts, player_controlled_provinces(), commander_id)


func move_field_army(army_id: String, destination: String) -> bool:
    return EmpireSystem.move_field_army(empire_state, army_id, destination, atlas_region_adjacency(), player_controlled_provinces())


func field_army_summary() -> Dictionary:
    return EmpireSystem.field_army_summary(empire_state)



func start_field_army_battle(army_id: String, siege_assault: bool = false) -> bool:
	if not empire_state.get("field_armies", {}).has(army_id):
		return false
	var army: Dictionary = empire_state["field_armies"][army_id]
	var region_id := str(army.get("location", ""))
	var territory: Dictionary = faction_state.get("territories", {}).get(region_id, {})
	if region_id == "" or territory.is_empty() or player_controlled_provinces().has(region_id):
		return false
	var siege: Dictionary = empire_state.get("sieges", {}).get(region_id, {})
	if siege_assault:
		if siege.is_empty() or str(siege.get("army_id", "")) != army_id or int(siege.get("progress", 0)) < 4 or bool(siege.get("captured", false)):
			return false
	var garrison_rules: Dictionary = GameData.strategic_warfare.get("garrisons", {})
	var fortified_regions: Array = garrison_rules.get("fortified_regions", [])
	var fort_level := 1 if fortified_regions.has(region_id) else 0
	if siege_assault:
		fort_level = maxi(fort_level, clampi(int(siege.get("defence", 20)) / 20, 1, 3))
	var battle := EmpireSystem.build_tactical_battle(empire_state, army_id, GameData.battle_def("battle_01"), region_id, str(territory.get("owner", "")), siege_assault, fort_level, GameData.strategic_warfare)
	if battle.is_empty():
		return false
	pending_battle = battle
	from_world = true
	return true


func resolve_field_army_battle(battle: Dictionary, units: Array, won: bool) -> Dictionary:
	var army_id := str(battle.get("strategic_army_id", ""))
	var region_id := str(battle.get("strategic_region_id", ""))
	if army_id == "" or region_id == "":
		return {"ok": false, "reason": "not_a_strategic_battle"}
	var cohort_data: Dictionary = battle.get("strategic_units", {})
	var casualties: Dictionary = {}
	for unit_obj in units:
		var unit: BattleUnit = unit_obj
		if not cohort_data.has(unit.character_id):
			continue
		var cohort: Dictionary = cohort_data[unit.character_id]
		var count := int(cohort.get("count", 0))
		var lost := count
		if unit.is_alive():
			lost = int(round(float(count) * float(unit.max_hp() - unit.hp) / float(unit.max_hp())))
		if lost > 0:
			var troop_type := str(cohort.get("troop_type", "infantry"))
			casualties[troop_type] = int(casualties.get(troop_type, 0)) + lost
	var army_result_ok := EmpireSystem.resolve_tactical_battle(empire_state, str(battle.get("id", "")), army_id, casualties, won)
	if not army_result_ok:
		return {"ok": false, "reason": "army_result_rejected"}
	var effective_win := won and empire_state.get("field_armies", {}).has(army_id)
	var siege_resolved := false
	if bool(battle.get("strategic_siege_assault", false)):
		siege_resolved = EmpireSystem.resolve_siege_battle(empire_state, region_id, effective_win)
	save_campaign("auto_a")
	return {"ok": true, "won": effective_win, "casualties": casualties, "siege_resolved": siege_resolved}


func battle_db_for_battle(battle: Dictionary) -> Dictionary:
	var morale := 75
	var army_id := str(battle.get("strategic_army_id", ""))
	if empire_state.get("field_armies", {}).has(army_id):
		var army: Dictionary = empire_state["field_armies"][army_id]
		morale = int(army.get("morale", 75))
		if not bool(army.get("supplied", false)):
			morale -= 15
	return EmpireSystem.tactical_battle_database(battle_db(), battle, GameData.strategic_warfare, morale)

## Battle database with the party's current sheets (level, stats, equipment) substituted in.
func battle_db() -> Dictionary:
    return party.battle_db(GameData.as_db())


## Pays EXP, AP and gold after a battle (FF7 rules, see PartyState.battle_rewards).
## Returns {"reports", "gold", "spawned", "defeated", "total_exp", "total_ap"}; an empty report list on defeat.
func award_battle(units: Array, result: String) -> Dictionary:
    return party.apply_battle_result(units, result, rng, GameData.rules_db())


## A road ambush generated during campaign travel; encounters are part of the world, not a separate mode.
func travel_encounter_def() -> Dictionary:
    return EncounterBuilderScript.build_skirmish(GameData.encounters, GameData.battles, rng)


## Switch regions while preserving the last safe position in each one.
func set_active_region(region_id: String) -> void:
    if region_id == "" or region_id == active_region_id:
        return
    world_positions[active_region_id] = [world_pos.x, world_pos.y]
    active_region_id = region_id
    var saved: Array = world_positions.get(region_id, [])
    world_pos = Vector2(float(saved[0]), float(saved[1])) if saved.size() >= 2 else Vector2.ZERO


## Called by the overworld: the battle scene picks `def` up when it loads.
func start_battle_from_world(def: Dictionary) -> void:
    pending_battle = def
    from_world = true


## Called by the battle scene once: returns the queued battle (or {}) and clears it.
func take_pending_battle() -> Dictionary:
    var d: Dictionary = pending_battle
    pending_battle = {}
    return d


## Campaign-level save data is separate from the tactical battle snapshot.
func campaign_payload() -> Dictionary:
    return {
        "campaign": true,
        "party": party.to_dict(),
        "creation_profile": creation_profile.duplicate(true),
        "world_pos": [world_pos.x, world_pos.y],
        "active_region_id": active_region_id,
        "world_positions": world_positions.duplicate(true),
        "world_flags": world_flags.duplicate(true),
        "faction_state": faction_state.duplicate(true),
        "empire_state": empire_state.duplicate(true),
        "from_world": true
    }


func save_campaign(slot_id: String = "auto_a") -> bool:
    return SaveSystem.save_slot(slot_id, campaign_payload(), "Kindlewake • %d gold • %d companions" % [party.gold, party.roster.size()])


func load_campaign(slot_id: String) -> bool:
    var result: Dictionary = SaveSystem.load_slot(slot_id)
    if not bool(result.get("ok", false)):
        return false
    var payload: Dictionary = result.get("payload", {})
    if not RegionSaveState.is_valid_campaign_payload(payload):
        push_warning("GameState: refusing malformed campaign save in slot " + slot_id)
        return false

    # Build and verify all replacement state before touching the live campaign.
    var restored_party: PartyStateScript = PartyStateScript.from_dict(payload["party"])
    if restored_party.roster.is_empty():
        return false
    var region_state: Dictionary = RegionSaveState.from_payload(payload)
    party = restored_party
    creation_profile = (payload.get("creation_profile", {}) as Dictionary).duplicate(true)
    world_flags = (payload.get("world_flags", {}) as Dictionary).duplicate(true)
    faction_state = FactionSystem.normalize_state(payload.get("faction_state", {}), GameData.factions)
    empire_state = EmpireSystem.normalize_state(payload.get("empire_state", {}))
    world_pos = region_state["world_pos"]
    active_region_id = str(region_state["active_region_id"])
    world_positions = region_state["world_positions"]
    from_world = true
    pending_battle = {}
    pending_location = ""
    campaign_slot = slot_id
    return true


func newest_campaign_slot() -> String:
    var best := ""
    var newest := -1.0
    for slot in ["auto_a", "auto_b", "1", "2", "3"]:
        var info: Dictionary = SaveSystem.slot_info(slot)
        if bool(info.get("exists", false)) and float(info.get("unix", 0.0)) > newest:
            var loaded: Dictionary = SaveSystem.load_slot(slot)
            if bool(loaded.get("ok", false)) and bool((loaded.get("payload", {}) as Dictionary).get("campaign", false)):
                newest = float(info.get("unix", 0.0))
                best = slot
    return best
