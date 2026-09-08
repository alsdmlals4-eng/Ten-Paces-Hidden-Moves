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


if __name__ == "__main__":
    unittest.main()
