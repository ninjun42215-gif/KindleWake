extends Node2D

const RecruitmentSystem = preload("res://scripts/core/recruitment_system.gd")
const BrinegateQuestSystem = preload("res://scripts/core/brinegate_quest_system.gd")
const OpeningActOneQuestSystem = preload("res://scripts/core/opening_act_one_quest_system.gd")
const ActTwoQuestSystem = preload("res://scripts/core/act_two_quest_system.gd")
const ActThreeQuestSystem = preload("res://scripts/core/act_three_quest_system.gd")
const ExplorationControls = preload("res://scripts/ui/exploration_controls.gd")
const VirtualStick = preload("res://scripts/ui/virtual_stick.gd")
const PremiumUITheme = preload("res://scripts/ui/premium_ui_theme.gd")
## Towns and building interiors (data/locations.json, rules in LocalMap).
## Walk with tap / drag like the overworld. Walking into a door loads the next map (town -> house -> town) inside this
## scene; walking onto the exit (E) of a town returns to the overworld. People and objects ("spots") are used with the
## prompt button: some talk, some open the Party, Gear and Shop screen.

const TILE := 48.0
const WALK_SPEED := 200.0
const PLAYER_RADIUS := 11.0
const SPOT_RADIUS := 1.6                 # tiles

var maps: Dictionary = {}
var current_map_id: String = ""
var lmap: LocalMap
var camera: Camera2D
var player_pos: Vector2 = Vector2.ZERO
var target: Vector2 = Vector2.ZERO
var has_target: bool = false
var pressing: bool = false
var facing_left: bool = false
var last_cell: Vector2i = Vector2i(-1, -1)
var near_spot: Dictionary = {}
var panel_open: bool = false
var hud_text: String = ""
var leaving: bool = false

var hud_root: Control
var info_label: Label
var prompt_btn: Button
var spot_panel: PanelContainer
var spot_title: Label
var spot_text: Label
var spot_buttons: VBoxContainer
var party_screen: PartyScreen
var move_stick: VirtualStick
var run_btn: Button
var run_toggled: bool = false
var moving_vector: Vector2 = Vector2.ZERO


func _ready() -> void:
    ExplorationControls.configure()
    maps = LocalMap.load_all(GameData.locations)
    camera = Camera2D.new()
    add_child(camera)
    camera.make_current()
    _build_ui()
    var id: String = GameState.pending_location
    if not maps.has(id):
        id = "crossing"
    _load_map(id, Vector2i(-1, -1))


func cell_center(c: Vector2i) -> Vector2:
    return (Vector2(c) + Vector2(0.5, 0.5)) * TILE


func cell_of(pos: Vector2) -> Vector2i:
    return Vector2i(floori(pos.x / TILE), floori(pos.y / TILE))


func _load_map(id: String, spawn: Vector2i) -> void:
    current_map_id = id
    lmap = maps[id]
    var sp: Vector2i = spawn if spawn.x >= 0 else lmap.entry
    player_pos = cell_center(sp)
    last_cell = sp
    has_target = false
    pressing = false
    near_spot = {}
    prompt_btn.visible = false
    _update_camera(true)
    hud_text = ""
    queue_redraw()


# ------------------------------------------------------------------ input and movement

func _unhandled_input(event: InputEvent) -> void:
    if panel_open or party_screen.visible or leaving:
        return
    if event is InputEventMouseButton:
        var mb := event as InputEventMouseButton
        if mb.button_index == MOUSE_BUTTON_LEFT:
            pressing = mb.pressed
            if mb.pressed:
                _set_target(mb.position)
    elif event is InputEventMouseMotion and pressing:
        _set_target((event as InputEventMouseMotion).position)


func _set_target(screen_pos: Vector2) -> void:
    target = get_canvas_transform().affine_inverse() * screen_pos
    has_target = true


func _free_at(p: Vector2) -> bool:
    var r: float = PLAYER_RADIUS
    for off in [Vector2(-r, -r * 0.4), Vector2(r, -r * 0.4), Vector2(-r, r), Vector2(r, r)]:
        if not lmap.walkable(cell_of(p + off)):
            return false
    return true


func _process(delta: float) -> void:
    if leaving:
        return
    if not panel_open and not party_screen.visible:
        moving_vector = ExplorationControls.movement_vector()
        if move_stick != null and move_stick.value.length() > moving_vector.length():
            moving_vector = move_stick.value
        if moving_vector.length() > 0.12:
            _move_direction(delta, moving_vector.normalized())
        else:
            _move(delta)
        _update_near()
        if Input.is_action_just_pressed("interact") and not near_spot.is_empty():
            _on_prompt_pressed()
    _update_camera(false)
    _update_hud()
    queue_redraw()


func _move(delta: float) -> void:
    if not has_target:
        return
    var to: Vector2 = target - player_pos
    var dist: float = to.length()
    if dist < 4.0:
        has_target = false
        return
    var multiplier: float = 1.6 if run_toggled or ExplorationControls.running() else 1.0
    var step: float = minf(dist, WALK_SPEED * multiplier * delta)
    var dir: Vector2 = to / dist
    var before: Vector2 = player_pos
    var nx: Vector2 = player_pos + Vector2(dir.x * step, 0.0)
    if _free_at(nx):
        player_pos = nx
    var ny: Vector2 = player_pos + Vector2(0.0, dir.y * step)
    if _free_at(ny):
        player_pos = ny
    if player_pos.distance_to(before) < 0.01:
        if not pressing:
            has_target = false
        return
    if absf(dir.x) > 0.2:
        facing_left = dir.x < 0.0
    var cell: Vector2i = cell_of(player_pos)
    if cell != last_cell:
        last_cell = cell
        _on_enter_cell(cell)



