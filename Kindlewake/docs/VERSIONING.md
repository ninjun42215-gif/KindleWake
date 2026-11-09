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

## Android version-code mapping

The integer code is derived deterministically:

```text
version_code = MAJOR * 10000 + MINOR * 100 + PATCH
```

Minor and patch components must each be between 0 and 99. The derived value must be between 1 and Android's maximum supported version code (2,100,000,000). This makes 0.9.0 map to 900 and 0.10.0 map to 1000. Increase the semantic version in project.godot for every Android build intended to replace an earlier build.

## Automatic behavior

`.github/workflows/version-sync.yml` provides two safeguards:

1. **Push to main:** the workflow applies the metadata synchronization and commits only README/export metadata when a correction is needed. This also runs after a pull request is merged into main.
2. **Pull request targeting main:** the workflow checks the proposed project tree and fails if README or Android export metadata does not match project.godot. It does not rewrite the contributor's branch.

The workflow checks out the trusted synchronizer from main for PR validation, so older feature branches do not need to carry the tool before the guard can run. The version tool's unit tests execute on both paths.

## Manual use

From the repository root:

```bash
python Kindlewake/tools/sync_version.py --check
python Kindlewake/tools/sync_version.py --apply
python Kindlewake/tests/test_sync_version.py
```

- `--check` is read-only and returns non-zero on drift.
- `--apply` updates only README first-heading version and Android export version fields.
- The operation is idempotent: repeating it without changing project.godot produces no further edits.

## Branch and release safety

This automation synchronizes version metadata only. It does **not** merge branches, copy feature code into main, publish an APK/release, change signing keys, or alter save data. A feature branch can legitimately have a newer version than main until its pull request is reviewed and merged. The push-to-main workflow then synchronizes main's metadata to the version actually present in the merged main tree.

The current main version remains 0.9.0 until a reviewed project change updates `project.godot`. Feature work at 0.10.0 is not promoted to main merely because its metadata is newer.
