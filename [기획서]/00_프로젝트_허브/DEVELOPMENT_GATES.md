# 십보강호 개발 게이트

> 현재 결정 권한: `docs/decisions/2026-07-28_V6_DECISION_AUTHORITY_LEDGER.md`.

## 1. 상태 축

```yaml
product_stage: CONCEPT_APPROVAL | PROTOTYPE_AND_VERTICAL_SLICE | PRODUCTION_APPROVAL | RELEASE_CANDIDATE_APPROVAL
work_mode: PLAN | BUILD | REVIEW
gate: APPROVED | APPROVED_WITH_CONDITIONS | REWORK | REPEAT_VALIDATION | HOLD | STOP | UNVERIFIED
implementation: IMPLEMENTED | PARTIALLY_IMPLEMENTED | PLANNED | PROPOSED_ONLY | DEFERRED | REMOVED | UNVERIFIED
```

파일 존재·Actions·Godot·Windows·사람 플레이·접근성·성능·Required Check는 독립 증거다.

## 2. 현재 게이트

```yaml
product_stage: CONCEPT_APPROVAL
work_mode: PLAN
execution_profile: PLANNING_ONLY_PROFILE
runtime_implementation: PROHIBITED_UNTIL_NEW_APPROVAL
planning_integration: PR_45
gate_decision: APPROVED_WITH_CONDITIONS
human_validation: UNVERIFIED
t1_greenlight: NOT_GRANTED
```

조건:

- v6 결정 원장과 PR #45 역사 자료의 중복 제거.
- 최신 PR Validation PASS.
- 제품 런타임 경로 무변경 확인.
- `[보류]` 항목을 구현 입력에서 제외.

## 3. G0 — 권한·기준선

- [x] 최신 사용자 지시와 v6 계약 확인.
- [x] 저장소·PR #45·main 기준 확인.
- [x] 현행 T0 구현 계보 PR #7·Issue #13 확인.
- [x] 기술 기준 SHA `659c57e7ffa588ad6a6471ed9b5394985b159eaf`를 역사·구현 추적으로 보존.
- [x] 최신 설계 권한과 현행 구현 사실 분리.

판정: `APPROVED`.

## 4. G1 — v6 계획 권한

- [x] 프로젝트 코어·강호행·전투·무공서·성장·메타 계약 추출.
- [x] 폐기·대체·보류·미검증 분리.
- [x] 결정별 연결 프로필 적용.
- [x] PR #45의 BUILD 승인과 구형 규칙을 `SUPERSEDED_REFERENCE`로 분류.

판정: `APPROVED`.

## 5. G2 — GitHub 계획 통합

- [x] 최신 결정 원장과 통합 검수 문서 생성.
- [x] Active Context·Documentation Map·Handoff·진입점 정렬.
- [x] PR #45 메타데이터 교정.
- [x] 제품 `data/`, `src/`, `scenes/`, `assets/`, `addons/`, `project.godot` 변경 금지.
- [ ] 최신 HEAD의 운영·최신성·거버넌스·planning 검증 PASS.
- [ ] unresolved review thread 0건 확인.
- [ ] 병합 뒤 main 재검증.

판정: `REWORK` — 최신 CI가 통과할 때까지 병합 금지.

## 6. G3 — `[보류]`

- Round 4 이후 전체 적대적 검토.
- 16개 개별 절초 설계.
- 2026-07-26 구현 계획 실행.
- Godot 런타임·데이터·씬·자산 변경.

판정: `HOLD`.

## 7. G4 — 향후 BUILD 진입

다음 조건 전에는 BUILD로 전환하지 않는다.

1. 사용자가 보류 항목을 재개한다.
2. 개별 절초와 통합 명세가 승인된다.
3. 보류된 적대적 검토에서 `MUST_FIX`가 0이다.
4. 최신 구현 계획과 기준 SHA·보호 경로·롤백이 작성된다.
5. 사용자가 명시적으로 구현을 승인한다.

현재 판정: `NOT_GRANTED / PLANNING_ONLY`.

## 8. 검증 순서

```text
contract-check
→ reference-freshness
→ syntax·static
→ automated tests
→ 적용 시 runtime·render·build
→ accessibility·performance
→ normal·failure·edge·counterexample·regression
→ baseline diff
→ evidence-report
```

실행하지 않은 검증은 `NOT_RUN / UNVERIFIED`다.

## 9. 완료 금지 조건

- 최신 PR Validation 실패 또는 미완료.
- 제품 경로 변경 발생.
- 현재 권한과 과거 BUILD 승인 혼재.
- 보류된 절초·검토를 완료로 표시.
- 런타임·사람 증거 없이 구현·재미·T1 통과 주장.

현행 T0의 과거 판정 `CORE_CONFIRMED / PRODUCT_GATE_REPEAT_POC`는 역사·구현 계보이며 현재 v6 제품 단계 권한이 아니다.
