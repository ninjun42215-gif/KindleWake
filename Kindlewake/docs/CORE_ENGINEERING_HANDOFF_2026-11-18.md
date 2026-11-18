# KindleWake — Core Engineering Handoff (2026-11-18)

## Live repository checkpoint

- Repository: https://github.com/ninjun42215-gif/KindleWake
- Canonical project: `Kindlewake/`
- Engine: Godot 4.2.2 · GL Compatibility · Android
- Game / Android version: `0.12.0 / 1200`
- Save schema: `4` (unchanged) · Level cap: `250`
- Main at this run's start: `751b2f3f6b1104aa30e107659094ae2e221dbe3d`
- Current core candidate: [PR #160](https://github.com/ninjun42215-gif/KindleWake/pull/160)
- Branch: `fix/campaign-empire-state-validation-2026-11-18`
- No changes were pushed to main; PR #160 is draft and unmerged.

## Implemented code

A checksum-valid campaign payload can contain an Array/string/null for `empire_state`. The current validator accepted it, then `GameState.load_campaign()` passed it to `EmpireSystem.normalize_state(raw: Dictionary, ...)`. The typed call can fail after some live campaign fields have already been replaced, so this is both a crash risk and a partial-restore risk.

The current-main candidate:
- Rejects a present non-Dictionary `empire_state` in `RegionSaveState.is_valid_campaign_payload()`, before campaign mutation.
- Keeps the field optional via the existing `payload.get("empire_state", {})` default, preserving schema-4 saves created before realm state was added.
- Tests both explicit Dictionary acceptance and Array rejection.
- Does not change schema/version, migration behavior, player data, story or gameplay content.

### Exact base and code commits

- Base main: `751b2f3f6b1104aa30e107659094ae2e221dbe3d`
- `7faad4ab0a638cf95ad28ea1571ebeabd29149be` — validate optional empire state before campaign restore.
- `a89ae2eb64b48b52b2012492a27d0aaeaab76c7b` — add valid/malformed empire-state regression assertions.

Changed code files:
- `Kindlewake/scripts/core/region_save_state.gd`
- `Kindlewake/tests/run_tests.gd`

## Current-main CI and Android diagnostics

Main SHA `751b2f3f6b1104aa30e107659094ae2e221dbe3d`:
- [Project Health Audit #44225653218](https://github.com/ninjun42215-gif/KindleWake/actions/runs/44225653218) — passed.
- [Workflow YAML Lint #44225653214](https://github.com/ninjun42215-gif/KindleWake/actions/runs/44225653214) — passed.
- [Version Sync #44225653230](https://github.com/ninjun42215-gif/KindleWake/actions/runs/44225653230) — passed.
- [Manual Source Handoff #44225653270](https://github.com/ninjun42215-gif/KindleWake/actions/runs/44225653270) — passed.
- [Build Android APK #44225653213](https://github.com/ninjun42215-gif/KindleWake/actions/runs/44225653213) — **failed in the emulator smoke stage after the build/export stage succeeded**. Godot import had no script errors; 20/20 scenes loaded; strict suite 1,009 checks / 0 failures; campaign lifecycle, merchant UI, title/creator UI, Act V, continuity (70), dynasty (39), family development (19) and balance simulation completed. A signed 65.8 MB APK was exported for arm64-v8a, armeabi-v7a and x86_64; no Android permissions were requested.
- Emulator logcat from artifact `14392193337` shows the AOSP ATD / SwiftShader renderer reporting `SceneShaderGLES3` program-link failure because active fragment uniforms (261) exceed the reported device limit. The captured screenshot is black and the game process is absent at the 30-second check. Do not report the main emulator run as passed or release-ready.

QA owns [PR #159](https://github.com/ninjun42215-gif/KindleWake/pull/159), which changes the emulator image/script. Its exact branch head at this checkpoint was `df58cfded03c7a85f8e9e7d36719e6a80528b010`; [Build Android APK #44076962703](https://github.com/ninjun42215-gif/KindleWake/actions/runs/44076962703) passed and its diagnostic artifact `14324334765` shows the KindleWake title menu with OCR matches and no GLES uniform-limit error. That is emulator evidence on a separate, stale-base QA branch—not physical-device certification and not proof that the same workflow has been fixed on main.

## PR / branch coordination at this checkpoint

All counts compare the branch against current main; branches are references only unless the PR is explicitly current:
- [#160](https://github.com/ninjun42215-gif/KindleWake/pull/160): this focused current-main save-validation candidate.
- [#156](https://github.com/ninjun42215-gif/KindleWake/pull/156): old save-validation candidate, 8 ahead / 83 behind; do not merge or rebase wholesale. PR #160 ports only the code/test slice to current main.
- [#151](https://github.com/ninjun42215-gif/KindleWake/pull/151): 9 ahead / 93 behind; battle-resume, GameState and title/save flow. Avoid overlapping it.
- [#152](https://github.com/ninjun42215-gif/KindleWake/pull/152): 4 ahead / 93 behind; release workflows. Keep release permission work with QA/release ownership; do not merge wholesale.
- [#157](https://github.com/ninjun42215-gif/KindleWake/pull/157): 34 ahead / 4 behind; portrait/creator visual work.
- [#158](https://github.com/ninjun42215-gif/KindleWake/pull/158): 4 ahead / 4 behind; equipment icon and party/shop visual work.
- [#159](https://github.com/ninjun42215-gif/KindleWake/pull/159): 18 ahead / 4 behind; Android emulator workflow and release-readiness docs.
- [#81](https://github.com/ninjun42215-gif/KindleWake/pull/81): 3 ahead / 141 behind; regional trading integration; still stale and not safe to merge wholesale.
- [#130](https://github.com/ninjun42215-gif/KindleWake/pull/130): 2 ahead / 112 behind; authentication/offline documentation.

## Repository health and release security

- Routine `.github/workflows/build-apk.yml` uses `contents: read`; its version-tag publishing job alone has `contents: write`.
- `.github/workflows/publish-android-release.yml` currently grants `contents: write` at workflow scope. Its rejected-confirmation job inherits that permission even though it only prints an error. Move write permission down to the protected `publish` job; PR #152 owns this area but is too stale to merge wholesale.
- `.github/workflows/safe-auto-merge.yml` uses `actions: read`, `contents: write`, `pull-requests: write`; it does not check out or execute PR code and gates on exact SHA, unique open PR, non-draft state and required checks. This run did not alter workflow permissions or repository settings.
- Asset provenance ledger was updated 2026-11-18. Runtime-used packs are marked verified; restricted/unverified legacy packs are marked unused. Credits documentation is present. Recheck both before distribution.

## Next steps

1. Wait for and inspect every exact-head check for PR #160, especially the Android build and emulator diagnostic. Code-SHA checks do not certify a later documentation-only head.
2. Keep PR #160 draft and unmerged; never merge as part of this workflow.
3. QA/release owner should rebase/port PR #159's emulator workflow fix to current main and verify the exact new head; do not duplicate it here.
4. Narrow `publish-android-release.yml` write permission to the actual publishing job after reconciling PR #152.
5. Physical Android QA remains outstanding: install/launch on a real handset, creator selection/touch, Chapter 1 courtyard, world travel, battle/pause/resume, and save → kill/relaunch → Continue.
6. Preserve offline operation, save schema 4, story, all existing systems and player data.
