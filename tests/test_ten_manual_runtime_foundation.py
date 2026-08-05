from __future__ import annotations

import importlib.util
import json
import shutil
import tempfile
import unittest
from contextlib import contextmanager
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
TOOL = ROOT / "tools/check_ten_manual_runtime_foundation.py"
CATALOG = ROOT / "data/cards/martial_manual_cards.json"


def load_validator():
    spec = importlib.util.spec_from_file_location("ten_manual_runtime_validator", TOOL)
    if spec is None or spec.loader is None:
        raise RuntimeError("cannot load ten-manual runtime validator")
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


@contextmanager
def mutated_root():
    required = [
        "data/cards/martial_manual_cards.json",
        "docs/planning-data/approved_20260806_ten_recognizable_martial_manuals_contract.json",
        "docs/planning-data/approved_20260806_ten_manual_growth_budget_overlay_contract.json",
        "src/combat/martial_manual_registry.gd",
        "src/combat/martial_effect_pipeline.gd",
        "src/combat/combat_resolution_engine.gd",
        "docs/implementation/BUILD_APPROVAL_2026-08-06.md",
        "docs/decisions/2026-08-06_TEN_MANUAL_RUNTIME_IMPLEMENTATION_GATE.md",
    ]
    with tempfile.TemporaryDirectory() as directory:
        root = Path(directory)
        for relative in required:
            source = ROOT / relative
            if not source.is_file():
                continue
            destination = root / relative
            destination.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(source, destination)
        yield root


def read_catalog(root: Path) -> dict:
    return json.loads((root / "data/cards/martial_manual_cards.json").read_text(encoding="utf-8"))


def write_catalog(root: Path, value: dict) -> None:
    path = root / "data/cards/martial_manual_cards.json"
    path.write_text(json.dumps(value, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")


class TenManualRuntimeFoundationTests(unittest.TestCase):
    def setUp(self) -> None:
        self.validator = load_validator()

    def assert_rejected(self, root: Path) -> None:
        with self.assertRaises(self.validator.RuntimeFoundationError):
            self.validator.validate(root)

    def require_catalog(self) -> None:
        if not CATALOG.is_file():
            self.skipTest("runtime catalog intentionally absent during RED")

    def test_current_repository_passes(self) -> None:
        self.validator.validate(ROOT)

    def test_requires_exact_ten_manual_roster(self) -> None:
        self.require_catalog()
        with mutated_root() as root:
            catalog = read_catalog(root)
            catalog["manuals"].pop(next(iter(catalog["manuals"])))
            write_catalog(root, catalog)
            self.assert_rejected(root)

    def test_rejects_stat_assignment_drift(self) -> None:
        self.require_catalog()
        with mutated_root() as root:
            catalog = read_catalog(root)
            catalog["manuals"]["shaolin_arhat_vajra_art"]["primary_stat"] = "근골"
            write_catalog(root, catalog)
            self.assert_rejected(root)

    def test_rejects_any_stat_quota_policy(self) -> None:
        self.require_catalog()
        with mutated_root() as root:
            catalog = read_catalog(root)
            catalog["stat_quota_rules_enabled"] = True
            write_catalog(root, catalog)
            self.assert_rejected(root)

    def test_rejects_star9_multiple_effects(self) -> None:
        self.require_catalog()
        with mutated_root() as root:
            catalog = read_catalog(root)
            overlay = catalog["manuals"]["wudang_taiji_sword"]["overlays"]["star9"]
            overlay["effect_steps"].append({"op": "GAIN_RESOURCE", "resource": "internal", "amount": 1})
            write_catalog(root, catalog)
            self.assert_rejected(root)

    def test_rejects_unsupported_effect_operation(self) -> None:
        self.require_catalog()
        with mutated_root() as root:
            catalog = read_catalog(root)
            catalog["manuals"]["sichuan_tang_hidden_weapons"]["cards"]["star10"]["effect_steps"][0]["op"] = "RANDOM_POISON_NOVA"
            write_catalog(root, catalog)
            self.assert_rejected(root)

    def test_zixia_use_right_must_precede_all_recovery(self) -> None:
        self.require_catalog()
        with mutated_root() as root:
            catalog = read_catalog(root)
            steps = catalog["manuals"]["mount_hua_purple_mist_art"]["cards"]["star10"]["effect_steps"]
            steps[0], steps[1] = steps[1], steps[0]
            write_catalog(root, catalog)
            self.assert_rejected(root)

    def test_returning_spear_requires_range_recheck(self) -> None:
        self.require_catalog()
        with mutated_root() as root:
            catalog = read_catalog(root)
            steps = catalog["manuals"]["yang_family_spear"]["cards"]["star10"]["effect_steps"]
            catalog["manuals"]["yang_family_spear"]["cards"]["star10"]["effect_steps"] = [step for step in steps if step["op"] != "RECHECK_RANGE"]
            write_catalog(root, catalog)
            self.assert_rejected(root)

    def test_legacy_card_compatibility_is_mandatory(self) -> None:
        self.require_catalog()
        with mutated_root() as root:
            catalog = read_catalog(root)
            catalog["compatibility"]["preserved_card_ids"].remove("basic_move")
            write_catalog(root, catalog)
            self.assert_rejected(root)


if __name__ == "__main__":
    unittest.main()
