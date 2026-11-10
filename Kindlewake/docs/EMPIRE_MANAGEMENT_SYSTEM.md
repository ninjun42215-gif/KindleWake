# Empire Management System — KindleWake

## Design intent

The realm layer turns campaign victories, alliances and restored territories into a consequential administration game. It is an offline, deterministic extension of the existing faction/territory foundation. It does not replace tactical combat, party progression, regional exploration or authored story decisions.

## Canon and unlock boundaries

- Realm administration is locked by default in a new campaign.
- An authored story outcome must call `GameState.complete_story_milestone("crown_authority_granted")` when the protagonist is legitimately granted governing authority. No arbitrary calendar event, sea charter or random flag unlocks it.
- This does **not** unlock the hereditary dynasty/family simulation.
- The full Knight of Ages-inspired hereditary title and family layer remains post-campaign only: the protagonist completes the original story, becomes the Last Emperor, abolishes the Empire, completes the epilogue and dies naturally of old age. Only then can descendants enter the separate barony/count/duchy succession loop.
- Faction ownership remains grounded in the seven-continent atlas and existing faction definitions. The management layer cannot invent provinces.

## Current backend scope

Implemented as `scripts/core/empire_management_system.gd`, integrated with `GameState` and the campaign payload:

- Treasury, food reserves, manpower, stability, legitimacy and public order.
- Low, normal and high tax settings. High taxation improves income but harms order and legitimacy; low taxation trades income for public order.
- Toggleable relief, development, conscription, mercantile and tolerance policies.
- Five council offices: Steward, Marshal, Spymaster, Chancellor and High Priest. Council appointments reference existing party characters. Twenty-three companions now carry authored personality tags; compatible traits add office-specific seasonal bonuses.
- Province governors reference known atlas regions and existing party characters.
- Province construction: farms/granaries, markets, barracks, roads, forts, aqueducts and supply depots. Depots seed connected supply networks through controlled atlas links; a hostile frontier region can be supplied when it borders that network. Costs are paid immediately; duplicate building types per province are rejected.
- Explicit seasonal advancement. The caller/story clock controls when a season advances; there is no hidden real-time simulation.
- Provincial standing forces with levy infantry, march archers and household cavalry; recruitment spends manpower and treasury, and disbanding returns 75% of the manpower cost.
- Controlled-province garrison limits (50 baseline, +100 with barracks), validation against foreign/unknown provinces, and an aggregate army summary.
- Standing armies add seasonal treasury upkeep and food/ration demand. Seasonal reports expose troop count, military upkeep and military food consumption so army size has a visible economic cost.
- Field armies can be mobilized from existing garrisons without creating duplicate troops. Mobilization preserves troop composition and may assign an existing party character as commander.
- Field armies move one step per season along authored regional links in the seven-continent atlas; arbitrary jumps and non-adjacent moves are rejected.
- Field armies outside player-controlled provinces are marked unsupplied unless they border a connected supply network seeded by a controlled supply depot. One isolated season is a warning grace period; from the second consecutive unsupplied season onward, each season causes deterministic 5% troop attrition (minimum one soldier), reduces morale by 10, and records total losses in the seasonal ledger. Supplied armies recover 6 morale per season up to 100. Armies destroyed by prolonged isolation are removed and recorded in the chronicle.
- Seasonal tax income, upkeep, food production/consumption, manpower replenishment, public-order and stability effects, fort defence contribution, trade-route income and bounded event history.
- Direct trade routes between adjacent controlled provinces; each 100-gold charter returns 20 gold per season and persists in campaign saves.
- Deterministic NPC diplomacy: neutral factions at +70 relation may form trade pacts; NPC pairs at -80 may declare war. Player faction is excluded from autonomous war declarations.
- Rebellion pressure derived from public order, stability and legitimacy, persistent province warnings, and a funded relief action that reduces risk and restores public order.
- Negotiated peace acceptance weighs bilateral relation, war exhaustion and offered gold; accepted terms end the war and reduce war exhaustion.
- Safe normalization for legacy saves with no empire payload. The system is additive and does not require a save schema bump.

## Seasonal economy model

Each known province contributes a modest baseline tax and food yield, while population/administration creates upkeep and food consumption. Buildings add focused benefits. Council seats incur upkeep. Food reaching zero creates a serious stability and public-order penalty. High taxes are a short-term treasury lever with visible long-term political cost. Policies create trade-offs rather than universally optimal bonuses.

## Player-facing screens now implemented in the feature branch

