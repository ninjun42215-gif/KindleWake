# KindleWake — The Sundered Vow

Offline-first medieval tactical RPG built with Godot 4 (GDScript), targeting Android and iOS.

## Repository layout

- `Kindlewake/` — extracted Godot source tree (created by the archive extraction workflow).
- `Kindlewake_Project.zip` — source checkpoint archive uploaded by the maintainer.
- `.github/workflows/extract-project-archive.yml` — validates, safely extracts and commits the archive.
- `.github/workflows/build-apk.yml` — builds the Android APK from `Kindlewake/`.

## Updating the source checkpoint

1. Replace the root `Kindlewake_Project.zip` with the latest project archive. The archive must contain a top-level `Kindlewake/` directory and `Kindlewake/project.godot`.
2. Commit and push the archive to the repository's `main` branch.
3. Open **Actions → Extract Godot Project into Repository → Run workflow** on `main`.
4. The workflow extracts into a staging directory, rejects unsafe paths/symlinks, replaces the previous source tree only after archive validation, runs the static GDScript checker and Android offline preflight, then commits the extracted source.
5. Review the extraction run logs before building.

The archive is the source of truth for each checkpoint. Do not manually edit the extracted `Kindlewake/` tree and then overwrite it with an older archive.

## Build Android APK

After a successful extraction, open **Actions → Build Android APK → Run workflow**. Download the `Kindlewake-APK` artifact and `test-logs` artifact from the completed run.

The build workflow checks that `Kindlewake/project.godot` and `Kindlewake/tools/build_apk.py` exist before starting. It runs the builder from inside the Godot project directory.

## Project constraints

- Godot 4.2+, GDScript, GL Compatibility.
- Offline-only game: no account, cloud, multiplayer or server dependency; no INTERNET permission.
- Local JSON data and local save files.
- The source archive contains optional sprite packs; they remain unimported pending asset/license review.
- Runtime status must be reported honestly. Static checks and APK preflight are not substitutes for running the game in Godot or testing it on a phone.

## Current source checkpoint

The latest verified Library checkpoint supplied for this work is v0.7.8 (2026-11-09). The repository's currently committed root archive is older than that Library archive; replace it with the v0.7.8 archive before running extraction. The current v0.7.8 source passed:

- `python3 -I tools/gd_static_check.py` — 0 errors, 0 warnings.
- `python3 tools/build_apk.py --check` — offline preflight passed.

Godot import, headless GDScript tests, balance report, scene rendering and phone playthrough were not run because no Godot executable was available.
