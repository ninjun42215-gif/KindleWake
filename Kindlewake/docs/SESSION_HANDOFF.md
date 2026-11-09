# Repository delivery note — v0.7.11 (2026-11-09)

Gameplay remains at v0.7.9. The one-time four-part import is complete. GitHub Actions reconstructed `assets/optional_sprite_packs/zxf.zip`, extracted 129 project files, passed the static checker (27 files/classes, 0 errors, 0 warnings), and passed Android offline preflight. The extracted `Kindlewake/` tree on `main` is the canonical source. Temporary upload shards and the one-time import workflow have been removed. Continue by editing and committing ordinary files directly; do not ask for or rebuild a project ZIP for routine work.

# Session Handoff — KINDLEWAKE: THE SUNDERED VOW (state: v0.7.9)

## v0.7.9 (weapon-preference starting loadouts)
Continued from the authoritative v0.7.8 checkpoint. The next documented task was balanced starting equipment for every protagonist weapon preference.

Changes in this checkpoint:
- `scripts/core/character_creation.gd`: added a single explicit preference-to-common-item mapping. `build_definition()` now equips the selected weapon on the protagonist and records `starting_weapon_item` in creator metadata. It preserves all other equipment and clears the off-hand only if a future mapped starter is two-handed.
- `data/weapons.json` and `data/items.json`: added common-tier spear, crossbow, staff and dagger definitions. Existing sword, axe, bow and mace definitions are reused. All starters use a comparable baseline power budget; ranged/reach, accuracy and critical traits differentiate them.
- `tests/run_tests.gd`: verifies the archer receives a bow and iterates every compatible discipline/preference pair to ensure a real matching item and weapon definition are equipped.
- `docs/GDD.md`, `README.md`, project version and save `GAME_VERSION` updated to v0.7.9. Save schema remains v2; no migration is required.

Validation on 2026-11-09:
- `python3 -I tools/gd_static_check.py` → 0 errors / 0 warnings.
- `python3 tools/build_apk.py --check` → Android offline preflight passed.
- `data/weapons.json` and `data/items.json` parse as valid JSON.
- Godot is not installed here. The GDScript test suite, balance report, import, scene rendering and actual battle balance have NOT been run. The new loadouts are structurally mapped and statically checked, not runtime-balanced.

Still open:
- Run Godot import, `tests/run_tests.gd` and `tests/balance_report.gd` as soon as Godot is available. Pay particular attention to staff magic damage/range and spear reach in combat.
- Origin tags are stored but no story event consumes them yet.
- Geometric preview is not production portrait art; the 26 nested optional sprite archives still require content/license review.
- Save version 2 persists the creator profile in battle saves, but world position, interior state and the full campaign are not independently persisted.

Next: obtain a Godot 4.2+ runtime, run import and the full test suite, fix any failures, then inspect the creator and each starter weapon in a landscape phone build. Do not add another feature before runtime validation.

---

## v0.7.7 (interactive protagonist creator + campaign/save integration)
Implemented from the verified v0.7.6 checkpoint:
- Added `CharacterCreator.tscn` and `scripts/ui/character_creator.gd`. The overworld's top-right **New Chronicle** button opens it as an overlay; Back closes it without changing the current party.
- The touch-first form supports name, presentation, face, hair, skin, build, origin, starting discipline, compatible weapon preference and temperament. It validates with `CharacterCreation.validate`; invalid profiles disable confirmation.
- Added `scripts/ui/character_preview.gd` (`CharacterPreview`), an original geometric bust preview reflecting skin, hair, face preset, build and origin palette. The summary displays the selected presentation/build, origin, discipline, weapon preference and origin/temperament stat bonuses. This is not production portrait art.
- Confirm calls `GameState.new_game(profile)`. `CharacterCreation.build_definition` creates a fresh Torren definition; `PartyState.new_game` accepts the override only for stable id `torren`. The four-member starting party and all companion definitions remain unchanged.
- `GameState.creation_profile` holds the selected profile. Battle manual saves and autosaves include it; load restores it. `SaveSystem.SAVE_VERSION` is now 2 with an explicit v1→v2 migration that adds an empty `creation_profile` and preserves existing fields.
- Added tests for custom protagonist initialization, unchanged four-member party/companions, profile save round-trip and v1 migration preservation.
- Validation: `python3 -I tools/gd_static_check.py` → 0 errors / 0 warnings; `python3 tools/build_apk.py --check` → offline preflight passed; all project JSON parsed and creator class/weapon references were checked; rebuilt ZIP integrity verified.
- **Not run in Godot:** no Godot binary is installed here. Scene parsing/import, headless test suite, layout, touch behavior and gameplay are unverified.

Known limitations / next tasks:
- Weapon preference is stored as creation metadata but does not yet swap the protagonist's equipped starting weapon. Avoid adding unowned weapon types without defining a fair starting loadout.
- Origin tags are stored in the protagonist definition/profile but no story branches consume them yet.
- Preview is geometric UI art, not a portrait/sprite. Review optional sprite-pack licenses before importing production art.
- Existing saves are made during battles. World position, local interior, and complete campaign state are not independently saved. The current save migration preserves v1 battle/party data.
- Next: run Godot import and `tests/run_tests.gd`; inspect the creator on a phone at landscape resolution; correct any engine/API/layout issues; then add origin-tag story hooks and deliberate weapon-preference loadout rules.

## v0.7.6 (protagonist creation foundation)
User asked to continue Kindlewake from v0.7.5 and keep every in-progress checkpoint downloadable. Implemented the first small creator subtask:
- Added `data/character_creation.json`: defaults, name limits, presentation/face/hair/skin/build presets, three origins, eight starting disciplines, compatible weapon preference lists and four temperaments.
- Added `scripts/core/character_creation.gd` (`CharacterCreation`): profile validation and a pure `build_definition()` function that copies the existing Torren definition, applies origin/temperament stat bonuses, changes the selected tier-one class and stores visual/origin/discipline choices in a `creation` metadata block. The stable character id remains `torren`.
- `GameData` loads `character_creation.json`; tests cover default validity, definition creation, class choice, stat bonuses, invalid name/weapon rejection and source-data immutability.
- Static checker: `python3 -I tools/gd_static_check.py` → 0 errors, 0 warnings.
- **Not implemented yet:** visual creator scene, preview/confirm flow, `GameState`/`PartyState` hookup, save payload integration or migration, origin-tag story hooks, sprite/portrait layers. Current game boot still uses the fixed Torren setup.
- **Not run in Godot:** no Godot binary is installed in this environment. Runtime and headless test suite remain unverified.

