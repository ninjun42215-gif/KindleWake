# Rune icon atlas

- Runtime file: `rune_atlas.svg`
- Canvas: 400 × 240 SVG; 10 columns × 6 rows; each cell is 40 × 40 px.
- The grid contract is consumed by `scripts/ui/party_screen.gd::_rune_icon()`; do not reorder columns or rows without updating that resolver and its tests.
- Columns, in order: arcane, vitality, flame, frost, holy, shadow, storm, earth, wind, fortune.
- Rows, in order: common, uncommon, rare, epic, legendary, mythical.
- Each rune family has a distinct original glyph; rarity is communicated by the outer frame and small grade pips, while the glyph accent identifies the family.
- Authorship: original KindleWake project vector artwork authored in this repository for this replacement atlas.
- Rights: original project content; no third-party source images, fonts, filters, external resources or packages.
- Import contract: SVG only, no raster embedding, external references, CSS, filters or runtime texture generation. Existing `AtlasTexture` cell regions remain 40 × 40 px.
- Base RGBA8 raster planning estimate: 400 × 240 × 4 = 384,000 bytes (375 KiB) before importer compression, mipmaps or driver overhead. This is not a measured Android GPU-memory value.
- Visual review is required at the actual 40 px mobile presentation size. Physical-device texture residency and frame pacing remain unmeasured.
