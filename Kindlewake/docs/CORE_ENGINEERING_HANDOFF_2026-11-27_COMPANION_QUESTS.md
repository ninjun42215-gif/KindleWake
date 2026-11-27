# Core engineering handoff — companion quest save integrity (2026-11-27)

**Repository:** https://github.com/ninjun42215-gif/KindleWake  
**Project:** `Kindlewake/` · Godot 4.2.2 · GL Compatibility · Android  
**Parent PR:** [#179 — holding garrison integrity](https://github.com/ninjun42215-gif/KindleWake/pull/179)  
**Working branch:** `fix/companion-quest-save-normalization-2026-11-27`  
**Base branch:** `fix/holding-garrison-reserve-integrity-2026-11-25`  
**Base SHA:** `c7630c816ed090f7a16b2d4dc77c429cdb82c5d2`  
**Project version:** `0.12.0 / Android 1200` · **Save schema:** `4`

## Implemented

Hardened `CompanionQuestSystem` against inconsistent persisted and in-memory quest states:

- A saved `complete` state is retained only when every authored milestone is complete and the outcome belongs to that quest's outcome list.
- A forged or stale completed snapshot with incomplete progress is reopened as `active`, preserving its valid progress and clearing its outcome.
- A fully progressed completed snapshot with an unknown outcome is reopened as `ready`, so the player can make a valid concluding choice.
- Non-numeric saved progress resets safely to zero before clamping; fractional saved progress cannot preserve a completed state.
- Non-complete states no longer retain stale outcome values.
- Runtime resolution independently checks that a `ready` record has completed every milestone.
- `advance` and `status` safely handle malformed quest records without invalid Dictionary casts.

## Compatibility and preservation

- No save-schema/version change, migration, new persistent fields, story rewrite, quest IDs, milestone IDs, outcomes, reward values or player-save mutation.
- Valid active, ready and completed quest records retain their existing progress and choices.
- Existing completed quests produced by the current API already require all milestones, so valid saves remain unchanged.
- Invalid legacy/corrupt records are reopened at their last valid progress rather than silently retaining a completion outcome.
- The feature branch is stacked on PR #179 solely to reuse its isolated standalone-test registration in `tools/build_apk.py`; it does not edit the parent PR's garrison code or tests.

## Regression coverage

New standalone test: `Kindlewake/tests/test_companion_quest_normalization.gd`.

The canonical Android build runner invokes this script in its campaign test list. It covers valid state preservation, incomplete-completion recovery, invalid outcomes, ready/active reconciliation, negative/excessive/non-numeric/fractional progress, malformed choices, unknown quests, unsupported statuses, runtime resolve guards and malformed-record handling.

## Exact refs and validation

Implementation is committed on this branch after the parent PR head `c7630c816ed090f7a16b2d4dc77c429cdb82c5d2`. The exact child head and GitHub Actions results are recorded in the follow-up section below once CI completes.

Parent PR #179 currently remains a separate draft. Its latest known exact-head Project Health, Workflow YAML Lint and Version Sync checks passed; Android Build exported/imported/tested but failed at the known AOSP ATD / SwiftShader emulator process-survival stage. The parent PR's known Android rendering limitation is not caused by this companion-quest change.

## Review risks

- This changes only recovery behavior for inconsistent saved quest records; no valid current quest progression should change.
- If a historical save contains a completed quest with incomplete progress, it will no longer appear completed. That state could not be produced by the current progression API and is treated as corrupt/stale.
- The child PR depends on the parent branch until PR #179 is integrated. Keep this PR draft and do not merge it independently into main.

## CI routing note

The repository's Android Build and Version Sync workflows are configured for pull requests targeting `main`. Because this feature is intentionally stacked on PR #179, PR #184 is temporarily targeted at `main` to trigger exact-head verification against the complete child tree (including its parent commits). After those runs complete, the PR base will be returned to the parent branch. The branch itself is not rebased or force-pushed.

## Exact-head verification — first CI pass

On the first implementation/test head `f9c3d9e8e408ee1553e0a6348f659b5a2997a70d`:

- [Project Health Audit #45938157557](https://github.com/ninjun42215-gif/KindleWake/actions/runs/45938157557) — passed.
- [Workflow YAML Lint #45938157479](https://github.com/ninjun42215-gif/KindleWake/actions/runs/45938157479) — passed.
- [Version Sync #45938157503](https://github.com/ninjun42215-gif/KindleWake/actions/runs/45938157503) — passed.
- [Android Build #45938157483](https://github.com/ninjun42215-gif/KindleWake/actions/runs/45938157483) — workflow passed, including import, strict tests, APK export, install and process-survival check.

Observed test output: 1,009 main strict checks, 20/20 scene loads, 70 campaign continuity checks, 39 Chronicle dynasty checks, 19 Chronicle family checks, 12 parent-PR garrison integrity checks and 20 companion-quest normalization checks; all reported zero failures. The current branch adds one additional fractional-saved-progress assertion, so this first run is not the final-head test result.

APK artifact: [#15171576766](https://github.com/ninjun42215-gif/KindleWake/actions/runs/45938157483/artifacts/15171576766), 65,298,331-byte archive, SHA-256 `9393806401a33e3622f3c26319333bfccb684005eb397ac8d347a3671865f924`.

### Visual qualification — do not treat the green emulator job as visual approval

The uploaded screenshot `honor400-emulator.png` shows the dark title panel and button shapes but no readable title or button labels. The same run's logcat still reports `SceneShaderGLES3` fragment uniform overflow at `GL_MAX_FRAGMENT_UNIFORM_VECTORS (261)` and shader bind failures. The process remained alive, so the workflow's liveness/error gate passed, but visible text rendering did not. This remains a QA/release blocker; no renderer, shader, font or visual files were changed by this PR.

Diagnostic log artifact: [#15171612417](https://github.com/ninjun42215-gif/KindleWake/actions/runs/45938157483/artifacts/15171612417).

## Follow-up head

The code now also rejects fractional saved progress from retaining a completed quest state. Final child-head CI and artifact details will be appended after the current branch checks finish.

## Final exact-head verification

**Code/test and pre-final-handoff head:** `2d322a381019c839979e2c38fcff04ca6f07f630`.

- [Project Health Audit #45938680807](https://github.com/ninjun42215-gif/KindleWake/actions/runs/45938680807) — passed.
- [Workflow YAML Lint #45938680799](https://github.com/ninjun42215-gif/KindleWake/actions/runs/45938680799) — passed.
- [Version Sync #45938680889](https://github.com/ninjun42215-gif/KindleWake/actions/runs/45938680889) — passed.
- [Android Build #45938680852](https://github.com/ninjun42215-gif/KindleWake/actions/runs/45938680852) — **failed at Android emulator process-survival**, after import, strict tests, APK export and upload succeeded.

Exact build summary:

- Godot 4.2.2 import: exit 0, no script errors.
- Scene smoke: 20 loaded, 0 failures.
- Main strict suite: 1,009 checks, 0 failures, 0 script errors, 0 parse errors.
- Campaign lifecycle: passed; Merchant UI: passed; title/creator UI: passed.
- Act V: 0 failures; campaign continuity: 70 checks, 0 failures.
- Chronicle dynasty: 39 checks, 0 failures; Chronicle family: 19 checks, 0 failures.
- Parent PR #179 garrison integrity: 12 checks, 0 failures.
- Companion quest normalization: **21 checks, 0 failures**.
- Balance report completed.

APK artifact: [#15171128800](https://github.com/ninjun42215-gif/KindleWake/actions/runs/45938680852/artifacts/15171128800), 65,298,421-byte archive, SHA-256 `cf90b1842c6387f5ff064d2c85d638dd4a24d7588f194a64eee981be4eb0d964`. Build summary reports a 65.9 MB signed APK with ARM64, ARMv7 and x86_64 libraries and no Android permissions.

Diagnostic artifact: [#15172056577](https://github.com/ninjun42215-gif/KindleWake/actions/runs/45938680852/artifacts/15172056577), SHA-256 `c42a2a0e8a1b8afef52be9aaae18f19966da3bedf5c0c6f73e49535c159582da`.

### Android failure evidence

The final-head screenshot is black. The emulator logcat records repeated `SceneShaderGLES3` program-link failures because fragment uniforms exceed `GL_MAX_FRAGMENT_UNIFORM_VECTORS (261)`, followed by shader bind warnings. The Godot process then exits with signal 9; the workflow fails its process-liveness check. No Java `FATAL EXCEPTION`, native fatal signal or GDScript/parse error was captured.

The earlier run at `f9c3d9e` did keep the process alive, but its screenshot showed button panels with no visible text and the same shader-limit error. Therefore the Android emulator is **not visually or runtime verified**, despite successful import/tests/export. The current CI liveness gate does not establish correct text rendering. QA must resolve the shader/uniform issue and add a visual/text-presence assertion before release approval.

## Current PR state

PR #184 has been returned to its intended stacked base, `fix/holding-garrison-reserve-integrity-2026-11-25`. Parent PR #179 remains a separate draft. The child PR must not be merged directly to main before its parent dependency is integrated. No main, player-save, visual or QA-owned files were changed.
