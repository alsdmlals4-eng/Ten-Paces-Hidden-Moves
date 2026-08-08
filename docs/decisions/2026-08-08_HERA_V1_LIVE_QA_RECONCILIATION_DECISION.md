# Hera v1 live QA 설치 정합화 결정

- Decision ID: `TEN-DEC-20260808-HERA-V1-LIVE-QA-RECONCILIATION-01`
- 승인일: 2026-08-08
- 상태: `CURRENT_APPROVED_RECONCILIATION`
- 조사 기준 main: `8e06c3ed4b572d211aeb9447d5d0b1491b1b8467`
- PR #110 병합 직후 main: `102bd7010316edc10fa0709dfe336040d33082df`
- 원격 CLI preflight 기준 main: `6b995ec49761110ac2d8b2f944d041b1921e6bb9`
- 계약: `docs/planning-data/approved_20260808_hera_v1_live_qa_reconciliation.json`
- Base 역할 정본: `docs/knowledge/godot/HIGODOT_SINGLE_AUTHORITY_AND_SAFE_OPERATION.md`

## 1. 목적

`main`에 PR·Decision 계보 없이 추가된 `addons/hera_agent_godot/**`를 삭제하거나 활성 채택으로 간주하지 않고, 공식 upstream과 실제 프로젝트 상태를 대조해 역할·권위·남은 검증 Gate를 fail-closed로 정합화한다.

## 2. 확인된 현재 사실

```yaml
investigation_main: 8e06c3ed4b572d211aeb9447d5d0b1491b1b8467
pr110_merge_main: 102bd7010316edc10fa0709dfe336040d33082df
remote_cli_preflight_main: 6b995ec49761110ac2d8b2f944d041b1921e6bb9
installation_commit: b6a7a96778d7420c67829bb6ffa59b32d959dae2
project_addon_tree: 6cb87ac8ba768de1d924447f385fba6d80bcde68
official_source: NotNull92/hera-agent-godot
official_tag: v1.0.0
official_addon_tree: 6cb87ac8ba768de1d924447f385fba6d80bcde68
addon_tree_match: EXACT
plugin_manifest_version: 1.0.0
official_addon_release_asset: hera-agent-godot-addon.zip
official_addon_release_sha256: 0a71000f0c4192043e72e9b18f4de3bac720035d9d7c95c9634648a7b5c54d9f
official_windows_amd64_cli_asset: hera-windows-amd64.zip
official_windows_amd64_cli_sha256: 9ae181741c2e8a3f57bbb2a2e4c61ac2c9c7c844fad21c88ae3890c55a5cc66b
expected_cli_version: 1.0.0
remote_expected_cli_pin: VERIFIED_OFFICIAL_V1_0_0_RELEASE
license: MIT
project_godot_enabled_plugins:
  - res://addons/godot_ai/plugin.cfg
hera_enabled_in_project_godot: false
```

공식 v1.0.0 tag의 addon tree와 프로젝트 addon tree가 같은 Git tree SHA를 사용하므로 vendored addon 파일 자체는 exact v1.0.0으로 확인한다. 공식 v1.0.0 Release의 Windows x64 CLI 자산은 `hera-windows-amd64.zip`이고 release digest는 `sha256:9ae181741c2e8a3f57bbb2a2e4c61ac2c9c7c844fad21c88ae3890c55a5cc66b`이다. 같은 Release의 addon ZIP digest는 `sha256:0a71000f0c4192043e72e9b18f4de3bac720035d9d7c95c9634648a7b5c54d9f`이다.

이 content-addressed pin은 **로컬 Windows에 실제로 설치된 CLI가 이 파일·버전과 일치한다는 증거가 아니다.** 현재 세션에는 사용자 Windows checkout과 Hera CLI artifact가 마운트되어 있지 않으므로 local pair 검증은 계속 차단한다.

`addons/hera_agent_godot/README.md`의 `v0.9.0 baseline` 문구는 프로젝트 혼합 오류가 아니라 공식 v1.0.0 tag에도 존재하는 upstream 문구이므로 별도 drift로 판정하지 않는다.

## 3. 권위와 허용 역할

Hera는 다음 역할만 허용한다.

```yaml
role: LIVE_QA_AND_OBSERVABILITY_ONLY
persistent_source_mutation: FORBIDDEN
transport: LOCALHOST_ONLY
acceptance_source_delta: NONE
```

허용 범위:

- editor/runtime status·instance 확인
- run/stop
- runtime tree·UI inspect
- input/click/input-log
- assert
- output/diagnostics
- screenshot capture/diff
- bounded smoke 및 game QA diagnose

금지 범위:

