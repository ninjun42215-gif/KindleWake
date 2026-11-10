extends Node
## Kindlewake global presentation and feedback layer. Register as autoload "KW".

const SETTINGS_PATH := "user://settings.cfg"
const INK := Color("#101820")
const INK_RAISED := Color("#1b2b35")
const INK_DEEP := Color("#0b141a")
const BRASS := Color("#b9955e")
const BRASS_LIGHT := Color("#e4c991")
const PARCHMENT := Color("#f0e5ce")
const MUTED := Color("#aeb8b4")
const FONT_BODY := "res://assets/fonts/body.ttf"
const FONT_TITLE := "res://assets/fonts/title.ttf"
const SFX_DIR := "res://assets/audio/sfx/"
const MUSIC_DIR := "res://assets/audio/music/"

var reduce_motion: bool = false
var haptics: bool = true
var sfx_enabled: bool = true
var title_font: Font
var _fade_layer: CanvasLayer
var _fade_rect: ColorRect
var _busy: bool = false
var _music: AudioStreamPlayer
var _music_id: String = ""
var _sfx_cache: Dictionary = {}


func _ready() -> void:
    process_mode = Node.PROCESS_MODE_ALWAYS
    _load_preferences()
    get_tree().root.theme = _build_theme()
    get_tree().node_added.connect(_on_node_added)
    _build_fade()
    _music = AudioStreamPlayer.new()
    _music.bus = "Master"
    add_child(_music)


func _load_preferences() -> void:
    var cfg := ConfigFile.new()
    cfg.load(SETTINGS_PATH)
    haptics = bool(cfg.get_value("accessibility", "haptics", true))
    reduce_motion = bool(cfg.get_value("accessibility", "reduce_motion", false))
    sfx_enabled = bool(cfg.get_value("audio", "sfx_enabled", true))


func _save_preference(section: String, key: String, value: Variant) -> void:
    var cfg := ConfigFile.new()
    cfg.load(SETTINGS_PATH)
    cfg.set_value(section, key, value)
    cfg.save(SETTINGS_PATH)


func set_haptics_enabled(value: bool) -> void:
    haptics = value
    _save_preference("accessibility", "haptics", value)


func set_reduce_motion_enabled(value: bool) -> void:
    reduce_motion = value
    _save_preference("accessibility", "reduce_motion", value)


func set_sfx_enabled(value: bool) -> void:
    sfx_enabled = value
    _save_preference("audio", "sfx_enabled", value)


func _box(bg: Color, border: Color, width: int = 2, radius: int = 10, margin: int = 10) -> StyleBoxFlat:
    var style := StyleBoxFlat.new()
    style.bg_color = bg
    style.border_color = border
    style.set_border_width_all(width)
    style.set_corner_radius_all(radius)
    style.set_content_margin_all(margin)
    return style


func _build_theme() -> Theme:
    var theme := Theme.new()
    if ResourceLoader.exists(FONT_BODY):
        theme.default_font = load(FONT_BODY) as Font
    if ResourceLoader.exists(FONT_TITLE):
        title_font = load(FONT_TITLE) as Font
    theme.default_font_size = 18
    for type_name in ["Button", "OptionButton", "MenuButton", "CheckButton"]:
        theme.set_stylebox("normal", type_name, _box(INK_RAISED, BRASS))
        theme.set_stylebox("hover", type_name, _box(Color("#29404a"), BRASS_LIGHT))
        theme.set_stylebox("pressed", type_name, _box(INK_DEEP, BRASS_LIGHT))
        theme.set_stylebox("focus", type_name, _box(Color(0, 0, 0, 0), BRASS_LIGHT, 3))
        theme.set_stylebox("disabled", type_name, _box(Color("#172129"), Color("#59646a")))
        theme.set_color("font_color", type_name, PARCHMENT)
        theme.set_color("font_hover_color", type_name, Color("#fff4dc"))
        theme.set_color("font_pressed_color", type_name, BRASS_LIGHT)
        theme.set_color("font_disabled_color", type_name, MUTED)
    theme.set_stylebox("panel", "Panel", _box(INK, BRASS))
    theme.set_stylebox("panel", "PanelContainer", _box(INK, BRASS))
    theme.set_stylebox("normal", "LineEdit", _box(INK_DEEP, Color("#596873"), 2, 8, 10))
    theme.set_stylebox("focus", "LineEdit", _box(INK_DEEP, BRASS_LIGHT, 2, 8, 10))
    theme.set_color("font_color", "LineEdit", PARCHMENT)
    theme.set_color("caret_color", "LineEdit", BRASS_LIGHT)
    theme.set_stylebox("panel", "PopupMenu", _box(INK, BRASS, 2, 10, 8))
    theme.set_stylebox("hover", "PopupMenu", _box(Color("#29404a"), BRASS_LIGHT, 1, 6, 6))
    theme.set_color("font_color", "PopupMenu", PARCHMENT)
    theme.set_stylebox("background", "ProgressBar", _box(INK_DEEP, Color("#3a4650"), 1, 6, 0))
    theme.set_stylebox("fill", "ProgressBar", _box(BRASS, BRASS_LIGHT, 0, 6, 0))
    for slider in ["HSlider", "VSlider"]:
        theme.set_stylebox("slider", slider, _box(INK_DEEP, Color("#3a4650"), 1, 6, 0))
        theme.set_stylebox("grabber_area", slider, _box(BRASS, BRASS, 0, 6, 0))
        theme.set_stylebox("grabber_area_highlight", slider, _box(BRASS_LIGHT, BRASS_LIGHT, 0, 6, 0))
    for bar in ["VScrollBar", "HScrollBar"]:
        theme.set_stylebox("scroll", bar, _box(Color(0, 0, 0, 0.25), Color(0, 0, 0, 0), 0, 6, 0))
        theme.set_stylebox("grabber", bar, _box(Color(BRASS.r, BRASS.g, BRASS.b, 0.75), Color(0, 0, 0, 0), 0, 6, 0))
        theme.set_stylebox("grabber_highlight", bar, _box(BRASS_LIGHT, Color(0, 0, 0, 0), 0, 6, 0))
        theme.set_stylebox("grabber_pressed", bar, _box(BRASS_LIGHT, Color(0, 0, 0, 0), 0, 6, 0))
    return theme


