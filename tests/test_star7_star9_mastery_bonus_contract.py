import json
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
CONTRACT = ROOT / "docs/planning-data/approved_20260805_star7_star9_mastery_bonus_contract.json"
CHECKER = ROOT / "tools/check_star7_star9_mastery_bonus_contract.py"
DECISION = ROOT / "docs/decisions/2026-08-05_STAR7_STAR9_MASTERY_BONUS_DECISION.md"

EXPECTED = {
    "falling_petal_chasing_sword": (65, 75, 25, 100),
    "rebounding_vajra_fist": (65, 75, 25, 100),
    "four_ounces_move_thousand_pounds": (66, 76, 25, 101),
    "chained_road_lock": (75, 85, 27, 112),
    "returning_qi_meridian": (61, 71, 24, 95),
    "ten_paces_position_reversal": (96, 106, 31, 137),
}


class Star7Star9MasteryBonusContractTest(unittest.TestCase):
    def run_checker(self, contract_path: Path = CONTRACT) -> subprocess.CompletedProcess[str]:
        return subprocess.run(
            [sys.executable, str(CHECKER), "--contract", str(contract_path)],
            cwd=ROOT,
            text=True,
            capture_output=True,
            check=False,
        )

    def load_contract(self) -> dict:
        self.assertTrue(CONTRACT.is_file(), "approved Star7/Star9 mastery contract is missing")
        return json.loads(CONTRACT.read_text(encoding="utf-8"))

    def mutate(self, edit) -> Path:
        data = self.load_contract()
        edit(data)
        temp = tempfile.NamedTemporaryFile("w", suffix=".json", delete=False, encoding="utf-8")
        json.dump(data, temp, ensure_ascii=False, indent=2)
        temp.write("\n")
        temp.close()
        return Path(temp.name)

    def assert_mutation_rejected(self, edit, expected: str):
        mutated = self.mutate(edit)
        result = self.run_checker(mutated)
        self.assertNotEqual(result.returncode, 0)
        self.assertIn(expected, result.stdout + result.stderr)

    def test_contract_checker_and_decision_exist(self):
        self.assertTrue(CONTRACT.is_file(), "approved Star7/Star9 mastery contract is missing")
        self.assertTrue(CHECKER.is_file(), "Star7/Star9 mastery checker is missing")
        self.assertTrue(DECISION.is_file(), "Star7/Star9 mastery Decision is missing")

    def test_approved_contract_passes(self):
        result = self.run_checker()
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertIn("STAR7_STAR9_MASTERY_BONUS_CONTRACT_PASS", result.stdout)

    def test_metadata_closes_ten_of_ten_checkpoint(self):
        data = self.load_contract()
        self.assertEqual(data["decision_id"], "TEN-DEC-20260805-STAR7-STAR9-MASTERY-BONUS-01")
        self.assertEqual(data["authority_status"], "CURRENT_APPROVED_PLANNING_GOVERNANCE")
        self.assertEqual(data["implementation_authority"], "PLANNING_ONLY")
        self.assertEqual(data["active_approval_count"], "10/10")
        self.assertEqual(data["next_planning_decision"], "SIX_STAR7_MASTERY_BONUS_ALLOCATIONS")

    def test_budget_source_is_effective_reprice_overlay(self):
        source = self.load_contract()["budget_source"]
        self.assertEqual(source["contract"], "approved_20260804_existing_action_reprice_contract.json")
        self.assertEqual(source["field"], "actions[].available_budget_ticks")
        self.assertEqual(source["category"], "technique_2")

    def test_star7_and_star9_formulas_are_fixed(self):
        data = self.load_contract()
        star7 = data["star7_policy"]
        star9 = data["star9_policy"]
        self.assertEqual(star7["fixed_mastery_bonus_ticks"], 10)
        self.assertEqual(star7["formula"], "effective_existing_budget_ticks + 10")
        self.assertEqual(star9["fixed_mastery_bonus_ticks"], 10)
        self.assertEqual(star9["percentage_of_star7_final_budget"], 0.20)
        self.assertEqual(star9["rounding"], "FLOOR_TO_INTEGER_TICKS")
        self.assertEqual(star9["bonus_formula"], "10 + floor(star7_final_budget_ticks * 0.20)")
        self.assertEqual(star9["total_formula"], "star7_final_budget_ticks + star9_bonus_ticks")

    def test_all_six_budget_rows_match_current_reprice_authority(self):
        techniques = self.load_contract()["techniques"]
        self.assertEqual(set(techniques), set(EXPECTED))
        for technique_id, expected in EXPECTED.items():
            item = techniques[technique_id]
            actual = (
                item["effective_existing_budget_ticks"],
                item["star7_final_budget_ticks"],
                item["star9_bonus_ticks"],
                item["star9_total_budget_ticks"],
            )
            self.assertEqual(actual, expected, technique_id)

    def test_star9_is_single_effect_and_branchless(self):
        policy = self.load_contract()["star9_policy"]
        self.assertEqual(policy["effect_count_per_technique"], 1)
        self.assertFalse(policy["branching_allowed"])
        self.assertFalse(policy["public_trigger_required"])
        self.assertFalse(policy["additional_player_input_allowed"])
        self.assertFalse(policy["additional_resource_cost_allowed"])
        self.assertFalse(policy["multiple_bonus_effects_allowed"])
        self.assertTrue(policy["one_sentence_card_rule_required"])

    def test_role_nonreplacement_and_deferred_allocations(self):
        data = self.load_contract()
        self.assertTrue(data["role_policy"]["value_superior_role_nonreplacement_required"])
        self.assertFalse(data["role_policy"]["technique1_role_duplication_allowed"])
        self.assertFalse(data["role_policy"]["core_role_change_allowed"])
        self.assertEqual(
            data["star7_policy"]["individual_bonus_allocation_status"],
            "PENDING_SEPARATE_GRILLME_DECISION",
        )
        self.assertEqual(
            data["star9_policy"]["individual_effect_allocation_status"],
            "PENDING_SEPARATE_GRILLME_DECISION",
        )

    def test_scope_remains_planning_only(self):
        scope = self.load_contract()["scope_boundary"]
        for key in [
            "product_code_changed",
            "godot_scene_changed",
            "html_poc_changed",
            "runtime_data_changed",
        ]:
            self.assertFalse(scope[key])
        for key in [
            "runtime_validation",
            "godot_validation",
            "windows_validation",
            "accessibility_validation",
            "performance_validation",
            "human_validation",
            "balance_validation",
        ]:
            self.assertEqual(scope[key], "NOT_RUN")

    def test_later_authorities_preserve_mastery_and_product_lineage(self):
        active = (ROOT / "[기획서]/00_프로젝트_허브/ACTIVE_CONTEXT.md").read_text(encoding="utf-8")
        roadmap = (ROOT / "docs/04_ROADMAP.md").read_text(encoding="utf-8")
        mastery = (ROOT / "docs/06_STARTING_FACTION_MASTERY_DATA.md").read_text(encoding="utf-8")

        for current in [active, roadmap]:
            self.assertIn("TEN_MANUAL_UI_AI_ADOPTION_GATE", current)
            self.assertIn("TEN_MANUAL_PRODUCT_VALIDATION_GATE", current)
            self.assertIn("merged_product_pr: 92", current)
            self.assertIn("product_implementation_merge_commit: a839cd724d0d3ca60c8066abe5a1e2a5e0b78e90", current)
            self.assertIn("active_approval_count: 1/10", current)
            self.assertIn("active_decision_state: WINDOWS_ANDROID_ADAPTER_ARCHITECTURE_MERGED", current)
            self.assertIn("next_planning_decision: WINDOWS_ANDROID_ADAPTER_IMPLEMENTATION_GATE", current)

        self.assertIn("runtime_implementation: TEN_MANUAL_PRODUCT_VALIDATION_MERGED_PR92", active)
        self.assertIn("product_gate: PARTIAL_AUTOMATED_COMPLETE", active)
        self.assertIn("evidence_source_head: 0a8bf577b936ddac5cb7130a0cc58e519ea6eff6", active)

        self.assertIn("active_batch: 10/10", mastery)
        self.assertIn("implementation_authority: RUNTIME_FOUNDATION", mastery)
        self.assertIn("approved_20260806_ten_recognizable_martial_manuals_contract.json", mastery)
        self.assertIn("approved_20260806_ten_manual_growth_budget_overlay_contract.json", mastery)
        self.assertNotIn("active_batch: 9/10", mastery)

    def test_rejects_star7_bonus_drift(self):
        self.assert_mutation_rejected(
            lambda data: data["star7_policy"].update({"fixed_mastery_bonus_ticks": 8}),
            "STAR7_BONUS_CONFLICT",
        )

    def test_rejects_star9_percentage_or_rounding_drift(self):
        self.assert_mutation_rejected(
            lambda data: data["star9_policy"].update({"percentage_of_star7_final_budget": 0.25}),
            "STAR9_FORMULA_CONFLICT",
        )
        self.assert_mutation_rejected(
            lambda data: data["star9_policy"].update({"rounding": "ROUND_HALF_UP"}),
            "STAR9_FORMULA_CONFLICT",
        )

    def test_rejects_branching_or_additional_input(self):
        self.assert_mutation_rejected(
            lambda data: data["star9_policy"].update({"branching_allowed": True}),
            "STAR9_SIMPLICITY_CONFLICT",
        )
        self.assert_mutation_rejected(
            lambda data: data["star9_policy"].update({"additional_player_input_allowed": True}),
            "STAR9_SIMPLICITY_CONFLICT",
        )

    def test_rejects_premature_individual_effect_approval(self):
        self.assert_mutation_rejected(
            lambda data: data["star9_policy"].update({"individual_effect_allocation_status": "APPROVED"}),
            "MASTERY_ALLOCATION_SCOPE_CONFLICT",
        )


if __name__ == "__main__":
    unittest.main()
