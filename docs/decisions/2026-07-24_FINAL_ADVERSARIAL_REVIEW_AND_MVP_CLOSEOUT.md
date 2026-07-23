# 최종 적대적 검토 및 MVP 마감 보고서

> 작성일: 2026-07-24
> 저장소: `alsdmlals4-eng/Ten-Paces-Hidden-Moves`
> 검토 base: PR #7 `agent/t0-combat-poc-board@659c57e7ffa588ad6a6471ed9b5394985b159eaf`
> 검토 head 시작점: PR #15 `agent/project-core-confirmation@ff3787325efff19894e66bde440895fb15cb6a66`
> 최종 판정: `REVISE`
> MVP 판정: `MVP_NOT_COMPLETE`

## 1. 최종 판정

```yaml
final_decision: REVISE
project_core: CORE_CONFIRMED
product_gate: REPEAT_POC
mvp_completion: NOT_GRANTED
human_step14: NOT_RUN
assistive_technology_validation: NOT_RUN
release_performance: NOT_RUN
branch_protection_required_checks: UNVERIFIED
full_conversation_review: UNVERIFIED_CONTEXT
```

프로젝트 코어 문서화는 유지한다. 그러나 활성 정본의 남은 기준 SHA 불일치, 전장 데이터의 AI source 의미 충돌, 결정적 복기·읽을 수 있는 라이벌 성향 미구현, 사람 STEP 14 부재, Required Check 강제 미확인 때문에 구현 완료·MVP 완료를 선언하지 않는다.

## 2. 작업 목표와 완료 기준

목표는 새 기능을 자유롭게 추가하는 것이 아니라 다음을 증거로 마감하는 것이다.

1. 접근 가능한 대화의 최신 승인·기각·보류 결정 추적.
2. 코어 문서·운영 진입점·Issue·PR·실제 구현의 일치.
3. 구형 경로·SHA·상태·Skill·Schema의 활성 참조 차단.
4. 5회 적대적 검토와 최소 수정.
5. 최신 Actions·PR·커밋·PDF 파생본 확인.
6. 필수 미검증이 남으면 완료 선언 금지.

## 3. 검토한 현재 대화 범위

- 최신 사용자 지시: 최종 적대적 검토·5회 개선 루프·GitHub 최신성·PDF·커밋·푸시·PR 마감.
- 현재 컨텍스트에 노출된 사용자·어시스턴트 메시지와 첨부 마크다운을 검토했다.
- 시스템이 이전 대화 일부를 생략해 제공했으므로 전체 대화를 처음부터 끝까지 읽었다고 주장하지 않는다.
- 생략된 대화에만 존재할 수 있는 승인·기각·보류 결정은 `UNVERIFIED_CONTEXT`다.

## 4. 대화 결정 원장

| 결정·요구사항 | 대화 상태 | 최신 사용자 의도 | 반영 책임 원본 | 실제 구현·데이터 경로 | 검증 상태 | 필요한 조치 |
|---|---|---|---|---|---|---|
| 10칸·4/7·3/3/4 | CONFIRMED | 유지 | `docs/01`, `docs/02` | `data/combat`, `src/combat`, tests | 구현·기술 증거 | 보호 |
| 합·방어·필중·중단·강건 | CONFIRMED | 유지 | `docs/02_COMBAT_RULES.md` | engine·data·Godot tests | 구현·자동 증거 | 사람 복기 검증 |
| 공개 정보만 보는 AI | CONFIRMED | 치팅 금지 유지 | `docs/02`, `docs/09` | `combat_ai_planner.gd` | 코드·테스트 | source 의미 충돌 수정 |
| 프로젝트 코어 | LATEST_OVERRIDE | `CORE_CONFIRMED` | `docs/01_GAME_DESIGN.md` | 제품 전체 | 문서 승인 | T1 승인과 분리 |
| 코어와 T1 게이트 분리 | CONFIRMED | `REPEAT_POC` | `docs/04`, Active Context | 없음 | 문서 | 유지 |
| 결정적 복기 | PROPOSED_ONLY | 다음 POC 최소 실험 | 통합 구현계획 | 현재 독립 구현 없음 | NOT_STARTED | 별도 승인·구현·테스트 |
| 읽을 수 있는 라이벌 성향 | PROPOSED_ONLY | 다음 POC 최소 실험 | 통합 구현계획 | 현재 단일 결정 사다리 | NOT_STARTED | 후보 정책·사람 발견 검증 |
| 12세력·10성·10전 | DEFERRED | T1 뒤 판단 | `docs/03`, `docs/04`, `docs/06` | 미구현 | DEFER | 선제 제작 금지 |
| 덱·손패·행동력·내공·집중 | REJECTED | 추가하지 않음 | `docs/02`, AGENTS | 데이터·UI에 없음 | 정적 계약 | 재제안 금지 |
| 사람 STEP 14 | UNRESOLVED | 실제 신규 플레이어로 실행 | `docs/05`, `docs/08` | 연구 빌드 없음 | NOT_RUN | MVP 차단 |
| 전체 대화 결정 | UNVERIFIED_CONTEXT | 접근 가능 범위만 판정 | 이 보고서 | 해당 없음 | UNVERIFIED | 사용자 확인 가능 |

