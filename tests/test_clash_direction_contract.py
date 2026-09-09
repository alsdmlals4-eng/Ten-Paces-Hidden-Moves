"""Planning linkage checks, not animation/runtime quality evidence."""
from pathlib import Path
ROOT = Path(__file__).resolve().parents[1]

def test_clash_direction_has_resolved_roles_and_evidence_boundary():
    text = (ROOT/'docs/decisions/2026-09-09_CLASH_STAGING_AND_OUTCOME_DIRECTION.md').read_text(encoding='utf-8')
    for marker in ('상단 합', '합 승자', '합 패자', '피해', '논리 위치',
                   '효과 없는', '역할 반전', 'NOT_RUN', '수동', '사거리 밖', '장풍', '검 대 검'):
        assert marker in text, marker

def test_current_owners_route_to_direction():
    marker = '2026-09-09_CLASH_STAGING_AND_OUTCOME_DIRECTION.md'
    for path in ('docs/18_VISUAL_ART_STYLE_COMPONENT_SYSTEM_SPEC.md',
                 'docs/04_ROADMAP.md', '[기획서]/00_프로젝트_허브/ACTIVE_CONTEXT.md'):
        assert marker in (ROOT/path).read_text(encoding='utf-8'), path
