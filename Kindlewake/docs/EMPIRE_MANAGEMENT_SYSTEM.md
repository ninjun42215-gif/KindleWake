# Empire Management System — KindleWake

## Design intent

The realm layer turns campaign victories, alliances and restored territories into a consequential administration game. It is an offline, deterministic extension of the existing faction/territory foundation. It does not replace tactical combat, party progression, regional exploration or authored story decisions.

## Canon and unlock boundaries

- Realm administration is locked by default in a new campaign.
- An authored story outcome must call `GameState.unlock_empire_management()` when the protagonist is legitimately granted governing authority. No arbitrary calendar event or random flag unlocks it.
- This does **not** unlock the hereditary dynasty/family simulation.
- The full Knight of Ages-inspired hereditary title and family layer remains post-campaign only: the protagonist completes the original story, becomes the Last Emperor, abolishes the Empire, completes the epilogue and dies naturally of old age. Only then can descendants enter the separate barony/count/duchy succession loop.
- Faction ownership remains grounded in the seven-continent atlas and existing faction definitions. The management layer cannot invent provinces.

## Current backend scope

Implemented as `scripts/core/empire_management_system.gd`, integrated with `GameState` and the campaign payload:

- Treasury, food reserves, manpower, stability, legitimacy and public order.
- Low, normal and high tax settings. High taxation improves income but harms order and legitimacy; low taxation trades income for public order.
- Toggleable relief, development, conscription, mercantile and tolerance policies.
- Five council offices: Steward, Marshal, Spymaster, Chancellor and High Priest. Council appointments reference existing party characters.
- Province governors reference known atlas regions and existing party characters.
- Province construction: farms/granaries, markets, barracks, roads, forts and aqueducts. Costs are paid immediately; duplicate building types per province are rejected.
- Explicit seasonal advancement. The caller/story clock controls when a season advances; there is no hidden real-time simulation.
- Provincial standing forces with levy infantry, march archers and household cavalry; recruitment spends manpower and treasury, and disbanding returns 75% of the manpower cost.
- Controlled-province garrison limits (50 baseline, +100 with barracks), validation against foreign/unknown provinces, and an aggregate army summary.
- Standing armies add seasonal treasury upkeep and food/ration demand. Seasonal reports expose troop count, military upkeep and military food consumption so army size has a visible economic cost.
- Seasonal tax income, upkeep, food production/consumption, manpower replenishment, public-order and stability effects, fort defence contribution and bounded event history.
- Safe normalization for legacy saves with no empire payload. The system is additive and does not require a save schema bump.

## Seasonal economy model

Each known province contributes a modest baseline tax and food yield, while population/administration creates upkeep and food consumption. Buildings add focused benefits. Council seats incur upkeep. Food reaching zero creates a serious stability and public-order penalty. High taxes are a short-term treasury lever with visible long-term political cost. Policies create trade-offs rather than universally optimal bonuses.

## Player-facing screens now implemented in the feature branch

1. **Realm overview:** treasury, food, manpower, stability, legitimacy, public order and explicit season advancement/report.
2. **Council chamber:** office responsibilities, roster-based appointments and dismissal. Character portrait rendering and trait/loyalty-based office effects remain future work.
3. **Provinces:** atlas ownership, governor appointment/recall and construction. Actions are disabled outside player-controlled House Dunmarrow/Crownlands territory; local order and resource specialization remain future work.
4. **Economy:** tax policy, edicts and seasonal ledger. A forecast/confirmation preview remains future work.
5. **Military:** manpower is visible in the realm overview and forts contribute a defence value in the seasonal report; garrisons, recruitment levies, supply and campaign readiness are not yet implemented.
6. **Military:** recruit and disband provincial infantry, archers and cavalry; view total troops, garrisoned provinces, upkeep and food demand. Barracks increase local garrison capacity. Seasonal ledgers charge troop upkeep and rations. Field armies, movement, tactical deployment, supply lines, sieges and war declarations remain future work.
7. **Diplomacy:** faction relations and territorial transfers remain available through the separate faction backend; a player-facing diplomacy screen, treaties, trade and war declarations are future work.
8. **Chronicle:** current realm decisions, construction, appointments, policy changes and seasonal reports. Rebellion and territorial events will join when authored.

## Future gameplay systems

- Province-level population, prosperity, culture and unrest.
- Trade routes, tariffs, resource specialization and caravan/port income.
- Army mustering, garrisons, supply lines, siege preparation and war exhaustion.
- Faction AI turns, claims, succession crises and negotiated peace.
- Character traits, skills, loyalty and rivalries influencing office performance.
- Events with clear causes, player choices and persistent consequences.
- A dedicated strategic map and mobile-first administration UI.

## Balance and quality requirements

- Never make a single tax rate or policy universally optimal.
- No random rebellion without readable warning signals and player agency.
- Every recurring cost and yield must be visible before committing.
- A season advances only through an explicit game-time/story action.
- Preserve offline-first operation, no account/server dependency and no Android INTERNET permission.
- Keep old schema-4 saves loadable; test both missing and populated empire payloads.
- Do not describe backend APIs as a finished UI or playable empire campaign until screens and story integration are implemented and tested.


## Current feature-branch UI status

The Realm, Council, Provinces, Economy and Chronicle tabs are implemented in `scripts/ui/empire_administration.gd` and mounted from the overworld through an unlock-gated Royal Court button. Story integration is intentionally not guessed: the approved narrative milestone must call `GameState.unlock_empire_management()`. The feature branch has added strict regression tests, but no Godot/Android validation is yet confirmed.
