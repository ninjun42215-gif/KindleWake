# KindleWake — Production Audit and Roadmap

**Audit date:** 2026-11-10  
**Repository:** `ninjun42215-gif/KindleWake`  
**Audited source:** live `main` at `036a17da88ab1b1037b224334dbfbbdcb392e195`  
**Project:** Godot 4.2.2, GDScript, GL Compatibility, offline-first

This document distinguishes systems that are present in the default branch from designs, data catalogues, and feature branches that are not yet integrated. A JSON entry or a draft pull request is not proof of a playable feature.

## Executive assessment

KindleWake has a functioning tactical-RPG foundation: character creation, party progression, equipment and runes, traits/personality, tactical battles, free-roam regional exploration, location maps, factions, and several authored quest chains. The highest risk is integration and content completeness, not a lack of ideas.

The project is **not release-ready**. The reported Android Continue crash has not been reproduced on a physical device; the full campaign is not yet a playable five-act experience on `main`; the seven-continent atlas is not seven fully traversable overworld regions; and mobile device QA, audio, typography, and broad art coverage remain incomplete.

## Current technical baseline

| Area | Current default-branch value |
|---|---|
| Engine | Godot 4.2.2 |
| Renderer | GL Compatibility |
| Game version | 0.12.0 |
| Android version code | 1200 |
| Save schema | 4 |
| Package ID | `com.kindlewake.game` |
| Android architectures | ARM64 and ARMv7 |
| Network policy | Offline-first; Android INTERNET permission disabled |
| Primary project root | `Kindlewake/` |

Do not change the save schema or project version as part of unrelated feature work. Any required migration must be explicit, backward-compatible, and covered by tests.

## Runtime inventory on main

These are catalogue/data counts, not a claim that every item is equally balanced or exposed through UI.

| System | Current count / status |
|---|---|
| Classes | 28, with tiered promotion links |
| Combat skills | 15 |
| Runes | 77 |
| Character traits | 69 plus 5 synergies |
| Personality event templates | 40 |
| Curated character ambitions | 12 |
| Character definitions | 36 |
| Location/town maps | 39 |
| Battle definitions | 6 |
| Continent atlas | 7 continent entries and 7 route-gate entries |
| Distinct overworld datasets wired through `GameData.world_for_region()` | 2: Eldrimar/Sethmarch and Thalassar/Brinegate Coast |
| Eldrimar overworld | 18 places and 17 roads |
| Generic companion quest framework | Not present on main |
| Regional trade/economy system | Not present on main |
| Five-act playable campaign continuity | Not present on main |
| Chronicle founder epilogue/unlock | Not present on main |
| Realm/territory management UI and simulation | Not integrated on main |

The seven-continent atlas is a campaign blueprint. At present, `GameData.world_for_region()` selects the Brinegate Coast dataset for `brinegate_coast` and returns the Eldrimar world for other region IDs. Do not describe all seven continents as separately playable overworlds until each has a real region dataset, route entry/exit, encounter pool, local maps, progression gate, and save/restore coverage.

The 39 location maps are town/interior maps; they are not 39 overworld regions.

## Implemented foundations

- **Combat:** grid-based tactical battles, unit snapshots, turn control, status effects, AI and deterministic battle simulations.
- **Characters:** character creation, persistent party, XP/levels, class promotions, equipment, enhancements, runes/sigils, traits, personality memories and behavior evidence.
- **Exploration:** free-roam overworld movement, terrain speed, local places, encounter buildup, battle transitions, and campaign autosaves.
- **World content:** data-driven location maps, two distinct regional overworld datasets, six battle definitions, factions and several authored quest systems.
- **Persistence:** checksummed save envelopes, temporary-file writes, backups, schema migrations, campaign restore validation, and battle snapshot validation.
- **Mobile:** Android export pipeline, touch controls, portrait/landscape layout work, signed CI APKs, and an offline-permission gate.

These foundations still require integration-level playtesting. A feature can pass a pure unit test while its scene, UI, content trigger, save lifecycle, or mobile interaction remains incomplete.

## Important gaps and recommendations

### 1. Continue/save reliability — highest priority

