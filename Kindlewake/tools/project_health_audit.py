#!/usr/bin/env python3
"""Read-only Kindlewake structural and release-readiness audit."""
from __future__ import annotations

import argparse
import json
import re
from collections import Counter
from pathlib import Path


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--root", type=Path, default=Path("."))
    parser.add_argument("--output", type=Path, default=Path("health-audit"))
    parser.add_argument("--fail-on-warnings", action="store_true", help="Return non-zero when advisory findings exist.")
    args = parser.parse_args()
    root = args.root.resolve()
    project = root / "Kindlewake"
    findings: list[dict[str, str]] = []
    counts: dict[str, object] = {
        "json_files": 0,
        "tracked_workflows": 0,
        "gdscript_files": 0,
        "scene_files": 0,
        "resource_files": 0,\n        "project_version": None,\n        "android_export_version": None,\n        "android_version_code": None,
        "rune_definitions": None,
        "rune_kinds": {},
"unverified_asset_entries": 0,
"unverified_used_assets": 0,
    }

    def add(level: str, code: str, message: str, path: str = "") -> None:
        findings.append({"level": level, "code": code, "path": path, "message": message})

    if not (project / "project.godot").is_file():
        add("error", "PROJECT_MISSING", "Kindlewake/project.godot was not found.")
    else:
        for path in project.rglob("*.json"):
            if any(part in {".git", ".godot", "__pycache__"} for part in path.parts):
                continue
            counts["json_files"] = int(counts["json_files"]) + 1
            try:
                json.loads(path.read_text(encoding="utf-8"))
            except (OSError, UnicodeError, json.JSONDecodeError) as exc:
                add("error", "INVALID_JSON", str(exc), path.relative_to(root).as_posix())

        counts["gdscript_files"] = sum(1 for _ in project.rglob("*.gd"))
        counts["scene_files"] = sum(1 for _ in project.rglob("*.tscn"))
        counts["resource_files"] = sum(
            1 for pattern in ("*.tres", "*.res") for _ in project.rglob(pattern)
        )

        godot_text = (project / "project.godot").read_text(encoding="utf-8", errors="replace")
        version_match = re.search(r'^config/version="([^"]+)"', godot_text, re.M)
        readme = project / "README.md"
        readme_text = readme.read_text(encoding="utf-8", errors="replace") if readme.exists() else ""
        readme_match = re.search(r'v(\d+\.\d+\.\d+)', readme_text)
        if version_match and readme_match and version_match.group(1) != readme_match.group(1):
            add(
                "warning",
                "VERSION_DRIFT",
                f"project.godot is {version_match.group(1)} while README headline is {readme_match.group(1)}.",
                "Kindlewake/project.godot;Kindlewake/README.md",
            )

        if version_match:
            counts["project_version"] = version_match.group(1)
        export_preset = project / "export_presets.cfg"
        if not export_preset.is_file():
            add("warning", "ANDROID_EXPORT_PRESET_MISSING", "Android export preset file is missing.", "Kindlewake/export_presets.cfg")
        else:
            preset_text = export_preset.read_text(encoding="utf-8", errors="replace")
            export_version = re.search(r'^version/name="([^"]+)"', preset_text, re.M)
            export_code = re.search(r'^version/code=(\d+)', preset_text, re.M)
            if export_version:
                counts["android_export_version"] = export_version.group(1)
            if export_code:
                counts["android_version_code"] = int(export_code.group(1))
            if version_match and export_version and version_match.group(1) != export_version.group(1):
                add(
                    "warning",
                    "ANDROID_EXPORT_VERSION_DRIFT",
                    f"project.godot is {version_match.group(1)} while Android export preset is {export_version.group(1)}.",
                    "Kindlewake/project.godot;Kindlewake/export_presets.cfg",
                )
            if not export_code or int(export_code.group(1)) < 1:
                add("error", "ANDROID_VERSION_CODE_INVALID", "Android export preset must define a positive integer version/code.", "Kindlewake/export_presets.cfg")

        credits = project / "assets" / "art" / "CREDITS.md"
        if not credits.is_file():
            add(
                "warning",
                "ASSET_CREDITS_MISSING",
                "No assets/art/CREDITS.md found; document every imported or generated asset and its rights.",
                "Kindlewake/assets/art/CREDITS.md",
            )
        else:
            credits_text = credits.read_text(encoding="utf-8", errors="replace")
            unverified_lines = [
                line.strip()
                for line in credits_text.splitlines()
                if not re.search(r"\bnot used\b", line, re.I)
                and re.search(r"unverified|no licence file|no license file|confirm the licen[cs]e", line, re.I)
            ]
            counts["unverified_asset_entries"] = len(unverified_lines)
            if unverified_lines:
                add(
                    "warning",
                    "ASSET_LICENSE_UNVERIFIED",
                    f"{len(unverified_lines)} asset-credit row(s) still contain unverified or missing licence status; resolve before public/commercial release.",
                    "Kindlewake/assets/art/CREDITS.md",
                )

        provenance_path = project / "data" / "asset_provenance.json"
        if not provenance_path.is_file():
            add(
                "warning",
                "ASSET_PROVENANCE_MISSING",
                "No structured data/asset_provenance.json found; record each used asset, source and licence status.",
                "Kindlewake/data/asset_provenance.json",
            )
        else:
            try:
                provenance = json.loads(provenance_path.read_text(encoding="utf-8"))
            except (OSError, UnicodeError, json.JSONDecodeError) as exc:
                add("error", "ASSET_PROVENANCE_INVALID", f"Could not parse asset provenance: {exc}", provenance_path.relative_to(root).as_posix())
            else:
                assets = provenance.get("assets") if isinstance(provenance, dict) else None
                if not isinstance(assets, list):
                    add("error", "ASSET_PROVENANCE_SCHEMA_INVALID", "Expected an object with an assets array.", provenance_path.relative_to(root).as_posix())
                else:
                    malformed_assets = []
                    unverified_used = []
                    for asset in assets:
                        if not isinstance(asset, dict) or not asset.get("id") or not asset.get("name") or not isinstance(asset.get("used_in_game"), bool) or not asset.get("license_status"):
                            malformed_assets.append(str(asset.get("id", "<unknown>")) if isinstance(asset, dict) else "<non-object>")
                            continue
                        if asset["used_in_game"] and asset["license_status"] != "verified":
                            unverified_used.append(str(asset["id"]))
                    counts["unverified_used_assets"] = len(unverified_used)
                    if malformed_assets:
                        add("error", "ASSET_PROVENANCE_ENTRY_INVALID", f"{len(malformed_assets)} asset provenance entry/entries are missing required fields.", provenance_path.relative_to(root).as_posix())
                    if unverified_used:
                        add(
                            "warning",
                            "USED_ASSET_LICENSE_UNVERIFIED",
                            f"{len(unverified_used)} used asset pack(s) are not marked verified ({', '.join(unverified_used[:8])}); resolve before public/commercial release.",
                            provenance_path.relative_to(root).as_posix(),
                        )

        rune_path = project / "data" / "runes.json"
        if rune_path.exists():
            try:
                data = json.loads(rune_path.read_text(encoding="utf-8"))
            except (OSError, UnicodeError, json.JSONDecodeError) as exc:
                add("error", "RUNE_DATA_INVALID", f"Could not parse rune data: {exc}", rune_path.relative_to(root).as_posix())
            else:
                runes = data.get("runes", data) if isinstance(data, dict) else None
                if not isinstance(runes, dict):
                    add("error", "RUNE_SCHEMA_INVALID", "Expected a JSON object keyed by rune ID.", rune_path.relative_to(root).as_posix())
                else:
                    counts["rune_definitions"] = len(runes)
                    kinds: Counter[str] = Counter()
                    malformed = []
                    for rune_id, rune in runes.items():
                        if not isinstance(rune, dict) or not rune.get("name") or not rune.get("kind"):
                            malformed.append(str(rune_id))
                        else:
                            kinds[str(rune["kind"])] += 1
                    counts["rune_kinds"] = dict(sorted(kinds.items()))
                    if malformed:
                        preview = ", ".join(malformed[:8])
                        add(
                            "error",
                            "RUNE_DEFINITION_INVALID",
                            f"{len(malformed)} rune definition(s) are missing an object, name or kind: {preview}.",
                            rune_path.relative_to(root).as_posix(),
                        )
                    if len(runes) < 50:
                        add(
                            "warning",
                            "RUNE_TARGET_NOT_MET",
                            f"Found {len(runes)} rune definitions; design target is 50+.",
                            rune_path.relative_to(root).as_posix(),
                        )

    workflows = root / ".github" / "workflows"
    if workflows.exists():
        counts["tracked_workflows"] = sum(1 for p in workflows.glob("*.y*ml") if p.is_file())
    nested = project / ".github" / "workflows"
    if nested.exists() and any(nested.glob("*.y*ml")):
        add(
            "warning",
            "NESTED_WORKFLOWS",
            "Workflow YAML under Kindlewake/.github/workflows is not discovered by GitHub Actions; consolidate active workflows at repository root.",
            "Kindlewake/.github/workflows",
        )

    add(
        "info",
        "AUDIT_SCOPE",
        "Read-only structural audit. It does not execute Godot, inspect every GDScript semantic, test scenes, validate external licence terms, or prove Android device compatibility.",
    )
    errors = sum(f["level"] == "error" for f in findings)
    warnings = sum(f["level"] == "warning" for f in findings)
    report = {
        "schema_version": 2,
        "project": "Kindlewake",
        "counts": counts,
        "summary": {"errors": errors, "warnings": warnings},
        "findings": findings,
    }
    args.output.mkdir(parents=True, exist_ok=True)
    (args.output / "project-health.json").write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")
    lines = [
        "# Kindlewake Project Health Audit",
        "",
        f"- Errors: **{errors}**",
        f"- Warnings: **{warnings}**",
        "",
        "## Inventory",
        "",
    ]
    lines += [f"- {key.replace('_', ' ').title()}: {value}" for key, value in counts.items()]
    lines += ["", "## Findings", ""]
    lines += [
        f"- **{f['level'].upper()} — {f['code']}** {f['message']} ({f['path']})"
        for f in findings
    ]
    (args.output / "project-health.md").write_text("\n".join(lines) + "\n", encoding="utf-8")
    print(json.dumps(report, indent=2))
    return 1 if errors or (args.fail_on_warnings and warnings) else 0


if __name__ == "__main__":
    raise SystemExit(main())
