extends RefCounted
## Shared portrait resolver. Raster artwork takes priority while legacy SVGs remain compatible.

const PORTRAIT_DIR := "res://assets/art/portraits/"
const EXTENSIONS := [".png", ".webp", ".jpg", ".svg"]


static func resolve_path(portrait_id: String) -> String:
    var normalized_id := portrait_id.strip_edges()
    if normalized_id.is_empty():
        return ""
    for extension in EXTENSIONS:
        var path := PORTRAIT_DIR + normalized_id + extension
        if ResourceLoader.exists(path):
            return path
    return ""


static func load_texture(portrait_id: String) -> Texture2D:
    var path := resolve_path(portrait_id)
    if path.is_empty():
        return null
    return load(path) as Texture2D
