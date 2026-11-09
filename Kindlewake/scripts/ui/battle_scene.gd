extends Node2D

const CharacterSheetScript = preload("res://scripts/core/character_sheet.gd")
## Milestone 1 battle scene: isometric placeholder rendering, touch/mouse input and a HUD built in code.
## All rules live in BattleController; this script only presents state and forwards player input.

const TILE_W := 64.0
const TILE_H := 32.0
const HEIGHT_STEP := 16.0
const MOVE_SPEED := 420.0
const BATTLE_ID := "battle_01"
const AI_DELAY := 0.6
const ZOOM_MIN := 0.7
const ZOOM_MAX := 2.6
const NO_CELL := Vector2i(-1, -1)
const SETTINGS_PATH := "user://settings.cfg"
const HAND_DRAWN_CLASSES: Array = ["swordsman", "knight", "archer", "cleric", "roadreaver"]   # everything else gets a branch glyph

enum Mode { IDLE, MOVE, ATTACK, SKILL }

var controller: BattleController = BattleController.new()
var camera: Camera2D
var map_center: Vector2 = Vector2.ZERO
var mode: Mode = Mode.IDLE
var move_cells: Dictionary = {}          # Vector2i -> true
var target_cells: Dictionary = {}        # Vector2i -> unit id
var pending_cell: Vector2i = NO_CELL
var pending_cost: int = 0
var pending_path: Array[Vector2i] = []
var pending_target_id: int = -1
var active_skill: String = ""
var inspected_id: int = -1
var visual_pos: Dictionary = {}          # unit id -> Vector2 (smoothed world position)
var anim_clock: float = 0.0              # seconds, drives the unit sprite animations
var anim_last_draw: float = 0.0
var anim_override: Dictionary = {}       # unit id -> {"anim": String, "start": float} (attack / hurt one-shots)
var popups: Array[Dictionary] = []
var log_lines: Array[String] = []
var last_turn_count: int = -1
var ai_busy: bool = false
var input_locked: bool = false
var suppress_autosave: bool = false
var auto_battle: bool = false            # when true the AI also plays the player's units
var resync_view: bool = false            # Auto was switched off while the AI loop was running
var exp_awarded: bool = false            # EXP is paid out once per battle
var battle_rewards: Dictionary = {}       # result of PartyState.apply_battle_result (EXP, AP, gold, sigil reports)
var battle_def: Dictionary = {}           # story battle or a generated Skirmish

# Gesture state (tap, drag-to-pan, pinch-to-zoom)
var touches: Dictionary = {}
var pinch_start_dist: float = 0.0
var pinch_start_zoom: float = 1.0
var press_active: bool = false
var press_pos: Vector2 = Vector2.ZERO
var dragging: bool = false
var gesture_used: bool = false

# UI references
var info_label: Label
var log_label: Label
var timeline_box: HBoxContainer
var btn_move: Button
var btn_attack: Button
var btn_skill: Button
var btn_wait: Button
var btn_confirm: Button
var btn_cancel: Button
var btn_auto: Button
var result_panel: PanelContainer
var result_title: Label
var result_text: Label
var result_scroll: ScrollContainer
var prep_scroll: ScrollContainer
var prep_panel: PanelContainer          # shown before every battle: briefing, Party / Gear / Shop, Begin
var prep_title: Label
var prep_text: Label
var prep_active: bool = false
var party_screen: PartyScreen
var btn_flee: Button                     # pre-battle: leave without fighting (only when we came from the world)
var hud_root: Control                    # everything in the HUD lives here (inset by the phone safe area)
var preview_panel: PanelContainer        # attack / skill / move preview above Confirm and Cancel
var preview_label: Label
var menu_panel: PanelContainer           # Save / Load popup


func _ready() -> void:
    camera = Camera2D.new()
    add_child(camera)
    camera.make_current()
    _load_settings()
    _build_ui()
    controller.log_message.connect(_on_log)
    controller.state_changed.connect(_on_state_changed)
    controller.unit_acted.connect(_on_unit_acted)
    controller.battle_ended.connect(_on_battle_ended)
    SaveSystem.app_paused.connect(_autosave)
    _start_battle()


func _start_battle() -> void:
    popups.clear()
    log_lines.clear()
    visual_pos.clear()
    mode = Mode.IDLE
    last_turn_count = -1
    ai_busy = false
    resync_view = false
    exp_awarded = false
    battle_rewards = {}
    input_locked = false
    result_panel.visible = false
    if battle_def.is_empty():
        battle_def = GameState.take_pending_battle()
    if battle_def.is_empty():
        battle_def = GameData.battle_def(BATTLE_ID)
    controller.setup(battle_def, GameState.battle_db())
    _center_camera()
    for o in controller.units:
        var u: BattleUnit = o
        visual_pos[u.id] = cell_to_world(u.cell)
    _show_prep()


## Before the first turn: briefing plus "Party, Gear and Shop". Units are built from the party's current
## sheets, so closing the party screen rebuilds the battle with the new gear.
func _show_prep() -> void:
    prep_active = true
    input_locked = true
    result_panel.visible = false
    prep_title.text = str(battle_def.get("title", "Battle"))
    var lines: Array[String] = [str(battle_def.get("briefing", "")), "", "Gold: %d" % GameState.party.gold]
    prep_text.text = "\n".join(PackedStringArray(lines))
    btn_flee.visible = GameState.from_world
    prep_panel.visible = true
    _refresh_ui()
    queue_redraw()


func _on_begin_pressed() -> void:
    prep_active = false
    input_locked = false
    prep_panel.visible = false
    controller.begin()


func _on_party_pressed() -> void:
    party_screen.setup(GameState.party, GameData.party_db(), GameData.shop)
    party_screen.open()


func _on_party_closed() -> void:
    if prep_active:
        _start_battle()
    else:
        result_panel.visible = controller.result != ""


func _center_camera() -> void:
    var m: BattleMap = controller.map
    map_center = Vector2(float(m.width - m.height) * 0.25 * TILE_W, float(m.width + m.height) * 0.25 * TILE_H)
    camera.position = map_center
    _set_zoom(1.3)


# ------------------------------------------------------------------ coordinates

func cell_to_world(cell: Vector2i) -> Vector2:
    var h := 0
    if controller.map != null:
        h = controller.map.height_at(cell)
    return Vector2(float(cell.x - cell.y) * TILE_W * 0.5, float(cell.x + cell.y) * TILE_H * 0.5 - float(h) * HEIGHT_STEP)


func _to_world(screen_pos: Vector2) -> Vector2:
    return get_canvas_transform().affine_inverse() * screen_pos


## Units are picked first (their bodies extend above their tile), then tiles front-to-back.
func _pick_cell(world_pos: Vector2) -> Vector2i:
    var best_unit: BattleUnit = null
    var best_y := -1.0e9
    for o in controller.units:
        var u: BattleUnit = o
        if not u.is_alive():
            continue
        var p: Vector2 = visual_pos.get(u.id, cell_to_world(u.cell))
        if Rect2(p + Vector2(-20, -50), Vector2(40, 58)).has_point(world_pos) and p.y > best_y:
            best_y = p.y
            best_unit = u
    if best_unit != null:
        return best_unit.cell
    var m: BattleMap = controller.map
    var best: Vector2i = NO_CELL
    var best_order := -1
    for y in range(m.height):
        for x in range(m.width):
            var c := Vector2i(x, y)
            var center: Vector2 = cell_to_world(c)
            var dx: float = absf(world_pos.x - center.x) / (TILE_W * 0.5)
            var dy: float = absf(world_pos.y - center.y) / (TILE_H * 0.5)
            if dx + dy <= 1.0 and x + y > best_order:
                best_order = x + y
                best = c
    return best


func _set_zoom(value: float) -> void:
    var z: float = clampf(value, ZOOM_MIN, ZOOM_MAX)
    camera.zoom = Vector2(z, z)
    queue_redraw()


func _clamp_camera() -> void:
    camera.position = camera.position.clamp(map_center - Vector2(560, 330), map_center + Vector2(560, 330))


# ------------------------------------------------------------------ input

