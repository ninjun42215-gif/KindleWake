# Equipment icon atlas provenance

- Asset: `equipment_icons.svg`
- Author: KindleWake project (original project-authored vector artwork)
- Licence: Original project content; no third-party source art, fonts or external packages used
- Format: SVG, 256 × 256 px, 4 × 4 cells, 64 × 64 px per cell
- Categories: sword, greatsword, bow, spear, axe, mace, crossbow, staff, dagger, armor, shield, helm, accessory, trade good, consumable and neutral fallback
- Runtime integration: `scripts/ui/equipment_icon_atlas.gd`, consumed by `scripts/ui/party_screen.gd` for equipped slots, bag choices and shop rows
- Import strategy: one preloaded SVG atlas; individual icons are lightweight `AtlasTexture` regions. No per-frame image conversion or runtime texture creation
- Planning estimate: a 256 × 256 RGBA8 base raster is 262,144 bytes (0.25 MiB) before import compression, mipmaps or driver overhead. Actual Android texture residency is not measured by this estimate
- Scope: category-level interface symbols, not unique item illustrations or character equipment sprites
