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


## Exact-head verification — code/test head `0de73637d4bfb510e42d369dc1e8febc5973e0ec`

- [Project Health Audit #45107833510](https://github.com/ninjun42215-gif/KindleWake/actions/runs/45107833510): passed.
- [Workflow YAML Lint #45107833502](https://github.com/ninjun42215-gif/KindleWake/actions/runs/45107833502): passed.
- [Version Sync #45107833429](https://github.com/ninjun42215-gif/KindleWake/actions/runs/45107833429): passed.
- [Build Android APK #45107833431](https://github.com/ninjun42215-gif/KindleWake/actions/runs/45107833431): **failed only at the emulator process-liveness stage**. Import, strict tests, APK export and artifact upload completed successfully.

### Automated test results

- Godot 4.2.2 import: exit 0, no script errors.
- Scene smoke: 20 loaded, 0 failures.
- Core strict suite: **1,012 checks, 0 failures**; the three new enhancement assertions were included.
- Campaign lifecycle: 0 failures.
- Merchant UI: 0 failures.
- Title/creator UI: 0 failures.
- Act V: 0 failures.
- Campaign continuity: 70 checks, 0 failures.
- Chronicle dynasty: 39 checks, 0 failures.
- Chronicle family development: 19 checks, 0 failures.
- Balance report: completed.

### APK provenance

- [APK artifact #14787723023](https://github.com/ninjun42215-gif/KindleWake/actions/runs/45107833431/artifacts/14787723023) is tied by GitHub artifact metadata to exact code/test head `0de73637d4bfb510e42d369dc1e8febc5973e0ec`.
- Artifact archive size: 65,297,953 bytes.
- Artifact archive SHA-256: `4a05b3ac65b581fc4ecaa1b1feac5924ef75645e90595c5d6d30e348359ffa7a`; downloaded archive ZIP integrity passed and the digest matched GitHub metadata.
- Extracted APK: 65,852,762 bytes.
- Extracted APK SHA-256: `66c82dbded913f816d1886f842931c475a640ab88a28a2be4d56e38225388a31`.
- Build summary reports a valid signature (key fingerprint prefix `c04a7792715ad8f5`), ABIs `arm64-v8a`, `armeabi-v7a`, `x86_64`, and no Android permissions requested.
- [Test/build log artifact #14788636477](https://github.com/ninjun42215-gif/KindleWake/actions/runs/45107833431/artifacts/14788636477), archive SHA-256 `2721ef25288dae70b62b96ad270056e54cd8249b2e4cbacbfe1ef86ea2c92da8`; downloaded archive ZIP integrity passed.

### Emulator failure root cause

The AOSP ATD / forced SwiftShader GLES3 emulator installed and launched the APK, and Godot reported that its main loop started. Logcat then recorded:

- `rendering/limits/global_shader_variables/buffer_size` exceeds the emulator's maximum uniform-buffer size of 16,384 bytes.
- `SceneShaderGLES3: Program linking failed` because 261 active fragment uniforms exceed `GL_MAX_FRAGMENT_UNIFORM_VECTORS`.
- Godot emitted shader compilation/binding errors, destroyed its app instance and the Android process died. The captured 1368×632 emulator screenshot is black; the process-liveness assertion failed.
- No Android `FATAL EXCEPTION`, native fatal signal, GDScript `SCRIPT ERROR` or parse error was present in the captured logcat.

This is a confirmed failure on the configured SwiftShader emulator path. It is not evidence that the same shader limit occurs on every physical Android GPU.

### QA emulator comparison

QA PR #164's current head is `03efa339e85df62763bada23c2f7f97d5158d514`. Its [Build Android APK #45014535413](https://github.com/ninjun42215-gif/KindleWake/actions/runs/45014535413) passed using its API 35 Google APIs / Pixel 5 emulator path: the Godot activity resumed, title/menu OCR found KINDLEWAKE / NEW GAME / SETTINGS, the app process remained alive, and log checks found no shader-link, fatal or script errors. This is separate QA-branch evidence, not a test of this PR's APK on that emulator and not physical-device QA.

## Repository safety notes

- GitHub's branch endpoint currently reports `main` as unprotected with required status-check enforcement disabled. No repository settings were changed.
- Main's `.github/workflows/publish-android-release.yml` still grants `contents: write` at workflow scope. QA PR #164 owns the least-privilege release-workflow change; this core PR does not modify release workflows.
- No physical Android handset was tested. Touch behavior, long-session performance, thermal/memory behavior, save/load on handset and vendor-GPU compatibility remain outstanding.
