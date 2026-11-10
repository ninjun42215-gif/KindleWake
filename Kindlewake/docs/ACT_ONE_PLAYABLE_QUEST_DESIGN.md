# Act I — Playable Quest Gameplay

This document describes the first playable gameplay pass for the five Kaer Sethorn / Sallow Crossing quests. The intent is to prevent the opening chapter from becoming five copies of a dialogue choice menu.

## Quest identity and mechanics

| Quest | Primary mechanic | Skill being tested | Narrative payoff |
|---|---|---|---|
| The Blocked Well | Ordered restoration puzzle | Safety, diagnosis and process | Clean water returns to the keep |
| Roof Before Banner | Material selection and repair-sequence puzzle | Observation and prioritisation | The wounded have a dry hall before the house banner is raised |
| The Last Convoy | Tactical route/formation decisions followed by a cinematic boss confrontation | Protecting civilians, controlling space and reading an enemy's commitment | The convoy manifest is recovered; families and supplies are accounted for |
| A Name on the Toll Book | Evidence deduction puzzle | Chronology, authority and witness protection | A forged toll order is authenticated without needlessly exposing families |
| The First Oath | Cinematic confrontation, interactive response and a final oath choice | Legitimacy, restraint and institutional accountability | The household publicly accepts a duty to the Sethmarch |

## Implementation notes

- Each quest is launched from its existing in-world story spot and opens a dedicated full-screen challenge scene.
- The five challenges have separate authored stage content, not one generic quiz prompt.
- Choices are validated. A wrong answer explains that the choice puts people or evidence at risk and allows another attempt; it does not softlock the campaign.
- Successful completion writes the established GameState.world_flags used by the Act I quest gates and saves through the existing local campaign save path.
- The Last Convoy and First Oath include authored boss-confrontation beats with meaningful counterplay choices. In this first pass these are cinematic, choice-driven encounters, not yet full tactical BattleController encounters with animated boss units. A later combat pass should replace or extend these beats with bespoke tactical battle definitions while preserving their story gates and outcomes.
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
