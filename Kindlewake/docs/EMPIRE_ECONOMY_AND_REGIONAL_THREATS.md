# Empire Economy & Regional Threats — Implementation Notes

## Turn-based holding economy

The economy is deliberately **player-advanced**, not real-time. A campaign turn is processed only when the player explicitly invokes the empire-turn action. Merely exploring, leaving the game open, or loading a save never charges upkeep.

Each player-held location can define its recurring yield in the existing `economy` object:
- `economy.gold`: base treasury income per empire turn.
- `economy.provisions`: provisions added to the campaign stockpile per empire turn.
- `economy.materials`: materials added to the campaign stockpile per empire turn.

The authored catalogue values are recurring yields, not one-time capture rewards. The Empire screen displays the yield and the resulting stockpiles.
- `garrison_upkeep`: fixed administrative/security cost per turn.
- `recommended_garrison`: garrison size that stabilizes the holding.
- `governance`: initial governance model.

The in-game **Holdings** screen lists the authored locations, their strategic descriptions and output, and clearly distinguishes administered holdings from locations that still require an authored world objective. It allows garrison assignment and governance changes only for player-held locations. Capture is intentionally not available from this screen.

The economy reads existing `world_flags` holding ownership, claim, stability and governance fields. It writes per-turn income/upkeep reports, stability, provisions and materials stockpiles back to `world_flags`, so the existing campaign save format remains sufficient.

### Governance models

| Model | Economic effect | Stability effect |
|---|---|---|
| Appointed warden | No modifier | Standard |
| Merchant council | +20% holding income (rounded up), +1 upkeep | Standard |
| Local compact | -1 upkeep (minimum 0) | +2 stability |
| Military command | +2 upkeep | -1 stability |

Garrison upkeep is one treasury unit per assigned soldier per turn, in addition to the holding's fixed upkeep. A garrison at or above the recommended strength grants +3 stability. An empty garrison costs 4 stability; provisional administration costs another 1. Stability is clamped to 0–100.

## Regional threat and boss roster

The world catalogue should give every continent its own identity rather than reskinning the same guardian. The following encounter identities are authored as expansion targets; they must be connected to a dedicated battle definition and map before being represented as playable:

| Region | Threat / boss identity | Encounter signature | Intended counterplay |
|---|---|---|---|
| Eldrimar | The Hollow Hart | Root-bound guardian that calls thornbound sentries | Clear its root anchors before focusing the core |
| Thalassar | Admiral Veyr, the Drowned Crown | Corsair commander with tide-callers and deck hazards | Disable signal drums and control the gangplank |
| Varakhan | Kharzug the Ash Regent | Siege-ogre with ash shamans and collapsing cover | Break the shamans' ward pylons first |
| Nhalor | The Pale Matriarch | Grave-weaver supported by revenant banners | Destroy banners to prevent resurrection pulses |
| Veyrwood | The Briar Sovereign | Mobile forest colossus with shifting terrain | Lure it onto prepared ironwood traps |
| Asterreach | The Star-Eater | Astral construct that changes safe tiles each phase | Read the constellation telegraph and relocate |
| Ilyr | The Last Cantor | Memory-bound duelist who echoes party abilities | Rotate skills and avoid repeating the same attack pattern |

These are content definitions, not a claim that all seven boss fights are already wired into the battle database.

## Siege and capture progression

Future siege encounters should use objective-based maps, not only defeat-all battles:
1. **Approach:** clear a supply route or disable an outer watch post.
2. **Breach:** open a gate, lower a port chain, or seize a signal tower.
3. **Objective:** hold a command tile for a set number of rounds or destroy a siege engine.
4. **Resolution:** defeat the commander or negotiate surrender.
5. **Aftermath:** claim only the authored location, set it to provisional status, assign governance and garrison, and record the change in holding history.

No siege can transfer an entire atlas region unless a separate authored faction-region event explicitly does so.

## Compatibility and balance guardrails

- No save-schema bump: all persistent economy values live in existing `world_flags`.
- No background timers or offline upkeep.
- Treasury cannot fall below zero; an unaffordable turn does not create debt.
- Ownership is checked every turn; lost or non-player holdings produce no player income or upkeep.
- Economy reports are deterministic and can be surfaced in a future Empire screen.
- The regional bosses above remain marked as expansion targets until their unique battle data and maps exist.


## Development, recruitment and garrison reserves

Player-administered holdings can now spend treasury and materials on three-tier local improvements:
- **Granary farms:** +3 provisions per tier and empire turn.
- **Civic workshops:** +2 gold per tier and empire turn.
- **Chartered trade posts:** +5 gold per tier and empire turn.
- **Stone fortifications:** +2 stability per tier and empire turn.

Upgrade costs scale with the next tier. The first tier uses the base cost; each later tier multiplies the base gold and materials cost by the next tier number. A failed affordability check changes neither treasury nor the building tier.

Recruitment is purchased from a holding reserve and consumes both treasury and provisions:
- Frontier Levy: 18 gold and 3 provisions.
- March Archer: 32 gold and 4 provisions.
- Household Knight: 65 gold and 7 provisions.

Recruitment currently creates strategic reserve stacks. The player may assign reserve troops to that holding's garrison; those assigned soldiers are included in the existing per-turn garrison upkeep. This is a campaign management layer and does not yet create tactical battle units or move army stacks between regions.

## Objective-based siege progression

The campaign state now supports a persistent siege objective lifecycle: stage an objective from a player holding, advance it in explicit progress steps, require objective completion before encounter resolution, and record whether the assault was resolved or repelled. Progress history is retained in `world_flags`. This is the objective/state foundation for siege missions; it is not yet a tactical siege map, gate interaction, AI siege turn or battle scene.

## Seven bespoke regional boss encounter briefs

`data/regional_boss_encounters.json` is loaded by GameData and contains a unique arena, three phase objectives, telegraphed hazards and counterplay for each continent:
- Eldrimar — The Hollow Hart
- Thalassar — Admiral Veyr, the Drowned Crown
- Varakhan — Kharzug the Ash Regent
- Nhalor — The Pale Matriarch
- Veyrwood — The Briar Sovereign
- Asterreach — The Star-Eater
- Ilyr — The Last Cantor

These are validated encounter briefs, not yet playable battle definitions. Each still needs a compatible tactical map, battle roster using existing character/unit IDs, phase-trigger scripting, hazard resolution and victory/aftermath integration before it can be launched as a boss fight.
