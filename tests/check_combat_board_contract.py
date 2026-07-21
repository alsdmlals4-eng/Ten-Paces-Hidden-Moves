from __future__ import annotations

import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
CONTRACT = ROOT / "data/combat/combat_board_poc.json"
HUD_DATA = ROOT / "data/combat/combat_hud_preview.json"


def res_file(value: str) -> Path:
    assert value.startswith("res://")
    return ROOT / value.removeprefix("res://")


def main() -> None:
    contract = json.loads(CONTRACT.read_text(encoding="utf-8"))

    assert contract["schema_version"] >= 3
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

    top_hud = contract["top_hud"]
    assert top_hud["step"] == 4
    assert top_hud["approval_status"] == "USER_APPROVED_LAYOUT"
    assert top_hud["momentum_segments"] == 6
    assert top_hud["layout"] == [
        "player_status",
        "player_momentum",
        "round_bundle",
        "enemy_momentum",
        "enemy_status",
    ]
    assert top_hud["resource_fields"] == ["health", "stamina", "internal"]
    assert top_hud["lower_status_panels"] is False
    assert res_file(top_hud["scene"]).exists()
    assert res_file(top_hud["data"]).exists()

    hud_data = json.loads(HUD_DATA.read_text(encoding="utf-8"))
    assert hud_data["momentum_segments"] == 6
    assert len(hud_data["player"]["momentum"]) == 2
    assert len(hud_data["enemy"]["momentum"]) == 2
    assert hud_data["player"]["momentum"][1] == 6
    assert hud_data["enemy"]["momentum"][1] == 6
    assert hud_data["round"]["bundle_total"] == 3
    assert hud_data["round"]["resolution_order"] == "대응 → 속공 → 이동 → 일반 공격"
    for side in ("player", "enemy"):
        for field in ("health", "stamina", "internal", "momentum"):
            assert len(hud_data[side][field]) == 2

    scope = set(contract["presentation_scope"])
    assert {"battle_background", "top_hud"} <= scope

    excluded = set(contract["excluded_until_later_steps"])
    assert "final_background" not in excluded
    assert "top_hud" not in excluded
    assert {"action_slots", "cards", "log_panel", "progress_button"} <= excluded

    required_files = [
        "assets/backgrounds/step3_mountain_fortress.svg",
        "data/combat/combat_hud_preview.json",
        "scenes/combat/battle_background.tscn",
        "scenes/combat/combat_board_tile.tscn",
        "scenes/combat/combat_character_placeholder.tscn",
        "scenes/combat/combat_board_preview.tscn",
        "scenes/ui/combatant_status_panel.tscn",
        "scenes/ui/momentum_gauge.tscn",
        "scenes/ui/round_hud_panel.tscn",
        "scenes/ui/top_combat_hud.tscn",
        "src/combat/battle_background.gd",
        "src/combat/combat_board_tile.gd",
        "src/combat/combat_character_placeholder.gd",
        "src/combat/combat_board_preview.gd",
        "src/ui/combatant_status_panel.gd",
        "src/ui/momentum_gauge.gd",
        "src/ui/round_hud_panel.gd",
        "src/ui/top_combat_hud.gd",
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
    assert 'const TOP_HUD_SCENE := preload("res://scenes/ui/top_combat_hud.tscn")' in controller
    assert 'battle_background = BACKGROUND_SCENE.instantiate() as BattleBackground' in controller
    assert 'top_hud = TOP_HUD_SCENE.instantiate() as TopCombatHud' in controller
    assert controller.index("add_child(battle_background)") < controller.index("add_child(_tile_layer)")
    assert controller.index("add_child(_tile_layer)") < controller.index("add_child(top_hud)")
    assert 'tile.name = "Tile%02d" % index' in controller
    assert 'player_character.place_foot_at(get_tile_foot_anchor(player_tile))' in controller
    assert 'enemy_character.place_foot_at(get_tile_foot_anchor(enemy_tile))' in controller
    assert 'get_tile(player_tile).set_occupied("player")' in controller
    assert 'get_tile(enemy_tile).set_occupied("enemy")' in controller
    assert '"background_ready": is_instance_valid(battle_background)' in controller
    assert '"hud_ready": is_instance_valid(top_hud)' in controller
    assert '"lower_status_panels": false' in controller

    top_hud_script = (ROOT / "src/ui/top_combat_hud.gd").read_text(encoding="utf-8")
    assert 'player_panel.name = "PlayerStatusPanel"' in top_hud_script
    assert 'player_momentum.name = "PlayerMomentumGauge"' in top_hud_script
    assert 'round_panel.name = "RoundHudPanel"' in top_hud_script
    assert 'enemy_momentum.name = "EnemyMomentumGauge"' in top_hud_script
    assert 'enemy_panel.name = "EnemyStatusPanel"' in top_hud_script
    assert 'set_meta("lower_status_panels", false)' in top_hud_script

    verifier = (ROOT / "tests/verify_combat_board.gd").read_text(encoding="utf-8")
    assert "EXPECTED_TILE_COUNT := 10" in verifier
    assert "EXPECTED_PLAYER_TILE := 3" in verifier
    assert "EXPECTED_ENEMY_TILE := 8" in verifier
    assert "EXPECTED_HEIGHT_RATIO := 1.5" in verifier
    assert "EXPECTED_MOMENTUM_SEGMENTS := 6" in verifier
    assert '"background_ready"' in verifier
    assert '"hud_ready"' in verifier

    print("combat board STEP 1-4 contract: PASS")


if __name__ == "__main__":
    main()
