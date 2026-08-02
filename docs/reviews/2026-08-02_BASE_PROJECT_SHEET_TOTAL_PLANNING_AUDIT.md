# Base·십보강호·Google Sheets 총기획·적대적 통합 감사

- Audit ID: `TEN-AUD-011`
- 동기화 ID: `TEN-SYNC-20260802-10`
- 날짜: `2026-08-02`
- Work Mode: `REVIEW → BUILD(SAFE_PLANNING_FIXES) → REVIEW`
- Base 기준: `alsdmlals4-eng/Base@896d2e6fd257084b6aa29b1703cd0bbfa3b18daa`
- 프로젝트 main 기준: `c5771ddae40f58d88824d9319fc4ef6cd1053bba`
- 작업 Branch: `agent/2026-08-02-total-planning-audit-platform-sync`
- 플랫폼 Decision: `TEN-DEC-20260802-PLATFORM-SCOPE-01`
- 제품 경로 변경: `NONE`
- 감사 상태: `CANON_FIXED_SHEET_SYNCED_DRAFT_PR_READY_WITH_DECLARED_GAPS`

## 1. 작업 계약

이 감사는 다음 순서를 적용했다.

```text
Base·프로젝트·Sheet 기준선 복원
→ 현재 강점·승인 Decision 보호
→ 진입 문서·정본·실제 구현 상태·열린 Issue·Sheet 교차 감사
→ attack
→ validate-critique
→ AUTO_FIX_ELIGIBLE / USER_DECISION_REQUIRED / RESEARCH_OR_TEST_REQUIRED 분류
→ 승인된 플랫폼 범위 정본화
→ GitHub 정본·계획 데이터·Sheet 동기화
→ readback·regression-recheck
→ Draft PR exact-HEAD 검수
```

첨부 총기획 계약 v3.1은 감사 우선, 책임 원본 하나, 미실행 검증의 fail-closed 표시, 주요 Decision의 GitHub·Sheet 즉시 동기화를 요구한다.

## 2. 기준선 복원

### Base

- Base main: `896d2e6fd257084b6aa29b1703cd0bbfa3b18daa`.
- 운영 구조: `PLAN / BUILD / REVIEW` 단일 주 Work Mode.
- Skill 선택: Registry trigger 기반 최소 Skill 자동 라우팅.
- L1 이상 권장·설계: 중립성 Gate와 `attack → validate-critique`.
- 실제 수정: 승인된 finding을 분야 책임에서 최소 변경하고 REVIEW로 복귀.
- PR #134의 총기획 v3 Prompt와 PR #136의 시각 작업 계약은 열린 PR이며 Base main 정본으로 오인하지 않는다.

### 프로젝트

```yaml
project_main: c5771ddae40f58d88824d9319fc4ef6cd1053bba
stage: VERTICAL_SLICE_APP_FLOW_PLANNING
base_release: 9.4.0
action_selection: IMPLEMENTED_AUTOMATED_VALIDATION_PASS_HUMAN_PENDING
screen_architecture: APPROVED_PLANNING
next_package: VERTICAL_SLICE_APP_FLOW_SHELL
primary_platform: PC
future_platform: MOBILE_CONSIDERATION_ONLY
human_validation: NOT_RUN
```

### Google Sheets

- 파일: `십보강호: 숨은 수의 비무(Ten Paces: Hidden Moves)`.
- 시간대: `Asia/Seoul`.
- 탭: 25개.
- GitHub 권위 원본을 연결하는 `USER_FACING_GDD_WORKSPACE`.

### 증거 한계

- GitHub 커넥터로 main·PR·Issue·정본·파일을 읽고 쓸 수 있다.
- Google Sheets 커넥터로 metadata·cell·write·readback을 수행할 수 있다.
- 실행 환경 DNS 제한으로 `git clone`과 tracked-file 전체 로컬 inventory·로컬 테스트 실행은 실패했다.
- 따라서 저장소 전체 파일 전문 감사와 로컬 runtime 검증은 `BLOCKED_UNVERIFIED`이며 GitHub 책임 원본·PR changed-file inventory·CI로 보완한다.

## 3. 보호한 강점

- 1대1 10칸 일자형 전장.
- 플레이어 4번·상대 7번 시작과 거리 0 `[밀착]`.
- `3수 → 해결 → 3수 → 해결 → 4수 → 해결`.
- 공개 상태·해결 이력 기반 상대 추론.
- AI의 미확정 플레이어 계획 비열람.
- 무공서→현재 해금 기술→수 배치.
- 순차 `[합]`, 방어도, 회피, 중단, 강건, 복기.
- 데모 5슬롯·슬롯별 후보 3명·중간 노드 8개.
- ActionSelectionDock 구현과 기존 자동 검증 증거.
- 후보 15명 계약을 유지하되 대표 후보로 제작 파이프라인을 먼저 증명하는 순서.

