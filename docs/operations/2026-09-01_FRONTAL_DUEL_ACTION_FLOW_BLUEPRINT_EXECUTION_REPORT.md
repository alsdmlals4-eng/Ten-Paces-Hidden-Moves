# 2026-09-01 정면 결투·순차 공개·통합 카드 블루프린트 · Execution Report

## 작업 전 문제

사용자는 최신 Base 계약을 기준으로 작업 구조를 갱신한 뒤, 벤치마킹과 블루프린트(와이어프레임/플로우 맵)를 시작하고 필요한 이미지/UI를 실제 제품 소비처에 맞춰 제작하라고 요청했다. 현재 main의 실제 Godot source에는 다음 두 층이 동시에 남아 있었다.

- 최신 방향에 맞는 층: 정면 공유 바닥 background, shared semantic card atlas, action-by-action reveal, resolved-event VFX, 관찰의 행동 유형만 공개하는 resolver output.
- 구형 carrier: `CombatBoardPreview`의 `TileLayer`/`FootAnchorGuide`, `attack_direction`, `BasicCardTray`와 별도 `UltimateList` presentation.

즉 새 이미지가 없는 것이 문제가 아니며, 이미 승인·구현된 자산과 UI 컴포넌트가 최신 플레이어 흐름으로 완전히 합쳐지지 않은 것이 문제였다.

## 조사·비교 결과

`docs/reviews/2026-09-01_FRONTAL_DUEL_REVEAL_AND_CARD_BENCHMARK.md`는 최신 공식 source로 다음 10개를 재확인했다.

1. Your Only Move Is HUSTLE
2. Shogun Showdown
3. Fights in Tight Spaces
4. Hellish Quart
5. For Honor
6. Into the Breach
7. Phantom Brigade
8. Marvel's Midnight Suns
9. Inkulinati
10. Slay the Spire

직접 비교는 계획 결투/거리 타이밍을, 인접 비교는 공개 정보·타임라인·카드 사실성·수묵 정보 위계를 다뤘다. YOMI Hustle의 완전 미래 예측과 Slay the Spire의 deck/hand/draw는 각각 십보강호의 숨은 계획과 deck 금지를 위협하는 혼합/부정 경계 사례로 기록했다.

## 채택한 구조와 이유

- 정면 공유 바닥과 중앙 `거리 N`을 전장 표현의 1차 정보로 고정한다. 논리 10칸은 resolver의 내부 구조로 남기며 floor grid/번호를 화면에서 제거한다.
- 기초·무공·절초는 단일 `ActionChoiceCard` 표면을 사용한다. 삽화는 보조 정보이고, 이름·수 점유·비용·효과·잠금·접근성 설명은 항상 text-native로 유지한다.
- 이동만 전진/후퇴 의도를 받는다. 비이동 공격의 방향 선택은 없고, 현재 규칙의 자동 대상 선정 결과를 사용한다.
- 현재 timing의 양측 action card만 공개하고, 사건별 합/사거리/방어/회피/중단 → VFX/위치 정착 → 다음 수의 순서를 쓴다. 미래 action은 드러내지 않는다.
- 관찰은 잠긴 적 행동의 **유형**만 history chip으로 남기며 기술명·대상·피해는 계속 비공개다.

## 실제 산출물

- [벤치마크 보강](../reviews/2026-09-01_FRONTAL_DUEL_REVEAL_AND_CARD_BENCHMARK.md): 10개 공식 사례의 `ADOPT / ADAPT / AVOID`와 source/evidence limit.
- [정면 결투 블루프린트](../design/2026-09-01_FRONTAL_DUEL_ACTION_FLOW_BLUEPRINT.md): 제품 flow map, 세 화면 와이어프레임, 상태·카드·asset·Godot·test contract.
- `current_user_planning_status.json`: 위 두 정본 locator와 `BLUEPRINT_READY_IMPLEMENTATION_PENDING` 상태를 추가했다.
- `tests/test_frontal_duel_action_flow_blueprint_contract.py`: blueprint가 core/save/raster scope를 확대하지 않고 current planner가 benchmark/blueprint를 가리키는지 검증한다.

새 PNG는 만들지 않았다. 현 P0 전투 소비처가 user-final-locked background, battlers, basic/martial/ultimate card atlas, attack-clash VFX를 이미 가지므로 동일 목적의 raster를 새로 만들면 용량·provenance·검수 비용만 증가한다. 정확히 새로운 uncovered runtime consumer가 발견될 때만 scoped brief → 단일 candidate → user final lock 경로로 생성한다.

## 사용 예와 기대 효과

