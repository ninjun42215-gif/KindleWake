# Act I — Playable Quest Gameplay

This document describes the first playable gameplay pass for the five Kaer Sethorn / Sallow Crossing quests. The intent is to prevent the opening chapter from becoming five copies of a dialogue choice menu.

## Quest identity and mechanics

| Quest | Primary mechanic | Skill being tested | Narrative payoff |
|---|---|---|---|
| The Blocked Well | Ordered restoration puzzle | Safety, diagnosis and process | Clean water returns to the keep |
| Roof Before Banner | Material selection and repair-sequence puzzle | Observation and prioritisation | The wounded have a dry hall before the house banner is raised |
| The Last Convoy | Tactical route/formation decisions followed by a full tactical boss battle | Protecting civilians, controlling space and reading an enemy's commitment | The convoy manifest is recovered; families and supplies are accounted for |
| A Name on the Toll Book | Evidence deduction puzzle | Chronology, authority and witness protection | A forged toll order is authenticated without needlessly exposing families |
| The First Oath | Cinematic confrontation, full tactical boss battle and a final oath choice | Legitimacy, restraint and institutional accountability | The household publicly accepts a duty to the Sethmarch |

## Implementation notes

- Each quest is launched from its existing in-world story spot and opens a dedicated full-screen challenge scene.
- The five challenges have separate authored stage content, not one generic quiz prompt.
- Choices are validated. A wrong answer explains that the choice puts people or evidence at risk and allows another attempt; it does not softlock the campaign.
- Successful completion writes the established GameState.world_flags used by the Act I quest gates and saves through the existing local campaign save path.
- The Last Convoy and First Oath launch dedicated tactical BattleController encounters with boss-grade units, signature skills, supporting enemies, authored battlefields, commander objectives and story-specific victory flags. The story challenge resumes after the battle result. Unique multi-phase boss AI, bespoke animated boss sprites and custom attack VFX remain future polish work.
- The initial arrival priority remains respected: if the player already completed the well or roof through the arrival decision, that work remains complete and the corresponding quest is not replayed.
- All content is offline and uses the existing Godot scene and campaign state architecture.

## Accessibility and failure handling

- Every choice is a large button suitable for touch input.
- The player can leave a challenge and return to the town map without losing completed campaign progress.
- Incorrect choices can be retried; no timer, dexterity check or colour-only cue is required.
- Quest completion is saved before returning to exploration.
- Challenge progress is deliberately short and checkpointed by quest completion. A future polish pass should add explicit mid-challenge resume state if stages become longer or include real-time sequences.

## Acceptance checks

- Each of the five quest IDs has at least two stages and multiple options per stage.
- Convoy and First Oath include boss-confrontation stages.
- Completion writes the exact flags consumed by OpeningActOneQuestSystem._act_one_ready() and inspect().
- The campaign can return to Location.tscn and resume the same town map.
- Godot headless parsing and the project's full test command must pass before this work is considered runtime-verified.


## Tactical boss battle follow-up

The Last Convoy and The First Oath now launch dedicated tactical encounters through the existing Battle scene and BattleController.

- **Hask Gravelteeth:** separate boss-grade character definition, increased health and strength, Power Strike, roadwolf retainers, and the Sallow Ford river-crossing map.
- **The Ash Bailiff:** separate boss-grade character definition, increased health and armour, Radiant Judgement (Holy Smite II) and Greater Mending, retainers, and a distinct Hall of Ash arena with pillars for cover.
- Both battles use the existing tactical turn queue, movement, terrain, attack, skill, enemy AI, party preparation, battle rewards and commander-defeat victory rules.
- A successful boss defeat sets a dedicated campaign flag and saves the campaign after battle rewards are applied.
- The battle result screen returns to the active quest challenge. The challenge resumes at its boss stage, checks the victory flag and advances to the next story beat. A defeat returns to the same challenge so the boss can be retried.
- Boss battles are not exposed as random overworld encounters and do not show the normal overworld flee option.

