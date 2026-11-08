# KindleWake v0.9.4 — Stability, Verification & Release Readiness

**Working branch:** `kindlewake/v0.9.4-stability`  
**Baseline:** repository default branch `main`  
**Project version described by the supplied archive:** v0.9.3  
**Milestone goal:** verify the existing game and release pipeline without removing features or changing save behavior unnecessarily.

## Repository audit findings

- The repository stores the primary Godot project in `Kindlewake_Project.zip`; the Godot source tree is not currently expanded at repository root.
- Several other ZIP files are feature/reference packages. Build automation must never choose an arbitrary ZIP as the game project.
- The root README was effectively empty.
- The Android workflow is manually dispatched and publishes the APK as a GitHub Release.
- The supplied project notes identify missing Godot runtime/headless verification and missing real-device visual review.
- The project notes identify save/room-resume behavior and asset licensing as areas requiring verification.
- A test signing key is described in the supplied project notes. It must not be treated as a production release key.

## Changes made on this branch

- [x] Create an isolated v0.9.4 working branch; leave `main` unchanged.
- [x] Make the Android workflow select the exact primary archive, `Kindlewake_Project.zip`, rather than the first ZIP returned by filesystem traversal.
- [x] Add a check that the extracted Godot project contains `Kindlewake/project.godot`.
- [x] Replace the minimal root README with repository layout, build instructions, validation commands, milestone scope, and signing guidance.
- [ ] Run GitHub Actions preflight and full APK build.
- [ ] Run Godot import and headless test suite.
- [ ] Verify save/load and room resume, including compatibility with existing saves.
- [ ] Review mobile UI, touch targets, and screen scaling on Android hardware.
- [ ] Audit all shipped assets and record license/attribution evidence.
- [ ] Confirm test signing material is not used for production distribution.
- [ ] Update project WIP/checkpoint and continuation prompt with measured results.
- [ ] Open a pull request for review; merge only after checks pass.

## Required validation

Run these commands from the extracted `Kindlewake/` project directory, where the corresponding tools are available:

```bash
godot --headless --path . --import
godot --headless --path . --script res://tests/run_tests.gd
godot --headless --path . --script res://tests/balance_report.gd
python3 -I tools/gd_static_check.py
python tools/build_apk.py --check
python tools/build_apk.py
```

Record the exact Godot version, command, exit status, and relevant log/artifact for each run. Do not mark a check complete based only on source inspection.

## Release gates

A v0.9.4 release candidate is not ready until:

1. The project imports cleanly in the target Godot version.
2. Automated tests pass, or any known failures are explicitly documented and accepted.
3. Existing save data loads without destructive migration.
4. Core gameplay, recruitment, room transitions, and room resume have been exercised.
5. An APK is built successfully and installed/launched on a physical Android device.
6. Asset licenses and attributions are documented.
7. Production signing credentials are stored outside the repository and are not reused from a test key.
8. The final changes are reviewed in a pull request before merging to `main`.

## Change-control rules

- Preserve existing features and save compatibility.
- Prefer small, reviewable patches over broad rewrites.
- Do not delete or replace project archives until a complete, verified source migration exists.
- Keep test results factual; distinguish static inspection, headless tests, CI builds, and physical-device checks.
- Keep this checklist and the project handoff notes synchronized as work progresses.
