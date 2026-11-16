# QA and Android release-readiness report — 2026-11-16

**Repository:** https://github.com/ninjun42215-gif/KindleWake  
**Canonical project:** `Kindlewake/` · Godot 4.2.2 · GL Compatibility · Android  
**Audited main:** `698765fd3b5d3cfbef13e301ebd544b8e93277cc`  
**QA candidate branch:** `qa/release-publish-gate-2026-11-16`  
**Candidate base:** `698765fd3b5d3cfbef13e301ebd544b8e93277cc`

This is a dated evidence snapshot. Re-check live refs and Actions before relying on it for a later release.

## Executive result

- The latest visual work, PR [#146](https://github.com/ninjun42215-gif/KindleWake/pull/146), is merged to main. It adds idle breathing, walking bob/stride, periodic eye blinks, talking-mouth animation, NPC speech bubbles and named enemy movement/attack/skill effects. It uses the original project-authored 16-archetype atlas and introduces no external asset dependency.
- PR #146 passed its Android build, project-health audit, workflow YAML lint and version-sync checks on exact PR head `00dd3f2adb826df173767a663e34278874bc5e73`.
- Main now points to merge commit `698765fd3b5d3cfbef13e301ebd544b8e93277cc`. Its Git tree is identical to the tested PR head tree, so the tested APK contains the same source tree. However, the APK's recorded build source is the PR head SHA, not the merge commit SHA. No separate main push build was observed for merge commit `698765f`.
- The existing repository `Safe Auto Merge` workflow completed successfully and merged PR #146. This QA run did not merge, modify main, force-push, delete branches or change repository settings.
- A release-workflow conflict was found and addressed on this isolated QA candidate branch. The candidate remains unmerged and is intended to stay a draft.

## Verified CI and APK evidence

### PR #146 exact-head validation

| Check | Result | Run |
|---|---:|---|
| Build Android APK | Success, run #1000 | [43846527607](https://github.com/ninjun42215-gif/KindleWake/actions/runs/43846527607) |
| Project Health Audit | Success | [43846527756](https://github.com/ninjun42215-gif/KindleWake/actions/runs/43846527756) |
| Workflow YAML Lint | Success | [43846527676](https://github.com/ninjun42215-gif/KindleWake/actions/runs/43846527676) |
| Synchronize Project Version | Success | [43846527726](https://github.com/ninjun42215-gif/KindleWake/actions/runs/43846527726) |

Build log evidence from the exact PR head:

- 20 authored scenes loaded; 0 scene-smoke failures.
- Strict regression suite: **986 checks, 0 failures**.
- Campaign lifecycle failures: 0.
- Merchant UI failures: 0.
- Title/creator UI failures: 0.
- Act V checks completed with 0 failures.
- Campaign continuity: 70 checks, 0 failures.
- Chronicle dynasty: 39 checks, 0 failures.
- Chronicle family development: 19 checks, 0 failures.
- Save tests include legacy v1 save preservation, checksum rejection, malformed metadata rejection and fallback from a semantically invalid primary save to a valid backup.
- Godot 4.2.2 Android export completed. APK was signed and verified, includes `arm64-v8a` and `armeabi-v7a`, and requests **no Android permissions**. Export log reports approximately 41.8 MB.

Artifacts from that exact PR-head run:

- [Kindlewake-APK artifact](https://github.com/ninjun42215-gif/KindleWake/actions/runs/43846527607/artifacts/14215188540) — artifact ID `14215188540`, 41,357,378 bytes, ZIP SHA-256 `b38d49bd70864a5ecd2da88237e2a52773565ed9413794c7152708fcc153757c`.
- [Test logs artifact](https://github.com/ninjun42215-gif/KindleWake/actions/runs/43846527607/artifacts/14215332962) — artifact ID `14215332962`, ZIP SHA-256 `ea5bdd3cd447594e82745937c3c469db86cd65ff5456ecbcaf780adf37a57e80`.
- [Project health audit artifact](https://github.com/ninjun42215-gif/KindleWake/actions/runs/43846527756/artifacts/14215063640) — artifact ID `14215063640`.

### Previous main build

- [Main Build Android APK run #999](https://github.com/ninjun42215-gif/KindleWake/actions/runs/43845632925) passed on prior main SHA `1765c3fdb00cb95ae0a06c6d467231a03bd68648`, before PR #146 was merged.
- Its APK artifact was `14215187300`; do not label it as a build of current main SHA `698765f`.
- [Main source handoff snapshot](https://github.com/ninjun42215-gif/KindleWake/actions/runs/43845632900) also ran on prior SHA `1765c3f`, not current main.
- [Safe Auto Merge run](https://github.com/ninjun42215-gif/KindleWake/actions/runs/43846720641) completed successfully after the PR build.

**Artifact rule:** use the PR #146 APK only as a tested build of `00dd3f2`. The current main tree matches that tested tree, but its merge-commit SHA has not yet received a separate main build or source-handoff snapshot in the observed runs.

## Project-health, assets and combat balance

### Structural audit

The Project Health Audit on PR #146 reported:

- 44 JSON files checked.
- 77 rune definitions found.
- 0 structural errors and 0 warnings.

This is a structural audit only. It does not execute every gameplay path, prove rune effects are balanced, validate third-party licence terms or certify device compatibility.

### Asset provenance

`Kindlewake/data/asset_provenance.json` is updated `2026-11-16`.

- Used Quaternius nature assets: recorded as CC0 with official source evidence.
- Used Zerie free Soldier/Orc subset: official author page and game-use/modification terms recorded; standalone redistribution of the source pack remains prohibited.
- Original settlement, heraldry and 16-archetype character art: recorded as project-authored.
- Legacy voxel building packs, restricted LimeZu interiors and unknown MountainRocks archive are recorded as **not used in game**. The unverified voxel archive is not currently a release blocker because the runtime uses original settlement art instead.

No new third-party assets were introduced by PR #146.

### Balance report

The strict build ran the deterministic AI-vs-AI balance report with 30 battles per scenario. Starting-party win rates were:

| Enemy group | Win rate | Automated verdict |
|---|---:|---|
| Hask Gravelteeth, 2 Roadwolf Reavers, Roadwolf Bowman | 57% | Hard |
| 2 Roadwolf Reavers, Roadwolf Bowman | 100% | Easy |
| Roadwolf Reaver, 2 Roadwolf Bowmen | 80% | Fair |
| 3 Roadwolf Reavers, Roadwolf Bowman | 97% | Easy |
| Hask Gravelteeth, Roadwolf Reaver, Roadwolf Bowman | 100% | Easy |

The 60-battle persistent-party grind simulation recorded 59 wins. These are AI-vs-AI diagnostics, not human playtest results. The first scenario is slightly below the report's 60–90% fair band; three scenarios are classified easy. Keep these as tuning candidates rather than changing boss values without human play evidence.

## Release-workflow defects found and QA candidate fixes

The live workflows had two release-integrity problems:

1. `.github/workflows/build-apk.yml` had a tag-triggered `publish-tag-release` job that created/updated a GitHub Release using the ordinary CI APK. The production workflow separately refuses to overwrite an existing release for the same tag. A `v*` tag push could therefore create a test-signed release first and prevent the protected production workflow from publishing the production-signed APK.
2. `.github/workflows/publish-android-release.yml` populated the release manifest's `commit` field from `${{ github.sha }}`. On `workflow_dispatch`, that value can identify the dispatch ref rather than the tag commit actually checked out and built. This would make the manifest's source SHA unreliable.

The QA candidate branch changes only release workflow and release documentation paths:

- Removes automatic GitHub Release creation from routine/tag candidate builds. Tag builds still upload their APK artifact; only the protected production workflow creates a public release.
- Captures `git rev-parse HEAD` immediately after checking out the requested tag and uses that exact checked-out commit for the release manifest.
- Changes the production workflow's default permission to `contents: read`, grants `contents: write` only to the publish job and gives the rejected-confirmation job no repository permissions.
- Refreshes `ANDROID_RELEASE_WORKFLOW.md` for the current 0.12.0 / Android version-code 1200 configuration, actual workflow names, current default-branch availability and outstanding release gates.

**Candidate paths:** `.github/workflows/build-apk.yml`, `.github/workflows/publish-android-release.yml`, `.github/workflows/workflow-lint.yml`, `Kindlewake/docs/ANDROID_RELEASE_WORKFLOW.md`, and this report. No game runtime code, save schema, campaign content, assets or player data is changed.

The candidate branch is based on `698765fd3b5d3cfbef13e301ebd544b8e93277cc`. The first YAML lint attempts failed because the repository's existing static contract still required the removed `publish-tag-release` job (`Only the tag-release job may use contents: write`). That obsolete assertion was replaced with checks that routine builds cannot publish, the protected publish job alone has write permission, and the release manifest uses the checked-out tag SHA. The updated lint contract is in commit `1e55970e288b5c0c476d378b432b474378f866a4`. Await the new exact-head checks before considering this candidate complete.

## Tags, production publishing and security

- The live repository exposed eight legacy `apk-*` tags and no `v*` tags; the GitHub Releases endpoint returned no releases at audit time.
- `Publish Android Production Release` exists on `main` and is available for manual dispatch. It requires an existing `v*` tag, exact `PUBLISH` confirmation and the `android-production` environment.
- The environment's actual reviewer rules, keystore secrets and `ANDROID_RELEASE_CERT_SHA256` variable were not inspected. Do not infer they are configured.
- Tag-protection rules were not verified. Protect `v*` tags before production use; the workflow's tag-name check alone does not make a tag immutable.
- The ordinary CI APK is a test/sideload build, not a production signing identity. No production release was attempted.
- Actions logs emitted non-blocking Node.js 20 deprecation warnings for current action versions (including checkout/setup-python/cache/upload-artifact). Track a separate pinned-action/toolchain update; do not mix an untested toolchain upgrade into this release fix.
- The repository's custom `Safe Auto Merge` workflow is active. It can merge eligible non-draft PRs after exact-SHA checks. This QA PR is intentionally draft so that the repository automation skips it. Native GitHub Auto-merge is not enabled according to repository metadata.

## Open PR and branch divergence

The 13 pre-existing open PR branches compared as **diverged** from main at `698765f`. Ahead/behind counts below are relative to that main SHA. Newer PRs #147 (visual) and #148 (this QA candidate) are tracked separately below.

| PR | Topic | Ahead | Behind |
|---|---|---:|---:|
| [#130](https://github.com/ninjun42215-gif/KindleWake/pull/130) | Authentication documentation | 2 | 16 |
| [#81](https://github.com/ninjun42215-gif/KindleWake/pull/81) | Regional trading integration | 3 | 45 |
| [#78](https://github.com/ninjun42215-gif/KindleWake/pull/78) | Godot headless test gate | 70 | 59 |
| [#66](https://github.com/ninjun42215-gif/KindleWake/pull/66) | Act I boss balance simulations | 57 | 59 |
| [#63](https://github.com/ninjun42215-gif/KindleWake/pull/63) | Act I boss AI/balance | 57 | 59 |
| [#47](https://github.com/ninjun42215-gif/KindleWake/pull/47) | Full campaign story arc | 19 | 59 |
| [#46](https://github.com/ninjun42215-gif/KindleWake/pull/46) | Empire management | 261 | 60 |
| [#45](https://github.com/ninjun42215-gif/KindleWake/pull/45) | Lore and campaign scenarios | 18 | 59 |
| [#44](https://github.com/ninjun42215-gif/KindleWake/pull/44) | Chronicle founder gate | 4 | 59 |
| [#43](https://github.com/ninjun42215-gif/KindleWake/pull/43) | Base44 game bible | 30 | 59 |
| [#42](https://github.com/ninjun42215-gif/KindleWake/pull/42) | Regional bestiary | 21 | 60 |
| [#23](https://github.com/ninjun42215-gif/KindleWake/pull/23) | Premium narrative/UX/art direction | 6 | 97 |
| [#22](https://github.com/ninjun42215-gif/KindleWake/pull/22) | Premium story/world direction | 1 | 97 |

Do not merge these branches wholesale. In particular, #81 is 45 commits behind and should be selectively ported/re-tested from current main; #78, #66 and #63 contain broad, overlapping older code histories; #46 is substantially divergent. Resolve each feature in a fresh branch from current main and preserve its current data/save contracts.


## Active visual branch blocker found

PR [#147 — Rebuild Thornmere town and give the cast distinct character silhouettes](https://github.com/ninjun42215-gif/KindleWake/pull/147) is a separate, open visual branch at head `960de9e49984a3bc296ecfe84eb1a163f42889bb`. Its Workflow YAML Lint, Project Health Audit and Version Sync checks passed, but its Android build failed during the first Godot import:

- [Build Android APK run](https://github.com/ninjun42215-gif/KindleWake/actions/runs/43848357766) failed with `Cannot return value of type "null" because the function return type is "bool"` at `res://scripts/ui/battle_scene.gd:1259`.
- `_draw_unit_sprite(...)->bool` uses a bare `return` after drawing the player atlas sprite. It must return `true` in that branch; otherwise Godot 4.2.2 rejects the script before the APK can be exported.
- A review comment was posted on PR #147 with the exact line and suggested one-line correction. This QA branch did not modify the visual branch.

Keep PR #147 unmerged until the owner fixes the parse error and reruns the Android build. No APK artifact was produced by the failed run; only the small failure log artifact was uploaded.

## This QA candidate

PR [#148 — QA: protect production release publishing and provenance](https://github.com/ninjun42215-gif/KindleWake/pull/148) is intentionally draft, based on main SHA `698765fd3b5d3cfbef13e301ebd544b8e93277cc`, with current head after the workflow-lint contract update pending verification. The repository's Safe Auto Merge run [43848459491](https://github.com/ninjun42215-gif/KindleWake/actions/runs/43848459491) skipped this draft as intended. No merge is authorized.

## Remaining release gates and next actions

1. Wait for this QA candidate's exact-head Workflow YAML Lint, Project Health Audit, Version Sync and Android build. Inspect failures rather than assuming success.
2. Obtain a fresh build/source snapshot for the exact current main SHA after the repository owner authorizes the merge; the observed main build and handoff artifacts predate PR #146's merge commit.
3. Perform physical Android QA: install/upgrade-in-place, launch, new game, character creation, one-tap option activation, scrolling, Continue, save/load/recovery, dialogue bubbles, NPC movement, tactical movement/attacks/skills, portrait/landscape safe areas, low-memory behaviour and sustained frame pacing. No physical-device result is available in this audit.
4. Verify `android-production` reviewers/secrets and `v*` tag protection in repository settings before using the production workflow.
5. Review AI-vs-AI balance outliers with human playtests before changing boss stats or rewards.
6. Reconcile the stale feature PRs selectively; do not force-push, delete branches or rewrite player/save data.

## Safety record

This QA run did not merge to main, force-push, delete branches, change repository settings, access or expose secret values, publish a release, or claim physical-device testing. The release workflow/documentation changes remain isolated on `qa/release-publish-gate-2026-11-16` for review.
