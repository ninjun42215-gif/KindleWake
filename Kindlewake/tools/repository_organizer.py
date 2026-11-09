#!/usr/bin/env python3
"""Conservative Kindlewake repository inventory and organizer.

Only moves standalone Markdown documents from the Godot project root into docs/.
All code, Godot resources, assets, data, tests, plugins and project settings remain
untouched. Apply mode is intended for an isolated maintenance branch and draft PR.
"""
from __future__ import annotations
import argparse
import json
import subprocess
from datetime import datetime, timezone
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
EXEMPT = {
    "README.md", "LICENSE.md", "LICENSE", "CHANGELOG.md", "CONTRIBUTING.md",
    "SECURITY.md", "CODE_OF_CONDUCT.md", "CONTINUATION_PROMPT.md",
}

def git(*args: str) -> str:
    return subprocess.check_output(["git", *args], cwd=ROOT, text=True)

def category(path: Path) -> str:
    parts, suffix = set(path.parts), path.suffix.lower()
    if ".github" in parts or "tools" in parts: return "automation_and_tools"
    if "tests" in parts: return "tests"
    if "assets" in parts: return "assets"
    if "data" in parts: return "game_data"
    if "docs" in parts or suffix in {".md", ".rst"}: return "documentation"
    if suffix == ".gd": return "game_scripts"
    if suffix in {".tscn", ".scn"}: return "scenes"
    if suffix in {".tres", ".res", ".import"}: return "resources"
    if path.name in {"project.godot", "export_presets.cfg"} or suffix in {".cfg", ".toml", ".ini"}:
        return "project_configuration"
    return "other"

def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--mode", choices=("audit", "organize"), default="audit")
    parser.add_argument("--report-dir", type=Path, required=True)
    args = parser.parse_args()
    tracked = [Path(p) for p in git("ls-files", "-z").split("\0") if p]
    moves, collisions, protected = [], [], []
    categories = {name: [] for name in (
        "documentation", "automation_and_tools", "tests", "game_scripts",
        "scenes", "resources", "assets", "game_data", "project_configuration", "other"
    )}
    for src in tracked:
        categories[category(src)].append(src.as_posix())
        if src.parent == Path("Kindlewake") and src.suffix.lower() == ".md":
            if src.name in EXEMPT:
                protected.append({"path": src.as_posix(), "reason": "root-level entry-point or policy document"})
                continue
            dst = Path("Kindlewake/docs") / src.name
            if dst.exists() or dst in tracked:
                collisions.append({"source": src.as_posix(), "target": dst.as_posix(), "reason": "destination already exists"})
            else:
                moves.append({"source": src.as_posix(), "target": dst.as_posix(), "reason": "standalone project documentation belongs in docs/"})
        elif src.parts and src.parts[0] == "Kindlewake" and (
            "assets" in src.parts or "scenes" in src.parts or "scripts" in src.parts
            or "data" in src.parts or "tests" in src.parts or "addons" in src.parts
            or src.name in {"project.godot", "export_presets.cfg"}
        ):
            protected.append({"path": src.as_posix(), "reason": "Godot source/resource path; never relocate automatically"})
    if args.mode == "organize":
        for item in moves:
            target = ROOT / item["target"]
            target.parent.mkdir(parents=True, exist_ok=True)
            subprocess.check_call(["git", "mv", "--", item["source"], item["target"]], cwd=ROOT)
    args.report_dir.mkdir(parents=True, exist_ok=True)
    result = {
        "generated_at_utc": datetime.now(timezone.utc).isoformat(),
        "repository": git("config", "--get", "remote.origin.url").strip(),
        "base_commit": git("rev-parse", "HEAD").strip(),
        "mode": args.mode,
        "tracked_file_count": len(tracked),
        "inventory_by_category": categories,
        "planned_moves": moves,
        "applied_moves": moves if args.mode == "organize" else [],
        "collisions": collisions,
        "protected_paths": protected,
        "safety": "No code, Godot scenes/resources, assets, data, tests, addons or project settings are moved.",
    }
    (args.report_dir / "organization-report.json").write_text(json.dumps(result, indent=2) + "\n", encoding="utf-8")
    lines = [
        "# Kindlewake repository organization report", "",
        f"- Mode: **{args.mode}**",
        f"- Tracked files inspected: {len(tracked)}",
        f"- Candidate moves: {len(moves)}",
        f"- Destination collisions: {len(collisions)}",
        f"- Protected paths/examples: {len(protected)}", "",
        "## Repository inventory by category",
    ]
    lines += [f"- {name}: {len(paths)} tracked files" for name, paths in categories.items()]
    lines += ["", "## Proposed / applied moves"]
    lines += [f"- {m['source']} → {m['target']} — {m['reason']}" for m in moves] or ["- No safe documentation moves found."]
    lines += ["", "## Destination collisions"]
    lines += [f"- {x['source']} → {x['target']}: {x['reason']}" for x in collisions] or ["- None."]
    lines += ["", "## Safety", result["safety"], "",
              "The organizer deliberately does not relocate game code or Godot resource paths. Expand its explicit rules only after reviewing references and adding tests."]
    (args.report_dir / "organization-report.md").write_text("\n".join(lines) + "\n", encoding="utf-8")
    print("\n".join(lines))
    return 1 if collisions else 0

if __name__ == "__main__":
    raise SystemExit(main())
