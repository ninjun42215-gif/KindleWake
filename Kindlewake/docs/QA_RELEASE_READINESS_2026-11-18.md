# KindleWake QA and Android release-readiness report — 18 November 2026

## Authoritative source checkpoint

- Repository: https://github.com/ninjun42215-gif/KindleWake
- Canonical project: `Kindlewake/`
- Main SHA inspected: `751b2f3f6b1104aa30e107659094ae2e221dbe3d` (commit dated 2026-11-18 02:46:06 UTC)
- Godot: 4.2.2 · GL Compatibility · Android · project/export version `0.12.0 / 1200`
- Save schema: `4` · level cap: `250` · offline-first
- No repository settings, secrets, tags, releases, or mainline code were changed in this QA run.

## Mainline build and automated verification

The exact-main Android workflow was [Build Android APK run 44225653213](https://github.com/ninjun42215-gif/KindleWake/actions/runs/44225653213), for the SHA above. **The overall workflow failed at its Android emulator smoke stage**; do not call this a fully passing Android build or a release-ready result.

The import, headless tests, balance report, APK export and signing steps before the emulator stage completed successfully:

- Godot 4.2.2 import: exit 0, no script errors.
- Scene smoke: 20 loaded, 0 failures.
- Strict core suite: 1,009 checks, 0 failures.
- Campaign save/Continue lifecycle: 0 failures.
- Merchant UI: 0 failures.
- Title/creator UI: 0 failures.
- Act V: 0 failures.
- Campaign continuity: 70 checks, 0 failures.
- Chronicle dynasty: 39 checks, 0 failures.
- Chronicle family development: 19 checks, 0 failures.
- Balance report: exit 0.
- APK: 65,848,438 bytes; SHA-256 `046d7cd0006b4cdfdb1c6937e586b392879444a62a12d9ae01e01bd18b069c2f`.
- Build log reports valid APK signature (certificate fingerprint prefix `c04a7792715ad8f5`), native libraries for `arm64-v8a`, `armeabi-v7a`, and `x86_64`, and no Android permissions requested.

Exact run artifacts:
- [APK artifact 14393186073](https://github.com/ninjun42215-gif/KindleWake/actions/runs/44225653213/artifacts/14393186073) — downloaded and SHA-256 checked against the value above.
- [Test/log artifact 14392193337](https://github.com/ninjun42215-gif/KindleWake/actions/runs/44225653213/artifacts/14392193337).

Other checks on the same main SHA:
- [Project Health Audit 44225653218](https://github.com/ninjun42215-gif/KindleWake/actions/runs/44225653218) — passed; report has 0 errors and 0 warnings.
- [Workflow YAML Lint 44225653214](https://github.com/ninjun42215-gif/KindleWake/actions/runs/44225653214) — passed.
- [Version Sync 44225653230](https://github.com/ninjun42215-gif/KindleWake/actions/runs/44225653230) — passed.
- [Manual Source Handoff 44225653270](https://github.com/ninjun42215-gif/KindleWake/actions/runs/44225653270) — passed.

### Android emulator failure diagnosis

The main build's AOSP ATD / `swiftshader_indirect` run installed and launched the APK, but the Godot activity disappeared about two seconds after startup. The captured emulator screenshot is black, and the 30-second process check failed. The log includes the Compatibility renderer warning about the default global shader-variable buffer (65,536 vs the emulator-reported 16,384) and repeated `SceneShaderGLES3` link messages reporting 261 fragment uniforms. This is **not enough evidence to attribute the activity exit to a game-code crash**: no GDScript parse/runtime error or Android fatal exception was recorded.

Godot maintainers have documented the same 261-uniform error under Google SwiftShader and describe it as a SwiftShader shader-compiler limitation that should not, by itself, stop a game. See [Godot issue #109550, especially the maintainer analysis](https://github.com/godotengine/godot/issues/109550#issuecomment-3184387942). The compatibility renderer's global uniform buffer default warning is also a known Godot 4.2 Compatibility-project default issue, not proof of an app failure: [Godot issue #85374](https://github.com/godotengine/godot/issues/85374).

A separate QA candidate demonstrates a better CI emulator configuration:
- [PR #159](https://github.com/ninjun42215-gif/KindleWake/pull/159), exact head `df58cfded03c7a85f8e9e7d36719e6a80528b010`.
- [Build Android APK run 44076962703](https://github.com/ninjun42215-gif/KindleWake/actions/runs/44076962703) passed using a standard `google_apis` image with ANGLE and the emulator's native Pixel 5 display defaults.
- [Diagnostic artifact 14324334765](https://github.com/ninjun42215-gif/KindleWake/actions/runs/44076962703/artifacts/14324334765) contains a visible title screen; OCR detected KINDLEWAKE, NEW GAME and SETTINGS, and its log has no SwiftShader uniform-limit error.
- PR #159 is still draft and diverged from current main (18 commits ahead / 4 behind); its successful run is on that older exact head. Rebase and rerun on current main before relying on it for mainline CI.

**No physical Android device was tested.** Emulator evidence is not physical-device certification.

## Source handoff integrity

The main source snapshot came from [Manual Source Handoff run 44225653270](https://github.com/ninjun42215-gif/KindleWake/actions/runs/44225653270), artifact [14392014166](https://github.com/ninjun42215-gif/KindleWake/actions/runs/44225653270/artifacts/14392014166).

Downloaded and verified locally:
- Exact ref: `refs/heads/main`, SHA `751b2f3f6b1104aa30e107659094ae2e221dbe3d`.
- 369 tracked files.
- Three binary parts: 25,000,000; 25,000,000; and 23,960,538 bytes (all within the 25,000,000-byte limit).
- Reassembled archive: 73,960,538 bytes; SHA-256 `84918cec1bdc1fb7cf8855e87ff9b0c40420cb2ade6ece91ce7eb06dc815ed5e`.
- The included helper verified all part hashes, archive size/hash, ZIP CRC and all 369 tracked-file hashes; safe extraction passed.

## Repository, branch and PR health

The repository currently has 166 branches and 23 open pull requests. There is substantial branch sprawl; many older branches are stacked or far behind main. Do not bulk-merge or cherry-pick stale branches without a fresh diff and exact-SHA checks.

Priority open PRs:
- **#159 — Android emulator script guard:** head `df58cfded03c7a85f8e9e7d36719e6a80528b010`, 18 ahead / 4 behind main, draft, mergeable false. It contains the currently demonstrated emulator workaround; rebase and rerun.
- **#160 — malformed empire-state validation:** head `6714affbb57235e768383da39b4b1e65827999bd`, 6 ahead / 0 behind main, draft. Its [Build APK run 44230871352](https://github.com/ninjun42215-gif/KindleWake/actions/runs/44230871352) completed import, 20-scene smoke, 1,011 strict checks and APK export/signing, then failed at the same AOSP ATD emulator stage. Its focused save-validation change is not merged.
- **#161 — companion portrait identity journal:** head `c8e4782ffb6dae4f06ad54a1639e01ad92c8757d`, 6 ahead / 0 behind main, draft. Its [Build APK run 44255293371](https://github.com/ninjun42215-gif/KindleWake/actions/runs/44255293371) completed import, 20-scene smoke, 1,009 strict checks and APK export/signing, then failed at the same emulator stage.
- **#162 — Ilyan/Maren companion portraits:** head `bb014d5d627b88a2a70b06d1a6b59ee8933f8ac5`, stacked on #161, 12 ahead / 0 behind main. Only YAML lint is complete on this exact head; Android build and project audit are still required.
- **#152 — production release gate hardening:** head `740dc7d6b3c55f4d23d63c5eca81f690dc3e3433`, 4 ahead / 93 behind main. Its four checks passed on that older exact head, but it needs rebasing and fresh checks. #148 is an older overlapping candidate (11 ahead / 96 behind).
- **#156** is an older empire-save validation candidate (8 ahead / 83 behind); prefer reviewing the newer focused #160 candidate rather than integrating both.
- **#81 regional trading** is severely stale (3 ahead / 141 behind) and remains unsuitable for integration without a fresh current-main implementation and renewed tests.

Older branches such as #78/#66/#63, #46, #42 and #22/#23 are heavily diverged/stacked and should be treated as archival references until individually reconciled.

## Release workflow and security findings

Two release-workflow mismatches remain on main and should be resolved before pushing a version tag or publishing:

1. `.github/workflows/build-apk.yml` correctly defaults the ordinary build job to `contents: read`, but it still contains a tag-only `publish-tag-release` job with `contents: write` that attaches the CI APK to a GitHub Release for any `v*` tag. This contradicts `Kindlewake/docs/ANDROID_RELEASE_WORKFLOW.md`, which says a tag push only creates a candidate artifact and does not publish a release.
2. `.github/workflows/publish-android-release.yml` grants `contents: write` at workflow scope, so even its rejected-confirmation job inherits write access. Its manifest sets `SOURCE_SHA` from `github.sha` rather than recording the commit actually checked out from the requested tag; a manual dispatch from a different ref can therefore misstate provenance.

PR #152 contains the appropriate direction: remove automatic release publishing from the routine build workflow; set production workflow permissions to read by default and grant write only to the publish job; set the rejected job to no permissions; record `git rev-parse HEAD` after checking out the requested tag; and extend workflow lint to cover the separate release workflow. Rebase that PR on current main and rerun the checks before considering it.

Secret handling reviewed in the workflow source is otherwise scoped to the relevant steps and the protected `android-production` environment; the keystore is written to the ephemeral runner's temp directory with mode 600. No secret values were exposed in the inspected logs. Repository secret values and environment protection settings were not inspected. The build/release workflows still use version-tag action references (for example `@v4` / `@v5` / `@v2`) rather than full commit-SHA pins; consider pinning for stronger supply-chain reproducibility.

There are currently **zero published GitHub Releases**. The main CI APK artifact is a verified build candidate tied to the exact main run/SHA, not a published production release.

## Asset provenance and structural audit

The exact-main health audit reports 44 JSON files, 88 GDScript files, 20 scenes, 77 rune definitions, 0 errors, 0 warnings, and 0 unverified used assets. The provenance ledger has 10 entries: 7 used entries are marked verified (Quaternius CC0, the Zerie Free Soldier/Orc subset under the author's game-use terms, and project-authored artwork); the remaining legacy/restricted/unknown entries are unused. The old voxel-building pack is marked unused and replaced in runtime by original KindleWake settlement SVGs. Continue to keep unused packs out of runtime and do not redistribute the Zerie source pack as a standalone archive.

The audit is structural only; it does not validate external licence claims, runtime appearance, gameplay balance or physical-device performance.

## Documentation drift

At the inspected main SHA, root `README.md` still named main `8a1f9e4...` and an older build, while `Kindlewake/docs/SESSION_HANDOFF.md` still named `9ac0b8c...`. `Kindlewake/docs/ANDROID_RELEASE_WORKFLOW.md` still carries a 10 November update date and describes artifact contents/tag publishing that do not match the current workflows. This report is the current QA checkpoint; reconcile the older handoff and Android workflow documents after the overlapping QA PRs are rebased.

## Release-readiness decision

**Not release-ready yet.** The exact-main headless tests, APK export/signature and source handoff are good, but the current main emulator smoke is red; the emulator workaround exists only on a stale draft PR; production release permissions/provenance are too broad/misaligned; and no physical Android device QA has been recorded. Preserve the existing game content and save schema. Do not publish or merge as part of this QA report.
