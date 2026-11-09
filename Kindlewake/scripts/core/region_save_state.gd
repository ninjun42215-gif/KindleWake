class_name RegionSaveState
extends RefCounted
## Pure, dependency-free normalization for campaign region coordinates and legacy saves.

static func from_payload(payload: Dictionary) -> Dictionary:
    var raw_pos: Array = payload.get("world_pos", [0.0, 0.0])
    var pos := Vector2.ZERO
    if raw_pos.size() >= 2:
        pos = Vector2(float(raw_pos[0]), float(raw_pos[1]))
    var region_id: String = str(payload.get("active_region_id", "sethmarch"))
    var positions: Dictionary = (payload.get("world_positions", {}) as Dictionary).duplicate(true)
    if not positions.has("sethmarch"):
        positions["sethmarch"] = [pos.x, pos.y] if region_id == "sethmarch" else [0.0, 0.0]
    if region_id != "sethmarch" and not positions.has(region_id):
        positions[region_id] = [pos.x, pos.y]
    return {"active_region_id": region_id, "world_positions": positions, "world_pos": pos}
