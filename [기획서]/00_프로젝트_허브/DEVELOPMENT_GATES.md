# 십보강호 개발 게이트

> 현재 상태: `ACTIVE_CONTEXT.md`  
> 현재 상세 로드맵: `../../../docs/04_ROADMAP.md`  
> 과거 v6 결정 인덱스: `../../../docs/decisions/2026-07-28_V6_DECISION_AUTHORITY_LEDGER.md`

## 1. 상태 축

```yaml
product_stage: VERTICAL_SLICE_APP_FLOW_PLANNING | PROTOTYPE_AND_VERTICAL_SLICE | PRODUCTION_APPROVAL | RELEASE_CANDIDATE_APPROVAL
work_mode: PLAN | BUILD | REVIEW
gate: APPROVED | APPROVED_WITH_CONDITIONS | REWORK | REPEAT_VALIDATION | HOLD | STOP | UNVERIFIED
implementation: IMPLEMENTED | PARTIALLY_IMPLEMENTED | PLANNED | PROPOSED_ONLY | DEFERRED | REMOVED | UNVERIFIED
```

파일 존재·Actions·Godot headless·Windows 실제 실행·접근성·성능·사람 플레이는 독립 증거다.

## 2. 현재 게이트

활성 PR·exact head·승인 수·다음 Decision은 `ACTIVE_CONTEXT.md`가 단독 책임진다. 이 문서는 Gate 조건만 책임지고 변동 상태를 복제하지 않는다.

안정 경계:

```yaml
product_stage: VERTICAL_SLICE_APP_FLOW_PLANNING
runtime_work_mode: REVIEW
runtime_integration_pr: 65
planning_work_mode: PLAN
runtime_implementation: TEN_MANUAL_PRODUCT_VALIDATION_AUTOMATED_PR92
next_package: VERTICAL_SLICE_APP_FLOW_SHELL
human_validation: NOT_RUN
t1_greenlight: NOT_GRANTED
base_release_pinned: 9.4.3
```

## 3. G0 — 권한·기준선

- [x] 최신 사용자 지시와 프로젝트 코어 확인.
- [x] 병합 main, 최근 체크포인트, ACTIVE_CONTEXT의 활성 Draft, Sheet 확인.
- [x] PR #7·Issue #13 T0 구현 계보 보존.
- [x] v6 원장을 역사 인덱스로 유지하고 최신 날짜별 Decision을 우선.
- [x] Base v9.4.3 Adapter payload·evidence·finalization pin 확인.
- [x] main 상태와 활성 Draft PR 상태를 별도 축으로 기록.

판정: `APPROVED`.

## 4. G1 — ActionSelectionDock 런타임 기준선

- [x] `[기초] [무공] [절초]` 출처와 무공서→해금 기술 계약.
- [x] 전체 10수·3/3/4 현재 묶음 편집.
- [x] 자동 배치와 `[전조] → [실행]` 연결 블록.
- [x] 진행 전 이동·제거와 절초기세 예약·환불.
- [x] 포인터 Drop 누락 RED 재현·수정.
- [x] 구현 HEAD 자동 검증 통과.
- [ ] Windows 실제 Godot·실물 입력·사람 이해도 검증.

판정: `APPROVED_WITH_CONDITIONS / HUMAN_PENDING`.

## 5. G2 — 현재 기획 배치·정본·Sheet

- [x] 병합 main 상태와 활성 Draft 상태를 분리한다.
- [x] 승인 Decision을 같은 ID로 Branch·Decision·planning JSON·Sheet에 연결한다.
- [x] 모든 작업에 전용 RED→GREEN 회귀와 exact-head Actions를 요구한다.
- [x] 활성 PR·승인 수·다음 Decision은 `ACTIVE_CONTEXT.md`에서 단일 조회한다.
- [ ] 최대 10건 또는 허용된 조기 체크포인트에서 전체 적대적 검토.
- [ ] 병합 후 새 main SHA와 Sheet `SYNCED_TO_MAIN` 재기록.

