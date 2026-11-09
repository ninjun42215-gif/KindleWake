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
