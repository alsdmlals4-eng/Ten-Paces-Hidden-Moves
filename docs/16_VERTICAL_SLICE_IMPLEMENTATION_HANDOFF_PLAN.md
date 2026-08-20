# 십보강호 첫 Vertical Slice 구현 인수인계 계획

> 상태: `HANDOFF_READY_NOT_IMPLEMENTATION_AUTHORIZATION`  
> 기획 완료 Decision: `TEN-DEC-20260820-VERTICAL-SLICE-PLANNING-COMPLETE-01`  
> 구현 시작 조건: 사용자 별도 구현 요청 + fresh GitHub/Notion/Entry Gate 재검증  
> 제품 구현 권한: `false`

## 목표

현재 전투 POC를 폐기하거나 다시 만드는 대신, 이미 구현된 전투 코어를 **첫 5전 강호 비무행의 end-to-end Vertical Slice shell** 안에 연결한다.

완료 경험:

```text
Main
→ 새 비무행 / 이어하기
→ 시작 무공 6중4 + 시작 설정
→ 짧은 도입
→ Duel Briefing
→ 기존 3/3/4 Combat
→ Combat Review Overlay
→ Duel Result + Reward
→ Growth/Recovery Route
→ Information/Preparation Route
→ 다음 Duel
→ 5전 완주 요약
→ Main / 기록
```

## 구현 보호선

- `10칸 / 3→3→4 / 거리 / 합 / 대응 / 중단 / 복기`를 재작성하지 않는다.
- 적 AI는 미확정 플레이어 계획·hover/focus·미공개 입력을 읽지 않는다.
- `[관찰]`은 플레이어 전용을 유지한다.
- 기존 10권 무공을 재사용하고 11번째 무공을 구현 범위에 추가하지 않는다.
- Combat Review는 Overlay, Duel Result는 별도 Scene이다.
- 주요 비무 사이 Route는 정확히 2노드다.
- 이미지·최종 아트·오디오 생성은 별도 승인 전 구현 범위에 넣지 않는다.
- Android 실기기 완료나 Human PASS를 자동화 결과로 대체하지 않는다.

## 현재 코드 기반

현재 `project.godot`의 main scene은 `res://scenes/combat/combat_board_preview.tscn`이고 Godot 4.7을 사용한다. 기존 전투 화면은 `src/combat/combat_board_preview.gd`가 `data/combat/combat_board_poc.json`을 읽고 HUD, 3/3/4 timing, 카드 tray, opponent hypothesis, combat review 등을 조립한다.

핵심 재사용 경계:

- `scenes/combat/combat_board_preview.tscn`
- `src/combat/combat_board_preview.gd`
- `src/combat/combat_ai_planner.gd`
- `src/combat/combat_resolution_engine_ten_manuals.gd`
- `src/ui/action_selection/action_selection_dock.gd`
- `src/ui/action_selection/action_view_model_adapter.gd`
- `scenes/ui/combat_review_panel.tscn`
- `data/combat/combat_board_poc.json`
- `tests/check_action_selection_contract.py`
- `tests/check_combat_board_contract.py`
- `tests/check_rival_tendency_contract.py`
- `tests/gut/test_martial_manual_registry.gd`
- `src/validation/ten_manual_product_scenario_validator.gd`

## 구현 원칙

새 기능은 **run/app-flow 계층**에 추가하고 combat 내부의 판정 책임을 침범하지 않는다.

권장 새 경계:

```text
src/run/
  run_state.gd
  run_flow_controller.gd
  opponent_catalog.gd
  route_resolver.gd
  reward_resolver.gd

src/ui/run/
  main_menu.gd
  starting_loadout.gd
  duel_briefing.gd
  duel_result.gd
  route_node.gd
  run_completion.gd

scenes/run/
  main_menu.tscn
  starting_loadout.tscn
  duel_briefing.tscn
  duel_result.tscn
  route_node.tscn
  run_completion.tscn

data/run/
  vertical_slice_opponents.json
  vertical_slice_route_nodes.json
  vertical_slice_flow.json
```

