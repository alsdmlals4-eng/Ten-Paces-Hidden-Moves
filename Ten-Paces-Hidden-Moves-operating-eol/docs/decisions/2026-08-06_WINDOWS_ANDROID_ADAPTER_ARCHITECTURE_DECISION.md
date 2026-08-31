# Windows·Android Adapter Architecture Decision

```yaml
decision_id: TEN-DEC-20260806-WINDOWS-ANDROID-ADAPTER-ARCHITECTURE-01
date: 2026-08-06
status: CURRENT_APPROVED_PLANNING
implementation_authority: PLANNING_CONTRACT_ONLY
parent_decision: TEN-DEC-20260806-WINDOWS-ANDROID-DUAL-TARGET-01
approval_batch: 1/10
next_gate: WINDOWS_ANDROID_ADAPTER_IMPLEMENTATION_GATE
```

## 결정

Windows와 Android는 하나의 전투·AI·콘텐츠·수치·저장 코어를 사용한다. 플랫폼 차이는 다음 다섯 Adapter에서만 처리한다.

1. `INPUT`
2. `RESPONSIVE_UI`
3. `APP_LIFECYCLE`
4. `PLATFORM_SERVICES`
5. `QUALITY_EXPORT`

플랫폼마다 별도 전투 규칙, AI 의사결정, 카드 ID, 성장 수치, 저장 의미를 두지 않는다. 화면 배치·입력 장치·앱 중단/복귀·플랫폼 SDK·export 방식은 달라도 같은 입력 의도는 같은 합법성·판정·보상·저장 결과를 만들어야 한다.

## 핵심 재미 보호

이 결정은 모바일 기능을 추가하는 결정이 아니라 핵심 재미를 플랫폼 분기로부터 보호하는 결정이다.

```text
공개 단서 관찰
→ 잠긴 상대 계획 추론
→ 비공개 3/3/4 계획 확정
→ 거리·순서·합·방어·회피·중단 해결
→ 원인 복기
→ 다음 계획 변경
```

다음은 금지한다.

- Android에서만 쉬운 거리·비용·합·중단 규칙.
- 작은 화면을 이유로 상대 정보 또는 복기 원인을 삭제.
- 터치 편의를 이유로 정답 행동·자동 대응을 추천.
- 플랫폼별 별도 세이브 구조로 성장·획득 의미가 달라지는 것.
- 성능 차이를 이유로 AI 탐색 규칙이나 난이도 수치를 변경하는 것.

## 현행 프로젝트 감사

현재 확인 상태는 다음과 같다.

| 항목 | 현재 상태 | 판정 |
|---|---|---|
| 전투·AI·무공 데이터 | 공통 GDScript·JSON | 공유 코어로 유지 |
| Renderer | Windows·mobile 모두 `gl_compatibility` | 2D·저사양 공통 기준선으로 유지 |
| Windows export | Release 검증 preset 존재 | 기존 자동 증거 유지 |
| Android export | preset 없음 | `NOT_RUN` |
| InputMap 제품 Action | 프로젝트 설정에 별도 `[input]` 없음 | 구현 Gate에서 추가 |
| UI 입력 | 일부 leaf control이 `InputEventKey`·mouse click 직접 처리 | `MIGRATION_REQUIRED_NOT_PRODUCT_FAILURE` |
| RunSession·SaveService | 제품 서비스 없음 | 구현 Gate에서 추가 |
| Safe area·cutout | 제품 adapter 없음 | 구현 Gate에서 추가 |
| Android lifecycle·back | 제품 adapter 없음 | 구현 Gate에서 추가 |

직접 입력을 사용하는 현재 leaf control은 제품 실패로 판정하지 않는다. 기존 포커스·`ui_accept`·mouse click 동작을 보존하면서 논리 명령 계층으로 이동해야 할 migration inventory다.

## 현업·공식 지침 비교

- Godot Input action system은 키보드와 controller를 별도 게임 규칙 코드 없이 같은 action으로 연결할 수 있다. 핵심 controller는 raw key/button이 아니라 logical command 또는 InputMap action을 소비한다.
- Godot Compatibility renderer는 2D와 저사양 desktop/mobile에서 가장 넓은 하드웨어 범위를 제공한다. 현재 프로젝트가 이미 desktop·mobile 공통으로 사용하므로 별도 근거 없이 renderer를 분기하지 않는다.
- Android·Godot은 safe area와 display cutout 처리를 요구한다. 배경은 edge-to-edge가 가능하지만 버튼·텍스트·전투 선택 영역은 system bar와 cutout에 가려지면 안 된다.
- Android 접근성 기준에 따라 핵심 touch target 기본값은 `48dp × 48dp`다.
- Android back은 즉시 종료가 아니라 overlay 닫기 → 되돌릴 수 있는 단계 취소 → pause/종료 확인 순서로 처리한다.
- Android lifecycle의 pause 구간은 짧을 수 있으므로 pause 시점 하나에만 저장을 의존하지 않는다. 결정적 경계마다 idempotent checkpoint를 만들고 stop/suspend에서 dirty checkpoint를 flush한다.
- Google Play 배포 artifact는 Release AAB를 사용하며 keystore와 password는 저장소에 넣지 않는다.

