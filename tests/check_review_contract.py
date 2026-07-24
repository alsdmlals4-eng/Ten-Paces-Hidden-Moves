from pathlib import Path
import json

ROOT = Path(__file__).resolve().parents[1]


def text(path: str) -> str:
    target = ROOT / path
    assert target.is_file(), f"missing review file: {path}"
    return target.read_text(encoding="utf-8")


def main() -> None:
    data = json.loads(text("data/combat/combat_hypothesis_poc.json"))
    assert data["schema_version"] == 1
    assert [item["id"] for item in data["options"]] == [
        "approach", "quick_attack", "heavy_prepare",
        "response_or_recover", "ultimate", "none",
    ]
    hypothesis = text("src/ui/opponent_hypothesis_panel.gd")
    assert "snapshot_hypothesis" in hypothesis
    assert "기록한 가설 없음" in hypothesis
    summary = text("src/combat/combat_review_summary_builder.gd")
    for token in ("class_name CombatReviewSummaryBuilder", "CAUSE_PRIORITY", "NO_SINGLE_DECISIVE_CAUSE", "result.duplicate(true)"):
        assert token in summary, f"summary builder missing {token}"
    assert "resolve_bundle(" not in summary
    assert "damage" not in summary.lower() or "recompute" in summary.lower()
    review = text("src/ui/combat_review_panel.gd")
    for token in ("class_name CombatReviewPanel", "review_continue_requested", "apply_summary", "set_continue_enabled", "상세 기록", "다음 묶음 또는 재시작"):
        assert token in review, f"review panel missing {token}"
    assert "candidate_scores" not in review and "selected_card_id" not in review
    scene = text("scenes/ui/combat_review_panel.tscn")
    for node in ("HypothesisValue", "EnemyActionValue", "CauseValue", "DistanceValue", "NextDimensionValue", "DetailButton", "ContinueButton"):
        assert node in scene, f"review scene missing {node}"
    print("review contract: PASS")


if __name__ == "__main__":
    main()