## 5. 프로젝트 코어와 보호 대상

### 코어

- 1대1 무협 라이벌 결투.
- 10칸 선형 전장.
- 비공개 `3수 → 3수 → 4수` 계획.
- 공개 정보와 반복 습관에 기반한 상대 읽기.
- 덱·손패 없는 소수 공용 행동.
- 위치·순서·합·대응·중단 우선.
- AI의 미확정 계획 읽기 금지.
- 설명 가능한 판정과 다음 계획 변경.

### 보호 경로

- `data/`
- `src/`
- `scenes/`
- `assets/`
- `addons/`
- `project.godot`
- 제품 Godot 런타임 테스트

이번 마감 작업은 위 제품 경로를 수정하지 않는다.

## 6. 확인한 책임 원본과 실제 파일

- `AGENTS.md`
- `START_HERE.md`
- 허브 `START_HERE`, `ACTIVE_CONTEXT`, `DOCUMENTATION_MAP`, `DEVELOPMENT_GATES`, `ROADMAP`, `HANDOFF`
- `docs/BASE_RULES_VERSION.md`
- `docs/01~11`
- 두 코어 decision 문서
- Design Document Registry·Skill Registry
- `.github/reference-freshness.json`
- `.github/workflows/documentation-governance.yml`
- `tests/test_project_governance.py`
- Issue #13
- PR #7·#14·#15
- 실제 AI·판정·전장 데이터와 대표 Godot 테스트

## 7. 적대적 검토 1차 결과 — 대화·요구사항·책임 범위

### Attack

- 최신 코어 승인 뒤에도 최상위 진입점이 이전 상태를 가리키는가.
- 사용자 보류·기각 기능이 누락 기능으로 재등장하는가.
- 코어 확정과 MVP 완료가 혼합되는가.

### Validate

- `AGENTS.md`, 루트·허브 `START_HERE`, Base 버전, Gates, 운영 Roadmap, Handoff가 `147a...`, 구 정합화 브랜치 또는 `CORE_REVIEW_PENDING`을 현재 상태로 기록했다.
- PR #15의 `docs/01`·Active Context는 `CORE_CONFIRMED / REPEAT_POC`다.
- 사람 STEP 14는 모든 현재 책임 원본에서 `NOT_RUN`이다.

### Finding

- `F-01` 활성 운영 진입점 상태 충돌: `MUST_FIX / HIGH`.
- `F-02` 전체 대화 일부 생략: `UNVERIFIED / HIGH`.
- `F-03` 코어 확정을 MVP 완료로 오인할 위험: `MUST_FIX / HIGH`.

### 최소 변경

- 운영 진입점의 기준 SHA·코어·제품 게이트를 현재 상태로 동기화했다.
- `CORE_CONFIRMED`와 `REPEAT_POC`를 같은 문맥에서 유지했다.
- 생략 대화는 `UNVERIFIED_CONTEXT`로 남겼다.

### Regression Recheck

- 10칸·4/7·3/3/4·제품 보호 경로·제외 기능은 변경하지 않았다.

## 8. 적대적 검토 2차 결과 — 논리·모순·판정 가능성

### Attack