## 4. 검증된 Finding

### MUST_FIX — 이번 범위에서 수정

#### TEN-FIND-20260802-01 — Sheet 현재 기준의 Base·main drift

- 유형: `MISSING_SYNC / STALE_REFERENCE`.
- 증거: `00_프로젝트_허브`가 Base v9.1 SHA `3c158f52...`와 프로젝트 main `2d8b9fc...`를 현재 기준으로 표시했다.
- 실제 현재: Base v9.4 프로젝트 적용, project main `c5771dd...`.
- 영향: 새 작업자가 오래된 Base 계약과 main을 기준으로 시작할 위험.
- 조치: Hub·GDD 요약·변경이력을 v9.4와 현재 main으로 교정.
- 결과: `FIXED_AND_READ_BACK`.

#### TEN-FIND-20260802-02 — Sheet Stage·Work Mode·PR 상태 drift

- 유형: `MISSING_SYNC / DERIVATIVE_STALE`.
- 증거: `05_GDD_요약`이 `CONCEPT_APPROVAL`, `PLAN`, `PR65_OPEN`, Base v9.1을 현재 상태로 표시했다.
- 실제 현재: `VERTICAL_SLICE_APP_FLOW_PLANNING`, `REVIEW`, PR #65 merged, Base v9.4.
- 영향: 다음 기획·구현 Gate와 검증 순서 왜곡.
- 조치: 현재 상태·다음 패키지·검증 한계를 교정하고 활성 Decision 행의 PR-open 상태를 main 병합 상태로 갱신.
- 결과: `FIXED_AND_READ_BACK`.

#### TEN-FIND-20260802-03 — GitHub Roadmap·START_HERE의 완료 작업 잔존

- 유형: `STALE_REFERENCE / DUPLICATE_WORK`.
- 증거: `docs/04_ROADMAP.md`와 과거 감사가 PR #65 정본·Sheet 동기화와 병합, Base v9.3 migration을 현재 작업으로 남겼다.
- 실제 현재: PR #65 merged·Sheet post-merge sync 완료, PR #68 Base v9.4 적용 완료.
- 영향: 완료 작업 재수행, App Flow Shell 착수 지연.
- 조치: 완료 이력으로 이동하고 현재 Gate를 App Flow Shell 구현 계약 정밀화로 전환.
- 결과: `FIXED_IN_BRANCH`.

#### TEN-FIND-20260802-04 — 플랫폼 범위 책임 원본 부재

- 유형: `MISSING_CANON`.
- 사용자 승인 입력: `PC, 이후 모바일(고려 중)`.
- 영향: 모바일 고려가 현재 포팅 승인 또는 동시 출시 범위로 오해될 위험.
- 조치: `TEN-DEC-20260802-PLATFORM-SCOPE-01`을 Decision·planning JSON·entrypoint·Sheet에 같은 ID로 연결.
- 결과: `CANONICALIZED_AND_READ_BACK`.

#### TEN-FIND-20260802-05 — 완료된 Base 이관 Issue의 활성 잔존

- 유형: `STALE_REFERENCE / DUPLICATE_WORK`.
- 대상: Issue #60(v9.1), Issue #63(v9.3).
- 실제 현재: PR #68로 Base v9.4 적용 완료.
- 조치: 완료·대체 근거 댓글을 남기고 두 Issue를 `completed`로 닫음.
- 결과: `FIXED`.

#### TEN-FIND-20260802-06 — 현재 결정 Sheet의 역사·활성 상태 혼재

- 유형: `STALE_REFERENCE / DUPLICATE_ACTIVE_STATE`.
- 증거: 활성 Decision이 `CURRENT`이면서 `SHEET_UPDATE_PENDING_GITHUB`, `PR_OPEN`, `PENDING_PR65`를 사용했다.
- 조치: 최신 main 병합 상태, 역사 인덱스, Pilot·사람 검증 대기를 구분해 갱신.
- 결과: `FIXED_AND_READ_BACK`.

#### TEN-FIND-20260802-07 — Issue #54의 차단 사유 drift

