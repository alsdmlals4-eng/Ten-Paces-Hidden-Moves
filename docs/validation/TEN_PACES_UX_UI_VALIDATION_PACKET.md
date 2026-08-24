# 십보강호 Issue #54 Human / Device Validation Packet

> Owner: GitHub Issue `#54` — `UX-VALIDATION-001`  
> 상태: `READY_FOR_HUMAN_DEVICE_EXECUTION`  
> 대상: 이미 `main`에 병합된 첫 5전 Vertical Slice  
> runtime mutation authorization: `false`  
> Fixture: `docs/validation/TEN_PACES_UX_UI_FIXTURE_CATALOG.md`  
> Structured state: `docs/planning-data/current_issue54_human_device_validation_packet.json`

이 패킷은 새 기능을 만드는 Build 문서가 아니다. 자동 검증을 통과한 현재 제품을 **실제 Windows 화면·실제 입력 장치·신규 플레이어·접근성 사용자·Android actual device**에서 검증하고, 결과를 정확한 Git commit과 실제 실행에 묶기 위한 절차다.

> **자동 증거는 Human PASS를 대신하지 않는다.**

CI, headless Godot, synthetic keyboard/mouse, export 성공은 서로 다른 증거다. 이 결과를 `Windows visible local`, `physical gamepad`, `Android actual device`, `accessibility user`, `Human fun/readability/immersion`, `15명 상대 식별성`, final Visual/VFX/Audio, release performance PASS로 자동 승격하지 않는다.

## 1. 시작 상태와 증거 경계

| Evidence | 상태 | 의미 |
|---|---|---|
| CI / automated product scenarios | PASS evidence exists | 구조·자동 시나리오 증거 |
| Windows export/runtime CI | PASS evidence exists | CI runner export/runtime 증거 |
| Windows visible local | `NOT_RUN` | 실제 Windows 화면·조작 필요 |
| physical gamepad | `NOT_RUN` | 실물 컨트롤러 필요 |
| Android actual device | `NOT_RUN` | 실제 Android artifact + 실기기 필요 |
| accessibility user | `NOT_RUN` | 실제 접근성 사용자 필요 |
| Human fun/readability/immersion | `NOT_RUN` | 신규 플레이어 필요 |
| 15명 상대 식별성 | `NOT_RUN` | 후보별 visible evidence 필요 |
| final Visual/VFX/Audio | `NOT_RUN` | 최종 presentation evidence 필요 |
| release performance | `NOT_RUN` | release gate 실제 성능 evidence 필요 |

### Android 준비 상태의 관측 범위

이 패킷의 structured state에 `prepared_from_main` 기준점을 보존한다. 그 기준점의 `export_presets.cfg`에는 Windows Desktop preset만 있고 Android preset은 없었다. 이 관측을 영구 현재 사실로 취급하지 않는다.

Android 실행 직전에 exact current main의 `export_presets.cfg`와 artifact를 다시 읽는다. Android preset/artifact가 아직 없으면:

```yaml
android_physical_device: NOT_RUN
android_readiness: BLOCKED_ANDROID_EXPORT_PRESET_NOT_PRESENT
```

로 유지하며 PASS/FAIL로 세탁하지 않는다.

## 2. Existing Solution First · Evidence owner 재사용

새 QA 툴을 만들지 않는다.

### Project local automated receipt

```powershell
pwsh -File tools/collect_godot_live_evidence.ps1
```

`tools/collect_godot_live_evidence.ps1`는 로컬 Git, Godot 버전, import/parse, GUT JUnit, Hera smoke, 최종 worktree cleanliness를 확인한다. required blocker는 `BLOCKED` 또는 `FAIL`로 기록한다.

### Windows human-visible evidence

Base의 **QA Evidence Studio**를 재사용한다.

- 실제 Windows 제품을 보는 developer-owner checklist와 screenshot을 exact 40-char Git commit에 묶는다.
- project repository에 두 번째 QA Evidence Studio를 복제하지 않는다.
- Base의 현재 README/CLI contract를 실행 직전에 다시 읽는다.
- `.asset-vault/` 등 ignored local evidence는 제품 정본이 아니다.
- screenshot/log를 자동 Git commit하지 않는다.

## 3. FRESH_RUNTIME_ARTIFACT_GATE

Base의 최신 `FRESH_RUNTIME_ARTIFACT_GATE`를 Issue #54 실행에도 적용한다.

