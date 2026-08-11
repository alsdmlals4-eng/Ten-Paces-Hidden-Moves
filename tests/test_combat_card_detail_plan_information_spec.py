from pathlib import Path
import unittest


ROOT = Path(__file__).resolve().parents[1]
SPEC = ROOT / "docs/superpowers/specs/2026-08-11-combat-card-detail-plan-information-design.md"
DECISION = ROOT / "docs/decisions/2026-08-11_COMBAT_UI_INFORMATION_HIERARCHY_DECISION.md"
UI_SPEC = ROOT / "docs/07_COMBAT_UI_SPEC.md"


class CombatCardDetailPlanInformationSpecTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.spec = SPEC.read_text(encoding="utf-8")
        cls.decision = DECISION.read_text(encoding="utf-8")
        cls.ui_spec = UI_SPEC.read_text(encoding="utf-8")

    def test_user_approved_companion_spec_is_canon_linked(self):
        self.assertIn("APPROVED_SPEC", self.spec)
        self.assertIn(
            "docs/superpowers/specs/2026-08-11-combat-card-detail-plan-information-design.md",
            self.decision,
        )

    def test_card_body_and_detail_information_split_is_explicit(self):
        self.assertIn("card_body_numeric_display: CURRENT_CALCULATED_VALUE", self.decision)
        self.assertIn("detail_formula_display: EXACT_FORMULA", self.decision)
        self.assertIn("카드 본체는 현재 계산값을 우선", self.ui_spec)

    def test_detail_open_paths_are_not_hover_only(self):
        self.assertIn("detail_open_windows: CLICK_KEYBOARD_GAMEPAD_FOCUS", self.decision)
        self.assertIn("detail_open_android: TAP_BACK", self.decision)
        self.assertIn("hover 전용", self.ui_spec)

    def test_planning_review_then_image_generation_order_is_explicit(self):
        self.assertIn("기획완료 → 검수완료 → 이미지 생성", self.decision)

    def test_existing_player_facing_guardrails_remain_present(self):
        for required in (
            "ATTACK_ACTIONS_ONLY",
            "행동계획 잠금",
            "[관찰]",
            "[전조]",
            "[기절]",
            "% 명중률",
            "product_implementation_authorized: false",
        ):
            self.assertIn(required, self.decision)


if __name__ == "__main__":
    unittest.main()
