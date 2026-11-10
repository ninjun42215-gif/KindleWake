# KindleWake — Expanded World, Kingdoms, Empire & Base44 Web Edition Roadmap

**Status:** Product/architecture proposal. Planning only; no gameplay code or released-version changes are made by this document.
**Reference baseline:** KindleWake v0.12.0, Godot 4.2+, save schema 4, existing fully-offline single-player design.
**New target:** A browser-first edition with optional install/download and a genuinely playable offline mode.
**Creative references:** The scale of recruitment, headquarters growth, political conflict and war from *Suikoden II*; the variety of character-driven activities, world exploration and memorable mini-games from *Final Fantasy VII*. These are design references only. KindleWake must use original characters, plot, maps, art, music, UI, dialogue, mechanics implementation and naming.

---

## 1. Product direction and non-negotiable decisions

KindleWake should become a large single-player fantasy RPG in which a personal party, a growing stronghold, a network of kingdoms and an emerging empire are all parts of one campaign. The player should feel the world becoming larger as their influence grows: first surviving a local conflict, then uniting regions, then deciding the political future of the continent.

The web edition must not sacrifice the existing game's defining qualities:
- Offline-first single-player play; no always-online requirement for core story, battles, saves, mini-games or kingdom simulation.
- Touch-first landscape layout that remains usable on phones, tablets and desktop browsers.
- Local save ownership and multiple save slots; cloud backup is optional and never the only save.
- Existing characters, lore, classes, tactical combat, equipment, runes, loyalty, campaign state and art identity are preserved where suitable.
- Deterministic, data-driven game rules with versioned saves and migration tests.
- Original premium mature fantasy art direction; portraits must match the exact corresponding in-game character sprites. Never invent mismatched portrait identities.
- Do not start a wholesale visual redesign or overwrite current systems before a compatibility inventory and playable prototype exist.

**Important product distinction:** “Runs in a browser”, “can be installed”, “can be downloaded”, and “works with no internet” are four different requirements. The architecture and acceptance tests must treat them separately.

## 2. The world: expansion blueprint

### 2.1 World structure

Build one connected campaign world with:
- 1 main continent containing the primary kingdom and imperial conflict.
- 7 major regional territories, consistent with the existing seven-continent atlas concept only where that geography remains canon after map audit.
- 6–8 sovereign kingdoms or former kingdoms with distinct political structures.
- 1 imperial heartland and its directly controlled provinces.
- 3–5 independent city-states, frontier marches, religious enclaves or trade leagues.
- 2–3 major sea lanes and island chains.
- A frontier belt containing ruins, monster territories, abandoned forts and disputed borderlands.
- A network of roads, rivers, passes, ports, bridges, ferries and mountain routes that make travel choices meaningful.

Do not assume all regions are playable at once. Use a staged unlock model. The first public vertical slice should make one home region and two neighbouring regions genuinely explorable; the larger atlas can appear as an illustrated strategic map with locked/rumoured regions.

### 2.2 Region content standard

Every major region should have:
1. A distinct biome, palette, climate and landmark silhouette.
2. One capital or principal settlement, 2–4 secondary settlements, and rural points of interest.
3. A local ruler or governing faction, power blocs and a conflict that matters to the main story.
4. At least one unique resource or economic specialty.
5. A local recruitment pool and 1–3 character-specific recruit opportunities.
6. A regional quest chain, side quests and a dungeon/ruin/stronghold.
7. A regional traversal hazard or travel mechanic.
8. A mini-game, festival or local activity where it fits naturally.
9. A regional battle map or strategic objective.
10. Persistent consequences when the player changes control, trade, security or alliances.

### 2.3 Proposed regional roster (working names, not final canon)

