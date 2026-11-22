# KindleWake QA release-readiness handoff — 2026-11-21

## Scope and source state

- Repository: https://github.com/ninjun42215-gif/KindleWake
- Engine/project: Godot 4.2.2, GL Compatibility, Android
- Exact base `main`: `13f66ec19476c9af5ed2b5c81af95e4d8a026876`
- QA branch: `qa/project-health-audit-doc-consistency-2026-11-21`
- This branch contains documentation-only consistency work. It does not change game runtime, save data, story, assets, permissions, project version or workflows.
- No merge, force-push, branch deletion, repository-setting change, production tag or release publication was performed.

## Confirmed asset-provenance documentation mismatch

On `main`, `Kindlewake/docs/PROJECT_HEALTH_AUDIT.md` said the legacy voxel building packs were used and a release blocker. The machine-readable ledger at `Kindlewake/data/asset_provenance.json` says the opposite:

- `voxel-building-packs`: `license_status=unverified`, `used_in_game=false`, `release_blocker=false`.
- Ledger notes say those legacy PNGs are retained for provenance/history and are no longer loaded; original KindleWake vector settlement art replaced them.
- `assets/art/CREDITS.md` also says the legacy PNGs are no longer loaded.
- The current used third-party entries (Quaternius Stylized Nature MegaKit and the Zerie free Soldier/Orc subset) are marked verified; project-authored used artwork is separately recorded.

The audit documentation is corrected on this branch: the legacy voxel files remain unverified and must not be imported or redistributed, but are not a current used-game release blocker while unused. Used assets with unverified rights remain release blockers. No ledger flags or asset files were changed.

## Current repository inventory

- Main SHA remains `13f66ec19476c9af5ed2b5c81af95e4d8a026876`; the latest main commit is dated 2026-11-19.
- GitHub listing after opening this QA branch and PR #172: 176 branches and 33 open PRs (32 open PRs were present before #172 was opened).
- Main reports `protected=false`; required status-check enforcement is not configured. This run did not change repository settings.
- No published GitHub Releases were found.
- Recent PR divergence from current main:
  - #164 Android/release QA: 18 ahead / 0 behind.
  - #165 Safe Auto Merge freshness: 2 / 0.
  - #166 Chronicle save normalization: 7 / 0.
  - #167 settlement architecture atlas: 5 / 0.
  - #168 character appearance save guard: 7 / 0.
  - #169 regional settlement style: 11 / 0; stacked on #167, so review it with its parent.
  - #170 lethal rune-status turn advance: 3 / 0.
  - #171 rune-element battle VFX: 9 / 0.
- Older trading, portrait, empire and story branches remain heavily diverged or stacked; reconcile selectively rather than bulk-merging. Examples: #81 trading 3 ahead / 146 behind; #130 auth docs 2 / 117; #78 headless CI 70 / 160; #46 empire management 261 / 161; #22 and #23 art-direction docs 1 / 198 and 6 / 198.
- Asset-provenance coordination: PR #167 adds the runtime-loaded `assets/art/tiles/local_architecture_detail.svg` and a per-asset provenance note, but does not add the asset to the central `data/asset_provenance.json` or `assets/art/CREDITS.md`. PR #157 currently changes both shared inventories and is 34 ahead / 9 behind main. QA left a review comment on #167 requesting a coordinated ledger/credits entry after reconciliation; do not overwrite the shared files or bulk-merge the stale portrait branch. PR #169 is stacked on #167 and modifies the same location renderer/test file.

## Android renderer failure — reproduced on current-main-based PRs

Two fresh main-based PR builds reproduced the same AOSP ATD / forced SwiftShader GLES3 failure:

### PR #170 — battle turn soft-lock regression