func _move_direction(delta: float, direction: Vector2) -> void:
    has_target = false
    var multiplier: float = 1.6 if run_toggled or ExplorationControls.running() else 1.0
    var step: float = WALK_SPEED * multiplier * delta
    var before := player_pos
    var nx := player_pos + Vector2(direction.x * step, 0.0)
    if _free_at(nx):
        player_pos = nx
    var ny := player_pos + Vector2(0.0, direction.y * step)
    if _free_at(ny):
        player_pos = ny
    if player_pos.distance_to(before) < 0.01:
        return
    if absf(direction.x) > 0.12:
        facing_left = direction.x < 0.0
    var cell := cell_of(player_pos)
    if cell != last_cell:
        last_cell = cell
        _on_enter_cell(cell)


func _toggle_run() -> void:
    run_toggled = not run_toggled
    if run_btn != null:
        run_btn.text = "RUN: ON" if run_toggled else "RUN"

func _on_enter_cell(cell: Vector2i) -> void:
    var door: Dictionary = lmap.door_at(cell)
    if not door.is_empty():
        var sp: Array = door.get("spawn", [1, 1])
        _load_map(str(door["to"]), Vector2i(int(sp[0]), int(sp[1])))
    elif lmap.is_exit(cell):
        leaving = true
        get_tree().change_scene_to_file("res://World.tscn")


func _update_camera(snap: bool) -> void:
    var vp: Vector2 = get_viewport_rect().size
    var map_px := Vector2(float(lmap.width), float(lmap.height)) * TILE
    var z: float = lmap.zoom
    if z <= 0.0:
        z = clampf(minf(vp.x / (map_px.x + 120.0), vp.y / (map_px.y + 120.0)), 1.0, 1.9)
    camera.zoom = Vector2(z, z)
    var half: Vector2 = vp / z * 0.5
    var c: Vector2 = player_pos
    c.x = map_px.x * 0.5 if map_px.x <= half.x * 2.0 else clampf(c.x, half.x, map_px.x - half.x)
    c.y = map_px.y * 0.5 if map_px.y <= half.y * 2.0 else clampf(c.y, half.y, map_px.y - half.y)
    camera.position = c if snap else camera.position.lerp(c, 0.25)


# ------------------------------------------------------------------ spots

func _update_near() -> void:
    var best: Dictionary = {}
    var best_d: float = SPOT_RADIUS * TILE
    for s in lmap.spots:
        var d: float = cell_center(lmap.spot_cell(s)).distance_to(player_pos)
        if d < best_d:
            best_d = d
            best = s
    near_spot = best
    prompt_btn.visible = not best.is_empty() and not panel_open
    if not best.is_empty():
        var verb: String = "Talk to" if bool(best.get("npc", false)) else "Use"
        prompt_btn.text = "A  %s %s" % [verb, str(best.get("name", ""))]


func _on_prompt_pressed() -> void:
    if near_spot.is_empty():
        return
    panel_open = true
    has_target = false
    pressing = false
    prompt_btn.visible = false
    spot_title.text = str(near_spot.get("name", ""))
    spot_text.text = str(near_spot.get("text", ""))
    var extra_dialogue: Array = near_spot.get("dialogue", [])
    for line in extra_dialogue:
        spot_text.text += "\\n\\n" + str(line)
    for c in spot_buttons.get_children():
        spot_buttons.remove_child(c)
        c.queue_free()
    var spot_kind: String = str(near_spot.get("kind", "text"))
    if spot_kind == "party":
        spot_buttons.add_child(_btn("Open market and company stores", _open_party))
    elif spot_kind == "inn":
        spot_buttons.add_child(_btn("Rest the company — 20 gold", _rest_at_inn))
    elif spot_kind == "choice":
        if not BrinegateQuestSystem.can_report_ledger(GameState.world_flags):
            spot_text.text += "\n\nThe missing lighthouse ledger is still in Tideglass Grotto. Ilyra will not put an incomplete account before the Assembly."
        elif bool(GameState.world_flags.get("brinegate_ledger_decision", false)):
            spot_text.text += "\n\nYour decision has been entered into the harbour chronicle."
        else:
            spot_buttons.add_child(_btn("Present the ledger publicly", _resolve_brinegate_choice.bind("public")))
            spot_buttons.add_child(_btn("Keep the Codicil seal private", _resolve_brinegate_choice.bind("private")))
    elif spot_kind == "story":
        var story_id: String = str(near_spot.get("story_id", ""))
        if story_id in ["boundary_tree", "orrowen_hearing", "changed_escort"]:
            _render_act_two_story(near_spot)
        elif story_id in ["three_bridges", "banner_reeds", "price_crossing"]:
            _render_act_three_story(near_spot)
        else:
            _render_opening_story(near_spot)
    elif spot_kind == "recruit":
        var cid: String = str(near_spot.get("character_id", ""))
        var definition: Dictionary = GameData.characters.get(cid, {})
        var availability: Dictionary = RecruitmentSystem.inspect(GameState.party, cid, definition, GameState.world_flags, near_spot)
        if bool(availability.get("available", false)):
            var cost: int = int(availability.get("cost", 0))
            var invite_label: String = "Invite " + str(near_spot.get("name", "traveller"))
            if cost > 0:
                invite_label += " — %d gold" % cost
            spot_buttons.add_child(_btn(invite_label, _recruit.bind(near_spot)))
        else:
            spot_text.text += "\n\n" + str(availability.get("reason", "This recruit is not available."))
    elif spot_kind == "treasure":
        var cache_flag: String = _spot_flag("cache")
        if not bool(GameState.world_flags.get(cache_flag, false)):
            spot_buttons.add_child(_btn("Open the cache", _claim_treasure.bind(near_spot)))
        else:
            spot_text.text += "\n\nThe cache is empty."
    elif spot_kind == "boss":
        var boss_flag: String = str(near_spot.get("world_flag_on_victory", ""))
        if not bool(GameState.world_flags.get(boss_flag, false)):
            spot_buttons.add_child(_btn("Challenge the guardian", _challenge_boss.bind(near_spot)))
        else:
            spot_text.text += "\n\nThe guardian has been defeated."
    spot_buttons.add_child(_btn("Close", _close_panel))
    spot_panel.visible = true


