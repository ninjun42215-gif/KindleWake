# QA and Android release-readiness report — 2026-11-16

**Repository:** https://github.com/ninjun42215-gif/KindleWake  
**Canonical project:** `Kindlewake/` · Godot 4.2.2 · GL Compatibility · Android  
**Latest main at report update:** `a72ca6b1962733c1ef596699f42f391157991df5`  
**QA candidate branch:** `qa/release-publish-gate-2026-11-16`  
**Candidate base:** `698765fd3b5d3cfbef13e301ebd544b8e93277cc`  
**Last fully validated candidate head:** `a64cd4df28c5bf7c92a936e24bc54cd4c7dd6477` (later report/guide-only commits are checked again on the live PR head)

This is a dated evidence snapshot. Re-check live refs and Actions before relying on it for a later release.

## Executive result

- The latest visual work, PR [#146](https://github.com/ninjun42215-gif/KindleWake/pull/146), is merged to main. It adds idle breathing, walking bob/stride, periodic eye blinks, talking-mouth animation, NPC speech bubbles and named enemy movement/attack/skill effects. It uses the original project-authored 16-archetype atlas and introduces no external asset dependency.
- PR #146 passed its Android build, project-health audit, workflow YAML lint and version-sync checks on exact PR head `00dd3f2adb826df173767a663e34278874bc5e73`.
- Main advanced to merge commit `a72ca6b1962733c1ef596699f42f391157991df5` after PR #147. Its Git tree is identical to PR #147's tested head `c0855f11f9e62ddacd1de6be80b2c11b8958eb24`; the PR-head APK therefore contains the same source tree, but its recorded build SHA remains the PR head, not the merge commit. No separate main push build was observed for `a72ca6b`.
- The repository's existing `Safe Auto Merge` workflow merged PRs #146 and #147 after their exact-head builds. This QA run did not merge, modify main, force-push, delete branches or change repository settings.
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

### Main and visual merge verification

- [Main Build Android APK run #999](https://github.com/ninjun42215-gif/KindleWake/actions/runs/43845632925) passed on prior main SHA `1765c3fdb00cb95ae0a06c6d467231a03bd68648`, before PR #146.
- Its APK artifact was `14215187300`; do not label it as a build of current main.
- [Main source handoff snapshot](https://github.com/ninjun42215-gif/KindleWake/actions/runs/43845632900) also ran on prior SHA `1765c3f`, not current main.
- PR #147's [Android build run #1006](https://github.com/ninjun42215-gif/KindleWake/actions/runs/43848734406) passed on exact head `c0855f11f9e62ddacd1de6be80b2c11b8958eb24`: 20 scenes loaded, 989 strict checks / 0 failures, 70 continuity checks, 39 dynasty checks and 19 family-development checks, all with 0 failures. Its APK artifact is [14216682073](https://github.com/ninjun42215-gif/KindleWake/actions/runs/43848734406/artifacts/14216682073), ZIP SHA-256 `b75f70181a0821102e80d0e87416ec5e28d50f5433420e09467e2765e935ab2f`.
- PR #147 was merged as `a72ca6b`; the current main Git tree matches that tested PR head. The merge commit itself has not received a separate main build or source-handoff snapshot.
- [Safe Auto Merge run #43846720641](https://github.com/ninjun42215-gif/KindleWake/actions/runs/43846720641) merged PR #146; subsequent Safe Auto Merge runs completed for PR #147.

**Artifact rule:** PR #146's APK is tested against `00dd3f2`; PR #147's APK is tested against `c0855f1`. Current main `a72ca6b` has the same Git tree as `c0855f1`, but neither artifact should be relabeled as a build whose source SHA is the main merge commit.

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

The live workflows on main `a72ca6b` still have two release-integrity problems until PR #148 is reviewed and merged:

1. `.github/workflows/build-apk.yml` had a tag-triggered `publish-tag-release` job that created/updated a GitHub Release using the ordinary CI APK. The production workflow separately refuses to overwrite an existing release for the same tag. A `v*` tag push could therefore create a test-signed release first and prevent the protected production workflow from publishing the production-signed APK.
2. `.github/workflows/publish-android-release.yml` populated the release manifest's `commit` field from `${{ github.sha }}`. On `workflow_dispatch`, that value can identify the dispatch ref rather than the tag commit actually checked out and built. This would make the manifest's source SHA unreliable.

The QA candidate branch changes only release workflow and release documentation paths:

- Removes automatic GitHub Release creation from routine/tag candidate builds. Tag builds still upload their APK artifact; only the protected production workflow creates a public release.
- Captures `git rev-parse HEAD` immediately after checking out the requested tag and uses that exact checked-out commit for the release manifest.
- Changes the production workflow's default permission to `contents: read`, grants `contents: write` only to the publish job and gives the rejected-confirmation job no repository permissions.
- Refreshes `ANDROID_RELEASE_WORKFLOW.md` for the current 0.12.0 / Android version-code 1200 configuration, actual workflow names, current default-branch availability and outstanding release gates.

**Candidate paths:** `.github/workflows/build-apk.yml`, `.github/workflows/publish-android-release.yml`, `.github/workflows/workflow-lint.yml`, `Kindlewake/docs/ANDROID_RELEASE_WORKFLOW.md`, and this report. No game runtime code, save schema, campaign content, assets or player data is changed.

The candidate branch is based on `698765fd3b5d3cfbef13e301ebd544b8e93277cc`, 7 commits ahead and 1 behind current main. The first YAML lint attempts failed because the repository's existing static contract still required the removed `publish-tag-release` job (`Only the tag-release job may use contents: write`). That obsolete assertion was replaced with checks that routine builds cannot publish, the protected publish job alone has write permission, and the release manifest uses the checked-out tag SHA. The updated lint contract is in commit `1e55970e288b5c0c476d378b432b474378f866a4`; all exact-head checks subsequently passed on `a64cd4d`.

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

| PR | Topic | Target base | Ahead vs main | Behind vs main |
|---|---|---|---:|---:|
| [#130](https://github.com/ninjun42215-gif/KindleWake/pull/130) | Authentication documentation | main | 2 | 17 |
| [#81](https://github.com/ninjun42215-gif/KindleWake/pull/81) | Regional trading integration | main | 3 | 46 |
| [#78](https://github.com/ninjun42215-gif/KindleWake/pull/78) | Godot headless test gate | #66 branch | 70 | 60 |
| [#66](https://github.com/ninjun42215-gif/KindleWake/pull/66) | Act I boss balance simulations | tactical-AI branch | 57 | 60 |
| [#63](https://github.com/ninjun42215-gif/KindleWake/pull/63) | Act I boss AI/balance | tactical-AI branch | 57 | 60 |
| [#47](https://github.com/ninjun42215-gif/KindleWake/pull/47) | Full campaign story arc | #45 branch | 19 | 60 |
| [#46](https://github.com/ninjun42215-gif/KindleWake/pull/46) | Empire management | main | 261 | 61 |
| [#45](https://github.com/ninjun42215-gif/KindleWake/pull/45) | Lore and campaign scenarios | #43 branch | 18 | 60 |
| [#44](https://github.com/ninjun42215-gif/KindleWake/pull/44) | Chronicle founder gate | main | 4 | 60 |
| [#43](https://github.com/ninjun42215-gif/KindleWake/pull/43) | Base44 game bible | main | 30 | 60 |
| [#42](https://github.com/ninjun42215-gif/KindleWake/pull/42) | Regional bestiary | main | 21 | 61 |
| [#23](https://github.com/ninjun42215-gif/KindleWake/pull/23) | Premium narrative/UX/art direction | main | 6 | 98 |
| [#22](https://github.com/ninjun42215-gif/KindleWake/pull/22) | Premium story/world direction | main | 1 | 98 |

Stack relationships verified against their actual target branches: #78 is 13 commits ahead of #66 with no base divergence; #66 and #63 are each 3 commits ahead of `feature/act-one-boss-tactical-ai`; #47 is 1 commit ahead of #45; #45 is 5 ahead and 17 behind #43. The #66/#63/#78 and #43/#45/#47 chains are stacked PRs, not independent main-ready changes. Do not merge these branches wholesale. In particular, #81 is 46 commits behind main and should be selectively ported/re-tested; #46 is 261 commits ahead and 61 behind. Resolve each feature in a fresh branch from current main and preserve its current data/save contracts.


## Visual branch blocker discovered and resolved

PR [#147 — Rebuild Thornmere town and give the cast distinct character silhouettes](https://github.com/ninjun42215-gif/KindleWake/pull/147) initially failed on head `960de9e49984a3bc296ecfe84eb1a163f42889bb` because `_draw_unit_sprite(...)->bool` used a bare `return` at `Kindlewake/scripts/ui/battle_scene.gd:1259`. Godot 4.2.2 correctly rejected returning null from a bool function. A line-level review comment identified the one-line fix: return `true` after the player atlas sprite is drawn.

The visual branch owner corrected it in head `c0855f11f9e62ddacd1de6be80b2c11b8958eb24`. Its [Android build](https://github.com/ninjun42215-gif/KindleWake/actions/runs/43848734406), [health audit](https://github.com/ninjun42215-gif/KindleWake/actions/runs/43848734456), [YAML lint](https://github.com/ninjun42215-gif/KindleWake/actions/runs/43848734360) and [version sync](https://github.com/ninjun42215-gif/KindleWake/actions/runs/43848734375) passed. It was then merged as main commit `a72ca6b1962733c1ef596699f42f391157991df5`. The merged tree is identical to the tested PR head. No changes from this QA branch were applied to the visual branch.

## This QA candidate

PR [#148 — QA: protect production release publishing and provenance](https://github.com/ninjun42215-gif/KindleWake/pull/148) remains intentionally draft. It is based on main SHA `698765fd3b5d3cfbef13e301ebd544b8e93277cc`, is 1 commit behind current main `a72ca6b`, and is mergeable without conflicts. Its latest complete code/workflow validation passed on `a64cd4df28c5bf7c92a936e24bc54cd4c7dd6477`: [Android build](https://github.com/ninjun42215-gif/KindleWake/actions/runs/43848987986), [health audit](https://github.com/ninjun42215-gif/KindleWake/actions/runs/43848988084), [YAML lint](https://github.com/ninjun42215-gif/KindleWake/actions/runs/43848987901) and [version sync](https://github.com/ninjun42215-gif/KindleWake/actions/runs/43848987997). The APK artifact is [14216477641](https://github.com/ninjun42215-gif/KindleWake/actions/runs/43848987986/artifacts/14216477641), ZIP SHA-256 `6b58e9de3ba74743232d777278a356da28990fc660c62017da654f9e41e002b2`. Two later commits only refresh handoff/release documentation after PR #147 merged; CI is rerun against the live PR head. Safe Auto Merge skipped the draft as intended. No merge is authorized.

## Remaining release gates and next actions

1. Keep PR #148 draft until its changes are reviewed. Its exact-head YAML lint, Project Health Audit, Version Sync and Android build passed on `a64cd4d`; the branch is one main commit behind but conflict-free.
2. Obtain a fresh build/source snapshot for exact current main SHA `a72ca6b`; the observed PR #147 build is from identical tree `c0855f1`, but no main-commit build or handoff artifact exists yet.
3. Perform physical Android QA: install/upgrade-in-place, launch, new game, character creation, one-tap option activation, scrolling, Continue, save/load/recovery, dialogue bubbles, NPC movement, tactical movement/attacks/skills, portrait/landscape safe areas, low-memory behaviour and sustained frame pacing. No physical-device result is available in this audit.
4. Verify `android-production` reviewers/secrets and `v*` tag protection in repository settings before using the production workflow.
5. Review AI-vs-AI balance outliers with human playtests before changing boss stats or rewards.
6. Reconcile the stale feature PRs selectively; do not force-push, delete branches or rewrite player/save data.

## Safety record

This QA run did not merge to main, force-push, delete branches, change repository settings, access or expose secret values, publish a release, or claim physical-device testing. The release workflow/documentation changes remain isolated on `qa/release-publish-gate-2026-11-16` for review.
