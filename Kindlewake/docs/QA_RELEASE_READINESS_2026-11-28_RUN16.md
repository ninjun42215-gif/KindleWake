# QA and Android Release Readiness — Run 16

**Date:** 2026-11-28  
**Repository:** https://github.com/ninjun42215-gif/KindleWake  
**Project:** `Kindlewake/` · Godot 4.2.2 · GL Compatibility · Android  
**Observed main:** `13f66ec19476c9af5ed2b5c81af95e4d8a026876`  
**QA handoff PR:** [#172](https://github.com/ninjun42215-gif/KindleWake/pull/172)

## Executive disposition

**Not production-release-ready.** Main remains unchanged. This run inspected the current 191-branch / 48-open-PR repository snapshot, downloaded and inspected the latest PR #172 and PR #186 emulator screenshots/logcat, independently verified both exact-head APK archives and extracted APK hashes, reproduced the LocalMap validation rules across all 58 maps on PR #186, and posted a verification limitation on stacked QA PR #187.

A key result is that PR #186's Android job is green while its screenshot has no readable title/menu labels and logcat records GLES3 shader-link failures. Process liveness alone is not a valid visual smoke test. PR #164 remains the demonstrated alternate CI path with OCR and renderer-error guards, but is still draft and unmerged.

No merge, force-push, branch deletion, repository-setting change, secret access, production tag or release publication occurred. No physical Android handset was tested.

## 1. Live repository snapshot

- Default branch: `main`, exact SHA `13f66ec19476c9af5ed2b5c81af95e4d8a026876`; latest main commit dated 2026-11-19 02:42:49Z.
- Branch API pagination: 100 entries on page 1 and 91 on page 2 — **191 branches**.
- Open PRs: **48**, of which **46 are drafts**. The two non-draft PRs are #22 and #23.
- Published GitHub Releases: **0**.
- Main branch metadata reports `protected=false`; the repository rulesets endpoint returns `[]`. The branch-protection detail endpoint returned HTTP 403 to this integration, so detailed required-check/reviewer settings could not be inspected. No settings were changed.
- Latest Safe Auto Merge run [#46138620702](https://github.com/ninjun42215-gif/KindleWake/actions/runs/46138620702) completed with conclusion `skipped`. Earlier same-day main runs #46138227374 and #46138190465 were also skipped. No merge occurred.
- The latest main-branch Actions listing contains Safe Auto Merge runs only; no new main Android, Project Health, Version Sync, or source-handoff run was found. The last recorded main Android build remains [#44446304169](https://github.com/ninjun42215-gif/KindleWake/actions/runs/44446304169).
- The last verified main source snapshot remains [manual handoff #44446304164](https://github.com/ninjun42215-gif/KindleWake/actions/runs/44446304164), artifact [#14493885543](https://github.com/ninjun42215-gif/KindleWake/actions/runs/44446304164/artifacts/14493885543), previously verified for 370 tracked files and per-file hashes. Main has not changed since that snapshot.

## 2. PR #172 — exact-head Android failure and artifact

[PR #172](https://github.com/ninjun42215-gif/KindleWake/pull/172)  
Branch: `qa/project-health-audit-doc-consistency-2026-11-21`  
Exact latest head before this Run 16 documentation commit: `62b73e6374d6e937ec5079a9377ce1bc2b97ad9d`  
Base main: `13f66ec19476c9af5ed2b5c81af95e4d8a026876`  
Comparison: **23 ahead / 0 behind**, draft, GitHub reports mergeable but merge state unstable.

Exact-head checks:
- [Project Health Audit #46138374445](https://github.com/ninjun42215-gif/KindleWake/actions/runs/46138374445) — passed.
- [Workflow YAML Lint #46138374479](https://github.com/ninjun42215-gif/KindleWake/actions/runs/46138374479) — passed.
- [Synchronize Project Version #46138374486](https://github.com/ninjun42215-gif/KindleWake/actions/runs/46138374486) — passed.
- [Build Android APK #46138374476](https://github.com/ninjun42215-gif/KindleWake/actions/runs/46138374476) — **failed** at Android emulator verification.

### Headless/build evidence

The exact-head build logs report:
- Godot 4.2.2 project import exit 0.
- 20/20 scenes loaded.
- Core suite: **1,009 checks / 0 failures**.
- Campaign lifecycle, merchant UI, title/creator UI, Act V, campaign continuity (70), Chronicle dynasty (39), Chronicle family development (19), and balance report completed without reported failures.
- APK export and upload succeeded.

### Android failure diagnosis

I downloaded test-log artifact [#15261220039](https://github.com/ninjun42215-gif/KindleWake/actions/runs/46138374476/artifacts/15261220039), digest `d0e2d1e44a52693e474c14879e15b713998cd3a31cfd246755f503d4c0a6241a`, and opened `honor400-emulator.png`: the capture is fully black.

Logcat records:
- global shader-variable buffer warning above the emulator's 16,384-byte uniform-buffer limit;
- four `SceneShaderGLES3` program-link failures;
- fragment uniforms exceeding `GL_MAX_FRAGMENT_UNIFORM_VECTORS (261)`;
- shader compile/bind failure;
- KindleWake process death, followed by exit due to signal 9.

The job log also records an initial ADB daemon connection failure on port 5037 and a later `adb shell dumpsys activity activities` command exiting with code 1. No Java `FATAL EXCEPTION`, native fatal-signal stack trace, GDScript error or parse error was captured. The shader failure is confirmed; the exact initiator of SIGKILL is not established by these logs.

### Exact-head APK verification

Candidate artifact [#15260229585](https://github.com/ninjun42215-gif/KindleWake/actions/runs/46138374476/artifacts/15260229585):
- Artifact ZIP SHA-256: `4dcc161f33cee74dffdf83be80bd45232c74b31aeed3f6361f6a6b63e1f6b23f` — independently computed and matches GitHub artifact metadata.
- Extracted APK: 65,852,762 bytes; SHA-256 `7b6f0fa8905af258123a9094762e834430aac3bc10dfb9e264d694ab014f877b`.
- ZIP integrity: passed; archive contains one `Kindlewake.apk`.
- Build summary reports a valid CI/test signature, ABIs arm64-v8a / armeabi-v7a / x86_64, and no requested Android permissions.

The APK is tied to exact head `62b73e...`, but the emulator stage failed; it is not release-verified.

## 3. PR #186 — nine regional interiors and a green-but-visually-broken Android job

[PR #186](https://github.com/ninjun42215-gif/KindleWake/pull/186)  
Branch: `art/regional-interior-room-dressing-2026-11-28`  
Exact head: `23fa13eb6b87905f558b78d18246167eb54f62d2`  
Base main; **3 ahead / 0 behind**, draft, mergeable.

Exact-head checks:
- [Project Health Audit #46116868791](https://github.com/ninjun42215-gif/KindleWake/actions/runs/46116868791) — passed.
- [Workflow YAML Lint #46116868834](https://github.com/ninjun42215-gif/KindleWake/actions/runs/46116868834) — passed.
- [Synchronize Project Version #46116868839](https://github.com/ninjun42215-gif/KindleWake/actions/runs/46116868839) — passed.
- [Build Android APK #46116868790](https://github.com/ninjun42215-gif/KindleWake/actions/runs/46116868790) — concluded **success**, but is not a visual pass.

I downloaded and opened test-log artifact [#15252047912](https://github.com/ninjun42215-gif/KindleWake/actions/runs/46116868790/artifacts/15252047912). The screenshot shows the title/menu panel and empty button rectangles, with no readable title or menu labels. Logcat records the same 16,384-byte global shader-buffer warning and four GLES3 fragment-uniform link failures. The Godot activity is still top-resumed in the activity snapshot. No Java fatal exception, native fatal signal, GDScript error or parse error was captured.

This is a confirmed **current-main workflow false-positive**: process/activity liveness passed while the UI was visibly unusable. It is not a data regression attributed to the interior-layout PR. The current main workflow's shell guard at `.github/workflows/build-apk.yml` line 108 ends in `|| true`, so a matching renderer/script error can be swallowed. Its emulator step uses forced SwiftShader at line 85 and does not require OCR-visible title/menu text.

### Independent LocalMap validation

I fetched exact-head `Kindlewake/data/locations.json` and `LocalMap`'s current blocked/allowed glyph and connectivity rules, then independently reproduced the `LocalMap.validate()` semantics in JavaScript:

- **58 maps checked; 0 errors**.
- All nine edited maps remain 12×8 with rectangular rows.
- All entries remain walkable; all doors are defined/reachable; all target maps and spawn cells exist and are walkable.
- Every NPC/service/story spot retains a reachable interaction neighbour.
- All protected non-row map data is preserved; the nine edited maps change only row strings.

This is an independent data-level reproduction, not a Godot runtime execution or visual approval.

### Exact-head APK verification

Candidate artifact [#15251748869](https://github.com/ninjun42215-gif/KindleWake/actions/runs/46116868790/artifacts/15251748869):
- Artifact ZIP SHA-256: `a0d22077cc1cc522f7c2b1a4f3892de034a724dd4844d8f46a19ba757f50ac59` — independently computed and matches GitHub artifact metadata.
- Extracted APK: 65,852,762 bytes; SHA-256 `b8bbf2c2105891ff00a2baee264f1ebc3cc988adcb55e0b9ecd34b3b6eb6dad7`.
- ZIP integrity: passed; archive contains one `Kindlewake.apk`.
- Build summary reports valid CI/test signature, three ABIs and no requested permissions.

Keep #186 draft until the visual path is re-run with PR #164's OCR and renderer-error guards and a phone-scale interior screenshot/navigation walkthrough is available.

## 4. PR #187 — UI-audio scene-smoke cleanup is not runtime-verified

[PR #187](https://github.com/ninjun42215-gif/KindleWake/pull/187)  
Exact head: `a717f39fc6c3beb06364265cfab238524d47b8e5`  
Base: PR #185 branch at `88603d2a2ea6e936035b61474e1659ad79e6d34c`; **1 ahead / 0 behind parent**, draft, mergeable.

The three `free()` calls for temporary Button/Button/CheckButton controls are narrow and appropriate. However, the only exact-head run is [Workflow YAML Lint #46137431999](https://github.com/ninjun42215-gif/KindleWake/actions/runs/46137431999), which passed. No Project Health, Godot headless scene-smoke, strict test or Android build was triggered because this stacked PR targets the parent feature branch, not main.

QA comment [#7238582411](https://github.com/ninjun42215-gif/KindleWake/pull/187#issuecomment-7238582411) records the limitation. The previous parent PR #185 run reported three leaked CanvasItem RIDs. Keep #187 draft and stacked until a combined parent+child head runs `scene_smoke_test.gd` and confirms those control RIDs are gone. Do not treat YAML lint as runtime verification.

## 5. PR #185 — UI audio parent and asset provenance

[PR #185](https://github.com/ninjun42215-gif/KindleWake/pull/185)  
Exact head: `88603d2a2ea6e936035b61474e1659ad79e6d34c`; base main; **3 ahead / 0 behind**, draft.

Its last exact-head checks are:
- [Project Health #45952128762](https://github.com/ninjun42215-gif/KindleWake/actions/runs/45952128762) — passed.
- [Workflow YAML Lint #45952128794](https://github.com/ninjun42215-gif/KindleWake/actions/runs/45952128794) — passed.
- [Version Sync #45952128876](https://github.com/ninjun42215-gif/KindleWake/actions/runs/45952128876) — passed.
- [Android Build #45952128835](https://github.com/ninjun42215-gif/KindleWake/actions/runs/45952128835) — failed on the old emulator path; parent smoke log recorded three leaked CanvasItem RIDs plus retained dummy texture/shaped-text/font resources at exit.

The central `asset_provenance.json` still says it was updated 2026-11-19; `CREDITS.md` has no entry for the new UI-audio files. PR #185's own handoff describes the sounds as original, but the central inventory should be updated before release. Audio playback, mute preference, rapid-tap behavior and device speaker quality remain untested on a physical phone.

## 6. PR #164 — alternate Android and production-release workflow

[PR #164](https://github.com/ninjun42215-gif/KindleWake/pull/164)  
Exact head: `f6a4fb0b9ce3b653f96d146aef9022bcca558fb2`; base main; **22 ahead / 0 behind**, draft, mergeable.

The last recorded exact-head checks all passed:
- [Android Build #45810983519](https://github.com/ninjun42215-gif/KindleWake/actions/runs/45810983519) — API 35 Google APIs x86_64 emulator install/launch, Godot resumed activity, title/menu OCR and renderer/fatal log guards passed.
- [Project Health #45810983525](https://github.com/ninjun42215-gif/KindleWake/actions/runs/45810983525) — passed.
- [Workflow YAML Lint #45810983616](https://github.com/ninjun42215-gif/KindleWake/actions/runs/45810983616) — passed.
- [Version Sync #45810983499](https://github.com/ninjun42215-gif/KindleWake/actions/runs/45810983499) — passed.

This remains the only demonstrated visual Android CI path. It is a workflow correction, not a game GLES3 renderer fix and not physical-device verification.

## 7. Existing save/economy candidates

No new exact-head runs for these candidates were found during this pass; the following are the last recorded results, not fresh reruns:

- [PR #179 — garrison/reserve integrity](https://github.com/ninjun42215-gif/KindleWake/pull/179): head `b7e1cb61bd7cc5c0e19f67d76e318b3c5d74973f`, 4 ahead / 0 behind main; last dedicated numeric-validation suite 22 checks / 0 failures, including negative, fractional, NaN, ±INF, out-of-range float and maximum signed 64-bit handling.
- [PR #184 — companion quest save normalization](https://github.com/ninjun42215-gif/KindleWake/pull/184): head `fab926e41b0f7476894478de5e4de27eabbeb94e`, 11 ahead / 0 behind parent #179; last dedicated suite 24 checks / 0 failures. Keep stacked on #179.
- [PR #182 — governor bonuses](https://github.com/ninjun42215-gif/KindleWake/pull/182): head `ed28b188a189eb1ca2c4c2219bd09898633d8386`, 25 ahead / 0 behind main; last core suite 1,031 checks / 0 failures and deterministic 24-month economy simulation. Human playtesting of the hard opening boss and easy repeat encounters remains outstanding.

## 8. Branch divergence and integration health

Current comparisons against main:

| PR | Ahead | Behind | Disposition |
|---|---:|---:|---|
| #164 Android workflow | 22 | 0 | Current QA candidate |
| #172 QA handoff | 23 | 0 | Documentation only |
| #182 governor bonuses | 25 | 0 | Current gameplay candidate |
| #185 UI audio | 3 | 0 | Current feature candidate |
| #186 interior dressing | 3 | 0 | Current data candidate |
| #187 audio smoke cleanup | 1 | 0 vs parent | Stacked QA follow-up |
| #81 regional trading | 3 | 146 | Selective reconciliation |
| #78 headless CI | 70 | 160 | Highly divergent |
| #46 empire management | 261 | 161 | Highly divergent |
| #157 portrait identity | 34 | 9 | Coordinate shared asset files |
| #169 settlement style | 11 | 0 | Stacked on #167 |

Do not bulk-merge the highly divergent branches. Reconcile reviewed changes selectively on fresh current-main branches.

## 9. Workflow security, assets and handoff

The repository currently has 11 workflow files under `.github/workflows/`.

Main workflow risks confirmed by source inspection:
- `.github/workflows/build-apk.yml`: forced SwiftShader at line 85; error grep ends in `|| true` at line 108; routine tag-triggered `publish-tag-release` job grants `contents: write` at lines 125–132 and can attach a CI candidate to a GitHub Release.
- `.github/workflows/publish-android-release.yml`: workflow-wide `contents: write` at lines 18–19; manifest source uses `github.sha` at line 151 rather than an output captured from the exact checked-out tag commit.
- `repository-organizer.yml` and `safe-branch-integration.yml`: workflow-level `contents: write` and `pull-requests: write`; scope write credentials to the final publication step and keep audit-only work read-only.

PR #164's release workflow changes the production workflow to workflow-level `contents: read`, grants `contents: write` only to the publish job, records the checked-out commit SHA through a step output, and gives the rejected-confirmation job `contents: none`. Human review is still required.

The main `project.godot` confirms GL Compatibility for desktop/mobile and does not explicitly set `rendering/limits/global_shader_variables/buffer_size`. Do not assume the warning is caused by a custom project override; investigate the engine/emulator limits with a controlled GLES3 test.

The latest PR #172 build logs also contain GitHub Actions Node.js 20 deprecation warnings for cache/checkout/setup-python/upload-artifact actions. These are maintenance warnings, not the Android failure cause.

No production signing secrets were accessed. Secret presence, production environment protection and required reviewers remain unverified.

## 10. Final disposition and next priorities

1. Human review of PR #164's emulator and production-release security changes.
2. Retest PR #186 and other feature candidates using PR #164's OCR and renderer-error gates; do not accept a green process-liveness-only run.
3. Investigate the GLES3 global shader buffer / fragment uniform limit without attributing the SIGKILL to shaders until a causal trace exists.
4. Run PR #187's combined parent+child Godot scene-smoke and confirm the three CanvasItem RID leaks are gone.
5. Add the original UI-audio assets to the central provenance ledger and credits.
6. Continue save/load/migration verification for #179/#184 and human balance playtesting for #182.
7. Complete physical Android installation and testing: touch controls, save/load, orientation, pause/resume, memory, thermal behavior, frame pacing and audio.
8. Verify production signing and protected release approvals before publishing.

**Final disposition:** exact-head APK archives were verified for PR #172 and PR #186, but PR #172's Android job failed and PR #186's green Android job rendered a visibly blank menu. Main remains at `13f66ec19476c9af5ed2b5c81af95e4d8a026876`. No merge, force-push, branch deletion, repository-setting change, secret access or release publication occurred. No physical Android handset was tested.
