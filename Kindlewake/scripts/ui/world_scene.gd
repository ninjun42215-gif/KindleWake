extends Node2D

const CharacterSheetScript = preload("res://scripts/core/character_sheet.gd")
const PartyScreenScript = preload("res://scripts/ui/party_screen.gd")
const EmpireScreenScript = preload("res://scripts/ui/empire_screen.gd")
const PrologueSystem = preload("res://scripts/core/prologue_system.gd")
const HoldingSystem = preload("res://scripts/core/holding_system.gd")
const ExplorationControls = preload("res://scripts/ui/exploration_controls.gd")
const VirtualStick = preload("res://scripts/ui/virtual_stick.gd")
const PremiumUITheme = preload("res://scripts/ui/premium_ui_theme.gd")
## Overworld (Milestone 7, first step): walk freely over the Sallow Marches, find places, get ambushed.
## Touch: tap to walk to a spot, hold and drag to steer. Terrain changes speed; forests are more dangerous.
## All rules live in WorldMap; battles reuse the battle scene through GameState.start_battle_from_world().

const CREATOR_SCENE = preload("res://CharacterCreator.tscn")
const TILE := 48.0
const WALK_SPEED := 230.0
const PLAYER_RADIUS := 12.0
const INTERACT_RADIUS := 64.0
const AMBUSH_DELAY := 0.9
const MINIMAP_SCALE := 3
const TERRAIN_COLORS: Array[Color] = [
    Color("#41714f"), Color("#2f4a38"), Color("#6f8f5a"), Color("#5c7f94"),
    Color("#2d4a63"), Color("#6a7380"), Color("#8a6b4a"), Color("#b78b52"),
]

var active_world: Dictionary = {}
var wmap: WorldMap
var camera: Camera2D
var rng := RandomNumberGenerator.new()
var player_pos: Vector2 = Vector2.ZERO
var target: Vector2 = Vector2.ZERO
var has_target: bool = false
var pressing: bool = false
var facing_left: bool = false
var walk_phase: float = 0.0
var danger_accum: float = 0.0
var next_threshold: float = 1200.0
var ambush_timer: float = -1.0
var near_place: Dictionary = {}
var panel_open: bool = false
var hud_text: String = ""

var hud_root: Control
var info_label: Label
var leader_status_label: Label
var leader_exp_bar: ProgressBar
var company_btn: Button
var manual_save_btn: Button
var global_atlas_btn: Button
var empire_btn: Button
var empire_screen: EmpireScreenScript
var prompt_btn: Button
var place_panel: PanelContainer
var place_title: Label
var place_text: Label
var place_buttons: VBoxContainer
var banner: PanelContainer
var banner_label: Label
var party_screen: PartyScreenScript
var minimap_dot: ColorRect
var campaign_save_timer: float = 0.0
var creator_screen: Control
var move_stick: VirtualStick
var run_btn: Button
var run_toggled: bool = false
var moving_vector: Vector2 = Vector2.ZERO


func _ready() -> void:
    rng.randomize()
    ExplorationControls.configure()
    active_world = GameData.world_for_region(GameState.active_region_id)
    wmap = WorldMap.generate(active_world)
    camera = Camera2D.new()
    add_child(camera)
    camera.make_current()
    camera.zoom = Vector2(1.1, 1.1)
    if GameState.world_pos == Vector2.ZERO:
        player_pos = cell_center(wmap.start_cell)
    else:
        player_pos = GameState.world_pos
    camera.position = player_pos
    next_threshold = WorldMap.encounter_threshold(active_world, rng.randf())
    _build_ui()
    _build_minimap()
    _show_prologue_acknowledgement()
    _show_escape_acknowledgement()
    GameState.from_world = true
    GameState.save_campaign("auto_a")


func _show_prologue_acknowledgement() -> void:
    if not bool(GameState.world_flags.get("prologue_complete", false)):
        return
    if bool(GameState.world_flags.get("prologue_acknowledged", false)):
        return
    var line: String = PrologueSystem.acknowledgement(GameState.world_flags)
    if line == "":
        return
    banner_label.text = line
    banner.visible = true
    GameState.world_flags["prologue_acknowledged"] = true
    get_tree().create_timer(7.0).timeout.connect(func():
        if is_instance_valid(banner):
            banner.visible = false
    )


func _show_escape_acknowledgement() -> void:
    if not bool(GameState.world_flags.get("east_gallery_escaped", false)):
        return
    if bool(GameState.world_flags.get("escape_acknowledged", false)):
        return
    banner_label.text = "The postern is behind you. Dunmarrow is lost, but the company lives — and the truth has not yet been silenced."
    banner.visible = true
    GameState.world_flags["escape_acknowledged"] = true
    GameState.save_campaign("auto_a")
    get_tree().create_timer(8.0).timeout.connect(func():
        if is_instance_valid(banner):
            banner.visible = false
    )


func cell_center(c: Vector2i) -> Vector2:
    return (Vector2(c) + Vector2(0.5, 0.5)) * TILE


func cell_of(pos: Vector2) -> Vector2i:
    return Vector2i(floori(pos.x / TILE), floori(pos.y / TILE))


# ------------------------------------------------------------------ input and movement

func _unhandled_input(event: InputEvent) -> void:
    if panel_open or party_screen.visible or ambush_timer >= 0.0:
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
    var r: float = PLAYER_RADIUS * 0.7
    for off in [Vector2(-r, -r), Vector2(r, -r), Vector2(-r, r), Vector2(r, r)]:
        if not wmap.walkable(cell_of(p + off)):
            return false
    return true


