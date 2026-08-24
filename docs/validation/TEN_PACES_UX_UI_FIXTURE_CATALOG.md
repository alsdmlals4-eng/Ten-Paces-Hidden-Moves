# 십보강호 UX/UI 검증 Fixture Catalog

> Issue owner: `#54` — `UX-VALIDATION-001`  
> 상태: `READY_FOR_HUMAN_DEVICE_EXECUTION`  
> 목적: 이미 구현된 첫 5전 Vertical Slice를 실제 사람·Windows·입력 장치에서 검증하기 위한 재현 가능한 상황 목록  
> 제품 변경 권한: `false`

이 문서는 새 전투 규칙이나 밸런스를 정의하지 않는다. 각 Fixture는 **현재 `main`의 실제 카드·거리·자원·상대 상태를 사용해 아래 의미 조건을 재현**한다. 수치·카드 ID를 이 문서에 복제해 고정하지 않는다.

## 공통 실행 흐름

모든 전투 Fixture는 현재 승인 코어인 다음 흐름을 보존한다.

```text
3수 → 해결 → 3수 → 해결 → 4수 → 해결
```

검증자는 각 상황에서 다음을 구분해 기록한다.

- 화면에서 보이는 사실.
- 플레이어가 선택한 계획.
- 실행 전에 이해한 위험.
- 실제 해결 결과.
- 플레이어가 설명한 원인.
- PASS / FAIL / BLOCKED / NOT_RUN.

자동 테스트로 상태·계산이 맞다는 것과 사람이 실제 화면에서 이해한다는 것은 별도 증거다.

## Fixture Index

| ID | Fixture | 재현 목표 | 핵심 관찰 |
|---|---|---|---|
| UX54-F00 | `VALID_SELECTION` | 현재 거리·자원·남은 슬롯에서 합법 행동을 선택·배치 | 비용·거리·대상·슬롯·확정 상태를 실행 전에 이해 |
| UX54-F01 | `RANGE_INSUFFICIENT` | 현재 거리에서 닿지 않는 실제 기술을 선택 | 무반응이 아니라 거리 부족 원인과 수정 행동이 보임 |
| UX54-F02 | `RESOURCE_INSUFFICIENT` | 기력/내력 중 하나가 부족한 실제 기술을 선택 | 부족 자원 종류와 필요한 수정이 보임 |
| UX54-F03 | `INVALID_TARGET` | 현재 상태에서 유효하지 않은 대상/방향을 시도 | 대상 또는 방향 실패 이유가 명확함 |
| UX54-F04 | `SLOT_COLLISION` | 남은 수보다 긴 다중 수 행동을 배치 시도 | 3/3/4 슬롯 점유와 충돌 원인이 설명됨 |
| UX54-F05 | `PLAN_ORDER_CHANGES_RESULT` | 같은 행동 묶음을 다른 순서로 배치 | 순서 변경이 합·중단·거리 결과를 바꾸는 이유를 설명 가능 |
| UX54-F06 | `CLASH_CAUSAL_CHAIN` | 실제 `[합]`이 발생하는 계획을 실행 | 합→방어/회피→피해→중단/강건의 인과를 복기 가능 |
| UX54-F07 | `LONG_KOREAN_TEXT` | 긴 한국어 효과·큰 값·자기 대상/사거리 없음 표현 | 핵심 비용·거리·효과·행동 버튼이 잘리지 않음 |
| UX54-F08 | `CONFIRMED_VS_UNCERTAIN_INTENT` | 공개된 단서와 아직 모르는 상대 계획이 공존 | 확정 사실과 추론/불확실성을 혼동하지 않음 |
| UX54-F09 | `SHARED_PLAYER_AI_MARTIAL_POOL` | 상대가 문파 무공서 기술을 사용하는 전투 | AI 전용 무공 없이 플레이어도 같은 무공서 조건에서 같은 기술을 쓸 수 있음을 확인 |

## UX54-F00 · VALID_SELECTION

### Setup

- 현재 `main`의 첫 5전 Vertical Slice 중 하나를 사용한다.
- 현재 묶음에서 실제로 합법인 무공/기초 행동을 하나 이상 확보한다.
- 테스트용 임의 수치를 주입하지 않는다.

### Actions

1. 현재 거리, 기력/내력, 3/3/4 중 현재 묶음의 남은 수를 확인한다.
2. 카드/행동을 포커스한다.
3. 선택한다.
4. 필요한 대상/방향을 지정한다.
5. 계획판에 배치한다.
6. 확정 전 취소 또는 교체한다.
7. 다시 배치하고 확정한다.

### PASS 관찰

- `focused`와 `selected`가 시각/상태상 구분된다.
- 비용·거리·대상·슬롯 점유를 실행 전 설명할 수 있다.
- 확정 전 취소/교체가 가능하고 의미 있는 이전 위치로 돌아간다.
- 확정 뒤에는 잠긴 계획이 임의로 바뀌지 않는다.

## UX54-F01 · RANGE_INSUFFICIENT

현재 거리에서 사용할 수 없는 실제 공격/기술을 고른다.

PASS:
- 선택 자체를 조용히 무시하지 않는다.
- `거리 부족`에 해당하는 원인이 텍스트/상태로 드러난다.
- 플레이어가 이동·다른 기술 선택 등 가능한 다음 행동을 추론할 수 있다.
- AI가 이 상황을 이유로 플레이어의 숨은 계획을 읽지 않는다.

## UX54-F02 · RESOURCE_INSUFFICIENT

