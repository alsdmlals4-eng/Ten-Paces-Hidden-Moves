"""Keep the approved presentation regressions in the normal test entrypoint."""
import os
from pathlib import Path
import shutil
import subprocess
import unittest

ROOT = Path(__file__).resolve().parents[1]
CASES = (
    ("motion_roster_integration", "MOTION_ROSTER_INTEGRATION_PASS"),
    ("clash_recovery_readability", "CLASH_RECOVERY_READABILITY_PASS"),
    ("wuxia_paper_surfaces", "WUXIA_PAPER_SURFACES_PASS"),
    ("clash_alpha_vfx", "CLASH_ALPHA_VFX_PASS"),
    ("compact_timing_labels", "COMPACT_TIMING_LABELS_PASS"),
    ("preparation_art_fill", "PREPARATION_ART_FILL_PASS"),
    ("wuxia_sound_envelopes", "WUXIA_SOUND_ENVELOPES_PASS"),
    ("battle_first_layout", "BATTLE_FIRST_LAYOUT_PASS"),
    ("character_pose_animation", "CHARACTER_POSE_ANIMATION_PASS"),
    ("combat_impact_camera", "COMBAT_IMPACT_CAMERA_PASS"),
    ("compact_action_detail", "COMPACT_ACTION_DETAIL_PASS"),
    ("execution_visual_contract", "EXECUTION_VISUAL_CONTRACT_PASS"),
    ("flat_martial_grid", "FLAT_MARTIAL_GRID_PASS"),
    ("portrait_hud", "PORTRAIT_HUD_PASS"),
    ("pose_cache_ready", "POSE_CACHE_READY_PASS"),
    ("preparation_columns", "PREPARATION_COLUMNS_PASS"),
    ("visual_distance_spacing", "VISUAL_DISTANCE_SPACING_PASS"),
    ("dogyeom_status_portrait", "DOGYEOM_STATUS_PORTRAIT_VERIFY_OK"),
)


class VisualContinuationTests(unittest.TestCase):
    def test_native_visual_contracts(self):
        binary = os.environ.get("GODOT_BIN") or shutil.which("godot")
        if not binary:
            self.skipTest("Set GODOT_BIN to run native visual regressions")
        for name, marker in CASES:
            with self.subTest(name=name):
                result = subprocess.run(
                    [binary, "--headless", "--path", str(ROOT), "--script",
                     "res://tests/verify_" + name + ".gd"],
                    cwd=ROOT, capture_output=True, text=True, encoding="utf-8",
                    errors="replace", timeout=120,
                )
                output = result.stdout + result.stderr
                self.assertEqual(result.returncode, 0, output)
                self.assertNotIn("SCRIPT ERROR", output)
                self.assertIn(marker, output)


if __name__ == "__main__":
    unittest.main()