실제 구현 시 기존 repo naming pattern과 현재 코드 의존성을 다시 읽고, 더 작은 기존 경계가 있으면 그쪽을 우선한다. 위 경로는 handoff 기준이며 맹목적으로 강제하지 않는다.

---

# Task 0 · Fresh implementation gate

**변경 파일:** 없음.

1. `main`, 열린 PR, exact Project Notion을 다시 읽는다.
2. `AGENTS.md`, `ACTIVE_CONTEXT.md`, current entry/operating gate를 다시 읽는다.
3. 사용자 변경·다른 진행 중 PR과 겹치는 경로를 확인한다.
4. 제품 구현이 여전히 blocked이면 중단하고 상태만 보고한다.
5. 구현이 승인되었을 때만 다음 Task로 간다.

**완료 증거:** fresh SHA, open PR 목록, 적용 Decision ID, 허용된 mutation 범위를 작업 로그에 남긴다.

---

# Task 1 · RunState와 결정론적 회차 상태

**신규 후보:**
- `src/run/run_state.gd`
- `tests/gut/test_run_state.gd`

**테스트 먼저:**
- 새 회차가 seed, duel slot=1, 선택 무공 4개, 현재 자원, 완료 상대, Route 기록을 보유한다.
- `6중4`가 아니면 생성 실패.
- Duel Result 시 다음 슬롯 상대가 Route 전에 한 번만 잠긴다.
- 동일 restart snapshot은 동일 seed/상대/전투 직전 상태를 복원한다.

**구현:** 전투 판정 데이터를 복제하지 않고 run-level 상태만 소유한다.

**검증:** GUT 실패→최소 구현→PASS 순서 증거를 남긴다.

---

# Task 2 · 15명 후보 카탈로그와 합법 loadout

**신규 후보:**
- `data/run/vertical_slice_opponents.json`
- `src/run/opponent_catalog.gd`
- `tests/check_vertical_slice_opponent_contract.py`

**기준:** `docs/13`, `docs/14`, `docs/15`.

**테스트 먼저:**
- 정확히 5 slot × 3 candidate.
- 후보마다 readable habit, counterexample, briefing hook, personality hook 존재.
- 모든 기술/무공은 현행 10권 또는 승인 기초 행동에만 존재.
- Slot 성급 Seed `3/7/7/7/9` 준수.
- 비연은 4성 및 적 `[관찰]` 미활성.
- 최종 스탯 총량 Seed `20/22/24/26/28`의 중복 가산 금지.

**구현:** `CombatAiPlanner`에 새 숨은 정보 통로를 추가하지 말고 후보의 공개 loadout/정성 tendency만 어댑트한다.

---

# Task 3 · Main + 새 비무행 + 6중4 Setup

**신규 후보:**
- `scenes/run/main_menu.tscn`
- `src/ui/run/main_menu.gd`
- `scenes/run/starting_loadout.tscn`
- `src/ui/run/starting_loadout.gd`
- `tests/check_vertical_slice_setup_contract.py`

**수정 후보:**
- `project.godot` main scene은 Task 검증 후 새 shell로 전환.

**테스트 먼저:**
- 새 비무행 / 이어하기가 구분됨.
- 시작 무공은 정확히 6개 중 4개.
- 시작 스탯/무공 성장 계약을 기존 source에서 재사용.
- 잘못된 3개/5개 선택으로 진행 불가.
- keyboard/gamepad focus path 존재.

**금지:** Setup에서 새 성장 공식이나 신규 무공을 정의하지 않는다.

---

# Task 4 · Duel Briefing

**신규 후보:**
- `scenes/run/duel_briefing.tscn`
- `src/ui/run/duel_briefing.gd`
- `tests/check_duel_briefing_contract.py`

**표시:** 상대 이름/이명, 공개 전투 인상, 공개 스탯, 공개된 무공/기술 범위, Route에서 획득한 정보, 플레이어 현재 상태.

