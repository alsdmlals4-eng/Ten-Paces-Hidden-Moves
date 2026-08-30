"""Validate deterministic balance instrumentation output without reimplementing combat."""

from __future__ import annotations

import json
import sys
from pathlib import Path
from typing import Any


CONTRACT_ID = "TEN-DEC-20260830-BALANCE-INSTRUMENTATION-CONTRACT-01"
EXPECTED_SCENARIOS = 3375
EXPECTED_ROUTE_CONTEXT = "opening_no_route"
EXPECTED_ROW_KEYS = {
    "scenario_id",
    "candidate_id",
    "starter_loadout_id",
    "player_policy_id",
    "ai_decision_seed",
    "route_context_id",
    "outcome",
    "bundles_resolved",
    "battle_metrics",
}
EXPECTED_METRIC_KEYS = {
    "successful_dodges",
    "clash_wins",
    "player_health_lost",
    "rounds_elapsed",
    "ultimate_uses",
}
EXPECTED_POLICIES = {
    "public_approach_pressure",
    "public_guarded_exchange",
    "public_recovery_range",
}
EXPECTED_SEEDS = {0, 1, 17, 101, 1009}
FORBIDDEN_TOKENS = (
    "ai_profile",
    "weight",
    "trace",
    "locked_enemy",
    "pending",
    "preview",
    "pointer",
    "focus",
    "observation",
)


def _load(path: Path) -> tuple[bytes, dict[str, Any]]:
    raw = path.read_bytes()
    value = json.loads(raw.decode("utf-8"))
    if not isinstance(value, dict):
        raise AssertionError("report root must be an object")
    return raw, value


def _assert_no_forbidden(value: Any) -> None:
    if isinstance(value, dict):
        for key, child in value.items():
            lowered = str(key).lower()
            assert not any(token in lowered for token in FORBIDDEN_TOKENS), key
            _assert_no_forbidden(child)
    elif isinstance(value, list):
        for child in value:
            _assert_no_forbidden(child)


def _validate(report: dict[str, Any]) -> None:
    assert report["schema_version"] == 1
    assert report["contract_id"] == CONTRACT_ID
    assert report["route_context_id"] == EXPECTED_ROUTE_CONTEXT
    assert report["scenario_count_expected"] == EXPECTED_SCENARIOS
    assert report["scenario_count_completed"] == EXPECTED_SCENARIOS
    assert report["scenario_count"] == EXPECTED_SCENARIOS
    rows = report["rows"]
    assert isinstance(rows, list)
    assert len(rows) == EXPECTED_SCENARIOS
    scenario_ids = [row["scenario_id"] for row in rows]
    assert scenario_ids == sorted(scenario_ids)
    assert len(set(scenario_ids)) == EXPECTED_SCENARIOS
    candidate_ids = set()
    starter_loadout_ids = set()
    policy_ids = set()
    seeds = set()
    for row in rows:
        assert isinstance(row, dict)
        assert set(row) == EXPECTED_ROW_KEYS
        assert row["route_context_id"] == EXPECTED_ROUTE_CONTEXT
        assert row["outcome"] in {"win", "loss", "draw", "timeout"}
        assert isinstance(row["bundles_resolved"], int)
        assert row["bundles_resolved"] >= 0
        metrics = row["battle_metrics"]
        assert isinstance(metrics, dict)
        assert set(metrics) == EXPECTED_METRIC_KEYS
        for metric in metrics.values():
            assert isinstance(metric, int)
            assert metric >= 0
        candidate_ids.add(row["candidate_id"])
        starter_loadout_ids.add(row["starter_loadout_id"])
        policy_ids.add(row["player_policy_id"])
        seeds.add(row["ai_decision_seed"])
    assert len(candidate_ids) == 15
    assert len(starter_loadout_ids) == 15
    assert policy_ids == EXPECTED_POLICIES
    assert seeds == EXPECTED_SEEDS
    _assert_no_forbidden(report)


def main(argv: list[str]) -> int:
    if len(argv) not in (2, 3):
        raise SystemExit("usage: check_vertical_slice_balance_report.py REPORT_A [REPORT_B]")
    first_raw, first = _load(Path(argv[1]))
    if len(argv) == 3:
        second_raw, second = _load(Path(argv[2]))
        assert first_raw == second_raw, "reports are not byte-identical"
        _validate(second)
    _validate(first)
    print("VERTICAL_SLICE_BALANCE_REPORT_CHECK_OK")
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv))
