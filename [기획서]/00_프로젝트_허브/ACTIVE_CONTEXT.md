# 십보강호 활성 컨텍스트

## 현재 기준

```yaml
project: 십보강호
repository: alsdmlals4-eng/Ten-Paces-Hidden-Moves
platform: PC
product_stage: CONCEPT_APPROVAL
work_mode: PLAN
execution_profile: PLANNING_ONLY_PROFILE
runtime_implementation: PROHIBITED_UNTIL_NEW_APPROVAL
current_integration_pr: 45
canonical_decision_ledger: docs/decisions/2026-07-28_V6_DECISION_AUTHORITY_LEDGER.md
integration_review: docs/decisions/2026-07-28_V6_PR45_INTEGRATION_REVIEW.md
human_step14: NOT_RUN
```

PR #45의 과거 BUILD 승인 선언은 최신 사용자 결정으로 대체됐다. 이번 PR은 v6 계획 정본과 역사 자료를 정합화하는 문서 통합 PR이며 런타임 구현 인계가 아니다.

역사 추적: 현행 T0 구현 계보는 PR #7과 Issue #13이며 STEP 14 사람 검증은 아직 실행하지 않았다. 현행 구현은 플레이어 4번·상대 7번 시작과 공개 상태 기반 AI를 사용한다. 과거 상태 `CORE_REVIEW_PENDING`은 역사 토큰일 뿐 현재 제품 단계나 코어 권한이 아니다.

## 프로젝트 코어

> 상대의 다음 행동 단서를 모아 가설을 세우고 여러 수의 계획으로 의도를 무너뜨리는 무협 전술 로그라이트.

- 뾰족한 재미: 계획을 세워 상대의 숨은 수를 읽고 파훼한다.
- 판매 문구: `보이지 않는 상대의 수를 읽고, 준비한 계획으로 꺾는다.`
- 성장은 더 다양하고 강력한 파훼 방법을 제공한다.
- 원시 수치 상승은 판단을 대체하지 않는다.

## 현재 주요 계약

- 한 라운드: `3수 → 해결 → 3수 → 해결 → 4수 → 해결`.
- 버티컬 슬라이스 앵커: 핵심 결투 5개. 총 전투 수는 별도다.
- 전장: 10칸 일자형, 거리 0 `[밀착]`.
- 절초: 무공서 10성, 절초기세 5, 동일 슬롯 일반 기술보다 약 50% 높은 예산.
- `[연격 N]`: 총피해를 N회로 분할. 첫 피해만 합. 기본 회피는 한 피해만 회피.
- 방어·보호막: 통합 `[방어도]`, 피해 묶음마다 고정 감산, 피격으로 소모되지 않음.
- 수련 체크포인트: 전체 전투 5회 40~50, 10회 90~100의 표준 경로 중앙 목표.
- 전투 랭크: A +0, A+ +1, S +2, S+ +3.

최신 설계 권한은 v6 원장이 소유한다. `docs/02_COMBAT_RULES.md`는 현행 T0 구현 규칙과 영향 책임 원본이며, 충돌 시 v6 원장이 우선한다.

## `[보류]`

- Round 4 이후 전체 적대적 검토.
- 16권 절초의 개별 이름·효과·슬롯·태그·대응점.
- 2026-07-26 구현 계획 실행.
- Godot 런타임·데이터·씬·자산 변경.

`[보류]`는 결정 행에서는 `DEFERRED`, 게이트에서는 `HOLD`로 기록한다.

## PR #45 자산 지위

- 최신 권한 원장: `2026-07-28_V6_DECISION_AUTHORITY_LEDGER.md`.
- 2026-07-26 기획·BUILD 진입 문서: `SUPERSEDED_REFERENCE`.
- 과거 적대적 검토·벤치마크·sanity: `HISTORICAL_EVIDENCE`.
- `docs/planning-data/`: `SOURCE_ONLY / HOLD`.
- 2026-07-26 구현 계획: `DEFERRED / REFERENCE_ONLY`.
- 제품 런타임: 이번 통합에서 변경하지 않음.

## 다음 작업

사용자가 절초 설계를 재개하면 16권 절초를 하나씩 확정한다. 그 전에는 최신 원장과 PR #45 정합성만 유지하고 Codex Build로 전환하지 않는다.
