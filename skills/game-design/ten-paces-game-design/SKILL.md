---
name: ten-paces-game-design
description: Use for Ten Paces combat, tournament, martial-art, growth, balance, constraint, PoC, playtest, or vertical-slice decisions that change rules, numbers, scope, or observable completion criteria.
---

# 십보강호 게임 디자인

## Skill Modes

- `rule-update`: 확정 규칙·예외·수치·상태 갱신
- `balance-review`: 비용·보상·대응·성장 비교
- `poc-contract`: 가장 위험한 가설의 최소 검증
- `playtest-recalibration`: 실제 결과를 유지·증폭·변경·삭제·보류·재검증으로 반영

## 책임 원본

- 전체 경험: `docs/01_GAME_DESIGN.md`
- 전투 판정: `docs/02_COMBAT_RULES.md`
- 콘텐츠: `docs/03_CONTENT_CATALOG.md`
- 제품 로드맵: `docs/04_ROADMAP.md`
- POC·Vertical Slice: `docs/05_COMBAT_POC_SPEC.md`
- 무공·심법: `docs/06_STARTING_FACTION_MASTERY_DATA.md`
- 시스템 경계: `docs/09_COMBAT_SYSTEM_ARCHITECTURE.md`
- 검증: `docs/08_TEST_CHECKLIST.md`
- 실제 상태: `data/`, `src/`, `tests/`, PR #7

## 현재 고정 구조

- `[강호낭인]` 플레이어 정체성.
- 전장 10칸, 플레이어 4번·상대 7번 시작, 시작 거리 3.
- 라운드 `3수 → 3수 → 4수`, 총 10수.
- 판정 `대응 → 속공 → 이동 → 일반 공격`.
- 기초 행동 8종.
- 비용은 행동 슬롯·기력·내력.
- 절초 기세 최대 5칸.
- 현재 적은 고정 검증 계획이며 정식 AI가 아님.
- T0 단일 전투 → T1 최소 세로 슬라이스 → T2 5전 데모 → 전체 10전.
- 내부 상대 데이터와 무림식 표현의 의미 키 분리.
- 절초가 없어도 데모 정상 완주.

## 절차

1. 플레이어 판단과 실패 원인을 정의한다.
2. 확정·권장·확인 필요·보류를 분리한다.
3. 핵심 컨셉·제약·뾰족한 재미에 미치는 영향을 확인한다.
4. 대안은 비용·위험·장점과 검증 방법으로 비교한다.
5. 규칙→도메인 상태·이벤트→UI·연출→QA로 추적한다.
6. 숫자 하나가 바뀌어도 데이터·fallback·fixture·문서·Skill·Context 소비자를 함께 확인한다.
7. 구현 필수 값과 플레이테스트 조정 값을 분리한다.
8. PoC는 가장 위험한 가설만 검증하고 전체 Vertical Slice로 팽창시키지 않는다.
9. 외부 게임·리뷰는 공식 사실·자기보고·행동 근거·해석을 분리한다.
10. 결과는 `KEEP / AMPLIFY / CHANGE / REMOVE / DEFER / RETEST`로 기록한다.
11. 관련 본책·Roadmap·Test·실제 데이터를 같은 작업에서 동기화한다.

## 현재 시작 거리 가설

플레이어 4번·상대 7번의 시작 거리 3은 다음을 의도한다.

- 첫 수부터 속공·강공을 바로 적중시키지 못한다.
- 이동·보법·대응·명상 중 첫 묶음 선택을 만든다.
- 양측이 한 칸 접근하면 5번·6번에서 인접해 공격 국면으로 전환된다.

이 의도가 실제로 재미와 판독성을 높이는지는 STEP 14 플레이테스트에서 검증한다.

## 금지

- UI 시안 임시 숫자로 전투 기준 확정.
- 문파 전용 해상 순서 추가.
- 개발용 상대 태그 직접 노출.
- `[보류]` 기능 구현.
- 외부 인기 기능 복사.
- T1 이후 성장 후보를 T0 구현 완료로 표시.
- 문서 또는 정적 검사만으로 구현·플레이 검증 완료 판정.

## 완료 기준

- 규칙 소유자와 표현 계층이 분리된다.
- 예외·무효·실패 원인이 관찰 가능하다.
- POC·T1·5전 데모·전체판 범위가 구분된다.
- 테스트 가능한 완료 기준이 있다.
- 실제 구현과 낡은 소비자 표현을 함께 확인했다.
- 플레이테스트를 실행하지 않았으면 결과를 검증된 밸런스로 표시하지 않는다.