- Keep the runtime campaign-restore-to-World lifecycle scene in the strict CI path. It now executes on main.
- Main now validates semantic campaign payloads, recovers a valid backup when the primary is checksum-valid but malformed, refuses malformed campaign writes, protects valid backups, and prevents silent downgrade of newer-version saves.
- The SaveSystem regression suite now runs in a per-process test directory, not the player's real save folder.
- Ensure malformed in-memory campaign data cannot overwrite a valid save.
- Test manual slots, both autosaves, backup recovery, app pause/resume, process death, cold relaunch, and Continue on physical Android devices.
- Obtain the Android logcat `FATAL EXCEPTION` and Godot stack trace for issue #36. Headless CI is not a substitute.

### 2. Class and skill progression

The 28-class promotion graph is a useful base, but it is not yet a full talent/skill-tree system. `CharacterSheet` supports class promotion and class-defined skills; it does not expose a persistent skill-point budget or node-based talent tree.

Recommended next design:
- Give each class a small, readable branch tree: core, specialization, and capstone.
- Use explicit prerequisites and one-time purchase records; never infer unlocks from UI visibility.
- Make active skills, passives, movement changes, and tactical roles distinct.
- Balance all unlocks against AP/MP, action economy, range, status duration, and enemy threat.
- Preserve old saves with empty skill-tree defaults.

Do not inflate the 15-skill catalogue by adding superficial variants. Add abilities only when the combat system and UI can support their target rules, animation/readability, and counterplay.

### 3. Traits and personality

The 69 traits, five synergies, 40 event templates and 12 curated ambitions are present on main, with GameState APIs and character-sheet persistence. Templates are not proof of gameplay coverage: behavior evidence has limited external call sites, and the party UI shows an ambition summary but does not provide a complete ambition-assignment workflow.

Next:
- Wire evidence to committed outcomes across battle, quests, dialogue, training, crafting, and exploration; avoid leaving behavior counters as API-only state.
- Add a clear ambition assignment/selection UI, explain objective progress, and expose completion/failure outcomes.
- Keep evidence IDs unique and deduplicated.
- Never infer morality, betrayal, romance, trauma, cowardice, or consent from generic combat heuristics.
- Add a touch-friendly trait journal with acquisition/removal history and explainable effects.
- Complete the objective evidence triggers and completion/failure consequences for the existing 12 ambitions.

### 4. Companion quests and relationships

Main has relationship/personality foundations and several bespoke quest systems, but no generic companion-quest framework. Draft PR #53 contains a large catalogue and location-hook implementation, but it is 62 commits ahead and 25 behind main at the last comparison and overlaps core state, location maps, and tests.

Port this in small slices:
1. Merge the pure quest-state rules and save normalization.
2. Add one complete companion quest from recruitment through journal, milestones, resolution, rewards, and persistent world flags.
3. Verify on device and test old saves.
4. Add remaining companions in batches, distinguishing bespoke minigames/cinematics/bosses from shared investigation interactions.

A catalogue entry without a playable route is not a completed quest.

### 5. World and encounter content

- Give every continent a distinct regional map dataset, biomes, settlements, route graph, encounter tables, local-map coverage, and story gates.
- Integrate regional monsters and human enemy factions only after validating their character IDs, class/weapon references, spawn cells, rewards, and encounter weights.
- Keep boss encounters mechanically distinct; do not reuse a normal enemy stat block with only a larger HP value.
- Add region-to-region travel and save transitions before presenting the atlas as a connected world.

### 6. Trading, governance, and empire systems

Several open branches implement overlapping versions of regional trading, holdings, territory governance, empire economy, and administration. PR #61, #87, and #91 touch overlapping state and UI surfaces; PR #46 is an older, much larger empire branch.

Recommendation: define one canonical realm model before integration:
- territory ownership and contest state;
- treasury, upkeep, taxation, supplies and unrest;
- governors, garrisons, fortification and policy;
- market prices, stock, route risk, tolls, contracts and caravan upgrades.

Use deterministic monthly/turn settlement, explicit transaction logs, and idempotent save operations. Do not merge multiple parallel implementations of treasury, ownership, or regional simulation.

### 7. Five-act campaign and Chronicle

