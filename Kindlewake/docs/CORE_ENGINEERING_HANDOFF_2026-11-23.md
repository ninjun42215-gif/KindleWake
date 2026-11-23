# KindleWake — Core Engineering Handoff (2026-11-23)

## Live repository checkpoint

- Repository: https://github.com/ninjun42215-gif/KindleWake
- Project directory: `Kindlewake/`
- Engine: Godot 4.2.2 · GL Compatibility · Android
- Base `main` SHA: `13f66ec19476c9af5ed2b5c81af95e4d8a026876`
- Branch: `fix/equipment-enhancement-stat-scaling-2026-11-23`
- Implementation commit: `8a752b2faca66f2ff06ee22f2f488b2a795f6133`
- Regression-test commit: `ba8f2a7c9d06a8c41584eedcd91247da60a85820`
- CI and Android export status: pending PR creation and exact-head Actions.

## Finding

Blacksmith enhancements are persisted under a composite key, `slot|item_id`, by `PartyState.enhance_equipment()`. Armor defense/resistance and weapon power already read that key. However, `CharacterSheet.total_stats()` used `enhancements.get(slot, 0)` when scaling the equipped item's `bonus` block. Consequently, +1 through +15 enhancements charged gold and were saved, but did not increase the equipment's HP/MP/stat bonuses. This affected accessories, off-hand items, armor and any other equipment with a `bonus` dictionary.

## Implemented fix

- Resolve the enhancement level from `slot|item_id`, matching the blacksmith write path.
- Retain a slot-only fallback for older character-sheet data.
- Clamp the effective level to the established +0..+15 range when deriving stats.
- Reuse the same resolved level for the weapon power percentage so all enhancement effects share one source of truth.
- Updated the field comment to document the composite key and legacy fallback.

No equipment definitions, prices, enhancement cost curve, +15 cap, save schema, story, player data, item IDs, socket rules or Android permissions changed.

## Regression coverage

Added three checks to the existing strict `tests/run_tests.gd` shop/equipment section:

1. A +15 item-keyed accessory enhancement increases the unique Starfall Charm's MP bonus from +8 to +14 and INT bonus from +3 to +5.
2. A legacy slot-only enhancement key still applies the same bonus.
3. A +3 weapon enhancement still adds 15 percentage points of weapon power.

The tests use a throwaway CharacterSheet and do not modify the live test party or player saves.

## Changed files

- `Kindlewake/scripts/core/character_sheet.gd`
- `Kindlewake/tests/run_tests.gd`
- `Kindlewake/docs/CORE_ENGINEERING_HANDOFF_2026-11-23.md`

## Coordination and remaining risks

- PR #168 changes the separate `CharacterSheet.from_dict()` appearance fallback hunk; this branch changes the `total_stats()` hunk. The edits are independent, but rerun the full suite after integration.
- Visual PRs #167/#169 also add separate assertions in `tests/run_tests.gd`; this branch adds tests only in `_test_progression()`. Re-run the complete strict suite after any merge of those branches.
- PR #158 changes the Party screen/equipment icon presentation, not the stat derivation code.
- Main's Android workflow has previously failed its AOSP ATD / forced SwiftShader emulator stage with a GLES3 fragment-uniform limit error. QA PR #164 reports a successful Google APIs/default-graphics emulator path on its own exact head; that is not a physical-device result and is not evidence for this branch until its own checks run.
- No physical Android device was tested. Touch, long-session performance, save/load on handset and vendor-GPU compatibility remain outstanding.

## Safety

This is a focused gameplay calculation correction. No main-branch changes, merges, force-pushes, branch deletions, repository-setting changes, secret access or release publication were performed.
