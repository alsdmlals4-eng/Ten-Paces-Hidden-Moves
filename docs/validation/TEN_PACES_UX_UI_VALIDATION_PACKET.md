# 십보강호 Issue #54 Human / Device Validation Packet

> Owner: GitHub Issue `#54` — `UX-VALIDATION-001`  
> 상태: `READY_FOR_HUMAN_DEVICE_EXECUTION`  
> 대상: 이미 `main`에 병합된 첫 5전 Vertical Slice  
> runtime mutation authorization: `false`  
> Fixture: `docs/validation/TEN_PACES_UX_UI_FIXTURE_CATALOG.md`

이 패킷의 목적은 자동 테스트가 이미 확인한 동작을 다시 자동화하는 것이 아니라, **실제 Windows 화면·실제 입력 장치·신규 플레이어·접근성 사용자·Android actual device**에서 제품을 검증하고 증거를 같은 Git commit에 묶는 것이다.

가장 중요한 증거 원칙:

> **자동 증거는 Human PASS를 대신하지 않는다.**

CI, headless Godot, synthetic keyboard/mouse, export 성공은 서로 다른 증거이며 `Windows visible local`, `physical gamepad`, `Android actual device`, `accessibility user`, `Human fun/readability/immersion`을 자동으로 PASS로 승격하지 않는다.

## 1. 현재 증거 경계

Issue #54 실행 시작 시 기본 상태는 다음과 같다.

| Evidence | 상태 | 의미 |
|---|---|---|
| CI / automated product scenarios | PASS evidence exists | 구조·자동 시나리오 증거 |
| Windows export/runtime CI | PASS evidence exists | CI runner의 export/runtime 증거 |
| Windows visible local | `NOT_RUN` | 개발자 PC에서 실제 화면·조작 확인 필요 |
| physical gamepad | `NOT_RUN` | 실물 컨트롤러 필요 |
| Android actual device | `NOT_RUN` | 현재 정확한 Android artifact/preset 확인 후 실기기 필요 |
| accessibility user | `NOT_RUN` | 실제 사용자 검증 필요 |
| Human fun/readability/immersion | `NOT_RUN` | 신규 플레이어 검증 필요 |
| release performance | `NOT_RUN` | release 조건 별도 필요 |

현재 repository의 `export_presets.cfg`에는 Windows Desktop preset만 존재한다. 따라서 Android 실제 기기 검증은 **현재 `main`에 실행 가능한 Android artifact/preset이 생기기 전까지 readiness가 BLOCKED**이며, 이 상태를 Android PASS나 제품 결함 FAIL로 바꾸지 않는다.

## 2. Evidence owner 재사용

새 QA 툴을 만들지 않는다.

### Project local automated receipt

기존 읽기 전용 collector를 사용한다.

```powershell
pwsh -File tools/collect_godot_live_evidence.ps1
```

`tools/collect_godot_live_evidence.ps1`는 로컬 Git 상태, Godot 버전, import/parse, GUT JUnit, Hera smoke, 최종 worktree cleanliness를 증거로 남긴다. 이 단계가 BLOCKED/FAIL이면 원인을 먼저 해결하고 Human PASS를 주장하지 않는다.

### Windows human-visible evidence

Base의 **QA Evidence Studio**를 재사용한다. 목적은 개발자 1명이 실제 PC 빌드를 직접 보면서 checklist item별 `PASS / FAIL / BLOCKED / NOT_RUN`과 screenshot을 특정 40자리 Git commit에 묶는 것이다.

Base repository가 로컬에 준비된 경우 그 README와 CLI contract를 그대로 따른다. project repository에 두 번째 QA 도구를 복제하지 않는다.

로컬 결과는 `.asset-vault/` 또는 collector가 정한 ignored evidence 경로에 둔다. 이 디렉터리는 제품 정본이 아니다. 스크린샷/로그를 Git에 자동 커밋하지 않는다.

## 3. Phase 0 — Exact-main freshness gate

테스트 직전 반드시 다음을 확인한다.

