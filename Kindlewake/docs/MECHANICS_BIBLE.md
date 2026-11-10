# KindleWake — Game Mechanics Bible
## Systems, rules, progression and implementation contracts

**Role:** The consolidated mechanics reference for Base44 and future developers.  
**Primary detailed source:** [GDD.md](GDD.md), especially sections 2–10, 15–17 and the later implementation appendices. This bible is an index and system-level contract, not a replacement for the detailed formulas and revision history in the GDD.  
**Status language:** “Documented baseline” means recorded in the GDD/handoff and must still be confirmed in current code. “Target” means requested/designed, not necessarily playable.

---

## 1. The complete game loop

The intended macro loop connects four scales:

1. **Company/home:** manage the roster, companions, classes, equipment, runes, traits, platoons, facilities, training and supplies at Kaer Sethorn.
2. **Campaign/world:** choose routes and missions, explore settlements and dungeons, investigate leads, manage faction relations and territory, and make story decisions.
3. **Tactical operation:** deploy a squad or platoons, read terrain and enemy intent, complete a battle objective and preserve the company.
4. **Aftermath:** resolve casualties, rewards, EXP/AP/Sigils, loot, morale, fatigue, traits, relationships, faction changes, territory state and journal/chronicle records.

A win is not only a victory screen. It should change the campaign state and be acknowledged by characters and locations. The player should be able to see why a resource, relationship or political value changed.

## 2. Campaign calendar and economy

### Documented GDD model
- Campaign time is organised into weeks; four weeks form a month and four seasons form a year.
- Travel, training and construction may consume weeks.
- Story missions may have deadlines; side content is optional.
- At week end: upkeep, construction progress, training results and rumour refresh are resolved.
- Core resources: **Gold** (wages, gear, buildings, bribes), **Provisions** (weekly upkeep and marches), **Materials** (construction, forging and siege gear), **Renown** (recruitment, nobles, promotions and endings).

The detailed GDD describes wages scaling with roster level/rarity and provisions consumed by upkeep and army marches. Avoid adding a second calendar or resource wallet. Audit the live economy and current save payload first.

### Target economy principles
- Optional content should enrich the campaign, not be mandatory repetitive grinding.
- Every cost must have a readable reason and preview.
- Avoid irreversible resource traps that make the main story unwinnable.
- Keep resource sources and sinks balanced over a complete chapter, not just one shop screen.

## 3. Tactical grid combat

### 3.1 Battlefield model
The GDD specifies an isometric 2:1 square grid, commonly 10×10 to 20×16, with terrain and height per cell. Height values range 0–4. Units have four-direction facing. The last movement or attack establishes facing; waiting can be used to choose facing.

Movement is tile-cost based. The player previews movement/targeting before confirming. Camera zoom and pan are supported by the design.

### 3.2 Charge-time turn order (CTB)
This is not a conventional alternating player/enemy phase system:
- Every unit has a countdown `ctb`.
- The lowest countdown acts next; all other units subtract that amount.
- After acting, the unit receives a new countdown based on `ACTION_BASE / SPD` multiplied by action type.
- GDD multipliers: attack/skill 1.0, move-only 0.75, wait-only 0.5. Crossbow reload has a documented slower turn multiplier.
- Fatigue, Haste and Slow affect effective speed.
- HUD previews the next eight turns.

### 3.3 Turn actions
The documented action sequence is **Move → one action** (Attack, Skill, Item or Wait). No movement after the action. Movement and action confirmation must be distinct, readable and reversible before commitment where the UI permits.

### 3.4 Character statistics
HP, MP, STR, DEX, INT, VIT, SPD, LCK, ACC, EVA, LDR and MOR. The GDD records level-one reference ranges; actual character/class data is authoritative for tuning.

### 3.5 Damage and hit calculations
The GDD labels `CombatCalc` as the authoritative damage implementation. Its documented model:

