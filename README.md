> **AUTHORITATIVE LIVE CHECKPOINT — 2026-11-10 12:33 UTC:** Canonical repository `ninjun42215-gif/KindleWake`; project directory `Kindlewake/`; default branch `main`; current main commit `84da6e400b7991d753bcc2cddeb02d854702b547`. PR #118 (Maren sequel), #119 (production audit/handoff), #121 (Chronicle inter-house diplomacy) and #122 (headless resource cleanup) are merged. Game/Android version `0.12.0 / 1200`; save schema `4`; Godot `4.2.2`; offline-first, no accounts, servers, multiplayer or INTERNET permission. The requested level cap of 250 is implemented and covered by strict tests.

> **Post-merge verification:** Current main CI passed 18/18 scene loads, 929 strict checks / 0 failures, campaign lifecycle and continuity tests, Chronicle dynasty/family checks, balance report, signed Android APK export, Project Health Audit, Version Sync, Workflow YAML Lint and source handoff. APK artifact `13764651354` (41,194,872-byte artifact archive); build run [#42816530381](https://github.com/ninjun42215-gif/KindleWake/actions/runs/42816530381). The previous ObjectDB/resource-shutdown and Blender-import warnings are no longer present. Remaining non-blocking diagnostics: transient first-pass global-class registration errors followed by a clean import retry, a headless custom-cursor warning, and GitHub Actions Node.js deprecation notices.

> **Release gates:** Physical Android-device QA remains outstanding. Third-party sprite/voxel asset redistribution rights remain a public/commercial release blocker until verified or replaced. See [PRODUCTION_AUDIT_2026-11-10.md](PRODUCTION_AUDIT_2026-11-10.md) for branch triage and the production roadmap. The current main source is authoritative; historical candidate notes below must not override it.

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
