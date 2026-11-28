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

## Required CI / remaining QA
The pull request's Android build should run the existing Godot 4.2.2 first import, scene smoke, strict test suite (which invokes `LocalMap.validate()`), balance report and APK export. Do not claim those checks passed until exact-head Actions results are available.

Still required:
1. Godot editor screenshots of all nine interiors at the intended phone zoom.
2. Touch/navigation walkthrough from each town door to every NPC/service spot and back outside.
3. Physical Android check for readability, safe areas, frame pacing and low-memory behavior.

CI/headless validation is not visual editor or physical-device approval.

## Next production slice
Continue with the next three regional settlement interiors only after this batch is reviewed. Keep distinct room purposes readable (inn, market, muster hall) and preserve every authored interaction coordinate.
