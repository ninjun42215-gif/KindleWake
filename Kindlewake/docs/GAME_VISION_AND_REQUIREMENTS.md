# KindleWake — Intended Game Vision and Requirements
## Product direction, player requests and implementation acceptance criteria

**Status:** Consolidated target design. Requirements below are not all implemented. Check `CURRENT_GAME_STATE_AND_GAP_ANALYSIS.md` and live source before claiming completion.

---

## 1. Product identity

KindleWake: The Sundered Vow is an offline-first medieval fantasy tactical RPG for mobile, built in Godot. The player leads the last heir of House Dunmarrow and a growing company through a character-driven campaign, rebuilds Kaer Sethorn, recruits a broad cast, explores a multi-continent world and makes choices that alter relationships, politics and territory.

### Player experience goals
- Become attached to a distinct company of characters, not anonymous units.
- Make tactical decisions where terrain, positioning, class, equipment, runes and enemy behaviour matter.
- Explore a coherent world with memorable territories, settlements, dungeons, factions and regional threats.
- See the home keep and political map change because of decisions.
- Have choices remembered and acknowledged by companions and the world.
- Enjoy meaningful depth without online requirements, manipulative timers or mandatory grinding.

### Scope targets in the existing GDD
The GDD describes a 25–35 hour core campaign and New Game+ as long-term targets. The former optional Legacy Mode toggle is superseded: the Chronicle of Houses is a separate post-campaign system available only after the designated Last Emperor → formal dissolution → late-life epilogue → natural old-age death sequence. These are targets, not current content claims.

## 2. World and campaign

- Maintain seven named continents: Eldrimar, Thalassar, Varakhan, Nhalor, Veyrwood, Asterreach and Ilyr.
- Each continent needs its own political identity, climate, ecology, cultures, named territories, settlements, dungeons, routes, signature threats and story arc.
- The global atlas must distinguish inspectable/story-locked continents from regions the player can actually enter.
- Regional maps should feel authored and geographically connected. Keep roads, gates, settlements, dungeons and travel unlocks consistent.
- Campaign progression should move from the prologue and Eldrimar into other continents through story-earned routes, not arbitrary menu teleportation.
- Preserve the original world canon and current map data. New content must extend it rather than replace it.

## 3. Story and meaningful choices

The prologue and five-act structure in `LORE_BIBLE.md` is the narrative target. Each chapter should include a personal problem, investigation, tactical operation, consequential choice, aftermath and new question.

Every major decision should affect at least two of:
- companion relationship or loyalty;
- faction/house reputation;
- resources or keep facilities;
- future mission modifier or access;
- recruitment or personal quest;
- journal/chronicle and epilogue tags.

The player must understand the immediate stakes. Later scenes should acknowledge outcomes. Do not create fake branches that all resolve identically without acknowledgement, and do not soft-lock the main story because of an optional choice.

### Journal and chronicle
The intended campaign should have a persistent journal with:
- main objectives, optional leads and completed entries;
- decision records and their immediate consequences;
- discovered lore, people, factions, territories and bestiary entries;
- a clear “continue next” marker;
- a short recap after a long break;
- an end-of-campaign chronicle reflecting companions, losses, alliances, territories and decisions.

Do not claim a full persistent journal or recap system exists unless verified in current source.

## 4. Company, characters and CK-style traits

The company should feel like a living social group with personality, bonds, rivalries and changing circumstances.

### Character dossiers
Each recruit should have:
- name, origin, faction/territory and recruitment route;
- class, combat role, stats and growth;
- surface want, private need, wound and contradiction;
- personality/voice rules and dialogue portrait/expression;
- relationships, loyalty and personal quest;
- signature skills, equipment preferences and battle barks;
- keep contribution and ending/resolution state.

Portraits must match the same character identity and visual design as the corresponding in-game sprite. Do not use unrelated stock portraits or a different face/armour identity between portrait and sprite. Maintain consistent proportions, palette, clothing, hair, weapon and recognizable silhouette.

