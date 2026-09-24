"""Native resolver and scene regressions for the approved ink presentation."""
import unittest
from tests import test_combat_feedback_correction as feedback


class InkCombatRuntimeTests(unittest.TestCase):
    native = feedback.CombatFeedbackCorrectionTests.native

    def test_read_only_resolver_projection(self):
        self.native("verify_ink_resolution_model.gd", "INK_RESOLUTION_MODEL checks=")

    def test_full_bundles_pause_restart_and_existing_planning(self):
        self.native("verify_ink_combat_runtime.gd", "INK_COMBAT_RUNTIME failures=0")

    def test_card_fact_sequence(self):
        self.native("verify_card_motion_presets.gd", "CARD_MOTION_PRESETS")

    def test_readable_results_and_matching_screen_art(self):
        self.native("verify_ink_screen_refresh.gd", "INK_SCREEN_REFRESH failures=0")

    def test_current_enemy_sprites_have_real_alpha_and_match_profiles(self):
        import json, hashlib
        from PIL import Image
        for opponent in ['masked','dogyeom']:
            profile = json.loads((feedback.ROOT / f'data/presentation/{opponent}_ink_opponent.json').read_text(encoding='utf-8'))
            self.assertEqual(len(profile['poses']),9)
            for pose in profile['poses']:
                path = feedback.ROOT / pose['path'].removeprefix('res://')
                with Image.open(path) as image:
                    self.assertEqual(image.mode,'RGBA')
                    alpha=image.getchannel('A')
                    self.assertEqual(alpha.getextrema(),(0,255))
                    self.assertTrue(alpha.getbbox())
                    self.assertTrue(all(alpha.getpixel(xy)==0 for xy in [(0,0),(image.width-1,0),(0,image.height-1),(image.width-1,image.height-1)]))

    def test_regressions_are_run_after_import_in_product_ci(self):
        workflow = (feedback.ROOT / ".github/workflows/validate-ten-manual-product-gate.yml").read_text(encoding="utf-8")
        job = workflow.split("  automated-product-evidence:", 1)[1].split("  windows-product-evidence:", 1)[0]
        for script in ("verify_ink_resolution_model.gd", "verify_ink_combat_runtime.gd", "verify_card_motion_presets.gd","verify_ink_screen_refresh.gd"):
            command = "run: godot --headless --path . --script res://tests/" + script
            self.assertIn(command, job)
            self.assertGreater(job.index(command), job.index("run: godot --headless --editor --path . --quit"))


if __name__ == "__main__":
    unittest.main()
