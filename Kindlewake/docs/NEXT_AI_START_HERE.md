> **AUTHORITATIVE LIVE CHECKPOINT — 2026-11-10 (verified against GitHub main):** Canonical repository `ninjun42215-gif/KindleWake`, default branch `main`, latest main commit `eb589c08b40b639a83b45bcc8d10718fd8223d7a` (seven-continent atlas milestone). Project version is **0.11.0**, Android version name/code **0.11.0 / 1100**, and save schema **4**. Sources of truth checked: `Kindlewake/project.godot`, `Kindlewake/export_presets.cfg`, and `Kindlewake/scripts/core/save_system.gd`. Save schema 4 includes the recruitment/company-loyalty migration from schema 3; preserve it and add future migrations rather than resetting saves.
>
> **Merged campaign/gameplay milestones:** opening prologue choices and the playable Dunmarrow courtyard escape are merged; the seven-continent runtime atlas is merged. The atlas preserves Eldrimar, Thalassar, Varakhan and Nhalor and adds Veyrwood, Asterreach and Ilyr. Eldrimar/Sethmarch remains the only playable regional overworld at this checkpoint. Thalassar's Brinegate Coast is currently a world-data blueprint (Brinegate, Saltmere, Lantern Quay, Tideglass Grotto, Wreck-King's Hold and Old Beacon Vault), **not a playable region**. Do not claim the other continents are explorable.
>
> **Current GitHub state:** Main points to `eb589c08b40b639a83b45bcc8d10718fd8223d7a`. The latest commit-run lookup and combined status lookup returned no entries; this is **not evidence of a successful post-merge Android build**. Do not claim a current APK artifact or percentage without a fresh successful workflow run and artifact check. Two old creative-direction PRs remain open: [#22](https://github.com/ninjun42215-gif/KindleWake/pull/22) and [#23](https://github.com/ninjun42215-gif/KindleWake/pull/23). They target an older main base and overlap the production direction now present in the GDD; inspect their exact diffs before closing or merging. PR #23 currently reports non-mergeable. Do not merge either blindly.
>
> **Immediate production priority:** create a fully playable, touch-first Brinegate Coast vertical slice. Audit the existing `WorldMap`, `world_scene.gd`, `locations.json`, `GameState`, battle/encounter data and test harness first. Add a region identity/selection model without breaking Sethmarch saves; author Brinegate as a real regional map with connected port hub, Saltmere and Lantern Quay, discoverable routes, a first dungeon/encounter, at least one consequential quest, recruitable sailor(s), and a story reveal tied to the Covenant's unbinding. Add deterministic data and save-migration tests. Reuse the existing battle, location, recruitment and dialogue systems where sound; do not build a disconnected demo.
>
> **Release gates remain:** real Android-device QA, current-main APK verification, and authoritative redistribution/licence proof for any voxel/sprite packs. The game must remain fully offline with no INTERNET permission. Keep all edits on short-lived feature branches and PRs. Require all four core PR checks plus every discovered PR-triggered workflow to pass on the **same exact head SHA**; merge only through the expected-head-SHA safe merge guard after GitHub confirms mergeability. Never push directly to main or force-push.
>
> **Handoff rule:** inspect live main, branches, PRs, workflows and source files before each task. This checkpoint supersedes all older version/SHA/PR-status statements below; historical notes are retained for traceability, not current truth.

---



# KindleWake — Next AI Start Here

**Repository:** `ninjun42215-gif/KindleWake`  
**Project directory:** `Kindlewake/`  
**Branch:** `main`  
**Latest inspected main SHA:** `d25ac6840ab0cdcc339b6fa89ed4ef42dec917dc`  
**Godot version:** `0.10.0` · **Android code:** `1000` · **Save schema:** `3`  
**Timezone:** Asia/Manila (UTC+08:00)

## Start here — no user re-explanation required

1. Read `Kindlewake/docs/SESSION_HANDOFF.md`, `Kindlewake/docs/GDD.md`, `Kindlewake/docs/CONTINUATION_PROMPT.md`, `Kindlewake/docs/VERSIONING.md` and `Kindlewake/docs/SAFE_AUTO_MERGE.md`.
2. Inspect the live `main` SHA, branches, open PRs and exact-head CI before editing. The SHA above is the inspected checkpoint, not a substitute for a live check.
3. The canonical source is the ordinary tracked files under `Kindlewake/`. Do not ask the user for a master project ZIP.
4. Use a feature/workflow branch and PR. Never write directly to main or force-push. Allow automatic merge only after all required exact-SHA checks pass and GitHub reports the PR is mergeable.
5. Always preserve offline-only behavior, save compatibility, asset provenance and the current version source of truth.

## Current facts

- PR #16 is merged; main was `843d21be5b201b95736e98a38f0485274e5dcc03` when inspected.
- `project.godot` says `0.10.0`; Android export name/code and `SaveSystem.GAME_VERSION` say `0.10.0` / `1000`; `SAVE_VERSION=3`.
- GDD notes extend to `0.10.4`, but the project version was not bumped. Audit those notes against actual scenes/scripts/tests before calling them shipped or validated.
- No open PRs were found at inspection time.
- The available PR-run lookup returned no PR-triggered runs for current main and combined status had no entries. Post-merge main APK status is therefore unverified.
- Historical successful automation: PR #14 four-check exact-SHA gate; PR #16 was merged by the bot after its checks. Check live Actions for current evidence.
- No fresh source-handoff artifact for `843d21be5b201b95736e98a38f0485274e5dcc03` has yet been verified. Older artifacts are stale.
- Physical Android QA is still outstanding.
- Voxel-building pack redistribution rights remain unresolved; public/commercial release is blocked until verified or assets are replaced.

## Latest verified CI and handoff

- PR #17 merged by `github-actions[bot]` at `843d21be5b201b95736e98a38f0485274e5dcc03` after all four exact-SHA checks passed on `91660c021144b53719e5cca43de6b3d946f2880b`.
- Build Android APK run `42708085011`: 342 strict checks, 0 failures; balance report passed; signed 41.2 MB APK, arm64-v8a + armeabi-v7a, no permissions. APK artifact `13715145936`; logs artifact `13715305665`.
- Version Sync `42708084633`, Workflow YAML Lint `42708084644`, Project Health Audit `42708084771`: all passed.
- Safe Auto Merge run `42708329157` succeeded.
- Source handoff run `42708064822`, artifact `13714701100`: 177 tracked files, four verified parts, reconstructed archive SHA-256 `aba0eea9f02f0ca1c96be8ac91259cef50ba6c71145cca41c349ec5f4d76d976`. The PR head source tree was merged unchanged into main.
- The first Godot import produced transient global-class registration errors; the build script's clean second scan succeeded, then all 342 checks passed and APK export succeeded. Investigate this import warning separately.

## Next work — execute, do not merely propose

1. Audit GDD `0.10.1`–`0.10.4`: responsive UI, battle identity overlays, receiving intake and portable handoff packaging. Inspect actual files and tests; report exact evidence and gaps.
2. Verify or trigger a strict Godot import/test/balance/APK build on current main.
3. Locate the source handoff workflow, generate an artifact for the exact current source SHA and verify its SHA-256 manifest and each part is at most 25 MB.
4. Choose the next highest-value campaign feature from the GDD based on the audit; implement a complete, tested vertical slice rather than adding disconnected systems.
5. Update GDD, README, session handoff and continuation prompts in the same PR.

## Fixed product constraints

- Godot 4.2+, GDScript, GL Compatibility, touch-first landscape/mobile support.
- Fully offline: no accounts, servers, multiplayer or INTERNET permission.
- Original KindleWake IP only. Preserve existing lore, systems and save migrations.
- Do not claim runtime/device testing without evidence.
- Keep restricted/uncertain assets out of release builds until licence provenance is clear.

## Automation and merge safety

Required checks for a merge: Build Android APK, Version Sync, Workflow YAML Lint and Project Health Audit on the **same exact PR head SHA**. The merge must reject stale heads, missing/failed checks, drafts, conflicts, wrong base branches and ambiguous PR discovery. Use expected-head-SHA REST merge; never bypass the gate for convenience.

## Links

- Main: https://github.com/ninjun42215-gif/KindleWake/tree/main
- Actions: https://github.com/ninjun42215-gif/KindleWake/actions
- PR #16: https://github.com/ninjun42215-gif/KindleWake/pull/16
- PR #14: https://github.com/ninjun42215-gif/KindleWake/pull/14