1. GitHub `main`을 다시 조회한다.
2. 로컬 repository가 그 exact 40-char commit과 일치하는지 확인한다.
3. tracked worktree가 깨끗한지 확인한다.
4. 열린 PR을 현재 상태로 다시 확인한다.
5. Issue #54와 exact Project Notion Validation 상태를 읽는다.

테스트 세션에는 반드시 `exact_git_commit`을 기록한다. 오래된 branch·merge-preview SHA·과거 artifact의 결과를 current main Human 증거로 재사용하지 않는다.

## 4. Phase 1 — Read-only local preflight

실행:

```powershell
pwsh -File tools/collect_godot_live_evidence.ps1
```

최소 확인:

- Git repository readable.
- local HEAD == intended exact main commit.
- Godot expected 4.7.1 family is resolved according to current project contract.
- project import/parse succeeds.
- GUT JUnit required evidence exists.
- Hera smoke contract does not mutate tracked project files.
- final tracked worktree is clean.

판정:

- 하나라도 required blocker면 `BLOCKED` 또는 `FAIL`을 기록한다.
- collector PASS만으로 `Windows visible local`, Human, gamepad, Android를 PASS 처리하지 않는다.

## 5. Phase 2 — Windows visible local developer-owner pass

실제 화면으로 다음 app flow를 최소 한 번 완주한다.

```text
Main
→ Setup
→ Briefing
→ Combat
→ Review
→ Result / Reward
→ Route
→ 다음 Briefing
```

그 과정에서 Fixture `UX54-F00`~`F09`를 가능한 범위에서 재현한다.

### 필수 Windows 화면 체크

- 거리·체력·기력·내력·현재 3/3/4 묶음이 첫 시선에서 찾을 수 있다.
- `focused` 상태와 `selected` 상태가 혼동되지 않는다.
- 확정 전 카드/슬롯/대상 선택을 취소하고 다시 선택할 수 있다.
- 확정 후 잠긴 계획이 UI 입력 때문에 임의 변경되지 않는다.
- 비용 부족·거리 부족·대상 무효·슬롯 충돌이 무반응이 아니라 이유를 보여준다.
- 긴 한국어 기술 설명에서도 비용·거리·핵심 효과·행동 버튼이 잘리지 않는다.
- `[합]` 발생 뒤 계획 → 합 → 방어/회피 → 체력 피해 → 중단/강건 → 결과의 인과를 복기할 수 있다.
- 공개된 상대 정보와 아직 불확실한 상대 의도가 구분된다.
- AI 전용 무공/기술이 존재하는 것처럼 보이는 표현이 없다.

각 핵심 화면은 QA Evidence Studio의 checklist item에 연결하고, PASS라면 최소 1개 screenshot 또는 동등한 시각 evidence를 연결한다.

## 6. Phase 3 — Input matrix

입력 방식은 서로 대체하지 않는다.

### Mouse

- 카드 hover/focus.
- click selection.
- 대상/슬롯 선택.
- 취소·상세 열기/닫기·확정.

### Keyboard

- focus 이동 순서가 화면 정보 구조와 일치.
- Enter/confirm과 cancel/back 동작.
- mouse 없이 계획 → 확정 → 복기 경로 진행.
- 팝업 닫기 후 의미 있는 이전 focus로 복귀.

### physical gamepad

실물 컨트롤러로 따로 실행한다. synthetic input 또는 키보드 매핑만으로 PASS하지 않는다.

기록:

```yaml
controller_type: generic category only
connection: wired|wireless
recognized_by_os: true|false
recognized_by_godot: true|false
focus_navigation: PASS|FAIL|BLOCKED|NOT_RUN
confirm_cancel: PASS|FAIL|BLOCKED|NOT_RUN
full_plan_to_review_path: PASS|FAIL|BLOCKED|NOT_RUN
```

컨트롤러 serial, account, MAC 등 개인/기기 식별정보는 저장하지 않는다.

## 7. Phase 4 — 신규 플레이어 Human Step 14

