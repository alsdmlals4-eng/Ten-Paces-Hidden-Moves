# GUT 9.7.1 기존 설치 정합화·검증 결정

- Decision ID: `TEN-DEC-20260807-GUT-9-7-1-RECONCILIATION-01`
- 부모 Decision: `TEN-DEC-20260806-GUT-HIGODOT-TEST-AUTHORITY-01`
- 현행 Actions 검증 Decision: `TEN-DEC-20260807-PUBLIC-REPO-FREE-GITHUB-HOSTED-ACTIONS-01`
- 과거 PR #107 전용 fallback Decision: `TEN-DEC-20260807-ACTIONS-BUDGET-MANUAL-VALIDATION-FALLBACK-01` (`SUPERSEDED_FOR_FUTURE_HEADS`)
- 승인일: 2026-08-07
- 상태: `CURRENT_APPROVED_RECONCILIATION_MERGED_HOSTED_VALIDATED`
- 계약: `docs/planning-data/approved_20260807_gut_9_7_1_reconciliation.json`
- BUILD 승인: `docs/implementation/BUILD_APPROVAL_2026-08-08.md`
- 정규화 variance marker: `GUT_TREE_NORMALIZATION_VARIANCE`

## 1. 목적과 post-merge 상태

v4.3 명세보다 먼저 main에 들어간 GUT 파일을 공식 `bitwes/Gut` tag `v9.7.1`과 정합화하고, 실제 GDScript 테스트·JUnit 소비 경로와 production hash 불변을 exact HEAD의 표준 GitHub-hosted Actions에서 검증한다.

PR #109는 exact HEAD `b648161dfe39ce8dbc1d7a363da835cc9dadaecc`에서 요구 검증을 모두 통과한 뒤 squash merge됐으며, 병합 직후 main은 `a06f0171df4b0585ab35772349ecec7affde0cb7`이다.

```yaml
official_tag: v9.7.1
official_commit: aeb5d4f3f7f0a6c9b5e178876d6c99b791fda605
official_addon_tree: 5d6893836af4917ee62b1a395125a7530b1f239d
initial_project_addon_tree: 09d040309bbed0e07420ad72c4aa69cbd0e58190
validated_pr: 109
validated_exact_head: b648161dfe39ce8dbc1d7a363da835cc9dadaecc
merge_main: a06f0171df4b0585ab35772349ecec7affde0cb7
```

## 2. GUT tree 정합화

공식 tag와 프로젝트 `addons/gut/**`를 파일 단위로 비교한다. hosted RED run `31227143260`에서, 바이너리·의미 차이가 아니라 첫 줄 `load_steps` 메타데이터만 다른 text resource가 다음 17개임을 fail-closed 비교가 직접 보고했다.

- `GutScene.tscn`
- `UserFileViewer.tscn`
- `gui/GutControl.tscn`
- `gui/GutLogo.tscn`
- `gui/GutRunner.tscn`
- `gui/GutSceneTheme.tres`
- `gui/MinGui.tscn`
- `gui/NormalGui.tscn`
- `gui/OutputText.tscn`
- `gui/ResizeHandle.tscn`
- `gui/RunAtCursor.tscn`
- `gui/RunExternally.tscn`
- `gui/RunResults.tscn`
- `gui/ShellOutOptions.tscn`
- `gui/ShortcutButton.tscn`
- `gui/run_from_editor.tscn`
- `gut_loader_the_scene.tscn`

이 17개는 `normalize_godot_text_resource`가 허용하는 첫 줄 `load_steps=<정수>` 토큰 하나를 제거했을 때 공식 v9.7.1과 정확히 같아지는 파일만 포함한다. 노드·리소스·UID·property·connection 등 의미 차이가 하나라도 남으면 허용 목록에 있어도 통과하지 않는다.

`source_code_pro.fnt`는 바이너리 정규화 예외를 허용하지 않는다. 공식 v9.7.1 blob `eb6b9b859954c85bc878e93e6893d6f552b01a9e`, SHA-256 `404094d0aae3de496a64fca1795bed8bd60c2411a3d992551f9e8f00789b71fe`로 정확히 복원됐다.

정규화 허용 범위는 계속 `GODOT_TEXT_RESOURCE_LOAD_STEPS_METADATA_ONLY`다. 그 외 누락·추가·내용 차이와 모든 바이너리 차이는 `BLOCKED_UNEXPECTED_ADDON_DIFFERENCE`로 차단한다. 이 repair에서 `.tscn`·`.tres`를 다시 저작하지 않았다.

## 3. 실제 소비 경로

```yaml
config: .gutconfig.json
test_root: tests/gut
representative_test: tests/gut/test_martial_manual_registry.gd
junit_output: build/test-results/gut.xml
```

대표 테스트는 무공서 registry 10권과 숙련도 3·7·10성 해금 경계를 GDScript에서 직접 검증한다. 기존 Python·SceneTree 검증은 보존한다. `tests/test_gut_9_7_1_observed_variance_manifest.py`는 17개 allowlist가 validator와 계약에서 서로 다르면 즉시 실패시킨다.

## 4. PR #109 exact-HEAD 검증 결과

검증 대상 exact HEAD는 `b648161dfe39ce8dbc1d7a363da835cc9dadaecc`이다.

```yaml
gut_reconciliation_run: 31228560420
full_validation_run: 31228560398
base_v9_run: 31228560404
pr_validation_run: 31228560529
product_gate_run: 31228560427
review_threads_unresolved: 0
result: PASS_EXACT_HEAD_HOSTED
```

