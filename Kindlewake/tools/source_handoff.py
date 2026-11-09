#!/usr/bin/env python3
"""Kindlewake portable source handoff packer, verifier and safe extractor."""
from __future__ import annotations
import argparse, hashlib, json, os, re, shutil, subprocess, zipfile
from pathlib import Path, PurePosixPath

LIMIT = 25_000_000
ARCHIVE = "Kindlewake-Source-Handoff.zip"
PREFIX = ARCHIVE + ".part"
SKIP_DIRS = {".git", ".godot", "__pycache__", "node_modules", ".venv", "venv", "dist", "build", "target"}
SKIP_NAMES = {".env", ".env.local", ".env.production", ".env.development", "credentials.json", "secrets.json", "id_rsa", "id_ed25519"}
SKIP_SUFFIXES = {".keystore", ".jks", ".p12", ".pfx", ".pem", ".key", ".mobileprovision", ".asc"}
# Explicitly public repository test key; never include arbitrary signing material.
PUBLIC_TEST_KEY = "Kindlewake/tools/keys/kindlewake-sideload.keystore"

def digest(path):
    h = hashlib.sha256()
    with Path(path).open("rb") as f:
        for chunk in iter(lambda: f.read(1024 * 1024), b""):
            h.update(chunk)
    return h.hexdigest()

def write_json(path, data):
    Path(path).write_text(json.dumps(data, indent=2, sort_keys=True) + "\n", encoding="utf-8")

def exclusion(name, path):
    p = PurePosixPath(name)
    if p.is_absolute() or ".." in p.parts: return "unsafe path"
    if any(x in SKIP_DIRS for x in p.parts): return "generated/cache directory"
    if p.name.lower() in SKIP_NAMES or p.name.lower().endswith(".secret"): return "sensitive filename"
    if p.suffix.lower() in SKIP_SUFFIXES and name != PUBLIC_TEST_KEY:
        return "private key/certificate"
    if path.is_symlink(): return "symlink omitted"
    return ""

GUIDE = """KINDLEWAKE SOURCE HANDOFF — VERIFIED REASSEMBLY

Download ALL artifact files into one folder. The .partNNN files are consecutive
binary slices of ONE ZIP; never extract them individually. Keep PARTS-MANIFEST.json,
SHA256SUMS.txt and all parts together. Run the validation/reassembly commands:

Linux / macOS / Android Termux (Python 3):
  python3 source_handoff.py reassemble --parts-dir . --output Kindlewake-Source-Handoff.zip
  python3 source_handoff.py verify --archive Kindlewake-Source-Handoff.zip --extract-to ./Kindlewake-Handoff-Extracted

Windows PowerShell (Python 3):
  py -3 source_handoff.py reassemble --parts-dir . --output Kindlewake-Source-Handoff.zip
  py -3 source_handoff.py verify --archive Kindlewake-Source-Handoff.zip --extract-to .\\Kindlewake-Handoff-Extracted

The source_handoff.py helper is included beside these parts in this artifact folder.
It checks missing/extra parts, numeric ordering, each part's size and SHA-256,
the reconstructed archive size/hash, ZIP CRC, and every tracked file's hash.
Extraction rejects traversal paths and refuses to overwrite a non-empty folder.
Never extract if any verification fails.

Manual fallback only reconstructs the archive (verification is still mandatory):
  Linux/macOS/Termux: cat Kindlewake-Source-Handoff.zip.part* > Kindlewake-Source-Handoff.zip
  PowerShell:
    $parts = Get-ChildItem 'Kindlewake-Source-Handoff.zip.part*' | Sort-Object Name
    $out = [IO.File]::Create('Kindlewake-Source-Handoff.zip')
    try { foreach ($p in $parts) { $s=[IO.File]::OpenRead($p.FullName); try{$s.CopyTo($out)}finally{$s.Dispose()} } } finally {$out.Dispose()}

Read AI_NEXT_SESSION.md and the repository continuation documents before editing.
The ZIP contains tracked files only, not Git history, ignored files, untracked files,
build outputs or excluded secrets. GitHub remains canonical; inspect live state first.
"""