func _process(delta: float) -> void:
    campaign_save_timer += delta
    if campaign_save_timer >= 25.0 and not panel_open and not party_screen.visible:
        campaign_save_timer = 0.0
        GameState.world_pos = wmap.wrap_position(player_pos)
        GameState.save_campaign("auto_a")
    if ambush_timer >= 0.0:
        ambush_timer -= delta
        if ambush_timer < 0.0:
            _launch_ambush()
        queue_redraw()
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
        if Input.is_action_just_pressed("interact") and not near_place.is_empty():
            _on_prompt_pressed()
    camera.position = camera.position.lerp(player_pos, clampf(delta * 8.0, 0.0, 1.0))
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
    var cell: Vector2i = cell_of(player_pos)
    var speed_multiplier: float = 1.6 if run_toggled or ExplorationControls.running() else 1.0
    var step: float = minf(dist, WALK_SPEED * speed_multiplier * wmap.speed_at(cell) * delta)
    var dir: Vector2 = to / dist
    var before: Vector2 = player_pos
    var nx: Vector2 = player_pos + Vector2(dir.x * step, 0.0)
    if _free_at(nx):
        player_pos = nx
    var ny: Vector2 = player_pos + Vector2(0.0, dir.y * step)
    if _free_at(ny):
        player_pos = ny
    var moved: float = player_pos.distance_to(before)
    if moved < 0.01:
        if not pressing:
            has_target = false
        return
    if absf(dir.x) > 0.2:
        facing_left = dir.x < 0.0
    walk_phase += moved * 0.12
    _accumulate_danger(moved, cell)



func _move_direction(delta: float, direction: Vector2) -> void:
    has_target = false
    var cell := wmap.wrap_cell(cell_of(player_pos))
    var multiplier: float = 1.6 if run_toggled or ExplorationControls.running() else 1.0
    var step: float = WALK_SPEED * multiplier * wmap.speed_at(cell) * delta
    var before := player_pos
    var nx := player_pos + Vector2(direction.x * step, 0.0)
    if _free_at(nx):
        player_pos = nx
    var ny := player_pos + Vector2(0.0, direction.y * step)
    if _free_at(ny):
        player_pos = ny
    var moved := player_pos.distance_to(before)
    if moved > 0.01:
        if absf(direction.x) > 0.12:
            facing_left = direction.x < 0.0
        walk_phase += moved * 0.12
        _accumulate_danger(moved, wmap.wrap_cell(cell_of(player_pos)))


func _toggle_run() -> void:
    run_toggled = not run_toggled
    if run_btn != null:
        run_btn.text = "RUN: ON" if run_toggled else "RUN"

func _in_safe_zone(cell: Vector2i) -> bool:
    cell = wmap.wrap_cell(cell)
    var radius: float = float(active_world.get("safe_radius", 5))
    for p in wmap.places:
        var d: Dictionary = p
        var kind: String = str(d.get("kind", ""))
        if kind == "keep" or kind == "village" or kind == "port":
            if Vector2(wmap.wrapped_delta(cell, wmap.place_cell(str(d.get("id", ""))))).length() < radius:
                return true
    return false


func _accumulate_danger(dist: float, cell: Vector2i) -> void:
    if _in_safe_zone(cell):
        return
    danger_accum += dist * wmap.danger_at(cell)
    if danger_accum >= next_threshold:
        danger_accum = 0.0
        next_threshold = WorldMap.encounter_threshold(active_world, rng.randf())
        has_target = false
        pressing = false
        ambush_timer = AMBUSH_DELAY
        banner_label.text = "Ambush! Roadwolves leap from the brush!"
        banner.visible = true


func _launch_ambush() -> void:
    var def: Dictionary = GameState.travel_encounter_def()
    if def.is_empty():
        banner.visible = false
        return
    _go_to_battle(def)


func _go_to_battle(def: Dictionary) -> void:
    GameState.world_pos = wmap.wrap_position(player_pos)
    GameState.save_campaign("auto_a")
    GameState.start_battle_from_world(def)
    get_tree().change_scene_to_file("res://Main.tscn")


# ------------------------------------------------------------------ places

func _place_world_position(place_cell: Vector2i) -> Vector2:
    return cell_center(cell_of(player_pos) + wmap.wrapped_delta(wmap.wrap_cell(cell_of(player_pos)), place_cell))


func _update_near() -> void:
    var best: Dictionary = {}
    var best_d: float = INTERACT_RADIUS
    for p in wmap.places:
        var d: Dictionary = p
        var place_cell: Vector2i = wmap.place_cell(str(d.get("id", "")))
        var dist: float = _place_world_position(place_cell).distance_to(player_pos)
        if dist < best_d:
            best_d = dist
            best = d
    near_place = best
    prompt_btn.visible = not best.is_empty() and not panel_open
    if not best.is_empty():
        var verb: String = "Speak with" if str(best.get("kind", "")) == "charter" else "Enter"
        prompt_btn.text = "A  %s %s" % [verb, str(best.get("name", "place"))]


func _on_prompt_pressed() -> void:
    if not near_place.is_empty():
        _open_place(near_place)


func _clear_children(node: Node) -> void:
    for c in node.get_children():
        node.remove_child(c)
        c.queue_free()