| Region | Identity | Signature content |
|---|---|---|
| Dunmarrow Heartland | Old royal roads, ruined keeps, fertile valleys | House politics, fortress restoration, early recruitment |
| Brinegate Coast | Ports, salt marshes, storm cliffs, merchant houses | Naval trade, smugglers, fishing, sea caves |
| Orrowen Weald | Ancient forests, druidic remnants, hidden villages | Tracking, herbalism, beast encounters, forest ruins |
| Vessmoor Marches | Floodplains, forts, river crossings | Border skirmishes, supply routes, bridge control |
| Cinderpeak Holds | Mountain mines, forges, volcanic passes | Mining, smithing, siege materials, subterranean dungeon |
| Lythene Crownlands | Rich farmlands, noble estates, royal capital | Court intrigue, taxation, diplomacy, tournament |
| Ashen Reach | Scarred frontier, old battlefields, forbidden ruins | High-risk exploration, relics, veteran recruits |
| Imperial Meridian | Imperial capital, roads, legions, administrative cities | Main imperial arc, espionage, succession and endgame |

Names and geography must be reconciled with current GDD, map JSON and existing Brinegate/Sethmarch content before implementation. Do not duplicate or silently rename existing settlements.

### 2.4 Map layers and navigation

Create three complementary map scales:

**A. Strategic world map**
- Full region/kingdom boundaries, capitals, borders, roads, sea lanes, mountain passes, rivers and major strategic assets.
- Kingdom/faction overlays: controlled, allied, neutral, hostile, contested, occupied.
- Fog of war and rumours: unknown, rumoured, discovered, surveyed.
- Political map changes as wars, treaties and story events occur.
- Filters for political control, trade, danger, resources, quests and army movement.

**B. Regional travel map**
- Connected nodes for towns, villages, camps, dungeons, ruins, shrines, forts and resource sites.
- Roads and terrain routes with travel time, risk, provisions cost and weather.
- Optional detours, ambush chances and discoveries. Random encounters must be authored from a curated encounter pool and respect story state; never randomly block main quests.
- Fast travel unlocks only after discovery and should have a cost or condition when appropriate.

**C. Local exploration maps**
- Hand-authored town districts, interiors, dungeons and battlefield approach maps.
- Distinct landmarks, NPC schedules, doors, hidden routes, interactables and environmental storytelling.
- Reuse modular terrain art, but each location must have its own visual identity and encounter layout.

### 2.5 Exploration mechanics

- Day/night and weather affect visibility, NPC availability, enemy patrols and selected activities.
- Travel uses provisions and a campaign calendar; avoid tedious hunger micromanagement.
- Mounts, ships, ferries, bridges, climbing routes and passes unlock traversal options.
- Scout reports reveal enemy strength, supply routes, secrets and recruit leads.
- Region reputation changes market prices, guards, rumours, access and dialogue.
- Discoveries include ruins, treasure caches, lore tablets, rare materials, monster lairs, hidden recruits and map shortcuts.
- Use a journal with tracked quests, discovered locations, map clues, rumours and completed discoveries.

## 3. Kingdoms, diplomacy and empire-building

### 3.1 Political entities

Represent each political entity as data, not a bespoke script:
- Kingdom, empire, city-state, duchy, clan confederation, religious order, merchant league, rebel movement or independent fortress.
- Ruler, heir/succession state, government form, capital, territory, treasury, food stores, manpower, army strength, stability, legitimacy, culture, laws, diplomatic posture and active conflicts.
- Named nobles, commanders, envoys, merchants and faction leaders.
- Relations with other entities and with the player-led faction.
- Public goals and hidden agendas, revealed through espionage or story.

### 3.2 Core kingdom statistics

Use a small readable set with clear cause and effect:
- **Legitimacy:** accepted right to rule; influenced by lineage, victories, treaties, laws and public decisions.
- **Stability:** unrest, faction tension, crime and rebellion risk.
- **Treasury:** gold income, expenses, debt and reserves.
- **Food:** harvest, storage, consumption and siege resilience.
- **Manpower:** available recruits and population burden; replenishes slowly.
- **Infrastructure:** roads, ports, farms, mines, walls and administrative capacity.
- **Military readiness:** trained troops, equipment, morale and supply.
- **Influence:** diplomatic reach, noble support and ability to negotiate.
- **Knowledge/intelligence:** maps, reports, spies and technology/research where supported.

Avoid dozens of meaningless meters. Every number must drive a decision and be visible in the ledger.

### 3.3 Player progression from survivor to ruler

