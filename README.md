# KindleWake — The Sundered Vow

The Godot game project lives in **[`Kindlewake/`](Kindlewake/)**. That folder contains the canonical project, source, assets, tests and current design documentation.

## Start here

- [Game project README](Kindlewake/README.md)
- [Authoritative game design document](Kindlewake/docs/GDD.md)
- [Mobile Release Candidate 1 readiness gates](Kindlewake/docs/MOBILE_RELEASE_CANDIDATE_1_READINESS.md)
- [Android build instructions](Kindlewake/docs/BUILD_APK.md)
- [Android release workflow and signing guidance](Kindlewake/docs/ANDROID_RELEASE_WORKFLOW.md)

The root-level `GDD_Kindlewake.md` is an archived legacy snapshot. Do not use it as the current design specification.

## Current development checkpoint

- App version: **0.12.0** · Android version code: **1200** · save schema: **4** · Godot: **4.2.2**.
- Active portrait audit branch: `feature/complete-portrait-coverage-audit`.
- Reviewed commit: `a5d845164b10de2de2270636c8b13aacea4baee6`.
- Default branch `main` is separate and has not been modified by the portrait-audit work.
- Android CI build, strict tests, APK export and configured emulator install/launch passed on the reviewed commit: [Build run 44011454711](https://github.com/ninjun42215-gif/KindleWake/actions/runs/44011454711).
- The portrait coverage audit remains explicitly incomplete; original individually approved painterly portraits and physical-device QA remain outstanding.

## Branch safety

The portrait-audit branch is currently **diverged** from `main` (61 commits ahead / 5 behind at the reviewed checkpoint). Do not bulk-merge it or force-push it. Reconcile and review the branch against current main, then run all required checks on the exact candidate commit before merging.

## Project constraints

KindleWake is designed as an offline-first RPG. Preserve local saves and schema migrations, avoid adding network permissions or account/server dependencies, retain asset provenance and licensing records, and keep production signing keys out of source control.
