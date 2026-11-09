extends Control
## Touch-first escape traversal between the authored prologue choice and the first tactical battle.

const EscapeMissionScript = preload("res://scripts/core/escape_mission.gd")

var player_pos := Vector2.ZERO
var target_pos := Vector2.ZERO
var exit_pos := Vector2.ZERO
var moving := false
var clock := 0.0
var objective_label: Label
var story_label: Label
var instruction_label: Label
var action_button: Button
var started := false


func _ready() -> void:
    _build_ui()
    var viewport_size: Vector2 = get_viewport_rect().size
    player_pos = Vector2(viewport_size.x * 0.16, viewport_size.y * 0.72)
    target_pos = player_pos
    exit_pos = Vector2(viewport_size.x * 0.84, viewport_size.y * 0.30)
    _set_story_text()
    queue_redraw()


func _build_ui() -> void:
    var top := PanelContainer.new()
    var top_style := StyleBoxFlat.new()
    top_style.bg_color = Color(0.035, 0.045, 0.055, 0.94)
    top_style.border_color = Color("#b58a52")
    top_style.set_border_width_all(2)
    top_style.set_corner_radius_all(8)
    top_style.set_content_margin_all(14)
    top.add_theme_stylebox_override("panel", top_style)
    top.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
    top.offset_left = 16
    top.offset_right = -16
    top.offset_top = 16
    top.offset_bottom = 152
    add_child(top)

    var copy := VBoxContainer.new()
    copy.add_theme_constant_override("separation", 8)
    top.add_child(copy)

    var chapter := Label.new()
    chapter.text = "CHAPTER I  /  THE BURNING COURTYARD"
    chapter.add_theme_font_size_override("font_size", 15)
    chapter.add_theme_color_override("font_color", Color("#d9b879"))
    copy.add_child(chapter)

    objective_label = Label.new()
    objective_label.text = "OBJECTIVE  •  Reach the postern gate"
    objective_label.add_theme_font_size_override("font_size", 20)
    objective_label.add_theme_color_override("font_color", Color("#fff0d2"))
    copy.add_child(objective_label)

    story_label = Label.new()
    story_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    story_label.add_theme_font_size_override("font_size", 16)
    story_label.add_theme_color_override("font_color", Color("#d5d9d5"))
    copy.add_child(story_label)

    var bottom := PanelContainer.new()
    var bottom_style := StyleBoxFlat.new()
    bottom_style.bg_color = Color(0.035, 0.045, 0.055, 0.92)
    bottom_style.border_color = Color("#806342")
    bottom_style.set_border_width_all(1)
    bottom_style.set_corner_radius_all(8)
    bottom_style.set_content_margin_all(12)
    bottom.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
    bottom.offset_left = 16
    bottom.offset_right = -16
    bottom.offset_top = -112
    bottom.offset_bottom = -16
    add_child(bottom)

    var bottom_box := VBoxContainer.new()
    bottom_box.add_theme_constant_override("separation", 8)
    bottom.add_child(bottom_box)

    instruction_label = Label.new()
    instruction_label.text = "TAP THE COURTYARD TO MOVE  •  Avoid the burning debris"
    instruction_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    instruction_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    instruction_label.add_theme_font_size_override("font_size", 14)
    instruction_label.add_theme_color_override("font_color", Color("#d4c6aa"))
    bottom_box.add_child(instruction_label)

    action_button = Button.new()
    action_button.text = "BREAK THROUGH THE POSTERN"
    action_button.custom_minimum_size = Vector2(0, 58)
    action_button.add_theme_font_size_override("font_size", 18)
    action_button.visible = false
    action_button.pressed.connect(_launch_battle)
    bottom_box.add_child(action_button)


func _set_story_text() -> void:
    var people_saved: bool = bool(GameState.world_flags.get("prologue_people_saved", false))
    var record_saved: bool = bool(GameState.world_flags.get("prologue_record_saved", false))
    if people_saved and record_saved:
        story_label.text = "Sela keeps the household record close while Bram shepherds the survivors through the smoke. Wystan points to the postern — but armed raiders have taken the courtyard."
    elif people_saved:
        story_label.text = "The servants are with you. The household record is lost to the flames, and Sela refuses to look back. The postern is still open — if you can reach it."
    elif record_saved:
        story_label.text = "The sealed record is safe beneath Sela's cloak. The archive corridor is gone, and the people you could not reach are behind you. Raiders hold the postern."
    else:
        story_label.text = "The company escaped the gallery with neither the survivors nor the record. There is no time to turn back. Raiders have taken the postern."


func _unhandled_input(event: InputEvent) -> void:
    if started or action_button.visible:
        return
    var point := Vector2.ZERO
    var pressed := false
    if event is InputEventMouseButton:
        var mouse := event as InputEventMouseButton
        pressed = mouse.pressed and mouse.button_index == MOUSE_BUTTON_LEFT
        point = mouse.position
    elif event is InputEventScreenTouch:
        var touch := event as InputEventScreenTouch
        pressed = touch.pressed
        point = touch.position
    if pressed and point.y > 150.0 and point.y < size.y - 120.0:
        target_pos = point
        moving = true


