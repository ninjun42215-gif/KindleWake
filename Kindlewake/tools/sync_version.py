#!/usr/bin/env python3
"""Synchronize Kindlewake's public version metadata from project.godot.

The Godot application version is the sole version source. Android's integer
version code is derived deterministically as MAJOR*10000 + MINOR*100 + PATCH.
This supports two-digit minor/patch components and stays monotonic for normal
semantic-version releases.
"""
from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path

VERSION_RE = re.compile(r'^config/version="(\d+)\.(\d+)\.(\d+)"$', re.M)
README_RE = re.compile(r'^(# Kindlewake:.*?\(v)\d+\.\d+\.\d+(\).*)$', re.M)
EXPORT_NAME_RE = re.compile(r'^version/name="[^"]*"$', re.M)
EXPORT_CODE_RE = re.compile(r'^version/code=\d+$', re.M)


def synchronized_contents(project_dir: Path) -> dict[Path, str]:
    project_file = project_dir / "project.godot"
    readme_file = project_dir / "README.md"
    export_file = project_dir / "export_presets.cfg"
    for path in (project_file, readme_file, export_file):
        if not path.is_file():
            raise ValueError(f"Required version file is missing: {path}")

    project_text = project_file.read_text(encoding="utf-8")
    match = VERSION_RE.search(project_text)
    if not match:
        raise ValueError('project.godot must contain config/version="MAJOR.MINOR.PATCH"')
    major, minor, patch = map(int, match.groups())
    if minor > 99 or patch > 99:
        raise ValueError("Android version-code mapping requires minor and patch components <= 99")
    version = f"{major}.{minor}.{patch}"
    version_code = major * 10000 + minor * 100 + patch
    if version_code < 1 or version_code > 2_100_000_000:
        raise ValueError(f"Derived Android version code is outside Android's supported range: {version_code}")

    readme = readme_file.read_text(encoding="utf-8")
    updated_readme, count = README_RE.subn(lambda m: f"{m.group(1)}{version}{m.group(2)}", readme, count=1)
    if count != 1:
        raise ValueError("README.md first heading must be '# Kindlewake: ... (vX.Y.Z)'")

    export_text = export_file.read_text(encoding="utf-8")
    if len(EXPORT_NAME_RE.findall(export_text)) != 1:
        raise ValueError("export_presets.cfg must contain exactly one version/name entry")
    if len(EXPORT_CODE_RE.findall(export_text)) != 1:
        raise ValueError("export_presets.cfg must contain exactly one version/code entry")
    updated_export = EXPORT_NAME_RE.sub(f'version/name="{version}"', export_text, count=1)
    updated_export = EXPORT_CODE_RE.sub(f"version/code={version_code}", updated_export, count=1)

    return {readme_file: updated_readme, export_file: updated_export}


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--project-dir", type=Path, default=Path(__file__).resolve().parents[1])
    mode = parser.add_mutually_exclusive_group(required=True)
    mode.add_argument("--check", action="store_true", help="Fail if README/export metadata is stale.")
    mode.add_argument("--apply", action="store_true", help="Update README/export metadata in place.")
    args = parser.parse_args()

    try:
        updates = synchronized_contents(args.project_dir.resolve())
        drift = [(path, content) for path, content in updates.items()
                 if path.read_text(encoding="utf-8") != content]
        if args.check:
            if drift:
                for path, _ in drift:
                    print(f"VERSION DRIFT: {path.relative_to(args.project_dir.resolve())}")
                print("Run sync_version.py --apply to repair the metadata.")
                return 1
            print("Version metadata is synchronized.")
            return 0
        for path, content in drift:
            path.write_text(content, encoding="utf-8", newline="\n")
            print(f"Updated {path.relative_to(args.project_dir.resolve())}")
        print("Version metadata synchronized." if drift else "Version metadata already synchronized.")
        return 0
    except (OSError, UnicodeError, ValueError) as exc:
        print(f"Version synchronization failed: {exc}", file=sys.stderr)
        return 2


if __name__ == "__main__":
    raise SystemExit(main())
