from __future__ import annotations

import json
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]


def test_warm_dusk_v2_is_locked_as_a_non_runtime_planning_anchor() -> None:
    decision = ROOT / "docs/decisions/2026-08-28_WARM_DUSK_V2_PLANNING_ANCHOR_DECISION.md"
    assert decision.is_file(), "the user-approved planning anchor needs a durable Decision owner"
    text = decision.read_text(encoding="utf-8")
    assert "TEN-DEC-20260828-WARM-DUSK-V2-PLANNING-ANCHOR-01" in text
    assert "PROJECT_CORE_SCENE_VISUAL_BOARD" in text
    assert "not a runtime asset" in text

    handoff = json.loads(
        (ROOT / "docs/planning-data/current_visual_production_handoff_20260826.json").read_text(
            encoding="utf-8"
        )
    )
    style = handoff["style_lock"]
    assert style["candidate_status"] == "USER_APPROVED_PLANNING_ANCHOR_ONLY_NON_RUNTIME"
    assert style["planning_anchor_decision"] == "TEN-DEC-20260828-WARM-DUSK-V2-PLANNING-ANCHOR-01"
    packet = style["visual_direction_lock_packet"]
    assert packet["selected_candidate"] == "WARM_DUSK_TEN_STEP_COMBAT_ANCHOR_01_v2_NO_FLOOR_GRID"
    assert packet["approved_use"] == "PLANNING_VISUALIZATION_ANCHOR_ONLY"
    assert packet["runtime_asset_status"] == "NOT_APPROVED"
    assert handoff["next_result"]["id"] == "PROJECT_CORE_SCENE_VISUAL_BOARD"
    assert handoff["next_result"]["generation_status"] == "TEXT_BRIEF_AND_EXPLICIT_USER_APPROVAL_REQUIRED"
