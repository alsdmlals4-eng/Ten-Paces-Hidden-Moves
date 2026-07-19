---
name: combat-ux-and-accessibility
description: Use for Ten Paces combat screens, cards, two-move selection, HUD, presentation, wireframes, accessibility, and visual-state contracts without moving domain calculations into UI.
---

# 십보강호 전투 UX·접근성

## 책임 원본

- UI·카드·화면 영역: `docs/07_COMBAT_UI_SPEC.md`
- 시선·공개·해상·연출·폴백: `docs/10_COMBAT_PRESENTATION_PLAN.md`
- 판정 기준: `docs/02_COMBAT_RULES.md`
- 도메인·이벤트 경계: `docs/09_COMBAT_SYSTEM_ARCHITECTURE.md`
- 검증: `docs/08_TEST_CHECKLIST.md`

## 중심 경험

플레이어가 현재 거리·자원·타이밍·1수·2수·잠금 상태를 빠르게 읽고, 공개 결과의 성공·실패 원인을 다음 판단에 사용하게 한다.

## 절차

1. 화면마다 첫 시선과 중심 질문을 하나씩 정한다.
2. 선택 전 필수 정보, 호버 정보, 클릭 상세, 결과 로그의 역할을 분리한다.
3. 규칙의 구조화 이벤트만 받아 표현하고 피해·보상·저장을 재계산하지 않는다.
4. 기본·선택·잠금·사용 불가·발동 가능·예약·완료 상태를 텍스트·아이콘·형태로 구분한다.
5. 최소 해상도·긴 문구·키보드 포커스·모션 감소·점멸 감소·색상 독립·자산 누락을 함께 설계한다.
6. 실제 렌더가 있으면 전후 캡처로 검수하고 정적 추정만으로 결함을 확정하지 않는다.

## 금지

- 색이나 음향만으로 상태 전달.
- AI 행동을 잠금 전에 공개.
- 첫 수 결과 뒤 둘째 수 변경.
- 합과 일반 공격을 같은 표제·로그·연출로 표시.
- 애니메이션 콜백에서 결과 지급.
- 승인 이미지가 있는데 임의로 새 시안 교체.

## 완료 기준

- 카드만 보고 3초 안에 문파/공용·이름·종류·사거리·주요 비용을 말한다.
- 플레이어가 한 2수 묶음의 성공·실패 원인을 설명한다.
- 연출 감소·자산 누락에서도 같은 정보와 결과를 확인한다.
- UI 상태와 도메인 상태의 소유자가 명시된다.
- 실제 렌더가 없으면 구현·시각 검증 완료로 표시하지 않는다.