Next: implement creator scene and preview/confirm flow; then connect the confirmed profile to `GameState.new_game`, persist it in save payloads with a versioned migration, and add tests before producing original portraits/body layers. Keep each subtask checkpointed with the fixed three download names.



## v0.7.5 (character creation + original cast design)
User requested a Final Fantasy VII / Suikoden II-inspired direction, character creation, and unique protagonist/antagonist designs.
- Added a GDD section defining creator fields, gameplay consequences, scene/data/save migration implementation sequence, and validation tests.
- Added original visual identity briefs for the player protagonist, High Chancellor Maelor Veyne, Ashen Marshal Ser Caldris Orrowen, Mother of Cinders Ilyra Voss, and rival heir Lady Ysabet Brennhallow.
- Added recruitment differentiation and inspiration/copyright boundaries: broad genre inspirations only; Kindlewake keeps original world, characters, CTB combat, Sigils, and narrative.
- This is a design/documentation milestone only. Character creator scene, JSON schema, save migration, and visual assets are not implemented yet. Godot not run.
Superseded by v0.7.6: the creator data/rules foundation is now in place. Continue with the creator scene, campaign initialization, save integration/migration and tests.
## v0.7.4 (asset integration checkpoint)
User supplied `sprite.zip` alongside the current project and asked to integrate the files and keep AI progress immediately downloadable for the next session.
- Integrated all 26 nested ZIP source packs, preserving each archive intact at `assets/optional_sprite_packs/`.
- No sprites were extracted into runtime art, assigned to scenes, or referenced by game code yet. The source packs contain varied/opaque filenames and may have their own licensing/attribution conditions; use them only after review.
- Existing code and game architecture remain unchanged. This checkpoint is a packaging/documentation integration, not a playable art implementation.
- Updated `README.md`, `docs/GDD.md`, and `docs/CONTINUATION_PROMPT.md`. External deliverables use fixed names and are also copied alongside this project ZIP.
- Validation performed: archive inventory and integrity check of the output ZIP; no Godot execution or gameplay verification.

Next asset task: inspect nested packs and their metadata/license files; make a catalog/contact sheet if feasible; choose art matching Kindlewake; copy only approved assets into the relevant `assets/art/` folders and add credits. Maintain a downloadable checkpoint after each finished subtask.



## Where we are
- Milestone 1 ("playable tactical combat prototype") has been rebuilt from the single-file prototype into a modular, data-driven project. **The code has never been run in Godot** (no Godot binary was available while writing it). Treat everything as "written carefully, untested" until the test-suite and a manual playthrough pass.
- The Game Design Document (all 17 requested sections) is complete: `docs/GDD.md`.
- Previous prototype (single `scripts/main.gd`, Manhattan movement, adjacent melee only) was replaced; nothing from it is still needed.

## v0.7.3 (this session): scrolling the equipment lists
User: "browsing the equipments are hard to scroll". Likely cause (from the Godot behaviour, not observed): the cards were full-width Buttons inside ScrollContainers, and a Button takes the touch so a drag that starts on it does not scroll. Fix: new `scripts/ui/tap_card.gd` (`TapCard`, a PanelContainer that handles mouse/emulated-touch events: tap vs drag with a 12 px deadzone, manual scrolling of the nearest ScrollContainer, wheel support); `PartyScreen._card` builds TapCards, `_seal` ignores the mouse on all content, `_relax_mouse` (called at the end of `_rebuild`) sets every non-interactive Control to IGNORE so drags starting on tiles or gaps scroll natively. Tests: tap, drag and disabled behaviour with synthetic events. Linter: `gd_static_check.py` now treats PanelContainer subclasses like Control ones and knows `accept_event`. Static check 0/0. **Not run in Godot.** Check on the phone: scroll by dragging from the middle of a card, tap still selects, no double scrolling, no jump when a drag starts (the first 12 px are not scrolled), and that Unequip / Confirm buttons are not a problem. If scrolling is still stiff, add inertia to TapCard or turn Unequip/Cancel/Confirm into TapCards too.

## v0.7.2 (this session): shop compare + confirm
User asked for (1) comparing equipment before purchasing and (2) a confirmation button for every buy and sell. Done in `party_screen.gd`: `shop_pick` replaces `sell_pending`; tapping a shop card opens it (`_on_shop_pick`) with `_fill_shop_detail`: `_add_compare` (selected hero, every slot the item fits, replaced item, equip problem, other heroes via `_best_slot`) and Cancel / Confirm (`_on_confirm_buy`, `_on_confirm_sell_item`, `_on_confirm_sell_sigil`); unaffordable items can still be opened, the Confirm button is then disabled. Test block added after the heirloom check in `_test_shop_and_screen`. Static check 0/0. **Not run in Godot.** Ideas not done: compare sigils by resulting stats, compare against both accessory slots for other heroes, item icons.

