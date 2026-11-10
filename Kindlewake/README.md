> **LIVE PROJECT CHECKPOINT — 2026-11-10 (visual asset pass):** Canonical repository `ninjun42215-gif/KindleWake`; default branch `main`. PR #28 (v0.12.0 world expansion), PR #30 (Chapter I + creator fixes), PR #31 (verified CI handoff) and PR #32 (final post-merge handoff state) are merged. There is no active implementation branch for this milestone; inspect the live `main` ref before starting new work.
>
> **Project state:** Godot 4.2 / GL Compatibility, game and Android version `0.12.0`, Android version code `1200`, save schema `4`. Preserve all existing systems, JSON data and saves. No version/schema change was needed.
>
> **Phase 0/1 complete:** Chapter I courtyard movement uses `Control._gui_input()` for taps and drags, responsive playable bounds, gate placement below the objective card, and a 120px reach radius. The title screen mounts the creator as a full-screen overlay; portrait preview and compact live summary stay pinned above the scrolling form on narrow portrait phones. Pure responsive-layout regression checks and an all-scene headless smoke test are in place. Root ignore rules are installed and five superseded root-level `Feature_*.zip` snapshots are removed. The canonical extracted project remains `Kindlewake/`; no root `Kindlewake_Project.zip` existed to archive.
>
> **CI evidence:** runtime-code commit `b2598c3c8620a701d1fabd84394ec5cbb7449451` passed Godot 4.2.2 import (clean retry), 8/8 scene smoke loads, 427 strict checks with 0 failures, balance simulation, signed Android APK export (~40.8 MB) and zero requested Android permissions. Build run [#633](https://github.com/ninjun42215-gif/KindleWake/actions/runs/42731540020), APK artifact `13724652587`. Version Sync #139, Project Health Audit #348 and Workflow YAML Lint #526 passed. Documentation-only PR #31 also passed Build Android APK #635, Project Health Audit #350, Version Sync #141 and Workflow YAML Lint #539 before merge. The first editor import scan still logs transient global-class registration errors before its clean retry; ObjectDB/resource-cleanup warnings remain non-failing.
>
> **Remaining QA:** physical Android testing is not yet recorded. Verify 20:9 portrait and landscape, safe areas/notches, title → creator → BACK, Prologue → escape → battle → World, victory flag, kill/relaunch and Continue/save-load. CI is not device QA.
>
> **Next step:** complete physical Android QA and report findings. Stop before Phase 2 (Theme/fonts/SceneRouter) until the owner approves.
>
> **Current architecture:** JSON data remains under `Kindlewake/data/`; autoloads remain `GameData`, `SaveSystem`, and `GameState`; core rules remain under `Kindlewake/scripts/core/`; tactical rules under `Kindlewake/scripts/battle/`; UI remains code-built under `Kindlewake/scripts/ui/` with one-node scene shells. Courtyard mission rules remain in `EscapeMission`; responsive layout math is isolated in `EscapeLayout`. The creator emits the existing validated profile contract. Tests: `Kindlewake/tests/run_tests.gd` and `Kindlewake/tests/scene_smoke_test.gd`; Android build orchestration: `Kindlewake/tools/build_apk.py`. The next approved milestone after device QA is Phase 2: shared Theme, bundled OFL fonts, safe-area helper, SceneRouter, UIFX and AudioManager.
>
> **Hard constraints:** fully offline; no accounts, servers, multiplayer or INTERNET permission. Preserve saves and schema compatibility. The unresolved third-party sprite-pack redistribution licence remains a public/commercial release blocker until verified or replaced.

---



# Kindlewake: The Sundered Vow — Rune mastery and world expansion (v0.12.0)

Offline-first medieval tactical RPG for Android and iOS, built with Godot 4.2+ (GDScript, GL Compatibility).
Design document: `docs/GDD.md` · Session notes: `docs/SESSION_HANDOFF.md` · Next-session prompt: `docs/CONTINUATION_PROMPT.md` · Start here: `docs/NEXT_AI_START_HERE.md`

Manual repository workflows: `docs/MANUAL_GITHUB_WORKFLOWS.md`.

## Source-of-truth and GitHub workflow
- Version source of truth: `project.godot`; GitHub Actions automatically synchronizes the README and Android export version on main. See `docs/VERSIONING.md` and run `python tools/sync_version.py --check` locally.
- The extracted `Kindlewake/` directory in `ninjun42215-gif/KindleWake` on `main` is the canonical source. Routine development edits are committed as ordinary files; do not upload or rebuild a master project ZIP.
- After the extracted folder is present, future updates are direct file commits. Keep `docs/SESSION_HANDOFF.md`, `docs/GDD.md`, this README, and `docs/CONTINUATION_PROMPT.md` current with each meaningful change.
- The nested sprite packs are optional source material only; they are not imported into scenes or license-cleared.

## v0.10.0 — Rune mastery and expanded battle systems

**Version note:** GDD revision entries 0.10.1–0.10.4 record subsequent implementation notes, but `project.godot` remains authoritative at 0.10.0. Do not advertise a newer app version until the project, Android export, SaveSystem metadata and CI all agree.
- Replaces player-facing Sigils with a data-driven Rune library: 77 definitions across active magic, passive, support, stat and independent effects, including unique and heirloom runes.
- Three-copy fusion supports mixed grades; rune mastery/AP improves fusion success. Unique and heirloom runes have safeguards against accidental sale or fusion.
- Adds rune-driven Burn, Chill, Shock, Exposed, Regeneration and Shadow life-drain effects, combat feedback, rune sockets and specialist regional rune merchants.
- Adds original rune atlas and UI/environment artwork, expanded battle data and supporting GDD coverage.
- Android project version: 0.10.0 (version code 1000). CI validates imports/tests and APK export; physical-device gameplay QA remains outstanding.
- Public/commercial release remains blocked until the used voxel-building pack's redistribution licence is verified or those assets are replaced.

## v0.9.0 — Title screen, campaign saves and economy
- New title menu: New Game, Continue, Load Game and Settings.
- Campaign saves preserve the party, protagonist choices, overworld position and regional flags. The overworld autosaves periodically and before travel transitions.
- Equipment price bands now scale sharply by rarity; Unique relics remain special rewards. High-tier armor stats have been moderated.
- Each market has a distinct regional stock list. Sethorn is an entry-level stall; later markets specialize in rare, epic and limited legendary/mythical wares.
- Settings currently provide a persistent master-volume control. The overworld HUD also has a manual SAVE action to slot 1.

## Sethmarch Frontier (v0.7.14)
- Connected Sallow Crossing to Orrowen Weald and Vessmoor Plains with continuous roads and regional gate landmarks.
- Added six settlements: Thornmere, Foxglove, Elderbough, Cindermead, Redwater and Milefort. Each has a town map, inn, market and recruitment hall.
- Inns cost 20 gold and restore roster morale; markets open the existing party/shop screen; six named recruits can be invited once each.
- Added three explorable dungeons with one-time treasure caches and dedicated boss battles: Hollowroot Warren, The Bell Under Leaves and Kingsroad Catacombs.
- SaveSystem v3 stores regional world flags and overworld hand-off context in battle saves. This is not yet a complete free-roam campaign save; overworld/town/dungeon saving remains a next milestone.
- Regression assertions were added, but the user previously asked to defer Godot tests. No Godot runtime, balance or device verification is claimed. Static checker and Android offline preflight have not yet been run for this branch.

## Get the Android installer (APK) — new in v0.5.1
- **Windows:** double-click `Build_APK.bat` (needs Python 3; first run downloads about 1.3 GB, then your installer is `dist/Kindlewake.apk`).
- **Cloud:** push the project to GitHub and run Actions -> "Build Android APK" (no Android tools on your PC).
- **By hand in the Godot editor:** the `Android` export preset is already in `export_presets.cfg`.
- Install on the phone: copy the APK over, allow "Install unknown apps", tap it. Full steps and troubleshooting: `docs/BUILD_APK.md`.
- The APK asks for no permissions (the build fails if INTERNET ever appears). Offline settings check: `python tools/build_apk.py --check`.
- Status: the pipeline was checked offline only; it has not yet run against the real Godot/Android downloads. The same build also runs the game tests and saves the output in `dist/logs/`.

## Sprite asset integration (v0.7.4)
- The supplied `sprite.zip` was integrated as 26 original nested source archives under `assets/optional_sprite_packs/`.
- These are preserved as source packs, not yet extracted/imported into Godot scenes or assigned to game objects. This avoids making unverified art/license assumptions or disrupting existing assets.
- Before production use, review each pack's contents, license/attribution terms, dimensions, animation format, and fit with Kindlewake's muted pixel-art direction. Then selectively import approved assets and record credits in `assets/art/CREDITS.md`.

## Interactive protagonist creator (v0.7.9)
- The overworld HUD now opens a touch-first **New Chronicle** creator overlay with name, appearance, origin, discipline, weapon preference and temperament choices.
- A live geometric bust preview and stat-bonus summary update as choices change. The preview now varies the head silhouette by presentation and uses distinct facial details for weathered, soft, scarred and sharp presets; invalid profiles cannot be confirmed.
- Confirm initializes a new campaign while preserving the stable `torren` id and four-member starting party. Back leaves the current in-memory party untouched.
- Battle saves/autosaves preserve the creator profile. SaveSystem v3 also stores regional world flags, overworld position and the from-world hand-off; v1→v2→v3 migrations preserve existing battle and party data.
- Each compatible weapon preference now equips its matching common-tier starter: sword, axe, spear, bow, crossbow, staff, mace or dagger. The creator records the selected item. Origin story hooks and full free-roam campaign saves remain future work; regional flags persist only when a battle save is written.
- Static checker: 0 errors / 0 warnings. Android offline preflight passes. A headless test now guards the presentation-to-silhouette mapping, but Godot import, the GDScript test suite, scene rendering and gameplay have not been run in this environment.

## Run
1. Install Godot 4.2 or newer (standard build, not .NET).
2. Open `project.godot`, press Play (F5). No internet and no external assets needed.

## Verify it (do this first; nothing since v0.2 has ever been run in Godot)
Run these from the project folder, in this order:
```
godot --headless --path . --import
godot --headless --path . --script res://tests/run_tests.gd
godot --headless --path . --script res://tests/balance_report.gd
```
1. `--import` runs ONCE on a fresh unzip. It lets Godot register the `class_name` scripts; without it the tests fail with "Could not find type ..." errors. (Opening the project in the editor once does the same.)
2. `run_tests.gd` prints `ok` / `FAIL` per check, then an AI-vs-AI battle simulation summary. Exit code 0 = all checks passed. **Any `SCRIPT ERROR` or `Parse Error` line matters even if the checks say ok.**
3. `balance_report.gd` prints how hard each enemy group is and how the campaign reward curve scales (add `-- 100` for 100 battles per scenario).
4. Open `project.godot`, press Play, and follow the campaign: travel, enter story locations, manage the Company, fight, then Continue Journey from the results screen.
5. Paste ALL the output (including errors) into the next chat.

Optional, needs only Python 3 (no Godot): `python3 -I tools/gd_static_check.py` lints every script and JSON file (parse-class errors, missing members, bad references). It reports 0 errors on this version, but it cannot see engine-API or logic mistakes.
(Status: written and statically checked, NOT yet executed in Godot; the sandbox that produced it had no Godot binary.)

## Controls
- Tap/click a tile or unit to select it. Tap a unit to inspect it.
- **Move**: tap a blue tile (path preview), tap it again or press Confirm.
- **Attack**: tap a red target (shows hit %, crit %, damage, rear/flank/height bonuses), tap again or Confirm.
- **Before every battle** a panel shows the briefing and two buttons: **Begin Battle** and **Party, Gear and Shop**. The same Party button is on the results screen.
- **Party screen**: pick a hero on the left. Tabs on the right: **Equipment** (tap a slot, see the stat change of each item before equipping), **Sigils** (tap a socket to add, inspect or remove a sigil; levels, AP to next level and links are shown), **Shop** (Buy / Sell toggle, sell price 50%). Close it to rebuild the battle with the new gear.
- **Skill** (Brother Wystan): Mend (from his Sigil of Mending) heals an ally within 2 tiles. Other heroes get spells by socketing Sigils in the Party screen (e.g. Embers, Frost).
- **Auto Battle** (button under Save/Load, top right): ON = the AI plays your units too (Brother Wystan will Mend allies at 50% HP or less). Tap it again to take back control at the next unit's turn. The setting is remembered in `user://settings.cfg`. Save/Load are disabled while Auto runs.
- **Wait / End** ends the unit's turn early. Acting automatically ends the turn.
- Drag to pan, pinch or mouse wheel or +/- to zoom. **Save** writes slot 1; **Load** restores the newest of slot 1 and the two autosaves.
- Autosave runs at the start of each player turn and when the app is paused.

## What is implemented (Milestone 1)
- Data-driven content in `data/` (classes, terrain, weapons, skills, characters, battle map).
- Isometric grid with terrain and heights, forest cover, river with bridge and ford, rock walls.
- Charge-Time turn order driven by Speed, with an 8-turn timeline.
- Dijkstra movement (terrain cost, height/jump rule, enemies block, allies pass through).
- Melee, ranged (min/max range, line of sight, high-ground range bonus) and a heal skill.
- Damage formula with hit, crit, facing (front/side/rear), flank, height and morale (see GDD 3.5).
- Morale changes on kills; routed units skip turns. Victory: rout all or defeat the chief. Defeat: Torren falls or all fall.
- Scoring AI (works for any team) with simple heal support; Auto Battle toggle hands your units to it. Placeholder shape art, touch gestures, HUD with 72 px buttons.
- Save system: slots, atomic writes, SHA-256 checksum, `.bak` fallback, version field, autosave rotation.
- Headless test-suite and battle simulator.

## v0.4.0: FF7-inspired battle rewards and Sigils (legacy foundation; campaign flow updated in v0.8.0)
- Every defeated enemy pays fixed EXP / AP / gold. EXP is split among the surviving heroes, each survivor gets the full AP, gold goes to the party. A defeat pays nothing.
- **Sigils** (the Materia equivalent) sit in weapon/armor sockets (some linked in pairs), gain AP, level up, teach spells (Mend, Ember Bolt...), boost stats, EXP or gold, and forge a fresh copy when mastered. Support sigils (Resonance, Tutor) work on the linked socket.
- The old results-screen Skirmish / Story Battle mode buttons have been removed. Random patrol encounters now occur during dangerous world travel; authored battles are entered through campaign locations and events.
- Details: `docs/GDD.md` section 4.6.

## v0.5.0: party screen, shop, static checker, balance report (written, NOT yet run in Godot)
- Pre-battle panel and a full **Party screen** (roster, character sheet, Equipment / Sigils / Shop tabs); stat-change preview for every item; sigil sockets, links, levels and AP shown. Code: `scripts/ui/party_screen.gd`. Details: `docs/GDD.md` section 4.7.
- **Shop** (`data/shop.json`, `ShopSystem`): 19 items and 11 sigils; sell price 50%; heirlooms and equipped items cannot be sold.
- New **Sigil of Frost** (Frost Shard, Frost Lance).
- `tests/balance_report.gd` (balance numbers per enemy group and a 60-battle progression curve) and `tools/gd_static_check.py` (Python linter).

## Milestone 2, step 1 (v0.3.0; written, NOT yet run in Godot)
- `data/items.json`: weapons, off-hands, armor, helms, accessories with rarity, bonuses, two-handed and heirloom rules. `data/campaign_start.json`: starting party, gold, inventory.
- `CharacterSheet` (persistent hero: class, level, EXP, base stats, equipment, derived stats, level-up growth, promotion) and `PartyState` (roster, inventory, equip/unequip, battle EXP, save/load) in `scripts/core/`; `GameState` autoload owns the party.
- Battles are built from the party's current sheets. The results screen pays out EXP and lists level-ups; Save/Load include the party. The info panel shows EXP for your units.
- Still missing from Milestone 2: remaining classes, skills v1, status effects, fatigue, counter-attacks, forest concealment, weather, enemy tables for more maps, balance tuning from the first real report.

## Not yet implemented (planned)
Counter-attacks, fatigue, status effects, weather, forest concealment, remaining classes and skills v1 (rest of M2), recruitment (M3),
platoons (M4), army battles (M5), headquarters (M6), world map and story (M7), generations (M8), full save UI (M9),
final sprites/audio/export presets (M10).

## Folder structure
```
data/            classes, terrain, weapons, skills, characters, items, sigils, encounters, shop, campaign_start, battles/battle_01.json
scripts/core/    game_data.gd, save_system.gd, game_state.gd (autoloads); character_sheet.gd, party_state.gd,
                 shop_system.gd, item_info.gd, encounter_builder.gd
scripts/battle/  battle_map, battle_unit, combat_calc, turn_queue, battle_ai, battle_controller
scripts/ui/      battle_scene.gd (rendering, input, HUD, pre-battle panel), party_screen.gd
tools/           gd_static_check.py (Python linter; no Godot needed), build_apk.py / build_apk.sh (APK builder), make_icon.py, keys/
assets/icons/    launcher icons
export_presets.cfg, Build_APK.bat, .github/workflows/build-apk.yml   Android packaging (v0.5.1)
tests/           run_tests.gd, balance_report.gd
docs/            GDD.md, SESSION_HANDOFF.md, CONTINUATION_PROMPT.md
```

## Export notes
- Android: already configured in `export_presets.cfg` (Compatibility renderer, ETC2/ASTC import, arm64-v8a + armeabi-v7a, landscape, no permissions, `*.json` packed so `data/` is included). Build it with `Build_APK.bat` or the cloud workflow; see `docs/BUILD_APK.md`. Do NOT enable the INTERNET permission.
- iOS needs macOS and Xcode (not set up yet).

**v0.5.4:** phone HUD rework (bigger text/buttons, safe area, Menu popup, preview + Confirm/Cancel panel, scrollable result screen). See docs/GDD.md 14.1.

**v0.5.5:** weapon skills: Power Strike (Torren, Bram) and Aimed Shot (Sela); tap Skill again to cycle skills. See docs/GDD.md 3.13.

**v0.5.6:** weapon skills now come from the class (`class_skills` in classes.json), so promoted heroes keep them.

**v0.6.0:** free-roam overworld (World.tscn is now the main scene): walk the Sallow Marches, find places, get ambushed, fight, return. See docs/GDD.md 11.1.

**v0.6.1:** art pass: animated Soldier/Orc sprites in battle and the overworld, tree/rock/building sprites rendered from the supplied 3D packs, credits in assets/art/CREDITS.md (some licences unverified).

**v0.7.0:** towns and houses: entering Kaer Sethorn or Sallow Crossing opens a town map, walking into a door opens the building interior, walking south out of a town returns to the overworld. See docs/GDD.md 11.2.

**v0.7.1:** the Party screen (inventory, gear, sigils, shop) was redesigned for phones: the top bar no longer wraps the Gold label (that bug pushed the panels to the bottom half of the screen), roster and bag entries are tappable cards, the sheet uses stat tiles, gear changes are shown in green and red, the shop shows prices and what is missing, selling needs a second tap, and the Back button closes the screen. Not run in Godot.

**v0.7.2:** in the shop, tapping a gear card compares it with what the hero wears (green/red stat changes, other heroes listed), and every buy or sell needs a Confirm press. Not run in Godot.

**v0.7.3:** lists in the party screen (roster, gear, sigils, shop) now scroll by dragging anywhere on a card; a short tap still selects. Not run in Godot.

## Weapon-preference starting loadouts (v0.7.9)
- The protagonist now starts with a weapon matching the selected preference. All eight preferences use common-tier gear; the four missing weapon families (spear, crossbow, staff and dagger) now have weapon and item definitions.
- The four-member roster, companion equipment and shared starting inventory are unchanged. Existing save schema remains v2; only game-version metadata advanced.
- Static checker and Android offline preflight pass. Godot runtime and balance tests remain unverified because Godot is unavailable in this environment.


## 2026-11-10 — Premium environment asset pass

- Added eight original KindleWake SVG settlement illustrations for the houses, frontier hut, keep and towers. `Art.world()` now loads these vector assets in place of the legacy voxel-building PNGs.
- Updated the asset provenance ledger and art credits. The unverified voxel building pack is no longer used by the game; its old files remain in the repository only as historical material.
- This is the first asset tranche, not a claim that the full game art is production-complete. Character portraits, player/companion sprites, enemy variety, dungeon set dressing, battle effects, UI iconography, and audio still need dedicated premium passes.


## Campaign politics foundation (implementation in review)

The current feature branch adds data-driven factions across the seven-continent atlas, regional political affiliations, bounded diplomatic relations, non-aggression/trade/alliance/war states, alliance trust gating, validated territory transfers and campaign history. Political state is stored as an optional campaign payload field; legacy schema-4 saves receive safe defaults. Code head `f7b31035e4651a4a6854cc5ad644beff88c2148b` passed the Android build, 8/8 scene smoke tests, 447 strict checks / 0 failures, balance report, version sync, workflow lint and project health audit. Physical Android QA remains outstanding. This is the rules/data foundation only: no player-facing kingdom UI, autonomous faction turns or complete strategic-war system is claimed yet. See `docs/GDD.md` section 19 and `docs/SESSION_HANDOFF.md`.
