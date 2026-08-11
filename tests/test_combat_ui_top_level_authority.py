from __future__ import annotations

import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


class CombatUiTopLevelAuthorityTests(unittest.TestCase):
    def test_agents_core_uses_current_public_start_distance_and_labels_legacy_coordinates(self) -> None:
        text = (ROOT / "AGENTS.md").read_text(encoding="utf-8")
        core = text.split("## 5. 프로젝트 코어", 1)[1].split("## 6. 행동 선택 계약", 1)[0]

        self.assertIn("시작 공개 거리 2", core)
        self.assertIn("4/7 시작 좌표는 `IMPLEMENTED_LEGACY`", core)
        self.assertNotIn("플레이어 4번·상대 7번 시작.", core)

    def test_base_rules_project_contract_uses_public_distance_and_labels_runtime_legacy(self) -> None:
        text = (ROOT / "docs/BASE_RULES_VERSION.md").read_text(encoding="utf-8")
        core = text.split("## 6. 프로젝트 고유 계약", 1)[1].split(
            "## 7. 현재 프로젝트 상태와 검증", 1
        )[0]

        self.assertIn("시작 공개 거리 2", core)
        self.assertIn("4/7 시작 좌표는 `IMPLEMENTED_LEGACY`", core)
        self.assertIn("새 절대 시작 좌표는 `IMPLEMENTATION_BINDING_PENDING`", core)
        self.assertNotIn("플레이어 4번·상대 7번 시작과 거리 0 `[밀착]`.", core)

    def test_user_approved_card_detail_plan_spec_is_completion_review_ready(self) -> None:
        text = (
            ROOT
            / "docs/superpowers/specs/2026-08-11-combat-card-detail-plan-information-design.md"
        ).read_text(encoding="utf-8")
        self.assertIn("USER_APPROVED_SPEC / PLANNING_COMPLETION_REVIEW_READY", text)
        self.assertIn("기획완료 → 검수완료 → 이미지 생성", text)

    def test_planning_completion_review_keeps_images_after_review(self) -> None:
        text = (
            ROOT / "docs/superpowers/plans/2026-08-11-planning-completion-review.md"
        ).read_text(encoding="utf-8")
        required = (
            "Stage 1 — 기획완료 후보",
            "Stage 2 — 검수완료",
            "Stage 3 — 이미지 생성",
            "Base / Project / Sheet fresh-read",
            "벤치마킹·현업 조사",
            "P0/P1 = 0",
            "PLANNING_COMPLETE does not require generated images",
            "REVIEW_COMPLETE does not require generated images",
            "image_generation_gate: AFTER_REVIEW_COMPLETE",
            "image_generation_before_review_complete: FORBIDDEN",
            "product_implementation_authorized: false",
        )
        for marker in required:
            self.assertIn(marker, text)


if __name__ == "__main__":
    unittest.main()