`PRIOR_ARTIFACT_EXISTENCE_IS_NOT_FRESH_EVIDENCE`: 과거 build, screenshot, video, runtime report, trace가 디스크에 남아 있다는 사실만으로 현재 commit/run의 PASS를 주장하지 않는다. 이는 `STALE_ARTIFACT_FALSE_PASS`를 막기 위한 fail-closed 규칙이다.

```text
exact build/commit + run identity 고정
→ 재생성 가능한 이전 transient output을 삭제·격리하거나 unique run directory 사용
→ 현재 producer/runtime를 실제 실행
→ 이번 run이 expected artifact를 새로 생성했는지 확인
→ artifact path + bytes/hash + run/build identity를 evidence에 묶음
→ semantic/runtime assertion과 함께 판정
```

- baseline/golden은 비교 기준이므로 transient output처럼 무조건 삭제하지 않고 identity를 pin한다.
- screenshot/video/runtime report/trace처럼 재생성 가능한 material evidence는 가능한 한 현재 run에서 새로 만든다.
- 같은 파일명을 쓰면 이전 파일을 격리/제거한 뒤 새 생성 여부와 bytes 또는 hash를 확인한다.
- current capture/runtime 환경 부재, producer 실패, timeout, fresh artifact 미생성이면 `INCONCLUSIVE_NOT_PASS` 또는 더 구체적인 `BLOCKED_UNVERIFIED`로 남긴다.
- fresh artifact는 **품질 자체의 증거가 아니다**. fresh screenshot도 가독성·재미·접근성·Human approval을 자동 증명하지 않는다.
- deterministic state가 구조화 assertion으로 충분하면 screenshot을 강제하지 않는다. 반대로 pixel/layout/presentation이 acceptance 대상이면 fresh visual artifact가 필요하다.

## 4. Exact-main freshness preflight

실행 직전:

1. GitHub `main`을 다시 조회한다.
2. Base `main`도 다시 조회하고 현재 evidence 규칙을 읽는다.
3. 로컬 HEAD가 intended exact 40-char main commit과 일치하는지 확인한다.
4. tracked worktree가 clean인지 확인한다.
5. 열린 PR live metadata를 확인한다.
6. Issue #54, `ACTIVE_CONTEXT.md`, current JSON, exact Project Notion Validation을 읽는다.
7. 모든 세션에 `exact_git_commit`과 run identity를 기록한다.

오래된 branch SHA, PR merge-preview SHA, 과거 artifact를 current Human/device evidence로 재사용하지 않는다.

### Exact-main Product Gate route

`Validate Ten Manual Product Gate`의 exact-main route는 **PR #195**에서 병합됐다. route 설치 merge는 `020b5cabf3f5d8d950b089dfefdd9bd148333b8a`이며, 제품/runtime/export/evidence producer 관련 변경이 `main`에 들어오면 path-scoped `push` 실행 대상이 된다.

확인된 최신 fresh CI 증거는 PR exact head `869b9cd54c778848638ac87721c1d1eb349d97cd`, run `32714634940`, Windows artifact `9515454613`, digest `sha256:a72a46df70005c6f5def8e05457a57957e3fd5b1af73969377700666cca080ae`다. 이 증거는 PR-head 검증이며 exact-main merge SHA의 push-run PASS와 동일하지 않다.

현재 연결은 pull-request-triggered Actions run만 조회할 수 있어 route 설치 merge SHA의 실제 push-run 결과는 `UNVERIFIED_CONNECTOR_LIMIT`이다. 이후 실행에서는 Actions/Check evidence를 다시 조회하고 exact-main run identity와 fresh artifact가 실제 확인될 때만 PASS로 승격한다. 관측할 수 없거나 fresh output이 없으면 `UNVERIFIED_CONNECTOR_LIMIT` 또는 `INCONCLUSIVE_NOT_PASS`를 유지하며 **push-run PASS로 승격하지 않는다**.

이 route의 CI 성공 여부는 자동 제품 증거 범위일 뿐 `Windows visible local`, `physical gamepad`, `Android actual device`, `accessibility user`, Human 이해·재미·가독성·몰입을 대신하지 않는다.

## 5. Windows visible local developer-owner pass

실제 화면에서 최소 다음 경로를 완주한다.

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

Fixture `UX54-F00`~`F09`를 실제 runtime 상태에서 가능한 범위로 재현한다.

필수 확인:

