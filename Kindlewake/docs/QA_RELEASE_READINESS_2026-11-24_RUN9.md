# QA and Android release-readiness handoff — Run 9

**Date:** 24 November 2026  
**Repository:** https://github.com/ninjun42215-gif/KindleWake  
**Project:** `Kindlewake/` · Godot 4.2.2 · Android APK  
**QA owner branch:** `qa/project-health-audit-doc-consistency-2026-11-21`  
**Main SHA:** `13f66ec19476c9af5ed2b5c81af95e4d8a026876`

## Executive status

**Not release-ready.** Main remains unchanged. Headless import, scene smoke and strict regression checks pass on the newest market-icon candidate, and the exact-head APK was independently downloaded and hash-verified. The current AOSP ATD / forced SwiftShader emulator attempt still exits during Godot startup with a black screenshot. The alternate API 35 Google APIs / default-graphics path last passed on QA PR #164's exact head, but has not yet been applied to the newest feature candidates. No physical Android handset was tested.

## 1. Live repository snapshot

- Main: `13f66ec19476c9af5ed2b5c81af95e4d8a026876` (commit dated 19 Nov 2026).
- Open PRs: 39; 37 drafts.
- Branches: 177 (100 on first page, 77 on second).
- Published GitHub Releases: 0.
- Main branch API reports `protected=false`; repository rulesets endpoint returned an empty list.
- Latest Safe Auto Merge run [#45340408761](https://github.com/ninjun42215-gif/KindleWake/actions/runs/45340408761) was skipped. No merge occurred.

Latest main-commit checks:
- [Project Health Audit #44446304110](https://github.com/ninjun42215-gif/KindleWake/actions/runs/44446304110) — success.
- [Workflow YAML Lint #44446304180](https://github.com/ninjun42215-gif/KindleWake/actions/runs/44446304180) — success.
- [Version Sync #44446304299](https://github.com/ninjun42215-gif/KindleWake/actions/runs/44446304299) — success.
- [Manual Source Handoff #44446304164](https://github.com/ninjun42215-gif/KindleWake/actions/runs/44446304164) — success.
- [Android Build #44446304169](https://github.com/ninjun42215-gif/KindleWake/actions/runs/44446304169) — failure at emulator runtime/liveness.

No newer main source commit or main Android build was found in the current Actions listing. The last verified source handoff artifact remains [#14493885543](https://github.com/ninjun42215-gif/KindleWake/actions/runs/44446304164/artifacts/14493885543); its earlier independent check covered 370 tracked files, ZIP integrity and per-file hashes.

## 2. PR #178 — regional trade-goods icon atlas

[PR #178](https://github.com/ninjun42215-gif/KindleWake/pull/178)  
Branch: `art/trade-goods-iconography-2026-11-24`  
Exact current head: `0cedeb2e17062146e4fc089f7ffdd4db65e6452d`  
Base: main `13f66ec19476c9af5ed2b5c81af95e4d8a026876`  
Comparison: 3 ahead / 0 behind; open, draft, mergeable.

Scope: original 384×128 SVG atlas with 12 64×64 trade-goods icons; stable-ID mapping; 44×44 display in regional exchange rows; merchant UI regression coverage. No prices, cargo rules, transactions, save schema, story, character data, permissions or workflows change.

### Exact-current-head CI

- [Project Health Audit #45339958987](https://github.com/ninjun42215-gif/KindleWake/actions/runs/45339958987) — success.
- [Workflow YAML Lint #45339958938](https://github.com/ninjun42215-gif/KindleWake/actions/runs/45339958938) — success.
- [Version Sync #45339959361](https://github.com/ninjun42215-gif/KindleWake/actions/runs/45339959361) — success.
- [Android Build #45339958956](https://github.com/ninjun42215-gif/KindleWake/actions/runs/45339958956) — failed at Android startup/process survival. Import, tests, APK export and upload completed.

Evidence from exact-head test logs:
- Godot 4.2.2 import: exit 0.
- Scene smoke: 20 scenes loaded, 0 failures.
- Core strict suite: 1,009 checks, 0 failures.
- Merchant UI: 40 assertions, 0 failures. This covers all twelve icon IDs returning a 64×64 region, the grain row displaying an icon, and buy/sell/close behavior.
- Campaign lifecycle, title/creator UI, Act V, campaign continuity, Chronicle dynasty, family-development and balance checks completed without reported failures.

### Exact-head APK verification

Downloaded the APK artifact from the exact current PR head, not the older code-tested commit:

- [Artifact #14895981497](https://github.com/ninjun42215-gif/KindleWake/actions/runs/45339958956/artifacts/14895981497)
- ZIP size: 65,323,953 bytes.
- ZIP SHA-256: `eb5d97c2dfd6b51d25f0674c2925108e8df83b612e5312ceb084868e08fc6a4e`.
- Extracted APK: 65,877,655 bytes.
- Extracted APK SHA-256: `0219c33bf09ffb3fe5ef157a0355b41f1c575f17b7e7092255ae3eac4c479fdf`.
- ZIP CRC/integrity: passed.
- Build summary: CI/test signature valid; ABIs `arm64-v8a`, `armeabi-v7a`, `x86_64`; no Android permissions requested.

Exact-head log artifact:
- [Artifact #14894928717](https://github.com/ninjun42215-gif/KindleWake/actions/runs/45339958956/artifacts/14894928717)
- ZIP size: 87,862 bytes.
- ZIP SHA-256: `ebc8ec355daf1154ad8daad11320df23f42775eb0a5797fb264c32d30868c0fc`.
- ZIP CRC/integrity: passed.

### Android failure diagnosis — exact current head

The exact-head screenshot `honor400-emulator.png` is black. The activity starts, the native `libgodot_android.so` loads, then Godot destroys the activity and logs:

`USER ERROR: Condition "!_start_success" is true.`  
`at: cleanup (main/main.cpp:3802)`

The process is then sent SIGKILL (9). No Java `FATAL EXCEPTION`, native fatal-signal stack trace, GDScript `SCRIPT ERROR` or parse error was present in this exact-head capture. This particular log does **not** include the GLES3 uniform-limit messages; do not state that those messages were observed on this exact run.

For comparison, the preceding code-tested head `ce7c500afe6089dad7f18e32db5b78d0db4fa6e0` [Build #45339445216](https://github.com/ninjun42215-gif/KindleWake/actions/runs/45339445216) did record:
- global shader-variable buffer exceeds 16,384 bytes;
- `SceneShaderGLES3` fragment uniforms exceed `GL_MAX_FRAGMENT_UNIFORM_VECTORS (261));
- shader link/bind failure followed by Godot force-quit.

The final head adds only the handoff document, so code is unchanged, but the differing logs mean the exact current startup failure remains incompletely diagnosed. Do not overstate a single proven root cause.

### QA review comment

Comment [#7129317932](https://github.com/ninjun42215-gif/KindleWake/pull/178) records the independent APK/hash verification, exact-head Android diagnosis and a coverage gap: the current test checks non-null 64×64 regions but not each expected atlas origin. Recommend assertions for every `AtlasTexture.region.position`, unknown-ID fallback (`null`) and, if practical, all twelve visible rows.

I confirmed that current main's `Kindlewake/data/asset_provenance.json` and `Kindlewake/assets/art/CREDITS.md` do not yet list `trade_goods_atlas.svg`. PR #157 owns both shared files, so reconcile the atlas into the central provenance and credits records after coordinating with that branch.

## 3. PR #177 — Merchant Council holding income

[PR #177](https://github.com/ninjun42215-gif/KindleWake/pull/177)  
Head: `e63f8c02caf4ea338c58d14841bfdb0848be179a`; 6 ahead / 0 behind; open, draft, mergeable.

The focused fix applies the documented rounded-up 20% Merchant Council bonus to total holding income after workshop and trade-post yields are added. Regression fixture: base 20 + workshop 2 + trade post 5 = 27; council bonus `ceil(27 × 0.2) = 6`; final income 33; existing upkeep remains 3.

Exact-head checks:
- [Project Health Audit #45321542779](https://github.com/ninjun42215-gif/KindleWake/actions/runs/45321542779) — success.
- [Workflow YAML Lint #45321542750](https://github.com/ninjun42215-gif/KindleWake/actions/runs/45321542750) — success.
- [Version Sync #45321542746](https://github.com/ninjun42215-gif/KindleWake/actions/runs/45321542746) — success.
- [Android Build #45321542738](https://github.com/ninjun42215-gif/KindleWake/actions/runs/45321542738) — failed at emulator process survival.

Build logs show 1,010 core checks / 0 failures, 20 scenes / 0 failures, and the Merchant Council regression passed. APK export/upload completed. The emulator uses the old AOSP ATD / forced SwiftShader path. QA comment [#7129318775](https://github.com/ninjun42215-gif/KindleWake/pull/177) records the diagnosis and recommends retesting on the alternate emulator workflow. No save-schema change was introduced.

## 4. Android workflow hardening candidate

[PR #164 — Android emulator and production release provenance](https://github.com/ninjun42215-gif/KindleWake/pull/164)  
Head: `03efa339e85df62763bada23c2f7f97d5158d514`; 20 ahead / 0 behind; open, draft, mergeable.

Last exact-head verification on 22 Nov:
- [Android Build #45014535413](https://github.com/ninjun42215-gif/KindleWake/actions/runs/45014535413) — success, including API 35 Google APIs x86_64 emulator install, foreground/resumed activity, title/menu OCR and explicit renderer-error guard.
- [Project Health #45014535347](https://github.com/ninjun42215-gif/KindleWake/actions/runs/45014535347) — success.
- [YAML Lint #45014535345](https://github.com/ninjun42215-gif/KindleWake/actions/runs/45014535345) — success.
- [Version Sync #45014535355](https://github.com/ninjun42215-gif/KindleWake/actions/runs/45014535355) — success.

The branch changes the CI emulator to Google APIs/default graphics, captures and OCR-checks the title/menu, and explicitly rejects renderer shader errors. It also separates routine candidate builds from production publishing, scopes `contents: write` to the protected release job, and records the exact checked-out tag commit. This is a workflow correction, not a game renderer fix. Human review is still required before integration.

## 5. Repository and release workflow risks

- Main branch is reported unprotected and rulesets are empty; required status-check enforcement is not configured. No repository settings were changed.
- Main `.github/workflows/build-apk.yml` still uses `target: aosp_atd` and `-gpu swiftshader_indirect`. This is the current failing CI runtime path.
- Main routine tag builds still contain a write-capable release-attachment job; PR #164 removes this routine release path.
- Main `publish-android-release.yml` grants `contents: write` at workflow scope and writes `github.sha` into the release manifest rather than the explicitly resolved checked-out tag commit. PR #164 scopes write permission to the publishing job and records `git rev-parse HEAD` after checkout.
- Production environment reviewer configuration and presence of required signing secrets/variables remain unverified. No secret values were accessed.
- GitHub Actions emits Node.js 20 deprecation warnings for pinned actions; schedule a tested dependency update rather than changing versions without CI evidence.
- PR #157 changes the central asset ledger and credits and is 34 ahead / 9 behind main. Coordinate shared-file reconciliation; do not overwrite it.
- Old integration branches remain highly divergent. PR #81 regional trading is 3 ahead / 146 behind; PR #78 headless CI is 70 ahead / 160 behind; PR #46 empire management is 261 ahead / 161 behind. Port reviewed work selectively to fresh main-based branches; do not bulk-merge.

## 6. Next release gates

1. Human review of PR #164's emulator and production publishing workflow changes.
2. Retest PR #178 and PR #177 on the alternate Google APIs/default-graphics emulator path after the workflow change is accepted.
3. Strengthen PR #178's exact atlas-cell-position and unknown-ID fallback assertions.
4. Reconcile the trade atlas into central provenance, asset manifest and credits after coordination with PR #157.
5. Re-test save/load and campaign migration candidates on the same alternate emulator path.
6. Install on a physical Android device and verify touch input, portrait/landscape behavior, save/load/Continue, pause/resume, memory, thermal behavior and frame pacing.
7. Verify production signing configuration and protected environment approvals before creating a version tag or release.

## 7. Safety and disposition

No merge to main, force-push, branch deletion, repository-setting change, secret access, production tag or release publication occurred. Main remains at `13f66ec19476c9af5ed2b5c81af95e4d8a026876`. No physical handset was tested. All APKs listed above are CI/test candidates, not production releases.


### Exact-head APK verification

- [APK artifact #14887991502](https://github.com/ninjun42215-gif/KindleWake/actions/runs/45321542738/artifacts/14887991502), produced by the exact PR #177 head `e63f8c02caf4ea338c58d14841bfdb0848be179a`.
- ZIP size: 65,297,907 bytes; SHA-256: `9dbc4e901c3937c68c6e070ed1866d56757db9d8be0defc7ee8272796f855b5d`; CRC passed.
- Extracted APK: 65,852,762 bytes; SHA-256: `dd82e67b1fb1dd404fddc8f15c92fce417282626d380838caba1612c2030ac81`.
- [Test-log artifact #14888441233](https://github.com/ninjun42215-gif/KindleWake/actions/runs/45321542738/artifacts/14888441233): ZIP SHA-256 `dab647bbd5b2eaa494c5a87abcb35e2d94bbf05985e7023a85e9665ebafd87fe`; CRC passed.
- Build summary reports a valid CI/test signature, `arm64-v8a`, `armeabi-v7a`, `x86_64`, and no requested Android permissions. The artifact is tied to the tested commit but is not release-verified because the workflow failed at emulator runtime.
