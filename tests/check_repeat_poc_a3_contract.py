from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]

REQUIRED_PATHS = [
    "src/ui/combat_review_panel.gd",
    "scenes/ui/combat_review_panel.tscn",
    "tests/verify_combat_review_ui.gd",
]


def read(relative: str) -> str:
    path = ROOT / relative
    assert path.is_file(), f"missing A3 file: {relative}"
    return path.read_text(encoding="utf-8")


def main() -> None:
    for relative in REQUIRED_PATHS:
        assert (ROOT / relative).is_file(), f"missing A3 file: {relative}"

    panel = read("src/ui/combat_review_panel.gd")
    for token in (
        "class_name CombatReviewPanel",
        "detail_requested",
        "continue_requested",
        "show_summary",
        "hide_review",
        "get_detail_button",
        "get_continue_button",
        "내 가설",
        "상대 실제 행동",
        "결정적 원인",
        "전후 거리",
        "다음 검토",
        "accessibility_name",
    ):
        assert token in panel, f"review panel missing token: {token}"
    assert "resolve_bundle(" not in panel
    assert "CombatResolutionEngine" not in panel
    assert "damage" not in panel.lower()

    board = read("src/combat/combat_board_preview.gd")
    for token in (
        "COMBAT_REVIEW_SCENE",
        "combat_review_panel",
        '"review_ready"',
        "_show_review_panel",
        "_on_review_detail_requested",
        "_on_review_continue_requested",
        "set_collapsed(false)",
        "last_review_summary",
    ):
        assert token in board, f"board A3 integration missing token: {token}"
    assert 'return _presentation_state not in ["planning", "next_bundle_ready"]' in board

    print("repeat POC A3 static contract: PASS")


if __name__ == "__main__":
    main()
