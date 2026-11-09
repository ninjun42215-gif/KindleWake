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


## v0.10.0 — Rune Mastery & World Expansion
- Rune library: 77 definitions including 23 active magic, 43 passive, legacy support/stat types, 7 unique and 5 heirloom entries.
- Cross-grade fusion: any three copies of one rune; average grade determines next target tier; rune AP mastery adds up to +25 percentage points. Failed fusion returns one rune.
- Unique and heirloom runes are not sellable/fusible; boss battles reward Dragon, Worldtree, Starfall and Sundered Oath runes.
- Socket insertion, removal and transfer require a magic-rune specialist or blacksmith. Oswin and Master Smith Rurik are designated service NPCs.
- Equipment enhancement persists per character/slot to +15; each level scales equipment bonuses/armor and weapon power by 5%; cost increases quadratically. UI is exposed at Rurik's smithy.
- Four battle maps expanded to 16×14 and tailored to river crossing, deep forest marsh, highland snowfield and ashen ruins; new terrain costs/cover/LOS rules and visual accents.
- Title screen Exit Game confirmation and expanded NPC dialogue for Sallow Crossing and Kaer Sethorn.
- Project version 0.10.0; save schema remains 3. Legacy `sigil_inv` and socket fields intentionally retained.
- CI for this batch is pending. No Android device test has been performed.


## Visual art pass — original environment and UI assets
- Added `assets/art/props/field_props.svg`, a 4×4 atlas of 16 original props: arch, broken column, rune stone, torch, reeds, crystals, grave marker, banner, mushrooms, stump, barrel, crate, campfire, frost pine, statue and flowers.
- Added `assets/art/ui/title_illustration.svg` as a new painted-style landscape backdrop and `ornament_divider.svg` as a reusable fantasy divider.
- `Art.draw_prop()` now loads atlas cells. Tactical battle tiles use terrain-matched props (forest trees, marsh reeds, snow pines, ash campfires, ruin columns and cliff crystals); town tiles receive stallside crates, barrels, torches, banners, columns and sparse flowers.
- These are original project-authored vector assets; no unverified third-party pack was imported in this pass. Existing unit sprite sheets remain in place and should receive a separate animation/character-art upgrade pass.
- CI validation for this asset pass is still running; prior v0.10.0 CI runs had two balance/stat test failures, so do not call the latest branch build verified until a current run completes.


## 2026-11-10 continuation — Godot script registration fixes
- CI run `42650643361` confirmed that `CharacterSheetScript` was not a registered global class inside `character_sheet.gd`; the file declares `class_name CharacterSheet`. `with_item()` now uses the registered `CharacterSheet` class for its copy factory.
- `PartyStateScript` was likewise unresolved inside `party_state.gd`; `from_dict()` now instantiates the current script through `load("res://scripts/core/party_state.gd").new()` with an explicit `PartyState` type annotation to avoid inference failure.
- Commits: `cd30afb04731446e8a5c93fdb2af1e045b70eff9` and `35a8e1c9f546f3f1eddbafd4ea84c47a98d83528` on `feature/rune-system-v1`.
- Latest build run for `35a8e1c9f546f3f1eddbafd4ea84c47a98d83528`: `42666872518` (in progress at handoff). Do not claim the APK is current or validated until this run completes successfully.
- Next visual task: integrate the existing hero battle sprite feature pack if compatible with the current project; upgrade enemies beyond the existing Soldier/Orc idle/walk/attack/hurt/death strips, add distinct silhouettes and spell/impact effects. Preserve existing frame contracts in `scripts/ui/art.gd`; verify third-party licences before redistribution.
- `main` remains untouched; PR #4 remains draft and unmerged.


## Build validation update — 2026-11-10
- Successful Android build run: `42666872518` — https://github.com/ninjun42215-gif/KindleWake/actions/runs/42666872518
- Validated commit: `35a8e1c9f546f3f1eddbafd4ea84c47a98d83528` (the two GDScript fixes are included).
- Godot import passed; strict automated tests: **333 checks, 0 failures**; balance report passed; signed Android APK exported and verified.
- APK size: 41.2 MB. Actions artifact: `Kindlewake-APK` (artifact ID `13697765975`, expires 2027-02-07). Artifact ZIP SHA-256: `6547d22563f0ae1082968ece261891bd188a92246d01f797fd8eb628f9eea088`.
- This validates the project code at `35a8e1c`; the subsequent commits only append handoff documentation. No physical Android device test has been performed.


