# 십보강호 Issue #54 Human / Device Validation Packet

> Owner: GitHub Issue `#54` — `UX-VALIDATION-001`  
> 상태: `READY_FOR_HUMAN_DEVICE_EXECUTION`  
> 대상: 이미 `main`에 병합된 첫 5전 Vertical Slice  
> runtime mutation authorization: `false`  
> Fixture: `docs/validation/TEN_PACES_UX_UI_FIXTURE_CATALOG.md`  
> Structured state: `docs/planning-data/current_issue54_human_device_validation_packet.json`

이 패킷은 새 기능을 만드는 Build 문서가 아니다. 자동 검증을 통과한 현재 제품을 **실제 Windows 화면·실제 입력 장치·신규 플레이어·접근성 사용자·Android actual device**에서 검증하고, 결과를 정확한 Git commit에 묶기 위한 실행 절차다.

가장 중요한 증거 원칙:

> **자동 증거는 Human PASS를 대신하지 않는다.**

CI, headless Godot, synthetic keyboard/mouse, export 성공은 서로 다른 종류의 증거다. 이 결과를 `Windows visible local`, `physical gamepad`, `Android actual device`, `accessibility user`, `Human fun/readability/immersion`, `15명 상대 식별성`, release performance PASS로 자동 승격하지 않는다.

## 1. 시작 상태와 증거 경계

Issue #54 실행 준비 시 기본 상태는 다음과 같다.

| Evidence | 상태 | 의미 |
|---|---|---|
| CI / automated product scenarios | PASS evidence exists | 구조·자동 시나리오 증거 |
| Windows export/runtime CI | PASS evidence exists | CI runner의 export/runtime 증거 |
| Windows visible local | `NOT_RUN` | 개발자 PC에서 실제 화면·조작 필요 |
| physical gamepad | `NOT_RUN` | 실물 컨트롤러 필요 |
| Android actual device | `NOT_RUN` | 실제 Android artifact + 실기기 필요 |
| accessibility user | `NOT_RUN` | 실제 접근성 사용자 검증 필요 |
| Human fun/readability/immersion | `NOT_RUN` | 신규 플레이어 검증 필요 |
| 15명 상대 식별성 | `NOT_RUN` | 최종 표현에서 후보별 구분 검증 필요 |
| final Visual/VFX/Audio | `NOT_RUN` | 최종 presentation evidence 필요 |
| release performance | `NOT_RUN` | release 단계 실제 성능 evidence 필요 |

### Android 준비 상태의 관측 범위

이 패킷을 준비한 `main` 기준점은 structured state의 `prepared_from_main`에 기록한다. 그 기준점의 `export_presets.cfg`에는 Windows Desktop preset만 있고 Android preset은 없었다.

이 관측은 영구 현재 사실이 아니다. **Android 실행 직전에 exact current main의 `export_presets.cfg`와 artifact를 다시 읽는다.** Android preset/artifact가 아직 없으면:

```yaml
android_physical_device: NOT_RUN
android_readiness: BLOCKED_ANDROID_EXPORT_PRESET_NOT_PRESENT
```

로 유지한다. 이 blocker를 Android PASS나 제품 결함 FAIL로 세탁하지 않는다.

## 2. Existing Solution First · Evidence owner 재사용

새 QA 툴을 만들지 않는다.

### Project local automated receipt

기존 읽기 전용 collector를 사용한다.

```powershell
pwsh -File tools/collect_godot_live_evidence.ps1
```

`tools/collect_godot_live_evidence.ps1`는 로컬 Git 상태, Godot 버전, import/parse, GUT JUnit, Hera smoke, 최종 worktree cleanliness를 증거로 남긴다. 여기서 FAIL/BLOCKED가 발생하면 원인을 먼저 기록하며 Human/device PASS를 주장하지 않는다.

### Windows human-visible evidence

Base의 **QA Evidence Studio**를 재사용한다. 개발자 owner가 실제 Windows 제품을 보면서 checklist item별 `PASS / FAIL / BLOCKED / NOT_RUN`과 screenshot을 특정 40자리 Git commit에 묶는다.

