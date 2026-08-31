from __future__ import annotations

import json
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
VISUAL = ROOT / "docs" / "planning-data" / "current_visual_production_handoff_20260826.json"
PLANNING = ROOT / "docs" / "planning-data" / "current_user_planning_status.json"
HANDOFF = ROOT / "docs" / "handoffs" / "2026-08-26_GPT_WORK_HANDOFF.md"
DECISION = ROOT / "docs" / "decisions" / "2026-08-26_VISUAL_CONSUMER_ASSET_PRODUCTION_DECISION.md"
BASE_WORK = "templates/project-operations/CHATGPT_WORK_PROJECT_EXECUTION_INSTRUCTION_v4.9.md"
BASE_WORK_COMPAT = "templates/project-operations/CHATGPT_WORK_PROJECT_EXECUTION_INSTRUCTION_v4.9_COMPATIBILITY_APPENDIX.md"
HANDOFF_MERGED_MAIN = "111f97d7a713a82d61d8e97e262ccbfc800e0868"


class GptWorkHandoff20260826Tests(unittest.TestCase):
    def test_battler_approval_and_work_resume_are_current(self) -> None:
        visual = json.loads(VISUAL.read_text(encoding="utf-8"))
        planning = json.loads(PLANNING.read_text(encoding="utf-8"))

        self.assertEqual("REPOSITORY_ONLY_GPT_WORK", visual["handoff"]["next_surface"])
        self.assertTrue(visual["handoff"]["fresh_read_required"])
        self.assertEqual(
            "FRONTAL_COURTYARD_DUEL_AND_SHARED_MARTIAL_ULTIMATE_CARD_ATLAS_USER_FINAL_LOCKED_CANON_REGISTERED_IMPLEMENTED_MACHINE_RUNTIME_VERIFIED_DOGYEOM_ASSETS_PRESERVED",
            visual["status"],
        )
        self.assertEqual("43b3ffb2c5b026e3d4a38dab2338585894d36f61", visual["handoff"]["snapshot_observed_base_main"])
        self.assertEqual(BASE_WORK, visual["handoff"]["base_work_adapter"])
        self.assertEqual(BASE_WORK_COMPAT, visual["handoff"]["base_work_compatibility_appendix"])

        battler = visual["approved_results"]["DOGYEOM_COMBAT_BATTLER_01"]
        self.assertEqual("USER_APPROVED_2026_08_26", battler["status"])
        self.assertEqual("79ae965f-6048-48c5-b667-6e9b7a55b68f", battler["generation_id"])
        self.assertEqual(
            "064a8772406c743bbe6b252c138b4333c88b00b90a0ba905cce9ea18773539c9",
            battler["source_png_sha256"],
        )
        self.assertEqual("PASS_20260826", battler["historical_notion_delivery_evidence"])
        self.assertEqual("res://assets/characters/dogyeom_combat_battler_01_v1.png", battler["runtime_asset"])
        self.assertEqual("AUTOMATED_GODOT_PASS_20260827", battler["opponent_specific_routing"])

        portrait = visual["approved_results"]["DOGYEOM_STATUS_PORTRAIT_01"]
        self.assertEqual("AUTOMATED_GODOT_PASS_20260826", portrait["opponent_specific_routing"])
        background = visual["approved_results"]["FRONTAL_COURTYARD_DUEL_BACKGROUND_01"]
        self.assertEqual("USER_FINAL_LOCKED_CANON_REGISTERED_IMPLEMENTED_MACHINE_RUNTIME_VERIFIED_2026_08_31", background["status"])
        self.assertEqual("res://assets/backgrounds/frontal_courtyard_duel_background_01_v1.png", background["runtime_asset"])
        self.assertEqual("src/combat/battle_background.gd", background["consumer"])
        self.assertEqual("ink_mist_valley_duel_01_v1", background["previous_runtime_asset_removed_from_current_tree_id"])
        self.assertEqual("PROJECT_CORE_SCENE_VISUAL_BOARD", visual["next_result"]["id"])
        self.assertEqual("USER_FINAL_LOCKED_PLANNING_ONLY", visual["next_result"]["generation_status"])
        self.assertEqual("USER_APPROVED_FINAL_LOCKED", visual["next_result"]["final_lock_status"])
        self.assertEqual([], planning["next_visual_batch"])
        self.assertEqual(
            "REPOSITORY_ONLY_GPT_WORK",
            planning["next_execution_surface"],
        )
        self.assertEqual(
            f"MERGED_MAIN_{HANDOFF_MERGED_MAIN}",
            planning["evidence_ceiling"]["github_visual_handoff_and_provenance"],
        )
        self.assertNotIn(
            "PENDING_TASK_PR_MERGE",
            planning["evidence_ceiling"]["github_visual_handoff_and_provenance"],
        )

    def test_handoff_document_preserves_evidence_ceiling(self) -> None:
        self.assertTrue(HANDOFF.is_file())
        text = HANDOFF.read_text(encoding="utf-8")
        for marker in (
            "GPT Work",
            "b6d76410e3aa0edd7a2e698270742187cc471fd9",
            "43b3ffb2c5b026e3d4a38dab2338585894d36f61",
            BASE_WORK,
            BASE_WORK_COMPAT,
            "WORK_IS_EXECUTION_SURFACE_NOT_CANON",
            "DOGYEOM_COMBAT_BATTLER_01",
            "DOGYEOM_STATUS_PORTRAIT_01",
            "MIGRATION_ONLY_UNTIL_REMOVAL",
            "CODEX_GODOT_PRODUCT_IMPLEMENTATION_HANDOFF",
            "runtime art integration: AUTOMATED_GODOT_PASS_20260826",
        ):
            self.assertIn(marker, text)

        decision = DECISION.read_text(encoding="utf-8")
        self.assertIn("DOGYEOM_COMBAT_BATTLER_01", decision)
        self.assertIn("USER_APPROVED_2026_08_26", decision)


if __name__ == "__main__":
    unittest.main()
