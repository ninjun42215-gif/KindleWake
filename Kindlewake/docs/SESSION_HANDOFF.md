# LIVE SESSION UPDATE — 2026-11-10

- Canonical main at session start: `6379826a992e67a2abd92a9a795d97cb1022e4ca`; Godot project version `0.11.0`.
- Current creative-direction branch: `feature/premium-narrative-ux-art-direction`.
- Added `Kindlewake/docs/PREMIUM_PRODUCTION_BIBLE.md`: a new story reframe, first-hour sequence, cast-writing standard, choice/consequence architecture, healthy 45–90 minute session design, mobile UX quality bar, visual/asset production bible, audio direction and vertical-slice acceptance criteria.
- This is a design/documentation foundation. It does **not** claim new playable scenes, dialogue UI, journal, art assets, portraits or audio have been implemented yet.
- Next implementation: audit the actual prologue/mission/scene systems; build a playable 45–60 minute first-region vertical slice with the journal, first keep choice and a meaningful non-elimination tactical objective. Keep save migration tests and asset licences in scope.
- Do not use the obsolete checkpoint statements below as live repository truth. Re-check the branch, PRs and Actions before proceeding.

---

> **ACTIVE IMPLEMENTATION CHECKPOINT — 2026-11-10:** Main is `b322c86fbb44696dfc85382f49478dcb5bce2cd9` (v0.10.0, Android code 1000, save schema 3). The active candidate is branch `feature/recruitment-system-v1-2026-11-10`; do not describe it as merged until its PR is merged. The candidate bumps the game to v0.11.0, Android code 1100 and save schema 4.
>
> **Recruitment v1 scope:** the data now defines all 24 Wave-1 named characters (4 starting members + 20 recruitable profiles). Fourteen recruit profiles were added; the six existing recruit definitions were aligned to their intended class/weapon identities. Six muster halls now expose the recruit roster. Recruitment validates duplicate flags, gold costs, story flags and companion prerequisites before atomically adding the member and recording the one-time world flag.
>
> **Company bonds:** each CharacterSheet now carries loyalty 0–100, the party screen displays its bond band, and story systems can adjust it through `PartyState.adjust_loyalty()`. Save schema v4 migrates v3 members to neutral loyalty 50 and preserves existing party/world data. Calendar-based desertion, weekly wages, personal-quest scenes and automatic loyalty event changes are not implemented yet; late Act IV recruits remain correctly gated behind the future `act_4_unlocked` flag.
>
> **Validation state:** implementation is committed on the feature branch but has not yet passed its new exact-SHA CI build. The next AI must inspect the branch head, run the full APK workflow and strict tests, fix every failure, then open a PR. Merge only after all four core PR checks and every discovered PR workflow pass for the same exact head SHA. Physical-phone QA remains separate.

> **LIVE CHECKPOINT — 2026-11-10 (supersedes older checkpoint statements below):** Current `main` is `d25ac6840ab0cdcc339b6fa89ed4ef42dec917dc` (tree `6ea221fa15ccc4d073215e5fbf3edb60386feae8`). This is the merged PR #19 result. Its tree is identical to tested PR head `769022ebee463a35af95e4cd9dfcab7a55e89cb7`; do not confuse differing commit ancestry with differing source contents. Project version remains 0.10.0, Android code 1000, save schema 3.
>
> **Verified Android build:** run `42711243963` (Build Android APK #525) succeeded on that exact source tree with Godot 4.2.2, 342 strict checks / 0 failures, balance report completed, signed 41.2 MB APK and no Android permissions. APK artifact `13715144284`; SHA-256 `e1f303c2c9f5ef73b527988636ef5e467f6162ca043c1f443ad3fa33ea833c72`. Build log artifact `13715523963`.
>
> **Verified portable handoff:** run `42711223545` generated artifact `13714769557` from the same tested source tree. It contains 177 tracked files in four parts (25,000,000; 25,000,000; 25,000,000; 93,428 bytes). Reassembled archive size 75,093,428 bytes; SHA-256 `b7abf92e4e8c3f5340afc1a6c20f0527698c167d60f2efde4cd9901cc23c968e`. ZIP CRC, all 177 file hashes and safe extraction passed.
>
> **Live GitHub state:** PR #19 is merged; no open PRs were found. The rune branch `feature/rune-system-v1` has no unique commits ahead of main and is 121 commits behind. Numerous historical branches remain; do not delete them without a separate stale-branch review. Safe Auto Merge run `42711476072` completed successfully.
>
> **Audit of GDD 0.10.1–0.10.4:** responsive HUD/company/world/town layout code exists in battle, party, world and location UI scripts; battle class/enemy identity overlays exist in `battle_scene.gd`; the receiving folder, source-handoff helper, safety tests and handoff workflow exist. Automated tests cover party-screen construction and TapCard gestures, but do not exercise a full viewport/orientation matrix or screenshot-level visual layout. No dedicated assertions verify the identity-art drawing. The 0.10.4 handoff pipeline was exercised successfully by the verified artifact above. These are implementation notes, not a released app-version bump.
>
> **Outstanding release gates:** physical Android QA (launch, safe areas, portrait/landscape, touch/scroll, rune fusion, shops, status effects, save/load and performance) and authoritative redistribution/licence verification for the voxel-building pack. Optional sprite packs remain source-only. The first Godot import log contained transient global-class resolution errors, although the final build summary and strict suite passed; investigate that warning separately. The balance/test logs also report ObjectDB/resource cleanup warnings; tests still completed with 342 checks and 0 failures.

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
