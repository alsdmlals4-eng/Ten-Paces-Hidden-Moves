# GUT 9.7.1·HiGodot 3.1.2 권위 분리 Decision

```yaml
decision_id: TEN-DEC-20260806-GUT-HIGODOT-TEST-AUTHORITY-01
date: 2026-08-06
status: APPROVED_FOR_IMPLEMENTATION
approval_source: USER_SELECTED_OPTION_B_AND_REQUIRED_HIGODOT_USE
approval_batch: 2/10
baseline_main: 6e471b62a6236749312f31264428a46b97c8387a
product_behavior_change: false
next_product_package: WINDOWS_ANDROID_ADAPTER_IMPLEMENTATION
next_product_package_state: BLOCKED_BY_WORK_ENTRY_COMPLETENESS_GATE
```

## 결정

GUT 9.7.1을 십보강호의 Godot GDScript 단위·통합 테스트 실행기로 정식 채택한다. HiGodot 3.1.2는 Scene·Node·Resource·프로젝트 설정·스크립트 등 Godot 저작과 편집 변경의 유일한 실행 권위로 유지한다.

```yaml
HiGodot 3.1.2:
  authority: SOLE_GODOT_AUTHORING_AUTHORITY
  execution: EDITOR_AND_MCP_BOUNDED_OPERATIONS
GUT 9.7.1:
  authority: GDSCRIPT_TEST_EXECUTION_AND_JUNIT_ONLY
  execution: HEADLESS_TESTS_AND_LOCAL_TEST_RUNNER
Python:
  authority: REPOSITORY_CANON_AND_STATIC_CONTRACT_VALIDATION
```

GUT는 두 번째 MCP, Scene 편집기, 프로젝트 mutation authority, 기획 정본, 전투 데이터 권위가 아니다. HiGodot은 테스트 성공을 대신하지 않으며, GUT는 HiGodot의 저작 권위를 침범하지 않는다.

## 채택 근거

프로젝트에는 실제 GDScript 제품 코드와 반복 가능한 전투·무공 규칙이 존재한다. 기존 검증은 Python 정적 계약과 단독 `SceneTree` 실행 스크립트 중심이므로, 테스트 fixture·assertion·suite·JUnit 증거를 제공하는 전용 GDScript 테스트 실행기가 유효하다.

GUT 공식 `godot_4_7` 브랜치의 9.7.1 기준은 다음과 같다.

```yaml
source_repository: bitwes/Gut
upstream_branch: godot_4_7
upstream_commit: aeb5d4f3f7f0a6c9b5e178876d6c99b791fda605
license: MIT
bundled_fonts: SIL_OPEN_FONT_LICENSE_WHERE_APPLICABLE
project_path: addons/gut
```

HiGodot 기준은 다음과 같다.

```yaml
provider: hi-godot/godot-ai
release: v3.1.2
asset: godot-ai-plugin.zip
asset_sha256: 60915d780e112aa25b142a596548786a0fb558f795278b9337722532e5dfdb33
project_path: addons/godot_ai
network: LOOPBACK_ONLY
```

## 실제 소비 경로

GUT는 폴더 존재만으로 채택 완료되지 않는다. 다음 소비 경로가 모두 연결되어야 한다.

```text
.gutconfig.json
→ tests/gut/test_martial_manual_registry.gd
→ Godot 4.7.1 headless import
→ addons/gut/gut_cmdln.gd
→ build/test-results/gut.xml
→ GitHub Actions artifact
```

첫 대표 테스트는 `MartialManualRegistry`가 초기 무공서 10권을 정상 로드하는지와 3·7·10성 카드 해금 경계를 검증한다. 이후 Windows·Android Adapter 구현에서는 논리 명령, 저장 round-trip, checkpoint idempotency, 동일 seed·command stream 결과를 GUT suite에 단계적으로 추가한다.

## HiGodot 사용 계약

HiGodot은 Godot 저작 작업에서 적극 사용한다.

1. L0에서 현재 Scene tree·Resource·프로젝트 설정을 읽는다.
2. 승인된 변경은 L1 bounded write로 수행하고 전후 diff·Undo·save를 확인한다.
3. `project.godot`, Autoload, 다중 Scene, 저장 Schema처럼 보호 범위가 커지면 L2 승인 manifest를 요구한다.
4. 프로젝트 전체 변환·대량 삭제·비가역 마이그레이션은 L3 별도 사용자 승인을 요구한다.
5. 연결은 loopback only이며 credentials·host 개인 설정을 저장소에 넣지 않는다.
6. DeepSeek 프로필에는 HiGodot MCP·credential을 등록하지 않는다.
7. GUT가 Scene·Node·Resource를 수정하도록 사용하지 않는다.

현재 저장소에서 HiGodot EditorPlugin은 활성 상태이며 headless에서는 비활성화된다. GUT EditorPlugin은 활성화하지 않고 CLI·CI 테스트 실행에만 사용한다.

## HiGodot runtime helper 경계

적대적 재검토에서 `project.godot`의 기존 autoload를 확인했다.

```yaml
autoload: _mcp_game_helper
path: res://addons/godot_ai/runtime/game_helper.gd
status: EXISTING_BASELINE_PRESENT
included_by_current_product_export: true
product_authority: false
removal_state: BLOCKED_PENDING_HIGODOT_L1_OR_L2_VALIDATION
```

