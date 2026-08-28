# TEN-DEC-20260828-FIRST_FIVE-DEFEAT-RETRY-SCOPE-01

```yaml
decision_id: TEN-DEC-20260828-FIRST_FIVE-DEFEAT-RETRY-SCOPE-01
status: APPROVED_CURRENT_IMPLEMENTATION_BINDING_REQUIRED
decision_date: 2026-08-28
approval_source: "user explicit: 권장안대로 진행"
scope: FIRST_FIVE_DUEL_SLICE_DEFEAT_RETRY_PLAYER_JOURNEY
canonical_rule_owners:
  - docs/07_COMBAT_UI_SPEC.md
  - docs/09_COMBAT_SYSTEM_ARCHITECTURE.md
  - docs/10_COMBAT_PRESENTATION_PLAN.md
  - docs/12_VERTICAL_SLICE_JIANGHU_JOURNEY.md
  - docs/13_VERTICAL_SLICE_OPPONENT_ROUTE_TEXT_UX.md
  - docs/planning-data/poc_run_state_contract.json
runtime_mutation: NONE_IN_THIS_DECISION
runtime_evidence: NOT_RUN
human_player_evidence: NOT_RUN
```

## 결정

첫 5전 Vertical Slice의 패배 여정은 다음 하나의 제한된 학습 루프다.

```text
패배
→ 실제 사건 1~3개 Combat Review
→ 실패 Result: 원인·복원 범위·남은 재도전 0/1을 표시
→ 1회 무료 동일-seed 재도전
→ 다시 패배하면 보상·Route 없이 회차 종료 및 타이틀 복귀
```

- 각 비무에서 허용되는 재도전은 정확히 한 번이다.
- 무료 재도전은 `PRE_BATTLE_RUN_STATE`를 복원하고, 같은 상대·같은 seed를 사용한다.
- 재도전 중 전투 피해·임시 자원·임시 상태·미획득 보상·노드 진행은 복원 대상이며, 승리 보상과 Route 진행은 한 번만 commit할 수 있다.
- Review는 숨은 적 계획·미선택 미래 결과·정답 행동을 보여 주지 않는다. 플레이어가 바꾸는 것은 자신의 다음 3슬롯 계획이다.
- 두 번째 패배에서는 재도전 CTA를 비활성화하고 회차 종료/타이틀 복귀만 제공한다. 이 Slice에는 패배 보상·Route 진입·영구재화 차감이 없다.

기존 `[영구재화]` 1/2/3 유료 재도전은 삭제하지 않는다. 다만 첫 5전 Slice에는 적용하지 않는 `DEFERRED_POST_SLICE_EXTENSION`이며, 재화 획득처·profile 저장·결제 복구·잔액 부족 UX·반복 난이도 검증을 포함한 새 승인 없이는 구현하지 않는다.

## 비교한 대안

| Alternative | Disposition | Player value | Scope / risk |
| --- | --- | --- | --- |
| A. 비무당 1회 무료 동일-seed 재도전 후 회차 종료 | `ADOPT` | 실패 원인을 읽고 한 번 수정해 핵심 판단 재미를 즉시 검증한다. | snapshot·패배 Result·중복 commit 방지만 필요하며 경제·저장 범위를 열지 않는다. |
| B. 기존 유료 재도전 1/2/3을 P0부터 구현 | `REJECT_FOR_FIRST_FIVE` | 비용이 긴장을 만들 수 있다. | 재화 source·profile/save·결제 recovery·잔액 부족을 함께 열어 Slice의 fun 검증을 흐린다. |
| C. 첫 5전에서 패배/재도전을 제외 | `REJECT` | 제작비는 가장 낮다. | `실패 → 복기 → 수정` 학습 약속이 끊겨 핵심 loop 증명이 불완전해진다. |

## 보호·제외

- `3수 = 3슬롯`, 2슬롯 `[전조] → [실행]`, `행동계획 실행` 뒤의 전투 해결 애니메이션 전환은 변경하지 않는다.
- 시작 공개 거리 `2`, 공개 상태만 읽는 AI, Review의 비정답 코칭 금지는 변경하지 않는다.
- 이 Decision은 `data/`, `src/`, `scenes/`, `assets/`, `addons/`, `project.godot`을 변경하거나 제품 구현을 승인하지 않는다.
- 새 그림체·독립 runtime asset을 만들지 않는다. 이후 계획 보드에는 기존 visual grammar 안에서 실패 Result 상태만 추가 검토할 수 있다.

## 단일 구현계약 수용 기준

1. 첫 패배는 Review 뒤 Failure Result를 표시하고 정확히 한 번만 무료 재도전할 수 있다.
2. 재도전은 동일 seed·상대·전투 직전 RunState를 사용하며 피해·임시 상태·미획득 보상·노드 진행을 누수 없이 복원한다.
3. 재도전 승리의 보상과 Route 진행은 정확히 한 번 commit한다.
4. 두 번째 패배에는 재도전·보상·Route가 없고 회차 종료/타이틀 복귀만 가능하다.
5. 영구재화, 잔액, 유료 결제, profile persistence는 이 Slice UI·데이터·저장에 나타나지 않는다.
6. 자동 회귀, Windows 가시 play, Human/Player·접근성·Android evidence는 서로 대체하지 않는다.
