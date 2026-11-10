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
- Seasonal tax income, upkeep, food production/consumption, manpower replenishment, public-order and stability effects, fort defence contribution and bounded event history.
- Safe normalization for legacy saves with no empire payload. The system is additive and does not require a save schema bump.

## Seasonal economy model

Each known province contributes a modest baseline tax and food yield, while population/administration creates upkeep and food consumption. Buildings add focused benefits. Council seats incur upkeep. Food reaching zero creates a serious stability and public-order penalty. High taxes are a short-term treasury lever with visible long-term political cost. Policies create trade-offs rather than universally optimal bonuses.

## Planned player-facing screens (not yet implemented)

1. **Realm overview:** treasury, food, manpower, stability, legitimacy, public order, season report and alerts.
2. **Council chamber:** character portraits, office responsibilities, appointment/removal and trait/loyalty context.
3. **Provinces:** owner, governor, local order, buildings, construction queue and region-specific resources.
4. **Economy:** tax policy, relief spending, development and seasonal ledger.
5. **Military:** manpower, garrisons, forts, recruitment levies, supply and campaign readiness.
6. **Diplomacy:** faction dossiers, relations, treaties, tribute, trade and war declarations. Actions must be authored, validated and paid for; the current faction backend does not yet simulate AI turns or wars.
7. **Chronicle:** decisions, construction, appointments, shortages, rebellions and territorial changes.

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
