# Kindlewake Art Asset Pipeline

**Status:** Active production standard  
**Updated:** 17 November 2026

## Visual target

Kindlewake should feel like a mature, premium 2D fantasy RPG. The approved portrait direction is the two user-supplied examples: painterly semi-realism, believable adult facial structure, expressive but restrained faces, layered hair, practical garments and armor, readable material separation, warm directional light, and textured atmospheric backgrounds.

Suikoden II is a craft benchmark only. Do not copy its characters, compositions, portraits, sprites, maps, interface, or proprietary assets. Kindlewake's designs must remain original.

## Portrait construction

1. **Build the head as a form, not an emoji-like face.** Establish the cranium, jaw, centerline, brow line, tilt, and perspective before detailing features. Keep the neck and shoulder connection anatomically credible.
2. **Preserve individual likeness.** Give each named character a distinct skull/jaw rhythm, eye spacing, nose shape, hairline, age cues, and expression. Avoid reusing one generic face with different hair.
3. **Separate materials.** Skin, hair, cloth, leather, metal, and background should have different value ranges and surface behavior. Metal gets compact highlights; leather gets broad worn planes; cloth gets folds that follow tension and gravity.
4. **Use controlled lighting.** One readable key direction, restrained fill, clear cast/contact shadows, and a limited warm/cool relationship. Do not add indiscriminate glow or glossy plastic skin.
5. **Keep a readable silhouette.** Hair, hood, collar, weapon and shoulder armor must remain recognizable when the portrait is reduced to the creator-gallery size.
6. **Use a consistent crop.** Square bust portraits are the current reference format. Keep the eyes above the midpoint, retain enough shoulder/garment detail to identify the role, and do not let weapons obscure the face.

Proko's head-construction lesson emphasizes the cranial mass, side plane, jaw, centerline, tilt, and perspective before facial detail. Apply that construction discipline while keeping the final Kindlewake rendering painterly and original: https://www.proko.com/course-lesson/how-to-draw-the-head-from-any-angle/

## Runtime asset pipeline

- Stable IDs remain the source of truth; do not derive file names from display names.
- `scripts/ui/portrait_resolver.gd` resolves in this order: **PNG → WebP → JPG → SVG**.
- `torren_redcloak.webp` and `auburn_ranger.webp` are the first raster portrait pilots, exported at **192×192 WebP, quality 70** from the approved user-supplied portrait references. The original high-resolution reference images remain in the conversation; these are game-ready derivatives for the current UI scale.
- The legacy SVGs remain in place as fallbacks. Godot documents WebP as a supported raster import format and notes that complex SVG support is limited, so raster artwork is the preferred route for painterly portraits: https://docs.godotengine.org/en/4.1/tutorials/assets_pipeline/importing_images.html
- The creator gallery and live preview resolve the selected portrait. The party sheet and battle timeline use raster overrides only for the stable protagonist ID `torren`; other named characters retain their existing SVGs until their own unique artwork is ready. This avoids accidentally applying Torren's or the ranger's face to unrelated companions.
- Keep layered source masters at 512 px or higher when possible. Export runtime sizes according to the largest actual UI display, ideally at least 2× that display size. The current 192 px pilots are a first runtime pass for the existing compact gallery and battle timeline. They are not final high-resolution masters; increase to at least 384–512 px before a larger character-sheet presentation or final art lock.

## Portrait-to-sprite translation

Do **not** shrink a painted portrait directly into a tiny sprite. Extract only the identity cues that survive at game scale:

- hair/hood silhouette;
- dominant garment or cloak shape;
- weapon profile;
- one heraldic or material accent.

Block the sprite silhouette first, then add proportion and a compact material palette. Test it at native game scale before adding texture. A small sprite should read by shape and color grouping, not by miniature facial detail. For a practical silhouette-first overview, see: https://piximelon.com/guides/pixel-art-characters/

## Current coverage gap

The current data has **48 character definitions but only 12 distinct portrait IDs**. Many named characters therefore share an existing portrait. The first two raster pilots improve the protagonist's selectable portrait experience; they do **not** solve unique portrait coverage for the full cast.

Enemy and ordinary NPC battle representations still use the shared character atlas/archetype mapping rather than individual painted portrait assets. Do not claim that every enemy or NPC now has a unique portrait.

## Quality gate for every new portrait

- [ ] Distinct face and silhouette; no generic same-face reuse
- [ ] Believable anatomy, head tilt, neck, shoulders and hands if visible
- [ ] Costume construction and material response are grounded in the character's role and world
- [ ] Light direction and shadow structure are consistent
- [ ] Reads clearly in the 78 px creator gallery and 58 px battle timeline
- [ ] Character sheet crop does not cut off defining features
- [ ] The chosen portrait ID matches the same character in creator, party sheet and battle UI
- [ ] Android import/render checked before calling the asset complete
