from __future__ import annotations

import importlib.util
import json
import shutil
import tempfile
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
TOOL = ROOT / "tools/check_poc_planning_data.py"


def load_validator():
    spec = importlib.util.spec_from_file_location("poc_planning_validator", TOOL)
    if spec is None or spec.loader is None:
        raise RuntimeError("cannot load PoC planning validator")
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


class PocPlanningDataTests(unittest.TestCase):
    def test_validator_exists(self) -> None:
        self.assertTrue(TOOL.is_file(), "PoC planning validator must exist")

    def test_current_planning_data_passes(self) -> None:
        if not TOOL.is_file():
            self.skipTest("validator not implemented yet")
        validator = load_validator()
        validator.run(ROOT)

    def test_out_of_tolerance_budget_is_rejected(self) -> None:
        if not TOOL.is_file():
            self.skipTest("validator not implemented yet")
        validator = load_validator()
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            shutil.copytree(ROOT / "docs/planning-data", root / "docs/planning-data")
            path = root / "docs/planning-data/poc_martial_arts.json"
            data = json.loads(path.read_text(encoding="utf-8"))
            technique = data["manuals"][0]["mastery"]["3"]["data"]
            technique["budget"]["variance_ticks"] = 6
            technique["budget"]["within_auto_tolerance"] = True
            path.write_text(json.dumps(data, ensure_ascii=False), encoding="utf-8")
            with self.assertRaises(validator.PlanningDataError):
                validator.run(root)

    def test_unknown_effect_scope_is_rejected(self) -> None:
        if not TOOL.is_file():
            self.skipTest("validator not implemented yet")
        validator = load_validator()
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            shutil.copytree(ROOT / "docs/planning-data", root / "docs/planning-data")
            path = root / "docs/planning-data/poc_martial_arts.json"
            data = json.loads(path.read_text(encoding="utf-8"))
            technique = data["manuals"][0]["mastery"]["3"]["data"]
            technique["effects"][0]["scope"] = "PER_BATTLE"
            path.write_text(json.dumps(data, ensure_ascii=False), encoding="utf-8")
            with self.assertRaises(validator.PlanningDataError):
                validator.run(root)


if __name__ == "__main__":
    unittest.main()
