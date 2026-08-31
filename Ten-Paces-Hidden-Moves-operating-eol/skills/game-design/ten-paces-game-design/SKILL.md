---
name: ten-paces-game-design
description: Use for Ten Paces combat, tournament, martial-art, growth, balance, constraint, PoC, playtest, or vertical-slice decisions that change project-specific rules, numbers, scope, or observable completion criteria.
---

# 십보강호 게임 디자인

## 책임

십보강호 고유 전투·성장·대회·무공·제약의 규칙과 범위를 결정한다. 공용 프로젝트 코어 식별·확정, 일반 벤치마킹 방법, 문서 운영, 변경 검증은 Base Skill이 책임진다.

## Skill Modes

- `rule-update`: 확정 규칙·예외·수치·상태 갱신.
- `balance-review`: 비용·보상·대응·성장 선택 비교.
- `poc-contract`: 가장 위험한 프로젝트 가설의 최소 검증 범위.
- `playtest-recalibration`: 실제 결과를 유지·증폭·변경·삭제·보류·재검증으로 반영.

## 사용 조건

사용한다.

- 10칸·3/3/4·거리·합·대응·중단·절초 등 프로젝트 규칙이 바뀐다.
- T0/T1/T2/전체판 범위나 진입 게이트가 바뀐다.
- 세력·무공·심법·성장·제약이 플레이 판단을 바꾼다.
- 플레이테스트 결과로 수치·규칙·범위를 재조정한다.

사용하지 않는다.

- 표현만 바꾸고 규칙·수치·완료 기준은 바뀌지 않는다.
- 프로젝트 코어를 읽기 전용으로 분류하거나 승인 확정하는 공용 작업이다.
- 일반 벤치마킹 방법론이나 저장소 구조 최적화만 필요하다.

## 읽기 순서

1. `[기획서]/00_프로젝트_허브/ACTIVE_CONTEXT.md`
2. `docs/01_GAME_DESIGN.md`
3. 질문별 책임 원본:
   - 판정: `docs/02_COMBAT_RULES.md`
   - 콘텐츠: `docs/03_CONTENT_CATALOG.md`
   - 로드맵: `docs/04_ROADMAP.md`
   - POC·단계: `docs/05_COMBAT_POC_SPEC.md`
   - 성장: `docs/06_STARTING_FACTION_MASTERY_DATA.md`
   - 시스템 경계: `docs/09_COMBAT_SYSTEM_ARCHITECTURE.md`
   - 검증: `docs/08_TEST_CHECKLIST.md`
4. 관련 `data/`, `src/`, `tests/`, PR #7·활성 Issue.

## 절차

1. 플레이어에게 전달할 경험과 유도할 행동을 `WHY`로 적는다.
2. 목표를 만드는 전략·제약·상호작용을 `HOW`로 적는다.
3. 실제 규칙·수치·화면·콘텐츠를 `WHAT`으로 적는다.
4. 확정·기술 검증·사람 미검증·가설·보류를 분리한다.
5. 프로젝트 코어·뾰족한 재미·제약에 미치는 영향을 확인한다.
6. 규칙→도메인 상태·이벤트→UI·연출→QA 소비자를 추적한다.
7. 대안은 장점·비용·위험·검증 방법으로 비교한다.
8. POC는 가장 위험한 가설만 검증하고 Vertical Slice로 팽창시키지 않는다.
9. 결과를 `KEEP / AMPLIFY / CHANGE / REMOVE / DEFER / RETEST`로 기록한다.
10. 관련 본책·Roadmap·Test·Context를 같은 작업에서 동기화한다.

## 프로젝트 고유 품질 게이트

- 거리·방향·합·대응·자원·중단 중 성공·실패 이유를 설명할 수 있다.
- AI는 비공개 계획을 읽지 않는다.
- 새 콘텐츠가 공용 슬롯·거리·자원·판정 계약을 재사용한다.
- T1 이후 가설을 T0 구현 완료로 표시하지 않는다.
- 수치 변경은 데이터·fallback·fixture·문서·Skill 소비자를 함께 확인한다.
- 사람 플레이를 실행하지 않았으면 검증된 재미·밸런스로 표시하지 않는다.

## 금지

- UI 임시 숫자로 전투 기준 확정.
- 세력 전용 독립 판정 순서 추가.
- 개발용 상대 태그 직접 노출.
- 사용자 승인 없이 현재 단계 밖 기능 구현.
- 외부 게임 기능을 의도·근거 없이 복사.
- `[집중]`, 행동력, 덱/손패 등 제외 요소 재도입.

## 출력

```yaml
why:
how:
what:
status:
canonical_owner:
player_decision:
changed_rules:
affected_consumers:
alternatives:
validation:
human_evidence:
decision: KEEP | AMPLIFY | CHANGE | REMOVE | DEFER | RETEST
```

## 완료 기준

- 규칙 소유자와 표현 계층이 분리된다.
- 예외·무효·실패 원인이 관찰 가능하다.
- T0·T1·T2·전체판 범위가 구분된다.
- 테스트 가능한 완료 기준이 있다.
- 실제 구현과 untouched 소비자를 확인했다.
