from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SPEC = ROOT / "docs/superpowers/specs/2026-08-11-combat-card-detail-plan-information-design.md"
PLAN = ROOT / "docs/superpowers/plans/2026-08-11-planning-completion-review.md"


def test_approved_combat_information_spec_is_ready_for_completion_review():
    text = SPEC.read_text(encoding="utf-8")
    assert "USER_APPROVED_SPEC / PLANNING_COMPLETION_REVIEW_READY" in text
    assert "기획완료 → 검수완료 → 이미지 생성" in text


def test_planning_completion_review_plan_has_ordered_gates_and_boundaries():
    text = PLAN.read_text(encoding="utf-8")
    required = (
        "Stage 1 — 기획완료 후보",
        "Stage 2 — 검수완료",
        "Stage 3 — 이미지 생성",
        "Base / Project / Sheet fresh-read",
        "벤치마킹·현업 조사",
        "P0/P1 = 0",
        "image_generation_before_review_complete: FORBIDDEN",
        "product_implementation_authorized: false",
    )
    for marker in required:
        assert marker in text, marker


def test_images_are_not_a_prerequisite_for_planning_or_review_completion():
    text = PLAN.read_text(encoding="utf-8")
    assert "PLANNING_COMPLETE does not require generated images" in text
    assert "REVIEW_COMPLETE does not require generated images" in text
    assert "image_generation_gate: AFTER_REVIEW_COMPLETE" in text
