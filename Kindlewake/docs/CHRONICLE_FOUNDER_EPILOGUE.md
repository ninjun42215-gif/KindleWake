# Chronicle of Houses — Founder Epilogue

## Purpose and unlock contract

Chronicle of Houses is a post-campaign generational continuation. It is not available during the five-act campaign and does not begin when the protagonist merely wins the final battle.

The founder transition is deliberately ordered:

1. The five-act campaign is complete.
2. The protagonist is recorded as the last Emperor.
3. The Empire is formally dissolved.
4. The founder completes the authored late-life epilogue.
5. The founder reaches the natural old-age threshold and dies with explicit `old_age` provenance.
6. Only then does Chronicle of Houses unlock.

The existing `ChronicleSystem` remains the final authority. It rejects skipped milestones, missing founder identity, battle-death provenance, and serialized `unlocked=true` claims unsupported by the milestone chain.

## Playable epilogue

The new `ChronicleEpilogue.tscn` is reachable from the Act V ending and from the title screen's Founder’s Epilogue / Chronicle entry. It requires Act V completion and the Empire-dissolved milestone.

The founder makes three reflective choices:
- **The people:** leave authority in local assemblies.
- **The companions:** preserve their names and honest disagreements.
- **The Concord:** require public review of each realm's obligations.

Once all three are recorded, the epilogue milestone is written. The founder then advances in five-year narrative passages until age 70. The natural passing is an authored epilogue action, not a combat result or a player-controlled instant-death option. The founder record stores identity, age, date, final title, ending ID and cause.

The character creator currently has no age field. Until that is added as a first-class character attribute, the epilogue initializes the founder at age 30 when no explicit `age` value exists in the saved creation profile. This fallback is localized to the epilogue system and is not a claim that the character creator already models age.

## Persistence and recovery

All epilogue progress is stored in the existing offline campaign `world_flags` payload under `chronicle_epilogue_state`. The founder milestone state remains in `chronicle_state`. The title-screen entry loads the newest campaign slot before routing, so a player can leave and resume the epilogue without losing reflection choices or age passages.

## Validation

Run:

```sh
godot --headless --path . --script res://tests/test_campaign_continuity.gd
```

The deterministic test now covers pre-dissolution blocking, all three reflections, epilogue completion, rejection of non-five-year passages, premature death rejection, age progression, JSON normalization, explicit old-age provenance, and final Chronicle unlock.

This environment does not include a Godot executable. The test has been committed but has not been run here. Scene parsing, device UI layout and full in-engine playthrough remain required. This PR does not implement the dynasty simulation itself (family trees, marriage, children, title jurisdictions, inheritance, cadet branches or generational AI); it creates the gated founder transition and unlock boundary for that next system.
