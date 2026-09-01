# 십보강호 · 정면 결투·순차 공개·통합 카드 블루프린트

```yaml
blueprint_id: TEN-BLUEPRINT-20260901-FRONTAL-DUEL-ACTION-FLOW-01
status: IMPLEMENTED_MACHINE_VERIFIED_CURRENT_VISUAL_CAPTURE_PENDING_PROJECT_BOUND_SESSION
authority:
  - latest_user_direction
  - AGENTS.md
  - docs/planning-data/current_user_planning_status.json
  - docs/decisions/2026-09-01_ACTION_PLAN_LOCK_AND_EXECUTE_CTA_DECISION.md
  - docs/18_VISUAL_ART_STYLE_COMPONENT_SYSTEM_SPEC.md
  - docs/reviews/2026-09-01_FRONTAL_DUEL_REVEAL_AND_CARD_BENCHMARK.md
scope: COMBAT_PRESENTATION_AND_INTERACTION_CARRIER_ONLY
core_rule_change: false
save_schema_change: false
new_raster_asset: NONE_REQUIRED
implementation_feasibility: FEASIBLE_IMPLEMENTED
evidence_ceiling: MACHINE_GODOT_PRODUCT_VERIFIERS_AND_WINDOWS_VISIBLE_OBSERVATION_ONLY_CURRENT_EXACT_REPOSITORY_CAPTURE_PENDING_HUMAN_ANDROID_ACCESSIBILITY_RELEASE_NOT_RUN
```

## 1. 플레이어 약속과 한 문장 설계

**플레이어 약속:** “세 수를 내 손으로 잠그고, 서로의 수가 한 장면씩 드러나는 순간에 거리·합·방어의 이유를 읽어 다음 묶음을 더 날카롭게 고른다.”

**설계 문장:** 전투는 **정면으로 마주 선 두 인물**, 중앙의 `거리 N`, 하단의 **공통 카드 격자와 현재 3/3/4 묶음**을 유지한다. 잠금 뒤에는 화면을 계획 편집에서 분리하고, 한 수의 두 행동 카드만 공개한 다음 실제 해결된 사건을 충돌·피격·이동으로 이어 붙인다.

## 2. 현재 상태 → 교체 이유 → 기대 효과

| ID | 현재 상태 | 요청 이유 | 목표와 기대 효과 | 다음 구현 책임 |
| --- | --- | --- | --- | --- |
| BP-01 | pre-merge에는 `TileLayer`/`FootAnchorGuide`와 `attack_direction` carrier가 남아 있었다. | 플레이어에게 논리 전투판/공격 방향을 보이지 않게 해야 한다. | 논리 10칸은 resolver만 사용하고, 전투 화면은 공유 바닥·거리·발 접지로 읽힌다. | `CombatBoardPreviewAuto` 구현·검증 완료 |
| BP-02 | pre-merge에는 기초 tray, 무공 dock, 절초 list/menu가 나뉘어 있었다. | 기초·무공·절초가 모두 카드 형식으로 일관되어야 한다. | 하나의 `ActionChoiceCard` 계층에서 탭만 바꿔 5×2 이내로 비교한다. | `ActionSelectionDock` + panels 구현·검증 완료 |
| BP-03 | 카드 사실 정보는 작은 surface에서 detail 의존 위험이 있었다. | 카드에서 사거리·소모량·효과가 다시 보여야 한다. | 항상 이름·수·비용·짧은 효과를 보이고, 공격만 사거리를 같은 행에 표시한다. | `ActionChoiceCard` view-model 구현·검증 완료 |
| BP-04 | reveal overlay는 있었지만 계획 잠금과 현재 수 공개의 경계를 한 상태 전이로 확인할 필요가 있었다. | 행동을 하나씩 공개하며 자연스럽게 겨루어야 한다. | 현재 수만 공개, 상호 카드 대조, 합/방어/회피/사거리 이유, 인물 motion, 최신 거리 순으로 이어진다. | `CombatActionRevealOverlay` + presentation adapter 구현·검증 완료 |
| BP-05 | 관찰은 잠긴 적 행동 유형만 공개하도록 실제 resolver가 지원한다. | 관찰이 상대 행동을 알려줘야 한다. | `관찰 기록 · [공격→대응]`은 planning층에 표시하되 기술명·대상·피해·뒤 수는 계속 숨긴다. | resolver output → status chip 구현·검증 완료 |
| BP-06 | 기존 compact CTA는 `3수 실행`만 보여 계획 확정과 해결 시작이 한 입력으로 섞였다. | 행동계획 잠금과 실행 의미를 한눈에 구분해야 한다. | 선택 완료 뒤 `행동계획 잠금`, 잠금 후 같은 compact CTA는 `3수 실행`처럼 현재 묶음 수만 표시한다. | progress-button + dock input state 구현·검증 완료 |

