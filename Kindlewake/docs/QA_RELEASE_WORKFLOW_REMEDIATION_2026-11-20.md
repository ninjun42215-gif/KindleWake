# KindleWake QA — Android release workflow remediation (2026-11-20)

## Scope and exact refs

- Repository: https://github.com/ninjun42215-gif/KindleWake
- Canonical Godot project: `Kindlewake/` (Godot 4.2.2, GL Compatibility, Android)
- Current main base: `13f66ec19476c9af5ed2b5c81af95e4d8a026876`
- Existing QA PR: [#164 — Android emulator smoke and production release provenance](https://github.com/ninjun42215-gif/KindleWake/pull/164)
- QA branch: `qa/android-release-workflow-hardening-2026-11-18`
- Previous branch head before current-main refresh: `8d8ae2c641002f130480e270b834d65b845f1527`
- This refresh is a non-force fast-forward merge commit with current main as the second parent. No main write, PR merge, force-push, branch deletion, or repository-setting change is performed.

## Reproducible release-workflow findings

1. The routine `.github/workflows/build-apk.yml` workflow is triggered by `v*` tags and its legacy `publish-tag-release` job has `contents: write`. That job attaches the ordinary CI/test-signed APK to a GitHub Release, bypassing the separately protected production workflow. This conflicts with the documented candidate-only CI lane.
2. `.github/workflows/publish-android-release.yml` checks out the tag supplied by the manual-dispatch input, but the release manifest previously used `${{ github.sha }}`. On a dispatch launched from the default branch for a different tag, that can identify the dispatch ref rather than the actual checked-out tag commit.
3. The production workflow granted `contents: write` at workflow scope, including the rejected-confirmation job. The write permission is only needed by the protected publish job.
4. The API 35 AOSP ATD + forced SwiftShader path on current main failed after installation and activity launch. The logs report GLES3 shader uniform/resource limits and the Godot process did not remain alive. This is not proof of a physical-device failure. The QA candidate uses the standard Google APIs image, leaves GPU selection to the emulator default, checks the resumed Godot activity and visible title/menu text, and preserves logcat before assertions.

## Changes carried by this QA candidate

- Remove the routine tag-triggered release-publishing job; tag pushes still build and upload candidate artifacts.
- Keep production release publishing in the separate manual workflow with the `android-production` environment.
- Default production workflow permissions to `contents: read`; grant `contents: write` only to the protected `publish` job; give the rejected-confirmation job `contents: none`.
- Capture `git rev-parse HEAD` after checking out the requested tag and write that exact SHA into the release manifest.
- Extend workflow lint to reject routine release publishing, overly broad write permissions, and incorrect manifest source-SHA wiring.
- Use API 35 Google APIs x86_64 for emulator smoke, default GPU selection, resumed-activity checks and screenshot OCR for KINDLEWAKE / NEW GAME / SETTINGS.
- Keep source handoff and historical QA report records; no game content, scenes, save data, schemas, assets, or gameplay systems are changed.

## Verification status

The new current-main refresh triggers fresh GitHub Actions on its exact resulting branch head. Record the exact implementation SHA and run IDs here after the checks finish; do not reuse the 18 November candidate runs as proof for this refreshed head.

Prior evidence (historical only):
- [Previous exact-head Android candidate run #44300234804](https://github.com/ninjun42215-gif/KindleWake/actions/runs/44300234804) passed on old branch head `8d8ae2c641002f130480e270b834d65b845f1527`, based on main `751b2f3f6b1104aa30e107659094ae2e221dbe3d`. It is not current-main verification.
- [Current main Android build #44446304169](https://github.com/ninjun42215-gif/KindleWake/actions/runs/44446304169) failed at the AOSP ATD emulator liveness step, although import, strict tests and APK export completed.
- [Current main workflow lint #44446304180](https://github.com/ninjun42215-gif/KindleWake/actions/runs/44446304180), [Project Health Audit #44446304110](https://github.com/ninjun42215-gif/KindleWake/actions/runs/44446304110), [Version Sync #44446304299](https://github.com/ninjun42215-gif/KindleWake/actions/runs/44446304299), and [Source Handoff #44446304164](https://github.com/ninjun42215-gif/KindleWake/actions/runs/44446304164) passed on exact main `13f66ec19476c9af5ed2b5c81af95e4d8a026876`.

## Release limitations

- No GitHub Releases currently exist in the repository listing.
- Production environment reviewer rules and signing secrets cannot be validated from this read-only audit; do not expose or print secret values.
- The candidate APK is not production-signed or physically device-tested.
- Emulator success is CI evidence only, not device certification.
- Keep PR #164 draft until exact-current-main checks pass and a human reviews the workflow/security diff.
