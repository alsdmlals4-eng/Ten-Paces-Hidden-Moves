# 십보강호 프로젝트 허브

## 기본 경로

```text
../../../AGENTS.md
→ ACTIVE_CONTEXT.md
→ ../../../docs/decisions/2026-07-28_V6_DECISION_AUTHORITY_LEDGER.md
→ DOCUMENTATION_MAP.md
→ 질문별 책임 원본
→ 실제 파일·테스트·PR·Issue
```

- Base 적용 기준: `../../../docs/BASE_RULES_VERSION.md`.
- Base 동기화 감사: `BASE_MAIN_SYNC_AUDIT.md`.
- Skill Registry: `SKILL_REGISTRY.json`.
- 현재 요청에 필요할 때만 Gates·Roadmap·Audit·Handoff를 추가로 읽는다.

## 현재 상태

```yaml
product_stage: CONCEPT_APPROVAL
work_mode: PLAN
execution_profile: PLANNING_ONLY_PROFILE
runtime_implementation: PROHIBITED_UNTIL_NEW_APPROVAL
planning_integration_pr: 45
canonical_decision_ledger: ../../../docs/decisions/2026-07-28_V6_DECISION_AUTHORITY_LEDGER.md
human_validation: UNVERIFIED
t1_greenlight: NOT_GRANTED
```

현행 T0 구현 계보는 PR #7 `agent/t0-combat-poc-board@659c57e7ffa588ad6a6471ed9b5394985b159eaf`와 Issue #13이다. 당시 코어 상태 `CORE_CONFIRMED`와 제품 게이트 `REPEAT_POC`는 구현·역사 추적 토큰이며, 최신 제품 단계와 설계 권한은 v6 원장이 소유한다.

2026-07-26 BUILD 승인·구현 인계 문서는 `SUPERSEDED_REFERENCE`다. PR #45는 계획 정본과 역사 자료를 통합하며 제품 런타임을 변경하지 않는다.

## Work Mode

- `PLAN`: 요구·정본·설계·문서·검수.
- `BUILD`: 사용자가 새로 승인한 범위의 구현.
- `REVIEW`: 적대적 검토·반례·증거·판정.

현재는 `PLAN`이다.

## `[보류]`

- Round 4 이후 전체 적대적 검토.
- 16권 절초의 개별 설계.
- 2026-07-26 구현 계획 실행.
- Godot 런타임·데이터·씬·자산 변경.

## 허브 책임

- `ACTIVE_CONTEXT.md`: 현재 상태·보류·다음 작업.
- `DOCUMENTATION_MAP.md`: 질문별 현재 권한 원본과 역사 자료.
- `DEVELOPMENT_GATES.md`: 현재 단계 진입·차단 조건.
- `ROADMAP.md`: 계획 순서와 재개 조건.
- `HANDOFF.md`: 세션 인수 경계.
- `SKILL_REGISTRY.json`: Base·로컬 Skill 라우팅.

정적 검사와 문서 정합성은 Godot 런타임·Windows·접근성·성능·사람 플레이를 증명하지 않는다.
