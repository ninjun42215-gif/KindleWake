# KindleWake QA and Android release-readiness handoff — Run 10

**Date:** 25 November 2026  
**Repository:** https://github.com/ninjun42215-gif/KindleWake  
**Project:** `Kindlewake/` · Godot 4.2.2 · GL Compatibility · Android  
**Exact main:** `13f66ec19476c9af5ed2b5c81af95e4d8a026876`  
**QA documentation branch:** `qa/project-health-audit-doc-consistency-2026-11-21`  
**Related PR:** [#172 — QA documentation and release-readiness handoff](https://github.com/ninjun42215-gif/KindleWake/pull/172)

## Executive status

**Not release-ready.** Main is unchanged at the exact SHA above. The current main Android workflow still fails at emulator process survival on its AOSP ATD / forced SwiftShader path. The alternate API 35 Google APIs / default-graphics path last passed on QA PR #164's exact head on 22 November; it has not yet been applied to the newest feature candidates.

This run independently downloaded and checked two exact-head APK artifacts from PRs #179 and #180. Their APK export and headless tests succeeded, but both full Android jobs failed at emulator process survival. No physical Android handset was tested. No merge, force-push, branch deletion, repository-setting change, secret access, production tag or release publication occurred.

## 1. Live repository snapshot

- Main branch SHA: `13f66ec19476c9af5ed2b5c81af95e4d8a026876`; commit authored/committed 19 November 2026.
- Branch API pagination: 100 entries on page 1 and 85 on page 2, **185 branches total**. The branch listing reports every sampled branch, including main, as unprotected.
- Open PRs: **42**; drafts: **40**; non-draft PRs: #22 and #23 (both old art-direction documentation PRs).
- Published GitHub Releases: **0**.
- `main` protection endpoint reports `protected=false`, required status checks disabled, and no rulesets were returned.
- Latest Safe Auto Merge runs on main (#45561401315, #45560806091 and earlier 25 Nov runs) were skipped. No merge occurred.
- Latest main Android build: [#44446304169](https://github.com/ninjun42215-gif/KindleWake/actions/runs/44446304169), exact main SHA above, failed at emulator launch on 19 November.
- Main health audit [#44446304110](https://github.com/ninjun42215-gif/KindleWake/actions/runs/44446304110), YAML lint [#44446304180](https://github.com/ninjun42215-gif/KindleWake/actions/runs/44446304180), version sync [#44446304299](https://github.com/ninjun42215-gif/KindleWake/actions/runs/44446304299), and source handoff [#44446304164](https://github.com/ninjun42215-gif/KindleWake/actions/runs/44446304164) passed on the 19 November main commit.
- Main combined commit status currently has no status entries (`total_count=0`); use the linked Actions runs for actual workflow outcomes.

The last source-handoff artifact is [#14493885543](https://github.com/ninjun42215-gif/KindleWake/actions/runs/44446304164/artifacts/14493885543), tied to this unchanged main SHA. Its prior verification covered 370 tracked files, archive integrity and individual file hashes; it was not re-downloaded in this run.

## 2. PR #179 — garrison and reserve integrity

[PR #179](https://github.com/ninjun42215-gif/KindleWake/pull/179)  
Branch: `fix/holding-garrison-reserve-integrity-2026-11-25`  
Exact head: `c7630c816ed090f7a16b2d4dc77c429cdb82c5d2`  
Base: main `13f66ec19476c9af5ed2b5c81af95e4d8a026876`  
Comparison: 3 ahead / 0 behind; open, draft, mergeable.

### Implementation and regression coverage

The implementation in `scripts/core/empire_development_system.gd` caps reserve-to-garrison transfers at the existing 999-soldier limit, preserves troops that do not fit, rejects unknown troop IDs and non-positive amounts, validates nested reserve/garrison containers/counts, and avoids resource/state mutation on rejected recruitment/assignment operations.

The new `tests/test_empire_development_integrity.gd` is registered in the strict build test list. Exact tested head `c7630c816ed090f7a16b2d4dc77c429cdb82c5d2`:
- [Project Health Audit #45541594539](https://github.com/ninjun42215-gif/KindleWake/actions/runs/45541594539) — success.
- [Workflow YAML Lint #45541594495](https://github.com/ninjun42215-gif/KindleWake/actions/runs/45541594495) — success.
- [Version Sync #45541594572](https://github.com/ninjun42215-gif/KindleWake/actions/runs/45541594572) — success.
- [Android Build #45541594538](https://github.com/ninjun42215-gif/KindleWake/actions/runs/45541594538) — import, strict tests, APK export and upload passed; emulator process-survival step failed.

Downloaded exact-head log artifact [#14989377508](https://github.com/ninjun42215-gif/KindleWake/actions/runs/45541594538/artifacts/14989377508):
- Artifact ZIP SHA-256: `3f362411540384c54c79c550d24b564b01e65f6ee308cb6872c579742af195a7`.
- ZIP integrity: passed.
- Main strict suite: 1,009 checks, 0 failures.
- Scene smoke: 20 scenes, 0 failures.
- New empire development integrity suite: **12 checks, 0 failures**.
- Campaign lifecycle, merchant UI, title/creator UI, Act V, campaign continuity, Chronicle dynasty, Chronicle family and balance report completed without reported failures.
- Godot 4.2.2 import exited 0; no script or parse errors were reported.

### APK from the exact tested head

[APK artifact #14990185161](https://github.com/ninjun42215-gif/KindleWake/actions/runs/45541594538/artifacts/14990185161)
- Artifact ZIP: 65,298,110 bytes; SHA-256 `0dc615e926e3c5d9bf465324e9ac935cc5f9913f51f9f1199221e30e3957cce0`.
- Downloaded ZIP CRC/integrity: passed.
- Extracted APK: 65,852,762 bytes; SHA-256 `de921472f64507fffe716094d76b043321fd546bc896ccd552cc639c0e3fad1f`.
- Build summary reports a valid CI/test signature, ABIs `arm64-v8a`, `armeabi-v7a`, `x86_64`, and no Android permissions requested.

### Additional QA review

I posted comment [#7159984750](https://github.com/ninjun42215-gif/KindleWake/pull/179) requesting one numeric edge-case hardening: `_read_nonnegative_count()` converts integer values through float before casting back, which can lose precision for large 64-bit counts; non-finite floats such as INF should also be explicitly rejected before conversion. Add tests for non-finite and out-of-range values. This is a malformed-save hardening request; the 12 current checks passed and do not cover those edge cases.

### Emulator diagnostics

The downloaded exact-head logcat contains:
- global shader-variable buffer exceeds 16,384-byte uniform-buffer limit;
- `SceneShaderGLES3: Program linking failed`;
- fragment shader uniforms exceed `GL_MAX_FRAGMENT_UNIFORM_VECTORS (261)`;
- shader compilation/binding failure;
- Godot activity destruction and Android process death.

No Java `FATAL EXCEPTION`, native fatal-signal stack trace, GDScript script error or parse error was found. The shader errors are strongly correlated with the failed startup but this capture does not prove the sole causal mechanism.

## 3. PR #180 — enemy roster heraldry

[PR #180](https://github.com/ninjun42215-gif/KindleWake/pull/180)  
Branch: `art/enemy-roster-heraldry-2026-11-25`  
Exact head: `0e1e214bd5ac745049e506418b5f06745f10be93`  
Base: main `13f66ec19476c9af5ed2b5c81af95e4d8a026876`  
Comparison: 8 ahead / 0 behind; open, draft, mergeable.

The SVG change adds twelve small heraldic marks to existing roster atlas cells without changing the 1024×960 atlas, 8×6 grid, 128×160 cell size, stable character IDs, combat rules or resource loading. I checked the main `ROSTER_CHARACTER_IDS` order; the documented zero-based indices 4–6, 31–34 and 43–47 correspond to the listed IDs.

Exact-head checks:
- [Project Health Audit #45560999164](https://github.com/ninjun42215-gif/KindleWake/actions/runs/45560999164) — success.
- [Workflow YAML Lint #45560999289](https://github.com/ninjun42215-gif/KindleWake/actions/runs/45560999289) — success.
- [Version Sync #45560999150](https://github.com/ninjun42215-gif/KindleWake/actions/runs/45560999150) — success.
- [Android Build #45560999204](https://github.com/ninjun42215-gif/KindleWake/actions/runs/45560999204) — import, headless tests, APK export and upload passed; emulator process-survival failed.

Downloaded exact-head logs artifact [#14997119643](https://github.com/ninjun42215-gif/KindleWake/actions/runs/45560999204/artifacts/14997119643):
- ZIP SHA-256: `81de5055e7b67e63c5d8d90780eb2b9c6b94c0cec51c470ae2a07650532cb5df`.
- ZIP integrity: passed.
- Core suite: 1,009 checks, 0 failures.
- Scene smoke: 20 scenes, 0 failures.
- Merchant UI: 40 assertions, 0 failures.
- Godot 4.2.2 import: exit 0; no script/parse errors in build summary.

Exact-head APK [artifact #14997029384](https://github.com/ninjun42215-gif/KindleWake/actions/runs/45560999204/artifacts/14997029384):
- ZIP: 65,312,018 bytes; SHA-256 `d707091dbe27362efaa533f01a5e8db82813793c029b009271f557c698496072`.
- Downloaded ZIP CRC/integrity: passed.
- Extracted APK: 65,865,050 bytes; SHA-256 `8ff743c6693665d6226c7413f7b4f6a66009491b4bd05c2c35675a88de049f13`.
- Build summary reports a valid CI/test signature, ABIs arm64/armeabi/x86_64 and no Android permissions requested.

The logcat records the same SwiftShader uniform-buffer and GLES3 fragment-uniform link failures, then Godot activity destruction and process death. No Java fatal exception, native fatal-signal stack trace, GDScript error or parse error was found. Screenshot is black.

QA comment [#7159985614](https://github.com/ninjun42215-gif/KindleWake/pull/180) requests tests for all 12 stable ID-to-cell mappings and coordination of the central asset provenance/credits entry with portrait work PR #157. The sidecar provenance file is useful interim evidence but does not replace the central ledger and credits table.

## 4. PR #181 — title crest divider (stacked PR)

[PR #181](https://github.com/ninjun42215-gif/KindleWake/pull/181)  
Branch: `art/title-codex-crest-divider-2026-11-25`  
Exact head: `a3bdf678a55253783445f1e4f3fe69715b197cbd`  
Base: PR #175 branch head `76c59c5318d7c056623b59ed2ef5322adfa58915`  
Comparison to its parent: 4 ahead / 0 behind.

Only [Workflow YAML Lint #45562677985](https://github.com/ninjun42215-gif/KindleWake/actions/runs/45562677985) is present on this exact head. This branch is stacked on #175, not targeted at main; the other CI workflows are filtered to PRs targeting main. Therefore there is **no exact-head Godot import, scene/UI, project-health, version-sync or Android result** for #181 yet. Do not treat the YAML result as full validation.

QA comment [#7159986553](https://github.com/ninjun42215-gif/KindleWake/pull/181) asks for full exact-head checks once the parent is integrated/rebased, and central asset-ledger/credits reconciliation for the runtime title divider.

## 5. Alternate Android CI path

QA PR [#164 — Android emulator and release workflow hardening](https://github.com/ninjun42215-gif/KindleWake/pull/164) remains open/draft, head `03efa339e85df62763bada23c2f7f97d5158d514`, 20 ahead / 0 behind main.

Its exact-head [Android Build #45014535413](https://github.com/ninjun42215-gif/KindleWake/actions/runs/45014535413) passed on 22 November, with Project Health #45014535347, YAML Lint #45014535345 and Version Sync #45014535355 also passing. It used API 35 Google APIs x86_64 with default graphics selection, kept the app activity foreground/resumed, captured a title screenshot and found no shader-link errors. This remains a successful **CI emulator** path only; it is not a physical-device test or a fix to the game's GLES3 renderer.

## 6. Workflow, permissions and release audit

Current main `.github/workflows/build-apk.yml` still:
- uses Android emulator target `aosp_atd` and forced `-gpu swiftshader_indirect`;
- has a tag-triggered `publish-tag-release` job with `contents: write` that attaches the routine build APK to a GitHub Release.

Current main `.github/workflows/publish-android-release.yml` still:
- declares `contents: write` at workflow scope instead of only on the publishing job;
- records `SOURCE_SHA: ${{ github.sha }}` rather than explicitly recording the exact checked-out immutable tag commit.

PR #164 proposes candidate-only routine builds, narrower production write permissions and exact checked-out tag provenance. It remains unmerged. Production signing-secret presence and environment reviewer configuration could not be verified; no secret values were accessed.

GitHub Actions logs still show Node.js 20 deprecation warnings for pinned actions. Main's repository settings remain unchanged; branch protection and required-check enforcement are not enabled.

## 7. Other branch coordination

- PR #179's core engineering changes are isolated to empire development, a new dedicated test, build test registration and handoff docs; no merge was performed.
- PR #180 changes the shared roster atlas. PR #157 owns portrait/asset inventory work; coordinate the central ledger/credits update rather than overwriting that work.
- PR #181 is stacked on title landscape PR #175; run full checks after parent integration.
- PR #81 regional trading and PR #78 headless CI remain old/divergent; PR #46 empire management is also a legacy branch. Reconcile reviewed changes selectively onto current main rather than bulk-merging stale branches.
- Main asset credits currently list `units/character_atlas.svg`, but the new roster heraldry sidecar describes `units/character_roster_atlas.svg`; central inventory reconciliation remains open.

## Release disposition and next actions

1. Human review of PR #164's alternate emulator and production-release workflow changes.
2. Retest PR #179 and #180 on the alternate emulator path after review; keep their current CI APKs as non-release candidates.
3. Harden PR #179 numeric validation for non-finite and oversized save values.
4. Add exact 12-ID-to-cell regression coverage and central provenance/credits updates for PR #180.
5. Retest stacked PR #181 after its parent integration/rebase.
6. Verify production signing configuration and environment reviewers without exposing secrets.
7. Perform physical Android installation and test touch, save/load/migration, orientation, pause/resume, memory, thermal behavior and frame pacing on a real handset.

**No physical Android device was tested. No PR was merged. Main remains `13f66ec19476c9af5ed2b5c81af95e4d8a026876`.**