## v0.7.1: Party screen redesign
User sent a phone screenshot of the Party screen ("the inventory view is too cramped, fix this, make everything user friendly and improve the user experience") plus the project files and reference images. **Root cause found by reading `party_screen.gd`:** the Gold label in `_build_header` had autowrap on but no room, so it wrapped one letter per line and made the top bar about half the screen high; the three panels were pushed into the lower half. Fix and redesign (GDD 4.7, v0.7.1 block): new building blocks `_text` (never wraps), `_skin`, `_tab_button`, `_card` + `_seal` (a styled Button under free-form content, with mouse filters set to ignore), `_tile`, `_add_section`, `_delta_row`; header, roster cards, sheet tiles with `<` `>` stepping, slot cards, Bag overview, socket cards, price cards, message banner with per-tab hints, sell needs two taps (`sell_pending`, `_on_sell_item_ask`, `_on_sell_sigil_ask`), Back button via `_unhandled_input`, scroll positions kept for roster / sheet / right panel. `ItemInfo.delta_parts` added. Public API and every message string the tests check are unchanged (`_on_sell_item` and `_on_sell_sigil` still sell at once). Static check 0 errors 0 warnings. **Not run in Godot**, so the first things to check on the phone: card heights with wrapped labels, the Button-under-content tap routing (`_seal`), HFlowContainer wrapping of the green/red deltas, the `await` in `_restore_scroll`, and fit at 1280x720 and 20:9. Ask the user for a new screenshot of all three tabs.
Next (unchanged): save/load of location and world state, formation screen, inn healing and recruiting, skills for the other tier-1 classes, status effects, fatigue, counters, weather. Ideas not done: item icons (no item art yet), sort/filter for a long bag, compare-with-other-hero, sigil tier colours once the 6 rarity tiers and sigil tiers exist.

## v0.7.0: towns and interiors
User: "create a new map when entering a town and a new map entering a house" (plus 7 more reference images: RPG-Maker style castle interiors, village layouts, barracks/crypt plans). Done (GDD 11.2): `data/locations.json` (7 maps, generated once with a throwaway script, now hand-editable), `scripts/world/local_map.gd` (`LocalMap`: parse, walkable, doors, exit, spots, BFS, `validate`), `scripts/ui/location_scene.gd` + `Location.tscn`, `GameData.locations`, `GameState.pending_location`, overworld: place panel has `Enter <town>` (`_enter_town`, sets `world_pos` just south of the place), places in world.json got `town` ids, the overworld Party button and the place-panel party option were removed (party screen now opens from the shop counter and the war table). `_test_locations()` added. The map data was re-validated in Python (all doors, spawns, spots, exits reachable). Static check 0/0, preflight passes. **Not run in Godot.** Likely first-run issues: camera clamp and zoom on small interiors, door re-trigger right after a spawn (guarded by `last_cell`), tile drawing cost (only visible tiles are drawn), scene change back to the overworld. The reference images were used for layout ideas only (hall with carpet and pillars, inn with counter, barracks with beds).
Next: save/load of location and world state (SaveSystem), per-class sprites, formation screen, inn healing and recruiting, quests from NPCs.

## v0.6.1: art pass
User uploaded 8 voxel building zips, `Package.zip` (MountainRocks), the Quaternius Stylized Nature MegaKit, the Tiny RPG Soldier/Orc pack, Modern Interiors Free, plus 20 reference images ("use this", "use this reference as well"). Done: `tools/render_sprites.py` (numpy/Pillow OBJ renderer; run it on the unzipped packs to regenerate `assets/art/world/*.png`), `scripts/ui/art.gd` (`Art`: cached loading, null when missing so every caller falls back to primitives), battle sprites (`_draw_unit_sprite`, `anim_override`, `_play_anim`, redraw about every 70 ms), overworld props (`_collect_props`, y-sorted with places and the walker, `_draw_place` with sprites, `_draw_place_fallback`), `assets/art/CREDITS.md`, GDD 14.2. Checker: knows `static var`, `ResourceLoader`. Static check 0/0, preflight passes. **Not run in Godot** (also not imported: the PNGs get their `.import` files on the first editor/CI import). Not used: Modern Interiors (modern, non-commercial, no edits), MountainRocks (rendered as slabs), FBX/glTF nature models beyond the rendered ones, the reference images (style only). **Licences unverified** for the building packs and the Tiny RPG sheet: ask the owner for the source pages.
Next: per-class unit sprites, formation screen, cliff/water edges, then save/load of world state.

## v0.6.0: free-roam overworld
User asked "continue, make this open world". Interpreted as a free-roam overworld (GDD 11.1); a seamless open world would not fit a grid-tactics game on a phone. New: `data/world.json`, `scripts/world/world_map.gd` (`WorldMap`, pure logic), `scripts/ui/world_scene.gd` + `World.tscn` (now `run/main_scene`; `Main.tscn` is the battle scene), `GameData.world`, `GameState.pending_battle/from_world/world_pos/world_flags` + `start_battle_from_world/take_pending_battle`, battle scene: reads the pending battle, "Back to the World" buttons (result screen, pre-battle when from the world), sets `camp_cleared` on a story victory. `_test_world()` added. The map generator was re-implemented in Python to check the data: 83% walkable, all three roads connected, camp reachable. Static check 0/0, preflight passes. **Not run in Godot.** Likely first-run issues: Camera2D smoothing vs tap target, `Image.create`/`TextureRect` minimap sizing, tile drawing cost on low-end phones (only visible tiles are drawn), scene change from the battle scene. Known gaps: no persistence of world position/flags in saves, Party (with shop) opens anywhere, one region only.
Next: save/load of world state (SaveSystem), HQ screen at Kaer Sethorn, more places and enemy groups per region, then status effects, fatigue, counters, forest concealment, weather.

## v0.5.6: class-granted skills
User said "continue" again with no new output. `classes.json` `class_skills` (id -> level) for the warrior and ranged lines; `CharacterSheet.all_skills(items, sdefs, classes)` (new optional arg; `to_battle_def` and `PartyScreen` pass the class table); hero skills removed from `characters.json`; `_test_weapon_skills()` extended (class source, no-class-table case, every class skill exists). Static check 0/0, preflight passes. **Not run in Godot.** Next: skills for the other tier-1 classes (cavalier, apprentice mage, priest, thief, scout, engineer, roadreaver), then status effects, fatigue, counters, forest concealment, weather; run the balance report.