def pack(a):
    if not 1 <= a.part_size <= LIMIT:
        raise SystemExit("Part size must be between 1 and 25,000,000 bytes.")
    root, out = a.repository_root.resolve(), a.output_dir.resolve()
    out.mkdir(parents=True, exist_ok=True)
    tracked = subprocess.check_output(["git", "-C", str(root), "ls-files", "-z"]).decode("utf-8", "surrogateescape").split("\0")
    included, excluded = [], []
    for name in sorted(x for x in tracked if x):
        path = root / name
        reason = exclusion(name, path)
        if reason:
            excluded.append({"path": name, "reason": reason})
        elif path.is_file():
            included.append({"path": name, "size_bytes": path.stat().st_size, "sha256": digest(path)})
        else:
            excluded.append({"path": name, "reason": "missing or non-regular tracked path"})
    if not included: raise SystemExit("No eligible tracked files; refusing empty handoff.")
    meta = {
        "format": "kindlewake-source-handoff", "format_version": 2,
        "repository": a.repository, "git_ref": a.ref, "commit": a.sha,
        "event": a.event, "workflow_run_id": a.run_id, "workflow_run_attempt": a.run_attempt,
        "tracked_files_included": len(included), "tracked_files_excluded": len(excluded),
        "archive": ARCHIVE, "part_limit_bytes": a.part_size,
    }
    inventory = {"files": included, "excluded": excluded}
    archive = out / ARCHIVE
    ai = (
        "# Kindlewake AI handoff\n\n"
        f"- Repository: {a.repository}\n- Ref: {a.ref}\n- Exact commit: {a.sha}\n"
        f"- Event/run: {a.event} / {a.run_id} (attempt {a.run_attempt})\n"
        f"- Included tracked files: {len(included)}\n\n"
        "## First actions for the receiving AI\n"
        "1. Read root CONTINUATION_PROMPT.md, Kindlewake/docs/NEXT_AI_START_HERE.md, "
        "Kindlewake/docs/SESSION_HANDOFF.md, Kindlewake/docs/GDD.md, Kindlewake/README.md "
        "and Kindlewake/receiving/README.md.\n"
        "2. Confirm repository/ref/commit against HANDOFF-METADATA.json; inspect live GitHub "
        "state because this snapshot may be stale.\n"
        "3. Inspect recent commits, open PRs, latest CI run and artifacts; do not assume "
        "previous build results remain current.\n"
        "4. Inspect source/tests before editing. Preserve constraints and use the authorized "
        "development branch; do not alter main without permission.\n"
        "5. Inspect the GitHub Actions summary and Kindlewake-Workflow-Report artifact for "
        "the exact job outcomes and evidence-based next actions.\n"
        "6. Run documented checks, record exact results, update handoff docs and create a "
        "new verified split handoff after meaningful changes.\n\n"
        "## Snapshot limits\n"
        "- Tracked-source snapshot only: no Git history, untracked/ignored files, build outputs, "
        "caches or excluded sensitive files.\n"
        "- GitHub is canonical; re-check live repository state before editing.\n"
        "- FILE-MANIFEST.json records every included file hash and excluded path/reason.\n"
    )
    with zipfile.ZipFile(archive, "w", zipfile.ZIP_DEFLATED, compresslevel=6) as z:
        for item in included: z.write(root / item["path"], item["path"])
        z.writestr("HANDOFF-METADATA.json", json.dumps(meta, indent=2) + "\n")
        z.writestr("FILE-MANIFEST.json", json.dumps(inventory, indent=2) + "\n")
        z.writestr("AI_NEXT_SESSION.md", ai)
        z.writestr("REASSEMBLE.txt", GUIDE)
    archive_hash = digest(archive)
    parts_dir = out / "Kindlewake-Source-Handoff-Parts"
    if parts_dir.exists(): shutil.rmtree(parts_dir)
    parts_dir.mkdir()
    parts = []
    with archive.open("rb") as src:
        i = 1
        while True:
            data = src.read(a.part_size)
            if not data: break
            name = f"{PREFIX}{i:03d}"
            target = parts_dir / name
            target.write_bytes(data)
            if target.stat().st_size > a.part_size: raise SystemExit("Part size limit exceeded: " + name)
            parts.append({"name": name, "size_bytes": target.stat().st_size, "sha256": digest(target)})
            i += 1
    manifest = {
        "format": "kindlewake-handoff-parts", "format_version": 2,
        "archive": ARCHIVE, "archive_size_bytes": archive.stat().st_size,
        "archive_sha256": archive_hash, "part_limit_bytes": a.part_size,
        "part_count": len(parts), "parts": parts,
        "recovery_tool": {"name": "source_handoff.py", "sha256": digest(Path(__file__))},
    }
    shutil.copy2(Path(__file__), parts_dir / "source_handoff.py")
    write_json(parts_dir / "PARTS-MANIFEST.json", manifest)
    (parts_dir / "SHA256SUMS.txt").write_text(
        f"{archive_hash}  {ARCHIVE}\n" + "".join(f"{p['sha256']}  {p['name']}\n" for p in parts) +
        f"{manifest['recovery_tool']['sha256']}  source_handoff.py\n",
        encoding="utf-8")
    (out / "AI_NEXT_SESSION.md").write_text(ai, encoding="utf-8")
    (parts_dir / "AI_NEXT_SESSION.md").write_text(ai, encoding="utf-8")
    (parts_dir / "REASSEMBLE.txt").write_text(GUIDE, encoding="utf-8")
    print(json.dumps({"archive": ARCHIVE, "archive_size_bytes": archive.stat().st_size,
        "archive_sha256": archive_hash, "included_files": len(included),
        "excluded_files": len(excluded), "parts": parts}, indent=2))

