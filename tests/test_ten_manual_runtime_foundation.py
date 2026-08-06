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
MANIFEST = ROOT / "data/cards/martial_manual_cards.json"


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
        manual_dir = ROOT / "data/cards/martial_manuals"
        if manual_dir.is_dir():
            shutil.copytree(manual_dir, root / "data/cards/martial_manuals")
        yield root


def read_json(root: Path, relative: str) -> dict:
    return json.loads((root / relative).read_text(encoding="utf-8"))


def write_json(root: Path, relative: str, value: dict) -> None:
    path = root / relative
    path.write_text(json.dumps(value, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")


def manual_path(root: Path, manual_id: str) -> str:
    manifest = read_json(root, "data/cards/martial_manual_cards.json")
    return manifest["manual_files"][manual_id]


class TenManualRuntimeFoundationTests(unittest.TestCase):
    def setUp(self) -> None:
        self.validator = load_validator()

    def assert_rejected(self, root: Path) -> None:
        with self.assertRaises(self.validator.RuntimeFoundationError):
            self.validator.validate(root)

    def require_manifest(self) -> None:
        if not MANIFEST.is_file():
            self.skipTest("runtime manifest intentionally absent during RED")

    def test_current_repository_passes(self) -> None:
        self.validator.validate(ROOT)

    def test_requires_exact_ten_manual_roster(self) -> None:
        self.require_manifest()
        with mutated_root() as root:
            manifest = read_json(root, "data/cards/martial_manual_cards.json")
            manifest["manual_files"].pop(next(iter(manifest["manual_files"])))
            write_json(root, "data/cards/martial_manual_cards.json", manifest)
            self.assert_rejected(root)

    def test_rejects_stat_assignment_drift(self) -> None:
        self.require_manifest()
        with mutated_root() as root:
            path = manual_path(root, "shaolin_arhat_vajra_art")
            manual = read_json(root, path)
            manual["primary_stat"] = "근골"
            write_json(root, path, manual)
            self.assert_rejected(root)

    def test_rejects_any_stat_quota_policy(self) -> None:
        self.require_manifest()
        with mutated_root() as root:
            manifest = read_json(root, "data/cards/martial_manual_cards.json")
            manifest["stat_quota_rules_enabled"] = True
            write_json(root, "data/cards/martial_manual_cards.json", manifest)
            self.assert_rejected(root)

    def test_rejects_star9_multiple_effects(self) -> None:
        self.require_manifest()
        with mutated_root() as root:
            path = manual_path(root, "wudang_taiji_sword")
            manual = read_json(root, path)
            manual["overlays"]["star9"]["effect_steps"].append({"op": "GAIN_RESOURCE", "resource": "internal", "amount": 1})
            write_json(root, path, manual)
            self.assert_rejected(root)

    def test_rejects_unsupported_effect_operation(self) -> None:
        self.require_manifest()
        with mutated_root() as root:
            path = manual_path(root, "sichuan_tang_hidden_weapons")
            manual = read_json(root, path)
            manual["cards"]["star10"]["effect_steps"][0]["op"] = "RANDOM_POISON_NOVA"
            write_json(root, path, manual)
            self.assert_rejected(root)

    def test_zixia_use_right_must_precede_all_recovery(self) -> None:
        self.require_manifest()
        with mutated_root() as root:
            path = manual_path(root, "mount_hua_purple_mist_art")
            manual = read_json(root, path)
            steps = manual["cards"]["star10"]["effect_steps"]
            steps[0], steps[1] = steps[1], steps[0]
            write_json(root, path, manual)
            self.assert_rejected(root)

    def test_returning_spear_requires_range_recheck(self) -> None:
        self.require_manifest()
        with mutated_root() as root:
            path = manual_path(root, "yang_family_spear")
            manual = read_json(root, path)
            steps = manual["cards"]["star10"]["effect_steps"]
            manual["cards"]["star10"]["effect_steps"] = [step for step in steps if step["op"] != "RECHECK_RANGE"]
            write_json(root, path, manual)
            self.assert_rejected(root)

    def test_legacy_card_compatibility_is_mandatory(self) -> None:
        self.require_manifest()
        with mutated_root() as root:
            manifest = read_json(root, "data/cards/martial_manual_cards.json")
            manifest["compatibility"]["preserved_card_ids"].remove("basic_move")
            write_json(root, "data/cards/martial_manual_cards.json", manifest)
            self.assert_rejected(root)


if __name__ == "__main__":
    unittest.main()