func _process(delta: float) -> void:
    clock += delta
    if moving:
        var offset: Vector2 = target_pos - player_pos
        var distance: float = offset.length()
        if distance <= 4.0:
            moving = false
        else:
            player_pos += offset.normalized() * minf(distance, 220.0 * delta)
    var near_exit: bool = player_pos.distance_to(exit_pos) <= 100.0
    action_button.visible = near_exit and not started
    if near_exit:
        objective_label.text = "OBJECTIVE COMPLETE  •  The postern is within reach"
        instruction_label.text = "THE COMPANY IS TOGETHER  •  Break through the raiders"
    else:
        objective_label.text = "OBJECTIVE  •  Reach the postern gate"
        instruction_label.text = "TAP THE COURTYARD TO MOVE  •  Guide your company through the smoke"
    queue_redraw()


func _draw() -> void:
    var area := Rect2(Vector2.ZERO, size)
    draw_rect(area, Color("#171c1e"))
    var tile := 64.0
    for y in range(0, ceili(size.y / tile) + 1):
        for x in range(0, ceili(size.x / tile) + 1):
            var origin := Vector2(float(x), float(y)) * tile
            var shade: float = 0.92 + 0.08 * sin(float(x * 7 + y * 11))
            draw_rect(Rect2(origin, Vector2(tile - 2, tile - 2)), Color(0.22 * shade, 0.24 * shade, 0.23 * shade))

    # Fallen beams and shattered masonry form a visible route through the gallery court.
    var w: float = size.x
    var h: float = size.y
    for i in range(7):
        var px: float = w * (0.28 + float(i % 3) * 0.19)
        var py: float = h * (0.25 + float(i / 3) * 0.22)
        draw_rect(Rect2(Vector2(px, py), Vector2(48, 12)), Color("#55463a"), true)
        draw_rect(Rect2(Vector2(px + 6, py + 12), Vector2(26, 8)), Color("#77604a"), true)

    # Fire pockets pulse softly; they are visual hazards, not opaque navigation blockers.
    for i in range(9):
        var fx: float = w * (0.20 + float((i * 37) % 67) / 100.0)
        var fy: float = h * (0.24 + float((i * 19) % 53) / 100.0)
        var pulse: float = 0.65 + 0.35 * sin(clock * 2.2 + float(i))
        draw_circle(Vector2(fx, fy), 20.0 + pulse * 8.0, Color(0.75, 0.22, 0.07, 0.18))
        draw_colored_polygon(PackedVector2Array([Vector2(fx - 8, fy + 10), Vector2(fx + 9, fy + 10), Vector2(fx, fy - 24 - pulse * 12)]), Color(1.0, 0.48 + pulse * 0.2, 0.12, 0.82))

    # Broken arch and the open postern are the visual destination.
    draw_rect(Rect2(exit_pos + Vector2(-36, -28), Vector2(72, 56)), Color("#6e6657"), true)
    draw_rect(Rect2(exit_pos + Vector2(-23, -17), Vector2(46, 45)), Color("#101719"), true)
    draw_circle(exit_pos, 9.0, Color("#e3c17c"))
    draw_line(player_pos, exit_pos, Color(0.85, 0.73, 0.48, 0.28), 2.0)

    # The four companions move as a tight travelling knot around the protagonist.
    draw_circle(player_pos + Vector2(-26, 8), 13.0, Color("#9b6047"))
    draw_circle(player_pos + Vector2(24, 10), 12.0, Color("#7297a1"))
    draw_circle(player_pos + Vector2(0, 25), 11.0, Color("#b3a16e"))
    draw_circle(player_pos, 15.0, Color("#e3c17c"))
    draw_circle(player_pos + Vector2(-4, -4), 5.0, Color("#f7e8c7"))
    draw_string(ThemeDB.fallback_font, player_pos + Vector2(-38, -24), "YOUR COMPANY", HORIZONTAL_ALIGNMENT_LEFT, 150, 12, Color("#f5e5c2"))
    draw_string(ThemeDB.fallback_font, exit_pos + Vector2(-54, -40), "POSTERN GATE", HORIZONTAL_ALIGNMENT_LEFT, 140, 13, Color("#f0d49a"))


func _launch_battle() -> void:
    if started:
        return
    var battle: Dictionary = EscapeMissionScript.build_battle(GameData.battle_def("battle_01"))
    if battle.is_empty():
        story_label.text = "The courtyard encounter could not be prepared. Your chronicle is safe; return to the title and try again."
        return
    started = true
    GameState.world_flags["escape_started"] = true
    GameState.from_world = true
    GameState.world_pos = Vector2.ZERO
    GameState.save_campaign("auto_a")
    GameState.start_battle_from_world(battle)
    get_tree().change_scene_to_file("res://Main.tscn")
