# KindleWake — Next AI Start Here

**Canonical repository:** https://github.com/ninjun42215-gif/KindleWake  
**Project directory:** `Kindlewake/`  
**Live main SHA at handoff:** `9ac0b8c229337d3ac890403d7d359862359b9e97`  
**Engine:** Godot 4.2.2 · GL Compatibility · Android  
**Game / Android version:** `0.12.0 / 1200` · **Save schema:** `4` · **Level cap:** `250`

## Verified current build

Main commit `9ac0b8c229337d3ac890403d7d359862359b9e97` passed:

- [Build Android APK #43831250188](https://github.com/ninjun42215-gif/KindleWake/actions/runs/43831250188): first editor import clean (no script/parse errors), 18/18 scene smoke loads, **952 strict checks / 0 failures**, campaign lifecycle 0 failures, campaign continuity 70/70, Chronicle dynasty 39 checks, family development 19 checks, Act V and balance simulation.
- Signed APK verified for `arm64-v8a` and `armeabi-v7a`; no Android permissions requested. APK artifact ID: `14208059689`.
- [Project Health Audit #43831250533](https://github.com/ninjun42215-gif/KindleWake/actions/runs/43831250533), [Workflow YAML Lint #43831250108](https://github.com/ninjun42215-gif/KindleWake/actions/runs/43831250108), [Version Sync #43831250104](https://github.com/ninjun42215-gif/KindleWake/actions/runs/43831250104) and [source handoff #43831250102](https://github.com/ninjun42215-gif/KindleWake/actions/runs/43831250102) passed on the same SHA.

CI success is not physical Android device certification.

## What is in main

- Offline-first tactical fantasy RPG; no accounts, backend, multiplayer or INTERNET permission.
- Toroidal campaign overworld, controller/touch exploration and saved regional positions.
- Playable Sethmarch / Brinegate Coast vertical slice; seven-continent atlas and original heraldry. The other six continents are **not all playable** yet.
- Tactical combat, ally-aware AI pathfinding, class progression, equipment/runes, traits, companions, quests, faction diplomacy, holdings/realm administration, Chronicle and family progression.
- Save schema 4 with semantic validation, backup recovery and campaign lifecycle tests.
- Android build workflow uses read-only repository access; write access is isolated to version-tag release publishing.
- Godot bootstrap now uses explicit preloads and the build fails on first-pass import errors rather than retrying over them.

## Current blockers and limits

1. **Physical Android QA outstanding:** verify portrait/landscape, 20:9 screens, safe areas/notches, title → creator → new game, Chapter 1 courtyard touch, map travel/wrap, battle controls, pause/resume, long sessions, low-memory behavior and save → kill/relaunch → Continue.
2. **Regional trading PR #81 is not merge-ready:** stale/diverged branch; cargo inventory, tariff/route authority, story/region gating, canonical route endpoints and mobile layout need a fresh implementation based on current main. Do not merge it wholesale.
3. **Content breadth:** the global atlas is not the same as seven fully playable continents. Complete one tested regional vertical slice at a time.
4. Governor-specific stat bonuses are not yet implemented. Confirm feature behavior against current code/tests before extending it.
5. Recheck `Kindlewake/data/asset_provenance.json` and `Kindlewake/assets/art/CREDITS.md` before distribution. Only runtime-used assets marked verified should ship.

## Open PR triage at this checkpoint

- [#81 Regional trading](https://github.com/ninjun42215-gif/KindleWake/pull/81): blocked; rebuild on current main.
- [#130 Authentication / offline credential documentation](https://github.com/ninjun42215-gif/KindleWake/pull/130): draft documentation; review for accuracy before marking ready.
- Older stacked or heavily diverged PRs (#42, #46, #63, #66, #78 and old lore branches) are references only. Inspect their diffs and port small reviewed slices; do not bulk merge.

## Workflow rules

1. Inspect live `main`, open PRs and exact-head CI before editing. This checkpoint SHA is historical once main advances.
2. Use a short-lived branch and focused PR. Never edit main directly, force-push, or bypass checks.
3. Preserve existing story, systems, JSON data, player saves and schema compatibility. Add migrations and regression tests before any schema change.
4. Keep the game fully offline. Do not add accounts, servers, multiplayer or INTERNET permission.
5. Require Build Android APK, Project Health Audit, Workflow YAML Lint and Version Sync on the exact PR head. Use expected-head-SHA merge.
6. A headless scene load or APK export is not physical-device QA. Report the distinction accurately.
7. Update `docs/SESSION_HANDOFF.md`, this file and relevant design docs when a meaningful change is merged.

## Best next engineering step

Complete a fresh, reviewed regional trading vertical slice only after mapping current region IDs, market locations, player cargo inventory, tariff ownership and route unlock flags. Keep the first increment limited to safe local buy/sell transactions and save/load persistence; add caravans, route travel and smuggling only after their authority, destination and story-gate rules are testable.

For full context, read `Kindlewake/docs/SESSION_HANDOFF.md`, `Kindlewake/docs/GDD.md`, `Kindlewake/docs/PRODUCTION_AUDIT_2026-11-10.md`, and `Kindlewake/docs/CORE_ENGINEERING_HANDOFF_2026-11-16.md`.
