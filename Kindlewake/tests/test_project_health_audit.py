import json
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

SCRIPT = Path(__file__).resolve().parents[1] / "tools" / "project_health_audit.py"


class ProjectHealthAuditTests(unittest.TestCase):
    def fixture(self, root):
        project = root / "Kindlewake"
        (project / "data").mkdir(parents=True)
        (project / "assets" / "art").mkdir(parents=True)
        (project / "project.godot").write_text('config/version="1.2.3"\n')
        (project / "README.md").write_text("# Test v1.2.3\n")
        (project / "export_presets.cfg").write_text('version/name="1.2.3"\nversion/code=123\n')
        (project / "data" / "valid.json").write_text('{"ok": true}\n')
        (project / "data" / "asset_provenance.json").write_text('{"schema_version": 1, "assets": []}')
        (project / "assets" / "art" / "CREDITS.md").write_text("# Credits\n")
        return project

    def run_audit(self, root, fail_on_warnings=False):
        output = root / "out"
        command = [sys.executable, str(SCRIPT), "--root", str(root), "--output", str(output)]
        if fail_on_warnings:
            command.append("--fail-on-warnings")
        result = subprocess.run(
            command,
            capture_output=True,
            text=True,
        )
        report = json.loads((output / "project-health.json").read_text())
        return result, report

    def test_clean_fixture_emits_both_reports(self):
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp)
            self.fixture(root)
            result, report = self.run_audit(root)
            self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
            self.assertEqual(report["summary"]["errors"], 0)
            self.assertTrue((root / "out" / "project-health.md").is_file())

    def test_invalid_json_fails_audit(self):
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp)
            project = self.fixture(root)
            (project / "data" / "broken.json").write_text("{broken")
            result, report = self.run_audit(root)
            self.assertEqual(result.returncode, 1)
            self.assertTrue(any(item["code"] == "INVALID_JSON" for item in report["findings"]))


    def test_android_export_version_drift_is_reported(self):
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp)
            project = self.fixture(root)
            (project / "export_presets.cfg").write_text('version/name="1.2.2"\nversion/code=123\n')
            result, report = self.run_audit(root)
            self.assertEqual(result.returncode, 0)
            self.assertTrue(any(item["code"] == "ANDROID_EXPORT_VERSION_DRIFT" for item in report["findings"]))

    def test_unverified_asset_licence_is_reported_as_warning(self):
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp)
            project = self.fixture(root)
            (project / "assets" / "art" / "CREDITS.md").write_text(
                "| pack | source | No licence file | Unverified |\n"
            )
            result, report = self.run_audit(root)
            self.assertEqual(result.returncode, 0)
            self.assertEqual(report["summary"]["warnings"], 1)
            self.assertEqual(report["counts"]["unverified_asset_entries"], 1)
            self.assertTrue(any(item["code"] == "ASSET_LICENSE_UNVERIFIED" for item in report["findings"]))
            strict_result, _ = self.run_audit(root, fail_on_warnings=True)
            self.assertEqual(strict_result.returncode, 1)


    def test_used_asset_without_verified_licence_is_reported(self):
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp)
            project = self.fixture(root)
            manifest = {
                "schema_version": 1,
                "assets": [
                    {
                        "id": "unknown-pack",
                        "name": "Unknown Pack",
                        "used_in_game": True,
                        "license_status": "unverified",
                    }
                ],
            }
            (project / "data" / "asset_provenance.json").write_text(json.dumps(manifest))
            result, report = self.run_audit(root)
            self.assertEqual(result.returncode, 0)
            self.assertEqual(report["counts"]["unverified_used_assets"], 1)
            self.assertTrue(any(item["code"] == "USED_ASSET_LICENSE_UNVERIFIED" for item in report["findings"]))

    def test_unused_unlicensed_asset_is_not_a_release_warning(self):
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp)
            project = self.fixture(root)
            (project / "assets" / "art" / "CREDITS.md").write_text(
                "| not used: old pack | unknown | No licence file | not imported |\n"
            )
            result, report = self.run_audit(root)
            self.assertEqual(result.returncode, 0)
            self.assertEqual(report["counts"]["unverified_asset_entries"], 0)
            self.assertEqual(report["summary"]["warnings"], 0)

    def test_rune_inventory_counts_kinds_and_rejects_malformed_entries(self):
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp)
            project = self.fixture(root)
            runes = {
                "runes": {
                    "mend": {"name": "Mending Rune", "kind": "magic"},
                    "thorn": {"name": "Thorn Rune", "kind": "passive"},
                    "broken": {"kind": "passive"},
                }
            }
            (project / "data" / "runes.json").write_text(json.dumps(runes))
            result, report = self.run_audit(root)
            self.assertEqual(result.returncode, 1)
            self.assertEqual(report["counts"]["rune_definitions"], 3)
            self.assertEqual(report["counts"]["rune_kinds"], {"magic": 1, "passive": 1})
            self.assertTrue(any(item["code"] == "RUNE_DEFINITION_INVALID" for item in report["findings"]))


if __name__ == "__main__":
    unittest.main()
