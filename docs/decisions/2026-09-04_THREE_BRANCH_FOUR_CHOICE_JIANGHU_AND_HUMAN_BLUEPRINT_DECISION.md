# 2026-09-04 강호행로 3갈래·4회 선택 및 사람용 블루프린트 결정

> Decision ID: `TEN-DEC-20260904-THREE-BRANCH-FOUR-CHOICE-JIANGHU-AND-HUMAN-BLUEPRINT-01`
>
> 상태: `USER_APPROVED_CURRENT / SPECIFIED / RUNTIME_IMPLEMENTATION_NOT_STARTED`
>
> 사용자 승인 근거: 2026-09-04 최신 지시 - “강호행로 경로 이미지 처럼 3갈래,카운터 4개”, “일관된 이미지를 신경써서 필요한 이미지 제작 후에 사람용 블루프린트에 아틀라스+플로우맵+와이어프레임,단계별 PM 체크가 합쳐서 만들어줘”, “작업시 승인 필요한 사항은 다 승인할테니까 작업 마무리까지 진행해줘”.

## 1. 결정

### 1.1 강호행로

각 주요 비무 사이의 강호행로는 기존 `성장/회복 1개 → 정보/대비 1개` 고정 2노드가 아니다.

```text
비무 결과 → 3갈래 후보 중 1개 선택 × 정확히 4단계 → 다음 비무 Briefing
```

- 경로 화면은 `행로 선택 0/4`로 시작해 선택 성공 뒤 `1/4`부터 `4/4`까지 갱신한다.
- 각 단계는 가로로 비교 가능한 **정확히 세 후보**를 보여 준다. 같은 후보를 여러 개 고르는 방식은 아니다.
- 후보는 `성장/회복`, `정보/관찰`, `사건/대비` 중 하나의 공개 범주, 효과 한 줄, 필요한 비용/조건만 보인다.
- 한 후보를 고르면 결과를 적용하고, 다음 단계의 세 후보로만 전환한다. 새로운 서브 Scene이나 일반 전투를 추가하지 않는다.
- `4/4`의 적용이 끝나면 다음 비무 Briefing으로 간다. 첫 5전 Vertical Slice에서는 비무 간 4구간마다 이 계약을 반복하므로 최대 16개의 실제 경로 선택이 필요하다.
- 후보 생성은 다음 비무 준비를 바꾸어야 하지만, 상대의 현재·미래 행동 계획, 확률, 정확한 기술명/비용/피해/대상, AI 가중치 또는 정답 수를 주면 안 된다.

### 1.2 비무 준비와 행동 실행

- 준비 화면은 상단 상태 HUD, 중단 정면 결투, 하단 계획/카드/상세/관찰의 `20% / 50% / 30%` 정보 위계를 유지한다.
- 플레이어 HUD는 체력·기력·내력에 `현재/최대` 숫자를 보이며, 상대 HUD는 동일 막대·절초 기세 5칸·상태 칸만 보여 주고 정확한 수치는 감춘다.
- 현재 행동 묶음, `기본 / 무공 / 절초` 5×2 격자, 상세 효과, 유형 전용 상대 행동 관찰을 같은 준비 surface에 둔다.
- 유효한 계획을 확정하는 CTA는 단 하나의 **`행동 실행`**이다. 별도의 `행동계획 잠금` 화면/버튼을 플레이어에게 노출하지 않는다. 누르면 즉시 하단 계획 표면을 닫고 전투 실행으로 들어간다.
- `복기`는 보존되는 인과 정보이며 별도 Review scene/overlay는 두지 않는다. 현재 수 결과 strip과 전투 종료 결과의 실제 1~3개 원인 요약으로만 보여 준다.

### 1.3 전투 실행 시각 계약

- 기본 전투·합·절초에서 모두 `내 현재 공개 카드 → VS ← 상대 현재 공개 카드` compare rail을 상단에 표시한다.
- `합`은 실제 충돌 사건일 때만 쓴다. 두 카드와 중앙 VS, 흰금 접점, 검은 건조 먹선으로 한 번의 충돌을 표시한다.
- `절초`는 절초 기세 5칸과 청백 내공 소용돌이를 쓰며, 과도한 광선이나 부유 캐릭터를 쓰지 않는다.
- 피격으로 현재 행동이 중단되면 이미 공개된 현재 카드만 찢김/퇴색 `[중단]`으로 표시한다. 미래 행동 카드와 숨은 계획은 노출하거나 찢지 않는다.
- 두 전투원은 같은 바닥선에 접지하고, 공격·회피·막기·피격·절초는 presentation-only 모션이다. 판정·거리·자원·AI·저장값을 화면이 재계산하지 않는다.

## 2. 시각 생산 및 사람용 Blueprint

### 2.1 새 전체 아틀라스 후보

| 항목 | 값 |
|---|---|
| 후보 ID | `TEN_PACES_3X3_SCREEN_ATLAS_20260904_v1` |
| 저장소 경로 | `docs/visual-assets/candidates/TEN-HUMAN-BLUEPRINT-20260904/TEN_PACES_3X3_SCREEN_ATLAS_20260904_v1.png` |
| 역할 | 9개 화면의 동일 그림체·정보 위계 후보. 사람용 Blueprint의 시각 기준이며 runtime texture가 아니다. |
| 화면 | 1 메인, 2 시작 무공, 3 성장/구성, 4 강호행로, 5 비무 준비, 6 기본 전투, 7 합, 8 절초, 9 종료/보상 |
| 상태 | `GENERATED_CANDIDATE / DOCUMENTATION_CONSUMED / USER_FINAL_RUNTIME_LOCK_NOT_REQUESTED` |

