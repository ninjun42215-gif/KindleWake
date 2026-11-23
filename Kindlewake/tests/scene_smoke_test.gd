extends SceneTree

const AtlasLayoutScript = preload("res://scripts/ui/atlas_layout.gd")
const AtlasCartographyLayerScript = preload("res://scripts/ui/atlas_cartography_layer.gd")
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
    _test_atlas_cartography()
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


func _test_atlas_cartography() -> void:
    print("[atlas cartography]")
    var view_sizes: Array[Vector2] = [Vector2(1280, 720), Vector2(720, 1280), Vector2(360, 640)]
    var geometry_ok := true
    for view_size in view_sizes:
        var rect: Rect2 = AtlasLayoutScript.map_rect_for_size(view_size)
        var center: Vector2 = AtlasCartographyLayerScript.compass_center_for(view_size)
        var radius: float = AtlasCartographyLayerScript.compass_radius_for(view_size)
        if rect.size.x <= 0.0 or rect.size.y <= 0.0:
            geometry_ok = false
        if center.x - radius < rect.position.x or center.y - radius < rect.position.y:
            geometry_ok = false
        if center.x + radius > rect.end.x or center.y + radius > rect.end.y:
            geometry_ok = false
    if not geometry_ok:
        failures += 1
        push_error("Atlas compass geometry escaped the map frame in a supported viewport")
    else:
        print("  ok    atlas compass stays inside portrait, landscape and compact map frames")

    var packed := load("res://GlobalAtlas.tscn") as PackedScene
    var scene_ok := packed != null
    if scene_ok:
        var root := packed.instantiate()
        var layer := root.get_node_or_null("CartographyLayer") as Control
        scene_ok = layer != null
        if scene_ok:
            scene_ok = layer.mouse_filter == Control.MOUSE_FILTER_IGNORE and layer.z_index > 1
        root.free()
    if not scene_ok:
        failures += 1
        push_error("GlobalAtlas cartography layer is missing or can intercept map input")
    else:
        print("  ok    atlas cartography layer is present and input-transparent")
