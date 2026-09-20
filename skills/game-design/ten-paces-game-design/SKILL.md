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
4. 관련 `data/`, `src/`, `tests/`, 현재 관련 PR·활성 Issue.

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

공용 승인·격리·검토·보고 절차는 `AGENTS.md`와 `docs/PROJECT_TOTAL_PLANNING_IMPLEMENTATION_AND_DELIVERY_INSTRUCTION.md`를 재사용한다. 기존 실행 기록에 주장·변경·검증·미검증·다음 작업을 누적하며 단계마다 새 보고서를 만들지 않는다.

## 완료 기준

- 규칙 소유자와 표현 계층이 분리된다.
- 예외·무효·실패 원인이 관찰 가능하다.
- T0·T1·T2·전체판 범위가 구분된다.
- 테스트 가능한 완료 기준이 있다.
- 실제 구현과 untouched 소비자를 확인했다.

## 재미·표현 검증 연결

FUN_VERIFICATION_LIFECYCLE은 `docs/PROJECT_TOTAL_PLANNING_IMPLEMENTATION_AND_DELIVERY_INSTRUCTION.md` §6.1을 따른다. WHY(의도한 경험) → HOW(규칙·선택·정보가 경험을 만드는 방식) → WHAT(관찰 가능한 결과)을 설명하고, 변경 기능의 기존 owner에 가설·반례·입력/상태/정보·실제 consumer·검증·교정을 연결한다. 이해 실패·규칙/선택 실패·피드백 부족·반복 피로를 구분한다. HUMAN_NOT_RUN을 자동 테스트나 AI 검토로 FUN_PASS로 바꾸지 않으며 승인된 독립 구현은 계속한다. 작은 변경은 기존 기록에 짧게 적고 새 재미 보고서·보편 점수·가상 감독을 만들지 않는다.
