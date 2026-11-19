# Local architecture detail atlas provenance — 19 November 2026

## Runtime asset
- File: `Kindlewake/assets/art/tiles/local_architecture_detail.svg`
- Format and canvas: original SVG, 384 × 48 pixels, eight 48 × 48 cells
- Cell order: clay roof (two weathered variants), slate roof (two variants), timber-framed double-window facade, limestone arched-window facade, shopfront/lantern facade, salt-weathered stone facade
- Authorship: original KindleWake project artwork authored in this repository
- Rights: original project content; no third-party source images, fonts, brushes, packages or copied game artwork
- External references, scripts, embedded raster images and fonts: none

## Runtime integration
- Preloaded once by `scripts/ui/location_scene.gd`
- Existing base atlas remains unchanged at 528 × 48 pixels
- Existing local map glyphs `r`, `b` and `w` now select from the combined base/detail variants using the existing deterministic cell hash
- Existing glyphs `1`–`4` (doors) and `#` (stone walls) continue to use the original base atlas
- No location rows, collision rules, doors, NPC spots, quest hooks, player movement or save data were changed

## Performance and compatibility
- One 384 × 48 SVG texture is loaded through a constant preload and sampled by source rectangle
- Uncompressed RGBA8 base-raster estimate: 73,728 bytes (72 KiB), before mipmaps/driver overhead; actual Godot import and GPU residency are not measured
- SVG uses basic paths, rectangles, circles and strokes; no filters, masks, external resources or runtime texture generation
- Godot 4.2.2 editor import, Android rendering and physical-device frame pacing remain subject to CI/device verification
