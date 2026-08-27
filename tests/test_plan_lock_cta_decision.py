from __future__ import annotations

import json
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]


def test_plan_execution_cta_decision_is_the_current_semantic_authority() -> None:
    decision = ROOT / "docs/decisions/2026-08-28_ACTION_PLAN_EXECUTION_CTA_DECISION.md"
    assert decision.is_file(), "the user-approved CTA decision must have a durable owner"
    text = decision.read_text(encoding="utf-8")
    assert "TEN-DEC-20260828-ACTION-PLAN-EXECUTION-CTA-01" in text
    assert "\ud589\ub3d9\uacc4\ud68d \uc2e4\ud589" in text
    assert "3\uc218" in text and "3\uc2ac\ub86f" in text
    assert "\uc804\uc870" in text and "\uc2e4\ud589" in text
    assert "\uc804\ud22c\u00b7\ud574\uacb0 \uc560\ub2c8\uba54\uc774\uc158" in text

    handoff = json.loads(
        (ROOT / "docs/planning-data/current_visual_production_handoff_20260826.json").read_text(
            encoding="utf-8"
        )
    )
    combat = handoff["combat_reference_contract"]
    assert combat["semantic_cta_authority"] == "TEN-DEC-20260828-ACTION-PLAN-EXECUTION-CTA-01"
    assert combat["visual_cta_label"] == "\ud589\ub3d9\uacc4\ud68d \uc2e4\ud589"
    assert combat["bundle_slot_counts"] == [3, 3, 4]
    assert combat["two_slot_action_phases"] == ["\uc804\uc870", "\uc2e4\ud589"]
    assert combat["execution_transition"] == "PLAN_EDITING_TO_COMBAT_RESOLUTION_ANIMATION"
    assert combat["runtime_poc_label_status"] == "CONFLICT_REQUIRES_SCOPED_CODEX_UI_COPY_AND_TRANSITION_HANDOFF"
