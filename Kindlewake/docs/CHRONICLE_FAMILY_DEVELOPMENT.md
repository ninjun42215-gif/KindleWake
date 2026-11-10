# Chronicle of Houses — Family Development Layer

This layer extends the first playable dynasty foundation. It remains gated by the founder's verified natural old-age death and uses the existing offline campaign save.

## Guardianship and education

- Children aged 0–16 may have a living adult guardian recorded.
- Education can begin from age 6 through 15, and requires a living adult guardian.
- Five education focuses are available: martial, stewardship, diplomacy, learning and arts.
- Education completes once the student reaches age 16 or older and is still living.
- Completion grants a defined trait: martial → Brave, stewardship → Diligent, diplomacy → Diplomatic, learning → Scholarly, arts → Witty.
- The education record preserves its focus, guardian, start year, completion year and earned trait.

Education is a deterministic authored progression choice, not a school simulation or a stat optimisation system.

## Adoption

A living adult may adopt a living child aged 16 or younger. Birth-parent records are preserved separately from legal parentage, and the adoptive parent is added to the family tree. A child can have one recorded adoptive parent in this first slice. The system blocks adoption that would create a close-family relationship under its current ancestry rules.

## Household council

The house can appoint five offices:
- Steward
- Marshal
- Chancellor
- Spymaster
- Concord Legate

Appointments require a living adult. One person cannot occupy two offices simultaneously in this model. Council membership is persistent and appears in the Chronicle summary. These offices are house-level roles; they do not yet run independent AI turns or strategic subsystems.

## Title claims

A living person can record a claim to an existing title under one of three bases: inheritance, grant or service. Claims retain their basis, status and year. The player can recognize or reject a pending claim; recognition transfers the title and updates all title-holder references. This is a peaceful claim-resolution mechanic, not a war or siege system.

## Persistence and validation

Education, guardian, adoption, council and claim data are stored in the house-state dictionary inside the existing offline save. The restore path sanitizes malformed relationship and claim records and removes invalid council appointments.

Run:

```sh
godot --headless --path . --script res://tests/test_chronicle_family_development.gd
```

The dedicated test covers guardian requirements, education gates and trait awards, adoption with preserved birth parentage, council restrictions, title claim duplication and resolution, and JSON save normalization.

## Current boundaries

No autonomous court AI, education events, fertility or pregnancy simulation, adoption quests, cultural compatibility, court intrigue, claim wars, military levies, taxes or inter-house diplomacy are implemented here. These are separate future layers. The present implementation gives the player deterministic family-development and governance records without pretending to simulate the larger political world.
