# Enemy roster heraldry — asset provenance and mapping

**Asset:** `assets/art/units/character_roster_atlas.svg`  
**Source:** Original KindleWake vector atlas, extended in this repository on 25 November 2026.  
**Rights:** Project-authored vector artwork. No third-party packs, game screenshots, external fonts, embedded raster images, generated-image references, or linked resources are included in this change.

## Runtime contract

- Atlas remains exactly **1024 × 960**.
- The existing **8 × 6** grid remains unchanged.
- Each cell remains **128 × 160**.
- `scripts/ui/art.gd` continues to resolve all 48 stable IDs through `ROSTER_CHARACTER_IDS` and `draw_roster_character()`.
- Twelve existing cells now carry small, integrated heraldic identity marks on the sprite's left shoulder. This keeps the marks clear of the right-side class/weapon identity strokes drawn after the sprite by the existing battle renderer. No new texture, shader, node, draw call, or resource load is introduced.
- The marks are embedded in the already-used atlas; they are not a detached or unused asset drop.

## Stable ID → visual mark

| Stable character ID | Cell | Mark |
|---|---:|---|
| `hask_gravelteeth` | 4 | Roadwolf claw |
| `roadreaver` | 5 | Roadwolf claw |
| `roadbowman` | 6 | Roadwolf claw |
| `reefwarden` | 31 | Reef spiral |
| `saltcutthroat` | 32 | Crossed cutlasses |
| `saltbow` | 33 | Salt-Reef arrow |
| `blackwake_captain` | 34 | Blackwake sail |
| `hask_convoy_champion` | 43 | Roadwolf claw |
| `ash_bailiff` | 44 | Ash Bailiff flame seal |
| `checkpoint_sergeant` | 45 | Writ-captain crown seal |
| `river_marshal` | 46 | River crossing waves |
| `quillon_warden` | 47 | Quillon open-record seal |

These are visual identifiers derived from the existing character names and roles. They do **not** assert new diplomatic affiliations or modify `factions.json`, encounter weights, combat rules, character definitions, portrait IDs, or story canon.

## Import and performance constraints

- SVG uses only groups, paths, circles and simple fills/strokes.
- No filters, masks, foreign objects, scripts, external `href` references or raster images.
- The 48-cell grid and all stable roster IDs are preserved.
- The existing single imported atlas remains the only runtime texture. The marks are rasterized as part of that texture during the normal Godot import.
- The default roster draw scale is unchanged. Final device-scale visual review is still required.

## Central-ledger reconciliation

The shared `data/asset_provenance.json` and `assets/art/CREDITS.md` are intentionally not edited here because active portrait work PR #157 owns those shared inventory files. Add the updated roster-atlas entry to both central ledgers when that work is reconciled. This sidecar records the source and exact integration in the meantime.
