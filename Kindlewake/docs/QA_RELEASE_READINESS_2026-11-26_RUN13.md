# QA and Android Release Readiness — Run 13

**Date:** 26 November 2026  
**Repository:** https://github.com/ninjun42215-gif/KindleWake  
**Project:** `Kindlewake/` · Godot 4.2.2 · GL Compatibility · Android · offline-first  
**Observed main:** `13f66ec19476c9af5ed2b5c81af95e4d8a026876`  
**QA documentation branch:** `qa/project-health-audit-doc-consistency-2026-11-21`

## Executive disposition

**Not release-ready.** The current-main Android workflow remains a false-positive-prone AOSP ATD / forced SwiftShader path. The separate QA PR #164 has a stronger API 35 Google APIs emulator workflow that passed its exact-head checks, visible title/menu OCR, and renderer/fatal log guards. Two feature candidates (#182 and #183) still use the old Android path; #182's runtime smoke fails, while #183's older code-head run passed process liveness despite a blank screenshot and shader errors.

No main code, saves, game assets, repository settings, secrets, release tags or published releases were changed. No PR was merged, force-pushed, closed or deleted. No physical Android device was tested.

## Live repository snapshot

- Main: `13f66ec19476c9af5ed2b5c81af95e4d8a026876` (commit authored 19 Nov 2026 02:42:49Z).
- Branch API: 187 branches across the two retrieved pages.
- Open PR search: 44 open PRs.
- Published GitHub Releases: 0.
- Repository rulesets: empty list.
- Main branch metadata: `protected=false`; required status-check enforcement is off.
- Latest Safe Auto Merge run: [#45812331597](https://github.com/ninjun42215-gif/KindleWake/actions/runs/45812331597), skipped. Main SHA is unchanged.
- Earlier Safe Auto Merge runs #45811603937 and #45811474744 completed successfully, but no merge occurred; the default branch remains at the same SHA.

The latest 30-run query was dominated by PR checks and Safe Auto Merge runs. No newer main-branch Android build was present; the previously recorded main Android build [#44446304169](https://github.com/ninjun42215-gif/KindleWake/actions/runs/44446304169) failed at emulator startup.

## Mainline workflow defects confirmed by source inspection

Current `.github/workflows/build-apk.yml` still:
- selects `target: aosp_atd` and forces `-gpu swiftshader_indirect`;
- changes emulator size/density before launch;
- has no screenshot OCR or explicit GLES renderer-error gate;
- uses `grep ... && { ...; exit 1; } || true`, which can swallow the failure branch and turn a detected runtime error into a successful shell result;
- contains a tag-triggered `publish-tag-release` job with `contents: write`, allowing a routine CI/test-signed APK to be attached to a GitHub Release.

Current main `publish-android-release.yml`, `repository-organizer.yml`, and `safe-branch-integration.yml` still have broader write permissions than necessary. The current production workflow also needs exact checked-out tag SHA provenance. No secret values were accessed.

## PR #164 — alternate Android/release workflow

[PR #164](https://github.com/ninjun42215-gif/KindleWake/pull/164)  
Branch: `qa/android-release-workflow-hardening-2026-11-18`  
Exact head: `f6a4fb0b9ce3b653f96d146aef9022bcca558fb2`  
Base: main `13f66ec19476c9af5ed2b5c81af95e4d8a026876`  
Divergence: 22 ahead / 0 behind; draft, mergeable, unmerged.

Exact-head checks:
- [Android Build #45810983519](https://github.com/ninjun42215-gif/KindleWake/actions/runs/45810983519) — passed.
- [Project Health #45810983525](https://github.com/ninjun42215-gif/KindleWake/actions/runs/45810983525) — passed.
- [Workflow YAML Lint #45810983616](https://github.com/ninjun42215-gif/KindleWake/actions/runs/45810983616) — passed.
- [Version Sync #45810983499](https://github.com/ninjun42215-gif/KindleWake/actions/runs/45810983499) — passed.

The API 35 Google APIs x86_64 / Pixel 5 emulator installed and launched the APK, retained the Godot activity in the foreground/resumed state, and produced readable title/menu OCR. OCR includes `KINDLEWAKE`, `THE SUNDERED VOW`, `NEW GAME`, `LOAD GAME`, `SETTINGS`, and `EXIT GAME`. I opened the exact screenshot; title and menu labels are visible and legible. Logcat had zero matches for USER ERROR, SceneShaderGLES3 link failure, GL_MAX_FRAGMENT_UNIFORM_VECTORS, global shader buffer warning, shader compile/bind failure, fatal exception, native fatal signal, script error or parse error.

Exact-head APK:
- Artifact [#15114535341](https://github.com/ninjun42215-gif/KindleWake/actions/runs/45810983519/artifacts/15114535341), ZIP size 65,297,900 bytes.
- ZIP SHA-256: `603b5425cb40dfd70ea396f636d1a99390931885c941060b89b692a385e342a0` (matches GitHub artifact metadata; ZIP integrity passed).
- Extracted APK: 65,852,762 bytes; SHA-256 `3443c5e6c552224ae378d52a22b3ea045a84380e98a01de5ec46cf7d99096998`.
- Test-log artifact [#15112392796](https://github.com/ninjun42215-gif/KindleWake/actions/runs/45810983519/artifacts/15112392796), ZIP SHA-256 `9c7eb6ce91ffa4bbf6714c73664905289564d47dbc6c1d67bbbb7204b874fc5f`; ZIP integrity passed.
- Build summary: Godot 4.2.2 import passed; 20 scenes / 0 failures; 1,009 strict checks / 0 failures; campaign/UI/Act V/continuity/dynasty/family/balance checks passed.
- Build summary reports valid CI/test signature, ABIs arm64-v8a / armeabi-v7a / x86_64, and no Android permissions requested.

The PR also removes routine release publication from the candidate workflow, scopes production `contents: write` to the protected publish job, gives the rejected-confirmation job `contents: none`, records `git rev-parse HEAD` after immutable tag checkout, disables persisted checkout credentials in manual maintenance workflows and limits their write token to final publication steps.

This is CI/test-emulator evidence only. It does not alter game GLES3 shaders or prove compatibility with every physical Android GPU.

## PR #182 — governor stat bonuses

[PR #182](https://github.com/ninjun42215-gif/KindleWake/pull/182)  
Branch: `feat/governor-stat-bonuses-2026-11-26`  
Exact final head: `110066e3ba0d5779bb982288761e6174897d8c15`  
Corrected code/test head: `4c464cd1102e24aa10a03d68597d7ac57aa5015c`  
Base main; 14 ahead / 0 behind; draft, mergeable, unmerged.

The final head is one documentation-only commit beyond the corrected code/test head; the comparison shows only `CORE_ENGINEERING_HANDOFF_2026-11-26.md` changed. Final-head Android run [#45753941683](https://github.com/ninjun42215-gif/KindleWake/actions/runs/45753941683) completed with import/test/export steps successful and emulator launch failed.

Independently downloaded exact-final-head artifacts:
- Test logs [#15087256440](https://github.com/ninjun42215-gif/KindleWake/actions/runs/45753941683/artifacts/15087256440), ZIP SHA-256 `8aed952956e2eb02fae689b054f8a860ef29e0300a03196b65f1d2d6b133f073`; ZIP integrity passed.
- APK [#15086766884](https://github.com/ninjun42215-gif/KindleWake/actions/runs/45753941683/artifacts/15086766884), ZIP SHA-256 `de4728a7506ab38fceb2bac1577f79775150661e89fe08d2d8c19ec2c17335e2`; ZIP integrity passed.
- Extracted APK: 65,852,762 bytes; SHA-256 `1991fae8fab44346d6c12e32aa95a96e21a9eebe9e4bde9e44bb980e4ebf86ab`.
- Build summary reports a valid CI/test signature, ABIs arm64-v8a / armeabi-v7a / x86_64 and no requested Android permissions.

Test evidence from the final-head log artifact:
- Godot 4.2.2 import passed.
- 20 scenes loaded / 0 failures.
- Strict suite: **1,020 checks / 0 failures**.
- Campaign lifecycle, merchant UI, title/creator UI, Act V, campaign continuity, Chronicle dynasty and family-development suites passed.
- Existing `balance_report.txt` exited successfully, but it is a battle/grind report (AI-vs-AI battle scenarios and 60 skirmishes), not a governor/realm-economy simulation.

Android emulator evidence:
- Screenshot is black.
- Logcat reports the global shader-variable buffer exceeds the 16,384-byte uniform-buffer limit and repeated `SceneShaderGLES3` link errors because fragment uniforms exceed `GL_MAX_FRAGMENT_UNIFORM_VECTORS (261)`.
- No Java FATAL EXCEPTION, native fatal signal, GDScript error or parse error was found.
- The process-liveness check failed after GodotActivity was destroyed. Treat this as the old AOSP ATD / SwiftShader renderer/process-survival failure, not a physical-device result.

QA comment [#7191616982](https://github.com/ninjun42215-gif/KindleWake/pull/182) requests a deterministic 12–24 month realm-economy simulation before balance approval. Compare no-governor, one/two/max-governor cases with Royal Roads, high tax and negative upkeep; assert bounded treasury/stability. The current battle balance report does not validate long-run governor economy effects.

## PR #183 — battlefield surface atlas

[PR #183](https://github.com/ninjun42215-gif/KindleWake/pull/183)  
Branch: `art/battlefield-surface-atlas-2026-11-26`  
Exact final head: `c1acdd413b58dd986e710074847b65efba6a3f78`  
Parent PR #171 exact base: `e5e9f3ca1b7c66f7d46069b2b6a2c285dfe29a70`  
Stacked: 13 commits ahead of parent; parent #171 is 9 ahead / 0 behind main. PR #183 must remain dependent on #171.

The final head is two documentation-only commits beyond code head `53b2428311ddea10a02d481426ebcb85440ad7ea`; the comparison shows only the battlefield visual handoff document changed.

Code-head [Visual Content Validation #45768730864](https://github.com/ninjun42215-gif/KindleWake/actions/runs/45768730864) passed Godot 4.2.2 import, 20-scene smoke, 1,060 strict checks and SVG atlas geometry/provenance assertions. Final-head YAML lint [#45768779177](https://github.com/ninjun42215-gif/KindleWake/actions/runs/45768779177) passed. No Android build ran on the final documentation head.

Code-head Android run [#45768736707](https://github.com/ninjun42215-gif/KindleWake/actions/runs/45768736707) reported overall success and APK export, but screenshot inspection disproved usable rendering:
- Screenshot in test-log artifact [#15093207065](https://github.com/ninjun42215-gif/KindleWake/actions/runs/45768736707/artifacts/15093207065) shows only a dark menu shell and blank button rectangles; title and button labels are absent.
- Logcat contains the 16,384-byte global uniform-buffer warning, four SceneShaderGLES3 / GL_MAX_FRAGMENT_UNIFORM_VECTORS link errors and eight USER ERROR matches; no Java fatal exception, native fatal signal, script error or parse error.
- This is a process-liveness false positive in main's old emulator workflow, not successful visual smoke.

Exact code-head APK artifact [#15093451389](https://github.com/ninjun42215-gif/KindleWake/KindleWake/actions/runs/45768736707/artifacts/15093451389):
- ZIP SHA-256 `c83f1d4effead0d39a10ff1c539c17688dcf45ee26ea0c43a4fb9390c6ef58ae`.
- Extracted APK: 65,877,755 bytes; SHA-256 `6fa7fd80033e8426ec09bc601f7fe0e3796cf06837cb347c0fae1528339ceef7`.
- Test-log ZIP SHA-256 `9f99d94225aef53208f9272eb78378726f8fdd7a2b8c3549802170a5f10b99e2`.
- Both archives independently downloaded; ZIP integrity passed. The APK is a CI/test candidate, not a production release.

New QA comment [#7191616229](https://github.com/ninjun42215-gif/KindleWake/pull/183) identifies a likely visual layering defect: `_draw_tile` draws the atlas detail before the `hill` case paints an opaque inner diamond, which can cover the center of the new hill detail. Requested reorder plus a hill screenshot at gameplay zoom. This is a source-order finding; physical-device visual verification has not been claimed.

The PR adds a per-asset provenance sidecar and a visual validation workflow, but the changed-file list does not include the central `data/asset_provenance.json` or `assets/art/CREDITS.md`. Coordinate central-ledger and credits reconciliation with the shared asset-inventory work; do not overwrite another visual branch's files.

## PR #172 — QA handoff branch status

[PR #172](https://github.com/ninjun42215-gif/KindleWake/pull/172)  
Exact head: `0233704b55dbb78436f55fed6285a31d96ebbe27`; 14 ahead / 0 behind main; draft, mergeable, unmerged.

Exact-head runs:
- Project Health #45811849430 — passed.
- YAML Lint #45811849480 — passed.
- Version Sync #45811849426 — passed.
- Android Build #45811849450 — failed at emulator process-liveness after import/tests/APK export succeeded.

The final Android failure log repeats the AOSP ATD / SwiftShader startup failure. APK artifact [#15114331339](https://github.com/ninjun42215-gif/KindleWake/actions/runs/45811849450/artifacts/15114331339) ZIP SHA-256 `be12fd40eae518001b30a9b0e8bcefcb5a9a2c7bc234040b196392444f406c42`; extracted APK SHA-256 `995eefca0cdf180ec300037bce0175f4fb89c8022b4c89e8fe1eecbee735acf5`. Test-log artifact [#15112818380](https://github.com/ninjun42215-gif/KindleWake/actions/runs/45811849450/artifacts/15112818380) ZIP SHA-256 `ab203f7c37cf20241cb2ccba64e3cc05fd96f197be8dbcbd01f493237a729376`. These are exact-head CI artifacts, not release-ready.

## Selected active branch divergence

- PR #164: 22 ahead / 0 behind main.
- PR #172: 14 ahead / 0 behind main.
- PR #182: 14 ahead / 0 behind main.
- PR #183: 13 ahead / 0 behind its #171 parent; #171 is 9 ahead / 0 behind main.
- PR #175: 6 ahead / 0 behind main.
- PR #181: 10 ahead / 0 behind main, stacked on #175 (4 commits beyond that parent).
- PR #81 regional trading: 3 ahead / 146 behind main.
- PR #78 headless CI: 70 ahead / 160 behind main.
- PR #46 empire management: 261 ahead / 161 behind main.

Do not bulk-merge highly divergent legacy branches. Reconcile reviewed changes selectively onto a fresh current-main base.

## Source handoff and provenance

No newer main source-handoff artifact was observed in the latest Actions page. The last independently documented main snapshot remains [run #44446304164](https://github.com/ninjun42215-gif/KindleWake/actions/runs/44446304164), artifact [#14493885543](https://github.com/ninjun42215-gif/KindleWake/KindleWake/actions/runs/44446304164/artifacts/14493885543). Its prior verification covered 370 tracked files, reconstructed archive hash, ZIP CRC and individual tracked-file hashes. Main has not changed since that snapshot.

No GitHub Releases exist. Production signing-secret presence and protected environment reviewers remain unverified. No secrets were read.

## Next priorities

1. Human workflow/security review of PR #164; integrate only through normal owner review, not automatic QA merge.
2. Retest PR #182 and PR #183 using the Google APIs/OCR/renderer-error workflow from PR #164 after preserving the #183 → #171 dependency.
3. Add the 12–24 month governor-economy simulation requested on #182.
4. Fix the hill atlas layering order on #183 and capture editor screenshots for grass, forest, ford, snow, ash, ruins and hill at normal gameplay zoom.
5. Reconcile battlefield atlas central provenance and credits with the shared asset branch.
6. Retest save/load and migration candidates on the corrected emulator path.
7. Complete physical-device Android testing: touch, save/load, orientation, pause/resume, memory, thermal behavior, frame pacing and vendor GPU compatibility.
8. Verify production signing and protected release approvals; owner review is needed to configure main branch protection and required checks.
9. Update pinned GitHub Actions/runtime dependencies to remove Node.js 20 deprecation warnings after compatibility testing.

**Final disposition:** main remains `13f66ec19476c9af5ed2b5c81af95e4d8a026876`. No merge, force-push, branch deletion, repository-setting change, secret access, production tag or release publication occurred. No physical Android handset was tested.
