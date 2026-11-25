# Title codex crest divider — asset provenance

- **Runtime path:** `assets/art/ui/title_crest_divider.svg`
- **Canvas:** 320 × 54 SVG viewBox; rendered in the title menu at a responsive width between 224 and 320 logical pixels and a fixed 54-pixel height.
- **Creator/source:** Original KindleWake project vector artwork authored in this repository.
- **Design intent:** A restrained open-codex motif beneath a single rising flame and seven small sparks, framed by brass cartographic lines. It is a decorative echo of the established record-keeping and Covenant of the Seven Flames themes; it does not introduce a new house, faction, item, quest, or canonical insignia.
- **Rights/provenance:** Project-authored geometry. No third-party art packs, game screenshots, external fonts, generated raster images, linked resources, or licensed assets are embedded.
- **SVG constraints:** Paths, circles, gradients and groups only. No raster image, `href`, filter, mask, foreign object, script, or external resource.
- **Godot integration:** The existing title screen's divider TextureRect loads this exact SVG. The decoration retains `MOUSE_FILTER_IGNORE`, uses linear texture filtering, and adapts its width to narrow viewports without changing the title menu's button callbacks or scene flow.
- **Preservation:** No story, save data/schema, character data, menu actions, settings, project version, Android permission, or scene route changes.
- **Review gate:** The title screen should still be checked in the Godot editor at narrow portrait and landscape sizes. Headless texture import and regression assertions are not a substitute for screenshots or physical-device review.
