from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
WORKFLOW = ROOT / ".github" / "workflows" / "validate-ten-manual-ui-ai-adoption.yml"


def test_action_dock_context_invalidation_is_fail_closed_in_ci() -> None:
    workflow = WORKFLOW.read_text(encoding="utf-8")
    assert "Verify action-dock context invalidation" in workflow
    assert "res://tests/verify_action_dock_context_invalidation.gd" in workflow
    assert "set +e" in workflow
    assert 'native_status=$?' in workflow
    assert 'exit "$native_status"' in workflow
    assert "grep -q 'ACTION_DOCK_CONTEXT_INVALIDATION_OK'" in workflow
