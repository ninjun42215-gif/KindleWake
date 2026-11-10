# Act II — Broken Seals: Playable Scenario Implementation

## Scope

This implementation turns the first Orrowen arc into three offline playable scenarios. The player must complete the Sethmarch oath (chapter_1_complete) before any Act II scenario opens.

All scenario state is stored in GameState.world_flags and written through the existing local campaign save path. No network service, remote account or hosted backend is introduced.

## Scenario 1 — The Boundary Tree

**Location:** Thornmere  
**Mechanic:** evidence reconstruction / survey sequence

1. Record the age and direction of coppice cuts without claiming more than the evidence proves.
2. Compare tenant foundation stones with the forester's account of the maintained path.
3. Evaluate the steward's newer map against the older physical evidence.
4. Choose a durable settlement: shared stewardship or a temporary survey pending fuller evidence.

The scenario records named evidence facts (coppice marks, tenant stones, forester path, steward map) and the chosen settlement. It does not turn a survey into an automatic legal verdict.

## Scenario 2 — The Orrowen Hearing

**Location:** Elderbough  
**Mechanic:** testimony cross-check / contradiction analysis

1. Compare the tenant's double-levy account with dates and the veteran's recollection.
2. Distinguish a legal map from shared-use practice.
3. Separate the fact of a second collection from the still-unproven authorisation.
4. Choose to protect the witness with identifying details sealed, or publish the verified record with names withheld.

The hearing stores verification, witness protection and publication as separate facts. It deliberately avoids a simplistic culprit reveal.

## Scenario 3 — The Escort That Changed Course

**Location:** Sallow Crossing  
**Mechanic:** route and formation planning followed by a tactical battle and political decision

1. Move civilians along the reed bank rather than the exposed ford.
2. Set a defensive screen: Bram anchors the bridge, Sela covers the ridge and Wystan remains with civilians.
3. Fight Writ-Captain Odran Vale and his retainers in a dedicated tactical encounter.
4. Decide whether to obey the writ, grant sanctuary or negotiate temporary passage and accept a political debt.

The battle uses the existing tactical engine and returns to the Act II challenge scene. Victory sets act2_escort_captain_defeated; the post-battle political choice cannot be made before that flag exists. Defeat allows the player to retry without losing the scenario.

## Companion and consequence integration

- Sela helps interpret the coppice cuts and challenges unsupported conclusions in the hearing.
- Bram anchors the narrow bridge defence.
- Brother Wystan remains with the displaced families and frames sanctuary as a practical duty.
- Named outcome flags distinguish shared stewardship, temporary survey, witness protection, publication, sanctuary and negotiated passage.
- Negotiated passage records a political debt to Orrowen rather than silently granting a free resolution.

These are authored scenario beats using the existing party cast; they do not yet add full companion loyalty cutscenes or new recruitable characters.

## Technical changes

- New scripts/core/act_two_quest_system.gd: progression gates and validated, idempotent consequence rules.
- New scripts/ui/act_two_quest_challenge.gd and ActTwoQuestChallenge.tscn: three stage-based playable scenarios with local save/resume.
- location_scene.gd: story spot dispatch and challenge launch.
- locations.json: scenario spots in Thornmere, Elderbough and Sallow Crossing.
- characters.json: Writ-Captain Odran Vale.
- battles/battle_act2_escort.json: dedicated 20×14 crossing encounter, commander objective, retainers, campaign victory flag and custom return scene.
- game_data.gd: registers the encounter for exported builds.
- tests/run_tests.gd: checks progression gates, consequence branches, battle registration, unit references and story spot placement.

## Validation and remaining work

The new JSON data was parsed and checked for terrain dimensions, character references and battle registration. The challenge and system scripts have not been run through Godot's parser or runtime in this environment.

Still recommended after this foundation:
- Run the full headless Godot test suite and resolve any engine-level issues.
- Add animated survey overlays and an evidence-board presentation.
- Add voiced or portrait-based witness scenes and companion-specific relationship beats.
- Add tactical optional objectives for separated families and recovery of the original writ; the current encounter's primary objective is to defeat the commander.
- Feed Act II consequence flags into later campaign scenes and the final chronicle.
