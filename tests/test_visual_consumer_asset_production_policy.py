from __future__ import annotations

import json
from hashlib import sha256
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
VISUAL = ROOT / "docs" / "planning-data" / "current_visual_production_handoff_20260826.json"
PLANNING = ROOT / "docs" / "planning-data" / "current_user_planning_status.json"
GATE = ROOT / "docs" / "19_VISUAL_PRODUCTION_CURRENT_GATE_2026-08-26.md"
DECISION_ID = "TEN-DEC-20260827-WARM-DUSK-TEN-STEP-VISUAL-DIRECTION-01"
WARM_DUSK_DECISION = ROOT / "docs" / "decisions" / "2026-08-27_WARM_DUSK_TEN_STEP_VISUAL_DIRECTION_DECISION.md"
WARM_DUSK_CANDIDATE = ROOT / "docs" / "visual-assets" / "candidates" / "WARM_DUSK_TEN_STEP_COMBAT_ANCHOR_01_v2_NO_FLOOR_GRID.png"
WARM_DUSK_RECORD = ROOT / "docs" / "visual-assets" / "candidates" / "WARM_DUSK_TEN_STEP_COMBAT_ANCHOR_01_v2_NO_FLOOR_GRID.md"


class VisualConsumerAssetProductionPolicyTests(unittest.TestCase):
    def test_current_visual_queue_is_consumer_first_not_explanatory_sheet_first(self) -> None:
        visual = json.loads(VISUAL.read_text(encoding="utf-8"))
        planning = json.loads(PLANNING.read_text(encoding="utf-8"))
        gate = GATE.read_text(encoding="utf-8")

        self.assertEqual(DECISION_ID, visual["current_visual_production_decision"])
        self.assertEqual("ACTUAL_GAME_CONSUMER_REQUIRED", visual["consumer_first_asset_policy"])
        self.assertEqual("USER_APPROVED_AND_IMPLEMENTED_2026_08_27", visual["approved_results"]["OPPONENT_CHARACTER_MASTER_01"]["status"])
        self.assertEqual("PASS", visual["approved_results"]["OPPONENT_CHARACTER_MASTER_01"]["notion_delivery"])

        battler = visual["approved_results"]["DOGYEOM_COMBAT_BATTLER_01"]
        self.assertEqual("USER_APPROVED_2026_08_26", battler["status"])
        self.assertEqual("PASS", battler["notion_delivery"])
        self.assertEqual("res://assets/characters/dogyeom_combat_battler_01_v1.png", battler["runtime_asset"])
        self.assertEqual("src/combat/combat_character_placeholder.gd", battler["consumer"])
        self.assertEqual("AUTOMATED_GODOT_PASS_20260827", battler["opponent_specific_routing"])

        portrait = visual["approved_results"]["DOGYEOM_STATUS_PORTRAIT_01"]
        self.assertEqual("USER_APPROVED_AND_IMPLEMENTED_2026_08_26", portrait["status"])
        self.assertEqual("src/ui/combatant_status_panel.gd", portrait["consumer"])
        self.assertEqual("res://assets/portraits/dogyeom_status_portrait_01_v1.png", portrait["runtime_asset"])
        self.assertEqual("AUTOMATED_GODOT_PASS_20260826", portrait["opponent_specific_routing"])
        self.assertEqual("WARM_DUSK_TEN_STEP_COMBAT_ANCHOR_01", visual["next_result"]["id"])
        self.assertEqual("USER_DIRECTED_SINGLE_CORRECTION_GENERATED_EXPLORATION_IN_REVIEW", visual["next_result"]["generation_status"])
        self.assertEqual([], planning["next_visual_batch"])
        self.assertEqual("GPT_WORK", planning["next_execution_surface"])

        serialized_queue = json.dumps(visual.get("deferred_queue_after_result_review", []), ensure_ascii=False)
        self.assertNotIn("MARTIAL_TECHNIQUE_ILLUSTRATION_SHEET_01", serialized_queue)
        self.assertIn("실제 게임 소비처", gate)
        self.assertIn("DOGYEOM_COMBAT_BATTLER_01", gate)
        self.assertIn("DOGYEOM_STATUS_PORTRAIT_01", gate)
        self.assertIn("src/ui/combatant_status_panel.gd", gate)
        self.assertIn("CardView.illustration", gate)
        self.assertIn("GPT Work", gate)

    def test_warm_dusk_anchor_is_candidate_only_with_local_provenance(self) -> None:
        visual = json.loads(VISUAL.read_text(encoding="utf-8"))
        self.assertTrue(WARM_DUSK_DECISION.is_file())
        self.assertTrue(WARM_DUSK_CANDIDATE.is_file())
        self.assertTrue(WARM_DUSK_RECORD.is_file())
        self.assertEqual(
            "11281c8f6eb874b3ddd516b38c11cbba269eb6a2d547ce8c36f701c65fd84802",
            sha256(WARM_DUSK_CANDIDATE.read_bytes()).hexdigest(),
        )
        record = WARM_DUSK_RECORD.read_text(encoding="utf-8")
        decision = WARM_DUSK_DECISION.read_text(encoding="utf-8")
        self.assertIn("GENERATED_EXPLORATION · IN_REVIEW", record)
        self.assertIn("Notion delivery: `NOT_RUN`", record)
        self.assertIn("Runtime: `NOT_RUN`", record)
        self.assertIn("`src/combat/combat_board_preview.gd`", record)
        self.assertIn("logical ten-space field is not rendered as floor cells", record)
        self.assertIn(DECISION_ID, decision)
        self.assertEqual(
            "WARM_DUSK_TEN_STEP_COMBAT_ANCHOR_01",
            visual["next_result"]["id"],
        )


if __name__ == "__main__":
    unittest.main()