1. **Exile/House restoration:** secure Kaer Sethorn, protect nearby settlements, gather loyal companions.
2. **Regional protector:** clear threats, repair roads/bridges, negotiate local support and gain a recognised charter.
3. **Coalition leader:** unite houses, towns and smaller factions through diplomacy, shared enemies, quests or military victories.
4. **Kingmaker / sovereign:** decide who should rule a weakened kingdom or claim a crown under credible story conditions.
5. **Empire founder or reformer:** build a new political union, inherit/replace the empire, or prevent imperial collapse.
6. **Legacy/endgame:** determine succession, laws, regional autonomy and the political order left behind.

Do not force a single “become emperor” ending. Support multiple coherent outcomes: restore a kingdom, lead a federation, establish a reformed empire, back a legitimate successor, or break imperial rule into independent states.

### 3.4 Diplomacy

Actions should have prerequisites, costs, risks and consequences:
- Envoys, formal audiences, negotiations and councils.
- Non-aggression pacts, defensive alliances, trade agreements, passage rights, mutual defence, vassalage, protectorates and confederation.
- Hostage/exchange or prisoner diplomacy only if the story tone and consent-sensitive writing support it.
- Marriage diplomacy only if a full relationship/romance design is approved; do not add it as a shallow stat transaction.
- Tribute, reparations, debt relief, food aid and reconstruction support.
- Border arbitration, succession claims and settlement of disputed territories.
- Reputation and treaty reliability matter; breaking agreements damages trust and future negotiations.
- Diplomacy checks consider character skills, traits, evidence, faction goals, leverage, public opinion and current power balance. No single charisma roll should override the political situation.

### 3.5 Kingdom management and governance

A kingdom council should include original named characters recruited through the campaign:
- Marshal: army training, readiness, garrisons and battlefield doctrine.
- Steward: treasury, taxes, upkeep and construction.
- Spymaster: intelligence, counter-espionage and rumours.
- Chancellor/Diplomat: treaties, envoys and faction relations.
- Quartermaster: food, equipment, logistics and supply.
- Master Builder: fortifications, roads, facilities and projects.
- Scholar/Archivist: research, maps, lore and special projects.

Council members must have meaningful traits, relationships, loyalty, strengths and conflicts. Assigning a poor fit can create consequences; no character should become a faceless +5% bonus slot.

Governance decisions:
- Tax levels and exemptions.
- Food reserves and relief.
- Garrison distribution.
- Infrastructure projects.
- Recruitment and training policy.
- Law, justice and anti-corruption.
- Trade access and tariffs.
- Treatment of conquered territories and local autonomy.
- Refugee support and rebuilding after war.

Each policy changes some combination of revenue, stability, legitimacy, loyalty, regional relations and long-term risk. Provide clear previews and a confirmation step for irreversible high-impact decisions.

### 3.6 War and territory control

Retain the existing small-scale tactical battle system and platoon/army layer. Expand them rather than replacing them:
- Army map with movement, zones of control, terrain, roads, rivers, passes, forts and supply lines.
- Troop formations and platoons with roles, commanders, morale, experience, equipment and cohesion.
- Food/supply and fatigue; armies cut off from supply lose readiness and may desert.
- Siege preparation, blockade, assault, relief force, surrender negotiation and post-siege reconstruction.
- Strategic objectives: hold bridge, protect convoy, capture fort, escort refugees, break siege, secure pass, seize supply depot.
- Battlefield consequences persist: damaged bridges, depleted garrisons, destroyed farms, rescued civilians, captured officers.
- Named characters can command units, lead squads or participate in tactical combat. Protect character identity and avoid replacing the cast with generic army tokens.
- Player commands and tactical decisions take priority over personality AI. Traits influence preferences and morale, not hard-lock player control.

### 3.7 Stronghold and capital evolution

Kaer Sethorn becomes a visible evolving hub:
- Ruined refuge → fortified keep → regional headquarters → coalition capital → royal/imperial seat (depending on story route).
- New districts: barracks, infirmary, training yard, forge, market, archive, council chamber, embassy, stable, harbour/shipyard if geographically justified, gardens, festival square, intelligence office and memorial.
- Every building has an actual gameplay function, named staff, visual upgrade and quest/recruitment hook.
- Recruitable characters populate the stronghold and change dialogue, services, scenes and ambient activity.
- Facilities unlock through story, materials, gold, skilled recruits and political permissions; do not let money alone bypass major narrative milestones.