판정은 `ACTIVE_CONTEXT.md`와 latest exact-head Actions 결과에서 계산한다.

## 6. G3 — 기획 완료

필수 조건:

1. 제품 의미·수치 충돌은 GrillMe 승인.
2. 상세·가역 수치는 승인된 GPT 권장 기본값과 근거 기록.
3. 핵심 재미를 수치 성장·관찰 정답화·등급 파밍이 대체하지 않음.
4. Decision·분야 정본·planning JSON·Sheet ID 일치.
5. 10/10 또는 조기 체크포인트 exact-head CI·threads 0·P0/P1 0.

현재 판정: `NOT_COMPLETE`.

## 7. G4 — 전체 검토 완료

- Base·프로젝트·Sheet 권위 재대조.
- 변경 파일·활성 소비자·untouched 문서·테스트·파생본 공격 검토.
- 핵심 시스템·보조 시스템·핵심 재미·목표 정렬 검증.
- 구현과 최신 기획 차이 목록 확정.
- 모든 P0/P1 해결 또는 명시적 사용자 승인.

현재 판정: `BLOCKED_BY_G3`.

## 8. G5 — 이미지·애니메이션·HX

- 기획 완료와 검토 완료 뒤 필요한 목록만 생성.
- 전장·HUD·무공 카드·합/복기 가독성 우선.
- 승인 자산·버전·용도·화면 위치·금지 요소를 Sheet 71·72에 기록.
- 미승인 이미지로 구현 권한을 만들지 않음.

현재 판정: `BLOCKED_BY_G4`.

## 9. G6 — `VERTICAL_SLICE_APP_FLOW_SHELL` Codex BUILD

```text
App Root
→ Main
→ 시작 무공 6중4
→ Route·Node·Briefing
→ 기존 Combat
→ Result·Reward·Retry
```

BUILD 진입 조건:

- G3·G4·G5 완료.
- 별도 구현 Plan·Branch·회귀 계약과 사용자 Build 승인.
- `RunSession`·`SaveService` 최소 소유권.
- 전환 중 입력 잠금·저장 실패·보상 이중 commit 테스트.

현재 판정: `NOT_GRANTED`.

## 10. G7 — Vertical Slice·사람 검증

- Windows 실제 Godot 실행.
- 키보드·마우스·게임패드 핵심 흐름.
- 1280×800·1440×900·16:9 safe area.
- 접근성 보조기술·성능 프로파일.
- `STEP 14` 신규 플레이어 5명.
- 두 번째 상대·노드 반복 제작 증거.
- 고능력치가 잘못된 계획을 덮는 비율 검증.

현재 판정: `NOT_GRANTED`.

## 10A — 초기 10권 자동 제품 검증

- [x] Windows x86_64 Release export.
- [x] export된 실행 파일 Windows CI runtime.
- [x] 50개 성취도 제품 시나리오.
- [x] 1280×800·1440×900·1920×1080.
- [x] 합성 키보드·마우스와 자동 접근성.
- [x] 성능 baseline.
- [ ] 로컬 Windows·실물 입력·접근성 사용자·Release 성능.
- [ ] STEP 14 신규 플레이어 5명.

판정: `PARTIAL_AUTOMATED_COMPLETE`; 증거 `7494f50c48573168542781e007eeab6af11dda7d` / `31068098197` / `8954602789`.

## 11. `[보류]`

- 후보 15명 전체를 첫 App Flow 구현의 선행 조건으로 삼는 것.
- 16권 절초 개별 설계.
- 주요 비무 6~10 런타임.
- 천하제일인·비동기 기능.
- 모바일 포팅·스토어·크로스 세이브.
- 최종 아트·오디오 폴리싱.

## 12. 검증 순서

```text
contract-check
→ reference-freshness
→ syntax·static
→ automated tests
→ Godot headless
→ Windows runtime·render
→ accessibility·performance
→ normal·failure·edge·counterexample·regression
→ Sheet readback
→ evidence-report
```

실행하지 않은 검증은 `NOT_RUN / UNVERIFIED`다.