```
physical attack = weapon_power + STR + 0.25 * DEX
bow/crossbow attack = weapon_power + DEX
magic attack = spell_power + 1.2 * INT

physical defense = armor_def + 0.6 * VIT
magic defense = armor_res + 0.3 * INT + 0.3 * VIT

raw = attack_power * skill_multiplier
base = raw^2 / (raw + defense)
damage = max(1, round(base * height * facing * flank * status * morale * crit * variance))
```

Documented modifiers:
- Height: +10% per level advantage, capped at +30%; disadvantage −10% per level, capped at −30%.
- Facing: front 1.00, side 1.10, rear 1.25.
- Flank: +15% when an ally is positioned on the opposite side of the target.
- Critical: ×1.5; Assassin backstab ×2.0.
- Variance: 0.95–1.05.
- Morale: high morale (80+) ×1.05; low morale (below 30) ×0.85; routed units cannot attack.
- Hit chance: clamp(ACC + weapon accuracy − EVA − terrain cover − status penalty, 10, 98).
- Critical chance: clamp(5 + 0.5×LCK + 0.3×DEX + weapon critical + rear bonus, 0, 60).

**Implementation rule:** never duplicate these formulas in UI, AI or a second calculator. Call the existing `CombatCalc` preview/resolve functions. If the live code differs, code plus tests wins; reconcile this document and GDD with an explicit revision.

### 3.6 Weapons and ranges
GDD weapon families:
- Sword/axe/mace: range 1, possible melee counter.
- Spear/lance: range 1–2, cavalry charge bonus.
- Dagger: range 1, critical/rear attack identity.
- Bow: range 2–5, forest accuracy penalty, height range bonus.
- Crossbow: range 2–4, armour penetration and slower reload.
- Staff/spells: range 1–4, magic damage and MP cost.

Line of sight, impassable cells and weapon restrictions must be enforced by the shared battle rules, not only hidden by the UI.

### 3.7 Terrain, height and weather
Documented terrain includes grass, road, forest, hill, shallow river/ford, deep water, bridge, ruins, wall/rock and rain mud. Terrain affects movement cost, cover, concealment, fire, cavalry movement, evasion, height and line of sight.

Weather/environment conditions in the GDD: clear, rain, fog, night, snow and wind. These modify visibility, movement, ranged accuracy and fire spread. A new terrain type must define movement, cover, line of sight, hazard, elevation and unit exceptions.

### 3.8 Status effects
The documented family includes Poison, Burn, Bleed, Chill, Stun, Slow, Haste, Blind, Silence, Fear, Fortify, Inspire, Rally and Exhausted. Duration is counted in the affected unit's turns. Status application, stacking, refresh and immunity must be consistent between player and enemy units.

### 3.9 Morale and fatigue
Morale (0–100) responds to allies falling, kills, commander presence, flanking, numerical pressure and support abilities. Low morale weakens attacks; zero morale routes the unit. Rally can restore morale.

Fatigue (0–100) rises through movement/heavy actions, falls on waiting and recovers between battles. High fatigue reduces SPD/EVA and eventually causes Exhausted. Do not create a separate morale/fatigue implementation for platoons without a deliberate integration design.

### 3.10 Victory and defeat
Documented victory objectives include eliminating/routing enemies, defeating a commander, seizing/holding a point, escorting a target or surviving a turn count. Defeat can occur through protagonist/party collapse, escort death or a turn limit. Retry/retreat penalties must be fair and clearly shown.

### 3.11 Auto Battle
The GDD documents a player-toggleable Auto Battle using the same action controller and scoring AI as enemy turns, without hidden combat bonuses. It includes a healing priority for badly injured allies and explicit control handoff behaviour. Save/load and story-critical decisions must remain protected from unintended AI actions. Extend the existing AI; do not create an alternate combat resolution path.

## 4. Character progression and buildcraft

