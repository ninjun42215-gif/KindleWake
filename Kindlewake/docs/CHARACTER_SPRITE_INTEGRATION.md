# KindleWake lead sprite integration

## Source art and layout
- Male source: the user-provided 1024x1536 transparent sprite sheet.
- Female source: a matching generated transparent sprite sheet.
- Both sheets use a 4x4 layout: columns are four animation poses; rows are front, left-facing, right-facing and rear views.
- Runtime atlas frame size: 64x96 pixels; expected atlas size: 256x384 pixels.
- Keep alpha transparency. Do not include checkerboard previews or matte backgrounds in the runtime export.

## Runtime paths
- `res://assets/art/units/kindlewake_lead_male.webp`
- `res://assets/art/units/kindlewake_lead_female.webp`

## Battle rendering
`Art.draw_kindlewake_lead()` selects a direction row from the battle unit's facing vector and cycles the four columns. `battle_scene.gd` uses the custom sheet for Torren / player_lead and selects the female atlas when the character's saved `creation.presentation` (or `presentation`) is `feminine`. Other characters continue through the existing sprite renderer.

## Asset import gate
The battle renderer intentionally falls back to the existing character atlas when either custom atlas is absent. Before shipping, place both WebP atlases at the exact runtime paths above and run a Godot headless import/build plus an Android battle smoke test. Confirm idle, walking, all four directions, target selection, damage, and turn transitions.