func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventScreenTouch:
        var st := event as InputEventScreenTouch
        if st.pressed:
            touches[st.index] = st.position
            if touches.size() >= 2:
                gesture_used = true
                _begin_pinch()
        else:
            touches.erase(st.index)
    elif event is InputEventScreenDrag:
        var sd := event as InputEventScreenDrag
        touches[sd.index] = sd.position
        if touches.size() >= 2:
            _update_pinch()
    elif event is InputEventMouseButton:
        var mb := event as InputEventMouseButton
        if mb.button_index == MOUSE_BUTTON_LEFT:
            if mb.pressed:
                press_active = true
                press_pos = mb.position
                dragging = false
                gesture_used = touches.size() >= 2
            else:
                if press_active and not dragging and not gesture_used:
                    _on_tap(_to_world(mb.position))
                press_active = false
        elif mb.pressed and mb.button_index == MOUSE_BUTTON_WHEEL_UP:
            _set_zoom(camera.zoom.x * 1.1)
        elif mb.pressed and mb.button_index == MOUSE_BUTTON_WHEEL_DOWN:
            _set_zoom(camera.zoom.x / 1.1)
    elif event is InputEventMouseMotion:
        var mm := event as InputEventMouseMotion
        if press_active and not gesture_used:
            if not dragging and mm.position.distance_to(press_pos) > 14.0:
                dragging = true
            if dragging:
                camera.position -= mm.relative / camera.zoom.x
                _clamp_camera()
                queue_redraw()


func _begin_pinch() -> void:
    var keys: Array = touches.keys()
    var a: Vector2 = touches[keys[0]]
    var b: Vector2 = touches[keys[1]]
    pinch_start_dist = a.distance_to(b)
    pinch_start_zoom = camera.zoom.x


func _update_pinch() -> void:
    var keys: Array = touches.keys()
    var a: Vector2 = touches[keys[0]]
    var b: Vector2 = touches[keys[1]]
    if pinch_start_dist > 1.0:
        _set_zoom(pinch_start_zoom * a.distance_to(b) / pinch_start_dist)


func _on_tap(world_pos: Vector2) -> void:
    if controller.result != "" or input_locked:
        return
    var cell: Vector2i = _pick_cell(world_pos)
    if cell == NO_CELL:
        return
    var clicked: BattleUnit = controller.unit_at(cell)
    var a: BattleUnit = controller.active_unit()
    var my_turn: bool = a != null and a.team == "player" and not ai_busy
    if clicked != null:
        inspected_id = clicked.id
    if my_turn:
        match mode:
            Mode.MOVE:
                if move_cells.has(cell):
                    if pending_cell == cell:
                        _confirm()
                        return
                    _select_move_cell(a, cell)
            Mode.ATTACK, Mode.SKILL:
                if clicked != null and target_cells.has(cell):
                    if pending_target_id == clicked.id:
                        _confirm()
                        return
                    pending_target_id = clicked.id
    _refresh_ui()
    queue_redraw()


func _select_move_cell(unit: BattleUnit, cell: Vector2i) -> void:
    var reach: Dictionary = controller.reach_for(unit)
    pending_cell = cell
    pending_path = controller.map.path_from(reach, unit.cell, cell)
    var cost: Dictionary = reach["cost"]
    pending_cost = int(cost.get(cell, 0))


# ------------------------------------------------------------------ modes and actions

func _enter_mode(new_mode: Mode) -> void:
    mode = new_mode
    pending_cell = NO_CELL
    pending_path.clear()
    pending_target_id = -1
    _recompute_highlights()
    _refresh_ui()
    queue_redraw()


func _recompute_highlights() -> void:
    move_cells.clear()
    target_cells.clear()
    var a: BattleUnit = controller.active_unit()
    if a == null or a.team != "player" or controller.result != "":
        return
    match mode:
        Mode.MOVE:
            for c in controller.move_targets(a):
                move_cells[c] = true
        Mode.ATTACK:
            for t in controller.attack_targets(a, a.cell):
                target_cells[t.cell] = t.id
        Mode.SKILL:
            for t in controller.skill_targets(a, active_skill):
                target_cells[t.cell] = t.id


func _confirm() -> void:
    var a: BattleUnit = controller.active_unit()
    if input_locked or a == null or a.team != "player" or controller.result != "":
        return
    if mode == Mode.MOVE and pending_cell != NO_CELL:
        var dest: Vector2i = pending_cell
        if controller.try_move(a, dest):
            var next_mode: Mode = Mode.IDLE
            if not controller.attack_targets(a, a.cell).is_empty():
                next_mode = Mode.ATTACK
            _enter_mode(next_mode)
    elif (mode == Mode.ATTACK or mode == Mode.SKILL) and pending_target_id != -1:
        var t: BattleUnit = controller.unit_by_id(pending_target_id)
        var ok := false
        if mode == Mode.ATTACK:
            ok = controller.try_attack(a, t)
        else:
            ok = controller.try_skill(a, active_skill, t)
        if ok:
            _enter_mode(Mode.IDLE)
            input_locked = true
            _refresh_ui()
            await get_tree().create_timer(0.55).timeout
            input_locked = false
            if controller.result == "" and controller.active_id == a.id:
                controller.end_active_turn()
            else:
                _refresh_ui()


func _on_move_pressed() -> void:
    _enter_mode(Mode.IDLE if mode == Mode.MOVE else Mode.MOVE)


func _on_attack_pressed() -> void:
    _enter_mode(Mode.IDLE if mode == Mode.ATTACK else Mode.ATTACK)


func _on_skill_pressed() -> void:
    var a: BattleUnit = controller.active_unit()
    if a == null or a.skills.is_empty():
        return
    # Tapping Skill again while it is open cycles to the next skill; after the last one it closes.
    if mode == Mode.SKILL:
        var idx: int = a.skills.find(active_skill) + 1
        if idx >= a.skills.size():
            _enter_mode(Mode.IDLE)
            return
        active_skill = a.skills[idx]
        _enter_mode(Mode.SKILL)
        return
    active_skill = _first_usable_skill(a)
    _enter_mode(Mode.SKILL)


## The first skill that has a target in range right now, otherwise the first skill.
func _first_usable_skill(a: BattleUnit) -> String:
    for sid in a.skills:
        if not controller.skill_targets(a, str(sid)).is_empty():
            return str(sid)
    return a.skills[0]


func _on_wait_pressed() -> void:
    if input_locked or ai_busy:
        return
    controller.end_active_turn()


func _on_confirm_pressed() -> void:
    _confirm()


func _on_cancel_pressed() -> void:
    _enter_mode(Mode.IDLE)


func _on_zoom_in() -> void:
    _set_zoom(camera.zoom.x * 1.15)


func _on_zoom_out() -> void:
    _set_zoom(camera.zoom.x / 1.15)


func _on_world_pressed() -> void:
    get_tree().change_scene_to_file("res://World.tscn")


func _on_restart_pressed() -> void:
    _start_battle()


# ------------------------------------------------------------------ controller signals

func _on_log(text: String) -> void:
    log_lines.append(text)
    while log_lines.size() > 4:
        log_lines.remove_at(0)
    if log_label != null:
        log_label.text = "\n".join(PackedStringArray(log_lines))


func _on_state_changed() -> void:
    for o in controller.units:
        var u: BattleUnit = o
        if not visual_pos.has(u.id):
            visual_pos[u.id] = cell_to_world(u.cell)
    if controller.turn_count != last_turn_count:
        last_turn_count = controller.turn_count
        _begin_turn_view()
    else:
        _recompute_highlights()
    _refresh_ui()
    queue_redraw()
    _maybe_run_ai()


func _begin_turn_view() -> void:
    inspected_id = controller.active_id
    pending_cell = NO_CELL
    pending_path.clear()
    pending_target_id = -1
    mode = Mode.IDLE
    var a: BattleUnit = controller.active_unit()
    if a != null and a.team == "player" and controller.result == "":
        if not auto_battle:
            if not controller.move_targets(a).is_empty():
                mode = Mode.MOVE
            elif not controller.attack_targets(a, a.cell).is_empty():
                mode = Mode.ATTACK
        _autosave()
    _recompute_highlights()


