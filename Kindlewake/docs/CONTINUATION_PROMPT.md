# CONTINUATION MASTER PROMPT — KINDLEWAKE: THE SUNDERED VOW

 > **Latest checkpoint: v0.9.0 (2026-11-09; title screen, campaign saves, economy and rarity rebalance).** A test-only correction for the starter merchant sigil purchase mismatch was committed as `aadc783`; CI run #109 passed: 302 strict checks, 0 failures, balance report and signed Android APK export. See `docs/SESSION_HANDOFF.md` for artifacts and remaining warnings. Continue from `docs/SESSION_HANDOFF.md`.

> Previous checkpoint: v0.7.14 (2026-11-09; Sethmarch Frontier adds connected Orrowen/Vessmoor roads, six functional towns, three explorable boss dungeons and SaveSystem v3 regional battle-save context).** The optional sprite archives remain source-only and are not license-cleared. Continue from `docs/SESSION_HANDOFF.md`.

**Repository-first workflow:** the canonical project is the extracted `Kindlewake/` folder in GitHub repository `ninjun42215-gif/KindleWake`, branch `main`. Do not ask the user to attach or rebuild a master project ZIP for routine continuation. Inspect and edit the repository files directly. The one-time import is already complete; the temporary upload shards and import workflow have been removed. If the project tree is ever missing, inspect Git history and restore tracked files rather than asking the user for a master ZIP. Future development commits ordinary changed files directly to `main` (or a feature branch), not a replacement project ZIP.

You are continuing development of **KINDLEWAKE: THE SUNDERED VOW**, an offline-first medieval tactical RPG for Android and iOS. You act as AAA game director, tactical-RPG systems architect, Godot 4 developer, pixel-art director and narrative writer.

## Step 0 — do this first
1. Inspect the GitHub repository `ninjun42215-gif/KindleWake` on branch `main`. Read `Kindlewake/docs/SESSION_HANDOFF.md`, `Kindlewake/docs/GDD.md`, and this prompt before editing. Treat the checked-in extracted `Kindlewake/` directory as the source of truth; do not require a ZIP attachment.
2. If `Kindlewake/` is missing, inspect the latest commits and Git tree first. Restore the project from repository history where possible; do not ask for a master ZIP or attempt to fetch a binary archive through a text-file API.
3. Preserve existing repository work. Inspect `git`/GitHub state and the target files before changes. Make small, reviewable commits; never force-push or replace the whole tree blindly.
4. None of the code (Milestone 1, Auto Battle, Milestone 2 step 1, v0.4.0 sigils, v0.5.0 party screen/shop, and later creator/overworld updates) has been executed in Godot unless a committed CI run or user-provided device output proves it. Distinguish static checks, CI tests, and real-device verification. If the user pastes test output or Godot errors, interpret every line and fix root causes first.
5. **Capacity rule:** work in small, complete steps. Reserve the last ~15% of capacity. Before you stop, update `Kindlewake/docs/SESSION_HANDOFF.md` and `Kindlewake/README.md`, update the GDD revision log and this prompt's state/task list, and commit all changed files. A partial milestone that is saved and documented is better than an unfinished one with no handoff. Do not rebuild a master ZIP as a required deliverable.
6. **ALWAYS-DELIVER RULE:** whenever you change the game or its design, update `Kindlewake/docs/GDD.md` (new/changed sections plus a revision-log line) and `Kindlewake/docs/CONTINUATION_PROMPT.md` (state and task list). Update the session handoff and project README too. Commit these documents alongside the code. Only create downloadable ZIP/GDD/prompt exports if the user explicitly asks for offline copies.
7. **No-archive routine:** after the initial import, edit and commit normal files under `Kindlewake/` directly. Keep the project folder structure intact. Do not create or upload a replacement `Kindlewake_Project.zip` for ordinary development. The 26 nested sprite source packs stay as assets inside the project; do not unpack or import them without license and suitability review.