### Levels and EXP
- GDD target/documented cap: levels 1–250.
- EXP curve: `80 + 20 × level + max(0, level - 2)^2`.
- EXP can carry over and produce multiple level-ups; cap handling must not store excess EXP.
- Stat growth is class-driven and uses per-stat growth chances. The GDD describes a deterministic seeded RNG for tests and a fallback growth point if every roll fails.

### Classes and promotion
The GDD documents 28 classes across warrior, cavalry, ranged, magic, support and specialist branches. Promotions occur at tier milestones (10/20/30) with class-specific story, stat, item, facility or relationship gates intended for some elite paths. Characters should retain learned skills as designed. The current class JSON and promotion API must be checked before modifying the tree.

### Skills
Skill roles include attack, buff/debuff, mobility, command and passive. Skills may be class-taught, innate, sigil-derived or character-unique. Each skill requires clear targeting, range, MP/AP cost, cooldown/turn impact, status rules and AI intent. Weapon strikes and magic spells should use the appropriate shared combat calculations.

### Equipment
Documented slots: weapon, off-hand, armour, helm, two accessories. Two-handed weapons block off-hand equipment. Heirloom gear is character-bound. Items modify stats and defensive values; paper-doll layers should reflect equipped gear where supported. Enhancement and heirloom growth must not be assumed implemented unless confirmed in code.

### Runes and Sigils
The repository's GDD and handoff describe 77 rune definitions and 11 sigils as a documented baseline. Runes include passive, active, support, stat, unique and heirloom forms; specialist services, fusion, mastery and protected unique/heirloom rules are part of the design. Sigils also participate in character progression and rewards. Check current data IDs and exact probabilities/costs before editing. Never duplicate content or silently remove a unique/heirloom item.

### CK-style traits — requested system
The owner requested a broad, Crusader Kings-inspired trait system with positive and negative traits that characters can acquire and lose. Treat this as a distinct design target unless the live main branch proves otherwise. Trait categories include personality, virtues/flaws, leadership, combat, education, profession, social reputation, faith/worldview, fears/resilience, survival, supernatural exposure and legacy.

Each trait needs: stable ID, display name, category, rarity, description, acquisition triggers, removal/decay rules, mechanical effects, dialogue/event tags, incompatibilities, stacking rules and save defaults. Effects may influence stats, skills, morale, loyalty, AI priorities, event options, recruitment and faction reactions. Traits should produce roleplay as well as numbers. Avoid random churn, runaway stacking and punishment spirals. Trait acquisition/removal must be explicit and journalled when narratively significant.

## 5. Recruitment, companions and relationships

Every recruit should be authored as a character with an identity, history, desire, fear, contradiction, voice, class/combat role, recruitment condition, personal quest, relationship hooks and possible contribution to the keep/company.

The documented loyalty foundation includes readable loyalty states, but that does not automatically mean a full relationship simulation is complete. Target relationship mechanics:
- pairwise bonds, rivalries, trust and unresolved conflict;
- changes from shared missions, disagreements, rescues, choices and personal quests;
- clear feedback about why a relationship changed;
- dialogue and tactical support effects where justified;
- foreshadowed departure/betrayal and player opportunity to respond.

Never use one hidden loyalty threshold as an arbitrary betrayal switch.

## 6. Platoon and army systems

The GDD has separate chapters for platoon management and large-scale army battles. It describes platoon types, structures, aptitudes, stats, formations and management actions. These sections must be treated as part of the existing design bible, but each player-facing feature must be checked against current scripts and scenes.

Design contract:
- A hero remains meaningful in both squad and platoon scales.
- Platoon composition, leader, troop roles, formation and aptitude should produce legible tactical trade-offs.
- Strategic battle outcomes must resolve through the same campaign state and preserve named-character consequences.
- Do not claim army battles or platoon management are fully playable based only on a GDD section or data scaffold.

## 7. Headquarters and settlement systems

Kaer Sethorn is the company’s functional and emotional centre. The GDD includes a castle headquarters chapter. Facilities should provide distinct, visible gameplay functions (training, recovery, recruitment, supplies, forging, research, mission planning, records/memorial). Upgrades should have costs, prerequisites, time, visible state and campaign effects.

