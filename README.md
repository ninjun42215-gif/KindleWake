> **AUTHORITATIVE LIVE CHECKPOINT — 2026-11-10 13:02 UTC:** Canonical repository `ninjun42215-gif/KindleWake`; project directory `Kindlewake/`; default branch `main`; current main commit `68523bbbd78b5aa780ae15b2d06c47262536f0bc`. Merged milestones: PR #118 story-chain correction, #119 production audit/handoff, #121 Chronicle inter-house diplomacy, #122 headless resource cleanup, #123 initial AI ally-path change, #125 actual AI ally-blocking pathfinder, #126 unified realm backend, and #128 mobile realm administration UI/unlock flow. Game/Android version `0.12.0 / 1200`; save schema `4`; Godot `4.2.2`; level cap `250`; offline-first, no accounts, servers, multiplayer or INTERNET permission.

> **Verified current-main build:** [Android build #42820633100](https://github.com/ninjun42215-gif/KindleWake/actions/runs/42820633100) passed 18/18 scene loads, 948 strict checks / 0 failures, campaign lifecycle (0 failures), Act V checks, 70 campaign-continuity checks, 39 Chronicle dynasty checks, 19 Chronicle family-development checks, balance simulation and signed APK export. Project Health Audit [#42820633040](https://github.com/ninjun42215-gif/KindleWake/actions/runs/42820633040), Version Sync [#42820633003](https://github.com/ninjun42215-gif/KindleWake/actions/runs/42820633003), Workflow YAML Lint [#42820633101](https://github.com/ninjun42215-gif/KindleWake/actions/runs/42820633101) and source handoff [#42820632950](https://github.com/ninjun42215-gif/KindleWake/actions/runs/42820632950) passed. APK artifact `13767006152` (41,200,629-byte archive; APK 41.6 MB). The previous ObjectDB/resource-shutdown and Blender-import warnings are absent. Remaining non-blocking diagnostics: transient first-pass global-class registration errors followed by a clean import retry, a headless custom-cursor warning, and GitHub Actions Node.js deprecation notices.

> **Current gameplay systems:** AI pathfinding routes around occupied allies while ordinary player movement preserves ally pass-through. Realm administration now has a mobile-first Holdings/Realm UI, shared-treasury summary, tax controls, governor appointments and royal policy cards; it unlocks after the first external stronghold is claimed. Governor assignments are unique, cleared on loss of territory and normalized against current ownership/roster. Existing holding governance, garrisons, buildings, recruitment and siege actions remain available. Governor-specific stat bonuses are not yet implemented.

> **Next priorities and release gates:** Regional trading PR #81 remains unready due to cargo inventory, foreign-tariff authorization, region-gate bypass, invalid route endpoints and mobile layout issues; do not merge it as-is. Physical Android viewport/touch QA remains outstanding. Third-party sprite/voxel asset redistribution rights remain a public/commercial release blocker until verified or replaced. See [PRODUCTION_AUDIT_2026-11-10.md](PRODUCTION_AUDIT_2026-11-10.md) for the current roadmap and integration decisions. The current main source is authoritative; older checkpoint notes below are archival.

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
