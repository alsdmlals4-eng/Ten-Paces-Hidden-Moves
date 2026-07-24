# Base main 최신 동기화 감사

## 1. 작업 계약

- 대상: `alsdmlals4-eng/Ten-Paces-Hidden-Moves`.
- 프로젝트 구현 기준: PR #7 `agent/t0-combat-poc-board@147a031c75e96bff170d7f99016beb9e85b12066`.
- 이전 Base: `ee265576da7f67d3278f8099dd97d4e714ef0651`.
- 최신 Base: `41a20584dd2ee51d917e5c9d7cab6838e1ceba7e`.
- 비교: 6개 커밋·43개 변경 파일.
- Work Mode: `PLAN → BUILD → REVIEW`.
- 주 Skill: `managing-game-project-operating-system`.
- 구조 Skill: `pruning-stale-and-nonfunctional-material`, `refactoring-with-contract-preservation`, `simplifying-skill-bodies`.
- 보존 Skill: `synchronizing-local-and-github-state`, `maintaining-long-running-task-continuity`.

## 2. 보호 계약

Base 동기화로 다음을 변경하지 않는다.

- 십보강호의 세계관·전투 수치·콘텐츠 방향.
- PR #7의 코드·데이터·씬·자산·Godot addon·제품 런타임 테스트.
- 사용자 Windows·Godot 기술 증거.
- 실행하지 않은 사람 플레이·접근성·Release 성능 상태.
- 사용자 로컬 미커밋 변경.

Base 패키지를 프로젝트에 폴더째 복사하지 않는다. 프로젝트 Registry와 기존 책임 원본에 route·계약·검사를 분화 적용한다.

## 3. Base delta 요약

| 변화군 | 프로젝트 판정 | 적용 |
|---|---|---|
| 프로젝트 코어 식별·확정 | `ROUTE` | 다음 PLAN에서 `identifying-project-core`, `establishing-project-core` 사용 |
| 적대적 검토 | `ROUTE` | 코어·기획·구조 제안의 반례 검토 |
| 계약 보존 리팩터링 | `ADAPT` | exact SHA·보호 prefix·baseline diff |
| Skill 본문 간소화 | `ADAPT` | 로컬 Skill을 절차 router로 축소 |
| stale 자료 가지치기 | `ADAPT` | 날짜별 보정 절·구형 검사·캐시 제거 |
| Git 상태 동기화 | `ADAPT` | PR #7 HEAD 보존·force 금지 |
| 장기 작업 연속성 | `ADAPT` | Plan·checkpoint·Handoff |
| 게임 유저리서치 11영역 | `ROUTE` | 코어·STEP 14 연구 범위에 조건부 사용 |
| 사용자 학습 노트 | `ROUTE` | 작업 이해 자료 요청 시 사용 |
| 시각 대시보드 | `ROUTE` | 정본을 대체하지 않는 파생 대시보드 |
| 엔진 런타임 진단 | `ROUTE` | Godot 재현·원인 격리 필요 시 사용 |
| Base Skill coverage·검사 | `REFERENCE` | Base 자체 검증이며 프로젝트는 route 집합만 검증 |

## 4. 활성 Skill 처리

### Base route

- 이전: 13개.
- 현재: 25개.
- `load_all_skills=false` 유지.
- trigger가 맞는 최소 Skill만 읽는다.
- 전체 ID 집합은 `.github/reference-freshness.json`이 검사한다.

### 프로젝트 로컬

4개를 유지한다.

- `ten-paces-game-design`.
- `combat-ux-and-accessibility`.
- `combat-implementation-handoff`.
- `ten-paces-verification`.

진행 상태·Issue 완료 여부는 Skill 본문에서 제거하고 Active Context·본책·실제 파일을 읽게 했다.

## 5. 구조 최적화 판정

### UPDATE_IN_PLACE

- `AGENTS.md`, README, START_HERE.
- 허브 Context·Map·Gates·Roadmap·Handoff.
- `docs/01~11`.
- Base version·Learning Log.
- Skill Registry·로컬 Skill 4개.
- freshness·운영·Skill checker·통합 test.
- Design Registry required section.

### DELETE_APPROVED

- 추적된 `tools/__pycache__/*.pyc` 3개.

재발 차단:

- `.gitignore`: `__pycache__/`, `*.py[cod]`.

### PRESERVE

- 전투 코드·데이터·씬·자산·addon·제품 런타임 테스트.
- 백업·보류·과거 Plan·Git 이력.
- Legacy Alias의 역사 ID.

## 6. 정본 최신성 개선

기존 검사는 최신 토큰의 존재만 확인해 다음 구조를 허용했다.

```text
구형 계약
→ 문서 하단의 날짜별 최신화 절
```

개선:

- 활성 본문을 현재 계약으로 다시 쓴다.
- 구형 점유·방어·AI·STEP·Base·schema 표현을 금지한다.
- 하단 최신화 절이 있어도 stale 문장이 남으면 실패한다.
- board schema 16을 JSON으로 직접 검사한다.
- Base SHA와 route 값 집합을 JSON으로 직접 검사한다.
- route 누락·중복과 schema drift 반례를 추가한다.

## 7. 공용/프로젝트 경계

### Base 공용

- 코어 판정·승인·적대적 검토 방법.
- 가지치기·간소화·리팩터링·Git 동기화·연속성 방법.
- 유저리서치·런타임 진단 절차.
- 정본 최신성·변경 검증 방법.

### 프로젝트 고유

- 10칸·4/7·3/3/4.
- 밀착·합·방어·필중·중단·강건.
- 절초 3종·자원·기세 수치.
- Godot 경로·자산·테스트.
- T0/T1/T2/10전 범위와 세력·성장 가설.

## 8. 검증 계획

1. Design Registry required section 검사.
2. freshness structured·stale 반례.
3. local Skill integrity.
4. 통합 Governance unittest.
5. 기준 SHA 대비 전체 changed file 확인.
6. 제품 보호 prefix 변경 0건 확인.
7. Draft 정합화 PR 생성.
8. Documentation Governance·Card Component Contract Actions.
9. head SHA 불변 확인.

## 9. 현재 판정

```yaml
base_delta_audit: PASS_SOURCE
project_adaptation: APPLIED_IN_REFRESH_BRANCH
product_preservation: PENDING_FINAL_DIFF
governance_actions: NOT_RUN_ON_REFRESH_HEAD
human_step14: NOT_RUN
integration: NOT_STARTED
```

최신 실행 증거 전에는 최종 PASS로 승격하지 않는다.