## 2026-11-10 — Battle sprite identity pass
- Commit `21c1702bd012b8ca0bd0bc51e5a0b6b9dae46c2c` adds class-aware palette variation to battle sprites: knight, swordsman, archer, cleric and roadreaver player units now read with distinct color treatments while retaining the existing Soldier animation strips.
- Enemy sprite treatment now keys off character ID/display name for boss/chieftain, bow/scout, shaman/mage, wraith/spectre, skeleton/bone and brute/ogre/troll archetypes. Each receives a matching palette and small screen-space identity marks; default enemies retain a restrained green tint.
- Hurt tint blends over each palette, and all existing idle/walk/attack/hurt/death frame contracts remain unchanged. This is an interim renderer-level art pass, not a replacement for bespoke frame-by-frame hero/monster sprite sheets.
- CI run `42667953445` for this commit was queued at handoff. Do not mark this pass build-validated or publish a new APK until that exact commit's workflow succeeds.
- Next: add original dedicated enemy and hero sprite sheets plus cast/impact animations; verify on device after CI.


## 2026-11-10 — Responsive UI/HUD implementation
- feature/rune-system-v1 commits: battle HUD 95d5ef7, overworld HUD 5383461, party layout ea6868c.
- Battle HUD: reduced viewport-relative unit card/log/preview widths on compact landscape screens; scaled action button widths/heights and Confirm/Cancel text while preserving large touch targets and existing anchors/safe-area handling.
- Overworld HUD: COMPANY and SAVE now have independent responsive sizing; SAVE is a persistent member reference so its dimensions/font can be updated after viewport changes.
- Party screen: compact mode now depends on orientation (stack only when portrait/narrow aspect); compact landscape retains three visible columns with proportional minimum widths. Header title, gold chip and Close button scale down together.
- No combat, economy, rune, equipment, save schema or progression rules were changed. This is a layout-focused pass.
- Validation: prior sprite identity commit 21c1702bd012b8ca0bd0bc51e5a0b6b9dae46c2c passed Android workflow 42667953445. The new UI commits require their own workflow run; do not claim them validated or distribute a new APK until the exact latest branch commit passes import, strict tests, balance report and APK verification.
- Physical Android touch/safe-area testing remains outstanding. Check 16:9 and narrow landscape, portrait party management, gesture/map input behind HUD panels, save confirmation, and scroll restoration.


## 2026-11-10 — UI/HUD responsive pass and combat feedback
- Party management now switches from the desktop three-column roster/sheet/tabs layout to a vertical, scrollable mobile layout below 1050px; panel minimum widths no longer force horizontal clipping. Attribute tiles reduce to three columns and the header/tabs use compact sizing.
- Battle HUD now reflows for narrow and portrait viewports: turn timeline and battle log are hidden when space is constrained, unit info/menu/action/preview controls scale down and reposition, and result/pre-battle panels are bounded to the viewport. Safe-area insets remain applied.
- Title menu panel and heading now fit narrow phone widths without forcing a 440px panel off-screen.
- Added lightweight vector combat VFX for melee hit slashes, elemental/status impact bursts and healing rings/particles. Effects are time-limited and use draw primitives rather than extra textures to keep mobile rendering inexpensive.
- Commits: party responsive layout `c50bea8`, battle HUD reflow `ab0e668`, title fit `d5b07d6`, compact party header/tabs `079510f`, combat VFX `e55242d`.
- Latest branch head: `e55242d78643bd3dde56e3bafdc623a4dfa6479e`. Android workflow run `42671737916` was queued at handoff; do not claim this combined UI/VFX batch passed until this exact head is validated.
- Remaining art work: bespoke per-class hero sprite sheets and per-species enemy sprite sheets are still not present; current battle sprites use the existing Soldier/Orc animation strips with tint/identity accents. Device visual testing remains required.
- `main` untouched; PR #4 remains open and draft.
