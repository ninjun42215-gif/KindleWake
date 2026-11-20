extends RefCounted
## Stable regional tint and location-seeded tile variation for local architecture.
## Palette entries cover all 31 named regions; only authored local maps are assigned below.

const LOCATION_REGION_ROOTS := [
    "elderbough_watch",
    "redwater_granary",
    "sallow_keep_hall",
    "sallow_keep_barracks",
    "sallow_ford_keep",
    "morrowtide_exchange",
    "veyhaven_beacon",
    "quillon_archive",
    "crossing",
    "sethorn",
    "thornmere",
    "foxglove",
    "elderbough",
    "cindermead",
    "redwater",
    "milefort",
    "tarnholt",
    "aurelmont",
    "brinegate",
    "saltmere",
    "lantern_quay"
]

const LOCATION_REGION_IDS := {
    "elderbough_watch": "orrowen_weald",
    "redwater_granary": "vessmoor_plains",
    "sallow_keep_hall": "sethmarch",
    "sallow_keep_barracks": "sethmarch",
    "sallow_ford_keep": "sethmarch",
    "morrowtide_exchange": "kelpward",
    "veyhaven_beacon": "isles_of_vey",
    "quillon_archive": "quillon_heights",
    "crossing": "sethmarch",
    "sethorn": "sethmarch",
    "thornmere": "orrowen_weald",
    "foxglove": "orrowen_weald",
    "elderbough": "orrowen_weald",
    "cindermead": "vessmoor_plains",
    "redwater": "vessmoor_plains",
    "milefort": "vessmoor_plains",
    "tarnholt": "tarnholt_cloisters",
    "aurelmont": "aurelmont",
    "brinegate": "brinegate_coast",
    "saltmere": "brinegate_coast",
    "lantern_quay": "brinegate_coast"
}

const REGION_TINTS := {
    # Eldrimar — warm marches, forest halls, plains, heights and royal stone.
    "sethmarch": Color(1.0, 0.96, 0.88, 1.0),
    "orrowen_weald": Color(0.91, 0.98, 0.86, 1.0),
    "vessmoor_plains": Color(1.0, 0.93, 0.79, 1.0),
    "quillon_heights": Color(0.91, 0.96, 1.0, 1.0),
    "tarnholt_cloisters": Color(0.96, 0.95, 0.89, 1.0),
    "brennhallow_highlands": Color(0.86, 0.92, 0.99, 1.0),
    "aurelmont": Color(1.0, 0.97, 0.87, 1.0),
    # Thalassar — salt ports, storm islands, kelp markets and black currents.
    "brinegate_coast": Color(0.86, 0.96, 1.0, 1.0),
    "isles_of_vey": Color(0.88, 0.93, 1.0, 1.0),
    "kelpward": Color(0.86, 0.98, 0.92, 1.0),
    "deepwake_reach": Color(0.86, 0.91, 0.98, 1.0),
    # Varakhan — red dunes, open steppe, volcanic glass and salt cliffs.
    "serekh_desert": Color(1.0, 0.91, 0.75, 1.0),
    "kharad_steppe": Color(1.0, 0.95, 0.82, 1.0),
    "obsidian_crown": Color(0.93, 0.84, 0.80, 1.0),
    "glasswind_coast": Color(1.0, 0.93, 0.82, 1.0),
    # Nhalor — tundra, aurora ice, old stone and fjord settlements.
    "skeld_tundra": Color(0.86, 0.94, 1.0, 1.0),
    "aurora_reach": Color(0.88, 0.94, 1.0, 1.0),
    "old_nhal": Color(0.90, 0.92, 0.95, 1.0),
    "frostcairn_coast": Color(0.86, 0.93, 1.0, 1.0),
    # Veyrwood — canopy, fen, lakes and ancient root valleys.
    "thorncrown": Color(0.88, 0.98, 0.84, 1.0),
    "mossglass_fen": Color(0.85, 0.96, 0.89, 1.0),
    "wildmere": Color(0.92, 0.98, 0.86, 1.0),
    "crownroot_basin": Color(0.87, 0.97, 0.83, 1.0),
    # Asterreach — wind ports, foundries, storm shelves and sky towers.
    "meridian_coast": Color(0.90, 0.96, 1.0, 1.0),
    "ironvale": Color(0.98, 0.92, 0.81, 1.0),
    "stormbreak": Color(0.87, 0.94, 1.0, 1.0),
    "nine_spires": Color(0.90, 0.94, 1.0, 1.0),
    # Ilyr — blue fjords, aurora shelf, long night and celestial meridian.
    "blueglass_fjord": Color(0.86, 0.93, 1.0, 1.0),
    "aurora_shelf": Color(0.88, 0.95, 1.0, 1.0),
    "long_night": Color(0.90, 0.92, 1.0, 1.0),
    "sevenfold_meridian": Color(0.95, 0.94, 1.0, 1.0)
}


static func region_for_location(location_id: String) -> String:
    var normalized := location_id.strip_edges().to_lower()
    for root in LOCATION_REGION_ROOTS:
        var root_id := str(root)
        if normalized == root_id or normalized.begins_with(root_id + "_"):
            return str(LOCATION_REGION_IDS.get(root_id, ""))
    return ""


static func tint_for_location(location_id: String) -> Color:
    var region_id := region_for_location(location_id)
    var tint: Color = REGION_TINTS.get(region_id, Color.WHITE)
    return tint


static func seed_for_location(location_id: String) -> int:
    var normalized := location_id.strip_edges().to_lower()
    var value := 17
    for index in range(normalized.length()):
        value = int((value * 31 + normalized.unicode_at(index)) % 2147483647)
    return maxi(value, 1)


static func variant_for_cell(location_seed: int, cell: Vector2i, salt: int = 17) -> float:
    var mixed := (location_seed + cell.x * 73856093 + cell.y * 19349663 + salt * 83492791) % 2147483647
    if mixed < 0:
        mixed += 2147483647
    return float(mixed) / 2147483647.0