- project repository에 두 번째 QA Evidence Studio를 복제하지 않는다.
- Base의 현재 README/CLI contract를 실행 직전에 다시 읽는다.
- `.asset-vault/` 등 ignored local evidence는 제품 정본이 아니다.
- screenshot/log를 자동으로 Git에 커밋하지 않는다.

## 3. Phase 0 — Exact-main freshness gate

테스트 직전 반드시 다음을 수행한다.

1. GitHub `main`을 다시 조회한다.
2. 로컬 repository의 HEAD가 그 exact 40-char commit과 일치하는지 확인한다.
3. tracked worktree가 깨끗한지 확인한다.
4. 열린 PR을 live metadata로 다시 확인한다.
5. Issue #54, `ACTIVE_CONTEXT.md`, current JSON, exact Project Notion Validation을 다시 읽는다.
6. 테스트 세션에 `exact_git_commit`을 기록한다.

오래된 branch SHA, PR merge-preview SHA, 과거 artifact 결과를 current main Human 증거로 재사용하지 않는다.

## 4. Phase 1 — Read-only local preflight

실행:

```powershell
pwsh -File tools/collect_godot_live_evidence.ps1
```

최소 확인:

- Git repository readable.
- local HEAD == intended exact main commit.
- current project contract가 요구하는 Godot 4.7.1 계열 resolve.
- project import/parse 성공.
- required GUT JUnit evidence 존재.
- Hera smoke가 tracked project files를 변경하지 않음.
- 최종 tracked worktree clean.

판정:

- required blocker는 `BLOCKED` 또는 `FAIL`로 기록한다.
- collector PASS만으로 Windows visible, Human, gamepad, Android를 PASS 처리하지 않는다.

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

Fixture `UX54-F00`~`F09`를 현재 runtime 상태에서 가능한 범위로 재현한다.

### 필수 Windows 화면 체크

- 거리·체력·기력·내력·현재 3/3/4 묶음을 첫 시선에서 찾을 수 있다.
- `focused`와 `selected`가 시각·상태상 분리된다.
- 확정 전 카드/슬롯/대상 선택을 취소하고 복구할 수 있다.
- 확정 뒤 잠긴 계획이 UI 입력 때문에 임의 변경되지 않는다.
- 비용 부족·거리 부족·대상 무효·슬롯 충돌이 무반응이 아니라 이유를 보여준다.
- 긴 한국어 기술 설명에서도 비용·거리·핵심 효과·행동 버튼이 잘리지 않는다.
- `[합]` 뒤 계획 → 합 → 방어/회피 → 체력 피해 → 중단/강건 → 결과를 복기할 수 있다.
- 공개된 상대 정보와 아직 불확실한 상대 의도가 구분된다.
- AI 전용 무공/기술이 존재하는 것처럼 보이는 표현이 없다.

PASS라면 핵심 checklist item마다 screenshot 또는 동등한 visible evidence를 QA Evidence Studio session에 연결한다.

## 6. Phase 3 — Input matrix

입력 방식은 서로 대체하지 않는다.

### Mouse

- 카드 hover/focus.
- click selection.
- 대상/슬롯 선택.
- 취소·상세 열기/닫기·확정.

### Keyboard

- focus 이동 순서가 정보 위계와 일치.
- Enter/confirm과 cancel/back 동작.
- mouse 없이 계획 → 확정 → 복기 진행.
- 팝업 닫기 뒤 의미 있는 이전 focus로 복귀.

### physical gamepad

Issue #54 종료 전 **실물 게임패드 실제 증거가 필수**다. synthetic input, 키보드 매핑, 자동 focus 테스트로 대체하지 않는다.

```yaml
controller_type: generic category only
connection: wired|wireless
recognized_by_os: true|false
recognized_by_godot: true|false
focus_navigation: PASS|FAIL|BLOCKED|NOT_RUN
confirm_cancel: PASS|FAIL|BLOCKED|NOT_RUN
full_plan_to_review_path: PASS|FAIL|BLOCKED|NOT_RUN
```

controller serial, account, MAC 등 고유 식별정보는 저장하지 않는다.

## 7. Phase 4 — 신규 플레이어 Human Step 14

