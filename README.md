> # 십보강호: 숨은 수의 비무
## Ten Paces: Hidden Moves

상대의 다음 행동 단서를 모아 가설을 세우고 여러 수의 계획으로 의도를 무너뜨리는 **1대1 무협 전술 로그라이트**입니다.

> 보이지 않는 상대의 수를 읽고, 준비한 계획으로 꺾는다.

## 시작

- [작업 시작](START_HERE.md)
- [현재 상태]([기획서]/00_프로젝트_허브/ACTIVE_CONTEXT.md)
- [문서 지도]([기획서]/00_프로젝트_허브/DOCUMENTATION_MAP.md)
- [게임 기획](docs/01_GAME_DESIGN.md)
- [전투 규칙](docs/02_COMBAT_RULES.md)
- [콘텐츠 카탈로그](docs/03_CONTENT_CATALOG.md)
- [로드맵](docs/04_ROADMAP.md)
- [테스트 체크리스트](docs/08_TEST_CHECKLIST.md)
- [행동 선택 Decision](docs/decisions/2026-08-01_MARTIAL_MANUAL_TECHNIQUE_TIMELINE_UX_DECISION.md)
- [화면 구조 Decision](docs/decisions/2026-08-01_SITUATION_SCREEN_ARCHITECTURE_DECISION.md)
- [ActionSelectionDock 종료 기록](docs/implementation/2026-08-01_ACTION_SELECTION_DOCK_CLOSEOUT.md)
- [PR #65 정본·Sheet 동기화](docs/implementation/2026-08-01_PR65_CANON_SHEET_SYNC.md)
- [Base·프로젝트·Sheet 적대적 감사](docs/reviews/2026-08-01_BASE_PROJECT_SHEET_ADVERSARIAL_AUDIT.md)
- [Base 적용 기준](docs/BASE_RULES_VERSION.md)
- [Base 동기화 감사]([기획서]/00_프로젝트_허브/BASE_MAIN_SYNC_AUDIT.md)
- [Base 채택·학습 기록](docs/11_BASE_ADOPTION_AND_LEARNING_LOG.md)

## 현재 작업 상태

```yaml
product_stage: VERTICAL_SLICE_APP_FLOW_PLANNING
work_mode: REVIEW
integration_pr: 65
runtime_implementation: ACTION_SELECTION_DOCK_IMPLEMENTED_PR65
automated_validation: PASS
human_validation: NOT_RUN
approved_screen_architecture: TEN-DEC-20260801-SITUATION-SCREEN-01
next_package: VERTICAL_SLICE_APP_FLOW_SHELL
base_release_pinned: 9.1.0
```

## 프로젝트 코어

```text
상대의 공개 상태·해결 이력 관찰
→ 다음 행동에 대한 가설 수립
→ 3/3/4 행동 묶음 계획
→ 상대 의도 완화·거부·반전·응징
→ 결과 복기와 무공 성장
```

- 1대1 10칸 일자형 전장입니다.
- 플레이어 4번·상대 7번에서 시작하는 현행 T0 구현을 유지합니다.
- 거리 0은 `[밀착]`입니다.
- 한 라운드는 `3수 → 3수 → 4수`, 각 묶음 뒤 해결하며 총 10수입니다.
- `[합]`, 순차 연격, 방어도, 회피, 중단, 강건을 사용합니다.
- AI는 플레이어의 미확정 계획을 읽지 않습니다.
- 덱·손패·드로우·장착 기술 제한을 사용하지 않습니다.
- 성장은 원시 수치로 판단을 대체하지 않고 더 다양한 파훼 수단을 제공합니다.

## 행동 선택 UX

```text
[기초]
[무공] → 무공서 → 현재 해금 기술
[절초]
→ 가장 앞 유효 연속 수 자동 배치
→ 대상·방향 지정
→ 진행 전 연결 블록 이동·제거
→ 진행 후 잠금·해결
```

- 무공서는 직접 배치하지 않습니다.
- 2수·3수 행동은 `[전조] → [실행]` 연결 블록입니다.
- 절초기세는 공유 `0~5`이며 예약·진행 전 환불을 지원합니다.
- ActionSelectionDock은 PR #65에서 구현됐고 자동 검증을 통과했습니다.
- Windows 실제 Godot와 사람 이해도 검증은 아직 실행하지 않았습니다.

## 회차·콘텐츠

```yaml
demo:
  major_duel_slots: 5
  candidates_per_slot: 3
  intermediate_nodes: 8
  target_playtime: 15_to_22_minutes
full_run:
  major_duel_slots: 10
  candidates_per_slot: 3
  intermediate_nodes: 18
  target_playtime: 30_to_40_minutes
```

첫 비무는 후보 3명 중 1명을 seed 기반 선정하고, 이후 비무는 후보 3명 중 2명을 경로 종착점으로 제시합니다. 전체 후보 계약은 유지하되 첫 제품 흐름 구현은 슬롯별 대표 후보로 파이프라인을 먼저 증명합니다.

## 다음 패키지

`VERTICAL_SLICE_APP_FLOW_SHELL`

```text
App Root
→ Main
→ 시작 무공 6중4 선택
→ Route·Node·Briefing
→ 기존 Combat
→ Result·Reward·Retry
```

저충실도 제품 흐름과 저장·전환·중복 commit 회귀를 먼저 검증하고, 실제 화면·입력·사람 검증 뒤 후보 풀을 확장합니다.

## 역사·호환 기준

- PR #7과 Issue #13은 현행 T0 `STEP 0~13` 구현 계보입니다.
- PR #45와 v6 Decision 원장은 재설계·승인 이력입니다.
- 과거 Base 기준 `c987647d01ad2baa028a16e03d85ddfc1572a727`은 `HISTORICAL_COMPATIBILITY_BASELINE`입니다.
- 현재 공용 Skill route는 `skills/PROJECT_BASE_ADAPTER.json`의 Base v9.1 pin을 사용합니다.

## `[보류]`

- 16개 개별 절초 설계
- 주요 비무 6~10 런타임
- 천하제일인·비동기 기능
- 최종 아트·오디오 폴리싱

정적 검사·Actions 성공은 Windows 실제 Godot, 실물 게임패드, 접근성 보조기술, 성능, 실제 플레이 재미를 증명하지 않습니다. 실행하지 않은 항목은 `NOT_RUN`입니다.
