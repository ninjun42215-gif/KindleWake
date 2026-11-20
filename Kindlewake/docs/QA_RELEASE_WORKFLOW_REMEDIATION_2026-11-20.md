# KindleWake QA — Android release workflow remediation (2026-11-20)

## Scope and exact refs

- Repository: https://github.com/ninjun42215-gif/KindleWake
- Canonical Godot project: `Kindlewake/` (Godot 4.2.2, GL Compatibility, Android)
- Current main base: `13f66ec19476c9af5ed2b5c81af95e4d8a026876`
- Existing QA PR: [#164 — Android emulator smoke and production release provenance](https://github.com/ninjun42215-gif/KindleWake/pull/164)
- QA branch: `qa/android-release-workflow-hardening-2026-11-18`
- Previous branch head before current-main refresh: `8d8ae2c641002f130480e270b834d65b845f1527`
- This refresh is a non-force fast-forward merge commit with current main as the second parent. No main write, PR merge, force-push, branch deletion, or repository-setting change is performed.

## Reproducible release-workflow findings

1. The routine `.github/workflows/build-apk.yml` workflow is triggered by `v*` tags and its legacy `publish-tag-release` job has `contents: write`. That job attaches the ordinary CI/test-signed APK to a GitHub Release, bypassing the separately protected production workflow. This conflicts with the documented candidate-only CI lane.
2. `.github/workflows/publish-android-release.yml` checks out the tag supplied by the manual-dispatch input, but the release manifest previously used `${{ github.sha }}`. On a dispatch launched from the default branch for a different tag, that can identify the dispatch ref rather than the actual checked-out tag commit.
3. The production workflow granted `contents: write` at workflow scope, including the rejected-confirmation job. The write permission is only needed by the protected publish job.
4. The API 35 AOSP ATD + forced SwiftShader path on current main failed after installation and activity launch. The logs report GLES3 shader uniform/resource limits and the Godot process did not remain alive. This is not proof of a physical-device failure. The QA candidate uses the standard Google APIs image, leaves GPU selection to the emulator default, checks the resumed Godot activity and visible title/menu text, and preserves logcat before assertions.

## Changes carried by this QA candidate

- Remove the routine tag-triggered release-publishing job; tag pushes still build and upload candidate artifacts.
- Keep production release publishing in the separate manual workflow with the `android-production` environment.
- Default production workflow permissions to `contents: read`; grant `contents: write` only to the protected `publish` job; give the rejected-confirmation job `contents: none`.
- Capture `git rev-parse HEAD` after checking out the requested tag and write that exact SHA into the release manifest.
- Extend workflow lint to reject routine release publishing, overly broad write permissions, and incorrect manifest source-SHA wiring.
- Use API 35 Google APIs x86_64 for emulator smoke, default GPU selection, resumed-activity checks and screenshot OCR for KINDLEWAKE / NEW GAME / SETTINGS.
- Keep source handoff and historical QA report records; no game content, scenes, save data, schemas, assets, or gameplay systems are changed.

## Exact-head verification

- Implementation/workflow SHA tested: `9e400b89ab059a03fc837fb098b38ac48b8c9cd5`.
- Base main SHA: `13f66ec19476c9af5ed2b5c81af95e4d8a026876`.
- PR #164 comparison at test time: 13 commits ahead / 0 behind; GitHub reported mergeable. PR remained draft.
- [Build Android APK #44722586171](https://github.com/ninjun42215-gif/KindleWake/actions/runs/44722586171): **passed end-to-end**, including import, strict tests, APK export, installation, launch, resumed activity, screenshot OCR and process liveness.
- [Project Health Audit #44722586121](https://github.com/ninjun42215-gif/KindleWake/actions/runs/44722586121): **passed**, 0 errors / 0 warnings.
- [Workflow YAML Lint #44722586089](https://github.com/ninjun42215-gif/KindleWake/actions/runs/44722586089): **passed**.
- [Version Sync #44722586039](https://github.com/ninjun42215-gif/KindleWake/actions/runs/44722586039): **passed**.

### Automated game/build results

- Godot 4.2.2 import: exit 0, no script errors.
- Scene smoke: 20 scenes loaded, 0 failures.
- Core regression suite: **1,009 checks, 0 failures**.
- Campaign lifecycle: pass.
- Merchant UI: pass.
- Title / creator UI: pass.
- Act V: pass.
- Campaign continuity: **70 checks, 0 failures**.
- Chronicle dynasty: **39 checks, 0 failures**.
- Chronicle family development: **19 checks, 0 failures**.
- Balance report: exit 0.
- APK signature: valid test signature (fingerprint prefix `c04a7792715ad8f5`).
- ABIs: `arm64-v8a`, `armeabi-v7a`, `x86_64`.
- Android permissions requested: none.

### Android emulator smoke evidence

The API 35 Google APIs x86_64 emulator installed and launched the app. The Godot activity remained foreground/resumed; the screenshot OCR found `KINDLEWAKE`, `NEW GAME` and `SETTINGS`, and the captured screenshot was visually inspected. No `FATAL EXCEPTION`, `Fatal signal`, `SCRIPT ERROR` or `Parse Error` was present in the captured logcat. This is a CI emulator result, not a physical-device test.

### APK artifact provenance

- Exact-head artifact: [Kindlewake-APK #14623280253](https://github.com/ninjun42215-gif/KindleWake/actions/runs/44722586171/artifacts/14623280253).
- Artifact archive SHA-256: `56cd40f9564d3eb2feb4fb5fdb0eea1b8b50ab0eb23c32da37b944b65a4d140f`; downloaded archive matched the GitHub artifact digest and passed ZIP integrity verification.
- Extracted APK: 65,852,762 bytes.
- Extracted APK SHA-256: `3547f91ce56059326f0752851aab070cecfa459e75c19c5abdfe1d6a08b29716`.
- Exact-head diagnostics: [test-logs #14623450310](https://github.com/ninjun42215-gif/KindleWake/actions/runs/44722586171/artifacts/14623450310), archive SHA-256 `7072a20c548557067ba731ae6763c340b8b38ea8d51a3cb256564b96b6ea1398`. Contains the build summary, suite logs, emulator logcat, window/activity state and screenshot/OCR output.
- Health report: [artifact #14623040593](https://github.com/ninjun42215-gif/KindleWake/actions/runs/44722586121/artifacts/14623040593), archive SHA-256 `ae5d36cff00a40692bc0b19280bbb7cd453d39563fd4962fa1458431281adb3e`. Reported 0 errors / 0 warnings, 44 JSON files, 88 GDScript files, 20 scenes, 77 rune definitions, 0 unverified asset entries and 0 unverified used assets.

The APK is a CI/test-signed candidate, not a production-signed release. Its artifact is tied to exact tested SHA `9e400b89ab059a03fc837fb098b38ac48b8c9cd5`; do not reuse it for a later commit.

### Mainline baseline and AOSP renderer issue

- Current main Android build [#44446304169](https://github.com/ninjun42215-gif/KindleWake/actions/runs/44446304169) on `13f66ec19476c9af5ed2b5c81af95e4d8a026876` exported a valid APK but failed the AOSP ATD / SwiftShader emulator liveness step.
- Downloaded main APK archive #14493646109 matched archive digest `9f5fbd39e4cb933ab4568d03f37f9a44c688a02d0903f644187037db36d3722c`; extracted APK SHA-256 `25679e76061f51c42daeffefa47f2e53c962237d33314783374364a8aa61a776`.
- Main test logs #14493611498 show the AOSP ATD renderer warning that global shader variable buffer size exceeds 16,384 bytes and repeated `SceneShaderGLES3` link failures because 261 active fragment uniforms exceed `GL_MAX_FRAGMENT_UNIFORM_VECTORS`; the Godot activity is destroyed and the process exits. The screenshot is black.
- The successful Google APIs emulator path avoids that failing AOSP ATD/SwiftShader combination; no runtime shader or rendering code was changed. Do not claim the underlying shader compatibility issue is fixed for all Android GPUs.

### Asset provenance and documentation review

- Main `asset_provenance.json` has 11 entries, 8 marked used, and 0 unverified used assets. The legacy voxel-building pack is explicitly `used_in_game: false`; unused LimeZu and MountainRocks archives remain excluded.
- Documentation mismatch: `docs/PROJECT_HEALTH_AUDIT.md` still describes the voxel-building pack as used and a release blocker, while the current ledger and `assets/art/CREDITS.md` say it is unused and replaced.
- Active visual PR #167 preloads `assets/art/tiles/local_architecture_detail.svg` from `scripts/ui/location_scene.gd` and has a separate asset provenance note, but the central `data/asset_provenance.json` and `assets/art/CREDITS.md` do not yet list this additional runtime asset. The current health audit does not cross-check runtime asset references against the central ledger. Flagged for the visual branch owners; this QA PR does not edit their branch.

## Release limitations

- No GitHub Releases are currently published.
- Production environment reviewer rules and signing-secret presence cannot be validated from this read-only audit; no secret values were read.
- The candidate APK is test-signed, not production-signed.
- Emulator success is CI evidence only; physical Android install, touch/gameplay, save/load and performance testing remain outstanding.
- Keep PR #164 draft until human review of the workflow/security diff. No merge to main is performed.


---

## Latest exact-head verification — 20 November 2026

This section supersedes the earlier 20 November candidate checkpoint above for the current PR head. Earlier SHA/run/artifact records remain historical and must not be reused as the latest build.

### Exact source refs

- Base `main`: `13f66ec19476c9af5ed2b5c81af95e4d8a026876`.
- Latest QA branch head: `ad3200b9b007a63e0f4db0bf3e33ce4eff46ffff`.
- Branch: `qa/android-release-workflow-hardening-2026-11-18`.
- PR #164: 15 commits ahead / 0 behind `main`; GitHub reports mergeable. PR remains draft.
- Latest commit: `qa: isolate credentials in manual maintenance workflows`.
- No merge, main write, force-push, branch deletion, repository-setting change, or secret access was performed.

### Exact-head CI results

All four PR checks ran against the exact head above and completed successfully:

- [Build Android APK #44725189995](https://github.com/ninjun42215-gif/KindleWake/actions/runs/44725189995) — passed end-to-end, including Android emulator installation, explicit activity launch, resumed-activity assertion, screenshot OCR, logcat assertions and process liveness.
- [Project Health Audit #44725190132](https://github.com/ninjun42215-gif/KindleWake/actions/runs/44725190132) — passed; report records 0 errors and 0 warnings, project version 0.12.0 and Android version code 1200.
- [Workflow YAML Lint #44725190041](https://github.com/ninjun42215-gif/KindleWake/actions/runs/44725190041) — passed; all 11 active workflow YAML files validated, including candidate-only CI publishing, least-privilege permissions, exact tag provenance and manual-maintenance credential isolation.
- [Version Sync #44725190094](https://github.com/ninjun42215-gif/KindleWake/actions/runs/44725190094) — passed; project/README/export metadata check reports synchronized.

Build details from the exact-head log artifact:

- Godot 4.2.2 import: exit 0; no script errors.
- Scene smoke: 20 scenes loaded, 0 failures.
- Core regression suite: 1,009 checks, 0 failures.
- Campaign lifecycle, merchant UI, title/creator UI and Act V: passed.
- Campaign continuity: 70 checks, 0 failures.
- Chronicle dynasty: 39 checks, 0 failures.
- Chronicle family development: 19 checks, 0 failures.
- Balance report: exit 0.
- APK signature: valid CI/test signature (certificate fingerprint prefix `c04a7792715ad8f5`).
- ABIs: `arm64-v8a`, `armeabi-v7a`, `x86_64`.
- Android permissions requested: none.

### Android emulator result and screenshot review

The exact-head workflow used API 35 Google APIs x86_64 with the emulator's default graphics selection. Logcat identifies ANGLE backed by Vulkan SwiftShader. The Godot activity remained resumed/foreground. OCR detected `KINDLEWAKE`, `NEW GAME` and `SETTINGS`; the captured logcat contains no `FATAL EXCEPTION`, `Fatal signal`, `SCRIPT ERROR` or `Parse Error`. The process remained alive after the 30-second launch interval.

The screenshot in the test-log artifact was also visually inspected: the title card is centered in landscape, title/subtitle and menu controls are visible, and the menu text is legible. `CONTINUE` is disabled on the fresh emulator install, consistent with the absence of a saved campaign; this is not a failure of the smoke test.

- [Exact-head test-log artifact #14623248375](https://github.com/ninjun42215-gif/KindleWake/actions/runs/44725189995/artifacts/14623248375), archive SHA-256 `fc1688d9da9596671f8d7019a03ebb2c9d90f5f8d6915971bf014a0f3330133f`. Contains screenshot, OCR text, 2.2 MB logcat, activity/window state and suite logs.

### Exact-head APK provenance

- [Exact-head APK artifact #14624006308](https://github.com/ninjun42215-gif/KindleWake/actions/runs/44725189995/artifacts/14624006308).
- Downloaded ZIP size: 65,297,808 bytes; ZIP integrity test passed.
- Downloaded ZIP SHA-256: `0f56241f485147633db2c717ca53a3d2fc8423f0a094b8ec2c66dd3ea0800f58`, matching GitHub's artifact digest.
- Extracted APK: 65,852,762 bytes.
- Extracted APK SHA-256 independently computed from the downloaded bytes: `3d06bfc9bc2c42a1316d19fb75936c27b9d025857fd75df2866bf5f04765cbb3`.
- The artifact's GitHub workflow metadata identifies source head `ad3200b9b007a63e0f4db0bf3e33ce4eff46ffff`; it must not be reused for another commit.
- This is a CI/test-signed candidate, not a production-signed release.

### Remaining release limitations and follow-up

- The earlier AOSP ATD / forced SwiftShader failure on current main remains a real CI configuration failure. This candidate changes the emulator image/backend and launch assertions; it does not modify the game's GLES3 shader code or prove compatibility with all Android GPUs.
- No physical Android device has been tested. Touch/gameplay, save/load on-device, orientation changes, memory/performance and vendor GPU compatibility remain unverified.
- Production signing-secret presence and `android-production` environment reviewer rules were not inspected; no secret values were read. No GitHub Releases exist.
- The successful workflow emits GitHub Node.js 20 deprecation warnings for pinned actions. They are non-fatal but should be addressed in a separate tested dependency-maintenance change.
- Visual PR #167 / stacked #169 still need central asset-ledger and credits reconciliation for their runtime-loaded architecture detail atlas before integration.
- Keep PR #164 draft for human workflow/security review. Do not merge it or claim physical-device release readiness.