func _play_anim(unit_id: int, anim: String) -> void:
    anim_override[unit_id] = {"anim": anim, "start": anim_clock}


func _on_unit_acted(unit_id: int, kind: String, data: Dictionary) -> void:
    if kind == "attack" or kind == "skill_damage":
        _play_anim(unit_id, "attack")
        var tid: int = int(data.get("target_id", -1))
        if tid >= 0 and (kind == "skill_damage" or bool((data.get("result", {}) as Dictionary).get("hit", false))):
            _play_anim(tid, "hurt")
    if kind == "attack":
        var res: Dictionary = data["result"]
        var target: BattleUnit = controller.unit_by_id(int(data["target_id"]))
        if target == null:
            return
        if bool(res["hit"]):
            var crit: bool = bool(res["crit"])
            _add_popup(target, str(res["damage"]) + ("!" if crit else ""), Color(1.0, 0.85, 0.3) if crit else Color.WHITE)
        else:
            _add_popup(target, "Miss", Color(0.75, 0.75, 0.75))
    elif kind == "skill_damage":
        var hit_target: BattleUnit = controller.unit_by_id(int(data["target_id"]))
        if hit_target != null:
            _add_popup(hit_target, str(data["damage"]) + "*", Color(1.0, 0.55, 0.25))
    elif kind == "heal":
        var healed: BattleUnit = controller.unit_by_id(int(data["target_id"]))
        if healed != null:
            _add_popup(healed, "+" + str(data["amount"]), Color(0.4, 1.0, 0.5))


func _on_battle_ended(_outcome: String) -> void:
    _show_result()


func _show_result() -> void:
    var won: bool = controller.result == "victory"
    result_title.text = "VICTORY" if won else "DEFEAT"
    result_text.text = str(battle_def.get("victory_text", "The roadwolves are broken. The road to Eldrimar is open.")) if won else str(battle_def.get("defeat_text", "The Dunmarrow company has fallen."))
    result_text.text += "\nTurns taken: %d" % controller.turn_count
    if won:
        if str(battle_def.get("id", "")) == BATTLE_ID:
            GameState.world_flags["camp_cleared"] = true
        var clear_flag: String = str(battle_def.get("world_flag_on_victory", ""))
        if clear_flag != "":
            GameState.world_flags[clear_flag] = true
    if not exp_awarded:
        exp_awarded = true
        battle_rewards = GameState.award_battle(controller.units, controller.result)
    if not (battle_rewards.get("reports", []) as Array).is_empty():
        result_text.text += "\n\n" + _rewards_summary(battle_rewards)
    elif not won:
        result_text.text += "\nA lost battle pays no EXP, AP or gold."
    result_panel.visible = true
    _refresh_ui()


## True when the AI should take this unit's turn: always for enemies, and for the player's units while Auto Battle is on.
func _ai_controls(u: BattleUnit) -> bool:
    if u == null:
        return false
    return u.team == "enemy" or (auto_battle and u.team == "player")


## FF7-style victory report: totals, then one line per character (EXP, AP, level-ups, sigil level-ups).
func _rewards_summary(rw: Dictionary) -> String:
    var lines: Array[String] = []
    lines.append("EXP %d (split among survivors)   AP %d (each)   Gold +%d" % [int(rw.get("total_exp", 0)), int(rw.get("total_ap", 0)), int(rw.get("gold", 0))])
    for r in (rw.get("reports", []) as Array):
        var rep: Dictionary = r
        var line: String = "%s  +%d EXP  +%d AP" % [str(rep["name"]), int(rep["exp_gained"]), int(rep.get("ap_gained", 0))]
        var levels: Array = rep["levels"]
        if not levels.is_empty():
            var total: Dictionary = {}
            for lv in levels:
                var gains: Dictionary = (lv as Dictionary)["gains"]
                for k in gains.keys():
                    total[k] = int(total.get(k, 0)) + int(gains[k])
            var parts: Array[String] = []
            var keys: Array = total.keys()
            keys.sort()
            for k in keys:
                parts.append("%s+%d" % [str(k).to_upper(), int(total[k])])
            var last: Dictionary = levels[levels.size() - 1]
            line += "  LEVEL UP! Lv %d (%s)" % [int(last["level"]), " ".join(PackedStringArray(parts))]
        lines.append(line)
        for s in (rep.get("sigils", []) as Array):
            var sr: Dictionary = s
            if bool(sr["mastered"]) and int(sr["after"]) > int(sr["before"]):
                lines.append("   %s MASTERED!" % str(sr["name"]))
            elif int(sr["after"]) > int(sr["before"]):
                var extra := ""
                var ns: Array = sr["new_skills"]
                if not ns.is_empty():
                    var names: Array[String] = []
                    for sid in ns:
                        names.append(str((GameData.skills.get(str(sid), {}) as Dictionary).get("name", sid)))
                    extra = " - learned " + ", ".join(PackedStringArray(names))
                lines.append("   %s reached level %d%s" % [str(sr["name"]), int(sr["after"]), extra])
    for sname in (rw.get("spawned", []) as Array):
        lines.append("A new %s was forged from the mastered sigil!" % str(sname))
    return "\n".join(PackedStringArray(lines))


func _maybe_run_ai() -> void:
    if ai_busy:
        return
    ai_busy = true
    while controller.result == "":
        if not _ai_controls(controller.active_unit()):
            break
        await get_tree().create_timer(AI_DELAY).timeout
        if controller.result != "":
            break
        var a: BattleUnit = controller.active_unit()
        if not _ai_controls(a):               # Auto Battle was switched off while we waited
            break
        controller.run_ai_turn(a.team == "player")
    ai_busy = false
    if resync_view:
        resync_view = false
        var cur: BattleUnit = controller.active_unit()
        if cur != null and cur.team == "player" and controller.result == "":
            _begin_turn_view()                # hand control back: show move/attack tiles again
    _refresh_ui()
    queue_redraw()


func _on_auto_toggled(pressed: bool) -> void:
    auto_battle = pressed
    _save_settings()
    if pressed:
        resync_view = false
        _on_log("Auto Battle ON: your units fight on their own.")
        _enter_mode(Mode.IDLE)                # drop any half-made selection and its highlights
        if not input_locked:
            _maybe_run_ai()
    else:
        resync_view = ai_busy                 # the running AI loop hands control back when it stops
        _on_log("Auto Battle OFF: you are in control.")
    _refresh_ui()
    queue_redraw()


# ------------------------------------------------------------------ settings

func _load_settings() -> void:
    var cfg := ConfigFile.new()
    if cfg.load(SETTINGS_PATH) == OK:
        auto_battle = bool(cfg.get_value("battle", "auto_battle", false))


func _save_settings() -> void:
    var cfg := ConfigFile.new()
    cfg.load(SETTINGS_PATH)                   # keep other keys; a missing file is fine
    cfg.set_value("battle", "auto_battle", auto_battle)
    cfg.save(SETTINGS_PATH)


# ------------------------------------------------------------------ saving

func _save_summary() -> String:
    return "%s | turn %d" % [str(controller.def.get("title", "Battle")), controller.turn_count]


func _autosave() -> void:
    if suppress_autosave or controller.result != "" or controller.units.is_empty():
        return
    var a: BattleUnit = controller.active_unit()
    if a == null or a.team != "player" or ai_busy or input_locked:
        return
    SaveSystem.autosave({"battle": controller.to_dict(), "party": GameState.party.to_dict(), "battle_def": controller.def, "creation_profile": GameState.creation_profile.duplicate(true), "world_flags": GameState.world_flags.duplicate(true), "world_pos": [GameState.world_pos.x, GameState.world_pos.y], "from_world": GameState.from_world}, _save_summary())


func _on_save_pressed() -> void:
    if ai_busy or input_locked or controller.result != "":
        if auto_battle and controller.result == "":
            _on_log("Turn Auto Battle off to save.")
        else:
            _on_log("You can only save during your own turn.")
        return
    if SaveSystem.save_slot("1", {"battle": controller.to_dict(), "party": GameState.party.to_dict(), "battle_def": controller.def, "creation_profile": GameState.creation_profile.duplicate(true), "world_flags": GameState.world_flags.duplicate(true), "world_pos": [GameState.world_pos.x, GameState.world_pos.y], "from_world": GameState.from_world}, _save_summary()):
        _on_log("Game saved to slot 1.")
    else:
        _on_log("Save failed.")


