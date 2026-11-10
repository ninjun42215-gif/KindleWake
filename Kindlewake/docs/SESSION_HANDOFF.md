# Current session handoff — 2026-11-10

**Canonical repository:** `ninjun42215-gif/KindleWake`  
**Default branch:** `main`  
**Current main commit:** `036a17da88ab1b1037b224334dbfbbdcb392e195`  
**Project:** Godot 4.2.2 / GL Compatibility / offline-first  
**Version:** 0.12.0 · Android version code 1200 · save schema 4

Read [PRODUCTION_AUDIT_AND_ROADMAP.md](PRODUCTION_AUDIT_AND_ROADMAP.md) first. It is the current implementation inventory and integration plan. Older checkpoints below this section are historical records and must not be treated as current state.

## Current verified state

- Main includes semantic campaign-save validation, valid-backup recovery when the primary is malformed, malformed campaign write rejection, future-version downgrade protection, and isolated SaveSystem test storage. The test harness no longer writes into the player's real `auto_a` / `auto_b` save slots.
- Main exact-head CI run [#42804577127](https://github.com/ninjun42215-gif/KindleWake/actions/runs/42804577127) passed: 671 strict checks / 0 failures, 9/9 scene resources loaded, campaign restore → World startup lifecycle test with 0 failures, balance report, Android APK export/signature, Project Health Audit, Version Sync and Workflow YAML Lint.
- The first Godot editor import scan still logs a transient global-class registration error (`CharacterSheet`); the builder's clean second scan completes without unresolved script errors. ObjectDB/resource cleanup warnings remain at headless test exit and should be tracked separately.
- PR #100 is merged and the lifecycle test is now part of strict CI. PRs #102, #104 and #110 were closed as stale/duplicate work after their save-recovery changes were incorporated into main. PR #95 and #93 were closed as superseded by PR #100.
- Issue #36 (Android crash after character creation / Continue) remains open. Headless lifecycle coverage is not physical-device QA. Obtain Android logcat `FATAL EXCEPTION`, Godot stack trace, and a reproducible device sequence before claiming a root cause or fix.
- Issue #82 tracks integration and release readiness.

## Current main inventory

- 28 classes, 15 combat skills, 77 runes, 69 traits, five trait synergies, 40 personality event templates, 12 curated ambitions and 36 character definitions.
- 39 town/interior location maps and six battle definitions.
- Seven-continent atlas blueprint, but only two distinct overworld datasets are wired through `GameData.world_for_region()`.
- Tactical battle, character creation, party progression, gear/runes, traits/personality, free-roam exploration, faction foundations, authored quest chains, checksummed saves and battle restore validation are present.
- Generic companion quest framework, regional trading, full five-act campaign, Chronicle founder epilogue, realm/territory simulation, and a persistent node-based class skill tree are not integrated on main.
- No bundled music/SFX or font files are present. Most classes lack complete character sprite/portrait/animation coverage.
- Android is configured; iOS export/device QA is not.

## Integration snapshot

Recheck these branches against live main before touching them. Divergence counts are not quality scores.

| PR | System | Last observed divergence | Integration warning |
|---|---|---:|---|
| #42 | Regional bestiary / human enemies | 21 ahead / 26 behind | Touches GameState, encounters, characters and tests |
| #53 | Companion quest framework | 62 ahead / 25 behind | Large overlap in locations, GameState, save validation and tests |
| #61 | Dungeons / holdings / world expansion | 72 ahead / 24 behind | Overlaps world maps, location UI, economy and GameState |
| #81 | Regional trading | 3 ahead / 11 behind | Reconcile shared GameState, location, merchant UI and tests |
| #83 | Five-act continuity | 123 ahead / 25 behind | Stacked on Act V parent; do not merge independently |
| #87 | Territorial governance | 6 ahead / 8 behind | Overlaps other governance implementation |
| #88 | Founder epilogue / Chronicle | 132 ahead / 25 behind | Stacked on #83; parent must integrate first |
| #91 | Realm governance | 5 ahead / 6 behind | Overlaps #87 and #61; consolidate to one realm model |

PR #99 and #101 were closed without merge; however, current main contains 40 event definitions and 12 ambitions with GameState APIs. Verify actual gameplay trigger coverage and ambition assignment UX before claiming the whole system is complete. PR #80 is stale and must not be merged wholesale.

## Immediate next steps

1. Reproduce issue #36 on Android with logcat and test install, pause/resume, process kill, cold relaunch, Continue and autosave recovery.
2. Reconcile one vertical slice of the companion quest system before porting all 21 quests.
3. Integrate regional trade and faction diplomacy on current main.
4. Expand the world only when each region has a real map, routes, encounters, local maps, progression gates and save tests.
5. Choose one coherent governance/holdings/economy model rather than merging overlapping branches.
6. Integrate five-act continuity and then the founder epilogue in dependency order. Chronicle must remain gated behind the full ending, the ruler's explicit abolition of the empire, the founder's authored late-life epilogue, and a recorded natural old-age death.
7. Build and balance class talent trees after the current promotion/skill system is fully mapped.
8. Complete audio, typography, class/companion art, accessibility, performance and Android device QA.

## Engineering constraints

- Never commit directly to `main`; use focused pull requests.
- Preserve offline-first behavior and save schema 4 unless a separately reviewed migration is necessary.
- Reconcile each feature against the current main head; do not merge stale branches wholesale or merge stacked children before parents.
- Exact-head CI must include import, strict tests, scene smoke, campaign lifecycle, balance, Android export/signature and project audits.
- Physical-device QA is a separate release gate.
- Keep README, asset manifest, provenance ledger and production audit synchronized.

---

> **ARCHIVED HISTORICAL CHECKPOINTS BELOW:** These entries preserve prior-session evidence only. Their SHAs, branch names, PR states, version values, and release blockers are superseded by the current checkpoint above.

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
