import hashlib
import importlib.util
import json
import subprocess
import sys
import tempfile
import unittest
import zipfile
from pathlib import Path

SCRIPT = Path(__file__).resolve().parents[1] / "tools" / "source_handoff.py"

class SourceHandoffTests(unittest.TestCase):
    def test_only_documented_public_test_keystore_is_allowed(self):
        spec = importlib.util.spec_from_file_location('source_handoff', SCRIPT)
        module = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(module)
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp)
            public = 'Kindlewake/tools/keys/kindlewake-sideload.keystore'
            private = 'private/release-signing.keystore'
            public_path = root / public
            private_path = root / private
            public_path.parent.mkdir(parents=True)
            private_path.parent.mkdir(parents=True)
            public_path.write_bytes(b'public test fixture')
            private_path.write_bytes(b'private signing fixture')
            self.assertEqual(module.exclusion(public, public_path), '')
            self.assertEqual(module.exclusion(private, private_path), 'private key/certificate')
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
            self.assertTrue((parts / "source_handoff.py").is_file())
            self.assertGreater(manifest["part_count"], 1)
            self.assertTrue(all(p["size_bytes"] <= 128 for p in manifest["parts"]))
            archive = Path(temp) / "restored.zip"
            self.run_tool("reassemble", "--parts-dir", parts, "--output", archive)
            extracted = Path(temp) / "extracted"
            self.run_tool("verify", "--archive", archive, "--extract-to", extracted)
            self.assertEqual((extracted / "README.md").read_text(), "handoff test\n")
            self.assertTrue((extracted / "AI_NEXT_SESSION.md").is_file())
            self.assertTrue((extracted / "REASSEMBLE.txt").is_file())

    def test_missing_part_is_rejected(self):
        with tempfile.TemporaryDirectory() as temp:
            folder = Path(temp)
            helper = folder / "source_handoff.py"
            helper.write_bytes(SCRIPT.read_bytes())
            helper_sha = hashlib.sha256(helper.read_bytes()).hexdigest()
            (folder / "PARTS-MANIFEST.json").write_text(json.dumps({
                "parts": [{"name": "Kindlewake-Source-Handoff.zip.part001",
                           "size_bytes": 1, "sha256": "0" * 64}],
                "part_limit_bytes": 25000000,
                "recovery_tool": {"name": "source_handoff.py", "sha256": helper_sha}
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


    def test_windows_style_zip_traversal_is_rejected(self):
        with tempfile.TemporaryDirectory() as temp:
            archive = Path(temp) / "bad-windows.zip"
            with zipfile.ZipFile(archive, "w") as z:
                z.writestr("..\\\\escape.txt", "bad")
                z.writestr("FILE-MANIFEST.json", json.dumps({"files": []}))
            result = self.run_tool("verify", "--archive", archive, expect=1)
            self.assertIn("Unsafe ZIP path", result.stdout + result.stderr)

if __name__ == "__main__":
    unittest.main()
