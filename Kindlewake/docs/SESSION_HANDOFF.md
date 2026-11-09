# Session handoff — Rune System v1

- Base checkpoint: v0.9.0, save schema 3; source repository ninjun42215-gif/KindleWake.
- Feature branch: feature/rune-system-v1; based on current main at 5715984.
- Scope: replace player-facing Sigils with Runes while preserving old save inventory/socket fields and script aliases; add rune types, grade ladder, fusion, specialist regional shops, rune status effects, combat popups and original atlas.
- New data: data/runes.json (17 runes) and additional storm/holy/shadow spells in data/skills.json.
- Fusion: 3 identical id+grade; success chances 70/55/40/25/12% for Uncommon through Mythical; consumes 3 and returns 1 higher-grade rune on success or 1 original-grade rune on failure.
- Regional vendors: Sallow Crossing, Thornmere, Foxglove, Elderbough, Cindermead, Redwater, Milefort. Each has explicit rune stock; no universal rune catalogue.
- Status effects: burn damage, chill speed penalty, shock turn skip, exposed defense reduction, regen, shadow life drain. Combat popup labels are added.
- Sprite atlas: assets/art/runes/rune_atlas.svg, 10 types × 6 grades; custom original artwork, no unverified external assets.
- Existing saves are compatible: party inventory remains sigil_inv; old sigils.json is fallback if new rune data is unavailable; GameData publishes both runes and legacy sigils keys.

## Validation required
1. Run GitHub Actions for this branch. Inspect static check, Godot import, strict tests, balance report and APK build.
2. Resolve all parse/static/test failures before opening a PR.
3. Verify fusion success/failure inventory math and save round-trip for optional grade field.
4. Playtest status durations, Shock turn skip, Chill speed, Exposed defense and Shadow healing. Check status turn progression after battle end.
5. Verify SVG atlas import in Godot Android export and check sprite crop readability on phone.
6. Only claim device testing after actual Android installation and playtest.

## Next work after v1 validation
- Add per-element cast/impact VFX beyond status popups.
- Add rune merchant dialogue/identity and lore, and rare rune drops from bosses/quests.
- Review grade balance and keep Mythical aspirational.
- Retire internal sigil_* identifiers only after a dedicated save migration and compatibility test.


## Itch.io asset review
- Reviewed Foozle's Pixel Magic Effects pack: 10 animated 32×32 spell effects with icons, explicitly CC0 1.0 and permitted for commercial use/modification. Candidate for the next battle VFX pass; not yet imported into the repository. Source: https://foozlecc.itch.io/pixel-magic-sprite-effects
- Keep asset packs source-only until the actual archive, frame layout and import scale are checked. Do not add packs that prohibit commercial use or redistribution.