대상은 개발 과정에 익숙하지 않은 신규 플레이어 **5명**이다. 핵심 이해 기준은 **5명 중 4명 이상**이다.

- 같은 한 사람의 반복 세션을 여러 명으로 세지 않는다.
- 질문 전 정답이나 UI 사용법을 코칭하지 않는다.
- 막힌 경우 화면·행동·혼동 지점만 기록한다.

각 참가자에게 다음을 확인한다.

1. 사용할 수 없는 행동 하나를 보고 비용/거리/대상/슬롯 중 실제 실패 원인을 설명하는가?
2. `focused`와 `selected`, 확정 전 cancel 가능 여부를 구분하는가?
3. `[합]` 장면 뒤 왜 체력 결과가 그렇게 됐는지 실제 인과를 설명하는가?
4. 복기 뒤 다음 계획에서 무엇을 바꾸겠는지 설명하는가?
5. 공개 상대 단서와 아직 모르는 상대 계획을 구분하는가?
6. AI가 사용한 문파 무공을 플레이어도 같은 무공서를 배우면 사용할 수 있는 공용 기술로 이해하는가?

### PASS threshold

다음 세 항목은 **각각** 5명 중 4명 이상이 독립적으로 성공해야 한다.

- 비용/거리/대상/슬롯 실패 원인 설명.
- focused / selected / cancel 구분.
- `[합]` 원인 → 결과 → 다음 계획 연결.

### Player-value qualitative questions

정량 PASS를 조작하기 위한 점수가 아니라 개선 근거로 기록한다.

- 언제 상대의 수를 읽었다고 느꼈는가?
- 어디에서 가장 긴장했는가?
- 패배·피해의 가장 큰 이유는 무엇이라고 생각하는가?
- 복기를 보고 다음 수를 바꾸고 싶어졌는가?
- 가장 기억나는 상대·무공·합 장면은 무엇인가?
- 불공정하다고 느낀 순간이 있었는가? 왜인가?

`Human fun/readability/immersion`은 이 실제 세션 전까지 `NOT_RUN`이며 자동화나 개발자 자기평가로 PASS하지 않는다.

## 8. Phase 5 — Accessibility user

자동 접근성 검사는 선행 증거일 뿐 `accessibility user` PASS가 아니다. **Issue #54 종료에는 accessibility user 실제 증거가 필요하다.**

실제 사용자와 최소 다음을 검증한다.

- 색 없이도 문파/위험/유효·무효 상태 구분.
- reduced motion에서도 상태 전이·사건 순서·결과 원인 유지.
- audio off에서도 중단·반격·상태 변화 이해.
- keyboard-only 또는 사용자가 실제 쓰는 입력 방식으로 핵심 경로 진행.
- 긴 한국어 설명과 focus outline 인지.
- animation skip/cancel 뒤에도 실제 결과와 복기 정보 동일.

제품 코드 수정이 필요하면 이 패킷에서 즉시 고치지 않고 Issue #54에 FAIL/요구사항을 기록해 별도 Build Gate로 보낸다.

## 9. Phase 6 — Android actual device

### 실행 가능 조건

exact current main에 승인된 Android export preset/artifact가 생긴 뒤에만 실행한다.

1. exact main commit 기록.
2. Android artifact가 그 commit에서 생성됐는지 확인.
3. `adb devices`로 실제 기기 연결/authorization 확인.
4. 설치 및 launch.
5. touch target, safe area/cutout, 텍스트 clipping 확인.
6. Android Back 동작 확인.
7. background → foreground 복귀.
8. 가능한 경우 process recreation 뒤 상태 의미 확인.
9. 대표 3/3/4 계획 → 실행 → Review 완주.
10. serial/계정/고유 식별자는 기록하지 않는다.

Android artifact가 없으면 `BLOCKED_ANDROID_EXPORT_PRESET_NOT_PRESENT` 또는 그 시점의 정확한 blocker를 기록한다. **blocker가 해결됐다는 사실만으로 Issue #54를 닫지 않으며, Android actual device 실제 증거까지 필요하다.**