func _render_opening_story(spot: Dictionary) -> void:
    var story_id: String = str(spot.get("story_id", ""))
    var view: Dictionary = OpeningActOneQuestSystem.inspect(story_id, GameState.world_flags)
    spot_title.text = str(view.get("title", spot.get("name", "Story")))
    spot_text.text = str(view.get("body", ""))
    for child in spot_buttons.get_children():
        spot_buttons.remove_child(child)
        child.queue_free()
    if not (view.get("actions", []) as Array).is_empty():
        spot_buttons.add_child(_btn("Begin playable quest", _launch_opening_challenge.bind(story_id)))
    else:
        spot_text.text += "\\n\\nThis quest has been completed or is waiting for another campaign milestone."


func _render_act_two_story(spot: Dictionary) -> void:
    var story_id := str(spot.get("story_id", ""))
    var view: Dictionary = ActTwoQuestSystem.inspect(story_id, GameState.world_flags)
    spot_title.text = str(view.get("title", spot.get("name", "Story")))
    spot_text.text = str(view.get("body", ""))
    for child in spot_buttons.get_children():
        spot_buttons.remove_child(child)
        child.queue_free()
    if bool(view.get("available", false)) and not bool(view.get("complete", false)):
        spot_buttons.add_child(_btn("Begin playable Act II scenario", _launch_act_two_challenge.bind(story_id)))
    elif bool(view.get("complete", false)):
        spot_text.text += "\n\nThis scenario is recorded in the campaign chronicle."
    else:
        spot_text.text += "\n\nThis scenario is waiting for an earlier Act II decision."
    spot_buttons.add_child(_btn("Close", _close_panel))


func _launch_act_two_challenge(story_id: String) -> void:
    var view: Dictionary = ActTwoQuestSystem.inspect(story_id, GameState.world_flags)
    if not bool(view.get("available", false)) or bool(view.get("complete", false)):
        spot_text.text += "\n\nThis scenario is not currently available."
        return
    GameState.pending_location = current_map_id
    if str(GameState.world_flags.get("_pending_act_two_challenge", "")) != story_id:
        GameState.world_flags["_pending_act_two_challenge"] = story_id
        GameState.world_flags["_pending_act_two_challenge_step"] = 0
    get_tree().change_scene_to_file("res://ActTwoQuestChallenge.tscn")

func _render_act_three_story(spot: Dictionary) -> void:
    var story_id := str(spot.get("story_id", ""))
    var view: Dictionary = ActThreeQuestSystem.inspect(story_id, GameState.world_flags)
    spot_title.text = str(view.get("title", spot.get("name", "Story")))
    spot_text.text = str(view.get("body", ""))
    for child in spot_buttons.get_children():
        spot_buttons.remove_child(child)
        child.queue_free()
    if bool(view.get("available", false)) and not bool(view.get("complete", false)):
        spot_buttons.add_child(_btn("Begin playable Act III scenario", _launch_act_three_challenge.bind(story_id)))
    elif bool(view.get("complete", false)):
        spot_text.text += "\n\nThis scenario is recorded in the campaign chronicle."
    else:
        spot_text.text += "\n\nThis scenario is waiting for an earlier Act III decision."
    spot_buttons.add_child(_btn("Close", _close_panel))


func _launch_act_three_challenge(story_id: String) -> void:
    var view: Dictionary = ActThreeQuestSystem.inspect(story_id, GameState.world_flags)
    if not bool(view.get("available", false)) or bool(view.get("complete", false)):
        spot_text.text += "\n\nThis scenario is not currently available."
        return
    GameState.pending_location = current_map_id
    if str(GameState.world_flags.get("_pending_act_three_challenge", "")) != story_id:
        GameState.world_flags["_pending_act_three_challenge"] = story_id
        GameState.world_flags["_pending_act_three_challenge_step"] = 0
    get_tree().change_scene_to_file("res://ActThreeQuestChallenge.tscn")


func _launch_opening_challenge(story_id: String) -> void:
    if not ["blocked_well", "roof_before_banner", "last_convoy", "toll_book", "first_oath"].has(story_id):
        spot_text.text += "\\n\\nThis story challenge is not available."
        return
    GameState.pending_location = current_map_id
    GameState.world_flags["_pending_act_one_challenge"] = story_id
    get_tree().change_scene_to_file("res://ActOneQuestChallenge.tscn")


