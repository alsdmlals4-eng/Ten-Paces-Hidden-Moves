# Grounded Duel · Automatic Targeting · Observation Disclosure · Execution Report

```yaml
work_item: TEN-GROUNDED-DUEL-AUTO-TARGET-OBSERVE-20260901
work_level: L1
baseline_sha: 4032cf550295da6d55646a8fb64fb27acaf1ddc3
implementation_source_sha: 6cd0e4489cb5adfe1ad49a150f93911cf9379ed5
work_mode: BUILD + REVIEW
skill_id:
  - ten-paces-hidden-moves-workflow-router
  - ten-paces-game-design
  - combat-ux-and-accessibility
  - combat-implementation-handoff
  - ten-paces-verification
  - superpowers:test-driven-development
  - superpowers:verification-before-completion
skill_mode: implementation + runtime verification + adversarial review
selection: user-directed continuation
current_source_relevance_check: REUSED_BOUNDED_CONTINUATION
benchmark_packet: docs/reviews/2026-08-30_TEN_PACES_BENCHMARK_REVERSE_ENGINEERING.md
feasibility: FEASIBLE
status: MACHINE_VERIFIED_PENDING_GITHUB_PR
```

## 작업 전 문제

| 현재 상태 | 요청 이유 | 기대효과 |
|---|---|---|
| 인물 발밑에 큰 원형 그림자가 있어 공중에 떠 보였다. | 전경 석재 바닥과 캐릭터의 접점이 서로 다르게 읽혔다. | 같은 바닥선과 납작한 접지 그림자로 서 있는 감각을 만든다. |
| 공격·무공·절초가 의미 카드로 노림/방향을 다시 물었다. | 이동과 공격의 입력 부담이 같은 수준이라 계획 속도가 느려졌다. | 이동만 판단 입력으로 남기고 공격은 바로 배치한다. |
| 연결 행동 블록이 작은 타이밍 셀 밖으로 흘렀다. | 3/3/4 슬롯 수와 연결 행동의 점유 경계가 흐려졌다. | 카드형 연결 블록을 유지하면서 셀 안에서 읽는다. |
| 실행 control이 설명문까지 포함한 큰 패널이었다. | 전투판 오른쪽 log와 충돌하고 정보 위계를 차지했다. | 현재 묶음 수만 보여 주는 짧은 primary CTA가 된다. |
| 관찰점이 있어도 수동 버튼을 다시 눌러야 했다. | 관찰 행동의 즉각적 보상이 약하고 놓치기 쉽다. | 적 묶음 lock 직후 종류만 자동 공개해 다음 판단에 바로 쓴다. |

## 조사·비교 결과

`CURRENT_SOURCE_RELEVANCE_CHECK: REUSED_BOUNDED_CONTINUATION`으로 2026-08-31에 freshness를 재확인한 12개 게임 benchmark packet을 재사용했다. 같은 ActionSelectionDock/CombatBoardPreview의 카드 선택·타이밍·공개 정보 차원이라 다시 검색하지 않았다.

- **ADAPT:** `YOMI 2`의 행동 종류 식별성, `Into the Breach`의 제한된 읽을 수 있는 의도.
- **AVOID:** 덱·손패·드로우, 적의 정확한 전체 계획 공개, 실시간 반응 조작, 다른 게임 UI/고유 명칭 복사.
- **판정:** 이 변경은 10칸 논리 전장, 공개 거리 2, 3/3/4, 합, 비용, 저장 키, AI의 공개 정보 경계를 바꾸지 않으므로 `FEASIBLE`이다.

## 채택한 구조와 이유

1. `BattleBackground`가 승인된 전경 석재 밴드의 floor ratio를 소유하고, 양 전투원과 접지 그림자가 그 하나의 참조를 공유한다.
2. `move_intent`만 플레이어가 선택한다. 다른 카드 출처의 모든 비이동 행동은 `targeting_mode: none`, 방향 `0`으로 놓고 resolver가 공개된 상대 기준의 내부 방향만 계산한다.
3. 연결 행동 블록은 slot bounds로 배치하고 clip한다. 따라서 2수/3수의 카드형 연결 표현은 유지하면서 행 높이를 침범하지 않는다.
4. CTA는 현재 묶음 길이에서 `3수 실행` 또는 `4수 실행`을 직접 만든다. tooltip/accessibility는 현재 행동계획 실행의 완전한 의미를 유지한다.
5. 관찰은 적 묶음 lock 뒤 현재 보유 관찰점만큼 front-to-back으로 `ACTUAL_ACTION_TYPES`를 공개한다. 이름·ID·비용·사거리·대상·방향·피해·AI 가중치·미래 묶음은 payload와 화면에서 제외한다.

## 실제 구현 또는 준비 결과

- 새 현재 Decision: `TEN-DEC-20260901-GROUNDED-DUEL-AUTO-TARGET-OBSERVE-01`.
- `ActionViewModelAdapter`, 무공/절초 JSON, AI display contract, Ten-Manual normalization을 자동 대상으로 동기화했다.
- `ActionTimingPanel`은 이동만 미완료 intent로 남기고, `ActionPlacementController`의 안내도 이동의 접근/후퇴로 한정했다.
- `ActionTimingPanelAuto`의 linked-block bounds와 scene clip을 고쳤다.
- `CombatProgressButton`은 88×64 minimum, 실제 최대 104×68의 한 줄 CTA로 축소했고 collapsed combat log 폭을 먼저 예약해 겹침을 제거했다.
- `CombatBoardPreview`는 수동 `ObservationRevealButton`을 생성하지 않고, `관찰 공개 · 상대 [이동→공격] / [공격]` status/log를 자동 갱신한다.
- GDD/UI spec/current visual gate/test checklist를 새 입력·CTA·카드 삽화 현재 상태에 맞췄다.