func _open_place(p: Dictionary, extra: String = "") -> void:
    panel_open = true
    has_target = false
    pressing = false
    prompt_btn.visible = false
    var id: String = str(p.get("id", ""))
    var kind: String = str(p.get("kind", ""))
    place_title.text = str(p.get("name", "Place"))
    var text: String = str(p.get("text", ""))
    _clear_children(place_buttons)
    var town: String = str(p.get("town", ""))
    if town != "" and GameData.locations.get("maps", {}).has(town):
        place_buttons.add_child(_btn("Enter %s" % str(p.get("name", "town")), _enter_town.bind(p), 24))
    if kind == "charter":
        if not bool(GameState.world_flags.get("east_gallery_escaped", false)):
            text += "\n\nThe envoy is waiting for proof that the Dunmarrow company survived the escape."
        elif not bool(GameState.world_flags.get("chapter_2_sea_passage", false)):
            place_buttons.add_child(_btn("Accept the Tidebound sea charter", _accept_sea_charter.bind(p), 24))
        else:
            text += "\n\nThe Tidebound charter is sealed. A ship is waiting at the harbour."
    elif kind == "gate":
        var gate_flag: String = str(p.get("world_flag", ""))
        if gate_flag != "" and not bool(GameState.world_flags.get(gate_flag, false)):
            place_buttons.add_child(_btn("Pass through the regional gate", _pass_gate.bind(p), 24))
        elif gate_flag != "":
            text += "\n\nYour company has passed through this gate."
    if kind == "ruin":
        if bool(GameState.world_flags.get("found_" + id, false)):
            text += "\n\nYou already searched here."
        else:
            place_buttons.add_child(_btn("Search the ruins", _on_search.bind(p), 24))
    elif kind == "dungeon":
        var clear_flag: String = str(p.get("world_flag_on_victory", "dungeon_" + id + "_cleared"))
        if bool(GameState.world_flags.get(clear_flag, false)):
            text += "\n\nThe dungeon's guardian has fallen. The route is quiet."
        else:
            text += "\n\nThe entrance leads into an explorable dungeon. Find its cache and face the guardian below."
    elif kind == "camp":
        if bool(GameState.world_flags.get("camp_cleared", false)):
            text += "\n\nThe palisade burns. The raiders are gone."
        else:
            place_buttons.add_child(_btn("Attack the camp", _on_attack_camp.bind(p), 24))
    elif kind == "stronghold":
        var holding: Dictionary = HoldingSystem.inspect(p, GameState.world_flags)
        if bool(holding.get("claimed", false)):
            text += "\n\nCONTROL: %s • STATUS: %s • STABILITY: %d/100" % [str(holding.get("owner", "unknown")), str(holding.get("status", "provisional")).to_upper(), int(GameState.world_flags.get("holding_stability_" + id, 35))]
        elif bool(holding.get("available", false)):
            var method: String = str(p.get("capture_method", "occupation"))
            var action: String = "Negotiate the stewardship compact" if method == "forest_stewardship_compact" else ("Sign the grain charter" if method == "grain_charter" else ("Restore the beacon and assume the watch" if method == "beacon_restoration" else "Secure the keep and establish a garrison"))
            place_buttons.add_child(_btn(action, _claim_holding.bind(p), 24))
        else:
            text += "\n\nSOVEREIGNTY UNRESOLVED: " + str(holding.get("reason", "The local objective remains unresolved."))
    if extra != "":
        text += "\n\n" + extra
    place_text.text = text
    place_buttons.add_child(_btn("Leave", _close_place, 24))
    place_panel.visible = true


func _close_place() -> void:
    panel_open = false
    place_panel.visible = false


func _accept_sea_charter(p: Dictionary) -> void:
    GameState.world_flags["chapter_2_sea_passage"] = true
    GameState.world_flags["tidebound_charter_accepted"] = true
    GameState.save_campaign("auto_a")
    _open_place(p, "Captain Ilyra Venn accepts the seal. The Tidebound Assembly will grant your company passage to Brinegate. The route is now charted.")


func _pass_gate(p: Dictionary) -> void:
    var flag: String = str(p.get("world_flag", ""))
    if flag == "":
        return
    GameState.world_flags[flag] = true
    var region: String = "Orrowen Weald" if str(p.get("id", "")) == "orrowen_gate" else "Vessmoor Plains"
    _open_place(p, "The company passes into %s. The road remains open behind you." % region)


func _claim_holding(p: Dictionary) -> void:
    var result: Dictionary = HoldingSystem.claim(p, GameState.world_flags)
    if not bool(result.get("ok", false)):
        _open_place(p, str(result.get("reason", "The holding cannot be secured.")))
        return
    GameState.save_campaign("auto_a")
    var method: String = str(p.get("capture_method", "occupation"))
    var consequence: String = "A provisional garrison is sworn in. The holding is yours to administer, but stability must be earned through food, safety, fair levies and respect for local custom."
    if method == "forest_stewardship_compact":
        consequence = "The wardens accept a stewardship compact. The watch remains under local law, and the old-growth grove is placed under protection."
    elif method == "grain_charter":
        consequence = "The freeholders sign a grain charter. Seed stores and winter reserves are protected before any military requisition."
    _open_place(p, consequence)


## Walk into a town: the location scene opens the town map; leaving it puts us back just south of the place.
func _enter_town(p: Dictionary) -> void:
    GameState.world_pos = wmap.wrap_position(player_pos)
    GameState.save_campaign("auto_a")
    GameState.pending_location = str(p.get("town", ""))
    GameState.world_pos = cell_center(wmap.place_cell(str(p.get("id", "")))) + Vector2(0, 58)
    get_tree().change_scene_to_file("res://Location.tscn")


func _on_search(p: Dictionary) -> void:
    var id: String = str(p.get("id", ""))
    var gold: int = int(p.get("reward_gold", 0))
    GameState.party.gold += gold
    GameState.world_flags["found_" + id] = true
    _open_place(p, "You find a purse: +%d gold." % gold)


func _on_attack_camp(p: Dictionary) -> void:
    var def: Dictionary = GameData.battle_def(str(p.get("battle", "battle_01")))
    if def.is_empty():
        return
    _go_to_battle(def)


func _open_party() -> void:
    party_screen.setup(GameState.party, GameData.party_db(), {}, false)
    # The minimap is created later in the world HUD; keep the modal above it.
    if party_screen.get_parent() != null:
        party_screen.get_parent().move_child(party_screen, party_screen.get_parent().get_child_count() - 1)
    party_screen.open()


func _on_party_closed() -> void:
    hud_text = ""


# ------------------------------------------------------------------ drawing

