# KindleWake — The Sundered Vow

Offline-first medieval tactical RPG built with Godot 4 (GDScript), targeting Android and iOS.

## Project source and one-time phone import

The canonical source is the extracted `Kindlewake/` directory on `main`. Routine development is done by editing and committing ordinary files in that directory; **do not rebuild or upload a master project ZIP**.

The initial project checkpoint is prepared as four upload shards, each below GitHub's 25 MB browser-upload limit:

- `KindleWake_Project_part1.zip`
- `KindleWake_Project_part2.zip`
- `KindleWake_Project_part3.zip`
- `KindleWake_Project_part4.zip`

From an Android phone, open the [repository upload page](https://github.com/ninjun42215-gif/KindleWake/upload/main), select all four parts, and commit them to `main`. GitHub Actions runs **Extract KindleWake Upload Parts**. The workflow validates and merges the shards, reconstructs the large optional sprite source archive, replaces `Kindlewake/` transactionally, runs the static GDScript checker and Android preflight, and removes the temporary shards (and the legacy master ZIP) in its commit. If it does not start automatically, run it from **Actions → Extract KindleWake Upload Parts → Run workflow**.

See [UPLOAD_PROJECT_FROM_PHONE.md](UPLOAD_PROJECT_FROM_PHONE.md) for step-by-step instructions.

## Automatic Android build

After `Kindlewake/` is present, open **Actions → Build Android APK → Run workflow**. The build imports the project, runs the strict headless test suite and balance report, then exports the APK. A test failure blocks the APK. Download the `Kindlewake-APK` artifact and `test-logs` artifact from the completed run.

## Project constraints

- Godot 4.2+, GDScript, GL Compatibility.
- Offline-only game: no account, cloud, multiplayer or server dependency; no INTERNET permission.
- Local JSON data and local save files.
- Optional sprite packs remain unimported pending asset/license review.
- Static checks and APK preflight are not substitutes for running the game in Godot or testing it on a phone.

## Current gameplay checkpoint

Gameplay remains at **v0.7.9**. The v0.7.10 documentation update changes only the repository delivery workflow; it does not change game code, data, save schema, or project version.
