# KindleWake — Core Engineering Handoff (2026-11-20)

## Live repository checkpoint

- Repository: https://github.com/ninjun42215-gif/KindleWake
- Project directory: `Kindlewake/`
- Engine: Godot 4.2.2 · GL Compatibility · Android
- Main base SHA: `13f66ec19476c9af5ed2b5c81af95e4d8a026876`
- Branch: `fix/character-sheet-appearance-save-guard-2026-11-20`
- Pull request: [#168 — Guard optional character appearance during save restoration](https://github.com/ninjun42215-gif/KindleWake/pull/168)
- Current code/test/build-runner SHA: `4ea41f84b56dbf7104959fa4f3aae3ca34c3ce61`
- No changes to main; no merge, force-push, branch deletion or repository-setting changes.

## Finding

A checksum-valid schema-4 campaign payload can contain a character sheet whose optional `appearance` field is an Array, String or another non-Dictionary value. The campaign validator checks many other sheet fields but does not validate `appearance`. `PartyState.from_dict()` delegates each member to `CharacterSheet.from_dict()`, which previously cast `d.get("appearance", {})` directly to Dictionary. A malformed cosmetic value could therefore abort restoration of the party and prevent Continue.

## Implemented fix

`CharacterSheet.from_dict()` now:
- Preserves a valid Dictionary appearance payload with a deep duplicate.
- Uses the existing empty Dictionary default when appearance is missing (legacy saves) or malformed.
- Leaves character identity, portrait ID, class, level, stats, equipment, runes, traits and all other persisted state unchanged.

This is intentionally a local cosmetic fallback, not a save migration. No schema/version bump, player-data rewrite, story change or gameplay-rule change.

## Regression tests

Added `tests/test_character_sheet_persistence.gd` with seven assertions covering:
1. Preservation of valid appearance dictionaries.
2. Safe fallback for Array appearance data.
3. Safe fallback for String appearance data.
4. Legacy saves with no appearance field.
5. Party restoration retaining the member with malformed appearance.
6. Sanitized appearance on the restored member.
7. Preservation of non-cosmetic character identity.

Registered this suite in `tools/build_apk.py` as an additional strict persistence test, so Android CI executes it and fails under `--strict` if the suite reports errors.

## Commits

- `1c9a027cbcb240f0760b8530e771c53c38a2d9e1` — guard optional character appearance during restoration.
- `f1fc259c1593a84e2c6598ae792514ebf830a432` — add character-sheet persistence regression tests.
- `4ea41f84b56dbf7104959fa4f3aae3ca34c3ce61` — run the persistence suite in strict Android builds.

Changed implementation/test/build files:
- `Kindlewake/scripts/core/character_sheet.gd`
- `Kindlewake/tests/test_character_sheet_persistence.gd`
- `Kindlewake/tools/build_apk.py`

## Verification status

Exact-head PR Actions are pending. No test pass or APK verification is claimed until GitHub Actions completes on the final PR head. The new regression suite is expected to report seven checks; the actual count and result must be read from its build log.

Main at the start of this run, SHA `13f66ec19476c9af5ed2b5c81af95e4d8a026876`:
- Project Health Audit #44446304110 — passed.
- Workflow YAML Lint #44446304180 — passed.
- Version Sync #44446304299 — passed.
- Android Build #44446304169 — failed at the Android emulator process-survival stage after import, 20/20 scene loads, 1,009 strict checks and APK export. This is not a physical-device result. QA owns emulator/release workflow work in PRs #159 and #164.

## Coordination

- PR #160 is an older top-level empire-state validation candidate based on a prior main SHA.
- PR #166 covers Chronicle domain-catalog normalization; this change is isolated to character appearance restoration.
- PR #167 owns local settlement architecture visuals and touches the monolithic `tests/run_tests.gd`; this PR avoids that file.
- PR #151 owns battle-resume/save-title flow.
- PRs #159/#164 own Android emulator and release workflow changes. This PR does not change workflow YAML or release permissions.
- PR #168 is intentionally draft and must remain unmerged under the current core-engineering instructions.

## Next steps

1. Inspect Build Android APK, Project Health Audit, Workflow YAML Lint and Version Sync on PR #168's exact final head.
2. Confirm `test_character_sheet_persistence.gd` ran and all seven assertions passed.
3. Inspect the emulator result separately from Godot tests/APK export; do not call CI an Android-device certification.
4. Keep PR #168 draft pending review. Do not merge or modify main.
5. Continue auditing optional persisted fields against their deserialization casts, but avoid overlapping active save-validation and battle-resume branches.
