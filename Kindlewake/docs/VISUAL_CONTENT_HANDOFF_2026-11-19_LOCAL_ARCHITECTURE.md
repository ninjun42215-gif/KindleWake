# Visual content handoff — local settlement architecture expansion

## Exact source state
- Repository: https://github.com/ninjun42215-gif/KindleWake
- Project: `Kindlewake/`
- Base `main` SHA: `13f66ec19476c9af5ed2b5c81af95e4d8a026876`
- Branch: `art/local-settlement-architecture-variants-2026-11-19`
- Scope: original local-map roof and facade art plus deterministic runtime selection and regression coverage
- No changes to story, lore, character stats, location data, map glyphs, collision, door targets, NPC/quest spots, save schema or game version

## Delivered
- Added `assets/art/tiles/local_architecture_detail.svg`, an original 384 × 48 SVG with eight 48 × 48 cells:
  - two weathered clay roof variants
  - two slate roof variants
  - timber-framed double-window facade
  - limestone arched-window facade
  - shopfront and lantern facade
  - salt-weathered stone facade
- Integrated the detail atlas into `scripts/ui/location_scene.gd`. The existing `r`, `b` and `w` glyphs now select from four roof or eight facade variants deterministically from the existing cell hash. Existing map data and collision remain untouched.
- Added runtime asset regression checks in `tests/run_tests.gd` for both atlas dimensions, the new preload and the variant selection paths.
- Added `assets/art/tiles/LOCAL_ARCHITECTURE_DETAIL_PROVENANCE.md` documenting original authorship, rights, dimensions, integration and the estimated base raster size.

## Visual and technical review
- The new atlas was rendered locally at 1536 × 192 for visual inspection using CairoSVG. The eight cells remain separate and the palette stays within the existing clay, slate, lime plaster, timber and weathered stone language.
- SVG contains no embedded raster, external font, script, filter or third-party asset.
- Detail atlas base RGBA8 estimate: 72 KiB; this is not a measured Godot import or GPU memory figure.
- The atlas is loaded once and drawn by source region; there is no per-frame conversion or animation loop.

## Validation status
- Local SVG raster preview: passed.
- Godot 4.2.2 editor import, headless scene smoke and strict suite: pending PR CI.
- Android APK export and emulator visual check: pending PR CI.
- Physical handset screenshot, touch, memory and frame-pacing QA: not performed.
- Central `data/asset_provenance.json`, `data/asset_manifest.md` and `assets/art/CREDITS.md` were not changed because active portrait PR #157 currently edits those shared provenance files. The sidecar above records this extension; reconcile the central inventory after that branch is resolved.

## Coordination
- Current main at branch creation: `13f66ec19476c9af5ed2b5c81af95e4d8a026876`.
- This branch avoids the active portrait resolver/journal, protagonist creator/gallery, equipment icon, campaign save, Android workflow and core engineering files.
- No merge, force-push, branch deletion or repository-setting change was performed.
