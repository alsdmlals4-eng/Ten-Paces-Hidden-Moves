# GUT 9.7.1 기존 설치 정합화·검증 결정

- Decision ID: `TEN-DEC-20260807-GUT-9-7-1-RECONCILIATION-01`
- 부모 Decision: `TEN-DEC-20260806-GUT-HIGODOT-TEST-AUTHORITY-01`
- 현행 Actions 검증 Decision: `TEN-DEC-20260807-PUBLIC-REPO-FREE-GITHUB-HOSTED-ACTIONS-01`
- 과거 PR #107 전용 fallback Decision: `TEN-DEC-20260807-ACTIONS-BUDGET-MANUAL-VALIDATION-FALLBACK-01` (`SUPERSEDED_FOR_FUTURE_HEADS`)
- 승인일: 2026-08-07
- 상태: `CURRENT_APPROVED_RECONCILIATION_REPAIR_IN_REVIEW`
- 계약: `docs/planning-data/approved_20260807_gut_9_7_1_reconciliation.json`
- BUILD 승인: `docs/implementation/BUILD_APPROVAL_2026-08-08.md`
- 정규화 variance marker: `GUT_TREE_NORMALIZATION_VARIANCE`

## 1. 목적

v4.3 명세보다 먼저 main에 들어간 GUT 파일을 공식 `bitwes/Gut` tag `v9.7.1`과 정합화하고, 실제 GDScript 테스트·JUnit 소비 경로와 production hash 불변을 exact HEAD의 표준 GitHub-hosted Actions에서 검증한다.

```yaml
official_tag: v9.7.1
official_commit: aeb5d4f3f7f0a6c9b5e178876d6c99b791fda605
official_addon_tree: 5d6893836af4917ee62b1a395125a7530b1f239d
initial_project_addon_tree: 09d040309bbed0e07420ad72c4aa69cbd0e58190
latest_main_reconciled: 8315fde182f4c26669a983c8da71b2174655a823
```

## 2. GUT tree 정합화

공식 tag와 프로젝트 `addons/gut/**`를 파일 단위로 비교한다. PR #109를 최신 main 위에 재구성한 exact HEAD `15f5dbfaf5d4bf137799f3dbdfcbcb526c833973`의 hosted RED run `31227143260`에서, 바이너리·의미 차이가 아니라 첫 줄 `load_steps` 메타데이터만 다른 text resource가 다음 17개임을 fail-closed 비교가 직접 보고했다.

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

`source_code_pro.fnt`는 바이너리 정규화 예외를 허용하지 않는다. 공식 v9.7.1 blob `eb6b9b859954c85bc878e93e6893d6f552b01a9e`, SHA-256 `404094d0aae3de496a64fca1795bed8bd60c2411a3d992551f9e8f00789b71fe`로 정확히 복원한다.

정규화 허용 범위는 계속 `GODOT_TEXT_RESOURCE_LOAD_STEPS_METADATA_ONLY`다. 그 외 누락·추가·내용 차이와 모든 바이너리 차이는 `BLOCKED_UNEXPECTED_ADDON_DIFFERENCE`로 차단한다. 이 repair에서 `.tscn`·`.tres`를 다시 저작하지 않는다.

## 3. 실제 소비 경로

```yaml
config: .gutconfig.json
test_root: tests/gut
representative_test: tests/gut/test_martial_manual_registry.gd
junit_output: build/test-results/gut.xml
```

대표 테스트는 무공서 registry 10권과 숙련도 3·7·10성 해금 경계를 GDScript에서 직접 검증한다. 기존 Python·SceneTree 검증은 보존한다. 또한 `tests/test_gut_9_7_1_observed_variance_manifest.py`를 dedicated workflow에서 직접 실행해 17개 allowlist가 validator와 계약에서 서로 다르면 즉시 실패시킨다.

## 4. exact-HEAD 검증 경로

현행 정식 경로는 `TEN-DEC-20260807-PUBLIC-REPO-FREE-GITHUB-HOSTED-ACTIONS-01`에 따른 공개 저장소 표준 GitHub-hosted runner다. PR의 exact HEAD에서 다음을 모두 실행한다.

1. 프로젝트 exact HEAD checkout.
2. 공식 GUT `v9.7.1` checkout.
3. reconciliation contract 및 observed-variance manifest unit tests.
4. addon tree 파일 단위 비교와 제한된 text-resource 정규화 검사.
5. Godot 4.7.1 import.
6. import 후 tracked tree clean 확인.
7. production scope hash 기록.
8. GUT CLI 실행.
9. JUnit 파일 확인.
10. GUT 실행 후 production scope hash 동일성 확인.
11. GUT 후 tracked tree clean 확인.
12. reconciliation JSON과 JUnit artifact 업로드.

PR #107 전용 예산 fallback은 이력으로만 보존하며 새 HEAD의 성공 증거로 재사용하지 않는다. workflow·branch protection·Ruleset을 우회하지 않는다. HEAD가 바뀌면 이전 exact-head 검증 결과는 무효다.

Production scope는 `src`, `scenes`, `data`, `assets`, `project.godot`, `export_presets.cfg`, 그리고 `addons/gut`을 제외한 `addons`다.

## 5. BUILD 승인과 HiGodot 경계

Base adversarial gate는 `addons/` binary 변경을 보호 경로로 취급하므로, 공식 GUT 폰트 복원은 같은 diff의 `docs/implementation/BUILD_APPROVAL_2026-08-08.md`에 사용자 승인 출처와 정확한 tooling-only 범위를 기록한다. 이 승인으로 제품 런타임 기능·Scene·Resource·플랫폼 adapter 변경 권한을 확대하지 않는다.

HiGodot은 Scene·Node·Resource·project settings의 단일 저작 권위다. 이 repair에서는 다음을 수행하지 않는다.

- vendored GUT `.tscn`·`.tres`의 raw upstream 재저장.
- `project.godot` 변경.
- `export_presets.cfg`의 GUT 제외 규칙 변경.

따라서 exact-head GUT reconciliation이 GREEN이어도 권위 상태는 다음으로 제한한다.

```yaml
authority_state: PARTIAL_VALIDATED_EXPORT_GATE_OPEN
export_exclusion: BLOCKED_PENDING_HIGODOT_L1
formal_adoption_claim: NOT_COMPLETE
```

## 6. 변경 금지와 Claim Ceiling

- 제품 GDScript·Scene·Resource·전투 데이터·save·`project.godot` 변경 금지.
- GUT `.tscn`·`.tres` 직접 저작 금지.
- 바이너리 복원은 공식 `v9.7.1` blob과 exact 일치해야 함.
- 제품 visible/audio diff 0.
- `PRODUCT_IMPLEMENTATION_EFFECT_NONE`.
- exact-head hosted Actions가 끝나기 전 Godot·GUT·JUnit은 `PENDING_EXACT_HEAD_HOSTED_VALIDATION`.
- local HiGodot·local Godot·local Windows·Android·사람 검증은 별도 실행 증거가 없으면 `NOT_RUN`.
- 제품 구현은 기존 Work Entry Completeness Gate에 따라 계속 차단.

## 7. 다음 Gate

먼저 PR exact HEAD의 GUT reconciliation hosted workflow가 tree comparison, Godot import clean-tree, GUT, JUnit, production hash 불변을 모두 통과해야 한다. 이후 `HIGODOT_L1_VALIDATE_PRODUCT_EXPORT_EXCLUSION`에서 export 설정 변경의 diff·Undo·save와 제품 export 제외를 검증한 뒤에만 GUT 정식 채택 완료를 주장한다.
