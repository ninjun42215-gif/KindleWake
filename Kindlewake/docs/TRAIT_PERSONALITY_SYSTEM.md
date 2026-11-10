# Character Traits and Personality — Implementation Notes

## Delivered in this branch

This is the first runtime implementation slice of the KindleWake trait/personality design. It adds a data-driven foundation without replacing the existing company, character-sheet, equipment, rune, battle, or save systems.

- `data/traits.json`: 69 enduring trait definitions across personality, psychological, intelligence, combat, social, physical, leadership, lifestyle, morality, and magical categories, plus five derived synergies.
- `scripts/core/trait_system.gd`: trait validation, opposing-trait checks, acquisition/removal history, permanent-trait protection, evolution chains, additive stat effects, and non-stacking synergies.
- `data/trait_events.json`: 40 reusable event definitions covering courage, protection, study, oaths, sharing, healing, expeditions, combat milestones, betrayal, failure, reconciliation, and loss.
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
- Trait acquisition is deterministic and evidence-driven. Duplicate evidence IDs are ignored; event instances can carry unique IDs; evolution requires configured behavior thresholds; no per-frame or random permanent-trait rolls occur.
- Synergies are derived from compatible trait combinations and do not consume another trait slot or permanently duplicate a trait.

## Integration API

Campaign/story code can use the following GameState methods:

- `record_character_behavior(character_id, behavior_id, amount, evidence_id)`
- `resolve_character_event(character_id, event_id, source = "campaign_event")`
- `progress_character_ambition(character_id, amount)`

A story event should record meaningful evidence with a unique evidence ID, then resolve the corresponding event definition. Event requirements are checked against the character's recorded behavior. The event call records a bounded memory and applies its authored stress delta even when the trait-award threshold has not yet been reached.

CharacterSheet also exposes `begin_ambition`, `advance_ambition`, and `adjust_stress`. Ambitions currently support objective text, progress, optional deadline metadata, and completion state; reward/failure resolution and a full ambition catalogue remain future work.

## Explicitly not complete yet

This branch is a working foundation, not the entire long-term design target. It does **not** claim to deliver the proposed 300-trait encyclopedia or 200-event library. The initial library is 69 traits and 40 event templates. Further work is required for:

1. Expanding and balancing the full 300-trait catalogue with category quotas and no duplicates.
2. Expanding event templates toward 200 and connecting real campaign, combat, training, exploration, crafting, and dialogue outcomes to evidence IDs.
3. Character-specific starting personalities, authored ambitions, trait acquisition sources, relationship arcs, and recovery/rehabilitation quest content.
4. Separate affinity/trust/respect relationship dimensions while preserving the existing loyalty system.
5. Trait-aware companion AI decisions, dialogue checks, campaign rewards, and supported profession/crafting hooks.
6. Full trait detail/history/filter UI and touch-tested portrait integration.
7. Physical-device validation on Android. Exact-head CI on `501e3abfa6877502254d8a60790f6a7818f30587` passed Godot 4.2.2 import, 8/8 scene smoke loads, 465 strict checks / 0 failures, balance report, signed Android export for both supported ABIs, Version Sync, Project Health Audit, and Workflow YAML Lint. Physical-device validation remains pending.

Do not seed traits onto the existing named cast merely from class or combat stats. Starting personalities must be grounded in approved character writing and consistent with the exact sprite/portrait identity.


## Companion relationship progression — added after the initial trait foundation

- `scripts/core/relationship_system.gd` tracks symmetric pair relationships across independent friendship, trust, respect, rivalry, affection, and romance dimensions. Every value is bounded from 0 to 100.
- `GameState.adjust_companion_relationship()` records authored changes with unique evidence IDs; duplicate evidence is rejected. `GameState.companion_relationship()` returns a safe read model and derives a relationship stage such as Acquaintances, Friendly, Mutual Respect, Trusted Allies, Close Friends, Rivals, or Romantic.
- Romance is never inferred from friendship or affection: it requires explicit authored romance evidence and sufficient trust. No automatic attraction, random drift, or forced pairing is introduced.
- Pair state, bounded history, and evidence IDs are persisted in the campaign payload. Existing schema-4 saves without this optional field normalize to an empty relationship map.
- This is a persistent rules/API foundation. Existing loyalty remains separate; a player-facing relationship journal, companion-specific story scenes, dialogue checks, and AI behavior hooks remain follow-up integration work.


## Authored recruitment relationship event

- Recruitment supports optional `recruit.relationship_on_join` dimensions. The effect is applied only after the roster transaction succeeds, using the first roster member as company lead.
- Maren Vey's Tideglass recruitment records a modest trust (+6) and respect (+8) bond with the company lead because the party completed the ledger expedition required for her to sail with them.
- Stable evidence IDs prevent repeated recruitment UI interactions from farming the same relationship reward. This remains separate from starting loyalty and does not imply romance.
- The shared recruitment helper is covered by regression tests; recruits without authored relationship metadata receive no automatic relationship bonus.


