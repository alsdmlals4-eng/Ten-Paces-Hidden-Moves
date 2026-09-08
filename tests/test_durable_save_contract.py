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
    def native(self, *arguments, script="verify_run_save_store.gd", marker="RUN_SAVE_STORE: PASS", entry="--script"):
        binary = godot_binary()
        if not binary:
            self.skipTest("Native Godot unavailable; CI executes the dedicated Godot workflow step")
        result = subprocess.run(
            [binary, "--headless", "--path", str(ROOT), entry, "res://tests/" + script, "--", *arguments],
            cwd=ROOT, text=True, encoding="utf-8", errors="replace", capture_output=True, timeout=240,
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

    def test_actual_shell_transactions_recovery_and_lifecycle(self):
        self.native(script="verify_durable_run_continue.gd", marker="DURABLE_CONTINUE PASS")

    def test_script_entries_default_to_no_production_storage(self):
        for entry in ["--script", "-s"]:
            self.native(script="verify_save_entry_isolation.gd", marker="SCRIPT_ENTRY_ISOLATION PASS", entry=entry)

    def test_actual_continue_across_real_process_exits(self):
        with tempfile.TemporaryDirectory(prefix="ten-paces-shell-process-") as directory:
            phases = ["baseline", "planning", "committed", "resolved", "result", "pending_reward", "route", "retry", "completion"]
            phases += [kind + "_" + boundary for kind in ["martial", "ultimate"] for boundary in ["baseline", "committed", "resolved"]]
            phases += ["terminal_baseline", "terminal_gap"]
            for phase in phases:
                self.native("write", phase, directory, script="durable_continue_process.gd", marker="FRESH_SHELL_WRITE PASS")
            for phase in phases:
                for _ in range(2):
                    self.native("read", phase, directory, script="durable_continue_process.gd", marker="FRESH_SHELL_READ PASS")

    def test_checkpoint_rehydrates_in_an_independent_process(self):
        with tempfile.TemporaryDirectory(prefix="ten-paces-independent-save-") as directory:
            self.native("--checkpoint-write", directory)
            self.native("--checkpoint-read", directory)


if __name__ == "__main__":
    unittest.main()
