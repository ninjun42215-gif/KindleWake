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
- The Last Convoy and First Oath launch dedicated tactical BattleController encounters with boss-grade units, signature skills, supporting enemies, authored battlefields, commander objectives and story-specific victory flags. The story challenge resumes after the battle result.
- Both commanders have a one-time, persisted phase transition at a data-authored HP threshold. Hask becomes faster and stronger, recovers health and unlocks Fordbreaker Cleave; the Ash Bailiff gains strength and armour, recovers health and unlocks Final Edict. The existing tactical AI can select these newly unlocked damage skills.
- Phase transitions emit battle events for a distinct on-field burst and phase callout, using the existing lightweight VFX renderer rather than claiming bespoke sprite animations or particle assets.
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

These are data-driven tactical encounters using existing combat systems. The first phase pass uses a reusable commander HP-threshold rule, phase-specific stat/armour recovery, newly unlocked signature damage skills and lightweight burst/callout feedback. Bespoke animated boss sprites, custom attack animations and authored particle assets remain future polish work; current phase effects use the existing renderer.
