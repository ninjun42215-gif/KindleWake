# KindleWake — The Sundered Vow

Offline-first medieval tactical RPG built with Godot 4 (GDScript), targeting Android and iOS.

## Repository layout

- `Kindlewake/` — extracted Godot source tree, automatically refreshed from the source archive.
- `Kindlewake_Project.zip` — authoritative source checkpoint archive.
- `.github/workflows/extract-project-archive.yml` — automatically validates, replaces and commits the extracted project whenever the root archive changes.
- `.github/workflows/build-apk.yml` — builds the Android APK from `Kindlewake/`.

## Automatic source synchronization

The root `Kindlewake_Project.zip` is the single source of truth.

Whenever a new version of that ZIP is committed to the `main` branch, GitHub Actions automatically:

1. Validates the ZIP structure and rejects unsafe paths and symbolic links.
2. Extracts into a temporary staging directory.
3. Verifies `Kindlewake/project.godot` and the static checker exist.
4. Replaces the existing `Kindlewake/` directory with the new extracted project.
5. Runs the static GDScript checker and Android offline build preflight.
6. Commits the refreshed `Kindlewake/` directory back to the same branch.

The workflow only triggers when `Kindlewake_Project.zip` changes, so its own source-tree commit does not trigger another extraction run. It can also be started manually from **Actions → Extract Godot Project into Repository → Run workflow**.

**Important:** To publish a new checkpoint, replace the repository-root `Kindlewake_Project.zip` with the new complete archive and commit that replacement. The automation cannot synchronize a ZIP that exists only in a local ChatGPT workspace; the archive must first be committed to GitHub. The extraction workflow will then replace the source tree automatically.

Do not manually edit the extracted `Kindlewake/` tree as the source of truth. Make changes in the authoritative project checkpoint, package it as the root ZIP, and publish the ZIP update.

## Build Android APK

After a successful source synchronization, open **Actions → Build Android APK → Run workflow**. Download the `Kindlewake-APK` artifact and `test-logs` artifact from the completed run.

The build workflow checks that `Kindlewake/project.godot` and `Kindlewake/tools/build_apk.py` exist before starting. It runs the builder from inside the Godot project directory.

## Project constraints

- Godot 4.2+, GDScript, GL Compatibility.
- Offline-only game: no account, cloud, multiplayer or server dependency; no INTERNET permission.
- Local JSON data and local save files.
- Optional sprite packs remain unimported pending asset/license review.
- Static checks and APK preflight are not substitutes for running the game in Godot or testing it on a phone.

## Current working checkpoint

The latest local working checkpoint is **v0.7.9**. The weapon-preference starting-equipment update has been prepared and locally validated. The ZIP still needs to be committed to the repository root before GitHub's automatic synchronization can extract it into `Kindlewake/`.