## 4. Characters, recruitment and relationships

The recruitment experience should evoke the joy of assembling a memorable large cast without copying another game's cast, exact recruitment checklist or story structure.

- Long-term target: up to 108 meaningful recruitable characters if the final narrative and production budget can support them. This is a target, not a launch requirement.
- Every recruit needs identity, sprite, matching portrait, class/role, combat function, personality traits, voice/text style, recruitment arc, personal quest, relationship hooks and at least one strong reason to remember them.
- Characters should not all be mandatory. Some are mutually exclusive or route-specific, with clear warnings before irreversible decisions.
- Recruitment conditions may involve rescue, persuasion, proof, quest completion, faction standing, skill demonstrations, gifts, tournament performance, or a consequential story choice.
- Avoid obscure missable requirements without clues. Put leads in rumours, journals, NPC dialogue and scout reports.
- A recruited character must have an ongoing use: combat, council, facilities, mini-games, crafting, intelligence, training, diplomacy, or personal story.
- Preserve the existing trait/personality system design: contextual trait acquisition, stress, memories, ambitions, relationships and behavior evidence. Keep temporary conditions separate.
- Relationship model should distinguish loyalty, trust, respect and affinity where justified. Keep romance optional and only implement after its narrative scope is approved.
- Character death, injury, departure and reconciliation must follow authored rules; never kill or permanently remove a recruit through a hidden random roll.

## 5. Core RPG and combat mechanics

### 5.1 Character progression
- Preserve existing attributes, class paths, weapon mastery, skills, runes, equipment, experience and AP systems where compatible.
- Add character build specialisations with meaningful trade-offs rather than endless flat stat inflation.
- Add weapon techniques, passive talents, combo links, tactical roles and limited cross-class learning.
- Keep individual character identities stronger than generic class optimisation.
- Skill upgrades should be earned through use, trainers, story milestones or rare manuals; avoid grind-only progression.

### 5.2 Combat modes
- **Tactical party combat:** retain the current CTB/grid foundation and deepen terrain, facing, elevation, cover, status, interrupts, combos and environmental interactions.
- **Army/platoon battles:** strategic positioning and command decisions, with named commanders and unit identities.
- **Duel/boss encounters:** special authored rules, readable telegraphs, phase changes, interactive terrain and character-specific counters.
- **Non-combat resolutions:** diplomacy, stealth, rescue, sabotage, negotiation or escape where the story supports it.

### 5.3 Battle aftermath
- Rewards include gold, materials, provisions, renown, intelligence, recruits and political leverage.
- Casualties, injuries, fatigue, morale and loyalty have clear rules and recovery paths.
- Avoid punishing players twice for a single failure. Provide difficulty/accessibility options and clear battle forecasts.
- Major victories/losses should create memories, ambitions and relationship changes through authored event IDs.

## 6. Story-connected mini-games

Mini-games must feel like activities that belong in this world, not unrelated arcade distractions. They should be short, replayable, touch-friendly and connected to character stories or regional culture. All are original implementations, not copies of FF7 mini-games.

### Launch candidates