- “상대 습관을 읽는다”는 코어 약속이 현행 AI에서 관찰 가능한가.
- “내 예상과 실제를 비교한다”는 구현계획이 플레이어 가설을 실제로 기록하는가.
- 완료 기준이 기계와 사람 증거를 혼합하는가.

### Validate

- 현행 AI는 공개 상태를 사용하지만 조건별 대표 행동 하나를 고르는 최소 결정 사다리다.
- 현행 입력에는 플레이어 가설 snapshot이 없다.
- 현재 결과 UI는 수별 사건과 로그를 제공하지만 묶음 단위 결정적 복기 계약은 구현되지 않았다.

### Finding

- `F-04` 라이벌 성향 약속과 현행 AI 능력 차이: `MUST_FIX / HIGH` — 사람 STEP 14 전.
- `F-05` 기록하지 않은 가설을 복기에서 추정할 위험: `MUST_FIX / HIGH` — 복기 구현 전.
- `F-06` 기계 STEP 14를 사람 증거로 오인할 위험: 현재 문서에서 분리됨, `REJECT`.

### 최소 변경

- 운영 문서에서 결정적 복기·라이벌 성향을 “구현 완료”가 아니라 다음 POC 실험으로 유지했다.
- 실제 가설 기록 없이 `내 예상`을 생성하지 않는 조건을 후속 구현 게이트로 남겼다.

### Regression Recheck

- AI 입력 공정성·결정론·현행 판정 엔진을 변경하지 않았다.

## 9. 적대적 검토 3차 결과 — 경계 조건·데이터·호환성

### Attack

- 데이터와 코드가 AI source를 같은 의미로 설명하는가.
- 기준 SHA·Schema·상태가 모든 활성 문서에 전파됐는가.
- 저장·재시작·실패 복구와 롤백이 명시됐는가.

### Validate

- `data/combat/combat_board_poc.json`에는 `fixed_enemy_preview_plan: true`가 남아 있다.
- `data/combat/combat_resolution_preview.json`은 `enemy_plan_source: public_state_ai`, `enemy_bundles: {}`다.
- `CombatBoardPreview`는 `ai_enabled = true`, 엔진은 `CombatAiPlanner`를 사용한다.
- `docs/02`, `docs/05`, `docs/08`, `docs/09`의 구현 기준 헤더는 여전히 이전 `147a...`다.
- 종료·4/7 재시작은 코드·테스트에 존재한다. 저장·불러오기는 T0 제외 범위다.

### Finding

- `F-07` AI source 의미 충돌: `MUST_FIX / HIGH`.
- `F-08` 활성 제품 문서의 구현 기준 SHA drift: `MUST_FIX / HIGH`.
- `F-09` 저장·불러오기 누락 주장: 현재 T0 제외 범위이므로 `REJECT`.

### 최소 변경

- 운영 진입점 기준은 `659c...`로 수정했다.
- 제품 데이터와 전문 문서의 수정은 별도 제품 계약 PR이 필요하므로 이번 문서-only 마감에서 몰래 수정하지 않았다.

### Regression Recheck

- 데이터·코드·씬·Godot 테스트 diff 0을 유지했다.

## 10. 적대적 검토 4차 결과 — 플레이어 경험·UX·접근성·운영

### Attack

- 플레이어가 왜 졌는지 이해하고 다음 계획을 바꿀 수 있는가.
- 모든 행동·절초·수치가 첫 플레이를 과부하시킬 수 있는가.
- 핵심 정보가 색·모션·음향 하나에 의존하는가.
- 기술 옵션 존재가 실제 사용자 접근성을 증명하는가.

### Validate

- 키보드 포커스·모션 감소·음향 제어와 기술 테스트는 존재한다.
- 실제 보조기기 사용자·주관적 음향/모션·외부 플레이는 `NOT_RUN`이다.
- 현재 화면은 기초 행동 8종·절초 3종을 제공하고 결정적 복기 패널은 없다.
- 단계적 온보딩은 계획이며 구현되지 않았다.

### Finding

- `F-10` 결정적 복기 부재: `MUST_FIX / HIGH` — 사람 STEP 14 전.
- `F-11` 첫 플레이 정보 과밀 위험: `SHOULD_FIX / MEDIUM`.
- `F-12` 보조기기·주관적 읽기성: `UNVERIFIED / HIGH`.
- `F-13` Release 성능 예산: `UNVERIFIED / MEDIUM`.

