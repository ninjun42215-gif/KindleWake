> **CONSOLIDATED 0.12.0 DEVELOPMENT CANDIDATE — 2026-11-10:** Canonical repository `ninjun42215-gif/KindleWake`; verified `main` baseline is `eb589c08b40b639a83b45bcc8d10718fd8223d7a`, game/Android version `0.11.0 / 1100`, save schema `4`. All new work is isolated on `docs/authoritative-live-handoff-2026-11-10` and consolidated in **one** PR: [#28](https://github.com/ninjun42215-gif/KindleWake/pull/28). Main and its APK have not been changed by this candidate. Do not build, distribute or describe a new APK as released until the full candidate passes CI and the one PR is merged.
>
> **Candidate upgrade:** project version `0.12.0`, Android version code `1200`, save schema remains `4` (new region fields are additive and legacy schema-4 saves default safely to Sethmarch). The branch now contains the approved [Premium Production Bible](Kindlewake/docs/PREMIUM_PRODUCTION_BIBLE.md), a separate 64×48 Brinegate Coast overworld, Brinegate/Saltmere/Lantern Quay town maps, Tideglass Grotto dungeon and tactical battle, the Tidebound sea-charter unlock from Eldrimar, region-specific coastal rendering, Maren Vey recruitment, a persistent ledger quest with public/private outcomes, per-region save positions, and automated tests for map connectivity, recruitment, quest idempotency and old-save restoration.
>
> **Implementation honesty:** these features exist on the candidate branch but are not yet CI-validated or merged. The rest of Thalassar (Isles of Vey, Kelpward Reach and Deepwake Reach), the Wreck-King's Hold and Old Beacon Vault are still future content; do not present all seven continents as explorable. The production bible is a quality standard, not proof that every proposed portrait, animation, audio cue or asset pack has shipped. Unknown third-party asset licences remain a release blocker.
>
> **Single-delivery rule:** keep improving this same branch and PR #28; do not create separate feature PRs or run an APK release for partial work. Before merge, validate Godot import, the full strict test suite, battle simulation/balance, Android export, YAML lint, version sync and project health on the exact final PR head SHA. Fix failures, refresh the handoff, mark this PR ready, and use the exact-head safe merge guard. Physical Android QA remains separate from CI. The game remains fully offline and must not request INTERNET permission.


---

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