| Mini-game | Core loop | Story/gameplay connection |
|---|---|---|
| Frontier Skirmish Table | Small turn-based tactical puzzle on a miniature map | Teaches army tactics; rewards command manuals and council reputation |
| Beast Run | Mount/beast racing with stamina, terrain lanes and hazards | Stable upgrades, mount recruits, regional festivals |
| Harbor Angling | Timing, bait choice, fish behaviour and location knowledge | Food, rare crafting materials, local stories and character bonding |
| Forge Trial | Heat, rhythm and material sequencing | Weapon quality, smith recruitment and crafting mastery |
| Merchant's Ledger | Buy/sell negotiation under changing supply and demand | Trade knowledge, regional economy and merchant relationships |
| Archery Range | Wind, distance, moving targets and limited arrows | Ranged skill training, tournament prizes and recruit trials |
| Ruin Delver | Short tile/route puzzle with traps, clues and resource limits | Exploration, lore fragments, relics and map discoveries |
| Commander's Gambit | Compact tactical board puzzle with asymmetric units | Recruitment, war council scenes and strategic rewards |
| Festival Games | Rotating original local contests (strength, memory, aim, cooking) | Town reputation, companion scenes, unique cosmetics/items |
| Campfire Stories | Character-choice and memory activity, not a reflex game | Relationship development, lore and stress recovery |
| Courier Route | Plan a route with time, weather and interception risks | Intelligence, supply, faction reputation and world map knowledge |
| Monster Tracking | Read tracks, wind and habitat clues to locate a target | Monster research, rare materials and hunter recruitment |

### Design rules for mini-games
- Start with 3 polished activities, not 12 unfinished ones. Recommended vertical-slice trio: Archery Range, Harbor Angling and Commander's Gambit.
- Each activity needs a tutorial, clear controls, pause/exit, accessibility options and a fair retry loop.
- Rewards should be useful but not mandatory for main-story completion.
- Skill should matter more than random luck; use deterministic seeded rules for replay and testing.
- Companions can participate with distinct strengths, banter, rivalry and rewards.
- Higher ranks should unlock through story, facility upgrades, regional festivals or character recruitment.
- Avoid real-money gambling, loot-box mechanics, casino framing or pay-to-win rewards.
- Store high scores and unlocked challenges locally. Cloud leaderboard is optional and must never gate offline content.

## 7. Base44 web-first architecture and offline/download strategy

### 7.1 Platform reality and risk

Base44 provides a managed web-app platform with hosting, authentication, data functionality, file storage, integrations and a developer SDK/CLI. Its official developer materials describe deployment and managed backend capabilities: https://base44.com/developers and https://github.com/base44/cli.

However, the current Godot baseline is explicitly fully offline and does not use accounts, servers or an INTERNET permission. A Base44 app that depends on its hosted database, auth or server functions cannot be assumed to run fully offline merely because the browser shell is cached. Exporting source code is not the same as exporting an independent backend.

**Architecture recommendation:** use Base44 for rapid web UI scaffolding, hosted publishing, optional accounts/cloud backup and content administration, but make the actual single-player game engine client-side and local-first. Put all core rules and campaign state behind a platform-neutral game-domain layer. Keep Base44 SDK calls in optional adapters, never inside battle, quest, save or kingdom rules.

### 7.2 Proposed layers

1. **Presentation layer:** responsive React/TypeScript web UI, landscape-first but responsive, keyboard/gamepad/touch input, accessible menus and scalable UI.
2. **Game domain layer:** pure deterministic modules for combat, character progression, inventory, quests, map travel, diplomacy, economy, kingdom simulation, army movement and mini-games. No direct network calls.
3. **Content layer:** versioned JSON/typed data for characters, traits, regions, settlements, quests, factions, buildings, laws, events, battles, mini-games, items and dialogue.
4. **Local persistence layer:** IndexedDB for campaign state, saves, content cache, options, unlocks and mini-game records. Use explicit schema migrations, checksums and recovery backups.
5. **Offline shell:** PWA manifest, service worker, cached application shell, fonts, UI, core game code and selected content/assets. Provide an offline-ready indicator and update management.
6. **Optional cloud adapter:** Base44 auth/database/storage for opt-in account sync, cloud backup and cross-device transfer. Conflict resolution must be explicit; local save remains authoritative until sync succeeds.
7. **Packaging layer:** installable PWA as the first download/install option. Later evaluate Android/iOS wrappers (e.g. Capacitor) and desktop packaging only after offline acceptance tests pass.

### 7.3 Offline requirements

The following must work with airplane mode enabled after the game has been installed and its required content downloaded:
- Launch to title screen.
- New Game, Continue, load/save/delete slots.
- World map, region exploration, towns, dungeons and travel.
- Combat, army battles, kingdom simulation and diplomacy.
- Recruitment, character sheets, inventory, equipment, runes, quests and dialogue.
- All core mini-games and their local records.
- Audio and visual assets needed by the selected offline campaign pack.
- Settings, accessibility and save export/import.