func _draw() -> void:
    if wmap == null:
        return
    var inv: Transform2D = get_canvas_transform().affine_inverse()
    var vp: Vector2 = get_viewport_rect().size
    var tl: Vector2 = inv * Vector2.ZERO
    var br: Vector2 = inv * vp
    var x0: int = floori(tl.x / TILE) - 1
    var y0: int = floori(tl.y / TILE) - 1
    var x1: int = floori(br.x / TILE) + 1
    var y1: int = floori(br.y / TILE) + 1
    for y in range(y0, y1 + 1):
        for x in range(x0, x1 + 1):
            _draw_tile(Vector2i(x, y))
    # props (trees, rocks, buildings) and the walker are drawn back to front so they overlap correctly
    var props: Array = _collect_props(x0, y0, x1, y1)
    for p in wmap.places:
        var base_cell: Vector2i = wmap.place_cell(str((p as Dictionary).get("id", "")))
        var pc: Vector2 = _place_world_position(base_cell)
        var display_place: Dictionary = (p as Dictionary).duplicate(true)
        display_place["_render_pos"] = pc
        props.append({"y": pc.y + 26.0, "kind": "place", "place": display_place})
    props.append({"y": player_pos.y + 6.0, "kind": "player"})
    props.sort_custom(func(a, b): return float(a["y"]) < float(b["y"]))
    for o in props:
        var d: Dictionary = o
        var k: String = str(d["kind"])
        if k == "tex":
            Art.draw_world(self, str(d["name"]), Vector2(float(d["x"]), float(d["y"])), float(d["scale"]))
        elif k == "place":
            _draw_place(d["place"])
        else:
            _draw_player()


const FOREST_SPRITES: Array[String] = ["pine_a", "pine_b", "pine_c", "tree_a", "tree_b", "tree_c"]
const MOUNTAIN_SPRITES: Array[String] = ["mountain_a", "mountain_b", "mountain_c"]


## Sprite props for the visible tiles: trees on forest, rock peaks on mountains, boulders on some hills.
func _collect_props(x0: int, y0: int, x1: int, y1: int) -> Array:
    var out: Array = []
    if Art.world("pine_a") == null:
        return out
    for y in range(y0, y1 + 1):
        for x in range(x0, x1 + 1):
            var c := Vector2i(x, y)
            var t: int = wmap.terrain_at(c)
            var canonical := wmap.wrap_cell(c)
            var h: float = WorldMap.hash01(canonical.x, canonical.y, 21)
            var h2: float = WorldMap.hash01(canonical.x, canonical.y, 22)
            var origin := Vector2(float(x), float(y)) * TILE
            if t == WorldMap.FOREST:
                var name: String = FOREST_SPRITES[int(h * 5.99)]
                out.append({"y": origin.y + TILE * (0.78 + 0.2 * h2), "kind": "tex", "name": name, "x": origin.x + TILE * (0.25 + 0.5 * h2), "scale": 0.52 + 0.14 * h})
            elif t == WorldMap.MOUNTAIN:
                out.append({"y": origin.y + TILE * 0.95, "kind": "tex", "name": MOUNTAIN_SPRITES[int(h * 2.99)], "x": origin.x + TILE * 0.5, "scale": 0.72 + 0.2 * h2})
            elif t == WorldMap.HILL and h > 0.55:
                out.append({"y": origin.y + TILE * (0.7 + 0.2 * h2), "kind": "tex", "name": "rock_a" if h2 < 0.5 else "rock_b", "x": origin.x + TILE * (0.3 + 0.4 * h2), "scale": 0.9})
            elif t == WorldMap.GRASS and h > 0.965:
                out.append({"y": origin.y + TILE * 0.8, "kind": "tex", "name": "tree_a" if h2 < 0.5 else "tree_b", "x": origin.x + TILE * 0.5, "scale": 0.6})
    return out


func _draw_tile(c: Vector2i) -> void:
    var art: bool = Art.world("pine_a") != null
    var t: int = wmap.terrain_at(c)
    var base: Color = TERRAIN_COLORS[t]
    if GameState.active_region_id == "brinegate_coast":
        match t:
            WorldMap.GRASS: base = Color("#779384")
            WorldMap.FOREST: base = Color("#426b68")
            WorldMap.HILL: base = Color("#8a9b80")
            WorldMap.FORD: base = Color("#5b91a0")
            WorldMap.WATER: base = Color("#285d70")
            WorldMap.MOUNTAIN: base = Color("#7d8587")
            WorldMap.ROAD: base = Color("#b59a70")
            WorldMap.BRIDGE: base = Color("#9c7654")
    var canonical := wmap.wrap_cell(c)
    var f: float = 0.93 + 0.14 * WorldMap.hash01(canonical.x, canonical.y, 3)
    var col := Color(base.r * f, base.g * f, base.b * f)
    var origin := Vector2(float(c.x), float(c.y)) * TILE
    draw_rect(Rect2(origin, Vector2(TILE + 0.5, TILE + 0.5)), col)
    var h: float = WorldMap.hash01(canonical.x, canonical.y, 11)
    if art and (t == WorldMap.FOREST or t == WorldMap.MOUNTAIN or t == WorldMap.HILL):
        pass                                  # the sprite props are drawn after the ground
    elif t == WorldMap.FOREST:
        for i in range(2):
            var o := Vector2(TILE * (0.28 + 0.44 * float(i)), TILE * (0.62 - 0.12 * h * float(i + 1)))
            draw_colored_polygon(PackedVector2Array([origin + o + Vector2(-9, 8), origin + o + Vector2(9, 8), origin + o + Vector2(0, -14)]), Color(0.14, 0.30, 0.20))
    elif t == WorldMap.HILL:
        draw_arc(origin + Vector2(TILE * 0.5, TILE * 0.75), 16.0, PI, TAU, 10, Color(0.45, 0.60, 0.36), 3.0)
    elif t == WorldMap.MOUNTAIN:
        draw_colored_polygon(PackedVector2Array([origin + Vector2(4, TILE - 4), origin + Vector2(TILE - 4, TILE - 4), origin + Vector2(TILE * 0.5, 6)]), Color(0.46, 0.50, 0.57))
        draw_colored_polygon(PackedVector2Array([origin + Vector2(TILE * 0.38, 18), origin + Vector2(TILE * 0.62, 18), origin + Vector2(TILE * 0.5, 6)]), Color(0.9, 0.92, 0.95))
    elif t == WorldMap.WATER or t == WorldMap.FORD:
        if GameState.active_region_id == "brinegate_coast":
            draw_line(origin + Vector2(7, 16 + h * 7), origin + Vector2(25, 16 + h * 7), Color(0.82, 0.94, 0.92, 0.25), 1.5)
            draw_line(origin + Vector2(21, 29 - h * 5), origin + Vector2(39, 29 - h * 5), Color(0.82, 0.94, 0.92, 0.16), 1.0)
        elif h > 0.55:
            draw_line(origin + Vector2(10, 20), origin + Vector2(26, 20), Color(1, 1, 1, 0.18), 2.0)
    elif t == WorldMap.BRIDGE:
        draw_rect(Rect2(origin + Vector2(0, 6), Vector2(TILE, TILE - 12)), Color(0.55, 0.40, 0.22))


