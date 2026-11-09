#!/usr/bin/env python3
"""Conservative Kindlewake repository organizer.

Only moves standalone Markdown documents from the Godot project root into docs/.
All source code, Godot resources, assets, data, tests, plugins and project settings
are protected. The workflow runs this on a disposable maintenance branch and opens
a PR; it never writes directly to the selected base branch.
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

def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--mode", choices=("audit", "organize"), default="audit")
    parser.add_argument("--report-dir", type=Path, required=True)
    args = parser.parse_args()
    tracked = [Path(p) for p in git("ls-files", "-z").split("\0") if p]
    moves, collisions, protected = [], [], []
    for src in tracked:
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
        "planned_moves": moves,
        "applied_moves": moves if args.mode == "organize" else [],
        "collisions": collisions,
        "protected_examples": protected,
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
        "## Proposed / applied moves",
    ]
    lines += [f"- {m['source']} → {m['target']} — {m['reason']}" for m in moves] or ["- No safe documentation moves found."]
    lines += ["", "## Destination collisions"]
    lines += [f"- {x['source']} → {x['target']}: {x['reason']}" for x in collisions] or ["- None."]
    lines += ["", "## Safety", result["safety"], "",
              "This tool deliberately does not reorganize game code or Godot resource paths. Extend its explicit rules only after reviewing project references."]
    (args.report_dir / "organization-report.md").write_text("\n".join(lines) + "\n", encoding="utf-8")
    print("\n".join(lines))
    return 1 if collisions else 0

if __name__ == "__main__":
    raise SystemExit(main())
