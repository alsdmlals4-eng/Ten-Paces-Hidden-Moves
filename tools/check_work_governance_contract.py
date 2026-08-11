#!/usr/bin/env python3
from __future__ import annotations

import json
import pathlib
import sys
from typing import Any

ROOT = pathlib.Path(__file__).resolve().parents[1]
CONTRACT_PATH = ROOT / "docs" / "planning-data" / "approved_20260805_work_governance_contract.json"
EXPECTED_CHECKPOINT_TRIGGERS = {"HIGH_RISK_CONFLICT", "SESSION_END", "LARGE_CANON_IMPACT"}
EXPECTED_TDD_SEQUENCE = ["RED", "GREEN", "REFACTOR", "VERIFY_EXACT_HEAD"]
EXPECTED_PREWORK_SEQUENCE = [
    "FRESH_PROJECT_AUTHORITY_READ",
    "BENCHMARK_AND_INDUSTRY_RESEARCH",
    "PROJECT_FIT_RECOMMENDATION",
    "PLAN_TDD_OR_MUTATION",
]
REQUIRED_SOURCE_ORDER_PREFIX = [
    "OFFICIAL_DOCUMENTATION_OR_STANDARD",
    "PRIMARY_RESEARCH_OR_FIRST_PARTY_TECHNICAL_PAPER",
    "FIRST_PARTY_CASE_STUDY_OR_POSTMORTEM",
]
REQUIRED_ADVERSARIAL_CHECKS = {
    "CORE_FUN_ALIGNMENT", "CANON_CONFLICT", "MISSING_REQUIREMENT",
    "EXPLOIT_OR_ABUSE_PATH", "LEGACY_REFERENCE_DRIFT", "VALIDATION_OVERCLAIM",
}


class WorkGovernanceContractError(ValueError):
    pass


def _require(condition: bool, message: str) -> None:
    if not condition:
        raise WorkGovernanceContractError(message)


def validate(contract: dict[str, Any]) -> None:
    _require(contract.get("schema_version") == 1, "work governance schema differs")
    _require(contract.get("decision_id") == "TEN-DEC-20260805-WORK-GOVERNANCE-01", "work governance decision differs")
    _require(contract.get("authority_status") == "CURRENT_APPROVED_PROJECT_OPERATING_POLICY", "work governance authority differs")

    batch = contract.get("approval_batch", {})
    _require(batch.get("maximum_approval_items") == 10, "approval batch maximum must be exactly ten")
    _require(batch.get("counting_unit") == "DISTINCT_USER_APPROVAL_DECISIONS", "approval batch counting unit differs")
    _require(batch.get("larger_batch_requires_split") is True, "approval batch larger than ten must split")

    checkpoint = contract.get("checkpoint_policy", {})
    _require(checkpoint.get("early_checkpoint_allowed") is True, "early checkpoint must be allowed")
    _require(set(checkpoint.get("early_checkpoint_triggers", [])) == EXPECTED_CHECKPOINT_TRIGGERS, "checkpoint trigger coverage differs")
    required_evidence = {"DECISION_IDS", "AUTHORITY_PATHS", "EXACT_HEAD_OR_MERGE_SHA", "VALIDATION_STATE", "UNRESOLVED_RISKS", "NEXT_GATE"}
    _require(required_evidence.issubset(set(checkpoint.get("checkpoint_must_record", []))), "checkpoint evidence coverage differs")

    tdd = contract.get("tdd_policy", {})
    _require(tdd.get("required_for_every_task") is True, "TDD must be required for every task")
    _require(tdd.get("required_sequence") == EXPECTED_TDD_SEQUENCE, "RED must precede GREEN, REFACTOR, and exact-head verification")
    _require(tdd.get("implementation_before_red_allowed") is False, "implementation before RED is forbidden")
    _require(tdd.get("document_only_exception") is False, "document-only work cannot bypass TDD")
    _require(tdd.get("non_executable_work") == "WRITE_FAILING_CONTRACT_OR_REGRESSION_CHECK_BEFORE_CANON_IMPLEMENTATION", "non-executable work still requires a failing contract check")
    _require(tdd.get("failure_must_be_relevant") is True, "TDD RED failure must be relevant")

    benchmark = contract.get("benchmark_policy", {})
    _require(benchmark.get("required_for_material_questions_and_tasks") is True, "benchmarking is required for material work")
    _require(benchmark.get("required_before_every_project_task") is True, "benchmarking and industry research are required before every project task")
    _require(benchmark.get("research_depth") == "PROPORTIONAL_TO_TASK_RISK_AND_SCOPE", "benchmark research depth policy differs")
    _require(benchmark.get("timing") == "PRE_WORK_BEFORE_PLAN_OR_MUTATION", "benchmarking must happen before planning or mutation")
    _require(benchmark.get("research_packet_required_before_task") is True, "benchmark research packet is required before material work")
    _require(benchmark.get("required_prework_sequence") == EXPECTED_PREWORK_SEQUENCE, "benchmark pre-work sequence differs")
    _require(benchmark.get("compare_current_or_proposed_approach") is True, "benchmark comparison is required")
    _require(benchmark.get("industry_comparison_required") is True, "industry benchmark comparison is required")
    _require(benchmark.get("recommendation_required") is True, "benchmark recommendation is required")
    source_order = benchmark.get("preferred_source_order", [])
    _require(source_order[:3] == REQUIRED_SOURCE_ORDER_PREFIX, "benchmark source order must prefer official and primary evidence")
    _require(benchmark.get("minimum_reliable_comparables_when_available") >= 2, "benchmark comparable coverage is insufficient")
    _require(benchmark.get("when_no_reliable_comparable") == "DISCLOSE_GAP_AND_USE_EXPLICIT_INTERNAL_ASSUMPTIONS", "no reliable comparable must be disclosed rather than invented")
    _require(benchmark.get("current_verification_required_when_fact_may_have_changed") is True, "current benchmark verification is required")
    _require(benchmark.get("benchmark_must_not_override_project_core") is True, "benchmark cannot override project core")

    adversarial = contract.get("adversarial_review", {})
    _require(adversarial.get("required") is True, "adversarial review is required")
    _require(REQUIRED_ADVERSARIAL_CHECKS.issubset(set(adversarial.get("must_check", []))), "adversarial review coverage differs")

    boundary = contract.get("validation_boundary", {})
    _require(boundary.get("static_validation") == "REQUIRED", "static validation boundary differs")
    _require(boundary.get("human_validation") == "NOT_RUN_UNLESS_EXECUTED", "human validation cannot be overclaimed")
    _require(boundary.get("runtime_validation") == "NOT_RUN_UNLESS_EXECUTED", "runtime validation cannot be overclaimed")


def main() -> int:
    try:
        contract = json.loads(CONTRACT_PATH.read_text(encoding="utf-8"))
        validate(contract)
    except (OSError, json.JSONDecodeError, WorkGovernanceContractError) as exc:
        print(f"FAIL: {exc}", file=sys.stderr)
        return 1
    print("PASS: work governance contract is valid")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
