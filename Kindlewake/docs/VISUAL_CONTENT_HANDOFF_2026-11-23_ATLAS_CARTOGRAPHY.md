# Visual-content handoff — 23 November 2026: Sevenfold atlas cartography

## Summary

Added a lightweight cartographic finish to the existing seven-continent campaign atlas. The map now shares one responsive viewport calculation across its polygon renderer, heraldry overlay and new decorative layer. The new layer draws three restrained brass corner marks and an eight-point compass rose in the clear north-west sea margin; the north-west frame corner is intentionally left open for the compass.

## Runtime integration

- New scripts/ui/atlas_layout.gd owns the normalized portrait/landscape map rectangle.
- global_atlas.gd and continent_heraldry_layer.gd call that shared helper, preventing geometry drift.
- New scripts/ui/atlas_cartography_layer.gd is attached to GlobalAtlas.tscn above the heraldry layer.
- The decorative layer uses MOUSE_FILTER_IGNORE; it does not receive or block map, button, diplomacy or touch input.
- Compass center and radius are derived from the shared map rectangle and remain inside the map frame at 1280×720, 720×1280 and 360×640 test viewports.
- No new raster textures, shaders, fonts, plugins or third-party art are introduced. All marks are drawn with Godot CanvasItem primitives.

## Preservation

No continent IDs, region data, map polygons, travel gates, diplomacy rules, story flags, save data, schema, project version, or gameplay code changed. The existing title-art, settlement, portrait, equipment and battle-VFX branches were not modified.

## Provenance

The cartographic ornaments are original KindleWake GDScript drawing instructions. No third-party asset pack or externally sourced visual material is used.

## Exact refs

- Base branch: main
- Base SHA: 13f66ec19476c9af5ed2b5c81af95e4d8a026876
- Branch: art/cartographic-world-atlas-details-2026-11-23
- Implementation/tested code head: d31cc094b46e98ca27894d4a902fd3719becc1da
- Pull request: https://github.com/ninjun42215-gif/KindleWake/pull/176
- PR remains draft; GitHub reports it mergeable and 8 commits ahead / 0 behind main at the tested code head.

## Exact-head verification — implementation commit d31cc094

- Project Health Audit [#45126561570](https://github.com/ninjun42215-gif/KindleWake/actions/runs/45126561570): passed.
- Workflow YAML Lint [#45126561571](https://github.com/ninjun42215-gif/KindleWake/actions/runs/45126561571): passed.
- Version Sync [#45126561531](https://github.com/ninjun42215-gif/KindleWake/actions/runs/45126561531): passed.
- Android Build [#45126561535](https://github.com/ninjun42215-gif/KindleWake/actions/runs/45126561535): import, scene smoke, strict tests, balance report and APK export passed; emulator process-liveness failed.

Detailed passed stages:
- Godot 4.2.2 project import: exit 0; no script errors.
- Scene smoke: 20 scenes loaded, 0 failures.
- New cartography checks: portrait, landscape and compact bounds passed; scene node present and input-transparent.
- Strict suite: 1,009 checks, 0 failures.
- Campaign lifecycle, merchant UI, title/creator UI, Act V, campaign continuity (70), Chronicle dynasty (39), Chronicle family development (19), and balance report all exited successfully.
- APK export: exit 0; signature valid; no Android permissions requested; native libraries for arm64-v8a, armeabi-v7a and x86_64.

## Android emulator failure diagnosis

The API 35 AOSP ATD x86_64 emulator used forced Google SwiftShader GLES3. Godot logged:
- Project global shader-variable buffer size exceeds the emulator's 16,384-byte uniform-buffer limit.
- SceneShaderGLES3 program linking failed because active fragment uniforms exceed GL_MAX_FRAGMENT_UNIFORM_VECTORS (261).
- Godot's main loop started, then GodotActivity paused/destroyed the instance and force-quit; the app process was gone at the 30-second liveness check.
- The captured emulator screenshot is black.
- No Java FATAL EXCEPTION, native fatal signal, GDScript SCRIPT ERROR or Parse Error was found.

This matches the pre-existing main-branch SwiftShader/GLES3 compatibility failure. The new atlas layer uses CanvasItem drawing only and adds no shader or global uniform. Do not attribute this emulator failure to the cartography change; do not treat it as proof of failure on every physical Android GPU.

## APK artifact and logs

- Exact implementation-head APK artifact: [#14795768161](https://github.com/ninjun42215-gif/KindleWake/actions/runs/45126561535/artifacts/14795768161)
- APK size: 65,852,931 bytes.
- Extracted APK SHA-256: 9bbc30ade5b5a5081d04bc23ff8486798ebf80d151cac8ee96367215d1ecefe9
- Artifact ZIP SHA-256: not independently calculated in this handoff; do not substitute the APK checksum for the archive checksum.
- Test and emulator logs artifact: [#14795529179](https://github.com/ninjun42215-gif/KindleWake/actions/runs/45126561535/artifacts/14795529179)
- Test-log archive SHA-256: 34514ebfbc3dd52af39cd210ee71b069cbde1f696f29c5577810337ad65cd91b

The APK is CI/test-signed, not a production release. It is tied to implementation commit d31cc094 and must not be reused for later source commits.

## Remaining review gates

- Godot editor screenshot inspection of the compass and frame at portrait and landscape aspect ratios.
- Physical Android device rendering, touch, memory and frame-pacing checks.
- Re-run exact-head CI after any further code changes.
- No physical-device verification is claimed.
- No merge, main write, force-push, branch deletion, repository-setting change or release publication was performed.


## Asset-pack and provenance audit on current main

The current main ledger (updated 2026-11-19) records:
- Quaternius Stylized Nature MegaKit: CC0 1.0, verified and runtime-used.
- Zerie Tiny RPG Character Asset Pack 01 Free Soldier/Orc subset: author terms permit personal/commercial game use and modification; standalone source-pack redistribution is prohibited.
- Legacy voxel-building PNGs: retained historically, not runtime-used; original KindleWake SVG settlement art replaces them.
- LimeZu Modern Interiors Free: restricted non-commercial and non-editable; excluded.
- MountainRocks archive: unknown licence; excluded.
- Existing original KindleWake vector art and seven-continent heraldry: project-authored and verified.

This cartography change adds no imported pack, third-party artwork, font, texture or binary. Its drawing instructions are original project code.

The main asset manifest still labels its baseline as 8a1f9e4227c3541c34e17593bb317a88c1c2d7a6, older than current main 13f66ec19476c9af5ed2b5c81af95e4d8a026876. PR #157 currently owns asset_manifest.md, asset_provenance.json and CREDITS.md, and its branch is 34 commits ahead / 9 behind main (diverged, not mergeable). These shared provenance files were deliberately left untouched here; reconcile their baseline and any later approved asset entries when PR #157 is rebased/reviewed.
