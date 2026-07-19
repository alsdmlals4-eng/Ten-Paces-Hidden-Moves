---
name: ten-paces-game-design
description: Use for Ten Paces combat, tournament, martial-art, growth, balance, constraint, or vertical-slice decisions that change rules, numbers, scope, or observable completion criteria.
---

# 십보강호 게임 디자인

## 책임 원본

- 전체 경험: `docs/01_GAME_DESIGN.md`
- 전투 판정: `docs/02_COMBAT_RULES.md`
- 콘텐츠: `docs/03_CONTENT_CATALOG.md`
- 제품 로드맵: `docs/04_ROADMAP.md`
- Vertical Slice: `docs/05_COMBAT_POC_SPEC.md`
- 무공·심법: `docs/06_STARTING_FACTION_MASTERY_DATA.md`
- 시스템 경계: `docs/09_COMBAT_SYSTEM_ARCHITECTURE.md`
- 검증: `docs/08_TEST_CHECKLIST.md`

## 불변 구조

- 전장 10칸·라운드 10타이밍·대회 10전.
- 행동 두 개 비공개 잠금·동시 공개·1수→2수 해상.
- 데모 1~5전과 5전 예선 결승.
- 유효한 쌍방 공격은 합 수치 비교와 차이 피해.
- 절초는 10성 해금과 전투 중 발동 조건을 분리.
- 내부 상대 데이터와 무림식 표현을 의미 키로 분리.
- 절초가 없어도 데모를 정상 완주.

## 절차

1. 해결할 플레이어 판단과 실패 원인을 정의한다.
2. 확정·권장·확인 필요·보류를 분리한다.
3. 대안이 필요한 L2 이상은 2~3개를 비용·위험·장점으로 비교한다.
4. 규칙→도메인 상태·이벤트→UI·연출→QA 순서로 추적한다.
5. 구현 필수 값과 플레이테스트 조정 값을 분리한다.
6. 관련 본책·Roadmap·Test·Plan을 Update Matrix에 따라 동기화한다.

## 금지

- UI 시안의 임시 숫자로 전투 기준 확정.
- 문파 전용 해상 순서 추가.
- 개발용 상대 태그 직접 노출.
- `[보류]` 기능 구현.
- 문서만 보고 구현 완료 판정.

## 완료 기준

- 규칙의 소유자와 표현 계층이 분리된다.
- 예외·무효·실패 원인이 관찰 가능하다.
- 5전 데모 포함·제외 범위가 명확하다.
- 테스트 가능한 완료 기준이 있다.
- 기존 고정 구조와 충돌하는 낡은 표현을 검색했다.
