# 십보강호 제품 문서 지도

> 최상위 운영 지도: [`[기획서]/00_프로젝트_허브/DOCUMENTATION_MAP.md`](../%5B기획서%5D/00_%ED%94%84%EB%A1%9C%EC%A0%9D%ED%8A%B8_%ED%97%88%EB%B8%8C/DOCUMENTATION_MAP.md)

이 파일은 제품 도메인 문서의 **안정적인 찾기 지도**다. active PR·exact SHA·승인 수·제품 stage·next package 같은 mutable state는 여기에 저장하지 않는다.

## 1. 최초 진입

```text
../START_HERE.md
→ ../AGENTS.md
→ PROJECT_TOTAL_PLANNING_IMPLEMENTATION_AND_DELIVERY_INSTRUCTION.md
→ ../[기획서]/00_프로젝트_허브/ACTIVE_CONTEXT.md
→ ../[기획서]/00_프로젝트_허브/DOCUMENTATION_MAP.md
→ 00_TAG_STATUS_REGISTRY.md
→ 질문별 제품 owner
→ actual data/scenes/src/tests/GitHub metadata
→ exact Project Notion when human-facing context is required
```

최신 사용자 승인 Decision과 current owner가 과거 Ledger·백업·구형 구현보다 우선한다. 실제 구현이 planning과 다르면 `IMPLEMENTED_LEGACY` 등 명시 상태로 구분한다.

## 2. 제품 문서 읽기 순서

1. `00_TAG_STATUS_REGISTRY.md` — 제품 태그·전투 키워드·상태 어휘.
2. `01_GAME_DESIGN.md` — 정체성·핵심 루프·제품 범위.
3. `02_COMBAT_RULES.md` — 전투 판정·자원·AI·관찰·3/3/4.
4. `03_CONTENT_CATALOG.md` — 데모·전체판·HOLD 콘텐츠.
5. `04_ROADMAP.md` — 제품 장기 단계와 evidence checkpoint.
6. `05_COMBAT_POC_SPEC.md` — PoC/구현 경계.
7. `06_STARTING_FACTION_MASTERY_DATA.md` — 무공서·기술 성장.
8. `07_COMBAT_UI_SPEC.md` — HUD·입력·접근성.
9. `08_TEST_CHECKLIST.md` — 완료 evidence와 미검증 경계.
10. `09_COMBAT_SYSTEM_ARCHITECTURE.md` — 상태·이벤트·저장·AI.
11. `10_COMBAT_PRESENTATION_PLAN.md` — 판정 사건 연출·복기 표현.
12. `11_BASE_ADOPTION_AND_LEARNING_LOG.md` — Base 채택·제안·검증 역사.
13. `12_VERTICAL_SLICE_JIANGHU_JOURNEY.md` 이후 Vertical Slice 문서 — 승인된 5전 세계/콘텐츠/UX 구조.

사람이 한눈에 이해·비교·수정할 전체 Flow·Visual·핵심 표는 exact Project Notion을 함께 읽는다.

## 3. Current Decision 찾기

Decision 목록을 이 파일에 고정하지 않는다.

```text
ACTIVE_CONTEXT.md
→ CANON_LIFECYCLE_REGISTRY.md
→ 관련 docs/decisions/*.md
→ related planning JSON
→ domain owner
→ exact Project Notion projection when required
```

과거 PR #72/#80/#82 등의 당시 Decision 상태는 역사 evidence이며 current 승인 상태가 아니다.

## 4. 고정 제품 계약

- 1대1 10칸 논리 전장.
- 플레이어-facing 시작 기준은 공개 거리 2이며, 실제 runtime의 4/7 좌표 계보는 구현 binding으로 별도 구분한다.
- 거리 0 `[밀착]`.
- `3수 → 해결 → 3수 → 해결 → 4수 → 해결`.
- 공개 정보와 해결 이력으로 상대를 추론하며 AI는 미확정 플레이어 계획을 읽지 않는다.
- 현재 해금 기술을 수에 배치하고 무공서를 직접 배치하지 않는다.
- `[합]`, 방어도, 회피, 중단, 강건, 복기를 사용한다.
- Windows·Android를 기본 설계 대상으로 하며 단일 공유 전투/AI/데이터/저장 코어 + platform adapters를 사용한다.
- Google Sheets는 `MIGRATION_ONLY_UNTIL_REMOVAL`; 신규 current GDD workspace가 아니다.

정확한 세부 수치·상태는 각 분야 owner와 actual runtime을 읽는다.

## 5. 작업별 최소 읽기

| 작업 | 최소 owner |
|---|---|
| 방향·인수 | Active Context, hub Documentation Map, 01, current GitHub metadata, exact Notion |
| 전투 규칙·밸런스 | 01, 02, 05, 08, 최신 Decision/contract, actual combat data/code |
| 기술 작성·능력치 | 02, 05, 06, current budget JSON, 관련 Decision |
| 무공·성장 | 01, 02, 03, 05, 06, 08, current planning/runtime data |
| 콘텐츠·경로 | 01, 03, 04, Vertical Slice owner, planning JSON, exact Notion |
| UI·접근성 | 02, 07, 08, 09, 10, actual Scene/runtime, exact Notion Visual/Flow |
| 제품 구현 | Active Context, current operating contract, current implementation Gate, relevant owner/test |
| 검수 | 08, current diff, exact-head CI, actual runtime evidence, affected Notion/repository destination |
| Base compatibility | Base latest owner + `BASE_RULES_VERSION.md` + `skills/PROJECT_BASE_ADAPTER.json` |

## 6. 구형·오해 표현 차단

활성 정본에서 current authority로 사용하지 않는다.

- `PC 우선 / 모바일 후속 고려` → Windows·Android dual-target으로 대체.
- `PR #82 active approval` 같은 과거 PR snapshot.
- `PR #65`를 current runtime 전체 상태로 사용.
- `플레이어4/상대7`을 current player-facing 시작거리 정의로 사용.
- Google Sheets를 current user-facing GDD workspace로 사용.
- v4.5 r2를 current project operating contract로 사용.
- 이미지 생성이 모든 BUILD의 무조건 선행조건이라는 해석.

## 7. 현재 상태

현재 상태는 이 문서가 소유하지 않는다.

```yaml
current_state_owner: ../[기획서]/00_프로젝트_허브/ACTIVE_CONTEXT.md
current_pr_authority: GITHUB_PR_METADATA
current_human_workspace: EXACT_PROJECT_NOTION
current_structured_runtime_authority: GITHUB_REPOSITORY_AND_ACTUAL_RUNTIME
google_sheets_policy: MIGRATION_ONLY_UNTIL_REMOVAL
current_work_contract: TEN-DEC-20260824-INTEGRATED-WORK-CONTRACT-V4-8-R2-01
```

## 8. 갱신 규칙

- 새 규칙·태그·제품 의미는 current Decision/승인 계약을 따른다.
- 명칭 정규화·구형 current 참조 제거는 정본 영향과 테스트를 함께 본다.
- 책임 경로가 바뀌면 hub Documentation Map, active consumer, tests, 필요한 Notion projection을 함께 갱신한다.
- mutable state는 이 지도에 복제하지 않는다.
- `v2`, `final`, `latest` 복제본보다 Git 이력과 explicit historical status를 사용한다.
- 자동·Godot·Windows·Android·접근성·성능·사람 evidence를 분리한다.
