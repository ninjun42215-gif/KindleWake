> **AUTHORITATIVE LIVE CHECKPOINT — 2026-11-10 (verified against GitHub main):** Canonical repository `ninjun42215-gif/KindleWake`, default branch `main`, latest main commit `eb589c08b40b639a83b45bcc8d10718fd8223d7a` (seven-continent atlas milestone). Project version is **0.11.0**, Android version name/code **0.11.0 / 1100**, and save schema **4**. Sources of truth checked: `Kindlewake/project.godot`, `Kindlewake/export_presets.cfg`, and `Kindlewake/scripts/core/save_system.gd`. Save schema 4 includes the recruitment/company-loyalty migration from schema 3; preserve it and add future migrations rather than resetting saves.
>
> **Merged campaign/gameplay milestones:** opening prologue choices and the playable Dunmarrow courtyard escape are merged; the seven-continent runtime atlas is merged. The atlas preserves Eldrimar, Thalassar, Varakhan and Nhalor and adds Veyrwood, Asterreach and Ilyr. Eldrimar/Sethmarch remains the only playable regional overworld at this checkpoint. Thalassar's Brinegate Coast is currently a world-data blueprint (Brinegate, Saltmere, Lantern Quay, Tideglass Grotto, Wreck-King's Hold and Old Beacon Vault), **not a playable region**. Do not claim the other continents are explorable.
>
> **Current GitHub state:** Main points to `eb589c08b40b639a83b45bcc8d10718fd8223d7a`. The latest commit-run lookup and combined status lookup returned no entries; this is **not evidence of a successful post-merge Android build**. Do not claim a current APK artifact or percentage without a fresh successful workflow run and artifact check. Two old creative-direction PRs remain open: [#22](https://github.com/ninjun42215-gif/KindleWake/pull/22) and [#23](https://github.com/ninjun42215-gif/KindleWake/pull/23). They target an older main base and overlap the production direction now present in the GDD; inspect their exact diffs before closing or merging. PR #23 currently reports non-mergeable. Do not merge either blindly.
>
> **Immediate production priority:** create a fully playable, touch-first Brinegate Coast vertical slice. Audit the existing `WorldMap`, `world_scene.gd`, `locations.json`, `GameState`, battle/encounter data and test harness first. Add a region identity/selection model without breaking Sethmarch saves; author Brinegate as a real regional map with connected port hub, Saltmere and Lantern Quay, discoverable routes, a first dungeon/encounter, at least one consequential quest, recruitable sailor(s), and a story reveal tied to the Covenant's unbinding. Add deterministic data and save-migration tests. Reuse the existing battle, location, recruitment and dialogue systems where sound; do not build a disconnected demo.
>
> **Release gates remain:** real Android-device QA, current-main APK verification, and authoritative redistribution/licence proof for any voxel/sprite packs. The game must remain fully offline with no INTERNET permission. Keep all edits on short-lived feature branches and PRs. Require all four core PR checks plus every discovered PR-triggered workflow to pass on the **same exact head SHA**; merge only through the expected-head-SHA safe merge guard after GitHub confirms mergeability. Never push directly to main or force-push.
>
> **Handoff rule:** inspect live main, branches, PRs, workflows and source files before each task. This checkpoint supersedes all older version/SHA/PR-status statements below; historical notes are retained for traceability, not current truth.

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
