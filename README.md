# 십보강호: 숨은 수의 비무
## Ten Paces: Hidden Moves

`[강호낭인]`이 10칸 전장에서 상대의 수를 읽고 `3수 → 3수 → 4수`로 행동을 배치·판정하는 1대1 무협 로그라이트입니다.

## 가장 먼저 읽기

```text
START_HERE.md
→ AGENTS.md
→ docs/BASE_RULES_VERSION.md
→ [기획서]/00_프로젝트_허브/START_HERE.md
→ ACTIVE_CONTEXT.md
→ DOCUMENTATION_MAP.md
→ DEVELOPMENT_GATES.md
→ ROADMAP.md
→ DESIGN_DOCUMENT_REGISTRY.json
→ 현재 책임 원본
→ SKILL_REGISTRY.json
→ 실제 코드·데이터·자산·테스트
```

- [프로젝트 시작 지점](START_HERE.md)
- [프로젝트 기획 허브]([기획서]/00_프로젝트_허브/START_HERE.md)
- [현재 상태]([기획서]/00_프로젝트_허브/ACTIVE_CONTEXT.md)
- [기획 책임 원본 Registry]([기획서]/DESIGN_DOCUMENT_REGISTRY.json)
- [프로젝트 Skill Registry]([기획서]/00_프로젝트_허브/SKILL_REGISTRY.json)
- [Base 최신 main 전수 감사]([기획서]/00_프로젝트_허브/BASE_MAIN_SYNC_AUDIT.md)

## 현재 전투 POC

- 전장: 정확히 10칸
- 플레이어 시작: 3번 칸
- 상대 시작: 8번 칸
- 라운드: `3수 → 3수 → 4수`, 총 10수
- 판정: `대응 → 속공 → 이동 → 일반 공격`
- 같은 단계의 공격: 동시 피해
- 10수 완료: 전투 종료가 아니라 다음 라운드 진입
- 절초 기세: 최대 5칸
- 기초 행동 8종: 이동·보법·막기·회피·속공·강공·명상·태세
- 비용: 행동 슬롯·기력·내력
- 덱·손패·행동력 없음

구현 범위:

```text
STEP 0~10
+ TARGETING 10.5 이동 칸·공격 방향 지정
+ RESPONSE 10.6 막기·회피·태세 대응 연계
+ RESOURCE PREVIEW 10.6 배치 즉시 자원 예상치
```

사용자 Windows Godot에서 STEP 0~10과 대상 지정까지 확인했습니다. RESPONSE 10.6 최신 판정과 자원 미리보기의 사용자 런타임 재확인은 남아 있습니다.

## 대응·이동 규칙 보완

- 강공: 행동 슬롯 2, 사거리 2, 기력 1·내력 1, 지정 방향 거리 1·2 공격
- 보법: 행동 슬롯 1, 내력 1, 좌우 1칸 또는 2칸 선택 이동
- 막기: 같은 수 공격은 피해 50% 감소, 같은 묶음은 방어도 감소, 둘 중 높은 감소량 적용
- 회피: 같은 수 공격 완전 회피
- 태세+막기: 같은 슬롯 결합, 묶음 전체 방어, 방어도 50% 증가
- 태세+회피: 같은 슬롯 결합, 묶음 전체 완전 회피
- 카드 배치 시 기력·내력 소모와 명상 회복 예상치를 HUD에 즉시 표시
- 자원 부족 계획은 진행 버튼을 잠금
- 전투 시작 체력·기력·내력은 최대치이며 시작 패널티가 있을 때만 감소

## 데모·전체판 범위

데모는 1~5전이며 5전째 예선 결승입니다.

- 1~2전: 내부전
- 3~4전: 예선
- 5전: 예선 결승·데모 최종전
- 6~7전: 본선
- 8전: 8강
- 9전: 준결승
- 10전: 결승

절초는 데모 필수 조건이 아니라 상위 성과와 행운으로 먼저 체험할 수 있는 하이라이트입니다.

## 운영체계

현재 프로젝트는 `alsdmlals4-eng/Base@ee265576da7f67d3278f8099dd97d4e714ef0651`의 운영 계약을 프로젝트 구조에 맞게 분화 적용합니다.

- Work Mode: `PLAN / BUILD / REVIEW`
- Skill·Skill Mode: Registry trigger로 자동 선택
- L1 이상: 사용 이유·수행 내용·결과·증거·미검증 보고
- 책임 원본: 질문별 단일 Markdown 또는 JSON
- 발행 정책: `source_only / milestone_sync / always_sync`
- 구형 파일: `audit → reconcile-legacy → 승인된 migrate → verify`
- 변경 검증: 정본 최신성·정적·런타임·접근성·성능·회귀 증거 분리

Base 이전 기준 이후 155개 커밋과 70개 변경 파일의 적용 판정은 `BASE_MAIN_SYNC_AUDIT.md`에 기록합니다.

## 보존·발행 상태

- 기존 `docs/01~11`은 Markdown 책임 원본으로 보존합니다.
- `docs/[백업]`, `docs/[보류]`, Plan, PR·Git 이력은 별도 승인 전 삭제하지 않습니다.
- PDF·Skill Map PDF·선택 DOCX·다이어그램은 발행 도구와 시각 검수 전까지 `MIGRATION_PENDING`입니다.
- Workflow 파일 존재, Actions 성공, Required Check 강제는 서로 다른 상태입니다.
- 사용자 로컬 작업본과 원격은 자동 동기화되지 않습니다.

## 활성 책임 원본

- [게임 기획서](docs/01_GAME_DESIGN.md)
- [전투 규칙](docs/02_COMBAT_RULES.md)
- [구현 콘텐츠 카탈로그](docs/03_CONTENT_CATALOG.md)
- [제품 로드맵](docs/04_ROADMAP.md)
- [전투 POC 명세](docs/05_COMBAT_POC_SPEC.md)
- [핵심무공·심법 데이터](docs/06_STARTING_FACTION_MASTERY_DATA.md)
- [전투 UI·아트 명세](docs/07_COMBAT_UI_SPEC.md)
- [테스트 체크리스트](docs/08_TEST_CHECKLIST.md)
- [전투 시스템 아키텍처](docs/09_COMBAT_SYSTEM_ARCHITECTURE.md)
- [전투·대회 연출 기획서](docs/10_COMBAT_PRESENTATION_PLAN.md)
- [Base 적용·학습 기록](docs/11_BASE_ADOPTION_AND_LEARNING_LOG.md)

## 작업 규칙

- 확정 결정은 해당 책임 원본과 영향 소비자에 반영합니다.
- 새 활성 `v2`, `final`, `latest`, `copy` 파일을 만들지 않습니다.
- UI·VFX·오디오는 전투·성장·저장 결과를 재계산하지 않습니다.
- 변경 후 [문서 갱신 매트릭스]([기획서]/00_프로젝트_허브/DOCUMENT_UPDATE_MATRIX.md)를 확인합니다.
- Base로 일반화할 교훈은 제안 PR·사용자 승인·별도 구현 PR 절차를 따릅니다.
- 실행하지 않은 테스트·렌더·접근성·성능·Branch protection은 완료로 표시하지 않습니다.