func style_title(label: Label, size: int = 32) -> void:
    if title_font != null:
        label.add_theme_font_override("font", title_font)
    label.add_theme_font_size_override("font_size", size)
    label.add_theme_color_override("font_color", BRASS_LIGHT)
    label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.7))
    label.add_theme_constant_override("outline_size", 4)


func _on_node_added(node: Node) -> void:
    if node is BaseButton and not node.has_meta("kw_no_fx"):
        var button := node as BaseButton
        if not button.button_down.is_connected(_on_button_down.bind(button)):
            button.button_down.connect(_on_button_down.bind(button))
        if not button.button_up.is_connected(_on_button_up.bind(button)):
            button.button_up.connect(_on_button_up.bind(button))


func _on_button_down(button: BaseButton) -> void:
    if not is_instance_valid(button) or button.disabled:
        return
    button.pivot_offset = button.size * 0.5
    if not reduce_motion:
        if button.has_meta("kw_press_tween"):
            var old_tween: Tween = button.get_meta("kw_press_tween")
            if old_tween.is_running():
                old_tween.kill()
        var tween := button.create_tween()
        button.set_meta("kw_press_tween", tween)
        tween.tween_property(button, "scale", Vector2(0.96, 0.96), 0.06)
    buzz(12)
    sfx("ui_tap")


func _on_button_up(button: BaseButton) -> void:
    if not is_instance_valid(button):
        return
    if not reduce_motion:
        if button.has_meta("kw_press_tween"):
            var old_tween: Tween = button.get_meta("kw_press_tween")
            if old_tween.is_running():
                old_tween.kill()
        var tween := button.create_tween()
        button.set_meta("kw_press_tween", tween)
        tween.tween_property(button, "scale", Vector2.ONE, 0.10).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
    else:
        button.scale = Vector2.ONE


func buzz(milliseconds: int = 15) -> void:
    if haptics and OS.has_feature("mobile"):
        Input.vibrate_handheld(milliseconds)


func sfx(sound_id: String, volume_db: float = -4.0) -> void:
    if not sfx_enabled:
        return
    if not _sfx_cache.has(sound_id):
        var path := SFX_DIR + sound_id + ".ogg"
        if not ResourceLoader.exists(path):
            return
        _sfx_cache[sound_id] = load(path)
    var player := AudioStreamPlayer.new()
    player.stream = _sfx_cache[sound_id] as AudioStream
    player.volume_db = volume_db
    add_child(player)
    player.finished.connect(player.queue_free)
    player.play()


func music(track_id: String, fade: float = 0.8) -> void:
    if track_id == _music_id:
        return
    var path := MUSIC_DIR + track_id + ".ogg"
    if not ResourceLoader.exists(path):
        return
    var stream := load(path) as AudioStream
    if stream == null:
        return
    for property in stream.get_property_list():
        if str(property.get("name", "")) == "loop":
            stream.set("loop", true)
            break
    _music_id = track_id
    var tween := create_tween()
    if _music.playing:
        tween.tween_property(_music, "volume_db", -40.0, fade * 0.5)
    tween.tween_callback(func() -> void:
        _music.stream = stream
        _music.volume_db = -40.0
        _music.play()
    )
    tween.tween_property(_music, "volume_db", -8.0, fade)


func _build_fade() -> void:
    _fade_layer = CanvasLayer.new()
    _fade_layer.layer = 128
    add_child(_fade_layer)
    _fade_rect = ColorRect.new()
    _fade_rect.color = Color(0.03, 0.05, 0.07, 0.0)
    _fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
    _fade_rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    _fade_layer.add_child(_fade_rect)


func goto(path: String, duration: float = 0.22) -> void:
    if _busy or not ResourceLoader.exists(path):
        return
    _busy = true
    var time := 0.0 if reduce_motion else maxf(duration, 0.0)
    _fade_rect.mouse_filter = Control.MOUSE_FILTER_STOP
    var fade_out := create_tween()
    fade_out.tween_property(_fade_rect, "color:a", 1.0, time)
    await fade_out.finished
    var error := get_tree().change_scene_to_file(path)
    if error != OK:
        var fade_back := create_tween()
        fade_back.tween_property(_fade_rect, "color:a", 0.0, time)
        await fade_back.finished
        _fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
        _busy = false
        return
    await get_tree().process_frame
    await get_tree().process_frame
    var fade_in := create_tween()
    fade_in.tween_property(_fade_rect, "color:a", 0.0, time)
    await fade_in.finished
    _fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
    _busy = false