func _on_load_pressed() -> void:
    if ai_busy or (input_locked and not prep_active):
        if auto_battle:
            _on_log("Turn Auto Battle off to load.")
        return
    var slot: String = _newest_slot()
    if slot == "":
        _on_log("No save found yet.")
        return
    var res: Dictionary = SaveSystem.load_slot(slot)
    if not bool(res.get("ok", false)):
        _on_log(str(res.get("error", "Load failed.")))
        return
    var payload: Dictionary = res["payload"]
    var saved: Dictionary = payload.get("battle", {})
    popups.clear()
    visual_pos.clear()
    last_turn_count = -1
    if payload.has("party"):
        var saved_party: Dictionary = payload["party"]
        GameState.party = PartyState.from_dict(saved_party)
    GameState.creation_profile = (payload.get("creation_profile", {}) as Dictionary).duplicate(true)
    GameState.world_flags = (payload.get("world_flags", {}) as Dictionary).duplicate(true)
    var saved_world_pos: Array = payload.get("world_pos", [0.0, 0.0])
    if saved_world_pos.size() >= 2:
        GameState.world_pos = Vector2(float(saved_world_pos[0]), float(saved_world_pos[1]))
    GameState.from_world = bool(payload.get("from_world", false))
    suppress_autosave = true
    var saved_def: Dictionary = payload.get("battle_def", GameData.battle_def(BATTLE_ID))
    var ok: bool = controller.restore(saved_def, GameState.battle_db(), saved)
    suppress_autosave = false
    if not ok:
        _on_log("That save does not match this battle.")
        return
    battle_def = saved_def
    result_panel.visible = false
    prep_active = false
    prep_panel.visible = false
    input_locked = false
    _refresh_ui()
    queue_redraw()
    exp_awarded = controller.result != ""      # a finished battle was already paid out
    battle_rewards = {}
    if controller.result != "":
        _show_result()
    if bool(res.get("from_backup", false)):
        _on_log("Main save was damaged; loaded the backup copy.")


## "Load" restores the most recent save: manual slot 1 or either autosave.
func _newest_slot() -> String:
    var best := ""
    var best_unix := -1.0
    for slot in ["1", "auto_a", "auto_b"]:
        var info: Dictionary = SaveSystem.slot_info(str(slot))
        if bool(info["exists"]) and float(info["unix"]) > best_unix:
            best_unix = float(info["unix"])
            best = str(slot)
    return best


# ------------------------------------------------------------------ frame update

func _process(delta: float) -> void:
    var dirty := false
    for o in controller.units:
        var u: BattleUnit = o
        var target: Vector2 = cell_to_world(u.cell)
        var cur: Vector2 = visual_pos.get(u.id, target)
        if cur != target:
            visual_pos[u.id] = cur.move_toward(target, MOVE_SPEED * delta)
            dirty = true
    for i in range(popups.size() - 1, -1, -1):
        popups[i]["age"] = float(popups[i]["age"]) + delta
        if float(popups[i]["age"]) > 1.1:
            popups.remove_at(i)
        dirty = true
    anim_clock += delta
    if anim_clock - anim_last_draw >= 0.07:      # sprite animation: about 14 redraws per second is plenty
        anim_last_draw = anim_clock
        dirty = true
    if dirty:
        queue_redraw()


func _add_popup(unit: BattleUnit, text: String, color: Color) -> void:
    var p: Vector2 = visual_pos.get(unit.id, cell_to_world(unit.cell))
    popups.append({"text": text, "pos": p, "age": 0.0, "color": color})


# ------------------------------------------------------------------ drawing

func _draw() -> void:
    if controller.map == null:
        return
    var m: BattleMap = controller.map
    for order in range(m.width + m.height - 1):
        for x in range(m.width):
            var y: int = order - x
            if y >= 0 and y < m.height:
                _draw_tile(Vector2i(x, y))
    _draw_overlays()
    _draw_units()
    _draw_popups()


func _diamond(center: Vector2, factor: float = 1.0) -> PackedVector2Array:
    var hw: float = TILE_W * 0.5 * factor
    var hh: float = TILE_H * 0.5 * factor
    return PackedVector2Array([center + Vector2(0, -hh), center + Vector2(hw, 0), center + Vector2(0, hh), center + Vector2(-hw, 0)])


func _outline(center: Vector2, color: Color, width: float, factor: float = 1.0) -> void:
    var pts: PackedVector2Array = _diamond(center, factor)
    pts.append(pts[0])
    draw_polyline(pts, color, width)


func _draw_tile(cell: Vector2i) -> void:
    var m: BattleMap = controller.map
    var top: Vector2 = cell_to_world(cell)
    var h: int = m.height_at(cell)
    var tid: String = m.terrain_id(cell)
    var col := Color.html(str(m.terrain_def(cell).get("color", "#41714f")))
    var hw: float = TILE_W * 0.5
    var hh: float = TILE_H * 0.5
    if h > 0:
        var drop := Vector2(0, float(h) * HEIGHT_STEP)
        draw_colored_polygon(PackedVector2Array([top + Vector2(-hw, 0), top + Vector2(0, hh), top + Vector2(0, hh) + drop, top + Vector2(-hw, 0) + drop]), col.darkened(0.45))
        draw_colored_polygon(PackedVector2Array([top + Vector2(0, hh), top + Vector2(hw, 0), top + Vector2(hw, 0) + drop, top + Vector2(0, hh) + drop]), col.darkened(0.30))
    if tid == "rock":
        var lift := Vector2(0, -14)
        draw_colored_polygon(_diamond(top), col.darkened(0.2))
        draw_colored_polygon(PackedVector2Array([top + Vector2(-hw, 0), top + Vector2(0, hh), top + Vector2(0, hh) + lift, top + Vector2(-hw, 0) + lift]), col.darkened(0.35))
        draw_colored_polygon(PackedVector2Array([top + Vector2(0, hh), top + Vector2(hw, 0), top + Vector2(hw, 0) + lift, top + Vector2(0, hh) + lift]), col.darkened(0.2))
        draw_colored_polygon(_diamond(top + lift), col.lightened(0.1))
        _outline(top, Color(0.05, 0.08, 0.07, 0.6), 1.0)
        return
    draw_colored_polygon(_diamond(top), col.lightened(0.04 * float(h)))
    _outline(top, Color(0.05, 0.08, 0.07, 0.55), 1.0)
    match tid:
        "forest":
            _draw_tree(top + Vector2(-9, 3))
            _draw_tree(top + Vector2(9, 1))
        "hill":
            draw_colored_polygon(_diamond(top, 0.55), col.lightened(0.12))
        "deep_water", "ford":
            var wave := Color(1, 1, 1, 0.2)
            draw_line(top + Vector2(-14, -3), top + Vector2(-6, -1), wave, 1.5)
            draw_line(top + Vector2(2, 3), top + Vector2(12, 5), wave, 1.5)
            draw_line(top + Vector2(-4, 6), top + Vector2(4, 8), wave, 1.5)
        "bridge":
            var ex := Vector2(hw, hh) * 0.5
            var ey := Vector2(-hw, hh) * 0.5
            var plank := Color(0.36, 0.25, 0.14)
            for k in [-0.6, 0.0, 0.6]:
                draw_line(top + ey * float(k) - ex * 0.9, top + ey * float(k) + ex * 0.9, plank, 2.0)
            draw_line(top + ex * 0.9 - ey, top + ex * 0.9 + ey, plank.darkened(0.3), 3.0)
            draw_line(top - ex * 0.9 - ey, top - ex * 0.9 + ey, plank.darkened(0.3), 3.0)
        "road":
            draw_circle(top + Vector2(-6, 2), 1.5, col.lightened(0.2))
            draw_circle(top + Vector2(7, -2), 1.5, col.lightened(0.2))