## Overworld buildings from the voxel packs rendered to sprites (tools/render_sprites.py); primitives without them.
func _draw_place(p: Dictionary) -> void:
    if Art.world("keep") == null:
        _draw_place_fallback(p)
        return
    var id: String = str(p.get("id", ""))
    var kind: String = str(p.get("kind", ""))
    var c: Vector2 = p.get("_render_pos", cell_center(wmap.place_cell(id)))
    draw_circle(c + Vector2(0, 14), 26.0, Color(0, 0, 0, 0.22))
    var top: float = 60.0
    if kind == "keep" or kind == "stronghold":
        Art.draw_world(self, "keep", c + Vector2(0, 26), 0.85)
        top = 100.0
    elif kind == "port":
        draw_rect(Rect2(c + Vector2(-48, 18), Vector2(96, 12)), Color("#7d684e"))
        draw_line(c + Vector2(-42, 16), c + Vector2(-42, 44), Color("#b99a6b"), 4.0)
        draw_line(c + Vector2(30, 16), c + Vector2(30, 44), Color("#b99a6b"), 4.0)
        draw_colored_polygon(PackedVector2Array([c + Vector2(-25, 22), c + Vector2(25, 22), c + Vector2(16, 38), c + Vector2(-16, 38)]), Color("#463d35"))
        draw_line(c + Vector2(0, 20), c + Vector2(0, -32), Color("#d7c49a"), 3.0)
        draw_colored_polygon(PackedVector2Array([c + Vector2(2, -30), c + Vector2(24, -18), c + Vector2(2, -6)]), Color("#7aaeb0"))
        top = 82.0
    elif kind == "village":
        Art.draw_world(self, "house_a", c + Vector2(-28, 14), 0.85)
        Art.draw_world(self, "house_c", c + Vector2(26, 12), 0.85)
        Art.draw_world(self, "house_b", c + Vector2(0, 28), 0.85)
        top = 62.0
    elif kind == "ruin" or kind == "dungeon":
        Art.draw_world(self, "dead_b", c + Vector2(-30, 24), 0.8)
        Art.draw_world(self, "tower_a", c + Vector2(0, 26), 0.8, Color(0.82, 0.82, 0.82))
        Art.draw_world(self, "rock_a", c + Vector2(26, 28), 0.9)
        top = 82.0
    elif kind == "gate":
        Art.draw_world(self, "tower_a", c + Vector2(0, 24), 0.9, Color(0.75, 0.68, 0.48))
        top = 70.0
    elif kind == "charter":
        draw_line(c + Vector2(0, 18), c + Vector2(0, -42), Color("#d9c18a"), 4.0)
        draw_colored_polygon(PackedVector2Array([c + Vector2(2, -38), c + Vector2(34, -24), c + Vector2(2, -8)]), Color("#7aaeb0"))
        draw_colored_polygon(PackedVector2Array([c + Vector2(-2, -30), c + Vector2(-27, -18), c + Vector2(-2, -5)]), Color("#e4d5b0"))
        top = 76.0
    elif kind == "camp":
        var cleared: bool = bool(GameState.world_flags.get("camp_cleared", false))
        var tint: Color = Color(0.55, 0.55, 0.55) if cleared else Color(1.0, 0.82, 0.78)
        Art.draw_world(self, "hut", c + Vector2(-28, 16), 0.9, tint)
        Art.draw_world(self, "hut", c + Vector2(26, 14), 0.9, tint)
        Art.draw_world(self, "hut", c + Vector2(0, 30), 0.95, tint)
        top = 60.0
    var font: Font = ThemeDB.fallback_font
    var label: String = str(p.get("name", ""))
    draw_string(font, c + Vector2(-79, -top + 15), label, HORIZONTAL_ALIGNMENT_CENTER, 160, 18, Color(0, 0, 0, 0.85))
    draw_string(font, c + Vector2(-80, -top + 14), label, HORIZONTAL_ALIGNMENT_CENTER, 160, 18, Color(1.0, 0.95, 0.8))


