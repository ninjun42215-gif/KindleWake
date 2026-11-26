# Core Engineering Handoff — 2026-11-26

**Repository:** https://github.com/ninjun42215-gif/KindleWake  
**Project:** `Kindlewake/` · Godot 4.2.2 · GL Compatibility · Android  
**Base main:** `13f66ec19476c9af5ed2b5c81af95e4d8a026876`  
**Branch:** `feat/governor-stat-bonuses-2026-11-26`  
**Pull request:** [#182 — Implement stat-based regional governor bonuses](https://github.com/ninjun42215-gif/KindleWake/pull/182)  
**Initial code/test head:** `1e9ec9a8f56fd6f40eebd2007a7505c4621dcdf3`  
**Corrected code/test head:** `4c464cd1102e24aa10a03d68597d7ac57aa5015c`

## Repository inspection and coordination

The live default branch was confirmed as `main` at `13f66ec19476c9af5ed2b5c81af95e4d8a026876`. Open PRs and recent commits were reviewed before implementation.

Relevant existing work:
- PR #177 changes `empire_economy_system.gd` and an economy regression case. This branch does not modify that runtime file or its test hunk.
- PR #179 changes `empire_development_system.gd`, its dedicated integrity suite and the APK test runner. This branch does not modify those files.
- PR #174 changes `character_sheet.gd` and progression tests. This branch does not modify those files.
- PR #164 owns Android/release QA workflows. No workflow or permission files were changed.
- PR #46 (261 ahead / 161 behind) and PR #81 (3 ahead / 146 behind) are heavily diverged legacy branches. Their old GameState/test changes were inspected but not used as implementation bases.
- Visual PRs #180 and #181 were left untouched.

## Implemented

Governor assignments were previously administrative labels only. The current GDD, README and handoff notes explicitly identified governor-specific gameplay bonuses as unimplemented.

This branch adds deterministic bonuses derived from each appointed companion's trained **base** attributes:
- Every 4 INT points above 6 grants +1% monthly realm income, up to +2% per governor.
- Every 4 LDR points above 6 grants +1 realm stability per empire turn, up to +2 per governor.
- Realm-wide caps are +8% income and +3 stability per turn.
- Only currently held regions and roster-backed governor assignments count.
- A malformed duplicate assignment cannot count the same companion twice.
- Income bonuses apply after the existing tax and policy multipliers. Stability bonuses are added to the existing monthly stability delta.
- The Realm screen now displays aggregate influence and each appointed governor's contribution.

The implementation uses trained base attributes only. Equipment, runes and temporary battle effects do not change administrative bonuses.

## Changed files

1. `Kindlewake/scripts/core/empire_system.gd`
2. `Kindlewake/scripts/core/game_state.gd`
3. `Kindlewake/scripts/ui/empire_screen.gd`
4. `Kindlewake/tests/run_tests.gd`
5. This handoff document.

## Exact implementation commits

- `bb0807e2d95eac657efa6fffc300246378859e12` — add bounded governor effect calculation and apply it to realm finance/stability.
- `31c5ea3dc8f09a09c5e2f57d510ddadd951f5985` — supply appointed governors' trained base stats to realm settlement and summary.
- `7651421c4eb67065312dcc9f66e74bf41174ad83` — display governor effects in the Realm UI.
- `1e9ec9a8f56fd6f40eebd2007a7505c4621dcdf3` — add governor bonus regression coverage.

The handoff commit is documentation-only and is the final PR head after this file is created; use PR #182 metadata for its exact SHA.

## Regression coverage added

The realm-administration test now covers:
- Attribute threshold behavior at 9 and 10.
- INT-based income bonus.
- LDR-based stability bonus.
- Original finance behavior when callers omit governor stats.
- Exclusion of a governor assigned to a foreign/unheld region.
- De-duplication of a malformed repeated governor assignment.
- Stacking across distinct governors within the realm stability cap.
- Settlement into the existing shared treasury and realm stability.
- Summary/UI data matching the effects used by settlement.

Expected deterministic fixture: a single governor with INT 14 / LDR 14 grants +2% income and +2 stability. With the existing 15% tax and Royal Roads policy on a 100-gold base income fixture, the final monthly income is 118 versus 116 without governor stats.

## Compatibility and safety

- No new persistent fields, save-schema/version change, migration or player-data rewrite.
- New stat-map parameters are optional and default to empty, preserving old call behavior for callers that do not provide governor stats.
- Faction ownership remains authoritative; no second treasury or territory source was introduced.
- No story, quest, battle, class, rune, equipment, visual asset, Android workflow, permission, secret or repository-setting changes.
- Main was not modified. No merge, force-push, branch deletion or release publication occurred.

## Exact-head verification — `cc174ae1f9fa3ba33debc9cd8c99715930eb5286`

- [Project Health Audit #45752624278](https://github.com/ninjun42215-gif/KindleWake/actions/runs/45752624278): passed.
- [Workflow YAML Lint #45752624255](https://github.com/ninjun42215-gif/KindleWake/actions/runs/45752624255): passed.
- [Version Sync #45752624248](https://github.com/ninjun42215-gif/KindleWake/actions/runs/45752624248): passed. The main-only version-application step was skipped, as expected for a PR.
- [Android Build #45752624368](https://github.com/ninjun42215-gif/KindleWake/actions/runs/45752624368): import, scene smoke, strict tests, APK export and upload passed; the overall job failed only at Android emulator process-survival.

Automated results:
- Godot 4.2.2 import: exit 0, no script errors.
- Scene smoke: 20 scenes loaded, 0 failures.
- Strict suite: **1,019 checks, 0 failures, 0 script errors, 0 parse errors**.
- Campaign Continue lifecycle: 0 failures.
- Merchant UI: 0 failures.
- Title/creator UI: 0 failures.
- Act V: 0 failures.
- Campaign continuity: 70 checks, 0 failures.
- Chronicle dynasty: 39 checks, 0 failures.
- Chronicle family development: 19 checks, 0 failures.
- Battle balance report: completed.
- The ten initial governor assertions passed, covering threshold behavior, held-region filtering, duplicate-assignment de-duplication, stacking caps, treasury settlement and summary parity. A further active-roster regression was added afterward and awaits the final-head CI rerun.

Exact-head APK candidate:
- [APK artifact #15086211823](https://github.com/ninjun42215-gif/KindleWake/actions/runs/45752624368/artifacts/15086211823), 65,299,046-byte ZIP archive.
- Artifact archive SHA-256: `224ba492d2e637c0e9b2021069a780b0e79c587418e626f86b4a5553f3c55c36`.
- Extracted APK SHA-256, independently calculated after download: `63d7f5c955fcd15a0b29944e9ed5fe418558d617a374740cfb3ca9a791803984`.
- Build summary reports a valid APK signature, ARM64 / ARMv7 / x86_64 libraries, and no requested Android permissions.
- [Diagnostic logs and screenshot artifact #15086487501](https://github.com/ninjun42215-gif/KindleWake/actions/runs/45752624368/artifacts/15086487501), archive SHA-256: `de11be27e3f9be7666a30714594f60089ce6b5d6796ffd4f1c58d3c4e3931c80`.

Android emulator finding:
- The APK installed and the Godot main loop started.
- SwiftShader GLES3 reported the global shader-variable buffer exceeded 16,384 bytes and fragment shader uniforms exceeded `GL_MAX_FRAGMENT_UNIFORM_VECTORS (261)`.
- The captured emulator screenshot was black. GodotActivity then destroyed its instance and the process was killed with SIGKILL; the workflow's 30-second `pidof` check failed.
- No Java `FATAL EXCEPTION`, native fatal signal, GDScript error or parse error was captured.
- Treat this as an emulator rendering/process-survival failure, not proof of a physical-device failure. QA PR #164 owns the emulator/release workflow investigation. Do not merge this PR as a release-readiness approval.

The current main branch remains unprotected and has no required status checks. No repository settings were changed. Physical Android testing remains outstanding.

## Follow-up hardening after the initial verified head

A final code review found that `party.sheet(character_id)` can return a saved sheet even when that character is no longer in the active party roster. The GameState adapter now explicitly requires `party.roster.has(character_id)` before passing a governor's base attributes into realm settlement.

Additional commits:
- `3f6a98af542703ec0b7f9e135552042e2ddae001` — initial active-roster guard in GameState.
- `76a86eaa4a993c4de2ae32fd242a5a7ac5616cc7` — first roster regression attempt.
- `56c14f362b1e7b8e8c830ba292770962d50a6c04` — extract a pure, testable roster filter.
- `8393840e0c7586d2468fc85ff8946b38bee59be9` — route GameState governor stats through the roster filter.
- `3404f73a9d17dad31e00eb53d026b52d62f16606` — replace the autoload-dependent probe with a pure helper regression.

The first roster-test attempt, [Android Build #45753323613](https://github.com/ninjun42215-gif/KindleWake/actions/runs/45753323613), exposed a test-harness mistake: preloading GameState directly in `--script` mode failed because the GameData autoload identifier is unavailable in that mode. The runtime import and 20-scene smoke stage passed, but the strict runner then reported a compile error. The test was refactored to exercise the pure `filter_governor_stats_for_roster` helper without preloading GameState. This failed attempt is superseded by the corrected run below.

## Corrected code-head verification — `4c464cd1102e24aa10a03d68597d7ac57aa5015c`

- [Project Health Audit #45753529961](https://github.com/ninjun42215-gif/KindleWake/actions/runs/45753529961): passed.
- [Workflow YAML Lint #45753529968](https://github.com/ninjun42215-gif/KindleWake/actions/runs/45753529968): passed.
- [Version Sync #45753529950](https://github.com/ninjun42215-gif/KindleWake/actions/runs/45753529950): passed.
- [Android Build #45753529962](https://github.com/ninjun42215-gif/KindleWake/actions/runs/45753529962): Godot import, scene smoke, strict tests, APK export and upload passed; overall job failed at Android emulator process-survival.

Automated results on the corrected code head:
- Godot 4.2.2 import: exit 0, no script errors.
- Scene smoke: 20 scenes loaded, 0 failures.
- Strict suite: **1,020 checks, 0 failures, 0 script errors, 0 parse errors**.
- Campaign Continue lifecycle: 0 failures.
- Merchant UI: 0 failures.
- Title/creator UI: 0 failures.
- Act V: 0 failures.
- Campaign continuity: 70 checks, 0 failures.
- Chronicle dynasty: 39 checks, 0 failures.
- Chronicle family development: 19 checks, 0 failures.
- Battle balance report: completed.
- All eleven governor assertions passed, including the new active-roster-only filter.

Exact-head APK candidate:
- [APK artifact #15086567298](https://github.com/ninjun42215-gif/KindleWake/actions/runs/45753529962/artifacts/15086567298), 65,299,208-byte ZIP archive.
- Artifact archive SHA-256: `c6b0676bbcbc03e8701926c447b04a250c9f42f955b5af8e9adfdd11d1070781`.
- Extracted APK SHA-256, independently calculated after download: `1f28608e158e5dc15ec509d8dcf2a11f1e89dc530281d32286148e6a22b6a8e6`.
- Build summary reports a valid signature, ARM64 / ARMv7 / x86_64 libraries and no requested Android permissions.
- [Diagnostic logs and screenshot artifact #15087125915](https://github.com/ninjun42215-gif/KindleWake/actions/runs/45753529962/artifacts/15087125915), archive SHA-256: `db824f329f659a31e904ca726a73d976614a604a10235b7bc6c3ad6f6b34750a`.

Android emulator finding on the corrected head:
- The APK installed and the Godot main loop started.
- SwiftShader GLES3 reported the global shader-variable buffer exceeded 16,384 bytes and fragment shader uniforms exceeded `GL_MAX_FRAGMENT_UNIFORM_VECTORS (261)`.
- The captured emulator screenshot was black. GodotActivity then destroyed its instance and the process was killed with SIGKILL; the workflow's 30-second `pidof` check failed.
- No Java `FATAL EXCEPTION`, native fatal signal, GDScript error or parse error was captured.
- Treat this as an emulator rendering/process-survival failure, not proof of a physical-device failure. QA PR #164 owns the emulator/release workflow investigation.

The prior 1,019-check run on `cc174ae` is historical and superseded for the corrected code. The corrected code/test head above passed all 1,020 checks. This final handoff update is documentation-only; its exact final SHA is recorded in PR #182 metadata.

## Known balance and QA risks

- The INT/LDR mapping and +8% / +3 realm caps are an initial balance pass; review campaign simulations before merging.
- Governor bonuses use base attributes, not gear/rune bonuses. This is intentional for predictable administration but should remain clearly described in the UI.
- Physical Android viewport, touch, pause/resume, low-memory and long-session QA remain separate release gates.
