extends SceneTree
## Regression coverage for optional appearance data in persisted character sheets.
## Run with: godot --headless --path . --script res://tests/test_character_sheet_persistence.gd

const CharacterSheetScript = preload("res://scripts/core/character_sheet.gd")
const PartyStateScript = preload("res://scripts/core/party_state.gd")

var checks: int = 0
var failures: int = 0


func _initialize() -> void:
    var expected_appearance := {"portrait_id": "torren", "palette": "dunmarrow"}
    var valid_sheet = CharacterSheetScript.from_dict({
        "character_id": "torren",
        "appearance": expected_appearance
    })
    check(valid_sheet.appearance == expected_appearance,
        "valid saved appearance dictionaries are preserved")

    var array_sheet = CharacterSheetScript.from_dict({
        "character_id": "torren",
        "appearance": ["portrait_id", "torren"]
    })
    check(array_sheet.appearance.is_empty(),
        "malformed Array appearance falls back safely without aborting restoration")

    var string_sheet = CharacterSheetScript.from_dict({
        "character_id": "torren",
        "appearance": "invalid appearance payload"
    })
    check(string_sheet.appearance.is_empty(),
        "malformed String appearance falls back safely")

    var legacy_sheet = CharacterSheetScript.from_dict({"character_id": "legacy"})
    check(legacy_sheet.appearance.is_empty(),
        "legacy saves without appearance retain the existing empty default")

    var restored_party = PartyStateScript.from_dict({
        "roster": ["torren"],
        "sheets": {
            "torren": {
                "character_id": "torren",
                "name": "Torren",
                "class_id": "swordsman",
                "level": 1,
                "appearance": []
            }
        },
        "inventory": {},
        "gold": 0,
        "sigil_inv": []
    })
    var restored_sheet = restored_party.sheet("torren")
    check(restored_sheet != null,
        "party restoration retains the member when optional appearance data is malformed")
    check(restored_sheet != null and restored_sheet.appearance.is_empty(),
        "party restoration sanitizes malformed appearance to the legacy default")
    check(restored_sheet != null and restored_sheet.display_name == "Torren",
        "non-cosmetic character identity remains intact after appearance fallback")

    print("Character sheet persistence checks: %d   Failures: %d" % [checks, failures])
    quit(1 if failures > 0 else 0)


func check(condition: bool, label: String) -> void:
    checks += 1
    if condition:
        print("  ok  " + label)
    else:
        failures += 1
        push_error("FAIL: " + label)