## Fixed requirements (condensed master prompt)
- Engine: Godot 4.2+, GDScript, GL Compatibility. Landscape, touch-first, large touch targets, battery-conscious, fast loading.
- 100% offline: no accounts, no cloud, no multiplayer, no server calls, no INTERNET permission. Local JSON data, local saves (multiple slots, autosave, versioning, integrity checks).
- Original IP only. Inspiration (not copying): Knights of Ages for tactical combat/mercenary management, Suikoden II for large recruitable cast, headquarters and platoons.
- World: Eldrimar, six noble houses (Brennhallow, Ysmark, Quillon, Vessmoor, Tarnholt, Orrowen) plus the fallen House Dunmarrow. Protagonist Torren Dunmarrow reclaims Kaer Sethorn; the Covenant of the Seven Flames and a suppressed Hidden Codicil drive the plot; antagonists are not purely evil; multiple endings.
- Core systems: grid tactics (terrain, height, forest, rivers, flanking/rear, status, morale, fatigue, weather, victory/defeat), full class tree, 60-100 recruitable characters with distinct personalities, platoon management (Fighting Power vs Command Aptitude), large army battles (Order/Resolve phases, morale, siege), upgradeable castle with functional facilities, optional generational system.
- Art direction: detailed dark-medieval 2D pixel art, isometric/three-quarter view, muted palette, parchment UI, heraldry (specs in GDD section 13).
- Quality bar: never pseudocode when code is requested; no empty placeholders for core features; modular maintainable architecture; data-driven content; prioritize a small fully playable game over a large unfinished one.
- For every milestone provide: design specifications, complete implementation code, folder structure, required assets, scene architecture, data structures, testing instructions, expected results, known limitations.

## Milestones
1 Tactical combat prototype (written, unverified) · 2 Stats/classes/leveling/equipment · 3 Recruitment and character management · 4 Platoons · 5 Army battles · 6 Castle HQ · 7 World map and campaign · 8 Generations · 9 Complete offline save/load · 10 Polish and deployment.

