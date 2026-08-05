import copy
import json
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
CONTRACT = ROOT / "docs/planning-data/approved_20260806_ten_recognizable_martial_manuals_contract.json"
CHECKER = ROOT / "tools/check_ten_recognizable_martial_manuals_contract.py"

EXPECTED_MANUALS = {
    "mount_hua_plum_blossom_sword": ("화산파", "매화검결", "신법", "외공", "이십사수매화검법"),
    "shaolin_arhat_vajra_art": ("소림사", "나한금강공", "외공", "내공", "여래신장"),
    "wudang_taiji_sword": ("무당파", "태극검결", "심안", "내공", "태극혜검"),
    "yang_family_spear": ("양가", "양가창결", "외공", "신법", "회마창"),
    "mount_hua_purple_mist_art": ("화산파", "자하심법", "내공", "근골", "자하신공"),
    "xiaoyao_lingbo_footwork": ("소요파", "소요보결", "신법", "심안", "능파미보"),
    "beggars_dragon_subduing_palm": ("개방", "강룡장결", "내공", "근골", "항룡십팔장"),
    "sichuan_tang_hidden_weapons": ("사천당문", "천기암기록", "심안", "신법", "만천화우"),
    "hebei_peng_five_tigers_saber": ("하북팽가", "팽가도결", "근골", "외공", "오호단문도"),
    "nangong_boundless_sky_sword": ("남궁세가", "창궁무애검법", "내공", "심안", "제왕검형"),
}

EXPECTED_CONFLICTS = {
    "metadata": "STAT_QUOTA_POLICY_CONFLICT",
    "stat": "STAT_AUTHORITY_CONFLICT",
    "rationale": "STAT_FIT_RATIONALE_CONFLICT",
    "growth": "GROWTH_STAGE_CONFLICT",
    "star9": "STAR9_SINGLE_EFFECT_CONFLICT",
    "zixia": "ZIXIA_ONCE_PER_BATTLE_CONFLICT",
    "vajra": "VAJRA_TENACITY_CONFLICT",
    "palm": "PALM_FORCE_STAT_CONFLICT",
    "scope": "TEN_MANUAL_SCOPE_CONFLICT",
}


