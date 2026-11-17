# KindleWake runtime visual asset manifest

**Baseline:** main adf3d44bbeef1e1e048f2aa244a1a80bf95147fc · Godot 4.2.2 · GL Compatibility · Android · offline-first.

## Art direction

Painterly medieval realism translated into crisp, readable 2D/isometric game art: weathered materials, strong silhouettes, restrained saturation, warm human interiors against colder political exteriors. Keep the existing muted pixel-art/gameplay scale coherent; use original vector art for scalable UI and map ornaments. Do not mix in unrelated packs or imply that the seven-continent atlas makes all seven continents playable.

## Runtime-integrated assets

| Asset family | Runtime source / contract | Provenance and status |
|---|---|---|
| Overworld vegetation and rock silhouettes | assets/art/world/tree_*, pine_*, dead_*, twisted_*, rock_*, mountain_*; rendered through tools/render_sprites.py and Art.world() | Quaternius Stylized Nature MegaKit, CC0 1.0; official source and licence recorded in data/asset_provenance.json. |
| Settlement silhouettes | assets/art/world/house_a.svg, house_b.svg, house_c.svg, hut.svg, keep.svg, tower_a.svg, tower_b.svg, tower_c.svg; loaded by Art.world() | Original KindleWake vector art; replaces runtime use of legacy voxel-building PNGs. |
| Field props | assets/art/props/field_props.svg; 512×512 SVG, 4×4 cells at 128×128; rendered by Art.draw_prop() | Original KindleWake vector art: arch, column, rune stone, torch, reeds, crystals, grave, banner, mushrooms, stump, barrel, crate, campfire, frost pine, statue and flower. |
| Tactical / exploration units | assets/art/units/soldier_*, orc_*, arrow.png; 100×100 horizontal animation frames interpreted by scripts/ui/art.gd | Tiny RPG Character Asset Pack 01 free Soldier/Orc subset by Zerie. The author's official terms permit personal/commercial game use and modification; do not redistribute the source pack standalone. |
| Seven-continent heraldry | assets/art/atlas/continent_sigils.svg; 896×128 SVG, seven 128×128 cells; rendered by the non-interactive ContinentHeraldryLayer child of GlobalAtlas.tscn | Original KindleWake vector artwork. The id-to-cell mapping follows data/continents.json and is documented in scripts/ui/continent_heraldry_layer.gd. |
| New protagonist portrait concepts | assets/art/portraits/maelin_tidecaller.svg, kellan_ashward.svg, nyra_briar.svg and orin_lantern.svg; 512×512 SVG; resolved by PortraitResolver for creator and party views; appearance metadata is consumed by Art.draw_kindlewake_lead() | Four original KindleWake vector concepts. Provenance is recorded in data/asset_provenance.json; these are concept assets, not final painterly portrait masters. |

## Excluded or historical material

- Legacy voxel-building PNGs and source packs have unresolved provenance and are not loaded by the current runtime. Do not add them back to scenes or include them in a release without authoritative licence evidence.
- assets/optional_sprite_packs/ is an intake/source archive, not a production asset library. Do not extract or import an archive until its exact contents, author, licence, modification rights, redistribution rights, dimensions and Godot compatibility are reviewed.
- LimeZu Modern Interiors Free is recorded as non-commercial and non-editable; it remains excluded.
- The MountainRocks archive has no recorded licence; it remains excluded.
- The existing Soldier/Orc licence does not permit standalone redistribution of the original source pack. Keep the game-use subset and its provenance distinct from the source archive.

## Known production gaps

- The four new protagonist portraits load as original vector concept art; they are not yet the approved final painterly semi-realistic masters.
- Named companion, NPC, enemy and boss portrait coverage still needs unique, approved final artwork.
- Named recruit portraits must be matched to the exact approved sprite identity; do not fabricate portrait-to-sprite links.
- The current Soldier/Orc subset does not provide a complete class-specific companion, human-enemy and boss roster.
- The seven-continent atlas is inspectable, but regional maps, quests, encounters and travel gates are not complete for every continent. Do not label locked regions as playable.
- Dedicated boss portraits, dungeon kits, regional settlement variants, battle VFX, equipment/item icon families, typography assets and authored audio remain separate production work.

## Mobile and performance rules

- Keep atlas and UI vector assets compact; avoid loading a full-resolution image for a small phone icon.
- The new sigil atlas is one 896×128 SVG (seven 128×128 cells), loaded once by the scene script. The UI draws only the seven mapped regions; it creates no runtime textures, animation loops or per-frame image data.
- A base RGBA8 raster of 896×128 would occupy 458,752 bytes (about 0.44 MiB) before mipmaps/driver overhead. This is a planning estimate, not a measured Godot import or Android GPU-memory result.
- Preserve the parent atlas's responsive map geometry and labels. The overlay uses 38 px icons in portrait and 46 px in landscape, sits above the map but ignores mouse input, and does not shrink text or change touch targets.
- Confirm imported texture dimensions, SVG rasterization, frame pacing and actual memory on the Godot 4.2.2 Android export before treating the budget as measured.

## Verification status

- SVG source was parsed and raster-previewed locally; seven symbols are present in the intended order and remain distinct at the 38 px portrait presentation size.
- The scene integration is isolated to GlobalAtlas.tscn plus a new draw-only child script. No gameplay rules, save data, save schema, project version, external dependency or Android permission was changed.
- Godot editor import, headless scene smoke, Android APK export, in-editor screenshot inspection and physical-device viewport/touch/performance QA are pending for this branch. CI results must be checked against the exact PR head.


## Reviewed candidate — not imported

- Foozle Pixel Magic Effects: https://foozlecc.itch.io/pixel-magic-sprite-effects. The source page states CC0 1.0 and permits commercial use/modification. It remains a candidate only: the archive, frame layout and Godot import contract have not been reviewed or integrated in this project.

## 2026-11-17 — Protagonist portrait gallery expansion

- Added four original 512×512 SVG portrait concepts: Maelin Tidecaller, Kellan Ashward, Nyra Briar and Orin Lantern. They are new protagonist appearance choices, not new canonical party members or named NPCs.
- The creator gallery now has 16 stable portrait IDs. Portrait textures are resolved through the existing PNG → WebP → JPG → SVG resolver; no existing portrait or save ID was renamed.
- Each gallery record includes a sprite_accent palette value. The shared protagonist renderer reads the saved creation_profile.portrait_id and draws a small matching chest mark in exploration and tactical battle. The current directional sprite still shares its base face/hair silhouette by presentation; this is a palette bridge, not full individualized sprite anatomy.
- The mobile gallery uses two columns below 460 px, three below 900 px and four on wider viewports, with larger portrait tiles on narrow screens.
- All four SVGs are project-authored and use gradients, paths and basic shapes only. No third-party images, fonts, audio or filters were used.
- A 512×512 RGBA import would be approximately 1 MiB per portrait before driver/compression overhead. The creator gallery loads the four new portrait textures alongside its existing choices; this is an estimate, not measured Android GPU memory.