플레이어는 카드에서 `속공 · 1수 · 공격 · 사거리 1 · 기력 1 · 기본 피해 6`을 읽고 현재 3수 슬롯에 넣는다. 이동이면 `전진/후퇴`만 선택한다. 계획을 잠그면 `실행 · 3수`가 작게 남고, 해상도마다 양측의 이번 행동 카드가 드러난 뒤 `합 승리 · 방어도 적용 · 피해 2`가 해당 VFX와 인물의 actual state 변화로 이어진다. 다음 행동은 아직 보이지 않는다.

이 구조는 사용자가 요구한 카드 일관성·불필요한 공격 방향 제거·행동 수 중심 CTA·관찰의 실질 정보·자연스러운 순차 연출을 하나의 상태 전이로 묶는다.

## 검증 증거

- **Fresh read:** local `main`과 `origin/main`은 작업 시작 시 `8f17a923db7814ef0663b46dfe6ce32c2079da24`에서 일치했고, 전용 worktree/branch에서만 변경했다.
- **Base/project contract:** project operating-contract validator가 PASS했다. 최신 Base v9.4.4 adapter와 project-local game-design/combat UX/implementation/verification routes를 읽었다.
- **Current actual consumers:** `CombatBoardPreview`, `ActionChoiceCard`, `ActionSelectionDock`, `CombatActionRevealOverlay`, `ActionTimingPanel`, main title, card data/atlas and current asset provenance were fresh-read했다.
- **Baseline Python suite:** blueprint 문서 작성 전 440개 중 438 pass, 2 failure였다. 둘 다 이번 blueprint 이전부터 존재한 stale string-expectation failure다: `test_action_card_source_unification_contract`는 이미 `_range_fact_text()` helper로 옮겨진 조건을 이전 inline string으로 찾았고, `test_pc_first_vertical_slice_implementation_gate`는 현 visual owner보다 오래된 final-lock 문자열을 요구했다.
- **Recovery:** 위 두 test를 product source를 되돌리지 않고 실제 helper와 현 `current_user_planning_status.json` 정본을 검사하도록 최소 갱신했다. focused 5/5 PASS, Python discovery 442/442 PASS였다.
- **New blueprint contract:** `tests/test_frontal_duel_action_flow_blueprint_contract.py` 2/2 PASS를 포함해 위 full suite에 반영했다. 이 문서 작성만으로 Godot runtime, player/Human, Android, accessibility-user, release performance PASS를 주장하지 않는다.

## 자동화·학습 반영

이 package는 image gap을 automatic generation queue로 만들지 않고 `ACTUAL_CONSUMER_REQUIRED`를 유지한다. 새 contract test는 future planning status가 benchmark를 잃거나, blueprint가 core/save/raster mutation처럼 오독되는 drift를 잡는다. 다음 UI mutation package는 이 blueprint의 BP-T01~BP-T06을 RED→GREEN 순서로 실제 Godot verifier에 추가한다.

## 5회 적대 검토

1. **Core attack:** full enemy intent/target/damage, deck/hand/draw, save schema가 새 blueprint에 들어가지 않았는지 검토했다. 모두 제외했다.
2. **Consumer attack:** 새 image 생성 대신 existing final-locked asset/actual consumer를 확인했다. P0 raster gap은 발견되지 않았다.
3. **Input attack:** 공격 direction과 tile click은 user direction과 충돌하므로 move-only front/back intent로 replacement boundary를 명시했다.
4. **Information attack:** 관찰과 reveal이 current timing/type-only 경계를 넘지 않도록 state table과 test acceptance에 기록했다.
5. **Evidence/retention attack:** desk research, current-source readback, future runtime capture, human/device evidence를 분리했고 임시 이미지·복제 asset·불필요한 archive 삭제를 하지 않았다.

## 미검증·남은 위험과 다음 안전 작업

- **미검증:** 이 blueprint를 반영한 1440×900/1280×800 Godot runtime capture, reduced-motion path, Windows/Android device, human-player 이해·재미, accessibility-user, release/performance.
- **구형 code carrier:** `TileLayer`/`FootAnchorGuide`, `attack_direction`, separate tray/ultimate list는 아직 main에서 살아 있다. 이 report는 삭제/수정을 수행하지 않는다.
- **다음 안전 작업:** BP-T01~BP-T06을 failing Godot tests로 먼저 작성하고, common card grid → move-only intent → sequential reveal/impact → capture 순으로 UI adapter를 교체한다. 새 image는 이 과정에서 실제 uncovered consumer가 확인될 때만 별도 candidate로 만든다.
