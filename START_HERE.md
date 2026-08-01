# 십보강호 시작 지점

## 기본 읽기

```text
최신 사용자 지시
→ AGENTS.md
→ docs/BASE_RULES_VERSION.md
→ [기획서]/00_프로젝트_허브/ACTIVE_CONTEXT.md
→ [기획서]/00_프로젝트_허브/DOCUMENTATION_MAP.md
→ 최신 관련 Decision
→ 질문별 책임 원본
→ 실제 코드·데이터·Scene·테스트·PR
```

백업·보류·과거 계획·닫힌 PR·전체 Skill 폴더를 기본 로드하지 않는다.

## 현재 기준

```yaml
repository: alsdmlals4-eng/Ten-Paces-Hidden-Moves
product_stage: VERTICAL_SLICE_APP_FLOW_PLANNING
work_mode: REVIEW
integration_pr: 65
implemented_feature: ACTION_SELECTION_DOCK
implemented_decision: TEN-DEC-20260801-MARTIAL-TECHNIQUE-UX-01
approved_planning_decision: TEN-DEC-20260801-SITUATION-SCREEN-01
next_package: VERTICAL_SLICE_APP_FLOW_SHELL
human_validation: NOT_RUN
base_adapter: skills/PROJECT_BASE_ADAPTER.json
base_release_pinned: 9.1.0
```

## 현재 책임 원본

- 현재 상태: `[기획서]/00_프로젝트_허브/ACTIVE_CONTEXT.md`.
- 문서 지도: `[기획서]/00_프로젝트_허브/DOCUMENTATION_MAP.md`.
- Base 버전: `docs/BASE_RULES_VERSION.md`.
- 전투 규칙: `docs/02_COMBAT_RULES.md`.
- 행동 선택: `docs/decisions/2026-08-01_MARTIAL_MANUAL_TECHNIQUE_TIMELINE_UX_DECISION.md`.
- 화면 구조: `docs/decisions/2026-08-01_SITUATION_SCREEN_ARCHITECTURE_DECISION.md`.
- 구현 종료: `docs/implementation/2026-08-01_ACTION_SELECTION_DOCK_CLOSEOUT.md`.
- 통합 감사: `docs/reviews/2026-08-01_BASE_PROJECT_SHEET_ADVERSARIAL_AUDIT.md`.

## 프로젝트 코어

- 1대1 10칸 일자형 전장.
- 거리 0 `[밀착]`.
- `3수 → 해결 → 3수 → 해결 → 4수 → 해결`.
- 공개 상태·해결 이력 기반 상대 추론.
- AI의 미확정 플레이어 계획 열람 금지.
- 덱·손패·드로우·장착 기술 제한 없음.
- 무공서가 아니라 현재 해금 기술을 수에 배치.

## 현재 작업

```text
ActionSelectionDock 자동 검증 완료
→ PR #65 정본·Sheet 동기화
→ VERTICAL_SLICE_APP_FLOW_SHELL
→ Main→Setup→Route→Node→Briefing→Combat→Result
→ 실제 화면·입력·STEP 14 사람 검증
```

## Work Mode

- `PLAN`: 설계·근거·순서·Decision.
- `BUILD`: 승인 패키지 구현.
- `REVIEW`: 적대적 검토·검증·최소 수정.

## 역사·호환

- PR #7과 Issue #13은 T0 `STEP 0~13` 구현 계보다.
- PR #45는 v6 계획 통합 이력이다.
- 과거 Base v8 SHA는 호환성 회귀 증거일 뿐 현재 Adapter 권한이 아니다.

자동·정적 검증은 Windows 실제 Godot, 실물 게임패드, 화면 읽기 도구, 성능, 사람 플레이를 증명하지 않는다. 실행하지 않은 항목은 `NOT_RUN`이다.
