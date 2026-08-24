from __future__ import annotations

import copy
import json
import tempfile
import unittest
from pathlib import Path

from tools.validate_ten_manual_product_gate import (
    build_contract_from_manifest,
    validate_contract_document,
    validate_evidence_document,
)


ROOT = Path(__file__).resolve().parents[1]
MANIFEST_PATH = ROOT / "data/cards/martial_manual_cards.json"


class TenManualProductGateTests(unittest.TestCase):
    def setUp(self) -> None:
        self.manifest = json.loads(MANIFEST_PATH.read_text(encoding="utf-8"))
        self.contract = build_contract_from_manifest(self.manifest)
        self.valid_evidence = {
            "decision_id": "TEN_MANUAL_PRODUCT_VALIDATION_GATE",
            "head_sha": "a" * 40,
            "godot_version": "4.7.1",
            "platform": "windows-x86_64",
            "scenario_count": 50,
            "scenario_passed": 50,
            "scenario_failed": 0,
            "windows_export": "PASS",
            "windows_ci_runtime": "PASS",
            "windows_local_render": "NOT_RUN",
            "keyboard_synthetic": "PASS",
            "mouse_synthetic": "PASS",
            "gamepad_physical": "NOT_RUN",
            "resolution_matrix": "PASS",
            "accessibility_automated": "PASS",
            "accessibility_user": "NOT_RUN",
            "performance_baseline": "CAPTURED",
            "release_performance": "NOT_RUN",
            "human_step14": "NOT_RUN",
            "participant_count": 0,
            "product_gate": "PARTIAL_AUTOMATED_COMPLETE",
            "artifact": {
                "name": "ten-manual-product-validation-a",
                "workflow_run_id": "12345",
                "build_utc": "2026-08-06T00:00:00Z",
                "preset": "Windows Desktop Product Validation",
                "repository": "alsdmlals4-eng/Ten-Paces-Hidden-Moves",
                "pr": 92,
                "head_sha": "a" * 40,
            },
            "performance_environment": {
                "runner": "windows-latest",
                "godot_version": "4.7.1",
            },
        }

    def test_generated_contract_contains_exact_fifty_scenarios(self) -> None:
        errors = validate_contract_document(self.contract, self.manifest)
        self.assertEqual([], errors)
        self.assertEqual(50, len(self.contract["scenario_matrix"]))
        pairs = {
            (row["manual_id"], row["mastery"])
            for row in self.contract["scenario_matrix"]
        }
        self.assertEqual(50, len(pairs))

    def test_contract_rejects_forty_nine_scenarios(self) -> None:
        mutated = copy.deepcopy(self.contract)
        mutated["scenario_matrix"] = mutated["scenario_matrix"][:-1]
        errors = validate_contract_document(mutated, self.manifest)
        self.assertTrue(any("scenario_count" in error for error in errors), errors)

    def test_evidence_rejects_human_pass_with_zero_participants(self) -> None:
        mutated = copy.deepcopy(self.valid_evidence)
        mutated["human_step14"] = "PASS"
        errors = validate_evidence_document(
            mutated,
            self.contract,
            expected_sha="a" * 40,
        )
        self.assertTrue(any("human_step14" in error for error in errors), errors)

    def test_evidence_rejects_ci_claimed_as_local_windows_pass(self) -> None:
        mutated = copy.deepcopy(self.valid_evidence)
        mutated["windows_local_render"] = "PASS"
        errors = validate_evidence_document(
            mutated,
            self.contract,
            expected_sha="a" * 40,
        )
        self.assertTrue(any("windows_local_render" in error for error in errors), errors)

    def test_evidence_rejects_mismatched_head_sha(self) -> None:
        mutated = copy.deepcopy(self.valid_evidence)
        mutated["head_sha"] = "b" * 40
        errors = validate_evidence_document(
            mutated,
            self.contract,
            expected_sha="a" * 40,
        )
        self.assertTrue(any("head_sha" in error for error in errors), errors)

    def test_valid_automated_partial_evidence_passes(self) -> None:
        errors = validate_evidence_document(
            self.valid_evidence,
            self.contract,
            expected_sha="a" * 40,
        )
        self.assertEqual([], errors)

    def test_product_gate_generates_exact_main_evidence_after_relevant_merges(self) -> None:
        workflow = (
            ROOT / ".github/workflows/validate-ten-manual-product-gate.yml"
        ).read_text(encoding="utf-8")
        self.assertIn("on:\n  push:\n    branches: [main]", workflow)
        required_paths = (
            "project.godot",
            "export_presets.cfg",
            "data/**",
            "src/**",
            "scenes/**",
            "assets/**",
            "addons/**",
            "scripts/windows/**",
            "tools/validate_ten_manual_product_gate.py",
            "tests/test_ten_manual_product_gate.py",
            "tests/verify_ten_manual_product_gate.gd",
            "tests/verify_ten_manual_product_viewports.gd",
            "tests/verify_combat_keyboard_accessibility.gd",
            "tests/verify_combat_focus_order.gd",
            "tests/verify_combat_layout_accessibility.gd",
            "tests/verify_combat_action_selection_integration.gd",
            ".github/workflows/validate-ten-manual-product-gate.yml",
        )
        for path in required_paths:
            self.assertIn(f'      - "{path}"', workflow)
        self.assertNotIn('      - "tests/**"', workflow)
        self.assertIn("workflow_dispatch:", workflow)
        self.assertIn(
            "PR_NUMBER: ${{ github.event.pull_request.number || 0 }}",
            workflow,
        )
        self.assertNotIn("github.event.pull_request.number || 92", workflow)

        producer = (
            ROOT / "scripts/windows/run_ten_manual_product_validation.ps1"
        ).read_text(encoding="utf-8")
        self.assertIn("else { 0 }", producer)
        self.assertNotIn("else { 92 }", producer)

    def test_canonical_product_evidence_matches_latest_verified_artifact(self) -> None:
        canonical_paths = (
            ROOT / "docs/decisions/2026-08-06_TEN_MANUAL_PRODUCT_VALIDATION_GATE.md",
            ROOT / "docs/evidence/TEN_MANUAL_PRODUCT_VALIDATION_EVIDENCE.md",
            ROOT / "[기획서]/00_프로젝트_허브/ACTIVE_CONTEXT.md",
        )
        required_tokens = (
            "0a8bf577b936ddac5cb7130a0cc58e519ea6eff6",
            "31074079068",
            "8956790279",
            "2344.67",
            "188571648",
            "123037256",
        )
        stale_tokens = (
            "7494f50c48573168542781e007eeab6af11dda7d",
            "31068098197",
            "8954602789",
            "3018.23",
            "188674048",
        )

        for path in canonical_paths:
            text = path.read_text(encoding="utf-8")
            for token in required_tokens:
                self.assertIn(token, text, f"{path} missing {token}")
            for token in stale_tokens:
                self.assertNotIn(token, text, f"{path} retains stale {token}")


if __name__ == "__main__":
    unittest.main()
