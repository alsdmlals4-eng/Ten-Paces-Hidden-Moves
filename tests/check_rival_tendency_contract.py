from __future__ import annotations

import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
DATA_PATH = ROOT / "data/combat/combat_rival_tendency_poc.json"
PLANNER_PATH = ROOT / "src/combat/combat_ai_planner.gd"

EXPECTED_RIVAL_ID = "rival_t0_midrange_pressure"
EXPECTED_CLUE_IDS = [
    "midrange_pressure",
    "safe_heavy_prepare",
    "low_health_response",
]
TRACE_TOKENS = (
    "func get_last_trace() -> Dictionary",
    '"public_snapshot"',
    '"rival_id"',
    '"candidate_ids"',
    '"candidate_scores"',
    '"selected_card_id"',
    '"seed"',
    '"reason_codes"',
)


def load_json(path: Path) -> dict:
    assert path.is_file(), f"missing rival tendency data: {path.relative_to(ROOT)}"
    return json.loads(path.read_text(encoding="utf-8"))


def main() -> None:
    data = load_json(DATA_PATH)
    assert data["schema_version"] == 1
    assert data["active_rival_id"] == EXPECTED_RIVAL_ID
    assert data["max_candidates"] == 3
    assert float(data["score_window"]) == 2.0

    profiles = data["profiles"]
    assert len(profiles) == 1
    profile = profiles[0]
    assert profile["id"] == EXPECTED_RIVAL_ID
    assert [clue["id"] for clue in profile["public_clues"]] == EXPECTED_CLUE_IDS
    assert all(clue["text"].strip() for clue in profile["public_clues"])

    required_weights = {
        "approach",
        "quick_pressure",
        "heavy_prepare",
        "response_low_health",
        "recover_low_resource",
        "ultimate_ready",
    }
    assert set(profile["weights"]) == required_weights

    planner = PLANNER_PATH.read_text(encoding="utf-8")
    missing = [token for token in TRACE_TOKENS if token not in planner]
    assert not missing, f"planner trace contract missing: {missing}"

    print("rival tendency static contract: PASS")


if __name__ == "__main__":
    main()
