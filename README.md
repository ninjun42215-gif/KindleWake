# KindleWake — The Sundered Vow

Offline-first medieval tactical RPG built with Godot 4.2.2 (GDScript, GL Compatibility), targeting Android and iOS.

## Live project checkpoint

- Canonical source: tracked files under `Kindlewake/` in `ninjun42215-gif/KindleWake`.
- Current main: `d25ac6840ab0cdcc339b6fa89ed4ef42dec917dc`; gameplay version 0.10.0; Android code 1000; save schema 3.
- The current main tree is identical to tested PR head `769022ebee463a35af95e4cd9dfcab7a55e89cb7`.
- Android build run [42711243963](https://github.com/ninjun42215-gif/KindleWake/actions/runs/42711243963) passed with Godot 4.2.2, 342 strict checks and 0 failures, balance report, signed APK export and no Android permissions.
- APK artifact ID: `13715144284`; SHA-256: `e1f303c2c9f5ef73b527988636ef5e467f6162ca043c1f443ad3fa33ea833c72`.
- Verified source handoff run [42711223545](https://github.com/ninjun42215-gif/KindleWake/actions/runs/42711223545) produced 177 tracked files in four parts, each no larger than 25,000,000 bytes. Reassembly, ZIP integrity, file hashes and safe extraction passed.

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
