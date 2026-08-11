# 십보강호 기획완료 권위 Inventory — 2026-08-11

- Inventory ID: `TEN-PLAN-INVENTORY-20260811-01`
- 단계: `Stage 1 — 기획완료 후보 / Task 2 authoritative planning inventory`
- 판정: **`PLANNING_COMPLETION_CANDIDATE = false`**
- P0/P1: **`0 / 14 domains`**
- 제품 구현 권한: `product_implementation_authorized: false`
- 이미지: **이미지 생성 금지** — `기획완료 후보 → 사용자 명시 기획 완료 → 검수완료 → 이미지 생성`
- 구조화 원본: `docs/planning-data/planning_completion_inventory_20260811.json`

## 1. 작업 시작 snapshot

이번 inventory는 수정 전에 현재 권위를 다시 읽고 시작했다.

```yaml
project_main_sha: e66c2df9fdb98ebfbe8116af1fff9d10cace8d49
base_remote_main_sha: 069f0c9654a6cde7cea6f3343dd2fa81c6248d5d
project_open_prs_at_work_start: []
base_open_prs_at_work_start: []
current_work_pr: 157
product_stage: VERTICAL_SLICE_APP_FLOW_PLANNING
product_implementation_authorized: false
image_generation_allowed: false
planning_completion_candidate: false
```

Base remote의 `069f0c96...` 변경은 serial-fiction 전용 관측이다. 십보강호의 Base Adapter pin이나 게임 규칙으로 자동 채택하지 않는다.

## 2. 벤치마킹·현업 조사

이번 작업은 외부 체계를 가져오는 것이 아니라 **기획완료 inventory를 잘 만드는 실무 요소만** 참고했다.

### 가져오는 요소

1. **대표 Vertical Slice 범위**  
   전체 콘텐츠를 다 만드는 것이 아니라 최종 플레이 경험을 대표하는 end-to-end 범위를 닫는다. 십보강호에서는 `Main → Setup → Route/Node → Briefing → Combat → Review → Result/Reward/Retry`와 그 흐름에 필요한 전투·성장·저장·UX 계약이 대상이다.

2. **Requirement traceability**  
   각 기획 영역을 `책임 원본 → Decision ID → Sheet 소비처 → 구현 상태 → conflict → evidence → completion status`로 연결한다.

3. **Milestone discipline**  
   완료 audit 중 새 기능을 섞지 않는다. 발견은 `P0/P1/P2`, `DEFERRED_NON_BLOCKING`, `EVIDENCE_PENDING_NON_PLANNING`으로 분리하고 후속 작업에서 별도 TDD로 고친다.

### 가져오지 않는 요소

- Unity/다른 엔진의 제작 단계·툴·폴더 구조를 프로젝트에 복제하지 않는다.
- Jira 등 외부 workflow를 현재 Decision/Google Sheet 체계 대신 넣지 않는다.
- 타 게임의 콘텐츠 수, 수치, 전투 규칙, UI 구조를 기획완료 기준으로 삼지 않는다.

### 십보강호 적용

십보강호의 완료 판단은 **`3/3/4 비공개 계획 + 공개 단서 추론 + 1대1 거리 결투`**를 중심으로 한다. 사람/실기기 검증이 아직 없다는 사실과 텍스트 기획이 미완이라는 사실을 섞지 않는다. 또한 `CURRENT_APPROVED_PLANNING`과 `IMPLEMENTED_LEGACY`를 명확히 분리한다.

## 3. 완료 상태 분류

| 분류 | 수 | 의미 |
|---|---:|---|
| `RESOLVED` | 3 | 현재 Vertical Slice 기획 계약 자체는 닫힘 |
| `P0` | 0 | 즉시 전체 작업 중단급 blocker 없음 |
| `P1` | 14 | `기획완료 후보` 전에 해결해야 하는 current-scope blocker |
| `P2` | 0 | 이번 inventory에서 별도 P2로 남긴 항목 없음 |
| `DEFERRED_NON_BLOCKING` | 0 | domain-level 분류는 없음; 개별 후속 콘텐츠는 각 domain 안에서 비차단으로 분리 가능 |
| `EVIDENCE_PENDING_NON_PLANNING` | 1 | 기획이 아니라 실행·사람·실기기 증거 대기 |