### 최소 변경

- 사람 증거와 기술 증거의 독립 상태를 운영 진입점에 유지했다.
- 새 UI·온보딩·연구 시스템을 이번 마감에 추가하지 않았다.

### Regression Recheck

- 기존 키보드·모션 감소·음향 제어 계약을 완료 증거로 과대해석하지 않았다.

## 11. 적대적 검토 5차 결과 — GitHub 최신성·통합 회귀·PR

### Attack

- 모든 활성 진입점이 현재 정본을 참조하는가.
- PR 설명이 실제 head와 일치하는가.
- 최신 Actions와 Required Check가 확인됐는가.
- PDF·Manifest 정책을 위반하는가.

### Validate

- PR #15 시작 head `ff378732...`의 Documentation Governance run #466은 성공했다.
- 그러나 해당 검사도 운영 진입점 상태 충돌을 통과시켰다.
- PR #7 본문은 한 칸 한 명·고정 계획·STEP 11~14 미구현 등 구형 내용을 현재 체크리스트로 유지한다.
- PR #15에는 unresolved review thread와 review submission이 없다.
- 저장소 등록 문서와 Skill Registry는 `source_only`; 저장소 PDF generator·Manifest는 없다.
- Branch protection Required Check 강제는 확인 도구가 없어 `UNVERIFIED`다.

### Finding

- `F-14` PR #7 본문 stale: `MUST_FIX / HIGH`.
- `F-15` Governance 의미 상태 회귀 누락: `MUST_FIX / HIGH` — 이번 작업에서 test 보강.
- `F-16` 최신 head Actions: `UNVERIFIED / HIGH` — 새 커밋 실행 대기.
- `F-17` 저장소 Manifest 강제 생성: `source_only` 정책 위반이므로 `REJECT`.
- `F-18` Required Check 강제: `UNVERIFIED / HIGH`.

### 최소 변경

- 운영 상태 회귀 테스트를 `tests/test_project_governance.py`에 추가했다.
- PR #7·#15 설명 갱신을 본 작업의 PR 마감 단계로 지정했다.
- PDF는 사용자용 파생본으로만 생성한다.

### Regression Recheck

- PR #15 base는 PR #7 `659c...`로 유지한다.
- 제품 보호 경로를 수정하지 않는다.
- PR #15는 최신 checks 전 병합하지 않는다.

## 12. MUST_FIX / SHOULD_FIX / DEFER / REJECT / UNVERIFIED

### MUST_FIX

- `F-01` 운영 진입점 상태 충돌 — 이번 작업에서 수정.
- `F-03` 코어/MVP 상태 혼동 — 이번 작업에서 수정.
- `F-04` 읽을 수 있는 라이벌 성향 — STEP 14 전 구현·검증 필요.
- `F-05` 가설 기록 없는 복기 — 복기 구현 전 계약 수정 필요.
- `F-07` AI source 데이터 의미 충돌 — 별도 제품 계약 수정 필요.
- `F-08` docs/02·05·08·09 기준 SHA drift — 활성 제품 문서 갱신 필요.
- `F-10` 결정적 복기 부재 — 사람 STEP 14 전 필요.
- `F-14` PR #7 본문 stale — PR 메타데이터 갱신 필요.
- `F-15` Governance 상태 회귀 누락 — 이번 작업에서 test 보강.

### SHOULD_FIX

- `F-11` 단계적 온보딩과 절초 역할 중심 정보 위계.

### DEFER

- 12세력·10성·10전·대형 경제·저장·영구 메타.
- 목표 장치 성능 예산의 구체 수치는 목표 플랫폼 확정 뒤.

### REJECT

- 덱·손패·행동력·내공·집중 재도입.
- T0 저장·불러오기를 현재 누락 결함으로 판정.
- `source_only` 문서에 저장소 Manifest·always_sync PDF를 강제.
- 기계 시나리오를 사람 증거로 대체했다는 비판 — 문서가 명시적으로 분리한다.

### UNVERIFIED

- 생략된 대화의 결정.
- 신규 플레이어 STEP 14.
- 실제 보조기기 사용자.
- 주관적 음향·모션 읽기성.
- Release 목표 장치 성능.
- Branch protection Required Check 강제.
- 사용자 로컬 미커밋 상태.
- 최신 PR #15 head Actions.

