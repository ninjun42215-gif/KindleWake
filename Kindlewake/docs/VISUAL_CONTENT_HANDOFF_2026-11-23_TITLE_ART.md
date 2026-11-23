# Visual content handoff — 23 November 2026: title-screen landscape

## Summary
Replaced the previous geometric title backdrop with a more layered original illustration of Kaer Sethorn at dawn: distant mountain shelves, a fortified ridge, curtain wall and towers, a stone river bridge, a winding river, mist bands and foreground pines. The composition keeps the strongest castle detail on the right and leaves the central valley comparatively quiet behind the title panel.

## Runtime integration
- Existing `TitleScreen.tscn` continues to instantiate `scripts/ui/title_screen.gd`.
- The script continues to load `res://assets/art/ui/title_illustration.svg`; no scene path or menu flow changed.
- Updated the TextureRect to use linear filtering and raised the illustration's visible contribution while reducing the solid wash from 0.48 to 0.36. The opaque menu panel, labels, button callbacks, creator overlay, save browser, settings and exit flow are unchanged.
- The new SVG is 1200×700, 16,383 bytes and uses only vector paths, circles, rectangles, groups and linear gradients. It has no embedded raster images, fonts, external references, filters or masks.
- The source passed XML parsing and rendered locally to a 1200×700 preview with CairoSVG. This is source-level preview evidence, not a Godot editor screenshot.

## Provenance
- The SVG is original KindleWake vector geometry authored for this project.
- An OpenAI ImageGen concept was used as a composition reference only; the generated raster is not shipped or embedded.
- Per-asset source and rights notes: `assets/art/ui/title_illustration_provenance.md`.
- No third-party pack or external artwork was imported. The existing broad central original-art ledger entry was not edited because active portrait work owns the shared provenance/credits files; reconcile the per-asset note into the central ledger after that work lands.

## Preservation
No story, lore, save format, character data, gameplay rules, project version, Android permissions, menu actions, creator flow or scene routing changed. The old SVG path remains valid, so no resource path migration is required.

## Verification status
- XML parse: passed locally.
- CairoSVG render at 1200×700: passed locally.
- GitHub Project Health, YAML lint, Godot import, scene smoke and Android APK workflows: requested by the draft PR; record exact-head results after Actions completes.
- Godot editor screenshot, landscape/portrait safe-area review, and physical Android rendering/touch/frame-pacing checks remain outstanding. No device test is claimed.

## Exact refs
- Base main: `13f66ec19476c9af5ed2b5c81af95e4d8a026876`.
- Branch: `art/cinematic-title-screen-landscape-2026-11-23`.
- SVG implementation commit: `e074c62ec2e5c246ac20394a85e7ecbf6533df5d`.
- Title-screen presentation commit: `2baab6e1901a6c3b649730aa086cbcbddb01b151`.
- Provenance commit: `724848737b3e729d75c9409185e1b2bda51ed0ed`.
- Handoff commit: recorded by the final PR head.
