# 십보강호 협업 규칙

이 파일은 `Ten-Paces-Hidden-Moves`의 최상위 프로젝트 작업 계약이다.

## 1. 우선순위

1. 사용자의 최신 확정 지시.
2. 보안·플랫폼 제약과 이 `AGENTS.md`.
3. `VERTICAL_SLICE_MASTER_REFERENCE_v6.md`와 축약 실행문.
4. `[기획서]/00_프로젝트_허브/ACTIVE_CONTEXT.md`.
5. `docs/decisions/2026-07-28_V6_DECISION_AUTHORITY_LEDGER.md`.
6. 질문별 책임 원본과 실제 코드·데이터·테스트 증거.
7. 과거 문서·PR·Issue·외부 사례.

정상 동작 중인 사용자·Codex 변경을 임의로 되돌리지 않는다.

## 2. 기본 읽기

```text
최신 사용자 지시
→ AGENTS.md
→ [기획서]/00_프로젝트_허브/ACTIVE_CONTEXT.md
→ docs/decisions/2026-07-28_V6_DECISION_AUTHORITY_LEDGER.md
→ [기획서]/00_프로젝트_허브/DOCUMENTATION_MAP.md
→ 질문별 책임 원본
→ 실제 파일·테스트·PR·Issue
```

백업·보류·과거 계획·닫힌 PR·전체 Skill 폴더를 기본 컨텍스트로 로드하지 않는다.

## 3. 현재 기준

```yaml
project: 십보강호
product_stage: CONCEPT_APPROVAL
work_mode: PLAN
execution_profile: PLANNING_ONLY_PROFILE
runtime_implementation: PROHIBITED_UNTIL_NEW_APPROVAL
planning_integration_pr: 45
canonical_decision_ledger: docs/decisions/2026-07-28_V6_DECISION_AUTHORITY_LEDGER.md
integration_review: docs/decisions/2026-07-28_V6_PR45_INTEGRATION_REVIEW.md
human_validation: UNVERIFIED
```

- 현행 T0 구현 계보는 PR #7과 Issue #13이다. 최신 v6 설계 권한과 분리한다.
- 2026-07-26의 BUILD 승인·구현 인계·구형 PoC 기준선은 `SUPERSEDED_REFERENCE`다.
- PR #45는 v6 계획 정본과 역사·검증 자료를 정합화하며 제품 런타임을 변경하지 않는다.

## 4. Work Mode·Skill Mode

- `PLAN`: 요구·정본·근거·설계·문서·검수. 승인 전 제품 변경 금지.
- `BUILD`: 사용자가 명시적으로 승인한 범위의 구현.
- `REVIEW`: 적대적 검토·반례·검증·판정.
- Skill Mode는 Registry trigger와 작업 위험에 따라 최소 범위로 선택한다.
- L1 이상 작업은 기준 SHA, 선택 Skill, 실제 수행, 결과, 증거, 미검증을 `execution-report`에 기록한다.
- 정본·경로·ID·Schema·Base SHA 변경은 `reference-freshness`로 검사한다.

한 시점의 주 Work Mode는 하나다. 현재는 `PLAN`이다.

## 5. 현재 제품 코어

> 상대의 다음 행동 단서를 모아 가설을 세우고 여러 수의 계획으로 의도를 무너뜨리는 무협 전술 로그라이트.

- 뾰족한 재미: 계획을 세워 상대의 숨은 수를 읽고 파훼한다.
- 한 라운드: `3수 → 해결 → 3수 → 해결 → 4수 → 해결`.
- 10칸 일자형 전장과 거리 0 `[밀착]`.
- AI는 플레이어의 미확정 계획을 읽지 않는다.
- 덱·손패·드로우·장착 기술 제한을 사용하지 않는다.
- 버티컬 슬라이스는 핵심 결투 5개를 앵커로 한다.
- `[연격 N]`은 한 공격의 총피해를 N개 피해 묶음으로 나눈다.
- 방어와 보호막은 통합 `[방어도]`다.
- 무공서 16권, 1~10성, 10성 절초.

세부 설계 권한은 v6 결정 원장이 소유한다. 실제 코드·데이터는 구현 사실을 증명하지만 최신 설계 권한을 자동으로 대체하지 않는다.

## 6. `[보류]`

- Round 4 이후 전체 적대적 검토.
- 16권 절초의 개별 설계.
- 2026-07-26 구현 계획 실행.
- Godot 런타임·데이터·씬·자산 변경.

`[보류]`는 결정 행에서 `DEFERRED`, 게이트에서 `HOLD`이며 런타임 구현 입력에서 제외한다.

## 7. 책임 원본·중복 방지

- 한 질문에 활성 권한 원본 하나만 둔다.
- 결정 원장은 사용자 승인·대체·폐기·보류를 소유한다.
- `ACTIVE_CONTEXT.md`는 현재 상태와 다음 행동만 요약한다.
- `DOCUMENTATION_MAP.md`는 질문별 책임 원본을 연결한다.
- 과거 문서·PR은 삭제하지 않고 `SUPERSEDED_REFERENCE / HISTORICAL_EVIDENCE`로 보존한다.
- `docs/planning-data/*.json`은 `SOURCE_ONLY / HOLD`이며 런타임 권한 원본이 아니다.
- 2026-07-26 구현 계획은 `DEFERRED / REFERENCE_ONLY`다.

## 8. 변경 보호

현재 `PLAN`에서 다음 제품 경로는 수정하지 않는다.

```text
data/
src/
scenes/
assets/
addons/
project.godot
```

문서·검증 자산을 수정한 뒤에는 changed files를 확인한다. 제품 경로 변경이 발견되면 즉시 중단하고 원인·복구를 보고한다.

## 9. 검증 원칙

```text
contract-check
→ reference-freshness
→ syntax·static
→ automated tests
→ 적용 시 runtime·render·build
→ normal·failure·edge·counterexample·regression
→ baseline diff
→ evidence-report
```

- 실제로 실행하지 않은 검증은 PASS로 기록하지 않는다.
- 파일 존재, 정적 테스트, Actions 성공, Godot 실행, Windows 확인, 접근성, 성능, 사람 플레이는 서로 다른 증거다.
- 문서 정합성 통과는 런타임 구현이나 게임 재미를 증명하지 않는다.
- `MUST_FIX` 또는 필수 `UNVERIFIED`가 남으면 완료를 과장하지 않는다.

## 10. L1 이상 작업 계약

```yaml
work_level: L1 | L2 | L3 | L4
work_mode: PLAN | BUILD | REVIEW
goal:
scope:
out_of_scope:
baseline_branch:
baseline_sha:
protected_paths_decisions_assets:
required_sources_tools_permissions:
selected_skills_and_modes:
execution_steps:
acceptance_criteria:
validation:
stop_conditions:
rollback:
```

사용자는 Skill 이름을 선언할 필요가 없다. 실제로 사용하지 않은 Skill이나 검증을 실행 보고에 적지 않는다.

## 11. 작업 종료

1. 최신 사용자 결정과 책임 원본을 맞춘다.
2. 활성 소비자에서 구형 권한 참조를 제거한다.
3. 제품 경로가 변경되지 않았는지 확인한다.
4. 정적·자동 검증과 PR 상태를 새 HEAD에서 다시 확인한다.
5. 미검증·보류·롤백 경계를 명시한다.
6. 병합은 사용자의 명시적 승인과 최신 검증 증거가 있을 때만 수행한다.