## 13. 실제 반영한 최소 변경

- 최종 실행 계획 추가.
- `AGENTS.md` 기준 SHA·코어·제품 게이트 갱신.
- 루트·허브 `START_HERE.md` 갱신.
- `docs/BASE_RULES_VERSION.md`의 PR #7 기준·검증 상태 갱신.
- `DEVELOPMENT_GATES.md`의 코어 Gate·Canonical Refresh·Vertical Slice 상태 갱신.
- 운영 `ROADMAP.md`를 PR #14 병합·PR #15 마감·STEP 14 순서로 재작성.
- `HANDOFF.md`를 현재 PR·코어·미검증·다음 행동으로 갱신.
- `tests/test_project_governance.py`에 운영 상태 전파 회귀 추가.
- 이 최종 보고서 추가.

제품 코드·데이터·씬·자산·Godot 테스트는 수정하지 않았다.

## 14. Red → Green → Refactor 증거

### Red

작업 시작 시 다음 활성 파일에서 구 상태를 직접 확인했다.

- `AGENTS.md@15e2b0...`: `147a...`, `CORE_REVIEW_PENDING`.
- `START_HERE.md@35dad3...`: `147a...`, `CORE_REVIEW_PENDING`.
- 허브 `START_HERE.md@b5561e...`: `147a...`, 구 코어 순서.
- `docs/BASE_RULES_VERSION.md@a9f6e3...`: 전투 기준 `147a...`.
- `DEVELOPMENT_GATES.md@2405d0...`: Project Core Gate 전체 미완료.
- `ROADMAP.md@e43686...`: 정합화·코어 PLAN이 미착수.
- `HANDOFF.md@f02468...`: 구 정합화 브랜치·구 코어 상태.

### Green

- 최신 기준 `659c57e7...`, `CORE_CONFIRMED`, `REPEAT_POC`, `T1_NOT_GRANTED`로 문서 본문을 교정했다.
- 새 회귀 테스트가 동일 파일의 required/forbidden 상태를 검사한다.

### Refactor

- 날짜별 보정 절을 추가하지 않고 현재 본문 자체를 갱신했다.
- 과거 상태는 상태 전이·Git 이력으로 남기고 현재 실행 순서만 축약했다.
- 제품 규칙과 데이터에는 손대지 않았다.

## 15. GitHub 최신성·구형 참조 감사

| 파일·참조 | 현재 역할 | 최신 정본 | 구형 여부 | 활성 소비자 | 필요한 조치 | 검증 결과 |
|---|---|---|---|---|---|---|
| `AGENTS.md` | 최상위 계약 | 자체 | UPDATE_REQUIRED→수정 | 모든 작업 | 기준·게이트 갱신 | 수정됨 |
| 루트 `START_HERE` | 최초 진입 | AGENTS·Context | UPDATE_REQUIRED→수정 | 사용자·AI | 현재 순서 | 수정됨 |
| 허브 `START_HERE` | 허브 진입 | Active Context | UPDATE_REQUIRED→수정 | 사용자·AI | 현재 상태 | 수정됨 |
| `ACTIVE_CONTEXT` | 현재 상태 | 자체 | CURRENT_CANONICAL | Entry points | 최종 head 반영 | 후속 갱신 |
| `DEVELOPMENT_GATES` | 제품·작업 게이트 | 자체 | UPDATE_REQUIRED→수정 | Roadmap·Handoff | 코어/VS 상태 | 수정됨 |
| 운영 `ROADMAP` | 운영 순서 | docs/04 연결 | UPDATE_REQUIRED→수정 | Handoff | 현재 단계 | 수정됨 |
| `HANDOFF` | 인수 스냅샷 | Active Context | UPDATE_REQUIRED→수정 | 새 세션 | 기준·다음 행동 | 수정됨 |
| `docs/02/05/08/09` 헤더 | 제품 책임 원본 | PR #7 659c | UPDATE_REQUIRED | 구현·QA | old SHA 제거 | 남음 |
| `combat_board_poc.fixed_enemy_preview_plan` | 전장 메타 | resolution data·code | CONFLICTING_SOURCE | tests·docs | 의미 정렬 | 남음 |
| 백업·보류 | 역사·HOLD | Git/명시 경로 | HISTORICAL_ARCHIVE | 기본 읽기 제외 | 삭제 금지 | 허용 |
| 구형 Skill ID alias | 호환 | LEGACY aliases | ACTIVE_COMPATIBILITY | 검색·migration | 새 문서 사용 금지 | 허용 |