## v0.5.5: weapon skills
User said "continue" with no new output, so work went on with Milestone 2 (skills v1). New `strike` skill type (GDD 3.13): `power_strike`, `aimed_shot` in `data/skills.json`, innate skills for torren, bram, sela in `characters.json`. Code: `CombatCalc.is_damage_skill`, `skill_preview/skill_resolve(..., weapon)`, controller `try_skill/_cast_damage`, `BattleAI._best_bolt`, `ItemInfo.skill_line`, HUD skill cycling (`_first_usable_skill`). Test `_test_weapon_skills()` added. Static check 0/0, APK preflight passes, JSON valid. **Not run in Godot.** Balance: heroes now have a 3 MP attack; run `tests/balance_report.gd` and re-check Win% (60-90 target). Next: more skills per tier-1 class (class-granted instead of per character), status effects, fatigue, counters, forest concealment, weather.

## v0.5.4: HUD / UI rework for phones
User asked: "continue and fix the UI and HUD" (no screenshot or error text). Found by reading `battle_scene.gd`: fonts 16-18 px and buttons 56-72 px were too small for a phone; result text could push the buttons off screen; six action buttons stacked about 470 px tall; no safe-area handling; HUD panels swallowed map drags.
Changes (all in `scripts/ui/battle_scene.gd`, layout in GDD 14.1): `_build_ui` rewritten (`_hud_panel`, `_apply_safe_area` for mobile only, `hud_root`); new Menu popup (`_on_menu_pressed/_save/_load`); `_info_text` split into the unit card and `_preview_text` (shown in `preview_panel` above Confirm/Cancel); Confirm/Cancel moved bottom-centre; result and pre-battle texts in ScrollContainers with a 2x2 / 1x2 button grid; timeline cells now removed before `queue_free`; bigger in-world name, HP bar and damage popup. `tools/gd_static_check.py` knows `DisplayServer`. Static check 0 errors 0 warnings; `build_apk.py --check` passes. Version 0.5.4, version code 504.
**Not run in Godot.** Check on a real phone: overlaps at 16:9 and 20:9 (top row has info card, 8 timeline cells and the menu; bottom row has log, preview and actions), safe-area insets, scrolling of the result text by touch drag. PartyScreen was not changed (already 20 px text, 60 px buttons).

## v0.5.3: results on the GitHub run page
`tools/build_apk.py` (`write_ci_summary`, called from `write_summary`) appends a "Kindlewake build report" to `$GITHUB_STEP_SUMMARY` (see GDD 15.1): the user can now just open the run (Summary) and screenshot/save it; no artifact download is needed, and no workflow edit is needed (the existing workflow already runs this script). Tested offline with fake logs (pass, fail, no env var, unwritable target). **No game code changed; no new feature work was stacked on the unrun code on purpose: the next step is to read the first real test output.** Version 0.5.3, version code 503.

## v0.5.2: APK built for the first time + full class tree as data

