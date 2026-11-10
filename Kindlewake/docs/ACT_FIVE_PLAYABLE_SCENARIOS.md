# Act V — The Kindling (Playable Implementation)

## Sequence
1. Road to Aurelmont: choose River Compact, Veyrwood Canopy or Imperial Ash Road, then resolve a route-specific logistics/social challenge. Each route records its cost, support and distinct action.
2. Seven Witnesses: convene a public corroboration board from seven evidence strands. These are documentary and civic sources, not seven recruitable combatants. A witness who withdrew testimony in Act IV is never counted as consenting or quoted as reaffirming it.
3. Three Fires: resolve the granary, archive and riverfront crises in sequence. The campaign records the trade-offs for food security, public record and civilian safety. The interface stages these as linked crisis decisions; it does not claim three simultaneous tactical maps.
4. Last Audience with Maelor: choose Open, Guarded, Wounded or Narrow Concord. All outcomes preserve the canon sequence: protagonist becomes last Emperor, formally dissolves the Empire and establishes the Concord of Free Realms.
5. Chronicle of Houses remains locked. Act V sets campaign/ending milestones only; the Chronicle founder gate still requires epilogue completion and a recorded natural old-age death.

## Consequence inputs
- Acts I–III completion, Act IV archive record, Edmer revision, threat investigation and Act V route support feed the evidence board.
- Route support is higher for the deliberate repair/negotiation/trail-marking actions than for the faster expedient alternatives.
- Three Fires responses persist independently and shape the final settlement profile context.
- No cloud services or network calls; all progress uses GameState.world_flags and existing campaign saves.

## Scope and validation
The route challenges and crises are story/strategy decisions, not new tactical-engine objectives. The existing battle engine is not represented as supporting simultaneous objective tracks. Static source review and JSON-free data validation are appropriate; Godot runtime and in-engine playtesting must still be run before calling this release-ready.


## Dedicated rules test
Run `godot --headless --path . --script res://tests/test_act_five.gd` to exercise the Act V gates, route, evidence, crisis order, ending milestones and Chronicle lock. This test script is added separately from the existing broad suite so it can be run directly while the branch is reviewed.
