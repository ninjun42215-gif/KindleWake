# Character Traits and Personality — Implementation Notes

## Delivered in this branch

This is the first runtime implementation slice of the KindleWake trait/personality design. It adds a data-driven foundation without replacing the existing company, character-sheet, equipment, rune, battle, or save systems.

- `data/traits.json`: 69 enduring trait definitions across personality, psychological, intelligence, combat, social, physical, leadership, lifestyle, morality, and magical categories, plus five derived synergies.
- `scripts/core/trait_system.gd`: trait validation, opposing-trait checks, acquisition/removal history, permanent-trait protection, evolution chains, additive stat effects, and non-stacking synergies.
- `data/trait_events.json`: 16 reusable event definitions covering courage, protection, study, oaths, sharing, healing, expeditions, combat milestones, betrayal, failure, reconciliation, and loss.
- `scripts/core/personality_system.gd`: bounded stress, stress bands, bounded memories, deduplicated behavior evidence, contextual event requirements, and event-driven trait awards.
- `CharacterSheet`: traits, trait history, stress, memories, behavior evidence, and ambition state are stored with the character. Trait bonuses are calculated from base stats + equipment + runes + traits and never written back into base stats.
- `GameData` and `GameState`: load the catalogue and expose campaign APIs for recording evidence, resolving authored character events, and progressing ambitions.
- `PartyScreen`: shows traits and their effects, active synergies, stress band, current ambition summary, and recent memories in the existing character sheet. The current Company layout and gear/rune/shop tabs remain intact.
- `tests/run_tests.gd`: adds coverage for catalogue loading, acquisition, conflicts, duplicate prevention, derived effects, synergies, evolution, permanent-trait protection, event awards, duplicate evidence, stress bounds, ambitions, serialization, and legacy character data.

## Compatibility and safety

- The save envelope remains schema 4. New character fields are optional nested data; old character records load with empty traits, zero stress, and empty memories/behavior/ambition.
- No character portrait or sprite reference is fabricated. No visual identity is changed by this system. When portrait work is added, each portrait must be verified against that exact character's existing sprite identity.
- Temporary conditions such as Poisoned, Exhausted, and Injured are not added to the enduring trait list; they remain in the existing battle/status-effect domain.
- A tactical retreat does not award Cowardly. Trauma is distinct from cowardice. Mental-health-related descriptions avoid treating distress as a moral failing.
- Permanent traits cannot be removed through the ordinary removal API; a story-resolution override is required.
- Trait acquisition is deterministic and evidence-driven. Duplicate evidence IDs are ignored; no per-frame or random permanent-trait rolls occur.
- Synergies are derived from compatible trait combinations and do not consume another trait slot or permanently duplicate a trait.

## Integration API

Campaign/story code can use the following GameState methods:

- `record_character_behavior(character_id, behavior_id, amount, evidence_id)`
- `resolve_character_event(character_id, event_id, source = "campaign_event")`
- `progress_character_ambition(character_id, amount)`

A story event should record meaningful evidence with a unique evidence ID, then resolve the corresponding event definition. Event requirements are checked against the character's recorded behavior. The event call records a bounded memory and applies its authored stress delta even when the trait-award threshold has not yet been reached.

CharacterSheet also exposes `begin_ambition`, `advance_ambition`, and `adjust_stress`. Ambitions currently support objective text, progress, optional deadline metadata, and completion state; reward/failure resolution and a full ambition catalogue remain future work.

## Explicitly not complete yet

This branch is a working foundation, not the entire long-term design target. It does **not** claim to deliver the proposed 300-trait encyclopedia or 200-event library. The initial library is 69 traits and 16 event templates. Further work is required for:

1. Expanding and balancing the full 300-trait catalogue with category quotas and no duplicates.
2. Expanding event templates toward 200 and connecting real campaign, combat, training, exploration, crafting, and dialogue outcomes to evidence IDs.
3. Character-specific starting personalities, authored ambitions, trait acquisition sources, relationship arcs, and recovery/rehabilitation quest content.
4. Separate affinity/trust/respect relationship dimensions while preserving the existing loyalty system.
5. Trait-aware companion AI decisions, dialogue checks, campaign rewards, and supported profession/crafting hooks.
6. Full trait detail/history/filter UI and touch-tested portrait integration.
7. Godot headless tests, scene smoke tests, Android export, and physical-device validation on the exact PR head.

Do not seed traits onto the existing named cast merely from class or combat stats. Starting personalities must be grounded in approved character writing and consistent with the exact sprite/portrait identity.
