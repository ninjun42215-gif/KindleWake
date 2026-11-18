extends RefCounted
## Shared portrait resolver. Raster artwork takes priority while legacy SVGs remain compatible.

const PORTRAIT_DIR := "res://assets/art/portraits/"
const EXTENSIONS: Array[String] = [".png", ".webp", ".jpg", ".svg"]
const CHARACTER_RASTER_OVERRIDES := {
    "sela": "auburn_ranger",
    "kestrel": "kestrel"
}


static func resolve_path(portrait_id: String) -> String:
    var normalized_id: String = portrait_id.strip_edges()
    if normalized_id.is_empty():
        return ""
    for extension: String in EXTENSIONS:
        var path: String = PORTRAIT_DIR + normalized_id + extension
        if ResourceLoader.exists(path):
            return path
    return ""


static func load_texture(portrait_id: String) -> Texture2D:
    var path := resolve_path(portrait_id)
    if path.is_empty():
        return null
    return load(path) as Texture2D


## Resolve raster art only when it is explicitly assigned to this character.
## Shared legacy IDs continue to use their SVG so one character's face cannot
## accidentally appear on unrelated recruits, enemies, or NPCs.
static func resolve_character_path(portrait_id: String, character_id: String) -> String:
    var normalized_portrait_id: String = portrait_id.strip_edges()
    var normalized_character_id: String = character_id.strip_edges()
    var raster_id: String = ""
    if normalized_character_id == "torren":
        raster_id = normalized_portrait_id if not normalized_portrait_id.is_empty() else "torren_redcloak"
    else:
        raster_id = str(CHARACTER_RASTER_OVERRIDES.get(normalized_character_id, ""))
    if raster_id.is_empty() and normalized_character_id == normalized_portrait_id:
        raster_id = normalized_character_id
    if not raster_id.is_empty():
        var raster_path := resolve_path(raster_id)
        if not raster_path.is_empty() and not raster_path.ends_with(".svg"):
            return raster_path

    # Prefer an original portrait authored for this exact character before
    # falling back to a legacy ID that may be shared by several characters.
    if not normalized_character_id.is_empty():
        var character_svg_path := PORTRAIT_DIR + normalized_character_id + ".svg"
        if ResourceLoader.exists(character_svg_path):
            return character_svg_path

    if normalized_portrait_id.is_empty():
        return ""
    var legacy_svg_path := PORTRAIT_DIR + normalized_portrait_id + ".svg"
    if ResourceLoader.exists(legacy_svg_path):
        return legacy_svg_path
    return ""


static func load_character_texture(portrait_id: String, character_id: String) -> Texture2D:
    var path := resolve_character_path(portrait_id, character_id)
    if path.is_empty():
        return null
    return load(path) as Texture2D
