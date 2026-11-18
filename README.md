> **AUTHORITATIVE LIVE CHECKPOINT — 2026-11-18 07:24 UTC:** Canonical repository `ninjun42215-gif/KindleWake`; project directory `Kindlewake/`; default branch `main`; current main commit `751b2f3f6b1104aa30e107659094ae2e221dbe3d`. Godot 4.2.2, GL Compatibility, game/Android version `0.12.0 / 1200`, save schema `4`, level cap `250`; offline-first.

> **Mainline QA:** [Build Android APK #44225653213](https://github.com/ninjun42215-gif/KindleWake/actions/runs/44225653213) on this exact SHA completed import, 20/20 scene smoke, 1,009 strict checks / 0 failures, lifecycle, merchant, title/creator, Act V, continuity, dynasty, family and balance tests, and exported a signed 65,848,438-byte APK (SHA-256 `046d7cd0006b4cdfdb1c6937e586b392879444a62a12d9ae01e01bd18b069c2f`; no Android permissions). **The overall workflow failed at the AOSP ATD / SwiftShader emulator smoke stage**: the app activity exited and the screenshot was black. Do not call this a fully passing Android build or release-ready. Project Health Audit [#44225653218](https://github.com/ninjun42215-gif/KindleWake/actions/runs/44225653218), YAML Lint [#44225653214](https://github.com/ninjun42215-gif/KindleWake/actions/runs/44225653214), Version Sync [#44225653230](https://github.com/ninjun42215-gif/KindleWake/actions/runs/44225653230) and source handoff [#44225653270](https://github.com/ninjun42215-gif/KindleWake/actions/runs/44225653270) passed on the same SHA.

> **Exact artifacts:** APK [14393186073](https://github.com/ninjun42215-gif/KindleWake/actions/runs/44225653213/artifacts/14393186073). Source handoff [14392014166](https://github.com/ninjun42215-gif/KindleWake/actions/runs/44225653270/artifacts/14392014166) contains 369 tracked files in three parts; reassembly and all hashes passed (archive SHA-256 `84918cec1bdc1fb7cf8855e87ff9b0c40420cb2ade6ece91ce7eb06dc815ed5e`).

> **Open QA/release candidates:** [PR #159](https://github.com/ninjun42215-gif/KindleWake/pull/159) has a successful emulator screenshot/OCR run on its older head using google_apis + ANGLE, but is 18 ahead / 4 behind main and must be rebased/retested. [PR #160](https://github.com/ninjun42215-gif/KindleWake/pull/160) adds malformed empire-state validation; its strict tests pass but its build hits the same emulator failure. [PR #161](https://github.com/ninjun42215-gif/KindleWake/pull/161) adds character-aware companion portraits; [PR #162](https://github.com/ninjun42215-gif/KindleWake/pull/162) is stacked on it and still needs Android/project-audit checks. [PR #152](https://github.com/ninjun42215-gif/KindleWake/pull/152) contains the release-permission/provenance fix but is 4 ahead / 93 behind and needs rebase. [PR #81](https://github.com/ninjun42215-gif/KindleWake/pull/81) remains too stale for direct integration.

> **Release gates:** Current main still has a tag-triggered auto-publish job and a production workflow with workflow-wide `contents: write`; PR #152 proposes least-privilege separation. The provenance ledger has no unverified runtime-used assets. There are zero published releases. Physical Android device QA remains outstanding. Full findings and exact evidence: [QA release-readiness report](Kindlewake/docs/QA_RELEASE_READINESS_2026-11-18.md).

---
---










# KindleWake — The Sundered Vow

Offline-first medieval tactical RPG built with Godot 4.2.2 (GDScript, GL Compatibility), targeting Android and iOS.

## Live project checkpoint

- Canonical source: tracked files under `Kindlewake/` in `ninjun42215-gif/KindleWake`.
- Current `main`: `751b2f3f6b1104aa30e107659094ae2e221dbe3d`; game/Android version `0.12.0 / 1200`; save schema `4`.
- Current exact-main CI, artifact hashes, branch divergence, release-workflow risks and physical-device gates are recorded in [the 18 November QA release-readiness report](Kindlewake/docs/QA_RELEASE_READINESS_2026-11-18.md).
- No mainline merge or physical Android device certification is claimed.

## Routine development

Edit ordinary tracked files under `Kindlewake/`; do not upload or rebuild a master project ZIP. Use a short-lived feature/workflow branch and pull request. The exact-SHA safe auto-merge gate requires the four core checks and every additional PR-triggered workflow discovered for that SHA to pass.

## Build an Android APK

Open **Actions → Build Android APK → Run workflow**. The workflow imports the Godot project, runs the strict headless tests and balance report, exports and verifies the signed APK, then uploads `Kindlewake-APK` and `test-logs` artifacts.

## Product constraints and release gates

- Fully offline: no accounts, servers, multiplayer or INTERNET permission.
- Local JSON data and local saves; preserve save migrations and schema compatibility.
- Optional sprite packs remain source-only pending licence and suitability review.
- Physical Android QA remains outstanding. CI is not proof of fit on a real phone.
- Public/commercial release remains blocked until the voxel-building pack's redistribution licence is verified or those assets are replaced.
- GDD notes 0.10.1–0.10.4 record implementation changes; the released project version remains 0.10.0.

See `Kindlewake/docs/SESSION_HANDOFF.md` and `Kindlewake/docs/NEXT_AI_START_HERE.md` before continuing work.
