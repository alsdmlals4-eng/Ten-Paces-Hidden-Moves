"""Exercise real input and two independent Godot processes with isolated settings."""
import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]


class PresentationPreferencesRestart(unittest.TestCase):
    def test_independent_process_restart(self):
        binary = os.environ.get("GODOT_BIN") or shutil.which("godot")
        if not binary:
            self.skipTest("Set GODOT_BIN or provide godot on PATH; native product CI supplies it")
        artifacts = Path(tempfile.mkdtemp(prefix="ten-paces-preferences-"))
        print(f"Preference test artifacts retained: {artifacts}")
        for mode in ("write", "read"):
            result = subprocess.run(
                [binary, "--headless", "--path", str(ROOT), "--script",
                 "res://tests/verify_presentation_preferences_runtime.gd", "--",
                 mode, str(artifacts / "settings.cfg")],
                capture_output=True, text=True, encoding="utf-8", errors="replace", timeout=110,
            )
            output = result.stdout + result.stderr
            (artifacts / f"{mode}.log").write_text(output, encoding="utf-8")
            self.assertEqual(result.returncode, 0, output)
            self.assertNotIn("SCRIPT ERROR", output)
            self.assertIn(f"PREFERENCES_RUNTIME PASS mode={mode}", output)
            print(output)


if __name__ == "__main__":
    unittest.main()
