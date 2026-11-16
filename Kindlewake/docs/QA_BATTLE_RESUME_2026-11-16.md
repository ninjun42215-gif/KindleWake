# QA report — battle resume and Return to Title

**Date:** 2026-11-16  
**Repository:** https://github.com/ninjun42215-gif/KindleWake  
**Project:** `Kindlewake/` · Godot 4.2.2 · GL Compatibility · Android  
**Main base:** `081759f7204bc43ea1acf84b5f4d282d00ceec84`  
**QA implementation commit tested:** `5615b9a5d4c3e8b7a35c1d58049545049f902588`  
**PR:** [#151 — Make in-progress battles resumable from the title screen](https://github.com/ninjun42215-gif/KindleWake/pull/151)  
**PR state:** Draft; no merge performed.

## Reproducible findings

The gameplay Return to Title option added by PR #150 had two persistence gaps:

1. Active-battle autosaves used a battle-only payload. The title screen's Continue and Load Game flows only accepted campaign payloads, so the saved tactical state was not resumable after returning to the title screen.
2. Returning after a completed non-siege battle could discard rewards and world flags because the result path did not always write a campaign save. The return handler also ignored the autosave result and changed scenes even if the write failed.

## Changes on the isolated QA branch

- Active battle autosaves and manual battle saves now use the existing campaign envelope plus an optional `battle_resume` snapshot. The envelope preserves world-region position, region state, factions, companions, chronicle and trade data alongside the tactical state.
- Title-screen Continue changes to **RESUME BATTLE** when the newest valid campaign save contains a tactical snapshot. Continue and Load Game route to `Main.tscn` for that save.
- The battle scene restores the saved battle definition, units and active turn using the existing validated `BattleController.restore()` path. The snapshot is consumed once.
- Legacy top-level battle saves remain readable from the in-battle Load path.
- Autosave now returns its actual success value. Return to Title is cancelled if a required write fails.
- Returning after a completed battle writes a campaign save, preserving awarded rewards and world flags.
- The lifecycle regression redirects all writes to an isolated test directory and restores both autosave slots; it does not overwrite player save data.

No story, combat rules, balance values, assets, permissions or existing campaign fields were removed. The new field is optional; no save version bump was made.

## Exact-head validation

All successful checks below ran on implementation SHA `5615b9a5d4c3e8b7a35c1d58049545049f902588`, the head of PR #151 at the time of validation.

| Check | Result | Run |
|---|---|---|
| Build Android APK | Success | [43855706015](https://github.com/ninjun42215-gif/KindleWake/actions/runs/43855706015) |
| Project Health Audit | Success | [43855705967](https://github.com/ninjun42215-gif/KindleWake/actions/runs/43855705967) |
| Workflow YAML Lint | Success | [43855705821](https://github.com/ninjun42215-gif/KindleWake/actions/runs/43855705821) |
| Synchronize Project Version | Success | [43855705894](https://github.com/ninjun42215-gif/KindleWake/actions/runs/43855705894) |

Build evidence:

- 20 authored scenes loaded; 0 scene-smoke failures.
- Strict regression suite: **994 checks, 0 failures**.
- Campaign save/restore and World startup lifecycle: **0 failures**.
- Merchant UI: **0 failures**.
- Title/creator UI: **0 failures**.
- Act V checks: 0 failures.
- Campaign continuity: 70 checks, 0 failures.
- Chronicle dynasty: 39 checks, 0 failures.
- Chronicle family development: 19 checks, 0 failures.
- New lifecycle assertions passed for active-turn autosave, title campaign-slot discovery, battle restoration, one-time snapshot consumption, completed-battle reward persistence and failed-save cancellation.
- The failure-injection test intentionally makes the isolated save directory a file; SaveSystem emits its expected write error, and the test confirms the scene does not leave the battle on a failed save.
- APK export completed; the APK signature verified, Android permissions requested: **none**. The exported APK contains ARM64 and ARMv7 native libraries. Export log size: approximately 41.8 MB.
- Project Health Audit: 44 JSON files, 87 GDScript files, 20 scenes, 0 structural errors, 0 warnings and 0 unverified assets marked as used.

Artifacts from the exact tested build:

- [Kindlewake APK artifact](https://github.com/ninjun42215-gif/KindleWake/actions/runs/43855706015/artifacts/14220538071) — artifact ID `14220538071`, 41,429,859 bytes.
- [Test/build logs](https://github.com/ninjun42215-gif/KindleWake/actions/runs/43855706015/artifacts/14220168158) — artifact ID `14220168158`.
- [Project health audit report](https://github.com/ninjun42215-gif/KindleWake/actions/runs/43855705967/artifacts/14219903500) — artifact ID `14219903500`.

**Artifact provenance:** the APK above was produced by Build Android APK run `43855706015`, whose `head_sha` is exactly `5615b9a5d4c3e8b7a35c1d58049545049f902588`. It is a QA candidate artifact, not a production release and not an APK built from the main ref alone.

## Balance and runtime observations

The existing deterministic balance report still classifies one Act I scenario as hard (57% AI-vs-AI starting-party win rate), three scenarios as easy (80%, 97% and 100%), and one at 100%. The 60-battle persistent-party simulation recorded 59 wins. These are automated diagnostics, not human playtest results; no balance changes were made in this save-integrity PR.

## Related repository/release risks

- Main remains at `081759f7204bc43ea1acf84b5f4d282d00ceec84` during this QA work. Main has no Build Android APK run for that merge commit; the PR #151 build above validates the current main base plus this QA change.
- The separate release-workflow candidate PR #148 is still draft and stale: its base is `698765fd3b5d3cfbef13e301ebd544b8e93277cc`, while current main has advanced to `081759f`; compare reports it 11 commits ahead / 3 behind and conflicted. Do not merge it as-is.
- Current main still has a tag-triggered routine build job that can create a GitHub Release with the CI candidate APK. There are eight legacy `apk-*` tags, no `v*` tags and no GitHub Releases at this check. Avoid pushing a `v*` tag until the release-publishing safeguards are refreshed and reviewed.
- The production workflow's `android-production` environment settings, reviewer protections, secret presence and tag rules were not inspected. No production release was attempted.
- GitHub Actions emitted non-blocking Node.js 20 deprecation warnings for current action versions; schedule a separate pinned-action maintenance change.
- No physical Android device QA was performed for install, launch, touch, suspend/resume or performance. CI success is not device QA.

## Next actions

1. Review PR #151 as a draft and re-run exact-head checks after any code changes. Do not merge automatically.
2. Refresh the release-publish safeguards from PR #148 onto a new branch based on current main; do not merge its stale branch.
3. Perform physical Android install/launch, battle resume, campaign Continue, save/load and suspend/resume checks on representative devices.
4. Revisit the easy/hard encounter scenarios only after human playtesting.
