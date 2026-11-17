extends SceneTree
## Focused regression coverage for equipment icon category selection and atlas bounds.

const EquipmentIconAtlas = preload("res://scripts/ui/equipment_icon_atlas.gd")

var failures := 0


func _initialize() -> void:
    call_deferred("_run")


func _check(condition: bool, label: String) -> void:
    if condition:
        print("  ok    " + label)
    else:
        failures += 1
        push_error("FAIL: " + label)


func _run() -> void:
    var cases: Array = [
        ["arming_sword", {"slot":"weapon", "weapon_id":"arming_sword"}, "sword"],
        ["rare_longsword", {"slot":"weapon", "weapon_id":"rare_longsword"}, "sword"],
        ["greatsword", {"slot":"weapon", "weapon_id":"greatsword"}, "greatsword"],
        ["hunting_bow", {"slot":"weapon", "weapon_id":"hunting_bow"}, "bow"],
        ["short_bow", {"slot":"weapon", "weapon_id":"short_bow"}, "bow"],
        ["crossbow", {"slot":"weapon", "weapon_id":"crossbow"}, "crossbow"],
        ["battle_axe", {"slot":"weapon", "weapon_id":"battle_axe"}, "axe"],
        ["spear", {"slot":"weapon", "weapon_id":"spear"}, "spear"],
        ["mace", {"slot":"weapon", "weapon_id":"mace"}, "mace"],
        ["staff", {"slot":"weapon", "weapon_id":"staff"}, "staff"],
        ["dagger", {"slot":"weapon", "weapon_id":"dagger"}, "dagger"],
        ["unique_kingbreaker", {"slot":"weapon", "weapon_id":"unique_kingbreaker"}, "greatsword"],
        ["plate_harness", {"slot":"armor"}, "armor"],
        ["kite_shield", {"slot":"offhand"}, "shield"],
        ["iron_cap", {"slot":"helm"}, "helm"],
        ["pilgrim_medal", {"slot":"accessory"}, "accessory"],
        ["trade_grain", {"slot":"trade_good", "trade_good":true}, "trade_good"],
        ["healing_draught", {"slot":"consumable"}, "consumable"]
    ]
    for entry in cases:
        var item_id := str(entry[0])
        var definition: Dictionary = entry[1]
        var expected := str(entry[2])
        _check(EquipmentIconAtlas.category_for_item(item_id, definition) == expected,
            "%s resolves to %s" % [item_id, expected])

    _check(EquipmentIconAtlas.category_for_slot("accessory2") == "accessory",
        "accessory slots share the accessory icon")
    _check(EquipmentIconAtlas.category_for_slot("unknown_slot") == "unknown",
        "unrecognized slots use the neutral fallback icon")

    var icon := EquipmentIconAtlas.icon_for_item("iron_cap", {"slot":"helm"}, 48)
    _check(icon.texture is AtlasTexture, "runtime icon is an AtlasTexture region")
    if icon.texture is AtlasTexture:
        var region := icon.texture as AtlasTexture
        _check(region.atlas != null, "atlas texture preloads successfully")
        _check(region.region == Rect2(192, 128, 64, 64), "helm region uses the expected 64px cell")
    _check(icon.custom_minimum_size == Vector2(48, 48), "icon respects the requested mobile size")
    icon.free()

    var slot_icon := EquipmentIconAtlas.icon_for_slot("offhand", 42)
    _check(slot_icon.texture is AtlasTexture, "empty equipment slots still show a category icon")
    slot_icon.free()

    print("Equipment icon atlas failures: %d" % failures)
    quit(1 if failures > 0 else 0)
