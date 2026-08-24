import json
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
FIXTURE = ROOT / "docs/validation/TEN_PACES_UX_UI_FIXTURE_CATALOG.md"
PACKET = ROOT / "docs/validation/TEN_PACES_UX_UI_VALIDATION_PACKET.md"
CONTRACT = ROOT / "docs/planning-data/current_issue54_human_device_validation_packet.json"
LAUNCHER = ROOT / "tools/start_issue54_human_validation.ps1"
PR_VALIDATION = ROOT / ".github/workflows/documentation-governance.yml"


class Issue54HumanDeviceValidationPacketTests(unittest.TestCase):
    def test_required_artifacts_exist(self):
        self.assertTrue(FIXTURE.is_file(), "Issue #54 fixture catalog must exist")
        self.assertTrue(PACKET.is_file(), "Issue #54 executable validation packet must exist")
        self.assertTrue(CONTRACT.is_file(), "Issue #54 structured validation contract must exist")

    def test_fixture_catalog_covers_core_ux_failure_modes(self):
        text = FIXTURE.read_text(encoding="utf-8")
        for token in (
            "3수 → 해결 → 3수 → 해결 → 4수 → 해결",
            "VALID_SELECTION",
            "RANGE_INSUFFICIENT",
            "RESOURCE_INSUFFICIENT",
            "INVALID_TARGET",
            "SLOT_COLLISION",
            "PLAN_ORDER_CHANGES_RESULT",
            "CLASH_CAUSAL_CHAIN",
            "LONG_KOREAN_TEXT",
            "CONFIRMED_VS_UNCERTAIN_INTENT",
            "SHARED_PLAYER_AI_MARTIAL_POOL",
            "BAD_CONTENT_ASYMMETRY",
        ):
            self.assertIn(token, text)

    def test_validation_packet_preserves_evidence_boundaries(self):
        text = PACKET.read_text(encoding="utf-8")
        for token in (
            "tools/collect_godot_live_evidence.ps1",
            "QA Evidence Studio",
            "Windows visible local",
            "physical gamepad",
            "Android actual device",
            "accessibility user",
            "Human fun/readability/immersion",
            "5명 중 4명 이상",
            "15명 상대 식별성",
            "focused",
            "selected",
            "[합]",
            "BAD_CONTENT_ASYMMETRY",
            "NOT_RUN",
            "자동 증거는 Human PASS를 대신하지 않는다",
        ):
            self.assertIn(token, text)

    def test_fresh_runtime_artifact_gate_is_explicit_and_fail_closed(self):
        text = PACKET.read_text(encoding="utf-8")
        for token in (
            "FRESH_RUNTIME_ARTIFACT_GATE",
            "PRIOR_ARTIFACT_EXISTENCE_IS_NOT_FRESH_EVIDENCE",
            "STALE_ARTIFACT_FALSE_PASS",
            "exact build/commit + run identity",
            "artifact path + bytes/hash + run/build identity",
            "INCONCLUSIVE_NOT_PASS",
        ):
            self.assertIn(token, text)

        payload = json.loads(CONTRACT.read_text(encoding="utf-8"))
        freshness = payload["runtime_artifact_freshness"]
        self.assertEqual(freshness["gate"], "FRESH_RUNTIME_ARTIFACT_GATE")
        self.assertEqual(freshness["status"], "REQUIRED_AT_EXECUTION")
        self.assertFalse(freshness["prior_artifact_existence_is_fresh_evidence"])
        self.assertTrue(freshness["require_exact_build_commit_and_run_identity"])
        self.assertTrue(freshness["require_path_bytes_hash_and_run_build_identity"])
        self.assertEqual(freshness["fresh_artifact_missing_result"], "INCONCLUSIVE_NOT_PASS")

    def test_exact_main_product_evidence_route_is_structured_and_non_promotional(self):
        text = PACKET.read_text(encoding="utf-8")
        for token in (
            "Validate Ten Manual Product Gate",
            "PR #195",
            "UNVERIFIED_CONNECTOR_LIMIT",
            "push-run PASS로 승격하지 않는다",
        ):
            self.assertIn(token, text)

        payload = json.loads(CONTRACT.read_text(encoding="utf-8"))
        route = payload["exact_main_product_evidence_route"]
        self.assertEqual(route["status"], "ACTIVE")
        self.assertEqual(
            route["workflow"],
            ".github/workflows/validate-ten-manual-product-gate.yml",
        )
        self.assertEqual(route["route_merge_pr"], 195)
        self.assertEqual(
            route["route_merge_sha"],
            "020b5cabf3f5d8d950b089dfefdd9bd148333b8a",
        )
        self.assertEqual(route["last_exact_main_push_observation"], "UNVERIFIED_CONNECTOR_LIMIT")
        self.assertEqual(
            route["latest_verified_pr_head"],
            "869b9cd54c778848638ac87721c1d1eb349d97cd",
        )
        self.assertEqual(route["latest_verified_pr_run_id"], 32714634940)
        self.assertEqual(route["latest_verified_windows_artifact_id"], 9515454613)
        self.assertEqual(
            route["latest_verified_windows_artifact_digest"],
            "sha256:a72a46df70005c6f5def8e05457a57957e3fd5b1af73969377700666cca080ae",
        )
        self.assertFalse(route["push_observation_promotes_human_or_device_pass"])

    def test_one_shot_launcher_reuses_existing_evidence_owners_and_stays_fail_closed(self):
        self.assertTrue(LAUNCHER.is_file(), "Issue #54 one-shot launcher must exist")
        text = LAUNCHER.read_text(encoding="utf-8")
        for token in (
            "ISSUE54_HUMAN_VALIDATION_LAUNCHER",
            "FRESH_RUNTIME_ARTIFACT_GATE",
            "git ls-remote origin refs/heads/main",
            "LOCAL_HEAD_MUST_EQUAL_REMOTE_MAIN",
            "BASE_HEAD_MUST_EQUAL_REMOTE_MAIN",
            "collect_godot_live_evidence.ps1",
            "Windows Desktop Product Validation",
            "Get-FileHash",
            "qa_evidence_studio.app",
            "ten-paces-hidden-moves",
            "installed-base-identity.json",
            "base_root",
            "base_main_commit",
            'Assert-TrackedClean $baseRootResolved "QA_STUDIO_INSTALL"',
            'Assert-TrackedClean $baseRootResolved "LAUNCH_READY"',
            "QA_PROCESS_CLEANUP_AFTER_GAME_LAUNCH_FAILURE",
            "BROWSER_OPEN_FAILED",
            "HUMAN_DEVICE_STATUS_REMAINS_NOT_RUN_UNTIL_REVIEW",
        ):
            self.assertIn(token, text)
        for forbidden in (
            "installed-base-main-sha.txt",
            "git reset --hard",
            "git clean -fd",
            "git pull",
            "windows_visible_local_usability = 'PASS'",
            "human_step14 = 'PASS'",
        ):
            self.assertNotIn(forbidden, text)

        packet = PACKET.read_text(encoding="utf-8")
        self.assertIn("tools/start_issue54_human_validation.ps1", packet)
        payload = json.loads(CONTRACT.read_text(encoding="utf-8"))
        self.assertEqual(
            payload["owners"]["human_validation_launcher"],
            "tools/start_issue54_human_validation.ps1",
        )
        workflow = PR_VALIDATION.read_text(encoding="utf-8")
        self.assertIn('"tools/start_issue54_human_validation.ps1"', workflow)

    def test_structured_contract_is_machine_readable_and_non_promotional(self):
        payload = json.loads(CONTRACT.read_text(encoding="utf-8"))
        self.assertEqual(payload["issue_number"], 54)
        self.assertEqual(payload["status"], "READY_FOR_HUMAN_DEVICE_EXECUTION")
        self.assertFalse(payload["runtime_mutation_authorized"])
        self.assertEqual(payload["human_validation"]["target_participants"], 5)
        self.assertEqual(payload["human_validation"]["pass_threshold"], 4)
        self.assertEqual(payload["windows_visible_local_usability"], "NOT_RUN")
        self.assertEqual(payload["physical_gamepad"], "NOT_RUN")
        self.assertEqual(payload["android_physical_device"], "NOT_RUN")
        self.assertEqual(payload["accessibility_user"], "NOT_RUN")
        self.assertEqual(payload["human_fun_readability_immersion"], "NOT_RUN")
        self.assertEqual(payload["fifteen_opponent_identifiability"], "NOT_RUN")
        self.assertEqual(payload["release_performance"], "NOT_RUN")
        self.assertEqual(payload["shared_player_ai_martial_pool"]["enemy_exclusive_manuals_allowed"], False)
        self.assertEqual(payload["shared_player_ai_martial_pool"]["enemy_exclusive_techniques_allowed"], False)
        self.assertEqual(payload["shared_player_ai_martial_pool"]["remaining_four_acquisition_paths"], "NOT_ASSERTED_IMPLEMENTED")

        close_requirements = payload["close_issue_only_when"]
        self.assertIn("physical_gamepad_has_real_evidence", close_requirements)
        self.assertIn("accessibility_user_has_real_evidence", close_requirements)
        self.assertIn("fifteen_opponent_identifiability_has_real_evidence", close_requirements)
        self.assertFalse(any("declared_shipping" in item for item in close_requirements))
        self.assertFalse(any("explicit_release_scope_decision" in item for item in close_requirements))


if __name__ == "__main__":
    unittest.main()