- 유형: `STALE_REFERENCE`.
- 증거: Issue #54가 `BLOCKED_BY_CONCEPT_APPROVAL`을 사용했지만 화면 구조와 App Flow Shell 다음 패키지는 승인됨.
- 조치: 이슈를 닫지 않고 `READY_AFTER_APP_FLOW_SHELL` 근거 댓글을 추가.
- 결과: `FIXED_WITH_OPEN_VALIDATION_ISSUE`.

#### TEN-FIND-20260802-08 — Sheet의 존재하지 않는 책임 원본 경로

- 유형: `ORPHANED_REFERENCE`.
- 증거: `10_제품방향`의 핵심 카피 책임 원본 `docs/00_GAME_PILLARS.md`는 GitHub main에 존재하지 않음.
- 조치: 실제 현행 책임 원본 `docs/01_GAME_DESIGN.md`로 교정하고 플랫폼·현재 Gate 책임 경로도 최신 Decision·Active Context·Roadmap으로 연결.
- 결과: `FIXED_AND_READ_BACK`.

### RESEARCH_OR_TEST_REQUIRED

- `VERTICAL_SLICE_APP_FLOW_SHELL`의 실제 Godot Scene·Autoload·Save Schema·전환 구현.
- Windows 실제 Godot·키보드·마우스·게임패드.
- 해상도·화면 읽기 도구·접근성·성능.
- STEP 14 신규 플레이어 5명.
- 재미·피로·플레이타임·후보 풀 제작량.
- 모바일 터치 UX·성능·스토어·비용 타당성.

## 5. 적대적 공격과 비판 검증

| 공격 | 검증 | 판정 |
|---|---|---|
| 모바일 고려를 현재 구현 범위로 확대했다 | Decision에서 구현 권한 `NONE`, 제외 범위와 재검토 Gate를 명시 | `REJECTED_CRITIQUE` |
| 문서만 최신이고 제품 구현을 완료로 과장했다 | full product flow runtime·Windows·human·mobile을 `NOT_STARTED/NOT_RUN` 유지 | `NO_REGRESSION` |
| PR #65 완료 이력을 삭제했다 | README·Roadmap·Active Context 역사에 PR #65를 보존 | `NO_REGRESSION` |
| Base 열린 PR #134를 main 규칙으로 적용했다 | Base main과 첨부 작업 계약을 분리하고 PR #134를 미병합으로 명시 | `NO_CONFLICT` |
| Sheet를 GitHub 권위 원본처럼 사용했다 | GitHub Decision·planning JSON을 먼저 커밋하고 Sheet는 Draft-PR sync 상태로 기록 | `NO_CONFLICT` |
| 오래된 모든 행을 무차별 덮어썼다 | 현재 상태를 오도하는 활성 셀과 신규 Decision·감사·마일스톤 행만 수정 | `NO_REGRESSION` |
| 런타임·사람 검증 없이 Demo Ready를 주장했다 | Demo/T1 Gate는 미충족으로 유지 | `BLOCKED_UNVERIFIED` |
| 모바일 호환성을 이유로 조기 추상화를 추가했다 | 제품 코드·Scene·데이터·자산 변경 0, 미래 경계만 문서화 | `NO_REGRESSION` |

## 6. 플랫폼 Decision 동기화 Ledger

```yaml
SAME_DECISION_ID: TEN-DEC-20260802-PLATFORM-SCOPE-01
decision_status: APPROVED_PLANNING
decision_summary: PC가 현재 제품 기준이며 모바일은 PC 버티컬 슬라이스 검증 뒤 재평가할 고려 대상이다.
approval_source_and_time: 사용자 직접 지시 / 2026-08-02 KST
GITHUB_CANONICAL_LOCATION:
  repository: alsdmlals4-eng/Ten-Paces-Hidden-Moves
  file_path: docs/decisions/2026-08-02_PLATFORM_SCOPE_DECISION.md
  planning_data: docs/planning-data/approved_20260802_platform_scope_contract.json
  canonical_decision_commit: 87756efa2c6dc2f4e6cbdee706ff21817d5468b9
  planning_data_commit: 492edb4e6911e452f68f532672435805b1fe4c00
GOOGLE_SHEET_LOCATION:
  spreadsheet: 1KzU5M7xsrbz3a3_vG0yEh3hqk736lrYJW3YgPPRloP0
  exact_locations:
    - 00_프로젝트_허브!A1:K2
    - 01_작업순서!A1:N11
    - 02_현재_확정결정!A1:M12
    - 04_누락_충돌_감사!A1:H12
    - 05_GDD_요약!A1:J8
    - 10_제품방향!A1:F4
    - 20_코어경험_데모목표!A1:I4
    - 30_데모범위_품질기준_제작기반!A1:H4
    - 80_데모_버티컬슬라이스_플레이테스트!A1:L5
    - 90_본제작_출시_사업!A1:H5
    - 99_변경이력!A1:H12
readback_result: PASS
sync_status: SHEET_SYNCED_DRAFT_PR_POST_MERGE_MAIN_UPDATE_REQUIRED
```