### Trait system — requested feature
Implement a broad Crusader Kings-style character trait system, adapted to a tactical RPG. Traits can be acquired and removed through authored events, choices, training, relationships, battles, injuries, discoveries and life events. Include both positive and negative traits, with some neutral, situational, inherited, rare, unique or hidden traits where appropriate.

Trait categories should include:
- personality and temperament;
- virtues, flaws and habits;
- leadership and command;
- combat talent and technique;
- wounds, scars, illness and recovery (respect existing content and tone);
- education, profession and expertise;
- social standing, reputation and relationships;
- faith, conviction and worldview;
- fears, trauma and resilience;
- survival, exploration and regional adaptation;
- supernatural exposure and oath-related marks;
- legacy, bloodline and inherited qualities.

Trait behaviour requirements:
- Each trait needs an ID, name, category, rarity, description, acquisition rules, removal rules, effects and stacking/exclusion rules.
- Effects should be bounded and understandable: stats, skill modifiers, morale, loyalty, dialogue tags, recruitment checks, faction interactions, event options or AI tendencies.
- Traits should not be only stat bonuses. Use them to create distinct dialogue and event opportunities.
- Positive traits should have trade-offs or contextual limits where sensible; negative traits should be playable and potentially manageable, not a punishment spiral.
- Traits may conflict (e.g. patient/impulsive) or form progressions (e.g. green recruit → seasoned veteran), but avoid arbitrary random churn.
- Rare/unique traits must have clear provenance and protection against duplication.
- Acquisition/removal must be explicit and testable. Do not remove a trait silently.
- Save old campaigns safely with default empty trait collections and migration tests if persistence is introduced.
- Provide a readable character-sheet panel showing trait name, icon, category, description and actual gameplay effects.

### Relationships and loyalty
- Loyalty is not a single hidden desertion trigger. It should be visible and contextual.
- Relationships between named pairs should change through authored interactions, shared missions, disagreements, rescue, rivalry and personal quests.
- Betrayal, departure and reconciliation must be foreshadowed and offer player agency.

## 5. Tactical battles and enemy variety

Retain the existing tactical combat architecture and improve it rather than creating a parallel battle system.

### Battlefield variety
- Expand terrain-specific battlefield layouts: forests, marshes, rivers, bridges, ruins, hills, snow, coastal docks, ship decks, caves, keeps and settlement streets.
- Terrain must change movement, cover, visibility, hazards, height, line of sight or objectives—not just appearance.
- Build encounters around meaningful objectives: rescue, escort, hold, seize, defend, escape, sabotage, survive, disable an enemy device or defeat a commander.
- Keep objective markers and tactical previews readable on mobile.

### Enemy and monster expansion — requested feature
Add a wide variety of story- and territory-related enemies and monsters. Use the bestiary directions in `LORE_BIBLE.md`, but check the existing enemy data first to avoid duplicates.

Each territory should have a coherent encounter roster with:
- common enemies, elite variants, ranged/support/control roles and one or more signature threats;
- human faction units with distinct equipment, heraldry, tactics and motivations;
- local wildlife and supernatural creatures that fit the ecology and story;
- dungeon-specific guardians, minibosses and bosses;
- encounter formations that combine roles intelligently;
- region-appropriate loot, crafting materials, lore clues and recruitment opportunities.

Enemy roster should not be a single large list of stat reskins. Distinguish silhouettes, animations, movement, resistances, weaknesses, attack patterns, status effects and AI priorities. Bosses need telegraphed phases/mechanics and a tactical objective beyond inflated HP.

### Battle rewards and progression
- Preserve the existing EXP/AP/Sigil/rune progression rules unless an approved balance change is made.
- Reward optional encounters with mastery, lore, materials, alternate tactics and character development; do not require repetitive grinding.
- Maintain balance simulations and regression tests for new enemies, skills and rewards.

## 6. Character progression, classes, equipment, runes and sigils

