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

    timing = read("src/ui/action_timing_panel_auto.gd")
    assert "func find_earliest_open_anchor(span: int) -> int:" in timing
    assert "return 0" in timing
    timing_scene = read("scenes/ui/action_timing_panel.tscn")
    assert "action_timing_panel_auto.gd" in timing_scene

    board = read("src/combat/combat_board_preview_auto.gd")
    for token in (
        "func _auto_place_selected_card(definition: Dictionary) -> bool:",
        "action_placement_controller.select_and_place",
        "Callable(self, \"_reserve_ultimate_at\")",
        "[전조]",
    ):
        assert token in board, f"board auto-placement delegation missing {token}"
    assert "슬롯 선택" not in board

    controller = read("src/ui/action_selection/action_placement_controller.gd")
    for token in (
        'timing_panel.call("find_earliest_open_anchor", span)',
        "reserve_ultimate.call(anchor)",
        "refund_ultimate.call(placement)",
        "CODE_NO_CONTIGUOUS_TIMINGS",
        "CODE_MOMENTUM_INSUFFICIENT",
        "CODE_TARGETING_IN_PROGRESS",
    ):
        assert token in controller, f"placement controller contract missing {token}"

    board_base = read("src/combat/combat_board_preview.gd")
    assert "func _refund_ultimate_reservation(placement: Dictionary) -> void:" in board_base
    assert "current + 5" in board_base
    board_scene = read("scenes/combat/combat_board_preview.tscn")
    if "combat_board_preview_ten_manuals_auto.gd" in board_scene:
        board_wrapper = read("src/combat/combat_board_preview_ten_manuals_auto.gd")
        assert 'extends "res://src/combat/combat_board_preview_auto.gd"' in board_wrapper
        assert "TEN_MANUAL_ENGINE_SCRIPT" in board_wrapper
        assert "func _build_action_selection_runtime_context() -> Dictionary:" in board_wrapper
        assert 'context["martial_loadout"]' in board_wrapper
    else:
        assert "combat_board_preview_auto.gd" in board_scene

    engine = read("src/combat/combat_resolution_engine_prepare.gd")
    for token in (
        'actor["prepare_active"]',
        "prepare_meditate_momentum",
        "func _clear_prepare_state(actor: Dictionary) -> void:",
        'if category == "move":',
    ):
        assert token in engine, f"prepare engine contract missing {token}"

    ten_manual_engine = read("src/combat/combat_resolution_engine_ten_manuals.gd")
    assert 'extends "res://src/combat/combat_resolution_engine_prepare.gd"' in ten_manual_engine
    assert "configure_martial_loadouts" in ten_manual_engine

    rules = json.loads(read("data/combat/combat_resolution_preview.json"))
    assert rules["schema_version"] == 8
    assert rules["prepare_meditate_momentum"] == 1

    print("prepare and delegated auto placement contract: PASS")


if __name__ == "__main__":
    main()
