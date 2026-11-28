# QA and Android Release Readiness — Run 14

**Date:** 27 November 2026  
**Repository:** https://github.com/ninjun42215-gif/KindleWake  
**Project:** `Kindlewake/` · Godot 4.2.2 · GL Compatibility · Android · offline-first  
**Observed main:** `13f66ec19476c9af5ed2b5c81af95e4d8a026876`  
**QA documentation branch:** `qa/project-health-audit-doc-consistency-2026-11-21`  
**Previous QA branch head:** `6eb55988b2ccb6876b215de99a57742fec7e9cc8`

## Executive disposition

**Not production-release-ready.** Main remains unchanged at the 19 Nov commit. A new exact-head audio PR (#185) confirms that the current main Android smoke gate can report success while the screenshot is unusable: its prior green run shows blank menu panels and four GLES3 shader-link failures. Its latest attempt fails process survival, with a fully black screenshot and the same shader failure. The alternate API 35 Google APIs/OCR workflow in PR #164 remains the only currently demonstrated Android CI path that visibly rendered the title/menu.

The 24-month governor economy simulation is now present in PR #182 and its exact current head passes 1,031 strict checks; its Android emulator still fails on the old SwiftShader path. PR #184 adds 21 companion-quest normalization checks; QA identified an untested non-finite/oversized-float conversion edge case. PR #185's new audio integration imports and classifies all four WAV cues, but its scene-smoke test leaks three Button CanvasItem RIDs and no physical listening test exists.

No main code, saves, repository settings, secrets, release tags or published releases were changed. No PR was merged, force-pushed, closed or deleted. No physical Android handset was tested.

## Live repository snapshot

- Main SHA: `13f66ec19476c9af5ed2b5c81af95e4d8a026876`, authored 2026-11-19 02:42:49Z.
- Open PR search: **46** open PRs.
- Branches: **189** (100 on page 1, 89 on page 2).
- Main branch metadata: `protected=false`.
- Repository rulesets: empty list.
- Published GitHub Releases: **0**.
- Latest Safe Auto Merge run [#45952516926](https://github.com/ninjun42215-gif/KindleWake/actions/runs/45952516926) completed successfully; [#45952479875](https://github.com/ninjun42215-gif/KindleWake/actions/runs/45952479875) was skipped. Main SHA is unchanged; no merge occurred.
- The GitHub branch-protection endpoint was not needed for the main protection result; the branch-list response itself reports `protected=false`.

Selected active PRs and exact refs:

| PR | Head | Base | Comparison / disposition |
|---|---|---|---|
| #164 Android/release QA | `f6a4fb0b9ce3b653f96d146aef9022bcca558fb2` | main | 22 ahead / 0 behind; draft |
| #172 QA handoff | `6eb55988b2ccb6876b215de99a57742fec7e9cc8` before this Run 14 doc commit | main | 16 ahead / 0 behind; draft |
| #179 garrison integrity | `c7630c816ed090f7a16b2d4dc77c429cdb82c5d2` | main | 3 ahead / 0 behind; draft |
| #184 companion quest normalization | `a7c8a7aa4957c7ba2a5958e3492e89635b68fa7d` | #179 head | 8 ahead / 0 behind parent; draft |
| #182 governor bonuses | `ed28b188a189eb1ca2c4c2219bd09898633d8386` | main | 25 ahead / 0 behind; draft |
| #183 battlefield surface atlas | `c1acdd413b58dd986e710074847b65efba6a3f78` | #171 head `e5e9f3ca1b7c66f7d46069b2b6a2c285dfe29a70` | stacked visual PR; draft |
| #185 UI audio cues | `88603d2a2ea6e936035b61474e1659ad79e6d34c` | main | 3 ahead / 0 behind; draft |

The full open-PR search returned 46 records. The table focuses on current QA, core-save, economy and visual branches with new or material evidence this run.

## PR #164 — alternate Android emulator and release workflow

[PR #164](https://github.com/ninjun42215-gif/KindleWake/pull/164) remains draft, mergeable, 22 ahead / 0 behind.

Exact-head checks on `f6a4fb0b9ce3b653f96d146aef9022bcca558fb2`:
- [Android Build #45810983519](https://github.com/ninjun42215-gif/KindleWake/actions/runs/45810983519) — passed.
- [Project Health #45810983525](https://github.com/ninjun42215-gif/KindleWake/actions/runs/45810983525) — passed.
- [Workflow YAML Lint #45810983616](https://github.com/ninjun42215-gif/KindleWake/actions/runs/45810983616) — passed.
- [Version Sync #45810983499](https://github.com/ninjun42215-gif/KindleWake/actions/runs/45810983499) — passed.

The API 35 Google APIs x86_64 Pixel 5 emulator installed and launched the APK, retained the Godot activity in foreground/resumed state, and produced a readable title/menu screenshot. OCR detected KINDLEWAKE, THE SUNDERED VOW, NEW GAME, LOAD GAME, SETTINGS and EXIT GAME. The log guard found no SceneShaderGLES3 link failure, GL_MAX_FRAGMENT_UNIFORM_VECTORS overflow, global shader-buffer warning, fatal exception, native fatal signal, script error or parse error.

Exact-head candidate APK: [artifact #15114535341](https://github.com/ninjun42215-gif/KindleWake/actions/runs/45810983519/artifacts/15114535341).
- ZIP SHA-256: `603b5425cb40dfd70ea396f636d1a99390931885c941060b89b692a385e342a0`.
- Extracted APK SHA-256: `3443c5e6c552224ae378d52a22b3ea045a84380e98a01de5ec46cf7d99096998`.
- APK size: 65,852,762 bytes.
- Build summary reports a valid CI/test signature, arm64-v8a / armeabi-v7a / x86_64 and no requested Android permissions.

This is CI-emulator evidence, not physical-device or production-signing evidence. QA comment [#7215670452](https://github.com/ninjun42215-gif/KindleWake/pull/164#issuecomment-7215670452) records the new PR #185 false-positive reproduction and asks that the OCR and renderer-error checks remain mandatory.

## PR #185 — original semantic UI audio cues

[PR #185](https://github.com/ninjun42215-gif/KindleWake/pull/185)  
Branch: `art/original-ui-audio-cues-2026-11-27`  
Exact head: `88603d2a2ea6e936035b61474e1659ad79e6d34c`  
Base main; 3 ahead / 0 behind; draft, mergeable.

The branch adds four original project-synthesized 24 kHz mono PCM16 WAV cues (tap, confirm, back, toggle), a WAV-first/OGG-fallback cached resolver, semantic button classification, and a scene-smoke test. The runtime `sfx()` function does call `player.play()`; no missing-play defect was found.

### Exact-head CI and false-positive evidence

- [Project Health #45952128762](https://github.com/ninjun42215-gif/KindleWake/actions/runs/45952128762) — passed.
- [Workflow YAML Lint #45952128794](https://github.com/ninjun42215-gif/KindleWake/actions/runs/45952128794) — passed.
- [Version Sync #45952128876](https://github.com/ninjun42215-gif/KindleWake/actions/runs/45952128876) — passed.
- [Android Build #45952128835](https://github.com/ninjun42215-gif/KindleWake/actions/runs/45952128835), attempt 1 — failed process survival after import, scene smoke, strict tests, APK export and upload passed.

The exact-head test-log artifact [#15177566436](https://github.com/ninjun42215-gif/KindleWake/actions/runs/45952128835/artifacts/15177566436) was downloaded and independently hashed:
- ZIP SHA-256: `063f1a375150c6bc0b35faea16a73dc5d867034e33a2e83bc5501491600a00c8`, matching GitHub artifact metadata.
- Screenshot is fully black.
- Logcat has four `SceneShaderGLES3` program-link failures because fragment uniforms exceed `GL_MAX_FRAGMENT_UNIFORM_VECTORS (261)`, followed by app process death with signal 9.
- No Java FATAL EXCEPTION, native fatal signal, GDScript error or parse error was captured.

Earlier head `441a4e351dd6e0a5567eaed08fd5c8e99fa3ec1a`, Android run [#45952118559](https://github.com/ninjun42215-gif/KindleWake/actions/runs/45952118559), was marked successful by the old workflow. Its test-log artifact [#15177681099](https://github.com/ninjun42215-gif/KindleWake/actions/runs/45952118559/artifacts/15177681099) was also downloaded and inspected:
- ZIP SHA-256: `fc0fd35705569e5cf916abc46b5003cbc68035b7526facdce41bba9730f99658`, matching artifact metadata.
- Screenshot shows only an empty menu shell and blank button rectangles, with no title/menu text.
- Logcat contains the same four shader-link failures and no Java/native/GDScript/parse fatal.
- The process-liveness-only gate therefore produced a **visual-smoke false positive**.

The latest exact-head APK artifact [#15177157903](https://github.com/ninjun42215-gif/KindleWake/actions/runs/45952128835/artifacts/15177157903) was downloaded and verified:
- ZIP SHA-256: `4bc9e277ff833b321f9a20a60dc7136f24a1b5575c5da159c5a2ce90ef241574`, matching GitHub metadata; ZIP integrity passed.
- Extracted APK: 65,886,370 bytes; SHA-256 `97f771e95eca386530b93be109ee1df1a318d2507c224d35cbc3bb44e222fd54`.
- Build summary reports a valid CI/test signature, three ABIs and no requested Android permissions.
- It remains a non-release candidate because the exact-head emulator failed.

### Scene-smoke leak

The exact-head `scene_smoke_test.txt` reports:
- 20 scenes loaded, 0 test failures.
- **3 CanvasItem RIDs leaked**.
- 9 DummyTexture RIDs, 6 shaped-text RIDs, 1 font RID and ObjectDB instances leaked at exit.

The test creates exactly three controls (`back_button`, `primary_button`, `toggle_button`) with `Button.new()` / `CheckButton.new()` and does not free them. QA comment [#7215633644](https://github.com/ninjun42215-gif/KindleWake/pull/185#issuecomment-7215633644) requests explicit cleanup and a rerun. The three CanvasItem RIDs are consistent with these unfreed test controls; other renderer/text leaks should be rechecked after cleanup.

A rerun of failed job `140350188464` was requested (run #45952128835 attempt 2). It was still in progress at the last poll; do not claim a rerun result until GitHub reports completion.

The headless test validates WAV import/format/duration and semantic label mapping, not audible playback, mix, SFX toggle, Master volume, latency, rapid-tap overlap or physical-speaker behavior. The new audio files also need a central `Kindlewake/data/asset_provenance.json` entry, coordinated with the shared asset-ledger owner. No central inventory/credits file is changed in this PR.

## PR #184 — companion quest completion save normalization

[PR #184](https://github.com/ninjun42215-gif/KindleWake/pull/184) is intentionally stacked on parent PR #179:
- Parent head: `c7630c816ed090f7a16b2d4dc77c429cdb82c5d2`.
- Child final head: `a7c8a7aa4957c7ba2a5958e3492e89635b68fa7d`, 8 ahead / 0 behind parent.
- Verified code/test head: `2d322a381019c839979e2c38fcff04ca6f07f630`.
- Final child head adds handoff documentation after the code/test head; it must not be described as if the 21-check evidence ran on the final handoff commit.

The code/test head adds 21 companion quest normalization/runtime assertions and is documented with 1,009 strict core checks, 20/20 scene smoke and campaign/Chronicle suites passing. Android run [#45938680852](https://github.com/ninjun42215-gif/KindleWake/actions/runs/45938680852) failed the old AOSP ATD / SwiftShader emulator stage after export/upload. The final handoff-only head's [YAML Lint #45939188872](https://github.com/ninjun42215-gif/KindleWake/actions/runs/45939188872) passed; no final-head Android run is established.

The exact code/test-head APK artifact [#15171128800](https://github.com/ninjun42215-gif/KindleWake/actions/runs/45938680852/artifacts/15171128800) was downloaded:
- ZIP SHA-256: `cf90b1842c6387f5ff064d2c85d638dd4a24d7588f194a64eee981be4eb0d964`, matching GitHub metadata; ZIP integrity passed.
- Extracted APK: 65,852,762 bytes; SHA-256 `0c2dfef29cd63d4fa221e218a3be31511ce567afe22a09c5ddf257c283d97e83`.
- This artifact belongs to code/test head `2d322a3`, not final docs-only head `a7c8a7a`.

QA comment [#7215634205](https://github.com/ninjun42215-gif/KindleWake/pull/184#issuecomment-7215634205) identifies an additional malformed-save edge case: progress accepts int/float then calls `int(progress_value)` before checking finite range. Add finite checks before integer conversion and clamp finite floats before casting; test NaN, positive/negative infinity and very large finite values. Keep the child stacked on #179 and draft.

## PR #182 — governor bonuses and long-run economy simulation

[PR #182](https://github.com/ninjun42215-gif/KindleWake/pull/182) current head: `ed28b188a189eb1ca2c4c2219bd09898633d8386`, base main, 25 ahead / 0 behind, draft.

The previously requested long-run balance coverage is now present. The exact-head test log includes a deterministic **24-month governor economy simulation** with 11 new assertions:
- 0, 1, 2 and 4 governors.
- Royal Roads disabled/enabled, including the one-time 400-gold cost.
- Progressive treasury outcomes.
- +8% realm income and +3 stability caps.
- 25%-tax / negative-net-upkeep cases with four governors, with and without Royal Roads.
- Negative monthly net remains visible in all 24 months; treasury/stability remain bounded; 24-entry history and processed-token windows are checked.

Exact-head run [#45936940378](https://github.com/ninjun42215-gif/KindleWake/actions/runs/45936940378):
- Project Health #45936940377 — passed.
- YAML Lint #45936940373 — passed.
- Version Sync #45936940386 — passed.
- Android Build #45936940378 — import, 20/20 scenes, 1,031 strict checks and APK export/upload passed; emulator failed.

Downloaded exact-head test-log artifact [#15171266520](https://github.com/ninjun42215-gif/KindleWake/actions/runs/45936940378/artifacts/15171266520):
- ZIP SHA-256: `44a041cb6ef3df16f6ad93b2feba394af304a70a2ae079abbbb9322f4daab0ca`, matching artifact metadata.
- 20 scenes loaded, 0 failures; 1,031 strict checks, 0 failures.
- The 24-month economy assertions passed.
- Screenshot is black; logcat contains four SceneShaderGLES3 link failures / GL_MAX_FRAGMENT_UNIFORM_VECTORS (261) overflow and app process death via signal 9. No Java fatal exception, native fatal signal, GDScript error or parse error was found.

Exact-head APK artifact [#15171102295](https://github.com/ninjun42215-gif/KindleWake/actions/runs/45936940378/artifacts/15171102295):
- ZIP SHA-256: `63660de0ac24f68c3151632b003b541de9302b2707582baab347dd858bf153f1`, matching metadata; ZIP integrity passed.
- Extracted APK: 65,852,762 bytes; SHA-256 `66070706ba83cc32171c1799541a21998db36bc4aa9e042c99fcef0abb31cea8`.
- Build summary reports valid CI/test signature, arm64-v8a / armeabi-v7a / x86_64 and no requested permissions.
- Not release-verified due emulator rendering failure.

## PR #183 — battlefield surface atlas

[PR #183](https://github.com/ninjun42215-gif/KindleWake/pull/183) remains stacked on rune VFX PR #171. Final head `c1acdd413b58dd986e710074847b65efba6a3f78`; parent head `e5e9f3ca1b7c66f7d46069b2b6a2c285dfe29a70`.

The earlier code-head visual validation passed SVG geometry, 20-scene smoke and strict checks, but the Android screenshot was blank and logcat had the same GLES3 link failures. QA comment [#7191616229](https://github.com/ninjun42215-gif/KindleWake/pull/183#issuecomment-7191616229) identified likely draw-order occlusion: the atlas hill detail is drawn before an opaque inner hill diamond. Reorder and inspect a gameplay-zoom hill screenshot on the alternate emulator. Central provenance/credits reconciliation also remains outstanding. No new exact-head Android verification was established this run.

## Main workflow and repository security review

Main workflow file SHAs:
- `.github/workflows/build-apk.yml`: `7f5ef9251ae0580791f5049637a4004dcb08630e`.
- `.github/workflows/publish-android-release.yml`: `583fa0e157cdd9ae3ffe3a935091a3eaea493964`.
- `.github/workflows/repository-organizer.yml`: `041ea7c438687762d39051986f493f928d6aa5ca`.
- `.github/workflows/safe-branch-integration.yml`: `018bf57851f8d0f0de14250094b9739185f4dcc8`.

Confirmed mainline weaknesses:
1. `build-apk.yml` uses AOSP ATD and `-gpu swiftshader_indirect`; the process-liveness-only check can accept blank UI, and its `grep ... || true` guard can swallow a detected renderer/script failure.
2. A tag-triggered `publish-tag-release` job grants `contents: write` and attaches a routine CI/test-signed APK to a GitHub Release.
3. `publish-android-release.yml` grants `contents: write` at workflow scope and records `github.sha` in the manifest even though the job checks out an input tag. The manifest should record the exact checked-out commit.
4. `repository-organizer.yml` and `safe-branch-integration.yml` grant workflow-wide `contents: write` and `pull-requests: write`.

PR #164 changes the candidate workflow to API 35 Google APIs with visible OCR checks, removes routine release attachment, scopes production write permission to the publishing job, records `git rev-parse HEAD` after immutable tag checkout and narrows maintenance workflow permissions. It should receive human security review before integration.

Production signing-secret presence and required environment reviewers remain unverified. No secret values were accessed. No releases exist. GitHub Actions Node.js 20 deprecation notices remain.

## Run 14 QA actions

- Posted PR #185 comment [#7215633644](https://github.com/ninjun42215-gif/KindleWake/pull/185#issuecomment-7215633644) for three leaked test controls, false-positive Android evidence, missing audible playback QA and central provenance.
- Posted PR #184 comment [#7215634205](https://github.com/ninjun42215-gif/KindleWake/pull/184#issuecomment-7215634205) for non-finite/oversized float handling in save normalization.
- Posted PR #164 comment [#7215670452](https://github.com/ninjun42215-gif/KindleWake/pull/164#issuecomment-7215670452) with the new #185 false-positive reproduction and support for keeping OCR/renderer guards mandatory.
- Re-ran only failed job `140350188464` for PR #185; attempt 2 was still running at the last poll. Its final result must be checked separately.
- No new code was pushed to another team's feature branch; no conflicting core/visual files were changed.

## Remaining release gates

1. Human review and integration of PR #164's alternate emulator and release-security changes.
2. Complete PR #185's attempt-2 rerun; fix the three unfreed test controls and rerun exact-head smoke.
3. Retest feature candidates with the API 35 Google APIs/OCR gate; reject black/blank screenshots even when the process remains alive.
4. Add finite-number handling and NaN/INF/large-float tests to PR #184.
5. Keep the 24-month governor simulation in PR #182 and obtain gameplay/economy review.
6. Correct battlefield hill-detail draw order and inspect real rendered screenshots.
7. Reconcile new audio/visual assets with the central provenance ledger and credits.
8. Physical Android testing: touch, saves, orientation, pause/resume, audio playback/mix, memory, thermal behavior and frame pacing.
9. Verify production signing and protected release approvals before publishing.

**No merge, force-push, branch deletion, repository-setting change, secret access or release publication occurred. No physical Android handset was tested.**


## Run 14 follow-up — PR #185 emulator retry completed

The failed Android job for PR #185 was rerun once (attempt 2) on the unchanged exact head `88603d2a2ea6e936035b61474e1659ad79e6d34c`. It failed again at emulator process survival:
- [Android Build #45952128835, attempt 2](https://github.com/ninjun42215-gif/KindleWake/actions/runs/45952128835) — failed.
- Exact-head test-log artifact [#15188987014](https://github.com/ninjun42215-gif/KindleWake/actions/runs/45952128835/artifacts/15188987014): ZIP SHA-256 `ff133afabdfd4e6c6a48325c772ace2e46b3b040e112a463b913775fb3164783`, matching GitHub artifact metadata; ZIP integrity passed.
- Screenshot is fully black. Logcat contains four SceneShaderGLES3 link failures because fragment uniforms exceed `GL_MAX_FRAGMENT_UNIFORM_VECTORS (261)`, followed by the app process exiting with signal 9. No Java FATAL EXCEPTION, native fatal signal, GDScript error or parse error was captured.
- The headless scene smoke still reports 3 CanvasItem RIDs leaked, 9 DummyTexture RIDs, 6 shaped-text RIDs, 1 font RID and ObjectDB instances leaked. The three CanvasItem RIDs are consistent with the three unfreed Button/CheckButton test controls.
- Exact-head attempt-2 APK [#15189765403](https://github.com/ninjun42215-gif/KindleWake/actions/runs/45952128835/artifacts/15189765403): ZIP SHA-256 `0e1bd65eb7d31ab40273e982075b270d81a51c56d0562ff3d2a913798f1ccda2`, matching metadata; ZIP integrity passed. Extracted APK: 65,886,370 bytes; SHA-256 `aac8bcf5b215dcd5cb5452dcfa63278cd0b0cb4210b638dded44e30208b2b819`. It remains a non-release candidate.

Two failed attempts on the same exact head now reproduce the renderer/process failure. The earlier successful attempt remains a visual false positive because its screenshot had only empty button panels and its logcat contained the same shader errors. PR #185 must use PR #164's OCR/renderer-error gate before any Android visual/runtime approval. QA follow-up comment [#7215736461](https://github.com/ninjun42215-gif/KindleWake/pull/185#issuecomment-7215736461) records the rerun evidence.
