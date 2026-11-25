# Core engineering handoff — 2026-11-25

**Repository:** https://github.com/ninjun42215-gif/KindleWake  
**Project:** `Kindlewake/` · Godot 4.2.2 · Android / GL Compatibility  
**Base main:** `13f66ec19476c9af5ed2b5c81af95e4d8a026876`  
**Branch:** `fix/holding-garrison-reserve-integrity-2026-11-25`  
**Pull request:** [#179 — Cap holding garrisons and validate troop reserve transfers](https://github.com/ninjun42215-gif/KindleWake/pull/179)  
**Implementation commit:** `f0e3dbfd5f3e9224a8df31165c96db44a2ffef07`

## Implemented

Hardened strategic troop recruitment and reserve-to-garrison transfers in `scripts/core/empire_development_system.gd`.

- Reserve assignment now respects the existing 999-soldier maximum used by the direct garrison assignment API.
- If a request exceeds the remaining capacity, only the number that fits is transferred; the remainder stays in the reserve.
- Unknown troop IDs and zero/negative assignment quantities are rejected.
- Reserve containers, troop counts and garrison counts are checked before mutation.
- Recruitment rejects malformed reserve containers/counts before spending provisions or returning a treasury deduction.
- Failed operations preserve the input `world_flags` state.

## Root cause

`assign_recruits_to_garrison()` previously added the selected reserve count directly to `holding_garrison_<id>`, bypassing the 999 clamp in `EmpireEconomySystem.assign_garrison()`. It also trusted nested `world_flags` values as Dictionaries and numeric counts. A malformed schema-4 save could therefore create an invalid garrison or trigger a runtime type error during recruitment/assignment.

## Regression coverage

Added `tests/test_empire_development_integrity.gd` and registered it in `tools/build_apk.py`'s strict campaign-test list. The script checks:

- Valid recruitment and reserve assignment.
- Partial transfer at the 999-soldier cap, preserving unassigned reserve troops.
- Unknown troop IDs.
- Zero and negative assignment amounts.
- Malformed reserve containers and troop counts.
- Malformed garrison counts.
- No resource or state mutation on rejected operations.

The existing heavily shared `tests/run_tests.gd` was intentionally left untouched to avoid conflicts with open PRs #81, #174 and #177.

## Changed files

1. `Kindlewake/scripts/core/empire_development_system.gd`
2. `Kindlewake/tests/test_empire_development_integrity.gd` (new)
3. `Kindlewake/tools/build_apk.py`
4. `Kindlewake/docs/CORE_ENGINEERING_HANDOFF_2026-11-25.md` (this file)
5. `Kindlewake/docs/NEXT_AI_START_HERE.md`

## Compatibility and preservation

- No save schema/version change or destructive migration.
- Existing valid reserve dictionaries and integer/integer-valued numeric counts remain accepted.
- Existing troop IDs, recruitment prices, provisions costs, building effects, story and player data are unchanged.
- Over-cap garrisons already present in an old save are not rewritten by a failed transfer. Use the existing direct garrison assignment path to set an intentional valid count.
- No workflow definitions, permissions, secrets, release settings or repository settings were changed.

## Verification status at implementation commit

**Not yet verified.** The implementation commit was pushed and PR #179 opened, but no Godot import, strict test, scene smoke, APK export, or exact-head CI result is claimed in this handoff. Check the latest PR head and require Project Health Audit, Workflow YAML Lint, Version Sync and Android Build on that exact SHA. The new standalone regression script must report zero failures.

Physical Android device testing remains separate; CI does not establish handset compatibility.

## Coordination and remaining risks

- PR #46 is an old, heavily diverged Royal Administration candidate; it changes a different legacy management layer and was not modified.
- PR #177 owns the Merchant Council economy calculation; PR #174 owns equipment enhancement stats; PR #170 owns battle turn restoration. This branch does not touch their files.
- PR #164 owns Android release/emulator workflow hardening. Its workflow changes were not modified.
- Keep PR #179 draft and unmerged until exact-head checks and review complete.
- Main remains unchanged at `13f66ec19476c9af5ed2b5c81af95e4d8a026876`.
