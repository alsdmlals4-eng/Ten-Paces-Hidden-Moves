from __future__ import annotations

import json
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
VISUAL = ROOT / "docs" / "planning-data" / "current_visual_production_handoff_20260826.json"
PLANNING = ROOT / "docs" / "planning-data" / "current_user_planning_status.json"
GATE = ROOT / "docs" / "19_VISUAL_PRODUCTION_CURRENT_GATE_2026-08-26.md"
DECISION_ID = "TEN-DEC-20260826-VISUAL-CONSUMER-ASSET-PRODUCTION-01"


class VisualConsumerAssetProductionPolicyTests(unittest.TestCase):
    def test_current_visual_queue_is_consumer_first_not_explanatory_sheet_first(self) -> None:
        visual = json.loads(VISUAL.read_text(encoding="utf-8"))
        planning = json.loads(PLANNING.read_text(encoding="utf-8"))
        gate = GATE.read_text(encoding="utf-8")

        self.assertEqual(DECISION_ID, visual["current_visual_production_decision"])
        self.assertEqual("ACTUAL_GAME_CONSUMER_REQUIRED", visual["consumer_first_asset_policy"])
        self.assertEqual("USER_APPROVED_2026_08_26", visual["approved_results"]["OPPONENT_CHARACTER_MASTER_01"]["status"])
        self.assertEqual("PASS", visual["approved_results"]["OPPONENT_CHARACTER_MASTER_01"]["notion_delivery"])

        battler = visual["approved_results"]["DOGYEOM_COMBAT_BATTLER_01"]
        self.assertEqual("USER_APPROVED_2026_08_26", battler["status"])
        self.assertEqual("PASS", battler["notion_delivery"])
        self.assertFalse(battler["runtime_asset"])
        self.assertEqual("src/combat/combat_character_placeholder.gd", battler["consumer"])
        self.assertEqual("NOT_RUN", battler["opponent_specific_routing"])

        self.assertEqual("DOGYEOM_STATUS_PORTRAIT_01", visual["next_result"]["id"])
        self.assertEqual("src/ui/combatant_status_panel.gd", visual["next_result"]["consumer"])
        self.assertEqual("PREFER_NON_GENERATIVE_CROP_FROM_APPROVED_MASTER", visual["next_result"]["derivation_policy"])
        self.assertEqual("GPT_WORK_RESUME_REQUIRED", visual["next_result"]["generation_status"])
        self.assertEqual(["DOGYEOM_STATUS_PORTRAIT_01"], planning["next_visual_batch"])
        self.assertEqual("GPT_WORK", planning["next_execution_surface"])

        serialized_queue = json.dumps(visual.get("deferred_queue_after_result_review", []), ensure_ascii=False)
        self.assertNotIn("MARTIAL_TECHNIQUE_ILLUSTRATION_SHEET_01", serialized_queue)
        self.assertIn("실제 게임 소비처", gate)
        self.assertIn("DOGYEOM_COMBAT_BATTLER_01", gate)
        self.assertIn("DOGYEOM_STATUS_PORTRAIT_01", gate)
        self.assertIn("src/ui/combatant_status_panel.gd", gate)
        self.assertIn("CardView.illustration", gate)
        self.assertIn("GPT Work", gate)


if __name__ == "__main__":
    unittest.main()