- Preserve the existing class tree and class-specific identity. Promotion should have meaningful requirements and keep learned skills where designed.
- Character level cap target/current documented baseline is 250; verify code before changing.
- Expand character growth and traits without replacing stats, class growth or existing skills.
- Equipment should be meaningful, readable and regionally appropriate. The existing GDD describes an equipment enhancement ceiling of +15; verify live implementation before relying on it.
- Preserve rune and sigil systems. Existing documentation records 77 runes and 11 sigils; verify current JSON before adding duplicates.
- Rune types include passive, active, support, stat, unique and heirloom forms. Unique/heirloom protection, fusion chance, mastery and specialist removal/vendor rules must remain coherent with the existing system.
- Rune removal is an intentional service action (blacksmith or magic rune shop), not a free arbitrary toggle if that remains the implemented design.
- Fusion and upgrades must be tested for probability, costs, duplication and save compatibility.

## 7. Factions, diplomacy and territorial control

The world should develop from a set of territories and factions into a political campaign.

Target features:
- authored faction identities, leaders, goals, resources, rivalries and relationships;
- region ownership/claim, contested status, occupation and liberation;
- relations, treaties, trade, non-aggression, alliances and war;
- story-authored diplomacy choices with visible costs and consequences;
- faction missions, recruitment, supply routes and territory operations;
- strategic battles that connect to the tactical battle system;
- a readable faction/territory dossier and map overlays;
- historical record of important treaties, wars and territory transfers.

Do not add random wars, coups or territory flips without narrative cause. Keep the backend bounded and data-driven. A foundation system does not mean the player-facing diplomacy UI or full strategic war layer is complete.

## 8. Kaer Sethorn and headquarters development

The keep should visibly evolve through facilities, people and story:
- infirmary: recovery, treatment and relevant trait/wound stories;
- barracks: training, platoon organisation and recruitment support;
- storehouse: provisions and material capacity;
- forge/blacksmith: equipment, upgrades and rune services;
- library/archive: lore, research and codex access;
- war room: missions, maps, faction dossiers and strategic operations;
- recruitment/muster hall: recruit scenes and roster access;
- memorial: remember fallen or departed companions and reflect campaign choices.

Facilities should have distinct costs, unlock conditions, practical effects, upgrade states and visible environmental changes. These are design targets; audit current facilities before building duplicates.

## 9. Mini-games and story activities

Use short, story-linked activities inspired at a high level by classic RPG variety (for example, tactical training, scouting, lock/ruin puzzles, convoy management, archery trials, ship navigation, crafting or social investigation). Every mini-game must:
- be optional or clearly motivated by the story;
- have a meaningful result (clue, resource, relationship, trait, tactical advantage or access);
- be playable with touch controls and have a non-precision alternative;
- avoid feeling like a disconnected arcade mode;
- be original in rules, visuals and presentation.

Do not copy specific mini-games, layouts or assets from other games.

## 10. UI, visual and audio direction

- Premium, coherent medieval presentation; consistent typography, spacing, alignment and responsive layout.
- Mobile-first touch controls with large targets, safe areas, readable text and no clipped panels.
- Distinct title, creator, world, battle, company, character, equipment, rune, shop, journal and faction experiences.
- Character portraits must match gameplay sprite identity.
- Enemies need clear silhouettes and readable faction/creature identity.
- Use original or licence-cleared assets only. Record asset provenance.
- Atmosphere (weather, fog, embers, water shimmer, dust, torchlight) must not obscure tactical information.
- Audio direction: original faction motifs, adaptive exploration/battle/aftermath layers, readable UI feedback, meaningful silence, independent volume controls and reduced-flash options.

## 11. Technical and save requirements

- Godot 4.2+ GDScript; GL Compatibility; offline-first.
- No online accounts, servers, multiplayer, telemetry or required INTERNET permission.
- Reuse existing autoloads, JSON definitions, save/load and combat rules.
- Preserve current saves and migration paths. Any new persistent trait, relationship, journal, faction, facility or region field must default safely for old saves and have migration tests.
- Keep test coverage for data integrity, combat, save/load, scene smoke loading, balance and platform export.
- No feature should be described as complete solely because data structures or UI mockups exist.

