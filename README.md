# 십보강호: 숨은 수의 비무
## Ten Paces: Hidden Moves

`[강호낭인]`이 10칸 전장에서 상대의 수를 읽고 `3수 → 3수 → 4수`로 행동을 배치·판정하는 1대1 무협 로그라이트입니다.

## 시작

- [작업 시작](START_HERE.md)
- [현재 상태]([기획서]/00_프로젝트_허브/ACTIVE_CONTEXT.md)
- [문서·Skill 지도]([기획서]/00_프로젝트_허브/DOCUMENTATION_MAP.md)
- [Base 적용 기준](docs/BASE_RULES_VERSION.md)
- [기획 책임 원본 Registry]([기획서]/DESIGN_DOCUMENT_REGISTRY.json)
- [프로젝트 Skill Registry]([기획서]/00_프로젝트_허브/SKILL_REGISTRY.json)
- [Base 70개 변경 파일 감사]([기획서]/00_프로젝트_허브/BASE_MAIN_SYNC_AUDIT.md)

## 전투 계약

- 전장 10칸, 플레이어 4번·상대 7번 시작
- 라운드 `3수 → 3수 → 4수`, 총 10수
- 판정 `대응 → 속공 → 이동 → 일반 공격`
- 같은 단계 공격은 동시 피해
- 기초 행동 8종: 이동·보법·막기·회피·속공·강공·명상·태세
- 절초 기세 최대 5칸
- 비용은 행동 슬롯·기력·내력
- 덱·손패·행동력 없음

## 현재 전투 POC

```text
STEP 0~10
+ TARGETING 10.5 이동 목적지·공격 방향
+ RESPONSE 10.6 막기·회피·태세 대응 연계
+ RESOURCE PREVIEW 10.6 배치 즉시 자원 예상치
```

사용자 Windows Godot에서 STEP 0~10과 대상 지정까지 확인했습니다. 최신 대응 판정·자원 미리보기와 4번·7번 시작 위치는 사용자 재확인 대기입니다.

## 범위

- T0: 단일 전투 POC
- T1: 플레이 스타일 2개·상대 3명 내외·전투 3회 내외의 최소 세로 슬라이스
- T2: 5전 데모, 5전째 예선 결승
- 전체판: 10전
- 절초는 데모 필수 조건이 아니라 상위 성과·행운으로 먼저 체험 가능한 하이라이트 후보

## 운영체계

Base `ee265576da7f67d3278f8099dd97d4e714ef0651`의 공용 계약을 프로젝트에 분화 적용합니다.

- Work Mode: `PLAN / BUILD / REVIEW`
- Base 공유 Skill 13개 + 프로젝트 고유 Skill 4개
- Registry trigger 기반 자동 Skill·Skill Mode 선택
- 현재 기획·Skill Registry는 실제 생성기가 없어 `source_only`
- PDF가 필요한 마일스톤에서 생성기·폰트·렌더 검증과 함께 필요한 문서만 `milestone_sync`로 전환
- 구형 파일 `audit → reconcile-legacy → 승인된 migrate → verify`
- 정본 최신성·정적·런타임·접근성·성능·회귀 증거 분리

활성 책임 원본은 아래 `docs/01~11`과 프로젝트 허브 Registry가 관리합니다. 백업·보류·Plan·Git 이력은 기록 보존용이며 활성 구현의 기본 참조가 아닙니다.

정적 Actions 성공은 Godot 런타임, PDF 발행, 접근성, 성능, 사용자 시각 검수, Required Check 강제를 의미하지 않습니다.

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
