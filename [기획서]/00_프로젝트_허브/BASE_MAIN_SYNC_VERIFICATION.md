# Base main·PR #7 정합화 검증

## 1. 기준

- Base: `alsdmlals4-eng/Base@41a20584dd2ee51d917e5c9d7cab6838e1ceba7e`.
- 이전 Base: `ee265576da7f67d3278f8099dd97d4e714ef0651`.
- Base delta: 6개 커밋·43개 변경 파일.
- 구현 기준: PR #7 `agent/t0-combat-poc-board@147a031c75e96bff170d7f99016beb9e85b12066`.
- 최신 승인: Issue #13 STEP 12~14.
- 정합화 브랜치: `agent/pr7-canonical-skill-refresh`.
- 파일별 판정: `BASE_MAIN_SYNC_AUDIT.md`.

## 2. 검증 주장

1. Base 최신 공용 책임을 프로젝트에 중복 없이 route했다.
2. 프로젝트 고유 Skill 4개의 기능을 잃지 않았다.
3. Issue #13의 현재 전투 계약이 활성 문서·검사에 일치한다.
4. stale 보정 절·구형 Base·구형 Skill·schema drift가 다시 들어오면 실패한다.
5. PR #7의 Codex 제품 코드·데이터·씬·자산을 변경하지 않았다.
6. 사람 STEP 14와 Release 검증을 완료로 과장하지 않았다.

## 3. 변경 집합

### 문서

- `docs/01~11`을 현재 계약과 단계 상태로 재작성.
- README·START_HERE·AGENTS·허브 Context·Map·Gates·Roadmap·Handoff 갱신.
- Design Registry required section을 Issue명 대신 지속 가능한 책임명으로 변경.

### Skill

- Base 활성 Skill 25개 route.
- 프로젝트 고유 Skill 4개 유지.
- 로컬 Skill에서 STEP·Issue 진행 상태 복제 제거.
- 현재 상태는 Active Context·제품 정본·실제 파일에서 읽도록 변경.

### Governance

- board schema 16 직접 검사.
- Base SHA 직접 검사.
- Base Skill ID 집합·누락·중복 직접 검사.
- 하단 최신 보정 절로 stale 문장을 가릴 수 없는 반례.
- schema drift·Base drift·route 누락/중복 반례.
- Python cache 3개 삭제와 ignore.

## 4. 기능 보존 계약

### Base 공용

- [x] `PLAN / BUILD / REVIEW`.
- [x] trigger 기반 최소 Skill·Skill Mode.
- [x] `load_all_skills=false`.
- [x] execution-report.
- [x] audit·reconciliation·reference-freshness·변경 검증.
- [x] 코어 식별·확정·적대적 검토.
- [x] 가지치기·간소화·계약 보존 리팩터링.
- [x] Git 동기화·연속성·유저리서치·런타임 진단 route.

### 프로젝트 고유

- [x] 전투·성장·대회 디자인.
- [x] 전투 UX·접근성.
- [x] Godot 구현 인수와 baseline 보존.
- [x] 십보강호 규칙·반례·증거.

### 제품 계약

- [x] 10칸·4/7·거리 3·밀착.
- [x] 3/3/4.
- [x] 기초 행동 8종·절초 3종.
- [x] 합·방어·회피·필중.
- [x] 중단·강건.
- [x] 공개 상태 최소 AI.
- [x] 승패·무승부·재시작.
- [x] STEP 14 사람 검증 `NOT_RUN` 유지.

## 5. 적대적 반례

| 반례 | 기대 |
|---|---|
| 구형 점유 규칙 뒤에 최신 갱신 절 추가 | FAIL |
| board schema 15 | FAIL |
| Base commit 불일치 | FAIL |
| Base Skill route 누락 | FAIL |
| Base Skill route 중복 | FAIL |
| 로컬 Skill 4개 초과·누락 | FAIL |
| 삭제한 로컬 공용 Skill 재등장 | FAIL |
| Skill Map PDF·Manifest 재등장 | FAIL |
| source_only에 generator·PDF 선언 | FAIL |
| 제품 보호 prefix 변경 | FAIL/BLOCK |

## 6. 실행할 자동 검증

```text
Python compile
→ project operating-system contract
→ Design Registry required sections
→ canonical reference freshness
→ structured board/Base/Skill contract
→ local Skill package integrity
→ integrated Governance unittest and negative cases
→ Card Component Contract
→ baseline compare
```

## 7. baseline 보존 기준

기준 SHA `147a031c...` 대비 허용 변경:

- 루트 운영 문서.
- `docs/` 활성 기획 문서.
- `[기획서]/` 허브·Registry.
- `skills/` 프로젝트 Skill·Alias·Learning Log.
- `.github/` Governance 설정·Workflow.
- `schemas/`, `tools/` 운영 검사, `tests/test_project_governance.py`.
- `.gitignore`, 실행 계획.
- 추적 생성 캐시 삭제.

허용하지 않는 변경:

- `data/`, `src/`, `scenes/`, `assets/`, `addons/`, `project.godot`.
- 제품 Godot 런타임 테스트.

## 8. 현재 실행 상태

```yaml
source_audit: PASS_SOURCE
canonical_rewrite: APPLIED
base_routes_25: APPLIED
local_skills_4: PRESERVED
negative_tests: ADDED
tracked_cache: REMOVED
local_governance_execution: NOT_RUN
refresh_head_actions: NOT_RUN
baseline_product_preservation: PENDING_FINAL_COMPARE
stacked_pr: NOT_CREATED
human_step14: NOT_RUN
```

## 9. 최종 PASS 조건

- [ ] 통합 Governance unittest 성공.
- [ ] 최신 Documentation Governance Actions 성공.
- [ ] 최신 Card Component Contract 성공.
- [ ] 기준 SHA 대비 제품 보호 경로 변경 0건.
- [ ] 정합화 PR head SHA와 Actions SHA 일치.
- [ ] PR 본문에 기준·보호·미검증 기록.
- [ ] 실패·미검증·롤백이 Active Context·Handoff에 반영.

모든 조건 전 판정은 `IN_PROGRESS`다.
