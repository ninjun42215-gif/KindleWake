> **AUTHORITATIVE LIVE CHECKPOINT — 2026-11-10 13:02 UTC:** Canonical repository `ninjun42215-gif/KindleWake`; project directory `Kindlewake/`; default branch `main`; current main commit `68523bbbd78b5aa780ae15b2d06c47262536f0bc`. Merged milestones: PR #118 story-chain correction, #119 production audit/handoff, #121 Chronicle inter-house diplomacy, #122 headless resource cleanup, #123 initial AI ally-path change, #125 actual AI ally-blocking pathfinder, #126 unified realm backend, and #128 mobile realm administration UI/unlock flow. Game/Android version `0.12.0 / 1200`; save schema `4`; Godot `4.2.2`; level cap `250`; offline-first, no accounts, servers, multiplayer or INTERNET permission.

> **Verified current-main build:** [Android build #42820633100](https://github.com/ninjun42215-gif/KindleWake/actions/runs/42820633100) passed 18/18 scene loads, 948 strict checks / 0 failures, campaign lifecycle (0 failures), Act V checks, 70 campaign-continuity checks, 39 Chronicle dynasty checks, 19 Chronicle family-development checks, balance simulation and signed APK export. Project Health Audit [#42820633040](https://github.com/ninjun42215-gif/KindleWake/actions/runs/42820633040), Version Sync [#42820633003](https://github.com/ninjun42215-gif/KindleWake/actions/runs/42820633003), Workflow YAML Lint [#42820633101](https://github.com/ninjun42215-gif/KindleWake/actions/runs/42820633101) and source handoff [#42820632950](https://github.com/ninjun42215-gif/KindleWake/actions/runs/42820632950) passed. APK artifact `13767006152` (41,200,629-byte archive; APK 41.6 MB). The previous ObjectDB/resource-shutdown and Blender-import warnings are absent. Remaining non-blocking diagnostics: transient first-pass global-class registration errors followed by a clean import retry, a headless custom-cursor warning, and GitHub Actions Node.js deprecation notices.

> **Current gameplay systems:** AI pathfinding routes around occupied allies while ordinary player movement preserves ally pass-through. Realm administration now has a mobile-first Holdings/Realm UI, shared-treasury summary, tax controls, governor appointments and royal policy cards; it unlocks after the first external stronghold is claimed. Governor assignments are unique, cleared on loss of territory and normalized against current ownership/roster. Existing holding governance, garrisons, buildings, recruitment and siege actions remain available. Governor-specific stat bonuses are not yet implemented.

> **Next priorities and release gates:** Regional trading PR #81 remains unready due to cargo inventory, foreign-tariff authorization, region-gate bypass, invalid route endpoints and mobile layout issues; do not merge it as-is. Physical Android viewport/touch QA remains outstanding. Third-party sprite/voxel asset redistribution rights remain a public/commercial release blocker until verified or replaced. See [PRODUCTION_AUDIT_2026-11-10.md](PRODUCTION_AUDIT_2026-11-10.md) for the current roadmap and integration decisions. The current main source is authoritative; older checkpoint notes below are archival.

---

> **HISTORICAL CHECKPOINTS:** Everything below this marker is archived development history. Use the live main commit and exact-head CI above as the current source of truth.


> **HISTORICAL CHECKPOINTS:** Notes below this marker predate the current realm-UI candidate. Verify live refs and exact-head CI before relying on earlier statuses.


> **HISTORICAL CHECKPOINTS:** Everything below this marker is archived development history. Use the live main commit and exact-head CI above as the current source of truth.


> **HISTORICAL CHECKPOINTS:** Notes below this marker predate the current realm-administration candidate. Verify live refs and exact-head CI before relying on earlier statuses.


> **HISTORICAL CHECKPOINTS:** Notes below this marker predate the current tactical-AI candidate. Verify live refs and exact-head CI before relying on earlier statuses.


> **ARCHIVED PRIOR CHECKPOINTS:** The notes below predate this rebased maintenance candidate. Verify live refs and CI before treating any branch, SHA or validation result as current.


> **HISTORICAL HANDOFF NOTES:** Everything below this marker is retained as development history. Re-check live GitHub refs and workflows before relying on old PR numbers, SHAs, branch names or test counts.


> **LIVE PROJECT CHECKPOINT — 2026-11-10 (post-merge):** Canonical repository `ninjun42215-gif/KindleWake`; default branch `main`. PR #28 (v0.12.0 world expansion), PR #30 (Chapter I + creator fixes), PR #31 (verified CI handoff) and PR #32 (final post-merge handoff state) are merged. There is no active implementation branch for this milestone; inspect the live `main` ref before starting new work.
>
> **Project state:** Godot 4.2 / GL Compatibility, game and Android version `0.12.0`, Android version code `1200`, save schema `4`. Preserve all existing systems, JSON data and saves. No version/schema change was needed.
>
> **Phase 0/1 complete:** Chapter I courtyard movement uses `Control._gui_input()` for taps and drags, responsive playable bounds, gate placement below the objective card, and a 120px reach radius. The title screen mounts the creator as a full-screen overlay; portrait preview and compact live summary stay pinned above the scrolling form on narrow portrait phones. Pure responsive-layout regression checks and an all-scene headless smoke test are in place. Root ignore rules are installed and five superseded root-level `Feature_*.zip` snapshots are removed. The canonical extracted project remains `Kindlewake/`; no root `Kindlewake_Project.zip` existed to archive.
>
> **CI evidence:** runtime-code commit `b2598c3c8620a701d1fabd84394ec5cbb7449451` passed Godot 4.2.2 import (clean retry), 8/8 scene smoke loads, 427 strict checks with 0 failures, balance simulation, signed Android APK export (~40.8 MB) and zero requested Android permissions. Build run [#633](https://github.com/ninjun42215-gif/KindleWake/actions/runs/42731540020), APK artifact `13724652587`. Version Sync #139, Project Health Audit #348 and Workflow YAML Lint #526 passed. Documentation-only PR #31 also passed Build Android APK #635, Project Health Audit #350, Version Sync #141 and Workflow YAML Lint #539 before merge. The first editor import scan still logs transient global-class registration errors before its clean retry; ObjectDB/resource-cleanup warnings remain non-failing.
>
> **Remaining QA:** physical Android testing is not yet recorded. Verify 20:9 portrait and landscape, safe areas/notches, title → creator → BACK, Prologue → escape → battle → World, victory flag, kill/relaunch and Continue/save-load. CI is not device QA.
>
> **Next step:** complete physical Android QA and report findings. Stop before Phase 2 (Theme/fonts/SceneRouter) until the owner approves.
>
> **Current architecture:** JSON data remains under `Kindlewake/data/`; autoloads remain `GameData`, `SaveSystem`, and `GameState`; core rules remain under `Kindlewake/scripts/core/`; tactical rules under `Kindlewake/scripts/battle/`; UI remains code-built under `Kindlewake/scripts/ui/` with one-node scene shells. Courtyard mission rules remain in `EscapeMission`; responsive layout math is isolated in `EscapeLayout`. The creator emits the existing validated profile contract. Tests: `Kindlewake/tests/run_tests.gd` and `Kindlewake/tests/scene_smoke_test.gd`; Android build orchestration: `Kindlewake/tools/build_apk.py`. The next approved milestone after device QA is Phase 2: shared Theme, bundled OFL fonts, safe-area helper, SceneRouter, UIFX and AudioManager.
>
> **Hard constraints:** fully offline; no accounts, servers, multiplayer or INTERNET permission. Preserve saves and schema compatibility. The unresolved third-party sprite-pack redistribution licence remains a public/commercial release blocker until verified or replaced.

---

> **ARCHIVED HISTORY ONLY:** The earlier milestone notes below record prior development sessions. They are superseded by the consolidated 0.12.0 candidate checkpoint at the top of this file. Do not use old branch names, SHAs, PR states, version numbers or APK artifact IDs below as the current repository state.

> **LIVE CHECKPOINT — 2026-11-10: Seven-continent atlas implementation in progress.** Active branch: `feature/seven-continent-world-atlas`, based on `main` after PR #26. PR #26 (Dunmarrow courtyard escape mission) merged successfully as `dd2d826844b230f834c58d74b1a0d298074c8774`. Exact head `9dc88818555d297f48fe35ac91faf14e86d293d8` passed Build Android APK (run `42718648871`), Project Health Audit (`42718648820`), Workflow YAML Lint (`42718648838`) and Version Sync (`42718649138`). APK artifact `13719287111` (40,804,433 bytes); test logs artifact `13719521628`. The build completed Godot import, strict tests, balance report and APK export successfully.

> **Atlas implementation:** PR #27 is open at `https://github.com/ninjun42215-gif/KindleWake/pull/27`. It preserves the repository's original continent canon (Eldrimar, Thalassar, Varakhan and Nhalor), expands it with Veyrwood, Asterreach and Ilyr, and adds a runtime-loaded global atlas with seven authored vector silhouettes. Each continent has a capital, government, climate, identity, conflict, signature places, at least four named macro-regions and a campaign hook. Existing Eldrimar region/town/dungeon/route blueprint remains intact. The existing 64×48 Sethmarch Frontier remains the only playable continent map. Other six are inspectable but story-locked until their playable regional content exists. World Atlas is reachable from the overworld HUD and preserves regional player position. Added headless data-integrity tests. No save-schema change.

> **Validation gate:** PR #27 must pass exact-head Godot import, strict tests, balance report, Android APK export, YAML lint, version sync and project health audit. Inspect failures and fix them before merge. Do not claim all seven continents are fully playable; this milestone ships the global atlas and authored world blueprint only.

# KindleWake — live session handoff (2026-11-10)

**Canonical repository:** `ninjun42215-gif/KindleWake`  
**Canonical project directory:** `Kindlewake/`  
**Default branch:** `main`  
**Latest verified main commit at handoff creation:** `843d21be5b201b95736e98a38f0485274e5dcc03`  
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

## PR #17 validation and current source handoff

- PR #17 merged automatically as `github-actions[bot]` at `843d21be5b201b95736e98a38f0485274e5dcc03` after all four required checks passed on PR head `91660c021144b53719e5cca43de6b3d946f2880b`.
- Build Android APK: run `42708085011` passed; 342 strict checks, 0 failures; balance report completed; signed 41.2 MB APK exported for arm64-v8a and armeabi-v7a; no Android permissions requested. First Godot import emitted transient global-class registration errors, then the clean second scan succeeded; preserve this as a warning to investigate, not a test failure.
- Version Sync: run `42708084633` passed. Workflow YAML Lint: `42708084644` passed. Project Health Audit: `42708084771` passed.
- Safe Auto Merge: run `42708329157` passed; PR #17 was merged by the bot.
- Portable source handoff: run `42708064822`, artifact `13714701100`, generated from PR head `91660c021144b53719e5cca43de6b3d946f2880b`. Its tracked source tree is the tree merged by PR #17. 177 tracked files, 4 parts, all at or below 25,000,000 bytes. Reconstructed archive SHA-256: `aba0eea9f02f0ca1c96be8ac91259cef50ba6c71145cca41c349ec5f4d76d976`; artifact ZIP SHA-256: `9d9f5c78b6544ef354a625c7394d2c5f6a5cb018a5613b9b7c0a808ec44f0669`.
- APK artifact ID `13715145936`; test logs artifact ID `13715305665`. Run page: https://github.com/ninjun42215-gif/KindleWake/actions/runs/42708085011.

## CI and handoff status

- Latest exact main SHA: `843d21be5b201b95736e98a38f0485274e5dcc03`.
- APK build and all required checks passed on PR #17's exact source tree, which was merged unchanged at the main SHA above. No separate push-triggered APK build ran for the merge commit (GitHub token-triggered workflow behavior).
- A fresh source-handoff artifact was generated for PR #17's exact source tree; the merge commit has the same merged tree. The artifact is available from run 42708064822 (details above).
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
- Main commit: https://github.com/ninjun42215-gif/KindleWake/commit/843d21be5b201b95736e98a38f0485274e5dcc03
- Actions: https://github.com/ninjun42215-gif/KindleWake/actions
- PR #16: https://github.com/ninjun42215-gif/KindleWake/pull/16
- PR #14: https://github.com/ninjun42215-gif/KindleWake/pull/14


---

# AUTHORITATIVE LIVE CHECKPOINT — 2026-11-10 (Premium Pass v1 merged)

- Repository: `ninjun42215-gif/KindleWake`; default branch `main`; merged commit: `b78fc7847f166ea51290d0cd15c8b954a4034350` (PR #34).
- Project baseline remains Godot 4.2 / GL Compatibility, game/Android version 0.12.0, Android version code 1200, save schema 4. No game version, save schema, gameplay data or permissions changed.
- Premium Pass v1: `KW` is now an autoload providing the brass/ink shared theme, button press feedback, optional font/audio hooks, haptics, opt-in fade transitions and persistent haptics/reduce-motion/UI-SFX settings. The Company overlay now stacks above the minimap. Battle turn chips use readable names; only active/inspected units get name tags; floating combat text has a wider outlined treatment.
- PR head `062677c8f8f7eb54300d31dfd2a16d67162b2763` passed all four required exact-SHA checks. Build run `42734417425`: Godot 4.2.2 import clean, 8/8 scene smoke loads, 427 strict checks / 0 failures, balance report pass, signed 41.2 MB APK, arm64-v8a + armeabi-v7a, no requested Android permissions.
- Post-merge main checks also passed on `b78fc7847f166ea51290d0cd15c8b954a4034350`: Build APK run `42734657735`; Version Sync `42734657698`; Workflow YAML Lint `42734657714`; Project Health Audit `42734657704`; source handoff `42734658083`.
- Main APK artifact: `13726900432`, 41,207,581 bytes, SHA-256 `e391fb8cdf308bd1419b3f0c382850c07c51817683a4560623b4d762ce2829cc`. Downloaded and locally verified as an APK archive. Test log artifact: `13725404960`.
- Receiving intake: both reviewed ZIPs removed; only `Kindlewake/receiving/README.md` remains. Full review and disposition are in `Kindlewake/docs/RECEIVING_REVIEW_2026-11-10.md`.
- Limitations: the ZIP did not contain fonts, audio, portraits or tiles, so those are not bundled; the game remains without new SFX/music. Physical Android QA is not recorded. The third-party voxel pack redistribution licence remains unresolved and blocks public/commercial release.
- Existing non-failing Godot ObjectDB/resource cleanup warnings remain in the test log. Do not report them as test failures, but keep them on the cleanup backlog.
- Next: continue Premium Pass Sprint 1 in small tested slices (licensed font/audio integration, compact world HUD icon bar, title/world atmosphere and responsive label treatment); then Company/recruit portrait/icon pass and battle HUD work. Preserve all systems and saves; do not add unverified assets. Device QA remains a separate gate.

---



---

# CURRENT IMPLEMENTATION HANDOFF — CAMPAIGN FACTIONS (2026-11-10)

- Working branch: `feature/campaign-factions-diplomacy`, created from the verified `main` ref `c1069d116e234a17437bd93af9b0282ca255f31b`. Do not edit `main` directly.
- Added `data/factions.json` with the major political powers already established by `data/continents.json`, plus a starting affiliation for every atlas region. No new continent or region has been invented.
- Added `scripts/core/faction_system.gd` for bounded relation values, treaty/war states, alliance trust gating, validated region transfers, history and safe normalization.
- `GameData` loads faction definitions. `GameState` initializes faction state for new campaigns, exposes APIs for authored story outcomes and includes the optional state in campaign payloads. Existing schema-4 saves remain compatible through defaults.
- Added strict regression assertions in `tests/run_tests.gd` for atlas-region coverage, diplomacy thresholds, territory validation, history and legacy defaults.
- Current scope is backend foundation only. No diplomacy screen, automatic war simulation, AI faction turns or strategic battle layer is claimed complete.
- Validation on code head `f7b31035e4651a4a6854cc5ad644beff88c2148b`: Build Android APK run #683 passed Godot 4.2.2 import (clean retry), 8/8 scene smoke loads, 447 strict checks / 0 failures, balance report and signed APK export for arm64-v8a + armeabi-v7a with no requested Android permissions. APK artifact `13733346417` (~41.0 MB); test logs artifact `13732869336`. Version Sync #188, Workflow YAML Lint #666 and Project Health Audit #458 also passed on that exact code head. The first CI attempt caught a missing `GameData.factions` declaration and a strict-test type inference error; both were fixed before the successful rerun. Documentation commits after that code head require a fresh exact-head gate. Physical Android QA remains outstanding.
- Next implementation slice after this foundation: connect authored quests/choices to relation changes, then add a compact faction dossier UI before enabling player-initiated treaty/war actions. Preserve offline-only architecture, existing saves and schema 4.


---

## QA and Android release-readiness refresh — 2026-11-16

### Live baseline and verified build
- Current `main`: `da4d220de7cdbfeae0d2bc182a3c191b997cd861` (Godot 4.2.2, game/Android 0.12.0 / code 1200, save schema 4).
- Exact-main Android build: [run #42821049869](https://github.com/ninjun42215-gif/KindleWake/actions/runs/42821049869). Result: 18/18 scene loads; 948 strict checks / 0 failures; campaign lifecycle, Act V, 70 campaign continuity, 39 Chronicle dynasty and 19 Chronicle family-development checks passed; balance report passed; APK signature valid; no Android permissions requested.
- Exact-SHA companion checks: Project Health Audit [#42821049944](https://github.com/ninjun42215-gif/KindleWake/actions/runs/42821049944), Version Sync [#42821049780](https://github.com/ninjun42215-gif/KindleWake/actions/runs/42821049780), Workflow YAML Lint [#42821049916](https://github.com/ninjun42215-gif/KindleWake/actions/runs/42821049916), source handoff [#42821050055](https://github.com/ninjun42215-gif/KindleWake/actions/runs/42821050055).
- Exact-main APK artifact: `13767016313`, archive 41,200,735 bytes, SHA-256 `676584a761743ebbaf60fca1011fe458b6ab39d3c2c45da4f1e2bc029e3077d2`; artifact metadata ties it to run #42821049869 and SHA `da4d220de7cdbfeae0d2bc182a3c191b997cd861`. Build log confirms signature validity and zero requested Android permissions.
- Import diagnostics: first import scan reported unresolved global classes (`CharacterSheet`, `BattleUnit`, `BattleMap`); clean retry then completed, 18 scenes loaded and strict suites passed. Continue investigating this startup/import-order warning rather than hiding it. Headless custom-cursor and Actions Node.js runtime deprecation warnings remain.
 
### Current PR and workflow triage
- PR #130 (`docs/authentication-security-model`, head `d2ab36d73e71e69965f6658aa18e8642f3e52daa)): Build APK #43792465999, Version Sync #43792465983, Workflow YAML Lint #43792465988 and Project Health Audit #43792465990 all passed on its exact head. It remains draft.
- Safe Auto Merge run [#43792636541](https://github.com/ninjun42215-gif/KindleWake/actions/runs/43792636541) failed at its eligibility gate because PR #130 is draft. The log explicitly says it refused to merge; this is an intentional fail-closed refusal, not a game/build test failure. Do not merge or mark the PR ready without authorization.
- PR #81 trading branch: 3 ahead / 29 behind main, diverged; keep blocked pending cargo inventory separation, tariff/route ownership, canonical region/story-gate validation and mobile layout fixes.
- PR #42 bestiary: 21 ahead / 44 behind main, diverged; rebase and exact-head test before integration.
- PR #46 empire system: 261 ahead / 44 behind main, diverged; use only as a reference, extract reviewed slices rather than bulk merge.
- PR #78 headless test gate: 70 ahead / 43 behind main and stacked on the boss simulation branch; preserve dependency order.
- PR #130: 2 ahead / 0 behind main, documentation-only.
- Production publishing remains a separate manual workflow requiring a version tag, explicit `PUBLISH` confirmation and the `android-production` environment. Never use it as a routine QA build.

### Asset and release gates
- The live provenance ledger marks runtime-used assets verified: Quaternius nature art (CC0), Zerie's Free Soldier/Orc subset (author terms permit game use/modification; no standalone source-pack redistribution), and original KindleWake vector art.
- Legacy voxel-building PNGs are recorded as unused and replaced in-game by original SVG settlement illustrations. Restricted/unknown optional packs remain unused. The current ledger has no unverified asset marked as used in-game; keep it synchronized with `assets/art/CREDITS.md` and inspect before each release.
- Physical Android QA is still outstanding: test touch targets, viewport/safe areas, app pause/resume, long sessions, thermal/memory behavior and install/update/save preservation on low-memory and modern devices.

### QA workflow hardening candidate
- Dedicated branch: `qa/least-privilege-apk-build`, based on exact main SHA `da4d220de7cdbfeae0d2bc182a3c191b997cd861`.
- Commit `507d41d0eb25372d16a4330ea85f96688f66b4fb`: routine APK build workflow now defaults to `contents: read`; write access is isolated to a tag-only release job that depends on the successful APK build and downloads that run's artifact.
- Commit `d1a7f3c41fa3f5bb734d943793b9df6ffff48956`: added a YAML-lint policy assertion for read-only build permissions and isolated tag release.
- Commit `ceb4e9f1a5d24d4ecec253d56c6b4d30f7bdd0fe`: extended the lint guard to every non-release build job, so a future job cannot silently inherit write access.
- PR [#132](https://github.com/ninjun42215-gif/KindleWake/pull/132) is open as a draft; validated implementation head at this checkpoint: `e7d56027b09afdf28fd0767c24267c3b88dc9cc6` (2 ahead of current main before the handoff-only refresh). Push Workflow YAML Lint [#43793712360](https://github.com/ninjun42215-gif/KindleWake/actions/runs/43793712360) and PR checks all passed on that exact head: Build Android APK [#43793743671](https://github.com/ninjun42215-gif/KindleWake/actions/runs/43793743671), Version Sync [#43793743483](https://github.com/ninjun42215-gif/KindleWake/actions/runs/43793743483), Workflow YAML Lint [#43793743574](https://github.com/ninjun42215-gif/KindleWake/actions/runs/43793743574), Project Health Audit [#43793743525](https://github.com/ninjun42215-gif/KindleWake/actions/runs/43793743525). The PR build log confirms `GITHUB_TOKEN` has `Contents: read`; APK job passed, tag-release job was skipped because this was a PR, 18/18 scenes loaded, 948 strict checks / 0 failures, 70 campaign-continuity checks, 39 Chronicle dynasty checks, 19 family-development checks, balance report, valid APK signature and no requested Android permissions.
- PR-head APK artifact `14193164762`: 41,200,647-byte archive, SHA-256 `15552ff2497a5d0979652d2c69d4dd8c136ccc0709ac96aa50d26c0fd14f6435`; metadata ties it to run #43793743671 and the validated implementation head above. The import scan still emits transient first-pass global-class compile errors before subsequent scene/tests/build complete; keep investigating this known warning.
- The session-handoff refresh itself creates a documentation-only commit and therefore advances the PR head; verify the newly triggered exact-head checks before reporting the final PR head as green. Keep PR #132 draft and do not merge.

---

## Mainline CI follow-up — 2026-11-16 02:49 UTC

- Main advanced independently from `da4d220de7cdbfeae0d2bc182a3c191b997cd861` to `8a1f9e4227c3541c34e17593bb317a88c1c2d7a6` with a focused `.github/workflows/safe-auto-merge.yml` fix. This is not part of QA PR #132; do not overwrite or duplicate it.
- The new mainline SHA passed Build Android APK [#43794234232], Project Health Audit [#43794234198], Version Sync [#43794234203], Workflow YAML Lint [#43794234269] and source handoff [#43794234231]. Exact-main APK artifact `14194230922`, 41,200,677 bytes, SHA-256 `49873ba30a3eab807482734bf3881d84d72d6b03d1e769d43b73988d571d74f3`; log confirms valid signature and no requested Android permissions.
- The Safe Auto Merge run [#43794410915] succeeded and explicitly skipped draft PR #132 as ineligible. This verifies the mainline no-op fix against the QA PR; no merge was attempted.
- QA PR #132 remains open/draft. At the validated implementation snapshot, head `5d9af862758e327d637667d655f4f41b3cdb3db6` passed all four core PR checks and produced APK artifact `14193309006` (41,200,583 bytes; SHA-256 `d0e54f24cf4bb28b1ecba3bb46287da4c68a06d450a0980c16fcf37368e25532`). The subsequent README/session-handoff refresh is documentation-only and will advance the branch again; recheck its exact-head PR workflows before final sign-off.
- Current comparison: QA branch is 8 commits ahead / 1 behind main and GitHub reports the PR mergeable. The one-behind commit is the independent safe-auto-merge fix; no conflicting file changes were observed. Keep the PR draft and do not merge.
