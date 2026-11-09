# KindleWake — The Sundered Vow

Offline-first medieval tactical RPG built with Godot 4 (GDScript), targeting Android and iOS.

## Project source — archive-free workflow

The one-time import is complete. The extracted `Kindlewake/` directory on `main` is the canonical source, including the reconstructed optional sprite archive. GitHub Actions extracted 129 project files; the static checker passed with 0 errors and 0 warnings, and the Android offline preflight passed.

Routine development is done by editing and committing ordinary files under `Kindlewake/`. **Do not upload or rebuild a master project ZIP.** The old four-part upload instructions are retained only as historical documentation; the temporary upload files are being removed.
## Automatic Android build

After `Kindlewake/` is present, open **Actions → Build Android APK → Run workflow**. The build imports the project, runs the strict headless test suite and balance report, then exports the APK. A test failure blocks the APK. Download the `Kindlewake-APK` artifact and `test-logs` artifact from the completed run.

## Project constraints

- Godot 4.2+, GDScript, GL Compatibility.
- Offline-only game: no account, cloud, multiplayer or server dependency; no INTERNET permission.
- Local JSON data and local save files.
- Optional sprite packs remain unimported pending asset/license review.
- Static checks and APK preflight are not substitutes for running the game in Godot or testing it on a phone.

## Current gameplay checkpoint

Gameplay checkpoint: **v0.8.1**. This update adds six equipment rarity tiers plus Unique grade, expanded gear stock, allocated protagonist starting attributes, staffed-shop access rules, road inventory access, creator scroll improvements and a company-wipe Game Over flow. Godot runtime validation is pending.
