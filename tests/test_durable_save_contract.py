"""Execute the native durable contract and a separate-process continuation."""
import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]


def godot_binary():
    configured = os.environ.get("GODOT_BIN") or shutil.which("godot")
    if configured:
        return configured
    local = Path("C:/Users/user/Downloads/Godot_v4.7.1-stable_win64.exe/Godot_v4.7.1-stable_win64_console.exe")
    return str(local) if local.exists() else None


class DurableSaveContractTests(unittest.TestCase):
    def native(self, *arguments, script="verify_run_save_store.gd", marker="RUN_SAVE_STORE: PASS"):
        binary = godot_binary()
        if not binary:
            self.skipTest("Native Godot unavailable; CI executes the dedicated Godot workflow step")
        result = subprocess.run(
            [binary, "--headless", "--path", str(ROOT), "--script", "res://tests/" + script, "--", *arguments],
            cwd=ROOT, text=True, encoding="utf-8", errors="replace", capture_output=True, timeout=75,
        )
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn("SCRIPT ERROR", output)
        self.assertIn(marker, output)

    def test_combat_boundaries_restore_in_independent_process(self):
        with tempfile.TemporaryDirectory(prefix="ten-paces-independent-combat-") as directory:
            for mode in ["--checkpoint-write", "--checkpoint-read"]:
                self.native(mode, directory, script="verify_combat_checkpoint_resume.gd", marker="COMBAT_CHECKPOINT_RESUME: PASS")

    def test_native_corruption_retry_and_generation_contract(self):
        self.native()

    def test_checkpoint_rehydrates_in_an_independent_process(self):
        with tempfile.TemporaryDirectory(prefix="ten-paces-independent-save-") as directory:
            self.native("--checkpoint-write", directory)
            self.native("--checkpoint-read", directory)


if __name__ == "__main__":
    unittest.main()