- Exact head: `1627003d242ae719591b8b8fb8570f68a3b8d5ef`
- [Build Android APK #44861498921](https://github.com/ninjun42215-gif/KindleWake/actions/runs/44861498921): headless import, 20-scene smoke, strict tests, APK export and upload passed; emulator launch/liveness failed.
- [Project Health Audit #44861498868](https://github.com/ninjun42215-gif/KindleWake/actions/runs/44861498868): passed.
- [Workflow YAML Lint #44861498833](https://github.com/ninjun42215-gif/KindleWake/actions/runs/44861498833): passed.
- [Version Sync #44861498864](https://github.com/ninjun42215-gif/KindleWake/actions/runs/44861498864): passed.
- Strict core suite: 1,009 checks / 0 failures.
- Campaign continuity: 74 checks / 0 failures, including all four new lethal-burn turn-advance assertions.
- [Test logs #14689857858](https://github.com/ninjun42215-gif/KindleWake/actions/runs/44861498921/artifacts/14689857858), downloaded ZIP SHA-256 `6a7a819b04fda4678333af21be17e2fbe9aa0864f9fc697b181eff1ee8aa7d9c`; ZIP integrity passed.
- [APK #14690485462](https://github.com/ninjun42215-gif/KindleWake/actions/runs/44861498921/artifacts/14690485462): archive SHA-256 `029bc3bab3542c4b0b4b2b6ce0a602fc7ccd6c93ebd921d74afce0ee4621c45e`; downloaded ZIP integrity passed; extracted APK 65,852,762 bytes, SHA-256 `4073f2c550a0073ef267306f61b0377d67659214b6b198284a91ef90186ba013`. Build summary reports a valid CI/test signature, ABIs arm64-v8a / armeabi-v7a / x86_64, and no requested Android permissions.
- The combat fix and its test pass in CI. Keep PR #170 draft until the core engineer reviews turn-queue behavior; the Android step failure is separate.

### PR #171 — rune-element battle VFX

- Exact head: `e5e9f3ca1b7c66f7d46069b2b6a2c285dfe29a70`
- [Build Android APK #44876154698](https://github.com/ninjun42215-gif/KindleWake/actions/runs/44876154698): import, 20-scene smoke, strict tests, campaign/UI tests, balance report, APK export and upload passed; emulator launch/liveness failed.
- [Project Health Audit #44876154733](https://github.com/ninjun42215-gif/KindleWake/actions/runs/44876154733): passed.
- [Workflow YAML Lint #44876154670](https://github.com/ninjun42215-gif/KindleWake/actions/runs/44876154670): passed.
- [Version Sync #44876154712](https://github.com/ninjun42215-gif/KindleWake/actions/runs/44876154712): passed.
- Strict core suite: 1,026 checks / 0 failures, including 17 rune-VFX style assertions.
- Campaign continuity: 70 checks / 0 failures; Chronicle dynasty: 39 / 0; Chronicle family development: 19 / 0.
- [Test logs #14695764081](https://github.com/ninjun42215-gif/KindleWake/actions/runs/44876154698/artifacts/14695764081), downloaded ZIP SHA-256 `62cc94a193ac8fbd2ada439fe03b0c6e17b91d1b365d735060cec8e9f51552a0`; ZIP integrity passed.
- [APK #14696096827](https://github.com/ninjun42215-gif/KindleWake/actions/runs/44876154698/artifacts/14696096827): archive SHA-256 `4ea8372d2ec5a6a6947a9c865060f6510d0989e8bde850a23c50ff15cb6362c1`; downloaded ZIP integrity passed; extracted APK 65,852,845 bytes, SHA-256 `1d0d33d40252b06c6d51d35c4c4b0f0e6f0a5a4c8e3bb4856c1f993d47f62b85`. Build summary reports valid CI/test signature, three ABIs and no requested permissions.
- The new drawing uses bounded CanvasItem vector primitives; it adds no shaders, external assets or combat-rule changes. However, an editor/battle screenshot visual review and physical-device frame-pacing test remain outstanding.

### Reproduced emulator logcat cause

The PR #171 test-log artifact was downloaded and inspected. It records:

- `rendering/limits/global_shader_variables/buffer_size` exceeds the emulator's 16,384-byte uniform-buffer limit.
- `SceneShaderGLES3: Program linking failed`.
- `Fragment shader active uniforms exceed GL_MAX_FRAGMENT_UNIFORM_VECTORS (261)`.
- `shader failed to compile, unable to bind shader`.
- The Godot activity starts, logs the shader errors, then explicitly destroys/quits the Godot instance; Android records the app process exiting with signal 9. The screenshot is black. The final `pidof com.kindlewake.game` assertion therefore fails.
- No Java `FATAL EXCEPTION` or native fatal-signal stack trace was found in this captured logcat.

This is a reproducible renderer/backend compatibility failure in the AOSP ATD / forced SwiftShader CI path. PR #171 is CanvasItem vector drawing and does not add shaders; the same failure was already present on main and PR #170. Do not attribute it to the new rune effects. It is not yet proven that every physical Android GPU is affected.

## Verified alternate CI path

QA PR #164 uses API 35 Google APIs x86_64 / Pixel 5 with default graphics selection and stronger foreground/screenshot checks.

- Exact PR head: `d82a92485f3ea7651cab2abf616df3733d369420`, 18 ahead / 0 behind.
- [Build Android APK #44727952505](https://github.com/ninjun42215-gif/KindleWake/actions/runs/44727952505): passed end-to-end, including emulator install and launch.
- [Project Health Audit #44727952388](https://github.com/ninjun42215-gif/KindleWake/actions/runs/44727952388): passed.
- [Workflow YAML Lint #44727952421](https://github.com/ninjun42215-gif/KindleWake/actions/runs/44727952421): passed.
- [Version Sync #44727952533](https://github.com/ninjun42215-gif/KindleWake/actions/runs/44727952533): passed.
- The title screen remained foreground/resumed; OCR detected KINDLEWAKE, NEW GAME and SETTINGS; screenshot inspection showed a centered, legible title/menu. No GLES shader-link errors or fatal/script errors were found.
- [APK #14624273966](https://github.com/ninjun42215-gif/KindleWake/actions/runs/44727952505/artifacts/14624273966): archive SHA-256 `daeda8adc20809d56177e7c3eddc0ef935b77506aca381cc286e07157726ef36`; ZIP integrity passed; extracted APK 65,852,762 bytes, SHA-256 `f2a873bffd12ff8fa6466bc60eed9194261f2d9d490a8a4407ac13e8672b6f90`.
- This demonstrates that the alternate CI emulator path launches the current game build; it does not repair GLES3 shaders or certify other GPUs. The APK is CI/test-signed, not production-signed.

## Release workflow and repository security

Current `main` still has these issues, while PR #164 proposes fixes:

1. `.github/workflows/build-apk.yml` publishes an APK to a GitHub Release on any version-tag push. The job has `contents: write` and uses the routine CI/test signing identity. Candidate builds should remain artifacts only.
2. `.github/workflows/publish-android-release.yml` grants `contents: write` at workflow scope and records `github.sha` rather than the exact checked-out tag commit in the manifest.
3. PR #164 changes routine tag builds to candidate-only artifacts, narrows production write permission to the publish job, gives the rejected-confirmation job no write permission, and records `git rev-parse HEAD` after checking out the immutable tag.
4. Production environment reviewer rules and signing-secret presence remain unverified; no secret values were read.
5. GitHub Actions logs still warn that pinned actions target Node.js 20 and are being forced onto Node.js 24. Non-fatal; update separately after validating supported action versions.

## Source handoff and remaining release gates

- Last independently verified main source handoff remains run [#44446304164](https://github.com/ninjun42215-gif/KindleWake/actions/runs/44446304164), artifact [#14493885543](https://github.com/ninjun42215-gif/KindleWake/actions/runs/44446304164/artifacts/14493885543), exact main SHA `13f66ec19476c9af5ed2b5c81af95e4d8a026876`. The previous verification reassembled the three parts, checked ZIP CRC and all 370 tracked file hashes, and found zero excluded paths. No newer main source-handoff run was observed in this audit.
- No published releases were found.
- No physical Android handset was tested. Touch, save/load, orientation, pause/resume, thermal behavior, memory, frame pacing and vendor GPU compatibility remain unverified.
- Main has not changed from the base SHA during this run; no new main Android build was observed. Current-main Android readiness therefore remains unverified and the old AOSP emulator job remains known-failing.
- Do not reuse any APK above for a different commit. All are CI/test-signed candidates; none is a production release.

## Disposition

- Documentation mismatch fixed on this QA branch only.
- PRs #170 and #171 remain draft; their automated gameplay/visual mapping tests pass, but their Android emulator checks fail on the same pre-existing AOSP/SwiftShader renderer issue.
- PR #164 is a green workflow/security candidate and remains draft for human review.
- No merge to main, branch deletion, force-push, repository-setting change, secret access, physical-device test or production release was performed.


---

## QA run 7 — 2026-11-22

### Live repository state

- Main remains exactly 13f66ec19476c9af5ed2b5c81af95e4d8a026876; no new main commit was observed.
- Live search returned 33 open PRs and 177 branches (100 + 77; final page empty). No published GitHub Releases were found.
- The public rulesets endpoint returned an empty list. The branch-protection endpoint returned HTTP 403 (Resource not accessible by integration), so branch protection could not be independently re-read in this run. Do not treat the 403 as proof that protection is disabled.
- Current main workflow runs on the exact main SHA: Build Android APK [#44446304169](https://github.com/ninjun42215-gif/KindleWake/actions/runs/44446304169) failed at emulator liveness; Project Health Audit [#44446304110](https://github.com/ninjun42215-gif/KindleWake/actions/runs/44446304110), Workflow YAML Lint [#44446304180](https://github.com/ninjun42215-gif/KindleWake/actions/runs/44446304180), Version Sync [#44446304299](https://github.com/ninjun42215-gif/KindleWake/actions/runs/44446304299) and Manual Source Handoff [#44446304164](https://github.com/ninjun42215-gif/KindleWake/actions/runs/44446304164) passed.
- The latest main source-handoff artifact remains [#14493885543](https://github.com/ninjun42215-gif/KindleWake/actions/runs/44446304164/artifacts/14493885543). Prior independent reassembly verified the 370 tracked-file snapshot, ZIP CRC and every included file hash with zero excluded paths. No newer main handoff run was observed.

### Current PR divergence

All counts below compare the PR head against current main, except #169 which is stacked on #167 and must be reviewed with its parent:

| PR | Head SHA (short) | Ahead / behind | State |
|---|---|---:|---|
| #164 Android/release QA | 03efa339 | 20 / 0 | Draft; new exact-head Android run in progress |
| #165 Safe Auto Merge freshness | 69acf496 | 2 / 0 | Draft |
| #166 Chronicle save normalization | fbbfbaf2 | 7 / 0 | Draft |
| #167 settlement architecture | d55e2eca | 5 / 0 | Draft |
| #168 character appearance save guard | e33a591b | 7 / 0 | Draft |
| #169 regional settlement style | 38f7ebee | 11 / 0 | Draft; stacked on #167 |
| #170 battle turn recovery | cc6e819c | 6 / 0 | Draft |
| #171 rune battle VFX | e5e9f3ca | 9 / 0 | Draft |
| #172 QA documentation | 85d08817 before this handoff append | 3 / 0 | Draft |
| #173 rune icon atlas | 09c9080a | 6 / 0 | Draft |
| #81 regional trading | 69794034 | 3 / 146 | Draft; not mergeable |
| #78 headless CI | 5873e380 | 70 / 160 | Draft; stacked |
| #46 empire management | 84fdfc8e | 261 / 161 | Draft; not mergeable |
| #157 portrait identity | b9545c5e | 34 / 9 | Draft; not mergeable |
| #159 Android script guard | df58cfde | 18 / 9 | Draft; not mergeable |
| #152 release publishing | 740dc7d6 | 4 / 98 | Draft; stale |

Do not bulk-merge the stale branches. Extract reviewed changes into fresh branches from current main when their owners are ready.

### PR #173 — premium rune icon atlas

- Exact head: 09c9080a5690dabdcb25642ebc65615cf1236735; base main 13f66ec19476c9af5ed2b5c81af95e4d8a026876.
- The PR changes the runtime assets/art/runes/rune_atlas.svg, its README and visual handoff. It preserves the 400 × 240 canvas, 10 × 6 grid, 40 × 40 cells and column/row order used by PartyScreen._rune_icon(). No rune IDs, grades, fusion rules, equipment sockets, combat data, save schema or gameplay code changed.
- Project Health Audit [#44995604823](https://github.com/ninjun42215-gif/KindleWake/actions/runs/44995604823), Workflow YAML Lint [#44995604873](https://github.com/ninjun42215-gif/KindleWake/actions/runs/44995604873) and Version Sync [#44995604817](https://github.com/ninjun42215-gif/KindleWake/actions/runs/44995604817) passed on this exact head.
- Build Android APK [#44995604827](https://github.com/ninjun42215-gif/KindleWake/actions/runs/44995604827): Godot import, 20-scene smoke, strict core suite (1,009 checks / 0 failures), campaign lifecycle, merchant UI, title/creator UI, Act V, campaign continuity (70 / 0), Chronicle dynasty (39 / 0), family development (19 / 0), balance report and APK export/upload passed. Overall build failed at Android process liveness.
- Downloaded APK artifact [#14743538883](https://github.com/ninjun42215-gif/KindleWake/actions/runs/44995604827/artifacts/14743538883). GitHub artifact metadata digest and independently downloaded ZIP SHA-256 both equal de29158472b611df003b8d2680b29519e88b639b4cad16a26219c6711e16cc2f; ZIP CRC passed. Extracted APK size 65,897,818 bytes; extracted APK SHA-256 cb4ad8dcf01f6a1840c36c44907b34418be93229faeb0aea094dc0b0ac6eeace. Build summary reports valid CI/test signature (fingerprint prefix c04a7792715ad8f5), ABIs arm64-v8a / armeabi-v7a / x86_64 and no requested Android permissions. It is not a release-verified build because the emulator step failed.
- Downloaded test-log artifact [#14743163360](https://github.com/ninjun42215-gif/KindleWake/actions/runs/44995604827/artifacts/14743163360), ZIP SHA-256 ba8d9d1d36818cc5405c3a92e1ec59e3eef8125fbad58993a68826ef7ddfdf90; ZIP CRC passed.
- Logcat confirms the AOSP ATD / forced SwiftShader renderer failure: global shader-variable buffer size warning above 16,384 bytes; SceneShaderGLES3 link failure because fragment uniforms exceed GL_MAX_FRAGMENT_UNIFORM_VECTORS (261); Godot destroys the app activity and Android records the process death. No Java fatal exception or native fatal-signal stack trace was captured. This is pre-existing renderer/backend behavior in the old CI path, not introduced by the SVG atlas.
- The central kindlewake-original-art provenance entry already includes the rune atlas as project-authored art. The remaining visual gate is editor inspection at actual 40 px display size and physical-device texture/frame-pacing review. PR #173 remains draft.

### PR #170 — battle turn soft-lock and legacy restore recovery

- Exact head: cc6e819ca2f24cf84715f63d0b67c815f331996b; 6 ahead / 0 behind main.
- Project Health Audit [#44980590059](https://github.com/ninjun42215-gif/KindleWake/actions/runs/44980590059), Workflow YAML Lint [#44980590079](https://github.com/ninjun42215-gif/KindleWake/actions/runs/44980590079) and Version Sync [#44980590140](https://github.com/ninjun42215-gif/KindleWake/actions/runs/44980590140) passed.
- Build Android APK [#44980590086](https://github.com/ninjun42215-gif/KindleWake/actions/runs/44980590086): import, 20 scenes, 1,009 core checks / 0 failures, campaign continuity 79 / 0 (including new status-death and stale-active snapshot recovery assertions), Chronicle dynasty 39 / 0, family development 19 / 0, balance report and APK export/upload passed. Emulator process-survival failed.
- Downloaded test logs [#14737866383](https://github.com/ninjun42215-gif/KindleWake/actions/runs/44980590086/artifacts/14737866383), SHA-256 21600f394c63a445376100a9ef22dceb5431d9f1bb5833c2a974f71eb8125e74; ZIP CRC passed. Its logcat independently confirms the same 16,384-byte uniform-buffer warning and GL_MAX_FRAGMENT_UNIFORM_VECTORS (261) SceneShaderGLES3 link failure, followed by Godot activity destruction and process death.
- APK artifact [#14738045539](https://github.com/ninjun42215-gif/KindleWake/actions/runs/44980590086/artifacts/14738045539) is present in Actions metadata with archive digest f29dac59cb2881042e50d18eb2b514ec9b5f18bc38c0b245cb5b727c0196e299; its bytes were not independently downloaded in this run.
- QA posted the exact-head result and renderer diagnosis to [PR #170](https://github.com/ninjun42215-gif/KindleWake/pull/170#issuecomment-7078111406). Keep the PR draft for core engineering review; no merge performed.

### PR #164 — Android emulator and release workflow hardening

- The previously verified head d82a92485f3ea7651cab2abf616df3733d369420 passed Build Android APK [#44727952505](https://github.com/ninjun42215-gif/KindleWake/actions/runs/44727952505), Project Health Audit [#44727952388](https://github.com/ninjun42215-gif/KindleWake/actions/runs/44727952388), YAML Lint [#44727952421](https://github.com/ninjun42215-gif/KindleWake/actions/runs/44727952421) and Version Sync [#44727952533](https://github.com/ninjun42215-gif/KindleWake/actions/runs/44727952533). Its API 35 Google APIs / default-graphics Pixel 5 emulator kept the Godot activity foreground and OCR detected KINDLEWAKE, NEW GAME and SETTINGS.
- This run added a focused logcat guard to the same QA branch, failing the emulator smoke if USER ERROR, SceneShaderGLES3 link failure, GL_MAX_FRAGMENT_UNIFORM_VECTORS, shader compilation failure or shader binding failure appears. The change is workflow-only and does not change game code.
- New branch head: 03efa339e85df62763bada23c2f7f97d5158d514, 20 ahead / 0 behind main. Project Health Audit #45014535347, YAML Lint #45014535345 and Version Sync #45014535355 passed. Exact-head Android build [#45014535413](https://github.com/ninjun42215-gif/KindleWake/actions/runs/45014535413) was still running at the time of this handoff append; its import/test/APK export stages passed and the emulator stage was in progress. Do not claim final Android success until that run completes.
- PR #164 also removes the routine tag-triggered GitHub Release attachment job from build-apk.yml, keeps routine builds as candidate artifacts, scopes production contents: write to the production publish job, gives the rejected-confirmation job no write permission, and records git rev-parse HEAD after checking out the immutable release tag. These are safer than current main's workflow.
- Current main still has a tag-triggered publish-tag-release job in build-apk.yml and publish-android-release.yml still grants contents: write at workflow scope and records github.sha instead of the exact checked-out tag SHA. Production environment reviewer rules and signing-secret presence remain unverified; no secret values were read.
- PR #164 remains draft; its new exact-head build must finish before the candidate can be considered fully verified.

### Save-integrity candidates

- PR #166 head fbbfbaf271136798bd3d9113c8145305188862c3 retains its Chronicle normalization regression: 42 checks / 0 failures on its last exact-head test. Its Android workflow failed at the old AOSP/SwiftShader emulator step; it has not yet been retested on PR #164's alternate emulator path.
- PR #168 head e33a591ba5e08a9802499e9e5979d81ea990c0cc retains its character appearance persistence suite: 7 checks / 0 failures on its last exact-head test. Its Android workflow also failed at the old emulator step; it has not yet been retested on the alternate path.
- Neither save candidate was merged or changed in this run.

### Workflow, provenance and security notes

- Current main build-apk.yml gives the APK job contents: read, but still includes a separate tag-triggered job with contents: write and softprops/action-gh-release@v2; that can publish a routine CI/test-signed APK to a GitHub Release. This conflicts with ANDROID_RELEASE_WORKFLOW.md's claim that tag builds are candidate-only.
- Current main publish-android-release.yml has workflow-level contents: write and writes github.sha into the release manifest even though the job checks out inputs.tag. PR #164 narrows permissions and records the actual checked-out tag commit.
- Current safe-auto-merge.yml uses contents: write and pull-requests: write because it invokes the merge API, but it does not check out or execute PR code and validates unique open PR ownership, exact head SHA, current base and successful discovered workflows. Recent main Safe Auto Merge runs were skipped; no merge occurred in this run.
- The rulesets collection was empty; direct branch-protection inspection was denied with 403, so branch protection remains unverified in this run.
- Node.js 20 deprecation warnings remain for pinned GitHub Actions; update action versions separately after compatibility testing.
- The main asset ledger's generic original-art entry includes the rune atlas, so PR #173 does not need a duplicate entry solely for that replacement. PR #167's additional local architecture detail atlas still needs reconciliation with the central asset inventory/credits; PR #157 owns shared portrait inventory files and is 34 ahead / 9 behind, so coordinate rather than overwrite them.
- No secrets were accessed. No repository settings, main, tags, releases or user-owned feature branches were changed.

### Release disposition

- Main remains at 13f66ec19476c9af5ed2b5c81af95e4d8a026876.
- No physical Android device was tested. Touch, save/load, orientation, pause/resume, memory, thermal behavior, frame pacing and vendor GPU compatibility remain unverified.
- All APKs above are CI/test-signed candidates. The PR #173 archive and extracted APK hashes were independently verified, but its Android launch failed. Do not reuse any APK for a different SHA or label any candidate as production-ready.
- No merge, force-push, branch deletion, repository-setting change, production tag or release publication was performed.
