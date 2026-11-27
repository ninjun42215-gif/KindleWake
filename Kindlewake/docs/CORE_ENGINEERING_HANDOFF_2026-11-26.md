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


## Follow-up — 27 November 2026: 24-month governor economy simulation

QA review comments [#7190430035](https://github.com/ninjun42215-gif/KindleWake/pull/182#issuecomment-7190430035) and [#7191616982](https://github.com/ninjun42215-gif/KindleWake/pull/182#issuecomment-7191616982) correctly noted that the original battle balance report did not test recurring governor effects over a long realm timeline. This follow-up adds a deterministic 24-month simulation to the existing strict test runner.

### Simulation coverage

The new `_test_governor_long_run_economy()` exercises:
- No governor, one governor, two governors and four governors over 24 monthly settlements.
- Treasury progression and stability under the same four-region held-territory fixture.
- Royal Roads disabled/enabled, including the one-time 400-gold policy purchase cost.
- The maximum +8% realm income and +3 stability-per-turn caps.
- A high-tax (25%) negative-net-upkeep case with four governors, both without roads and with roads.
- Treasury and stability lower bounds, negative-net persistence, road-income improvement, month index, and the 24-entry settlement/processed-token history window.

The deficit fixture starts with 100 gold without roads. The roads case starts with 500 gold, pays the 400-gold policy cost, and enters the same 100-gold operating balance. Both scenarios deliberately retain negative monthly net income; the test verifies that the shared treasury and stability clamp at zero rather than becoming negative.

### Code/test-head verification

- Code/test head: `466d4792d3f9cd4a711e5b02a2c891d69634a2c6`.
- Added 11 deterministic long-run assertions to `tests/run_tests.gd`; no runtime economy formula, save format, story, or player data changed.
- [Project Health Audit #45935581580](https://github.com/ninjun42215-gif/KindleWake/actions/runs/45935581580): passed.
- [Workflow YAML Lint #45935581497](https://github.com/ninjun42215-gif/KindleWake/actions/runs/45935581497): passed.
- [Version Sync #45935581508](https://github.com/ninjun42215-gif/KindleWake/actions/runs/45935581508): passed.
- [Android Build #45935581529](https://github.com/ninjun42215-gif/KindleWake/actions/runs/45935581529): Godot import, scene smoke, strict tests, APK export and APK upload completed successfully; emulator launch was still running when this handoff section was authored.
- APK candidate [artifact #15169409703](https://github.com/ninjun42215-gif/KindleWake/actions/runs/45935581529/artifacts/15169409703), archive size 65,299,175 bytes. This is a CI candidate, not a production release or physical-device verification.

### Documentation alignment

The branch README and continuation prompt now describe the governor INT/LDR bonuses rather than claiming they are unimplemented. Historical dated GDD revision notes were intentionally left intact.

The documentation-updated head before this handoff append was `c904d8ad98dee4d6a6b01b30b552308c0222c2a3`. Its Project Health #45935804636, Workflow YAML Lint #45935804608 and Version Sync #45935804597 passed; Android Build #45935804605 was still running its import/test/export stage at last inspection. The final handoff commit requires its own exact-head checks.

### Remaining review risks

- The simulation is deterministic and covers 24 months, but it is a bounded synthetic four-region fixture, not a full authored campaign economy playthrough.
- Governor bonuses remain based on trained base attributes; equipment and temporary battle effects do not alter them.
- The AOSP ATD / forced SwiftShader rendering issue is owned by QA PR #164. This gameplay PR does not change emulator or release workflows.
- Keep PR #182 draft and unmerged pending exact final-head CI and review of the balance assumptions.


## Final exact-head verification — 27 November 2026

Final documentation head at this checkpoint: `5d9bf4a7f6936ec11f4a0c8ed0727c42cd2e7ae8`.

- [Project Health Audit #45935927770](https://github.com/ninjun42215-gif/KindleWake/actions/runs/45935927770): passed.
- [Workflow YAML Lint #45935927753](https://github.com/ninjun42215-gif/KindleWake/actions/runs/45935927753): passed.
- [Version Sync #45935927734](https://github.com/ninjun42215-gif/KindleWake/actions/runs/45935927734): passed.
- [Android Build #45935927744](https://github.com/ninjun42215-gif/KindleWake/actions/runs/45935927744): overall failed at the AOSP ATD / forced SwiftShader emulator process-liveness step. Its import, 20/20 scene smoke, strict tests, APK export and upload stages passed.

The exact-head build summary reports:
- Godot 4.2.2 import: exit 0, no script errors.
- Scene smoke: 20 loaded, 0 failures.
- Strict suite: **1,031 checks, 0 failures**.
- Campaign lifecycle, merchant UI, title/creator UI, Act V, campaign continuity (70), Chronicle dynasty (39), Chronicle family development (19) and balance report: exit 0.
- APK export: 65.9 MB; valid CI/test signature; ARM64, ARMv7 and x86_64 native libraries; no Android permissions requested.

Exact-head artifacts:
- APK [#15171255043](https://github.com/ninjun42215-gif/KindleWake/actions/runs/45935927744/artifacts/15171255043), 65,299,159-byte ZIP; GitHub artifact digest `sha256:8c5804fe7354d5944a86c5cbd0c1b4dc6d9323e25315bcf593a796b816b574d5`.
- Test logs [#15171040886](https://github.com/ninjun42215-gif/KindleWake/actions/runs/45935927744/artifacts/15171040886), 88,724-byte ZIP; GitHub artifact digest `sha256:8c20c28f643aebbcbe39323cd964f081d4d53221bccef8dfe86e0bd4e0f4d21a`.

I downloaded and inspected the exact-head test-log artifact:
- `honor400-emulator.png` is entirely black.
- Logcat contains four `SceneShaderGLES3: Program linking failed` entries and `Fragment shader active uniforms exceed GL_MAX_FRAGMENT_UNIFORM_VECTORS (261)`, followed by shader compile/bind failure.
- The Godot launcher activity returned `Status: ok`, but after the 30-second wait `pidof com.kindlewake.game` found no running process; the emulator step failed.
- The captured logcat has no `FATAL EXCEPTION`, native `Fatal signal`, `SCRIPT ERROR` or `Parse Error` matches.

This confirms that the current mainline AOSP ATD / forced SwiftShader route still does not provide a usable rendering/process-survival result. It does not establish that all physical Android devices fail. QA PR #164 owns the alternate API 35 Google APIs/default-graphics + screenshot OCR gate; no physical handset has been tested.

The final handoff update itself is documentation-only and must be treated as a new PR head with its own exact-head CI. Keep PR #182 draft and unmerged.
