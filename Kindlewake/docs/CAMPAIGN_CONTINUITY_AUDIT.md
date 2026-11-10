# Five-Act Campaign Continuity Audit

## Run
From the Godot project directory:

```sh
godot --headless --path . --script res://tests/test_campaign_continuity.gd
```

The dedicated test walks the rule systems in campaign order: Act I quest actions; Act II boundary, hearing and escort; Act III bridge victory, banner and crossing; Act IV archive access, record and witness; Act V route, evidence board, three crises and final audience. It also exercises the Chronicle founder gate and JSON normalization.

## Persistence integration
- `GameState.campaign_payload()` now includes the Chronicle state alongside `world_flags`.
- `GameState.load_campaign()` normalizes the Chronicle state from the save. Older campaign saves without this key start with a locked Chronicle.
- The Act V final audience records the first three Chronicle milestones in order: campaign completed, became last Emperor, Empire dissolved.
- The late-life epilogue and natural old-age death remain separate future gameplay milestones. They are not fabricated at the Act V ending, and battle death cannot unlock the Chronicle.
- The Chronicle state, not a world flag, is the authority for unlock status.

## Scope limits
This is a deterministic rules-level continuity test, not an end-to-end UI automation or Godot runtime claim. It simulates the tactical victory flags at the Act II escort and Act III bridge boundaries. The full five-act scenes, all save/load paths and the late-life epilogue still require a Godot headless run and in-engine playthrough.
