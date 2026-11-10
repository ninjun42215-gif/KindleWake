> **LIVE PROJECT CHECKPOINT — 2026-11-10 (authoritative):** Canonical repository `ninjun42215-gif/KindleWake`; default branch `main`; verified main commit `496f6c6a8130c920e0d9ed96f5e323c016d67c01`. PR [#28](https://github.com/ninjun42215-gif/KindleWake/pull/28) is **merged**. Do not describe it as a candidate or continue work on its old branch.
>
> **Released source/build state:** game and Android version `0.12.0`, Android version code `1200`, save schema `4`. The merged update includes the toroidal campaign overworld, controller/keyboard/touch exploration and sprint, Brinegate Coast vertical slice, regional save positions, and additive schema-4 compatibility. The seven-continent atlas is inspectable, but the other six continents are not all playable.
>
> **CI evidence:** the exact merged main commit passed Android APK build, Project Health Audit, source-handoff snapshot, version synchronization and workflow YAML lint. Current main APK artifact: `Kindlewake-APK`, artifact ID `13720944780`, about 40.8 MB; build run [42724834624](https://github.com/ninjun42215-gif/KindleWake/actions/runs/42724834624). CI success is not physical-device QA.
>
> **Next work:** perform real Android QA for all four world edges and corner crossings, movement/sprint/touch/controller paths, screen scaling, Brinegate quest and travel flow, save/load, performance and battery. Physical-device testing has not yet been confirmed. Record actual findings before claiming it passed.
>
> **Hard constraints/release gates:** fully offline; no accounts, servers, multiplayer or INTERNET permission. Preserve existing saves and schema compatibility. Third-party sprite-pack redistribution licensing remains unresolved and blocks public/commercial release until verified or replaced. Keep work on a short-lived branch and one consolidated PR; merge only after every required check passes on the exact PR head SHA. Never edit `main` directly.

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
