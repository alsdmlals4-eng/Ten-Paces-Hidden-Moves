from __future__ import annotations

import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]

REQUIRED_PATHS = [
    "data/combat/combat_hypothesis_poc.json",
    "src/ui/opponent_hypothesis_panel.gd",
    "scenes/ui/opponent_hypothesis_panel.tscn",
    "src/combat/combat_review_summary_builder.gd",
    "tests/verify_combat_hypothesis.gd",
    "tests/verify_combat_review_summary.gd",
]

EXPECTED_IDS = [
    "approach",
    "quick_attack",
    "heavy_prepare",
    "response_or_recover",
    "ultimate",
    "none",
]


def read(relative: str) -> str:
    path = ROOT / relative
    assert path.is_file(), f"missing A2 file: {relative}"
    return path.read_text(encoding="utf-8")


def main() -> None:
    for relative in REQUIRED_PATHS:
        assert (ROOT / relative).is_file(), f"missing A2 file: {relative}"

    hypothesis = json.loads(read("data/combat/combat_hypothesis_poc.json"))
    assert hypothesis["schema_version"] == 1
    assert hypothesis["default_id"] == "none"
    assert [entry["id"] for entry in hypothesis["hypotheses"]] == EXPECTED_IDS
    none_entry = hypothesis["hypotheses"][-1]
    assert none_entry["label"] == "기록한 가설 없음"
    assert none_entry["recorded"] is False

    panel = read("src/ui/opponent_hypothesis_panel.gd")
    for token in (
        "class_name OpponentHypothesisPanel",
        "select_hypothesis",
        "get_current_hypothesis_snapshot",
        "set_locked",
        "reset_to_initial",
        '"recorded"',
    ):
        assert token in panel, f"hypothesis panel missing token: {token}"

    builder = read("src/combat/combat_review_summary_builder.gd")
    for token in (
        "class_name CombatReviewSummaryBuilder",
        "CAUSE_PRIORITY",
        "build_summary",
        '"clash"',
        '"interrupted"',
        '"defense"',
        '"direction"',
        '"range"',
        '"resource"',
        '"position"',
        '"order"',
        '"review_dimension"',
    ):
        assert token in builder, f"summary builder missing token: {token}"
    assert "resolve_bundle(" not in builder
    assert "CombatResolutionEngine" not in builder
    assert "candidate_scores" not in builder

    board = read("src/combat/combat_board_preview.gd")
    for token in (
        "OPPONENT_HYPOTHESIS_SCENE",
        "REVIEW_SUMMARY_BUILDER_SCRIPT.new",
        "_committed_hypothesis_snapshot",
        "_committed_player_plan_snapshot",
        "_last_review_summary",
        "get_current_hypothesis_snapshot",
    ):
        assert token in board, f"board A2 integration missing token: {token}"

    print("repeat POC A2 static contract: PASS")


if __name__ == "__main__":
    main()
