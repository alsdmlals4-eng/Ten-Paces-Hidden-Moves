# GUT 9.7.1 기존 설치 정합화·검증 결정

- Decision ID: `TEN-DEC-20260807-GUT-9-7-1-RECONCILIATION-01`
- 부모 Decision: `TEN-DEC-20260806-GUT-HIGODOT-TEST-AUTHORITY-01`
- 승인일: 2026-08-07
- 상태: `CURRENT_APPROVED_RECONCILIATION_DRAFT`
- 계약: `docs/planning-data/approved_20260807_gut_9_7_1_reconciliation.json`

## 1. 목적

v4.3 명세보다 먼저 main에 들어간 GUT 파일을 공식 `bitwes/Gut` tag `v9.7.1`과 정합화하고, 실제 GDScript 테스트·JUnit 소비 경로와 production hash 불변을 exact HEAD에서 검증한다.

```yaml
official_tag: v9.7.1
official_commit: aeb5d4f3f7f0a6c9b5e178876d6c99b791fda605
official_addon_tree: 5d6893836af4917ee62b1a395125a7530b1f239d
initial_project_addon_tree: 09d040309bbed0e07420ad72c4aa69cbd0e58190
```

## 2. GUT tree 정합화

공식 tag와 프로젝트 `addons/gut/**`를 파일 단위로 비교한다. 관찰된 차이는 다음 두 Scene의 첫 줄에서 `load_steps` 메타데이터가 Godot import 후 생략된 것뿐이다.

- `GutScene.tscn`
- `UserFileViewer.tscn`

노드·리소스·UID·property·connection 내용은 동일하다. 이를 `GUT_TREE_NORMALIZATION_VARIANCE`로 기록하며 허용 범위는 `GODOT_GD_SCENE_LOAD_STEPS_METADATA_ONLY`다.

다른 누락·추가·내용 차이는 `BLOCKED_UNEXPECTED_ADDON_DIFFERENCE`로 차단한다. 이 PR에서는 GUT addon Scene을 다시 쓰지 않는다.

## 3. 실제 소비 경로

```yaml
config: .gutconfig.json
test_root: tests/gut
representative_test: tests/gut/test_martial_manual_registry.gd
junit_output: build/test-results/gut.xml
```

대표 테스트는 무공서 registry 10권과 숙련도 3·7·10성 해금 경계를 GDScript에서 직접 검증한다. 기존 Python·SceneTree 검증은 보존한다.

## 4. exact-HEAD 검증

Draft PR의 exact HEAD에서 다음을 모두 실행한다.

1. 프로젝트 exact HEAD checkout.
2. 공식 GUT `v9.7.1` checkout.
3. addon tree 파일 단위 비교와 정규화 variance 검사.
4. Godot 4.7.1 import.
5. production scope hash 기록.
6. GUT CLI 실행.
7. JUnit 파일 확인·artifact 업로드.
8. GUT 실행 후 production scope hash 재계산·동일성 확인.

Production scope는 `src`, `scenes`, `data`, `assets`, `project.godot`, `export_presets.cfg`, 그리고 `addons/gut`을 제외한 `addons`다.

## 5. HiGodot 경계와 남은 Gate

HiGodot은 Scene·Node·Resource·project settings의 단일 저작 권위다. 현재 로컬 HiGodot L0/L1을 실행할 수 없으므로 다음은 수행하지 않는다.

- 두 vendored GUT Scene의 raw upstream 재저장.
- `export_presets.cfg`의 GUT 제외 규칙 변경.

현재 product export는 `all_resources`이며 GUT 제외 규칙이 없다. 따라서 검증이 GREEN이어도 권위 상태는 다음으로 제한한다.

```yaml
authority_state: PARTIAL_VALIDATED_EXPORT_GATE_OPEN
export_exclusion: BLOCKED_PENDING_HIGODOT_L1
formal_adoption_claim: NOT_COMPLETE
```

이는 실패 은폐가 아니라 v4.3의 저작 권위와 제품 export Gate를 지키는 fail-closed 판정이다.

## 6. 변경 금지와 Claim Ceiling

- 제품 GDScript·Scene·Resource·전투 데이터·save·`project.godot` 변경 금지.
- GUT addon tree 변경 금지.
- 제품 visible/audio diff 0.
- `PRODUCT_IMPLEMENTATION_EFFECT_NONE`.
- local HiGodot·local Godot·local Windows·Android·사람 검증은 `NOT_RUN`.
- 제품 구현은 기존 Work Entry Completeness Gate에 따라 계속 차단.

## 7. 다음 Gate

`HIGODOT_L1_VALIDATE_PRODUCT_EXPORT_EXCLUSION`에서 export 설정 변경의 diff·Undo·save와 제품 export 제외를 검증한 뒤에만 GUT 정식 채택 완료를 주장한다.