**APK result (real):** the user built the APK on a phone with GitHub Actions (private repo `ninjun42215-gif/KindleWake`, run #3 "Build Android APK", success in 1 m 33 s, APK published as a GitHub Release asset). They then uploaded `Kindlewake.apk`; static inspection showed a valid 40.7 MB archive, signed v1+v2+v3 with the `CN=Kindlewake Sideload` certificate, package `com.kindlewake.game`, native libs for arm64-v8a and armeabi-v7a, **no INTERNET permission**, all 11 `data/*.json` files and the battle / party / save scripts packed, tests not packed. **Still unknown:** whether the game starts on a phone, and the test results (`build-logs` artifact: `BUILD_SUMMARY.txt`, `run_tests.txt`) — the user has not sent either yet. Ask again.
- **Phone-only build route:** after the one-time four-shard import has created the extracted `Kindlewake/` folder, the repository is the source of truth. Run **Actions → Build Android APK → Run workflow** to build; do not upload a master ZIP. The build workflow imports the Godot project, runs strict tests and the balance report, then publishes the APK and test logs.
- **Classes as data (Milestone 2):** `data/classes.json` now holds the whole GDD 4.2 tree, 28 classes in 4 tiers, with growth tables, move/jump and `promotes_to`; new optional fields `locked` (Berserker, Paladin: extra requirement not checkable yet, never offered), `story_only` (Commander) and `requires` (text). `CharacterSheet.promotion_options` skips locked and missing classes; the level gate is unchanged (10 × tier). Details and display names: GDD 4.2 "Implemented in v0.5.2".
- **Tests:** new `_test_class_tree()` (fields, growth ranges, every promotion goes up one tier inside its branch, every class reachable, locked/story-only rules, thief/scout jump 2) and rewritten promotion checks (duelist offered, berserker locked, ghost class refused, knight needs 20, heavy knight offered). Mirrored in Python against the data: 0 problems. **Not run in Godot.**
- **Battle glyphs:** `HAND_DRAWN_CLASSES` keep their drawings; any other class draws one placeholder glyph per branch (`_draw_branch_glyph`).
- **Linter limitation found:** `tools/gd_static_check.py` reports `identifier '_' is not declared` for the `_:` wildcard of a `match` (valid GDScript). Use `if/elif/else` or explicit patterns until the linter learns it.
- Version 0.5.2, `version/code` 502 (a newer APK installs over the old one; same signing key).
- Files changed: `data/classes.json`, `scripts/core/character_sheet.gd`, `scripts/ui/battle_scene.gd`, `tests/run_tests.gd`, `tools/phone_build_apk.yml` (new), `export_presets.cfg`, `project.godot`, `README.md`, `docs/GDD.md`, this file, `docs/CONTINUATION_PROMPT.md`.
- Not done yet (next): skills v1 (3-5 per tier-1 class, now including the new classes), status effects (also unlocks Berserker's Fear rule), fatigue, counter-attacks, forest concealment, weather, class/weapon restrictions, enemy tables and maps beyond the Prologue.

## v0.5.1: Android installer (APK) pipeline
**User request:** "make sure there will be an installer of this game for apk". **Honest status:** the sandbox had no Godot and no internet, so **no APK was built or executed**. What exists is a complete build pipeline, checked offline only (preflight mutation tests; the whole download/extract/import/test/export/verify flow was simulated with fake archives and a fake Godot on Linux; Windows-specific branches such as `.bat` quoting were NOT exercised). Game code and save format are unchanged (`GAME_VERSION` stays 0.5.0; `gd_static_check.py` still 0 errors, 0 warnings).

| File | What |
|---|---|
| `export_presets.cfg` | Preset `Android`: export templates (no Gradle), arm64-v8a + armeabi-v7a, `package/unique_name=com.kindlewake.game`, `version/name 0.5.1`, `version/code 501`, signed, `permissions/internet=false`, `include_filter="*.json"` (data must be packed), `exclude_filter` drops tests/tools/docs/.github/markdown/keys, immersive mode, launcher icons. |
| `project.godot` | Added `config/icon`, `config/version`, `rendering/textures/vram_compression/import_etc2_astc=true` (Godot refuses Android exports without it), orientation 0 -> 4 (landscape on either side). |
| `assets/icons/*` | `icon.png` 512, `icon_main_192.png`, `icon_fg_432.png`, `icon_bg_432.png` (placeholder art: sword with an ember flame). Generator: `tools/make_icon.py` (needs Pillow). |
| `tools/keys/kindlewake-sideload.keystore` | Committed sideload signing key (alias `kindlewake`, password `kindlewake-sideload`, PKCS12, 100 years). Public on purpose, same key for every build so updates install over old ones. NOT for Google Play. Overrides: env `KINDLEWAKE_KEYSTORE`, `KINDLEWAKE_KEY_ALIAS`, `KINDLEWAKE_KEY_PASS`. |
| `tools/build_apk.py` | Cross-platform (Windows/Linux, stdlib only). Steps: preflight (offline) -> download and cache JDK 17 (Temurin), Android cmdline-tools rev 11076708 + platform-tools, build-tools 34.0.0, android-34, Godot 4.2.2 + export templates (only `android_*` files extracted) in `~/.kindlewake_build` (or `KINDLEWAKE_CACHE`; Windows paths with spaces fall back to `C:\kw_build`) -> Godot "self-contained mode" (`_sc_` file, settings in `editor_data/`) with a generated `editor_settings-4.tres` (+ versioned name) -> `--headless --import` (retried once) -> `tests/run_tests.gd` (logged, non-blocking unless `--strict`; `--with-balance` adds the balance report) -> `--export-release Android dist/Kindlewake.apk` (signing via `GODOT_ANDROID_KEYSTORE_*` env vars) -> verify (zip integrity, arm64 library, `aapt2 dump permissions`: **fails if INTERNET is present**, `apksigner verify`). Flags: `--check`, `--skip-tests`, `--strict`, `--with-balance`, `--debug`, `--install` (adb), `--godot VER`, `--cache DIR`, `--allow-internet`. Logs in `dist/logs/`, short report `dist/logs/BUILD_SUMMARY.txt`. |
| `Build_APK.bat`, `tools/build_apk.sh` | Double-click / shell wrappers. |
| `.github/workflows/build-apk.yml` | GitHub Actions: manual run or `v*` tag; caches `~/.kindlewake_build`; uploads `Kindlewake-APK` and `test-logs`; tag builds attach the APK to the release. |
| `docs/BUILD_APK.md` | Plain-English guide: three ways to build, install on the phone, signing notes, troubleshooting table. |
| `docs/GDD.md` | New section 15.1, roadmap row 10, folder tree, revision log 0.5.1. |

**Preflight rules (`python tools/build_apk.py --check`):** preset exists and is Android, no Gradle, valid package name, arm64 on, version code/name, `*.json` in include_filter, no `permissions/internet`, icon files exist with exact sizes, `import_etc2_astc=true`, `config/icon` exists, landscape orientation, signing key exists, every `data/**/*.json` parses, and no network class (`HTTPRequest`, `WebSocketPeer`, `StreamPeerTCP`, `ENet*`, `OS.shell_open`...) appears in `scripts/`. Mutation-tested (11 injected faults, all caught).

**Likely first-run problems (all unverified):** (1) download URLs (Adoptium API, `dl.google.com` cmdline-tools 11076708, GitHub release assets `4.2.2-stable`); (2) Godot's Android export check may want something not installed (read `dist/logs/export.txt`); (3) editor settings file name/location in self-contained mode; (4) `sdkmanager` licence prompts on Windows (the script feeds `y` to stdin and quotes `build-tools;34.0.0` because cmd.exe splits at `;`); (5) a data file not packed (the game would crash at start, check `adb logcat -s godot`); (6) touch layout on a real phone is still unchecked (see v0.5.0 gaps).

**Decisions:** Godot pinned to 4.2.2 (the declared target); a newer Godot is available through `--godot` for 16 KB page-size phones (build-tools 35.0.1 / android-35 are used from 4.4 on; best effort). Release build, not debug (a release export never adds INTERNET). Template-based export, no Gradle, so no NDK/CMake download. APK name fixed `Kindlewake.apk`; no `.aab` yet (Milestone 10). iOS is untouched.

## v0.5.0: party screen, shop, pre-battle panel, static checker, balance report
**Verification status (honest):** this sandbox again had no Godot and no package installs, so NOTHING was executed in Godot. What was done instead:
- New `tools/gd_static_check.py` (pure Python, run `python3 -I tools/gd_static_check.py` from the project folder). It checks indentation, brackets, duplicate members, local variables that redeclare an enclosing scope (a Godot parse error), calls to missing methods / wrong argument counts / missing members and signals on every project class (following typed variables, typed members and return types), undeclared identifiers, probable `:=`-on-Variant mistakes, `connect()` handlers, `load()`/autoload paths and every JSON cross-reference. It was mutation-tested (5 injected bugs, all caught) and reports **0 errors, 0 warnings** on the whole project. It is a linter, not a substitute for Godot: it cannot see engine-API mistakes, runtime type errors or logic bugs.
- Typed-array return values and typed-array assignments were hand-audited (all build typed arrays).
- **Important first-run detail:** `class_name` scripts are only registered after Godot has scanned the project, so a fresh unzip must be imported ONCE before the tests: `godot --headless --path . --import` (or open the project in the editor once). Without it the tests fail with "Could not find type X" / "Identifier not declared" errors for every class_name. Then run `godot --headless --path . --script res://tests/run_tests.gd`. **Any `SCRIPT ERROR` / `Parse Error` line in the output matters even if the checks still say ok** (a runtime error inside a function prints an error and returns, it does not fail a check).
- Autoload scripts (`GameData`, `SaveSystem`, `GameState`) are still instantiated by hand in tests; `GameState.skirmish_def` logic moved to the new static `EncounterBuilder` so no test needs `GameState` any more.

**New / changed files**
| File | What |
|---|---|
| `scripts/ui/party_screen.gd` (`PartyScreen`, a Control built in code) | Full-screen party UI: roster column, character sheet (HP/MP, ATK/DEF/RES/ACC/EVA/CRIT/SPD/MOV/range, 10 stats with gear bonus, skills with power %, EXP bar, promotion buttons) and a right panel with 3 tabs: **Equipment** (6 slots; tap a slot to list matching bag items with a live stat delta such as "ATK +3, DEF +1"; blocked items show the reason; Unequip), **Sigils** (weapon/armor sockets as buttons "Embers Lv2 / 35/70 AP", linked sockets joined by "=", header shows socket count and AP multiplier; tap a socket for its sigil detail, level/AP to next/effect, linked Tutor bonus, Remove, or pick a sigil from the bag), **Shop** (Buy/Sell toggle, prices, item/sigil detail lines, sell ratio). It reads no autoloads: `setup(party, db, shop)` then `open()`; signal `closed`; `builds` counts complete layout builds (tests use it to detect half-built screens). Every action calls PartyState/CharacterSheet/ShopSystem and then rebuilds; scroll position is kept. |
| `scripts/core/shop_system.gd` (`ShopSystem`, static) | `stock`, `buy_item`, `buy_sigil`, `sell_item`, `sell_sigil`, `sell_price` (flat `sell_ratio` of the price, 0.5), `for_sale`. Returns "" on success or a reason ("Not enough gold.", "Not for sale.", "That cannot be sold." for heirlooms/bound items). Only bag items can be sold. |
| `scripts/core/item_info.gd` (`ItemInfo`, static) | Text helpers: `item_line`, `skill_line`, `sigil_effect`, `sigil_progress`, `sigil_ap_text`, `sigil_short`, `bonus_text`, `mods_text`, `delta_text(before, after)`, `signed`, names for stats and slots. |
| `scripts/core/encounter_builder.gd` (`EncounterBuilder`, static) | `build_group(encounters, battles, index)`, `build_skirmish(...)` (weighted pick), `group_count`. Moved out of `GameState`. |
| `scripts/core/character_sheet.gd` | New `with_item(slot, item_id, items)` returns a throw-away copy wearing that item (used for the stat-delta preview). |
| `scripts/core/game_data.gd` | Loads `data/shop.json` into `shop`; new `party_db()` (classes, weapons, items, sigils, skills). |
| `scripts/ui/battle_scene.gd` | **Pre-battle panel** (`prep_panel`): every battle now starts paused with the briefing, gold, **Begin Battle** and **Party, Gear and Shop**. Closing the party screen rebuilds the battle from the new gear (`_on_party_closed` -> `_start_battle`). Results screen got a **Party, Gear and Shop** button. Load is allowed during the pre-battle panel. New vars `prep_*`, `party_screen`, `prep_active`; new funcs `_show_prep`, `_on_begin_pressed`, `_on_party_pressed`, `_on_party_closed`. |
| `data/shop.json` | "Sethorn Market Stall": 19 items, 11 sigils, `sell_ratio` 0.5. |
| `data/sigils.json`, `data/skills.json` | New **Sigil of Frost** (350 g, AP 70/220/520: Frost Shard at Lv1, Frost Lance at Lv3) and two `damage` skills: Frost Shard (power 6, 3 MP, range 2-5), Frost Lance (power 11, 7 MP, range 2-5). |
| `scripts/core/save_system.gd` | `GAME_VERSION` 0.5.0 (save format unchanged; v0.4.0 saves still load). |
| `tests/run_tests.gd` | New `_test_shop_and_screen()` (shop data, Frost sigil, text helpers, buy/sell rules incl. heirloom/equipped/not-in-bag/not-enough-gold, `with_item` preview, and a headless smoke test that builds `PartyScreen` for every roster member x every tab, equips/unequips/sockets/buys/sells through its handlers and checks `builds`, state and messages). Skirmish tests now call `EncounterBuilder`. |
| `tests/balance_report.gd` | `godot --headless --path . --script res://tests/balance_report.gd [-- N]`: AI-vs-AI table per enemy group (win %, turns, survivors, HP lost %, EXP/AP/gold per victory, verdict easy/fair/hard/brutal) plus a 60-battle grind curve with one persistent party (levels, gold, bag sigils every 5 battles). Paste its output into the next chat to tune `HP_GAIN`, enemy rewards and item/sigil prices. |

**Known gaps after v0.5.0:** nothing has run in Godot; the party screen is untested on a real touch device (button sizes 52-84 px at 1280x720 base, fonts 15-30; check on a phone and adjust; the right-panel width is ~570 px so four sockets wrap into two rows); no class/weapon-type restrictions; no blacksmith upgrades; sigil sell price is flat (not level-based); shop stock is a fixed list (no chapter gating); no HQ screen yet, so the party screen is reachable only from the pre-battle panel and the results screen; still missing from Milestone 2: remaining classes as data, skills v1 per tier-1 class, status effects, fatigue, counter-attacks, forest concealment, weather, enemy tables for more maps.

## Files and responsibilities (Milestone 1 core; see the v0.5.0 table above for newer files)
| File | Role |
|---|---|
| `scripts/core/game_data.gd` | Autoload `GameData`: loads all JSON in `data/`; `as_db()` gives one dictionary for the battle code |
| `scripts/core/save_system.gd` | Autoload `SaveSystem`: slots, atomic write, SHA-256 checksum over a payload *string*, `.bak` fallback, version + `migrate()` |
| `scripts/battle/battle_map.gd` | Grid, terrain, heights, Dijkstra reach and paths, line of sight, facing helpers |
| `scripts/battle/battle_unit.gd` | Combatant data, `create()` from character+class defs, `to_dict`/`from_dict` |
| `scripts/battle/combat_calc.gd` | ALL formulas (attack power, defense, hit, crit, facing, flank, height, morale, heal) |
| `scripts/battle/turn_queue.gd` | Charge-Time order, timeline prediction |
| `scripts/battle/battle_ai.gd` | Scoring AI (team-agnostic; `run_ai_turn(true)` lets it play the player side for sims) |
| `scripts/battle/battle_controller.gd` | Rules, state machine, signals, victory/defeat, save/restore |
| `scripts/ui/battle_scene.gd` | Isometric drawing, gestures, HUD built in code |
| `tests/run_tests.gd` | Headless checks + 30-battle AI-vs-AI simulation |
| `scripts/core/character_sheet.gd`, `party_state.gd`, `game_state.gd` | Persistent heroes, party/inventory/sigil bag/gold, runtime state (v0.3.0-0.4.0) |

## v0.4.0: renaming + FF7-style grinding (untested in Godot, like everything since v0.2)
- **Rename:** world, houses, heroes, enemies, class display names and item display names changed (GDD Appendix B). IDs of the hero/enemy characters changed too (`torren`, `bram`, `sela`, `brother_wystan`, `hask_gravelteeth`, `roadreaver`, `roadbowman`; house ids `dunmarrow`, `orrowen`, `tarnholt`...). Class ids and weapon/item ids are unchanged. Save files from v0.3.0 are NOT compatible (old character ids).
- **New data:** `data/sigils.json` (10 sigils), `data/encounters.json` (Skirmish groups), `skills.json` +4 skills (mend_ii, mend_iii, ember_bolt, ember_storm; type `damage` is new), `items.json` weapons/armor have `sockets`, `links`, `ap_mult`, enemies in `characters.json` have `reward {exp, ap, gold}`, `campaign_start.json` has `sigils` (5 in the bag), heroes got MP (Torren 8, Bram 6, Sela 8) and MP growth for swordsman/knight/archer.
- **CharacterSheet:** `sigils` per group (weapon/armor), `fit_sockets`, `active_sigils`, `award_ap` (returns reports, `spawn` flag once on mastery), `all_skills`, `skill_mods`, `sigil_mods`, `reward_pct`; `total_stats(items, sdefs)`; `to_battle_def` now adds sigil skills, `skill_mods`, `reward`.
- **PartyState:** `sigil_inv`, `equip_sigil`/`unequip_sigil`, sockets refit on weapon/armor change (`unequip(char, slot, db)` has a new optional db), **new reward rules** `battle_rewards()` / `apply_battle_result(units, result, rng, db)` which now returns a Dictionary (`reports`, `gold`, `spawned`, ...). `battle_exp()` was removed.
- **Battle:** `BattleUnit.reward`, `skill_mods`; `CombatCalc.enemy_reward`, `skill_preview`, `skill_resolve`, `skill_power_mult`, `heal_amount(caster, skill, skill_id)`; `BattleController.skill_targets` handles `target: "enemy"`, `try_skill` handles `damage` (`_cast_damage`, signal kind `skill_damage`); `BattleAI._best_bolt`.
- **Core/UI:** `GameData.sigils/encounters/rules_db()`; `GameState.award_battle` returns the rewards dictionary, `skirmish_def()` + static `build_skirmish()`; `battle_scene.gd`: results screen shows FF7-style totals, per-hero EXP/AP, sigil level-ups, mastery copies; buttons "Skirmish (grind...)" and "Story Battle"; saves include `battle_def` so a skirmish can be loaded; ember skill preview and damage popup.
- **Tests:** `_test_progression()` battle-reward checks rewritten; new `_test_sigils()` (data integrity, levels, equip, links, Tutor/Resonance, stat sigils, greatsword sockets and AP x2, socket loss, mastery spawn, damage skill, AI, skirmish builder, AI-vs-AI skirmish). Only a static JSON cross-reference check has been run (it passes); the GDScript has never been executed.
- **Known gaps:** no sigil/equipment screen (cannot change sigils in the game yet), no shop, no limit-breaks, no summon/command sigils, no party-wide AP for bench, skirmish uses the one story map, balance untuned (grind pacing: about 62 EXP and 44 AP per hero per Prologue fight).

## v0.3.0: Milestone 2, step 1 (untested in Godot, like everything since v0.2)
- New data: `items.json` (21 items), `campaign_start.json`; `weapons.json` +3 weapons (fine_arming_sword, hardwood_bow, greatsword); `classes.json` cleric now grows MP; `characters.json` party heroes carry an `equipment` block (their armor totals equal the old numbers; a test guards it).
- `scripts/core/character_sheet.gd` (`CharacterSheet`): equipment-derived weapon/armor/stats, `derived(db)` via CombatCalc/BattleUnit, `equip_problem()`, `add_exp()` with growth rolls, `promotion_options()`/`promote()`, to/from dict.
- `scripts/core/party_state.gd` (`PartyState`): roster, inventory, gold, `equip`/`unequip`, `battle_db()` (swaps sheet-derived character defs into the battle db), `battle_exp()`/`apply_battle_result()`, to/from dict.
- `scripts/core/game_state.gd` (autoload `GameState`, registered after GameData in `project.godot`): owns the party and an RNG; `battle_db()`, `award_battle()`.
- `GameData.as_db()` now resolves every character through a sheet (so gear is folded in); `GameData.items`, `GameData.start`.
- `BattleUnit.kills/kill_exp` (saved), `CombatCalc.kill_exp()`, credited in `BattleController.try_attack`.
- `battle_scene.gd`: battles use `GameState.battle_db()`; results screen pays EXP once (`exp_awarded`) and prints one line per character with level-ups; saves include `party`; load restores it; info panel shows EXP. Restart Battle keeps the party's EXP (sandbox behaviour).
- `tests/run_tests.gd`: new `_test_progression()` (data integrity, v0.2-number regression guard, equip rules, EXP/levels, determinism, promotion, battle EXP, kill-EXP credit, JSON round trip).
- Known gaps: no equipment/character-sheet UI yet (equipping is only reachable from code/tests); no class/weapon-type restrictions; `HP_GAIN` and EXP values are untuned; only 5 classes exist so most promotion targets are filtered out.

## Patch v0.2.1: Auto Battle toggle (also untested in Godot)
- `battle_scene.gd`: `auto_battle` flag, toggle button under Save/Load, `_ai_controls(unit)` decides who the AI plays, `_maybe_run_ai()` loop now also runs player units when Auto is on, `_on_auto_toggled()`, settings in `user://settings.cfg` (`[battle] auto_battle`). While Auto runs `ai_busy` stays true, so manual buttons, taps, Save and Load are disabled. Switching Auto off hands control back at the next unit (`resync_view`).
- `battle_ai.gd`: `decide()` now returns `action = "skill"` (+ `skill_id`) when a unit with a heal skill can reach an ally at <= 50% HP (`_best_heal`). It also respects part-played turns (no second move after `has_moved`, nothing after `has_acted`).
- `battle_controller.gd`: `run_ai_turn()` executes the "skill" action via `try_skill`.
- `tests/run_tests.gd`: new `_test_auto_battle()` (heal planning, MP spent, part-played turn, no-force guard).
- Known gaps: the AI still has no buff/debuff logic; the existing "autosave at the start of a player turn" is skipped while the enemy loop is running (`ai_busy`), same as before; Auto does not stop at battle end (it stays on for a restarted battle).

## Key decisions (keep unless there is a strong reason)
- Godot 4.2+, GDScript, GL Compatibility, landscape 1280x720 base, stretch `canvas_items` + aspect `expand`.
- Isometric 2:1 tiles (64x32), height step 16 px. Facing = 4 grid directions (0=N(0,-1), 1=E, 2=S, 3=W).
- Turn order: Charge-Time (not player/enemy phases). Delay = 1000/SPD x (1.0 acted, 0.75 moved only, 0.5 waited).
- Damage = raw^2/(raw+def) with multipliers (see GDD 3.5). All formulas stay in `CombatCalc`.
- Saves: payload stored as a JSON string inside the envelope (stable checksum). 64-bit RNG values saved as strings.
- Autoload scripts have NO `class_name` (it would clash with the autoload name). Tests instantiate them with `load(...).new()`.
- Use spaces (4) for indentation in all GDScript files. Never mix tabs and spaces.
- Original IP only (Eldrimar, House Dunmarrow, Kaer Sethorn, the Covenant of the Seven Flames).

## Known limitations / risks of Milestone 1
1. Never executed: expect a few GDScript typing/parse errors on first run (the static checker removes the common classes of error but not all). Import the project once, then run `tests/run_tests.gd`.
2. Placeholder shape art only; no sprites, animation, audio.
3. Not implemented yet: counter-attacks, fatigue, status effects, weather, forest concealment, skills beyond Mend, equipment and leveling.
4. Pinch-zoom and touch targets are untested on a real device. HUD uses anchors; check on a 20:9 phone.
5. Load = newest of slot 1 / autosaves; there is no slot picker UI yet (Milestone 9).
6. AI has no healing/support logic and approaches the nearest enemy by straight distance before pathing.
7. Balance is unverified; sample matchups kill in 2-4 hits (see simulator output once the tests have run).
8. Dead units are simply hidden; no death animation.

## Next tasks, in order
0. **APK: the cloud build works (v0.5.1, run #3). Get the user's `build-logs` (`run_tests.txt`, `BUILD_SUMMARY.txt`) and their report of the first launch on the phone.** To rebuild: `Build_APK.bat` (Windows) or the GitHub workflow; if it fails, paste the console text or `dist/logs/BUILD_SUMMARY.txt`, and fix the root cause in `tools/build_apk.py` / `export_presets.cfg` (re-run `python tools/build_apk.py --check` and `python3 -I tools/gd_static_check.py` after edits). Then test the APK on a real phone: touch target sizes, party screen layout, save/load, app switching (autosave on pause), the Back button, immersive mode.
1. **Verify.** `godot --headless --path . --import` once, then `godot --headless --path . --script res://tests/run_tests.gd`, then play the battle in the editor (pre-battle panel, Party screen tabs, Skirmish, sigil level-ups on the results screen). Optionally run `tests/balance_report.gd`. If the user pastes errors/output, interpret every line (including SCRIPT ERROR lines that do not fail a check), fix root causes first, and re-run `python3 -I tools/gd_static_check.py` after every edit.
2. **Milestone 2** — stats, classes, leveling, equipment (step 1 DONE in v0.3.0: items, slots, sheets, EXP, promotion, party; equipment + sigil + character-sheet screen and shop DONE in v0.5.0 (unrun); REMAINING: remaining classes as data, skills v1 (3-5 per tier-1 class), status effects, fatigue, counter-attacks, forest concealment, weather, balance report from the simulator; keep Auto Battle/AI working with each):
   - `data/items.json` + equipment slots (weapon, off-hand, armor, helm, accessory x2); rarity tiers.
   - Character sheet resource separate from `BattleUnit`; derived stats; EXP = 80+20*level; growth rolls; promotion rules (GDD 4.2).
   - Remaining classes as data: DONE in v0.5.2 (28 classes). Next: skills v1 (3-5 per first-tier class); status effects, fatigue, counter-attacks, forest concealment, weather.
   - `GameState` autoload for the persistent party; results screen with EXP and level-ups; basic equipment screen.
   - Extend the simulator into a balance report (win rate, average turns, damage per class).
3. Milestones 3-10 per GDD section 16.

## Per-milestone deliverables (from the master prompt)
Design specs, complete implementation code (never pseudocode), folder structure, required assets, scene architecture, data structures, testing instructions, expected results, known limitations.

## Session rule
Reserve the last ~15% of capacity: update this file, README and `CONTINUATION_PROMPT.md`, then commit all changes directly to GitHub. Do not create a project ZIP unless the user explicitly requests one.
**Always deliver (every change, however small):** updated `docs/GDD.md` (version bump + revision-log line) and updated `docs/CONTINUATION_PROMPT.md` as ordinary committed project files. Provide separate downloads only when explicitly requested.
