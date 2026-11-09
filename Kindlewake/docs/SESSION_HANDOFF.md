# Session handoff — Rune System v1 (CI validated)

- Project version: v0.9.1, save schema 3; based on v0.9.0 campaign checkpoint. source repository ninjun42215-gif/KindleWake.
- Feature branch: feature/rune-system-v1.
- Latest validated commit: c643c8fc20b1f96ebaa8aadb2f54d7330fa8b59e (project version 0.9.1).
- Scope: replace player-facing Sigils with Runes while preserving old save inventory/socket fields and script aliases; add rune types, grade ladder, fusion, specialist regional shops, rune status effects, combat popups and original atlas.
- New data: data/runes.json (17 runes) and additional storm/holy/shadow spells in data/skills.json.
- Fusion: 3 identical id+grade; success chances 70/55/40/25/12% for Uncommon through Mythical; consumes 3 and returns 1 higher-grade rune on success or 1 original-grade rune on failure.
- Regional vendors: Sallow Crossing, Thornmere, Foxglove, Elderbough, Cindermead, Redwater, Milefort. Each has explicit rune stock; no universal rune catalogue.
- Status effects: burn damage, chill speed penalty, shock turn skip, exposed defense reduction, regen, shadow life drain. Battle popups show applied effects.
- Sprite atlas: assets/art/runes/rune_atlas.svg, 10 types × 6 grades; original SVG artwork.
- Existing saves remain compatible: party inventory persists under legacy sigil_inv and existing socket keys; GameData exposes runes plus legacy sigils keys.
- Internal grade bonuses apply only above each rune's configured starting grade, preserving the original v0.9.0 stat/AP/support balance.

## CI validation — passed
- Workflow run #42646097605 — https://github.com/ninjun42215-gif/KindleWake/actions/runs/42646097605
- Godot 4.2.2 import: exit 0; no script errors or parse errors.
- Strict automated suite: 312 checks, 0 failures.
- Balance report: exit 0.
- Android APK: signed successfully, 41.1 MB, arm64-v8a + armeabi-v7a.
- Requested Android permissions: none.
- APK SHA-256: 2d538df60d8c8f762923b838a020228b3b046f09cd176701a880740bcd15489e
- Build artifact is attached to the workflow run above.
- Remaining non-failing warnings: ObjectDB instances leaked / Resources still in use at headless process exit. Investigate separately.
- No physical Android device test has been performed.

## Itch.io asset review
- Reviewed Foozle's Pixel Magic Effects pack: 10 animated 32×32 spell effects with icons; page states CC0 1.0 and permits commercial use and modification. Candidate for the next battle VFX pass; not yet imported into the repository. Source: https://foozlecc.itch.io/pixel-magic-sprite-effects
- Keep third-party archives source-only until the actual archive, frame layout and import scale are checked.

## Next actions
1. Open/review the draft PR from feature/rune-system-v1 into main; do not merge until review.
2. Install the APK on Android and verify portrait/landscape, touch layout, rune socket UI, Forge, shops, save/load and rune battle effects.
3. Add animated cast/impact VFX using a reviewed CC0 pack or original animations; current rune atlas and status popups are in place, but per-element animated VFX are not yet integrated.
4. Add explicit tests for Burn/Chill/Shock/Exposed/Regeneration turn behavior and grade-scaling effects.
5. Review regional rune merchant placement, stock and prices; verify access gates match the intended story progression.
6. Retire internal sigil_* identifiers only after a dedicated save migration and full compatibility test.


## v0.10.0 scope added
- Expanded rune database to 70+ entries including active spells, passive stat runes, unique and heirloom runes.
- Cross-grade fusion: any three copies of the same rune can be combined; average grade determines target tier and rune AP level adds up to +25 percentage points to the success chance.
- Heirloom runes are bound and cannot be fused; unique runes are rare and marked unique.
- Rune removal and replacement require a rune-service flag, granted by the magic-rune specialist or blacksmith service.
- Equipment enhancement data persists per character/slot; enhancement cap +15; each level scales equipped item bonuses and armor by 5%, weapon enhancement also adds 5% weapon power per level.
- Title screen has an Exit Game confirmation.
- NPC dialogue pages expanded in Sallow Crossing and Kaer Sethorn; Oswin and Master Smith Rurik are rune-service locations.
- Device playtest pending; re-run CI after this feature batch.
