# KindleWake QA and Android release-workflow remediation — 18 November 2026

## Exact source and proposed revision

- Repository: https://github.com/ninjun42215-gif/KindleWake
- Canonical project: `Kindlewake/`
- Audited main SHA: `751b2f3f6b1104aa30e107659094ae2e221dbe3d`
- Godot 4.2.2 · GL Compatibility · Android version `0.12.0` · Android version code `1200` · save schema `4`
- QA branch: `qa/android-release-workflow-hardening-2026-11-18`
- Workflow implementation checkpoint (before this report file): `3e11da43fd28a0d2db9cf5b81063c65eef0c8de7`
- This is a draft QA proposal. No merge, release publication, branch deletion, force-push, repository setting change, secret read, gameplay/data change or save/schema change was performed.

## Mainline verification on the exact audited SHA

Main SHA `751b2f3f6b1104aa30e107659094ae2e221dbe3d` was the exact source for these runs:

| Check | Result | Evidence |
|---|---|---|
| Godot import and scene smoke | Passed; 20 scenes loaded, 0 failures | [Build Android APK #44225653213](https://github.com/ninjun42215-gif/KindleWake/actions/runs/44225653213) |
| Strict core suite | Passed; 1,009 checks, 0 failures | [Build #44225653213](https://github.com/ninjun42215-gif/KindleWake/actions/runs/44225653213) |
| Campaign lifecycle, merchant UI, title/creator UI, Act V | Passed; 0 failures in each suite | [Build #44225653213](https://github.com/ninjun42215-gif/KindleWake/actions/runs/44225653213) |
| Campaign continuity | Passed; 70 checks, 0 failures | [Build #44225653213](https://github.com/ninjun42215-gif/KindleWake/actions/runs/44225653213) |
| Chronicle dynasty | Passed; 39 checks, 0 failures | [Build #44225653213](https://github.com/ninjun42215-gif/KindleWake/actions/runs/44225653213) |
| Chronicle family development | Passed; 19 checks, 0 failures | [Build #44225653213](https://github.com/ninjun42215-gif/KindleWake/actions/runs/44225653213) |
| Balance report | Passed; exit 0 | [Build #44225653213](https://github.com/ninjun42215-gif/KindleWake/actions/runs/44225653213) |
| Project Health Audit | Passed; 0 errors, 0 warnings | [Audit #44225653218](https://github.com/ninjun42215-gif/KindleWake/actions/runs/44225653218) |
| Workflow YAML lint | Passed | [Lint #44225653214](https://github.com/ninjun42215-gif/KindleWake/actions/runs/44225653214) |
| Version sync | Passed | [Version Sync #44225653230](https://github.com/ninjun42215-gif/KindleWake/actions/runs/44225653230) |
| Source handoff packaging | Passed | [Handoff #44225653270](https://github.com/ninjun42215-gif/KindleWake/actions/runs/44225653270) |
| Full Android emulator workflow | **Failed at emulator smoke; overall build is not green** | [Build #44225653213](https://github.com/ninjun42215-gif/KindleWake/actions/runs/44225653213) |

### APK provenance

The failed overall main build nevertheless completed import, tests, balance, export, signature inspection and artifact upload before its emulator step:

- APK artifact: [14393186073](https://github.com/ninjun42215-gif/KindleWake/actions/runs/44225653213/artifacts/14393186073)
- Artifact ZIP size: 65,292,502 bytes.
- Extracted APK size: 65,848,438 bytes.
- Extracted APK SHA-256 independently recomputed during this QA run: `046d7cd0006b4cdfdb1c6937e586b392879444a62a12d9ae01e01bd18b069c2f`.
- Build summary reports a valid test/sideload signature, Android ABIs `arm64-v8a`, `armeabi-v7a`, `x86_64`, and no requested Android permissions.
- [Test/log artifact 14392193337](https://github.com/ninjun42215-gif/KindleWake/actions/runs/44225653213/artifacts/14392193337) contains the emulator diagnostics.

This APK is tied to the exact audited main SHA, but the full workflow failed. It is not a fully passing release candidate and must not be presented as device-certified.

### Emulator failure diagnosis

The current main workflow uses API 35 AOSP ATD with `swiftshader_indirect` and changes emulator resolution/density during startup. The downloaded logcat shows:

- Godot GLES3 `SceneShaderGLES3` link failures: 261 active fragment uniforms exceed the emulator-reported `GL_MAX_FRAGMENT_UNIFORM_VECTORS`.
- AOSP `MultiDisplayService` starts, creates displays and reports `invalid parameters for add/modify display`.
- The Godot activity is destroyed and its process is killed shortly after launch; the 30-second liveness check fails.
- No GDScript parse/runtime error or Android `FATAL EXCEPTION` was found in the captured log.

The evidence proves an emulator smoke failure, but does not isolate a game-code defect or establish a physical-device crash.

A useful prior diagnostic exists on an older branch:
- [PR #159](https://github.com/ninjun42215-gif/KindleWake/pull/159), tested head `df58cfded03c7a85f8e9e7d36719e6a80528b010`.
- [Build #44076962703](https://github.com/ninjun42215-gif/KindleWake/actions/runs/44076962703) passed using API 35 `google_apis` and ANGLE with Pixel 5 defaults.
- [Diagnostic artifact 14324334765](https://github.com/ninjun42215-gif/KindleWake/actions/runs/44076962703/artifacts/14324334765) was downloaded; OCR reported `KINDLEWAKE`, `NEW GAME`, and `SETTINGS`, and the screenshot showed the title menu.
- PR #159 is stale/diverged from current main (18 ahead / 4 behind at audit). Its workflow-only correction is being ported to a fresh branch; its old successful run is evidence for a candidate configuration, not validation of current main.

## Structural audit, data and provenance

The exact-main health-audit artifact [14393026627](https://github.com/ninjun42215-gif/KindleWake/actions/runs/44225653218/artifacts/14393026627) was downloaded and inspected:

- 44 JSON files, 88 GDScript files, 20 scenes, 11 tracked workflow files.
- 77 rune definitions: 23 magic, 43 passive, 6 stat, 3 support, 2 independent.
- Project/export version match: `0.12.0`; Android version code `1200`.
- 0 structural errors, 0 warnings, 0 unverified used assets.

The asset ledger has 10 entries. Seven runtime-used entries are marked verified: Quaternius CC0, the Zerie free Soldier/Orc subset under the author's game-use terms, and project-authored artwork. The legacy voxel-building pack, LimeZu free pack and MountainRocks archive are marked unused; their licence statuses remain unverified/restricted/unknown. Do not reintroduce them into runtime or redistribute the Zerie source pack standalone. The health audit is structural; it does not prove third-party licence terms.

The main source handoff is [run #44225653270](https://github.com/ninjun42215-gif/KindleWake/actions/runs/44225653270), artifact [14392014166](https://github.com/ninjun42215-gif/KindleWake/actions/runs/44225653270/artifacts/14392014166). The preceding QA handoff report records 369 tracked files, three parts under 25,000,000 bytes, reassembly and per-file hash verification. This run checked the live artifact metadata; it did not re-download/reassemble the full 74 MB snapshot.

## Workflow integrity findings on audited main

1. `.github/workflows/build-apk.yml` contains a tag-only `publish-tag-release` job with `contents: write`. It can publish a routine CI/test-signed APK to a public GitHub Release, contradicting the release guide's candidate-only policy.
2. `.github/workflows/publish-android-release.yml` grants `contents: write` at workflow scope, so the rejected-confirmation job inherits more permission than it needs.
3. The production manifest uses `${{ github.sha }}`, which is the manual-dispatch event SHA, rather than explicitly recording the immutable tag commit checked out by the publish job.
4. Workflow action references still include floating major tags such as `@v4`, `@v5` and `@v2`; full commit-SHA pinning is a separate supply-chain hardening task.
5. No published GitHub Releases were returned by the releases API. The production environment's reviewer rules and secret values were not inspected. No secret values were accessed or exposed.

The current `Safe Auto Merge` workflow has `actions: read`, `contents: write` and `pull-requests: write`, but does not check out or execute PR code. Its recent main runs skipped because no eligible non-draft PR was present. Native GitHub auto-merge is disabled. Main branch protection is also disabled (`protected: false`); this QA run did not alter repository settings.

## Proposed QA-only workflow changes

This branch changes workflow and release documentation only; it does not modify game runtime, scenes, story, balance, save files, schemas, assets or signing material.

- Remove the routine tag-release job. Tag builds remain CI candidates; only the protected production workflow may create public releases.
- Default production workflow permission to `contents: read`; grant `contents: write` only to the `publish` job; set `rejected` to `contents: none`.
- Capture `git rev-parse HEAD` immediately after checkout of the requested tag and use that exact SHA in the release manifest.
- Port the previously demonstrated Google APIs / ANGLE emulator setup to a fresh current-main branch; avoid runtime display-size mutations that trigger the ATD display reconfiguration path.
- Keep process, resumed activity, fatal-log and OCR assertions as single-line commands because the emulator runner invokes script lines with `/usr/bin/sh`.
- Extend workflow YAML lint to enforce the release permission and provenance boundaries.
- Refresh the Android release guide to version `0.12.0 / 1200`, the separate handoff workflow and the protected production lane.

Candidate CI on this new branch is pending at the time this report was authored. Do not describe the proposed changes as passing until the exact PR head's Project Health Audit, Workflow YAML Lint, Version Sync and Android build have completed successfully.

## Branch and PR health

The branch search returned 168 branches (including this new QA branch). The repository currently has 25 open PRs after this draft is opened; the highest-priority comparisons against current main at audit time were:

| PR | Head SHA | Main comparison | Disposition |
|---|---|---:|---|
| #161 companion identity/journal | `c8e4782ffb6dae4f06ad54a1639e01ad92c8757d` | 6 ahead / 0 behind | Fresh main-based visual draft; visual review still needed |
| #160 malformed empire-state validation | `6714affbb57235e768383da39b4b1e65827999bd` | 6 ahead / 0 behind | Fresh main-based save validation; its build still fails at the AOSP emulator stage |
| #163 QA readiness handoff | `3310a66e434786db2b623e0c1afb03d9408393b7` | 5 ahead / 0 behind | Documentation-only draft |
| #162 Ilyan/Maren portraits | `bb014d5d627b88a2a70b06d1a6b59ee8933f8ac5` | 12 ahead / 0 behind | Stacked on #161; do not review/merge independently of its parent |
| #157 protagonist portrait identity | `b9545c5e3fab1ebd5a095bfcf807573bbfc1973c` | 34 ahead / 4 behind | Diverged; reconcile with current visual work before integration |
| #158 equipment icons | `2a0df2d9bb868ed537d6603bcd2f8b4ba01fac87` | 4 ahead / 4 behind | Diverged; review current UI overlap before porting |
| #159 emulator smoke fix | `df58cfded03c7a85f8e9e7d36719e6a80528b010` | 18 ahead / 4 behind | Older successful diagnostic; fresh port supersedes it for current-main validation |
| #152 release publish hardening | `740dc7d6b3c55f4d23d63c5eca81f690dc3e3433` | 4 ahead / 93 behind | Stale release-workflow candidate; changes are ported selectively here |
| #148 release publish hardening | `993d9c49bb919e8ab50c802ce05f876603df6adb` | 11 ahead / 96 behind | Older overlapping candidate; do not bulk-merge |
| #151 battle resume | `e1908f83a01909177b0b72de72499030480b8b8d` | 9 ahead / 93 behind | Stale; rebase and rerun save/battle lifecycle tests |
| #156 empire save validation | `5b250870d3380e68183b7dde955acc7bbcf238fb` | 8 ahead / 83 behind | Superseded by newer focused #160; do not merge both |
| #81 regional trading | `69794034a12012f89e9e709d15b7761f3fa2e771` | 3 ahead / 141 behind | Severely stale; port reviewed slices to a fresh main-based branch only |
| #130 authentication documentation | `d2ab36d73e71e69965f6658aa18e8642f3e52daa` | 2 ahead / 112 behind | Stale documentation branch |
| #78 headless test gate | `5873e380a67d3657290ef0b128edb82f3f63682a` | 70 ahead / 155 behind | Old stacked branch; audit current main before reusing |
| #46 realm administration | `84fdfc8ec6aabfd42bc417530e75d715ec652d2a` | 261 ahead / 156 behind | Too divergent for bulk integration |
| #66 / #63 boss balance | `e22d202a4f69553c4e3f8d54c5c5f1eda51e5d25` / `9fce5718f28c1a16707810d5cc106036b03b3c43` | 57 ahead / 155 behind | Historical test branches; rebase only if current coverage is missing |

The exact branch heads and comparisons must be refreshed before any integration. This process never merges or deletes branches.

## Remaining release gates

- Candidate workflow PR must pass all checks on its exact final head; emulator fix must be verified after porting to current main.
- Install and test on physical Android hardware: launch, title/creator taps, scrolling, orientation, pause/resume, campaign save/load, active battle resume, touch controls, long session and low-memory behavior.
- Verify the actual production GitHub Environment reviewer rules and signing secrets privately; this report does not inspect them.
- Review all runtime asset licences and retain authoritative evidence. Do not mark an unused pack as cleared for use.
- Pin third-party GitHub Actions to reviewed commit SHAs in a separate tested maintenance change.
- Revisit branch protection and required status checks through an explicitly authorized repository-settings change; this QA run leaves settings untouched.
