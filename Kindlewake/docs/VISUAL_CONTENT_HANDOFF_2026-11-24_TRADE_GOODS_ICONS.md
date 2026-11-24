# Visual-content handoff — regional trade-goods iconography

## Repository and scope

- Repository: `ninjun42215-gif/KindleWake`
- Base branch: `main`
- Base SHA at branch creation: `13f66ec19476c9af5ed2b5c81af95e4d8a026876`
- Branch: `art/trade-goods-iconography-2026-11-24`
- Scope: original market icon atlas plus its runtime integration in the regional exchange UI.
- No story, lore, economy values, market rules, cargo rules, saves, save schema, project version, Android permissions or workflows are changed.

## Delivered

- Added a 384 × 128 SVG atlas with twelve original 64 × 64 symbols: grain, salt, dried fish, timber, iron ore, herbs, wool, leather, honey, pearls, glassware and spices.
- Added `TradeGoodsIconAtlas`, mapping exact stable trade-good IDs to AtlasTexture regions. The texture is loaded once and reused; per-row AtlasTexture resources only reference the shared imported atlas.
- Integrated a 44 × 44 icon at the left of each market commodity heading. Unknown IDs preserve the existing text-only behavior.
- Extended the existing merchant-screen runtime test to verify the atlas dimensions, all twelve mappings, visible row textures and unchanged buy/sell row controls.
- Added a per-asset provenance note and this handoff. No unverified third-party asset was imported.

## Performance and compatibility

- One small vector texture: 384 × 128 logical pixels.
- At 44 × 44 display size, the icons are downscaled from 64 px source cells.
- No per-frame drawing, timers, shaders, animations, external fonts, or network resources.
- The static resolver caches the imported Texture2D and creates lightweight AtlasTexture region wrappers per row.
- Existing market quotes, sort order, prices, stock, cargo, transaction callbacks and save data remain authoritative and unchanged.

## Verification status

- The build workflow runs `tests/merchant_screen_test.tscn` under strict mode; this exercises the real regional exchange overlay and its buy/sell actions.
- Exact-head Project Health Audit, Workflow YAML Lint, Version Sync and Android Build results must be recorded after CI completes.
- Godot editor screenshots at portrait and landscape phone sizes are still required for final visual review.
- CI emulator checks are not physical-device QA. Touch, texture residency and frame pacing on a physical Android device remain outstanding.
- No APK is a production release unless the protected production-release workflow publishes it from the exact immutable source tag.

## Coordination

- This branch starts from main SHA `13f66ec19476c9af5ed2b5c81af95e4d8a026876`.
- It changes `merchant_screen.gd` and `merchant_screen_test.gd`; no currently open PR listed at branch creation modified either file.
- It avoids `party_screen.gd`, `location_scene.gd`, `world_scene.gd`, battle code, title/creator UI, atlas/cartography files, workflows and central asset ledgers.
- The central provenance ledger and credits table require a later reconciliation because portrait PR #157 currently changes those shared files.

## Safety

- Main is not modified.
- No merge, force-push, branch deletion, repository-setting change, release publication or secret access is performed.
