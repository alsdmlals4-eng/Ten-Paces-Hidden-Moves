# 십보강호: 숨은 수의 비무
## Ten Paces: Hidden Moves

`[강호낭인]`이 10칸 전장에서 상대의 공개 상태를 읽고 `3수 → 3수 → 4수`로 계획해, 거리·`[합]`·대응·중단·절초의 결과를 복기하고 다음 계획을 바꾸는 1대1 무협 예측 전술 로그라이트입니다.

## 시작

- [작업 시작](START_HERE.md)
- [현재 상태]([기획서]/00_프로젝트_허브/ACTIVE_CONTEXT.md)
- [문서·Skill 지도]([기획서]/00_프로젝트_허브/DOCUMENTATION_MAP.md)
- [Base 적용 기준](docs/BASE_RULES_VERSION.md)
- [기획 책임 원본 Registry]([기획서]/DESIGN_DOCUMENT_REGISTRY.json)
- [프로젝트 Skill Registry]([기획서]/00_프로젝트_허브/SKILL_REGISTRY.json)
- [Base 동기화 감사]([기획서]/00_프로젝트_허브/BASE_MAIN_SYNC_AUDIT.md)

## 현재 기준

- Base: `41a20584dd2ee51d917e5c9d7cab6838e1ceba7e`.
- 구현 기준: PR #7 `agent/t0-combat-poc-board@147a031c75e96bff170d7f99016beb9e85b12066`.
- 최신 승인 범위: Issue #13 STEP 12~14.
- 프로젝트 코어: `CORE_REVIEW_PENDING`.

## 현재 전투 계약

- 전장 10칸, 플레이어 4번·상대 7번 시작, 시작 거리 3.
- 같은 칸 최대 2인, 거리 0 `[밀착]`.
- 라운드 `3수 → 3수 → 4수`, 총 10수.
- 기초 행동 8종: 이동·보법·막기·회피·속공·강공·명상·태세.
- 절초 3종: 십보 유파·단악결·파공검기.
- 같은 실행 수 공격은 `[합]`으로 원공격력 차이를 정산.
- 방어도 차감 뒤 같은 수 반감, 회피, 파공검기 `[필중]`.
- 같은 수 미실행 행동 중단과 태세 기반 `[강건]`.
- 공개 상태 기반 결정적 최소 AI.
- 승리·패배·무승부와 4/7 완전 재시작.
- 비용은 행동 슬롯·기력·내력·절초 기세이며 덱·손패·행동력·내공은 없습니다.

상세 규칙은 [전투 규칙서](docs/02_COMBAT_RULES.md)가 책임집니다.

## 현재 전투 POC

```text
STEP 0~10 기본 전장·UI·배치·판정
+ TARGETING 10.5 이동 목적지·공격 방향
+ RESPONSE / RESOURCE PREVIEW 10.6
+ Issue #11 밀착·중단·강건·절초 3종·순차 연출
+ STEP 12 공개 상태 기반 최소 AI
+ STEP 13 종료·재시작
+ STEP 14 개발자 기계 시나리오 기록
```

STEP 0~13은 구현·자동 또는 Windows/Godot 기술 증거가 있습니다. 실제 사용자 규칙 이해·보조기기 사용성·주관적 음향/모션·외부 플레이는 아직 `NOT_RUN`입니다.

## 제품 범위

- T0: 단일 전투 POC와 실제 사용자 STEP 14.
- T1: 플레이 스타일 2개·상대 3명 내외·전투 3회 내외의 최소 세로 슬라이스.
- T2: 5전 데모, 5전째 예선 결승.
- 전체판: 10전 대회와 세력·무공·심법·성장 후보.

T1은 프로젝트 코어 사용자 승인과 STEP 14 사람 증거 뒤에만 시작합니다.

## 운영체계

- Work Mode: `PLAN / BUILD / REVIEW`.
- Base 활성 Skill 25개를 원본에서 조건부 라우팅.
- 프로젝트 고유 Skill 4개 유지.
- Registry trigger 기반 자동 Skill·Skill Mode 선택.
- 현재 기획 문서와 Skill Registry는 `source_only`.
- 최신 본문에는 현재 계약만 유지하고 과거 전문은 Git 이력에서 확인.
- 정본·경로·ID·Schema·Base SHA·Skill 집합을 `reference-freshness`로 검사.
- exact 기준 SHA 분기와 보호 경로 diff로 Codex 작업을 보존.

정적 Actions 성공은 Godot 런타임·Windows 사용자 경험·접근성·Release 성능·PDF 발행·Required Check 강제를 의미하지 않습니다.

## 책임 원본

- [게임 기획](docs/01_GAME_DESIGN.md)
- [전투 규칙](docs/02_COMBAT_RULES.md)
- [콘텐츠](docs/03_CONTENT_CATALOG.md)
- [제품 로드맵](docs/04_ROADMAP.md)
- [전투 POC](docs/05_COMBAT_POC_SPEC.md)
- [무공·심법](docs/06_STARTING_FACTION_MASTERY_DATA.md)
- [전투 UI](docs/07_COMBAT_UI_SPEC.md)
- [테스트](docs/08_TEST_CHECKLIST.md)
- [아키텍처](docs/09_COMBAT_SYSTEM_ARCHITECTURE.md)
- [연출](docs/10_COMBAT_PRESENTATION_PLAN.md)
- [Base 적용·학습](docs/11_BASE_ADOPTION_AND_LEARNING_LOG.md)

## 다음 작업

```text
정본·Skill·Governance 검증
→ PR #7 제품 파일 보존 확인
→ 핵심 컨셉·제약·뾰족한 재미·WHY/HOW/WHAT·SWOT/VRIO로 프로젝트 코어 확정
→ STEP 14 실제 플레이
→ T1 진입 또는 기획 재조정
```
