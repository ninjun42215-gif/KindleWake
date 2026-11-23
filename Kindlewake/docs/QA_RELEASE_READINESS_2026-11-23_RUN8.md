# KindleWake QA / release-readiness handoff — 2026-11-23 (Run 8)

## Repository checkpoint

- Repository: https://github.com/ninjun42215-gif/KindleWake
- Engine/project: Godot 4.2.2, GL Compatibility, Android APK.
- Current `main`: `13f66ec19476c9af5ed2b5c81af95e4d8a026876`.
- GitHub branch API reports `main` as `protected=false`; the rulesets collection is empty. No repository settings were changed.
- Open PRs: 37 (35 draft, 2 non-draft at this snapshot).
- Branches: 180 (100 on page 1, 80 on page 2).
- Published GitHub Releases: 0.
- No main commit or current-main Android build was created during this run. Latest known exact-main Android build remains [#44446304169](https://github.com/ninjun42215-gif/KindleWake/actions/runs/44446304169), failed at the Android emulator liveness stage. Main's Project Health Audit [#44446304110](https://github.com/ninjun42215-gif/KindleWake/actions/runs/44446304110), Workflow YAML Lint [#44446304180](https://github.com/ninjun42215-gif/KindleWake/actions/runs/44446304180), Version Sync [#44446304299](https://github.com/ninjun42215-gif/KindleWake/actions/runs/44446304299), and Source Handoff [#44446304164](https://github.com/ninjun42215-gif/KindleWake/actions/runs/44446304164) passed on the main SHA.

## QA PR #164 — alternate emulator and release workflow candidate

- [PR #164](https://github.com/ninjun42215-gif/KindleWake/pull/164)
- Branch: `qa/android-release-workflow-hardening-2026-11-18`
- Exact head: `03efa339e85df62763bada23c2f7f97d5158d514`.
- Comparison with main: 20 ahead / 0 behind.
- Draft, mergeable, unmerged.
- Exact-head Build Android APK [#45014535413](https://github.com/ninjun42215-gif/KindleWake/actions/runs/45014535413), Project Health Audit [#45014535347](https://github.com/ninjun42215-gif/KindleWake/actions/runs/45014535347), Workflow YAML Lint [#45014535345](https://github.com/ninjun42215-gif/KindleWake/actions/runs/45014535345), and Version Sync [#45014535355](https://github.com/ninjun42215-gif/KindleWake/actions/runs/45014535355) all passed.
- This workflow uses API 35 Google APIs x86_64 / Pixel 5 with default graphics selection, avoids the old display reconfiguration steps, verifies the foreground/resumed activity, captures a screenshot, runs OCR, and rejects shader-link, GLES uniform-limit, fatal, script and parse errors.
- The test screenshot/log archive is artifact [#14751421618](https://github.com/ninjun42215-gif/KindleWake/actions/runs/45014535413/artifacts/14751421618); the exact-head APK is [#14751425527](https://github.com/ninjun42215-gif/KindleWake/actions/runs/45014535413/artifacts/14751425527). The earlier handoff independently verified both archive hashes and the extracted APK SHA-256 `b54706a5786c34e12a9212eed208531224c4027bb568449505732c4dd5ae5641`.
- This proves a CI emulator route can launch the game on this exact candidate. It does not modify the game's shaders, certify all vendor GPUs, or replace physical-device testing.
- PR #164 also proposes candidate-only routine builds, job-scoped production `contents: write`, and exact checked-out tag SHA provenance. It remains draft for human workflow/security review.

## Reproduced Android renderer failure on current-main workflow

The main `.github/workflows/build-apk.yml` still uses API 35 `aosp_atd`, forced `-gpu swiftshader_indirect`, and changes emulator size/density/rotation before launch. Three distinct current-main-based feature candidates reproduce the same failure:

### PR #174 — equipment enhancement stat scaling

- [PR #174](https://github.com/ninjun42215-gif/KindleWake/pull/174)
- Exact head: `4c4400d8565e02d9c6cad23e580c85b7c4c1c263`; 8 ahead / 0 behind.
- Android Build [#45108705585](https://github.com/ninjun42215-gif/KindleWake/actions/runs/45108705585) passed import, 20-scene smoke, strict suite, gameplay suites, balance report and APK export; it failed at emulator process liveness.
- Strict core suite: **1,012 checks, 0 failures**, including three new enhancement checks. Scene smoke: 20 scenes, 0 failures. Campaign lifecycle, merchant UI, title/creator UI, Act V, continuity, Chronicle dynasty/family and balance checks completed successfully.
- Downloaded test-log artifact [#14788038713](https://github.com/ninjun42215-gif/KindleWake/actions/runs/45108705585/artifacts/14788038713): SHA-256 `68a67b2c7f79e46086e5548fba0b9fa028a31c3cd3d37ee8b80b9eeba604e2fe`; ZIP integrity passed. Screenshot is black. Logcat reports the global shader-variable buffer exceeds 16,384 bytes, repeated `SceneShaderGLES3` program-link failures because fragment uniforms exceed `GL_MAX_FRAGMENT_UNIFORM_VECTORS (261)`, shader bind failures, then Godot activity/process death (signal 9). No Java fatal exception or native fatal-signal stack trace was captured.
- APK artifact [#14788741644](https://github.com/ninjun42215-gif/KindleWake/actions/runs/45108705585/artifacts/14788741644) was independently downloaded. ZIP SHA-256 `2715bc85d0e8ee505d9e98ae8063ceb6ea59639213bcb1491f73e573073af310`, matching GitHub artifact metadata; ZIP integrity passed. Extracted APK size 65,852,762 bytes; SHA-256 `1efef419959705f41937da17d7dc2242295978337d5e82323f166598e00496e5`. CI/test signature valid, ABIs arm64-v8a / armeabi-v7a / x86_64, no Android permissions requested. The artifact is tied to this tested head but is not an end-to-end Android-verified release because emulator launch failed.
- Finding: current main's `CharacterSheet.total_stats()` reads legacy slot-only enhancement keys, while `PartyState.enhance_equipment()` writes `slot|item_id`. PR #174 fixes the valid-save calculation mismatch and adds regression coverage.
- QA follow-up comment posted: `armor_totals()` still reads the raw item-keyed level without the new 0..15 clamp; `CharacterSheet.from_dict()` copies the enhancement dictionary without normalization and `PartyState.from_dict()` delegates to it. A malformed save can therefore make armor/resistance derivation diverge from the clamped stat-bonus result. Recommended a shared clamp/normalizer and malformed-save regression. This is a robustness follow-up, not a failure of valid blacksmith-generated levels.

### PR #175 — cinematic title illustration

- [PR #175](https://github.com/ninjun42215-gif/KindleWake/pull/175)
- Exact head: `76c59c5318d7c056623b59ed2ef5322adfa58915`; 6 ahead / 0 behind.
- Build [#45124791240](https://github.com/ninjun42215-gif/KindleWake/actions/runs/45124791240): import, scene smoke, strict tests, balance and APK export passed; emulator launch failed.
- Downloaded test-log artifact [#14795202527](https://github.com/ninjun42215-gif/KindleWake/actions/runs/45124791240/artifacts/14795202527): SHA-256 `7de2c624ff3bdca04e6afb9821d9e6209c6dd04eb28ace0596c0e7ac7e864d5d`, matching GitHub metadata; ZIP integrity passed. Screenshot is black; logcat has the same 16,384-byte uniform-buffer warning, `SceneShaderGLES3` link failure above 261 fragment uniform vectors, shader bind failure and process death (signal 9).
- QA comment posted: failure is shared with #174/#176 and is not evidence the title illustration caused it. Re-run on the #164 emulator workflow and inspect a real rendered screenshot before visual approval.

### PR #176 — seven-continent atlas cartography

- [PR #176](https://github.com/ninjun42215-gif/KindleWake/pull/176)
- Exact head: `914abbc32dd8f43c9c2d61e181e86d7800bae0b3`; 10 ahead / 0 behind.
- Build [#45127323224](https://github.com/ninjun42215-gif/KindleWake/actions/runs/45127323224): Godot import passed, 20 scenes loaded, core suite 1,009 checks / 0 failures, atlas geometry/input-transparency smoke assertions passed, APK exported; emulator launch failed.
- Downloaded test-log artifact [#14795939116](https://github.com/ninjun42215-gif/KindleWake/actions/runs/45127323224/artifacts/14795939116): SHA-256 `fbb9fc99617d44eaa818bc8dde86944df57c6c8b85447ff05b24c82fedf2fad9`, matching GitHub metadata; ZIP integrity passed. Screenshot is entirely black. Logcat confirms the same uniform-buffer and fragment-uniform shader-link failures followed by process death (signal 9).
- QA comment posted: the new geometry smoke test is useful but does not replace rendered screenshot review at portrait and landscape sizes. Keep draft until the alternate emulator workflow runs and visual output is inspected.

The three logs demonstrate a repeated failure in the configured AOSP ATD / forced SwiftShader path, not three independent feature regressions. Do not claim every physical GPU is affected. PR #164's alternate Google APIs/default-graphics CI path passed on its own exact head.

## Other active QA/feature candidates

| PR | Exact head | Ahead / behind | Current review note |
|---|---|---:|---|
| #166 Chronicle dynasty save normalization | `fbbfbaf271136798bd3d9113c8145305188862c3` | 7 / 0 | Last dedicated dynasty suite reported 42 / 0; retest on alternate emulator path. |
| #168 Character appearance save guard | `e33a591ba5e08a9802499e9e5979d81ea990c0cc` | 7 / 0 | Last dedicated persistence suite reported 7 / 0; retest on alternate emulator path. |
| #170 Battle turn soft-lock recovery | `cc6e819ca2f24cf84715f63d0b67c815f331996b` | 6 / 0 | Last verified core suite 1,009 / 0 and campaign continuity 79 / 0; Android old-emulator stage failed. Asked for terminal victory/defeat coverage after lethal status on commanders/protagonist. |
| #172 QA handoff | `c51fb042d41b9a95d23e525b7fd9daf7c86a672d` | 5 / 0 | This run's report file is being added to this PR branch; exact-head checks must rerun after the new documentation commit. |
| #173 Rune icon atlas | `09c9080a5690dabdcb25642ebc65615cf1236735` | 6 / 0 | 400×240 SVG, 10×6 / 40px grid preserved; visual review at true size and central credits check remain. |
| #164 Android/release workflow hardening | `03efa339e85df62763bada23c2f7f97d5158d514` | 20 / 0 | Exact-head alternate emulator workflow green; draft for human review. |

## Branch divergence / integration risk

These comparisons are against current main:

| PR | Ahead / behind |
|---|---:|
| #81 regional trading | 3 / 146 |
| #78 headless CI | 70 / 160 |
| #46 empire management | 261 / 161 |
| #157 portrait identity | 34 / 9 |

Do not bulk-merge stale branches. Selectively port reviewed changes to fresh branches from current main and rerun the full suite. PR #167/#169 asset work and PR #157 portrait inventory touch shared visual/provenance files; coordinate ledger/credits updates instead of overwriting.

## Workflow and security audit

- Current main `.github/workflows/build-apk.yml` still has a version-tag-triggered `publish-tag-release` job with `contents: write` that attaches the routine APK. This can publish a CI/test-signed candidate as a GitHub Release.
- Current main `.github/workflows/publish-android-release.yml` grants `contents: write` at workflow scope and uses `github.sha` in the release manifest rather than recording the exact checked-out tag commit.
- PR #164 proposes candidate-only routine builds, narrower write permission at the production publish job, and `git rev-parse HEAD` provenance after immutable-tag checkout.
- Production signing-secret presence and required environment reviewers are not verified. No secret values were accessed.
- Safe Auto Merge recent runs include success/skip outcomes, but main SHA did not change and no merge was performed. Its workflow does not check out or execute PR code; it uses exact-head checks.
- GitHub Actions continues to emit Node.js 20 deprecation warnings for pinned actions. Update versions separately after compatibility validation.
- No published release exists.
- No repository settings were modified.

## Disposition and remaining release gates

- No main write, merge, force-push, branch deletion, repository-setting change, secret access, production tag or release publication.
- No physical Android handset was tested.
- Required physical-device checks: install/upgrade, touch and one-tap navigation, portrait/landscape behavior, save/load and migration, pause/resume, long-session memory/thermal behavior, frame pacing, and vendor-GPU compatibility.
- Do not reuse an APK for a different commit. The PR #174 APK above is verified against its exact tested head but failed its emulator launch stage; it is not a release candidate.
- Immediate priorities: review #164 workflow/security changes; rerun #166/#168/#170/#174/#175/#176 on the alternate emulator path; close PR #174's malformed-enhancement restore edge; reconcile visual asset provenance/credits; verify production signing configuration and protected environment reviewers.


## Handoff commit and exact-head check status

- The Run 8 handoff was initially added in commit `c7ac16d00adb6a89b9e20312eb1436037e4dde0e`.
- A follow-up documentation-only commit `f12b0f241b88d2cb7162579239941d51cdb0964d` recorded the first exact-head lint result.
- Workflow YAML Lint [#45159773622](https://github.com/ninjun42215-gif/KindleWake/actions/runs/45159773622) completed successfully on exact commit `f12b0f241b88d2cb7162579239941d51cdb0964d`, including YAML syntax validation, source-handoff/organizer safety tests, and read-only branch-hygiene smoke test.
- No Project Health Audit, Version Sync or Android Build run was registered for exact commit `f12b0f241b88d2cb7162579239941d51cdb0964d`. That commit changed documentation only; earlier PR #172 checks on `c51fb042...` do not certify it. No runtime/gameplay source changed.
- Subsequent edits to this status section are documentation-only. The authoritative latest branch head and ahead/behind count are the live values on [PR #172](https://github.com/ninjun42215-gif/KindleWake/pull/172). Keep the PR draft and unmerged pending human review.