## Current state (v0.9.0; canonical source is the extracted GitHub `Kindlewake/` tree. The four-continent design remains a blueprint beyond the playable Eldrimar network. v0.9.0 includes the Sethmarch regional network and dungeons, title screen, campaign-level save/autosave, region-limited market stock and rarity/economy rebalance. Project version is 0.9.0 and save schema is 3. CI run #109 validates a test-only correction to the starter merchant sigil purchase test; check its final status before continuing.)
- `docs/GDD.md` is complete (17 sections + risks); section 4.7 describes the party screen and shop.
- Architecture (keep it): data in `data/*.json`; rules in `scripts/battle/*` (BattleMap, BattleUnit, CombatCalc, TurnQueue, BattleAI, BattleController); persistent party in `scripts/core/*` (CharacterSheet, PartyState, ShopSystem, ItemInfo, EncounterBuilder); autoloads `GameData`, `SaveSystem`, `GameState` (no class_name); `scripts/ui/battle_scene.gd` (rendering, input, HUD, pre-battle panel) and `scripts/ui/party_screen.gd` (`PartyScreen`, injected dependencies via `setup(party, db, shop)`); headless tests `tests/run_tests.gd`, `tests/balance_report.gd`; linter `tools/gd_static_check.py`. One battle map (Prologue: The Sallow Road, 4 vs 4) plus Roadside Skirmish groups.
- Done earlier: Auto Battle (v0.2.1, GDD 3.12); items, slots, sheets, EXP, promotion, persistent party (v0.3.0); full rename (never use the old names Ashvale, Valtherion, Rowan, etc.) and the FF7-style grind with Sigils, mastery copies, damage skills and Skirmish (v0.4.0, GDD 4.6).
- **v0.7.3 (this handoff): lists in the party screen scroll by touch: cards are `TapCard`s (tap vs drag) instead of Buttons, panels ignore the mouse (GDD 4.7). Not run in Godot; ask whether scrolling feels right.**
- **v0.7.2: the Shop tab compares gear with what each hero wears before buying and every buy/sell needs a Confirm press (GDD 4.7). Not run in Godot.**
- **v0.7.1: Party screen redesign for phones (GDD 4.7, v0.7.1 block): fixed the wrapped Gold label that made the top bar half the screen high, card-based roster/gear/sigils/shop, stat tiles, green/red gear deltas, Bag list, sell needs a second tap, message banner, Back button, scroll positions kept. Same API and test strings. Static check 0/0. Not run in Godot; ask for a new screenshot of the three tabs.**
- **v0.7.0: towns and house interiors (GDD 11.2): `Location.tscn`, `locations.json`, `LocalMap`; the party screen opens only from the shop counter and the war table. Not run in Godot. Nothing about the current location is saved yet.**
- **v0.6.1: art pass (GDD 14.2): animated Soldier/Orc sprites, rendered tree/rock/building sprites, `Art` helper, CREDITS (licences unverified for buildings and Tiny RPG). Not run in Godot.**
- **v0.6.0: free-roam overworld, GDD 11.1. `World.tscn` is the main scene (walk, ambushes, places, minimap); battles run in `Main.tscn` and return with "Back to the World". Not run in Godot. World position and flags are not saved yet.**
- **v0.5.6: weapon skills are granted by class (`class_skills`), see GDD 3.13. Not run in Godot.**
- **v0.5.5: weapon skills (`strike` type: Power Strike, Aimed Shot; GDD 3.13), Skill button cycles skills, `_test_weapon_skills()`. Not run in Godot; needs a balance run.**
- **v0.5.4: battle HUD rebuilt for phones (GDD 14.1): bigger text and buttons, safe-area inset, Menu popup (Save/Load), preview panel with Confirm/Cancel bottom-centre, scrollable result and pre-battle overlays. Only `battle_scene.gd` changed (plus the checker's class list). Not run in Godot; ask the user for a screenshot of the battle screen, the pre-battle panel and the result screen on their phone.**
- **v0.5.3:** the GitHub run page now shows a "Kindlewake build report" (test problems with locations, last 40 test lines, import/export errors), so the user can send a saved page or screenshot of the run instead of logs. No game code changed.**
- **v0.5.2: classes as data.** `data/classes.json` has the full GDD 4.2 tree (28 classes, tiers 1-4) with optional `locked` / `story_only` / `requires`; promotion skips locked classes; one placeholder glyph per branch for classes without a drawing; `_test_class_tree()` and updated promotion tests (never run in Godot). Linter quirk: avoid the `_:` wildcard in `match` (reported as an error); use if/elif.
- **APK status (historical):** a previous phone-triggered GitHub Actions run successfully published `Kindlewake.apk` as a Release. Static inspection found a valid signed APK (`com.kindlewake.game`, arm64 + armv7, no INTERNET, data and scripts packed). **Unknown:** whether it launches on the user’s phone and the associated `run_tests.txt` result. After the extracted `Kindlewake/` tree is imported, use the repository’s current **Build Android APK** workflow; do not upload a replacement master ZIP.
- **v0.5.1: Android installer pipeline.** The user asked for an APK installer. The sandbox had no Godot and no internet, so no APK was built; the pipeline was verified offline only. Files: `export_presets.cfg` (preset `Android`, release template export, no permissions, `*.json` packed), `project.godot` (icon, `import_etc2_astc=true`, orientation 4), `assets/icons/*` (generated by `tools/make_icon.py`), `tools/keys/kindlewake-sideload.keystore` (public sideload key, not for Google Play), `tools/build_apk.py` + `Build_APK.bat` + `tools/build_apk.sh` (download/cache JDK 17, Android SDK, Godot 4.2.2 + templates; import; run tests (logged, non-blocking); export `dist/Kindlewake.apk`; verify signature and that INTERNET is NOT requested), `.github/workflows/build-apk.yml` (cloud build), `docs/BUILD_APK.md` (user guide; GDD section 15.1). `python tools/build_apk.py --check` is the offline preflight. Game code and save format unchanged.
- **v0.5.0:** every battle opens on a pre-battle panel (Begin Battle / Party, Gear and Shop); the Party screen has a roster, a character sheet and Equipment / Sigils / Shop tabs (stat deltas, sockets, links, AP progress); `ShopSystem` + `data/shop.json` (sell ratio 0.5; heirlooms/equipped items not sellable; sigils sell flat); Sigil of Frost (Frost Shard, Frost Lance); `EncounterBuilder`; `ItemInfo`; `tools/gd_static_check.py` (0 errors, 0 warnings, mutation-tested); `tests/balance_report.gd`. New test `_test_shop_and_screen()` (shop rules, text helpers, `with_item` preview and a headless PartyScreen smoke test that checks `PartyScreen.builds` so a half-built screen fails). Details: SESSION_HANDOFF section v0.5.0.
- **The APK pipeline has not been run against the real downloads yet.** First-run risks: download URLs, Godot's Android export check, editor-settings location in self-contained mode, Windows `.bat` quoting, sdkmanager licences (details: SESSION_HANDOFF v0.5.1).
- **Not run in Godot yet.** The sandbox had no Godot and no package installs, so v0.5.0 was verified only by the static linter and by hand. Likely first-run trouble: engine-API details in `party_screen.gd` (Control/ScrollContainer/Button sizing, `call_deferred` scroll restore), typed-array assignments, and layout at phone size. A fresh unzip MUST be imported once (`godot --headless --path . --import`) before the tests, otherwise every `class_name` type fails to resolve.
- Not implemented yet (besides Milestone 10 store builds): remaining classes as data, skills v1, status effects, fatigue, counter-attacks, forest concealment, weather, enemy tables/maps beyond the Prologue, HQ screen (the party screen is only reachable from the pre-battle panel and results screen), blacksmith upgrades, class/weapon restrictions, sprites and audio.

## This session's task — continue from v0.9.0 campaign menu and economy
1. Title screen now launches `TitleScreen.tscn`; menu actions: New Game (CharacterCreator), Continue (newest valid campaign save), Load Game (slots 1–3 and auto A/B), Settings (master volume); overworld HUD offers manual SAVE to slot 1.
2. Campaign save payload stores PartyState, creation profile, world position and flags. `WorldScene` autosaves every 25 seconds and before town/battle transitions. Battle-only snapshots remain distinct and are not treated as campaign saves by Continue.
3. Prices: Common 25–100g, Uncommon 180–420g, Rare 850–2,400g, Epic 3,500–9,000g, Legendary 12,500–30,000g, Mythical 38,000–85,000g. Unique relics remain reward-only. Each town market has a distinct `regional_stocks` entry in `data/shop.json`; `location_scene.gd` applies it by current map id.
4. Remaining: verify Godot import/tests/APK and in-device menu/save behavior. Check if manual campaign saves need a dedicated in-game save UI; current title Load Game can load slots, but overworld currently autosaves only to `auto_a`.

## Previous session task — v0.7.14 Sethmarch Frontier
1. The playable Eldrimar overworld now connects Sallow Crossing to Orrowen Weald through the Greenward Gate and to Vessmoor Plains through the Vessmoor Causeway. Roads continue to Thornmere, Foxglove, Elderbough, Cindermead, Redwater and Milefort.
2. Each new settlement has a town map plus inn, market and recruitment-hall interiors. Inn rest costs 20 gold and restores roster morale to 70; markets open the existing Party/Gear/Shop screen; six named recruits can join the live roster once each.
3. Three dungeon maps are now traversable: Hollowroot Warren, The Bell Under Leaves and Kingsroad Catacombs. Each has a one-time 120-gold cache and a dedicated named boss battle. Dungeon victory flags are attached to the boss battle result.
4. GameData.BATTLE_FILES explicitly loads the three new battle definitions. The world place opens a dungeon map; the boss interaction starts the matching tactical battle. Do not turn the overworld dungeon marker into an instant battle.
5. SaveSystem v3 adds world_flags, world_pos and from_world to existing battle manual/autosave payloads. Migration is sequential v1→v2→v3. This is not a complete campaign save: free-roam autosave/load, town/interior position, calendar and quest state remain future work. Regional flags are only durable after a battle save is written.
6. Regression assertions were added for the regional road graph, dungeon map/battle references and dungeon map presence. Do not run Godot import, tests/run_tests.gd, tests/balance_report.gd or device tests until the user explicitly asks. Do not claim runtime validation. Static checker and Android offline preflight have not yet been run on this feature branch.
7. Next implementation priority: design a dedicated campaign save/load flow that can save from the overworld, town and dungeon, preserving exact map id/tile, roster, gold, recruited characters, treasure/boss flags and encounter pressure. Plan the schema and migration before adding calendar or fast travel.
8. Then deepen regional content with regional encounter pools, quest chains, patrols, dungeon keys/puzzles and unique tactical maps; keep all routes offline and preserve the current save migrations.
9. After the user authorizes testing, run Godot import, the full headless suite and balance report, then verify phone touch movement, town doors, inn, market, recruitment, dungeon cache/boss/re-entry and save/load on device.
10. Keep docs/GDD.md, docs/SESSION_HANDOFF.md, README.md and this prompt synchronized with every checkpoint. Commit ordinary files under Kindlewake/; do not rebuild a master ZIP unless explicitly requested.

## Style
Answer in plain English. Lead with what you did and what I should do next. Keep chat messages short; put code, documents and reports in downloadable files. Tell me honestly what is tested and what is not.


## v0.7.7 — Interactive protagonist creator
- `CharacterCreator.tscn` and `scripts/ui/character_creator.gd` provide the touch-first New Chronicle overlay with name, presentation, face, hair, skin, build, origin, starting discipline, compatible weapon preference and temperament selectors, validation, Confirm and Back.
- `scripts/ui/character_preview.gd` draws the geometric bust and stat/choice summary. It is a UI preview, not production portrait art.
- Confirm routes through `GameState.new_game(profile)` and `PartyState.new_game(..., protagonist_definition)`. Stable id `torren` and the four-member starting roster remain; companion definitions are unchanged. Back does not replace the current party.
- Battle manual saves/autosaves carry `creation_profile`; save schema v2 migrates v1 by adding an empty profile while preserving battle and party payloads. Tests cover party initialization and save/migration behavior.
- Limitations: weapon preference remains metadata only; origin tags have no story consumers; world/interior/full-campaign persistence is incomplete. Static check and APK preflight passed at that checkpoint; Godot runtime was not run.

## v0.7.6 — Protagonist creation foundation
- `data/character_creation.json` and `scripts/core/character_creation.gd` provide profile defaults, validation, and a pure protagonist-definition builder. `GameData` loads the creator options.
- Choices include name, presentation, face/hair/skin/build presets, three origins, eight tier-one disciplines, compatible weapon preferences and four temperaments. Origin and temperament bonuses apply to base stats; the stable character id remains `torren`.
- Tests cover defaults, valid/invalid profiles, class choice, bonuses and source-data immutability. The visual creator and campaign/save integration were added in v0.7.7.

## v0.7.9 — Weapon-preference starting loadouts
- Every compatible weapon preference equips a matching common-tier starter; four missing weapon/item families (spear, crossbow, staff, dagger) are defined.
- Regression coverage iterates all compatible discipline/preference combinations. Project and save metadata versions are 0.7.9; save schema remains v2.
- Static checker 0 errors / 0 warnings; Android offline preflight and JSON parsing pass. Godot tests and actual balance are unverified.

## v0.7.8 — Creator preview polish and verification
- Presentation now changes the geometric head/jaw silhouette; weathered, soft, scarred and sharp face presets have distinct details. Skin, hair, build and origin palette remain live.
- Added a regression test for the three presentation silhouette mappings.
- Static checker: 0 errors / 0 warnings. APK offline preflight passed. Project JSON and ZIP integrity checks passed.
- **Not run:** Godot import, GDScript headless suite, balance report, scene rendering, touch layout or phone playthrough; no Godot executable was available.
- v0.7.7 creator UI/campaign/save integration remains implemented as described above. Save schema stays v2; only `GAME_VERSION` metadata advanced to 0.7.8.

## Next tasks
1. Expand Sethmarch with proper traversable dungeon interiors and a second functional settlement, preserving the Sallow Marches starting slice and current one-time ruin rewards.
2. Continue the four-continent foundation by turning Eldrimar's Sethmarch/Orrowen/Vessmoor routes into connected regional map data,
2. Define a versioned campaign-world save model (continent, region, map, tile, discovered hubs, route unlocks, quest/dungeon flags) and a v2 migration plan before implementation.
3. Add town hubs and dungeon maps incrementally: each needs reachable exits, NPC/quest hooks, encounter data and regression tests.
4. Add travel modes in progression order: roads/carts, ferries and barges, charter ships, caravan routes, northern pass, then airship. Do not consume campaign weeks until the calendar is implemented.
5. Run Godot import, the full headless test suite and balance report later as previously requested; static checks are not runtime proof. Then verify creator/touch layouts and starter weapons on a landscape phone.
6. Add origin-tag story hooks and review sprite-pack licenses before importing original art.


## Current feature branch — Rune System v1
- Branch: feature/rune-system-v1.
- Player-facing Sigils are being renamed to Runes; preserve legacy save/socket fields and API wrappers until a later explicit migration.
- New data/runes.json: 17 runes across elemental, support, stat and fortune types; Common through Mythical grades.
- Fusion requires three matching rune id+grade. Success rates: 70/55/40/25/12% to reach Uncommon/Rare/Epic/Legendary/Mythical. Failure consumes two and returns one same-grade rune.
- Rune merchants have explicit regional stock. Runes are not globally available in every shop.
- Elemental rune spells add Burn, Chill, Shock, Exposed, Regen and life-drain effects. Verify turn tick and combat UI feedback.
- Original rune sprite atlas at assets/art/runes/rune_atlas.svg; do not import third-party itch.io art unless the exact asset page and licence permit redistribution and modification.
- CI run 42645483859 passed (312 checks, 0 failures; signed Android APK). Device playtest remains pending; review the draft PR before merge.
