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
    "AGENTS.md",
    "docs/06_STARTING_FACTION_MASTERY_DATA.md",
    "docs/CANON_LIFECYCLE_REGISTRY.md",
    "docs/decisions/2026-08-02_PLATFORM_SCOPE_DECISION.md",
    "docs/decisions/2026-08-06_WINDOWS_ANDROID_DUAL_TARGET_DECISION.md",
    "docs/decisions/2026-08-02_RANGE_PRICE_BANDS_DECISION.md",
    "docs/decisions/2026-08-03_STARTING_MARTIAL_TECHNIQUE_1_BASE_EFFECTS_AND_BUDGETS_DECISION.md",
    "docs/planning-data/approved_20260803_starting_martial_technique_1_base_effects_and_budgets_contract.json",
    "docs/planning-data/approved_20260804_postmerge_canon_adversarial_audit_contract.json",
    "docs/decisions/2026-08-06_TEN_MANUAL_RUNTIME_IMPLEMENTATION_GATE.md",
    "docs/implementation/BUILD_APPROVAL_2026-08-06.md",
    "data/cards/martial_manual_cards.json",
    "docs/decisions/2026-08-06_TEN_MANUAL_UI_AI_ADOPTION_GATE.md",
    "data/combat/ten_manual_loadout_poc.json",
    "docs/decisions/2026-08-06_TEN_MANUAL_PRODUCT_VALIDATION_GATE.md",
    "docs/planning-data/approved_20260806_ten_manual_product_validation_gate_contract.json",
    "docs/evidence/TEN_MANUAL_PRODUCT_VALIDATION_EVIDENCE.md",
    "docs/research/STEP14_REPEAT_POC_PROTOCOL_DRAFT.md",
    "docs/research/STEP14_REPEAT_POC_RESULTS_TEMPLATE.md",
    "docs/planning-data/current_operating_state.json",
]
OPERATING_KEYS = (
    "active_planning_work_mode",
    "active_planning_pr",
    "active_planning_parent_pr",
    "active_approval_count",
    "active_decision_state",
    "next_package",
    "next_planning_decision",
)


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
        load_validator().validate(ROOT)

    def test_runtime_work_mode_accepts_current_build_state(self) -> None:
        validator = load_validator()
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory); copy_fixture(root)
            p = root / TARGETS[0]
            p.write_text(
                replace_scalar(p.read_text(encoding="utf-8"), "runtime_work_mode", "BUILD"),
                encoding="utf-8",
            )
            validator.validate(root)

    def test_runtime_work_mode_rejects_unknown_state(self) -> None:
        validator = load_validator()
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory); copy_fixture(root)
            p = root / TARGETS[0]
            p.write_text(
                replace_scalar(p.read_text(encoding="utf-8"), "runtime_work_mode", "UNBOUNDED"),
                encoding="utf-8",
            )
            with self.assertRaisesRegex(validator.CanonLifecycleError, "runtime work mode"):
                validator.validate(root)

    def test_stale_active_pr_state_is_rejected(self) -> None:
        validator = load_validator()
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory); copy_fixture(root)
            p = root / TARGETS[0]
            p.write_text(replace_scalar(p.read_text(encoding="utf-8"), "active_planning_pr", "87"), encoding="utf-8")
            with self.assertRaisesRegex(validator.CanonLifecycleError, "active planning PR"):
                validator.validate(root)

    def test_current_state_authority_must_match_canon(self) -> None:
        validator = load_validator()
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory); copy_fixture(root)
            p = root / TARGETS[-1]
            data = json.loads(p.read_text(encoding="utf-8"))
            data["active_planning_pr"] = "999"
            p.write_text(json.dumps(data, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
            with self.assertRaisesRegex(validator.CanonLifecycleError, "active planning PR"):
                validator.validate(root)

    def test_roadmap_does_not_duplicate_mutable_operating_checkpoint(self) -> None:
        roadmap = (ROOT / TARGETS[1]).read_text(encoding="utf-8")
        for key in OPERATING_KEYS:
            self.assertIsNone(
                re.search(rf"(?m)^{re.escape(key)}:\s*", roadmap),
                f"roadmap duplicates mutable operating checkpoint: {key}",
            )

    def test_product_validation_state_cannot_revert_to_ui_ai(self) -> None:
        validator = load_validator()
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory); copy_fixture(root)
            p = root / TARGETS[0]
            p.write_text(replace_scalar(p.read_text(encoding="utf-8"), "active_decision_state", "TEN_MANUAL_UI_AI_ADOPTED"), encoding="utf-8")
            with self.assertRaisesRegex(validator.CanonLifecycleError, "active decision state"):
                validator.validate(root)

    def test_platform_decision_cannot_revert_to_pc_first(self) -> None:
        validator = load_validator()
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory); copy_fixture(root)
            p = root / TARGETS[6]
            p.write_text(p.read_text(encoding="utf-8").replace("design_targets: [WINDOWS, ANDROID]", "design_targets: [WINDOWS]", 1), encoding="utf-8")
            with self.assertRaisesRegex(validator.CanonLifecycleError, "current platform Decision"):
                validator.validate(root)

    def test_runtime_foundation_cannot_reenable_stat_quotas(self) -> None:
        validator = load_validator()
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory); copy_fixture(root)
            p = root / TARGETS[13]; data = json.loads(p.read_text(encoding="utf-8")); data["stat_quota_rules_enabled"] = True; p.write_text(json.dumps(data, ensure_ascii=False, indent=2)+"\n", encoding="utf-8")
            with self.assertRaisesRegex(validator.CanonLifecycleError, "stat quota"):
                validator.validate(root)

    def test_runtime_foundation_requires_explicit_loadout(self) -> None:
        validator = load_validator()
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory); copy_fixture(root)
            p = root / TARGETS[13]; data = json.loads(p.read_text(encoding="utf-8")); data["compatibility"]["explicit_loadout_required"] = False; p.write_text(json.dumps(data, ensure_ascii=False, indent=2)+"\n", encoding="utf-8")
            with self.assertRaisesRegex(validator.CanonLifecycleError, "explicit loadout"):
                validator.validate(root)

    def test_ui_ai_loadout_must_separate_player_and_enemy(self) -> None:
        validator = load_validator()
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory); copy_fixture(root)
            p = root / TARGETS[15]; data = json.loads(p.read_text(encoding="utf-8")); del data["enemy"]; p.write_text(json.dumps(data, ensure_ascii=False, indent=2)+"\n", encoding="utf-8")
            with self.assertRaisesRegex(validator.CanonLifecycleError, "player and enemy loadouts"):
                validator.validate(root)

    def test_ui_ai_loadout_authority_cannot_drift(self) -> None:
        validator = load_validator()
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory); copy_fixture(root)
            p = root / TARGETS[15]; data = json.loads(p.read_text(encoding="utf-8")); data["authority"] = "TEN_MANUAL_RUNTIME_IMPLEMENTATION_GATE"; p.write_text(json.dumps(data, ensure_ascii=False, indent=2)+"\n", encoding="utf-8")
            with self.assertRaisesRegex(validator.CanonLifecycleError, "loadout authority"):
                validator.validate(root)

    def test_product_contract_cannot_drop_one_scenario(self) -> None:
        validator = load_validator()
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory); copy_fixture(root)
            p = root / TARGETS[17]; data = json.loads(p.read_text(encoding="utf-8")); data["scenario_matrix"] = data["scenario_matrix"][:-1]; p.write_text(json.dumps(data, ensure_ascii=False, indent=2)+"\n", encoding="utf-8")
            with self.assertRaisesRegex(validator.CanonLifecycleError, "scenario count"):
                validator.validate(root)

    def test_step14_cannot_claim_human_pass_with_zero_participants(self) -> None:
        validator = load_validator()
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory); copy_fixture(root)
            p = root / TARGETS[19]; p.write_text(p.read_text(encoding="utf-8").replace("human_step14: NOT_RUN", "human_step14: PASS", 1), encoding="utf-8")
            with self.assertRaisesRegex(validator.CanonLifecycleError, "STEP14 protocol"):
                validator.validate(root)

    def test_superseded_contract_cannot_claim_current_authority(self) -> None:
        validator = load_validator()
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory); copy_fixture(root)
            p = root / TARGETS[9]; data = json.loads(p.read_text(encoding="utf-8")); data["authority_status"] = "CURRENT_APPROVED_PLANNING"; p.write_text(json.dumps(data, ensure_ascii=False, indent=2)+"\n", encoding="utf-8")
            with self.assertRaisesRegex(validator.CanonLifecycleError, "superseded Technique1 contract"):
                validator.validate(root)

    def test_missing_korean_superseded_label_is_rejected(self) -> None:
        validator = load_validator()
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory); copy_fixture(root)
            p = root / TARGETS[7]; p.write_text(p.read_text(encoding="utf-8").replace("[대체됨]", "[현행]"), encoding="utf-8")
            with self.assertRaisesRegex(validator.CanonLifecycleError, "range Decision lifecycle"):
                validator.validate(root)

    def test_missing_core_fun_risk_is_rejected(self) -> None:
        validator = load_validator()
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory); copy_fixture(root)
            p = root / TARGETS[10]; data = json.loads(p.read_text(encoding="utf-8")); del data["adversarial_risks"]["RESOURCE_SATURATION_RISK"]; p.write_text(json.dumps(data, ensure_ascii=False, indent=2)+"\n", encoding="utf-8")
            with self.assertRaisesRegex(validator.CanonLifecycleError, "adversarial risk coverage"):
                validator.validate(root)

    def test_held_html_pr_cannot_be_mergeable_authority(self) -> None:
        validator = load_validator()
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory); copy_fixture(root)
            p = root / TARGETS[10]; data = json.loads(p.read_text(encoding="utf-8")); data["held_artifacts"][0]["merge_allowed"] = True; p.write_text(json.dumps(data, ensure_ascii=False, indent=2)+"\n", encoding="utf-8")
            with self.assertRaisesRegex(validator.CanonLifecycleError, "held HTML PR"):
                validator.validate(root)

    def test_individual_star9_work_cannot_skip_shared_template(self) -> None:
        validator = load_validator()
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory); copy_fixture(root)
            p = root / TARGETS[10]; data = json.loads(p.read_text(encoding="utf-8")); data["next_planning_order"] = data["next_planning_order"][1:]; p.write_text(json.dumps(data, ensure_ascii=False, indent=2)+"\n", encoding="utf-8")
            with self.assertRaisesRegex(validator.CanonLifecycleError, "9-star template"):
                validator.validate(root)


if __name__ == "__main__":
    unittest.main()
