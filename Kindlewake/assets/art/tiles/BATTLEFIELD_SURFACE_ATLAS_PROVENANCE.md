# Battlefield surface atlas — provenance and runtime contract

**Asset:** `assets/art/tiles/battlefield_surface_atlas.svg`  
**Author:** KindleWake project  
**Rights:** Original project-authored vector artwork. No third-party pack, game screenshot, external font, linked image, generated source asset, or external dependency is used.

## Atlas contract

- Source size: **1408 × 32 SVG pixels**.
- Grid: **22 horizontal cells**, each exactly **64 × 32**.
- Background: transparent.
- Each surface family has two original detail variants.
- Cell variants are selected deterministically from the battlefield cell coordinate; no random state is consumed.
- The atlas contains only vector paths, circles, ellipses and grouped shapes. It contains no external `href`, embedded raster `image`, filters, masks, scripts or foreign objects.

## Terrain mapping

| Terrain ID | Cell pair | Surface treatment |
|---|---:|---|
| `grass` | 0–1 | restrained grass blades and seed flecks |
| `forest` | 2–3 | moss, leaf litter and root marks |
| `road` | 4–5 | compacted wheel ruts and gravel |
| `hill` | 6–7 | contour strata and stone chips |
| `ford` | 8–9 | shallow-water ripples and river stones |
| `deep_water` | 10–11 | darker open-water ripple marks |
| `marsh` | 12–13 | mud pools and reed traces |
| `snow` | 14–15 | pale ice fissures and frost flecks |
| `ash` | 16–17 | charcoal cracks and subdued ember flecks |
| `ruins` | 18–19 | fractured flagstone seams |
| `cliff` | 20–21 | slate strata and broken stone chips |

Legacy Act III battle data uses terrain ID `water` for traversable river shallows. It intentionally aliases the ford surface pair and ford color only. Its movement cost, occupancy, cover and line-of-sight behavior are unchanged. Bridges and raised `rock` walls retain their existing bespoke renderer and do not receive a ground overlay.

## Runtime integration

- `scripts/ui/battlefield_surface_style.gd` loads the atlas once per battle-scene helper instance and caches the Texture2D.
- `scripts/ui/battle_scene.gd` draws one 64×32 source region over each supported terrain diamond, beneath its outline and existing larger props.
- Existing trees, reeds, frost pines, campfires, columns, crystals and bridge planks remain in their current renderer paths.
- If the texture cannot load, the existing primitive ground-detail fallbacks remain active.
- No per-tile load, runtime texture construction, animation loop, shader, scene node, input handler or new external resource is added.

## Import and performance budget

- Godot target: **4.2.2**, GL Compatibility renderer, Android.
- The source dimensions match the existing 64×32 isometric tile.
- Uncompressed RGBA8 planning estimate: 1408 × 32 × 4 = **180,224 bytes (176 KiB)** before mipmaps and driver overhead.
- The project enables ETC2/ASTC VRAM compression import support. Actual imported format, compressed size, mip allocation, device VRAM residency and frame-time impact have **not** been measured here.
- The renderer adds at most one atlas-region draw per supported ground tile; no extra draw is made for bridge or raised rock-wall tiles.

## Preservation

This is presentation-only. No terrain movement costs, blocking flags, cover, height, line of sight, battle definitions, encounter data, combat calculations, unit stats, story flags, saves, save schema, game version, Android permissions or release workflow behavior are changed. The only legacy compatibility adjustment is visual: the existing traversable `water` alias receives the ford palette rather than the generic grass fallback.
