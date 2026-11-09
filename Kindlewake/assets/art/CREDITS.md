# Art credits and licences (Kindlewake)

| Folder / file | Source | Licence | Status |
|---|---|---|---|
| `world/tree_*, pine_*, dead_*, twisted_*, rock_*, mountain_*` (rendered from OBJ) | Stylized Nature MegaKit (Standard) by Quaternius ([official pack page](https://quaternius.com/packs/stylizednaturemegakit.html)) | CC0 1.0 (`LICENSE_Quaternius_Nature_CC0.txt`; official page also identifies CC0 and commercial use) | Confirmed. |
| `world/keep, house_*, tower_*, hut` (rendered from OBJ) | Voxel building packs (Large/Small/Tall/Tiny Building), author not named in the zips | **No licence file in the zips** | **Unverified: confirm the licence before any public or commercial release.** |
| `units/soldier_*, orc_*, arrow.png` | Tiny RPG Character Asset Pack 01 v2.0 — Free Soldier & Orc subset by Zerie ([official pack page](https://zerie.itch.io/tiny-rpg-character-asset-pack)) | Author-published terms: personal and commercial game use and modification permitted; standalone redistribution/resale prohibited; credit appreciated but not required. | **Verified from the author’s official page** (checked 2026-11-10). Keep the original pack out of standalone redistribution. |
| not used: `Modern_Interiors_Free_v2_2.zip` | LimeZu | Free version is **non-commercial only and forbids editing the sprites**; modern setting | Left out on purpose. |
| not used: `Package.zip` (MountainRocks) | unknown | **No licence file** | Rendered as terrain-slab chunks, they looked wrong; not used. |

The overworld sprites are generated with `tools/render_sprites.py` (software renderer, numpy + Pillow):
`python3 tools/render_sprites.py <folder with the unzipped OBJ packs>`. Unit sprites are the original 100x100 strips, unedited
(the frame layout is in `scripts/ui/art.gd`).

Reference images supplied by the project owner (screenshots and sprite sheets from other games and asset sets) were used for
**art direction only** (style, palette, readability, ideas). No pixels from them are in the game.


Structured machine-readable inventory: `Kindlewake/data/asset_provenance.json`. Keep this ledger synchronized with the table above; used packs marked unverified block public/commercial release.