- 거리·체력·기력·내력·현재 3/3/4 묶음을 찾을 수 있다.
- `focused`와 `selected`가 구분된다.
- 확정 전 취소·재선택이 가능하다.
- 확정 뒤 잠긴 계획이 임의 변경되지 않는다.
- 비용 부족·거리 부족·대상 무효·슬롯 충돌의 이유가 보인다.
- 긴 한국어 기술 설명에서도 비용·거리·핵심 효과·행동 버튼이 잘리지 않는다.
- `[합]` 뒤 계획 → 합 → 방어/회피 → 체력 피해 → 중단/강건 → 결과 인과를 복기한다.
- 공개 상대 정보와 아직 불확실한 상대 의도가 분리된다.
- AI 전용 무공/기술이 존재하는 것처럼 보이는 표현이 없다.

PASS visual 항목은 현재 run에서 생성한 screenshot 등 fresh evidence를 QA Evidence Studio session에 연결한다.

## 6. Input matrix

### Mouse

- hover/focus.
- click selection.
- 대상/슬롯 선택.
- cancel/detail/confirm.

### Keyboard

- focus 순서가 정보 위계와 일치.
- Enter/confirm, cancel/back.
- mouse 없이 계획 → 확정 → 복기.
- popup 닫기 뒤 의미 있는 이전 focus 복귀.

### physical gamepad

Issue #54 종료 전 **physical gamepad 실제 증거가 필수**다. synthetic input, 키보드 mapping, 자동 focus 테스트로 대체하지 않는다.

```yaml
controller_type: generic category only
connection: wired|wireless
recognized_by_os: true|false
recognized_by_godot: true|false
focus_navigation: PASS|FAIL|BLOCKED|NOT_RUN
confirm_cancel: PASS|FAIL|BLOCKED|NOT_RUN
full_plan_to_review_path: PASS|FAIL|BLOCKED|NOT_RUN
```

serial/account/MAC 등 고유 식별정보는 저장하지 않는다.

## 7. 신규 플레이어 Human Step 14

대상은 개발 과정에 익숙하지 않은 신규 플레이어 **5명**이며 핵심 이해 기준은 **5명 중 4명 이상**이다.

- 한 사람의 반복 세션을 여러 명으로 세지 않는다.
- 질문 전 정답이나 사용법을 코칭하지 않는다.
- 막힌 경우 화면·행동·혼동 지점을 기록한다.

각 참가자에게 확인한다.

1. 불가능한 행동의 비용/거리/대상/슬롯 중 실제 실패 원인을 설명하는가?
2. `focused` / `selected` / 확정 전 cancel을 구분하는가?
3. 실제 `[합]` 뒤 결과의 인과를 설명하는가?
4. 복기 뒤 다음 계획에서 바꿀 점을 말하는가?
5. 공개 상대 단서와 아직 모르는 계획을 구분하는가?
6. AI의 문파 무공이 플레이어도 같은 무공서를 배우면 쓸 수 있는 공용 기술임을 이해하는가?

다음 세 핵심 항목은 **각각 5명 중 4명 이상** 성공해야 한다.

- 비용/거리/대상/슬롯 실패 원인 설명.
- focused / selected / cancel 구분.
- `[합]` 원인 → 결과 → 다음 계획 연결.

### Player-value qualitative questions

- 언제 상대의 수를 읽었다고 느꼈는가?
- 어디에서 가장 긴장했는가?
- 패배·피해의 가장 큰 이유는 무엇인가?
- 복기를 보고 다음 수를 바꾸고 싶어졌는가?
- 가장 기억나는 상대·무공·합 장면은 무엇인가?
- 불공정하다고 느낀 순간이 있었는가? 왜인가?

이 질문은 개선 근거이며 정량 PASS를 조작하는 점수가 아니다. `Human fun/readability/immersion`은 실제 세션 전까지 `NOT_RUN`이다.

## 8. Accessibility user

자동 접근성 검사는 선행 증거일 뿐 `accessibility user` PASS가 아니다. Issue #54 종료에는 **accessibility user 실제 증거**가 필요하다.

- 색 없이 문파/위험/유효·무효 상태 구분.
- reduced motion에서도 사건 순서·원인 유지.
- audio off에서도 중단·반격·상태 변화 이해.
- keyboard-only 또는 사용자의 실제 입력 방식으로 핵심 경로 진행.
- 긴 한국어 설명과 focus outline 인지.
- animation skip/cancel 뒤에도 결과·복기 의미 동일.