func _draw_tree(base: Vector2) -> void:
    draw_rect(Rect2(base + Vector2(-1.5, -3), Vector2(3, 6)), Color(0.28, 0.2, 0.12))
    draw_colored_polygon(PackedVector2Array([base + Vector2(-8, -2), base + Vector2(0, -20), base + Vector2(8, -2)]), Color(0.10, 0.27, 0.17))
    draw_colored_polygon(PackedVector2Array([base + Vector2(-6, -9), base + Vector2(0, -24), base + Vector2(6, -9)]), Color(0.14, 0.34, 0.21))


func _draw_overlays() -> void:
    for k in move_cells.keys():
        var c: Vector2i = k
        var top: Vector2 = cell_to_world(c)
        draw_colored_polygon(_diamond(top, 0.96), Color(0.28, 0.62, 0.95, 0.38))
        _outline(top, Color(0.5, 0.8, 1.0, 0.7), 1.5, 0.96)
    if pending_path.size() > 0 and pending_cell != NO_CELL:
        var prev: Vector2 = cell_to_world(controller.active_unit().cell)
        for step in pending_path:
            var s: Vector2i = step
            var p: Vector2 = cell_to_world(s)
            draw_line(prev, p, Color(1.0, 0.95, 0.5, 0.95), 3.0)
            prev = p
        draw_colored_polygon(_diamond(cell_to_world(pending_cell), 0.96), Color(1.0, 0.95, 0.4, 0.35))
        _outline(cell_to_world(pending_cell), Color(1.0, 0.95, 0.4), 3.0, 0.96)
    for k in target_cells.keys():
        var c: Vector2i = k
        var top: Vector2 = cell_to_world(c)
        var chosen: bool = int(target_cells[c]) == pending_target_id
        var tint := Color(0.4, 0.9, 0.5, 0.45) if mode == Mode.SKILL else Color(0.95, 0.25, 0.2, 0.45)
        draw_colored_polygon(_diamond(top, 0.96), tint)
        _outline(top, Color(1, 1, 1, 0.95) if chosen else Color(1, 0.6, 0.5, 0.8), 4.0 if chosen else 1.5, 0.96)
    var a: BattleUnit = controller.active_unit()
    if a != null and a.is_alive():
        _outline(cell_to_world(a.cell), Color(1.0, 0.86, 0.3, 0.9), 2.5, 1.02)


func _ellipse_points(center: Vector2, rx: float, ry: float, segments: int = 20) -> PackedVector2Array:
    var pts := PackedVector2Array()
    for i in range(segments):
        var ang: float = TAU * float(i) / float(segments)
        pts.append(center + Vector2(cos(ang) * rx, sin(ang) * ry))
    return pts


func _draw_units() -> void:
    var order: Array = []
    for o in controller.units:
        var u: BattleUnit = o
        if u.is_alive():
            order.append(u)
    order.sort_custom(func(a, b): return float(visual_pos.get(a.id, Vector2.ZERO).y) < float(visual_pos.get(b.id, Vector2.ZERO).y))
    for o in order:
        var u: BattleUnit = o
        _draw_unit(u, visual_pos.get(u.id, cell_to_world(u.cell)))


func _draw_unit(u: BattleUnit, p: Vector2) -> void:
    var is_player: bool = u.team == "player"
    var body := Color(0.22, 0.50, 0.88) if is_player else Color(0.78, 0.24, 0.20)
    draw_colored_polygon(_ellipse_points(p + Vector2(0, 2), 17.0, 7.0), Color(0, 0, 0, 0.35))
    if u.id == inspected_id:
        var ring: PackedVector2Array = _ellipse_points(p + Vector2(0, 2), 22.0, 10.0, 24)
        ring.append(ring[0])
        draw_polyline(ring, Color(1, 1, 1, 0.9), 2.0)
    # facing marker on the ground
    var f: Vector2i = BattleMap.DIRS[u.facing]
    var fdir: Vector2 = Vector2(float(f.x - f.y) * TILE_W * 0.5, float(f.x + f.y) * TILE_H * 0.5).normalized()
    if _draw_unit_sprite(u, p, is_player, fdir):
        return
    draw_line(p + Vector2(0, 2), p + Vector2(0, 2) + fdir * 20.0, Color(1, 1, 1, 0.8), 2.0)
    draw_circle(p + Vector2(0, 2) + fdir * 20.0, 3.0, Color(1, 1, 1, 0.9))
    # body, helm, visor
    draw_rect(Rect2(p + Vector2(-9, -26), Vector2(18, 27)), body)
    draw_rect(Rect2(p + Vector2(-7, -36), Vector2(14, 11)), Color(0.72, 0.73, 0.70))
    draw_rect(Rect2(p + Vector2(-5, -33), Vector2(10, 3)), Color(0.16, 0.18, 0.20))
    # class glyph
    match u.class_id:
        "knight":
            draw_rect(Rect2(p + Vector2(-17, -24), Vector2(8, 14)), Color(0.62, 0.64, 0.68))
            draw_line(p + Vector2(10, -18), p + Vector2(19, -38), Color(0.85, 0.82, 0.66), 3.0)
        "swordsman":
            draw_line(p + Vector2(10, -18), p + Vector2(19, -38), Color(0.85, 0.82, 0.66), 3.0)
        "archer":
            draw_arc(p + Vector2(13, -20), 12.0, -PI * 0.5, PI * 0.5, 12, Color(0.55, 0.38, 0.2), 2.5)
            draw_line(p + Vector2(13, -32), p + Vector2(13, -8), Color(0.9, 0.9, 0.8), 1.0)
        "cleric":
            draw_line(p + Vector2(12, -4), p + Vector2(12, -36), Color(0.6, 0.45, 0.25), 3.0)
            draw_rect(Rect2(p + Vector2(-1.5, -22), Vector2(3, 10)), Color(0.95, 0.95, 0.9))
            draw_rect(Rect2(p + Vector2(-5, -19), Vector2(10, 3)), Color(0.95, 0.95, 0.9))
        "roadreaver":
            draw_line(p + Vector2(10, -14), p + Vector2(18, -38), Color(0.45, 0.32, 0.2), 3.0)
            draw_colored_polygon(PackedVector2Array([p + Vector2(14, -36), p + Vector2(24, -34), p + Vector2(15, -26)]), Color(0.75, 0.76, 0.78))
    if not HAND_DRAWN_CLASSES.has(u.class_id):
        _draw_branch_glyph(p, str(GameData.class_def(u.class_id).get("branch", "")))
    # HP bar and name
    var ratio: float = clampf(float(u.hp) / float(u.max_hp()), 0.0, 1.0)
    draw_rect(Rect2(p + Vector2(-20, -50), Vector2(40, 7)), Color(0.1, 0.08, 0.08))
    draw_rect(Rect2(p + Vector2(-20, -50), Vector2(40.0 * ratio, 7)), Color(0.85, 0.2, 0.2).lerp(Color(0.25, 0.85, 0.38), ratio))
    draw_string(ThemeDB.fallback_font, p + Vector2(-40, -55), u.display_name, HORIZONTAL_ALIGNMENT_CENTER, 80, 14, Color.WHITE)
    if u.morale <= 0:
        draw_string(ThemeDB.fallback_font, p + Vector2(-40, -70), "ROUTED", HORIZONTAL_ALIGNMENT_CENTER, 80, 14, Color(1, 0.6, 0.3))


