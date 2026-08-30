"""Validate deterministic balance instrumentation output without reimplementing combat."""

from __future__ import annotations

import json
import sys
from pathlib import Path
from typing import Any


CONTRACT_ID = "TEN-DEC-20260830-BALANCE-INSTRUMENTATION-CONTRACT-01"
EXPECTED_SCENARIOS = 3375
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
    assert report["scenario_count_expected"] == EXPECTED_SCENARIOS
    assert report["scenario_count_completed"] == EXPECTED_SCENARIOS
    rows = report["rows"]
    assert isinstance(rows, list)
    assert len(rows) == EXPECTED_SCENARIOS
    scenario_ids = [row["scenario_id"] for row in rows]
    assert scenario_ids == sorted(scenario_ids)
    assert len(set(scenario_ids)) == EXPECTED_SCENARIOS
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
