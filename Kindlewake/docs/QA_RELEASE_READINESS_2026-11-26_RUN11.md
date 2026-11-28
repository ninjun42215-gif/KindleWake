# KindleWake QA and Android release-readiness handoff — Run 11

**Date:** 26 November 2026  
**Repository:** https://github.com/ninjun42215-gif/KindleWake  
**Project:** `Kindlewake/` · Godot 4.2.2 · GL Compatibility · Android  
**Exact main:** `13f66ec19476c9af5ed2b5c81af95e4d8a026876`  
**QA documentation branch:** `qa/project-health-audit-doc-consistency-2026-11-21`  
**Related PR:** [#172 — QA documentation and release-readiness handoff](https://github.com/ninjun42215-gif/KindleWake/pull/172)

## Executive status

**Not release-ready.** Main is unchanged at the exact SHA above. This run independently downloaded and verified two new APK artifacts, inspected the Android screenshot and logcat from PR #183, confirmed a visual false-positive in the mainline emulator smoke test, reviewed the new governor-bonus implementation in PR #182, and audited auto-merge/release workflow permissions.

No physical Android handset was tested. No PR was merged. No force-push, branch deletion, repository-setting change, secret access, production tag or release publication occurred.

## 1. Live repository snapshot

- Default branch: `main`, exact SHA `13f66ec19476c9af5ed2b5c81af95e4d8a026876`; its latest commit is dated 19 November 2026.
- Branch API pagination returned 100 entries on page 1 and 87 on page 2: **187 branches total**. The `main` branch object reports `protected: false`.
- Open pull requests: **44**; drafts: **42**; the two non-draft PRs are #22 and #23.
- Published GitHub Releases: **0**.
- The rulesets endpoint returned an empty list. The detailed branch-protection endpoint returned HTTP 403 for this GitHub integration, so individual required-status-check and reviewer settings could not be independently inspected.
- No newer main push Build Android APK / Project Health / Version Sync run appeared in the current Actions listing. The latest main Android build remains [#44446304169](https://github.com/ninjun42215-gif/KindleWake/actions/runs/44446304169), which failed at the AOSP ATD / forced SwiftShader emulator process-survival step on 19 November. Main Project Health [#44446304110](https://github.com/ninjun42215-gif/KindleWake/actions/runs/44446304110), YAML lint [#44446304180](https://github.com/ninjun42215-gif/KindleWake/actions/runs/44446304180), Version Sync [#44446304299](https://github.com/ninjun42215-gif/KindleWake/actions/runs/44446304299), and source handoff [#44446304164](https://github.com/ninjun42215-gif/KindleWake/actions/runs/44446304164) are the latest known mainline results.
- Latest Safe Auto Merge run [#45769098522](https://github.com/ninjun42215-gif/KindleWake/actions/runs/45769098522) completed successfully as a **no-op**. Its log explicitly says no open PR owned triggering SHA `53b2428311ddea10a02d481426ebcb85440ad7ea`; workflow verification/merge steps were skipped. No merge occurred.

## 2. PR #183 — battlefield surface atlas and Android visual false-positive

[PR #183](https://github.com/ninjun42215-gif/KindleWake/pull/183) remains draft and mergeable. Its latest head is `c1acdd413b58dd986e710074847b65efba6a3f78`, 13 commits ahead of its parent branch `art/rune-combat-vfx-language-2026-11-21` at `e5e9f3ca1b7c66f7d46069b2b6a2c285dfe29a70`. It is stacked on PR #171 and must not be integrated before its parent.

### Exact latest-head checks

- [Visual Content Validation #45769372601](https://github.com/ninjun42215-gif/KindleWake/actions/runs/45769372601) passed on latest head `c1acdd...`: Godot 4.2.2 import, 20/20 scene smoke, strict suite **1,060 checks / 0 failures**, and 22-cell SVG atlas geometry validation.
- [Workflow YAML Lint #45769379177](https://github.com/ninjun42215-gif/KindleWake/actions/runs/45769379177) passed on the same latest head.
- The Android build was run on earlier code head `53b2428311ddea10a02d481426ebcb85440ad7ea`, not the final docs head. Compare confirms the two commits from `53b242...` to `c1acdd...` change only `Kindlewake/docs/VISUAL_CONTENT_HANDOFF_2026-11-26_BATTLEFIELD_SURFACES.md`.

### Android build false-positive

[Build Android APK #45768736707](https://github.com/ninjun42215-gif/KindleWake/actions/runs/45768736707) reported success on code head `53b242...`, including APK export, install, emulator launch and process-liveness. However, I independently downloaded and visually inspected [test-log artifact #15093207065](https://github.com/ninjun42215-gif/KindleWake/actions/runs/45768736707/artifacts/15093207065): the screenshot shows a blank, textless menu shell (panel and button rectangles only). Logcat contains:
- `rendering/limits/global_shader_variables/buffer_size` exceeding the emulator's 16,384-byte uniform-buffer limit;
- repeated `SceneShaderGLES3: Program linking failed`;
- fragment shader active uniforms exceeding `GL_MAX_FRAGMENT_UNIFORM_VECTORS (261)`;
- shader compile/bind failure.

The process remained alive long enough for the existing `pidof` check to pass. The mainline build workflow only checks process liveness plus fatal/script/parse patterns; it does not reject these USER ERROR shader-link failures or require visible title/menu text. Therefore the green Android workflow conclusion is a **visual-rendering false-positive**, not a successful visual smoke test. No Java `FATAL EXCEPTION`, native fatal-signal stack trace, GDScript error or parse error was found in this capture.

### Independent APK byte verification

Downloaded [APK artifact #15093451389](https://github.com/ninjun42215-gif/KindleWake/actions/runs/45768736707/artifacts/15093451389), tied to code head `53b242...`:
- ZIP SHA-256: `c83f1d4effead0d39a10ff1c539c17688dcf45ee26ea0c43a4fb9390c6ef58ae`, matching GitHub artifact metadata.
- Extracted APK: 65,877,755 bytes.
- APK SHA-256: `6fa7fd80033e8426ec09bc601f7fe0e3796cf06837cb347c0fae1528339ceef7`.
- Build summary reports a valid CI/test signature, ABIs `arm64-v8a`, `armeabi-v7a`, `x86_64`, and no requested Android permissions.

Downloaded test-log ZIP SHA-256: `9f99d94225aef53208f9272eb78378726f8fdd7a2b8c3549802170a5f10b99e2`, matching GitHub artifact metadata; ZIP extraction succeeded.

The atlas is original project-authored vector art: 1,408 × 32 SVG pixels, 22 cells at 64 × 32. The latest-head validation checks geometry and mapping; actual device VRAM residency, texture compression and frame-time impact remain unmeasured.

## 3. PR #182 — stat-based regional governor bonuses

[PR #182](https://github.com/ninjun42215-gif/KindleWake/pull/182) is draft and mergeable, 14 commits ahead / 0 behind main. Exact final head: `110066e3ba0d5779bb982288761e6174897d8c15`. Corrected code/test head: `4c464cd1102e24aa10a03d68597d7ac57aa5015c`.

The implementation derives administration effects from trained base attributes:
- Every four INT points above 6 grants +1% monthly realm income, capped at +2% per governor.
- Every four LDR points above 6 grants +1 realm stability per empire turn, capped at +2 per governor.
- Realm-wide caps: +8% income and +3 stability per turn.
- Only held player regions and active roster-backed governors contribute; duplicate assignments cannot stack one character twice.
- No save-schema/version change or new persistent fields were introduced.

### Exact final-head checks

- [Project Health #45753941606](https://github.com/ninjun42215-gif/KindleWake/actions/runs/45753941606): passed.
- [Version Sync #45753941608](https://github.com/ninjun42215-gif/KindleWake/actions/runs/45753941608): passed.
- [Workflow YAML Lint #45753941617](https://github.com/ninjun42215-gif/KindleWake/actions/runs/45753941617): passed.
- [Android Build #45753941683](https://github.com/ninjun42215-gif/KindleWake/actions/runs/45753941683): Godot import, 20-scene smoke, strict tests, APK export and upload passed; overall Android job failed during emulator launch.

Downloaded test-log artifact [#15087256440](https://github.com/ninjun42215-gif/KindleWake/actions/runs/45753941683/artifacts/15087256440), ZIP SHA-256 `8aed952956e2eb02fae689b054f8a860ef29e0300a03196b65f1d2d6b133f073`, matching GitHub metadata:
- Strict suite: **1,020 checks / 0 failures**, 0 script errors, 0 parse errors.
- 20 scenes loaded, 0 failures.
- Campaign lifecycle, merchant UI, title/creator UI, Act V, continuity, Chronicle dynasty/family and balance report completed.
- Logcat repeats the 16,384-byte uniform-buffer warning and `GL_MAX_FRAGMENT_UNIFORM_VECTORS (261)` shader-link failures; GodotActivity is destroyed. The screenshot is black. No Java fatal exception, native fatal signal, GDScript error or parse error was captured.

Downloaded exact-final-head APK artifact [#15086766884](https://github.com/ninjun42215-gif/KindleWake/actions/runs/45753941683/artifacts/15086766884):
- ZIP SHA-256: `de4728a7506ab38fceb2bac1577f79775150661e89fe08d2d8c19ec2c17335e2`, matching GitHub metadata.
- Extracted APK: 65,852,762 bytes.
- APK SHA-256: `1991fae8fab44346d6c12e32aa95a96e21a9eebe9e4bde9e44bb980e4ebf86ab`.
- Build summary reports valid CI/test signature, three ABIs and no requested Android permissions.

The balance report includes AI battle simulation, but I did not find a deterministic 12/24-month realm-economy simulation specifically exercising governor thresholds, multi-governor stacking, +8% income / +3 stability caps and interaction with tax, policy and upkeep. A focused economy simulation was requested in a PR comment before approval.

## 4. Android/release workflow and auto-merge audit

### PR #164 — alternate emulator and release hardening

[PR #164](https://github.com/ninjun42215-gif/KindleWake/pull/164) remains draft, mergeable, 20 ahead / 0 behind main, exact head `03efa339e85df62763bada23c2f7f97d5158d514`. Its last exact-head verification on 22 November passed all four checks:
- [Build Android APK #45014535413](https://github.com/ninjun42215-gif/KindleWake/actions/runs/45014535413);
- [Project Health #45014535347](https://github.com/ninjun42215-gif/KindleWake/actions/runs/45014535347);
- [Workflow YAML Lint #45014535345](https://github.com/ninjun42215-gif/KindleWake/actions/runs/45014535345);
- [Version Sync #45014535355](https://github.com/ninjun42215-gif/KindleWake/actions/runs/45014535355).

It uses API 35 Google APIs x86_64 / Pixel 5 with default graphics, checks Godot activity resume, OCRs `KINDLEWAKE`, `NEW GAME`, `SETTINGS`, and rejects shader-link/uniform-limit errors. It also keeps routine CI builds candidate-only, sets workflow-level release permissions to read-only, scopes `contents: write` to the protected production publish job, and records the exact checked-out tag commit via `git rev-parse HEAD`. This is a workflow correction, not a game shader fix or physical-device certification. It has not been merged.

### Current main release workflow risks

- Main `.github/workflows/build-apk.yml` still uses AOSP ATD and forced `swiftshader_indirect`; its screenshot is not OCR-gated and its logcat guard does not catch the shader USER ERROR pattern demonstrated by PR #183.
- Main `.github/workflows/publish-android-release.yml` grants `contents: write` at workflow scope and sets `SOURCE_SHA: ${{ github.sha }}`, rather than using an explicit output captured from the checked-out tag commit. PR #164 corrects these.
- Production signing-secret presence and protected environment reviewer configuration remain unverified. No secret values were accessed.

### Safe Auto Merge policy risk

Main `.github/workflows/safe-auto-merge.yml` has `contents: write` and `pull-requests: write` and can directly squash-merge a non-draft, mergeable, exact-head PR after all discovered PR workflows pass and the base is current. The current gate does not require an explicit opt-in label or approved review decision. PR #165 adds a `behind_by == 0` freshness guard, but does not add manual approval. A review comment requests a separate explicit approval/opt-in gate. This QA run did not enable auto-merge or merge anything.

## 5. Branch divergence and other active PRs

Selected live comparisons:
- PR #81 regional trading: 3 ahead / 146 behind main; GitHub reports not mergeable.
- PR #78 headless CI: 70 ahead / 160 behind main; it targets another feature branch.
- PR #46 empire management: 261 ahead / 161 behind main; GitHub reports not mergeable.
- PR #22: 1 ahead / 198 behind main.
- PR #23: 6 ahead / 198 behind main; GitHub reports not mergeable.
- PR #179 garrison integrity: 3 ahead / 0 behind main; draft.
- PR #180 enemy heraldry: 8 ahead / 0 behind main; draft.
- PR #172 QA handoff before this update: 11 ahead / 0 behind main; draft.

Do not bulk-merge old branches. Reconcile reviewed changes selectively onto current main. PR #180's central asset provenance/credits reconciliation remains outstanding; PR #157 owns shared inventory files.

## 6. Source handoff and limitations

The latest verified main source-handoff remains [run #44446304164](https://github.com/ninjun42215-gif/KindleWake/actions/runs/44446304164), artifact [#14493885543](https://github.com/ninjun42215-gif/KindleWake/actions/runs/44446304164/artifacts/14493885543). Its prior independent verification covered 370 tracked files, archive CRC and individual tracked-file hashes. Main has not changed since that snapshot, so no newer source snapshot was generated this run.

No physical Android handset was tested. Touch, gameplay, save/load/migration on-device, orientation, pause/resume, memory, thermal behavior, frame pacing and vendor-GPU compatibility remain unverified.

## 7. Disposition and next actions

1. Human review of PR #164's alternate emulator, OCR/shader guard and least-privilege release workflow.
2. Retest current feature candidates on PR #164's emulator path; do not treat the AOSP ATD process-liveness result as visual success.
3. Add deterministic multi-month governor/economy balance simulation to PR #182.
4. Preserve PR #183's stacked dependency on PR #171; obtain final Android build and visual validation on the exact latest head after parent integration.
5. Reconcile asset provenance/credits for new visual atlases with PR #157.
6. Add an explicit approval/opt-in gate to Safe Auto Merge if automatic mainline merges are intended.
7. Verify production signing and environment reviewer configuration without exposing secrets.
8. Perform physical Android installation and gameplay/save QA before release.

**No PR was merged. Main remains `13f66ec19476c9af5ed2b5c81af95e4d8a026876`. No physical Android handset was tested.**
