> **AUTHORITATIVE LIVE CHECKPOINT — 2026-11-16:** Canonical repository `ninjun42215-gif/KindleWake`; project directory `Kindlewake/`; default branch `main`; current main commit `da4d220de7cdbfeae0d2bc182a3c191b997cd861`. Game/Android version `0.12.0 / 1200`; save schema `4`; Godot `4.2.2`; level cap `250`; offline-first, no accounts, servers, multiplayer or INTERNET permission.

> **Verified current-main build:** [Android build #42821049869](https://github.com/ninjun42215-gif/KindleWake/actions/runs/42821049869) ran on that exact SHA and passed 18/18 scene loads, 948 strict checks / 0 failures, campaign lifecycle, Act V, 70 campaign-continuity checks, 39 Chronicle dynasty checks, 19 Chronicle family-development checks, balance simulation, APK signature verification and the no-permissions check. Project Health Audit [#42821049944](https://github.com/ninjun42215-gif/KindleWake/actions/runs/42821049944), Version Sync [#42821049780](https://github.com/ninjun42215-gif/KindleWake/actions/runs/42821049780), Workflow YAML Lint [#42821049916](https://github.com/ninjun42215-gif/KindleWake/actions/runs/42821049916) and source handoff [#42821050055](https://github.com/ninjun42215-gif/KindleWake/actions/runs/42821050055) also passed on the exact SHA. APK artifact `13767016313`: 41,200,735-byte archive, SHA-256 `676584a761743ebbaf60fca1011fe458b6ab39d3c2c45da4f1e2bc029e3077d2`; the build log reports a valid signature and no requested Android permissions. The first import scan emitted transient global-class resolution diagnostics (`CharacterSheet`, `BattleUnit`, `BattleMap`); the clean retry completed and the subsequent scene/test/build stages passed. Headless custom-cursor and GitHub Actions Node.js runtime deprecation warnings remain.

> **Asset provenance:** The current `Kindlewake/data/asset_provenance.json` marks runtime-used assets as verified: Quaternius nature art is CC0; the Zerie Free Soldier/Orc subset is covered by the author's game-use/modification terms (do not redistribute the source pack standalone); original KindleWake SVG settlement/prop art is project-authored. Legacy voxel-building PNGs are retained but marked unused and replaced at runtime by original SVGs. Restricted/unknown packs are marked unused. No unverified runtime-used asset is recorded in the current ledger; recheck the ledger before each release. Physical Android device QA remains outstanding.

> **Current gameplay systems:** AI pathfinding routes around occupied allies while ordinary player movement preserves ally pass-through. Realm administration has a mobile-first Holdings/Realm UI, shared-treasury summary, tax controls, governor appointments and royal policy cards; it unlocks after the first external stronghold is claimed. Governor assignments are unique, cleared on loss of territory and normalized against current ownership/roster. Existing holding governance, garrisons, buildings, recruitment and siege actions remain available. Governor-specific stat bonuses are not yet implemented.

> **Next priorities and release gates:** Regional trading PR #81 is not ready to merge: its branch is 3 commits ahead and 29 behind current main (diverged), and prior review identified cargo-inventory, tariff/route authorization, story-gate, canonical-region and mobile-layout issues. PR #42 is 21 ahead / 44 behind; PR #46 is 261 ahead / 44 behind and too broad for a safe bulk integration; PR #78 is a stacked test/CI chain. PR #130 is a two-commit documentation-only draft with all four core checks passing on its exact head; Safe Auto Merge correctly refused it because it remains a draft. See [PRODUCTION_AUDIT_2026-11-10.md](PRODUCTION_AUDIT_2026-11-10.md) and the latest QA handoff for detailed triage. Physical Android viewport, touch, resume and low-memory testing remain outstanding.
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
