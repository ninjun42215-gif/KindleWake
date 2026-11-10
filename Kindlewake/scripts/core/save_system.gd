extends Node
## Local save system (autoload "SaveSystem").
## - Slots: "1", "2", "3" (manual), "auto_a"/"auto_b" (rotating autosave), "quick".
## - File = JSON envelope { meta, payload (a JSON *string*), checksum (SHA-256 of that string) }.
##   Storing the payload as a string keeps the checksum stable across JSON number round-trips.
## - Atomic write: write .tmp -> verify -> keep old file as .bak -> rename into place.
## - Load falls back to the .bak file if the main file is missing or corrupt.
## - Versioning: save_version + migrate() hook for future formats.

signal app_paused

const SAVE_DIR := "user://saves/"
const SAVE_VERSION := 4
const GAME_VERSION := "0.12.0"
const AUTOSAVE_SLOTS := ["auto_a", "auto_b"]
const RegionSaveState = preload("res://scripts/core/region_save_state.gd")


func slot_path(slot_id: String) -> String:
    return SAVE_DIR + "slot_" + slot_id + ".save"


func checksum_of(text: String) -> String:
    var ctx := HashingContext.new()
    ctx.start(HashingContext.HASH_SHA256)
    ctx.update(text.to_utf8_buffer())
    return ctx.finish().hex_encode()


func save_slot(slot_id: String, payload: Dictionary, summary: String = "") -> bool:
    DirAccess.make_dir_recursive_absolute(SAVE_DIR)
    var payload_text: String = JSON.stringify(payload)
    var envelope: Dictionary = {
        "meta": {
            "save_version": SAVE_VERSION,
            "game_version": GAME_VERSION,
            "saved_at": Time.get_datetime_string_from_system(),
            "unix": Time.get_unix_time_from_system(),
            "summary": summary,
        },
        "payload": payload_text,
        "checksum": checksum_of(payload_text),
    }
    var final_path: String = slot_path(slot_id)
    var tmp_path: String = final_path + ".tmp"
    var bak_path: String = final_path + ".bak"
    var file := FileAccess.open(tmp_path, FileAccess.WRITE)
    if file == null:
        push_error("SaveSystem: cannot write " + tmp_path)
        return false
    file.store_string(JSON.stringify(envelope))
    file.close()
    if _read_envelope(tmp_path).is_empty():
        DirAccess.remove_absolute(tmp_path)
        push_error("SaveSystem: verification of the temporary save failed")
        return false
    if FileAccess.file_exists(final_path):
        DirAccess.copy_absolute(final_path, bak_path)
        DirAccess.remove_absolute(final_path)
    var err: int = DirAccess.rename_absolute(tmp_path, final_path)
    if err != OK:
        push_error("SaveSystem: rename failed (" + str(err) + ")")
        return false
    return true


## Returns {"ok": bool, "payload": Dictionary, "meta": Dictionary, "from_backup": bool, "error": String}
func load_slot(slot_id: String) -> Dictionary:
    var path: String = slot_path(slot_id)
    var primary_env: Dictionary = _read_envelope(path)
    if not primary_env.is_empty():
        var primary_result: Dictionary = _decode_envelope(primary_env)
        if bool(primary_result.get("ok", false)):
            primary_result["from_backup"] = false
            return primary_result
        # A newer-version save must never be silently replaced by an older backup.
        if str(primary_result.get("error", "")) == "Save was made by a newer version of the game.":
            return primary_result

    var backup_env: Dictionary = _read_envelope(path + ".bak")
    if not backup_env.is_empty():
        var backup_result: Dictionary = _decode_envelope(backup_env)
        if bool(backup_result.get("ok", false)):
            backup_result["from_backup"] = true
            return backup_result

    if primary_env.is_empty() and backup_env.is_empty():
        return {"ok": false, "error": "Save missing or corrupted."}
    if not primary_env.is_empty():
        return _decode_envelope(primary_env)
    return {"ok": false, "error": "Save missing or corrupted."}


## Decode, migrate and semantically validate before exposing persisted state to runtime systems.
func _decode_envelope(env: Dictionary) -> Dictionary:
    if typeof(env.get("meta")) != TYPE_DICTIONARY:
        return {"ok": false, "error": "Save metadata is invalid."}
    var meta: Dictionary = env["meta"]
    var version: int = int(meta.get("save_version", 1))
    if version > SAVE_VERSION:
        return {"ok": false, "error": "Save was made by a newer version of the game."}
    var parsed: Variant = JSON.parse_string(str(env.get("payload", "")))
    if typeof(parsed) != TYPE_DICTIONARY:
        return {"ok": false, "error": "Save payload is invalid."}
    var payload: Dictionary = migrate(parsed, version)
    if bool(payload.get("campaign", false)) and not RegionSaveState.is_valid_campaign_payload(payload):
        return {"ok": false, "error": "Campaign save payload is invalid."}
    return {"ok": true, "payload": payload, "meta": meta, "from_backup": false, "error": ""}


