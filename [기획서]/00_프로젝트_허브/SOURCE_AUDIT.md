# 십보강호 기존 구조·구형 파일 감사

- 사용자 승인: Base 전면 반영 후 가지치기·간소화·리팩터링·적대적 개선
- Base: `ee265576da7f67d3278f8099dd97d4e714ef0651`
- 최초 대상: `0ac66389ad6b1d10019680ebf1417d423fa1466e`
- 파일별 Base 감사: `BASE_MAIN_SYNC_AUDIT.md`
- 최종 검증: `BASE_MAIN_SYNC_VERIFICATION.md`
- 사용자 로컬 미커밋 상태: `[미검증]`

## 절차

```text
PLAN: audit
→ reconcile-legacy
→ 고유 정보·참조·파생본·복구·롤백 확인
→ 사용자 승인
→ BUILD: 승인된 UPDATE·MERGE·STUB·ARCHIVE·DELETE
→ REVIEW: reference-freshness·회귀·보존 대조
```

## 보호 범위

- `docs/01~11`, `docs/[백업]`, PR·Git 이력
- 프로젝트 세계관·수치·용어·ID·Godot 경로
- 승인 UI·배경·카드·전투 구현과 자산
- 사용자 로컬 미커밋 변경
- 실행하지 않은 검증의 미검증 상태

## 현행 구조

```text
START_HERE.md
AGENTS.md
README.md
docs/
[기획서]/
skills/                  # 프로젝트 고유 Skill 4개 + Learning Log·Alias
templates/               # 실행·reconciliation·컨셉근거·변경검증
schemas/
tools/                   # 운영 검사 3개 + 제품 자동화
tests/                   # 통합 Governance 회귀 + 제품 테스트
.github/
data/
scenes/
src/
project.godot
```

## 책임 인벤토리

| 경로 | 역할 | 판정 |
|---|---|---|
| README·START_HERE·AGENTS | 최소 Entry Point·최상위 규칙 | `CURRENT` |
| `docs/01~11` | 제품 책임 원본 | `CURRENT`, 전투 정본 최신성은 별도 제품 작업 |
| `docs/BASE_RULES_VERSION.md` | Base SHA·프로젝트 차이 | `CURRENT` |
| Design Registry | 책임 원본·현재 `source_only` 상태 | `CURRENT` |
| 프로젝트 허브 | Context·Map·Gates·Audit·이력 | `CURRENT` |
| Base 공유 Skill 13개 | 공용 작업 절차 | `REFERENCE` |
| 프로젝트 Skill 4개 | 십보강호 고유 디자인·UX·구현·QA | `CURRENT` |
| Legacy Alias | 제거된 Base·로컬 Skill ID 호환 | `CURRENT` |
| `data/`, `scenes/`, `src/`, 제품 tests | 전투 POC | `CURRENT`, 일부 런타임 미검증 |
| 백업 | 역사·복구 | `ARCHIVE_HISTORY` |
| 보류 | 재개 승인 전 구현 금지 | `KEEP_UNRESOLVED` |

## 이번 가지치기 처리표

| 제거 경로·ID | 이전 역할 | 승계 위치 | 판정·검증 |
|---|---|---|---|
| `project-operations-and-handoff` | 요청 라우팅·Context·Handoff | Base intake + context/handoff | `DELETE_APPROVED`, Legacy Alias·Skill 검사 |
| `project-health-review` | 운영체계 종합 검수 | Base operating-system + change-validation + freshness | `DELETE_APPROVED`, Legacy Alias·Skill 검사 |
| `PROJECT_SKILL_MAP.md` | Registry 수동 요약 | `SKILL_REGISTRY.json` 직접 읽기 | `DELETE_APPROVED`, forbidden path 검사 |
| Skill Map Manifest | 존재하지 않는 PDF 발행 상태 | `source_only` Registry | `DELETE_APPROVED`, forbidden path 검사 |
| 벤치마크·컨셉 템플릿 2개 | 조사·컨셉 검토 | `GAME_CONCEPT_AND_EVIDENCE_REVIEW.md` | `MERGE_TO_CANONICAL` |
| 정본 최신성 템플릿 | freshness 보고 | `PROJECT_CHANGE_VALIDATION.md` | `MERGE_TO_CANONICAL` |
| 분리 Governance tests 2개 | freshness·Skill 회귀 | `test_project_governance.py` | `MERGE_TO_CANONICAL` |
| `check_documentation_governance.py` | 구형 중복 검사 | `check_project_operating_system.py` | `DELETE_APPROVED`, Workflow 미참조·forbidden path 검사 |

모든 삭제는 사용자 요청의 명시 승인 범위 안에서 수행했다. Git 이력으로 복구 가능하며 제품 코드·본책·자산을 건드리지 않았다.

## 발행 감사

발견:

- Design Registry가 PDF·Manifest·생성기를 선언했지만 `tools/build_design_documents.py`가 존재하지 않았다.
- Registry는 `source_only`로 바뀌었는데 이전 Schema는 `always_sync`를 강제했다.

처리:

- 11개 문서와 Skill Registry를 실제 사용 가능한 `source_only`로 변경.
- 파생 경로·Manifest·generator를 null로 정리.
- Design Registry Schema를 세 정책 조건부 계약으로 수정.
- 정책 승격 시 생성기 파일 존재를 자동 검사.

## stale 방지

- 현행 Entry Point의 `2수·두 행동·7개 기초 행동·이전 Base SHA` 차단.
- 제거된 로컬 Skill·Skill Map·구형 템플릿·중복 checker 경로 재등장 차단.
- Base shared routes 13개와 프로젝트 Skill 정확히 4개 검사.
- changed 파일과 expected-but-untouched 소비자 확인.

## 보존 대조

- 10칸·10수·10전, 5전 데모, 무공·심법·절초: 보존
- UI·연출·아키텍처·QA 본책: 보존
- Godot 코드·데이터·씬·자산: 보존
- 백업·보류·Plan: 보존
- 사용 기능: Base 공유 Skill·통합 템플릿·통합 검사로 승계

## 미검증

- 사용자 로컬 미커밋 파일·원격 차이
- 백업·보류의 모든 외부 참조
- RESPONSE 10.6 최신 Windows 런타임
- PDF 발행 파이프라인·시각 검수
- 접근성·성능·플레이테스트
- Branch protection Required Check 강제

## 추가 Cleanup 게이트

추가 삭제·이동은 후보별 고유 정보·참조·복구·사용자 승인을 다시 확인하고 reference-freshness·회귀·콜드 스타트를 통과해야 한다.
