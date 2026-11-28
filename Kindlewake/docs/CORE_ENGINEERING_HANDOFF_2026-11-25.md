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

## Verification — tested PR head 95600bb70a95cf43207ae76bdef73ae6d52ab0a2

The exact PR head above completed the following checks:

- [Project Health Audit #45541003728](https://github.com/ninjun42215-gif/KindleWake/actions/runs/45541003728) — passed.
- [Workflow YAML Lint #45541003683](https://github.com/ninjun42215-gif/KindleWake/actions/runs/45541003683) — passed.
- [Version Sync #45541003652](https://github.com/ninjun42215-gif/KindleWake/actions/runs/45541003652) — passed.
- [Android Build #45541003661](https://github.com/ninjun42215-gif/KindleWake/actions/runs/45541003661) — **failed only at emulator process-survival verification**; import, strict tests, APK export and artifact upload passed.

Godot 4.2.2 results from the uploaded build logs:

- Import: exit 0, no script/parse errors.
- Scene smoke: 20 scenes loaded, 0 failures.
- Main strict suite: 1,009 checks, 0 failures; 0 script errors and 0 parse errors.
- Campaign lifecycle: 0 failures.
- Merchant UI and title/creator UI: passed.
- Act V, campaign continuity, Chronicle dynasty and Chronicle family suites: passed.
- New empire development integrity suite: **12 checks, 0 failures**.
- Balance report: exit 0.

### Android artifact

[Exact-head APK artifact #14989670703](https://github.com/ninjun42215-gif/KindleWake/actions/runs/45541003661/artifacts/14989670703)

- APK size: 65,852,762 bytes.
- APK SHA-256: `d310e9684e7000cadeef238771e5bcc370f347d85558e481b582aff4106bbca6`.
- Artifact ZIP SHA-256: `a1b1ad6572baad0137b409987c8d4ea56f815cf54952214ea2fc99ad73f1ace5`.
- ZIP integrity: passed.
- Build summary: signature valid; ABIs arm64-v8a, armeabi-v7a and x86_64; no Android permissions requested.

### Emulator failure and diagnostics

The APK installed successfully and Android reported `am start -W` as `Status: ok`. The process then died before the 30-second liveness check; the captured screenshot is black.

Logcat recorded:

- Project setting `rendering/limits/global_shader_variables/buffer_size` exceeding the emulator's 16,384-byte uniform-buffer limit.
- Repeated `SceneShaderGLES3` program-link failures because fragment shader active uniforms exceeded `GL_MAX_FRAGMENT_UNIFORM_VECTORS (261)`.
- Godot reported the shader failed to compile/bind.
- ActivityManager recorded `Process com.kindlewake.game ... has died`.

No `FATAL EXCEPTION`, fatal native signal, or GDScript/parse error was found in the captured log. The shader-link failures are a strong correlated rendering fault, but the exact process-death cause is not proven by a native crash trace. This is an emulator result, not physical-device evidence.

The uploaded diagnostic logs and black screenshot are in [test-logs artifact #14989052755](https://github.com/ninjun42215-gif/KindleWake/actions/runs/45541003661/artifacts/14989052755).

**Important:** the next commit only updates handoff documentation. It will change the PR head; re-run exact-head checks before treating the updated PR as fully verified. Physical Android testing remains separate; CI does not establish handset compatibility.

## Coordination and remaining risks

- PR #46 is an old, heavily diverged Royal Administration candidate; it changes a different legacy management layer and was not modified.
- PR #177 owns the Merchant Council economy calculation; PR #174 owns equipment enhancement stats; PR #170 owns battle turn restoration. This branch does not touch their files.
- PR #164 owns Android release/emulator workflow hardening. Its workflow changes were not modified.
- Keep PR #179 draft and unmerged until exact-head checks and review complete.
- Main remains unchanged at `13f66ec19476c9af5ed2b5c81af95e4d8a026876`.


## QA follow-up — numeric reserve bounds (2026-11-28)

Addressed QA comment [#7159984750](https://github.com/ninjun42215-gif/KindleWake/pull/179#issuecomment-7159984750) in the reserve-count parser:

- Integer variants are validated and returned as integers without a float round-trip, preserving large signed 64-bit values exactly.
- Float variants are rejected when non-finite, negative, fractional or at/above the exclusive signed-64-bit upper bound.
- Finite values are range-checked before conversion to int, preventing overflow/platform-dependent conversion behavior.
- Added 10 regression assertions (9 direct boundary checks plus an API-level atomicity check covering NaN, positive/negative infinity and oversized finite floats).
- The existing 12 integrity assertions remain unchanged. The new expected standalone total is 22 checks.

**Verification status:** this follow-up changes runtime code and tests. Run the exact resulting PR head through Godot import, the strict garrison suite, the full build/test pipeline and the alternate API 35/OCR Android workflow. Historical results above do not verify this follow-up. Do not claim Android visual success from the mainline AOSP/SwiftShader liveness-only workflow.
