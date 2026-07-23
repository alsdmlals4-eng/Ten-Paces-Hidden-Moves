# REPEAT_POC 작업 분해와 PR 게이트

> Codex entrypoint: `plans/CODEX_GOAL_REPEAT_POC.md`

| PR | 결과 | 선행 | 변경 중심 | 병합 게이트 |
|---|---|---|---|---|
| PR-A0 | 정본·schema 17·AI source 정렬 | PR #15 head | 문서·board data·Governance | old SHA·schema 16·fixed plan 활성 참조 0 |
| PR-A1 | 읽을 수 있는 라이벌 복수 후보 | PR-A0 | rival data·AI planner·verifier | seed 재현·private input 0·후보 분포 |
| PR-A2 | 가설 기록·결정적 summary | PR-A1 | hypothesis UI·summary builder·fixture | 미기록 가설 추정 0·cause fixture PASS |
| PR-A3 | 복기 UI·접근성 흐름 | PR-A2 | review panel·BoardPreview·focus | 판정 재계산 0·960×640·키보드 PASS |
| PR-A4 | 고정 빌드·STEP 14 | PR-A3 | 프로토콜·결과·상태 문서 | 동일 SHA·5명·사전 고정 신호 |

## 병렬화 금지

- PR-A1과 PR-A2는 모두 `CombatBoardPreview` 또는 판정 결과 계약에 영향을 줄 수 있어 실제 구현은 순차 실행한다.
- PR-A2 summary builder의 순수 fixture 작성만 PR-A1 코드와 병렬 검토할 수 있다.
- PR-A4는 A0~A3가 통합되고 전체 검증이 끝난 뒤에만 실행한다.

## 각 PR 공통 보고

```yaml
baseline_sha:
head_sha:
work_mode:
selected_skill:
red_evidence:
green_changes:
refactor:
static:
godot_runtime:
windows:
human_playtest:
protected_path_diff:
remaining_risks:
result: PASS | PARTIAL | FAIL | BLOCKED
```

## 완료 선언 금지

다음 중 하나라도 남으면 해당 PR을 ready 또는 전체 Goal 완료로 표시하지 않는다.

- Red 반례가 Green 뒤에도 재현됨.
- 관련 기존 Godot verifier 실패.
- private plan AI 유입.
- 복기 UI 판정 재계산.
- active stale reference.
- 테스트 side effect.
- 고정 build SHA 불일치.
- 사람 결과를 기계 결과로 대체.
