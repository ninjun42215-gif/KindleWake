# Visual Content Handoff — Regional Interior Room Dressing
**Date:** 2026-11-28  
**Repository:** https://github.com/ninjun42215-gif/KindleWake  
**Project:** `Kindlewake/` · Godot 4.2.2 · GL Compatibility  
**Branch:** `art/regional-interior-room-dressing-2026-11-28`  
**Base main:** `13f66ec19476c9af5ed2b5c81af95e4d8a026876`  
**Data commit:** `d385ff6bd2d3543250a55801115801df3b1bbf8b`

## Summary
Dressed nine previously empty regional interiors using the existing, already-supported local-map tile vocabulary and renderer. This is a content integration pass, not an unused asset drop.

### Maps updated
- Thornmere: `thornmere_inn`, `thornmere_market`, `thornmere_recruit`
- Foxglove: `foxglove_inn`, `foxglove_market`, `foxglove_recruit`
- Elderbough: `elderbough_inn`, `elderbough_market`, `elderbough_recruit`

## Runtime presentation
The existing `location_scene.gd::_draw_tile()` already renders these glyphs:
- `=`: warm timber floor
- `+`: existing red-and-brass carpet runner
- `B`: bed
- `S`: shelf / stock rack
- `K`: market counter
- `X`: table
- `H`: hearth
- `U`: barrel
- `P`: stone pillar
- `N`: banner
- `C`: crate

Each selected interior's generic grass floor (`.`) was changed to the existing walkable timber-floor glyph (`=`). Room-specific furniture was placed around the authored NPC/service positions. Inns and muster halls receive a short central carpet runner; markets remain clear, functional stock rooms.

The nine maps now contain 63 furnishing glyphs, 24 carpet cells and 453 remaining timber-floor cells. The existing renderer also layers the already-approved project prop art for shelves, barrels, hearths, banners and pillars.

## Preservation
Only `Kindlewake/data/locations.json` was changed in runtime data.
- All nine map IDs, dimensions, row counts, entries, door glyphs, door destinations/spawns and spot/NPC/quest records are unchanged.
- No NPC, shop, recruit, inn, story, dialogue, quest, collision or movement rule was added or removed.
- `.` and `=` remain walkable under `LocalMap.BLOCKED`; `+` is also walkable.
- No save schema, version, permissions, project settings, scenes, scripts, audio, shader or third-party asset changes.
- Other regional interiors remain untouched for a later focused pass.

## Asset provenance and budget
No new assets were imported. The update reuses the existing project-authored local architecture atlas and existing KindleWake furniture/prop drawing paths. No external pack, font, texture, shader or licence claim was added. Existing provenance remains in `Kindlewake/data/asset_provenance.json` and `Kindlewake/assets/art/CREDITS.md`; neither shared file was modified.

No texture dimensions, formats, import settings or VRAM requirements changed.

## Validation performed before push
A data-level validator equivalent to the current `LocalMap.validate()` contract checked all 58 maps:
- zero unknown glyphs or inconsistent row widths;
- all entries remain walkable;
- every authored door is defined and reachable from its map entry;
- every door destination exists and its spawn tile remains walkable;
- every authored NPC/service/story spot still has a reachable interaction neighbour;
- all nine edited maps retain their original dimensions, entries, door dictionaries and spot dictionaries.

Result: **58 maps checked, 0 errors; all protected fields preserved.**

## Exact-head CI results — implementation/test head `e29d66aa2a732f6ed81f593bdb9c94716e486a27`

- [Project Health Audit #2334](https://github.com/ninjun42215-gif/KindleWake/actions/runs/46116443808) — passed.
- [Workflow YAML Lint #3396](https://github.com/ninjun42215-gif/KindleWake/actions/runs/46116443801) — passed.
- [Synchronize Project Version #823](https://github.com/ninjun42215-gif/KindleWake/actions/runs/46116443812) — passed.
- [Build Android APK #1383](https://github.com/ninjun42215-gif/KindleWake/actions/runs/46116443809) — Godot 4.2.2 import exit 0; scene smoke 20/20; strict suite 1,009 checks / 0 failures; campaign lifecycle, merchant UI, title/creator UI, Act V, campaign continuity (70), Chronicle dynasty (39), Chronicle family (19) and balance report passed; APK export and upload passed.
- APK candidate artifact [#15251488575](https://github.com/ninjun42215-gif/KindleWake/actions/runs/46116443809/artifacts/15251488575), 65,297,999 bytes. Test logs and screenshot [artifact #15252086285](https://github.com/ninjun42215-gif/KindleWake/actions/runs/46116443809/artifacts/15252086285).

### Android emulator result
The build job failed only at the Android emulator process-liveness check. Installation succeeded and `am start -W` returned `Status: ok`, but after 30 seconds `pidof com.kindlewake.game` found no process. The captured screenshot is fully black. Logcat records four `SceneShaderGLES3` fragment shader link failures because active uniforms exceed `GL_MAX_FRAGMENT_UNIFORM_VECTORS (261)`, followed by shader bind failure, window death and process exit due to signal 9. No Java fatal exception, native fatal signal or GDScript/parse error was captured. This reproduces the existing emulator renderer issue and is unrelated to this data-only change; the QA remediation remains owned by PR #164. Do not call the APK visually verified or release-ready.

Still required:
1. Godot editor screenshots of all nine interiors at the intended phone zoom.
2. Touch/navigation walkthrough from each town door to every NPC/service spot and back outside.
3. Physical Android check for readability, safe areas, frame pacing and low-memory behavior.

CI/headless validation is not visual editor or physical-device approval.

## Next production slice
Continue with the next three regional settlement interiors only after this batch is reviewed. Keep distinct room purposes readable (inn, market, muster hall) and preserve every authored interaction coordinate.