## Upgrade old payloads step by step without discarding existing campaign fields.
func migrate(payload: Dictionary, from_version: int) -> Dictionary:
    var data: Dictionary = payload
    var v: int = from_version
    while v < SAVE_VERSION:
        if v == 1:
            data = _migrate_1_to_2(data)
            v = 2
        elif v == 2:
            data = _migrate_2_to_3(data)
            v = 3
        elif v == 3:
            data = _migrate_3_to_4(data)
            v = 4
        else:
            v += 1
    return data


## v2 stores the confirmed protagonist creation choices beside the persistent party.
static func _migrate_1_to_2(payload: Dictionary) -> Dictionary:
    var data: Dictionary = payload.duplicate(true)
    if not data.has("creation_profile"):
        data["creation_profile"] = {}
    return data


## v3 adds regional campaign context without changing existing party or battle records.
static func _migrate_2_to_3(payload: Dictionary) -> Dictionary:
    var data: Dictionary = payload.duplicate(true)
    if not data.has("world_flags"):
        data["world_flags"] = {}
    if not data.has("world_pos"):
        data["world_pos"] = [0.0, 0.0]
    if not data.has("from_world"):
        data["from_world"] = false
    return data


## v4 adds per-character loyalty; old members begin at a neutral 50 without losing campaign data.
static func _migrate_3_to_4(payload: Dictionary) -> Dictionary:
    var data: Dictionary = payload.duplicate(true)
    var party: Dictionary = data.get("party", {})
    var sheets: Dictionary = party.get("sheets", {})
    for id in sheets.keys():
        var member: Dictionary = sheets[id]
        if not member.has("loyalty"):
            member["loyalty"] = 50
        sheets[id] = member
    party["sheets"] = sheets
    data["party"] = party
    return data


func slot_info(slot_id: String) -> Dictionary:
    var env: Dictionary = _read_envelope(slot_path(slot_id))
    if env.is_empty():
        env = _read_envelope(slot_path(slot_id) + ".bak")
    if env.is_empty():
        return {"exists": false, "summary": "Empty", "saved_at": "", "unix": 0.0}
    var meta: Dictionary = env["meta"]
    return {"exists": true, "summary": str(meta.get("summary", "")), "saved_at": str(meta.get("saved_at", "")), "unix": float(meta.get("unix", 0.0))}


func delete_slot(slot_id: String) -> void:
    var path: String = slot_path(slot_id)
    for suffix in ["", ".bak", ".tmp"]:
        if FileAccess.file_exists(path + str(suffix)):
            DirAccess.remove_absolute(path + str(suffix))


## Writes to whichever autosave slot is older, so a crash mid-write never destroys the newest autosave.
func autosave(payload: Dictionary, summary: String = "") -> bool:
    var older: String = AUTOSAVE_SLOTS[0]
    var older_unix: float = 1.0e18
    for slot in AUTOSAVE_SLOTS:
        var info: Dictionary = slot_info(str(slot))
        var u: float = float(info["unix"])
        if not bool(info["exists"]):
            older = str(slot)
            older_unix = -1.0
            break
        if u < older_unix:
            older_unix = u
            older = str(slot)
    return save_slot(older, payload, summary)


func _read_envelope(path: String) -> Dictionary:
    if not FileAccess.file_exists(path):
        return {}
    var file := FileAccess.open(path, FileAccess.READ)
    if file == null:
        return {}
    var parsed: Variant = JSON.parse_string(file.get_as_text())
    if typeof(parsed) != TYPE_DICTIONARY:
        return {}
    var env: Dictionary = parsed
    if not (env.has("payload") and env.has("checksum") and env.has("meta")):
        return {}
    if typeof(env.get("payload")) != TYPE_STRING or typeof(env.get("meta")) != TYPE_DICTIONARY:
        return {}
    if checksum_of(str(env["payload"])) != str(env["checksum"]):
        return {}
    return env


func _notification(what: int) -> void:
    if what == NOTIFICATION_APPLICATION_PAUSED or what == NOTIFICATION_WM_WINDOW_FOCUS_OUT:
        app_paused.emit()
