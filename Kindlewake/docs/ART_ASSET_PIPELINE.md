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
- `torren_redcloak.webp` and `auburn_ranger.webp` are the first raster portrait pilots, exported at **192×192 WebP, quality 70** from the user's two supplied reference portraits. Torren uses the male swordsman reference; Sela Wrenfield (archer) uses the auburn ranger reference in party and battle presentation, while it remains available as a creator option.
- `kestrel.webp` is a **256×256 WebP, quality 74** original Kindlewake portrait crop assigned to Kestrel, the silent assassin. It was cropped from the project's existing 4×3 portrait concept sheet; the 512×512 PNG working master is retained in the project Library. The crop is an effective runtime asset, not a final layered master—repaint at 1024 px or larger before final art lock.
- The legacy SVGs remain in place as fallbacks. Godot 4.2 supports WebP as a raster import format and notes that complex SVG support is limited; its 2D defaults use lossless texture compression, which is the preferred import setting for final painterly portraits: https://docs.godotengine.org/en/4.2/tutorials/assets_pipeline/importing_images.html
- The creator gallery and live preview resolve the selected portrait. The party sheet and battle timeline now use `load_character_texture(portrait_id, character_id)`: explicit raster overrides map `torren` → `torren_redcloak`, `sela` → `auburn_ranger`, and `kestrel` → `kestrel`. Other characters that still share a generic portrait ID remain on their legacy SVGs unless a character-specific raster override is explicitly approved. This prevents one painterly face from leaking across unrelated companions, enemies, or NPCs.
- Keep layered source masters at 512 px or higher when possible. Export runtime sizes according to the largest actual UI display, ideally at least 2× that display size. The current 192 px pilots are a first runtime pass for the existing compact gallery and battle timeline. They are not final high-resolution masters; increase to at least 384–512 px before a larger character-sheet presentation or final art lock.

## Portrait-to-sprite translation

Do **not** shrink a painted portrait directly into a tiny sprite. Extract only the identity cues that survive at game scale:

- hair/hood silhouette;
- dominant garment or cloak shape;
- weapon profile;
- one heraldic or material accent.

Block the sprite silhouette first, then add proportion and a compact material palette. Test it at native game scale before adding texture. A small sprite should read by shape and color grouping, not by miniature facial detail. For a practical silhouette-first overview, see: https://piximelon.com/guides/pixel-art-characters/

## Current coverage gap

The current data has **48 character definitions and 22 distinct portrait IDs** after Kestrel received a unique ID. **11 portrait IDs are still shared by multiple definitions**, so the cast does not yet have one distinct portrait per named character. Torren, Sela, and Kestrel now have character-aware raster presentation; the remaining shared IDs stay on legacy SVGs until dedicated art is approved.

Enemy and ordinary NPC battle representations still use the shared character atlas/archetype mapping rather than individual painted portrait assets. Do not claim that every enemy or NPC now has a unique portrait.

## Quality gate for every new portrait

- [ ] Distinct face and silhouette; no generic same-face reuse
- [ ] Believable anatomy, head tilt, neck, shoulders and hands if visible
- [ ] Costume construction and material response are grounded in the character's role and world
- [ ] Light direction and shadow structure are consistent
- [ ] Reads clearly in the 78 px creator gallery and 58 px battle timeline
- [ ] Character sheet crop does not cut off defining features
- [ ] The chosen portrait ID matches the same character in creator, party sheet and battle UI
- [ ] A raster portrait is assigned through an explicit character-aware override or a unique character ID; shared legacy IDs never inherit another character's raster face
- [ ] Android import/render checked before calling the asset complete


## Daily production note — 18 November 2026: character-specific portrait routing

**Highest-impact weakness:** painterly portrait files existed, but the party sheet and battle timeline only allowed raster overrides for Torren. Several character definitions also shared IDs such as `auburn_ranger`; simply enabling raster-first loading globally would incorrectly show the same face on unrelated characters.

**Iteration:** added a character-aware resolver and routed both the party sheet and battle timeline through it. Torren resolves to `torren_redcloak.webp`; Sela Wrenfield resolves to the approved auburn ranger portrait; Kestrel resolves to her new `kestrel.webp`. Shared IDs remain on SVG fallback unless explicitly mapped. Kestrel's data record now has its own stable portrait ID.

**Research applied:** Proko's head-construction method stresses the cranial mass, side plane, jaw, head tilt and perspective before facial detail. Krita's layer/mask workflow supports non-destructive changes to individual materials and composition. For future masters, keep skin, hair, cloth, leather, metal, lighting and background on separate named layers; do not rely on texture noise to create realism.

**Sources:**
- Proko, [How to Draw the Head from Any Angle](https://www.proko.com/course-lesson/how-to-draw-the-head-from-any-angle/)
- Krita Manual, [Introduction to Layers and Masks](https://www.krita.org/en/reference_manual/layers_and_masks.html)
- Godot 4.2 Manual, [Importing Images](https://docs.godotengine.org/en/4.2/tutorials/assets_pipeline/importing_images.html)

**Verification target:** run the title/creator UI regression and the Android build after integration. The 256 px Kestrel export is suitable for the current compact UI; it is not the final 1024 px layered master.
