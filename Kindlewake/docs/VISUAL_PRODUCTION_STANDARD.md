# KindleWake — Visual Production Standard

**Status:** First implementation pass; shared Godot Theme is active from `project.godot`.
**Baseline:** v0.12.0, save schema 4. This work must not change gameplay data, saves, offline behavior or the release version.

## Creative target

A grounded, mature medieval-fantasy tactical RPG with cinematic composition and tactile materials. The world should feel inhabited and weathered rather than glossy, toy-like or generically high fantasy. The art direction is original KindleWake IP; external games are references for production quality and clarity only.

## Shared visual language

- **Foundation:** charcoal iron, smoked oak, worn slate and deep forest green.
- **Warm accent:** aged brass / muted gold for selection, focus, important rewards and faction authority.
- **Light accent:** parchment ivory for readable text and important narrative information.
- **Threat accent:** restrained rust / oxblood for danger, wounds and destructive states.
- **Surface treatment:** subtle grain and edge wear belong in authored textures, not runtime noise overlays that reduce text clarity.
- **Lighting:** one readable key-light direction per scene; warm interior pools against cooler ambient shadows.
- **Composition:** clear focal point, foreground/midground/background separation, negative space behind text and UI.
- **Typography:** readable serif display faces for chapter / location identity and a highly legible sans-serif for controls, stats and dense data. Bundle only fonts with documented compatible licences (prefer OFL); no system-font assumptions for final release.
- **Motion:** restrained transitions, short easing, clear attack anticipation / impact / recovery. Never animate critical text or tactical telegraphs in ways that obscure information.

## Implemented foundation

`assets/themes/kindlewake_premium.tres` provides a global Theme for standard Godot controls:
- dark iron panels with restrained brass borders;
- high-contrast ivory text;
- distinct normal, hover, pressed, disabled and keyboard/controller focus button states;
- matching LineEdit and TextEdit surfaces;
- 18 px default UI font size as a starting point for the 1280×720 logical viewport.

This is a baseline, not proof that every screen is fully reskinned. Code-built controls that set their own theme overrides or custom drawing must be audited and migrated deliberately. Do not remove useful per-screen contrast or tactical status colours merely to force uniformity.

## Asset production order

### P0 — first playable company and core interface
1. Player heir and four starting companions: consistent portrait crop, expression range, signature prop, class silhouette and combat sprite.
2. Core controls: buttons, tabs, cards, selection frames, separators, scrollbars, tooltips, controller focus and disabled / warning / success states.
3. Kaer Sethorn, Sallow Crossing / Brinegate Coast and the first battle maps: readable landmarks, coherent materials, purposeful prop placement and clear traversal.
4. Battle readability kit: movement range, selected tile, attack range, target intent, damage / heal feedback and objective markers.

### P1 — world and encounter identity
- Six house heraldry families: banners, shields, seals, uniforms and faction colour accents.
- Enemy families and bosses: distinct silhouettes, readable wind-ups, impact / stagger / defeat states.
- Town interiors and facilities: functional staging, warm/cold lighting contrast and environmental story details.
- Regional tile / prop kits that preserve distinct architecture, vegetation, climate and material language.

### P2 — emotional and atmospheric polish
- Companion expression portraits and personal-quest scenes.
- Weather, ambient particles, contextual battle effects and scene transitions.
- Original music motifs and location ambience, subject to separate audio implementation and licence review.

## Asset acceptance contract

Every shipped asset must have a manifest entry recording:
- stable asset ID and path;
- category, dimensions, intended scale and in-game use;
- author / source URL and exact licence;
- required attribution and permitted modifications;
- palette / style family and any derivative source;
- optimisation notes and responsible reviewer.

Unknown or incompatible licences are not distributable. The previously identified third-party voxel / sprite-pack licensing issue remains a release blocker until authoritative permission is recorded or the assets are replaced with original or compatible-licence work. Do not silently repackage, rename or remove provenance.

## Mobile and tactical quality gates

- Keep essential touch targets at least 48 dp where practical; maintain spacing for thumb use.
- Test 20:9 and 16:9 landscape layouts, notches / safe areas, compact phones and high-density displays.
- Keep critical labels and combat telegraphs readable at actual phone scale.
- Provide non-colour-only status cues (shape, icon or text) and restrained flashes.
- Preserve controller, keyboard and touch focus visibility.
- Profile texture dimensions, memory, draw calls and frame time on Android GL Compatibility.
- Test scene readability with effects disabled and at reduced brightness.
- Run Godot import, strict tests, scene smoke tests and Android export on the exact PR head. Physical-device QA is a separate required gate.

## Next production slices

1. Audit every current screen for theme overrides and migrate the highest-traffic surfaces without breaking existing layout or interactions.
2. Lock the portrait / sprite / environment technical specs against the actual asset pipeline and current source licences.
3. Replace or clear P0 assets in small batches, beginning with the player company and the first region.
4. Add controlled animation / combat feedback only after baseline frame-time and readability checks.
5. Capture before / after screenshots at phone resolution and review with the same scenes and device scale.

A shared Theme is the first visual foundation, not a claim that new portraits, sprites, maps, animation, music or physical-device polish are already complete.
