# Chronicle of Houses — Generational Foundation

## Unlock and mode boundary

Chronicle of Houses is a separate, post-campaign mode. It is reachable only after the canonical Chronicle gate records campaign completion, the protagonist as last Emperor, imperial dissolution, the late-life epilogue and a verified natural old-age death. The dynasty scene checks `GameState.chronicle_unlocked()` independently and displays a locked explanation if opened early.

The mode continues the Concord of Free Realms. It does not restore the Empire. Titles are jurisdictions with published obligations, not proof of bloodline superiority or unlimited authority.

## Starting house

The first Chronicle state is initialized from the founder record and current protagonist name. It records:
- The deceased founder and a founder's consort.
- Two adult successor branches, Alden and Maren, with distinct starting traits.
- The Barony of Kaer Sethorn and its initial domain measures.
- A chronicle event log, house calendar, succession law and designated successor.

The starting family members are authored campaign scaffolding for the first playable generational slice. They are not claimed to be fully simulated NPCs with autonomous lives.

## Family and character records

Each person stores identity, name, age, relationship role, parents, siblings, children, spouse, living/deceased state, cause of death, traits, title and domain references. Players can record children, record unrelated adult household members and create reciprocal marriage records. Direct relatives and people sharing a recorded ancestor cannot be married through this initial ruleset.

Traits can be added and removed with a persistent event record. The initial catalogue contains 45 positive, negative and mixed traits, each with a description and polarity. Traits are narrative records at this stage; they do not yet modify combat stats, AI, diplomacy or fertility.

## Aging and succession

The house calendar advances one year at a time. Living people age by one year; age 85 triggers a recorded natural old-age death. Titles are then passed using one of five policies:

- **Primogeniture:** eligible children are ordered by recorded birth year.
- **Equal partition:** titles remain indivisible, while domains held by the deceased are distributed across eligible children in a deterministic round-robin allocation.
- **Seniority:** the oldest eligible child succeeds.
- **Elective:** the player records the elected successor and that person must remain eligible.
- **Designated heir:** the player records a living successor; if that person is not eligible at succession, the rules fall back to the policy's available candidates.

If no children survive, the initial collateral fallback is the living spouse, then living siblings, then living parents. If no eligible successor exists, the title becomes vacant. The system does not silently invent a blood relative.

## Titles and domains

The title ladder is sequential: Knight/Dame, Baron/Baroness, Viscount/Viscountess, Count/Countess, Marquess/Marchioness, Duke/Duchess, Archduke/Archduchess and High Protector/First Warden. A new rank cannot skip an intervening rank. Each title records its holder, domain, jurisdiction, obligations and legitimacy.

Domains track prosperity, security, food and legitimacy. Annual passage reduces food by one. If food and security remain above the safety threshold, prosperity and legitimacy improve modestly; otherwise they decline. Players can invest in food, security and prosperity. This is a first economic pressure loop, not yet a full tax, labour, trade, construction or logistics simulation.

## Persistence

The house state is serialized as ordinary JSON-compatible dictionaries in the existing offline campaign save under `world_flags.chronicle_house_state`. The title-screen Chronicle entry loads the newest campaign and routes to the founder epilogue until unlocked, then to the house mode. No server or online account is required.

## Test command

```sh
godot --headless --path . --script res://tests/test_chronicle_dynasty.gd
```

The test covers initialization, parent/child links, marriage restrictions, traits, succession law validation, domain and title creation, rank progression, JSON normalization, annual aging, death and inheritance, equal partition and elective succession.

## Deliberate next steps / current limitations

This is a playable systems foundation, not the complete Crusader-Kings-like mode. It does not yet include autonomous AI houses, multiple independent kingdoms, diplomacy, wars, sieges, court positions, education, pregnancy/fertility simulation, adoption, guardianship, illness/injury, title claims, laws, tax collection, trade routes, construction queues, map ownership, or a multi-house campaign map. Those should be added in separate tested layers rather than implied by this first screen. Traits currently have no mechanical modifiers. Marriage is a recorded relationship; the system does not simulate consent, cultural compatibility or marriage diplomacy. The initial UI is a functional vertical control stack and requires device-specific layout/playtesting.
