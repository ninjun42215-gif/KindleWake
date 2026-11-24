# Core Engineering Handoff — 24 November 2026

**Repository:** https://github.com/ninjun42215-gif/KindleWake  
**Project directory:** `Kindlewake/`  
**Base main:** `13f66ec19476c9af5ed2b5c81af95e4d8a026876`  
**Branch:** `fix/merchant-council-building-income-2026-11-24`  
**Current implementation branch head before this handoff:** `1486f9b97acd335c8f7b075c2c4c3455388537bd`

## Finding

The documented Merchant Council rule grants **+20% holding income, rounded up**. The economy implementation calculated that 20% only from the holding's authored base income. It omitted recurring income from upgraded workshops and trade posts, even though those yields had already been added to the same local holding income.

This made the governance model weaker than its documented rule whenever a holding had productive buildings, and it gave no council bonus to a holding whose income came entirely from buildings.

## Change

In `scripts/core/empire_economy_system.gd`, calculate the Merchant Council's rounded-up 20% bonus from the complete `local_income` after building yields have been added. The existing +1 upkeep remains unchanged. No new persistent fields or save migration are required.

## Regression coverage

Added a focused case to `tests/run_tests.gd` with:
- Base holding income: 20.
- Workshop tier 1: +2.
- Trade post tier 1: +5.
- Merchant Council bonus: ceil(27 × 20%) = +6.
- Expected final income: 33.
- Expected upkeep: 3 (base 2 plus the existing council surcharge 1).

The fixture is self-contained and does not modify GameState, player saves or shared test data.

## Exact commits

- `fe9c8b5d4f1c19db2a05c53bdd981719a0a1e0c7` — apply the bonus to total holding yield.
- `af45cfeaa30ec7434617ca14509e1ab7098b69c5` — add Merchant Council regression coverage.
- `1486f9b97acd335c8f7b075c2c4c3455388537bd` — make the regression fixture self-contained.

## Preservation and verification status

- No story, quest, battle, class, rune, item, asset, UI or player-save changes.
- No save-schema or project-version change.
- No workflow, permission, secret or repository-setting changes.
- The existing holding economy, shared treasury, governance surcharge and all other governance models are unchanged.
- Godot import, strict tests, health audit, YAML lint, version sync and Android APK export have **not yet been claimed as passed** for this branch. Exact-head GitHub Actions evidence must be inspected after the PR is opened.
- No physical Android device was tested.

## Coordination

This is a focused current-main change to `EmpireEconomySystem`. It does not modify the older regional-trading branch, the visual branches, the battle-resume branch, or the existing campaign/Chronicle save-validation candidates. Keep the PR draft and unmerged pending exact-head verification and review.


## Initial exact-head CI evidence — `825aa2c94b20372400aa70bbe8024243f58a2490`

- [Project Health Audit #45321043773](https://github.com/ninjun42215-gif/KindleWake/actions/runs/45321043773) — passed.
- [Workflow YAML Lint #45321043705](https://github.com/ninjun42215-gif/KindleWake/actions/runs/45321043705) — passed.
- [Version Sync #45321043721](https://github.com/ninjun42215-gif/KindleWake/actions/runs/45321043721) — passed; the workflow's main-branch mutation job was skipped for this PR event.
- [Build Android APK #45321043786](https://github.com/ninjun42215-gif/KindleWake/actions/runs/45321043786) — import, scene/test/APK-export step passed and APK upload completed. At the time of this handoff update, the emulator install/launch step was still running; the overall workflow is not yet passed.
- Exact-head APK artifact [#14887685873](https://github.com/ninjun42215-gif/KindleWake/actions/runs/45321043786/artifacts/14887685873): 65,297,895-byte ZIP archive; GitHub artifact metadata digest `sha256:45b469eeb8314ec071966e3a898fac761d0db0531a73539571739911112565f3`. This proves an artifact was uploaded for the exact code/test head; APK signature and extracted APK hash have not yet been independently inspected in this run.

The handoff update itself is documentation-only. Fresh CI on the resulting final PR head is required; the results above certify the code/test head, not any later documentation commit.


## Completed Android build and emulator diagnostics — code/test head `825aa2c94b20372400aa70bbe8024243f58a2490`

[Build Android APK #45321043786](https://github.com/ninjun42215-gif/KindleWake/actions/runs/45321043786) completed with an overall **failure at the emulator process-liveness step**. The preceding build/test/export and APK upload steps passed.

### Verified test output

- Godot 4.2.2 import: exit 0, no script errors.
- Scene smoke: 20 scenes loaded, 0 failures.
- Strict core suite: **1,010 checks, 0 failures**.
- Campaign Continue lifecycle, merchant UI, title/creator UI, Act V, campaign continuity, Chronicle dynasty, Chronicle family development and balance report: all exited successfully with their pass markers/zero-failure summaries.
- The new Merchant Council assertion passed in `run_tests.txt`: base 20 + workshop 2 + trade post 5 produces income 33 and upkeep 3.

### Exact-head APK provenance

- [APK artifact #14887685873](https://github.com/ninjun42215-gif/KindleWake/actions/runs/45321043786/artifacts/14887685873) was downloaded and inspected.
- Artifact ZIP SHA-256: `45b469eeb8314ec071966e3a898fac761d0db0531a73539571739911112565f3`; ZIP CRC/integrity check passed.
- Extracted `Kindlewake.apk`: 65,852,762 bytes; SHA-256 `70464bd07c5654cda9286523e02a2cbf3b47376181533f6f770062d62b464b24`.
- The build summary reports a valid APK signature (fingerprint prefix `c04a7792715ad8f5`), ABIs arm64-v8a / armeabi-v7a / x86_64, and no requested Android permissions.
- [Test/log artifact #14887218496](https://github.com/ninjun42215-gif/KindleWake/actions/runs/45321043786/artifacts/14887218496) contains the strict test output, emulator screenshot and logcat. The screenshot was inspected and is entirely black.

### Emulator failure

The Android emulator installed the APK and `am start -W` returned `Status: ok`, but the app process disappeared before the 30-second liveness check; `pidof com.kindlewake.game` failed. The screenshot is black. Logcat records:
- `rendering/limits/global_shader_variables/buffer_size` exceeds the emulator's 16,384-byte uniform-buffer limit.
- `SceneShaderGLES3` linking fails because 261 active fragment uniforms exceed `GL_MAX_FRAGMENT_UNIFORM_VECTORS`.
- Godot reports that the shader could not compile/bind.

No `FATAL EXCEPTION`, `Fatal signal`, `SCRIPT ERROR` or `Parse Error` appears in the captured app log. The rendering failure is confirmed; the precise reason the app process exits is not conclusively captured. Do not label this a physical-device crash or a successful emulator run.

The test/build artifact proves the gameplay correction passed the strict suite; Android rendering/runtime verification remains blocked. The handoff update is documentation-only. Fresh exact-head checks are required for the resulting PR head.