Settlement and town interactions should be more than static menu text. The target is NPCs, rumours, services, quest triggers, local state, environmental changes and consequences. Avoid constructing duplicate facility or town systems before auditing existing scene/data architecture.

## 8. Kingdom, empire and grand-strategy layer — requested expansion

This is a requested expansion and must not be confused with the existing tactical combat foundation. The player should gradually move from leading a small company to governing a coalition/kingdom and potentially shaping an empire.

### Strategic map and territory
- Maintain the established seven-continent atlas and named macro-regions.
- Add a strategic layer above regional overworld maps and local battle maps.
- Territories should record owner/claim, controller/occupier, settlement/fortress, population or prosperity, stability, supply, strategic resources, routes and active threats.
- The player must not instantly own the world. Control is earned through story, diplomacy, defence, liberation, negotiation or war.
- A territory's state must affect local NPCs, prices, recruitment, patrols, roads, quests, garrisons and available operations.

### Kingdom and imperial institutions
Target institutions include:
- ruler / claimant and succession legitimacy;
- council positions with distinct responsibilities (military, treasury, diplomacy, intelligence, law, provisions/works);
- treasury, taxation and public spending;
- food stores, production and logistics;
- military muster, recruitment, wages and supply;
- infrastructure, fortifications and roads;
- law, stability, unrest and public trust;
- diplomacy, treaties, vassals/households and alliances;
- intelligence, rumours, agents and counterintelligence;
- war declarations, campaigns, sieges, occupation and settlement.

Each council appointment should use a named character's traits, skills, loyalty and relationships as modifiers, with trade-offs. Never make appointments purely decorative.

### Core strategic resources
The previously requested roadmap includes treasury, food, stability, legitimacy, military strength, infrastructure, diplomacy and intelligence. Model each with bounded values, clear sources/sinks, forecasts and event explanations. Avoid a single generic “kingdom power” score.

### Wars and sieges
- War needs a cause, declared objective, factions, fronts, supply lines, commanders and a route to settlement.
- Battles and sieges should connect to tactical encounters; strategic results must not be random UI-only outcomes.
- Siege phases may include investment, blockade, assault, relief, sabotage, negotiation and surrender.
- Occupation should create obligations and consequences; liberated/occupied people remember conduct.
- Defeat should create a recoverable campaign state where possible, not silently erase the player's campaign.

### Political agency
The faction foundation documented in the session handoff includes bounded relations (-100 to +100), diplomatic states (neutral, non-aggression, trade pact, alliance, war), alliance trust gating, region affiliation, validated transfers and event history. It is described as a backend foundation, not a completed diplomacy screen, automatic war simulation, AI faction turns or strategic battle layer. Build from this foundation rather than creating a second faction database.

## 9. Story-linked mini-games and activities

The owner requested optional activities inspired at a high level by classic RPG variety while remaining original. The earlier expansion roadmap named:
- Archery Range;
- Harbor Angling;
- Commander's Gambit;
- Forge Trial;
- Beast Run;
- Ruin Delver.

These are concepts until implemented. Each must have a narrative reason, clear controls, accessible touch alternative, meaningful reward/consequence and a finite session length. Mini-games should connect to traits, relationships, resources, faction reputation, clues or tactical preparation. They must not become disconnected mandatory grinding or copy another game's specific rules/art.

## 10. World exploration and mission design

- Global atlas → strategic/continental travel → regional overworld → local settlement/dungeon → tactical battle.
- Each map layer has a distinct purpose and navigation scale.
- Preserve the current Sethmarch and Brinegate content and the seven-continent canon.
- Travel should have readable route, risk, time, provisions and story gating.
- Missions need authored objectives, briefing, encounter composition, optional goals, outcome consequences and aftermath.
- Use varied battle objectives and environmental hazards rather than repeating elimination battles.

## 11. Save, data and offline rules

