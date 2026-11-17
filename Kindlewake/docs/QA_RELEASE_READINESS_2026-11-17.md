# QA & Android release-readiness report — 2026-11-17

**Repository:** https://github.com/ninjun42215-gif/KindleWake  
**Project:** `Kindlewake/` · Godot 4.2.2 · GL Compatibility · Android · offline-first  
**Verified main SHA:** `adf3d44bbeef1e1e048f2aa244a1a80bf95147fc`  
**QA branch:** `qa/android-emulator-script-guard-2026-11-17`  
**QA implementation commit:** `15c6c054a1a33907e3fdc4cee55a652a96581b8b`  
**QA PR:** [#159 — fix Android emulator smoke-test shell assertions](https://github.com/ninjun42215-gif/KindleWake/pull/159)  
**Report status:** CI for the QA branch is pending at the time of this report. This report must be refreshed after the exact-head workflow results complete.

## Executive result

The current mainline Godot import, scene smoke, strict game tests, balance run and APK export completed successfully. The Android build workflow nevertheless fails in its emulator-verification step because its multi-line shell conditionals are passed to the emulator runner as separate commands. This is a workflow defect, not a demonstrated game crash. The process-liveness and logcat fatal-error assertions did not execute, so Android runtime verification is incomplete.

A focused fix is proposed in PR #159. No merge, release publication, branch deletion, force-push, save/schema change or repository setting change was performed.

## Exact-main verification

Main SHA: `adf3d44bbeef1e1e048f2aa244a1a80bf95147fc`.

| Check | Result | Evidence |
|---|---|---|
| Godot import + scene smoke | Passed; 20 scenes loaded, 0 failures | [Android build #44018510162](https://github.com/ninjun42215-gif/KindleWake/actions/runs/44018510162) |
| Core strict regression suite | Passed; 1,009 checks, 0 failures | [Android build #44018510162](https://github.com/ninjun42215-gif/KindleWake/actions/runs/44018510162) |
| Campaign lifecycle | Passed; 0 failures | [Android build #44018510162](https://github.com/ninjun42215-gif/KindleWake/actions/runs/44018510162) |
| Merchant UI | Passed; 0 failures | [Android build #44018510162](https://github.com/ninjun42215-gif/KindleWake/actions/runs/44018510162) |
| Title / creator UI | Passed; 0 failures | [Android build #44018510162](https://github.com/ninjun42215-gif/KindleWake/actions/runs/44018510162) |
| Act V | Passed; 0 failures | [Android build #44018510162](https://github.com/ninjun42215-gif/KindleWake/actions/runs/44018510162) |
| Campaign continuity | Passed; 70 checks, 0 failures | [Android build #44018510162](https://github.com/ninjun42215-gif/KindleWake/actions/runs/44018510162) |
| Chronicle dynasty | Passed; 39 checks, 0 failures | [Android build #44018510162](https://github.com/ninjun42215-gif/KindleWake/actions/runs/44018510162) |
| Chronicle family development | Passed; 19 checks, 0 failures | [Android build #44018510162](https://github.com/ninjun42215-gif/KindleWake/actions/runs/44018510162) |
| Project Health Audit | Passed; 44 JSON, 88 GDScript, 20 scenes, version 0.12.0 / Android code 1200, 0 structural errors and 0 warnings | [Audit #44018510153](https://github.com/ninjun42215-gif/KindleWake/actions/runs/44018510153) |
| Workflow YAML Lint | Passed | [Lint #44018510208](https://github.com/ninjun42215-gif/KindleWake/actions/runs/44018510208) |
| Version synchronization | Passed | [Version Sync #44018510156](https://github.com/ninjun42215-gif/KindleWake/actions/runs/44018510156) |
| Source handoff packaging | Passed; 3 verified parts, each at or below 25,000,000 bytes | [Source handoff #44018510146](https://github.com/ninjun42215-gif/KindleWake/actions/runs/44018510146) |
| Android emulator verification | **Failed at workflow-script parsing**, not proven to be a game failure | [Android build #44018510162](https://github.com/ninjun42215-gif/KindleWake/actions/runs/44018510162) |

The read-only health audit explicitly does not execute Godot, validate every GDScript semantic, verify external licence terms or certify Android-device compatibility. Its zero-warning result is not a full release certification.

## Android workflow failure and proposed fix

The failing step is **Install and launch APK in Android emulator** in `.github/workflows/build-apk.yml`.

Observed failure:

```text
/usr/bin/sh: 1: Syntax error: end of file unexpected (expecting "fi")
```

The emulator runner invokes the script line-by-line; the multi-line `if ... then ... fi` blocks therefore arrive as incomplete `sh -c` commands. The APK was installed and the explicit Godot launcher activity returned `Status: ok`, but the workflow then failed before its process-liveness and logcat fatal-error assertions could be trusted.

PR #159 replaces those blocks with single-line assertions while retaining both gates. It changes only `.github/workflows/build-apk.yml`; it does not change the game runtime, data, saves, export preset, signing or permissions.

### APK artifact provenance — not release-approved

The failed main run is tied to exact main SHA `adf3d44bbeef1e1e048f2aa244a1a80bf95147fc`.

- Build run: [#44018510162](https://github.com/ninjun42215-gif/KindleWake/actions/runs/44018510162)
- APK artifact: [Kindlewake-APK, artifact ID 14299478214](https://github.com/ninjun42215-gif/KindleWake/actions/runs/44018510162/artifacts/14299478214)
- Uploaded artifact size: 65,216,059 bytes (artifact ZIP); builder reported APK size 65.8 MB.
- APK verifier reported a valid signature and no Android permissions requested.
- The overall workflow failed in the emulator step. Therefore this artifact is provenance-linked to the tested SHA but is **not a fully verified release candidate** and must not be substituted for a successful exact-head build.

The CI signing certificate is the test/sideload identity, not the protected production signing identity.

## Source handoff artifact

The exact-main handoff run #44018510146 succeeded and uploaded [artifact ID 14300365377](https://github.com/ninjun42215-gif/KindleWake/actions/runs/44018510146/artifacts/14300365377).

The partition manifest reported:
- Part 001: 25,000,000 bytes; SHA-256 `f87c9948981650cd7766582c87314d0984b842564f97e01b101e382402c7821c`
- Part 002: 25,000,000 bytes; SHA-256 `85c9ac406219002fefbf66289b8a866eb6d469d84668e186b0db84ce582774dd`
- Part 003: 23,949,148 bytes; SHA-256 `f9222444d6d2dd5a85bc46d51c7e4e85035aab7fcf287fcc66d38638447bef21`

The uploaded artifact ZIP digest was `f8dd87452bed61d88287fc4cabe8f37dae9bc132b33b063547749a2def5080ef`. The handoff is a source snapshot, not a Git clone; the live repository and exact branch head remain authoritative.

## Open PR and branch-health triage

All comparisons below use main `adf3d44bbeef1e1e048f2aa244a1a80bf95147fc` as the base, unless otherwise stated.

| PR | Head SHA | Main comparison | QA disposition |
|---|---|---:|---|
| [#159 emulator script fix](https://github.com/ninjun42215-gif/KindleWake/pull/159) | `15c6c054a1a33907e3fdc4cee55a652a96581b8b` | 1 ahead / 0 behind | Focused QA draft; await exact-head CI |
| [#158 equipment icons](https://github.com/ninjun42215-gif/KindleWake/pull/158) | `2a0df2d9bb868ed537d6603bcd2f8b4ba01fac87` | 4 ahead / 0 behind | Draft; Android workflow failure is the same emulator-script defect |
| [#157 protagonist identity / portraits](https://github.com/ninjun42215-gif/KindleWake/pull/157) | `b9545c5e3fab1ebd5a095bfcf807573bbfc1973c` | 34 ahead / 0 behind | Draft; Android workflow failure is the same emulator-script defect |
| [#156 empire save validation](https://github.com/ninjun42215-gif/KindleWake/pull/156) | `5b250870d3380e68183b7dde955acc7bbcf238fb` | 8 ahead / 79 behind; diverged | Do not merge as-is; rebase/reconcile and rerun save migration tests |
| [#152 release gate refresh](https://github.com/ninjun42215-gif/KindleWake/pull/152) | `740dc7d6b3c55f4d23d63c5eca81f690dc3e3433` | 4 ahead / 89 behind; diverged | Stale release-hardening candidate; overlaps #148 and #159 in workflow files |
| [#148 release publish gate](https://github.com/ninjun42215-gif/KindleWake/pull/148) | `993d9c49bb919e8ab50c802ce05f876603df6adb` | 11 ahead / 92 behind; diverged | Duplicate/stale release-hardening candidate; reconcile with #152, do not bulk merge |
| [#151 battle resume](https://github.com/ninjun42215-gif/KindleWake/pull/151) | `e1908f83a01909177b0b72de72499030480b8b8d` | 9 ahead / 89 behind; diverged | Rebase and revalidate lifecycle/save behavior before review |
| [#81 regional trading](https://github.com/ninjun42215-gif/KindleWake/pull/81) | `69794034a12012f89e9e709d15b7761f3fa2e771` | 3 ahead / 137 behind; diverged | Not merge-ready; port only reviewed slices to fresh main-based work |
| [#130 authentication documentation](https://github.com/ninjun42215-gif/KindleWake/pull/130) | `d2ab36d73e71e69965f6658aa18e8642f3e52daa` | 2 ahead / 108 behind; diverged | Documentation-only; verify against current offline architecture before readiness |

Older campaign, empire, bestiary, story and boss branches (#42–#78 and #22–#47) are substantially diverged. Treat them as reference material and port reviewed work rather than merging old branch histories wholesale. No branch was deleted or rewritten.

## Permissions, secrets and release publishing

- Routine `Build Android APK` uses repository `contents: read`; the tag-release job in that workflow is separately scoped to `contents: write`.
- Main still contains the legacy `v*` tag-triggered release attachment job in `build-apk.yml`. Avoid pushing a version tag until the release-publish gate changes are safely reconciled.
- `publish-android-release.yml` currently declares `contents: write` at workflow scope. The open release-gate proposals #148/#152 narrow this to the publish job and set the rejected-confirmation job to no repository permissions; these proposals are stale/diverged and must be rebased and reviewed before adoption.
- The production workflow uses the `android-production` environment and protected signing secrets. Environment reviewer rules, secret presence and tag protection could not be inspected through this read-only run; do not assume they are configured.
- Build logs redact the keystore path/password/alias values. No secret values were retrieved or written to the repository.
- GitHub Actions emitted non-blocking Node.js 20 deprecation warnings for several current actions; update action runtimes in a separate tested maintenance PR.

## Asset provenance

The current asset ledger records all runtime-used packs as verified:
- Quaternius Stylized Nature MegaKit: CC0 1.0, official source recorded.
- Zerie Tiny RPG Character Asset Pack 01 free Soldier/Orc subset: author-published game-use/modification terms recorded; standalone source-pack redistribution is prohibited.
- KindleWake-authored vector art, settlement illustrations and heraldry: original project content.

The legacy voxel-building pack has unverified provenance but is marked unused and replaced at runtime by original KindleWake SVG settlement art. LimeZu's non-commercial-only pack and the MountainRocks archive with unknown terms are also unused. Do not reintroduce or redistribute those archives without authoritative rights evidence.

## Remaining release blockers / next actions

1. Complete PR #159 exact-head CI. Confirm the Android emulator action executes both single-line assertions, captures logcat, and remains running after launch.
2. Re-run the exact current-main build after the workflow fix is accepted; do not reuse artifact 14299478214 as a successful build.
3. Keep #157 and #158 blocked on the common Android workflow failure until a new exact-head run succeeds.
4. Reconcile duplicate release-hardening PRs #148/#152 on current main; retain protected production signing, exact tag provenance and least-privilege permissions. Avoid version-tag pushes until then.
5. Rebase/review save validation #156 and battle-resume #151; run corruption, backup fallback, migration, battle-resume and title Continue lifecycle tests on current main.
6. Perform physical Android QA: install/update without losing saves; test title → creator → new game, Chapter 1 courtyard, touch and scrolling, overworld/town/battle controls, save → force-stop → relaunch → Continue, orientation/safe areas, long-session memory and frame pacing.
7. Inspect the uploaded emulator screenshot and logcat after the fixed run; CI emulator success is not a substitute for physical-device testing.
8. Confirm production environment reviewers, signing secrets, certificate fingerprint and immutable tag rules before any public release.

**No physical-device test was performed in this run. No PR was merged and no release was published.**


## Follow-up emulator evidence — 2026-11-17

The first PR-head build after replacing the broken multi-line shell blocks completed Godot import, all strict tests and APK export, then failed the new process-liveness assertion. This is a separate finding from the original shell parser defect.

- Follow-up build: [#44065627411](https://github.com/ninjun42215-gif/KindleWake/actions/runs/44065627411), source head `d167853258d63b6931776ca3d3b5ec4d2f4ea03a`.
- Strict checks again passed: 20 scenes, 1,009 core checks / 0 failures, campaign lifecycle 0, merchant UI 0, title/creator UI 0, Act V 0, continuity 70, dynasty 39 and family development 19.
- APK artifact: [ID 14319014751](https://github.com/ninjun42215-gif/KindleWake/actions/runs/44065627411/artifacts/14319014751). Builder reported 65.8 MB, valid signature and no Android permissions. The workflow failed after APK upload; do not treat it as a release candidate.
- Emulator diagnostics: [test-logs artifact ID 14320716062](https://github.com/ninjun42215-gif/KindleWake/actions/runs/44065627411/artifacts/14320716062). It contains the black screenshot, logcat, activity/window dumps and build logs.

### What the captured logcat proves

- Godot 4.2.2 loaded, created an OpenGL ES 3.0 SwiftShader context and reached `OnGodotMainLoopStarted`.
- No `FATAL EXCEPTION`, native `Fatal signal`, `SCRIPT ERROR` or `Parse Error` was found in the captured log.
- The renderer logged `SceneShaderGLES3: Program linking failed` with `GL_MAX_FRAGMENT_UNIFORM_VECTORS (261)` and a warning that the default `rendering/limits/global_shader_variables/buffer_size` exceeds the device's 16,384-byte uniform-buffer limit.
- Approximately two seconds after startup, `GodotActivity` logged `Destroying Godot app` / `Force quitting Godot instance`; Android then recorded the app process exiting with signal 9. The 30-second screenshot was black and the activity dump showed the emulator home activity, not KindleWake.

The log does **not** establish why the Android activity was destroyed. The SceneShader/SwiftShader messages are not proven to be the cause: a similar GLES3 uniform-link error has been reported upstream on Android SwiftShader, where a Godot maintainer suspected a SwiftShader issue rather than a game-level shader limit ([Godot issue #109550](https://github.com/godotengine/godot/issues/109550)). The project contains no custom `shader_type` or `global uniform` declarations in the current main source search. Treat the renderer messages as a compatibility warning to investigate, not as a confirmed crash root cause.

Godot's 4.2 docs identify `SCREEN_LANDSCAPE = 0` and document that Compatibility mobile devices can have much smaller global shader uniform limits than desktop ([DisplayServer orientation](https://docs.godotengine.org/en/4.2/classes/class_displayserver.html), [ProjectSettings](https://docs.godotengine.org/en/4.2/classes/class_projectsettings.html)). The project currently selects landscape orientation. The old workflow also changed emulator size/density/rotation while starting the app; the new follow-up commit removes those overrides to rule out an ATD display-reconfiguration interaction and prints filtered diagnostics before assertions.

### Follow-up implementation

- Workflow commit `04732f1621fad90da9204228a0639e84e5240c10` removes the manual `wm size`, `wm density` and rotation overrides, keeps the Pixel 5 20:9 profile defaults, and prints filtered Android/Godot error and lifecycle lines before process assertions.
- This commit is on PR #159. Exact-head Build Android APK, Project Health Audit, Workflow YAML Lint and Version Sync are pending; do not mark the emulator issue resolved until the app remains running and the captured screenshot shows the game.
- Next diagnostic if it still exits: compare a standard `google_apis` emulator image against `aosp_atd`, then inspect the first activity-finish reason and full Godot startup log. Keep the runtime and save files unchanged until a reproducible game-side cause is found.


### Emulator-image isolation follow-up

The same captured log shows the AOSP ATD `MultiDisplayService` starting during Godot startup, followed shortly by the Godot activity's orderly `onDestroy` path. This is a correlation, not proof that the service caused the exit. To isolate the test environment, workflow commit `9d74bf63b7eb5532a91e32ffdec726ce1643a4ff` switches the smoke-test AVD from `aosp_atd` to the standard `google_apis` image, retains the Pixel 5 profile and default display geometry, and keeps the process/logcat gates. This does not alter the app's Android export or gameplay. Exact-head emulator verification is pending.


## Save integrity and combat/data checks

The follow-up build log `logs/run_tests.txt` confirms the 1,009-check suite includes:
- v1-to-v2 and v2/v3-to-v4 migration preservation;
- real v1 save migration and schema-4 restore compatibility;
- corrupt primary save fallback to a verified backup;
- checksum mismatch rejection;
- rejection of checksum-valid but malformed campaign metadata;
- semantic backup fallback for a checksum-valid but semantically invalid primary;
- protection against silently downgrading a future-version primary to an older backup;
- malformed party, inventory, equipment, relationship, personality, trait-history and chronicle state validation.

The campaign Continue lifecycle test also passed: a restored campaign entered the World scene, initialized its regional map and remained alive through battle preparation/opening. These are automated headless tests; they do not replace testing actual user save files on physical Android devices.

The AI-vs-AI balance report ran 30 battles per scenario. It labels one encounter **hard** at 57% win rate, one **fair** at 80%, and three **easy** at 97–100%. The 60-skirmish grind sample ended at levels 11/10/10/10 with 59 wins and 4,714 gold. The report itself cautions that this is a starting-party AI benchmark, not human playtesting. Recommendation: keep the current data intact for now; review the hard encounter and three easy scenarios in human playtests before adjusting rewards or enemy stats.