참조:

- Godot controllers/gamepads: https://docs.godotengine.org/en/latest/tutorials/inputs/controllers_gamepads_joysticks.html
- Godot input examples: https://docs.godotengine.org/en/latest/tutorials/inputs/input_examples.html
- Godot renderer overview: https://docs.godotengine.org/en/stable/tutorials/rendering/renderers.html
- Godot DisplayServer safe area/cutout/back: https://docs.godotengine.org/en/4.7/classes/class_displayserver.html
- Godot Android export: https://docs.godotengine.org/en/latest/tutorials/export/exporting_for_android.html
- Android accessibility touch targets: https://developer.android.com/guide/topics/ui/accessibility/apps
- Android edge-to-edge and insets: https://developer.android.com/develop/ui/views/layout/insets
- Android activity lifecycle: https://developer.android.com/guide/components/activities/activity-lifecycle

## 1. Input Adapter

### 논리 명령

```text
NAVIGATE_LEFT / RIGHT / UP / DOWN
CONFIRM
CANCEL_BACK
TAB_PREVIOUS / TAB_NEXT
COMBAT_SELECT
COMBAT_REMOVE
COMBAT_COMMIT
COMBAT_INSPECT
REVIEW_PREVIOUS / REVIEW_NEXT
PAUSE_MENU
```

매핑 원칙:

| 의도 | Windows | Android |
|---|---|---|
| 이동·포커스 | keyboard / gamepad | touch focus / optional gamepad |
| 확인 | Enter·Space·gamepad accept·left click | tap·optional gamepad accept |
| 취소·뒤로 | Esc·gamepad cancel | Android back·화면 취소 버튼 |
| 선택 | mouse click·focus confirm | tap·focus confirm |
| 제거 | right click 또는 명시 버튼 | 명시 버튼·long press는 보조만 |
| 재배치 | pointer drag + 버튼 대안 | touch drag + 버튼 대안 |

보호 규칙:

- hover만으로 공개되는 필수 정보 금지.
- drag만으로 가능한 핵심 행동 금지.
- 터치와 mouse의 hit testing 결과가 달라도 전투 명령 payload는 동일해야 한다.
- core controller는 raw `InputEventKey`, button index, screen coordinate를 직접 읽지 않는다.
- leaf control은 device event를 logical command로 번역할 수 있다.

## 2. Responsive UI Adapter

레이아웃 동일성이 아니라 정보·행동 동일성을 요구한다.

```yaml
compact_max: 899 logical px
standard_max: 1439 logical px
wide_min: 1440 logical px
minimum_touch_target: 48dp (Android density-independent unit; raw pixel 고정값 아님)
breakpoint_measure: available safe-area UI logical width (framebuffer pixel 아님)
orientation: LANDSCAPE_PRIMARY
portrait_t1: NOT_SUPPORTED
```

| 구간 | 기본 구조 |
|---|---|
| Compact | stacked panel 또는 bottom sheet, 한 번에 하나의 주 작업 영역 |
| Standard | 전장 + 적응형 보조 영역 2개 |
| Wide | 현행 multi-panel 기준선 |

모든 구간에 남아야 하는 정보:

- 현재 거리와 타일 위치.
- 3/3/4 묶음 진행 상태.
- 선택 행동의 비용·사거리·방향·조건.
- 공개된 적 행동 종류와 잠금 상태.
- 합·방어·회피·중단·피해 원인.
- commit, remove, inspect, cancel/back.

색만으로 상태를 구분하지 않고 텍스트·아이콘·형태를 함께 사용한다. 글자 확대가 핵심 행동을 화면 밖으로 영구 밀어내면 실패다.

## 3. Android Window Adapter

제품 구현은 다음 Godot API를 사용한다.

```text
DisplayServer.get_display_safe_area()
DisplayServer.get_display_cutouts()
WINDOW_EVENT_GO_BACK_REQUEST
orientation_changed
```

safe area는 시작, resize, orientation change, resume에서 다시 계산한다. DisplayServer가 반환한 display-space 좌표는 viewport·Control 좌표계로 변환한 뒤 레이아웃에 적용한다. 배경·장식은 edge-to-edge를 허용하지만 핵심 선택 영역은 system bar·cutout과 겹치지 않는다.

Back 우선순위:

```text
CLOSE_TOP_OVERLAY
→ CANCEL_REVERSIBLE_STEP
→ OPEN_PAUSE_CONFIRM
→ REQUEST_EXIT
```

전투 묶음이 이미 commit된 뒤에는 back으로 묶음을 취소하지 않는다.

## 4. App Lifecycle Adapter

```yaml
focus_lost: PAUSE_PRESENTATION_AND_BLOCK_NEW_COMMIT
pause: QUEUE_IDEMPOTENT_CHECKPOINT
stop_or_suspend: FLUSH_CHECKPOINT_IF_DIRTY
resume: RESTORE_UI_THEN_ACCEPT_INPUT
background_simulation: false
```

