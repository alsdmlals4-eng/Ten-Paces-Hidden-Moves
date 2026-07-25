# PoC 기획 데이터 편집 안내

이 디렉터리는 Godot 런타임이 읽지 않는 `NON_RUNTIME_POC_PLANNING` 데이터다. 목적은 기획 수치와 콘텐츠를 한 곳에서 쉽게 편집하고, 기획 완료 뒤 Codex가 실제 런타임 Schema로 옮길 때 명시적인 입력을 제공하는 것이다.

## 파일

- `poc_balance_budget.json`: 정수 틱 예산·효과 가격·변경 정책.
- `poc_martial_arts.json`: 시작 무공 후보 6개와 1·3·5·7·9·10성 데이터.
- `poc_enemy_duels.json`: 공개 상태 AI 계약, 주요 비무 10개, `stage_id`, PoC 1~5 범위, 주요 비무 5 전 집중 성장 도달성.
- `poc_map_rewards.json`: 튜토리얼·3스테이지·히든 구조, 구간당 중간 노드 2~3개, 성과·보상·`[의료]`.
- `poc_sanity_model.json`: 비런타임 수치 sanity model 결과.

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
- 한 무공에 38 수련포인트를 집중하면 주요 비무 5 전에 10성 절초 도달 가능성이 있으나 보장되지 않음.

스테이지 배치는 `poc_enemy_duels.json`, 경로·노드 수는 `poc_map_rewards.json`이 소유한다. 두 파일의 주요 비무 ID와 순서가 일치해야 한다.

## 편집 순서

1. 안정된 주요 비무·무공·기술 ID는 유지한다.
2. 스테이지를 바꿀 때 결투의 `stage_id`와 `stage_contract`를 함께 수정한다.
3. 중간 노드 수를 바꿀 때 구간 수·중간 노드 합계·총 방문 노드를 함께 수정한다.
4. `poc_balance_budget.json`의 중앙 가격을 바꿔도 기존 기술은 자동 수정하지 않는다.
5. 각 기술의 `components`, `calculated_ticks`, `variance_ticks`를 다시 계산한다.
6. `abs(variance_ticks) <= 5`이면 PoC 자동 허용 범위다.
7. 범위를 벗어나면 원인 항목과 변경 전후를 기록한 뒤 사람이 수정한다.
8. 효과 trigger는 판정 시점에 맞게 선택하고, 비공격 행동에 `ON_HIT`을 사용하지 않는다.
9. `python tools/check_poc_planning_data.py --root .`로 참조·예산·스테이지·노드·성장 도달성 계약을 확인한다.

## 상태

- `APPROVED`: 사용자 승인 규칙.
- `POC_HYPOTHESIS`: PoC 제작을 위한 임시 숫자·콘텐츠.
- `IMPLEMENTED_LEGACY`: 현재 main 런타임에는 있으나 최신 승인 기획과 다른 규칙.
- `UNVERIFIED`: 엔진·사람·시장 증거가 없는 판단.

이 데이터의 존재는 구현 완료, 밸런스 검증, 사람 검증을 뜻하지 않는다.
