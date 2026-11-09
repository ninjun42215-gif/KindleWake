import importlib.util
import tempfile
import unittest
from pathlib import Path

SCRIPT = Path(__file__).resolve().parents[1] / "tools" / "sync_version.py"
SPEC = importlib.util.spec_from_file_location("sync_version", SCRIPT)
MODULE = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(MODULE)


class VersionSyncTests(unittest.TestCase):
    def fixture(self, root, version="0.9.0", readme_version="0.8.1", export_version="0.7.14", code=714):
        project = root / "Kindlewake"
        project.mkdir()
        (project / "project.godot").write_text(
            f'[application]\nconfig/version="{version}"\n', encoding="utf-8"
        )
        (project / "README.md").write_text(
            f"# Kindlewake: The Sundered Vow (v{readme_version})\n", encoding="utf-8"
        )
        (project / "export_presets.cfg").write_text(
            f'[preset.0.options]\nversion/code={code}\nversion/name="{export_version}"\n',
            encoding="utf-8",
        )
        return project

    def test_derives_readme_and_android_versions(self):
        with tempfile.TemporaryDirectory() as temp:
            project = self.fixture(Path(temp))
            updates = MODULE.synchronized_contents(project)
            self.assertIn("(v0.9.0)", updates[project / "README.md"])
            self.assertIn('version/name="0.9.0"', updates[project / "export_presets.cfg"])
            self.assertIn("version/code=900", updates[project / "export_presets.cfg"])

    def test_apply_then_check_is_idempotent(self):
        with tempfile.TemporaryDirectory() as temp:
            project = self.fixture(Path(temp))
            updates = MODULE.synchronized_contents(project)
            for path, content in updates.items():
                path.write_text(content, encoding="utf-8")
            self.assertFalse([
                path for path, content in MODULE.synchronized_contents(project).items()
                if path.read_text(encoding="utf-8") != content
            ])

    def test_semver_components_outside_mapping_are_rejected(self):
        with tempfile.TemporaryDirectory() as temp:
            project = self.fixture(Path(temp), version="0.100.0")
            with self.assertRaises(ValueError):
                MODULE.synchronized_contents(project)

    def test_missing_export_metadata_is_rejected(self):
        with tempfile.TemporaryDirectory() as temp:
            project = self.fixture(Path(temp))
            (project / "export_presets.cfg").write_text("[preset.0]\n", encoding="utf-8")
            with self.assertRaises(ValueError):
                MODULE.synchronized_contents(project)


if __name__ == "__main__":
    unittest.main()
