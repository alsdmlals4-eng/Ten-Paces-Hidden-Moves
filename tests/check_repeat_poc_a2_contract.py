from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]

REQUIRED_PATHS = [
    "src/combat/combat_review_summary_builder.gd",
    "tests/verify_combat_review_summary.gd",
]

RETIRED_PATHS = [
    "data/combat/combat_hypothesis_poc.json",
    "src/ui/opponent_hypothesis_panel.gd",
    "scenes/ui/opponent_hypothesis_panel.tscn",
    "tests/verify_combat_hypothesis.gd",
]


def read(relative: str) -> str:
    path = ROOT / relative
    assert path.is_file(), f"missing A2 file: {relative}"
    return path.read_text(encoding="utf-8")


def main() -> None:
    for relative in REQUIRED_PATHS:
        assert (ROOT / relative).is_file(), f"missing A2 file: {relative}"

    for relative in RETIRED_PATHS:
        assert not (ROOT / relative).exists(), f"retired player-intention hypothesis artifact remains: {relative}"

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
        "REVIEW_SUMMARY_BUILDER_SCRIPT.new",
        "_committed_player_plan_snapshot",
        "_last_review_summary",
    ):
        assert token in board, f"board A2 integration missing token: {token}"
    for retired_token in (
        "OPPONENT_HYPOTHESIS_SCENE",
        "OpponentHypothesisPanel",
        "_committed_hypothesis_snapshot",
        "get_current_hypothesis_snapshot",
        "SkipPresentationButton",
        "skip_presentation_button",
    ):
        assert retired_token not in board, f"retired combat-planning surface remains: {retired_token}"

    print("repeat POC A2 retirement contract: PASS")


if __name__ == "__main__":
    main()
