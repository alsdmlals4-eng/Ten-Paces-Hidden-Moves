# 행동계획 잠금 · 실행 CTA 결정 · 2026-09-01

> Decision ID: `TEN-DEC-20260901-ACTION-PLAN-LOCK-AND-EXECUTE-CTA-01`
> Status: `USER_APPROVED_CURRENT / IMPLEMENTED / MACHINE_VERIFIED`
> Work mode: `BUILD + REVIEW`
> Product/runtime mutation authority: `USER_EXPLICIT_ACTION_PLAN_LOCK_AND_COMPACT_EXECUTION_CONTINUATION_2026-09-01`
> Scope: 완성된 현재 행동 묶음의 잠금 확인과 실행 입력을 분리하는 전투 화면 UX

## 사용자 결정과 문제

사용자는 행동계획 잠금 control이 자기 칸을 벗어나지 않게 하고, 실제 실행 control은 현재 행동 수만 보이는 작고 명확한 표면이 되게 요청했다. 이어 승인된 정면 결투 블루프린트는 `행동계획 잠금 → N수 실행 → 한 수씩 공개`를 player-facing flow로 확정했다.

기존 `TEN-DEC-20260828-ACTION-PLAN-EXECUTION-CTA-01`은 한 번의 CTA가 유효한 묶음을 commit하고 바로 해결로 전환하도록 정의했다. 이는 잠금 의미와 실행 시작을 한 입력에 섞기 때문에 이번 명시적 UX와 충돌한다.

## 채택 계약

```yaml
core_and_persistence:
  ten_cell_line: preserved
  opening_distance: preserved
  bundle_cadence: [3, 3, 4]
  resolver_formulas: preserved
  save_schema: preserved
  public_only_ai_boundary: preserved

plan_lock:
  prerequisite: current_bundle_complete
  first_cta_copy: "행동계획 잠금"
  first_cta_effect:
    presentation_state: plan_locked
    resolver_invocation: 0
    card_source_and_slot_editing: locked
    observation_and_future_reveal: unchanged

execute:
  prerequisite: plan_locked
  second_cta_copy: "{current_bundle_actions}수 실행"
  second_cta_effect:
    resolver_invocation: exactly_once
    existing_reveal_impact_settle_flow: preserved
  compact_layout: timing_strip_bound

reset:
  when: restart_or_next_bundle_opens
  plan_locked: false
```

## 범위와 제외

- 범위: `CombatProgressButton`, `CombatBoardPreviewAuto`, `ActionSelectionDock`의 계획 편집 입력 상태, CTA copy, compact layout, 상태 snapshot과 회귀 검증.
- 범위: current bundle의 카드/연결 행동 배치를 읽기 전용으로 잠그고, 두 번째 activation에서만 기존 resolver transaction에 진입한다.
- 제외: 거리·수치·합·방어·회피·중단·AI·관찰 payload·카드 data·자산 bytes·저장·플랫폼·release 변경.
- 이동의 접근/후퇴 선택과 모든 비이동 행동의 public opponent auto target은 이 결정에서 바꾸지 않는다.

## 기존 Decision과의 관계

- `TEN-DEC-20260828-ACTION-PLAN-EXECUTION-CTA-01`의 3/3/4 슬롯과 해결 뒤 Review 인과 설명은 유지한다.
- 같은 Decision의 "하나의 CTA가 곧바로 commit/해결 전환"이라는 **입력 semantics만 이 Decision으로 SUPERSEDED**한다.
- `TEN-DEC-20260901-GROUNDED-DUEL-AUTO-TARGET-OBSERVE-01`의 compact CTA와 슬롯 경계는 유지하되, CTA surface는 이제 `행동계획 잠금`과 잠금 뒤 `N수 실행`의 두 명시적 상태를 가진다.
- `TEN-DEC-20260830-ACTION-CARD-SOURCE-UNIFICATION-01`과 `TEN-DEC-20260831-ACTION-CARD-ILLUSTRATION-EXTENSION-01`의 공통 카드/삽화 consumer는 변경하지 않는다.

## 근거·구현 가능성·증거 경계

`docs/reviews/2026-09-01_FRONTAL_DUEL_REVEAL_AND_CARD_BENCHMARK.md`의 10개 공식 사례를 이 정확한 decision dimension(계획 공개, bounded commitment, action-by-action resolution)에서 재검토했다. 다른 게임의 complete future preview, deck/hand/draw, 실시간 조작은 채택하지 않는다. Godot 현재 consumer가 progress button, board presenter, common dock의 세 파일로 한정되어 있고, product regression이 first click resolver `0`, second click exact `1`을 확인하므로 `FEASIBLE_IMPLEMENTED`다.

자동 Godot product verifier와 Windows-visible machine observation은 `MACHINE_VERIFIED` 증거다. Windows human usability, human-player 이해·재미, Android device, accessibility-user, controller, release performance는 모두 `NOT_RUN`이다. 이번 package에는 새 image consumer가 없으므로 raster 생성·승인·등록은 수행하지 않는다.
