# 십보강호 활성 컨텍스트

## 현재 기준

```yaml
project: 십보강호: 숨은 수의 비무
repository: alsdmlals4-eng/Ten-Paces-Hidden-Moves
project_main: c5771ddae40f58d88824d9319fc4ef6cd1053bba
primary_platform: PC
future_platform: MOBILE_CONSIDERATION_ONLY
engine: Godot 4.7
product_stage: VERTICAL_SLICE_APP_FLOW_PLANNING
work_mode: REVIEW
current_integration_pr: 65
latest_operating_pr: 68
runtime_implementation: ACTION_SELECTION_DOCK_IMPLEMENTED_PR65
implemented_decision: TEN-DEC-20260801-MARTIAL-TECHNIQUE-UX-01
planning_decision: TEN-DEC-20260801-SITUATION-SCREEN-01
platform_decision: TEN-DEC-20260802-PLATFORM-SCOPE-01
automated_validation: PASS
human_validation: NOT_RUN
next_package: VERTICAL_SLICE_APP_FLOW_SHELL
base_release_pinned: 9.4.0
base_v9_4_adoption: APPLIED_OPERATING_CONTRACT_ONLY
```

## 프로젝트 코어

> 상대의 다음 행동 단서를 모아 가설을 세우고 여러 수의 계획으로 의도를 무너뜨리는 무협 전술 로그라이트.

- 전투 규칙 정본: `docs/02_COMBAT_RULES.md`.
- 1대1 10칸 일자형 전장, 플레이어 4번·상대 7번 시작, 거리 0 `[밀착]`.
- 한 라운드는 `3수 → 3수 → 4수`이며 각 묶음 뒤 해결한다.
- `[합]`·방어도·회피·중단·강건과 결정적 복기를 사용한다.
- 상대 AI는 공개 상태와 해결 이력만 사용하며 플레이어의 미확정 계획을 읽지 않는다.
- 덱·손패·드로우·장착 기술 제한이 없다.
- 성장은 판단을 대체하지 않고 파훼 선택지를 확장한다.

## 플랫폼 범위

Decision: `TEN-DEC-20260802-PLATFORM-SCOPE-01`.

- 현재 기획·구현·검증·배포 기준은 `PC`다.
- 모바일은 `CONSIDERATION_ONLY`이며 현재 포팅·출시·스토어·터치 UX 권한이 없다.
- 모바일 재검토는 App Flow Shell, Windows 실제 실행, 저장·성능, STEP 14 사람 검증, 대표 콘텐츠 제작성 확인 뒤 별도 Decision으로 진행한다.
- 미래 모바일 가능성을 이유로 현재 전투 코어·3/3/4·정보 구조·콘텐츠 범위를 선행 변경하지 않는다.

정본:

- `docs/decisions/2026-08-02_PLATFORM_SCOPE_DECISION.md`
- `docs/planning-data/approved_20260802_platform_scope_contract.json`

## 구현 완료 — ActionSelectionDock

- 출처: `[기초] [무공] [절초]`.
- 무공서는 직접 배치하지 않고 현재 해금 기술을 배치한다.
- 가장 앞 유효 연속 수에 자동 배치한다.
- 2수·3수는 `[전조] → [실행]` 연결 블록이다.
- 진행 전 이동·제거를 지원한다.
- 절초기세 5를 예약하고 진행 전 환불·재예약한다.
- 마우스 Drop 누락은 RED 회귀 뒤 수정했다.
- 구현 검증 HEAD `673c209017ffe3e1c7ef2a89849ca4ea0846d1c5`: PR Validation #993, Base v9 #106, Full Validation #73 `PASS`.
- Windows 실제 Godot·실물 게임패드·사람 이해도는 `NOT_RUN`이다.

정본:

- `docs/decisions/2026-08-01_MARTIAL_MANUAL_TECHNIQUE_TIMELINE_UX_DECISION.md`
- `docs/implementation/2026-08-01_ACTION_SELECTION_DOCK_CLOSEOUT.md`
- `docs/planning-data/approved_20260801_martial_technique_timeline_ux_contract.json`

## 승인된 화면 구조