The following may require connectivity but must remain optional:
- Account login.
- Cloud save backup/sync.
- Online news/announcements.
- Community features or leaderboards if ever approved.
- Remote analytics/telemetry (prefer no analytics by default).

### 7.4 Download and install terminology

Provide clear options:
- **Play in Browser:** opens hosted web edition.
- **Install KindleWake:** installs the PWA to the home screen/desktop where supported.
- **Download Offline Pack:** downloads optional regional content/assets for offline play, with size and storage information.
- **Export Save:** downloads the player's save archive.
- **Download Standalone Build (future):** only advertise when a tested Android APK/desktop package is genuinely produced and runs without the Base44 hosted backend.

Do not label a browser shortcut as an APK or a source ZIP as a playable standalone game.

### 7.5 Base44 proof-of-capability spike (must happen before full port)

Build a throwaway/prototype slice and test:
1. Does Base44 allow the needed custom React/TypeScript structure and client-side modules?
2. Can a service worker be registered and controlled in the deployed app under the actual hosting configuration?
3. Can the app shell and a small content pack load and run in airplane mode after first install?
4. Can IndexedDB saves be created, migrated, backed up and restored with no network?
5. Does Base44 routing, auth or SDK initialization block app startup when offline?
6. Can a player skip login and start a local campaign?
7. What does Base44 source export include, and which functions still require Base44's backend?
8. What plan tier and credits are required for GitHub sync, export, custom domain and any mobile packaging?
9. Can the app be packaged outside Base44 without proprietary backend dependencies?
10. Does the result pass on Android Chrome and at least one desktop browser?

**Go/no-go:** if the Base44-hosted runtime prevents a reliable offline-first PWA or requires hosted services for core game state, keep Base44 as a prototype/content tool and deploy the exported client through independent static hosting with a separate optional backend. Do not compromise offline play to force a platform fit.

## 8. Data model and save architecture

Define stable IDs and versioned schemas for:
- Character, class, skill, trait, relationship, memory, ambition, equipment, rune and inventory.
- Region, map node, route, settlement, dungeon, discovery and resource node.
- Faction, kingdom, ruler, treaty, diplomatic relation, territory, law and council appointment.
- Army, platoon, commander, unit, supply route, siege and battle outcome.
- Quest, objective, choice, story flag, event, dialogue and journal entry.
- Building, facility, construction project, staff assignment and stronghold upgrade.
- Mini-game definition, challenge, result, record and reward.
- Save metadata, content version, schema version, platform metadata and sync status.

Rules:
- Stable IDs; never use display names as keys.
- Save player choices and outcomes, not copies of static content definitions.
- Version all content packs and save schemas independently.
- Migrations must be additive where possible, tested against representative old saves.
- Save at safe checkpoints and after major decisions; allow manual saves in safe locations.
- Keep rotating local backups and a user-accessible export/import format.
- Cloud sync must handle conflicts with a compare/choose flow; never silently overwrite a newer local campaign.

## 9. UI and presentation

The web edition should feel like a premium fantasy RPG, not a generic dashboard:
- Main navigation: Continue, World, Company, Stronghold, Kingdom, Journal, Activities, Codex, Settings.
- World map gets the largest visual canvas; overlays and detail panels remain readable on phone.
- Kingdom screen: map + ruler/council + ledger + diplomacy + laws + military + projects.
- Stronghold: visual explorable hub with building hotspots and named residents.
- Character profile: exact sprite-matched portrait, class, level, equipment, runes, traits, relationships, memories, ambitions and personal quest.
- Mini-games open in focused, distraction-free play surfaces with a clear return route.
- Use restrained bronze/gold, charcoal, parchment and region-specific accents; preserve text contrast and touch targets.
- Avoid tiny desktop-style tables on mobile. Use stacked cards, map overlays and collapsible ledgers.
- Every screen must have a clear back/close route, loading/error state and offline state.

## 10. Production roadmap and gates