func _resolve_opening_story_action(story_id: String, action_id: String) -> void:
    var outcome: Dictionary = OpeningActOneQuestSystem.resolve(story_id, action_id, GameState.world_flags)
    if not bool(outcome.get("ok", false)):
        spot_text.text += "\\n\\n" + str(outcome.get("reason", "That action is unavailable."))
        return
    GameState.world_flags = (outcome.get("world_flags", GameState.world_flags) as Dictionary).duplicate(true)
    GameState.save_campaign("auto_a")
    var result_text: String = str(outcome.get("text", ""))
    var view: Dictionary = OpeningActOneQuestSystem.inspect(story_id, GameState.world_flags)
    spot_text.text = result_text + "\\n\\n" + str(view.get("body", ""))
    for child in spot_buttons.get_children():
        spot_buttons.remove_child(child)
        child.queue_free()
    for action in view.get("actions", []):
        var entry: Dictionary = action
        spot_buttons.add_child(_btn(str(entry.get("label", "Continue")), _resolve_opening_story_action.bind(story_id, str(entry.get("id", "")))))
    spot_buttons.add_child(_btn("Close", _close_panel))


func _resolve_brinegate_choice(choice: String) -> void:
    var outcome: Dictionary = BrinegateQuestSystem.resolve_ledger_choice(GameState.world_flags, choice)
    if not bool(outcome.get("ok", false)):
        spot_text.text += "\n\n" + str(outcome.get("reason", "The decision cannot be made."))
        return
    GameState.world_flags = (outcome.get("world_flags", GameState.world_flags) as Dictionary).duplicate(true)
    GameState.party.gold += int(outcome.get("gold", 0))
    spot_text.text += "\n\n" + str(outcome.get("text", ""))
    GameState.save_campaign("auto_a")
    for child in spot_buttons.get_children():
        if child is Button and ((child as Button).text.begins_with("Present") or (child as Button).text.begins_with("Keep")):
            (child as Button).disabled = true

func _close_panel() -> void:
    panel_open = false
    spot_panel.visible = false


func _spot_flag(suffix: String) -> String:
    return "dungeon_" + lmap.name.to_lower().replace(" ", "_") + "_" + suffix


func _rest_at_inn() -> void:
    if GameState.party.gold < 20:
        spot_text.text += "\n\nYou need 20 gold to pay for beds and a meal."
        return
    GameState.party.gold -= 20
    for cid in GameState.party.roster:
        var sheet: CharacterSheet = GameState.party.sheet(cid)
        if sheet != null:
            sheet.base_stats["mor"] = 70
    spot_text.text += "\n\nThe company rests. Morale is restored across the roster."
    for c in spot_buttons.get_children():
        if c is Button and (c as Button).text.begins_with("Rest the company"):
            (c as Button).disabled = true


func _recruit(spot: Dictionary) -> void:
    var cid: String = str(spot.get("character_id", ""))
    var definition: Dictionary = GameData.characters.get(cid, {})
    var result: Dictionary = RecruitmentSystem.recruit(GameState.party, cid, definition, GameState.world_flags, spot)
    if not bool(result.get("ok", false)):
        spot_text.text += "\n\n" + str(result.get("reason", "There is no available recruit."))
        return
    var member: CharacterSheet = GameState.party.sheet(cid)
    spot_text.text += "\n\n" + str(spot.get("name", "The traveller")) + " has joined the company. Loyalty: %d/100." % member.loyalty
    for c in spot_buttons.get_children():
        if c is Button and (c as Button).text.begins_with("Invite"):
            (c as Button).disabled = true


func _claim_treasure(spot: Dictionary) -> void:
    var flag: String = _spot_flag("cache")
    var reward: int = int(spot.get("reward_gold", 120))
    if bool(GameState.world_flags.get(flag, false)):
        return
    GameState.party.gold += reward
    var reward_item: String = str(spot.get("reward_item", ""))
    var loot_text: String = ""
    if reward_item != "" and GameData.items.has(reward_item):
        GameState.party.add_item(reward_item, 1)
        loot_text = " You also recover %s." % str(GameData.items[reward_item].get("name", reward_item))
    GameState.world_flags[flag] = true
    if current_map_id == "dungeon_tideglass":
        GameState.world_flags["tideglass_ledger_found"] = true
    spot_text.text += "\n\nYou recover %d gold.%s" % [reward, loot_text]


func _challenge_boss(spot: Dictionary) -> void:
    var battle_id: String = str(spot.get("battle_id", ""))
    var def: Dictionary = GameData.battle_def(battle_id).duplicate(true)
    if def.is_empty():
        spot_text.text += "\n\nThe guardian's battle record is missing."
        return
    def["world_flag_on_victory"] = str(spot.get("world_flag_on_victory", ""))
    GameState.start_battle_from_world(def)
    get_tree().change_scene_to_file("res://Main.tscn")


func _open_party() -> void:
    # Company stores are a staffed service, not a remote menu. The player must
    # still be beside the actual market/company NPC to open this screen.
    if near_spot.is_empty() or str(near_spot.get("kind", "")) != "party":
        hud_text = "The shopkeeper is not available here."
        return
    var keeper_id: String = str(near_spot.get("shopkeeper_id", ""))
    if not bool(near_spot.get("npc_active", true)) or (keeper_id != "" and not bool(GameState.world_flags.get("npc_active_" + keeper_id, true))):
        spot_text.text += "\n\nThe shopkeeper is away. The market is closed."
        return
    var shop_def: Dictionary = GameData.shop.duplicate(true)
    var regional: Dictionary = shop_def.get("regional_stocks", {})
    if regional.has(current_map_id):
        var stock: Dictionary = regional[current_map_id]
        shop_def["items"] = (stock.get("items", []) as Array).duplicate()
        shop_def["sigils"] = (stock.get("sigils", shop_def.get("sigils", [])) as Array).duplicate()
        shop_def["runes"] = (stock.get("runes", []) as Array).duplicate()
    var is_rune_service := bool(near_spot.get("rune_service", false)) or bool(near_spot.get("blacksmith", false))
    party_screen.setup(GameState.party, GameData.party_db(), shop_def, true, is_rune_service, bool(near_spot.get("blacksmith", false)))
    party_screen.open()


