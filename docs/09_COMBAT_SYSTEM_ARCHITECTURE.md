# 십보강호 전투 시스템 아키텍처

> 책임: 실제 파일·상태·AI·판정·표현·재시작 경계와 최신 기획 데이터 인수 구조  
> 규칙 원본: `docs/02_COMBAT_RULES.md`

## 1. 아키텍처 원칙

```text
런타임 JSON·입력
→ 계획·대상·자원 검증
→ CombatAiPlanner 공개 후보
→ CombatResolutionEngine 단일 판정
→ state + timing_results + presentation_events + logs
→ CombatBoardPreview·HUD·VFX·SFX 표현
```

계산은 도메인, 표현은 UI에 둔다. 현재 구현은 Dictionary 기반이며 새 PoC 기획 JSON을 직접 읽지 않는다.

## 2. 실제 파일 책임

- `data/cards/basic_cards.json`, `ultimate_cards.json`: 현재 구형 런타임 행동.
- `data/combat/*.json`: 전장·HUD·판정·AI preview 계약.
- `src/combat/combat_resolution_engine.gd`: 상태·비용·합·피해·중단·기세·이벤트.
- `src/combat/combat_ai_planner.gd`: `CombatAiPlanner` 공개 snapshot·후보·seed·trace.
- `src/combat/combat_board_preview.gd`: 씬·입력·순차 표현·`restart_combat()`.
- `src/ui/`: 슬롯·HUD·로그·포커스.
- `tests/`: 현재 구현 회귀.

## 3. 편집 가능한 기획 데이터

`docs/planning-data/*.json`은 `NON_RUNTIME_POC_PLANNING`이다. 후속 구현은 다음 adapter를 명시적으로 만든다.

```text
planning budget/manual/duel/map JSON
→ schema validation
→ runtime card/status/enemy/run data
→ engine consumers
```

기획 파일을 런타임에서 암묵적으로 직접 읽지 않는다.

## 4. 현재 `CombatState`

현행 주요 필드: round_number, bundle_index, player, enemy, tile, health, attack_power, stamina, internal, momentum, statuses, seed. 최신 구현에는 다음 상태가 필요하다.

- accumulated_defense
- evade_charges와 valid_until_timing
- empowered_next_attack
- fortitude_charges
- active_action_id·current_hit_index
- effect_once_per_action_consumption

Schema·fallback·재시작·AI whitelist·로그 소비자를 함께 갱신해야 한다.

## 5. 공개 상태 라이벌 후보 AI 경계

현재 시그니처 `CombatAiPlanner.build_bundle_actions(...)`와 결정적 seed 원칙을 유지한다. 입력 whitelist만 사용하고 미확정 계획을 금지한다. 적 데이터의 public_tells·phase_change·candidate_actions를 runtime profile로 변환한다.

현행 운영 토큰: `enemy_plan_source=public_state_ai`.

## 6. 묶음 판정과 반환 구조

각 공격 행동은 `hits[]`를 가진다. 같은 수 공격은 hit index별로 짝짓고 다음 이벤트를 만든다.

```text
attack_action_started
hit_pair_clash | unmatched_hit
hit_evaded
defense_absorbed
health_damage_applied
effect_triggered
interrupt_attempted
fortitude_consumed
action_followups_cancelled
combatant_defeated
attack_action_finished
```

`timing_results`는 각 이벤트 뒤 snapshot을 제공하고, `presentation_events`는 동일 ID와 순서를 사용한다.

## 7. 순차 표현 상태

`planning → committed → resolving → presenting_result → next_bundle_ready | combat_ended`. 빠른 재생·즉시 완료는 큐 대기만 줄이고 결과를 바꾸지 않는다.

## 8. 종료·재시작

`restart_combat()`은 최신 초기 수치와 모든 신규 상태·이벤트 소비 기록을 초기화해야 한다. 반복 재시작에서 노드·signal·로그·효과 소비가 누적되면 실패다.

## 9. 검증 경계

- planning JSON 정적 검증.
- runtime adapter 단위 테스트.
- 단일·연격·중단·강건·효과 반례.
- `timing_results`와 `presentation_events` 순서 일치.
- AI 비공개 입력 부재.
- 재시작 완전 초기화.

이번 작업에서는 코드·runtime·Godot을 변경하지 않았으므로 새 아키텍처는 `AUTHORED_NOT_IMPLEMENTED`다.
