> **ACTIVE COMBAT-CORRECTNESS CANDIDATE — 2026-11-10:** Branch `fix/ai-block-allies-in-approach-paths`, based on main `0e3b6ac4f526f599d0e585d544e6d7968fbf5252`. It adds an opt-in allied-cell blocker to `BattleMap.compute_reach`, uses that mode for AI candidate generation and approach/fallback routes, and leaves ordinary player movement's ally pass-through rule unchanged. A deterministic corridor regression proves the AI route avoids the ally while player movement retains pass-through. Exact-head Godot import, scene smoke, strict tests, balance report and Android export are pending; do not call the fix verified until the PR workflows finish.

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
