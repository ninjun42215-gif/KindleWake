> **AUTHORITATIVE LIVE CHECKPOINT — 2026-11-10 12:46 UTC:** Canonical repository `ninjun42215-gif/KindleWake`; project directory `Kindlewake/`; default branch `main`; current main commit `b88f4da2c49a6de13f715604de502750e68ccf45`. Merged milestones: PR #118 story-chain correction, #119 production audit/handoff, #121 Chronicle inter-house diplomacy, #122 headless resource cleanup, #123 initial AI ally-path change, #125 actual AI ally-blocking pathfinder, and #126 unified realm administration backend. Game/Android version `0.12.0 / 1200`; save schema `4`; Godot `4.2.2`; level cap `250`; offline-first, no accounts, servers, multiplayer or INTERNET permission.

> **Verified current-main build:** [Android build #42818566073](https://github.com/ninjun42215-gif/KindleWake/actions/runs/42818566073) passed 18/18 scene loads, 945 strict checks / 0 failures, campaign lifecycle/continuity, Chronicle dynasty/family tests, balance simulation and signed APK export. Project Health Audit [#42818566176](https://github.com/ninjun42215-gif/KindleWake/actions/runs/42818566176), Version Sync [#42818566098](https://github.com/ninjun42215-gif/KindleWake/actions/runs/42818566098), Workflow YAML Lint [#42818566214](https://github.com/ninjun42215-gif/KindleWake/actions/runs/42818566214) and source handoff [#42818566233](https://github.com/ninjun42215-gif/KindleWake/actions/runs/42818566233) passed. APK artifact `13766128142` (41,198,600-byte archive; APK 41.6 MB). The previous ObjectDB/resource-shutdown and Blender-import warnings are absent. Remaining non-blocking diagnostics: transient first-pass global-class registration errors followed by a clean import retry, a headless custom-cursor warning, and GitHub Actions Node.js deprecation notices.

> **Current system boundaries:** AI pathfinding now treats allied occupied cells as blockers while ordinary player movement retains ally pass-through. Realm administration has a persisted backend (tax, stability, governors, policies) integrated with the existing shared `party.gold` and holding economy; it is gated by an authored campaign flag and does not yet have a player-facing administration screen or story unlock event. Regional trading PR #81 is not ready to merge; see the production audit for the identified inventory, authority, progression and mobile-layout blockers.

> **Release gates:** Physical Android-device QA remains outstanding. Third-party sprite/voxel asset redistribution rights remain a public/commercial release blocker until verified or replaced. Use [PRODUCTION_AUDIT_2026-11-10.md](PRODUCTION_AUDIT_2026-11-10.md) for integration decisions and the next milestone. The current main source is authoritative; historical checkpoint notes below are archival.

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
