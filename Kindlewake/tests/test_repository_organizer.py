import importlib.util
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path
from unittest.mock import patch

SCRIPT = Path(__file__).resolve().parents[1] / "tools" / "repository_organizer.py"
SPEC = importlib.util.spec_from_file_location("repository_organizer", SCRIPT)
organizer = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(organizer)

class RepositoryOrganizerTests(unittest.TestCase):
    def make_repo(self, root):
        subprocess.run(["git", "init", "-q"], cwd=root, check=True)
        subprocess.run(["git", "config", "user.email", "test@example.invalid"], cwd=root, check=True)
        subprocess.run(["git", "config", "user.name", "Test"], cwd=root, check=True)
        subprocess.run(["git", "remote", "add", "origin", "https://example.invalid/test/repo.git"], cwd=root, check=True)
        (root / "Kindlewake" / "docs").mkdir(parents=True)
        (root / "Kindlewake" / "assets").mkdir()
        (root / "Kindlewake" / "scenes").mkdir()
        (root / "Kindlewake" / "README.md").write_text("root readme\n")
        (root / "Kindlewake" / "DESIGN_NOTES.md").write_text("design\n")
        (root / "Kindlewake" / "assets" / "art.svg").write_text("<svg/>")
        (root / "Kindlewake" / "scenes" / "main.tscn").write_text("[gd_scene]\n")
        subprocess.run(["git", "add", "."], cwd=root, check=True)

    def invoke(self, root, report, mode):
        with patch.object(organizer, "ROOT", root), patch.object(
            sys, "argv", ["repository_organizer.py", "--mode", mode, "--report-dir", str(report)]
        ):
            return organizer.main()

    def test_moves_only_unambiguous_root_documentation(self):
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp) / "repo"
            root.mkdir()
            self.make_repo(root)
            report = Path(temp) / "report"
            self.assertEqual(self.invoke(root, report, "organize"), 0)
            self.assertTrue((root / "Kindlewake" / "docs" / "DESIGN_NOTES.md").is_file())
            self.assertTrue((root / "Kindlewake" / "README.md").is_file())
            self.assertTrue((root / "Kindlewake" / "assets" / "art.svg").is_file())
            self.assertTrue((root / "Kindlewake" / "scenes" / "main.tscn").is_file())

    def test_audit_does_not_move_files(self):
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp) / "repo"
            root.mkdir()
            self.make_repo(root)
            report = Path(temp) / "report"
            self.assertEqual(self.invoke(root, report, "audit"), 0)
            self.assertTrue((root / "Kindlewake" / "DESIGN_NOTES.md").is_file())
            self.assertFalse((root / "Kindlewake" / "docs" / "DESIGN_NOTES.md").exists())

if __name__ == "__main__":
    unittest.main()
