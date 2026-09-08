# Task 1 Report — Pure Bimu Constraint Catalog and Model

## 작업 전 문제

- 기준 SHA: `0010aaefc222e4b487461625f1917c8f280217e2`.
- Work Mode / Skill / Skill Mode: `BUILD` / `combat-implementation-handoff`, `ten-paces-verification` / `build`, `contract-check`, `static-validation`, `regression`, `evidence-report`.
- 승인된 Decision은 런타임 owner를 요구했지만 `data/run/bimu_constraints.json`, `src/run/bimu_constraint_model.gd`, 집중 테스트가 없었다.
- 작업 트리에 기존 `.import`, 캡처, 산출물 변경이 다수 존재했다. 해당 변경은 사용자/다른 작업 소유로 간주해 수정·정리·커밋하지 않았다.

## 조사·비교 결과

- `git show codex/human-blueprint-r4-closure-20260907:docs/planning-data/bimu_constraint_v0_candidate_catalog.json`으로 역사 카탈로그의 9종 값만 읽었다. 역사 `SPECIFIED_PLANNING_CANDIDATE`, `RUNTIME_NOT_IMPLEMENTED`, 과거 consumer/status 주장은 새 실행 데이터에 복사하지 않았다.
- 현재 실행 권위는 `docs/decisions/2026-09-08_BIMU_CONSTRAINT_RUNTIME_DECISION.md`의 `APPROVED_FOR_BUILD / IMPLEMENTATION_IN_PROGRESS`이다.
- 실제 무공 원본 `data/cards/martial_manuals/*.json`과 `src/combat/martial_manual_registry.gd`를 확인했다. 정규화된 카드가 `source=martial_manual`, `manual_id`, `unlock_star`, `category`, `action_slots`를 유지하므로 ID suffix 추론 없이 직접 필드로 봉인한다.
- 실제 전투 상태는 `stamina/internal/momentum` 자원쌍 `[current, maximum]`, 영구 능력치는 `stats` 하위 Dictionary를 사용한다. 순수 모델은 이 구조와 격리 테스트용 평면 구조를 모두 복사 후 overlay한다.
- `CURRENT_SOURCE_RELEVANCE_CHECK: NOT_APPLICABLE`. 이번 bounded 구현은 승인된 수치와 현재 저장소 데이터 구조의 기계적 결합이며 외부 최신 자료가 판정을 바꾸지 않는다. 기존 기획 package의 벤치마크를 확장하거나 새 설계를 만들지 않았다.

## 채택한 구조와 이유

- JSON이 9종 제약과 선택 정책의 유일한 런타임 owner다. docs/역사 branch 런타임 의존성은 없다.
- 모델은 선택 입력을 fail-closed로 정규화하고 깊은 복사 receipt를 반환한다. downstream helper는 `valid=true` 한 필드만으로 동작하지 않고 selections/errors/spent 구조와 예산·중복·강화 수를 다시 확인한다.
- 봉인은 오직 실제 `martial_manual` definition에 적용한다. `basic`/`ultimate` source는 항상 통과한다.
- mastery/state overlay는 입력을 deep copy하고 +2/10★, 현재자원 +1/current max clamp, 선택 능력치 +1만 적용한다. 보상·저장·AI·RunState·UI는 건드리지 않았다.

## TDD 및 실제 결과

1. RED: 모델 preload가 없을 때 집중 테스트 실행은 exit `1`, `Preload file ... bimu_constraint_model.gd does not exist`로 실패했다.
2. GREEN: 카탈로그와 최소 모델 구현 후 31개 경계가 출력상 통과했다.
3. 추가 RED: 실제 runtime 자원쌍/중첩 stats 반례를 추가하자 exit `1`, `runtime resource pairs...`, `runtime nested stat...` 두 실패가 관찰됐다.
4. 추가 GREEN: 실제 구조 overlay를 구현했다.
5. 자체 검토 RED: JSON 정책 budget을 0으로 바꾼 fixture와 빈 catalog fixture가 각각 정책 중복 하드코딩 및 fail-open을 검출했다.
6. 최종 GREEN: 정책을 JSON owner에서만 소비하고 malformed catalog를 거부한 뒤 `BIMU_CONSTRAINT_MODEL_OK cases=37`, exit `0`.

## 검증 증거

실행 명령:

```powershell
python -c "...json parse/policy assertions..."
git diff --check -- data/run/bimu_constraints.json src/run/bimu_constraint_model.gd tests/verify_bimu_constraint_model.gd
Godot_v4.7.1-stable_win64_console.exe --headless --path . --script res://tests/verify_bimu_constraint_model.gd
Godot_v4.7.1-stable_win64_console.exe --headless --path . --script res://tests/verify_ten_duel_campaign.gd
```

관찰 출력 및 종료:

```text
BIMU_CONSTRAINT_JSON_OK options=9
BIMU_CONSTRAINT_MODEL_OK cases=37
TEN_DUEL_CAMPAIGN_STATE_OK (synthetic terminal results; not full battle playthrough)
combined exit=0
```

## 5회 전체 적대 검토

1. 정본/범위: 역사 상태를 제외하고 새 Decision과 정확한 9종 값만 채택. 새 core/reward/save/UI/RunState 없음.
2. 실제 diff/소비자: model files/test/report만 소유. 기존 import/capture와 open work는 untouched. 다음 RunState/engine/UI 소비자는 controller 후속 Task이며 이번 변경에서 조기 연결하지 않음.
3. 실패/반례: 비 Dictionary, 누락/잘못된 타입/추가 key/알 수 없는 ID/중복/2개 초과/3점 초과/상대강화 2개/소유권/허용 stat을 fail-closed 검토. 집중 테스트로 확인.
4. 실제 실행 구조/비용: runtime resource pair와 nested stats 불일치를 발견해 RED→GREEN으로 교정. deep copy와 clamp로 원본 mutation 및 최대치 증가를 차단. 추가 서비스/비용 없음.
5. 장기 적합성/clean exit: definition의 실제 source/identity/metadata만 사용하고 `_star3` 등 ID 추론 없음. basic/ultimate 보호, 빈/단일-valid forged receipt 무효, 선택 보상/거리/3-3-4/AI private 계획 변경 없음. 추가 finding 없이 clean exit.

## 자동화·학습 반영

- 재실행 가능한 집중 Godot 스크립트가 9종/정책/parameter/overlay/guard/deep-copy 회귀를 소유한다.
- actual consumer shape를 테스트 fixture에 반영해 후속 engine binding에서 평면 상태를 오인하지 않도록 했다.

## 미검증·남은 위험

- RunState/engine/UI 실제 연결, 동일 retry receipt 복원, forged receipt의 실제 actor-owned catalog 재검증은 후속 Task 범위이며 `NOT_RUN`이다.
- Windows visible, Android actual device, 접근성 사용자, Human 균형/사용성, Release 성능·출시는 `NOT_RUN`이다.
- 현재 테스트는 headless pure model과 synthetic 10전 회귀 증거이며 실제 전투 플레이스루 증거가 아니다.