대상은 개발 과정에 익숙하지 않은 신규 플레이어 **5명**이다. 핵심 이해 기준은 **5명 중 4명 이상**이다.

테스트 중 정답을 먼저 알려주지 않는다. 막힌 지점은 시간/화면/행동만 기록하고, 검증 질문 전에 설명으로 유도하지 않는다.

각 참가자에게 최소 다음을 확인한다.

1. 지금 사용할 수 없는 행동 하나를 보고 **왜 불가능한지** 비용/거리/대상/슬롯 중 실제 원인으로 설명할 수 있는가?
2. `focused`와 `selected`의 차이, 확정 전 cancel 가능 여부를 설명할 수 있는가?
3. 실제 `[합]` 장면 뒤 **왜 체력 결과가 그렇게 됐는지** 합·방어·회피·중단 중 실제 인과를 설명할 수 있는가?
4. 복기 후 “다음 계획에서 무엇을 바꾸겠는가?”를 말할 수 있는가?
5. 공개된 상대 단서와 아직 모르는 상대 계획을 구분할 수 있는가?
6. AI가 사용한 문파 무공을 플레이어도 같은 무공서를 배우면 사용할 수 있는 공용 기술로 이해하는가?

### PASS threshold

아래 세 핵심 이해 항목은 각각 5명 중 4명 이상이 독립적으로 성공해야 한다.

- 비용/거리/대상/슬롯 실패 원인 설명.
- focused / selected / cancel 구분.
- `[합]` 원인 → 결과 → 다음 계획 연결.

한 사람의 반복 세션을 여러 명으로 세지 않는다.

### Player-value qualitative questions

다음은 정량 PASS threshold가 아니라 개선 근거를 위한 질문이다.

- “언제 상대의 수를 읽었다고 느꼈는가?”
- “어디에서 가장 긴장했는가?”
- “패배하거나 피해를 받은 가장 큰 이유는 무엇이라고 생각하는가?”
- “복기를 보고 다음 수를 바꾸고 싶어졌는가?”
- “가장 기억에 남는 상대·무공·합 장면은 무엇인가?”
- “불공정하다고 느낀 순간이 있었는가? 있었다면 왜인가?”

`Human fun/readability/immersion`은 이 실제 세션 전까지 `NOT_RUN`이다. 자동화나 개발자 자기평가로 이를 PASS하지 않는다.

## 8. Phase 5 — Accessibility user

자동 접근성 검사는 선행 증거일 뿐 `accessibility user` PASS가 아니다.

실제 사용자와 최소 다음을 검증한다.

- 색 없이도 문파/위험/유효·무효 상태 구분.
- reduced motion에서도 상태 전이·사건 순서·결과 원인 유지.
- audio off에서도 중단·반격·상태 변화 이해.
- keyboard-only 또는 사용자가 실제 사용하는 입력 방식으로 핵심 경로 진행.
- 긴 한국어 설명과 focus outline 인지.
- animation skip/cancel 뒤에도 실제 결과와 복기 정보가 동일.

접근성 요구가 현재 제품 범위 밖 기능 추가를 필요로 하면 즉시 제품 코드를 고치지 말고 Issue #54에 FAIL/요구사항을 기록해 별도 Build Gate로 보낸다.

## 9. Phase 6 — Android actual device

### 현재 readiness

현재 `export_presets.cfg`에는 Android runnable preset이 없다. 따라서 **지금 당장 Android PASS를 만들 수 없다.** 이 패킷의 병합만으로 Android adapter 구현 권한이 생기지 않는다.

현재 상태:

```yaml
android_physical_device: NOT_RUN
android_readiness: BLOCKED_ANDROID_EXPORT_PRESET_NOT_PRESENT
runtime_mutation_authorized: false
```

### 실행 가능 조건

후속 승인된 구현으로 exact current main에 실제 Android export preset/artifact가 생긴 경우에만 다음을 수행한다.