## Companion bond journal

- The Party Screen now shows a per-character companion bond journal alongside traits, memories, ambition and loyalty.
- Pair metrics (friendship, trust, respect, rivalry and affection), derived relationship stage, and latest authored event are displayed separately from company loyalty.
- Both regional and settlement Party Screen entry points pass campaign relationship state explicitly. The screen remains testable and does not read global autoloads.
- The journal is read-only: it never invents relationship gains, infers romance, or changes saved data.


### Authored Brinegate relationship consequences

The harbour-ledger decision applies relationship changes only for recruited companions with an explicit `recruit.relationship_on_ledger_choice` definition. Maren Vey gains trust and respect when the evidence is made public, and loses a smaller amount of each when it is withheld. The relationship event uses a stable quest/choice/character/dimension evidence key, so revisiting the UI or reloading a save cannot farm the reward. Companions without authored reactions are unaffected. These consequences are separate from company loyalty and do not infer romance.


### Companion tactical personality

Party battle definitions now carry each deployed character's enduring traits, stress, recent memory types, active ambition focus and authored bonds with other deployed companions. BattleUnit treats these as optional transient context and serializes them with safe defaults for older battle snapshots. The tactical AI uses explicit `battle_behavior` metadata on traits to adjust risk tolerance and support priority; high stress and recent traumatic/betrayal memories increase caution. An ambition affects tactics only when story code explicitly assigns `combat_focus` as `aggressive` or `support`. Healing decisions modestly favor trusted companions, while the existing HP threshold, tactical range and damage calculations remain authoritative.


## Personality event catalogue expansion — integration phase

The event library now contains 40 reusable definitions. The second set adds authored templates for defending wounded allies, sparing or executing surrendered foes, mentorship, advanced combat practice, standing against superior numbers, betrayal, difficult secrets, faction peace, expedition leadership, masterwork crafting, route discovery, supernatural catastrophe, relic purification, forbidden-pact choices, supported trauma recovery, accountability, and loyalty under hardship.

These are **data templates, not automatic triggers**. Campaign, battle, crafting, exploration, and dialogue systems must supply their own unique evidence IDs and call the existing GameState character-development APIs only after the player-visible outcome is committed. A template with no trait award may still record a memory and stress change for an explicitly authored story event. No generic combat heuristic should infer a moral choice, betrayal, romance, trauma diagnosis, or cowardice.

The strict test harness now checks that the expanded event library has at least 40 entries and that every template has a stable ID, name, description, requirements dictionary, and trait-award array. Trait award IDs are also checked against the loaded catalogue.

### Remaining integration work

- Connect the event IDs to real committed outcomes in existing quest, battle, training, crafting, exploration, and dialogue flows; never award evidence from a UI preview or an action that later fails.
- Add a data-driven ambition catalogue with eligibility, objective evidence, completion/failure outcomes, and rewards that already exist in the game.
- Expand the trait encyclopedia in curated, balanced batches; do not reach the 300 target by cloning effects or inventing unsupported professions/magic.
- Add a dedicated touch-friendly trait journal with filters, acquisition history, and detail views without disturbing the existing Company equipment/rune/shop navigation.
- Validate portrait references against each character's actual sprite identity before adding portrait art.


## Curated ambition progression

A new `data/ambitions.json` catalogue defines 12 ambitions with stable IDs, descriptive objectives, behavior evidence requirements, completion traits where appropriate, and stress recovery. GameData loads the catalogue from an explicit local JSON path so it is included in exported offline builds.

GameState exposes `assign_character_ambition(character_id, ambition_id)`. Assignment rejects unknown definitions, invalid objectives, and characters who already have an active ambition. The existing `record_character_behavior` API advances a matching active ambition only when new, non-duplicate behavior evidence is accepted. Completion can award the authored trait, reduce stress by the definition's stress reward, and append a bounded achievement memory. Duplicate evidence and unrelated behavior do not grant progress.

The ambition system intentionally does not invent gold, items, quests, romance, or faction outcomes. Future ambitions should reference only mechanics and authored evidence that exist in the game.

## Remaining integration

- Connect the 40 event templates to committed campaign, battle, training, crafting, exploration, and dialogue outcomes with unique evidence IDs.
- Add ambition failure/deadline handling only where the campaign has a reliable calendar and authored failure consequences.
- Expand the trait encyclopedia in curated, balanced batches; do not reach the 300 target by cloning effects or inventing unsupported mechanics.
- Add a dedicated touch-friendly trait journal without disturbing Company equipment, rune, or shop navigation.
- Validate every future portrait against the exact character sprite identity.