따라서 **아직 `기획 완료`를 요청할 단계가 아니다.** 먼저 14개 P1 domain을 후속 Task 3~6에서 닫아야 한다.

## 4. Domain inventory

### 4.1 제품 방향·핵심 약속 — `P1`

**권위:** `docs/01_GAME_DESIGN.md`, Sheet `10_제품방향`, Windows·Android current Decisions.

현재 `10_제품방향`은 Windows·Android 기본 설계를 올바르게 가진다. 그러나 `05_GDD_요약`, `20_코어경험_데모목표`, `90_본제작_출시_사업`에는 PC-first/mobile-later와 과거 PR84 상태가 current처럼 남아 있다.

- `INV-P1-PLATFORM-STABLE-CONSUMERS`
- `INV-P1-GDD-MUTABLE-SNAPSHOT`

**예:** 현행은 `Windows·Android 기본 설계 / 단일 공유 코어 + Adapter`인데, 일부 consumer는 “PC 완성 후 모바일 검토”를 여전히 현재 계획으로 표시한다.

### 4.2 핵심 루프·승패·실패/복구 — `P1`

**권위:** `docs/01_GAME_DESIGN.md`, `docs/02_COMBAT_RULES.md`, Sheet `12_핵심루프`.

READ→PLAN→RESOLVE→REVIEW 구조는 명확하지만, 일부 consumer가 대체된 자원 회복/관찰 표현을 유지한다.

- `INV-P1-INTERNAL-RECOVERY-SHEET-DRIFT`
- `INV-P1-OBSERVATION-COMPOSITE-KIND-DRIFT`

### 4.3 세계관·주요인물·세력 Vertical Slice — `P1`

Sheet `11`, `13`, `14`의 핵심 항목이 `PARTIAL`이다. 또한 데모는 주요 비무 5개를 목표로 하지만 fresh Sheet에서 구체 후보 풀은 슬롯1~3까지만 확인됐다.

- `INV-P1-WORLD-CHARACTER-PARTIAL`
- `INV-P1-DEMO-SLOT4-5-CONTENT`

이는 “첫 App Flow Shell에 15명 전부 만들어야 한다”는 뜻이 아니다. `TEN-DEC-20260801-SITUATION-SCREEN-01`대로 첫 파이프라인은 슬롯별 대표 후보로 증명할 수 있다. 다만 **기획완료 범위에서 어떤 인물/상대 계약이 필수인지**는 닫아야 한다.

### 4.4 전투 규칙·타이밍·거리·행동 — `P1`

GitHub current 정본은 시작거리2, `거리 N`, `[전조]`, 공격-only 사거리 등으로 정리되어 있다. 문제는 Sheet `15/40`에 후속 overlay로 대체된 값이 current처럼 공존한다는 점이다.

- `INV-P1-COMBAT-SHEET-CURRENT-LABEL-DRIFT`
- `INV-P1-INTERNAL-RECOVERY-SHEET-DRIFT`

현재 Godot runtime의 4/7 좌표·일부 기초행동 상태는 **`IMPLEMENTED_LEGACY`**로 취급한다.

### 4.5 `[관찰]`·정보 공정성 — `P1`

GitHub current 규칙은 상대가 먼저 계획을 잠그고, 관찰량만큼 앞 수의 **행동 종류만** 공개한다. 그러나 Sheet `12/15/40`의 일부 행에는 `[이동+공격]` 같은 복합 공개 표현이 남아 있어 현재 UI/행동종류 계약과 정합화가 필요하다.

- `INV-P1-OBSERVATION-COMPOSITE-KIND-DRIFT`

### 4.6 자원·합·중단 — `P1`

현재 authoritative 묶음 회복은:

```text
기력 +1 / 내력 +0 / 절초기세 +1
```

그런데 Sheet `12/15/40` 일부 current-labelled 행은 과거 `+1/+1/+1`을 유지한다.

- `INV-P1-INTERNAL-RECOVERY-SHEET-DRIFT`

