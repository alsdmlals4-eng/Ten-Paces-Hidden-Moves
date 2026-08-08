from __future__ import annotations

import re
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SCRIPT = ROOT / "tools" / "collect_godot_live_evidence.ps1"


class LocalGodotEvidenceCollectorContractTests(unittest.TestCase):
    def setUp(self) -> None:
        self.assertTrue(SCRIPT.is_file(), f"missing collector: {SCRIPT}")
        self.text = SCRIPT.read_text(encoding="utf-8")

    def test_read_only_safety_contract(self) -> None:
        for token in [
            "READ_ONLY_EVIDENCE_COLLECTOR",
            "LOCAL_SYNC_BLOCKED_DIRTY_WORKTREE",
            "LOCAL_SYNC_BLOCKED_LOCAL_ONLY_COMMITS",
            "LOCAL_SYNC_BLOCKED_DIVERGED_MAIN",
            "LOCAL_SYNC_READY_FAST_FORWARD",
            "PROJECT_MUTATION_ATTEMPTED_FALSE",
            "NOT_RUN_DIRTY_WORKTREE_SAFETY",
        ]:
            self.assertIn(token, self.text)

        forbidden_patterns = [
            r"(?im)^\s*git\s+(pull|reset|clean|stash|commit|checkout|switch|merge|rebase)\b",
            r"(?im)&\s*git\s+(pull|reset|clean|stash|commit|checkout|switch|merge|rebase)\b",
        ]
        for pattern in forbidden_patterns:
            self.assertIsNone(re.search(pattern, self.text), pattern)

    def test_collects_required_tool_and_project_evidence(self) -> None:
        for token in [
            "ProjectPath",
            "GodotPath",
            "HeraPath",
            "OutputDir",
            "project.godot",
            "addons/godot_ai/plugin.cfg",
            "addons/gut/plugin.cfg",
            "addons/hera_agent_godot/plugin.cfg",
            "run/main_scene",
            "editor_plugins",
            "gut_cmdln.gd",
            "smoke",
            "--skip-game",
            "HERA_SOURCE_DELTA_NONE",
            "HERA_CLI_NOT_FOUND_OR_PATH_UNSET",
            "GODOT_EXECUTABLE_UNRESOLVED",
        ]:
            self.assertIn(token, self.text)

    def test_redacts_secrets_and_writes_json_under_ignored_build_tree(self) -> None:
        for token in [
            "Protect-SecretText",
            "[REDACTED]",
            "build/local-validation",
            "ConvertTo-Json",
            "godot-live-evidence.json",
        ]:
            self.assertIn(token, self.text)


if __name__ == "__main__":
    unittest.main()
