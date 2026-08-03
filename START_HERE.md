# 십보강호 시작 지점

## 기본 읽기

```text
최신 사용자 지시
→ AGENTS.md
→ docs/BASE_RULES_VERSION.md
→ [기획서]/00_프로젝트_허브/ACTIVE_CONTEXT.md
→ [기획서]/00_프로젝트_허브/DOCUMENTATION_MAP.md
→ skills/SKILL_REGISTRY.json
→ [기획서]/00_프로젝트_허브/SKILL_REGISTRY.json
→ 최신 관련 Decision
→ 질문별 책임 원본
→ 실제 코드·데이터·Scene·테스트·PR
```

백업·보류·과거 계획·닫힌 PR·전체 Skill 폴더를 기본 로드하지 않는다. `skills/SKILL_REGISTRY.json`은 현재 프로젝트 고유 Skill 권한이며 `[기획서]/00_프로젝트_허브/SKILL_REGISTRY.json`은 호환 진입점이다.

## 현재 기준

```yaml
repository: alsdmlals4-eng/Ten-Paces-Hidden-Moves
main_state_sync_commit: 6d8237e00168e45a7d3c001a0f6b3587b57147b7
last_planning_checkpoint_merge: d9f38e6f3cacaf170d4b290e95b3645114639aff
active_planning_pr: 82
active_planning_head: 289378c214702223dc0d1e149134438c3e761ba0
active_approval_count: 2/10
active_decision_state: APPROVED_PENDING_MERGE
product_stage: VERTICAL_SLICE_APP_FLOW_PLANNING
work_mode: PLAN
runtime_implementation: ACTION_SELECTION_DOCK_IMPLEMENTED_PR65
latest_combat_planning_runtime: NOT_STARTED
primary_platform: PC
future_platform: MOBILE_CONSIDERATION_ONLY
next_package: VERTICAL_SLICE_APP_FLOW_SHELL
next_planning_decision: INTERMEDIATE_NODE_PERMANENT_STAT_REWARDS
human_validation: NOT_RUN
base_adapter: skills/PROJECT_BASE_ADAPTER.json
base_release_pinned: 9.4.3
```

병합된 main 상태와 활성 Draft PR 상태를 혼합하지 않는다. PR #82의 승인 두 건은 Branch·Decision·planning data·Sheet에 기록된 `APPROVED_PENDING_MERGE`이며, 병합 후 main·Sheet 재조회 전에는 `SYNCED_TO_MAIN`이 아니다.

## 현재 책임 원본

- 현재 상태: `[기획서]/00_프로젝트_허브/ACTIVE_CONTEXT.md`.
- 문서 지도: `[기획서]/00_프로젝트_허브/DOCUMENTATION_MAP.md`.
- Base 버전: `docs/BASE_RULES_VERSION.md`.
- 전투 규칙: `docs/02_COMBAT_RULES.md`.
- 행동 선택: `docs/decisions/2026-08-01_MARTIAL_MANUAL_TECHNIQUE_TIMELINE_UX_DECISION.md`.
- 화면 구조: `docs/decisions/2026-08-01_SITUATION_SCREEN_ARCHITECTURE_DECISION.md`.
- 플랫폼 범위: `docs/decisions/2026-08-02_PLATFORM_SCOPE_DECISION.md`.
- 최근 병합 성장 체크포인트: PR #80과 `d9f38e6f3cacaf170d4b290e95b3645114639aff`.
- 현재 활성 성장 배치: PR #82와 두 Decision.
- 구현 종료: `docs/implementation/2026-08-01_ACTION_SELECTION_DOCK_CLOSEOUT.md`.
- 최신 총기획 감사: `docs/reviews/2026-08-02_BASE_PROJECT_SHEET_TOTAL_PLANNING_AUDIT.md`.

## 프로젝트 코어

- 1대1 10칸 일자형 전장.
- 거리 0 `[밀착]`.
- `3수 → 해결 → 3수 → 해결 → 4수 → 해결`.
- 공개 상태·해결 이력 기반 상대 추론.
- AI의 미확정 플레이어 계획 열람 금지.
- 덱·손패·드로우·장착 기술 제한 없음.
- 무공서가 아니라 현재 해금 기술을 수에 배치.
- 핵심 재미는 한 행동을 맞히는 것이 아니라 여러 가능성을 견디는 계획을 만들고, 해결·복기로 왜 상대의 의도가 무너졌는지 이해한 뒤 다음 계획을 바꾸는 데 있다.

## 플랫폼 경계

- 현재 주 플랫폼은 `PC`다.
- 모바일은 `CONSIDERATION_ONLY`이며 현재 구현·출시·검증 권한이 없다.
- PC App Flow Shell·Windows 실행·저장·성능·STEP 14 검증 뒤 별도 Decision으로 재평가한다.
- 모바일 가능성을 이유로 현재 전투 코어·UI 정보 구조·콘텐츠 범위를 선행 변경하지 않는다.

## 현재 작업

```text
PR #80 병합·PR #81 main 상태 동기화 완료
→ PR #82 GrillMe 승인 배치 2/10 수집 중
→ 중간 노드 영구 스테이터스 보상 Decision
→ 남은 기획 완료와 적대적 검토
→ 필요한 이미지·모션·HX 기획·생성·승인
→ VERTICAL_SLICE_APP_FLOW_SHELL Codex 구현 인계
→ 자동·Godot·Windows·접근성·성능·STEP 14 사람 검증
```

제품 코드·Scene·런타임 데이터는 별도 Build 승인 전 변경하지 않는다.

## Work Mode

- `PLAN`: 설계·근거·순서·Decision.
- `BUILD`: 승인 패키지 구현.
- `REVIEW`: 적대적 검토·검증·최소 수정.

## 역사·호환

- PR #7과 Issue #13은 T0 `STEP 0~13` 구현 계보다.
- PR #45는 v6 계획 통합 이력이다.
- PR #65는 ActionSelectionDock과 화면 구조 통합 이력이다.
- PR #68은 Base v9.4 운영 계약 적용 이력이다.
- PR #72와 PR #80은 이후 전투·성장 기획 체크포인트 이력이다.
- 현재 공용 Skill 권한은 `skills/PROJECT_BASE_ADAPTER.json`의 Base v9.4.3 pin이다.

자동·정적 검증은 Windows 실제 Godot, 실물 게임패드, 화면 읽기 도구, 성능, 사람 플레이를 증명하지 않는다. 실행하지 않은 항목은 `NOT_RUN`이다.