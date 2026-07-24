from pathlib import Path
import json

ROOT = Path(__file__).resolve().parents[1]


def read(path: str) -> str:
    target = ROOT / path
    assert target.is_file(), f"missing prepare/placement file: {path}"
    return target.read_text(encoding="utf-8")


def main() -> None:
    cards = json.loads(read("data/cards/basic_cards.json"))["cards"]
    prepare = next(card for card in cards if card["id"] == "basic_stance")
    assert prepare["name"] == "준비"
    assert "준비" in prepare["effect_text"]
    assert "명상" in prepare["effect_text"]
    assert "절초 기세" in prepare["effect_text"]

    timing = read("src/ui/action_timing_panel.gd")
    assert "func find_earliest_open_anchor(span: int) -> int:" in timing
    assert "return 0" in timing

    board = read("src/combat/combat_board_preview.gd")
    for token in (
        "func _auto_place_selected_card(definition: Dictionary) -> bool:",
        "find_earliest_open_anchor",
        "_reserve_ultimate_at(anchor)",
        "_refund_ultimate_reservation",
    ):
        assert token in board, f"board auto-placement contract missing {token}"
    assert "슬롯 선택" not in board

    engine = read("src/combat/combat_resolution_engine.gd")
    for token in (
        "[전조]",
        'actor["prepare_active"]',
        "prepare_meditate_momentum",
        "func _clear_prepare_state(actor: Dictionary) -> void:",
    ):
        assert token in engine, f"prepare engine contract missing {token}"

    rules = json.loads(read("data/combat/combat_resolution_preview.json"))
    assert rules["prepare_meditate_momentum"] == 1

    print("prepare and auto placement contract: PASS")


if __name__ == "__main__":
    main()
