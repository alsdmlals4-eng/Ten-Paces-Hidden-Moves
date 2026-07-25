# PoC Planning Baseline Design

## Goal

구형 구현 계약을 보존하면서 최신 승인 기획을 책임 원본에 통합하고, PoC 숫자·무공·적·지도 데이터를 런타임과 분리된 편집 가능한 JSON으로 제공한다.

## Boundaries

- 제품 코드·씬·에셋·런타임 데이터는 변경하지 않는다.
- 기획 단계는 `PLANNING_IN_PROGRESS`를 유지한다.
- 수치와 콘텐츠는 `POC_HYPOTHESIS`, 실제 구현은 `IMPLEMENTED_LEGACY`, 미실행 검증은 `UNVERIFIED`로 표시한다.
- 안정 ID와 중앙 가격표를 사용해 후속 편집 비용을 낮춘다.

## Components

1. `poc_balance_budget.json`: 틱 단위 가격과 변경 정책.
2. `poc_martial_arts.json`: 6개 무공의 성장 데이터.
3. `poc_enemy_duels.json`: 공개 상태 AI와 10개 주요 비무.
4. `poc_map_rewards.json`: 지도·성과·보상·의료.
5. `poc_sanity_model.json`: 분석 전용 결과.
6. `docs/01~10`: 질문별 현재 계약과 런타임 차이.
7. 감사·벤치마크·적대적 검토·sanity 결정 기록.

## Data flow

승인 규칙 → 중앙 PoC 데이터 → 책임 원본 설명 → 후속 Codex Schema 변환 → 자동/런타임/사람 검증. 중앙 가격 변경은 기술을 자동 수정하지 않고 편차 보고만 만든다.

## Error handling

- 예산 ±5틱 초과: 데이터는 유지하고 검토 실패로 표시한다.
- 알 수 없는 effect scope/trigger: 구현 인계 차단.
- 안정 ID 중복/참조 누락: 정적 검증 실패.
- 런타임과 기획 차이: `IMPLEMENTED_LEGACY`로 명시하고 PASS 금지.

## Validation

JSON 파싱, ID 고유성, 기술 예산, 별 수련 단계, 의료 상한, 주요 비무 순서, 지도 범위, 문서 상태 문구와 필수 section을 확인한다. Godot·Windows·사람 플레이는 `NOT_RUN`이다.