### 4.7 초기 무공서10권·기술 콘텐츠 — `RESOLVED`

`03_무공서_무학`과 ten-manual current contracts에 10권 roster, 3/5/7/9/10성 성장, 대표 절초, 역할·예산이 정의되어 있다. UI/AI/runtime 자동 경로와 50/50 자동 제품 검증도 존재한다.

사람 밸런스·선택률은 아직 미실행이지만 그것은 이 domain의 기획 부재와 다르다.

### 4.8 성장·경제·보상 — `P1`

Sheet `41_성장_경제`에는 최신 overlay와 대체된 과거 가격이 동시에 current처럼 읽히는 문제가 있다.

- `INV-P1-RANGE-PRICE-SHEET-DRIFT`
- `INV-P1-UNCAPPED-STAT-SHEET-DRIFT`
- `INV-P1-GROWTH-ECONOMY-CURRENT-LABEL-DRIFT`

**예:** 현재 거리 가격은 15틱/칸 계열인데, `0/10/25/40` 구형 사거리 표가 `CURRENT_APPROVED_PLANNING`으로 남아 있다.

### 4.9 Vertical Slice 콘텐츠 범위 — `P1`

데모 목표는 주요 비무5전·노드8개로 잡혀 있고, 첫 App Flow 구현에서 후보15명 전체가 선행조건은 아니다. 다만 `20`의 목표 상태가 `PLANNING_IN_PROGRESS/PARTIAL`이고 슬롯4~5의 대표 콘텐츠 계약을 inventory에서 확인할 수 없다.

- `INV-P1-DEMO-SLOT4-5-CONTENT`
- `INV-P1-PLATFORM-STABLE-CONSUMERS`

### 4.10 App Flow / Route / Node / Briefing / Result / Retry — `P1`

`TEN-DEC-20260801-SITUATION-SCREEN-01`이 전체 상태 흐름과 Scene 소유권을 승인했지만 Sheet `60`에서 다음이 아직 `DRAFT`다.

- Main/회차 진입
- 무공 구성
- Route
- Result/Reward/Retry

Decision 자체도 저장 슬롯, 재도전 비용·복구 UX, Route/Node wireframe, Result/Reward 정보 우선순위 등을 “남은 기획”으로 적고 있다.

- `INV-P1-APP-FLOW-UX-DRAFT`
- `INV-P1-SITUATION-SCREEN-REMAINING-PLANNING`

### 4.11 카드 본체·상세창·계획판 — `RESOLVED`

PR #156에서 사용자 승인 spec이 `USER_APPROVED_SPEC / PLANNING_COMPLETION_REVIEW_READY`로 승격됐다.

현재 핵심 예시는:

```text
이동: [이동] 1, 사거리 행 없음
속공: [공격] / 사거리1 / 현재 공격값
2수 공격: 1수 [전조] → 2수 [공격] 기술명
관찰 공개: [전조] / [공격] / ?  (기술명은 숨김)
```

이 domain은 현재 기획 기준으로 닫혀 있다.

### 4.12 접근성·입력 — `P1`

Windows/Android 공통 의미, 48dp, hover/drag-only 금지, focus/back 등 platform architecture는 승인되어 있다. 그러나 App Flow 핵심 화면이 여전히 DRAFT라 **화면별 실제 입력·오류·복구 계약이 텍스트상 완결되지 않은 부분**이 있다.

실제 Android device·실물 gamepad·사람 접근성 검증 `NOT_RUN`은 별도 evidence gap이다.

### 4.13 Windows·Android Adapter Architecture — `RESOLVED`

`TEN-DEC-20260806-WINDOWS-ANDROID-DUAL-TARGET-01`과 `...ADAPTER-ARCHITECTURE-01`이 공유 코어와 5 Adapter를 명확히 규정한다.

Android 구현/실기기 검증은 아직 `NOT_RUN`이지만, **플랫폼 기획 계약 자체는 닫혀 있다.**

### 4.14 저장·재개·commit idempotency — `P1`

Situation Screen/Adapter Architecture에는 `RunSession`, `SaveService`, atomic checkpoint, backup, lifecycle checkpoint 원칙이 있다. 그러나 저장 슬롯·retry/recovery 제품 UX와 일부 App Flow 값은 아직 남은 기획이다.

