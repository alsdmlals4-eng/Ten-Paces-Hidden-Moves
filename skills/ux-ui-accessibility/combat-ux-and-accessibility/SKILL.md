---
name: combat-ux-and-accessibility
description: Use for Ten Paces combat screens, cards, 3-3-4 action timing, HUD, presentation, runtime UI review, accessibility barriers, and visual-state contracts without moving domain calculations into UI.
---

# 십보강호 전투 UX·접근성

## Skill Modes

- `ui-contract`: 화면·카드·HUD·상태·상호작용 계약
- `runtime-review`: 실제 Godot 전후 렌더·포인터·최소 해상도 검수
- `accessibility-review`: 정보·입력·탐색·시간·난이도·모션 장벽과 대체 경로

## 책임 원본

- UI·카드·화면: `docs/07_COMBAT_UI_SPEC.md`
- 연출·폴백: `docs/10_COMBAT_PRESENTATION_PLAN.md`
- 판정: `docs/02_COMBAT_RULES.md`
- 도메인·이벤트: `docs/09_COMBAT_SYSTEM_ARCHITECTURE.md`
- 검증: `docs/08_TEST_CHECKLIST.md`
- 실제 구현: `scenes/`, `src/ui/`, `data/combat/`, `data/cards/`

## 중심 경험

플레이어가 현재 거리·자원·라운드·묶음·1~10수·선택·대상·잠금·판정 결과를 빠르게 읽고 다음 판단에 사용하게 한다.

## 현재 고정 구조

- 전장 10칸
- 상단 HUD: 플레이어 상태·절초 기세·라운드·상대 기세·상대 상태
- 절초 기세 최대 5칸
- 하단 상단: `3수 → 3수 → 4수` 행동 슬롯과 진행 버튼
- 하단 하단: 이동·보법·막기·회피·속공·강공·명상·태세
- 카드 상세: 호버 임시·클릭 고정
- 전투 로그: 접이식
- 이동: 녹색 칸과 형태·문구
- 공격: 붉은 방향 칸과 형태·문구
- 자원 계획: 배치 즉시 HUD 예상값, 부족 슬롯 문구

## 절차

1. 화면마다 첫 시선과 중심 질문을 하나씩 정한다.
2. 상시 정보·호버·클릭 상세·로그의 역할을 분리한다.
3. 구조화된 도메인 상태만 표현하고 피해·보상·저장을 재계산하지 않는다.
4. 기본·선택·잠금·사용 불가·대상 대기·자원 부족·예약·완료 상태를 색뿐 아니라 텍스트·아이콘·형태로 구분한다.
5. 키보드·마우스·컨트롤러 포커스, 긴 문구, 최소 해상도, 모션·점멸 감소, 색각 독립, 자산 누락 폴백을 확인한다.
6. 실제 렌더가 있으면 전후 캡처로 검수한다. 정적 패턴만으로 결함이나 자동 삭제를 확정하지 않는다.
7. 목표 플랫폼 성능 영향이 있으면 별도 performance-profile을 요청한다.

## 금지

- 색이나 음향만으로 상태 전달
- AI 비공개 행동 사전 노출
- 진행 후 확정 행동 변경
- UI·애니메이션 콜백에서 전투 결과 지급
- 승인 이미지 임의 교체
- 테스트되지 않은 법적 접근성 준수 주장
- 빈 에디터 장면·평균 FPS 하나만으로 성능 통과

## 완료 기준

- 카드만 보고 소속·이름·기능·사거리·비용을 설명한다.
- 플레이어가 한 행동 묶음의 배치·대상·자원·성공·실패 원인을 설명한다.
- 색·모션·자산 폴백에서도 동일 정보를 확인한다.
- UI와 도메인 상태의 소유자가 명시된다.
- 실제 런타임·접근성·성능을 실행하지 않았으면 `UNVERIFIED` 또는 `NOT_RUN`이다.