checkpoint 경계:

1. `BUNDLE_COMMITTED`
2. `BUNDLE_RESOLVED`
3. `ROUTE_NODE_CHOSEN`
4. `RESULT_ENTERED`

중간 연출 또는 effect pipeline 도중 앱이 중단되면 마지막 완료된 결정적 경계로 복구한다. resume 과정은 같은 피해·보상·성취도 효과를 두 번 적용하면 안 된다.

## 5. Save Contract

```yaml
root: user://
schema: SHARED_CROSS_PLATFORM
write: TEMP_WRITE_VALIDATE_ATOMIC_REPLACE
backup_count: 1
cloud_sync: DEFERRED
```

필수 envelope:

- `schema_version`
- `save_id`
- `written_at_utc`
- `app_version`
- `run_state`
- `integrity_hash` — 우발적 손상 탐지용이며 보안·위변조 방지 경계로 간주하지 않는다.

primary가 손상되면 backup을 검증한 뒤 복구한다. 둘 다 실패하면 새 run 시작 여부를 명시적으로 묻는다. 플랫폼별 gameplay field는 금지하고 migration test가 없는 schema 변경은 병합하지 않는다.

## 6. Platform Services Adapter

Store SDK, cloud save, achievement, billing, ads, push notification은 이 Decision에서 구현하지 않는다. 향후 adapter가 추가되어도 offline 전투 규칙을 바꾸면 안 된다.

- haptic: 선택적 presentation feedback만 허용.
- analytics: 별도 동의·데이터 최소화 Decision 전 `DEFERRED`.
- account·cross-save: 별도 서비스·개인정보·충돌 해결 Decision 필요.

## 7. Quality·Export Adapter

공통 renderer 기준선은 `GL_COMPATIBILITY`다. 더 높은 품질은 선택적 presentation tier로만 추가할 수 있고 판정·가시 정보량을 바꾸면 안 된다.

```yaml
windows_release: EXE_PLUS_PCK_RELEASE
android_store: AAB_RELEASE
android_local_device: APK_DEBUG_OR_RELEASE
android_architecture: ARM64
keystore_repository: FORBIDDEN
signing_secret: ENVIRONMENT_OR_SECRET_STORE_ONLY
custom_gradle_now: false
```

AAB·APK·keystore·Android SDK 설치는 구현 Gate의 범위이며 현재는 `NOT_RUN`이다.

## 구현 패키지 순서

```text
PLATFORM_COMMAND_ROUTER
→ RESPONSIVE_ROOT_AND_SAFE_AREA
→ RUN_SESSION_AND_SAVE_SERVICE
→ ANDROID_EXPORT_AND_DEVICE_GATE
```

각 패키지는 독립 TDD와 exact-head 검증을 가져야 한다.

## 검증 Gate

### 정적·자동

- logical command set과 device map.
- core가 raw device event를 직접 소비하지 않는지 검사.
- compact/standard/wide에서 정보·행동 동등성.
- 48dp touch target과 색 외 상태 채널.
- safe area·cutout·back 우선순위.
- checkpoint serialization·atomic replace·backup·migration.
- pause/resume 반복 시 effect·보상 중복 없음.
- Windows와 Android 동일 seed·동일 command stream 결과 비교.

### 실제 장치

- Windows local render.
- physical gamepad.
- Android AAB/APK export.
- 설치·실행·재실행.
- touch·back·safe area·cutout.
- background/foreground·pause/resume·process recreation.
- 저·중·고 성능 Android 장치 frame time·memory·thermal 관찰.
- 접근성 사용자 실사용.

현재 실제 장치 항목은 모두 `NOT_RUN`이다.

## 대안 검토

### A. PC 완성 후 Android 포팅

기각. UI·입력·저장·생명주기가 desktop 구조에 결합된 뒤 분리 비용과 회귀 위험이 커진다.

### B. Windows와 Android 제품 코드를 분기

기각. 전투·AI·수치·저장 권위가 갈라져 핵심 재미와 밸런스 검증 비용이 두 배 이상으로 증가한다.

### C. 모든 화면을 지금부터 모바일 최저 폭에 고정

기각. PC의 정보 밀도와 복기 가독성을 불필요하게 약화한다. 공통 semantic model과 breakpoint layout을 사용한다.

### D. Mobile renderer로 즉시 전환

기각. 현행은 2D 중심이며 Compatibility가 이미 공통 기준선이다. 실제 성능·시각 증거 없이 renderer 변경 권한을 주지 않는다.

## 완료 판정

이 Decision 완료는 아키텍처 계약 승인만 의미한다.

```yaml
planning_contract: APPROVED
product_code_changed: false
project_godot_changed: false
export_preset_changed: false
android_export: NOT_RUN
android_device: NOT_RUN
windows_local_render: NOT_RUN
physical_gamepad: NOT_RUN
accessibility_user: NOT_RUN
release_performance: NOT_RUN
```

다음 단계는 `WINDOWS_ANDROID_ADAPTER_IMPLEMENTATION_GATE`다.
