# 십보강호 시작 지점

## 기본 읽기

```text
최신 사용자 지시
→ AGENTS.md
→ [기획서]/00_프로젝트_허브/ACTIVE_CONTEXT.md
→ [기획서]/00_프로젝트_허브/DOCUMENTATION_MAP.md
→ 최신 날짜의 관련 Decision
→ 질문별 책임 원본
→ 실제 코드·데이터·Scene·테스트·PR
```

백업·보류·과거 계획·닫힌 PR·전체 Skill 폴더를 기본 컨텍스트로 로드하지 않는다.

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

## 현재 읽어야 할 정본

- 현재 상태: `[기획서]/00_프로젝트_허브/ACTIVE_CONTEXT.md`
- 문서 권한 지도: `[기획서]/00_프로젝트_허브/DOCUMENTATION_MAP.md`
- 전투 규칙: `docs/02_COMBAT_RULES.md`
- 회차·후보·경로: `docs/decisions/2026-07-31_COMBAT_ROUTE_AND_CHAMPION_DECISION.md`
- 절차형 비무: `docs/decisions/2026-07-31_PROCEDURAL_DUEL_POOL_AND_ROUTE_DECISION.md`
- 슬롯 3 거리 학습: `docs/decisions/2026-07-31_SLOT3_DISTANCE_DUEL_AND_ROUTE_DECISION.md`
- 행동 선택: `docs/decisions/2026-08-01_MARTIAL_MANUAL_TECHNIQUE_TIMELINE_UX_DECISION.md`
- 화면 구조: `docs/decisions/2026-08-01_SITUATION_SCREEN_ARCHITECTURE_DECISION.md`
- 구현 종료 증거: `docs/implementation/2026-08-01_ACTION_SELECTION_DOCK_CLOSEOUT.md`
- 통합 감사: `docs/reviews/2026-08-01_BASE_PROJECT_SHEET_ADVERSARIAL_AUDIT.md`

## 현재 코어

> 상대의 다음 행동 단서를 모아 가설을 세우고 여러 수의 계획으로 의도를 무너뜨리는 무협 전술 로그라이트.

- 1대1 10칸 일자형 전장.
- 거리 0 `[밀착]`.
- `3수 → 해결 → 3수 → 해결 → 4수 → 해결`.
- 공개 상태와 이력으로 상대를 추론한다.
- AI는 미확정 플레이어 계획을 읽지 않는다.
- 덱·손패·드로우·장착 기술 제한이 없다.
- 무공서가 아니라 현재 해금 기술을 수에 배치한다.

## 현재 작업

```text
ActionSelectionDock 자동 검증 완료
→ PR #65 정본·Sheet 동기화
→ VERTICAL_SLICE_APP_FLOW_SHELL
→ Main→Setup→Route→Node→Briefing→Combat→Result 연결
→ 실제 화면·입력·사람 검증
```

## 역사·호환

- PR #7과 Issue #13은 T0 `STEP 0~13` 구현 계보다.
- PR #45는 v6 계획 통합 이력이다.
- `PLAN / BUILD / REVIEW`는 현재도 유효한 Work Mode다.
- 과거 Base v8 SHA는 호환성 회귀 증거일 뿐 현재 Adapter 권한이 아니다.

## 상태 경계

자동·정적 검증은 Windows 실제 Godot, 실물 게임패드, 화면 읽기 도구, 해상도별 시각 품질, 성능, 사람 플레이를 증명하지 않는다. 실행하지 않은 항목은 `NOT_RUN`으로 기록한다.
