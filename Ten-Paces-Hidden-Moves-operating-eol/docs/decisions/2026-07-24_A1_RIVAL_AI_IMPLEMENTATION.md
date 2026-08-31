# A1 라이벌 복수 후보 AI 구현 기록

> Goal: Issue #16 PR-A1  
> Branch: `agent/repeat-poc-a1-rival-ai`  
> Base: `agent/repeat-poc-a0-contract-alignment@5fd8349ca042565c99e1054c0128a60ce14989f9`  
> 상태: `IMPLEMENTED_PENDING_GODOT_AND_CANONICAL_DOC_SYNC`

## 1. 범위

현행 판정 엔진과 `build_bundle_actions(state, bundle_index, cards_by_id)` 호출 계약을 유지하면서 다음만 추가했다.

- T0 라이벌 프로필 1명.
- 공개 단서 3개.
- 최대 후보 3개와 score window 2.0.
- 공개 상태 snapshot.
- 같은 상태·seed의 결정적 선택.
- 선택 후보·점수·이유 code를 담는 테스트용 trace.
- 비공개 계획·UI 상태의 snapshot·trace 유입 차단 verifier.

추가하지 않은 것:

- 새 행동·절초·판정 공식.
- 플레이어 계획 입력.
- AI score의 플레이어 UI 노출.
- 머신러닝·적응형 학습.
- 신규 플레이어 테스트.

## 2. Red 증거

먼저 `tests/check_rival_tendency_contract.py`를 추가했다.

현재 A0 상태를 모사한 로컬 격리 경로에서 실행했을 때 다음 원인으로 exit 1을 재현했다.

```text
AssertionError: missing rival tendency data: data/combat/combat_rival_tendency_poc.json
exit=1
```

실패 원인은 테스트 오타나 환경 오류가 아니라 A1 데이터 계약 부재였다.

## 3. Green 구현

### 데이터

`data/combat/combat_rival_tendency_poc.json`

```yaml
active_rival_id: rival_t0_midrange_pressure
max_candidates: 3
score_window: 2.0
public_clues:
  - midrange_pressure
  - safe_heavy_prepare
  - low_health_response
```

### Planner

`CombatAiPlanner`는 허용된 공개 값만 새 Dictionary로 복사한다.

```text
round_number, bundle_index, bundle_start, bundle_slots,
player_tile, enemy_tile, distance, player_health,
enemy_health, enemy_health_max, enemy_stamina, enemy_internal,
enemy_momentum, enemy_momentum_max, ai_decision_seed
```

trace 허용 키:

```text
public_snapshot, rival_id, candidate_ids, candidate_scores,
selected_card_id, seed, reason_codes
```

동일 공개 상태와 seed는 같은 후보 집합·선택·trace를 만든다. seed는 `round_number`와 `bundle_index`를 포함한 scoped 값으로 사용한다.

## 4. 후보 정책

| 공개 조건 | 주요 후보 | 공개 이유 code |
|---|---|---|
| 거리 3 이상 | 이동·보법 | `midrange_pressure` |
| 거리 1 | 속공 | `midrange_pressure` |
| 거리 2, 2슬롯·자원 보유 | 강공 | `safe_heavy_prepare` |
| 기세 최대 | 거리·슬롯에 맞는 절초 | `safe_heavy_prepare` 또는 `midrange_pressure` |
| 체력 1/3 이하 | 회피·막기 | `low_health_response` |
| 기력 또는 내력 고갈 | 명상 | `low_health_response` |

근거 없는 전체 행동 무작위 선택은 하지 않는다. 최상위 점수에서 2.0 이내의 합리 후보만 최대 3개 유지하고 seed로 하나를 고른다.

## 5. 로컬 결정 모델 확인

GDScript와 같은 점수·window·seed 수학을 Python으로 독립 재현했다.

```text
initial seeds 0..5:
basic_move, basic_footwork, basic_move, basic_footwork, basic_move, basic_footwork

momentum 5 / distance 3:
ultimate_void_sword_qi

health 10 / distance 1 / seed 0:
basic_guard

internal 0 / distance 3 / seed 0:
basic_meditate
```

이 결과는 기존 seed 0 회귀를 보존하면서 다른 seed에서 최소 두 합리 후보가 존재함을 확인한다. 이는 Godot 실행 증거가 아니라 알고리즘 수학의 독립 모델 확인이다.

## 6. 검증 자산

- `tests/check_rival_tendency_contract.py`
- `tests/verify_ai_rival_tendency.gd`
- `tools/verify_repeat_poc_a1.ps1`
- 비용 최적화 PR 정적 계약 목록.
- 할당량 재개 후 Full Validation Godot 목록.

Godot verifier는 다음을 확인하도록 작성됐다.

- same state/seed 결정론.
- 후보 최대 3개·score window 2.0.
- 다른 seed에서 최소 두 후보 선택.
- reason code와 공개 clue 일치.
- trace·snapshot 허용 키 고정.
- 독성 private/UI 필드 recursive leak 0.
- 기세 5 파공검기 회귀.
- 자원 부족 명상 회귀.

## 7. 미검증 경계

```yaml
actions_quota: UNAVAILABLE_UNTIL_USER_NOTICE
python_contract_on_repository_checkout: NOT_RUN
godot_parse: BLOCKED_BY_ACTIONS_QUOTA_AND_LOCAL_GODOT_UNAVAILABLE
godot_rival_verifier: BLOCKED_BY_ACTIONS_QUOTA_AND_LOCAL_GODOT_UNAVAILABLE
step12_13_regression: BLOCKED_BY_ACTIONS_QUOTA_AND_LOCAL_GODOT_UNAVAILABLE
windows_manual: NOT_RUN
human_step14: DEFERRED_BY_USER
human_validation: UNVERIFIED
```

과거 A0 head의 Actions PASS는 이 A1 변경을 검증하지 않는다.

## 8. 남은 작업

1. `docs/02_COMBAT_RULES.md`의 “성향 다양화는 T1 이후 가설” 문장을 A1 계약으로 교체.
2. `docs/09_COMBAT_SYSTEM_ARCHITECTURE.md`에 tendency data·trace·후보 선택 경계 추가.
3. Actions 사용 가능 통보 후 Python 계약·Godot verifier·기존 STEP 12·13 회귀 실행.
4. 결과가 PASS일 때만 A1을 `READY_FOR_REVIEW`로 전환.

## 9. 현재 판정

```yaml
a1_code: IMPLEMENTED
a1_data: IMPLEMENTED
a1_static_test: IMPLEMENTED_NOT_REPO_EXECUTED
a1_godot_test: BLOCKED
a1_canonical_docs: PENDING
pr_ready: false
product_gate: REPEAT_POC
t1_greenlight: NOT_GRANTED
mvp_complete: false
```
