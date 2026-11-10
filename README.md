> **AUTHORITATIVE LIVE CHECKPOINT — 2026-11-10 12:16 UTC:** Canonical repository `ninjun42215-gif/KindleWake`; project directory `Kindlewake/`; default branch `main`; current main commit `830bc0273d45140a11a4038f092a4d5ee347a243` (PR #118 merged). Game/Android version `0.12.0 / 1200`; save schema `4`; Godot `4.2.2`; offline-first, no accounts, servers, multiplayer or INTERNET permission. The requested level cap of 250 is implemented and asserted in strict tests. Main CI on this exact commit passed: 18/18 scenes loaded, 912 strict checks / 0 failures, balance report, signed Android APK export, Project Health Audit, Version Sync, Workflow YAML Lint and source handoff. APK artifact `13763523117` (41,190,380-byte artifact archive); build run [#42814167185](https://github.com/ninjun42215-gif/KindleWake/actions/runs/42814167185). Physical Android QA remains outstanding; third-party sprite/voxel asset redistribution rights remain a release blocker until verified or replaced. See [PRODUCTION_AUDIT_2026-11-10.md](PRODUCTION_AUDIT_2026-11-10.md) for the live branch/PR triage and production roadmap. Earlier checkpoint notes below are historical and must not override the live GitHub state.

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