func _draw_place_fallback(p: Dictionary) -> void:
    var id: String = str(p.get("id", ""))
    var kind: String = str(p.get("kind", ""))
    var c: Vector2 = p.get("_render_pos", cell_center(wmap.place_cell(id)))
    draw_circle(c + Vector2(0, 10), 22.0, Color(0, 0, 0, 0.25))
    if kind == "port":
        draw_rect(Rect2(c + Vector2(-48, 18), Vector2(96, 12)), Color("#7d684e"))
        draw_line(c + Vector2(-42, 16), c + Vector2(-42, 44), Color("#b99a6b"), 4.0)
        draw_line(c + Vector2(30, 16), c + Vector2(30, 44), Color("#b99a6b"), 4.0)
        draw_colored_polygon(PackedVector2Array([c + Vector2(-25, 22), c + Vector2(25, 22), c + Vector2(16, 38), c + Vector2(-16, 38)]), Color("#463d35"))
        draw_line(c + Vector2(0, 20), c + Vector2(0, -32), Color("#d7c49a"), 3.0)
        draw_colored_polygon(PackedVector2Array([c + Vector2(2, -30), c + Vector2(24, -18), c + Vector2(2, -6)]), Color("#7aaeb0"))
    elif kind == "keep" or kind == "stronghold":
        draw_rect(Rect2(c + Vector2(-20, -18), Vector2(40, 32)), Color(0.55, 0.55, 0.58))
        draw_rect(Rect2(c + Vector2(-24, -28), Vector2(12, 16)), Color(0.48, 0.48, 0.52))
        draw_rect(Rect2(c + Vector2(12, -28), Vector2(12, 16)), Color(0.48, 0.48, 0.52))
        draw_rect(Rect2(c + Vector2(-6, -2), Vector2(12, 16)), Color(0.15, 0.12, 0.10))
        draw_line(c + Vector2(0, -18), c + Vector2(0, -38), Color(0.8, 0.8, 0.8), 2.0)
        draw_rect(Rect2(c + Vector2(0, -38), Vector2(12, 8)), Color(0.75, 0.62, 0.20))
    elif kind == "charter":
        draw_line(c + Vector2(0, 18), c + Vector2(0, -42), Color("#d9c18a"), 4.0)
        draw_colored_polygon(PackedVector2Array([c + Vector2(2, -38), c + Vector2(34, -24), c + Vector2(2, -8)]), Color("#7aaeb0"))
        draw_colored_polygon(PackedVector2Array([c + Vector2(-2, -30), c + Vector2(-27, -18), c + Vector2(-2, -5)]), Color("#e4d5b0"))
    elif kind == "village":
        for i in range(3):
            var o := Vector2(-18.0 + 18.0 * float(i), 4.0 - 6.0 * float(i % 2))
            draw_rect(Rect2(c + o + Vector2(-7, -6), Vector2(14, 12)), Color(0.62, 0.48, 0.32))
            draw_colored_polygon(PackedVector2Array([c + o + Vector2(-9, -6), c + o + Vector2(9, -6), c + o + Vector2(0, -16)]), Color(0.65, 0.25, 0.2))
    elif kind == "ruin" or kind == "dungeon":
        for i in range(3):
            var hgt: float = 14.0 + 8.0 * float(i % 2)
            draw_rect(Rect2(c + Vector2(-16.0 + 14.0 * float(i), -hgt), Vector2(8, hgt + 6)), Color(0.62, 0.62, 0.60))
    elif kind == "gate":
        draw_rect(Rect2(c + Vector2(-23, -25), Vector2(9, 38)), Color(0.56, 0.55, 0.48))
        draw_rect(Rect2(c + Vector2(14, -25), Vector2(9, 38)), Color(0.56, 0.55, 0.48))
        draw_rect(Rect2(c + Vector2(-23, -31), Vector2(46, 10)), Color(0.64, 0.58, 0.40))
        draw_rect(Rect2(c + Vector2(-6, -13), Vector2(12, 26)), Color(0.14, 0.16, 0.14))
    elif kind == "camp":
        var cleared: bool = bool(GameState.world_flags.get("camp_cleared", false))
        var tent: Color = Color(0.5, 0.5, 0.5) if cleared else Color(0.70, 0.22, 0.18)
        draw_colored_polygon(PackedVector2Array([c + Vector2(-16, 12), c + Vector2(16, 12), c + Vector2(0, -16)]), tent)
        for i in range(5):
            draw_line(c + Vector2(-26.0 + 13.0 * float(i), 16), c + Vector2(-26.0 + 13.0 * float(i), 2), Color(0.45, 0.32, 0.2), 4.0)
    var font: Font = ThemeDB.fallback_font
    var label: String = str(p.get("name", ""))
    draw_string(font, c + Vector2(-79, -45), label, HORIZONTAL_ALIGNMENT_CENTER, 160, 18, Color(0, 0, 0, 0.8))
    draw_string(font, c + Vector2(-80, -46), label, HORIZONTAL_ALIGNMENT_CENTER, 160, 18, Color(1.0, 0.95, 0.8))