## 16. 책임 원본·Registry·Documentation Map 동기화

- 프로젝트 코어 정본: `docs/01_GAME_DESIGN.md`.
- 코어 확정 근거: `docs/decisions/2026-07-23_PROJECT_CORE_DECISION_RECORD.md`.
- 통합 구현계획: `docs/decisions/2026-07-23_CORE_INTEGRATED_SPEC_AND_IMPLEMENTATION_PLAN.md`.
- 최종 마감 증거: 이 보고서.
- 제품 판정·데이터는 기존 책임 원본이 유지한다.
- 이 보고서는 제품 규칙 정본을 대체하지 않는다.
- Documentation Map과 Active Context는 최종 head에서 이 보고서와 현재 판정을 연결해야 한다.

## 17. 정적·런타임·회귀 검증 결과

| 검증 | 상태 | 증거·경계 |
|---|---|---|
| PR #15 시작 head Governance | PASS | run #466, `ff378732...` |
| 새 운영 상태 regression | PENDING | 최신 Actions 필요 |
| Card/Combat Contract 최신 head | PENDING | 최신 Actions 필요 |
| 기준 SHA 대비 제품 경로 diff | PASS/PENDING_FINAL | 시작 head 7개 문서만 변경, 최종 compare 재확인 필요 |
| Godot runtime | NOT_RUN_THIS_CHANGE | 제품 코드 변경 없음, 기존 증거 재사용 금지 |
| Windows 사용자 흐름 | NOT_RUN | 환경 없음 |
| 사람 STEP 14 | NOT_RUN | 참가자·빌드 없음 |
| 접근성 사용자 | NOT_RUN | 참가자 없음 |
| Release 성능 | NOT_RUN | 목표 장치·예산 없음 |

## 18. PDF·Manifest·전 페이지 렌더 결과

- 저장소 등록 문서 정책: `source_only`.
- 저장소 PDF generator: 없음.
- 저장소 Publication Manifest: 없음이 정상.
- 사용자용 파생 PDF는 이 Markdown을 기준으로 별도 생성한다.
- PDF 생성 뒤 모든 페이지를 PNG로 렌더해 한글·표·잘림·빈 페이지를 확인한다.
- 사람이 실제로 열어 확인하기 전 `human_visual_review: NOT_RUN`.

## 19. PR 및 Required Check 결과

### PR #15

- 상태: Open, mergeable.
- base: `agent/t0-combat-poc-board@659c57e7...`.
- 시작 head: `ff378732...`.
- unresolved review thread: 0.
- submitted review: 0.
- 시작 head Governance: PASS.
- 최신 head checks: PENDING.
- 병합 판정: `REVISE`.

### PR #7

- 상태: Draft, Open, mergeable.
- head: `659c57e7...`.
- 본문: 현행 구현과 불일치하는 구형 체크리스트가 남음.
- 필요한 조치: 제목·본문을 STEP 0~13·Issue #13·현재 미검증으로 갱신.

### Required Check

- Workflow 실행 결과와 branch protection 강제 여부는 다르다.
- 현재 connector로 branch protection Required Check 강제를 확인하지 못해 `UNVERIFIED`다.

## 20. 커밋 목록과 각 커밋 목적

- `c3007ec1` — 최종 마감 실행 계획.
- `698df68d` — 루트 프로젝트 계약 현재화.
- `784acba9` — 루트 시작 지점 현재화.
- `14e22962` — 허브 시작 지점 현재화.
- `d49450e5` — Base 버전·검증 상태 현재화.
- `d86037ff` — 개발 게이트 현재화.
- `56b8c6cc` — Handoff 현재화.
- `0821969d` — 운영 Roadmap 현재화.
- `8b68b59e` — 운영 상태 회귀 테스트.
- 이 보고서 커밋 — 적대적 검토·판정·증거.

GitHub contents API가 각 파일 갱신을 독립 커밋으로 기록했다.

