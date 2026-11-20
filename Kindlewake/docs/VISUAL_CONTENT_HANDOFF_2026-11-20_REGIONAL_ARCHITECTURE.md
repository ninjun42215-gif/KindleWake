# Visual content handoff — regional settlement architecture styling

## Exact source state

- Repository: https://github.com/ninjun42215-gif/KindleWake
- Project: `Kindlewake/`
- Parent visual PR: #167 — local settlement architecture detail atlas
- Parent base `main` SHA: `13f66ec19476c9af5ed2b5c81af95e4d8a026876`
- Parent head at child-branch creation: `d55e2ecaa933da434945b21a578792801707137c`
- Child branch: `art/regional-settlement-architecture-style-2026-11-20`
- Scope: subtle region-aware architecture tinting and location-specific deterministic tile selection
- This PR is intentionally stacked on #167; do not retarget it to main until the parent atlas is integrated.

## Delivered

- Added `scripts/ui/regional_architecture_style.gd`.
- Defined restrained material-color palettes for all **31 canonical regions** in the seven-continent `data/continents.json` catalogue.
- Mapped existing authored local settlement/interior IDs to their established regions: Sethmarch, Orrowen Weald, Vessmoor Plains, Quillon Heights, Tarnholt Cloisters, Aurelmont, Brinegate Coast, Isles of Vey and Kelpward.
- Unmapped future locations remain neutral; the style system does not invent playable maps or assign a future settlement to an unsupported region.
- `location_scene.gd` caches the current location's tint and stable seed when loading a map. The existing base/detail roof, facade, wall and door atlas cells are drawn with the region tint.
- Roof, facade and stone variants now use a deterministic seed derived from the location ID plus cell coordinates. Re-entering the same settlement preserves its appearance, while different settlements can show different building variants at identical map coordinates.
- Added regression coverage for canonical region mapping, neutral fallback, all 31 palette entries, tint bounds, stable location seeds, and per-location tile variation.

## Art direction and performance

- Tints are deliberately restrained (each RGB channel remains between 0.75 and 1.0) so the existing clay, slate, timber, plaster and stone materials remain recognizable.
- No external assets, fonts, scripts, packages or network dependencies were introduced.
- No runtime texture generation, image conversion, per-frame animation or additional atlas allocation was added.
- The palette helper is loaded once; tint and seed are cached on map load rather than recalculated for every tile.
- The parent PR's original 384×48 detail atlas remains the only new texture in this stacked architecture tranche. Its 72 KiB RGBA8 base-raster estimate is documented by the parent; actual Godot import and device GPU residency still require measurement.

## Compatibility and preservation

- No `locations.json` rows, map glyphs, collision, doors, NPC spots, quest hooks, movement rules, save schema, character data, story or game version were changed.
- The architecture helper only changes rendering of existing architectural atlas tiles. Non-architecture ground, water, props, NPCs and player sprites retain their current rendering.
- All future-region palettes are design tokens only until matching playable local maps are authored.

## Validation status

- Regression assertions were added to `tests/run_tests.gd`; exact-head Godot import, strict test execution and Android export are pending PR CI.
- Godot editor screenshot inspection is still required for interior/exterior consistency and portrait/landscape mobile layouts.
- The existing Android emulator process-survival/SwiftShader issue remains a separate release blocker; a successful APK export alone does not establish emulator launch success.
- Physical Android device rendering, touch, memory and frame-pacing QA have not been performed.

## Coordination and safety

- Child branch was created from exact parent PR #167 head `d55e2ecaa933da434945b21a578792801707137c`.
- The child changes only the settlement renderer, its new style helper, the shared strict test file already modified by parent #167, and this handoff.
- No portrait, equipment, character creator, battle, save-system, Android workflow, central asset manifest or provenance-ledger files were changed.
- No merge, force-push, branch deletion or repository-setting change was performed.