func _on_party_closed() -> void:
    hud_text = ""


# ------------------------------------------------------------------ drawing

func _draw() -> void:
    if lmap == null:
        return
    var inv: Transform2D = get_canvas_transform().affine_inverse()
    var vp: Vector2 = get_viewport_rect().size
    var tl: Vector2 = inv * Vector2.ZERO
    var br: Vector2 = inv * vp
    var x0: int = clampi(floori(tl.x / TILE) - 1, 0, lmap.width - 1)
    var y0: int = clampi(floori(tl.y / TILE) - 1, 0, lmap.height - 1)
    var x1: int = clampi(floori(br.x / TILE) + 1, 0, lmap.width - 1)
    var y1: int = clampi(floori(br.y / TILE) + 1, 0, lmap.height - 1)
    var black := Rect2(tl - Vector2(TILE, TILE), br - tl + Vector2(TILE * 2.0, TILE * 2.0))
    draw_rect(black, Color(0.05, 0.04, 0.05))
    var props: Array = []
    for y in range(y0, y1 + 1):
        for x in range(x0, x1 + 1):
            var c := Vector2i(x, y)
            _draw_tile(c)
            if lmap.tile_at(c) == "T":
                props.append({"y": float(y) * TILE + TILE * 0.9, "kind": "tree", "cell": c})
    for s in lmap.spots:
        var sc: Vector2i = lmap.spot_cell(s)
        props.append({"y": cell_center(sc).y + 10.0, "kind": "spot", "spot": s})
    props.append({"y": player_pos.y + 6.0, "kind": "player"})
    props.sort_custom(func(a, b): return float(a["y"]) < float(b["y"]))
    for o in props:
        var d: Dictionary = o
        var k: String = str(d["kind"])
        if k == "tree":
            _draw_tree(d["cell"])
        elif k == "spot":
            _draw_spot(d["spot"])
        else:
            _draw_player()
    if has_target and not panel_open:
        draw_arc(target, 8.0, 0.0, TAU, 16, Color(1, 1, 1, 0.45), 2.0)


func _shade(c: Color, cell: Vector2i, amount: float = 0.1) -> Color:
    var f: float = 1.0 - amount * 0.5 + amount * WorldMap.hash01(cell.x, cell.y, 5)
    return Color(c.r * f, c.g * f, c.b * f)


