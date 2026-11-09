# Kindlewake versioning and automatic synchronization

## One source of truth

The Godot application version in `Kindlewake/project.godot` is authoritative:

```ini
[application]
config/version="MAJOR.MINOR.PATCH"
```

Do not independently edit the version in the README or Android export preset. The synchronization tool updates:

- The version in the first Kindlewake README heading.
- Android `version/name` in `Kindlewake/export_presets.cfg`.
- Android `version/code` in the same export preset.
- `GAME_VERSION` in `scripts/core/save_system.gd` save metadata. This does not change `SAVE_VERSION` or the payload migration schema.

## Android version-code mapping

The integer code is derived deterministically:

```text
version_code = MAJOR * 10000 + MINOR * 100 + PATCH
```

Minor and patch components must each be between 0 and 99. The derived value must be between 1 and Android's maximum supported version code (2,100,000,000). This makes 0.9.0 map to 900 and 0.10.0 map to 1000. Increase the semantic version in project.godot for every Android build intended to replace an earlier build.

## Automatic behavior

`.github/workflows/version-sync.yml` provides two safeguards:

1. **Pull request targeting main:** a read-only job checks out the proposed branch, runs that branch's synchronizer unit tests, and fails if README, Android export or SaveSystem game-version metadata does not match project.godot. It cannot write to the repository.
2. **Push to main:** a separate write-enabled job tests and applies the synchronizer on main, then commits only README/export/save-version metadata if a correction is needed. This also runs after a pull request is merged into main.

This split validates proposed synchronizer changes without granting untrusted pull-request code write permission. The payload schema constant `SAVE_VERSION` remains independent from `GAME_VERSION` metadata.

## Manual use

From the repository root:

```bash
python Kindlewake/tools/sync_version.py --check
python Kindlewake/tools/sync_version.py --apply
python Kindlewake/tests/test_sync_version.py
```

- `--check` is read-only and returns non-zero on drift.
- `--apply` updates the README first-heading version, Android export version fields and SaveSystem's `GAME_VERSION` metadata constant.
- The operation is idempotent: repeating it without changing project.godot produces no further edits.

## Branch and release safety

This automation synchronizes version metadata only. It does **not** merge branches, copy feature code into main, publish an APK/release, change signing keys, or alter save data. A feature branch can legitimately have a newer version than main until its pull request is reviewed and merged. The push-to-main workflow then synchronizes main's metadata to the version actually present in the merged main tree.

Current main is `0.10.0` (Android code `1000`). `project.godot` remains the sole version source; the synchronizer keeps README, Android export metadata and SaveSystem's displayed save-version metadata aligned. `SAVE_VERSION` is a separate data-schema version and must only change with a tested migration.