## 12. Priority sequence

1. Audit live source and reconcile this document against existing implementation.
2. Fix and verify core story continuity, save/load and current playable region.
3. Deliver the opening-hour experience with journal, aftermath and first keep decision.
4. Complete company dossier, relationship and trait systems as a coherent playable loop.
5. Expand enemy rosters and terrain encounters by territory, starting with currently playable regions.
6. Connect faction backend to authored story outcomes and deliver a usable faction dossier.
7. Expand headquarters facilities and regional content.
8. Add more playable territories/continents through complete vertical slices.
9. Add story-linked mini-games only where they support a chapter or character.
10. Complete Android device QA, asset licensing and release readiness.

## 13. Definition of done for every feature

A feature is done only when:
- it exists in runtime code and real game flow;
- its data is validated and content is authored;
- UI is usable on supported mobile aspect ratios;
- saves remain compatible;
- strict tests and scene smoke tests pass;
- balance is checked when relevant;
- no placeholder or fake success path remains;
- documentation records exact implementation status and limitations.


## Additional game-bible requirements

The mechanics are documented across [MECHANICS_BIBLE.md](MECHANICS_BIBLE.md), [GDD.md](GDD.md) and [GAME_BIBLES_INDEX.md](GAME_BIBLES_INDEX.md). Base44 must preserve and build on the documented tactical grid/CTB combat, shared CombatCalc rules, terrain/weather/status/morale/fatigue, character levels/classes/skills/equipment, EXP/AP/Sigil/rune systems, recruitment, platoons, army-battle design, Kaer Sethorn facilities, campaign calendar/economy and offline save architecture. The requested CK-style traits, broader human/monster bestiary, full kingdom/empire management, council appointments, strategic wars/sieges and named mini-games remain targets until confirmed in live code.

The [Premium Production Bible](PREMIUM_PRODUCTION_BIBLE.md) is part of the required design package, not optional inspiration. It governs emotional quality, story delivery, art direction, audio, mobile UX, asset licensing and release guardrails. The [Master Game Bibles Index](GAME_BIBLES_INDEX.md) defines reading order and status labels.


## 14. Post-ending dynasty campaign — explicit owner requirement

The family/dynasty simulation is **not part of the main campaign**. It unlocks only after the player completes the designated true-ending route, is formally invested as Last Emperor under the dormant imperial charter, abolishes the imperial office and central claim, establishes the Concord of Free Realms, completes the late-life epilogue and the protagonist dies naturally of old age. This is a hard progression gate, not an optional early-game toggle.

After that death, control passes to an eligible descendant or lawful chosen successor. The player then continues the Chronicle of Houses across generations, inspired at a high level by the character-life-cycle and inheritance depth of Knights of Ages while using original KindleWake lore and rules.

Required scope:
- family tree, spouses, children, siblings, guardians, adoption and cadet branches;
- character aging, education, traits, skills, injuries, retirement and natural death;
- inherited and learned traits with individual variation;
- noble ranks including Knight/Dame, Baron/Baroness, Viscount, Count/Earl, Marquess, Duke and culturally specific higher offices;
- title and land grants, domain management, house treasury, food, stability, taxes, justice, infrastructure and defence;
- marriage alliances, faction reputation, house prestige, legitimacy and local trust;
- succession laws, inheritance previews, contested claims and meaningful roles for younger children;
- wars, sieges, tactical battles, ransom, capture, memorials and generational chronicle;
- a flexible political order after the Empire's abolition; no ordinary restoration of the Emperor title. The old Eldrimar Empire was historically fragmented before the opening; Osric IV is King of the Crownlands, and the imperial office is dormant until the one-time endgame settlement.

The first generational release should be deliberately smaller than the full vision: unlock gate + founder chronicle, family tree, aging, one household, one barony, one succession law and a complete save/load loop. Expand only after that vertical slice is stable.

Do not claim any of this is implemented until verified in Godot source, data, UI, tests and saves. Preserve offline play and the original campaign save; generational state must be separately versioned and linked to the ending record.
