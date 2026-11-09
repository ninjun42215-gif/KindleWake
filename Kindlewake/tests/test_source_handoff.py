import json
import subprocess
import sys
import tempfile
import unittest
import zipfile
from pathlib import Path

SCRIPT = Path(__file__).resolve().parents[1] / "tools" / "source_handoff.py"

class SourceHandoffTests(unittest.TestCase):
    def run_tool(self, *args, cwd=None, expect=0):
        result = subprocess.run([sys.executable, str(SCRIPT), *map(str, args)],
                                cwd=cwd, text=True, capture_output=True)
        self.assertEqual(result.returncode, expect, result.stdout + result.stderr)
        return result

    def test_pack_reassemble_verify_and_safe_extract(self):
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp) / "repo"
            out = Path(temp) / "out"
            root.mkdir()
            (root / "Kindlewake").mkdir()
            (root / "Kindlewake" / "project.godot").write_text("config/name=\"Test\"\n")
            (root / "README.md").write_text("handoff test\n")
            subprocess.run(["git", "init", "-q"], cwd=root, check=True)
            subprocess.run(["git", "config", "user.email", "test@example.invalid"], cwd=root, check=True)
            subprocess.run(["git", "config", "user.name", "Test"], cwd=root, check=True)
            subprocess.run(["git", "add", "."], cwd=root, check=True)
            subprocess.run(["git", "commit", "-qm", "fixture"], cwd=root, check=True)
            self.run_tool("pack", "--repository-root", root, "--output-dir", out,
                          "--part-size", "128", "--repository", "test/repo",
                          "--ref", "refs/heads/test", "--sha", "abc123", cwd=root)
            parts = out / "Kindlewake-Source-Handoff-Parts"
            manifest = json.loads((parts / "PARTS-MANIFEST.json").read_text())
            self.assertGreater(manifest["part_count"], 1)
            self.assertTrue(all(p["size_bytes"] <= 128 for p in manifest["parts"]))
            archive = Path(temp) / "restored.zip"
            self.run_tool("reassemble", "--parts-dir", parts, "--output", archive)
            extracted = Path(temp) / "extracted"
            self.run_tool("verify", "--archive", archive, "--extract-to", extracted)
            self.assertEqual((extracted / "README.md").read_text(), "handoff test\n")
            self.assertTrue((extracted / "AI_NEXT_SESSION.md").is_file())

    def test_missing_part_is_rejected(self):
        with tempfile.TemporaryDirectory() as temp:
            folder = Path(temp)
            (folder / "PARTS-MANIFEST.json").write_text(json.dumps({
                "parts": [{"name": "Kindlewake-Source-Handoff.zip.part001",
                           "size_bytes": 1, "sha256": "0" * 64}],
                "part_limit_bytes": 25000000
            }))
            result = self.run_tool("reassemble", "--parts-dir", folder,
                                   "--output", folder / "out.zip", expect=1)
            self.assertIn("Part mismatch", result.stdout + result.stderr)

    def test_zip_traversal_is_rejected(self):
        with tempfile.TemporaryDirectory() as temp:
            archive = Path(temp) / "bad.zip"
            with zipfile.ZipFile(archive, "w") as z:
                z.writestr("../escape.txt", "bad")
                z.writestr("FILE-MANIFEST.json", json.dumps({"files": []}))
            result = self.run_tool("verify", "--archive", archive, expect=1)
            self.assertIn("Unsafe ZIP path", result.stdout + result.stderr)

if __name__ == "__main__":
    unittest.main()
