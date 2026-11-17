# KindleWake Character Art Expansion

## Art direction
The lead character's approved visual direction is a grounded JRPG fantasy look: dark tousled hair, teal travel coat with bronze trim, ivory scarf, leather harness, practical boots and a sheathed sword. Keep the palette readable at phone size: deep teal, warm bronze, ivory, charcoal and restrained skin tones.

## Character coverage rules
- Every playable/recruitable character uses a distinct portrait ID and a matching field-unit archetype where available.
- Named NPCs receive portraits based on role, faction, age and region; do not assign one unrelated portrait to multiple named characters.
- Enemy portraits must reflect their creature/faction rather than reusing a hero portrait.
- Boss portraits must be unique and remain consistent between dialogue, battle intro and bestiary.
- Missing assets must be reported during validation; do not silently substitute a generic face.

## Lead character
- ID: torren_redcloak
- Character: Torren Dunmarrow
- Design: dark-haired fallen heir, teal coat, bronze fastenings, ivory scarf, leather sword harness.
- Existing portrait file: assets/art/portraits/torren_redcloak.svg

## Engine integration
Godot resolves portrait assets from `res://assets/art/portraits/` using the character's `portrait_id`. Supported extensions are PNG, WEBP, JPG and SVG. Keep the existing resolver contract intact.
The generated 4x4 concept sheet is a visual reference only; its cells must be sliced, background-cleaned and verified before being used as a runtime animation sheet. Do not import the unsliced sheet as a single character texture.

## Completion checklist
- [ ] Audit all character IDs in data/characters.json and all named NPC definitions.
- [ ] Give each named recruit, NPC, enemy and boss a unique portrait asset.
- [ ] Update portrait_id references without changing combat stats or story flags.
- [ ] Add matching unit sprites and animation strips for playable/recruitable characters.
- [ ] Run the portrait coverage test and Godot headless scene smoke tests.
- [ ] Verify Android export and inspect portraits on narrow phone screens.

## 2026-11-17 protagonist gallery increment

The creator now offers sixteen selectable portrait identities. Four original vector concepts were added: Maelin Tidecaller, Kellan Ashward, Nyra Briar and Orin Lantern. Each has a stable portrait ID, presentation/appearance metadata and a sprite accent color. Narrow phone layouts now show two larger portrait tiles per row.

The chosen portrait ID and its appearance metadata remain part of the confirmed creation profile and are preserved by the existing campaign save path. The exploration and battle protagonist renderer now translates presentation, face style, hair style/colour, skin tone and build into the directional sprite, alongside the portrait's palette accent. The animation poses and core body atlas remain shared by presentation, so this is a readable identity translation rather than a pixel-perfect painted likeness.

These four assets are original project-authored SVGs, not third-party pack imports. They are concept-level vector portraits and do not replace the approved painterly semi-realistic final-art target.

