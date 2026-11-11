# Art credits and licences (Kindlewake)

| Folder / file | Source | Licence | Status |
|---|---|---|---|
| `world/tree_*, pine_*, dead_*, twisted_*, rock_*, mountain_*` (rendered from OBJ) | Stylized Nature MegaKit (Standard) by Quaternius | CC0 1.0 (`LICENSE_Quaternius_Nature_CC0.txt`) | Confirmed. |
| `world/keep, house_*, tower_*, hut` (rendered from OBJ) | Voxel building packs (Large/Small/Tall/Tiny Building), author not named in the zips | **No licence file in the zips** | **Unverified: confirm the licence before any public or commercial release.** |
| `units/soldier_*, orc_*, arrow.png` | Tiny RPG Character Asset Pack 01 v2.0, Free (Soldier and Orc) | **No licence file in the zip** (the free pack is normally free to use, check the page it came from) | **Unverified.** |
| not used: `Modern_Interiors_Free_v2_2.zip` | LimeZu | Free version is **non-commercial only and forbids editing the sprites**; modern setting | Left out on purpose. |
| not used: `Package.zip` (MountainRocks) | unknown | **No licence file** | Rendered as terrain-slab chunks, they looked wrong; not used. |

The overworld sprites are generated with `tools/render_sprites.py` (software renderer, numpy + Pillow):
`python3 tools/render_sprites.py <folder with the unzipped OBJ packs>`. Unit sprites are the original 100x100 strips, unedited
(the frame layout is in `scripts/ui/art.gd`).

Reference images supplied by the project owner (screenshots and sprite sheets from other games and asset sets) were used for
**art direction only** (style, palette, readability, ideas). No pixels from them are in the game.

| `props/field_props.svg` | Original KindleWake vector art, authored for this project | CC0 / project-created | Added: 16 environment props (ruins, rune stone, torch, reeds, crystals, grave, banner, mushrooms, stump, barrel, crate, campfire, frost pine, statue, flower, arch). |
| `ui/title_illustration.svg`, `ui/ornament_divider.svg` | Original KindleWake vector art, authored for this project | CC0 / project-created | Added: title landscape and reusable ornamental divider. |

| `units/enemies/rootbound_warden.svg`, `bell_keeper.svg`, `ashen_reeve.svg` | Original KindleWake pixel-art atlases, authored for this project | Project-created; no third-party material | Confirmed original. Each atlas is 6 columns × 7 animation rows (idle, walk, attack, hurt, cast, victory, death), with 100×100 transparent cells. |