공식 Android 개발 문서와 Godot 배포 가이드는 release 전 실제 hardware-device 테스트와 ADB/USB debugging 기반 실제 장치 실행을 권장한다. 실행 시점에는 현재 Godot/Android 공식 문서를 다시 확인한다.

## 10. Phase 7 — 15명 상대 식별성 + final presentation

Issue #54가 요구하는 `15명 상대 식별성`과 final Visual/VFX/Audio를 별도 visible evidence로 검증한다.

15명 후보는 한 run에서 전부 등장하지 않으므로, **현재 runtime의 결정적 seed/candidate selection 또는 이미 존재하는 QA fixture를 사용해 후보를 반복 재현**한다. 이를 위해 신규 상대·신규 선택 규칙을 만들지 않는다.

각 후보에 대해 확인한다.

- 이름/문파/대표 무공/행동 습관이 다른 후보와 구분된다.
- 외형·실루엣·UI 표지·무공 표현 중 현재 구현된 범위에서 기억점이 있다.
- 같은 무공서를 쓰는 다른 상대도 행동 성향/운용 차이로 구분된다.
- VFX가 판정 순서를 가리거나 잘못된 인과를 만들지 않는다.
- audio off/reduced motion에서도 핵심 사건 의미가 보존된다.
- placeholder 또는 미완성 asset이면 PASS로 세탁하지 않고 `BLOCKED`/`NOT_RUN`을 유지한다.

`fifteen_opponent_identifiability`와 `final_visual_vfx_audio_acceptance`는 각각 실제 evidence가 생기기 전까지 `NOT_RUN`이다.

## 11. SHARED_PLAYER_AI_MARTIAL_POOL acceptance

Decision: `TEN-DEC-20260824-SHARED-PLAYER-AI-MARTIAL-POOL-01`.

Human/device 검증에서도 다음을 보호한다.

- AI 전용 신규 무공서 금지.
- AI 전용 무공 기술 금지.
- 플레이어가 같은 무공서를 습득하고 같은 성급/해금 조건을 만족하면 동일 기술 ID/effect authority 사용.
- 상대 개성은 무공서 조합·숙련/성급·기초 행동·행동 성향으로 표현.
- 미확정 플레이어 계획·숨은 배치·UI 의도 신호는 AI 입력 금지.

```text
BAD_CONTENT_ASYMMETRY
= 플레이어가 배울 수 없는 AI 전용 무공/기술/무공 효과가 결과 원인이 됨
```

`BAD_CONTENT_ASYMMETRY`는 난이도 조정이 아니라 correctness defect다.

starter six 밖 나머지 4권의 실제 획득 경로는 `NOT_ASSERTED_IMPLEMENTED`다. player-learnable design eligibility와 acquisition implementation complete를 혼동하지 않는다.

## 12. 결과 기록 규칙

각 evidence row는 다음 중 하나만 쓴다.

- `PASS`: 해당 종류의 required evidence를 실제 확보.
- `FAIL`: 실행했고 acceptance 미충족.
- `BLOCKED`: 선행조건이 없어 판정 불가.
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

세션 후 다음을 요약한다.

- exact commit.
- 실행한 evidence 종류.
- PASS/FAIL/BLOCKED/NOT_RUN.
- 재현 가능한 blocker/defect.
- QA Evidence Studio session ID 또는 안전한 local evidence locator.
- 제품 코드 수정 필요 여부.

## 13. 종료 조건

Issue #54는 다음이 **모두 실제 증거로 충족**되기 전에는 닫지 않는다.

- Windows visible local required checks 실제 증거.
- mouse + keyboard 핵심 경로 실제 증거.
- physical gamepad 실제 증거.
- Human Step 14 핵심 이해 3항목 각각 5명 중 4명 이상.
- accessibility user 실제 증거.
- Android target의 Android actual device 실제 증거.
- 15명 상대 식별성 실제 증거.
- critical `BAD_INFORMATION_LEAK` / `BAD_CONTENT_ASYMMETRY` 0건.
- 최종 Visual/VFX/Audio acceptance 실제 증거.
- release gate에서 요구하는 release performance 실제 증거.

이 조건이 충족되지 않은 상태는 **검증 준비 완료**일 수는 있어도 제품 검증 완료가 아니다.
