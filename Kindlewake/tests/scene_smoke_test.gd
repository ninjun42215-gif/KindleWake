extends SceneTree
## Loads every authored .tscn resource without starting gameplay.
## Run after the editor import pass: godot --headless --path . --script res://tests/scene_smoke_test.gd

var failures: int = 0
var scene_paths: Array[String] = []


func _initialize() -> void:
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
