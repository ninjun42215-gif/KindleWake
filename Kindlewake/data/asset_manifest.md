# HD-2D Asset Manifest

The prototype currently uses procedural placeholder geometry so it runs without external art.

## Replace with original assets
- Isometric terrain tiles: grass, forest, road, rock, bridge, water, castle floor.
- Unit sprite sheets: Knight, Archer, Cleric, Roadreaver, Hask Gravelteeth.
- Per-unit animations: idle, walk, attack, hit, cast, victory, defeat.
- Portraits: 256x256 PNG with transparent background.
- UI: parchment panels, heraldic frames, class icons, HP bars.
- Effects: sword arc, arrow trail, healing particles, hit flash.

## Suggested visual pipeline
- Render at a consistent pixel density.
- Use 2D sprites with normal maps and carefully layered lights for an HD-2D look.
- Keep gameplay readability above visual effects.
- Use original designs; do not extract assets from commercial games.


## Reviewed candidates (not yet imported)
- Foozle — Pixel Magic Effects: https://foozlecc.itch.io/pixel-magic-sprite-effects. 10 animated 32×32 spell effects with icons; page states CC0 1.0 and permits commercial use and modification. Candidate only; archive/frame layout has not yet been imported or verified in this project.


## 2026-11-11 — original boss battle animation atlases
Six original, project-authored SVG pixel-art atlases are wired into the tactical battle renderer:
- `assets/art/units/enemies/rootbound_warden.svg` — broad bark-and-root guardian silhouette.
- `assets/art/units/enemies/bell_keeper.svg` — floating spectral keeper with a hanging bell.
- `assets/art/units/enemies/ashen_reeve.svg` — ash-armoured revenant with a burning blade.
- `assets/art/units/enemies/roadwolf_chieftain.svg` — broad horned war-chief with a heavy cleaver.
- `assets/art/units/enemies/roadwolf_reaver.svg` — hooded leather raider with a compact axe.
- `assets/art/units/enemies/roadwolf_bowman.svg` — lean hooded archer with a recurved bow and quiver.
- Each atlas is 600×700: six 100×100 frames across and seven rows (idle, walk, attack, hurt, cast, victory, death). The renderer selects the appropriate row and frame at runtime.
- Hask Gravelteeth, Roadwolf Reavers and Roadwolf Bowmen now resolve to distinct original atlases; unknown enemies retain the legacy Orc fallback.
- Existing hero Soldier strips remain integrated. Their unsupported cast/victory states use a supported idle frame plus original action-pose and VFX overlays rather than missing-file lookups.
- No third-party optional sprite pack was imported. The archive `Feature_hero_battle_sprites.zip` contains only code/docs/tests and no image assets; it is not a reusable hero sprite pack.