## 21. MVP 파일 갱신 결과

별도 이름의 단일 `MVP` 파일은 현재 Documentation Map과 code search에서 확인되지 않았다. MVP/Prototype 상태는 다음 책임 원본이 공동으로 연결한다.

- `docs/04_ROADMAP.md`
- `docs/05_COMBAT_POC_SPEC.md`
- `docs/08_TEST_CHECKLIST.md`
- 허브 `DEVELOPMENT_GATES.md`
- `ACTIVE_CONTEXT.md`

현재 판정은 `IMPLEMENTED / HUMAN_STEP14_NOT_RUN / REPEAT_POC`다.

## 22. 원격 푸시 결과

- 로컬 `gh` CLI와 GitHub 네트워크 clone은 현재 실행 환경에서 사용할 수 없었다.
- GitHub connector contents API로 `agent/project-core-confirmation` 원격 브랜치에 직접 커밋했다.
- 각 write action은 원격 commit SHA를 반환했다.
- 최종 head와 PR 반영은 마지막 검증에서 다시 확인한다.

## 23. 남은 위험·미검증·후속 작업

1. docs/02·05·08·09의 old baseline SHA 수정.
2. `fixed_enemy_preview_plan`과 `public_state_ai` 의미 정렬.
3. 플레이어 가설을 실제 기록하는 최소 연구 계약.
4. 결정적 복기 summary와 UI.
5. 읽을 수 있는 라이벌 후보 정책.
6. 동일 SHA의 신규 플레이어 STEP 14.
7. 접근성 사용자·주관적 오디오/모션 검수.
8. 목표 플랫폼 Release 성능 예산.
9. branch protection Required Check 강제 확인.
10. 생략된 대화 결정의 사용자 확인.

## 24. 사람이 직접 확인할 체크리스트

- [ ] PDF 전 페이지를 실제로 열어 읽었다.
- [ ] 코어 한 문장이 의도와 일치한다.
- [ ] 로그라이트 성장과 결투 코어의 우선순위가 의도와 일치한다.
- [ ] 대화 원장에서 누락된 승인·기각·보류가 없다.
- [ ] PR #15의 `REVISE` 판정에 동의한다.
- [ ] docs/02·05·08·09와 AI source 수정 범위를 승인한다.
- [ ] 결정적 복기·라이벌 성향을 STEP 14 전 선행 작업으로 승인한다.
- [ ] 실제 신규 플레이어 5명 테스트를 실행할 수 있다.
- [ ] PR #7 본문 갱신 내용이 현행 구현과 일치한다.

## 25. Base 공용 규칙 승격 후보

- 코어 상태 변경 시 AGENTS·START_HERE·Gates·Roadmap·Handoff의 required state를 자동 검사한다.
- 자연어 token 존재만 아니라 서로 다른 활성 문서의 상태 조합을 검사한다.
- “가설을 기록하지 않았으면 복기에서 플레이어 예상이라고 추정하지 않는다.”
- Workflow 성공과 branch protection Required Check 강제를 독립 증거로 기록한다.
- source_only 저장소의 사용자 요청 PDF는 저장소 정본·Manifest와 분리한다.

승격 전 다른 프로젝트 재현과 BCP 사용자 승인이 필요하다.

## 26. 프로젝트 전용으로 유지할 내용

- 10칸·4/7·3/3/4.
- 합·밀착·중단·강건·기세 5.
- 기초 행동 8종·절초 3종.
- 십보강호 라이벌 성향·가설 범주·복기 문구.
- Godot 파일·씬·데이터·테스트 경로.
- STEP 14의 5명 발견형 통과 신호.
- T1 2스타일·3상대·3전 범위.

---

## 종료 판정

```yaml
project_core: CORE_CONFIRMED
current_poc: STEP_0_TO_13_IMPLEMENTED
human_step14: NOT_RUN
remaining_must_fix: true
required_unverified: true
final_decision: REVISE
mvp_complete: false
```

다음 검증에서 남은 `MUST_FIX`를 제거하고 최신 Actions·사람 증거·Required Check를 확인하기 전에는 `ACCEPT`, `ACCEPT_WITH_FOLLOWUP`, “구현 완료”, “MVP 완료”를 사용하지 않는다.
