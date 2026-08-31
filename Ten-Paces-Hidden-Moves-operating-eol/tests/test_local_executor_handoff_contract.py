from pathlib import Path
import unittest

ROOT = Path(__file__).resolve().parents[1]
VERIFY_SKILL = ROOT / "skills" / "qa" / "ten-paces-verification" / "SKILL.md"
LEARNING_LOG = ROOT / "skills" / "SKILL_LEARNING_LOG.md"
ACTIVE_CONTEXT = ROOT / "[기획서]" / "00_프로젝트_허브" / "ACTIVE_CONTEXT.md"
HANDOFF = ROOT / "[기획서]" / "00_프로젝트_허브" / "HANDOFF.md"
LAUNCHER = ROOT / "tools" / "start_ten_paces_local_executor.ps1"
CURRENT_CONTRACT = ROOT / "docs" / "PROJECT_TOTAL_PLANNING_IMPLEMENTATION_AND_DELIVERY_INSTRUCTION.md"


class LocalExecutorHandoffContractTests(unittest.TestCase):
    def read(self, path: Path) -> str:
        self.assertTrue(path.exists(), f"missing required handoff artifact: {path}")
        return path.read_text(encoding="utf-8")

    def test_current_verification_owner_retires_local_codex_readiness_route(self) -> None:
        text = self.read(VERIFY_SKILL)
        contract = self.read(CURRENT_CONTRACT)
        self.assertIn("local-godot-validation-readiness", text)
        self.assertIn("CODEX_GODOT_PRODUCT_IMPLEMENTATION_HANDOFF", text)
        self.assertIn("local_codex_policy: RETIRED_NOT_USED", contract)
        self.assertIn("gpt_local_codex_orchestration_policy: RETIRED", contract)
        for stale_current_token in (
            "local-executor-readiness",
            "GODOT_AI_MCP_LIVE",
            "HERA_EXACT_PROJECT",
            "REPO_NO_NEW_MUTATION",
            "BOOTSTRAP_ORCHESTRATION_IS_NOT_READINESS_PASS",
            "HIGODOT_HTTP_8003",
            "HIGODOT_WS_9503",
        ):
            self.assertNotIn(stale_current_token, text)

    def test_learning_log_closes_four_local_executor_lessons(self) -> None:
        text = self.read(LEARNING_LOG)
        for token in (
            "LRN-TEN-LOCAL-001",
            "LRN-TEN-LOCAL-002",
            "LRN-TEN-LOCAL-003",
            "LRN-TEN-LOCAL-004",
            "headless editor",
            "NativeCommandError",
            "shared_token",
            "tools/start_ten_paces_local_executor.ps1",
        ):
            self.assertIn(token, text)

    def test_active_context_preserves_local_executor_checkpoint_as_history(self) -> None:
        text = self.read(ACTIVE_CONTEXT)
        for token in (
            "TEN-DEC-20260811-LOCAL-EXECUTOR-BOOTSTRAP-01",
            "LOCAL_EXECUTOR_HANDOFF_CHECKPOINT",
            "tools/start_ten_paces_local_executor.ps1",
            "IN_CODEX_FRESH_READINESS: NOT_RUN",
            "FRESH_POWERSHELL_REPEAT_RUN: NOT_RUN",
        ):
            self.assertIn(token, text)

    def test_handoff_preserves_historical_resume_evidence(self) -> None:
        text = self.read(HANDOFF)
        for token in (
            "TEN-DEC-20260811-LOCAL-EXECUTOR-BOOTSTRAP-01",
            "LOCAL_EXECUTOR_HANDOFF_CHECKPOINT",
            "IN_CODEX_FRESH_READINESS_GATE",
            "FRESH_POWERSHELL_REPEAT_RUN_GATE",
            "BASE_PROPOSAL_CONCURRENCY_REFETCH_REQUIRED",
            "tools/start_ten_paces_local_executor.ps1",
        ):
            self.assertIn(token, text)

    def test_persisted_launcher_remains_historical_artifact(self) -> None:
        text = self.read(LAUNCHER)
        self.assertIn("# Ten Paces Local Executor Launcher v5", text)
        self.assertIn("HERA_AUTH_SOURCE=", text)
        self.assertIn("LIVE_READINESS_MUST_BE_RECHECKED_IN_CODEX", text)
        current = self.read(CURRENT_CONTRACT)
        self.assertIn("GPT → PowerShell → local Codex one-shot launcher", current)
        self.assertIn("금지한다", current)


if __name__ == "__main__":
    unittest.main()