func _draw_player() -> void:
    var p: Vector2 = player_pos
    if Art.unit_sheet("soldier", "idle") != null:
        draw_colored_polygon(_ellipse(p + Vector2(0, 6), 14.0, 5.0), Color(0, 0, 0, 0.35))
        var t: float = float(Time.get_ticks_msec()) / 1000.0
        var moving: bool = (has_target or moving_vector.length() > 0.12) and not panel_open
        var sprinting: bool = moving and (run_toggled or ExplorationControls.running())
        var motion_state: String = "run" if sprinting and Art.unit_sheet("soldier", "run") != null else ("walk" if moving else "idle")
        Art.draw_unit(self, "soldier", motion_state, t, p + Vector2(0, 8), 2.0, facing_left)
        if has_target and not panel_open:
            draw_arc(target, 8.0, 0.0, TAU, 16, Color(1, 1, 1, 0.5), 2.0)
        return
    var bob: float = absf(sin(walk_phase)) * 3.0 if has_target else 0.0
    draw_colored_polygon(_ellipse(p + Vector2(0, 6), 13.0, 5.0), Color(0, 0, 0, 0.35))
    var q: Vector2 = p + Vector2(0, -bob)
    draw_rect(Rect2(q + Vector2(-8, -18), Vector2(16, 22)), Color(0.22, 0.50, 0.88))
    draw_rect(Rect2(q + Vector2(-6, -28), Vector2(12, 11)), Color(0.72, 0.73, 0.70))
    draw_rect(Rect2(q + Vector2(-4, -25), Vector2(8, 3)), Color(0.16, 0.18, 0.20))
    var s: float = -1.0 if facing_left else 1.0
    draw_line(q + Vector2(9.0 * s, -8), q + Vector2(17.0 * s, -28), Color(0.85, 0.82, 0.66), 3.0)
    if has_target and not panel_open:
        draw_arc(target, 8.0, 0.0, TAU, 16, Color(1, 1, 1, 0.5), 2.0)


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
    var vw: float = get_viewport().get_visible_rect().size.x
    var compact: bool = vw < 900.0
    if info_label != null:
        info_label.custom_minimum_size = Vector2(clampf(vw * 0.25, 175.0, 300.0), 0.0)
        info_label.add_theme_font_size_override("font_size", 15 if compact else 19)
    if leader_status_label != null:
        leader_status_label.add_theme_font_size_override("font_size", 12 if compact else 14)
    if company_btn != null:
        company_btn.custom_minimum_size = Vector2(clampf(vw * 0.16, 130.0, 190.0), 56.0 if compact else 64.0)
        company_btn.add_theme_font_size_override("font_size", 16 if compact else 20)
    if manual_save_btn != null:
        manual_save_btn.custom_minimum_size = Vector2(clampf(vw * 0.16, 130.0, 190.0), 48.0 if compact else 52.0)
        manual_save_btn.add_theme_font_size_override("font_size", 15 if compact else 18)
    if global_atlas_btn != null:
        global_atlas_btn.custom_minimum_size = Vector2(clampf(vw * 0.16, 130.0, 190.0), 48.0)
        global_atlas_btn.add_theme_font_size_override("font_size", 14 if compact else 17)
    if empire_btn != null:
        empire_btn.custom_minimum_size = Vector2(clampf(vw * 0.16, 130.0, 190.0), 48.0)
        empire_btn.add_theme_font_size_override("font_size", 14 if compact else 17)
    if prompt_btn != null:
        prompt_btn.custom_minimum_size = Vector2(clampf(vw * 0.42, 230.0, 380.0), 64.0 if compact else 68.0)
        prompt_btn.add_theme_font_size_override("font_size", 20 if compact else 28)
    if place_panel != null:
        place_panel.custom_minimum_size = Vector2(maxf(260.0, minf(vw - 24.0, 720.0)), 0.0)
    if place_title != null:
        place_title.add_theme_font_size_override("font_size", 26 if compact else 38)
    if place_text != null:
        place_text.custom_minimum_size = Vector2(maxf(220.0, minf(vw - 72.0, 560.0)), 0.0)
        place_text.add_theme_font_size_override("font_size", 17 if compact else 22)
    if banner_label != null:
        banner_label.add_theme_font_size_override("font_size", 20 if compact else 30)


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

    # Top-left: region, terrain, gold
    var info_panel := _hud_panel()
    info_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
    info_label = Label.new()
    info_label.custom_minimum_size = Vector2(300, 0)
    info_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    info_label.add_theme_font_size_override("font_size", 19)
    var info_box := VBoxContainer.new()
    info_box.add_theme_constant_override("separation", 5)
    info_box.add_child(info_label)
    leader_status_label = Label.new()
    leader_status_label.add_theme_font_size_override("font_size", 14)
    leader_status_label.add_theme_color_override("font_color", Color("#e5c98d"))
    info_box.add_child(leader_status_label)
    leader_exp_bar = ProgressBar.new()
    leader_exp_bar.custom_minimum_size = Vector2(0, 9)
    leader_exp_bar.show_percentage = false
    info_box.add_child(leader_exp_bar)
    info_panel.add_child(info_box)
    root.add_child(info_panel)
    info_panel.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT, Control.PRESET_MODE_MINSIZE, 12)

    # Top-right: company management is always one tap away on the road.
    company_btn = _btn("COMPANY", _open_party, 20)
    company_btn.custom_minimum_size = Vector2(190, 64)
    root.add_child(company_btn)
    company_btn.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT, Control.PRESET_MODE_MINSIZE, 12)
    company_btn.grow_horizontal = Control.GROW_DIRECTION_BEGIN
    manual_save_btn = _btn("SAVE", _save_campaign_manual, 18)
    manual_save_btn.custom_minimum_size = Vector2(190, 52)
    root.add_child(manual_save_btn)
    manual_save_btn.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT, Control.PRESET_MODE_MINSIZE, 84)
    manual_save_btn.grow_horizontal = Control.GROW_DIRECTION_BEGIN
    global_atlas_btn = _btn("WORLD ATLAS", _open_world_atlas, 17)
    global_atlas_btn.custom_minimum_size = Vector2(190, 48)
    root.add_child(global_atlas_btn)
    global_atlas_btn.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT, Control.PRESET_MODE_MINSIZE, 144)
    global_atlas_btn.grow_horizontal = Control.GROW_DIRECTION_BEGIN
    empire_btn = _btn("HOLDINGS", _open_empire, 17)
    empire_btn.custom_minimum_size = Vector2(190, 48)
    root.add_child(empire_btn)
    empire_btn.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT, Control.PRESET_MODE_MINSIZE, 204)
    empire_btn.grow_horizontal = Control.GROW_DIRECTION_BEGIN

    # Top-centre: ambush banner
    banner = _hud_panel(0.95)
    banner.mouse_filter = Control.MOUSE_FILTER_IGNORE
    banner_label = Label.new()
    banner_label.add_theme_font_size_override("font_size", 30)
    banner.add_child(banner_label)
    banner.visible = false
    root.add_child(banner)
    banner.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP, Control.PRESET_MODE_MINSIZE, 90)
    banner.grow_horizontal = Control.GROW_DIRECTION_BOTH

    # Bottom-centre: enter-place prompt
    prompt_btn = _btn("Enter", _on_prompt_pressed, 28)
    prompt_btn.custom_minimum_size = Vector2(380, 84)
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

    # Centre: place panel
    place_panel = _hud_panel(0.97)
    var box := VBoxContainer.new()
    box.add_theme_constant_override("separation", 12)
    place_title = Label.new()
    place_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    place_title.add_theme_font_size_override("font_size", 38)
    place_text = Label.new()
    place_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    place_text.custom_minimum_size = Vector2(560, 0)
    place_text.add_theme_font_size_override("font_size", 22)
    place_buttons = VBoxContainer.new()
    place_buttons.add_theme_constant_override("separation", 10)
    box.add_child(place_title)
    box.add_child(place_text)
    box.add_child(place_buttons)
    place_panel.add_child(box)
    root.add_child(place_panel)
    place_panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER, Control.PRESET_MODE_MINSIZE)
    place_panel.grow_horizontal = Control.GROW_DIRECTION_BOTH
    place_panel.grow_vertical = Control.GROW_DIRECTION_BOTH
    place_panel.visible = false

    party_screen = PartyScreenScript.new()
    root.add_child(party_screen)
    party_screen.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    party_screen.visible = false
    party_screen.closed.connect(_on_party_closed)

    empire_screen = EmpireScreenScript.new()
    root.add_child(empire_screen)
    empire_screen.setup(GameData.world_expansion.get("capturable_locations", []))
    empire_screen.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    empire_screen.visible = false
    empire_screen.closed.connect(_on_empire_closed)



