> **CONSOLIDATED 0.12.0 DEVELOPMENT CANDIDATE — 2026-11-10:** Canonical repository `ninjun42215-gif/KindleWake`; verified `main` baseline is `eb589c08b40b639a83b45bcc8d10718fd8223d7a`, game/Android version `0.11.0 / 1100`, save schema `4`. All new work is isolated on `docs/authoritative-live-handoff-2026-11-10` and consolidated in **one** PR: [#28](https://github.com/ninjun42215-gif/KindleWake/pull/28). Main and its APK have not been changed by this candidate. Do not build, distribute or describe a new APK as released until the full candidate passes CI and the one PR is merged.
>
> **Candidate upgrade:** project version `0.12.0`, Android version code `1200`, save schema remains `4` (new region fields are additive and legacy schema-4 saves default safely to Sethmarch). The overworld now uses a continuous wraparound surface in all four directions, with toroidal pathfinding, seam-aware landmarks, canonical save coordinates and tests for edge traversal. Exploration in the overworld, towns and dungeons now supports controller/keyboard movement, Android virtual-stick movement, contextual A/E interaction and 1.6× sprint via B/Shift or the touch RUN toggle. The branch now contains the approved [Premium Production Bible](Kindlewake/docs/PREMIUM_PRODUCTION_BIBLE.md), a four-direction wraparound overworld with seam-aware navigation, a shared controller-first exploration layer (D-pad/left stick, A/E interact, B/Shift run), Android virtual sticks and run toggles across world/town/dungeon scenes, a separate 64×48 Brinegate Coast overworld, Brinegate/Saltmere/Lantern Quay town maps, Tideglass Grotto dungeon and tactical battle, the Tidebound sea-charter unlock from Eldrimar, region-specific coastal rendering, Maren Vey recruitment, a persistent ledger quest with public/private outcomes, per-region save positions, and automated tests for map connectivity, recruitment, quest idempotency and old-save restoration.
>
> **Implementation honesty:** these features exist on the candidate branch but are not yet CI-validated or merged. The rest of Thalassar (Isles of Vey, Kelpward Reach and Deepwake Reach), the Wreck-King's Hold and Old Beacon Vault are still future content; do not present all seven continents as explorable. The production bible is a quality standard, not proof that every proposed portrait, animation, audio cue or asset pack has shipped. Unknown third-party asset licences remain a release blocker.
>
> **Single-delivery rule:** keep improving this same branch and PR #28; do not create separate feature PRs or run an APK release for partial work. Before merge, validate Godot import, the full strict test suite, battle simulation/balance, Android export, YAML lint, version sync and project health on the exact final PR head SHA. Fix failures, refresh the handoff, mark this PR ready, and use the exact-head safe merge guard. Physical Android QA remains separate from CI. The game remains fully offline and must not request INTERNET permission.


---



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
