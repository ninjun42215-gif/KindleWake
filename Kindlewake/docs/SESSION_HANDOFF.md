# KindleWake — live session handoff (2026-11-10)

**Canonical repository:** `ninjun42215-gif/KindleWake`  
**Canonical project directory:** `Kindlewake/`  
**Default branch:** `main`  
**Latest verified main commit at handoff creation:** `e108b0f32ea037ac7e338bc1e01c4ba1032de26b`  
**Godot project version:** `0.10.0`  
**Android version name/code:** `0.10.0` / `1000`  
**Save schema:** `3`  
**Timezone:** Asia/Manila (UTC+08:00)

## Current repository truth

- PR #16 merged the SaveSystem game-version metadata synchronization fix. Its merge commit is the current main SHA above.
- The game version source of truth is `Kindlewake/project.godot`; it currently says `0.10.0`. Android export metadata and `SaveSystem.GAME_VERSION` also read `0.10.0`; `SAVE_VERSION=3` remains a separate payload schema.
- No open PRs were found during this inspection.
- The latest main SHA returned no PR-triggered workflow runs through the available commit-run query, and its combined commit status returned no status entries. This is **not proof of a successful post-merge build**. Verify the Actions page before distributing an APK.
- The previous successful full gate is historical: PR #14 exact-head CI and Safe Auto Merge run `42705647621`. PR #16’s PR checks and Safe Auto Merge run `42706883392` are recorded in the prior handoff context; verify live run details if needed.
- The four-check exact-SHA auto-merge system is intended to require Build Android APK, Version Sync, Workflow YAML Lint and Project Health Audit, then merge only the exact tested PR head. PR #16 was successfully merged by `github-actions[bot]` after checks.

## Important documentation/version discrepancy

- `Kindlewake/docs/GDD.md` contains design/revision notes through `0.10.4`, including mobile UI refinements, battle identity art and external intake/handoff packaging.
- `Kindlewake/project.godot`, `Kindlewake/README.md`, Android export metadata and SaveSystem game metadata still identify the shipped project version as `0.10.0`.
- Treat GDD entries `0.10.1`–`0.10.4` as recorded implementation notes, **not a released version bump**. Audit their corresponding scenes/scripts/tests and exact commit/CI evidence before claiming each milestone is validated or incrementing the project version.
- Root `README.md` and older handoff text previously contained stale version/checkpoint statements; this handoff supersedes them.

## Merged work and verified automation

- PR #7 Operations Toolbox: source handoff/backup, branch hygiene, repository organizer, safe branch integration, health audit and workflow lint.
- PR #8 Rune System: 77 rune definitions, passive/active/support/stat/independent kinds, unique/heirloom protections, mixed-grade three-copy fusion, mastery bonuses, specialist vendors and combat status effects.
- PR #9/#10 Safe Auto Merge: exact-SHA PR discovery and expected-SHA REST merge.
- PR #11/#13/#14 handoff and four-check gate improvements; PR #14 verified end-to-end.
- PR #16 SaveSystem game-version metadata synchronization fix.

## CI and handoff status

- Latest exact main SHA: `e108b0f32ea037ac7e338bc1e01c4ba1032de26b`.
- Post-merge main APK artifact for this SHA: **not verified yet**.
- Fresh source-handoff artifact for this SHA: **not verified yet**. Older artifacts must not be presented as current.
- Existing handoff automation must be located and inspected before triggering; do not guess a workflow filename or claim a new archive exists.
- Any source archive must include an exact source SHA, SHA-256 manifest, reproducible reassembly instructions and parts no larger than 25,000,000 bytes.

## Release blockers and QA

1. Physical Android QA remains outstanding: install the latest APK and test launch, orientation/safe areas, touch HUD, party/gear/rune screens, fusion, specialist shops, status effects, save/load and performance.
2. The voxel-building asset pack still has unresolved redistribution/licensing evidence. Public/commercial release remains blocked until authoritative permission is recorded or the pack is replaced.
3. Optional nested sprite packs must remain source-only until their licence and suitability are verified.
4. Do not equate headless CI or successful APK export with real-device gameplay validation.

## Immediate next actions

1. Inspect GDD notes `0.10.1`–`0.10.4` against actual implementation, tests and commit history. Resolve whether they are complete, partially implemented or planned.
2. Check the latest main Actions runs directly; run the Android build and strict test suite if no current successful run exists.
3. Locate the real source-handoff workflow, trigger it for the current main tree, and verify exact SHA, manifest and part-size limits.
4. Continue the next smallest playable campaign milestone only after the audit; preserve offline-only design and save schema compatibility.
5. Update this handoff, both continuation prompts, README and GDD revision notes at the end of each meaningful session.

## Useful links

- Repository: https://github.com/ninjun42215-gif/KindleWake
- Main commit: https://github.com/ninjun42215-gif/KindleWake/commit/e108b0f32ea037ac7e338bc1e01c4ba1032de26b
- Actions: https://github.com/ninjun42215-gif/KindleWake/actions
- PR #16: https://github.com/ninjun42215-gif/KindleWake/pull/16
- PR #14: https://github.com/ninjun42215-gif/KindleWake/pull/14