## Animated pixel sprite (Tiny RPG Soldier for the player's side, Orc for the enemy). Returns false without the art,
## and _draw_unit then falls back to the drawn figure.
func _draw_unit_sprite(u: BattleUnit, p: Vector2, is_player: bool, fdir: Vector2) -> bool:
    var kind: String = "soldier" if is_player else "orc"
    if Art.unit_sheet(kind, "idle") == null:
        return false
    var team_col := Color(0.30, 0.58, 1.0) if is_player else Color(0.95, 0.30, 0.25)
    var ring: PackedVector2Array = _ellipse_points(p + Vector2(0, 2), 19.0, 8.0, 20)
    ring.append(ring[0])
    draw_polyline(ring, Color(team_col.r, team_col.g, team_col.b, 0.9), 2.5)
    draw_line(p + Vector2(0, 2), p + Vector2(0, 2) + fdir * 16.0, Color(1, 1, 1, 0.55), 2.0)
    var anim: String = "idle"
    var start: float = 0.0
    var ov: Dictionary = anim_override.get(u.id, {})
    if not ov.is_empty() and anim_clock - float(ov["start"]) < Art.unit_duration(str(ov["anim"])) + 0.1:
        anim = str(ov["anim"])
        start = float(ov["start"])
    elif visual_pos.get(u.id, p) != cell_to_world(u.cell):
        anim = "walk"
    var t: float = anim_clock - start if anim != "idle" and anim != "walk" else anim_clock + float(u.id) * 0.37
    var scale: float = 2.1 if is_player else 2.4
    var tint := Color(1, 0.75, 0.75) if (anim == "hurt") else Color.WHITE
    Art.draw_unit(self, kind, anim, t, p + Vector2(0, 4), scale, fdir.x < 0.0, tint)
    var ratio: float = clampf(float(u.hp) / float(u.max_hp()), 0.0, 1.0)
    draw_rect(Rect2(p + Vector2(-20, -50), Vector2(40, 7)), Color(0.1, 0.08, 0.08))
    draw_rect(Rect2(p + Vector2(-20, -50), Vector2(40.0 * ratio, 7)), Color(0.85, 0.2, 0.2).lerp(Color(0.25, 0.85, 0.38), ratio))
    draw_string(ThemeDB.fallback_font, p + Vector2(-40, -55), u.display_name, HORIZONTAL_ALIGNMENT_CENTER, 80, 14, Color.WHITE)
    if u.morale <= 0:
        draw_string(ThemeDB.fallback_font, p + Vector2(-40, -70), "ROUTED", HORIZONTAL_ALIGNMENT_CENTER, 80, 14, Color(1, 0.6, 0.3))
    return true


## Placeholder glyph for classes without their own drawing (promoted heroes): one simple shape per branch.
func _draw_branch_glyph(p: Vector2, branch: String) -> void:
    if branch == "cavalry":
        draw_line(p + Vector2(8, -4), p + Vector2(22, -42), Color(0.55, 0.42, 0.25), 3.0)
        draw_colored_polygon(PackedVector2Array([p + Vector2(20, -42), p + Vector2(30, -38), p + Vector2(21, -34)]), Color(0.80, 0.30, 0.25))
    elif branch == "ranged":
        draw_arc(p + Vector2(13, -20), 12.0, -PI * 0.5, PI * 0.5, 12, Color(0.55, 0.38, 0.2), 2.5)
        draw_line(p + Vector2(13, -32), p + Vector2(13, -8), Color(0.9, 0.9, 0.8), 1.0)
    elif branch == "magic":
        draw_line(p + Vector2(12, -4), p + Vector2(12, -34), Color(0.5, 0.38, 0.62), 3.0)
        draw_circle(p + Vector2(12, -38), 5.0, Color(0.55, 0.75, 1.0))
    elif branch == "support":
        draw_line(p + Vector2(12, -4), p + Vector2(12, -36), Color(0.6, 0.45, 0.25), 3.0)
        draw_circle(p + Vector2(12, -39), 4.0, Color(1.0, 0.9, 0.55))
    elif branch == "specialist":
        draw_line(p + Vector2(11, -16), p + Vector2(17, -30), Color(0.78, 0.80, 0.84), 3.0)
    else:
        if branch == "warrior":
            draw_rect(Rect2(p + Vector2(-17, -24), Vector2(8, 14)), Color(0.62, 0.64, 0.68))
        draw_line(p + Vector2(10, -18), p + Vector2(19, -38), Color(0.85, 0.82, 0.66), 3.0)


func _draw_popups() -> void:
    for pop in popups:
        var age: float = float(pop["age"])
        var base: Vector2 = pop["pos"]
        var c: Color = pop["color"]
        c.a = clampf(1.2 - age, 0.0, 1.0)
        draw_string(ThemeDB.fallback_font, base + Vector2(-30, -64 - age * 34.0), str(pop["text"]), HORIZONTAL_ALIGNMENT_CENTER, 60, 28, c)


# ------------------------------------------------------------------ HUD
## v0.5.4 layout (1280x720 base, phone landscape): fonts 18-26, buttons 64-84 high (about 7-8 mm on a phone),
## unit card top-left, turn order top-centre, zoom/menu/auto top-right, log bottom-left, preview + Confirm/Cancel
## bottom-centre, actions bottom-right. Everything sits inside `hud_root`, which is inset by the phone safe area.

func _hud_panel(alpha: float = 0.84) -> PanelContainer:
    var p := PanelContainer.new()
    var sb := StyleBoxFlat.new()
    sb.bg_color = Color(0.09, 0.08, 0.07, alpha)
    sb.border_color = Color(0.62, 0.52, 0.34, 0.9)
    sb.set_border_width_all(2)
    sb.set_corner_radius_all(8)
    sb.set_content_margin_all(10)
    p.add_theme_stylebox_override("panel", sb)
    return p


