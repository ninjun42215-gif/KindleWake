extends SceneTree
## Loads every authored .tscn resource without starting gameplay.
## Run after the editor import pass: godot --headless --path . --script res://tests/scene_smoke_test.gd

var failures: int = 0
var scene_paths: Array[String] = []


func _initialize() -> void:
    var kw_script: Script = load("res://scripts/core/kw.gd") as Script
    if kw_script == null:
        failures += 1
        push_error("Could not parse the KW premium UX autoload script")
    else:
        print("  ok    premium UX autoload script parses")
        _test_audio_feedback(kw_script)
    _collect_scenes("res://")
    scene_paths.sort()
    print("[scene smoke] Loading %d scenes" % scene_paths.size())
    for scene_path in scene_paths:
        var packed: Resource = load(scene_path)
        if packed is PackedScene:
            print("  ok    " + scene_path)
        else:
            failures += 1
            push_error("Could not load scene: " + scene_path)
    print("Scene smoke: %d loaded, %d failures" % [scene_paths.size() - failures, failures])
    quit(0 if failures == 0 else 1)


func _test_audio_feedback(kw_script: Script) -> void:
    print("[UI audio feedback]")
    var kw_instance: Node = kw_script.new() as Node
    if kw_instance == null:
        failures += 1
        push_error("Could not instantiate the KW audio resolver")
        return
    var sound_ids: Array[String] = ["ui_tap", "ui_confirm", "ui_back", "ui_toggle"]
    for sound_id in sound_ids:
        var stream := kw_instance.call("_load_sfx_stream", sound_id) as AudioStreamWAV
        if stream == null:
            failures += 1
            push_error("Could not load original UI cue: " + sound_id)
            continue
        var duration := stream.get_length()
        var valid := stream.mix_rate == 24000 and not stream.stereo and stream.data.size() > 0 and duration >= 0.05 and duration <= 0.30
        if valid:
            print("  ok    %s: 24 kHz mono WAV, %.3f s, %d bytes PCM" % [sound_id, duration, stream.data.size()])
        else:
            failures += 1
            push_error("UI cue format/duration budget failed: " + sound_id)
    var back_button := Button.new()
    back_button.text = "BACK"
    var primary_button := Button.new()
    primary_button.text = "NEW GAME"
    var toggle_button := CheckButton.new()
    if str(kw_instance.call("_button_sfx_id", back_button)) == "ui_back":
        print("  ok    navigation buttons resolve to the back cue")
    else:
        failures += 1
        push_error("Back-button sound mapping failed")
    if str(kw_instance.call("_button_sfx_id", primary_button)) == "ui_confirm":
        print("  ok    primary actions resolve to the confirm cue")
    else:
        failures += 1
        push_error("Confirm-button sound mapping failed")
    if str(kw_instance.call("_button_sfx_id", toggle_button)) == "ui_toggle":
        print("  ok    settings toggles resolve to the toggle cue")
    else:
        failures += 1
        push_error("Toggle sound mapping failed")
    kw_instance.free()


func _collect_scenes(directory_path: String) -> void:
    var directory := DirAccess.open(directory_path)
    if directory == null:
        push_warning("Could not scan directory: " + directory_path)
        return
    directory.list_dir_begin()
    var entry := directory.get_next()
    while entry != "":
        if entry != "." and entry != ".." and not entry.begins_with("."):
            var child_path: String = directory_path.path_join(entry)
            if directory.current_is_dir():
                if entry not in ["dist", "build", "export"]:
                    _collect_scenes(child_path)
            elif entry.ends_with(".tscn"):
                scene_paths.append(child_path)
        entry = directory.get_next()
    directory.list_dir_end()
