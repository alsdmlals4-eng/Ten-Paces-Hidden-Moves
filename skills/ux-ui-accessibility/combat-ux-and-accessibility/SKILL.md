---
name: combat-ux-and-accessibility
description: Use for Ten Paces combat screens, cards, action timing, HUD, presentation, runtime UI review, and accessibility barriers without moving domain calculations into UI.
---

# 십보강호 전투 UX·접근성

## 책임

십보강호 전투의 정보 계층·상호작용·상태 표현·연출 폴백·접근성 장벽을 설계하고 실제 Godot 화면에서 검수한다. 전투 계산은 소유하지 않는다.

## Skill Modes

- `ui-contract`: 화면·카드·HUD·상태·상호작용 계약.
- `runtime-review`: 실제 Godot 렌더·포인터·키보드·최소 해상도 검수.
- `accessibility-review`: 정보·입력·탐색·시간·난이도·모션·음향 장벽과 대체 경로.

## 사용 조건

사용한다.

- 전투판·HUD·카드·수 슬롯·절초·로그·재생·재시작 표현이 바뀐다.
- 거리·합·대응·중단·기세 결과의 판독성을 검수한다.
- 키보드·포커스·접근성 메타데이터·모션 감소·음향 폴백을 변경한다.
- 실제 Godot 전후 렌더를 검토한다.

사용하지 않는다.

- 도메인 계산·AI·저장 로직만 변경한다.
- 새 이미지 프롬프트만 설계한다.
- 실제 화면 없이 스타일 취향만 평가한다.

## 책임 원본

- UI·카드·입력: `docs/07_COMBAT_UI_SPEC.md`.
- 연출·폴백: `docs/10_COMBAT_PRESENTATION_PLAN.md`.
- 판정: `docs/02_COMBAT_RULES.md`.
- 도메인·이벤트: `docs/09_COMBAT_SYSTEM_ARCHITECTURE.md`.
- 검증: `docs/08_TEST_CHECKLIST.md`.
- 실제 구현: `scenes/`, `src/ui/`, `src/combat/`, `data/`, `assets/`.

현재 구현·증거 상태는 허브 `ACTIVE_CONTEXT.md`에서 읽는다.

## 절차

1. 화면마다 첫 시선과 중심 질문을 하나씩 정한다.
2. 상시 정보·선택 상세·로그·결과 요약의 역할을 분리한다.
3. 구조화된 state·event만 표현하고 피해·보상·저장을 재계산하지 않는다.
4. 기본·선택·잠금·준비·실행·중단·자원 부족·예약·종료 상태를 색 외 채널로 구분한다.
5. 위치·거리 변경 시 캐릭터·타일·점유·대상·로그·접근성 이름을 함께 검수한다.
6. 합·방어·회피·필중은 적용 순서와 최종 결과를 분리해 보여 준다.
7. 키보드·마우스·포커스·긴 한국어·최소 해상도·모션·음향·자산 누락 폴백을 확인한다.
8. 실제 렌더가 있으면 전후 캡처와 입력으로 검수한다.
9. 실제 사용자·보조기기 검증을 실행하지 않았으면 `NOT_RUN`으로 유지한다.
10. 목표 플랫폼 성능 영향이 있으면 별도 performance-profile을 실행한다.

## 정보 계약

플레이어가 다음을 설명할 수 있어야 한다.

- 양측 위치·거리·밀착.
- 현재 자원·기세·상태.
- 라운드·묶음·수.
- 배치·준비·실행·중단.
- 이동 목적지·공격 방향·절초 예약.
- 합·방어·회피·필중 결과.
- 진행 불가·종료·재시작 이유.

## 접근성 게이트

- 상태가 색·모션·음향 하나에만 의존하지 않는다.
- 모든 핵심 입력에 포인터와 키보드 경로가 있다.
- 포커스가 시각적으로 보이고 순서가 명시적이다.
- 한국어 접근성 이름·설명이 기능과 결과를 전달한다.
- 모션 감소·음향 끄기·자산 누락에서도 같은 의미가 남는다.
- 긴 문구와 최소 해상도에서 핵심 UI가 잘리지 않는다.
- 기술 노출을 실제 보조기기 사용성이나 법적 준수로 과장하지 않는다.
- 실제 사용자 증거가 없으면 상태는 `HUMAN_NOT_RUN`이다.

## 금지

- 색이나 음향만으로 상태 전달.
- AI 비공개 행동 사전 노출.
- 진행 뒤 확정 계획 변경.
- UI·애니메이션 콜백에서 전투 결과 지급.
- 승인 이미지 임의 교체.
- 구형 배치·placeholder를 현행 승인 상태로 설명.
- 빈 에디터 장면·정적 패턴·평균 FPS 하나로 통과 판정.

## 출력

```yaml
screen_question:
first_attention:
state_source:
information_channels:
input_paths:
accessibility_barriers:
fallbacks:
runtime_evidence:
human_evidence:
performance_impact:
result: PASS | PARTIAL | FAIL | NOT_RUN | BLOCKED
```

## 완료 기준

- 플레이어가 카드·전장·슬롯·결과만 보고 한 묶음을 설명한다.
- 같은 정보가 색·모션·음향 폴백에서도 남는다.
- UI와 도메인 상태 소유자가 명시된다.
- 실제 런타임·접근성·성능을 실행하지 않았으면 검증 완료로 쓰지 않는다.
