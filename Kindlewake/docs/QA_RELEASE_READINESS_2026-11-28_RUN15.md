# QA and Android Release Readiness — Run 15

**Date:** 2026-11-28  
**Repository:** https://github.com/ninjun42215-gif/KindleWake  
**Project:** `Kindlewake/` · Godot 4.2.2 · GL Compatibility · Android  
**Observed main:** `13f66ec19476c9af5ed2b5c81af95e4d8a026876`  
**QA handoff PR:** [#172](https://github.com/ninjun42215-gif/KindleWake/pull/172)

## Executive disposition

**Not production-release-ready.** Main is unchanged. This run independently validated the new nine-interior data pass, downloaded and checked three exact-head APK artifacts, inspected the latest emulator screenshots/logcat, and confirmed that the current mainline Android workflow can report success while the UI is visibly blank. The earlier numeric-save hardening requests in PRs #179 and #184 have now been implemented with explicit boundary tests. A small QA-only child PR (#187) fixes three leaked controls in the UI-audio scene smoke test.

No merge, force-push, branch deletion, repository-setting change, secret access, production tag or release publication occurred. No physical Android handset was tested.

## 1. Live repository snapshot

- Default branch: `main`, exact SHA `13f66ec19476c9af5ed2b5c81af95e4d8a026876`; latest commit dated 2026-11-19 02:42:49Z.
- Branch API pagination: 100 entries on page 1 and 91 on page 2 — **191 branches**.
- Open PR search: **48 open PRs**, **46 drafts** (including QA follow-up PR #187 created in this run). The two non-draft PRs are #22 and #23.
- Published GitHub Releases: **0**.
- Main branch metadata reports `protected=false`; the repository rulesets endpoint returns `[]`. The branch-protection detail endpoint is not accessible to this integration (HTTP 403); no repository settings were changed.
- Latest Safe Auto Merge run [#46117110829](https://github.com/ninjun42215-gif/KindleWake/actions/runs/46117110829) completed successfully, but its exact-PR workflow verification and merge steps were skipped. Main remains at the same SHA; **no merge occurred**.
- The latest main-branch Actions listing contains Safe Auto Merge runs only. No newer main Android build, Project Health, Version Sync or source-handoff run was found. The last recorded main Android build remains [#44446304169](https://github.com/ninjun42215-gif/KindleWake/actions/runs/44446304169), which failed on the old emulator path.
- The last verified main source snapshot remains [manual handoff #44446304164](https://github.com/ninjun42215-gif/KindleWake/actions/runs/44446304164), artifact [#14493885543](https://github.com/ninjun42215-gif/KindleWake/actions/runs/44446304164/artifacts/14493885543), previously verified for 370 tracked files and per-file hashes. Main has not changed since that snapshot.

## 2. PR #186 — nine regional interiors

[PR #186](https://github.com/ninjun42215-gif/KindleWake/pull/186)  
Branch: `art/regional-interior-room-dressing-2026-11-28`  
Exact latest head: `23fa13eb6b87905f558b78d18246167eb54f62d2`  
Base: main `13f66ec19476c9af5ed2b5c81af95e4d8a026876`  
Comparison: **3 ahead / 0 behind**, draft, mergeable.

### Independent data validation

I fetched the base and exact PR-head `locations.json`, and reproduced the current `LocalMap` validation rules using its allowed/blocked glyph sets and connectivity logic.

- 58 maps in base and head.
- **0 validation errors** across all 58 head maps.
- All nine edited maps remain 12×8.
- Every edited map preserves its entry, door dictionary and NPC/service/story spot dictionary.
- Only the nine maps' row strings changed.
- Entries remain walkable; doors are defined/reachable; destination maps and spawn tiles are valid; all spots retain a reachable interaction neighbour.

This independently confirms the data-level preservation claim. No story, NPC, quest, service, destination or save-schema data was changed.

### Android visual false-positive — confirmed on exact head

[Build Android APK #46116868790](https://github.com/ninjun42215-gif/KindleWake/actions/runs/46116868790) concluded **success** on exact head `23fa13...`.

Headless/build evidence from its uploaded logs:
- Godot 4.2.2 import exit 0.
- 20/20 scenes loaded.
- Core suite: **1,009 checks / 0 failures**.
- Campaign lifecycle, merchant UI, title/creator UI, Act V, continuity (70), Chronicle dynasty (39), Chronicle family (19), balance report and APK export passed.
- Emulator install/start step and process-liveness check passed.

However, I downloaded and opened test-log artifact [#15252047912](https://github.com/ninjun42215-gif/KindleWake/actions/runs/46116868790/artifacts/15252047912). The screenshot `honor400-emulator.png` shows only empty menu panels; no title or menu labels are visible. Logcat contains:
- global shader-variable buffer warning above the emulator's 16,384-byte limit;
- four `SceneShaderGLES3` program-link failures;
- fragment uniforms exceeding `GL_MAX_FRAGMENT_UNIFORM_VECTORS (261)`;
- shader compile/bind failure.

The Godot activity remained top-resumed, so process liveness passed while rendering was unusable. No Java fatal exception, native fatal signal, GDScript error or parse error was captured. The filename `honor400-emulator.png` is an emulator capture, not a physical HONOR handset result.

This is a **current-main workflow false-positive**, not a regression attributed to this data-only PR. QA comment [#7238222616](https://github.com/ninjun42215-gif/KindleWake/pull/186#issuecomment-7238222616) records the evidence. Keep the PR draft; the black/blank screenshot is not visual approval. Retest with PR #164's OCR and renderer-error gates, then perform a phone-scale interior screenshot and touch/navigation walkthrough.

### Exact-head APK verification

Candidate artifact [#15251748869](https://github.com/ninjun42215-gif/KindleWake/actions/runs/46116868790/artifacts/15251748869):
- Artifact ZIP: 65,297,947 bytes; SHA-256 `a0d22077cc1cc522f7c2b1a4f3892de034a724dd4844d8f46a19ba757f50ac59` (matches GitHub artifact metadata).
- Extracted APK: 65,852,762 bytes; SHA-256 `b8bbf2c2105891ff00a2baee264f1ebc3cc988adcb55e0b9ecd34b3b6eb6dad7`.
- APK ZIP integrity: passed.
- Build summary reports valid CI/test signature, ABIs arm64-v8a / armeabi-v7a / x86_64, and no requested Android permissions.

The APK is tied to the exact tested head, but the successful workflow does **not** certify visual correctness or production readiness.

## 3. PR #179 — garrison/reserve numeric hardening

[PR #179](https://github.com/ninjun42215-gif/KindleWake/pull/179)  
Exact head: `b7e1cb61bd7cc5c0e19f67d76e318b3c5d74973f`  
Base main; **4 ahead / 0 behind**, draft, mergeable.

The previously identified numeric-conversion gap is addressed. `_read_nonnegative_count()` now preserves integer variants without a float round-trip and rejects negative, fractional, NaN, positive/negative infinity and out-of-range floating values before conversion. Regression suite: **22 checks / 0 failures**, including preservation of the maximum signed 64-bit integer.

Exact-head checks:
- [Project Health #46103663027](https://github.com/ninjun42215-gif/KindleWake/actions/runs/46103663027) — passed.
- [Workflow YAML Lint #46103663011](https://github.com/ninjun42215-gif/KindleWake/actions/runs/46103663011) — passed.
- [Version Sync #46103663003](https://github.com/ninjun42215-gif/KindleWake/actions/runs/46103663003) — passed.
- [Android Build #46103663059](https://github.com/ninjun42215-gif/KindleWake/actions/runs/46103663059) — import, headless tests and APK export passed; emulator step failed.

Build logs report import exit 0, 20 scenes, core **1,009 / 0**, campaign/UI/Act V/continuity/dynasty/family suites, and empire development **22 / 0**. The emulator screenshot is fully black; logcat reproduces the SwiftShader uniform-buffer and GLES3 shader-link errors. The job failed at the Android activity/process check; no Java fatal exception, native fatal signal, GDScript error or parse error was captured.

Exact-head APK artifact [#15246039931](https://github.com/ninjun42215-gif/KindleWake/actions/runs/46103663059/artifacts/15246039931):
- ZIP SHA-256 `4319c0149a1d464be47a777a84af3bcd10b44bf448da8dc9b69da6ae9c04ee95`, matching GitHub metadata.
- Extracted APK: 65,852,762 bytes; SHA-256 `3764219deb608cc507b45725996bfef369f5bae33e5dacbdfbd06cc3e67f4213`.
- ZIP integrity passed; build summary reports valid CI/test signature, three ABIs and no requested permissions.

## 4. PR #184 — companion quest save normalization

[PR #184](https://github.com/ninjun42215-gif/KindleWake/pull/184)  
Exact head: `fab926e41b0f7476894478de5e4de27eabbeb94e`  
Base: PR #179 head `b7e1cb61bd7cc5c0e19f67d76e318b3c5d74973f`; **11 ahead / 0 behind parent**, draft, mergeable.

The previous non-finite/oversized-progress concern is now addressed:
- NaN, +INF and -INF are rejected safely.
- Huge finite progress is clamped while still a float, before integer conversion.
- Runtime resolution rejects non-finite/out-of-range progress without mutating quest state.
- Companion quest normalization suite: **24 checks / 0 failures**.
- Empire development integrity suite: **22 / 0**.
- Core suite: **1,009 / 0**.

Exact-head checks:
- [Project Health #46103982665](https://github.com/ninjun42215-gif/KindleWake/actions/runs/46103982665) — passed.
- [Workflow YAML Lint #46103982784](https://github.com/ninjun42215-gif/KindleWake/actions/runs/46103982784) — passed.
- [Version Sync #46103982687](https://github.com/ninjun42215-gif/KindleWake/actions/runs/46103982687) — passed.
- [Android Build #46103982669](https://github.com/ninjun42215-gif/KindleWake/actions/runs/46103982669) — import, tests and APK export passed; emulator failed.

The screenshot is fully black and logcat reproduces the same shader-limit/link failures; no Java/native/GDScript fatal trace was captured.

Exact-head APK artifact [#15246319768](https://github.com/ninjun42215-gif/KindleWake/actions/runs/46103982669/artifacts/15246319768):
- ZIP SHA-256 `0cf909d431536466f224c17239076ac091e7f9d1c41446efdcb9a47afd79870d`, matching GitHub metadata.
- Extracted APK: 65,852,762 bytes; SHA-256 `a4d7d3555bc99236eeef7710d96dbc6b2f9074b5b4f6bb765cebf9f6783a344e`.
- ZIP integrity passed; build summary reports valid CI/test signature, three ABIs and no requested permissions.

Keep #184 stacked on #179; do not integrate it independently.

## 5. PR #185 — UI audio cues and test-resource leak

[PR #185](https://github.com/ninjun42215-gif/KindleWake)  
Exact head: `88603d2a2ea6e936035b61474e1659ad79e6d34c`; base main; **3 ahead / 0 behind**, draft.

Source inspection confirms `scene_smoke_test.gd` creates three temporary controls (two Buttons and one CheckButton) for semantic sound mapping but only frees the KW test instance. The prior exact-head log artifact [#15188987014](https://github.com/ninjun42215-gif/KindleWake/actions/runs/45952128835/artifacts/15188987014) reports 3 leaked CanvasItem RIDs, 9 DummyTexture RIDs, 6 shaped-text RIDs, 1 font RID and ObjectDB instances at exit. The three unfreed controls are a direct test-harness cleanup gap.

### QA-only follow-up PR #187

[PR #187 — release temporary controls in UI audio scene smoke test](https://github.com/ninjun42215-gif/KindleWake/pull/187)

- QA branch: `qa/ui-audio-smoke-rid-cleanup-2026-11-28`.
- Exact head: `a717f39fc6c3beb06364265cfab238524d47b8e5`.
- Base: PR #185 branch at `88603d2a2ea6e936035b61474e1659ad79e6d34c`.
- One commit ahead / 0 behind; one file changed, three cleanup lines added.
- The fix frees the three temporary controls before freeing the KW test instance; no runtime audio, scenes, assets, save data or gameplay behavior changes.
- [Workflow YAML Lint #46137431999](https://github.com/ninjun42215-gif/KindleWake/actions/runs/46137431999) — passed.
- No Godot/headless or Android check was triggered for the child PR at the last poll because it targets the feature branch, not main. Exact-head runtime verification remains pending; PR #187 is draft and must remain stacked on #185.

QA comment [#7238223276](https://github.com/ninjun42215-gif/KindleWake/pull/185#issuecomment-7238223276) links the follow-up. The audio assets are still absent from the central `asset_provenance.json` / `CREDITS.md`; the current ledger is dated 2026-11-19 and has no UI-audio entry. Add the project-authored audio entry before release. Audio playback, mute preference and rapid-tap behavior remain untested on a physical phone.

## 6. PR #164 — alternate Android and release workflow

[PR #164](https://github.com/ninjun42215-gif/KindleWake/pull/164)  
Exact head: `f6a4fb0b9ce3b653f96d146aef9022bcca558fb2`; base main; **22 ahead / 0 behind**, draft, mergeable.

The four latest recorded exact-head checks on this head passed:
- [Android Build #45810983519](https://github.com/ninjun42215-gif/KindleWake/actions/runs/45810983519) — passed API 35 Google APIs x86_64 emulator install/launch, Godot foreground/resumed state, title/menu OCR and renderer/fatal log guards.
- [Project Health #45810983525](https://github.com/ninjun42215-gif/KindleWake/actions/runs/45810983525) — passed.
- [Workflow YAML Lint #45810983616](https://github.com/ninjun42215-gif/KindleWake/actions/runs/45810983616) — passed.
- [Version Sync #45810983499](https://github.com/ninjun42215-gif/KindleWake/actions/runs/45810983499) — passed.

The OCR-visible title/menu and absence of shader-link errors make this the only demonstrated visual Android CI path. This is a workflow correction, not a game GLES3 renderer fix and not physical-device verification.

Source inspection confirms the PR:
- removes the routine tag-triggered release-attachment job;
- uses workflow-level `contents: read` for routine build;
- uses Google APIs emulator/default graphics, explicit OCR for KINDLEWAKE / NEW GAME / SETTINGS, and fail-fast fatal/renderer guards;
- narrows production publishing to workflow-level read plus job-level write;
- records `git rev-parse HEAD` after checking out the requested immutable tag;
- scopes repository-organizer and safe-branch-integration writes to their required jobs.

QA comment [#7238222976](https://github.com/ninjun42215-gif/KindleWake/pull/164#issuecomment-7238222976) records the new #186 false-positive reproduction. Keep #164 for human workflow/security review; no merge is authorized by this QA run.

## 7. Mainline workflow/security audit

Current main `.github/workflows/build-apk.yml` still:
- uses `aosp_atd` and forced `-gpu swiftshader_indirect`;
- has no OCR/title/menu visibility gate;
- contains the swallowed-failure shell pattern `grep ... && { ...; exit 1; } || true`;
- includes a tag-triggered `publish-tag-release` job with `contents: write`.

Current main `publish-android-release.yml` grants workflow-wide `contents: write` and sets `SOURCE_SHA: ${{ github.sha }}`, rather than recording the exact commit checked out from the requested tag. The rejected-confirmation job inherits the workflow-wide write permission.

PR #164 corrects these source-level risks. Production signing-secret presence and environment reviewer rules remain unverified; no secret values were accessed. No published releases exist.

The current provenance ledger `Kindlewake/data/asset_provenance.json` is dated 2026-11-19. It documents the existing local architecture atlas used by PR #186, but it does not include the four new UI audio files from PR #185.

## 8. Branch divergence and integration order

Selected live comparisons:
- #164: 22 ahead / 0 behind main.
- #172: 18 ahead / 0 behind main.
- #179: 4 ahead / 0 behind main.
- #184: 11 ahead / 0 behind parent #179.
- #185: 3 ahead / 0 behind main.
- #186: 3 ahead / 0 behind main.
- #187: 1 ahead / 0 behind parent #185.
- #81 regional trading: **39 ahead / 160 behind main** (diverged).
- #78 headless CI: 70 ahead / 160 behind main (diverged).
- #46 empire management: 261 ahead / 161 behind main (diverged).

Do not bulk-merge old divergent branches. Preserve the #179 → #184 and #185 → #187 dependencies. PR #183 remains stacked on #171.

## Remaining release gates

1. Human review and integration of PR #164's emulator and least-privilege release-workflow changes.
2. Retest PR #186 on the OCR/renderer-error path and inspect the nine interiors at phone scale; complete touch/navigation walkthrough.
3. Keep the 22 garrison numeric-boundary and 24 companion-quest normalization assertions in their exact-head suites.
4. Run PR #187's headless scene smoke and confirm the three CanvasItem RID leaks disappear.
5. Add UI-audio provenance/credits entry and test audio/mute/rapid taps on a physical device.
6. Reconcile all new visual assets with the central provenance ledger.
7. Physical Android testing: touch, save/load, orientation, pause/resume, audio, memory, thermal behavior and frame pacing.
8. Verify production signing and protected release approvals before publishing.

**No merge, force-push, branch deletion, repository-setting change, secret access or release publication occurred. No physical Android handset was tested.**
