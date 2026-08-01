# 십보강호 프로젝트 허브

## 기본 경로

```text
../../../AGENTS.md
→ ../../../docs/BASE_RULES_VERSION.md
→ ACTIVE_CONTEXT.md
→ DOCUMENTATION_MAP.md
→ SKILL_REGISTRY.json
→ 최신 관련 Decision
→ 질문별 책임 원본
→ 실제 파일·테스트·PR·Issue
```

- Base 동기화 감사: `BASE_MAIN_SYNC_AUDIT.md`.
- 과거 v6 결정 인덱스: `../../../docs/decisions/2026-07-28_V6_DECISION_AUTHORITY_LEDGER.md`.
- 현재 요청에 필요할 때만 Gates·Roadmap·Audit·Handoff를 추가로 읽는다.

## 현재 상태

```yaml
product_stage: VERTICAL_SLICE_APP_FLOW_PLANNING
work_mode: REVIEW
integration_pr: 65
runtime_implementation: ACTION_SELECTION_DOCK_IMPLEMENTED_PR65
implemented_decision: TEN-DEC-20260801-MARTIAL-TECHNIQUE-UX-01
approved_planning_decision: TEN-DEC-20260801-SITUATION-SCREEN-01
automated_validation: PASS
human_validation: NOT_RUN
next_package: VERTICAL_SLICE_APP_FLOW_SHELL
t1_greenlight: NOT_GRANTED
```

- PR #66의 ActionSelectionDock 구현은 PR #65 통합 브랜치에 병합됐다.
- 전체 제품 화면 흐름은 승인된 PLAN이며 런타임은 다음 패키지에서 시작한다.
- Base v9.3 채택은 PR #65 main 안정화 뒤 별도 migration으로 수행한다.

## Work Mode

- `PLAN`: 요구·정본·설계·문서·순서.
- `BUILD`: 승인된 구현 패키지.
- `REVIEW`: 적대적 검토·반례·증거·최소 수정.

현재는 `REVIEW`다.

## 현재 다음 작업

```text
PR #65 동일 HEAD 필수 검사
→ main 병합
→ GitHub·Google Sheets post-merge 동기화
→ VERTICAL_SLICE_APP_FLOW_SHELL
→ Windows 실제 실행·해상도·입력·STEP 14 사람 검증
```

## 허브 책임

- `ACTIVE_CONTEXT.md`: 현재 상태·다음 작업·위험.
- `DOCUMENTATION_MAP.md`: 질문별 현재 권한 원본과 역사 자료.
- `DEVELOPMENT_GATES.md`: 현재 단계 진입·차단 조건.
- `ROADMAP.md`: 운영 순서와 재개 조건.
- `HANDOFF.md`: 세션 인수 경계.
- `SKILL_REGISTRY.json`: Base·로컬 Skill 라우팅.

## 역사·보류

- PR #7·Issue #13: T0 `STEP 0~13` 구현 계보.
- PR #45·`2026-07-28_V6_DECISION_AUTHORITY_LEDGER.md`: 재설계·승인 이력.
- 2026-07-26 BUILD 문서: `SUPERSEDED_REFERENCE`.
- 16권 절초 개별 설계, 주요 비무 6~10, 천하제일인·비동기 기능, 최종 폴리싱: `[보류]`.

자동 검증은 Windows 실제 Godot·접근성·성능·사람 플레이를 증명하지 않는다.
