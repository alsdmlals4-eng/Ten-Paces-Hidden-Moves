from __future__ import annotations

import json
import unittest
from pathlib import Path


REPOSITORY_ROOT = Path(__file__).resolve().parents[1]
BLUEPRINT_PATH = REPOSITORY_ROOT / "docs" / "design" / "2026-09-01_FRONTAL_DUEL_ACTION_FLOW_BLUEPRINT.md"
BENCHMARK_PATH = REPOSITORY_ROOT / "docs" / "reviews" / "2026-09-01_FRONTAL_DUEL_REVEAL_AND_CARD_BENCHMARK.md"
CURRENT_STATUS_PATH = REPOSITORY_ROOT / "docs" / "planning-data" / "current_user_planning_status.json"


class FrontalDuelActionFlowBlueprintContractTests(unittest.TestCase):
    def test_blueprint_preserves_the_current_core_boundaries_and_implementation_route(self) -> None:
        blueprint = BLUEPRINT_PATH.read_text(encoding="utf-8")

        self.assertIn("core_rule_change: false", blueprint)
        self.assertIn("save_schema_change: false", blueprint)
        self.assertIn("new_raster_asset: NONE_REQUIRED", blueprint)
        self.assertIn("논리 10칸은 resolver만 사용", blueprint)
        self.assertIn("이동만 front/back intent", blueprint)
        self.assertIn("기술명·대상·피해·뒤 수는 계속 숨긴다", blueprint)
        self.assertIn("`ActionChoiceCard`", blueprint)
        self.assertIn("`CombatActionRevealOverlay`", blueprint)
        self.assertIn("1440×900", blueprint)
        self.assertIn("1280×800", blueprint)

    def test_blueprint_status_links_the_fresh_benchmark_without_promoting_unrun_evidence(self) -> None:
        status = json.loads(CURRENT_STATUS_PATH.read_text(encoding="utf-8"))
        benchmark = BENCHMARK_PATH.read_text(encoding="utf-8")

        self.assertEqual(
            "docs/design/2026-09-01_FRONTAL_DUEL_ACTION_FLOW_BLUEPRINT.md",
            status["frontal_duel_blueprint"],
        )
        self.assertEqual(
            "docs/reviews/2026-09-01_FRONTAL_DUEL_REVEAL_AND_CARD_BENCHMARK.md",
            status["frontal_duel_blueprint_benchmark"],
        )
        self.assertIn("benchmarked_game_count: 10", benchmark)
        self.assertIn("DESK_RESEARCH_ONLY_NO_TEN_PACES_HUMAN_PLAYTEST_NO_RUNTIME_OR_RULE_MUTATION", benchmark)
        self.assertIn("NO_NEW_RASTER_REQUIRED", status["frontal_duel_blueprint_asset_disposition"])
        self.assertIn("NOT_RUN", status["frontal_duel_blueprint_evidence_ceiling"])


if __name__ == "__main__":
    unittest.main()
