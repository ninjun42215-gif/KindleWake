# Visual and content production handoff — 2026-11-16

## Repository checkpoint

- Repository: ninjun42215-gif/KindleWake
- Canonical project: Kindlewake/
- Branch: art/continent-heraldry-atlas-2026-11-16
- Base: main at 8a1f9e4227c3541c34e17593bb317a88c1c2d7a6
- Runtime baseline: Godot 4.2.2, GL Compatibility, Android, game version 0.12.0, save schema 4, fully offline.
- Main was left untouched. No merge, force-push, save migration, gameplay-data change or version bump was performed.

## Live-state audit

- Main contains original settlement SVGs, a 4×4 original field-prop atlas, Quaternius nature sprites and the verified free Soldier/Orc subset from Zerie's Tiny RPG pack.
- The settlement SVGs are loaded through Art.world(); field props are drawn through Art.draw_prop(); unit animation strips are interpreted by scripts/ui/art.gd.
- character_preview.gd still draws a procedural protagonist bust. It is not a finished portrait, and named recruit portraits must not be invented or assigned without matching the exact character sprite identity.
- The project has seven authored continent records and vector map silhouettes. The atlas is a worldbuilding/navigation surface; it is not proof that all seven continents have playable regional maps.
- Legacy voxel assets and optional sprite archives have unresolved or restrictive provenance and must remain excluded from runtime/release use unless authoritative rights are established. The used Quaternius and Zerie sources have recorded evidence; new art in this branch is original project-authored vector work.
- Existing open engineering PRs touch core party state/tests, build workflows and README/handoff files. The visual tranche therefore avoids those files and confines runtime integration to the atlas scene child, its new script and original art/provenance documentation.

## Delivered vertical slice

- Added seven original heraldic emblems that express the existing continent identities: Eldrimar's broken crown, Thalassar's beacon and tide, Varakhan's sun and caravan well, Nhalor's mountain and aurora, Veyrwood's leaf and roots, Asterreach's stormglass spire and Ilyr's far lantern.
- Added a single 896×128 SVG atlas with seven 128×128 cells. The order is explicit and the script maps by stable continent id, not by display-name or list position.
- Added ContinentHeraldryLayer as a non-interactive, full-rect child of GlobalAtlas.tscn. It overlays a small medallion above each existing map label, preserves the parent's polygon, labels, side panel and selection logic, and ignores mouse/touch input.
- Added source provenance and refreshed the runtime asset manifest. No third-party art, fonts, audio, external package or network dependency was added.

## Performance and compatibility notes

- The overlay preloads one vector texture and draws only the seven 128×128 atlas regions at 38 px in portrait or 46 px in landscape.
- There is no _process() loop, animation timer, runtime texture construction, per-frame image conversion or input interception.
- The 0.44 MiB figure is the uncompressed RGBA8 base-raster estimate only; actual Godot import size, mipmaps, VRAM residency and device frame pacing remain unmeasured.
- The script uses Godot 4 Control/CanvasItem APIs and the existing autoloaded GameData.continents records. The project version and save schema are unchanged.

## Validation and outstanding QA

- Local SVG parsing and raster preview passed; all seven icons remain distinguishable at the intended portrait display size.
- The local environment does not contain a Godot executable, so editor import, GDScript execution, scene smoke, balance tests and Android APK export were not run locally.
- Check Build Android APK, Project Health Audit, Version Sync and Workflow YAML Lint on the exact PR head. Any transient first-import class-registration diagnostics must be distinguished from final import/test results.
- Editor inspection is still required for medallion/label overlap at 16:9, 20:9 portrait, narrow landscape and safe-area layouts.
- Physical Android QA is still required for touch pass-through, scrolling, map selection, memory and frame pacing. CI is not device certification.
- No screenshot or runtime visual verification is claimed.

## Next production priorities

1. Establish a named-character portrait pipeline with approved face, costume, sprite identity and expression references before creating portraits.
2. Expand class-specific player/companion/enemy/boss sprite identities and animation states without changing combat data or save contracts.
3. Build regional environment kits only alongside the corresponding playable map slice; keep locked continent concepts clearly marked as concept art.
4. Add tactical VFX and item/equipment icon families with restrained flash, readable status shapes and a reduced-flash option.
5. Review the existing typography and shared HUD hierarchy at actual phone sizes; bundle fonts only after checking licence and glyph coverage.
6. Add original house/region musical motifs and adaptive ambience after the audio settings and transition lifecycle are verified.

## Safety

This branch is a reviewable visual-content candidate only. Do not merge it automatically until exact-head CI, Godot editor inspection and mobile layout review are complete. Never merge to main as part of this work.