class TenRecognizableMartialManualsContractTest(unittest.TestCase):
    def load_contract(self) -> dict:
        self.assertTrue(CONTRACT.is_file(), "ten-manual approved contract is missing")
        return json.loads(CONTRACT.read_text(encoding="utf-8"))

    def run_checker(self, contract_path: Path = CONTRACT) -> subprocess.CompletedProcess[str]:
        self.assertTrue(CHECKER.is_file(), "ten-manual checker is missing")
        return subprocess.run(
            [sys.executable, str(CHECKER), "--contract", str(contract_path)],
            cwd=ROOT,
            text=True,
            capture_output=True,
            check=False,
        )

    def mutate(self, edit) -> Path:
        data = copy.deepcopy(self.load_contract())
        edit(data)
        temp = tempfile.NamedTemporaryFile("w", suffix=".json", delete=False, encoding="utf-8")
        json.dump(data, temp, ensure_ascii=False, indent=2)
        temp.write("\n")
        temp.close()
        return Path(temp.name)

    def assert_mutation_rejected(self, edit, expected: str):
        path = self.mutate(edit)
        result = self.run_checker(path)
        self.assertNotEqual(result.returncode, 0)
        self.assertIn(expected, result.stdout + result.stderr)

    def test_contract_and_checker_exist(self):
        self.assertTrue(CONTRACT.is_file(), "ten-manual approved contract is missing")
        self.assertTrue(CHECKER.is_file(), "ten-manual checker is missing")

    def test_approved_contract_passes(self):
        result = self.run_checker()
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertIn("TEN_RECOGNIZABLE_MARTIAL_MANUALS_CONTRACT_PASS", result.stdout)

    def test_metadata_disables_stat_quota_rules(self):
        data = self.load_contract()
        self.assertEqual(
            data["decision_id"],
            "TEN-DEC-20260806-TEN-RECOGNIZABLE-MARTIAL-MANUALS-FULL-GROWTH-01",
        )
        self.assertEqual(data["implementation_authority"], "PLANNING_ONLY")
        self.assertEqual(data["approval_batch"], "9/10")
        self.assertEqual(data["stat_assignment_policy"], "FACTION_MARTIAL_ACTION_FIT_ONLY")
        self.assertFalse(data["stat_quota_rules_enabled"])
        self.assertNotIn("primary_stat_distribution", data)
        self.assertNotIn("secondary_stat_distribution", data)

    def test_exact_roster_factions_stats_and_ultimates(self):
        manuals = self.load_contract()["manuals"]
        self.assertEqual(set(manuals), set(EXPECTED_MANUALS))
        for manual_id, expected in EXPECTED_MANUALS.items():
            manual = manuals[manual_id]
            actual = (
                manual["faction"],
                manual["manual_name"],
                manual["primary_stat"],
                manual["secondary_stat"],
                manual["growth"]["star10"]["name"],
            )
            self.assertEqual(actual, expected, manual_id)
            self.assertTrue(manual["stat_fit_rationale"].strip(), manual_id)

    def test_every_manual_has_complete_growth_and_provenance(self):
        for manual_id, manual in self.load_contract()["manuals"].items():
            self.assertEqual(
                set(manual["growth"]),
                {"star3", "star5", "star7", "star9", "star10"},
                manual_id,
            )
            star9 = manual["growth"]["star9"]
            self.assertEqual(star9["effect_count"], 1, manual_id)
            self.assertFalse(star9["branching_allowed"], manual_id)
            self.assertFalse(star9["additional_input_allowed"], manual_id)
            self.assertFalse(star9["additional_resource_cost_allowed"], manual_id)
            self.assertIn(
                manual["provenance"]["classification"],
                {
                    "HISTORICAL_OR_ESTABLISHED",
                    "WUXIA_CONVENTIONAL",
                    "PROJECT_ORIGINAL",
                    "INSPIRED_HYBRID",
                },
                manual_id,
            )
            self.assertGreaterEqual(len(manual["resolution_order"]), 2, manual_id)
            self.assertTrue(manual["counterplay"], manual_id)

    def test_zixia_once_per_battle_contract(self):
        rules = self.load_contract()["special_rules"]["zixia_divine_art"]
        self.assertEqual(rules["uses_per_battle"], 1)
        self.assertEqual(rules["consume_timing"], "FIRST_PRELUDE_EXECUTION")
        self.assertFalse(rules["refund_on_interrupt"])
        self.assertEqual(rules["ultimate_momentum_gain"], 1)
        self.assertEqual(rules["ultimate_momentum_timing"], "ON_SUCCESSFUL_COMPLETION")
        self.assertFalse(rules["recharge_allowed"])

    def test_vajra_and_emitted_force_stat_contracts(self):
        rules = self.load_contract()["special_rules"]
        vajra = rules["vajra_tenacity"]
        self.assertEqual(vajra["grant_timing"], "BEFORE_ATTACK_OR_PRELUDE")
        self.assertEqual(vajra["uses_existing_rule_only"], True)
        self.assertFalse(vajra["absolute_interrupt_immunity"])
        force = rules["emitted_force_scaling"]
        self.assertEqual(force["default_primary_stat"], "내공")
        self.assertIn("항룡십팔장", force["approved_internal_examples"])
        self.assertIn("여래신장", force["approved_close_range_external_exceptions"])

    def test_scope_is_planning_only(self):
        scope = self.load_contract()["scope_boundary"]
        for key in ["product_code_changed", "godot_scene_changed", "html_poc_changed", "runtime_data_changed"]:
            self.assertFalse(scope[key])
        for key in ["runtime_validation", "human_validation", "balance_validation"]:
            self.assertEqual(scope[key], "NOT_RUN")

    def test_rejects_quota_policy_drift(self):
        self.assert_mutation_rejected(
            lambda d: d.update({"stat_quota_rules_enabled": True}),
            EXPECTED_CONFLICTS["metadata"],
        )

    def test_rejects_shaolin_or_beggars_stat_drift(self):
        self.assert_mutation_rejected(
            lambda d: d["manuals"]["shaolin_arhat_vajra_art"].update({"primary_stat": "근골"}),
            EXPECTED_CONFLICTS["stat"],
        )
        self.assert_mutation_rejected(
            lambda d: d["manuals"]["beggars_dragon_subduing_palm"].update({"primary_stat": "외공"}),
            EXPECTED_CONFLICTS["stat"],
        )

    def test_rejects_missing_stat_fit_rationale(self):
        self.assert_mutation_rejected(
            lambda d: d["manuals"]["beggars_dragon_subduing_palm"].update({"stat_fit_rationale": ""}),
            EXPECTED_CONFLICTS["rationale"],
        )

    def test_rejects_growth_or_star9_drift(self):
        self.assert_mutation_rejected(
            lambda d: d["manuals"]["mount_hua_plum_blossom_sword"]["growth"].pop("star5"),
            EXPECTED_CONFLICTS["growth"],
        )
        self.assert_mutation_rejected(
            lambda d: d["manuals"]["wudang_taiji_sword"]["growth"]["star9"].update({"effect_count": 2}),
            EXPECTED_CONFLICTS["star9"],
        )

    def test_rejects_zixia_vajra_or_force_drift(self):
        self.assert_mutation_rejected(
            lambda d: d["special_rules"]["zixia_divine_art"].update({"uses_per_battle": 2}),
            EXPECTED_CONFLICTS["zixia"],
        )
        self.assert_mutation_rejected(
            lambda d: d["special_rules"]["vajra_tenacity"].update({"absolute_interrupt_immunity": True}),
            EXPECTED_CONFLICTS["vajra"],
        )
        self.assert_mutation_rejected(
            lambda d: d["special_rules"]["emitted_force_scaling"].update({"default_primary_stat": "외공"}),
            EXPECTED_CONFLICTS["palm"],
        )

    def test_rejects_runtime_scope_drift(self):
        self.assert_mutation_rejected(
            lambda d: d["scope_boundary"].update({"runtime_data_changed": True}),
            EXPECTED_CONFLICTS["scope"],
        )


if __name__ == "__main__":
    unittest.main()