func _open_empire() -> void:
    if panel_open or party_screen.visible or ambush_timer >= 0.0:
        return
    has_target = false
    pressing = false
    GameState.world_pos = wmap.wrap_position(player_pos)
    GameState.save_campaign("auto_a")
    panel_open = true
    empire_screen.open()


func _on_empire_closed() -> void:
    panel_open = false
    _update_hud()


func _open_world_atlas() -> void:
    if panel_open or party_screen.visible or ambush_timer >= 0.0:
        return
    has_target = false
    pressing = false
    GameState.world_pos = wmap.wrap_position(player_pos)
    GameState.save_campaign("auto_a")
    get_tree().change_scene_to_file("res://GlobalAtlas.tscn")


func _save_campaign_manual() -> void:
    GameState.world_pos = wmap.wrap_position(player_pos)
    if GameState.save_campaign("1"):
        GameState.campaign_slot = "1"
        banner_label.text = "Chronicle saved."
        banner.visible = true
        get_tree().create_timer(2.0).timeout.connect(func(): banner.visible = false)
    else:
        banner_label.text = "Could not save chronicle."
        banner.visible = true

func _on_new_chronicle_pressed() -> void:
    if creator_screen != null:
        return
    var creator: CharacterCreator = CREATOR_SCENE.instantiate() as CharacterCreator
    creator_screen = creator
    creator.confirmed.connect(_on_creator_confirmed)
    creator.cancelled.connect(_on_creator_cancelled)
    hud_root.add_child(creator)
    creator.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    panel_open = true
    has_target = false


func _on_creator_confirmed(profile: Dictionary) -> void:
    GameState.new_game(profile)
    GameState.from_world = true
    GameState.world_pos = Vector2.ZERO
    player_pos = cell_center(wmap.start_cell)
    target = player_pos
    has_target = false
    danger_accum = 0.0
    panel_open = false
    if creator_screen != null:
        creator_screen.queue_free()
        creator_screen = null
    hud_text = ""
    _update_hud()
    camera.position = player_pos


func _on_creator_cancelled() -> void:
    if creator_screen != null:
        creator_screen.queue_free()
        creator_screen = null
    panel_open = false


func _build_minimap() -> void:
    var img: Image = Image.create(wmap.width, wmap.height, false, Image.FORMAT_RGBA8)
    for y in range(wmap.height):
        for x in range(wmap.width):
            img.set_pixel(x, y, TERRAIN_COLORS[wmap.terrain_at(Vector2i(x, y))])
    for p in wmap.places:
        var c: Vector2i = wmap.place_cell(str((p as Dictionary).get("id", "")))
        img.set_pixel(c.x, c.y, Color(1.0, 0.85, 0.2))
    var rect := TextureRect.new()
    rect.texture = ImageTexture.create_from_image(img)
    rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
    rect.stretch_mode = TextureRect.STRETCH_SCALE
    rect.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
    rect.custom_minimum_size = Vector2(float(wmap.width * MINIMAP_SCALE), float(wmap.height * MINIMAP_SCALE))
    rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
    minimap_dot = ColorRect.new()
    minimap_dot.color = Color.WHITE
    minimap_dot.size = Vector2(6, 6)
    minimap_dot.mouse_filter = Control.MOUSE_FILTER_IGNORE
    rect.add_child(minimap_dot)
    var panel := _hud_panel(0.8)
    panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
    panel.add_child(rect)
    hud_root.add_child(panel)
    panel.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_LEFT, Control.PRESET_MODE_MINSIZE, 12)
    panel.grow_vertical = Control.GROW_DIRECTION_BEGIN


func _region_name_at(cell: Vector2i) -> String:
    cell = wmap.wrap_cell(cell)
    if GameState.active_region_id == "brinegate_coast":
        if cell.x >= 42 and cell.y <= 27:
            return "Lantern Reach"
        if cell.x >= 24 and cell.y >= 24:
            return "Saltmere Strand"
        return "Brinegate Coast"
    if cell.x >= 42 and cell.y <= 27:
        return "Orrowen Weald"
    if cell.x >= 35 and cell.y >= 30:
        return "Vessmoor Plains"
    return "Sethmarch"


func _update_hud() -> void:
    var cell: Vector2i = cell_of(player_pos)
    var txt: String = "%s  •  %s%s\nGOLD  %d" % [_region_name_at(cell), wmap.terrain_name(cell), "  •  SAFE" if _in_safe_zone(cell) else "", GameState.party.gold]
    if txt != hud_text:
        hud_text = txt
        info_label.text = txt
    if not GameState.party.roster.is_empty():
        var leader_id: String = GameState.party.roster[0]
        var leader: CharacterSheetScript = GameState.party.sheet(leader_id)
        if leader != null:
            var class_def: Dictionary = GameData.class_def(leader.class_id)
            var class_title: String = str(class_def.get("name", leader.class_id))
            if leader.level >= CharacterSheetScript.MAX_LEVEL:
                leader_status_label.text = "%s  •  Lv %d %s  •  MAX" % [leader.display_name, leader.level, class_title]
                leader_exp_bar.max_value = 1.0
                leader_exp_bar.value = 1.0
            else:
                leader_status_label.text = "%s  •  Lv %d %s  •  EXP %d/%d" % [leader.display_name, leader.level, class_title, leader.xp, leader.exp_to_next()]
                leader_exp_bar.max_value = float(maxi(1, leader.exp_to_next()))
                leader_exp_bar.value = float(leader.xp)
    if minimap_dot != null:
        minimap_dot.position = Vector2(wmap.wrap_cell(cell_of(player_pos))) * float(MINIMAP_SCALE) + Vector2(MINIMAP_SCALE * 0.5 - 3.0, MINIMAP_SCALE * 0.5 - 3.0)
