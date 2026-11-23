# Visual-content handoff — 23 November 2026: Sevenfold atlas cartography

## Summary

Added a lightweight cartographic finish to the existing seven-continent campaign atlas. The map now shares one responsive viewport calculation across its polygon renderer, heraldry overlay and new decorative layer. The new layer draws restrained brass corner marks and an eight-point compass rose in the clear north-west sea margin.

## Runtime integration

- New scripts/ui/atlas_layout.gd owns the normalized portrait/landscape map rectangle.
- global_atlas.gd and continent_heraldry_layer.gd now call that shared helper, preventing geometry drift.
- New scripts/ui/atlas_cartography_layer.gd is attached to GlobalAtlas.tscn above the heraldry layer.
- The decorative layer uses MOUSE_FILTER_IGNORE; it does not receive or block map, button, diplomacy or touch input.
- Compass center and radius are derived from the shared map rectangle and remain inside the map frame at 1280×720, 720×1280 and 360×640 test viewports.
- No new raster textures, shaders, fonts, plugins or third-party art are introduced. All marks are drawn with Godot CanvasItem primitives.

## Preservation

No continent IDs, region data, map polygons, travel gates, diplomacy rules, story flags, save data, schema, project version, or gameplay code changed. The existing title-art, settlement, portrait, equipment and battle-VFX branches were not modified.

## Provenance

The cartographic ornaments are original KindleWake GDScript drawing instructions. No third-party asset pack or externally sourced visual material is used.

## Verification

A focused regression was added to tests/scene_smoke_test.gd to validate the shared viewport geometry, compass safe bounds, and non-interactive overlay node in GlobalAtlas.tscn. The Godot import, scene smoke, full strict suite and Android build must run on the exact PR head before this work is treated as engine-verified. No Godot editor screenshot or physical-device rendering has yet been captured.

## Exact baseline

- Base branch: main
- Base SHA: 13f66ec19476c9af5ed2b5c81af95e4d8a026876
- Branch: art/cartographic-world-atlas-details-2026-11-23