제품 수정이 필요하면 즉시 고치지 않고 Issue #54에 FAIL/요구사항을 기록해 별도 Build Gate로 보낸다.

## 9. Android actual device

exact current main에 승인된 Android export preset/artifact가 생긴 뒤에만 실행한다. artifact는 `FRESH_RUNTIME_ARTIFACT_GATE`를 통과한 **현재 exact commit/run에서 새로 생성한 것**이어야 한다.

1. exact main commit + run identity 기록.
2. 현재 run에서 Android artifact를 새로 생성하고 path/bytes/hash를 기록.
3. `adb devices`로 실제 기기 연결/authorization 확인.
4. install + launch.
5. touch target, safe area/cutout, text clipping.
6. Android Back.
7. background → foreground.
8. 가능한 경우 process recreation.
9. 대표 3/3/4 계획 → 실행 → Review 완주.
10. serial/account 등 고유 식별정보는 저장하지 않는다.

Android artifact가 없으면 해당 시점의 정확한 blocker를 기록한다. blocker가 해결됐다는 사실만으로 Issue #54를 닫지 않으며 **Android actual device 실제 증거까지 필요**하다.

## 10. 15명 상대 식별성 + final presentation

Issue #54가 요구하는 `15명 상대 식별성`과 final Visual/VFX/Audio를 별도 fresh visible evidence로 검증한다.

15명 후보는 한 run에서 전부 등장하지 않으므로 현재 runtime의 결정적 seed/candidate selection 또는 기존 QA fixture를 이용해 반복 재현한다. 신규 상대·선택 규칙을 만들지 않는다.

- 이름/문파/대표 무공/행동 습관이 다른 후보와 구분된다.
- 외형·실루엣·UI 표지·무공 표현 중 구현된 범위에 기억점이 있다.
- 같은 무공서를 쓰는 상대도 행동 성향/운용 차이로 구분된다.
- VFX가 판정 순서나 인과를 왜곡하지 않는다.
- audio off/reduced motion에서도 핵심 사건 의미가 보존된다.
- placeholder/미완성 asset은 PASS로 세탁하지 않고 `BLOCKED`/`NOT_RUN`을 유지한다.

`fifteen_opponent_identifiability`와 `final_visual_vfx_audio_acceptance`는 실제 evidence 전까지 `NOT_RUN`이다.

## 11. SHARED_PLAYER_AI_MARTIAL_POOL acceptance

Decision: `TEN-DEC-20260824-SHARED-PLAYER-AI-MARTIAL-POOL-01`.

- AI 전용 신규 무공서 금지.
- AI 전용 무공 기술 금지.
- 같은 무공서·같은 성급/해금 조건이면 플레이어와 AI가 동일 기술 ID/effect authority 사용.
- 상대 개성은 무공서 조합·숙련/성급·기초 행동·행동 성향에서 만든다.
- 미확정 플레이어 계획·숨은 배치·UI 의도 신호는 AI 입력 금지.

```text
BAD_CONTENT_ASYMMETRY
= 플레이어가 배울 수 없는 AI 전용 무공/기술/무공 효과가 결과 원인이 됨
```

`BAD_CONTENT_ASYMMETRY`는 difficulty tuning이 아니라 correctness defect다. starter six 밖 나머지 4권의 실제 획득 경로는 `NOT_ASSERTED_IMPLEMENTED`이며 player-learnable eligibility와 acquisition implementation complete를 혼동하지 않는다.

## 12. 결과 기록

각 evidence row는 `PASS | FAIL | BLOCKED | NOT_RUN` 중 하나만 쓴다.

```yaml
exact_git_commit:
run_identity:
platform:
build_or_artifact_source:
artifact_path:
artifact_bytes:
artifact_hash:
input_mode:
fixture_ids:
started_at:
result:
evidence_locations:
blocking_reason:
```

Issue #54에는 exact commit/run identity, evidence 종류, PASS/FAIL/BLOCKED/NOT_RUN, 재현 blocker/defect, QA Evidence Studio session ID 또는 안전한 local locator, 제품 코드 수정 필요 여부를 요약한다.

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
- release gate가 요구하는 release performance 실제 증거.
- 각 runtime/render PASS 근거가 해당 exact run의 `FRESH_RUNTIME_ARTIFACT_GATE`를 만족.

이 조건이 충족되지 않은 상태는 **검증 준비 완료**일 수는 있어도 제품 검증 완료가 아니다.