1. **Realm overview:** treasury, food, manpower, stability, legitimacy, public order and explicit season advancement/report.
2. **Council chamber:** office responsibilities, roster-based appointments and dismissal. Companion trait tags are shown on office cards and compatible traits modify seasonal office effects. Character portrait rendering and deeper loyalty/rivalry effects remain future work.
3. **Provinces:** atlas ownership, governor appointment/recall and construction. Actions are disabled outside player-controlled House Dunmarrow/Crownlands territory; local order and resource specialization remain future work.
4. **Economy:** tax policy, edicts, persistent trade routes, rebellion warnings and funded relief. An immutable next-season forecast previews treasury, food and manpower without changing live campaign state.
5. **Military overview:** manpower, troop strength, garrison counts, field deployments, upkeep, rations, readiness and war exhaustion are visible in the military administration tab.
6. **Military:** recruit/disband infantry, archers and cavalry; mobilize field armies, appoint party commanders, and move along atlas links. Supply depots seed connected networks; exposed armies suffer morale loss and attrition. The Military tab launches real BattleController encounters against region-specific garrisons. Strategic cohorts and commanders join; tactical casualties persist to the field army. Breached sieges deploy destructible outer/inner walls, a gate tower, the Fort Gate commander objective, battering ram, ballista, trebuchet and siege engineer. Engineer support improves ram durability and reduces fortification HP. Destroying the gate wins the siege battle; occupation still requires explicit faction territory transfer. War exhaustion, seasonal upkeep and armistice actions remain active. Tactical assaults now deploy destructible outer/inner walls, a gate tower and Fort Gate objective, plus battering ram, ballista, trebuchet and siege engineer support. The engineer passively weakens fortification HP and improves ram durability. Strategic diplomacy now includes direct treaties, AI trade pacts/war declarations, and negotiated peace offers. Trade routes, rebellion warnings/relief, companion trait-driven council effects and a projected seasonal ledger are implemented.
7. **Diplomacy:** player-facing treaty controls, non-aggression pacts, trade pacts, alliances, war declarations and negotiated peace offers. Alliances require +50 relations; peace acceptance weighs relations, war exhaustion and offered gold. NPC diplomacy resolves deterministically each season.
8. **Chronicle:** realm decisions, construction, appointments, policy changes, seasonal reports and diplomatic events. Rebellion risk is forecast from stability, legitimacy and public order; warnings appear before a player-funded relief action.

## Future gameplay systems

- Province-level population, prosperity, culture and unrest.
- Tariffs, resource specialization and caravan/port trade bonuses.
- Additional siege-engineer active abilities and expanded fortification layouts.
- Faction AI territorial campaigns, claims and succession crises.
- Character loyalty and rivalries further influencing office performance.
- Events with clear causes, player choices and persistent consequences.
- A dedicated strategic map and mobile-first administration UI.

## Balance and quality requirements

- Never make a single tax rate or policy universally optimal.
- No random rebellion without readable warning signals and player agency.
- Every recurring cost and yield must be visible before committing.
- A season advances only through an explicit game-time/story action. War exhaustion above 70 applies a small visible political penalty; it never triggers an unannounced game-over.
- Preserve offline-first operation, no account/server dependency and no Android INTERNET permission.
- Keep old schema-4 saves loadable; test both missing and populated empire payloads.
- Do not describe backend APIs as a finished UI or playable empire campaign until screens and story integration are implemented and tested.


## Current feature-branch UI status

The Realm, Council, Provinces, Military, Diplomacy, Economy and Chronicle tabs are implemented in `scripts/ui/empire_administration.gd` and mounted from the overworld through an unlock-gated Royal Court button. Economy includes an immutable next-season forecast, trade-route charters and unrest relief; council cards display companion trait tags. The approved story scene still needs to call the explicit `crown_authority_granted` milestone after the narrative establishes governing authority. Story integration is intentionally not guessed: the approved narrative event must call `GameState.complete_story_milestone("crown_authority_granted")`. The feature branch has added strict regression tests, but no Godot/Android validation is yet confirmed.

- Strategic battle instances now receive unique persisted IDs; resolved battle IDs are retained in campaign state and duplicate result submissions are rejected, preventing repeated casualties/war-exhaustion awards after reloads.

- Siege engineer now has two tactical skills: Field Repair restores HP to a nearby allied unit (including the ram), and Breach Charge damages a nearby wall/gate or enemy. Both use the standard BattleController skill/target flow.

- Added low/standard/high trade tariff policies (5%/10%/20% of route turnover); high tariffs increase revenue but reduce public order and legitimacy, while low tariffs improve order.
- Added authored resource specializations for the seven Crown Continent regions: Sethmarch grain, Orrowen timber, Vessmoor horses, Quillon crystal, Tarnholt incense, Brennhallow iron and Aurelmont royal crafts. Controlled regions contribute seasonal income, food, manpower, stability or public-order yields.
- Council effects now account for companion loyalty as well as traits and office: low loyalty creates stability/order strain and war exhaustion; high loyalty grants a modest role-specific bonus.

- Deterministic NPC diplomacy now generates persistent frontier claims when hostile non-player factions are at war and share a border. Claims are shown in the Diplomacy tab and are cleared only when the territory is transferred; they do not autonomously seize land.
