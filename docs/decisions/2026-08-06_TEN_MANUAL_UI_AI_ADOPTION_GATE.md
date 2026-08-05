# TEN_MANUAL_UI_AI_ADOPTION_GATE

- 상태: `APPROVED_AND_IMPLEMENTED`
- 날짜: `2026-08-06`
- 사용자 승인: `권장안대로 진행`
- 대상: Draft PR #92
- 부모 PR: Draft PR #91
- 부모 성장 권위: `TEN-DEC-20260806-TEN-RECOGNIZABLE-MARTIAL-MANUALS-FULL-GROWTH-01`
- 부모 런타임 권위: `TEN_MANUAL_RUNTIME_IMPLEMENTATION_GATE`
- 다음 Gate: `TEN_MANUAL_PRODUCT_VALIDATION_GATE`

## 결정

초기 무공서 10권의 `MartialManualRegistry` 정본을 행동 선택 UI와 공개 상태 기반 적 AI에 연결한다. 선택된 무공 카드는 표시용 데이터로 끝나지 않고 실제 묶음 해결 안에서 `MartialEffectPipeline`의 `effect_steps`를 실행한다.

## UI 계약

- 런타임 입력은 `martial_loadout`과 `martial_mastery_by_manual`이다.
- 무공 탭은 loadout 순서를 유지한다.
- 문파·무공서·주/보조능력치를 표시한다.
- 3성·7성 기술의 해금 상태를 표시한다.
- 5성 overlay는 기술1에, 9성 overlay는 기술2에만 합성한다.
- 10성 절초는 기존 공용 절초와 함께 절초 탭에 표시한다.
- loadout이 제공되지 않으면 선행 ActionSelectionDock 호환 동작을 유지한다.

## AI 계약

- 적 AI는 적 자신의 명시적 loadout에서 현재 성취도로 해금된 카드만 후보로 사용한다.
- 후보 평가는 공개 거리·자원·남은 묶음 슬롯·카드 비용·공개 사거리만 사용한다.
- 미확정 플레이어 계획·포인터·숨은 가중치·현재 비공개 배치는 입력하지 않는다.
- 기존 기본 행동 후보와 공용 절초 후보는 유지한다.
- 적 loadout이 비어 있으면 기존 공개 상태 AI 동작을 유지한다.

## 전투 해결 계약

- `TenManualCombatResolutionEngine`은 준비 엔진을 상속해 `[준비]`와 자동 배치 후처리를 보존한다.
- 무공 카드는 실행 수에서 `MartialEffectPipeline`으로 해결한다.
- 상태 생성 선행, 이동 후 사거리 재검사, 독립 다단, 조건부 후속, 전투당 사용권 규칙을 유지한다.
- 무공 피해도 현행 중단 규칙을 통과한다.
- 특수 합 승리 시 같은 수의 상대 행동을 취소할 수 있으나 자동 합 승리는 없다.
- 기존 기본 행동·공용 절초 ID는 삭제하거나 변경하지 않는다.

## PoC loadout 경계

`data/combat/ten_manual_loadout_poc.json`은 제품 미리보기의 임시 명시적 loadout이다.

- 플레이어와 적 loadout·성취도를 분리한다.
- 향후 세이브·성장 시스템으로 교체 가능하다.
- 이 fixture는 최종 획득·장착 경제를 확정하지 않는다.

## TDD 증거

- RED workflow: `31053963064`
- RED 원인: UI 이후 준비 엔진에 플레이어/적 loadout 분리 API와 bundle effect pipeline 연결이 없음.
- GREEN 요구:
  - `Validate Ten Manual UI AI Adoption`
  - `Validate Ten Manual Runtime Foundation`
  - `PR Validation`
  - `Full Validation`
  - 기존 ActionSelectionDock·공개 상태 AI 회귀

## 승인하지 않은 범위

- 최종 피해 계수·자원 비용 확정
- 최종 loadout 획득·교체 경제
- 적별 최종 무공 배치와 난이도 곡선
- Windows 실제 실행 승인
- 접근성·성능 승인
- 신규 플레이어 사람 검증
- 최종 밸런스와 T1 완료 선언

## 정본 동기화

GitHub 권위 문서와 Google Sheet에는 이 Decision ID와 검증 완료 후의 exact head를 함께 기록한다. Google Sheet에는 `03_무공서_무학` 탭을 만들고 초기 10권의 문파·방향성·주/보조능력치·3/5/7/9/10성 성취도를 한 행씩 기록한다.

PR #92는 계속 Draft·stacked 상태이며 이 Decision은 병합·Draft 해제·부모 PR 우회를 승인하지 않는다.
