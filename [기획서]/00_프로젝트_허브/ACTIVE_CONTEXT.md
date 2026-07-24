# 십보강호 활성 컨텍스트

## 현재 기준

- Work Mode: `REVIEW`.
- Base: `41a20584dd2ee51d917e5c9d7cab6838e1ceba7e`.
- 제품 구현 원본: PR #7 `agent/t0-combat-poc-board@659c57e7ffa588ad6a6471ed9b5394985b159eaf`.
- 코어 확정·계획: PR #15 `agent/project-core-confirmation`.
- A0 계약 정렬: PR #17 `agent/repeat-poc-a0-contract-alignment`.
- A1 라이벌 후보 AI: PR #19 `agent/repeat-poc-a1-rival-ai`.
- A2 가설·summary: PR #22 `agent/repeat-poc-a2-hypothesis-summary`.
- A3 복기 UI·review gate: PR #25 `agent/repeat-poc-a3-review-ui-closeout`.
- 최신 기능: PR #35 `agent/prepare-momentum-and-auto-placement`.
- 최신 기능 검증 코드 head: `6b1c88759bcd416bbe0ee2bcd8b98697d7fd6417`.
- 최신 전투 승인: Issue #13과 2026-07-24 사용자 승인.
- 현재 Goal: Issue #16.
- 프로젝트 코어: `CORE_CONFIRMED`.
- 제품 게이트: `REPEAT_POC`.
- T1 진입: `NOT_GRANTED`.
- 현재 Task: `PREPARE_AND_AUTO_PLACEMENT_REVIEW_READY`.
- 신규 플레이어 STEP 14: `DEFERRED_BY_USER / UNVERIFIED`.
- GitHub Actions: `AVAILABLE / FULL_VALIDATION_PASS`.

## 프로젝트 코어

> 상대의 공개 상태와 반복 습관을 읽고, 서로의 현재 계획을 모른 채 10칸 전장에 `3수 → 3수 → 4수`로 수를 걸어 거리·`[합]`·대응·중단으로 한 수를 파훼하고, 그 이유를 복기해 다음 계획을 바꾸는 1대1 무협 심리 전술 로그라이트.

```text
대전 격투식 수읽기·파훼
> 전술 퍼즐식 거리·순서
> 로그라이트 성장
```

보호 경계:

- 10칸, 플레이어 4번·상대 7번·거리 3.
- 비공개 `3수 → 3수 → 4수`.
- AI는 플레이어의 미확정 계획을 읽지 않는다.
- 덱·손패 없는 소수 공용 행동.
- 위치·순서·대응·파훼 우선.
- 결과 이유를 복기하고 다음 계획을 변경한다.

판정·AI 기본 원본은 `docs/02_COMBAT_RULES.md`, 구조 원본은 `docs/09_COMBAT_SYSTEM_ARCHITECTURE.md`다. 이번 사용자 승인 변경은 `docs/decisions/2026-07-24_PREPARE_AND_AUTO_PLACEMENT_RULE_CHANGE.md`가 관련 기존 서술을 명시적으로 대체한다.

## 현재 기술 구현

### T0 기반

- STEP 0~13.
- TARGETING 10.5, RESPONSE·RESOURCE PREVIEW 10.6.
- 기초 행동 8종·절초 3종.
- `[합]`·방어·회피·필중·중단·강건.
- 승패·무승부·완전 재시작.
- `timing_results`·`presentation_events`.
- 키보드·모션 감소·음향 제어 기술 증거.

### REPEAT_POC A0~A3

```text
A0 정본 SHA·AI source·board schema — PASS
→ A1 라이벌 복수 후보 정책 — PASS
→ A2 가설 snapshot·결정적 summary — PASS
→ A3 복기 UI·review gate·접근성 — PASS
```

- A1 활성 라이벌: `rival_t0_midrange_pressure`.
- A1 공개 상태·seed 결정론과 trace whitelist.
- A2 플레이어가 직접 고른 가설만 commit 직전 snapshot.
- A2 판정 결과를 재계산하지 않는 순수 summary.
- A3 복기 확인 전 다음 묶음 잠금.
- A3 terminal review 뒤 4번·7번 완전 재시작.

### `[준비]`·`[전조]`·자동 배치

- 내부 ID `basic_stance`를 유지하고 표시명을 `[준비]`로 변경.
- 다중 슬롯 행동의 실행 전 점유 수를 `[전조]`로 표시.
- 내부 `action_stage = preparation`은 유지.
- `[준비]` 뒤 이동·보법은 준비 상태를 소비하지 않음.
- 이동 실패·제자리 이동도 준비 상태를 소비하지 않음.
- `[준비]` 뒤 명상 실행 시 기존 회복과 절초 기세 +1, 최대 5.
- 다음 공격은 기존 +2와 `[강건]` 적용 뒤 준비 상태 소비.
- 다른 비이동 행동 시도는 준비 상태 소비.
- 모든 기초 카드와 절초는 가장 앞의 유효 연속 빈 구간에 자동 배치.
- 절초 자동 예약 성공 시 기세 5 즉시 소비.
- `[진행]` 전 예약 슬롯 클릭·Enter 취소 시 기세 5 반환.
- `committed` 이후 실행 실패·중단에는 환불하지 않음.