- persistent Scene/Node/Script/Resource/Theme write
- `project.godot` persistent mutation
- main scene 변경
- filesystem persistent mutation
- editor-state mutation을 acceptance evidence로 사용하는 행위

Godot persistent authoring 권위는 계속 HiGodot 하나만 가진다.

## 4. 현재 채택 상태

```yaml
addon_provenance: VERIFIED_EXACT_V1_0_0
addon_enabled: false
expected_cli_version: 1.0.0
expected_windows_amd64_cli_sha256: 9ae181741c2e8a3f57bbb2a2e4c61ac2c9c7c844fad21c88ae3890c55a5cc66b
remote_cli_release_preflight: PASS_CONTENT_ADDRESSED_OFFICIAL_RELEASE
exact_local_cli_version: BLOCKED_UNVERIFIED_LOCAL_ACCESS
cli_addon_pair: HERA_CLI_ADDON_PAIR_UNVERIFIED
live_editor_connection: NOT_RUN
full_editor_restart_after_pair_validation: NOT_RUN
status_check: NOT_RUN
smoke_skip_game: NOT_RUN
shared_token_configuration: NOT_RUN
source_delta_canary: NOT_RUN
adoption_status: PRESENT_DISABLED_PAIR_UNVERIFIED
```

파일이 존재한다는 사실이나 원격 release pin만으로 `ADOPTED_ACTIVE` 또는 acceptance QA 가능 상태로 승격하지 않는다.

## 5. 활성화 전 Gate

공식 v1 migration contract에 따라 로컬 Windows 환경에서 다음을 모두 확인해야 한다.

1. companion `hera` CLI가 exact `v1.0.0`인지 `hera version`으로 확인한다.
2. Windows x64 binary를 사용할 경우 설치 artifact가 `hera-windows-amd64.zip` SHA-256 `9ae181741c2e8a3f57bbb2a2e4c61ac2c9c7c844fad21c88ae3890c55a5cc66b`와 일치하는지 확인한다.
3. addon과 CLI를 함께 v1.0.0 pair로 고정한다.
4. Godot Editor를 **완전히 종료 후 재시작**한다. plugin toggle만으로 preloaded addon script가 모두 reload된다고 간주하지 않는다.
5. `hera status`가 대상 프로젝트 instance를 정확히 가리키는지 확인한다.
6. `hera smoke --skip-game` bounded canary를 통과한다.
7. 채택 시 localhost-only와 shared token을 확인하고 secret을 로그에 남기지 않는다.
8. acceptance QA 전후 tracked source snapshot을 비교해 `Hera phase delta NONE`을 확인한다.

현재 세션에서는 사용자 Windows checkout과 CLI 실행 경로에 접근할 수 없으므로 1~8의 로컬 실행 결과를 PASS로 주장하지 않는다.

## 6. PR #109 관계의 현재 해석

초기 Hera 조사 당시 PR #109는 current main에 뒤처져 있었고, 이 사실은 역사적 조사 근거로 보존한다. 이후 PR #109의 GUT/JUnit exact-head 검증과 병합, post-merge closeout은 `TEN-DEC-20260807-GUT-9-7-1-RECONCILIATION-01`과 `docs/planning-data/current_entry_gate_20260808.json`에서 별도로 닫혔다. 따라서 PR #109 stale-base는 더 이상 Hera 활성화 Gate의 현재 blocker가 아니다.

Hera 정합화와 GUT tree repair는 서로 다른 Goal·증거 체계를 유지한다.

## 7. 제품 구현 Gate

이 Decision은 플레이어 기능·Scene·Resource·전투 데이터·`project.godot`을 변경하지 않는다.

```yaml
product_visible_diff: NONE
product_runtime_change: NONE
new_visual_asset_required: false
windows_android_adapter_implementation: BLOCKED_BY_ENTRY_GATE
```

`TEN-IMG-001`의 실제 이미지 검수 미완, 로컬 Hera pair/canary·HiGodot L1·Windows/Android/device/human 검증 미실행이 남아 있으므로 Windows·Android Adapter 제품 구현은 아직 시작하지 않는다.

## 8. 다음 단계

1. 로컬 Windows에서 exact v1.0.0 Hera CLI/addon pair·`hera version`·`hera status`·`hera smoke --skip-game`·source-delta canary를 검증한다.
2. `HIGODOT_L1_VALIDATE_PRODUCT_EXPORT_EXCLUSION`을 로컬 HiGodot에서 실행한다.
3. `TEN-IMG-001` Visual Requirement 검수를 완료한다.
4. 로컬 Windows/Android/device/human 검증 후 `WINDOWS_ANDROID_ADAPTER_IMPLEMENTATION_GATE` 진입 여부를 재판정한다.
