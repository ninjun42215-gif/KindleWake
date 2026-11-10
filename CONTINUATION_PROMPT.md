> **ACTIVE COMBAT-CORRECTNESS CANDIDATE — 2026-11-10:** Branch `fix/ai-block-allies-in-approach-paths`, based on main `0e3b6ac4f526f599d0e585d544e6d7968fbf5252`. It adds an opt-in allied-cell blocker to `BattleMap.compute_reach`, uses that mode for AI candidate generation and approach/fallback routes, and leaves ordinary player movement's ally pass-through rule unchanged. A deterministic corridor regression proves the AI route avoids the ally while player movement retains pass-through. Exact-head Godot import, scene smoke, strict tests, balance report and Android export are pending; do not call the fix verified until the PR workflows finish.

---

> **HISTORICAL CHECKPOINTS:** Notes below this marker predate the current tactical-AI candidate. Verify live refs and exact-head CI before relying on earlier statuses.


> **ARCHIVED PRIOR CHECKPOINTS:** The notes below predate this rebased maintenance candidate. Verify live refs and CI before treating any branch, SHA or validation result as current.


> **ARCHIVED CHECKPOINT HISTORY:** The material below is historical context. Always re-read live main, PRs and exact-head checks before starting work.


# KINDLEWAKE — CURRENT LIVE HANDOFF (2026-11-10)