## 3. 화면 플로우 맵

```text
MAIN
  └─ 비무행 시작
      └─ SETUP → INTRO → BRIEFING
                         └─ COMBAT / 계획 편집
                              ├─ [기초 | 무공 | 절초] 카드 탭
                              │    └─ 카드 선택 → 현재 3/3/4 슬롯에 배치
                              │          └─ 이동만 [전진 | 후퇴] 선택
                              ├─ 관찰점 사용 → 적 잠금 행동 "유형"만 기록
                              └─ 모든 현재 슬롯 완료 → 행동계획 잠금
                                    └─ 실행 · N수
                                        └─ TIMING 1 공개
                                            └─ 양측 현재 행동 카드
                                                └─ 합/사거리/방어/회피/중단 사건
                                                    └─ 타격·이동·VFX 정착
                                                        └─ TIMING 2 … 마지막 수
                                                            └─ REVIEW
                                                                └─ 다음 3/3/4 묶음 또는 RESULT
```

### 상태 전이와 입력 경계

| 상태 | 화면에서 보이는 것 | 허용 입력 | 금지/보호 |
| --- | --- | --- | --- |
| `planning` | 전장, 거리, 카드 격자, 현재 빈 슬롯, 관찰 기록 | 탭/카드/슬롯/관찰 | 적 잠금 기술명·목표·피해 |
| `move_intent` | 선택한 이동 카드와 `전진`/`후퇴` 두 intent tile | 전·후 선택, 취소 | 타일 번호·공격 방향·다른 카드 변경 |
| `plan_locked` | 잠금된 현재 묶음과 compact `N수 실행` | 실행 | 미래 결과 미리보기·카드/슬롯/관찰 변경 |
| `reveal` | 이번 timing 양측 카드, `N번째 행동 공개` | 빠른 재생/모션 감소/소리 | 카드 배치·관찰·다음 timing 보기 |
| `impact` | 합선/VFX와 실제 사건 라벨, 위치/HP/자원 변화 | 접근성 토글만 | 결과 중복 실행 |
| `settle` | 갱신된 거리와 완료한 수의 짧은 log | 없음 | 다음 수 누설 |
| `review` | 원인→적용→결과 1~3개 | 상세 log, 다음 묶음 | 자동 코칭·새 rule 계산 |

## 4. 전투 화면 와이어프레임

### A. 계획 편집 · 1440×900 기준

```text
┌─────────────────────────────────────────────────────────────────────────────────────────────────────┐
│ [나: 체력/기력/내력/기세]        제 N 라운드 · 현재 3수         [상대: 체력/기력/내력/기세]  │
│  관찰 기록 · [공격→대응]       ○ ○ ●  ○ ○ ○  ○ ○ ○ ○        관찰점 1                         │
├─────────────────────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                                     │
│   PLAYER BATTLEr      ───────────────  거리 2  ───────────────        ENEMY BATTLER                 │
│   (공유 석정 바닥, 동일 foot-anchor, 논리 grid/number 미표시)                                      │
│                                                                                                     │
├─────────────────────────────────────────────────────────────────────────────────────────────────────┤
│ 현재 계획 3수  [ 1 · 이동 / 전진 ] [ 2 · 전조 ] [ 3 · 공격 ]     [행동계획 잠금] → [3수 실행]  │
├─────────────────────────────────────────────────────────────────────────────────────────────────────┤
│ [기초 ●] [무공 ○] [절초 ○]    5열 × 최대 2행의 공통 행동 카드                          [상세]  │
│ [삽화][이름 · N수]  [유형 / 공격이면 사거리]  [기력·내력·기세]  [한 줄 효과]                    │
└─────────────────────────────────────────────────────────────────────────────────────────────────────┘
```

### B. 이번 수 공개 · 화면을 덮는 일시적 레이어

