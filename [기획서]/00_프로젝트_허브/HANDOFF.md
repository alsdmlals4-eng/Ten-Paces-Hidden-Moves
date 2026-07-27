# 십보강호 세션 인수

## 현재 상태

```yaml
project: 십보강호
product_stage: CONCEPT_APPROVAL
work_mode: PLAN
execution_profile: PLANNING_ONLY_PROFILE
runtime_implementation: PROHIBITED_UNTIL_NEW_APPROVAL
planning_integration_pr: 45
canonical_decision_ledger: docs/decisions/2026-07-28_V6_DECISION_AUTHORITY_LEDGER.md
integration_review: docs/decisions/2026-07-28_V6_PR45_INTEGRATION_REVIEW.md
current_runtime: IMPLEMENTED_LEGACY
new_v6_runtime: NOT_STARTED
human_validation: UNVERIFIED
t1_greenlight: NOT_GRANTED
```

2026-07-26의 `BUILD_IN_PROGRESS / implementation_authorization: GRANTED` 상태는 최신 v6 재설계 지시로 대체됐다. PR #45는 최신 계획 권한과 역사·검증 자료를 통합하지만 Codex 런타임 구현 인계를 허가하지 않는다.

## 반드시 읽을 파일

1. `AGENTS.md`.
2. `[기획서]/00_프로젝트_허브/ACTIVE_CONTEXT.md`.
3. `docs/decisions/2026-07-28_V6_DECISION_AUTHORITY_LEDGER.md`와 Part 1A·1B·2·3.
4. `docs/decisions/2026-07-28_V6_PR45_INTEGRATION_REVIEW.md`.
5. `[기획서]/00_프로젝트_허브/DOCUMENTATION_MAP.md`.
6. 질문별 책임 원본과 실제 코드·데이터·테스트.

## 현재 핵심 결정

- 뾰족한 재미: 계획을 세워 상대의 숨은 수를 읽고 파훼한다.
- 라운드: `3수 → 해결 → 3수 → 해결 → 4수 → 해결`.
- 버티컬 슬라이스 앵커: 핵심 결투 5개.
- `[연격 N]`: 총피해를 N회로 분할. 첫 피해만 합.
- 방어·보호막: 통합 `[방어도]`, 피해 묶음별 감산, 피격으로 소모되지 않음.
- 무공서: 16권, 1~10성, 시작 4권 3성.
- 수련 중앙 목표: 전체 전투 5회 40~50, 10회 90~100.
- 전투 랭크: A/A+/S/S+ 보너스 0/1/2/3.
- 절초: 기세 5, 동일 슬롯 일반 기술보다 약 50% 높은 예산.

## `[보류]`

- Round 4 이후 전체 적대적 검토.
- 16개 개별 절초 설계.
- 2026-07-26 구현 계획과 구현 branch 실행.
- Godot 런타임·데이터·씬·자산 변경.

## PR #45 통합 분류

| 자산 | 현재 지위 |
|---|---|
| v6 결정 원장·통합 검수 | `CURRENT_DECISION_AUTHORITY` |
| 2026-07-26 기획 기준선·BUILD 진입 | `SUPERSEDED_REFERENCE` |
| 과거 적대적 검토·벤치마크·sanity | `HISTORICAL_EVIDENCE` |
| `docs/planning-data/*.json` | `SOURCE_ONLY / HOLD` |
| 2026-07-26 구현 계획 | `DEFERRED / REFERENCE_ONLY` |
| planning validator·테스트·workflow | `VALIDATION_ASSET` |
| 제품 런타임 경로 | 이번 통합에서 변경하지 않음 |

## 다음 작업

사용자가 절초 설계를 재개하기 전에는 다음만 수행한다.

1. v6 원장과 활성 진입점의 최신성 유지.
2. PR #45 Required Check와 changed files 검증.
3. 제품 경로 무변경 확인.
4. 미검증·보류 상태 보존.

새 BUILD는 사용자의 명시적 승인과 최신 구현 계획이 생긴 뒤 별도 브랜치·worktree에서 시작한다.

## 금지

- 2026-07-26 구현 계획을 현재 승인으로 해석.
- planning JSON을 런타임 권한 원본으로 사용.
- 주요 비무 10개·3→10 비용 38·구형 순차 연격·S/A/B/C 랭크를 최신 계약으로 복원.
- 16개 절초를 사용자 승인 없이 확정.
- 사람 증거 없이 재미·밸런스·T1 통과 주장.
- 문서 검증을 런타임 구현 완료로 보고.