> **Authoritative state:** Repository `ninjun42215-gif/KindleWake`; default branch `main`; PRs [#28](https://github.com/ninjun42215-gif/KindleWake/pull/28), [#30](https://github.com/ninjun42215-gif/KindleWake/pull/30), [#31](https://github.com/ninjun42215-gif/KindleWake/pull/31) and [#32](https://github.com/ninjun42215-gif/KindleWake/pull/32) are merged; no active implementation branch. Always inspect the live `main` ref before starting new work. The earlier checkpoints below are historical only and must not override this block.
>
> **Project baseline:** Godot 4.2 / GL Compatibility; game and Android version 0.12.0; Android version code 1200; save schema 4. Keep the game offline. Preserve all existing systems, data and save compatibility; no version/schema change is part of this fix.
>
> **Current implementation:** courtyard movement now uses `Control._gui_input()` for tap and drag events, responsive playable bounds, gate placement below the objective card, and a 120px interaction radius. Character creator is a full-screen overlay, with a live portrait and compact summary pinned above the form on narrow portrait phones. Added viewport-bound regression assertions and a headless scan of every authored `.tscn` resource before gameplay tests and APK export.
>
> **Repository hygiene:** canonical extracted Godot source remains in `Kindlewake/`; the old root-level `Feature_*.zip` snapshots have been removed from main; root and project-level ignore rules cover generated Godot/build output and signing credentials. No old `Kindlewake_Project.zip` was present at repository root to archive.
>
> **CI/device status:** runtime code passed Godot 4.2.2 import (clean retry), 8/8 scene smoke loads, 427 strict checks with 0 failures, balance simulation, signed 40.8 MB Android APK export and zero requested Android permissions on commit `b2598c3c8620a701d1fabd84394ec5cbb7449451`. Build run [#633](https://github.com/ninjun42215-gif/KindleWake/actions/runs/42731540020), APK artifact `13724652587`; Version Sync #139, Project Health Audit #348 and Workflow YAML Lint #526 passed. PR #30 is merged. Transient first-pass global-class registration errors retry cleanly; ObjectDB/resource-cleanup warnings remain non-failing. Physical Android QA remains outstanding; no device screenshots/results exist.
>
> **Next step:** Phase 0/1 are merged and CI-validated. Complete the outstanding physical Android QA; do not start Phase 2 until the owner approves.
>
> **Current architecture & next step:** data remains JSON-driven under `Kindlewake/data/`; autoloads remain `GameData`, `SaveSystem`, and `GameState`; core rules remain under `Kindlewake/scripts/core/`; tactical rules remain under `Kindlewake/scripts/battle/`; UI remains code-built under `Kindlewake/scripts/ui/` with one-node scene shells. The courtyard mission logic remains in `EscapeMission`; this fix only repairs its traversal UI. The creator continues to emit the same validated profile contract. The smoke test is `Kindlewake/tests/scene_smoke_test.gd`; strict game tests remain `Kindlewake/tests/run_tests.gd`; Android build orchestration remains `Kindlewake/tools/build_apk.py`. Next approved milestone after this QA report is Phase 2: shared Theme, bundled OFL fonts, safe-area helper, SceneRouter, UIFX and AudioManager.

---

> **ACTIVE IMPLEMENTATION CHECKPOINT — 2026-11-10:** Main is `b322c86fbb44696dfc85382f49478dcb5bce2cd9` (v0.10.0, Android code 1000, save schema 3). The active candidate is branch `feature/recruitment-system-v1-2026-11-10`; do not describe it as merged until its PR is merged. The candidate bumps the game to v0.11.0, Android code 1100 and save schema 4.
>
> **Recruitment v1 scope:** the data now defines all 24 Wave-1 named characters (4 starting members + 20 recruitable profiles). Fourteen recruit profiles were added; the six existing recruit definitions were aligned to their intended class/weapon identities. Six muster halls now expose the recruit roster. Recruitment validates duplicate flags, gold costs, story flags and companion prerequisites before atomically adding the member and recording the one-time world flag.
>
> **Company bonds:** each CharacterSheet now carries loyalty 0–100, the party screen displays its bond band, and story systems can adjust it through `PartyState.adjust_loyalty()`. Save schema v4 migrates v3 members to neutral loyalty 50 and preserves existing party/world data. Calendar-based desertion, weekly wages, personal-quest scenes and automatic loyalty event changes are not implemented yet; late Act IV recruits remain correctly gated behind the future `act_4_unlocked` flag.
>
> **Validation state:** implementation is committed on the feature branch but has not yet passed its new exact-SHA CI build. The next AI must inspect the branch head, run the full APK workflow and strict tests, fix every failure, then open a PR. Merge only after all four core PR checks and every discovered PR workflow pass for the same exact head SHA. Physical-phone QA remains separate.

> **LIVE CHECKPOINT — 2026-11-10 (supersedes older checkpoint statements below):** Current `main` is `d25ac6840ab0cdcc339b6fa89ed4ef42dec917dc` (tree `6ea221fa15ccc4d073215e5fbf3edb60386feae8`). This is the merged PR #19 result. Its tree is identical to tested PR head `769022ebee463a35af95e4cd9dfcab7a55e89cb7`; do not confuse differing commit ancestry with differing source contents. Project version remains 0.10.0, Android code 1000, save schema 3.
>
> **Verified Android build:** run `42711243963` (Build Android APK #525) succeeded on that exact source tree with Godot 4.2.2, 342 strict checks / 0 failures, balance report completed, signed 41.2 MB APK and no Android permissions. APK artifact `13715144284`; SHA-256 `e1f303c2c9f5ef73b527988636ef5e467f6162ca043c1f443ad3fa33ea833c72`. Build log artifact `13715523963`.
>
> **Verified portable handoff:** run `42711223545` generated artifact `13714769557` from the same tested source tree. It contains 177 tracked files in four parts (25,000,000; 25,000,000; 25,000,000; 93,428 bytes). Reassembled archive size 75,093,428 bytes; SHA-256 `b7abf92e4e8c3f5340afc1a6c20f0527698c167d60f2efde4cd9901cc23c968e`. ZIP CRC, all 177 file hashes and safe extraction passed.
>
> **Live GitHub state:** PR #19 is merged; no open PRs were found. The rune branch `feature/rune-system-v1` has no unique commits ahead of main and is 121 commits behind. Numerous historical branches remain; do not delete them without a separate stale-branch review. Safe Auto Merge run `42711476072` completed successfully.
>
> **Audit of GDD 0.10.1–0.10.4:** responsive HUD/company/world/town layout code exists in battle, party, world and location UI scripts; battle class/enemy identity overlays exist in `battle_scene.gd`; the receiving folder, source-handoff helper, safety tests and handoff workflow exist. Automated tests cover party-screen construction and TapCard gestures, but do not exercise a full viewport/orientation matrix or screenshot-level visual layout. No dedicated assertions verify the identity-art drawing. The 0.10.4 handoff pipeline was exercised successfully by the verified artifact above. These are implementation notes, not a released app-version bump.
>
> **Outstanding release gates:** physical Android QA (launch, safe areas, portrait/landscape, touch/scroll, rune fusion, shops, status effects, save/load and performance) and authoritative redistribution/licence verification for the voxel-building pack. Optional sprite packs remain source-only. The first Godot import log contained transient global-class resolution errors, although the final build summary and strict suite passed; investigate that warning separately. The balance/test logs also report ObjectDB/resource cleanup warnings; tests still completed with 342 checks and 0 failures.

> **AUTHORITATIVE LIVE CHECKPOINT (2026-11-10):** Main `843d21be5b201b95736e98a38f0485274e5dcc03`; project version 0.10.0; Android code 1000; save schema 3; PR #16 merged. GDD has notes through 0.10.4 but these are not a project version bump. Latest main post-merge APK and source-handoff artifacts are not yet verified. Physical-device QA and voxel-building licence verification remain release blockers. Read `Kindlewake/docs/SESSION_HANDOFF.md` and `Kindlewake/docs/NEXT_AI_START_HERE.md` first; this block supersedes older checkpoint statements below.

> **Live checkpoint (2026-11-10):** Main before this handoff refresh is `fa34541df7f37a7f992f10bba3b5cb8f4afd7e23`, game version 0.10.0 / Android code 1000. PRs #7–#14 are merged. PR #14 proved the four-check exact-SHA gate and REST auto-merge end to end (Safe Auto Merge run `42705647621`). Continue from the current repository/GDD; remaining release gates are physical Android QA and voxel-building licence verification. Read `docs/NEXT_AI_START_HERE.md` and `docs/SESSION_HANDOFF.md` first; inspect live refs and checks.

> **Live repository checkpoint (2026-11-10):** PR #7 Operations Toolbox is merged into main at `d4b696938fcb22fc1e40862b11a900d435ab75b1`. Rune System source branch head is `01cd3f67a344a964b26eb4150167a21bd3fb733c`; reconcile its gameplay/data/assets onto current main, preserve main's current workflows and version-sync tooling, run exact-head CI, then update this prompt and session handoff. Project version target is 0.10.0 / Android code 1000. Do not assume branch names or CI state without checking live refs.

# CONTINUATION MASTER PROMPT — KINDLEWAKE: THE SUNDERED VOW

> **Current checkpoint: v0.10.0 (2026-11-10; Rune System, Operations Toolbox and verified four-check REST auto-merge integrated).** PR #14 automatically merged after all four exact-SHA checks passed. See `docs/SESSION_HANDOFF.md` for artifacts and remaining QA. Older version notes below are historical.

**Repository-first workflow:** the canonical project is the extracted `Kindlewake/` folder in GitHub repository `ninjun42215-gif/KindleWake`, branch `main`. Do not ask the user to attach or rebuild a master project ZIP for routine continuation. Inspect and edit the repository files directly. The one-time import is already complete; the temporary upload shards and import workflow have been removed. If the project tree is ever missing, inspect Git history and restore tracked files rather than asking the user for a master ZIP. Future development uses short-lived feature/workflow branches and pull requests; never commit directly to `main`.

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


## Manual GitHub workflows
See docs/MANUAL_GITHUB_WORKFLOWS.md for standalone user-operated workflows: build APK, create source handoffs, audit/organize documentation, prepare safe branch-integration PRs, inspect branch hygiene, create full repository backups, and lint workflow YAML. These tools do not require an AI assistant. The organizer only moves approved Markdown docs; safe integration never merges directly into the destination branch.


## Manual operations toolbox checkpoint
A separate workflow/manual-operations-toolbox branch is being prepared from main so these manual tools can be reviewed and merged independently of the Rune System feature PR. It adds source_handoff.py and its tests, the conservative repository organizer and tests, branch hygiene reporting, manual source handoff, full backup, safe branch integration and workflow YAML lint. No main-branch changes or merges are performed by the workflows. New workflow_dispatch entries become visible for manual launch after their files are merged to the default branch. Review PR #5 and its CI before enabling them.


## Repository-wide improvement pass — 2026-11-10

Approved improvement work was added to `workflow/manual-operations-toolbox` (PR #5), without merging to main:
- Source handoff now includes only the explicitly allowlisted public sideload/test keystore; all other keystore and signing-certificate suffixes remain excluded. A regression test guards the narrow exception.
- Added `Kindlewake/tools/project_health_audit.py` and manually launchable `.github/workflows/project-health-audit.yml`. It inventories the project, validates every project JSON file, detects version drift, checks asset-credit documentation, counts rune definitions against the 50+ target, and warns about nested workflow YAML.
- Workflow YAML Lint now pins checkout/setup-python actions to immutable commit SHAs, disables persisted checkout credentials, and runs project-health audit tests and the audit itself.
- Repaired literal escaped newline characters in `Kindlewake/README.md`.
- Expanded manual workflow documentation with Project Health Audit, main-branch protection setup, and signing-key handling guidance.

Validation status at handoff: the latest Workflow YAML Lint run was still in progress when this note was written. Do not claim the new tests/audit passed until the run for the latest PR #5 head completes. PR #5 remains draft; PR #4 remains draft. Main is still unmodified and unprotected. Branch protection could not be changed through the available GitHub write actions; configure it manually using the instructions in `Kindlewake/docs/MANUAL_GITHUB_WORKFLOWS.md`.

Next steps:
1. Inspect the latest PR #5 Actions run and fix any failing tests/YAML issues.
2. Review the full PR #5 diff, especially the source-handoff key exception and action pins.
3. Run Project Health Audit on main and feature/rune-system-v1; compare JSON/version/rune/asset findings.
4. Continue gameplay work on the feature branch: expand the rune system to 50+ tested definitions, validate active/passive/unique/heirloom behaviors and fusion probabilities, and add save migration/regression coverage.
5. Review asset licenses and add a structured asset provenance manifest before importing more packs.
6. Configure main branch protection in GitHub Settings. Keep both PRs unmerged until separately reviewed and explicitly approved for merge.
7. Re-run Android build and perform physical-device QA before any production release.


## Follow-up audit and provenance hardening — 2026-11-10

Work continued on `workflow/manual-operations-toolbox` (PR #5 only; main remains untouched):

- Expanded `Kindlewake/tools/project_health_audit.py` to validate rune definition shape, report rune kind totals, detect unverified asset-credit rows, parse a structured asset provenance ledger, and warn when an asset used in game is not marked licence-verified.
- Added `Kindlewake/data/asset_provenance.json`. It records the Quaternius CC0 pack as verified based on the repository's licence file; voxel building packs and Tiny RPG Character Asset Pack 01 are explicitly marked unverified and release-blocking; unused restricted/unknown packs remain documented as unused.
- Added `--fail-on-warnings` for strict pre-release auditing. Normal CI mode remains advisory for warnings; strict mode returns non-zero until warnings are resolved.
- Expanded `test_project_health_audit.py` for licence warnings, unused-pack handling, structured provenance, strict gate behavior, rune kind counts and malformed rune records.
- Added `docs/PROJECT_HEALTH_AUDIT.md` and updated manual workflow instructions.

**Validation status:** these latest changes have been committed to the toolbox branch, but a successful GitHub Actions run for the latest head has not yet been independently confirmed. Do not describe the new tests or audit output as passing until the latest PR #5 checks are inspected.

**Current known project state:** PR #4 remains a draft Rune System PR; its description reports 77 rune definitions and its branch is 309 commits ahead of main at the last comparison. PR #5 remains a separate draft operations-toolbox PR. Do not merge either PR without a separate explicit authorization. The main branch was still unprotected at the last inspection; branch protection must be configured manually in GitHub Settings. Two old branches are behind/diverged and should be reviewed with the read-only Branch Hygiene workflow, not automatically deleted or merged.

**Release blockers:** two asset packs currently used in game have unverified redistribution rights (voxel building packs and Tiny RPG Character Asset Pack 01). Do not publish a public/commercial build until authoritative licence evidence is recorded or the assets are replaced. Physical Android device/gameplay QA also remains outstanding.

Next actions:
1. Inspect latest PR #5 CI for the exact latest branch head; fix any syntax/test failures before claiming validation.
2. Run the audit against both `main` and `feature/rune-system-v1`; use strict mode to identify release blockers.
3. Review PR #4/#5 overlap in root GitHub workflow files before any integration; preserve independent, reviewable changes.
4. Configure main branch protection manually using `docs/MANUAL_GITHUB_WORKFLOWS.md`.
5. Resolve asset licensing or replace unverified assets, then complete physical-device QA before release.
6. Produce and verify a fresh split source handoff from the latest commit; compare its embedded SHA to the live branch head.


### Final handoff refresh — 2026-11-10
- Structured provenance ledger is now linked from `Kindlewake/assets/art/CREDITS.md`.
- Most recent audit/provenance code and ledger checkpoint before this documentation refresh: `6b36e169dfcd3be6e4f4b85a867f249ce9407611`.
- Read live PR #5 head and CI state before further work; no completed CI result has yet been confirmed for the audit/provenance hardening. Earlier green runs predate these changes.
- The source handoff workflow is configured to run on `workflow/**` pushes, but do not claim a new downloadable artifact is ready until its run succeeds and the part manifest/checksums are verified.


### Additional pre-release audit coverage — 2026-11-10
- Project Health Audit now compares `project.godot` version, README headline version and Android export preset `version/name`; it also validates a positive integer `version/code`.
- Live inspection found the old `main` baseline at project/README **0.9.0** but Android export preset **0.7.14** (version code 714). This mismatch is recorded as a warning, not silently changed on main.
- The Rune System feature branch currently has project/README/export preset **0.10.0** with Android version code **1000**, consistent at inspection time.
- Added an Android export-version drift regression test. Latest CI for this and the asset provenance additions is still unconfirmed.


### Verified implementation checkpoint — 2026-11-10

Current operations branch checkpoint at the time of this note:
- PR #5: `workflow/manual-operations-toolbox`, draft and unmerged. The latest verified code/documentation checkpoint was `14a8a34b0f34625c32ea727f818c1b74e0032fc6`; check the live PR head before continuing because this note itself is a documentation refresh.
- Latest Workflow YAML Lint passes: runs `42687335517` and `42687326371`.
- Latest Project Health Audit passed with 0 errors and 3 warnings: run `42687327011`; report artifact ID `13705327262`.
- Latest manual source handoff passed: run `42687326282`; artifact ID `13704633339`. It contains 161 tracked files in four ZIP parts (each <=25,000,000 bytes), zero excluded files, archive SHA-256 `73ab35465650e9090c36920720d94cef75802d7c302dc11e952e2551c2c6ce10`.
- The three health-audit warnings are: main project version 0.9.0 vs Android export preset 0.7.14/code 714; one active voxel-building pack still has unverified rights (reported by both the credits table and provenance manifest). The audit is intentionally warning rather than silently approving unknown rights.
- Quaternius Stylized Nature MegaKit is documented with the official CC0 pack page. Zerie's free Soldier/Orc subset is documented with the author's official game-use/modification terms; standalone asset redistribution remains prohibited. Only the voxel-building pack remains an unresolved used asset.
- PR #4: `feature/rune-system-v1`, draft and unmerged, head `c4a7e72313050acc35b3a85db9b53876048f437b`. It contains 77 runes (23 magic, 43 passive, 3 support, 6 stat, 2 independent; 7 unique and 5 heirloom flags overlap those kind counts). Latest CI run `42686782251` passed: 342 checks, 0 failures, balance report, Android 0.10.0/code 1000 APK export/signature verification, and source handoff. APK artifact ID `13704502185`; source handoff artifact ID `13705496581`.
- Main remains untouched and unprotected. Do not merge either PR unless the user explicitly authorizes it. The available GitHub integration cannot modify branch protection; configure it manually.

Next actions:
1. Verify the original source/licence of the voxel-building pack set or replace the assets; do not mark them verified without authoritative evidence.
2. Resolve main's Android export preset mismatch in the correct integration order; avoid overwriting PR #4's 0.10.0/code 1000 values with the older baseline.
3. Re-run Project Health Audit with `--fail-on-warnings` only after all release warnings are resolved.
4. Configure main branch protection manually from `Kindlewake/docs/MANUAL_GITHUB_WORKFLOWS.md`.
5. Review the shared workflow overlap between PR #4 and #5, then merge in a deliberate order only after explicit authorization.
6. Perform physical Android device QA and gameplay/save testing; CI export success is not device certification.
7. Recheck the live PR heads and produce a fresh handoff artifact from the exact latest commit before handing work to another AI.
