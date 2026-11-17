# Visual/content handoff — equipment icon atlas — 2026-11-17

## Repository checkpoint

- Repository: `ninjun42215-gif/KindleWake`
- Project: `Kindlewake/`
- Branch: `art/equipment-icon-atlas-2026-11-17`
- Base main SHA: `adf3d44bbeef1e1e048f2aa244a1a80bf95147fc`
- Runtime: Godot 4.2.2, GL Compatibility, Android, offline-first
- This branch is independent of the active protagonist portrait PR #157 and does not modify its files.
- No main merge, force-push, save/schema change, gameplay balance change or third-party asset import was performed.

## Delivered vertical slice

- Added a 16-cell original SVG category atlas for weapons, armor, shields, helms, accessories, trade goods, consumables and a neutral fallback.
- Added `EquipmentIconAtlas`, a small resolver that maps item slot and weapon identity to a stable 64×64 atlas cell.
- Integrated icons into current equipment slots, inventory equip choices, shop buy rows and sell rows in the existing Party screen.
- Rune shop rows continue to use the existing rune atlas rather than substituting an equipment icon.
- Added a dedicated headless regression script and wired it into the strict Android build pipeline.

## Compatibility and performance

- One 256×256 SVG is preloaded and reused through `AtlasTexture` regions.
- No third-party art, font, network dependency or new plugin is introduced.
- No per-frame draw loop, timer or runtime image conversion is added.
- The 0.25 MiB RGBA8 figure is a base-raster estimate only; Godot import size, Android VRAM residency and frame pacing require device measurement.

## Provenance coordination

The existing central `data/asset_provenance.json`, `data/asset_manifest.md` and shared `assets/art/CREDITS.md` are being updated by active portrait PR #157. To avoid editing the same files concurrently, this tranche records its original-art provenance in `assets/art/items/README.md`. Consolidate it into the central ledger after the overlapping visual PR is resolved.

## Verification plan

- Strict Android build must import the SVG, run the new icon test, run existing regression suites, export and sign the APK.
- The CI emulator screenshot must be inspected for actual visual output; a successful APK export is not visual verification.
- Physical Android QA remains required for touch targets, layout, GPU memory and frame pacing.

## Remaining art work

- This icon family is a UI aid, not a replacement for unique item illustrations, character equipment sprites, companion portraits, enemy/boss art, regional environment kits, battle VFX or audio.
- The existing character art pipeline remains the source of truth for portrait-to-sprite identity.