**숨김 테스트:** 현재/미래 잠금 계획, AI 가중치, 정답 대응, 랜덤 seed, 미공개 trigger가 UI model에 들어오지 않는다.

**시간 계측:** 최초 회차 평균 12~18초 목표를 측정할 instrumentation point만 추가하고 PASS는 Human 측정 전 주장하지 않는다.

---

# Task 5 · 기존 Combat을 Run shell에 연결

**수정 후보:**
- `src/combat/combat_board_preview.gd`
- `scenes/combat/combat_board_preview.tscn`
- `data/combat/combat_board_poc.json` 또는 별도 adapter data
- 필요 시 `src/combat/combat_ai_planner.gd`

**테스트 먼저:**
- RunState에서 확정한 candidate/loadout을 Combat에 주입 가능.
- 기존 standalone POC 진입은 회귀 테스트용으로 유지하거나 명시적 test fixture로 격리.
- 플레이어 plan lock 이전 정보가 AI에 전달되지 않음.
- Combat 종료 후 immutable result/review packet을 run flow로 반환.

**중요:** `CombatBoardPreview`가 App 전체 상태까지 떠맡지 않도록 run controller가 소유권을 갖는다.

**회귀:** `tests/check_combat_board_contract.py`, action-selection 계약, existing product scenario validation을 모두 다시 실행한다.

---

# Task 6 · Combat Review Overlay → Duel Result Scene

**재사용:**
- `scenes/ui/combat_review_panel.tscn`
- 기존 review summary builder

**신규 후보:**
- `scenes/run/duel_result.tscn`
- `src/ui/run/duel_result.gd`
- `tests/check_vertical_slice_review_result_contract.py`

**테스트 먼저:**
- Review는 실제 발생 사건 1~3개의 원인만 설명.
- Review는 다음 정답 행동을 추천하지 않음.
- Result는 승패·등급·보상만 소유.
- Review Overlay와 Result Scene이 합쳐지지 않음.
- Duel 1~4는 다음 후보 선잠금 후 Route로, Duel 5는 completion으로 이동.

---

# Task 7 · Route 8노드와 성장/회복/정보 경계

**신규 후보:**
- `data/run/vertical_slice_route_nodes.json`
- `src/run/route_resolver.gd`
- `scenes/run/route_node.tscn`
- `src/ui/run/route_node.gd`
- `tests/check_vertical_slice_route_contract.py`

**테스트 먼저:**
- Duel 사이 정확히 Growth/Recovery 1 + Information/Preparation 1.
- 전체 8노드.
- 집중 성장 총합 최소 +6.
- 자유 성장 총합 최소 +14.
- 회복 Seed는 `max HP 25% + 기력1 + 내력1`, cap 초과 금지.
- 회복 선택에 성장 포인트를 몰래 지급하지 않음.
- 정보 선택에 성장/회복 수치를 몰래 지급하지 않음.
- Information Route 전에 next candidate가 이미 고정됨.
- 정보 선택으로 candidate reroll 불가.

**주의:** 회복 Seed는 reversible이므로 balance simulation 결과 없이 final 상수로 승격하지 않는다.

---

# Task 8 · Reward와 38점 경로

**신규 후보:**
- `src/run/reward_resolver.gd`
- `tests/check_vertical_slice_growth_path_contract.py`

**테스트:**
- 집중 보상 4회 32 + Route 6 = 38.
- 자유 보상 4회 24 + Route 14 = 38.
- 특정 무공 하나를 강제하지 않음.
- 10성 도달 가능성과 스탯 요구 충족 보장은 구분됨.

---

# Task 9 · 5전 완주와 기록

**신규 후보:**
- `scenes/run/run_completion.tscn`
- `src/ui/run/run_completion.gd`
- `tests/check_vertical_slice_completion_contract.py`

**표시:** 5전 결과, 주요 선택, 성장한 무공, 기억할 복기/전투 패턴의 요약.

