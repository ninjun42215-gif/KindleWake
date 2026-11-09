# CONTINUATION MASTER PROMPT — KINDLEWAKE: THE SUNDERED VOW

> **Latest checkpoint: v0.7.13 (2026-11-09; three new road-connected Sethmarch ruin landmarks; no save schema change).** The supplied sprite bundle is preserved as 26 nested source ZIPs in `assets/optional_sprite_packs/`. They have not been imported into scenes or license-reviewed. Continue from `docs/SESSION_HANDOFF.md`.

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

## Current state (v0.7.11 repository import completed; gameplay remains v0.7.9. The canonical source is the extracted GitHub `Kindlewake/` tree with 129 tracked project files and the reconstructed optional sprite archive. The four temporary upload shards and one-time extraction workflow have been removed. Future edits are direct Git commits; no project ZIP is needed. v0.7.9 = v0.7.8 + balanced creator weapon-preference starting loadouts; v0.7.8 = v0.7.7 + creator preview polish and checkpoint verification; v0.7.7 = v0.7.6 + interactive protagonist creator, campaign hookup and save migration; v0.7.6 = v0.7.5 + protagonist creation foundation; v0.7.4 = v0.7.3 + supplied sprite source-pack integration; v0.7.3 = v0.7.2 + touch scrolling fix; v0.7.2 = v0.7.1 + shop compare and confirm; v0.7.1 = v0.7.0 + party screen redesign; v0.7.0 = v0.6.1 + towns and interiors; v0.6.1 = v0.6.0 + art pass; v0.6.0 = v0.5.6 + free-roam overworld; v0.5.6 = v0.5.5 + class skills; v0.5.5 = v0.5.4 + weapon skills; v0.5.4 = v0.5.3 + phone HUD rework; v0.5.3 = v0.5.2 + CI results page; v0.5.2 = v0.5.1 + full class tree as data; v0.5.1 = v0.5.0 + Android APK pipeline; v0.5.0 = v0.4.0 + party screen, shop, pre-battle panel, static checker, balance report)
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

## This session's task — continue from v0.7.9
1. The v0.7.7 creator scene, preview, validation, confirm/back flow, GameState/PartyState hookup, battle-save profile and v1→v2 migration are already implemented. Do not rebuild these systems or assume they are missing.
2. v0.7.8 polishes the geometric preview: presentation-sensitive head silhouette and distinct weathered / soft / scarred / sharp face details. A GDScript regression test covers the presentation mapping.
3. v0.7.9 equips a matching common-tier starter for every compatible weapon preference and adds spear, crossbow, staff and dagger data. Do not re-implement this mapping.
4. **First runtime task when Godot is available:** `godot --headless --path . --import`, then `godot --headless --path . --script res://tests/run_tests.gd`, then `godot --headless --path . --script res://tests/balance_report.gd`. Resolve every parse/runtime error before adding features. Godot is absent in the v0.7.9 environment; none of these commands ran.
5. **Phone verification:** test New Chronicle in landscape, all appearance selectors, origin/discipline/weapon filtering, live preview, stat summary, confirm, and Back preserving the existing party. Check safe areas, scroll, readability and touch targets.
6. Add origin-tag story hooks in small, testable steps. Tags are stored but do not yet trigger branches. Review the 26 nested optional sprite-pack licenses before importing art; no production portrait/body layers are approved yet.
7. Extend saves when world/local-map persistence is designed. Current v2 battle saves preserve party and creation profile; world position, interior state and full campaign state are not independently persisted.
8. After every code edit run `python3 -I tools/gd_static_check.py`; run `python3 tools/build_apk.py --check` before each checkpoint. Treat Godot/runtime behavior as unverified until actually executed.
9. After every finished subtask update `docs/GDD.md`, `docs/SESSION_HANDOFF.md`, `README.md` and this prompt, then commit changed text/source/assets directly to GitHub. Do not rebuild or deliver a project ZIP unless the user explicitly requests an offline archive.

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


## Automatic version synchronization — 2026-11-10

- Added `Kindlewake/tools/sync_version.py`; `project.godot` `config/version` is the only version source of truth.
- The tool synchronizes the README's first heading and Android export `version/name` and `version/code`. Code mapping: `MAJOR*10000 + MINOR*100 + PATCH` (minor/patch each <=99).
- Added unit tests in `Kindlewake/tests/test_sync_version.py` and `.github/workflows/version-sync.yml`.
- On pushes to main (including PR merges), the workflow repairs stale README/export metadata and commits only those metadata files. On PRs targeting main, it checks consistency and fails rather than rewriting the contributor branch.
- The PR check loads the trusted synchronizer from main, so older feature branches are covered too.
- Corrected main Android export metadata to version **0.9.0**, code **900**, matching `project.godot`. Main's README was already 0.9.0.
- Corrected the independent toolbox branch export metadata to 0.9.0/code 900. The Rune System branch remains 0.10.0/code 1000 and will only become main's version if/when that reviewed work is merged.
- Documentation: `Kindlewake/docs/VERSIONING.md`.

**Validation caveat:** the synchronizer and workflow files are committed, and live file inspection confirms main's version fields now match. The GitHub connector used here only exposes PR-triggered workflow runs, so it did not independently confirm the push-triggered `Synchronize Project Version` run. Verify its first run in Actions. Do not claim the workflow has passed until that run is green.
