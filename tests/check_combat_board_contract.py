from __future__ import annotations

import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
CONTRACT = ROOT / "data/combat/combat_board_poc.json"


def res_file(value: str) -> Path:
    assert value.startswith("res://")
    return ROOT / value.removeprefix("res://")


def main() -> None:
    contract = json.loads(CONTRACT.read_text(encoding="utf-8"))

    assert contract["schema_version"] >= 2
    assert contract["tile_count"] == 10
    assert contract["player_start_tile"] == 3
    assert contract["enemy_start_tile"] == 8
    assert contract["camera_mode"] == "fixed_wide"
    assert 1.4 <= contract["character_height_to_tile_width"] <= 1.6
    assert 0.0 < contract["character_body_width_to_tile_width"] < 1.0
    assert 0.0 < contract["foot_anchor_y_ratio"] < 1.0

    background = contract["battle_background"]
    assert background["step"] == 3
    assert background["approval_status"] == "USER_APPROVED"
    assert background["style"] == "ink_wash_mountain_fortress"
    assert background["contrast_role"] == "below_board_and_characters"
    assert res_file(background["asset"]).exists()
    assert res_file(background["scene"]).exists()

    scope = set(contract["presentation_scope"])
    assert "battle_background" in scope

    excluded = set(contract["excluded_until_later_steps"])
    assert "final_background" not in excluded
    assert {
        "top_hud",
        "action_slots",
        "cards",
        "log_panel",
        "progress_button",
    } <= excluded

    required_files = [
        "assets/backgrounds/step3_mountain_fortress.svg",
        "scenes/combat/battle_background.tscn",
        "scenes/combat/combat_board_tile.tscn",
        "scenes/combat/combat_character_placeholder.tscn",
        "scenes/combat/combat_board_preview.tscn",
        "src/combat/battle_background.gd",
        "src/combat/combat_board_tile.gd",
        "src/combat/combat_character_placeholder.gd",
        "src/combat/combat_board_preview.gd",
        "tests/verify_combat_board.gd",
    ]
    for relative in required_files:
        assert (ROOT / relative).exists(), relative

    background_script = (ROOT / "src/combat/battle_background.gd").read_text(encoding="utf-8")
    assert 'preload("res://assets/backgrounds/step3_mountain_fortress.svg")' in background_script
    assert 'stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED' in background_script
    assert '"below_board_and_characters"' in background_script

    controller = (ROOT / "src/combat/combat_board_preview.gd").read_text(encoding="utf-8")
    assert 'const CONTRACT_PATH := "res://data/combat/combat_board_poc.json"' in controller
    assert 'const BACKGROUND_SCENE := preload("res://scenes/combat/battle_background.tscn")' in controller
    assert 'battle_background = BACKGROUND_SCENE.instantiate() as BattleBackground' in controller
    assert controller.index("add_child(battle_background)") < controller.index("add_child(_tile_layer)")
    assert 'tile.name = "Tile%02d" % index' in controller
    assert 'player_character.place_foot_at(get_tile_foot_anchor(player_tile))' in controller
    assert 'enemy_character.place_foot_at(get_tile_foot_anchor(enemy_tile))' in controller
    assert 'get_tile(player_tile).set_occupied("player")' in controller
    assert 'get_tile(enemy_tile).set_occupied("enemy")' in controller
    assert '"background_ready": is_instance_valid(battle_background)' in controller

    verifier = (ROOT / "tests/verify_combat_board.gd").read_text(encoding="utf-8")
    assert "EXPECTED_TILE_COUNT := 10" in verifier
    assert "EXPECTED_PLAYER_TILE := 3" in verifier
    assert "EXPECTED_ENEMY_TILE := 8" in verifier
    assert "EXPECTED_HEIGHT_RATIO := 1.5" in verifier
    assert '"background_ready"' in verifier

    print("combat board STEP 1-3 contract: PASS")


if __name__ == "__main__":
    main()
