#!/usr/bin/env python3
"""Static completeness checks for the KindleWake portrait registry.

Run from the repository root:
    python3 Kindlewake/tests/test_portrait_registry.py
"""
import json
import re
import sys
from collections import Counter
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
REGISTRY_PATH = ROOT / "data" / "portrait_registry.json"
CHARACTERS_PATH = ROOT / "data" / "characters.json"
LOCATIONS_PATH = ROOT / "data" / "locations.json"
CREATOR_PATH = ROOT / "data" / "character_creation.json"
PORTRAIT_DIR = ROOT / "assets" / "art" / "portraits"


def load_json(path):
    with path.open(encoding="utf-8") as handle:
        return json.load(handle)


def main():
    registry = load_json(REGISTRY_PATH)
    characters = load_json(CHARACTERS_PATH)["characters"]
    locations = load_json(LOCATIONS_PATH)["maps"]
    creator = load_json(CREATOR_PATH)
    entities = registry["entities"]
    by_id = {entry["id"]: entry for entry in entities}
    errors = []

    if len(by_id) != len(entities):
        errors.append("Registry contains duplicate entity IDs.")

    starting_roster = {"torren", "bram", "sela", "brother_wystan"}
    wave_one_recruits = {cid for cid, definition in characters.items() if isinstance(definition.get("recruit"), dict) and int(definition["recruit"].get("wave", 0)) == 1}
    wave_two_recruits = {cid for cid, definition in characters.items() if isinstance(definition.get("recruit"), dict) and int(definition["recruit"].get("wave", 0)) == 2}
    if not starting_roster.issubset(characters):
        errors.append("One or more of the four named starting roster characters are missing.")
    if len(wave_one_recruits) != 20:
        errors.append(f"Expected 20 Wave 1 recruits in addition to four starters; found {len(wave_one_recruits)}.")
    if len(wave_two_recruits) != 2:
        errors.append(f"Expected the two authored Wave 2 recruits; found {len(wave_two_recruits)}.")

    for character_id, definition in characters.items():
        if character_id not in by_id:
            errors.append(f"Character definition missing from registry: {character_id}")
            continue
        entry = by_id[character_id]
        if entry.get("category") == "enemy":
            if entry.get("portrait_id"):
                errors.append(f"Enemy still carries a legacy hero-gallery portrait assignment: {character_id}")
        elif entry.get("portrait_id") != definition.get("portrait_id"):
            errors.append(f"Registry legacy portrait reference drift: {character_id}")

    for map_id, map_data in locations.items():
        for index, spot in enumerate(map_data.get("spots", [])):
            if not spot.get("npc"):
                continue
            slug = re.sub(r"[^a-z0-9]+", "_", str(spot.get("name") or "Unnamed NPC").lower()).strip("_")
            entity_id = f"npc.{map_id}.{index + 1}.{slug or 'unnamed'}"
            if entity_id not in by_id:
                errors.append(f"NPC dialogue spot missing from registry: {entity_id}")

    if registry.get("status") != "AUDIT_BASELINE_NOT_COMPLETE":
        errors.append("Registry status must remain explicitly incomplete until artistic QA is approved.")

    if not isinstance(registry.get("entities"), list) or not registry.get("entities"):
        errors.append("Portrait registry has no entity records.")

    for entry in entities:
        portrait_id = entry.get("portrait_id")
        if portrait_id:
            path = PORTRAIT_DIR / f"{portrait_id}.svg"
            if not path.is_file():
                errors.append(f"Portrait file missing for {entry['id']}: {path.name}")

    for appearance in creator.get("portraits", []):
        portrait_id = appearance.get("id", "")
        if not (PORTRAIT_DIR / f"{portrait_id}.svg").is_file():
            errors.append(f"Creator appearance portrait file missing: {portrait_id}")

    required_story = {"king_osric_iv", "lord_edmer", "regent_maelor"}
    if not required_story.issubset(by_id):
        errors.append("Required royal story figures are not all represented in the registry.")

    duplicate_ids = Counter(
        entry["portrait_id"] for entry in entities
        if entry.get("portrait_id") and entry.get("status") == "legacy_assignment_unverified"
    )
    print(f"Registry records: {len(entities)}")
    print(f"Character definitions: {len(characters)}")
    print(f"Creator appearances: {len(creator.get('portraits', []))}")
    print(f"Reused legacy portrait IDs: {sum(1 for n in duplicate_ids.values() if n > 1)}")
    print(f"Missing/unreviewed records: {sum(1 for e in entities if e.get('status') != 'approved')}")
    party_script = (ROOT / "scripts" / "ui" / "party_screen.gd").read_text(encoding="utf-8")
    if "character_id.hash()" in party_script or "fallback_ids" in party_script:
        errors.append("Party screen still randomly reuses unrelated portraits as a fallback.")
    if "portrait_registry" not in party_script:
        errors.append("Party screen does not receive the canonical portrait registry through its database.")
    art_script = (ROOT / "scripts" / "ui" / "art.gd").read_text(encoding="utf-8")
    if "hash(name)" in art_script or "common[posmod" in art_script:
        errors.append("NPC portrait resolver still hashes names into arbitrary profession portraits.")
    if 'return "guard"' not in art_script:
        errors.append("NPC portrait resolver has no safe authored-role fallback.")
    if "static func portrait_texture(" not in art_script or "registry.get(\"entities\", [])" not in art_script:
        errors.append("Shared portrait asset resolver is missing or bypasses the canonical registry.")
    if "static func character_portrait_texture(" not in art_script:
        errors.append("NPC dialogue portrait atlas resolver is missing.")
    enemy_entries = [entry for entry in entities if entry.get("category") == "enemy"]
    if any(entry.get("portrait_id") for entry in enemy_entries):
        errors.append("Enemy entities still borrow hero-gallery portrait IDs instead of enemy archetype portraits.")
    enemy_resolver = art_script[art_script.find("static func character_for_enemy"): ]
    if 'return "paladin"' in enemy_resolver:
        errors.append("Enemy archetype resolver still maps a boss to the hero paladin portrait.")
    party_method = party_script[party_script.find("func _portrait_texture"):party_script.find("func _class_title")]
    if "Art.portrait_texture(character_id, portrait_id, registry)" not in party_method:
        errors.append("Party screen bypasses the shared portrait resolver.")
    preview_script = (ROOT / "scripts" / "ui" / "character_preview.gd").read_text(encoding="utf-8")
    if "Art.portrait_texture(" not in preview_script:
        errors.append("Character creator preview does not use the shared portrait resolver.")
    location_script = (ROOT / "scripts" / "ui" / "location_scene.gd").read_text(encoding="utf-8")
    if "spot_portrait.texture = Art.character_portrait_texture(" not in location_script:
        errors.append("NPC dialogue panel does not display the shared archetype portrait.")
    battle_script = (ROOT / "scripts" / "ui" / "battle_scene.gd").read_text(encoding="utf-8")
    if "Art.portrait_texture(u.character_id, u.portrait_id, GameData.portrait_registry)" not in battle_script or "Art.character_portrait_texture(Art.character_for_enemy" not in battle_script:
        errors.append("Battle turn-order portraits do not use the shared identity/archetype resolver.")
    if errors:
        print("FAIL")
        for error in errors:
            print(f" - {error}")
        return 1
    print("PASS: registry references and referenced files are structurally consistent.")
    print("NOTE: this is a structural audit, not artistic identity approval or UI runtime coverage.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