1. exact main commit 기록.
2. Android artifact가 그 commit에서 생성됐는지 확인.
3. `adb devices`로 실제 기기 연결/authorization 확인.
4. 설치 및 launch.
5. 터치 target, safe area/cutout, 텍스트 clipping 확인.
6. Android Back 동작 확인.
7. background → foreground 복귀.
8. 가능한 경우 process recreation 후 상태 의미 확인.
9. 대표 3/3/4 계획 → 실행 → Review까지 완주.
10. 기기 모델은 필요 최소 수준의 범주만 기록하고 serial/계정/고유 식별자는 저장하지 않는다.

Android artifact가 없으면 `BLOCKED_ANDROID_EXPORT_PRESET_NOT_PRESENT` 또는 동등한 정확한 blocker를 남기며 FAIL/PASS로 세탁하지 않는다.

## 10. SHARED_PLAYER_AI_MARTIAL_POOL acceptance

Decision: `TEN-DEC-20260824-SHARED-PLAYER-AI-MARTIAL-POOL-01`.

Human/device 검증에서도 다음은 보호한다.

- AI 전용 신규 무공서 금지.
- AI 전용 무공 기술 금지.
- 플레이어가 같은 무공서를 습득하고 같은 성급/해금 조건을 만족하면 같은 기술 ID/effect authority 사용.
- 상대 개성은 무공서 조합·숙련/성급·기초 행동·행동 성향으로 표현.
- 미확정 플레이어 계획·숨은 배치·UI 의도 신호는 AI 입력 금지.

```text
BAD_CONTENT_ASYMMETRY
= 플레이어가 배울 수 없는 AI 전용 무공/기술/무공 효과가 결과 원인이 됨
```

`BAD_CONTENT_ASYMMETRY`가 나오면 difficulty tuning으로 넘기지 않고 correctness defect로 기록한다.

현재 starter six 밖 나머지 4권의 실제 획득 경로는 `NOT_ASSERTED_IMPLEMENTED`다. “player-learnable design eligibility”와 “acquisition path implementation complete”를 혼동하지 않는다.

## 11. 결과 기록 규칙

각 evidence row는 다음 상태 중 하나만 쓴다.

- `PASS`: 해당 종류의 required evidence를 실제로 확보.
- `FAIL`: 실행했고 acceptance를 충족하지 못함.
- `BLOCKED`: 실행 선행조건이 없어 판정 불가.
- `NOT_RUN`: 아직 실행하지 않음.

자동 증거는 Human PASS를 대신하지 않는다.

### 세션 최소 메타데이터

```yaml
exact_git_commit:
platform:
build_or_artifact_source:
input_mode:
fixture_ids:
started_at:
result:
evidence_locations:
blocking_reason:
```

### Issue #54 보고

세션 후 Issue #54에는 다음만 요약한다.

- exact commit.
- 실행한 evidence 종류.
- PASS/FAIL/BLOCKED/NOT_RUN.
- 재현 가능한 blocker/defect.
- 로컬 QA Evidence Studio session ID 또는 안전한 evidence locator.
- 제품 코드 수정이 필요한지 여부.

## 12. 종료 조건

Issue #54는 다음이 모두 실제 증거로 충족되기 전에는 닫지 않는다.

- Windows visible local required checks.
- mouse + keyboard 핵심 경로.
- physical gamepad가 declared shipping input이면 실제 기기 검증.
- Human Step 14 핵심 이해 3항목 각각 5명 중 4명 이상.
- accessibility user 범위의 실제 검증 또는 명시적으로 합의된 release scope 판정.
- Android가 target platform인 동안 Android actual device 증거 또는 그보다 앞선 승인된 구현 blocker 해결.
- critical `BAD_INFORMATION_LEAK` / `BAD_CONTENT_ASYMMETRY` 0건.
- 최종 Visual/VFX/Audio acceptance가 별도 evidence로 완료.
- release performance가 요구되는 release 단계에서 실제 기준을 통과.

이 조건이 충족되지 않은 상태는 **검증 준비 완료**일 수는 있어도 제품 검증 완료가 아니다.