## 사용 예

```text
보법 카드 선택
  → 접근 1칸 / 후퇴 1칸 중 선택

속공·무공 공격·절초 카드 선택
  → 다음 빈 슬롯에 즉시 배치
  → 방향/노림 UI 없음

다음 적 묶음 잠금 + 관찰점 2
  → 관찰 공개 · 상대 [이동→공격] / [공격]
  → 기술명·사거리·비용·방향·피해는 계속 숨김
```

## 기대효과

- 대치 장면은 같은 돌바닥에 닿아 보여 수묵 인물의 질량감이 생긴다.
- 공격 카드는 한 번의 선택으로 계획에 들어가고, 이동만 공간 판단의 의미 있는 선택으로 남는다.
- `N수 실행`은 슬롯 계획이 완성됐다는 순간만 강조하고, log/상태 패널을 침범하지 않는다.
- 관찰의 정보 보상은 즉시 읽히되, 공정한 정보 경계는 유지된다.

## 검증 증거

### TDD

- RED: attack `aim_intent`, 큰 CTA, 수동 관찰, floor API 부재, linked-block bound 부재를 요구하는 새 회귀가 기존 구현에서 실패했다.
- RED: compact CTA가 collapsed combat log에 가려지는 실제 geometry failure를 발견했다.
- GREEN: slot clipping, log 폭 예약, floor contact, type-only observation, non-move auto targeting을 구현한 뒤 아래 자동 검증이 통과했다.

### 자동·런타임

- `python tools/check_project_operating_system.py` → PASS.
- `python tests/check_action_selection_contract.py` → PASS.
- `python tests/check_combat_board_contract.py` → PASS.
- `python tests/check_canonical_combat_docs.py` → PASS.
- `python -m pytest tests/test_phase2_combat_canon_data.py tests/test_action_card_source_unification_contract.py tests/test_observation_answer_leak_guardrails_contract.py tests/test_runtime_visual_capture_contract.py -q` → PASS.
- Godot 4.7.1 headless: `verify_action_card_source_unification`, `verify_action_view_model_adapter`, `verify_combat_board`, `verify_linked_action_blocks`, `verify_phase2_observation`, `verify_ink_paper_combat_presentation` → PASS.
- Windows-visible exact project scene: HERA direct scene run, diagnostics `0 errors / 0 warnings`.
- Runtime capture `TEN-RVC-20260901-004`: initial grounded duel, compact `3수 실행`, no control/log overlap.
- Runtime capture `TEN-RVC-20260901-005`: 속공이 방향 picker 없이 slot에 즉시 배치된 상태.

각 capture는 `MACHINE_RUNTIME_CAPTURE`다. 사람이 조작 감각이나 미학을 승인했다는 증거는 아니다.

## 다섯 회 전체 적대 검토

| Loop | 공격면 | 결과 |
|---|---|---|
| 1 | 입력 의미 | 이동은 접근/후퇴를 유지하고 비이동 카드는 모두 자동 대상으로 통일했다. |
| 2 | 정보 공정성 | observation payload가 action type 이외의 ID·이름·사거리·방향·대상·피해를 보유하지 않음을 회귀로 확인했다. |
| 3 | 레이아웃 | action block bounds, compact CTA 최대 크기, collapsed log와의 비겹침을 기계 geometry와 capture로 확인했다. |
| 4 | 시각 접지 | 두 foot anchor가 aspect-covered background floor와 같고 flattened shadow가 발 아래에 머무름을 확인했다. |
| 5 | 호환·보존·용량 | 10칸/3·3·4/resolver/save 의미를 유지했고, Godot가 만든 tracked import는 HEAD hash 대조 뒤 되돌렸으며 untracked import/uid는 삭제했다. |

`CLEAN_EXIT`: 관련 제품 변경, current Decision, 테스트, 2개의 최소 대표 runtime capture만 보존한다.

## 자동화·학습 반영

- `get_duel_floor_y`, `get_shadow_contact_y`, linked-block bounds, compact CTA collision, view-model targeting, observation no-leak을 회귀로 고정했다.
- runtime capture registrar가 PNG SHA-256, source commit, scene/state, consumer, diagnostics, evidence ceiling을 기록한다.
- Base 승격 후보는 `NONE_INSUFFICIENT_CROSS_PROJECT_EVIDENCE`: 이번 구조는 이 프로젝트의 전경 이미지 비율·combat UI 배치에 종속적이다. 재사용 가능성은 더 많은 독립 Godot 프로젝트에서 확인된 뒤 별도 Base proposal로 다룬다.

## 미검증·남은 위험

- Human player comparison, accessibility-user, Android actual device, controller/keyboard human usability, release performance, store/release gates는 `NOT_RUN`이다.
- 모니터·해상도별 인물의 미학적 접지 판단은 machine geometry와 1280×800 capture만으로 완결되지 않는다.
- Windows temp 경로의 registrar source-copy 2개는 host safety policy가 외부 삭제를 막아 남아 있다. repository 내 원본/중복 capture와 Godot import/uid 산출물은 삭제했고, temp copies는 제품/저장소 파일이 아니다.
