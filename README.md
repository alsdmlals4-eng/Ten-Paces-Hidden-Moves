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
- [플랫폼 범위 Decision](docs/decisions/2026-08-02_PLATFORM_SCOPE_DECISION.md)
- [ActionSelectionDock 종료 기록](docs/implementation/2026-08-01_ACTION_SELECTION_DOCK_CLOSEOUT.md)
- [PR #65 정본·Sheet 동기화](docs/implementation/2026-08-01_PR65_CANON_SHEET_SYNC.md)
- [2026-08-01 Base·프로젝트·Sheet 적대적 감사](docs/reviews/2026-08-01_BASE_PROJECT_SHEET_ADVERSARIAL_AUDIT.md)
- [2026-08-02 총기획·정본·Sheet 감사](docs/reviews/2026-08-02_BASE_PROJECT_SHEET_TOTAL_PLANNING_AUDIT.md)
- [Base 적용 기준](docs/BASE_RULES_VERSION.md)
- [Base 동기화 감사]([기획서]/00_프로젝트_허브/BASE_MAIN_SYNC_AUDIT.md)
- [Base 채택·학습 기록](docs/11_BASE_ADOPTION_AND_LEARNING_LOG.md)

## 현재 작업 상태

활성 PR·승인 수·다음 Decision은 [현재 상태]([기획서]/00_프로젝트_허브/ACTIVE_CONTEXT.md)가 단독 책임진다. GitHub PR metadata와 함께 읽으며 이 README에는 변동 상태를 복제하지 않는다.

안정 경계:

- 제품 단계: `VERTICAL_SLICE_APP_FLOW_PLANNING`
- 런타임 기준선: PR #65 `ACTION_SELECTION_DOCK_IMPLEMENTED`
- 최신 전투 기획 런타임: `NOT_STARTED`
- 플랫폼: PC 우선, 모바일 고려만
- Base: v9.4.3
- Windows 실제 Godot·사람·접근성·성능 검증: `NOT_RUN`

## 플랫폼 범위

- 현재 기획·구현·검증·배포 기준은 `PC`입니다.
- 모바일은 PC 버티컬 슬라이스와 전투 코어 검증 뒤 재평가할 미래 후보이며 현재 구현 범위가 아닙니다.
- 터치 UI, Android·iOS 빌드, 모바일 성능·스토어·크로스 세이브는 별도 Decision 전까지 `NOT_STARTED`입니다.
- 모바일 가능성을 이유로 현재 전투 코어·3/3/4·정보 구조·콘텐츠 범위를 선행 변경하지 않습니다.

## 프로젝트 코어와 핵심 재미

```text
공개 상태·해결 이력 읽기
→ 가능한 행동 가설 세우기
→ 여러 가능성을 견디는 3/3/4 비공개 계획
→ 거리·현재 순번 합·대응·중단으로 해결
→ 결정적 원인을 복기
→ 다음 계획과 경로 선택 변경
```

- 1대1 10칸 일자형 전장입니다.
- 플레이어 4번·상대 7번에서 시작하는 현행 T0 구현을 유지합니다.
- 거리 0은 `[밀착]`입니다.
- 한 라운드는 `3수 → 3수 → 4수`, 각 묶음 뒤 해결하며 총 10수입니다.
- `[합]`, 순차 연격, 방어도, 회피, 중단, 강건을 사용합니다.
- AI는 플레이어의 미확정 계획을 읽지 않습니다.
- 덱·손패·드로우·장착 기술 제한을 사용하지 않습니다.
- 뾰족한 재미는 단일 행동을 찍어 맞히는 것이 아니라, 불완전한 정보에서 강건한 계획을 만들고 왜 상대의 의도가 무너졌는지 이해하는 데 있습니다.
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

## 다음 진행 순서

```text
활성 기획 Decision 승인·동기화
→ 기획 완료
→ 전체 정본·PR·Sheet 적대적 검토
→ 검토 완료
→ 필요한 이미지·애니메이션·HX 생성·검수·승인
→ 이미지 완료
→ VERTICAL_SLICE_APP_FLOW_SHELL Codex 구현
```

`VERTICAL_SLICE_APP_FLOW_SHELL`의 흐름은 다음과 같습니다.

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
- PR #65는 행동 선택 구현과 화면 구조 승인 통합 이력입니다.
- PR #68은 Base v9.4 운영 계약 적용 이력입니다.
- PR #72와 PR #80은 이후 전투·성장 기획 체크포인트 이력입니다.
- 과거 Base 기준 `c987647d01ad2baa028a16e03d85ddfc1572a727`은 `HISTORICAL_COMPATIBILITY_BASELINE`입니다.
- 현재 공용 Skill route는 `skills/PROJECT_BASE_ADAPTER.json`의 Base v9.4.3 payload/evidence/finalization pin을 사용합니다.

## `[보류]`

- 16개 개별 절초 설계
- 주요 비무 6~10 런타임
- 천하제일인·비동기 기능
- 모바일 포팅·스토어·크로스 세이브
- 최종 아트·오디오 폴리싱

정적 검사·Actions 성공은 Windows 실제 Godot, 실물 게임패드, 접근성 보조기술, 성능, 실제 플레이 재미를 증명하지 않습니다. 실행하지 않은 항목은 `NOT_RUN`입니다.