## Insets the HUD by the notch / rounded corners on phones. Desktop and headless runs get zero margins.
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

    # Reflow key HUD elements for narrow phones without shrinking the game world.
    var vw: float = get_viewport().get_visible_rect().size.x
    var vh: float = get_viewport().get_visible_rect().size.y
    var compact: bool = vw < 900.0
    if info_label != null:
        info_label.custom_minimum_size = Vector2(clampf(vw * 0.27, 190.0, 330.0), 0.0)
        info_label.add_theme_font_size_override("font_size", 16 if compact else 20)
    if log_label != null:
        log_label.custom_minimum_size = Vector2(clampf(vw * 0.25, 170.0, 370.0), 0.0)
        log_label.add_theme_font_size_override("font_size", 14 if compact else 18)
    if preview_label != null:
        preview_label.custom_minimum_size = Vector2(clampf(vw * 0.48, 250.0, 440.0), 0.0)
        preview_label.add_theme_font_size_override("font_size", 16 if compact else 20)
    var action_width: float = clampf(vw * 0.19, 138.0, 230.0)
    var action_height: float = clampf(vh * 0.09, 54.0, 76.0)
    for action in [btn_move, btn_attack, btn_skill, btn_wait]:
        if action != null:
            action.custom_minimum_size = Vector2(action_width, action_height)
            action.add_theme_font_size_override("font_size", 18 if compact else 25)
    if btn_confirm != null:
        btn_confirm.custom_minimum_size = Vector2(clampf(vw * 0.22, 150.0, 250.0), clampf(vh * 0.10, 58.0, 84.0))
    if btn_cancel != null:
        btn_cancel.custom_minimum_size = Vector2(clampf(vw * 0.16, 120.0, 180.0), clampf(vh * 0.10, 58.0, 84.0))
    if result_scroll != null:
        result_scroll.custom_minimum_size = Vector2(clampf(vw * 0.78, 280.0, 660.0), clampf(vh * 0.28, 130.0, 190.0))
        result_text.custom_minimum_size = Vector2(clampf(vw * 0.76, 260.0, 640.0), 0.0)
    if prep_scroll != null:
        prep_scroll.custom_minimum_size = Vector2(clampf(vw * 0.78, 280.0, 660.0), clampf(vh * 0.25, 120.0, 170.0))
        prep_text.custom_minimum_size = Vector2(clampf(vw * 0.76, 260.0, 640.0), 0.0)


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

    # Top-left: unit card (ignores touches so the map can be dragged underneath)
    var info_panel := _hud_panel()
    info_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
    info_label = Label.new()
    info_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    info_label.custom_minimum_size = Vector2(330, 120)
    info_label.add_theme_font_size_override("font_size", 20)
    info_panel.add_child(info_label)
    root.add_child(info_panel)
    info_panel.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT, Control.PRESET_MODE_MINSIZE, 12)

    # Top centre: turn timeline
    timeline_box = HBoxContainer.new()
    timeline_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
    timeline_box.add_theme_constant_override("separation", 4)
    root.add_child(timeline_box)
    timeline_box.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP, Control.PRESET_MODE_MINSIZE, 8)
    timeline_box.grow_horizontal = Control.GROW_DIRECTION_BOTH

    # Top right: zoom, menu (Save / Load), Auto Battle
    var menu := VBoxContainer.new()
    menu.add_theme_constant_override("separation", 6)
    var menu_row := HBoxContainer.new()
    menu_row.add_theme_constant_override("separation", 6)
    menu_row.add_child(_make_button("-", _on_zoom_out, Vector2(76, 64), 30))
    menu_row.add_child(_make_button("+", _on_zoom_in, Vector2(76, 64), 30))
    menu_row.add_child(_make_button("Menu", _on_menu_pressed, Vector2(130, 64), 22))
    menu.add_child(menu_row)
    btn_auto = Button.new()
    btn_auto.toggle_mode = true
    btn_auto.custom_minimum_size = Vector2(0, 64)
    btn_auto.add_theme_font_size_override("font_size", 22)
    btn_auto.set_pressed_no_signal(auto_battle)
    btn_auto.toggled.connect(_on_auto_toggled)
    menu.add_child(btn_auto)
    root.add_child(menu)
    menu.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT, Control.PRESET_MODE_MINSIZE, 12)
    menu.grow_horizontal = Control.GROW_DIRECTION_BEGIN

    # Bottom right: the four actions
    var col := VBoxContainer.new()
    col.add_theme_constant_override("separation", 8)
    btn_move = _make_button("Move", _on_move_pressed, Vector2(230, 76), 26)
    btn_attack = _make_button("Attack", _on_attack_pressed, Vector2(230, 76), 26)
    btn_skill = _make_button("Skill", _on_skill_pressed, Vector2(230, 76), 22)
    btn_wait = _make_button("Wait / End", _on_wait_pressed, Vector2(230, 76), 26)
    for b in [btn_move, btn_attack, btn_skill, btn_wait]:
        col.add_child(b)
    btn_skill.visible = false
    root.add_child(col)
    col.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_RIGHT, Control.PRESET_MODE_MINSIZE, 12)
    col.grow_horizontal = Control.GROW_DIRECTION_BEGIN
    col.grow_vertical = Control.GROW_DIRECTION_BEGIN

    # Bottom centre: attack / skill / move preview with big Confirm and Cancel under it
    var mid := VBoxContainer.new()
    mid.mouse_filter = Control.MOUSE_FILTER_IGNORE
    mid.add_theme_constant_override("separation", 8)
    preview_panel = _hud_panel(0.9)
    preview_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
    preview_label = Label.new()
    preview_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    preview_label.custom_minimum_size = Vector2(440, 0)
    preview_label.add_theme_font_size_override("font_size", 20)
    preview_panel.add_child(preview_label)
    preview_panel.visible = false
    mid.add_child(preview_panel)
    var confirm_row := HBoxContainer.new()
    confirm_row.alignment = BoxContainer.ALIGNMENT_CENTER
    confirm_row.add_theme_constant_override("separation", 10)
    btn_confirm = _make_button("Confirm", _on_confirm_pressed, Vector2(250, 84), 30)
    btn_cancel = _make_button("Cancel", _on_cancel_pressed, Vector2(180, 84), 26)
    confirm_row.add_child(btn_confirm)
    confirm_row.add_child(btn_cancel)
    btn_confirm.visible = false
    btn_cancel.visible = false
    mid.add_child(confirm_row)
    root.add_child(mid)
    mid.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM, Control.PRESET_MODE_MINSIZE, 12)
    mid.grow_horizontal = Control.GROW_DIRECTION_BOTH
    mid.grow_vertical = Control.GROW_DIRECTION_BEGIN

    # Bottom left: battle log (last 4 lines)
    var log_panel := _hud_panel(0.7)
    log_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
    log_label = Label.new()
    log_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    log_label.custom_minimum_size = Vector2(370, 100)
    log_label.add_theme_font_size_override("font_size", 18)
    log_panel.add_child(log_label)
    root.add_child(log_panel)
    log_panel.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_LEFT, Control.PRESET_MODE_MINSIZE, 12)
    log_panel.grow_vertical = Control.GROW_DIRECTION_BEGIN

    # Centre: result overlay. The text scrolls, so the four buttons are always on screen.
    result_panel = _hud_panel(0.96)
    var rbox := VBoxContainer.new()
    rbox.alignment = BoxContainer.ALIGNMENT_CENTER
    rbox.add_theme_constant_override("separation", 12)
    result_title = Label.new()
    result_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    result_title.add_theme_font_size_override("font_size", 44)
    result_scroll = ScrollContainer.new()
    result_scroll.custom_minimum_size = Vector2(660, 190)
    result_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
    result_text = Label.new()
    result_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    result_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    result_text.custom_minimum_size = Vector2(640, 0)
    result_text.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    result_text.add_theme_font_size_override("font_size", 21)
    result_scroll.add_child(result_text)
    var rgrid := GridContainer.new()
    rgrid.columns = 2
    rgrid.add_theme_constant_override("h_separation", 10)
    rgrid.add_theme_constant_override("v_separation", 10)
    rgrid.add_child(_make_button("Company • Gear • Sigils", _on_party_pressed, Vector2(320, 72), 22))
    rgrid.add_child(_make_button("Continue Journey", _on_world_pressed, Vector2(320, 72), 22))
    rbox.add_child(result_title)
    rbox.add_child(result_scroll)
    rbox.add_child(rgrid)
    result_panel.add_child(rbox)
    root.add_child(result_panel)
    result_panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER, Control.PRESET_MODE_MINSIZE)
    result_panel.grow_horizontal = Control.GROW_DIRECTION_BOTH
    result_panel.grow_vertical = Control.GROW_DIRECTION_BOTH
    result_panel.visible = false

    # Centre: pre-battle overlay
    prep_panel = _hud_panel(0.96)
    var pbox := VBoxContainer.new()
    pbox.alignment = BoxContainer.ALIGNMENT_CENTER
    pbox.add_theme_constant_override("separation", 12)
    prep_title = Label.new()
    prep_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    prep_title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    prep_title.custom_minimum_size = Vector2(640, 0)
    prep_title.add_theme_font_size_override("font_size", 36)
    prep_scroll = ScrollContainer.new()
    prep_scroll.custom_minimum_size = Vector2(660, 170)
    prep_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
    prep_text = Label.new()
    prep_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    prep_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    prep_text.custom_minimum_size = Vector2(640, 0)
    prep_text.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    prep_text.add_theme_font_size_override("font_size", 21)
    prep_scroll.add_child(prep_text)
    var prow := HBoxContainer.new()
    prow.alignment = BoxContainer.ALIGNMENT_CENTER
    prow.add_theme_constant_override("separation", 10)
    prow.add_child(_make_button("Begin Battle", _on_begin_pressed, Vector2(320, 80), 28))
    prow.add_child(_make_button("Party, Gear and Shop", _on_party_pressed, Vector2(320, 80), 22))
    btn_flee = _make_button("Back to the World", _on_world_pressed, Vector2(320, 80), 22)
    prow.add_child(btn_flee)
    pbox.add_child(prep_title)
    pbox.add_child(prep_scroll)
    pbox.add_child(prow)
    prep_panel.add_child(pbox)
    root.add_child(prep_panel)
    prep_panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER, Control.PRESET_MODE_MINSIZE)
    prep_panel.grow_horizontal = Control.GROW_DIRECTION_BOTH
    prep_panel.grow_vertical = Control.GROW_DIRECTION_BOTH
    prep_panel.visible = false

    # Centre: Menu popup (Save, Load, Close)
    menu_panel = _hud_panel(0.97)
    var mbox := VBoxContainer.new()
    mbox.add_theme_constant_override("separation", 10)
    var mtitle := Label.new()
    mtitle.text = "Menu"
    mtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    mtitle.add_theme_font_size_override("font_size", 32)
    mbox.add_child(mtitle)
    mbox.add_child(_make_button("Save", _on_menu_save, Vector2(300, 72), 26))
    mbox.add_child(_make_button("Load", _on_menu_load, Vector2(300, 72), 26))
    mbox.add_child(_make_button("Close", _on_menu_pressed, Vector2(300, 72), 26))
    menu_panel.add_child(mbox)
    root.add_child(menu_panel)
    menu_panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER, Control.PRESET_MODE_MINSIZE)
    menu_panel.grow_horizontal = Control.GROW_DIRECTION_BOTH
    menu_panel.grow_vertical = Control.GROW_DIRECTION_BOTH
    menu_panel.visible = false

    # Full screen: party / equipment / sigils / shop (added last so it covers everything)
    party_screen = PartyScreen.new()
    root.add_child(party_screen)
    party_screen.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    party_screen.visible = false
    party_screen.closed.connect(_on_party_closed)