- The game is fully offline; local JSON definitions and local save files are foundational.
- No Base44 cloud database, online account, telemetry, server or multiplayer requirement may replace this architecture.
- Keep data-driven definitions in existing JSON files where appropriate; runtime state belongs in the established GameState/SaveSystem path.
- Any new persistent field (traits, relationships, kingdom resources, territories, journal, facilities) requires safe defaults for existing saves and migration/regression tests.
- Never change save schema casually. Document exact schema impact and rollback/compatibility behaviour.
- Stable IDs, schema validation, deterministic test seeds and explicit normalization are preferred.

## 12. UI and feedback contracts

- Mobile-first landscape design, safe-area awareness and responsive scaling.
- Every important number has a label, context and explanation; show costs and outcomes before confirmation.
- Show CTB turn order, move/attack previews, hit chance, damage estimate, status, terrain and objectives clearly.
- Make character traits, bonds, equipment and class identity discoverable from character sheets.
- Show kingdom forecasts, faction relation changes, territory ownership and war goals in understandable language.
- Use consistent typography, spacing, hierarchy and shared theme. No overlapping panels, clipped text or tiny touch targets.
- Keep animation and effects subordinate to tactical clarity.

## 13. Testing and balancing

Every mechanic needs:
- unit tests for formulas and boundaries;
- data integrity tests for IDs, references, ranges and missing assets;
- save/load and legacy migration tests for persistent state;
- AI tests for legal actions and edge cases;
- battle simulations/balance reports for combat changes;
- scene smoke tests for screens and interactions;
- responsive layout checks at narrow portrait, narrow landscape and standard landscape;
- device QA for real Android input, performance, safe areas and save reliability.

Do not mark a mechanic complete because its JSON schema, class, screen mockup or planning document exists. It must work in the real game loop and pass relevant checks.

## 14. Source map

Use these detailed references rather than relying on this summary alone:
- [GDD — detailed mechanics, formulas, progression, recruitment, platoons, castle, story, world, roster, UI and offline architecture](GDD.md).
- [Current game state and gap analysis](CURRENT_GAME_STATE_AND_GAP_ANALYSIS.md).
- [Game vision and requirements](GAME_VISION_AND_REQUIREMENTS.md).
- [Lore bible](LORE_BIBLE.md).
- [Premium production bible](PREMIUM_PRODUCTION_BIBLE.md).
- [Base44 start here](BASE44_START_HERE.md).

**Rule:** When source code, tests and the GDD disagree, inspect the live code and test evidence, then record the discrepancy and update the bible. Never silently change an established mechanic.


## 15. Post-campaign generational dynasty system — locked until the true ending

**Canon dependencies:** The political terms and timeline are defined in LORE_BIBLE.md §2.1 and §13. Osric IV is King of the Crownlands, not Emperor; the old Eldrimar Empire is historically fragmented and its imperial office is dormant at campaign start. The protagonist becomes Last Emperor only through the ratified true-ending settlement, solely to enact dissolution. The secret-order faction covenant_seven_flames is distinct from the public historical Covenant compact. Brinegate belongs to the Tidebound Assembly; House Ysmark's seat remains unconfirmed.

**Status: DESIGNED / REQUESTED. Not verified implemented.** This is a distinct post-campaign mode. It must not be folded into the main campaign character progression or unlocked early.

### 15.1 Exact unlock gate and state transition

The system is locked unless the save records every required milestone:
- main campaign completion flag;
- protagonist reached the ending path in which they become the last Emperor;
- empire dissolution charter enacted and chronicle entry written;
- post-ending late-life sequence completed;
- protagonist's death cause is natural old age;
- a valid succession candidate or a deliberate no-heir succession resolution exists.

A battle death, scripted sacrifice, defeat, retirement, skipped epilogue or ordinary ending without the Emperor-and-dissolution sequence must not unlock dynasty mode. The UI should foreshadow the Chronicle as sealed/locked only if useful, but must not expose playable marriage, children, inheritance or noble-house management before the gate.