새 후보의 분리 생산 순서는 바꾸지 않는다.

```text
전체 아틀라스 후보
→ 실제 consumer 별 배경 / HUD frame / 계획 frame / 상세 frame / 관찰 frame / 카드 삽화 / battler / VFX brief
→ 사용자 final lock
→ provenance·SHA·consumer 등록
→ Godot composition
→ runtime capture
```

승인된 기존 모듈은 교체하지 않는다. 새 atlas가 실제 runtime을 증명하거나, 외부 reference의 shipping 권리를 증명하지 않는다.

### 2.2 사람용 Blueprint의 역할

새 PDF는 사람용으로 다음을 한 문서 안에서 연결한다.

1. 프로젝트 소개와 3분 독해 경로.
2. 3×3 화면 아틀라스와 화면 번호의 의미.
3. `강호행로`와 `비무`를 나눈 Flow Map, 와이어프레임, 정보 누출 경계.
4. 화면·자산·Godot handoff·검증을 구분한 단계별 PM 체크.
5. `현재 구현`, `명세 확정`, `후속 구현`, `NOT_RUN`의 증거 상태.

PDF는 파생 독자용 산출물이다. Markdown Decision·GDD·구조화 data·실제 code/data/scene/test를 대체하지 않는다.

## 3. 이전 정본과 실제 구현의 판정

| 대상 | 판정 | 이유 |
|---|---|---|
| `TEN-DEC-20260820-JIANGHU-JOURNEY-VERTICAL-SLICE-01`의 구간당 정확히 2노드 | `SUPERSEDED_FOR_ROUTE_COUNT_ONLY` | 사용자 최신 3갈래·4회 선택이 우선한다. 5전·정보 누출 방지·결과/보상 문맥은 유지한다. |
| `TEN-DEC-20260901-ACTION-PLAN-LOCK-AND-EXECUTE-CTA-01`의 두 단계 CTA | `SUPERSEDED_FOR_PLAYER_FACING_CTA_ONLY` | 단일 `행동 실행` 즉시 진입으로 교체한다. |
| 별도 `Combat Review Overlay` | `SUPERSEDED_FOR_SCREEN_BOUNDARY_ONLY` | 인과 복기는 유지하되 result strip/결과 요약에 흡수한다. |
| `src/run/vertical_slice_route_model.gd`, `src/run/vertical_slice_shell_route_auto.gd` | `IMPLEMENTED_LEGACY_TWO_NODE_ROUTE` | 현재 성장 1회와 정보 1회만 지원한다. 이 Decision을 구현하지 않았다. |
| `src/ui/combat_progress_button.gd` 및 관련 surface | `IMPLEMENTED_LEGACY_TWO_STEP_CTA` | 현재 lock 후 `N수 실행` 흐름이 남아 있다. 이 Decision을 구현하지 않았다. |

## 4. 구현 handoff와 수용 기준

후속 Godot BUILD package는 다음을 test-first로 소유해야 한다.

```yaml
route_state:
  candidates_per_stage: 3
  picks_per_inter_duel_gap: 4
  visible_counter: "0/4 through 4/4"
  selected_candidates_applied_once: true
  next_briefing_only_after_fourth_pick: true
  hidden_enemy_plan_leak: false

combat_surface:
  player_current_max_values_visible: true
  enemy_numeric_values_hidden: true
  momentum_pips: 5
  preparation_card_grid: "5x2"
  player_facing_execute_cta: "행동 실행"
  standalone_review_overlay: false
  reveal_compare_rail: "my card -> VS <- enemy card"
  interruption_only_affects_revealed_current_card: true
```

문서와 atlas의 상태는 `SPECIFIED / DOCUMENTATION_CANDIDATE`. Godot 구현, Windows runtime capture, 사람 플레이, Android, 접근성 사용자, 권리·출시 검증은 모두 별도 gate다.

## 5. 조사와 적대 검토

이 결정은 [`2026-09-04_THREE_BRANCH_FOUR_CHOICE_ROUTE_BENCHMARK.md`](../reviews/2026-09-04_THREE_BRANCH_FOUR_CHOICE_ROUTE_BENCHMARK.md)의 10개 사례를 current source check로 사용한다. `Monster Train`, `Wildfrost`, `Dead Cells`의 짧은 경로 선택은 **ADAPT**하고, `Slay the Spire`, `Loop Hero`의 덱/경로 조작은 **AVOID**한다. 검토 결과는 다음을 거절했다.

1. 4회 선택을 4개 독립 Scene으로 늘리는 구성.
2. 후보 효과가 동등하거나 다음 비무와 무관한 클릭 지연.
3. 전투의 숨은 계획을 정보 보상으로 풀어 버리는 구성.
4. 새 그림을 기존 final-locked runtime asset 위에 무단 교체하는 구성.
5. PDF/이미지 후보를 runtime·human·rights·release PASS로 과장하는 주장.

## 6. 상태와 남은 위험

```yaml
decision_state: USER_APPROVED_CURRENT
documentation_state: SPECIFIED
image_state: GENERATED_CANDIDATE_DOCUMENTATION_CONSUMED
runtime_state: IMPLEMENTED_LEGACY_FOR_ROUTE_AND_CTA
machine_runtime_verification_of_new_contract: NOT_RUN
human_player_validation: NOT_RUN
android_device_validation: NOT_RUN
accessibility_user_validation: NOT_RUN
shipping_asset_rights_and_release: RELEASE_BLOCKED_UNVERIFIED
```