EditorPlugin이 headless에서 비활성화되는 것과 runtime helper autoload가 시작되는 것은 서로 다른 상태다. 따라서 현재 `addons/godot_ai/**`를 export에서 단순 제외하면 autoload 참조가 깨질 수 있다.

PR #104는 `product_behavior_change: false`인 거버넌스·도구 채택 PR이므로 보호 파일인 `project.godot`의 autoload를 임의 삭제하거나 addon 전체를 export 제외하지 않는다. 제품용 helper 제거·격리는 후속 패키지에서 HiGodot L1 또는 L2 저작 절차로 수행하고 다음을 모두 검증해야 한다.

```text
project setting 전후 diff
→ Undo·save 증거
→ clean import·startup
→ Windows export·runtime
→ Android export
→ addons/godot_ai 제품 export 제외 가능 여부
```

이 경계가 닫히기 전 HiGodot은 제품 런타임 기능으로 승인된 것이 아니며 production readiness는 false다.

## 제품 빌드 경계

`addons/gut/**`, `tests/gut/**`, `.gutconfig.json`은 Windows·Android 제품 export에서 제외한다. 테스트 프레임워크와 결과는 개발·CI 도구이며 런타임 제품 의존성이 아니다.

HiGodot EditorPlugin은 개발 저작 도구이고 플랫폼 런타임·전투 권위를 갖지 않는다. 다만 기존 `_mcp_game_helper` autoload 때문에 현재 addon 전체는 제품 export 의존 상태다. 이는 `EXISTING_BASELINE_PRESENT`로 기록하며 `BLOCKED_PENDING_HIGODOT_L1_OR_L2_VALIDATION` 전에는 제거 완료나 제품 격리 완료를 주장하지 않는다.

## 작업 진입 Gate 연결

`TEN-DEC-20260806-WORK-ENTRY-COMPLETENESS-GATE-01`에 따라 이 PR은 `GOVERNANCE_TOOLING` 범위에서 `NO_NEW_VISUAL_ASSET_REQUIRED`로 진행한다. 이 예외는 다음 제품 패키지를 열지 않는다.

```yaml
product_implementation_entry: BLOCKED
reason: PLANNING_REVIEW_VISUAL_AND_AUTHORITY_GATES_OPEN
```

## TDD RED 증거

최초 RED는 의도적으로 채택 계약과 소비 경로가 없는 상태에서 실행했다.

```yaml
workflow_run: 31104521577
adoption_job: 92626120508
runtime_job: 92626120349
observed:
  - Decision·authority contract·HiGodot record 없음
  - .gutconfig.json·대표 GUT 테스트 없음
  - JUnit 결과 없음
  - 제품 export 제외 없음
  - START_HERE 플랫폼 권위 구형
  - GUT CLI가 테스트 디렉터리를 찾지 못해 종료 코드 1
```

충돌 마커 회귀 RED:

```yaml
workflow_run: 31104805445
adoption_job: 92627089422
observed: find_conflict_markers 미구현으로 회귀 테스트 import 실패
related_pr_validation_failure: GUT MIT 라이선스의 Markdown 밑줄을 병합 충돌로 오인
```

GUT JUnit RED:

```yaml
workflow_run: 31105746623
observed:
  - Godot 4.7.1 import PASS
  - GUT 대표 테스트 2/2 PASS
  - build/test-results 디렉터리 부재로 JUnit XML 생성 실패
minimal_fix: mkdir -p build/test-results
```

충돌 마커 수정은 실제 `<<<<<<<` 시작 또는 `>>>>>>>` 종료와 conflict block 내부 `=======`만 검출하도록 구조화하며, 일반 Markdown 제목 밑줄은 허용한다.

## 검증·주장 상한

GREEN에서 요구하는 자동 증거:

- Python 채택·권위·충돌 마커·작업 진입 계약 PASS.
- Godot 4.7.1 clean checkout import PASS.
- 대표 GUT 테스트 PASS.
- JUnit XML 생성·artifact 업로드 PASS.
- 기존 PR Validation·Full Validation과 관련 제품 회귀 PASS.

다음은 자동 검증으로 주장하지 않는다.

```yaml
local_windows_higodot_editor: HUMAN_NOT_RUN
mcp_host_registration: UNVERIFIED
higodot_l0_read: NOT_RUN
higodot_l1_write_undo_save: NOT_RUN
higodot_runtime_helper_product_separation: NOT_RUN
physical_gamepad: NOT_RUN
android_export_install_device_touch_lifecycle_performance: ANDROID_NOT_RUN
accessibility_user: HUMAN_NOT_RUN
release_performance: NOT_RUN
human_playtest: HUMAN_NOT_RUN
production_readiness: false
```

## 제거·rollback

GUT 제거 시 `.gutconfig.json`, `tests/gut/**`, 전용 Workflow와 소비자를 먼저 제거하고 남은 참조가 없는지 확인한 뒤 `addons/gut/**`를 제거한다. HiGodot rollback은 exact v3.1.2 asset과 hash를 기준으로 복원하며 `project.godot` enabled plugin·autoload 상태를 함께 확인한다. 자동 업데이트나 floating latest는 허용하지 않는다.
