"""Run the focused native combat-feedback behavior regressions."""
import os
from pathlib import Path
import shutil
import subprocess
import unittest


ROOT = Path(__file__).resolve().parents[1]


def godot_binary():
    configured = os.environ.get("GODOT_BIN") or shutil.which("godot")
    if configured:
        return configured
    local = Path("C:/Users/user/Downloads/Godot_v4.7.1-stable_win64.exe/Godot_v4.7.1-stable_win64_console.exe")
    return str(local) if local.exists() else None


class CombatFeedbackCorrectionTests(unittest.TestCase):
    def native(self, script, marker):
        binary = godot_binary()
        if not binary:
            self.skipTest("Native Godot unavailable; CI executes the dedicated Godot workflow step")
        result = subprocess.run(
            [binary, "--headless", "--path", str(ROOT), "--script", "res://tests/" + script],
            cwd=ROOT,
            text=True,
            encoding="utf-8",
            errors="replace",
            capture_output=True,
            timeout=120,
        )
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn("SCRIPT ERROR", output)
        self.assertIn(marker, output)

    def test_outcome_helper_board_bridge_and_authored_cues(self):
        self.native("verify_combat_outcome_feedback.gd", "COMBAT_OUTCOME_FEEDBACK_VERIFY_OK")

    def test_existing_terminal_flow_requests_victory_cue(self):
        self.native("verify_combat_terminal_presentation.gd", "COMBAT_TERMINAL_PRESENTATION_VERIFY_OK")

    def test_actor_owned_ultimate_presentation_profiles(self):
        self.native("verify_actor_ultimate_presentation.gd", "ACTOR_ULTIMATE_PRESENTATION_VERIFY_OK")

    def test_native_feedback_regressions_run_in_automated_product_evidence(self):
        workflow_path = ROOT / ".github" / "workflows" / "validate-ten-manual-product-gate.yml"
        workflow = workflow_path.read_text(encoding="utf-8")
        job_start = workflow.index("  automated-product-evidence:")
        job_end = workflow.index("  windows-product-evidence:", job_start)
        job = workflow[job_start:job_end]
        job_lines = job.splitlines()
        import_index = job_lines.index("        run: godot --headless --editor --path . --quit")
        push_start = workflow.index("  push:")
        push_end = workflow.index("  pull_request:", push_start)
        push_lines = workflow[push_start:push_end].splitlines()
        for script in (
            "tests/verify_combat_outcome_feedback.gd",
            "tests/verify_actor_ultimate_presentation.gd",
            "tests/verify_frontal_duel_screen_partition.gd",
            "tests/verify_combat_action_reveal.gd",
        ):
            with self.subTest(script=script):
                self.assertTrue((ROOT / script).is_file(), script)
                command = "        run: godot --headless --path . --script res://" + script
                self.assertIn(command, job_lines)
                self.assertGreater(job_lines.index(command), import_index)
                self.assertIn(f'      - "{script}"', push_lines)


if __name__ == "__main__":
    unittest.main()