func _draw_tile(c: Vector2i) -> void:
    var t: String = lmap.tile_at(c)
    var o := Vector2(float(c.x), float(c.y)) * TILE
    var full := Rect2(o, Vector2(TILE + 0.5, TILE + 0.5))
    var h: float = WorldMap.hash01(c.x, c.y, 17)
    var indoor: bool = lmap.kind == "interior"
    # ground under everything that stands on it
    if "=BSKXHUPCN+".contains(t):
        draw_rect(full, _shade(Color(0.50, 0.36, 0.22), c, 0.08))
        if int(c.x + c.y) % 2 == 0:
            draw_line(o + Vector2(0, TILE * 0.5), o + Vector2(TILE, TILE * 0.5), Color(0, 0, 0, 0.12), 1.0)
    elif ",E1234".contains(t):
        draw_rect(full, _shade(Color(0.62, 0.50, 0.33), c, 0.12))
    else:
        draw_rect(full, _shade(Color(0.30, 0.50, 0.30), c, 0.12))
    match t:
        "#":
            draw_rect(full, _shade(Color(0.46, 0.46, 0.49), c, 0.1))
            for r in range(3):
                var yy: float = o.y + TILE * (0.17 + 0.33 * float(r))
                draw_line(Vector2(o.x, yy), Vector2(o.x + TILE, yy), Color(0, 0, 0, 0.28), 1.5)
                var off: float = TILE * (0.25 if r % 2 == 0 else 0.7)
                draw_line(Vector2(o.x + off, yy), Vector2(o.x + off, yy + TILE * 0.33), Color(0, 0, 0, 0.28), 1.5)
        "r", "b":
            var col: Color = Color(0.64, 0.27, 0.22) if t == "r" else Color(0.26, 0.42, 0.60)
            draw_rect(full, _shade(col, c, 0.08))
            for r in range(4):
                var yy2: float = o.y + TILE * 0.25 * float(r + 1)
                draw_line(Vector2(o.x, yy2), Vector2(o.x + TILE, yy2), Color(0, 0, 0, 0.25), 2.0)
        "w":
            draw_rect(full, _shade(Color(0.70, 0.58, 0.40), c, 0.06))
            draw_line(o + Vector2(TILE * 0.5, 0), o + Vector2(TILE * 0.5, TILE), Color(0, 0, 0, 0.18), 1.5)
            if h > 0.35:
                draw_rect(Rect2(o + Vector2(TILE * 0.28, TILE * 0.22), Vector2(TILE * 0.44, TILE * 0.40)), Color(0.28, 0.40, 0.55))
                draw_rect(Rect2(o + Vector2(TILE * 0.28, TILE * 0.22), Vector2(TILE * 0.44, TILE * 0.40)), Color(0.15, 0.1, 0.06), false, 2.0)
        "1", "2", "3", "4":
            draw_rect(Rect2(o + Vector2(TILE * 0.12, TILE * 0.05), Vector2(TILE * 0.76, TILE * 0.95)), Color(0.34, 0.20, 0.10))
            draw_arc(o + Vector2(TILE * 0.5, TILE * 0.3), TILE * 0.38, PI, TAU, 10, Color(0.34, 0.20, 0.10), 5.0)
            draw_circle(o + Vector2(TILE * 0.72, TILE * 0.58), 2.5, Color(0.9, 0.8, 0.4))
        "E":
            draw_colored_polygon(PackedVector2Array([o + Vector2(TILE * 0.3, TILE * 0.3), o + Vector2(TILE * 0.7, TILE * 0.3), o + Vector2(TILE * 0.5, TILE * 0.72)]), Color(1, 1, 1, 0.35))
        "~":
            draw_rect(full, _shade(Color(0.27, 0.46, 0.62), c, 0.1))
            if h > 0.5:
                draw_line(o + Vector2(10, 22), o + Vector2(26, 22), Color(1, 1, 1, 0.22), 2.0)
        "F":
            draw_line(o + Vector2(0, TILE * 0.45), o + Vector2(TILE, TILE * 0.45), Color(0.45, 0.30, 0.16), 3.0)
            draw_line(o + Vector2(0, TILE * 0.7), o + Vector2(TILE, TILE * 0.7), Color(0.45, 0.30, 0.16), 3.0)
            draw_rect(Rect2(o + Vector2(TILE * 0.42, TILE * 0.3), Vector2(6, TILE * 0.55)), Color(0.35, 0.22, 0.12))
        "+":
            draw_rect(full, Color(0.62, 0.17, 0.17))
            draw_rect(Rect2(o + Vector2(3, 3), Vector2(TILE - 6, TILE - 6)), Color(0.76, 0.62, 0.25), false, 2.0)
        "B":
            draw_rect(Rect2(o + Vector2(4, 6), Vector2(TILE - 8, TILE - 10)), Color(0.42, 0.28, 0.16))
            draw_rect(Rect2(o + Vector2(8, 10), Vector2(TILE - 16, TILE - 22)), Color(0.90, 0.88, 0.80))
            draw_rect(Rect2(o + Vector2(8, 10), Vector2(TILE - 16, 10)), Color(0.78, 0.30, 0.28))
        "S":
            draw_rect(Rect2(o + Vector2(2, 2), Vector2(TILE - 4, TILE - 4)), Color(0.33, 0.21, 0.12))
            for i in range(5):
                var bc := Color(0.7, 0.25 + 0.12 * float(i % 3), 0.2 + 0.15 * float(i % 2))
                draw_rect(Rect2(o + Vector2(6.0 + 8.0 * float(i), 8), Vector2(6, 14)), bc)
                draw_rect(Rect2(o + Vector2(6.0 + 8.0 * float(i), 28), Vector2(6, 12)), bc.lerp(Color(0.3, 0.5, 0.7), 0.5))
        "K":
            draw_rect(Rect2(o + Vector2(0, 8), Vector2(TILE + 0.5, TILE - 14)), Color(0.45, 0.29, 0.15))
            draw_rect(Rect2(o + Vector2(0, 8), Vector2(TILE + 0.5, 8)), Color(0.60, 0.42, 0.24))
        "X":
            draw_circle(o + Vector2(TILE * 0.5, TILE * 0.52), TILE * 0.38, Color(0.50, 0.33, 0.18))
            draw_circle(o + Vector2(TILE * 0.5, TILE * 0.52), TILE * 0.30, Color(0.82, 0.76, 0.62))
        "H":
            draw_rect(Rect2(o + Vector2(2, 2), Vector2(TILE - 4, TILE - 4)), Color(0.40, 0.40, 0.43))
            draw_rect(Rect2(o + Vector2(10, 14), Vector2(TILE - 20, TILE - 16)), Color(0.08, 0.05, 0.04))
            draw_colored_polygon(PackedVector2Array([o + Vector2(TILE * 0.3, TILE * 0.9), o + Vector2(TILE * 0.7, TILE * 0.9), o + Vector2(TILE * 0.5, TILE * 0.45)]), Color(1.0, 0.55, 0.15))
        "U":
            draw_circle(o + Vector2(TILE * 0.5, TILE * 0.55), TILE * 0.32, Color(0.48, 0.30, 0.14))
            draw_arc(o + Vector2(TILE * 0.5, TILE * 0.55), TILE * 0.32, 0.0, TAU, 14, Color(0.25, 0.16, 0.08), 3.0)
        "P":
            draw_rect(Rect2(o + Vector2(TILE * 0.2, TILE * 0.1), Vector2(TILE * 0.6, TILE * 0.8)), Color(0.55, 0.55, 0.58))
            draw_rect(Rect2(o + Vector2(TILE * 0.15, TILE * 0.05), Vector2(TILE * 0.7, 7)), Color(0.68, 0.68, 0.70))
        "N":
            draw_rect(full, Color(0.46, 0.46, 0.49))
            draw_colored_polygon(PackedVector2Array([o + Vector2(TILE * 0.25, 4), o + Vector2(TILE * 0.75, 4), o + Vector2(TILE * 0.75, TILE * 0.8), o + Vector2(TILE * 0.5, TILE * 0.6), o + Vector2(TILE * 0.25, TILE * 0.8)]), Color(0.70, 0.18, 0.18))
        "C":
            draw_rect(Rect2(o + Vector2(6, 8), Vector2(TILE - 12, TILE - 14)), Color(0.58, 0.42, 0.22))
            draw_rect(Rect2(o + Vector2(6, 8), Vector2(TILE - 12, TILE - 14)), Color(0.28, 0.18, 0.08), false, 2.0)
    # Small hand-painted props make settlements feel inhabited without cluttering walkable lanes.
    var prop_center := o + Vector2(TILE * 0.5, TILE * 0.48)
    match t:
        "S":
            Art.draw_prop(self, "crate", prop_center + Vector2(0, -3), 0.34)
        "U":
            Art.draw_prop(self, "barrel", prop_center + Vector2(0, -3), 0.34)
        "H":
            Art.draw_prop(self, "torch", prop_center + Vector2(0, -2), 0.34)
        "N":
            Art.draw_prop(self, "banner", prop_center + Vector2(0, -2), 0.34)
        "P":
            Art.draw_prop(self, "column", prop_center + Vector2(0, -2), 0.34)
        _:
            if not indoor and t == "." and WorldMap.hash01(c.x, c.y, 43) > 0.94:
                Art.draw_prop(self, "flower", prop_center + Vector2(0, -5), 0.22)
    if indoor and t == "#" and c.y == 0:
        draw_rect(Rect2(o + Vector2(0, TILE - 6), Vector2(TILE, 6)), Color(0, 0, 0, 0.3))