GitHub가 권위 원본이다. Draft PR 병합 전 Sheet에는 Decision의 canonical commit과 Draft branch 상태를 기록하며, 병합 뒤 최종 main commit·PR 상태를 다시 갱신해야 한다.

## 7. Issue 정리

| Issue | 판정 | 처리 |
|---|---|---|
| #60 Base v9.1 | PR #68 Base v9.4에 흡수 완료 | 근거 댓글 + `closed/completed` |
| #63 Base v9.3 | PR #68 Base v9.4에 대체 완료 | 근거 댓글 + `closed/completed` |
| #54 UX·사람 검증 | 화면 구조 승인, 연결 빌드·사람 증거 미실행 | 열린 상태 유지 + `READY_AFTER_APP_FLOW_SHELL` 댓글 |
| #46·#13 | 이번 감사만으로 완료 증거 부족 | 변경하지 않음 |

## 8. 프로젝트 건강도

| 영역 | 상태 | 근거·제한 |
|---|---|---|
| 진입·운영 | `FIXED_IN_BRANCH` | current state drift 교정 |
| 제품·경험 | `HEALTHY_WITH_UNVERIFIED_HUMAN` | 코어 명확, 사람 검증 NOT_RUN |
| 시스템·콘텐츠 | `PARTIAL` | 전투 PoC·Dock 존재, 전체 제품 흐름 미구현 |
| 세계·서사 | `NEEDS_IMPROVEMENT` | 주요 비무 후보·세력·후반 콘텐츠 다수 보류 |
| UX·표현 | `PARTIAL` | 화면 구조 승인, 실제 흐름·최종 아트·오디오 미구현 |
| 데이터·기술 | `NEEDS_IMPROVEMENT` | App Flow Save/transaction 계약 정밀화 필요 |
| 제작·검증 | `BLOCKED_UNVERIFIED` | Windows·성능·STEP 14 미실행 |
| Skill·Workflow | `HEALTHY` | Base v9.4 Adapter·프로젝트 Skill 4개 유지 |
| Sheet·파생본 | `SYNCED_DRAFT_PR` | 동일 Decision ID·경로·canonical commit readback PASS |
| 콜드 스타트 | `FIXED_IN_BRANCH` | START_HERE·Active Context·Roadmap 정렬 |

## 9. 다음 작업 우선순위

1. 이 Branch의 Draft PR exact-HEAD·changed-file·CI·review thread 검수.
2. `VERTICAL_SLICE_APP_FLOW_SHELL` Codex 실행 Packet 작성.
3. 별도 구현 Branch에서 App Root·Main·Setup·Route·Node·Briefing·Combat·Result Shell 구현.
4. 저장·전환·중복 입력·same-seed·보상 단일 commit 자동 회귀.
5. Windows 실제 실행·해상도·입력·접근성·성능 검증.
6. STEP 14 사람 검증.
7. 같은 파이프라인으로 두 번째 후보·노드를 반복 제작하고 후보 풀 확장 판정.
8. 위 PC Gate가 닫힌 뒤 모바일 타당성 조사 여부 재결정.

## 10. 현재 완료 판정

```yaml
base_structure_understood: PASS_WITH_REMOTE_EVIDENCE
project_canon_and_progress_understood: PASS
sheet_structure_and_key_ranges_read: PASS
adversarial_findings_validated: PASS
platform_decision_canonicalized: PASS
github_entrypoint_sync: PASS_IN_BRANCH
google_sheet_sync: PASS_DRAFT_PR_STATE
sheet_readback: PASS
issue_cleanup: PASS
orphaned_sheet_reference_fix: PASS
local_tracked_file_inventory: BLOCKED_UNVERIFIED_DNS
local_tests: NOT_RUN_DNS
windows_godot: NOT_RUN
accessibility_performance: NOT_RUN
human_step14: NOT_RUN
mobile_runtime_and_validation: NOT_RUN
demo_ready: NO
merge_authority: NOT_REQUESTED
post_merge_sheet_update: REQUIRED_AFTER_MERGE
```