- 필수 화면: 메인 / 비무 / 무공 구성·자원 / 결과·복기·보상.
- P0: Main, Run Setup, Route, Node, Briefing, Combat Plan, Resolve, Review, Victory Reward, Defeat Retry.
- Route와 Combat은 별도 Scene.
- Combat Review는 Combat Overlay.
- Duel Result는 별도 Scene.
- P0 Autoload 후보는 `RunSession`, `SaveService`.
- `CombatState`는 Combat Scene 소유.
- 전체 제품 흐름 런타임은 아직 시작하지 않았다.

정본:

- `docs/decisions/2026-08-01_SITUATION_SCREEN_ARCHITECTURE_DECISION.md`
- `docs/planning-data/approved_20260801_situation_screen_contract.json`

## 회차 계약

```yaml
demo:
  major_duel_slots: 5
  candidates_per_slot: 3
  nodes_per_gap: 2
  intermediate_nodes: 8
  target_playtime: 15_to_22_minutes
full_run:
  major_duel_slots: 10
  candidates_per_slot: 3
  nodes_per_gap: 2
  intermediate_nodes: 18
  target_playtime: 30_to_40_minutes
```

첫 비무는 후보 3명 중 1명을 seed로 선정하고 이후는 후보 3명 중 2명을 제시한다. 후보 15명 계약은 유지하되 첫 제품 흐름은 슬롯별 대표 후보로 파이프라인을 증명한다.

## 현재 다음 작업

`VERTICAL_SLICE_APP_FLOW_SHELL`

```text
App Root
→ Main
→ 시작 무공 6중4
→ Route·Node·Briefing
→ 기존 Combat
→ Result·Reward·Retry
```

1. 승인된 화면 구조를 실제 파일·Scene·상태 계약에 맞춘 Codex 구현 Packet으로 정밀화한다.
2. 저충실도 흐름과 저장·전환·중복 commit 회귀를 별도 Branch/PR에서 구현한다.
3. 자동·Godot headless 검증 뒤 Windows·해상도·입력·접근성·성능·사람 검증을 수행한다.
4. 검증된 파이프라인으로 두 번째 후보·노드를 반복 제작한 뒤 후보 풀을 확장한다.

## 적대적 감사

- `docs/reviews/2026-08-01_BASE_PROJECT_SHEET_ADVERSARIAL_AUDIT.md`.
- `docs/reviews/2026-08-02_BASE_PROJECT_SHEET_TOTAL_PLANNING_AUDIT.md`.
- ActionSelectionDock 정본·Sheet 누락과 포인터 Drop 누락을 수정했다.
- PR #45·PLAN·Base v8 중심 시작 문서를 현재 기준으로 교체했다.
- Base v9.4 운영 계약은 제품 경로를 수정하지 않는 별도 adapter migration으로 적용했다.
- 2026-08-02 감사에서 GitHub·Sheet의 v9.1·CONCEPT_APPROVAL·PR #65 OPEN 잔존을 현재 상태와 분리했다.

## 역사·호환

- v6 역사 인덱스: `docs/decisions/2026-07-28_V6_DECISION_AUTHORITY_LEDGER.md`.
- PR #7과 Issue #13은 T0 `STEP 0~13` 구현 계보다.
- PR #65는 ActionSelectionDock과 화면 구조 승인 통합 이력이다.
- PR #68은 Base v9.4 운영 계약 적용 이력이다.
- 과거 상태 `CORE_REVIEW_PENDING`은 현재 권한이 아닌 역사 토큰이다.
- 과거 Base SHA `c987647d01ad2baa028a16e03d85ddfc1572a727`은 `HISTORICAL_COMPATIBILITY_BASELINE`이다.
- `docs/planning-data/*.json`은 직접 런타임 입력이 아니다.
- 자동 검증은 `STEP 14` 사람 검증을 대체하지 않는다.

## `[보류]`

- 16권 절초 개별 설계.
- 주요 비무 6~10 런타임.
- 천하제일인·비동기 기능.
- 모바일 포팅·스토어·크로스 세이브.
- 최종 아트·오디오 폴리싱.
