# KindleWake: The Sundered Vow

Offline-first medieval tactical RPG built with **Godot 4.2.2**, GDScript and the GL Compatibility renderer. Android is the current build target; the project is designed for mobile landscape play.

## Current checkpoint

- App version: **0.12.0**
- Android version code: **1200**
- Save schema: **4**
- Level cap: **250**
- Canonical project directory: this `Kindlewake/` folder
- Active working branch: `feature/complete-portrait-coverage-audit`
- Reviewed branch commit: `a5d845164b10de2de2270636c8b13aacea4baee6`
- Default branch `main` was not changed by this feature work.

## Latest verified CI

The following checks passed on the exact reviewed commit:

- Godot project import and headless scene smoke tests
- Strict automated tests and balance report
- Android APK export and artifact upload
- Install and launch in the configured Android emulator
- Portrait registry structural audit
- Project Health Audit, workflow YAML lint and source handoff

See [Android build run 44011454711](https://github.com/ninjun42215-gif/KindleWake/actions/runs/44011454711). Emulator success is not physical-device QA and does not prove a complete campaign playthrough.

## Release status

**Development build only — not approved for public/store release.** The required work and explicit exit criteria are tracked in [Mobile Release Candidate 1 Readiness](docs/MOBILE_RELEASE_CANDIDATE_1_READINESS.md).

Known release gates include:

1. Physical Android testing on the actual target phone, especially New Game → Choose Your Lead → character creation, touch/scroll/keyboard, save/load, resume and long-session stability.
2. Original, individually art-directed and reviewed portrait coverage. The current audit tracks 208 character/NPC/royal records; the existing 12 legacy SVGs are not the requested final painterly art.
3. End-to-end campaign, seven-continent atlas accuracy, current playable travel (Eldrimar/Sethmarch and Thalassar/Brinegate), recruitment, combat, progression and economy acceptance against [the current GDD](docs/GDD.md).
4. Save migration/recovery testing for all supported schema versions.
5. Branch reconciliation, exact-SHA CI, production signing and distribution setup.
6. Asset provenance, permissions, privacy and performance review.

## Source-of-truth

- [Current game design document](docs/GDD.md)
- [Mobile RC1 readiness gates](docs/MOBILE_RELEASE_CANDIDATE_1_READINESS.md)
- [Android APK build instructions](docs/BUILD_APK.md)
- [Android release and signing workflow](docs/ANDROID_RELEASE_WORKFLOW.md)
- [Session handoff](docs/SESSION_HANDOFF.md)
- [Next AI start guide](docs/NEXT_AI_START_HERE.md)

The root-level `GDD_Kindlewake.md` is an archived v0.7.11 snapshot, not the current GDD.

## Build an APK

1. Open GitHub Actions in the repository.
2. Select **Build Android APK**.
3. Run the workflow on the intended feature branch or reviewed commit.
4. Wait for project import, strict tests, balance report, APK export and emulator validation.
5. Download the `Kindlewake-APK` artifact. Keep its source SHA and workflow run with the APK.

The CI APK uses the test/sideload signing identity. It is not a production-signed store release. Production publishing requires a separately protected private keystore and the release workflow.

## Non-negotiable project constraints

- Offline-first: no accounts, servers, multiplayer or Android INTERNET permission.
- Preserve local campaign saves and backward-compatible migrations.
- Keep secrets, keystores and private signing material out of Git and chat.
- Keep third-party asset provenance and required attribution accurate.
- Never call the project release-ready based on CI alone; physical-device QA is mandatory.
