# KindleWake — Next AI Start Here

**Canonical repository:** https://github.com/ninjun42215-gif/KindleWake  
**Project directory:** `Kindlewake/`  
**Live main SHA:** `8c512a063f6ef63c88f33489d118cad6b0a29c6c`  
**Engine:** Godot 4.2.2 · GL Compatibility · Android  
**Game / Android version:** `0.12.0 / 1200` · **Save schema:** `4` · **Level cap:** `250`

## Latest main build

Main SHA `8c512a063f6ef63c88f33489d118cad6b0a29c6c` passed [Build Android APK #44007769755](https://github.com/ninjun42215-gif/KindleWake/actions/runs/44007769755):
- **994 strict checks / 0 failures**.
- Campaign lifecycle, merchant UI and title/creator UI: 0 failures.
- Campaign continuity: 70 checks; Chronicle dynasty: 39 checks; family development: 19 checks.
- APK artifact [14294529347](https://github.com/ninjun42215-gif/KindleWake/actions/runs/44007769755/artifacts/14294529347), 63,042,418 bytes; valid signature; no Android permissions requested.

**Important diagnostic caveat:** the optional emulator step in this main build did not confirm a running `com.kindlewake.game` process (`pidof` returned exit code 1). The workflow marks the emulator step `continue-on-error: true`; overall build success therefore does not prove emulator launch. No physical-device QA is recorded.

## Current core engineering candidate

[PR #156 — Reject malformed empire state before campaign restoration](https://github.com/ninjun42215-gif/KindleWake/pull/156)  
Branch: `fix/campaign-empire-save-validation-2026-11-17`  
Base: main SHA `8c512a063f6ef63c88f33489d118cad6b0a29c6c`

A malformed non-Dictionary `empire_state` could pass campaign payload validation, then be passed by `GameState.load_campaign()` to the typed `EmpireSystem.normalize_state(raw: Dictionary, ...)` function, raising a runtime type error. The candidate rejects malformed types while preserving absent-field defaults for legacy schema-4 saves. No schema bump or player-data rewrite.

Code commits:
- `f4bdf15c602addf3e2e2a8293dd181008c9c0538`
- `62a65c5a8a78c0b6ed8f1e4b3705cdc698b384c0`

Exact-code checks:
- [Project Health Audit #44010138457](https://github.com/ninjun42215-gif/KindleWake/actions/runs/44010138457) — passed.
- [Workflow YAML Lint #44010138493](https://github.com/ninjun42215-gif/KindleWake/actions/runs/44010138493) — passed.
- [Version Sync #44010138445](https://github.com/ninjun42215-gif/KindleWake/actions/runs/44010138445) — passed.
- [Build Android APK #44010138501](https://github.com/ninjun42215-gif/KindleWake/actions/runs/44010138501) — passed on exact code SHA `62a65c5a8a78c0b6ed8f1e4b3705cdc698b384c0`: 20/20 scenes, 995 strict checks / 0 failures, campaign lifecycle / merchant UI / title-creator UI 0 failures, Act V 0 failures, continuity 70, Chronicle dynasty 39 and family development 19 checks. Exact-code APK artifact [14296332096](https://github.com/ninjun42215-gif/KindleWake/actions/runs/44010138501/artifacts/14296332096), 63,042,548 bytes; valid signature; no permissions. Emulator boot and install completed, but `pidof com.kindlewake.game` returned exit code 1 after launch; the diagnostic is `continue-on-error: true` and produced no screenshot/logcat. Process launch remains unverified.

PR #156 is unmerged. Review the exact current PR head and require final checks before marking ready. Never merge as part of this workflow.

## What is in main

- Offline-first tactical fantasy RPG; no accounts, backend, multiplayer or INTERNET permission.
- Toroidal campaign overworld, touch/controller exploration and saved regional positions.
- Playable Sethmarch / Brinegate Coast vertical slice; seven-continent atlas and original heraldry. The other six continents are not all playable.
- Tactical combat, ally-aware AI pathfinding, class progression, equipment/runes, traits, companions/quests, faction diplomacy, realm administration, Chronicle and family progression.
- Save schema 4 with semantic validation, backup recovery and campaign lifecycle tests.
- Android build workflow creates signed candidate artifacts; a green export is not physical-device certification.

## Open PR coordination

- [#156](https://github.com/ninjun42215-gif/KindleWake/pull/156): isolated campaign save-validation candidate described above.
- [#151](https://github.com/ninjun42215-gif/KindleWake/pull/151): draft QA battle-resume work; old base `081759f7204bc43ea1acf84b5f4d282d00ceec84`, not mergeable. It touches GameState/save/battle flow. Do not duplicate or merge wholesale.
- [#152](https://github.com/ninjun42215-gif/KindleWake/pull/152): draft QA release-publishing safeguards; same old base, technically mergeable but not revalidated against current main. Keep release-workflow changes with QA/release ownership.
- [#81](https://github.com/ninjun42215-gif/KindleWake/pull/81): draft regional trading integration; old base `a9b6097e11`, not mergeable. Prior handoff lists cargo inventory, tariff/route authority, region/story gating, canonical route endpoints and mobile layout as unresolved. Rebuild a focused vertical slice from current main; do not merge the old branch wholesale.

## Remaining gates

1. Physical Android QA: portrait/landscape, 20:9 screens, safe areas/notches, title → creator → new game, Chapter 1 courtyard touch, world map travel/wrap, battle controls, pause/resume, long sessions, low-memory behavior and save → kill/relaunch → Continue.
2. Confirm emulator install/launch with actual process, logcat and screenshot evidence; current main diagnostic did not confirm process launch.
3. Complete one tested regional vertical slice at a time; the atlas does not mean seven fully playable continents.
4. Governor-specific stat bonuses remain unimplemented; verify current code before extending.
5. Recheck `Kindlewake/data/asset_provenance.json` and `Kindlewake/assets/art/CREDITS.md` before distribution. Only runtime-used assets marked verified should ship.

## Workflow rules

- Inspect live main, open PRs, active branches and exact-head CI before editing.
- Use a dedicated short-lived branch and focused PR. Never write directly to main, merge PRs, force-push, delete branches or overwrite user work.
- Preserve story, content, JSON data, player saves and schema compatibility. Add migrations and regression tests before any schema change.
- Keep the game fully offline. Do not add accounts, servers, multiplayer or INTERNET permission.
- Require Build Android APK, Project Health Audit, Workflow YAML Lint and Version Sync on the exact final PR head. Treat emulator diagnostics and physical-device QA separately.
- Update `docs/SESSION_HANDOFF.md`, this file and a dated engineering handoff after meaningful work.

For details, read `Kindlewake/docs/CORE_ENGINEERING_HANDOFF_2026-11-17.md`, `Kindlewake/docs/SESSION_HANDOFF.md`, `Kindlewake/docs/GDD.md`, and `Kindlewake/docs/PRODUCTION_AUDIT_2026-11-10.md`.
