# PoC 기획 데이터 편집 안내

이 디렉터리는 Godot 런타임이 읽지 않는 `NON_RUNTIME_POC_PLANNING` 데이터다. 목적은 기획 수치와 콘텐츠를 한 곳에서 쉽게 편집하고, 기획 완료 뒤 Codex가 실제 런타임 Schema로 옮길 때 명시적인 입력을 제공하는 것이다.

## 파일

- `poc_balance_budget.json`: 정수 틱 예산·효과 가격·변경 정책.
- `poc_martial_arts.json`: 시작 무공 후보 6개와 1·3·5·7·9·10성 데이터.
- `poc_enemy_duels.json`: 공개 상태 AI 계약과 주요 비무 10개.
- `poc_map_rewards.json`: PoC 지도·성과 등급·수련 보상·`[의료]` 공급.
- `poc_sanity_model.json`: 비런타임 수치 sanity model 결과.

## 편집 순서

1. `poc_balance_budget.json`의 중앙 가격을 바꾼다.
2. 기존 기술은 자동 수정하지 않는다.
3. 각 기술의 `components`, `calculated_ticks`, `variance_ticks`를 다시 계산한다.
4. `abs(variance_ticks) <= 5`이면 PoC 자동 허용 범위다.
5. 범위를 벗어나면 원인 항목과 변경 전후를 기록한 뒤 사람이 수정한다.
6. 안정된 ID는 유지하고 이름·수치·설명·가중치는 독립 편집한다.

## 상태

- `APPROVED`: 사용자 승인 규칙.
- `POC_HYPOTHESIS`: PoC 제작을 위한 임시 숫자·콘텐츠.
- `IMPLEMENTED_LEGACY`: 현재 main 런타임에는 있으나 최신 승인 기획과 다른 규칙.
- `UNVERIFIED`: 엔진·사람·시장 증거가 없는 판단.

이 데이터의 존재는 구현 완료, 밸런스 검증, 사람 검증을 뜻하지 않는다.
