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

    def test_exact_editor_requires_explicit_path_argument(self) -> None:
        self.assertIn("EXACT_GODOT_REQUIRES_PATH_ARGUMENT", self.text)
        self.assertRegex(self.text, r"(?i)--path")
        self.assertIn("MULTIPLE_EXACT_TEN_PACES_GODOT_EDITORS", self.text)

    def test_project_tooling_is_prebound_before_editor_start(self) -> None:
        for token in (
            "Get-ProjectSectionText",
            "[editor_plugins]",
            "[autoload]",
            "REQUIRED_TOOLING_AUTOLOAD_NOT_PREBOUND_BOOTSTRAP_WOULD_MUTATE_PROJECT",
            "HeraGameInspector",
            "_mcp_game_helper",
            r"res://addons/gut/plugin.cfg",
            "GUT_VERSION_MISMATCH_EXPECTED_9_7_1",
            "GUT_VERSION=",
        ):
            self.assertIn(token, self.text)

    def test_editor_settings_use_verified_headless_editor_tool_context(self) -> None:
        for token in (
            "_sc_",
            "Invoke-HeadlessEditorTool",
            "@tool",
            "bootstrap.tscn",
            "EditorInterface.get_editor_settings()",
            "godot_ai/http_port",
            "godot_ai/ws_port",
            "godot_ai/keep_server_on_exit",
        ):
            self.assertIn(token, self.text)
        self.assertRegex(self.text, r"(?m)get_tree\(\)\.quit\(|\bquit\(")
        self.assertNotIn("--recovery-mode", self.text)
        self.assertNotRegex(self.text, r"(?i)['\"]--script['\"]")
        self.assertNotRegex(self.text, r"(?i)editor_settings-4\.tres.*-replace")

    def test_hera_exact_project_auth_recovery_is_supported_and_secret_safe(self) -> None:
        for token in (
            ".hera-agent-godot",
            "instances",
            "project_path",
            "8770",
            "8785",
            "HERA_AGENT_GODOT_TOKEN",
            "$HeraTokenFile = Join-Path $TargetGodot '.hera-token'",
            "$HeraSharedTokenFile = Join-Path $HeraHome 'token'",
            "Resolve-HeraAuthForExactInstance",
            "inherited_env",
            "project_token",
            "shared_token",
            "no_token",
            "HERA_AUTH_SOURCE=",
            "HERA_EXACT_PROJECT_READY",
        ):
            self.assertIn(token, self.text)
        self.assertNotRegex(self.text, r"(?i)Write-Host[^\\n]*\$CandidateToken")
        self.assertNotRegex(self.text, r"(?i)Hera.*FORBIDDEN")

    def test_codex_mcp_config_uses_project_godot_ai_configurator(self) -> None:
        self.assertIn('preload("res://addons/godot_ai/client_configurator.gd")', self.text)
        self.assertIn('Configurator.configure("codex", "http://127.0.0.1:8003/mcp", context)', self.text)
        self.assertIn("CODEX_GODOT_AI_CONFIGURE_FAILED", self.text)
        self.assertNotRegex(self.text, r"(?i)codex(?:\.cmd)?\s+mcp\s+add")

    def test_codex_native_stderr_login_state_is_semantically_classified(self) -> None:
        for token in (
            "CODEX_DEDICATED_HOME_LOGIN_REQUIRED",
            "CODEX_LOGIN_STATUS_UNSUPPORTED",
            "CODEX_LOGIN_READY",
            "Not logged in",
            "Invoke-Capture $CodexExe @('login', 'status')",
        ):
            self.assertIn(token, self.text)
        self.assertRegex(self.text, r"&\s+\$CodexExe\s+login\b")
        self.assertNotRegex(self.text, r"(?i)Copy-Item[^\n]*\\\.codex\\auth\.json")

    def test_ports_fail_closed_without_unrelated_process_kill_or_auto_switch(self) -> None:
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

    def test_codex_help_preflight_precedes_launch(self) -> None:
        help_marker = self.text.find("CODEX_HELP_PREFLIGHT_COMPLETE")
        launch_call = self.text.rfind("Start-Codex -CodexExe")
        self.assertGreaterEqual(help_marker, 0)
        self.assertGreater(launch_call, help_marker)
        for token in ("workspace-write", "never", "--ask-for-approval", "--sandbox"):
            self.assertIn(token, self.text)

    def test_bootstrap_does_not_claim_live_readiness(self) -> None:
        for token in (
            "BOOTSTRAP_READY_FOR_CODEX",
            "LIVE_READINESS_MUST_BE_RECHECKED_IN_CODEX",
            "HERA_EXACT_PROJECT_READY",
        ):
            self.assertIn(token, self.text)


if __name__ == "__main__":
    unittest.main()
