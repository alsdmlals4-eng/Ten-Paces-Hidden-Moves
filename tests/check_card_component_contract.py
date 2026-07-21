from __future__ import annotations

import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
CATALOG = ROOT / "data/cards/basic_cards.json"
MANIFEST = ROOT / "assets/ui/cards/card_asset_manifest.json"
REQUIRED = {"id", "name", "source_label", "source_badge", "range_text", "category", "category_label", "category_badge", "illustration", "target", "damage", "condition", "effect_text", "tags", "action_slots", "stamina_cost", "internal_cost", "flavor"}
FORBIDDEN = {"action_point_cost", "guard_reduction"}
EXPECTED_IDS = {"basic_move", "basic_guard", "basic_evade", "basic_quick_attack", "basic_heavy_attack", "basic_meditate", "basic_stance"}
EXPECTED_CATEGORIES = {"move", "attack", "response", "recovery", "strengthen"}
AUTOMATION_FILES = {
    "tests/verify_step0.gd",
    "tools/verify_and_commit_step0.ps1",
    "tools/verify_and_commit_step0.cmd",
    "tools/verify_and_commit_combat_foundation.ps1",
}


def res_file(value: str) -> Path:
    assert value.startswith("res://")
    return ROOT / value.removeprefix("res://")


def validate_spec(spec: dict) -> None:
    assert set(spec) == {"atlas", "region"}
    assert res_file(spec["atlas"]).exists()
    assert len(spec["region"]) == 4 and all(isinstance(v, int) and v >= 0 for v in spec["region"])
    assert spec["region"][2] > 0 and spec["region"][3] > 0


def main() -> None:
    catalog = json.loads(CATALOG.read_text(encoding="utf-8"))
    cards = catalog["cards"]
    assert len(cards) == 7
    assert {card["id"] for card in cards} == EXPECTED_IDS
    assert {card["category"] for card in cards} == EXPECTED_CATEGORIES
    for card in cards:
        assert not (REQUIRED - set(card)), card["id"]
        assert not (FORBIDDEN & set(card)), card["id"]
        assert card["source_label"] == "기초"
        assert card["action_slots"] >= 1
        for key in ("source_badge", "category_badge", "illustration"):
            validate_spec(card[key])

    manifest = json.loads(MANIFEST.read_text(encoding="utf-8"))
    assert manifest["template_contract"]["bottom"] == ["action_slots", "stamina_cost", "internal_cost"]
    assert set(manifest["template_contract"]["removed"]) == FORBIDDEN
    assert res_file(manifest["step_2_reference"]).exists()
    for atlas in manifest["atlases"].values():
        assert res_file(atlas["path"]).exists() and atlas["regions"]

    assert 'run/main_scene="res://scenes/ui/card_component_preview.tscn"' in (ROOT / "project.godot").read_text(encoding="utf-8")
    for path in (
        "scenes/ui/card_view.tscn",
        "scenes/ui/card_detail_panel.tscn",
        "scenes/ui/card_component_preview.tscn",
        "src/ui/card_catalog.gd",
        "src/ui/card_view.gd",
        "src/ui/card_detail_panel.gd",
        "src/ui/card_component_preview.gd",
    ):
        assert (ROOT / path).exists(), path

    for path in AUTOMATION_FILES:
        assert (ROOT / path).exists(), path

    verifier = (ROOT / "tests/verify_step0.gd").read_text(encoding="utf-8")
    assert '"strengthen"' in verifier
    assert '"action_point_cost"' in verifier
    assert '"guard_reduction"' in verifier

    wrapper = (ROOT / "tools/verify_and_commit_step0.ps1").read_text(encoding="utf-8")
    assert 'verify_and_commit_combat_foundation.ps1' in wrapper

    powershell = (ROOT / "tools/verify_and_commit_combat_foundation.ps1").read_text(encoding="utf-8")
    assert '"pull", "--ff-only", "origin", $ExpectedBranch' in powershell
    assert '"add", "--", $ReportRelativePath' in powershell
    assert '"push", "origin", $ExpectedBranch' in powershell
    assert 'res://tests/verify_step0.gd' in powershell
    assert 'res://tests/verify_combat_board.gd' in powershell
    assert "Resolve-PythonCommand" not in powershell
    assert "check_card_component_contract.py" not in powershell

    print("card component contract: PASS")


if __name__ == "__main__":
    main()