These are data-driven tactical encounters using existing combat systems. Unique multi-phase boss AI, bespoke animated boss sprites and custom attack VFX remain future polish work; the current boss identity comes from their dedicated stats, skills, retainers, terrain and story-specific victory conditions.


## Multi-phase boss behavior

Both Act I commanders now have two authored health-threshold transitions. They are evaluated after damage resolution and before commander-defeat checks. Hask escalates into a desperate forward surge and then a high-accuracy finishing assault. The Ash Bailiff moves from renewed conviction to a precise final-clause assault. Phase payloads adjust combat stats and morale, with a small one-time recovery on the first transition. Phase markers live in the serialized BattleUnit status dictionary, so restored battles do not replay a transition. This is combat-state and battle-log feedback only; bespoke boss animations, cinematic camera work and custom VFX assets are not included.

## Boss visual presentation follow-up

- Boss phase events now trigger a dedicated attack-pose beat, a floating phase callout, a battle-log announcement and an animated radial effect.
- Hask's phase effect uses a hot, expanding impact ring with rotating outward pressure rays. His persistent identity marks emphasize a brutal iron-and-ember silhouette.
- The Ash Bailiff's phase effect uses a restrained golden seal geometry and radial spokes. His persistent identity marks evoke the authority seal that underpins his false warrant.
- Phase effects are drawn with the existing lightweight vector renderer; no external textures, shaders or high-cost particle nodes are required.
- Internal boss-phase persistence markers are hidden from ordinary ailment/status pips.
- These are implemented presentation effects using the current placeholder/sprite-sheet rendering path. They are not bespoke frame-by-frame boss sprite sheets, voice acting or cinematic camera sequences.

- Hask's successful weapon hits use a heavy double-sweep impact effect; the Ash Bailiff's damaging skills use a gold seal-and-verdict strike rather than the generic elemental burst.


## Boss-specific tactical AI

The two Act I commanders now receive encounter-specific plans through BattleAI; all other units continue to use the existing scoring AI.

- **Hask Gravelteeth — formation breaker:** evaluates legal movement cells, scores Power Strike against exposed targets, rewards isolation and finishing opportunities, and otherwise chooses a weapon attack using the same formation pressure. He approaches normally when no attack is available.
- **The Ash Bailiff — retainer guardian:** evaluates Greater Mending against wounded allies, with extra priority for retainers under immediate pressure. When urgent healing is not justified, he compares Judgement against weapon attacks and weights targets who threaten his formation.
- **Rules and persistence:** boss decisions still execute through BattleController.try_move, try_skill, and try_attack; the normal one-move/one-action economy, MP costs, range checks, line-of-sight rules and battle saves remain authoritative. No extra boss turn or hidden damage is granted.
- **Scope:** behavior is keyed to the corresponding Act I battle and commander character ID. It does not change the AI of ordinary enemies, unrelated commanders, or player Auto Battle.
- **Coverage:** headless test cases exercise Hask's isolated-target Power Strike, the Bailiff's retainer healing priority, and his offensive Judgement choice. Run the project's Godot test command before treating runtime behavior as verified.


## Boss balance pass and simulation coverage

The Bailiff's healing policy is deliberately conservative: Greater Mending is considered only when an ally is at or below 50% HP, then pressure on that ally raises its priority. This prevents the earlier 72% threshold from spending MP on routine chip damage and leaves more MP for Judgement. The boss remains free to attack when no ally meets the urgent-healing rule.

The headless test suite now includes seeded AI-vs-AI simulations for both Act I boss encounters. It reports player/boss outcomes, unfinished encounters, average turn count, and the commander's offensive skill/heal/attack frequency. The simulations use the real BattleController turn/action pipeline and a bounded turn guard; they are intended as a repeatable balance diagnostic, not proof that a difficulty target has been met until the Godot test runner is executed and the reported results are reviewed.
