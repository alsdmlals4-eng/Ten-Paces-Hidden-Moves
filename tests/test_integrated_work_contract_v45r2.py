from __future__ import annotations

import hashlib
import json
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
DECISION_ID = "TEN-DEC-20260811-INTEGRATED-WORK-CONTRACT-V4-5-R2-01"
PREVIOUS_DECISION_ID = "TEN-DEC-20260806-INTEGRATED-WORK-CONTRACT-V4-3-01"
SOURCE_SHA256 = "3f898b7e2749a2e1900e9df48183f02d4fbc735fd0e80297f28bb09317144de4"
BOUND_SHA256 = "0cc7943594d78824d6b3390232f61f12b8199d2f9f3b8817bf9953ed5aa90061"
CANONICAL = ROOT / "docs" / "PROJECT_TOTAL_PLANNING_IMPLEMENTATION_AND_DELIVERY_INSTRUCTION.md"
DECISION = ROOT / "docs" / "decisions" / "2026-08-11_INTEGRATED_WORK_CONTRACT_V4_5_R2_BINDING_DECISION.md"
CONTRACT = ROOT / "docs" / "planning-data" / "approved_20260811_integrated_work_contract_v4_5_r2_binding.json"
OLD_DECISION = ROOT / "docs" / "decisions" / "2026-08-06_INTEGRATED_WORK_CONTRACT_V4_3_BINDING_DECISION.md"
OLD_CONTRACT = ROOT / "docs" / "planning-data" / "approved_20260806_integrated_work_contract_v4_3_binding.json"
PARTS = [
    ROOT / "docs" / "contracts" / "integrated-work-v4.5-r2" / f"part-{index:02d}.md"
    for index in range(1, 7)
]