구현 책임:

- `src/ui/action_timing_panel_auto.gd`.
- `src/combat/combat_board_preview_auto.gd`.
- `src/combat/combat_resolution_engine_prepare.gd`.
- `tests/check_prepare_auto_placement_contract.py`.
- `tests/verify_prepare_momentum.gd`.
- `tests/verify_auto_card_placement.gd`.

## CI 구조와 최신 증거

PR은 `.github/workflows/documentation-governance.yml`의 단일 Ubuntu job이 변경 경로를 분류한다.

- 문서 전용: Python 3.12 문서 validator.
- 코드·데이터·씬·워크플로: Python 3.12 전체 정적 계약과 PowerShell 파싱 1회.
- `concurrency`와 `cancel-in-progress: true` 적용.

전체 검증은 `.github/workflows/full-validation.yml`이 소유한다.

- Ubuntu·Windows × Python 3.11·3.12.
- Godot 4.7 headless는 Ubuntu에서 1회.
- main·nightly·수동에서만 영구 실행한다.
- 검증 전용 PR의 trigger 변경은 제품 브랜치에 병합하지 않는다.

최신 증거:

- Red: PR #35 PR Validation run #659, 새 계약 step 예상 실패.
- 제품 정적 Green: PR #35 PR Validation run #681, `PASS`.
- 최종 검증 전용 PR #40 PR Validation run #682, `PASS`.
- Full Validation run #21, `PASS`.
- Ubuntu·Windows Python 3.11·3.12: 모두 `PASS`.
- Ubuntu Godot import와 기존 전투·절초·재시작·접근성·AI·A2·A3 회귀: 모두 `PASS`.
- 신규 `verify_prepare_momentum.gd`, `verify_auto_card_placement.gd`: 모두 `PASS`.

`concurrency` 취소 설정은 적용됐지만 실제 진행 중 run 취소 관찰은 아직 `NOT_OBSERVED`다.

## 다음 작업

1. PR #35의 변경 범위와 review thread를 최종 확인한다.
2. 검증용 PR #36~#40을 병합 없이 닫는다.
3. 사용자 요청이 있을 때 스택 병합 순서를 실행한다.
4. 신규 플레이어 STEP 14는 실행하지 않는다.
5. 사람 증거 없이 T1·MVP·재미 검증을 완료 처리하지 않는다.

## 증거 경계

```yaml
repeat_poc_planning: COMPLETE
a0_contract_alignment: IMPLEMENTED_FULL_ACTIONS_PASS
a1_rival_ai: IMPLEMENTED_FULL_ACTIONS_PASS
a2_hypothesis_and_summary: IMPLEMENTED_FULL_ACTIONS_PASS
a3_review_ui_and_gate: IMPLEMENTED_FULL_ACTIONS_PASS
prepare_card_rename: IMPLEMENTED_FULL_ACTIONS_PASS
multislot_omen_label: IMPLEMENTED_FULL_ACTIONS_PASS
prepare_movement_persistence: IMPLEMENTED_FULL_ACTIONS_PASS
prepare_meditation_momentum: IMPLEMENTED_FULL_ACTIONS_PASS
basic_card_auto_placement: IMPLEMENTED_FULL_ACTIONS_PASS
ultimate_auto_reservation: IMPLEMENTED_FULL_ACTIONS_PASS
ultimate_precommit_refund: IMPLEMENTED_FULL_ACTIONS_PASS
pr_scope_routing: PASS
concurrency_cancellation: CONFIGURED_NOT_CANCELLATION_OBSERVED
full_validation: PASS
godot_headless: PASS
windows_python_matrix: PASS
human_step14: DEFERRED_BY_USER
human_validation: UNVERIFIED
subjective_usability: UNVERIFIED
technical_implementation_complete: true
product_gate: REPEAT_POC
t1_greenlight: NOT_GRANTED
mvp_complete: false
```

기술 검증은 실제 플레이어 이해·성향 발견·재미·조작 선호를 대체하지 않는다.

## 중단 조건

- 기준 branch 또는 SHA가 예상과 다르다.
- AI 입력에 미확정 계획이 포함된다.
- 복기 UI가 판정을 재계산한다.
- 이동 행동이 `[준비]`를 소비한다.
- 절초 자동 배치 실패 전에 기세를 소비한다.
- `[진행]` 이후 절초 예약을 환불한다.
- Actions 미실행을 PASS로 기록한다.
- 사람 증거 없이 T1·MVP·재미 검증을 완료 처리한다.
