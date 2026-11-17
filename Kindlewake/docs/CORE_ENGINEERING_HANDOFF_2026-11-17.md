# KindleWake — Core Engineering Handoff (2026-11-17)

## Live repository checkpoint

- Repository: https://github.com/ninjun42215-gif/KindleWake
- Canonical project: `Kindlewake/`
- Engine: Godot 4.2.2 · GL Compatibility · Android
- Game / Android version: `0.12.0 / 1200`
- Save schema: `4` (unchanged)
- Level cap: `250`
- Main at branch creation: `8c512a063f6ef63c88f33489d118cad6b0a29c6c`
- Current work: [PR #156](https://github.com/ninjun42215-gif/KindleWake/pull/156), branch `fix/campaign-empire-save-validation-2026-11-17`
- No changes were pushed to main; PR #156 is unmerged.

## Implemented save-integrity fix

**Root cause:** `RegionSaveState.is_valid_campaign_payload()` validated the campaign's other normalizer inputs but did not validate optional `empire_state`. `GameState.load_campaign()` passes that value to `EmpireSystem.normalize_state(raw: Dictionary, ...)`. A checksum-valid save containing an Array or other non-Dictionary `empire_state` could therefore pass campaign validation and then raise a runtime type error during restore.

**Change:**
- Require `empire_state` to be a Dictionary when present.
- Preserve compatibility for older schema-4 saves by retaining the existing `{}` default when the field is absent.
- Add a regression assertion that rejects an Array-valued `empire_state` before realm normalization.

No save schema/version bump, destructive migration, story change or player-data rewrite was introduced.

### Code commits

- Base: `8c512a063f6ef63c88f33489d118cad6b0a29c6c`
- `f4bdf15c602addf3e2e2a8293dd181008c9c0538` — validate optional empire state before campaign restore.
- `62a65c5a8a78c0b6ed8f1e4b3705cdc698b384c0` — add malformed empire-state regression coverage.

### Changed code files

- `Kindlewake/scripts/core/region_save_state.gd`
- `Kindlewake/tests/run_tests.gd`

## Exact-head CI snapshot — code SHA `62a65c5a8a78c0b6ed8f1e4b3705cdc698b384c0`

- [Project Health Audit #44010138457](https://github.com/ninjun42215-gif/KindleWake/actions/runs/44010138457) — passed.
- [Workflow YAML Lint #44010138493](https://github.com/ninjun42215-gif/KindleWake/actions/runs/44010138493) — passed.
- [Version Sync #44010138445](https://github.com/ninjun42215-gif/KindleWake/actions/runs/44010138445) — passed.
- [Build Android APK #44010138501](https://github.com/ninjun42215-gif/KindleWake/actions/runs/44010138501) — at handoff time, Godot import, scene/test suite and APK export stage passed; APK artifact was uploaded. The optional emulator diagnostic step was still running, so the overall workflow had not yet completed.
- Exact-head APK candidate artifact: [14296332096](https://github.com/ninjun42215-gif/KindleWake/actions/runs/44010138501/artifacts/14296332096), 63,042,548 bytes. This is a PR candidate, not a production release.

Re-check the live run before treating the pending emulator diagnostic or overall build conclusion as final. No physical Android device test is claimed.

## Current-main baseline

Main SHA `8c512a063f6ef63c88f33489d118cad6b0a29c6c` passed [Build Android APK #44007769755](https://github.com/ninjun42215-gif/KindleWake/actions/runs/44007769755):
- Strict suite: 994 checks, 0 failures.
- Campaign lifecycle, merchant UI and title/creator UI: 0 failures.
- Campaign continuity: 70 checks, 0 failures.
- Chronicle dynasty: 39 checks; family development: 19 checks.
- APK signature verified; Android permissions requested: none.
- Main APK artifact: [14294529347](https://github.com/ninjun42215-gif/KindleWake/actions/runs/44007769755/artifacts/14294529347), 63,042,418 bytes.

**Android diagnostic caveat:** the optional emulator step in that main build did not establish a running application process: the `pidof com.kindlewake.game` assertion returned exit code 1. The step is configured `continue-on-error: true`, so the overall build remained green. Treat emulator launch as unverified until the log/screenshot evidence confirms it. This is not physical-device QA.

## Open PR / branch coordination

- [PR #156](https://github.com/ninjun42215-gif/KindleWake/pull/156): this isolated save-validation candidate; review exact head and checks. Do not merge automatically.
- [PR #151](https://github.com/ninjun42215-gif/KindleWake/pull/151): draft QA battle-resume work; based on an older main SHA and currently conflicted. It touches GameState, save flow and battle UI; do not overlap or merge wholesale.
- [PR #152](https://github.com/ninjun42215-gif/KindleWake/pull/152): draft release-workflow safeguards; based on an older main SHA and currently conflicted. Keep release workflow work with QA/release ownership.
- [PR #81](https://github.com/ninjun42215-gif/KindleWake/pull/81): draft regional trading integration; still not mergeable. The earlier handoff records cargo inventory, tariff/route authority, region/story gates, canonical route endpoints and mobile layout as unresolved. Rebuild a fresh slice from current main rather than merging the old branch wholesale.

## Next steps

1. Re-check PR #156's final head and wait for all exact-head checks, including the optional emulator diagnostic.
2. Review and mark PR #156 ready only after verification; never merge to main as part of this workflow.
3. Keep campaign restore validation changes isolated from PR #151's battle-resume work.
4. Continue save/load fault-injection coverage for malformed nested fields, backup fallback and failure-atomic restore.
5. Physical Android QA remains outstanding: install/launch, creator touch, Chapter 1 courtyard, world travel, battle, pause/resume and save → kill/relaunch → Continue.
6. Preserve offline operation, save schema 4, all story/content and existing player data.
