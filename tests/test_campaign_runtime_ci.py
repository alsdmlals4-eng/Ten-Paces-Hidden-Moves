"""Keep the new campaign and presentation regressions in actual CI execution."""
from pathlib import Path
import unittest


class CampaignRuntimeCiTest(unittest.TestCase):
    def test_product_job_executes_campaign_and_presentation_regressions(self):
        root = Path(__file__).resolve().parents[1]
        workflow = (root / ".github/workflows/validate-ten-manual-product-gate.yml").read_text(encoding="utf-8")
        job = workflow.split("  automated-product-evidence:", 1)[1].split("  windows-product-evidence:", 1)[0]
        for script in (
            "probe_sequential_ten_duel_campaign",
            "verify_ten_duel_campaign",
            "verify_vertical_slice_failure_retry",
            "verify_action_card_summary",
            "verify_jianghu_rest_presentation",
            "verify_atlas_presentation_successor",
            "verify_inline_combat_results",
        ):
            with self.subTest(script=script):
                self.assertTrue((root / "tests" / f"{script}.gd").is_file())
                self.assertIn(f"run: godot --headless --path . --script res://tests/{script}.gd", job)

    def test_inline_and_bridge_regressions_are_both_invoked_by_ci(self):
        root = Path(__file__).resolve().parents[1]
        product = (root / ".github/workflows/full-validation.yml").read_text(encoding="utf-8")
        bridge = (root / ".github/workflows/validate-vertical-slice-run-state.yml").read_text(encoding="utf-8")
        self.assertIn("run: godot --headless --path . --script res://tests/verify_inline_combat_results.gd", product)
        self.assertIn("run: godot --headless --path . --script res://tests/verify_vertical_slice_combat_bridge.gd", bridge)


if __name__ == "__main__":
    unittest.main()