현재 기력 또는 내력으로 지불할 수 없는 실제 행동을 선택한다.

PASS:
- 부족한 자원 종류가 구분된다.
- 필요한 비용과 현재 보유량을 비교할 수 있다.
- 불가능한 행동을 눌렀을 때 아무 설명 없이 입력이 사라지지 않는다.
- UI가 별도 밸런스 계산을 만들어내지 않고 runtime 상태를 표현한다.

## UX54-F03 · INVALID_TARGET

유효 대상/방향 조건을 만족하지 않는 입력을 시도한다.

PASS:
- `INVALID_TARGET` 또는 동등한 의미의 실패 이유가 이해 가능하다.
- 잘못된 대상 때문에 비용이 임의 소모되거나 계획이 확정되지 않는다.
- 수정 후 원래 계획 흐름으로 복귀할 수 있다.

## UX54-F04 · SLOT_COLLISION

현재 묶음의 남은 수보다 더 긴 다중 수 행동을 배치한다.

PASS:
- `SLOT_COLLISION`이 어떤 슬롯과 충돌하는지 이해할 수 있다.
- `[전조] → [실행]` 연결이 하나의 행동임을 알 수 있다.
- 3수/3수/4수 묶음 경계 밖으로 행동이 조용히 넘치지 않는다.

## UX54-F05 · PLAN_ORDER_CHANGES_RESULT

같은 행동 조합을 유지한 채 순서만 바꾼 두 계획을 비교한다.

PASS:
- 플레이어가 **왜 순서가 결과를 바꿨는지** 거리·전조·합·중단 중 실제 원인으로 설명한다.
- UI는 실행 전에 확정된 사실과 불확실한 결과를 구분한다.
- 결과 복기에서 실제 해결 순서가 계획 순서와 연결된다.

## UX54-F06 · CLASH_CAUSAL_CHAIN

실제로 양측 공격이 같은 수에서 충돌하는 상황을 만든다.

관찰 순서:

```text
공격 시작
→ 현재 피해 단위 [합]
→ 합 승패
→ 사거리/방향
→ 회피
→ 방어
→ 체력 피해
→ 중단/강건
→ 잔여 피해 단위 또는 다음 행동
```

PASS:
- 플레이어가 `[합]`의 승패와 최종 체력 피해를 같은 개념으로 오해하지 않는다.
- 방어·회피·중단/강건 중 실제로 작동한 원인을 찾을 수 있다.
- 복기 후 “다음에는 무엇을 바꾸겠다”를 한 문장 이상 말할 수 있다.

## UX54-F07 · LONG_KOREAN_TEXT

실제 카드 중 상대적으로 긴 한국어 기술 설명과 큰 수치가 노출되는 상태를 사용한다.

PASS:
- 카드명/문파/비용/거리/핵심 효과가 겹치거나 잘리지 않는다.
- 상세 정보가 길어도 핵심 행동 버튼을 영구적으로 밀어내지 않는다.
- 이미지가 없거나 대체 표현을 사용하는 상태에서도 핵심 의미가 사라지지 않는다.
- 색만으로 유효/무효/위험을 구분하지 않는다.

## UX54-F08 · CONFIRMED_VS_UNCERTAIN_INTENT

상대의 공개 단서는 일부 있으나 전체 계획은 공개되지 않은 상태를 사용한다.

PASS:
- `CONFIRMED_VS_UNCERTAIN_INTENT` 경계가 명확하다.
- 확정 공개 정보와 플레이어 추론이 서로 다른 표현을 가진다.
- AI 가중치·seed·정답 카운터가 유저에게 노출되지 않는다.
- 플레이어가 틀린 추론을 했더라도 UI가 나중에 그것을 “확정 정보였던 것”처럼 세탁하지 않는다.

## UX54-F09 · SHARED_PLAYER_AI_MARTIAL_POOL

상대가 실제 문파 무공서 기술을 사용하는 비무를 관찰한다.

정본:
- `TEN-DEC-20260824-SHARED-PLAYER-AI-MARTIAL-POOL-01`
- `docs/planning-data/approved_20260824_shared_player_ai_martial_pool_contract.json`

PASS:
- 상대의 무공서/기술이 공용 player-learnable pool에 속한다.
- 동일 무공서·동일 성급/해금 조건에서는 플레이어와 AI가 동일 card ID/effect authority를 사용한다.
- 상대의 개성은 전용 기술이 아니라 무공서 선택·숙련도·기초 행동 조합·행동 성향에서 발생한다.
- 시작 선택지 밖 무공서가 상대에게 등장해도 “그 획득 경로가 이미 구현됐다”고 잘못 주장하지 않는다.

FAIL taxonomy:

```text
BAD_CONTENT_ASYMMETRY
= 플레이어가 배울 수 없는 AI 전용 무공서/무공 기술/무공 효과로 전투 결과가 발생
```

`BAD_CONTENT_ASYMMETRY`는 난이도나 밸런스 이슈가 아니라 correctness defect다.

## Human 세션 공통 기록 필드

각 참가자/세션마다 개인식별정보 없이 다음만 남긴다.

```yaml
session_id:
exact_git_commit:
input_mode:
fixture_ids:
result: PASS|FAIL|BLOCKED|NOT_RUN
cost_range_target_explanation:
focused_selected_cancel_explanation:
clash_causal_explanation:
next_plan_change_explanation:
confusion_note:
most_memorable_moment:
```

Raw 사람 발언은 필요한 최소 범위로만 기록하며 이름·연락처·계정 등 개인정보를 저장하지 않는다.
