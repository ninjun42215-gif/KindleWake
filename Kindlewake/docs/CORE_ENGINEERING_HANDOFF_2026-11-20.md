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

## Exact-head verification — PR #168

- Final code/test/build-runner commit: `4ea41f84b56dbf7104959fa4f3aae3ca34c3ce61`.
- PR head tested by the Android workflow: `25bf4bd6e80669e303542ac2d4960355019eab73`.
- [Build Android APK #44665609160](https://github.com/ninjun42215-gif/KindleWake/actions/runs/44665609160) — overall **failed only at the Android emulator launch/liveness step**. Godot import, scene smoke, strict regression suites, APK export and artifact upload passed.
- [Project Health Audit #44665609182](https://github.com/ninjun42215-gif/KindleWake/actions/runs/44665609182) — passed on the exact tested PR head.
- [Workflow YAML Lint #44665609122](https://github.com/ninjun42215-gif/KindleWake/actions/runs/44665609122) — passed on the exact tested PR head.
- [Version Sync #44665609264](https://github.com/ninjun42215-gif/KindleWake/actions/runs/44665609264) — passed on the exact tested PR head.

### Automated results

- Godot 4.2.2 import: exit 0, no script errors.
- Scene smoke: 20 scenes loaded, 0 failures.
- Core strict regression suite: 1,009 checks, 0 failures.
- Campaign lifecycle: 0 failures; restored campaign entered World and initialized its regional map; first tactical battle initialized and remained alive through its opening combat window.
- Merchant UI and title/creator UI: passed.
- Act V, campaign continuity (70 checks), Chronicle dynasty (39 checks) and Chronicle family development (19 checks): passed.
- New `test_character_sheet_persistence.gd`: **7 checks, 0 failures** (valid appearance preservation; Array/String fallback; legacy omission; party restoration and preservation of character identity).
- Balance report: completed successfully.

Full logs are in [test-log artifact #14596704880](https://github.com/ninjun42215-gif/KindleWake/actions/runs/44665609160/artifacts/14596704880). Its archive SHA-256 is `b6f93997ba4370b726a910e7692602709293540b4a29e80bc50d43764a3efadf`.

### APK artifact provenance

- [APK artifact #14597682561](https://github.com/ninjun42215-gif/KindleWake/actions/runs/44665609160/artifacts/14597682561) was produced by run #44665609160, whose GitHub artifact metadata identifies the exact head `25bf4bd6e80669e303542ac2d4960355019eab73`.
- Artifact archive size: 65,297,997 bytes.
- Artifact archive SHA-256: `209cfa25922e8d41235edde6eceff643693bc5f69e864770f91a7094dfaeacf0` (independently matched after download; ZIP integrity test passed).
- Extracted APK: 65,852,762 bytes.
- Extracted APK SHA-256: `de3c530af4ea8af00ae390ddc9af124a8d7037b6adf1bf7fa5cf578aeb36ff8a`.
- Build summary: valid test signature (key fingerprint prefix `c04a7792715ad8f5`), ABIs arm64-v8a / armeabi-v7a / x86_64, no Android permissions requested.
- This is an exact-head CI candidate, not a production-signed release and not a physical-device-tested APK.

### Android emulator failure

The AOSP ATD / SwiftShader emulator step failed after launch:
- Godot logged repeated `SceneShaderGLES3: Program linking failed` messages because 261 active fragment uniforms exceeded the emulator-reported `GL_MAX_FRAGMENT_UNIFORM_VECTORS`.
- The Godot main loop started, then `GodotActivity` destroyed the app and the process was killed with SIGKILL. The 30-second process-liveness assertion failed.
- No Android `FATAL EXCEPTION` or GDScript parse/runtime error was reported in the captured logcat.
- This is an emulator/backend compatibility failure; it does not establish the same failure on a physical Android handset.

The QA-owned PR #164 proposes moving the smoke test to the Google APIs emulator and improving the visual/liveness assertions, but it is currently 12 commits ahead / 5 behind current main and needs revalidation on a fresh current-main base. Do not bulk-merge its stale branch.

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
