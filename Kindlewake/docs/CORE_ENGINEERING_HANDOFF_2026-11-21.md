# Core engineering handoff — 2026-11-21

**Repository:** https://github.com/ninjun42215-gif/KindleWake  
**Project:** `Kindlewake/` · Godot 4.2.2 · GL Compatibility · Android  
**Base:** `main` at `13f66ec19476c9af5ed2b5c81af95e4d8a026876`  
**Working branch:** `fix/battle-status-death-turn-advance-2026-11-21`  
**Status:** implementation and regression test committed; exact-head CI pending; no merge performed.

## Reproduced gameplay defect

Battle turn selection could soft-lock when a damage-over-time rune effect defeated a unit at the start of that unit's turn.

The prior flow set `active_id` to the selected unit, ticked its statuses, and returned immediately when the burn effect reduced HP to zero. If the death did not satisfy a battle-ending condition (for example, a non-commander enemy or a non-protagonist ally), the controller retained a dead active unit and never selected the next living combatant. `can_act()` then rejected all actions for that active unit.

## Implemented

- Reworked `BattleController._start_next_turn()` to process dead, stunned and routed turn skips iteratively rather than recursively.
- A non-terminal status death now returns control to the turn-selection loop, which advances to the next living unit.
- Shock still consumes the affected unit's turn and applies the same CTB delay; routed-unit skip guard remains 64.
- Terminal deaths still run `_check_end()` and stop the queue when victory/defeat is recorded.
- Added an exact regression to `tests/test_campaign_continuity.gd`, which is already executed by `tools/build_apk.py` as part of the strict campaign test scripts. The test applies lethal burn to a non-terminal combatant before `begin()` and asserts that the battle remains active with a different living active unit.

## Changed files

- `Kindlewake/scripts/battle/battle_controller.gd`
- `Kindlewake/tests/test_campaign_continuity.gd`
- `Kindlewake/docs/CORE_ENGINEERING_HANDOFF_2026-11-21.md`

No story, combat formulas, rune definitions, save schema, player data, Android permissions or network behavior changed.

## Verification state

CI has not yet run for the final PR head. Do not claim the regression passes until the strict Android build workflow completes on the exact head. Required checks: Build Android APK, Project Health Audit, Workflow YAML Lint and Version Sync. The campaign continuity test is run independently by the Android build script; its output is part of the test logs.

## Repository coordination and known risks

- This change is based on live main SHA `13f66ec19476c9af5ed2b5c81af95e4d8a026876`.
- The changed runtime/test files do not overlap the currently inspected active PRs #151, #160, #166, #167, #168 or #169, nor boss/CI PRs #63, #66 and #78.
- PR #168's latest observed Android build (#44666027582) exported and uploaded its APK, but its emulator job failed because `pidof com.kindlewake.game` found no surviving process after the 30-second launch window. The action log shows the emulator initially reported `adb: device offline`, then booted; the process-survival check still failed. The uploaded diagnostic logs should be inspected before attributing this to a renderer or game-code defect.
- Physical Android device QA remains outstanding.
- Root README and several older handoff files contain stale checkpoint SHAs; this dated handoff is scoped to this branch and does not silently rewrite files currently being edited by other PRs.

## Review checklist

1. Confirm the new campaign continuity regression fails against the old turn-selection logic and passes with this fix.
2. Confirm shock and routed-unit skip behavior remains unchanged.
3. Confirm a terminal status death still emits the existing battle-ending outcome.
4. Run all required workflows on the exact final PR head and inspect any failed logs.
5. Keep this PR unmerged; integration and merge are outside this work's authority.
