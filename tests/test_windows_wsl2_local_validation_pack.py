from __future__ import annotations

import importlib.util
import json
import re
import subprocess
import tempfile
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
DECISION_ID = "TEN-DEC-20260807-WINDOWS-WSL2-LOCAL-VALIDATION-PACK-01"
CONTRACT = ROOT / "docs/planning-data/approved_20260807_windows_wsl2_local_validation_pack.json"
DECISION = ROOT / "docs/decisions/2026-08-07_WINDOWS_WSL2_LOCAL_VALIDATION_PACK_DECISION.md"
MANIFEST = ROOT / "tools/local_validation/matrix_contract_commands.json"
RUNNER = ROOT / "tools/local_validation/run_matrix_contracts.py"
ORCHESTRATOR = ROOT / "tools/run_windows_wsl2_validation.ps1"
VALIDATOR = ROOT / "tools/check_windows_wsl2_local_validation_pack.py"
GUIDE = ROOT / "docs/verification/WINDOWS_WSL2_LOCAL_VALIDATION_PACK.md"
WORKFLOW = ROOT / ".github/workflows/full-validation.yml"


def load_runner():
    spec = importlib.util.spec_from_file_location("local_matrix_runner", RUNNER)
    if spec is None or spec.loader is None:
        raise AssertionError("runner module could not be loaded")
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


class WindowsWsl2LocalValidationPackTests(unittest.TestCase):
    def test_contract_pins_required_four_environment_matrix(self) -> None:
        payload = json.loads(CONTRACT.read_text(encoding="utf-8"))
        self.assertEqual(payload["decision_id"], DECISION_ID)
        matrix = payload["matrix"]
        self.assertEqual(
            [(item["id"], item["host"], item["python"]) for item in matrix],
            [
                ("windows-py311", "windows", "3.11"),
                ("windows-py312", "windows", "3.12"),
                ("windows-py313", "windows", "3.13"),
                ("wsl2-ubuntu-py312", "wsl2-ubuntu", "3.12"),
            ],
        )
        self.assertTrue(all(item["required"] for item in matrix))
        self.assertEqual(payload["workflow_source"], ".github/workflows/full-validation.yml")
        self.assertEqual(payload["workflow_job"], "matrix-contracts")

    def test_manifest_matrix_commands_match_full_validation_workflow(self) -> None:
        payload = json.loads(MANIFEST.read_text(encoding="utf-8"))
        workflow_text = WORKFLOW.read_text(encoding="utf-8")
        matrix_block = workflow_text.split("\n  matrix-contracts:\n", 1)[1].split(
            "\n  godot-headless:\n", 1
        )[0]
        workflow_commands = re.findall(r"^\s+run:\s+(.+)$", matrix_block, re.MULTILINE)
        manifest_commands = [item["workflow_run"] for item in payload["matrix_contract_commands"]]
        self.assertEqual(manifest_commands, workflow_commands)
        self.assertEqual(len(manifest_commands), 15)

    def test_runner_enforces_python_version_and_git_cleanliness(self) -> None:
        runner = load_runner()
        runner.require_python_version("3.13", (3, 13, 5))
        with self.assertRaisesRegex(RuntimeError, "PYTHON_VERSION_MISMATCH"):
            runner.require_python_version("3.12", (3, 13, 5))

        with tempfile.TemporaryDirectory() as temp_dir:
            root = Path(temp_dir)
            subprocess.run(["git", "init", "-q", str(root)], check=True)
            subprocess.run(["git", "-C", str(root), "config", "user.email", "test@example.com"], check=True)
            subprocess.run(["git", "-C", str(root), "config", "user.name", "Test"], check=True)
            (root / "tracked.txt").write_text("clean\n", encoding="utf-8")
            subprocess.run(["git", "-C", str(root), "add", "tracked.txt"], check=True)
            subprocess.run(["git", "-C", str(root), "commit", "-qm", "init"], check=True)
            self.assertTrue(runner.git_is_clean(root))
            expected_head = runner.git_head(root)
            self.assertEqual(len(expected_head), 40)
            (root / "tracked.txt").write_text("dirty\n", encoding="utf-8")
            self.assertFalse(runner.git_is_clean(root))

    def test_orchestrator_requires_all_four_environments_and_wsl2(self) -> None:
        text = ORCHESTRATOR.read_text(encoding="utf-8")
        for marker in (
            "windows-py311",
            "windows-py312",
            "windows-py313",
            "wsl2-ubuntu-py312",
            '"-3.11"',
            '"-3.12"',
            '"-3.13"',
            "python3.12",
            "wsl.exe",
            "uname",
            "WSL2",
            "git status --porcelain",
            "ALL_REQUIRED_ENVIRONMENTS_MUST_PASS",
        ):
            self.assertIn(marker, text)
        self.assertNotIn("Skip", text)
        self.assertNotIn("--skip", text)

    def test_orchestrator_resolves_wsl_root_from_inherited_working_directory(self) -> None:
        text = ORCHESTRATOR.read_text(encoding="utf-8")
        self.assertIn(
            '-Arguments @("-d", $WslDistribution, "--", "pwd") -WorkingDirectory $RepoRoot',
            text,
        )
        self.assertNotIn('"wslpath"', text)

    def test_contract_is_fail_closed_and_keeps_claim_ceiling(self) -> None:
        payload = json.loads(CONTRACT.read_text(encoding="utf-8"))
        requirements = payload["requirements"]
        for key in (
            "exact_head_required",
            "clean_tree_before_after_required",
            "all_four_environments_required",
            "workflow_command_parity_required",
            "per_environment_json_required",
            "combined_summary_required",
            "head_change_invalidates",
            "no_dependency_install",
        ):
            self.assertTrue(requirements[key], key)
        limitations = payload["limitations"]
        self.assertEqual(limitations["godot_execution"], "NOT_INCLUDED")
        self.assertEqual(limitations["gut_execution"], "NOT_INCLUDED")
        self.assertEqual(limitations["product_implementation_effect"], "NONE")
        self.assertEqual(payload["status"], "PACK_IMPLEMENTED_LOCAL_EXECUTION_PENDING")

    def test_decision_guide_and_validator_are_linked(self) -> None:
        decision = DECISION.read_text(encoding="utf-8")
        guide = GUIDE.read_text(encoding="utf-8")
        validator = VALIDATOR.read_text(encoding="utf-8")
        for marker in (
            DECISION_ID,
            "Windows Python 3.11",
            "Windows Python 3.12",
            "Windows Python 3.13",
            "WSL2 Ubuntu Python 3.12",
            "PACK_IMPLEMENTED_LOCAL_EXECUTION_PENDING",
            "CURRENT_HEAD_GODOT_GUT_NOT_RUN",
        ):
            self.assertIn(marker, decision)
        self.assertIn("run_windows_wsl2_validation.ps1", guide)
        self.assertIn("matrix-contracts", validator)
        self.assertIn("WORKFLOW_COMMAND_DRIFT", validator)


if __name__ == "__main__":
    unittest.main()