func _draw_tree(c: Vector2i) -> void:
    var h: float = WorldMap.hash01(c.x, c.y, 29)
    var foot := Vector2(float(c.x) + 0.5, float(c.y) + 0.92) * TILE
    var names: Array[String] = ["pine_a", "pine_b", "pine_c", "tree_a", "tree_b"]
    if not Art.draw_world(self, names[int(h * 4.99)], foot, 0.62 + 0.1 * h):
        draw_colored_polygon(PackedVector2Array([foot + Vector2(-16, 0), foot + Vector2(16, 0), foot + Vector2(0, -44)]), Color(0.14, 0.32, 0.20))


func _draw_spot(s: Dictionary) -> void:
    var c: Vector2 = cell_center(lmap.spot_cell(s))
    var t: float = float(Time.get_ticks_msec()) / 1000.0
    var near: bool = not near_spot.is_empty() and near_spot == s
    if bool(s.get("npc", false)):
        var tint_a: Array = s.get("tint", [1, 1, 1])
        var tint := Color(float(tint_a[0]), float(tint_a[1]), float(tint_a[2]))
        var foot: Vector2 = c + Vector2(0, 12)
        draw_colored_polygon(_ellipse(foot + Vector2(0, 2), 13.0, 5.0), Color(0, 0, 0, 0.3))
        if not Art.draw_unit(self, "soldier", "idle", t + c.x * 0.01, foot, 2.0, c.x > player_pos.x, tint):
            draw_rect(Rect2(foot + Vector2(-8, -30), Vector2(16, 28)), tint)
    var bob: float = sin(t * 3.0) * 3.0
    var tip: Vector2 = c + Vector2(0, -52 + bob)
    var col := Color(1.0, 0.85, 0.25) if near else Color(1.0, 0.85, 0.25, 0.65)
    draw_colored_polygon(PackedVector2Array([tip + Vector2(-6, -8), tip + Vector2(6, -8), tip]), col)
    var label: String = str(s.get("name", ""))
    if near:
        draw_string(ThemeDB.fallback_font, c + Vector2(-79, -69), label, HORIZONTAL_ALIGNMENT_CENTER, 160, 18, Color(0, 0, 0, 0.85))
        draw_string(ThemeDB.fallback_font, c + Vector2(-80, -70), label, HORIZONTAL_ALIGNMENT_CENTER, 160, 18, Color(1.0, 0.95, 0.8))


func _draw_player() -> void:
    var p: Vector2 = player_pos
    draw_colored_polygon(_ellipse(p + Vector2(0, 6), 14.0, 5.0), Color(0, 0, 0, 0.35))
    var t: float = float(Time.get_ticks_msec()) / 1000.0
    var walking: bool = (has_target or moving_vector.length() > 0.12) and not panel_open
    var sprinting: bool = walking and (run_toggled or ExplorationControls.running())
    var motion_state: String = "run" if sprinting and Art.unit_sheet("soldier", "run") != null else ("walk" if walking else "idle")
    if not Art.draw_unit(self, "soldier", motion_state, t, p + Vector2(0, 8), 2.0, facing_left):
        draw_rect(Rect2(p + Vector2(-8, -24), Vector2(16, 28)), Color(0.22, 0.50, 0.88))


func _ellipse(center: Vector2, rx: float, ry: float) -> PackedVector2Array:
    var pts := PackedVector2Array()
    for i in range(16):
        var a: float = TAU * float(i) / 16.0
        pts.append(center + Vector2(cos(a) * rx, sin(a) * ry))
    return pts


# ------------------------------------------------------------------ HUD

func _hud_panel(alpha: float = 0.84) -> PanelContainer:
    var panel := PanelContainer.new()
    panel.add_theme_stylebox_override("panel", PremiumUITheme.panel_style(alpha))
    return panel

func _btn(text: String, handler: Callable, font_size: int = 24) -> Button:
    var button := Button.new()
    button.text = text
    var viewport_size: Vector2 = get_viewport().get_visible_rect().size
    var compact: bool = viewport_size.x < 900.0 or viewport_size.y > viewport_size.x * 1.15
    button.custom_minimum_size = Vector2(clampf(viewport_size.x * 0.42, 210.0, 300.0), 58.0 if compact else 72.0)
    button.add_theme_font_size_override("font_size", mini(font_size, 19) if compact else font_size)
    PremiumUITheme.apply_button(button)
    button.pressed.connect(handler)
    return button