GUT Reconciliation #21에서 프로젝트/공식 tag checkout, contract tests, addon tree 비교, Godot 4.7.1 import, clean-tree, production hash, GUT CLI, JUnit, hash 불변, artifact upload가 모두 성공했다. Full Validation #1059, Base v9 adoption #1013, PR Validation #1930, Ten Manual Product Gate #212와 해당 exact HEAD에서 반환된 나머지 프로젝트 검증 workflow도 모두 `SUCCESS`였다.

PR #107 전용 예산 fallback은 이력으로만 보존하며 PR #109의 성공 증거로 재사용하지 않았다.

Production scope는 `src`, `scenes`, `data`, `assets`, `project.godot`, `export_presets.cfg`, 그리고 `addons/gut`을 제외한 `addons`다.

## 5. BUILD 승인과 HiGodot 경계

Base adversarial gate는 `addons/` binary 변경을 보호 경로로 취급하므로, 공식 GUT 폰트 복원은 같은 diff의 `docs/implementation/BUILD_APPROVAL_2026-08-08.md`에 사용자 승인 출처와 정확한 tooling-only 범위를 기록했다. 이 승인으로 제품 런타임 기능·Scene·Resource·플랫폼 adapter 변경 권한을 확대하지 않는다.

HiGodot은 Scene·Node·Resource·project settings와 관련 persistent Godot 저작의 단일 권위다. 이 repair에서는 vendored GUT `.tscn`·`.tres` 재저장, `project.godot`, `export_presets.cfg`의 GUT 제외 규칙 변경을 수행하지 않았다.

따라서 hosted GUT/JUnit 검증이 완료됐어도 권위 상태는 다음으로 제한한다.

```yaml
authority_state: PARTIAL_VALIDATED_EXPORT_GATE_OPEN
export_exclusion: BLOCKED_PENDING_HIGODOT_L1
formal_adoption_claim: NOT_COMPLETE
```

`BLOCKED_PENDING_HIGODOT_L1`은 기존 검증 Gate marker로 보존한다. 다만 Base 위험도 정본을 재대조한 결과, **현재 export 설정에 실제 persistent 변경이 필요하면 그 저작 행위는 HiGodot L2**다. L1은 이미 존재하는 결과를 재관찰·검증하는 단계로만 사용한다.

## 6. 현재 export readback과 보정된 Gate

main `e3c7a3cc0705f7a20dcf7810788ce86633b9b186`의 `export_presets.cfg` readback은 다음과 같다.

```yaml
export_filter: all_resources
exclude_filter: ""
observed_tooling_exclusion: NOT_IMPLEMENTED_IN_PRESET
legacy_gate_marker: BLOCKED_PENDING_HIGODOT_L1
authoring_required: true
authoring_authority: HIGODOT_ONLY
authoring_risk_class: L2_PERSISTENT_FILE_OR_PROJECT_SETTING_WRITE
verification_after_authoring: HIGODOT_L1_VALIDATE_PRODUCT_EXPORT_EXCLUSION
```

따라서 현재 상태에서 `HIGODOT_L1_VALIDATE_PRODUCT_EXPORT_EXCLUSION`을 실행해 PASS라고 주장할 수 없다. 먼저 기존 승인 범위의 GUT/test tooling exclusion 요구를 HiGodot L2로 저작하고, 그 후 L1/L0 재관찰과 실제 export regression으로 검증해야 한다.

- `addons/gut/**`, `tests/**`, `.gutconfig.json`의 product export exclusion은 기존 GUT/HiGodot 채택 의도에 따라 검증 대상이다.
- 다른 addon은 추측으로 제외하지 않는다. 예를 들어 현재 `addons/godot_ai/runtime/game_helper.gd`는 autoload 소비 경로가 있으므로 dependency/readback 없이 디렉터리 전체를 제외하면 안 된다.
- Hera addon의 product export disposition 역시 별도 dependency/readback과 같은 HiGodot authoring/validation 경계를 통과하기 전 자동 승인하지 않는다.

## 7. 변경 금지와 Claim Ceiling

- 제품 GDScript·Scene·Resource·전투 데이터·save·`project.godot` 변경 금지.
- GUT `.tscn`·`.tres` 직접 저작 금지.
- 바이너리 복원은 공식 `v9.7.1` blob과 exact 일치.
- 제품 visible/audio diff 0.
- `PRODUCT_IMPLEMENTATION_EFFECT_NONE`.
- PR #109 exact-head Godot·GUT·JUnit hosted 검증은 `PASS_EXACT_HEAD_HOSTED_PR109`.
- local HiGodot·local Godot·local Windows·Android·사람 검증은 별도 실행 증거가 없으면 `NOT_RUN`.
- Ten Manual Product Gate의 GitHub-hosted Windows export 증거는 local Windows/device/human 검증을 대체하지 않는다.
- 제품 구현은 기존 Work Entry Completeness Gate에 따라 계속 차단한다.

## 8. 다음 Gate

GUT/JUnit hosted reconciliation Gate는 닫혔다. 다음 GUT 채택 경로는 **HiGodot L2로 필요한 product export exclusion을 저작한 뒤 기존 `HIGODOT_L1_VALIDATE_PRODUCT_EXPORT_EXCLUSION`에서 결과를 검증**하는 것이다. 별도로 Hera CLI/addon local pair·HiGodot-authorized plugin enable·live QA canary, `TEN-IMG-001`, local Windows/Android/device/human Gate가 모두 닫히기 전에는 Windows/Android Adapter 제품 구현 Entry Gate를 열지 않는다.