```text
┌─────────────────────────────────────────────────────────────────────────────────────────────────────┐
│                                      2번째 행동 공개                                                  │
│                                         한 수씩 겨룬다                                                 │
│                                                                                                     │
│           ┌────────────────────┐              VS              ┌────────────────────┐                │
│           │ 나 · [삽화]        │                              │ 상대 · [삽화]      │                │
│           │ 전조 · 1수         │                              │ 검격 · 1수         │                │
│           │ 기력 1 · 효과 ...  │                              │ 사거리 1 · 효과 ...│                │
│           └────────────────────┘                              └────────────────────┘                │
│                                                                                                     │
│                              합 승리 · 방어도 적용 · 피해 2                                          │
└─────────────────────────────────────────────────────────────────────────────────────────────────────┘
```

`reveal`은 실제 현재 timing의 resolver event만 채운다. 카드에 보이는 정보는 이미 해결된 행동의 정보이며, 빈 면은 “이번 수 행동 없음 · 다음 수는 공개하지 않습니다”로 명시한다.

### C. 이동 방향 미니 intent

```text
선택: 이동 · 1수
[ ← 후퇴 ]     [ 전진 → ]
```

공격/무공/절초는 이 intent를 열지 않는다. target은 현재 규칙의 유효 대상 자동 선정 결과를 사용한다. 이 UI는 방향·범위를 새로 판정하지 않고, 플레이어 의도만 `ActionTimingPanel`에 보낸다.

## 5. 통합 카드 계약

| 영역 | 항상 보임 | 조건부 보임 | 상세 패널로 이동 | 금지 |
| --- | --- | --- | --- | --- |
| 상단 60% | semantic atlas 삽화, 이름, `N수` | lock/rank badge | 없음 | 삽화만으로 유형/효과 전달 |
| 중간 | 출처(기초/무공/절초), 유형 | 공격이면 `사거리 N` | 장거리 조건 | 이동/자신 행동에 가짜 사거리 |
| 하단 | 기력·내력·절초면 기세, 한 줄 효과 | 예약/잠금 사유 | 세부 조건·다단계 효과·flavor | 비용/효과를 숨긴 text-only card |
| 상태 | selected/focused/disabled/locked | reserved | tooltip과 accessibility description | 색상만으로 상태 전달 |

### 자산·소비처 매핑

| 대상 | 현재 승인 자산/컴포넌트 | 이번 disposition | 이유 |
| --- | --- | --- | --- |
| 전장 배경 | `assets/backgrounds/frontal_courtyard_duel_background_01_v1.png` | `REUSE_PROJECT` | 정면 공유 바닥 consumer가 이미 존재한다. |
| 전투원 | `player_wanderer_battler_rgba_v1.png`, `enemy_masked_battler_rgba_v1.png` | `REUSE_PROJECT` | 동일 발 기준선/크롭을 adapter로 맞추면 된다. |
| 기초 카드 | final-locked basic ink atlas | `REUSE_PROJECT` | 공통 renderer가 이미 소비한다. |
| 무공·절초 카드 | final-locked martial/ultimate semantic atlas | `REUSE_PROJECT` | 공통 renderer의 semantic mapping을 유지한다. |
| 합/공격 효과 | final-locked attack-clash atlas, ultimate VFX | `REUSE_PROJECT` | 실제 resolved event만 강조한다. |
| 새 raster | 없음 | `DO_NOT_GENERATE` | P0 실제 consumer의 asset gap이 없고, 같은 기능의 후보를 늘리면 provenance·용량·검수 비용만 증가한다. |

## 6. Godot 구현 계약

| 책임 | 현재 consumer | 다음 변경 | 비책임 |
| --- | --- | --- | --- |
| combat presentation | `src/combat/combat_board_preview.gd` | tile/guide의 player-facing 노출 제거, `move_tile`만 intent로 축소, shared dock·compact CTA 연결, state transition orchestration | resolver 수치·AI·save 판단 |
| 카드 surface | `src/ui/action_selection/action_choice_card.gd` | 60/40 hierarchy와 fact row의 clipping/wrapping contract, 모든 source 동일 state | 새 행동 데이터 생성 |
| source panels | `src/ui/action_selection/action_selection_dock.gd` | combat scene 내 단일 card grid host와 tab behavior | 전투 결과 계산 |
| sequential reveal | `src/ui/combat_action_reveal_overlay.gd` | current timing만 두 card에 fill, reason/result text가 사건과 일치 | future action·AI memory 노출 |
| placement | `src/ui/action_timing_panel.gd` | 이동 intent만 수용하며 action count/lock state를 export | range/validity 재계산 |
| progress | `src/ui/combat_progress_button.gd` | `행동계획 잠금` / `N수 실행` copy와 compact layout | commit/resolution authority |