- `INV-P1-SAVE-RETRY-RECOVERY-UX`

### 4.15 아트·오디오·시각 요구사항 — `P1`

Sheet `70`의 전장/HUD·캐릭터는 `PLANNED`, 오디오는 `UNVERIFIED`이다. TEN-IMG-001은 올바르게 `PAUSED_BY_USER_NOT_AN_ASSET`이다.

- `INV-P1-ART-AUDIO-TEXT-REQUIREMENTS`
- `INV-P1-VISUAL-TEN-SPACE-DISPLAY-FRESHNESS`

이미지를 지금 만드는 것이 해결책이 아니다. Stage 1에서는 post-review 생성에 필요한 **텍스트 requirement와 금지 요소**만 닫는다.

### 4.16 테스트·검증 evidence acceptance — `EVIDENCE_PENDING_NON_PLANNING`

자동 product evidence는 존재하지만 다음은 아직 실제로 수행되지 않았다.

- local Windows visible render
- physical keyboard/mouse/gamepad verification
- Android install/device/touch/back/safe-area/lifecycle
- accessibility user testing
- STEP14 신규 플레이어
- balance/human measurement

이것을 **기획 미완으로 잘못 분류하지 않는다.** 실행 전에는 `NOT_RUN` 그대로 유지한다.

### 4.17 구현 legacy ↔ 최신 기획 delta — `P1`

개별 문서에는 `IMPLEMENTED_LEGACY`가 잘 표시된 곳이 있지만, 기획완료용으로 모든 차이를 한 표에서 닫은 delta ledger가 아직 없다.

- `INV-P1-IMPLEMENTATION-LEGACY-DELTA-INVENTORY`

대표 예:

- runtime 시작 좌표 4/7 ↔ current public start distance2
- runtime 일부 기초행동/수치 ↔ current 10종/overlay
- current planning-only platform Adapter ↔ implementation not run

### 4.18 거버넌스·정본·Sheet sync — `P1`

Primary current authority (`ACTIVE_CONTEXT`, GitHub main, Sheet 00/02/04/99)는 최근 sync되어 있다. 그러나 derived consumer가 self-stale한 문제가 남는다.

- `INV-P1-GDD-MUTABLE-SNAPSHOT`
- `INV-P1-DEVELOPMENT-GATES-MUTABLE-SNAPSHOT`
- `INV-P1-DEVELOPMENT-GATES-IMAGE-DEPENDENCY`
- `INV-P1-SHEET-CONSUMER-CURRENT-LABEL-DRIFT`

특히 `DEVELOPMENT_GATES.md`는 “변동 상태를 복제하지 않는다”고 선언하면서 `runtime_integration_pr: 65`, `...PR92`, `next_package` 등을 직접 보유한다. 또 G6가 G5 이미지 단계 완료를 필수 선행으로 고정해 현재 승인된 `기획완료 → 검수완료 → 이미지 생성` sequence와 no-new-asset 가능성을 혼동시킬 수 있다.

## 5. P1 finding registry

