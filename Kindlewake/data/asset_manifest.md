# Asset manifest — runtime use and remaining work

This manifest describes the assets currently present in the default branch. It replaces the earlier prototype note that described all art as procedural placeholder geometry.

## Runtime assets

| Asset group | Current use | Compatibility notes |
|---|---|---|
| `art/world/*.svg` | Eight original KindleWake settlement illustrations: three houses, hut, keep and three towers | Loaded by `scripts/ui/art.gd`; preserve SVG viewBox, transparent padding and intended silhouette. |
| `art/props/field_props.svg` | Sixteen original field/environment props | Original project art; individual symbols share an atlas. Keep source rects and texture regions aligned. |
| `art/runes/rune_atlas.svg` | Rune/sigil icon atlas | UI atlas; verify source rectangles against the rune catalogue before adding IDs. |
| `art/ui/*.svg` | Title illustration and UI divider/ornament | UI-only; scale with aspect ratio preserved. |
| `art/world/*_{a,b,c}.png` nature sprites | Tree, pine, dead tree, twisted tree, rock and mountain world props rendered from Quaternius Stylized Nature MegaKit | CC0 1.0; source licence retained in `LICENSE_Quaternius_Nature_CC0.txt`. |
| `art/units/soldier_*.png`, `orc_*.png`, `arrow.png` | Soldier/Orc animation strips and projectile art | Free subset from Zerie's Tiny RPG Character Asset Pack 01 v2.0. Use the original frame layout; do not redistribute the source pack standalone. |
| `icons/*` | Android application icon variants | Keep foreground/background/icon dimensions aligned with Android export settings. |

## Retained but not runtime assets

- Legacy voxel settlement PNGs are retained for provenance/history. The runtime uses original KindleWake SVG replacements. The original voxel-building pack source/licence is unverified, but the pack is marked `used_in_game: false` and is not a current used-game release blocker.
- `optional_sprite_packs/*.zip` are archival/optional downloads, not integrated runtime assets. Some have unknown provenance or restrictive terms. Do not import or redistribute them until each source and licence is verified.
- The LimeZu free interior pack is non-commercial and editing-restricted per current project notes; it is intentionally not used.
- The MountainRocks sample archive has no recorded licence and is intentionally not used.

## Known production art gaps

- There are no bundled font files, music tracks or sound-effect files.
- Only Soldier/Orc character strips are bundled; most playable classes and named companions do not yet have a complete original portrait, idle, movement, attack, hit and defeat animation set.
- Bosses and regional enemy factions need distinct silhouettes, telegraphs and attack animations before being considered visually complete.
- World and battle scenes still use procedural/vector primitives for several elements. This is acceptable for mechanics testing, not final visual polish.
- UI needs a bundled typography system, scalable nine-slice panels, consistent icon sizing, touch-target verification and safe-area review.

## Sprite compatibility checklist

Before importing a new sheet:
1. Record source, author, licence, evidence and whether the asset is used in `data/asset_provenance.json`.
2. Confirm frame width/height, frame count, row order, transparency and pixel density.
3. Confirm pivot/foot anchor and facing direction match the character's collision footprint.
4. Verify idle/walk/attack/hurt/death animations use consistent dimensions and timing.
5. Check texture filtering and import settings at the target 720p/portrait/landscape resolutions.
6. Verify that the atlas/source rectangle used by code matches the actual texture dimensions.
7. Run scene smoke and inspect the asset in a real battle/world scene on Android.

## Authoritative provenance

Keep this file synchronized with:
- `data/asset_provenance.json`
- `assets/art/CREDITS.md`
- `docs/PRODUCTION_AUDIT_AND_ROADMAP.md`

Do not mark a third-party asset verified without authoritative licence evidence. Project-authored art should be labelled as original project content, not automatically described as CC0.
