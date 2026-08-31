# `[준비]` 강화·`[전조]`·카드 자동 배치 규칙 변경

- 결정일: 2026-07-24
- 상태: `USER_APPROVED / IMPLEMENTED_FULL_ACTIONS_PASS`
- 제품 브랜치: `agent/prepare-momentum-and-auto-placement`
- 제품 PR: #35
- 기준: `agent/repeat-poc-a3-review-ui-closeout`
- 검증 코드 head: `6b1c88759bcd416bbe0ee2bcd8b98697d7fd6417`

## 책임과 우선순위

이 문서는 다음 기존 서술을 명시적으로 대체한다.

- `docs/02_COMBAT_RULES.md` 3.3의 다중 슬롯 앞 점유 수 `[준비]` 표현.
- `docs/02_COMBAT_RULES.md`의 `basic_stance` 표시명 `태세`.
- `docs/02_COMBAT_RULES.md` 8장의 단독 태세 수명 설명.
- 기존 카드 선택 후 행동 슬롯을 다시 선택하는 배치 조작.
- 절초 선택 후 별도 슬롯 클릭으로 예약하는 조작.

내부 호환성을 위해 카드 ID `basic_stance`와 판정 기록 `action_stage = preparation`은 유지한다.

## 1. 사용자 표시 용어

### `[준비]`

- 카드 ID `basic_stance`의 새 표시명이다.
- 카드 자체의 강화 행동을 뜻한다.
- 기존 데이터·AI·fixture와의 호환성을 위해 내부 ID는 바꾸지 않는다.

### `[전조]`

- 2슬롯·3슬롯 행동의 최종 실행 수 이전 점유 수를 뜻한다.
- 내부 `action_stage = preparation`은 유지한다.
- 2슬롯 공격은 첫 수 `[전조]`, 둘째 수 `[공격]`이다.
- 3슬롯 절초는 첫째·둘째 수 `[전조]`, 셋째 수 `[절초]`다.

## 2. `[준비]` 강화 상태

`[준비]`가 실행되면 다음 비이동 행동까지 강화 상태를 보존한다.

- 이동·보법은 준비 상태를 소비하지 않는다.
- 이동 실패·제자리 이동도 이동 행동이므로 준비 상태를 소비하지 않는다.
- 이동·보법을 여러 번 실행해도 다음 비이동 행동 전까지 준비 상태를 유지한다.
- 다음 공격은 기존 공격력 +2와 `[강건]`을 적용하고 준비 상태를 소비한다.
- 다음 명상은 기존 기력·내력 회복에 절초 기세 +1을 더하고 준비 상태를 소비한다.
- 절초 기세는 최대 5를 넘지 않는다.
- 막기·회피·기타 비이동 행동은 처리 뒤 준비 상태를 소비한다.
- 자원 부족·중단 등으로 비이동 행동이 실행되지 않아도 해당 시도에서 준비 상태를 소비한다.
- 새로운 `[준비]`가 실행되면 기존 준비 상태를 새 준비 상태로 교체한다.

## 3. 자동 배치

모든 기초 카드와 절초는 선택 즉시 현재 묶음에서 가장 앞의 유효 연속 빈 구간에 배치한다.

- 1슬롯: 가장 앞의 빈 1수.
- 2슬롯: 가장 앞의 연속 빈 2수.
- 3슬롯: 가장 앞의 연속 빈 3수.
- 묶음 경계를 넘지 않는다.
- 유효 구간이 없으면 배치하지 않으며 비용·기세도 소비하지 않는다.
- 이동·공격 자동 배치 뒤에는 기존 이동 칸·공격 방향 선택으로 즉시 진입한다.
- 점유 슬롯은 `[진행]` 전에 클릭 또는 Enter로 행동 전체를 해제할 수 있다.

## 4. 절초 자동 예약·환불

- 절초는 기세가 정확히 5이고 필요한 연속 빈 구간이 있을 때 선택 즉시 자동 예약한다.
- 예약 성공 뒤 기세 5를 즉시 소비한다.
- `[진행]` 전에는 예약이 차지한 어느 슬롯을 눌러도 예약 전체를 취소한다.
- 예약 취소 시 기세 5를 돌려받는다.
- `committed` 이후 중단·방향 실패·사거리 실패에는 환불하지 않는다.

## 5. 구현 책임

- `src/ui/action_timing_panel_auto.gd`: 가장 앞의 유효 연속 빈 구간 탐색.
- `src/combat/combat_board_preview_auto.gd`: 기초 카드·절초 자동 배치, 예약·취소 흐름, `[전조]` 표시, 시작 칸 재시작 보정.
- `src/combat/combat_resolution_engine_prepare.gd`: 준비 상태 수명, 이동 비소모, 명상 기세 +1, 상태·로그 동기화.
- `data/cards/basic_cards.json`: `basic_stance` 표시명과 설명.
- `data/combat/combat_resolution_preview.json`: `prepare_meditate_momentum = 1`.

## 6. 기술 검증 증거

- Red: PR #35 PR Validation run #659에서 새 계약 step이 예상 실패.
- 제품 정적 Green: PR #35 PR Validation run #681 성공.
- 검증 전용 PR #40 PR Validation run #682 성공.
- Full Validation run #21 성공.
- Ubuntu Python 3.11·3.12 성공.
- Windows Python 3.11·3.12 성공.
- Ubuntu Godot 4.7 import 성공.
- 기존 전투·절초·terminal restart·키보드·레이아웃·AI·A2·A3 verifier 성공.
- `tests/verify_prepare_momentum.gd` 성공.
- `tests/verify_auto_card_placement.gd` 성공.

검증 전용 workflow trigger는 제품 브랜치에 포함하지 않으며 PR #40은 병합 없이 닫는다.

## 7. 증거 경계

```yaml
technical_implementation: IMPLEMENTED_FULL_ACTIONS_PASS
human_step14: DEFERRED_BY_USER
human_validation: UNVERIFIED
subjective_usability: UNVERIFIED
t1_greenlight: NOT_GRANTED
mvp_complete: false
```

자동 검증은 규칙 실행과 입력 계약을 증명하지만 실제 플레이어의 이해·재미·조작 선호를 증명하지 않는다.
