from __future__ import annotations

import json
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
VISUAL = ROOT / "docs" / "planning-data" / "current_visual_production_handoff_20260826.json"
PLANNING = ROOT / "docs" / "planning-data" / "current_user_planning_status.json"
HANDOFF = ROOT / "docs" / "handoffs" / "2026-08-26_GPT_WORK_HANDOFF.md"
DECISION = ROOT / "docs" / "decisions" / "2026-08-26_VISUAL_CONSUMER_ASSET_PRODUCTION_DECISION.md"


class GptWorkHandoff20260826Tests(unittest.TestCase):
    def test_battler_approval_and_work_resume_are_current(self) -> None:
        visual = json.loads(VISUAL.read_text(encoding="utf-8"))
        planning = json.loads(PLANNING.read_text(encoding="utf-8"))

        self.assertEqual("GPT_WORK", visual["handoff"]["next_surface"])
        self.assertTrue(visual["handoff"]["fresh_read_required"])
        self.assertEqual("HANDOFF_READY_GPT_WORK", visual["status"])

        battler = visual["approved_results"]["DOGYEOM_COMBAT_BATTLER_01"]
        self.assertEqual("USER_APPROVED_2026_08_26", battler["status"])
        self.assertEqual("79ae965f-6048-48c5-b667-6e9b7a55b68f", battler["generation_id"])
        self.assertEqual(
            "064a8772406c743bbe6b252c138b4333c88b00b90a0ba905cce9ea18773539c9",
            battler["source_png_sha256"],
        )
        self.assertEqual("PASS", battler["notion_delivery"])
        self.assertFalse(battler["runtime_asset"])

        self.assertEqual("DOGYEOM_STATUS_PORTRAIT_01", visual["next_result"]["id"])
        self.assertEqual("src/ui/combatant_status_panel.gd", visual["next_result"]["consumer"])
        self.assertEqual("GPT_WORK_RESUME_REQUIRED", visual["next_result"]["generation_status"])
        self.assertEqual(["DOGYEOM_STATUS_PORTRAIT_01"], planning["next_visual_batch"])
        self.assertEqual("GPT_WORK", planning["next_execution_surface"])

    def test_handoff_document_preserves_evidence_ceiling(self) -> None:
        self.assertTrue(HANDOFF.is_file())
        text = HANDOFF.read_text(encoding="utf-8")
        for marker in (
            "GPT Work",
            "b6d76410e3aa0edd7a2e698270742187cc471fd9",
            "06669fe9c6a3ccd6f3b0d19c5757540bfdcc0623",
            "DOGYEOM_COMBAT_BATTLER_01",
            "DOGYEOM_STATUS_PORTRAIT_01",
            "MIGRATION_ONLY_UNTIL_REMOVAL",
            "CODEX_GODOT_PRODUCT_IMPLEMENTATION_HANDOFF",
            "runtime art integration: `NOT_RUN`",
        ):
            self.assertIn(marker, text)

        decision = DECISION.read_text(encoding="utf-8")
        self.assertIn("DOGYEOM_COMBAT_BATTLER_01", decision)
        self.assertIn("USER_APPROVED_2026_08_26", decision)


if __name__ == "__main__":
    unittest.main()
