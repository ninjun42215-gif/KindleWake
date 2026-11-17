# KindleWake lead sprite integration

## Source art and layout
- Male source: the user-provided 1024x1536 transparent sprite sheet.
- Female source: a matching generated transparent sprite sheet.
- The combined atlas is 512x1280. It contains separate male and female 4x4 sheets: columns select front, left-facing, right-facing and rear views; rows select four animation poses.
- Runtime atlas cell size: 128x160 pixels; expected combined atlas size: 512x1280 pixels.
- Keep alpha transparency. Do not include checkerboard previews or matte backgrounds in the runtime export.

## Runtime paths
- `res://assets/art/units/kindlewake_lead_atlas.svg`
- `res://assets/art/units/kindlewake_lead_atlas.svg`

## Battle rendering
`Art.draw_kindlewake_lead()` selects a direction row from the battle unit's facing vector and cycles the four columns. `battle_scene.gd` uses the custom sheet for Torren / player_lead and selects the female atlas when the character's saved `creation.presentation` (or `presentation`) is `feminine`. Other characters continue through the existing sprite renderer.

## Asset import gate
The battle renderer intentionally falls back to the existing character atlas when either custom atlas is absent. The lead atlas is committed at the runtime path above. Run a Godot headless import/build plus an Android battle smoke test before shipping. Confirm idle, walking, all four directions, target selection, damage, and turn transitions.