On valid death, create an immutable Founder Chronicle record, calculate the succession according to the recorded succession law, then transition to the first successor. Preserve the completed main-campaign save as a read-only historical origin and create a separate generational campaign state. Never overwrite the original ending record.

### 15.2 Core generational loop

A generation should support this loop:
1. Review inherited house chronicle, family tree, titles, holdings, debts, alliances and unresolved claims.
2. Manage the current head and household: education, guardianship, marriage proposals, household roles and personal ambitions.
3. Govern the domain: taxes, food, infrastructure, justice, garrisons, trade, public works and local stability.
4. Fulfil obligations to the Concord and neighbouring realms.
5. Resolve events through diplomacy, personal decisions, investigations, military action or tactical battles.
6. Develop the current generation's skills, traits, relationships and reputation.
7. Age, retire, die or be succeeded; resolve inheritance and record the consequences.
8. Continue as the next eligible heir or chosen successor.

Time advances in a readable calendar (monthly/seasonal turns are a suitable starting point). Characters age every turn; important events must be surfaced before irreversible outcomes. Do not simulate decades in a single opaque tick.

### 15.3 Characters, family and life cycle

Characters require stable IDs and explicit relationships: parent, child, spouse, guardian, adopted child, sibling, half-sibling, cousin, legitimised child and house member. Track birth date/age, health, education, traits, skills, class, culture/region, faith/worldview where relevant, loyalty, relationships, titles, claims, holdings, life status and cause of death.

Life-cycle stages should include childhood, adolescence, adulthood, maturity, old age and death, with culturally authored age ranges. Children are not combat units by default. Their gameplay should focus on education, guardianship, relationships, events and future choices; only appropriate adults enter military roles.

Marriage must be consensual in narrative framing and represented through proposals, compatibility, personal agency and political consequences. Do not reduce spouses to breeding/stat optimisation. Marriage can create alliances, divided loyalties, claims, household changes and emotional storylines. Include celibate, unmarried, adopted and childless paths without a dead-end.

### 15.4 Hereditary traits, skills and bloodline

Build on the requested CK-style trait system, but separate:
- **inherited predispositions:** limited probabilities for selected temperament, aptitude or rare family traits;
- **learned traits:** gained through upbringing, mentors, education, profession and lived choices;
- **life-event traits:** gained or removed through hardship, service, injury, grief, recovery and achievement;
- **house traditions:** non-genetic cultural practices that descendants can learn or reject.

A child must not simply copy the parent's full stats. Use bounded inheritance ranges, individual variation, environment and training. Avoid guaranteed perfect heirs or runaway stat inflation. Traits must have provenance, acquisition/removal rules, exclusivity, caps and visible effects. Some traits may skip generations or be expressed differently; inherited traits should never be deterministic proof of superiority.

### 15.5 Nobility, titles and domains

Use a flexible rank model: Landed Gentry → Knight/Dame → Baron/Baroness → Viscount/Viscountess → Count/Earl → Marquess → Duke/Duchess → Archduke/Archduchess. Prince/Princess and High Protector/First Warden are realm-specific or constitutional offices, not automatic rungs above Duke. Emperor is abolished and must not return as an ordinary purchasable/inheritable title.

Each title record must define:
- stable title ID, local name, rank/tier and culture;
- jurisdiction and associated holdings;
- source of legitimacy (grant, election, inheritance, marriage claim, conquest recognised by law, or service);
- duties, taxes/revenue, levies, public works and defence obligations;
- privileges and legal limits;
- liege/compact obligations where applicable;
- succession and revocation rules;
- prestige/reputation effects and dispute process.

A title does not itself equal a territory. Domain, title, claim, occupation and legal control are distinct. A baron can hold a title but be dispossessed; a count may govern a county with contested claims; a knight may own an estate without holding a noble title.

### 15.6 House, domain and realm management