**금지:** 아직 승인되지 않은 천하제일인/비무6~10을 자동 연결하지 않는다.

---

# Task 10 · 정적 + 시뮬레이션 검증

**신규 후보:**
- `src/validation/vertical_slice_scenario_validator.gd`
- `tests/test_vertical_slice_scenario_contract.py`

**재사용:** `src/validation/ten_manual_product_scenario_validator.gd`의 가능한 구조만 재사용한다.

최소 matrix:

```text
15 candidates × 6 player archetypes × deterministic seed set
```

기록:
- 승률
- 평균 라운드
- 체력 손실
- 합 승/패
- 사거리 실패
- 중단
- 회피 성공
- 자원 부족으로 계획 불가
- Route 선택 전후 차이

경고선은 `docs/15_VERTICAL_SLICE_REVIEW_READY_CONTRACT.md`를 따른다. 경고는 자동 밸런스 수정 명령이 아니다.

---

# Task 11 · End-to-end 자동 검증

**검증 후보:**
- Python contract tests
- GUT
- 기존 documentation governance
- existing ten-manual product validation
- Godot headless launch/export가 현재 entry gate에서 허용되는 범위

필수 E2E fixture:

```text
New Run → choose 4 → Duel1 → Review → Result → Route×2
→ Duel2 → ... → Duel5 → completion
```

두 번째 fixture는 동일 pre-combat snapshot에서 restart 결과가 결정론적으로 재현되는지 확인한다.

`PASS`는 실제 실행한 항목에만 기록한다.

---

# Task 12 · release-near UX/visual 연결 후 Human 검증

이 단계는 placeholder system-only PoC로 재미 PASS를 선언하지 않는다.

사용자가 별도로 이미지/시각 제작을 요청하고 승인한 뒤:
- 실제 사용 후보 UI/UX
- 무협 캐릭터/전장 이미지
- 애니메이션/연출
- 음악/SFX
- VFX/피드백

을 대표 Vertical Slice에 연결하고 Human 측정한다.

측정:
- 첫인상
- 상대 습관을 읽을 수 있는가
- 3/3/4 계획의 고민이 재미있는가
- Review가 이해를 돕되 정답을 말하지 않는가
- 15~22분 전체 시간과 비전투 5:25~8:10 목표
- 8:30 초과 시 비전투 UX 재검토

Android 실기기 검증은 별도 플랫폼 Gate에 따라 진행한다.

---

## 구현 완료 기준

다음이 모두 있어야 첫 Vertical Slice 구현 완료 후보로 본다.

1. Main부터 5전 완주까지 끊기지 않는 E2E 흐름.
2. 15명 중 슬롯별 후보 선택/잠금/briefing/loadout 작동.
3. Route 8노드와 성장/회복/정보 경계 작동.
4. 기존 3/3/4 combat 회귀 없음.
5. AI 비공개 정보 누출 테스트 PASS.
6. 정적 loadout/resource/build-diversity Gate PASS.
7. 승인된 범위의 자동 scenario matrix 실제 실행 증거.
8. Windows 검증은 실제 실행한 ceiling까지만 PASS.
9. Human/Android는 실제 실행 전 `NOT_RUN` 유지.
10. Notion/GitHub 정본 재동기화.

## 롤백

- 각 Task는 독립 PR 또는 작게 검토 가능한 commit 단위로 유지한다.
- Run shell이 기존 combat을 깨면 main scene 전환을 롤백해 기존 `combat_board_preview.tscn` 진입점을 복구한다.
- 새 data contract가 문제면 기존 combat JSON/10권 카탈로그를 수정하지 말고 run adapter data만 롤백한다.
- 사용자 변경이나 다른 진행 중 PR을 덮어쓰지 않는다.

## 구현 시작 시 첫 명령

구현자는 이 문서를 곧바로 코딩 명령으로 보지 않는다. 먼저 fresh truth를 읽고 `Task 0` Gate를 통과한 뒤, `Task 1`부터 TDD로 진행한다.