def reassemble(a):
    folder = a.parts_dir.resolve()
    manifest = json.loads((folder / "PARTS-MANIFEST.json").read_text(encoding="utf-8"))
    parts = manifest.get("parts", [])
    tool = manifest.get("recovery_tool")
    if not tool or tool.get("name") != "source_handoff.py":
        raise SystemExit("Recovery tool entry is missing from PARTS-MANIFEST.json.")
    tool_path = folder / tool["name"]
    if not tool_path.is_file() or digest(tool_path) != tool["sha256"]:
        raise SystemExit("Recovery helper is missing or its SHA-256 does not match.")
    expected = [p["name"] for p in parts]
    actual = sorted(p.name for p in folder.glob(PREFIX + "*"))
    if not parts or actual != expected:
        raise SystemExit(f"Part mismatch. Missing={sorted(set(expected)-set(actual))}; extra={sorted(set(actual)-set(expected))}")
    for item in parts:
        p = folder / item["name"]
        if p.stat().st_size != item["size_bytes"] or p.stat().st_size > manifest["part_limit_bytes"]:
            raise SystemExit("Part size invalid: " + item["name"])
        if digest(p) != item["sha256"]: raise SystemExit("Part SHA-256 mismatch: " + item["name"])
    output = a.output.resolve()
    output.parent.mkdir(parents=True, exist_ok=True)
    temp = output.with_name(output.name + ".assembling")
    with temp.open("wb") as dst:
        for name in expected:
            with (folder / name).open("rb") as src: shutil.copyfileobj(src, dst, 1024 * 1024)
    if temp.stat().st_size != manifest["archive_size_bytes"] or digest(temp) != manifest["archive_sha256"]:
        temp.unlink(missing_ok=True)
        raise SystemExit("Reassembled ZIP size or SHA-256 mismatch.")
    temp.replace(output)
    print(f"Reassembly verified: {output}\nSize: {output.stat().st_size}\nSHA-256: {digest(output)}")

def verify(a):
    archive = a.archive.resolve()
    with zipfile.ZipFile(archive) as z:
        bad = z.testzip()
        if bad: raise SystemExit("ZIP CRC failure: " + bad)
        names = z.namelist()
        if len(names) != len(set(names)):
            raise SystemExit("Duplicate ZIP entry names are not allowed.")
        for name in names:
            normalized = name.replace("\\", "/")
            p = PurePosixPath(normalized)
            if p.is_absolute() or ".." in p.parts or re.match(r"^[A-Za-z]:", normalized):
                raise SystemExit("Unsafe ZIP path: " + name)
        inv = json.loads(z.read("FILE-MANIFEST.json"))
        for item in inv["files"]:
            name = item["path"]
            h = hashlib.sha256()
            size = 0
            with z.open(name) as stream:
                for chunk in iter(lambda: stream.read(1024 * 1024), b""):
                    size += len(chunk)
                    h.update(chunk)
            if size != item["size_bytes"] or h.hexdigest() != item["sha256"]:
                raise SystemExit("File inventory mismatch: " + name)
        print(f"ZIP integrity PASS; {len(inv['files'])} tracked files verified.")
        if a.extract_to:
            dest = a.extract_to.resolve()
            if dest.exists() and any(dest.iterdir()):
                raise SystemExit("Refusing to extract over non-empty directory: " + str(dest))
            dest.mkdir(parents=True, exist_ok=True)
            root = dest.resolve()
            for info in z.infolist():
                target = (dest / info.filename).resolve()
                if root != target and root not in target.parents: raise SystemExit("Unsafe extraction path.")
                if info.is_dir(): target.mkdir(parents=True, exist_ok=True)
                else:
                    target.parent.mkdir(parents=True, exist_ok=True)
                    with z.open(info) as src, target.open("wb") as dst: shutil.copyfileobj(src, dst)
            print("Safe extraction PASS: " + str(dest))

def main():
    p = argparse.ArgumentParser(description=__doc__)
    sub = p.add_subparsers(dest="cmd", required=True)
    x = sub.add_parser("pack")
    x.add_argument("--repository-root", type=Path, default=Path.cwd())
    x.add_argument("--output-dir", type=Path, required=True)
    x.add_argument("--repository", default=os.getenv("GITHUB_REPOSITORY", "local"))
    x.add_argument("--ref", default=os.getenv("GITHUB_REF", "local"))
    x.add_argument("--sha", default=os.getenv("GITHUB_SHA", "unknown"))
    x.add_argument("--event", default=os.getenv("GITHUB_EVENT_NAME", "local"))
    x.add_argument("--run-id", default=os.getenv("GITHUB_RUN_ID", "local"))
    x.add_argument("--run-attempt", default=os.getenv("GITHUB_RUN_ATTEMPT", "1"))
    x.add_argument("--part-size", type=int, default=LIMIT)
    x.set_defaults(func=pack)
    x = sub.add_parser("reassemble")
    x.add_argument("--parts-dir", type=Path, default=Path.cwd())
    x.add_argument("--output", type=Path, default=Path(ARCHIVE))
    x.set_defaults(func=reassemble)
    x = sub.add_parser("verify")
    x.add_argument("--archive", type=Path, required=True)
    x.add_argument("--extract-to", type=Path)
    x.set_defaults(func=verify)
    a = p.parse_args()
    a.func(a)

if __name__ == "__main__": main()
