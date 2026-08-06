from __future__ import annotations

import importlib.util
import json
import re
import shutil
import tempfile
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
VALIDATOR_PATH = ROOT / "tools" / "check_postmerge_canon_lifecycle.py"

TARGETS = [
    "[기획서]/00_프로젝트_허브/ACTIVE_CONTEXT.md",
    "docs/04_ROADMAP.md",
    "docs/06_STARTING_FACTION_MASTERY_DATA.md",
    "docs/CANON_LIFECYCLE_REGISTRY.md",
    "docs/decisions/2026-08-02_RANGE_PRICE_BANDS_DECISION.md",
    "docs/decisions/2026-08-03_STARTING_MARTIAL_TECHNIQUE_1_BASE_EFFECTS_AND_BUDGETS_DECISION.md",
    "docs/planning-data/approved_20260803_starting_martial_technique_1_base_effects_and_budgets_contract.json",
    "docs/planning-data/approved_20260804_postmerge_canon_adversarial_audit_contract.json",
]


def load_validator():
    spec = importlib.util.spec_from_file_location("postmerge_canon_lifecycle", VALIDATOR_PATH)
    if spec is None or spec.loader is None:
        raise RuntimeError("post-merge canon validator cannot be loaded")
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def copy_fixture(destination: Path) -> None:
    for relative in TARGETS:
        source = ROOT / relative
        target = destination / relative
        target.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(source, target)


def replace_scalar(text: str, key: str, value: str) -> str:
    pattern = rf"(?m)^{re.escape(key)}:\s*\S+\s*$"
    replaced, count = re.subn(pattern, f"{key}: {value}", text)
    if count != 1:
        raise AssertionError(f"expected one scalar for {key}, found {count}")
    return replaced


class PostMergeCanonLifecycleTests(unittest.TestCase):
    def test_current_repository_passes(self) -> None:
        validator = load_validator()
        validator.validate(ROOT)

    def test_stale_active_pr_state_is_rejected(self) -> None:
        validator = load_validator()
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            copy_fixture(root)
            for relative in TARGETS[:2]:
                path = root / relative
                path.write_text(
                    replace_scalar(path.read_text(encoding="utf-8"), "active_planning_pr", "87"),
                    encoding="utf-8",
                )
            with self.assertRaisesRegex(validator.CanonLifecycleError, "active planning PR"):
                validator.validate(root)

    def test_active_context_and_roadmap_must_share_checkpoint(self) -> None:
        validator = load_validator()
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            copy_fixture(root)
            path = root / TARGETS[1]
            path.write_text(
                replace_scalar(path.read_text(encoding="utf-8"), "active_planning_parent_pr", "91"),
                encoding="utf-8",
            )
            with self.assertRaisesRegex(validator.CanonLifecycleError, "operating checkpoint mismatch"):
                validator.validate(root)

    def test_superseded_contract_cannot_claim_current_authority(self) -> None:
        validator = load_validator()
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            copy_fixture(root)
            path = root / TARGETS[6]
            data = json.loads(path.read_text(encoding="utf-8"))
            data["authority_status"] = "CURRENT_APPROVED_PLANNING"
            path.write_text(json.dumps(data, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
            with self.assertRaisesRegex(validator.CanonLifecycleError, "superseded Technique1 contract"):
                validator.validate(root)

    def test_missing_korean_superseded_label_is_rejected(self) -> None:
        validator = load_validator()
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            copy_fixture(root)
            path = root / TARGETS[4]
            path.write_text(path.read_text(encoding="utf-8").replace("[대체됨]", "[현행]"), encoding="utf-8")
            with self.assertRaisesRegex(validator.CanonLifecycleError, "range Decision lifecycle"):
                validator.validate(root)

    def test_missing_core_fun_risk_is_rejected(self) -> None:
        validator = load_validator()
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            copy_fixture(root)
            path = root / TARGETS[7]
            data = json.loads(path.read_text(encoding="utf-8"))
            del data["adversarial_risks"]["RESOURCE_SATURATION_RISK"]
            path.write_text(json.dumps(data, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
            with self.assertRaisesRegex(validator.CanonLifecycleError, "adversarial risk coverage"):
                validator.validate(root)

    def test_held_html_pr_cannot_be_mergeable_authority(self) -> None:
        validator = load_validator()
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            copy_fixture(root)
            path = root / TARGETS[7]
            data = json.loads(path.read_text(encoding="utf-8"))
            data["held_artifacts"][0]["merge_allowed"] = True
            path.write_text(json.dumps(data, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
            with self.assertRaisesRegex(validator.CanonLifecycleError, "held HTML PR"):
                validator.validate(root)

    def test_individual_star9_work_cannot_skip_shared_template(self) -> None:
        validator = load_validator()
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            copy_fixture(root)
            path = root / TARGETS[7]
            data = json.loads(path.read_text(encoding="utf-8"))
            data["next_planning_order"] = data["next_planning_order"][1:]
            path.write_text(json.dumps(data, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
            with self.assertRaisesRegex(validator.CanonLifecycleError, "9-star template"):
                validator.validate(root)


if __name__ == "__main__":
    unittest.main()
