"""Regression contract for the approved unified action-card selection surface."""

from __future__ import annotations

import json
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]


def read(relative_path: str) -> str:
    return (ROOT / relative_path).read_text(encoding="utf-8")


class ActionCardSourceUnificationContractTests(unittest.TestCase):
    def test_active_combat_contract_keeps_movement_intent_but_auto_targets_non_move_actions(self) -> None:
        board = json.loads(read("data/combat/combat_board_poc.json"))
        selection = board.get("basic_action_cards", {})
        targeting = board.get("action_targeting", {})

        self.assertEqual("shared_action_card_grid", selection.get("card_surface"))
        self.assertEqual("semantic_intent_cards", targeting.get("move_mode"))
        self.assertEqual("auto_target_public_opponent", targeting.get("attack_mode"))
        self.assertTrue(targeting.get("auto_target_public_opponent"))
        self.assertNotIn("select_destination_board_tile", json.dumps(board, ensure_ascii=False))
        self.assertNotIn("select_left_or_right_direction", json.dumps(board, ensure_ascii=False))

    def test_common_card_renderer_keeps_compact_tag_and_moves_detail_facts_to_detail_panel(self) -> None:
        renderer = read("src/ui/action_selection/action_choice_card.gd")
        detail_panel = read("src/ui/action_selection/action_detail_panel.gd")

        self.assertIn('label.name = "CardTag"', renderer)
        self.assertIn('accessibility_description = _accessibility_description(status_text)', renderer)
        self.assertIn('custom_minimum_size = Vector2(0.0, 80.0)', renderer)
        self.assertNotIn('label.name = "CardFacts"', renderer)
        self.assertIn('_add_row("기력"', detail_panel)
        self.assertIn('_add_row("내력"', detail_panel)
        self.assertIn('_add_row("사거리"', detail_panel)
        self.assertIn('_add_section("효과"', detail_panel)

    def test_current_human_facing_owners_do_not_point_to_retired_action_selection_fixture(self) -> None:
        for path in (
            "docs/09_COMBAT_SYSTEM_ARCHITECTURE.md",
            "docs/design/PROJECT_AI_PRODUCTION_SPEC.md",
        ):
            self.assertNotIn("action_selection_poc.json", read(path), path)
        self.assertIn("combat_board_poc.json", read("docs/09_COMBAT_SYSTEM_ARCHITECTURE.md"))
        self.assertIn("combat_board_poc.json", read("docs/design/PROJECT_AI_PRODUCTION_SPEC.md"))


if __name__ == "__main__":
    unittest.main()