func _on_menu_pressed() -> void:
    if menu_panel != null:
        menu_panel.visible = not menu_panel.visible


func _on_menu_save() -> void:
    menu_panel.visible = false
    _on_save_pressed()


func _on_menu_load() -> void:
    menu_panel.visible = false
    _on_load_pressed()


func _make_button(text: String, handler: Callable, min_size: Vector2 = Vector2(220, 76), font_size: int = 26) -> Button:
    var b := Button.new()
    b.text = text
    b.custom_minimum_size = min_size
    b.add_theme_font_size_override("font_size", font_size)
    b.pressed.connect(handler)
    return b


func _refresh_ui() -> void:
    if info_label == null:
        return
    var a: BattleUnit = controller.active_unit()
    var my_turn: bool = a != null and a.team == "player" and controller.result == "" and not ai_busy and not input_locked
    info_label.text = _info_text()
    var pv: String = _preview_text() if not prep_active else ""
    preview_label.text = pv
    preview_panel.visible = pv != ""
    btn_move.disabled = true
    btn_attack.disabled = true
    btn_wait.disabled = not my_turn
    btn_skill.visible = false
    if my_turn:
        btn_move.disabled = a.has_moved or a.has_acted or controller.move_targets(a).is_empty()
        btn_attack.disabled = a.has_acted or controller.attack_targets(a, a.cell).is_empty()
        if not a.skills.is_empty():
            var shown: String = active_skill if (mode == Mode.SKILL and a.skills.has(active_skill)) else _first_usable_skill(a)
            var sk: Dictionary = controller.skills.get(shown, {})
            var any_usable: bool = false
            for sid in a.skills:
                if not controller.skill_targets(a, str(sid)).is_empty():
                    any_usable = true
            btn_skill.visible = true
            btn_skill.text = "%s (%d MP)%s" % [str(sk.get("name", "Skill")), int(sk.get("mp", 0)), " >" if a.skills.size() > 1 else ""]
            btn_skill.disabled = a.has_acted or not any_usable
    btn_confirm.visible = my_turn and (pending_cell != NO_CELL or pending_target_id != -1)
    btn_cancel.visible = my_turn and mode != Mode.IDLE
    _refresh_auto_button()
    _refresh_timeline()


func _refresh_auto_button() -> void:
    if btn_auto == null:
        return
    btn_auto.set_pressed_no_signal(auto_battle)
    btn_auto.text = "Auto Battle: ON" if auto_battle else "Auto Battle: OFF"
    btn_auto.modulate = Color(1.0, 0.86, 0.3) if auto_battle else Color(1, 1, 1)


func _info_text() -> String:
    var u: BattleUnit = controller.unit_by_id(inspected_id)
    if u == null:
        return "Tap a unit to inspect it."
    var w: Dictionary = controller.weapon_of(u)
    var cdef: Dictionary = GameData.class_def(u.class_id)
    var lines: Array[String] = []
    lines.append("%s  [%s]" % [u.display_name, "Ally" if u.team == "player" else "Enemy"])
    var lv_line: String = "Lv %d %s" % [u.level, str(cdef.get("name", u.class_id))]
    if u.team == "player":
        var sh: CharacterSheetScript = GameState.party.sheet(u.character_id)
        if sh != null:
            if sh.level >= CharacterSheetScript.MAX_LEVEL:
                lv_line += "   MAX LEVEL"
            else:
                var need: int = sh.exp_to_next()
                var pct: int = roundi(float(sh.xp) * 100.0 / float(maxi(1, need)))
                lv_line += "   EXP %d/%d (%d%%)" % [sh.xp, need, pct]
    lines.append(lv_line)
    lines.append("HP %d/%d   MP %d/%d" % [u.hp, u.max_hp(), u.mp, u.stat("mp")])
    lines.append("ATK %d  DEF %d  SPD %d  MOV %d" % [roundi(CombatCalc.attack_power(u, w)), roundi(CombatCalc.defense(u, "physical")), u.stat("spd"), u.move])
    lines.append("Morale %d   Facing %s" % [u.morale, str(BattleMap.FACING_NAMES[u.facing])])
    lines.append("%s (range %d-%d)" % [str(w.get("name", "Unarmed")), int(w.get("range_min", 1)), int(w.get("range_max", 1))])
    var tdef: Dictionary = controller.map.terrain_def(u.cell)
    lines.append("On %s (cover %d, height %d)" % [str(tdef.get("name", "?")), controller.map.cover_at(u.cell), controller.map.height_at(u.cell)])
    return "\n".join(PackedStringArray(lines))


## Move / attack / skill preview, shown in its own panel above Confirm.
func _preview_text() -> String:
    var lines: Array[String] = []
    var a: BattleUnit = controller.active_unit()
    if a != null and a.team == "player" and controller.result == "":
        if mode == Mode.MOVE and pending_cell != NO_CELL:
            lines.append("Move to (%d,%d), cost %d. Tap again or Confirm." % [pending_cell.x, pending_cell.y, pending_cost])
        elif (mode == Mode.ATTACK or mode == Mode.SKILL) and pending_target_id != -1:
            var t: BattleUnit = controller.unit_by_id(pending_target_id)
            if t != null:
                if mode == Mode.ATTACK:
                    var p: Dictionary = controller.preview_attack(a, t)
                    lines.append("%s -> %s" % [a.display_name, t.display_name])
                    lines.append("Hit %d%%   Crit %d%%   Dmg %d-%d" % [int(p["hit"]), int(p["crit"]), int(p["dmg_min"]), int(p["dmg_max"])])
                    var tags: Array[String] = []
                    if str(p["facing"]) == "rear":
                        tags.append("REAR +25%")
                    elif str(p["facing"]) == "side":
                        tags.append("SIDE +10%")
                    if bool(p["flank"]):
                        tags.append("FLANK +15%")
                    if int(p["height_diff"]) != 0:
                        tags.append("HEIGHT %+d%%" % (int(p["height_diff"]) * 10))
                    if not tags.is_empty():
                        lines.append(", ".join(PackedStringArray(tags)))
                else:
                    var sk: Dictionary = controller.skills.get(active_skill, {})
                    if CombatCalc.is_damage_skill(sk):
                        var sp: Dictionary = CombatCalc.skill_preview(a, t, sk, active_skill, controller.weapon_of(a))
                        lines.append("%s: %d-%d damage to %s" % [str(sk.get("name", "Skill")), int(sp["dmg_min"]), int(sp["dmg_max"]), t.display_name])
                    else:
                        lines.append("%s: +%d HP to %s" % [str(sk.get("name", "Skill")), CombatCalc.heal_amount(a, sk, active_skill), t.display_name])
    return "\n".join(PackedStringArray(lines)).strip_edges()


func _refresh_timeline() -> void:
    for child in timeline_box.get_children():
        timeline_box.remove_child(child)
        child.queue_free()
    var order: Array = TurnQueue.timeline(controller.units, 8)
    var first := true
    for o in order:
        var u: BattleUnit = o
        var panel := PanelContainer.new()
        var sb := StyleBoxFlat.new()
        sb.bg_color = Color(0.18, 0.34, 0.62) if u.team == "player" else Color(0.62, 0.20, 0.18)
        sb.set_border_width_all(4 if first else 1)
        sb.border_color = Color(1.0, 0.86, 0.3) if first else Color(0, 0, 0, 0.6)
        sb.set_corner_radius_all(6)
        panel.add_theme_stylebox_override("panel", sb)
        panel.custom_minimum_size = Vector2(62, 50)
        panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
        var lbl := Label.new()
        lbl.text = u.character_id.substr(0, 3).to_upper()
        lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        lbl.add_theme_font_size_override("font_size", 20)
        lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
        panel.add_child(lbl)
        timeline_box.add_child(panel)
        first = false
