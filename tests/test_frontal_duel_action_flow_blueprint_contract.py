from __future__ import annotations

import json
import unittest
from pathlib import Path


REPOSITORY_ROOT = Path(__file__).resolve().parents[1]
BLUEPRINT_PATH = REPOSITORY_ROOT / "docs" / "design" / "2026-09-01_FRONTAL_DUEL_ACTION_FLOW_BLUEPRINT.md"
BENCHMARK_PATH = REPOSITORY_ROOT / "docs" / "reviews" / "2026-09-01_FRONTAL_DUEL_REVEAL_AND_CARD_BENCHMARK.md"
CURRENT_STATUS_PATH = REPOSITORY_ROOT / "docs" / "planning-data" / "current_user_planning_status.json"
PLAN_LOCK_DECISION_PATH = REPOSITORY_ROOT / "docs" / "decisions" / "2026-09-01_ACTION_PLAN_LOCK_AND_EXECUTE_CTA_DECISION.md"
PLAN_LOCK_BUILD_APPROVAL_PATH = REPOSITORY_ROOT / "docs" / "implementation" / "BUILD_APPROVAL_2026-09-01.md"


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
        self.assertIn("IMPLEMENTED_MACHINE_VERIFIED", status["frontal_duel_blueprint_status"])
        self.assertIn("CURRENT_EXACT_REPOSITORY_CAPTURE", status["frontal_duel_blueprint_status"])

    def test_plan_lock_is_a_scoped_approved_transition_not_a_core_rule_change(self) -> None:
        decision = PLAN_LOCK_DECISION_PATH.read_text(encoding="utf-8")
        approval = PLAN_LOCK_BUILD_APPROVAL_PATH.read_text(encoding="utf-8")
        status = json.loads(CURRENT_STATUS_PATH.read_text(encoding="utf-8"))

        self.assertEqual("TEN-DEC-20260901-ACTION-PLAN-LOCK-AND-EXECUTE-CTA-01", status["frontal_duel_plan_lock_decision"])
        self.assertEqual("docs/implementation/BUILD_APPROVAL_2026-09-01.md", status["frontal_duel_plan_lock_build_approval"])
        self.assertIn("resolver_invocation: 0", decision)
        self.assertIn("resolver_invocation: exactly_once", decision)
        self.assertIn("save_schema: preserved", decision)
        self.assertIn("No new raster asset is approved or required.", approval)

    def test_human_blueprint_uses_current_visual_evidence_before_abstract_diagrams(self) -> None:
        blueprint = BLUEPRINT_PATH.read_text(encoding="utf-8")
        required_visual_inputs = (
            "docs/evidence/runtime-captures/TEN-RVC-20260901-001.png",
            "docs/evidence/runtime-captures/TEN-RVC-20260901-005.png",
            "docs/visual-assets/planning/PROJECT_CORE_SCENE_VISUAL_BOARD_20260828_R2.png",
            "assets/ui/cards/martial_ultimate_card_illustration_atlas_01_v1.png",
            "assets/vfx/attack_clash_ink_gold_atlas_rgba_v1.png",
        )

        self.assertIn("### D. 이미지 우선 블루프린트 기준", blueprint)
        for relative_path in required_visual_inputs:
            self.assertIn(relative_path, blueprint)
            self.assertTrue((REPOSITORY_ROOT / relative_path).exists(), relative_path)
        self.assertIn("체커보드처럼 직접 싣지 않고", blueprint)

    def test_human_pdf_keeps_the_structural_blueprint_layer_alongside_images(self) -> None:
        """A visual-evidence revision must not delete the actionable old PDF maps."""
        generator = (REPOSITORY_ROOT / "tools" / "build_frontal_duel_visual_blueprint_pdf.py").read_text(encoding="utf-8")
        blueprint = BLUEPRINT_PATH.read_text(encoding="utf-8")

        self.assertIn("### E. 이미지와 구조 설계의 이중 레이어", blueprint)
        self.assertIn("page_flow_map", generator)
        self.assertIn("page_plan_wireframe", generator)
        self.assertIn("page_reveal_wireframe", generator)
        self.assertIn("3수 → 해결 → 3수 → 해결 → 4수", generator)
        self.assertIn("현재 수만 공개", generator)


if __name__ == "__main__":
    unittest.main()
