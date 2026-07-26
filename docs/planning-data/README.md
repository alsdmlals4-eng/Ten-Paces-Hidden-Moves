# PoC 기획 데이터 편집 안내

이 디렉터리는 Godot 런타임이 읽지 않는 `NON_RUNTIME_POC_PLANNING` 데이터다. 목적은 기획 수치와 콘텐츠를 한 곳에서 쉽게 편집하고, 기획 완료 뒤 Codex가 실제 런타임 Schema로 옮길 때 명시적인 입력을 제공하는 것이다.

## 파일

- `poc_balance_budget.json`: 정수 틱 예산·효과 가격·변경 정책.
- `poc_martial_arts.json`: 시작 무공 후보 6개와 1·3·5·7·9·10성 데이터.
- `poc_enemy_duels.json`: 공개 상태 AI 계약, 주요 비무 10개, `stage_id`, PoC 1~5 범위, 주요 비무 5 전 집중 성장 도달성.
- `poc_map_rewards.json`: 튜토리얼·3스테이지·히든 구조, 구간당 중간 노드 2~3개, 성과·보상·`[의료]`.
- `poc_run_state_contract.json`: `RunState`/`CombatState`, 전투 전후 commit, 영구재화 유료 재도전 계약.
- `poc_sanity_model.json`: 비런타임 수치 sanity model과 38포인트 두 경로.

## 캠페인 편집 계약

- 튜토리얼: 주요 비무 1.
- 스테이지 1: 주요 비무 2~5.
- 스테이지 2: 주요 비무 6~8.
- 스테이지 3: 주요 비무 9~10.
- 히든 천하제일인 배틀: 스테이지 3 이후 후속 추가.
- PoC: 주요 비무 1~5.
- 연속 주요 비무 사이 실제 방문 중간 노드: 2~3개.
- PoC 총 방문 노드: 13~17개.
- 기본 절초 3종은 시작부터 사용 가능.
- 주요 비무 보상은 자유6 / 지정5+자유3 / 문파 무공3성 중 하나이며 제한이 강할수록 총 가치가 높음.
- 집중 경로는 주요 비무1~4에서 32 + 중간 노드 최소6 = 38. 자유 경로는 24 + 고효율 노드14 = 38.
- 패배 재도전은 전투 직전 `RunState` 복원과 `[영구재화]` 1→2→3 결제를 사용.
- `[필중]`은 실제 회피를 우회한 유효 타격마다 1스택 소비.

스테이지 배치는 `poc_enemy_duels.json`, 경로·노드 수는 `poc_map_rewards.json`이 소유한다. 두 파일의 주요 비무 ID와 순서가 일치해야 한다.

## 편집 순서

1. 안정된 주요 비무·무공·기술 ID는 유지한다.
2. 스테이지를 바꿀 때 결투의 `stage_id`와 `stage_contract`를 함께 수정한다.
3. 중간 노드 수를 바꿀 때 구간 수·중간 노드 합계·총 방문 노드를 함께 수정한다.
4. 중앙 가격은 `price_id × quantity` ledger로 기술 예산을 재계산하며 기존 기술을 자동 보정하지 않는다.
5. 5·9성 patch는 허용 필드만 사용하고 target 전후 차이로 추가 tick을 계산한다.
6. 기술 예산은 목표 ±5tick, patch 추가량은 5tick±1 범위만 자동 허용한다.
7. 효과 scope/trigger/condition, `[필중]` 스택 수량, card 판정 phase·이동 시점을 구조화한다.
8. 주요 비무 보상은 중앙 option set ID만 참조하고 독자 포인트를 중복 소유하지 않는다.
9. 노드는 stable ID·수치 선택·구간 제약·동일 seed 결정성을 유지한다.
10. 모든 JSON은 UTF-8, 2칸 들여쓰기, key 순서 유지, 마지막 개행 형식으로 저장한다.
11. `python -m unittest tests.test_poc_planning_data -v`와 `python tools/check_poc_planning_data.py --root .`를 실행한다.

## 상태

- `APPROVED`: 사용자 승인 규칙.
- `POC_HYPOTHESIS`: PoC 제작을 위한 임시 숫자·콘텐츠.
- `IMPLEMENTED_LEGACY`: 현재 main 런타임에는 있으나 최신 승인 기획과 다른 규칙.
- `UNVERIFIED`: 엔진·사람·시장 증거가 없는 판단.

이 데이터의 존재는 구현 완료, 밸런스 검증, 사람 검증을 뜻하지 않는다.
