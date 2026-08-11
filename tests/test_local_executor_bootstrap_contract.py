from pathlib import Path
import re
import unittest

ROOT = Path(__file__).resolve().parents[1]
SCRIPT = ROOT / "tools" / "start_ten_paces_local_executor.ps1"


class LocalExecutorBootstrapContractTests(unittest.TestCase):
    def setUp(self) -> None:
        self.assertTrue(SCRIPT.exists(), f"missing launcher: {SCRIPT}")
        self.text = SCRIPT.read_text(encoding="utf-8")

    def test_exact_ten_paces_binding(self) -> None:
        required = (
            r"C:\Users\user\Documents\GitHub\Ninza\Ten-Paces-Hidden-Moves",
            r"C:\Users\user\Tools\Godot-Ten-Paces-4.7.1",
            "Godot_v4.7.1-stable_win64.exe",
            "8003",
            "9503",
            r"C:\Users\user\.codex-ten-paces",
            "CODEX_HOME",
        )
        for token in required:
            self.assertIn(token, self.text)

    def test_self_contained_and_editor_settings_are_programmatic(self) -> None:
        self.assertIn("_sc_", self.text)
        self.assertIn("--recovery-mode", self.text)
        self.assertIn("EditorInterface.get_editor_settings()", self.text)
        self.assertIn("godot_ai/http_port", self.text)
        self.assertIn("godot_ai/ws_port", self.text)
        self.assertIn("godot_ai/keep_server_on_exit", self.text)
        self.assertNotRegex(self.text, r"(?i)editor_settings-4\.tres.*-replace")

    def test_hera_is_exact_project_dynamic_port_tooling(self) -> None:
        for token in (
            ".hera-agent-godot",
            "instances",
            "project_path",
            "8770",
            "8785",
            "HERA_AGENT_GODOT_TOKEN",
            "hera",
            "status",
        ):
            self.assertIn(token, self.text)
        self.assertIn("$HeraTokenFile = Join-Path $TargetGodot '.hera-token'", self.text)
        self.assertNotIn("Join-Path $HeraHome 'token'", self.text)
        self.assertNotRegex(self.text, r"(?i)Hera.*FORBIDDEN")

    def test_codex_mcp_config_uses_project_godot_ai_configurator(self) -> None:
        self.assertIn('preload("res://addons/godot_ai/client_configurator.gd")', self.text)
        self.assertIn('Configurator.configure("codex", "http://127.0.0.1:8003/mcp", context)', self.text)
        self.assertIn("CODEX_GODOT_AI_CONFIGURE_FAILED", self.text)
        self.assertNotRegex(self.text, r"(?i)codex(?:\.cmd)?\s+mcp\s+add")

    def test_ports_fail_closed_without_process_kill_or_auto_switch(self) -> None:
        self.assertIn("FOREIGN_OR_AMBIGUOUS_PORT_OWNER", self.text)
        self.assertIn("HIGODOT_EXPECTED_PORT_NOT_READY", self.text)
        forbidden = (
            r"Stop-Process\s+.*-Force",
            r"taskkill\b",
            r"Get-NetTCPConnection[^\n]+\|\s*Stop-Process",
            r"git\s+reset\b",
            r"git\s+restore\b",
            r"git\s+clean\b",
            r"git\s+add\b",
        )
        for pattern in forbidden:
            self.assertIsNone(re.search(pattern, self.text, re.IGNORECASE))
        self.assertNotIn("8004", self.text)
        self.assertNotIn("9504", self.text)

    def test_codex_help_preflight_precedes_launch_call(self) -> None:
        help_marker = self.text.find("CODEX_HELP_PREFLIGHT_COMPLETE")
        launch_call = self.text.rfind("Start-Codex -CodexExe")
        self.assertGreaterEqual(help_marker, 0)
        self.assertGreater(launch_call, help_marker)
        self.assertIn("workspace-write", self.text)
        self.assertIn("never", self.text)
        self.assertIn("--ask-for-approval", self.text)
        self.assertIn("--sandbox", self.text)

    def test_bootstrap_distinguishes_launch_from_readiness(self) -> None:
        self.assertIn("BOOTSTRAP_READY_FOR_CODEX", self.text)
        self.assertIn("LIVE_READINESS_MUST_BE_RECHECKED_IN_CODEX", self.text)
        self.assertIn("HERA_EXACT_PROJECT_READY", self.text)


if __name__ == "__main__":
    unittest.main()