A house has a head, members, cadet branches, family reputation, treasury, debts, traditions, heraldry, seat, claims, alliances and historical chronicle. Domain management should reuse the existing territory/faction/economy foundations rather than create parallel state.

Domain metrics should be individually legible: treasury, food reserves, prosperity, stability, legitimacy, public trust, infrastructure, defence, local relations and obligations. Events need cause-and-effect forecasts. Taxes and levies create trade-offs, not free income. Neglect, famine, unjust law, corruption or military occupation should create understandable consequences and opportunities to repair harm.

### 15.7 Succession and inheritance

Succession law is a core player choice and a source of story:
- equal partition among eligible heirs;
- seniority within the house;
- primogeniture with configurable gender-neutral or realm-specific rules;
- elective succession among eligible house members or recognised office-holders;
- designated heir with lawful confirmation;
- adoption/chosen successor;
- collateral-branch succession when the direct line ends.

Do not hard-code one child-count/title table. Resolve succession by title-specific law, legitimacy, parentage/adoption, age/eligibility, claims, prior grants, wills/charters and recorded events. Show a preview before confirmation, including who inherits each title/holding, what becomes contested, and who receives compensation. Prevent accidental title duplication. If a title has no eligible heir, it may revert to the granting realm, pass to a lawful collateral claimant or become disputed according to its charter.

Younger children need meaningful paths: command, scholarship, diplomacy, clergy/civic service, marriage alliance, estate stewardship, mercenary service, founding a cadet branch or pressing a claim. They should not become useless roster leftovers.

### 15.8 Reputation, diplomacy and social mobility

Keep realm/faction reputation separate from personal renown, house standing, legal legitimacy and local trust. They may influence invitations, marriage negotiations, title grants, trade, court access and arbitration, but high reputation must not guarantee every outcome.

Titles can be earned through service, lawful grant, election, recognised inheritance or a costly political settlement. Do not make every title a shop purchase. A common-born character may rise through service, while a noble may lose standing through misconduct. Marriage can open doors but must not be the only route to advancement.

### 15.9 War, injuries, aging and death

Generational characters age and eventually die. Retirement is a player-facing transition, not a silent deletion. Injuries can affect recovery, capability and story; permanent wounds must be rare, clearly explained and never stacked into an unavoidable punishment spiral. Death in battle should have clear rules and memorial/estate consequences; only the founder's specific natural-old-age death triggers the first unlock.

Wars should connect domain-level causes to existing tactical combat. A house may defend a keep, escort supplies, suppress banditry, support a liege, contest a border or refuse an unjust levy. Use named commanders and record casualties, captures, ransom, surrender, occupation and aftermath.

### 15.10 Chronicle and presentation

Required views: family tree; current household; character dossier; title/domain map; succession preview; house ledger; court/diplomacy; event chronicle; memorial. Each generation needs a concise year/season recap and a full life record on death. Use original KindleWake visual language and mobile-readable screens.

### 15.11 Save architecture and testing

Use a distinct versioned generational save profile linked to, but not mutating, the completed campaign origin. Add safe migration, deterministic succession tests, family-graph integrity checks, title uniqueness/claim tests, aging/death tests, save-load round trips and long-horizon simulation/balance tests. Offline local JSON/save architecture remains mandatory.

Acceptance tests must prove:
- every invalid ending/death path remains locked;
- only the specified Emperor → dissolution → natural old-age death path unlocks;
- a valid heir can inherit without corrupting the original campaign;
- adoption and non-biological succession work;
- partition and non-partition laws resolve consistently;
- no title or holding is duplicated;
- family graph has no impossible parent cycles;
- old campaign saves load unchanged;
- long simulations do not create runaway wealth, population, stats or title inflation.

Do not implement the entire generational system as one large feature. After source audit, build vertical slices: (1) ending gate and immutable founder chronicle, (2) family graph and life-cycle data, (3) one household and succession law, (4) one barony domain loop, (5) expanded titles/realms, (6) long-horizon events and wars.
