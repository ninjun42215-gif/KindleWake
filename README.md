# KindleWake

KindleWake is an offline-first medieval tactical RPG built with Godot 4.2+ and GDScript, with Android as the current automated build target.

## Repository layout

This repository currently distributes the game source as a project archive:

- `Kindlewake_Project.zip` — primary Godot project archive. The project folder inside is expected to be `Kindlewake/`.
- `GDD_Kindlewake.md` — game design document.
- `CONTINUATION_PROMPT.md` — project continuation and development context.
- `Feature_*.zip` — separately packaged feature/reference bundles. These are not substitutes for the primary project archive.
- `.github/workflows/build-apk.yml` — manually triggered Android APK build and release workflow.

The project archive is the source of truth for the current game implementation until the repository is migrated to a normal, directly browsable Godot project layout. Do not edit or replace the archive without first inspecting its contents and preserving the existing project structure and save compatibility.

## Build an Android APK with GitHub Actions

1. Open the repository's **Actions** tab.
2. Select **Build Android APK**.
3. Choose **Run workflow** on the intended branch.
4. Wait for the preflight and build jobs to finish.
5. Inspect the uploaded `build-logs` artifact if a step fails.
6. If the build succeeds, open the generated GitHub Release and download `Kindlewake.apk`.

The workflow explicitly extracts `Kindlewake_Project.zip`; it does not select an arbitrary ZIP from the repository. The expected extracted project path is `Kindlewake/project.godot`.

## Local validation

After extracting `Kindlewake_Project.zip`, open a terminal in the extracted `Kindlewake/` directory. The project documentation identifies these validation commands:

```bash
godot --headless --path . --import
godot --headless --path . --script res://tests/run_tests.gd
godot --headless --path . --script res://tests/balance_report.gd
python3 -I tools/gd_static_check.py
python tools/build_apk.py --check
```

Run the commands supported by the installed environment. A static check or APK preflight is not a substitute for executing the Godot test suite or reviewing the game on a real Android device.

## Current development focus

The next planned milestone is **v0.9.4 — Stability, Verification & Release Readiness**:

- verify project import and headless tests with the target Godot version;
- exercise save/load and room-resume behavior;
- review recruitment and core UI on mobile aspect ratios and touch input;
- run the Android preflight and full APK build;
- verify asset attribution and licensing;
- ensure production signing credentials are not committed to the repository;
- update the checkpoint and continuation notes with actual test results.

See [the v0.9.4 release-readiness checklist](docs/RELEASE_READINESS_v0.9.4.md).

## Safety and release signing

Do not use a test/debug keystore for a public store release. Production signing material must remain private and should be supplied through protected CI secrets or a secure local build environment. Never commit production keystores, passwords, API tokens, or signing credentials.

## Project status

The repository's project archive and documentation describe the game as v0.9.3. The v0.9.4 work is a verification and release-readiness milestone, not a claim that the game has already passed runtime or device testing. Build and test status must be updated only after the relevant commands have actually completed successfully.
