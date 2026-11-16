> **AUTHORITATIVE LIVE CHECKPOINT — 2026-11-16 02:49 UTC:** Canonical repository `ninjun42215-gif/KindleWake`; project directory `Kindlewake/`; default branch `main`; current main commit `8a1f9e4227c3541c34e17593bb317a88c1c2d7a6`. Game/Android version `0.12.0 / 1200`; save schema `4`; Godot `4.2.2`; level cap `250`; offline-first, no accounts, servers, multiplayer or INTERNET permission.

> **Verified current-main build:** [Android build #43794234232](https://github.com/ninjun42215-gif/KindleWake/actions/runs/43794234232) passed on exact SHA `8a1f9e4227c3541c34e17593bb317a88c1c2d7a6`: 18/18 scene loads, 948 strict checks / 0 failures, campaign lifecycle, Act V, 70 campaign-continuity checks, 39 Chronicle dynasty checks, 19 Chronicle family-development checks, balance simulation, APK signature verification and no requested Android permissions. Project Health Audit [#43794234198](https://github.com/ninjun42215-gif/KindleWake/actions/runs/43794234198), Version Sync [#43794234203](https://github.com/ninjun42215-gif/KindleWake/actions/runs/43794234203), Workflow YAML Lint [#43794234269](https://github.com/ninjun42215-gif/KindleWake/actions/runs/43794234269) and source handoff [#43794234231](https://github.com/ninjun42215-gif/KindleWake/actions/runs/43794234231) also passed on the exact SHA. APK artifact `14194230922`: 41,200,677-byte archive, SHA-256 `49873ba30a3eab807482734bf3881d84d72d6b03d1e769d43b73988d571d74f3`. The import scan still emits first-pass global-class resolution diagnostics (`CharacterSheet`, `BattleUnit`, `BattleMap`); the subsequent scene, strict-test and APK verification stages pass. Headless custom-cursor and GitHub Actions Node.js runtime deprecation warnings remain.

> **QA workflow PR #132:** Draft PR [#132](https://github.com/ninjun42215-gif/KindleWake/pull/132), branch `qa/least-privilege-apk-build`, validated head `5d9af862758e327d637667d655f4f41b3cdb3db6`. Its Build APK [#43794271155](https://github.com/ninjun42215-gif/KindleWake/actions/runs/43794271155), Version Sync [#43794270986](https://github.com/ninjun42215-gif/KindleWake/actions/runs/43794270986), Workflow YAML Lint [#43794271000](https://github.com/ninjun42215-gif/KindleWake/actions/runs/43794271000) and Project Health Audit [#43794271009](https://github.com/ninjun42215-gif/KindleWake/actions/runs/43794271009) passed on that exact head. The APK job reports `Contents: read`, 18/18 scenes, 948 strict checks / 0 failures, valid signature and no requested permissions. Artifact `14193309006`: 41,200,583-byte archive, SHA-256 `d0e54f24cf4bb28b1ecba3bb46287da4c68a06d450a0980c16fcf37368e25532`. PR #132 remains draft and mergeable; its branch is 8 commits ahead / 1 behind current main because of a separate mainline CI fix. No merge has been performed.

> **Safe Auto Merge:** Mainline commit `8a1f9e4227c3541c34e17593bb317a88c1c2d7a6` repaired the privileged merge workflow: it now treats draft/ineligible PRs as safe no-ops and grants `contents: write` to the workflow that invokes the merge REST endpoint. [Run #43794410915](https://github.com/ninjun42215-gif/KindleWake/actions/runs/43794410915) completed successfully; its log confirms it skipped draft PR #132. Earlier red runs occurred before this fix. The workflow does not check out or execute PR code and retains exact-SHA eligibility checks.

> **Asset provenance:** The current `Kindlewake/data/asset_provenance.json` marks runtime-used assets as verified: Quaternius nature art is CC0; the Zerie Free Soldier/Orc subset is covered by the author's game-use/modification terms (do not redistribute the source pack standalone); original KindleWake SVG settlement/prop art is project-authored. Legacy voxel-building PNGs are retained but marked unused and replaced at runtime by original SVGs. Restricted/unknown packs are marked unused. No unverified runtime-used asset is recorded in the current ledger; recheck the ledger before each release. Physical Android device QA remains outstanding.

> **Current gameplay systems:** AI pathfinding routes around occupied allies while ordinary player movement preserves ally pass-through. Realm administration has a mobile-first Holdings/Realm UI, shared-treasury summary, tax controls, governor appointments and royal policy cards; it unlocks after the first external stronghold is claimed. Governor assignments are unique, cleared on loss of territory and normalized against current ownership/roster. Existing holding governance, garrisons, buildings, recruitment and siege actions remain available. Governor-specific stat bonuses are not yet implemented.

> **Next priorities and release gates:** Regional trading PR #81 remains blocked: its branch is 3 commits ahead / 29 behind main (diverged), with cargo-inventory, tariff/route authorization, story-gate, canonical-region and mobile-layout issues from prior review. PR #42 is 21 ahead / 45 behind; PR #46 is 261 ahead / 45 behind and too broad for bulk integration; PR #78 remains a stacked test/CI chain. PRs #130 and #132 remain drafts. Physical Android viewport, touch, pause/resume, long-session and low-memory testing remain outstanding.
---










# KindleWake — The Sundered Vow

Offline-first medieval tactical RPG built with Godot 4.2.2 (GDScript, GL Compatibility), targeting Android and iOS.

## Live project checkpoint

- Canonical source: tracked files under `Kindlewake/` in `ninjun42215-gif/KindleWake`.
- Current `main`: `496f6c6a8130c920e0d9ed96f5e323c016d67c01`; game/Android version `0.12.0 / 1200`; save schema `4`.
- PR #28 is merged. Its exact merged source passed the Android APK build, Project Health Audit, source-handoff snapshot, version synchronization and workflow YAML lint.
- Latest main APK artifact ID: `13720944780` (about 40.8 MB); build run: https://github.com/ninjun42215-gif/KindleWake/actions/runs/42724834624.
- Real-device Android QA and third-party asset redistribution licensing remain outstanding. Do not claim device QA or commercial-release readiness without evidence.

## Routine development

Edit ordinary tracked files under `Kindlewake/`; do not upload or rebuild a master project ZIP. Use a short-lived feature/workflow branch and pull request. The exact-SHA safe auto-merge gate requires the four core checks and every additional PR-triggered workflow discovered for that SHA to pass.

## Build an Android APK

Open **Actions → Build Android APK → Run workflow**. The workflow imports the Godot project, runs the strict headless tests and balance report, exports and verifies the signed APK, then uploads `Kindlewake-APK` and `test-logs` artifacts.

## Product constraints and release gates

- Fully offline: no accounts, servers, multiplayer or INTERNET permission.
- Local JSON data and local saves; preserve save migrations and schema compatibility.
- Optional sprite packs remain source-only pending licence and suitability review.
- Physical Android QA remains outstanding. CI is not proof of fit on a real phone.
- Public/commercial release remains blocked until the voxel-building pack's redistribution licence is verified or those assets are replaced.
- GDD notes 0.10.1–0.10.4 record implementation changes; the released project version remains 0.10.0.

See `Kindlewake/docs/SESSION_HANDOFF.md` and `Kindlewake/docs/NEXT_AI_START_HERE.md` before continuing work.
