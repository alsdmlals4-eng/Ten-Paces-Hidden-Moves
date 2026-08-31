# GUT 9.7.1 채택 명세 결정

- Decision ID: `TEN-DEC-20260806-GUT-HIGODOT-TEST-AUTHORITY-01`
- 승인일: 2026-08-06
- 상태: `CURRENT_APPROVED_ADOPTION_SPEC_PENDING_MERGE`
- 계약: `docs/planning-data/approved_20260806_gut_9_7_1_adoption_spec.json`
- 기준 계약: `TEN-DEC-20260806-INTEGRATED-WORK-CONTRACT-V4-3-01`

## 1. 명세 우선 Gate와 현재 충돌

`GUT_ADOPTION_SPEC_DRAFT_PR_GATE`를 적용한다. 원칙상 GUT 실제 설치·실행 설정은 이 명세가 `main`에 병합된 뒤 별도 PR에서 수행해야 한다.

그러나 fresh main 감사에서 `addons/gut/**`가 이미 직접 커밋 `6e471b62a6236749312f31264428a46b97c8387a`에 추가된 사실을 확인했다. 이는 v4.3의 명세 우선 순서를 과거에 위반한 `PREEXISTING_OUT_OF_SEQUENCE_INSTALLATION`이다.

```yaml
adoption_spec_branch: chore/gut-9.7.1-adoption-spec
stage: ADOPTION_SPEC_DRAFT_PR
existing_installation_commit: 6e471b62a6236749312f31264428a46b97c8387a
existing_installation_state: PREEXISTING_OUT_OF_SEQUENCE_INSTALLATION
formal_installation: BLOCKED_UNTIL_SPEC_MERGED_AND_EXISTING_INSTALL_RECONCILED
production_files_may_be_modified: false
```

파일이 존재한다는 사실만으로 정식 채택 권위를 부여하지 않는다. 이 명세 PR은 기존 GUT 파일을 수정하지 않으며, 명세 병합 뒤 별도 정합화·검증 PR에서 tree 일치·소비 경로·실행·JUnit·hash 불변을 검증한다.

## 2. 출처·버전·라이선스

공식 upstream의 `refs/tags/v9.7.1`을 다시 조회해 실제 tag commit, plugin manifest, 라이선스를 검증했다.

```yaml
source_repository: bitwes/Gut
source_ref: refs/tags/v9.7.1
source_branch_or_release: v9.7.1
pinned_source_commit: aeb5d4f3f7f0a6c9b5e178876d6c99b791fda605
plugin_manifest: addons/gut/plugin.cfg
plugin_manifest_version: 9.7.1
license_path: addons/gut/LICENSE.md
license: MIT
upstream_compatibility_branch_family: godot_4_7
required_godot_compatibility: 4.7.x
```

초기 명세에 기록된 존재하지 않는 SHA `aeb5d4f3c66e2743cb7d1e6c1edc3f65a7721ea5`는 GPT 역할 분리 검토 중 P1 출처 오류로 발견해 폐기했다. 정합화 PR에서 tag ref·commit·license·plugin manifest·프로젝트 exact Godot version과 현재 설치 tree를 다시 대조한다.

## 3. HiGodot·GUT 권위 분리

`HIGODOT_GUT_ROLE_NON_OVERLAP_GATE`를 적용한다.

- HiGodot: `SINGLE_GODOT_SCENE_NODE_RESOURCE_PROJECT_SETTINGS_AUTHOR`.
- GUT: `FORMAL_TEST_EXECUTION_AND_ASSERTION`.
- GUT는 production Scene·Resource·project.godot·production GDScript를 수정하지 않는다.
- GUT는 테스트 결과·JUnit·artifact만 기록할 수 있다.
- Godot 저작 변경에는 HiGodot Authoring Manifest가 필요하다.
- GUT 실행 전후 production hash 불변 검사를 요구한다.

## 4. 소비 경로

정합화 후 대표 소비 경로는 다음으로 제한한다.

```yaml
test_root: tests/gut
representative_scope: MARTIAL_MANUAL_REGISTRY_AND_MASTERY_BOUNDARIES
junit_output: build/test-results/gut.xml
product_export_exclusion: REQUIRED
project_godot_plugin_enablement: NOT_REQUIRED_FOR_CLI_TEST_EXECUTION
```

GUT는 기존 Python·SceneTree 검증을 전면 대체하지 않고 GDScript 실행 검증을 보완한다.

## 5. 정합화·CI 계획

명세 병합 뒤 정합화 PR의 exact HEAD에서 다음을 수행한다.

- 현재 `addons/gut/**`와 verified tag tree의 일치 여부 확인.
- tag ref·pinned commit·plugin manifest version·license 확인.
- exact PR HEAD checkout.
- Godot 4.7.x import.
- GUT CLI test discovery·execution.
- JUnit 파일 필수 확인·artifact 업로드.
- GUT 실행 전후 production hash 불변 확인.
- Required Check와 unresolved thread 0 확인.

불일치가 있으면 임의 보정하지 않고 verified tag tree로 교체하는 변경을 해당 PR에 명시한다.

## 6. 제거·Rollback

GUT 제거 시 addon·config·GUT workflow 단계·GUT test만 제거하고 기존 Python·SceneTree 검증은 보존한다. 제거 뒤 Godot import와 product export 경계를 다시 검증한다.

## 7. 현재 판정

```yaml
spec: IN_REVIEW
source_provenance: VERIFIED_AT_ADOPTION_SPEC
existing_files: PRESENT_ON_MAIN
formal_installation_authority: EXISTING_FILES_PRESENT_AUTHORITY_NOT_GRANTED
next_gate: POST_SPEC_MERGE_RECONCILIATION_AND_VALIDATION_PR
higodot_local_authority_validation: NOT_RUN
local_godot_validation: NOT_RUN
android_validation: NOT_RUN
human_validation: NOT_RUN
visual_audio_disposition: NO_NEW_VISUAL_OR_AUDIO_ASSET_REQUIRED
```

명세 병합과 기존 설치 정합화가 끝나기 전 GUT 정식 채택이 READY라고 기록하지 않는다.