The five-act continuity and founder epilogue branches are stacked on other feature branches, not integrated into main. Preserve these gates:
- Acts unlock only from explicit campaign outcomes.
- The Chronicle cannot unlock simply because Act V's final battle was won.
- The ending must include the authored founder epilogue and the required political resolution, including the ruler's choice to abolish the empire.
- The founder's death must be recorded as natural old age, not a battle, execution, or arbitrary timer.
- Only then should the Chronicle of Houses unlock.

Review the five-act continuity branch before its stacked epilogue branch. Do not merge the epilogue first.

### 8. Art, UI, accessibility, and audio

Current used assets include original KindleWake SVG illustrations, Quaternius CC0 nature renders, and the permitted Free Soldier/Orc subset from Zerie's Tiny RPG Character Asset Pack. The unverified legacy voxel building pack is marked unused and is not a current used-game release blocker. Other optional sprite-pack archives are not runtime assets and must remain unimported until their licences are verified.

Current limitations:
- No bundled audio files or font files are present.
- Only Soldier/Orc character animation strips are included; most of the 28 class identities lack a complete original sprite/portrait/animation set.
- The asset manifest still describes an earlier procedural-placeholder stage and needs to be kept synchronized with runtime usage.
- The UI is largely code-built and needs consistent typography, spacing, focus states, safe-area behavior, touch targets, and accessibility review.

Prioritize gameplay readability over decorative effects. Verify sprite frame sizes, pivot points, orientation, animation timing, and collision footprints before adding more content.

### 9. Release readiness

- Android CI APK export is configured for ARM64 and ARMv7 and the preset disables INTERNET permission.
- Production publishing is a separate protected workflow and requires a production keystore, alias/password, certificate fingerprint, and GitHub Environment approval rules.
- The repository's sideload/test key is not a production signing identity.
- iOS export and device QA are not currently configured.
- Physical Android testing is outstanding. Verify install/update, launch, touch, orientation, safe areas, performance, pause/resume, save/load, Continue and long-session stability.

## Pull-request integration snapshot

PR states and branch divergence change frequently; recheck GitHub before every integration. At the time of this audit (main commit 036a17da88ab1b1037b224334dbfbbdcb392e195):

- PR #100: merged; it executes the campaign restore-to-World lifecycle test in strict CI.
- PR #104 and PR #110: closed as duplicates after their semantic save-recovery and test-isolation changes were incorporated into main.
- PR #80: older save-validation branch; stale and behind main. Do not merge it wholesale.
- PR #42: regional bestiary; draft and substantially diverged.
- PR #53: companion quest framework; draft and substantially diverged.
- PR #61: world/dungeon/holdings expansion; draft and substantially diverged.
- PR #81: regional trading integration; open and behind main.
- PR #83/#88: stacked campaign continuity and founder epilogue; integrate parent first.
- PR #87/#91: overlapping territorial/realm governance implementations; consolidate rather than merge both wholesale.
- PR #99/#101: closed without merge; their personality event/ambition work is not in main.

Commit divergence is a warning about integration cost, not a quality score. Port changes against current main and run exact-head tests.

## Required engineering gates

1. No direct commits to `main`; use focused pull requests.
2. Review every changed file for shared-state and save-schema impacts.
3. Godot 4.2.2 import must complete without unresolved script errors.
4. Run strict regression suite, scene smoke, campaign lifecycle test, deterministic balance report, and Android export on the exact PR head.
5. Review logs, not just green status badges; transient class-registration errors and resource-leak warnings should be tracked.
6. Physical-device QA is a separate release gate.
7. Keep all content offline-first and preserve existing saves.
8. Update this audit, README, asset manifest, and session handoff when implementation status changes.

## Suggested production order

1. Finish save safety and Continue lifecycle validation.
2. Reproduce and diagnose Android issue #36 on device.
3. Consolidate companion quest framework and finish one vertical slice.
4. Integrate regional trade and faction diplomacy.
5. Add playable regional content and connected continent travel.
6. Consolidate governance/holdings/economy into one canonical system.
7. Integrate five-act campaign and Chronicle gates in dependency order.
8. Add class talent trees and balance.
9. Complete audio, typography, original character art, accessibility and performance.
10. Run full Android release QA and prepare production signing.

This is a living audit. Update counts and status only after the relevant system is present on main and passes its required runtime tests.
