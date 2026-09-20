"""Active instruction contracts: keep historical receipts, reject obsolete live gates."""
import json
import re
import unittest
from pathlib import Path
ROOT = Path(__file__).resolve().parents[1]
CONTRACT = "docs/PROJECT_TOTAL_PLANNING_IMPLEMENTATION_AND_DELIVERY_INSTRUCTION.md"

def read(path):
    return (ROOT / path).read_text(encoding="utf-8")

class LeanWorkExecutionTests(unittest.TestCase):
    def test_front_doors_start_with_project_authority(self):
        for path in ("AGENTS.md", "START_HERE.md", "[기획서]/00_프로젝트_허브/START_HERE.md"):
            text = read(path)
            self.assertNotIn("→ 최신 Base completed main / Base root AGENTS.md", text, path)
            self.assertIn("docs/BASE_RULES_VERSION.md", text, path)
    def test_same_session_execution_has_conditional_handoff(self):
        for path in (CONTRACT,"START_HERE.md","skills/qa/ten-paces-verification/SKILL.md", "skills/engineering/combat-implementation-handoff/SKILL.md"):
            text=read(path)
            self.assertIn("UNIFIED_WORK_EXECUTION",text,path)
            self.assertIn("HANDOFF_ONLY_FOR_CAPABILITY_GAP_OR_EXPLICIT_REQUEST",text,path)
            self.assertNotIn("실제 Godot 제품 구현 필요 → CODEX_GODOT_PRODUCT_IMPLEMENTATION_HANDOFF",text,path)
            self.assertNotIn("codex_execution_policy: INDEPENDENT_GODOT_PRODUCT_IMPLEMENTATION_HANDOFF_ONLY",text,path)
    def test_current_benchmark_reuses_evidence_without_fixed_quota(self):
        text=read(CONTRACT)
        self.assertIn("DECISION_RELEVANT_COMPARISON",text)
        self.assertNotIn("prework_benchmark_minimum_game_comparables_for_new_l1_plus_package: 10",text)
        p=json.loads(read("docs/planning-data/current_user_planning_status.json"))
        self.assertEqual("TEN-DEC-20260920-LEAN-WORK-EXECUTION-01",p["prework_benchmark_gate_decision"])
    def test_new_decision_does_not_claim_historical_merge_evidence(self):
        p=json.loads(read("docs/planning-data/current_user_planning_status.json"))
        self.assertNotIn("PR287",p["prework_benchmark_gate_status"])
        self.assertEqual(287,p["prework_benchmark_historical_gate_pr"])

    def test_lean_policy_regression_runs_for_document_only_changes(self):
        workflow=read(".github/workflows/documentation-governance.yml")
        section=workflow.split("- name: Run governance regression tests",1)[1].split("- name:",1)[0]
        self.assertIn("python -m unittest tests.test_lean_work_execution_adoption",section)
        self.assertNotIn("if:",section)

    def test_metadata_and_prose_share_effective_policy(self):
        text=read(CONTRACT)
        p=json.loads(read("docs/planning-data/current_user_planning_status.json"))
        effective=re.search(r"^prework_benchmark_reverse_engineering_gate: (.+)$",text,re.M).group(1)
        self.assertEqual(p["prework_benchmark_gate_decision"],effective)
        for path in (CONTRACT,"docs/BASE_RULES_VERSION.md"):
            self.assertIn("APPROVED_SCOPE_EXECUTION_NOT_CODEX_LAUNCHER",read(path))
            self.assertNotIn("LOCAL_GODOT_OR_VALIDATION_ONLY_NOT_CODEX_LAUNCHER",read(path))

    def test_approval_and_blockers_are_scoped(self):
        text=read("AGENTS.md")
        for marker in ("REUSED_APPROVAL","SOURCE_DEPENDENCY_SCOPED_BLOCKER","RECOVERY_ONLY","UNIFIED_WORK_EXECUTION"):
            self.assertIn(marker,text)
        self.assertIn("2회",text)
        self.assertNotIn("최소 5회",text)
    def test_adoption_keeps_release_evidence_and_refresh_route(self):
        d=json.loads(read("skills/PROJECT_BASE_ADAPTER.json"))
        self.assertEqual("9.4.4",d["base_release"]["version"])
        policy=d["shared_overrides"]["managing-project-intake-and-work-contract"]["lean_work_execution"]
        self.assertEqual("FETCH_CURRENT_MAIN_THEN_IMPACT_RECHECK",policy["freshness_policy"])
        self.assertTrue((ROOT/policy["project_owner"]).is_file())
        self.assertEqual("UNIFIED_WORK_EXECUTION",policy["execution_policy"])
    def test_fun_verification_is_connected_without_human_overclaim(self):
        for path in ("skills/game-design/ten-paces-game-design/SKILL.md", "skills/ux-ui-accessibility/combat-ux-and-accessibility/SKILL.md", "skills/qa/ten-paces-verification/SKILL.md"):
            text=read(path)
            self.assertIn("FUN_VERIFICATION_LIFECYCLE",text,path)
            self.assertIn("HUMAN_NOT_RUN",text,path)
        text=read(CONTRACT)
        for token in ("counterevidence", "GAMEPLAY_EFFECT", "PRESENTATION_EFFECT", "BIDIRECTIONAL_REQUIREMENT_TRACE", "src/combat/combat_resolution_engine.gd"):
            self.assertIn(token,text)
    def test_old_quota_cannot_be_reactivated(self):
        from tools.check_work_governance_contract import validate, WorkGovernanceContractError
        d=json.loads(read("docs/planning-data/approved_20260805_work_governance_contract.json"))
        d["benchmark_policy"]["minimum_unique_game_comparables_for_new_l1_plus_package"]=10
        with self.assertRaisesRegex(WorkGovernanceContractError,"quota"):
            validate(d)

    def test_skill_paths_and_conditional_details_remain_discoverable(self):
        registry=json.loads(read("skills/SKILL_REGISTRY.json"))
        for item in registry["skills"]:
            file=ROOT/"skills"/item["path"]
            text=file.read_text(encoding="utf-8")
            self.assertNotIn("PR #7",text)
            for target in re.findall(r"\]\(([^)]+)\)",text):
                if not target.startswith("http"):
                    self.assertTrue((file.parent/target.split("#")[0]).is_file(),target)

if __name__ == "__main__":
    unittest.main()
