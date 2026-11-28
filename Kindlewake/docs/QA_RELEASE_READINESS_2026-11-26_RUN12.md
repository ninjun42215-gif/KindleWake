# KindleWake QA and Android release-readiness handoff — Run 12

**Date:** 26 November 2026  
**Repository:** https://github.com/ninjun42215-gif/KindleWake  
**Project:** `Kindlewake/` · Godot 4.2.2 · GL Compatibility · Android  
**Exact main:** `13f66ec19476c9af5ed2b5c81af95e4d8a026876`  
**QA documentation branch:** `qa/project-health-audit-doc-consistency-2026-11-21`  
**Related PR:** [#172 — QA documentation and release-readiness handoff](https://github.com/ninjun42215-gif/KindleWake/pull/172)

## Executive status

**Not release-ready.** Main is unchanged. This run independently inspected the latest battlefield-atlas and governor-bonus candidates, downloaded and verified the governor APK/log artifacts, opened the battlefield emulator screenshot, confirmed a false-positive in main's Android smoke gate, and added a static regression guard to QA PR #164. The corrected PR #164 head passes Project Health, Version Sync and Workflow YAML Lint; its Android build was still running at the last poll.

No physical Android handset was tested. No PR was merged. No force-push, branch deletion, repository-setting change, secret access, production tag or release publication occurred.

## 1. Live repository snapshot

- Default branch: `main`, exact SHA `13f66ec19476c9af5ed2b5c81af95e4d8a026876`. Its latest commit is dated 19 November 2026; feature branches have continued receiving commits without changing main.
- Branch API pagination returned 100 entries on page 1 and 87 on page 2: **187 branches**.
- Open pull requests: **44**; drafts: **42**.
- Published GitHub Releases: **0**.
- Main branch object reports `protected: false`; the rulesets endpoint returned an empty list. The detailed branch-protection endpoint is not available to this integration, so no repository settings were changed.
- The latest main-branch Actions entries are Safe Auto Merge only. [#45809199574](https://github.com/ninjun42215-gif/KindleWake/actions/runs/45809199574) skipped its job. [#45769098522](https://github.com/ninjun42215-gif/KindleWake/actions/runs/45769098522) completed successfully but skipped exact-PR verification and merge because there was no eligible PR for the triggering SHA. No merge occurred.
- No new main Android build, Project Health, Version Sync or source-handoff run was found. The latest known main Android build remains [#44446304169](https://github.com/ninjun42215-gif/KindleWake/actions/runs/44446304169), which failed at the AOSP ATD / forced SwiftShader emulator stage.
- The last independently verified main source snapshot remains [handoff run #44446304164](https://github.com/ninjun42215-gif/KindleWake/actions/runs/44446304164), artifact [#14493885543](https://github.com/ninjun42215-gif/KindleWake/actions/runs/44446304164/artifacts/14493885543). Its previous verification covered 370 tracked files, ZIP integrity and per-file hashes. Main has not changed since that snapshot.

## 2. Confirmed main Android smoke-test false-positive

The current `.github/workflows/build-apk.yml` still configures:

- Android emulator target `aosp_atd`;
- forced `-gpu swiftshader_indirect`;
- a 30-second process-liveness check;
- no screenshot OCR or visible-title/menu assertion;
- no explicit GLES shader-link/uniform-limit error assertion.

The existing fatal/script/parse check is also ineffective. Its shell form is:

`grep ... && { echo ...; exit 1; } || true`

When grep finds a fatal/script/parse error, the brace group exits nonzero, but the trailing `|| true` swallows that failure. When grep finds nothing, the final `true` also succeeds. Thus this check never fails for a match. The only effective Android assertion in main's current runner is process liveness.

This is not hypothetical: the PR #183 Android job passed while the screenshot had no title or button labels and logcat contained repeated shader-link failures.

## 3. PR #183 — battlefield surface atlas

[PR #183](https://github.com/ninjun42215-gif/KindleWake/pull/183) remains draft and mergeable. Latest head: `c1acdd413b58dd986e710074847b65efba6a3f78`; base is PR #171's branch `art/rune-combat-vfx-language-2026-11-21` at `e5e9f3ca1b7c66f7d46069b2b6a2c285dfe29a70`. It is 13 commits ahead of its parent and must not be integrated before #171.

### Exact latest-head checks

- [Visual Content Validation #45769372601](https://github.com/ninjun42215-gif/KindleWake/actions/runs/45769372601) passed on latest head `c1acdd...`: Godot 4.2.2 import, 20/20 scene smoke, strict suite **1,060 checks / 0 failures**, and 22-cell atlas geometry validation.
- [Workflow YAML Lint #45769379177](https://github.com/ninjun42215-gif/KindleWake/actions/runs/45769379177) passed on latest head.
- The Android build [#45768736707](https://github.com/ninjun42215-gif/KindleWake/actions/runs/45768736707) ran on earlier code head `53b2428311ddea10a02d481426ebcb85440ad7ea`, not the final docs head. Compare confirms the two commits from that code head to `c1acdd...` modify only `Kindlewake/docs/VISUAL_CONTENT_HANDOFF_2026-11-26_BATTLEFIELD_SURFACES.md`.

### Screenshot/logcat result

I independently downloaded [test-log artifact #15093207065](https://github.com/ninjun42215-gif/KindleWake/actions/runs/45768736707/artifacts/15093207065), verified its ZIP SHA-256 `9f99d94225aef53208f9272eb78378726f8fdd7a2b8c3549802170a5f10b99e2` against GitHub artifact metadata, extracted it, and opened `honor400-emulator.png`. The screenshot shows a centered menu panel and button rectangles but **no title or button text**.

Logcat records:
- global shader-variable buffer above the emulator's 16,384-byte uniform-buffer limit;
- repeated `SceneShaderGLES3: Program linking failed`;
- fragment uniforms above `GL_MAX_FRAGMENT_UNIFORM_VECTORS (261)`;
- shader compile/bind failure.

The process stayed alive long enough for the current mainline `pidof` assertion to pass. No Java `FATAL EXCEPTION`, native fatal-signal stack trace, GDScript error or parse error was found in this capture.

### APK provenance

APK artifact [#15093451389](https://github.com/ninjun42215-gif/KindleWake/actions/runs/45768736707/artifacts/15093451389) is from code head `53b242...`, not the final documentation head `c1acdd...`:

- ZIP SHA-256: `c83f1d4effead0d39a10ff1c539c17688dcf45ee26ea0c43a4fb9390c6ef58ae`, matching Actions metadata.
- Extracted APK: 65,877,755 bytes.
- APK SHA-256: `6fa7fd80033e8426ec09bc601f7fe0e3796cf06837cb347c0fae1528339ceef7`.
- Build summary reports a valid CI/test signature, ABIs `arm64-v8a`, `armeabi-v7a`, `x86_64`, and no requested Android permissions.

The artifact is valid for its exact code head but is not a visually successful Android smoke result and is not a production release. The final PR head has no Android build of its own. The atlas is original project-authored SVG (1,408 × 32, 22 cells at 64 × 32); actual import format, VRAM residency, frame-time impact and editor battle screenshots at multiple zoom levels remain unverified.

## 4. PR #182 — stat-based regional governor bonuses

[PR #182](https://github.com/ninjun42215-gif/KindleWake/pull/182) is draft and mergeable, 14 commits ahead / 0 behind main. Exact final head: `110066e3ba0d5779bb982288761e6174897d8c15`. Corrected code/test head: `4c464cd1102e24aa10a03d68597d7ac57aa5015c`; the final commit is documentation-only.

The implementation derives deterministic administrative bonuses from trained base attributes:
- Every four INT points above 6: +1% monthly realm income, capped at +2% per governor.
- Every four LDR points above 6: +1 realm stability per empire turn, capped at +2 per governor.
- Realm-wide caps: +8% income and +3 stability.
- Only held regions with active roster-backed governors count; duplicate assignments cannot stack the same companion.
- Income bonus applies after existing tax/policy multipliers. No new persistent field or save-schema change was added.

Exact final-head checks:
- [Project Health #45753941606](https://github.com/ninjun42215-gif/KindleWake/actions/runs/45753941606): passed.
- [Version Sync #45753941608](https://github.com/ninjun42215-gif/KindleWake/actions/runs/45753941608): passed.
- [Workflow YAML Lint #45753941617](https://github.com/ninjun42215-gif/KindleWake/actions/runs/45753941617): passed.
- [Android Build #45753941683](https://github.com/ninjun42215-gif/KindleWake/actions/runs/45753941683): import, 20-scene smoke, strict tests, APK export and upload passed; emulator launch failed.

Independently downloaded and checked:
- Test-log artifact [#15087256440](https://github.com/ninjun42215-gif/KindleWake/actions/runs/45753941683/artifacts/15087256440): ZIP SHA-256 `8aed952956e2eb02fae689b054f8a860ef29e0300a03196b65f1d2d6b133f073`, matching GitHub metadata; ZIP integrity passed.
- APK artifact [#15086766884](https://github.com/ninjun42215-gif/KindleWake/actions/runs/45753941683/artifacts/15086766884): ZIP SHA-256 `de4728a7506ab38fceb2bac1577f79775150661e89fe08d2d8c19ec2c17335e2`, matching GitHub metadata; ZIP integrity passed.
- Extracted APK: 65,852,762 bytes; SHA-256 `1991fae8fab44346d6c12e32aa95a96e21a9eebe9e4bde9e44bb980e4ebf86ab`.
- Build summary reports valid CI/test signature, three ABIs and no requested Android permissions.

The test log reports **1,020 strict checks / 0 failures**, 20 scenes / 0 failures, campaign continuity 70 / 0, Chronicle dynasty 39 / 0, family development 19 / 0, and 30 AI-vs-AI battle simulations. I opened the screenshot: it is fully black. Logcat repeats the 16,384-byte uniform-buffer warning and GLES3 fragment-uniform link errors. No Java fatal exception, native fatal signal, GDScript error or parse error was found.

The balance report simulates battles and grinding, not a deterministic 12/24-month realm-economy progression. The existing QA comment [#7190430035](https://github.com/ninjun42215-gif/KindleWake/pull/182) requests a focused economy simulation for thresholds, multi-governor stacking, +8%/+3 caps, tax, policy and upkeep interactions. Keep the PR draft until that evidence is available.

## 5. QA PR #164 — static regression guard added

[PR #164 — Android emulator and release workflow hardening](https://github.com/ninjun42215-gif/KindleWake/pull/164) remains draft and mergeable. This run added a static regression test to `.github/workflows/workflow-lint.yml` so future workflow edits cannot silently reintroduce the mainline Android smoke false-positive.

Latest branch head: `f6a4fb0b9ce3b653f96d146aef9022bcca558fb2`, 22 ahead / 0 behind main.

The new linter assertions require:
- the Google APIs emulator target;
- no forced `swiftshader_indirect`;
- OCR checks for `KINDLEWAKE`, `NEW GAME` and `SETTINGS`;
- explicit `USER ERROR`, `SceneShaderGLES3` and `GL_MAX_FRAGMENT_UNIFORM_VECTORS` renderer checks;
- a non-swallowed error exit pattern;
- installation of the OCR dependency.

The regex detector was locally checked against a known-bad `grep ... && exit 1 || true` example (detected) and a valid fail-fast grep example (not detected).

Exact-head results on `f6a4fb...`:
- [Project Health #45810983525](https://github.com/ninjun42215-gif/KindleWake/actions/runs/45810983525): passed.
- [Version Sync #45810983499](https://github.com/ninjun42215-gif/KindleWake/actions/runs/45810983499): passed.
- [Workflow YAML Lint #45810983616](https://github.com/ninjun42215-gif/KindleWake/actions/runs/45810983616): passed.
- [Android Build #45810983519](https://github.com/ninjun42215-gif/KindleWake/actions/runs/45810983519): passed on exact head `f6a4fb...`, including Godot import, 20-scene smoke, strict tests, APK export/upload, emulator installation/launch, foreground/resumed activity, screenshot OCR and shader/fatal log guards.

Exact-head artifact verification:
- APK artifact [#15114535341](https://github.com/ninjun42215-gif/KindleWake/actions/runs/45810983519/artifacts/15114535341): ZIP SHA-256 `603b5425cb40dfd70ea396f636d1a99390931885c941060b89b692a385e342a0`, matching GitHub artifact metadata; ZIP integrity passed.
- Extracted APK: 65,852,762 bytes; SHA-256 `3443c5e6c552224ae378d52a22b3ea045a84380e98a01de5ec46cf7d99096998`.
- Build summary reports valid CI/test signature, ABIs `arm64-v8a`, `armeabi-v7a`, `x86_64`, and no requested Android permissions.
- Test-log artifact [#15112392796](https://github.com/ninjun42215-gif/KindleWake/actions/runs/45810983519/artifacts/15112392796): ZIP SHA-256 `9c7eb6ce91ffa4bbf6714c73664905289564d47dbc6c1d67bbbb7204b874fc5f`, matching GitHub metadata; ZIP integrity passed.
- Strict suite: **1,009 checks / 0 failures**; scene smoke: **20 loaded / 0 failures**.
- OCR output contains `KINDLEWAKE`, `THE SUNDERED VOW`, `NEW GAME`, `LOAD GAME`, `SETTINGS` and `EXIT GAME`. I opened `pixel5-api35-title.png`; the title and menu labels are visibly rendered and legible.
- The 2.2 MB logcat has zero matches for USER ERROR, SceneShaderGLES3 link failure, GL_MAX_FRAGMENT_UNIFORM_VECTORS, shader compile/bind failure, fatal exception, native fatal signal, GDScript script error or parse error.
- This verifies the API 35 Google APIs x86_64 CI emulator path only. No physical handset was tested.

An intermediate commit `2d4d5b802e1152980d0d8cc9fb631e9310e000ea` failed YAML lint because its regex was over-escaped. That intermediate head is superseded by the corrected `f6a4fb...` head and its passing exact-head YAML lint. Do not use the intermediate failure as the current PR status.

PR #164's previous code head `03efa339e85df62763bada23c2f7f97d5158d514` passed all four exact-head checks on 22 November, including API 35 Google APIs emulator launch and title/menu OCR. The new `f6a4fb...` head has now passed its own exact-head Android build and screenshot/OCR gate.

## 6. Release workflow and repository health

Main's current release workflow still needs the PR #164 corrections:
- Routine `build-apk.yml` has a tag-triggered job that attaches a CI/test-signed APK to a GitHub Release.
- `publish-android-release.yml` grants `contents: write` at workflow scope rather than only to the publishing job.
- Its release manifest records `github.sha` rather than explicitly recording `git rev-parse HEAD` after checking out the requested immutable tag.
- `repository-organizer.yml` and `safe-branch-integration.yml` currently grant write permissions at workflow scope and use checkout credentials before their publication steps. PR #164 scopes write access, disables persisted checkout credentials and exposes the write token only in the final publisher step.

Production signing-secret presence and required environment reviewers remain unverified. No secret values were accessed.

Selected live divergence:
- PR #164: 22 ahead / 0 behind main.
- PR #172: 12 ahead / 0 behind main.
- PR #182: 14 ahead / 0 behind main.
- PR #183: 13 ahead / 0 behind its PR #171 parent; PR #171 is 9 ahead / 0 behind main.
- PR #181 is stacked on #175; it is 4 ahead of that parent. The parent is 6 ahead of main.
- PR #81's actual head `integration/trading-on-current-main`: 3 ahead / 146 behind main.
- PR #78 is stacked on `test/act-one-boss-balance-simulations`: 13 ahead / 0 behind its parent, but that parent is 57 ahead / 160 behind main.
- PR #46 empire management: 261 ahead / 161 behind main.

Do not bulk-merge the old divergent branches. No repository setting was changed.

## 7. Remaining release gates

1. Complete the exact-head Android Build #45810983519 on PR #164 and review its screenshot, OCR and logcat artifacts.
2. Retest PRs #182 and #183 using the corrected Google APIs/OCR workflow after their parent/branch dependencies are coordinated.
3. Add the requested governor economy simulation before approving the balance change.
4. Obtain Godot editor battle screenshots at multiple zoom levels and measure the new surface atlas's import size, GPU memory and frame-time impact.
5. Reconcile the new battlefield atlas with the central asset ledger and credits when the shared asset-inventory branch can be updated without conflict.
6. Perform physical Android installation and test touch input, save/load, orientation, pause/resume, low-memory behavior, thermal behavior and frame pacing.
7. Verify production signing configuration and protected release approvals before publishing.
8. Establish required main-branch status checks and release protection through owner-reviewed repository settings.

**Disposition:** main remains `13f66ec19476c9af5ed2b5c81af95e4d8a026876`. No merge, force-push, branch deletion, repository-setting change, secret access or release publication occurred. No physical Android device was tested.