| Finding | 핵심 |
|---|---|
| `INV-P1-PLATFORM-STABLE-CONSUMERS` | PC-first/mobile-later stale consumers |
| `INV-P1-GDD-MUTABLE-SNAPSHOT` | GDD summary의 PR84/old stage snapshot |
| `INV-P1-INTERNAL-RECOVERY-SHEET-DRIFT` | current 1/0/1 vs stale 1/1/1 |
| `INV-P1-OBSERVATION-COMPOSITE-KIND-DRIFT` | 관찰 type-only current와 복합 종류 stale wording |
| `INV-P1-COMBAT-SHEET-CURRENT-LABEL-DRIFT` | 대체된 전투 값을 current처럼 유지 |
| `INV-P1-RANGE-PRICE-SHEET-DRIFT` | old 0/10/25/40 range price current-label |
| `INV-P1-UNCAPPED-STAT-SHEET-DRIFT` | uncapped와 validation range 1/4/15 혼동 |
| `INV-P1-GROWTH-ECONOMY-CURRENT-LABEL-DRIFT` | 성장/경제 역사 current-label drift |
| `INV-P1-WORLD-CHARACTER-PARTIAL` | world/character/faction partial |
| `INV-P1-DEMO-SLOT4-5-CONTENT` | demo representative content slots4~5 미확인 |
| `INV-P1-APP-FLOW-UX-DRAFT` | Main/Route/Result 등 DRAFT |
| `INV-P1-SITUATION-SCREEN-REMAINING-PLANNING` | current-scope remaining product values |
| `INV-P1-SAVE-RETRY-RECOVERY-UX` | save/retry/recovery product UX 값 미완 |
| `INV-P1-ART-AUDIO-TEXT-REQUIREMENTS` | image 전 textual visual/audio requirement 미완 |
| `INV-P1-VISUAL-TEN-SPACE-DISPLAY-FRESHNESS` | old 10-space display wording vs 거리N UI |
| `INV-P1-IMPLEMENTATION-LEGACY-DELTA-INVENTORY` | completion delta ledger 미통합 |
| `INV-P1-DEVELOPMENT-GATES-MUTABLE-SNAPSHOT` | stable gate doc의 mutable state 복제 |
| `INV-P1-DEVELOPMENT-GATES-IMAGE-DEPENDENCY` | image Gate가 Build의 무조건 선행처럼 고정 |
| `INV-P1-SHEET-CONSUMER-CURRENT-LABEL-DRIFT` | derived tabs의 stale current labels/values |

Finding 수와 P1 domain 수는 같은 개념이 아니다. 여러 finding이 한 domain에 영향을 줄 수 있다.

## 6. 비차단과 미실행 증거의 경계

`DEFERRED_NON_BLOCKING`은 “모른 채 미룸”이 아니다. 현재 Vertical Slice에 필요하지 않은 후속 기능은 정확한 trigger와 함께 분리해야 한다. 예:

- 주요 비무6~10 runtime
- 천하제일인/비동기 챔피언 배틀
- 최종 Steam key art
- 온라인 서비스

반대로 다음은 **EVIDENCE_PENDING_NON_PLANNING**이다.

```text
Android device NOT_RUN
local Windows visible NOT_RUN
human usability NOT_RUN
STEP14 NOT_RUN
balance measurement NOT_RUN
```

이 값들은 실제 실행하지 않는 한 PASS로 승격하지 않는다.

## 7. 다음 작업 순서

이번 inventory PR은 blocker를 발견·추적하는 작업이다. 모든 P1을 한 PR에서 한꺼번에 고치지 않는다.

다음은 승인된 planning-completion plan의 Task 3~6을 따라 독립 TDD work unit으로 처리한다.

1. **정본/Sheet consumer drift 우선 정리**  
   platform, internal recovery, observation, range-price, uncapped stats, Development Gates.
2. **Vertical Slice 콘텐츠·App Flow 기획 닫기**  
   world/characters, representative duel content, Main/Route/Node/Briefing/Result/Retry, save/recovery UX.
3. **접근성·visual/audio 텍스트 요구사항 닫기**  
   실제 이미지 생성은 하지 않는다.
4. **IMPLEMENTED_LEGACY delta ledger 통합**.
5. 모든 current-scope domain이 `RESOLVED` 또는 승인된 `DEFERRED_NON_BLOCKING`이고 **P0/P1 = 0**일 때만 `PLANNING_COMPLETION_CANDIDATE`를 만든다.

그 뒤 사용자에게 명시적인 **`기획 완료`** 선언을 요청하고, 선언 후 Stage 2 적대적 검수를 수행한다. `REVIEW_COMPLETE`가 된 뒤에만 Stage 3 이미지 생성을 시작한다.

## 8. 안전 결론

```yaml
planning_completion_candidate: false
image_generation_allowed: false
product_implementation_authorized: false
local_windows_visible_validation: NOT_RUN
android_device_validation: NOT_RUN
human_usability_validation: NOT_RUN
```

현재는 **기획완료 후보를 만들기 위한 blocker inventory가 생긴 단계**다. 이미지 생성과 제품 BUILD는 계속 금지한다.