### test-first acceptance matrix

| 검증 ID | RED 조건 | GREEN 조건 |
| --- | --- | --- |
| BP-T01 | player-facing layout에 `TileLayer`, `FootAnchorGuide`, logical tile number가 남음 | logical board는 active but rest surface에서 hidden, `거리 N`은 visible |
| BP-T02 | `attack_direction`/공격 방향 문구 또는 red tile target이 호출됨 | 이동만 front/back intent, nonmove action은 auto target |
| BP-T03 | 기초·무공·절초가 서로 다른 renderer/fields를 사용함 | 모두 `ActionChoiceCard`, illustration/name/slots/cost/effect accessibility가 보존됨 |
| BP-T04 | reveal이 future action을 채우거나 하나의 timing 이상을 공개함 | current timing events만, future exposure false, empty side copy 명시 |
| BP-T05 | 관찰이 이름/목표/피해를 공개하거나 point 없이 성공함 | action-type only payload와 point spend가 resolver test로 확인됨 |
| BP-T06 | 1440×900 또는 1280×800에서 CTA/card/foot anchor가 clip·overlap | capture manifest + runtime tree/visual screenshot evidence |

## 7. 구현 순서와 evidence ceiling

1. **계약 test RED → GREEN** — 정면 carrier와 통합 카드 경계를 구현 전·후에 고정했다.
2. **공통 card grid 통합** — `ActionSelectionDock`이 기초·무공·절초의 동일 카드 surface를 실제 소비한다.
3. **전장 carrier 교체** — logical tile은 hidden state로, 이동만 front/back intent로 전환했다.
4. **reveal/impact refinement** — public resolved events로 card reveal → event VFX → distance settle을 연결했다.
5. **계획 잠금 refinement** — `TEN-DEC-20260901-ACTION-PLAN-LOCK-AND-EXECUTE-CTA-01`에 따라 첫 CTA는 resolver를 건드리지 않는 `plan_locked`, 두 번째 CTA만 기존 해결로 연결했다.
6. **runtime capture** — 기존 normal/readable baseline capture는 유지한다. 이번 CTA copy/state의 current exact repository capture는 프로젝트-bound capture session이 생길 때까지 별도 `PENDING`으로 남긴다.

```yaml
machine_verification: IMPLEMENTED_GODOT_PRODUCT_VERIFIERS_PASS_20260901
runtime_visual_capture: BASELINE_CAPTURE_TEN_RVC_004_005_RETAINED_CURRENT_EXACT_PLAN_LOCK_CAPTURE_PENDING_PROJECT_BOUND_SESSION
human_player_comparison: NOT_RUN
android_device: NOT_RUN
accessibility_user: NOT_RUN
release_performance: NOT_RUN
```

## 8. 적대 검토 기준

1. **숨은 정보:** 관찰과 reveal이 현재 수 이후를 누설하지 않는가.
2. **입력 부담:** 이동 외 행동에 방향 선택이나 logical tile 클릭을 강요하지 않는가.
3. **전투 우선:** 배경·배틀러·VFX가 거리·현재 수·카드 사실보다 강하게 읽히지 않는가.
4. **일관성:** 기초·무공·절초가 다른 정보 밀도/조작/상태 표현으로 갈라지지 않는가.
5. **회귀와 정리:** 새 consumer가 없는 raster/임시 파일을 만들지 않고, 삭제 전 source/asset/test consumer와 Git rollback을 확인하는가.

## 9. 지금 확정할 것과 사용자 결정을 남길 것

```yaml
approved_to_implement_next:
  - "current final-locked assets reuse"
  - "frontal shared ground and hidden logical board presentation"
  - "move-only front/back intent and nonmove auto targeting"
  - "unified ActionChoiceCard presentation"
  - "action-by-action current-timing reveal"
  - "type-only observation record"
  - "plan lock then current-bundle execution CTA"
requires_new_user_final_lock:
  - "a new raster/image candidate only if an uncovered concrete runtime consumer is discovered"
requires_human_evidence_later:
  - "whether new players understand the 3/3/4 lock, observation, and reveal causality"
```
