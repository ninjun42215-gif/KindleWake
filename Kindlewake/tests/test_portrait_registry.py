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

    for character_id, definition in characters.items():
        if character_id not in by_id:
            errors.append(f"Character definition missing from registry: {character_id}")
            continue
        entry = by_id[character_id]
        if entry.get("portrait_id") != definition.get("portrait_id"):
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

    if "portrait_registry" not in load_json(ROOT / "data" / "portrait_registry.json"):
        errors.append("Portrait registry payload is missing.")

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