class IntegratedWorkContractV45R2Tests(unittest.TestCase):
    def load_json(self, path: Path) -> dict:
        return json.loads(path.read_text(encoding="utf-8"))

    def test_v45r2_is_the_project_bound_canonical_instruction(self) -> None:
        self.assertTrue(CANONICAL.is_file(), "Missing stable-path integrated work contract canon")
        text = CANONICAL.read_text(encoding="utf-8")

        for marker in (
            "contract_version: '4.5'",
            "revision: '2026-08-11-r2'",
            "status: ACTIVE_BASE_CURRENT_MAIN_THIN_ADAPTER_GODOT_DELIVERY_CONTRACT",
            "base_snapshot_policy: ALWAYS_REFETCH_CURRENT_MAIN_BEFORE_WORK",
            'project_repository: "https://github.com/alsdmlals4-eng/Ten-Paces-Hidden-Moves"',
            'project_local_path: "C:/Users/user/Documents/GitHub/Ninza/Ten-Paces-Hidden-Moves"',
            'canonical_local_checkout: "C:/Users/user/Documents/GitHub/Ninza/Ten-Paces-Hidden-Moves"',
            'godot_project_path: "C:/Users/user/Documents/GitHub/Ninza/Ten-Paces-Hidden-Moves"',
            'project_google_sheet: "https://docs.google.com/spreadsheets/d/1KzU5M7xsrbz3a3_vG0yEh3hqk736lrYJW3YgPPRloP0/edit?gid=0#gid=0"',
            'decision_ledger_source: "02_현재_확정결정"',
            'unresolved_items_source: "04_누락_충돌_감사"',
            'image_review_sheet_tab_or_range: "72_이미지검수_승인로그"',
        ):
            self.assertIn(marker, text)

        self.assertNotIn("Switchy-Express-Cargo-Puzzle", text)

    def test_v45r2_preserves_the_new_high_value_gates(self) -> None:
        text = CANONICAL.read_text(encoding="utf-8")
        for marker in (
            "GPT_CHAT_PLANNING_COMPLETE_BEFORE_POWERSHELL_CODEX_GODOT_BUILD",
            "EXTERNAL_PROCESS_OVERLAY_AUTHORITY_BOUNDARY",
            "PLAYER_EXPERIENCE_EVIDENCE_GATE",
            "FULL_SHA_ACTION_SUPPLY_CHAIN_GATE",
            "OPEN_DRAFT_PR_FULL_INVENTORY_GATE",
            "PROJECT_SOURCE_BCP_PROPOSAL_GATE",
            "PARTIAL_SKILL_ABSORPTION_GATE",
            "FUNCTION_LEVEL_VALIDITY_CLASSIFICATION_GATE",
            "USER_ACTION_REQUIRED_LAST_GATE",
        ):
            self.assertIn(marker, text)

        self.assertIn("base_snapshot_observed_when_v4_5_written: 7ce3fb64fa6303c5da6c7fc27c979f7233b761ac", text)
        self.assertIn("meaning: HISTORICAL_OBSERVATION_ONLY", text)
        self.assertIn("use_as_permanent_authority: false", text)

    def test_normative_parts_reconstruct_the_project_bound_source_exactly(self) -> None:
        for part in PARTS:
            self.assertTrue(part.is_file(), f"Missing normative body part: {part.relative_to(ROOT)}")

        reconstructed = b"".join(part.read_bytes() for part in PARTS)
        digest = hashlib.sha256(reconstructed).hexdigest()
        self.assertEqual(digest, BOUND_SHA256)
        text = reconstructed.decode("utf-8")
        self.assertNotIn("Switchy-Express-Cargo-Puzzle", text)
        self.assertIn("## 44. 최종 원칙", text)

    def test_binding_promotes_v45r2_and_preserves_v43_as_history(self) -> None:
        self.assertTrue(DECISION.is_file())
        self.assertTrue(CONTRACT.is_file())
        self.assertTrue(OLD_DECISION.is_file())
        self.assertTrue(OLD_CONTRACT.is_file())

        payload = self.load_json(CONTRACT)
        self.assertEqual(payload["decision_id"], DECISION_ID)
        self.assertEqual(payload["contract_name"], "PROJECT_TOTAL_PLANNING_IMPLEMENTATION_AND_DELIVERY_INSTRUCTION")
        self.assertEqual(payload["contract_version"], "4.5")
        self.assertEqual(payload["revision"], "2026-08-11-r2")
        self.assertEqual(payload["status"], "CURRENT_APPROVED_PROJECT_OPERATING_CONTRACT")
        self.assertEqual(payload["canonical_document"], "docs/PROJECT_TOTAL_PLANNING_IMPLEMENTATION_AND_DELIVERY_INSTRUCTION.md")
        self.assertEqual(payload["source_uploaded_sha256"], SOURCE_SHA256)
        self.assertEqual(payload["project_bound_sha256"], BOUND_SHA256)
        self.assertEqual(payload["supersedes_decision_id"], PREVIOUS_DECISION_ID)
        self.assertEqual(payload["project_repository"], "alsdmlals4-eng/Ten-Paces-Hidden-Moves")
        self.assertEqual(payload["project_google_sheet_id"], "1KzU5M7xsrbz3a3_vG0yEh3hqk736lrYJW3YgPPRloP0")
        self.assertTrue(payload["test_first_every_task"])
        self.assertEqual(payload["planning_completion_trigger"], "USER_EXPLICIT_PLANNING_COMPLETE_DECLARATION")
        self.assertEqual(payload["base_snapshot_policy"], "ALWAYS_REFETCH_CURRENT_MAIN_BEFORE_WORK")
        self.assertEqual(payload["normative_body_parts"], [str(part.relative_to(ROOT)).replace("\\", "/") for part in PARTS])

        decision_text = DECISION.read_text(encoding="utf-8")
        for marker in (DECISION_ID, PREVIOUS_DECISION_ID, SOURCE_SHA256, BOUND_SHA256, "CURRENT_APPROVED_PROJECT_OPERATING_CONTRACT"):
            self.assertIn(marker, decision_text)

    def test_cold_start_documents_route_to_v45r2_current_authority(self) -> None:
        canonical_path = "docs/PROJECT_TOTAL_PLANNING_IMPLEMENTATION_AND_DELIVERY_INSTRUCTION.md"
        for relative in ("AGENTS.md", "START_HERE.md"):
            text = (ROOT / relative).read_text(encoding="utf-8")
            self.assertIn(canonical_path, text, f"{relative} must route to the current integrated work contract")
            self.assertIn(DECISION_ID, text, f"{relative} must expose the current integrated work contract Decision ID")


if __name__ == "__main__":
    unittest.main()