func _apply_safe_area() -> void:
    if hud_root == null or not is_inside_tree():
        return
    var l: float = 0.0
    var t: float = 0.0
    var r: float = 0.0
    var b: float = 0.0
    if OS.has_feature("mobile"):
        var win: Vector2i = DisplayServer.window_get_size()
        var safe: Rect2i = DisplayServer.get_display_safe_area()
        var vp: Vector2 = get_viewport().get_visible_rect().size
        if win.x > 0 and win.y > 0 and safe.size.x > 0 and safe.size.y > 0:
            var sx: float = vp.x / float(win.x)
            var sy: float = vp.y / float(win.y)
            l = clampf(float(safe.position.x) * sx, 0.0, 120.0)
            t = clampf(float(safe.position.y) * sy, 0.0, 120.0)
            r = clampf(float(win.x - safe.position.x - safe.size.x) * sx, 0.0, 120.0)
            b = clampf(float(win.y - safe.position.y - safe.size.y) * sy, 0.0, 120.0)
    hud_root.offset_left = l
    hud_root.offset_top = t
    hud_root.offset_right = -r
    hud_root.offset_bottom = -b
    var viewport_size: Vector2 = get_viewport().get_visible_rect().size
    var compact: bool = viewport_size.x < 900.0 or viewport_size.y > viewport_size.x * 1.15
    if info_label != null:
        info_label.custom_minimum_size = Vector2(clampf(viewport_size.x * 0.25, 160.0, 300.0), 0.0)
        info_label.add_theme_font_size_override("font_size", 15 if compact else 20)
    if prompt_btn != null:
        prompt_btn.custom_minimum_size = Vector2(clampf(viewport_size.x * 0.48, 230.0, 420.0), clampf(viewport_size.y * 0.11, 56.0, 84.0))
        prompt_btn.add_theme_font_size_override("font_size", 19 if compact else 28)
    if spot_panel != null:
        spot_panel.custom_minimum_size = Vector2(maxf(260.0, minf(viewport_size.x - 24.0, 700.0)), 0.0)
    if spot_title != null:
        spot_title.add_theme_font_size_override("font_size", 25 if compact else 36)
    if spot_text != null:
        spot_text.custom_minimum_size = Vector2(maxf(220.0, minf(viewport_size.x - 72.0, 560.0)), 0.0)
        spot_text.add_theme_font_size_override("font_size", 17 if compact else 22)


func _build_ui() -> void:
    var layer := CanvasLayer.new()
    add_child(layer)
    var root := Control.new()
    root.mouse_filter = Control.MOUSE_FILTER_IGNORE
    layer.add_child(root)
    root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    hud_root = root
    get_viewport().size_changed.connect(_apply_safe_area)
    call_deferred("_apply_safe_area")

    var info_panel := _hud_panel()
    info_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
    info_label = Label.new()
    info_label.custom_minimum_size = Vector2(300, 0)
    info_label.add_theme_font_size_override("font_size", 20)
    info_panel.add_child(info_label)
    root.add_child(info_panel)
    info_panel.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT, Control.PRESET_MODE_MINSIZE, 12)

    prompt_btn = _btn("Talk", _on_prompt_pressed, 28)
    prompt_btn.custom_minimum_size = Vector2(420, 84)
    prompt_btn.visible = false
    root.add_child(prompt_btn)
    prompt_btn.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM, Control.PRESET_MODE_MINSIZE, 16)
    prompt_btn.grow_horizontal = Control.GROW_DIRECTION_BOTH
    prompt_btn.grow_vertical = Control.GROW_DIRECTION_BEGIN

    move_stick = VirtualStick.new()
    root.add_child(move_stick)
    move_stick.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_LEFT)
    move_stick.offset_left = 18
    move_stick.offset_top = -174
    move_stick.offset_right = 174
    move_stick.offset_bottom = -18
    run_btn = _btn("RUN", _toggle_run, 17)
    run_btn.custom_minimum_size = Vector2(112, 58)
    root.add_child(run_btn)
    run_btn.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_RIGHT, Control.PRESET_MODE_MINSIZE, 18)
    run_btn.grow_horizontal = Control.GROW_DIRECTION_BEGIN
    run_btn.grow_vertical = Control.GROW_DIRECTION_BEGIN

    spot_panel = _hud_panel(0.97)
    var box := VBoxContainer.new()
    box.add_theme_constant_override("separation", 12)
    spot_title = Label.new()
    spot_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    spot_title.add_theme_font_size_override("font_size", 36)
    spot_text = Label.new()
    spot_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    spot_text.custom_minimum_size = Vector2(560, 0)
    spot_text.add_theme_font_size_override("font_size", 22)
    spot_buttons = VBoxContainer.new()
    spot_buttons.add_theme_constant_override("separation", 10)
    box.add_child(spot_title)
    box.add_child(spot_text)
    box.add_child(spot_buttons)
    spot_panel.add_child(box)
    root.add_child(spot_panel)
    spot_panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER, Control.PRESET_MODE_MINSIZE)
    spot_panel.grow_horizontal = Control.GROW_DIRECTION_BOTH
    spot_panel.grow_vertical = Control.GROW_DIRECTION_BOTH
    spot_panel.visible = false

    party_screen = PartyScreen.new()
    root.add_child(party_screen)
    party_screen.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    party_screen.visible = false
    party_screen.closed.connect(_on_party_closed)


func _update_hud() -> void:
    var txt: String = "%s\nGold: %d" % [lmap.name, GameState.party.gold]
    if lmap.kind == "town":
        txt += "\nWalk south to leave"
    if txt != hud_text:
        hud_text = txt
        info_label.text = txt
