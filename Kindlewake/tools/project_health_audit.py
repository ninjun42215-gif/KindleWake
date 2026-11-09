#!/usr/bin/env python3
"""Read-only Kindlewake project health audit; emits JSON and Markdown reports."""
from __future__ import annotations
import argparse
import json
import re
from pathlib import Path

def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--root", type=Path, default=Path("."))
    parser.add_argument("--output", type=Path, default=Path("health-audit"))
    args = parser.parse_args()
    root = args.root.resolve()
    project = root / "Kindlewake"
    findings = []
    counts = {"json_files": 0, "tracked_workflows": 0, "gdscript_files": 0,
              "scene_files": 0, "resource_files": 0, "rune_definitions": None}
    def add(level, code, message, path=""):
        findings.append({"level": level, "code": code, "path": path, "message": message})

    if not (project / "project.godot").is_file():
        add("error", "PROJECT_MISSING", "Kindlewake/project.godot was not found.")
    else:
        for path in project.rglob("*.json"):
            if any(part in {".git", ".godot", "__pycache__"} for part in path.parts):
                continue
            counts["json_files"] += 1
            try:
                json.loads(path.read_text(encoding="utf-8"))
            except (OSError, UnicodeError, json.JSONDecodeError) as exc:
                add("error", "INVALID_JSON", str(exc), path.relative_to(root).as_posix())

        counts["gdscript_files"] = sum(1 for _ in project.rglob("*.gd"))
        counts["scene_files"] = sum(1 for _ in project.rglob("*.tscn"))
        counts["resource_files"] = sum(1 for pattern in ("*.tres", "*.res") for _ in project.rglob(pattern))

        godot_text = (project / "project.godot").read_text(encoding="utf-8", errors="replace")
        version_match = re.search(r'^config/version="([^"]+)"', godot_text, re.M)
        readme = project / "README.md"
        readme_text = readme.read_text(encoding="utf-8", errors="replace") if readme.exists() else ""
        readme_match = re.search(r'v(\d+\.\d+\.\d+)', readme_text)
        if version_match and readme_match and version_match.group(1) != readme_match.group(1):
            add("warning", "VERSION_DRIFT",
                f"project.godot is {version_match.group(1)} while README headline is {readme_match.group(1)}.",
                "Kindlewake/project.godot;Kindlewake/README.md")
        if not (project / "assets" / "art" / "CREDITS.md").exists():
            add("warning", "ASSET_CREDITS_MISSING",
                "No assets/art/CREDITS.md found; verify asset ownership and licenses before release.",
                "Kindlewake/assets/art/CREDITS.md")
        rune_path = project / "data" / "runes.json"
        if rune_path.exists():
            try:
                data = json.loads(rune_path.read_text(encoding="utf-8"))
                runes = data.get("runes", data) if isinstance(data, dict) else {}
                counts["rune_definitions"] = len(runes) if isinstance(runes, dict) else 0
                if counts["rune_definitions"] < 50:
                    add("warning", "RUNE_TARGET_NOT_MET",
                        f"Found {counts['rune_definitions']} rune definitions; design target is 50+.",
                        rune_path.relative_to(root).as_posix())
            except (OSError, UnicodeError, json.JSONDecodeError):
                pass

    workflows = root / ".github" / "workflows"
    if workflows.exists():
        counts["tracked_workflows"] = sum(1 for p in workflows.glob("*.y*ml") if p.is_file())
    nested = project / ".github" / "workflows"
    if nested.exists() and any(nested.glob("*.y*ml")):
        add("warning", "NESTED_WORKFLOWS",
            "Workflow YAML under Kindlewake/.github/workflows is not discovered by GitHub Actions; consolidate active workflows at repository root.",
            "Kindlewake/.github/workflows")

    add("info", "AUDIT_SCOPE",
        "Read-only structural audit. It does not execute Godot, inspect every GDScript semantic, test scenes, validate licenses, or prove Android device compatibility.")
    errors = sum(f["level"] == "error" for f in findings)
    warnings = sum(f["level"] == "warning" for f in findings)
    report = {"schema_version": 1, "project": "Kindlewake", "counts": counts,
              "summary": {"errors": errors, "warnings": warnings}, "findings": findings}
    args.output.mkdir(parents=True, exist_ok=True)
    (args.output / "project-health.json").write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")
    lines = ["# Kindlewake Project Health Audit", "",
             f"- Errors: **{errors}**", f"- Warnings: **{warnings}**", "",
             "## Inventory", ""]
    lines += [f"- {key.replace('_', ' ').title()}: {value}" for key, value in counts.items()]
    lines += ["", "## Findings", ""]
    lines += [f"- **{f['level'].upper()} — {f['code']}** {f['message']} ({f['path']})" for f in findings]
    (args.output / "project-health.md").write_text("\n".join(lines) + "\n", encoding="utf-8")
    print(json.dumps(report, indent=2))
    return 1 if errors else 0

if __name__ == "__main__":
    raise SystemExit(main())
