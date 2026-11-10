# KindleWake production audit — 2026-11-10

## Audited source of truth

- Repository: [ninjun42215-gif/KindleWake](https://github.com/ninjun42215-gif/KindleWake)
- Canonical project: `Kindlewake/`
- Audited main commit: `830bc0273d45140a11a4038f092a4d5ee347a243`
- Game / Android version: `0.12.0` / version code `1200`
- Save payload schema: `4`
- Engine: Godot `4.2.2`, GDScript, GL Compatibility
- Distribution target: Android and iOS; offline-first; no accounts, servers, multiplayer or INTERNET permission
- The source tree, not historical ZIP snapshots or old handoff text, is authoritative.

## Verified current-main build

The post-merge CI run for main commit `830bc0273d45140a11a4038f092a4d5ee347a243` completed successfully:

| Gate | Run | Result |
|---|---:|---|
| Android APK build | [42814167185](https://github.com/ninjun42215-gif/KindleWake/actions/runs/42814167185) | Passed |
| Project Health Audit | [42814167059](https://github.com/ninjun42215-gif/KindleWake/actions/runs/42814167059) | Passed |
| Version synchronization | [42814167093](https://github.com/ninjun42215-gif/KindleWake/actions/runs/42814167093) | Passed |
| Workflow YAML lint | [42814167037](https://github.com/ninjun42215-gif/KindleWake/actions/runs/42814167037) | Passed |
| Source handoff snapshot | [42814166894](https://github.com/ninjun42215-gif/KindleWake/actions/runs/42814166894) | Passed |

The Android job used Godot 4.2.2, completed a clean retry after transient first-scan script-registration/import messages, loaded 18 scenes with 0 failures, ran 912 strict checks with 0 failures, completed the campaign balance report (30 AI-vs-AI battles per scenario), exported and verified a signed APK, and uploaded the test/build logs. APK artifact: `13763523117` (41,190,380-byte artifact archive). CI success is not physical-device QA.

The log still reports non-failing ObjectDB/resource cleanup warnings at shutdown, a custom-cursor warning on the headless display server, and a Blender-path warning because Blend import is enabled without a configured Blender executable. Track these as cleanup items; do not misreport them as failed tests.

## Latest integrated gameplay correction

PR [#118](https://github.com/ninjun42215-gif/KindleWake/pull/118) is merged. It moves Maren's final sequel objective to the Northstar Wreck, aligns the clue and consent framing across Brinegate and Saltmere, and adds regression assertions for the intended three-location quest chain. The PR head passed Android build, project health, version sync and YAML lint; the subsequent current-main build also passed.

## Progression requirement verified

The requested level cap of **250 is implemented**, not merely planned:
- `CharacterSheet.MAX_LEVEL == 250`
- Loaded character levels are clamped to 1–250.
- EXP is discarded at the cap, including pre-existing overflow.
- Strict tests assert the cap and legacy-save normalization.
- The canonical `Kindlewake/docs/GDD.md` describes the 1–250 curve.

The root-level `GDD_Kindlewake.md` is an older v0.7.11 snapshot and is not the current design source. Use `Kindlewake/docs/GDD.md`.

## Current playable-content boundary

- The global atlas contains seven authored continents.
- The GDD identifies Eldrimar/Sethmarch and the first Thalassar region, Brinegate Coast, as the playable regional areas. The other continents and later Thalassar regions are not all playable.
- The Brinegate route, regional saves, world travel and Chapter I courtyard fixes are part of the v0.12.0 source.
- The GDD explicitly leaves parts of the opening vertical slice unfinished: persistent journal, first keep-restoration decision, investigation content, expanded cinematic scenes and physical Android QA.
- Do not describe design-bible material, lore records or an inspectable atlas as shipped playable content unless the current scenes/data/tests prove it.

## Open pull-request portfolio — triage before integration

The repository currently has several open, overlapping or stacked proposals. They are not a single release candidate and must not be merged en masse.

| PR | Area | Audit decision |
|---|---|---|
| #112 | Chronicle inter-house diplomacy | Draft and stacked on `feature/chronicle-family-development`; review dependency and save/UI integration first. |
| #91 and #87 | Territorial governance | Overlapping governance proposals on old main bases; compare and select one canonical implementation. |
| #46 | Royal Administration / empire management | Very large, 261-commit draft with broad overlap against governance and diplomacy; do not merge as a bulk replacement. Decompose and port only validated slices. |
| #81 | Regional trading | Promising separate system, but stale base and currently non-mergeable; rebase and run exact-head validation. |
| #78, #66 and #63 | Godot test gate / boss simulations / boss AI | Stacked dependency chain; validate in order and retain the actual engine test gate. |
| #43, #45 and #47 | Lore and campaign documentation | Stacked documentation chain; consolidate canon and avoid duplicate competing bibles. |
| #42 | Regional bestiary and human factions | Large old-base content branch; audit encounter balance, art provenance and exact-head tests before porting. |
| #44 | Chronicle founder gate | Foundation only; must remain locked until the actual campaign ending milestones exist and call the gate. |
| #22 and #23 | Premium creative direction | Overlapping older-base documentation proposals; merge the strongest material into the canonical production bible rather than keeping parallel sources. |

The PR portfolio should be re-compared against the live main SHA before any action. Historical branch names, base SHAs, test counts and mergeability can change. No branch should be force-pushed or deleted as part of this audit.

## Release and quality blockers

1. **Physical Android QA:** no confirmed device test results are recorded. Test install/launch, portrait and landscape, safe areas, touch/scroll, world traversal and wraparound, Chapter I, Brinegate, battle transitions, save/continue after process death, performance, thermals and battery.
2. **Asset rights:** the current handoff identifies unresolved third-party sprite/voxel-pack redistribution rights. Do not ship those assets publicly or commercially until authoritative licences are recorded or the assets are replaced.
3. **Resource cleanup:** investigate the non-failing ObjectDB/resource shutdown warnings with verbose Godot logs and ensure tests release created nodes/resources.
4. **Import warnings:** investigate transient first-pass global-class registration messages and the missing Blender executable warning; keep the successful clean retry visible in CI.
5. **Main protection:** main is currently reported as unprotected. Enable an appropriate ruleset/branch protection with PR review and required exact-head checks when repository administration is available.

## Recommended production order

1. Keep main stable and preserve schema 4; maintain the exact-SHA CI gate.
2. Complete and test the Chapter I playable vertical slice, including journal, investigation, keep-restoration choice, cinematic beats and fail-forward outcomes.
3. Rebase and audit feature branches one dependency chain at a time; consolidate duplicate governance, diplomacy and creative-direction work.
4. Finish companion recruitment, bonds, personalities and personal quests as playable content rather than catalogue-only data.
5. Integrate regional economy, governance and diplomacy through one consistent campaign state and readable player-facing UI.
6. Expand the world one fully playable region at a time, with unique encounters, quests, dungeons and bosses.
7. Polish mobile UI, fonts, portraits, animations, effects and audio using assets with verified licences.
8. Complete device QA, accessibility, performance, save-integrity and release checks before calling the game release-ready.

## Non-negotiable safeguards

- Do not edit main directly; use a short-lived branch and PR.
- Preserve existing saves and schema 4 unless a migration is designed and tested.
- Keep the game offline and do not add INTERNET permission, accounts, servers or multiplayer.
- Preserve established canon and stable IDs.
- Never invent asset licences, playable content, test results or device QA.
- Prefer a smaller complete, tested vertical slice over a larger unfinished feature set.


## Follow-up maintenance candidate — rebased on current main

Branch `fix/headless-resource-cleanup-current-main` is based on main `0785d76c86f6a4b1eafcec54ccb54ca3b5299acc`. It frees the temporary PartyScreen synchronously in the headless UI test, drains deferred child-node deletion over two SceneTree frames, releases the GameData Node in the standalone balance report before quitting, and disables Blender import because the tracked tree contains no `.blend` files. This candidate must pass exact-head CI on the rebased source before merge; it changes no gameplay, save schema, game version or permissions.


## Tactical AI pathfinding follow-up — 2026-11-10

PR #123 merged a change that passed ally cells to `BattleMap.compute_reach`, but that function intentionally ignored its fifth argument; its test checked only destination occupancy, not the route. Follow-up branch `fix/ai-block-allies-in-approach-paths` adds an explicit opt-in blocker flag and uses it only for AI reach/approach planning, preserving ordinary player ally pass-through. The corridor regression asserts both behaviors. This branch is pending exact-head CI; do not merge until all gates pass.