### Phase 0 — Canon and technical audit
- Reconcile current GDD, atlas, world map JSON, existing settlements, campaign flags, saves and existing combat/army systems.
- Decide what remains canon and what is expanded.
- Inventory art licences and verify all portrait/sprite identity mappings.
- Produce a map graph and kingdom/faction relationship diagram.
- Confirm Base44 plan/feature availability and run the offline proof-of-capability spike.
**Exit:** signed-off world bible, data model and platform go/no-go report.

### Phase 1 — World map vertical slice
- Expand one connected region cluster with 3 regions, 1 capital, 5–7 settlements, 2 dungeons, 1 port and 1 major road/river route.
- Implement strategic and regional map layers, fog/discovery, travel costs, journal and persistent region flags.
- Keep the existing campaign and saves working.
**Exit:** player can travel, discover, quest, fight, save and resume fully offline.

### Phase 2 — Stronghold and first kingdom systems
- Expand Kaer Sethorn facilities and council roles.
- Implement one neighbouring kingdom with ruler, factions, legitimacy, stability, treasury, food and diplomacy.
- Add one treaty path, one conflict path and one local governance decision.
**Exit:** decisions visibly change faction relations, stronghold, resources and story state.

### Phase 3 — War and territory
- Connect army/platoon layer to the strategic map.
- Implement supply, army movement, forts, one siege and persistent battle consequences.
- Capture/release/restore one territory with a clear political aftermath.
**Exit:** one complete regional campaign with strategic and tactical battles.

### Phase 4 — Mini-game trio
- Implement Archery Range, Harbor Angling and Commander's Gambit.
- Add companion participation, local records, tutorial, rewards and quest hooks.
**Exit:** three polished activities on phone and desktop, playable offline.

### Phase 5 — Coalition and empire
- Expand to 4–5 political entities, council governance, diplomacy, multiple endings and a larger recruitment arc.
- Add regional autonomy, succession/legitimacy and imperial reform/conquest paths.
**Exit:** the player can complete a coherent kingdom/empire story route.

### Phase 6 — Full continent and content scale
- Expand toward 7 major territories, 6–8 kingdoms, independent factions, sea routes and late-game regions.
- Scale recruitable cast toward 108 only if every recruit meets the quality bar.
- Add remaining mini-games selectively.
**Exit:** complete campaign content, tested performance and stable save migrations.

### Phase 7 — Release packaging
- Browser release, PWA installation, offline content packs, save export/import.
- Optional Android wrapper/standalone package after independent offline verification.
- Accessibility, performance, security, storage and recovery QA.
**Exit:** release checklist passes on real Android devices and desktop browsers.

## 11. Quality gates and acceptance criteria

- No regression in existing saves or campaign progression.
- No mandatory network calls in core gameplay; airplane-mode test passes.
- World map routes are connected and navigable; no softlocks or unreachable quest targets.
- Kingdom simulation has understandable inputs/outputs and no runaway resource inflation.
- Diplomacy choices are readable and consequences persist.
- Army supply, morale and territory state reconcile after save/load.
- Every recruit has a unique identity and a valid matching sprite/portrait pair.
- Mini-games have tutorials, deterministic tests, pause/exit and fair rewards.
- Responsive layouts pass phone, tablet and desktop sizes; test touch and keyboard/gamepad.
- Asset licensing and provenance are recorded.
- Automated unit tests, content validation, save migration tests, scene/screen smoke tests and balance simulations pass.
- Real-device offline test is required; browser desktop tests alone are insufficient.
- Do not change the released version or save schema until implementation and migration tests justify it.

## 12. Immediate next actions

1. Do not start building all kingdoms at once. First complete Phase 0.
2. Audit current world-map data and list existing playable regions, settlements, routes and locked atlas regions.
3. Draw a world political map with the 6–8 kingdoms and imperial territory.
4. Build a small Base44 offline proof-of-capability prototype before moving game logic.
5. Select the first three-region vertical slice and its first kingdom conflict.
6. Only then write the full Base44 implementation prompt and begin porting in small tested milestones.

**Current scope note:** This document is a roadmap, not a claim that these features are implemented. The existing Godot game remains the authoritative playable baseline until a web edition passes the offline and save-compatibility gates.
