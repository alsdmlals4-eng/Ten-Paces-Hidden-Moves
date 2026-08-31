from __future__ import annotations

import json
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]


def load(relative_path: str) -> dict:
    return json.loads((ROOT / relative_path).read_text(encoding="utf-8"))


def test_phase2_runtime_data_matches_the_approved_opening_and_basic_actions() -> None:
    """Catches a regression to legacy 4/7, eight-card, or generic-progress data."""
    board = load("data/combat/combat_board_poc.json")
    basics = load("data/cards/basic_cards.json")["cards"]
    hud = load("data/combat/combat_hud_preview.json")
    resolution = load("data/combat/combat_resolution_preview.json")
    progress = load("data/combat/combat_progress_preview.json")

    assert (board["player_start_tile"], board["enemy_start_tile"]) == (4, 6)
    assert board["basic_action_cards"]["card_count"] == 10
    assert board["basic_action_cards"]["card_ids"] == [
        "basic_move",
        "basic_footwork",
        "basic_guard",
        "basic_evade",
        "basic_quick_attack",
        "basic_heavy_attack",
        "basic_observe",
        "basic_meditate",
        "basic_stance",
        "basic_palm",
    ]

    by_id = {card["id"]: card for card in basics}
    assert list(by_id) == board["basic_action_cards"]["card_ids"]
    assert by_id["basic_heavy_attack"]["internal_cost"] == 2
    assert by_id["basic_heavy_attack"]["range"] == {"min": 1, "max": 2}
    assert by_id["basic_heavy_attack"]["damage_formula"] == {
        "base": 7,
        "stat_key": "external",
        "coefficient": 1.0,
    }
    assert by_id["basic_palm"]["action_slots"] == 2
    assert by_id["basic_palm"]["range"] == {"min": 1, "max": 3}
    assert by_id["basic_palm"]["damage_formula"] == {
        "base": 3,
        "stat_key": "internal_power",
        "coefficient": 0.75,
    }
    assert "knockback" not in by_id["basic_palm"]
    assert by_id["basic_observe"]["player_only"] is True
    assert by_id["basic_observe"]["observation_points"] == 1
    assert by_id["basic_meditate"]["restore"] == {"stamina": 1, "internal": 1}

    for combatant in (hud["player"], hud["enemy"]):
        assert combatant["stats"] == {
            "external": 4,
            "constitution": 4,
            "agility": 4,
            "internal_power": 4,
            "insight": 4,
        }
    assert resolution["meditate_stamina_restore"] == 1
    assert resolution["meditate_internal_restore"] == 1
    assert progress["button_text"] == "{bundle_actions}수 실행"
    assert "잠금" not in progress["caption"]
