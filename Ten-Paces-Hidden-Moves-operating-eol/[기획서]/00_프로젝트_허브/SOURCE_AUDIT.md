# 십보강호 기존 구조·구형 자료 감사

## 1. 기준

- 구현 기준: PR #7 `agent/t0-combat-poc-board@147a031c75e96bff170d7f99016beb9e85b12066`.
- 정합화 브랜치: `agent/pr7-canonical-skill-refresh`.
- Base: `41a20584dd2ee51d917e5c9d7cab6838e1ceba7e`.
- 최신 승인: Issue #13.
- 사용자 로컬 미커밋 상태: `UNVERIFIED`.

## 2. 절차

```text
PLAN: audit
→ current/history/hold/removal 분류
→ 고유 정보·활성 참조·복구 확인
→ 사용자 승인 범위 확인
→ BUILD: UPDATE·MERGE·STUB·ARCHIVE·DELETE
→ REVIEW: reference-freshness·baseline diff·회귀
```

## 3. 보호 범위

- PR #7의 `data/`, `src/`, `scenes/`, `assets/`, `addons/`, `project.godot`.
- 제품 Godot 런타임 테스트.
- 프로젝트 고유 세계관·수치·ID·경로.
- 백업·보류·과거 Plan·Git 이력.
- 사용자 로컬 미커밋 변경.
- 실행하지 않은 검증의 미검증 상태.

## 4. 활성 구조

```text
README.md
START_HERE.md
AGENTS.md
[기획서]/DESIGN_DOCUMENT_REGISTRY.json
[기획서]/00_프로젝트_허브/
docs/01~11 + BASE_RULES_VERSION.md
skills/ 프로젝트 고유 4개 + Alias + Learning Log
schemas/
templates/
.github/ Governance·freshness·workflows
tools/ 운영·제품 검사
tests/
data/ scenes/ src/ assets/ addons/
project.godot
```

## 5. 자료 판정

| 경로·유형 | 역할 | 판정 |
|---|---|---|
| README·START_HERE·AGENTS | 최소 진입·최상위 계약 | `CURRENT` |
| 허브 Active Context·Map·Gates·Roadmap·Handoff | 현재 운영 상태·라우팅 | `CURRENT` |
| `docs/01~11` | 제품 책임 원본 | `CURRENT` |
| `docs/BASE_RULES_VERSION.md` | Base SHA·공용/전용 차이 | `CURRENT` |
| Design Registry | 책임 원본·발행 상태 | `CURRENT` |
| Skill Registry | Base 25 route·로컬 4개 | `CURRENT` |
| 로컬 Skill 4개 | 프로젝트 고유 판단 절차 | `CURRENT` |
| Legacy Alias | 과거 Skill ID 호환 검색 | `HISTORY_COMPATIBILITY` |
| `data/`, `src/`, `scenes/`, `assets/`, `tests/` | PR #7 제품 구현 | `PROTECTED_CURRENT` |
| `docs/[백업]/` | 복구·역사 | `ARCHIVE_HISTORY` |
| `docs/[보류]/` | 재개 승인 대기 | `KEEP_UNRESOLVED` |
| 과거 Plan·닫힌 PR·Git 이력 | 당시 결정·복구 | `HISTORY` |
| 열린 구형 Draft PR | 혼동 위험 | `SUPERSEDE_AFTER_UNIQUE_INFO_REVIEW` |

## 6. 이번 UPDATE_IN_PLACE

- 활성 본책에서 날짜별 보정 절과 구형 계약 제거.
- README·Entry Point·Context·Map·Gates·Roadmap·Handoff 최신화.
- Base `41a205...`·25 Skill route.
- 로컬 Skill 4개의 절차 router 간소화.
- Design Registry required section의 Issue명 제거.
- board schema 16·Base SHA·Skill 집합 구조 검사.
- stale 보정 절·schema·route 반례 추가.

## 7. 이번 DELETE_APPROVED

추적 생성물:

- `tools/__pycache__/check_canonical_reference_freshness.cpython-312.pyc`.
- `tools/__pycache__/check_project_operating_system.cpython-312.pyc`.
- `tools/__pycache__/check_skill_package_integrity.cpython-312.pyc`.

이 파일은 실행 원본이 아니며 Git에서 복구할 가치가 없는 생성 캐시다. `.gitignore`로 재발을 막는다.

## 8. 계속 금지하는 재등장

- 제거된 로컬 공용 Skill 패키지.
- Project Skill Map PDF·Manifest.
- 실제 생성기 없는 CURRENT PDF·always_sync.
- 두 수 비공개 잠금 전투 Skill.
- 활성 본문의 한 칸 한 전투원·공동 목적지 정지·높은 감소량 선택·고정 상대 plan.
- Base `ee265...`와 13 route를 현행으로 사용.
- board schema 13·15.
- 추적 `__pycache__`·`.pyc`.

## 9. 열린 구형 PR 처리 원칙

정합화와 #7 통합 증거 전에는 닫지 않는다. 이후 PR별로 고유 정보를 확인한다.

- #2: 과거 문서 구조·초기 POC 전환 기록.
- #3: 절초 HUD 계획. Issue #11 구현에 승계됐는지 대조.
- #5: 이전 Base 운영체계 migration. 최신 Base audit로 승계.
- #6: 폐기된 11개 분야 Skill Map/PDF 구조. 병합 금지.
- #12: 현행 3/3/4와 다른 두 수 전투 Skill. 공정 AI·결과 설명 원칙만 기존 Skill에 흡수.

고유 정보·참조·복구를 확인한 뒤 `superseded by PR #7` 설명과 함께 종료한다.

## 10. 보존 대조

- 현재 전투 코드·데이터·씬·자산: 변경 금지.
- 10칸·3/3/4·5전·10전·세력·성장 가설: 보존.
- 과거 문서 전문: Git 이력 보존.
- 백업·보류: 물리 보존.
- 공용 운영 기능: Base route·Registry·검사로 승계.

## 11. 미검증

- 기준 SHA 대비 최종 changed file 전체.
- 최신 Governance·Card Actions.
- 사용자 로컬 미커밋 파일.
- 구형 열린 PR의 모든 외부 링크.
- 실제 사용자 STEP 14.
- 접근성 사용자·Release 성능·Branch protection.

## 12. 추가 Cleanup 게이트

추가 삭제·이동은 후보별 고유 정보·활성 참조·복구·사용자 승인과 baseline diff·reference-freshness·회귀를 다시 확인한다.
