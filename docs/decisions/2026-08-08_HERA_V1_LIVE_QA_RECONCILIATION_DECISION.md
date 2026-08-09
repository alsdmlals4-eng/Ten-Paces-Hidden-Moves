# Hera v1 live QA 설치 정합화 결정

- Decision ID: `TEN-DEC-20260808-HERA-V1-LIVE-QA-RECONCILIATION-01`
- 승인일: 2026-08-08
- 상태: `CURRENT_APPROVED_RECONCILIATION_LOCAL_LIVE_QA_ACCEPTED`
- 조사 기준 main: `8e06c3ed4b572d211aeb9447d5d0b1491b1b8467`
- PR #110 병합 직후 main: `102bd7010316edc10fa0709dfe336040d33082df`
- 원격 CLI preflight 병합 main: `e3c7a3cc0705f7a20dcf7810788ce86633b9b186`
- 로컬 live-QA acceptance 기준 main: `ce81eeba1af293061c17e4547fdd2364ec33f8c9`
- 계약: `docs/planning-data/approved_20260808_hera_v1_live_qa_reconciliation.json`
- 로컬 acceptance evidence: `docs/planning-data/local_hera_v1_live_qa_acceptance_20260810.json`
- Base 역할 정본: `docs/knowledge/godot/HIGODOT_SINGLE_AUTHORITY_AND_SAFE_OPERATION.md`

## 1. 목적

`addons/hera_agent_godot/**`를 삭제하거나 무제한 authoring 도구로 취급하지 않고, 공식 upstream v1.0.0과 실제 프로젝트 상태를 대조해 Hera의 역할을 **live QA / observability only**로 정합화한다. Persistent Godot authoring 권위는 계속 HiGodot 하나만 가진다.

## 2. 공식 provenance와 exact pair

```yaml
official_source: NotNull92/hera-agent-godot
official_tag: v1.0.0
official_addon_tree: 6cb87ac8ba768de1d924447f385fba6d80bcde68
project_addon_tree: 6cb87ac8ba768de1d924447f385fba6d80bcde68
addon_tree_match: EXACT
plugin_manifest_version: 1.0.0
official_addon_release_asset: hera-agent-godot-addon.zip
official_addon_release_sha256: 0a71000f0c4192043e72e9b18f4de3bac720035d9d7c95c9634648a7b5c54d9f
official_windows_amd64_cli_asset: hera-windows-amd64.zip
official_windows_amd64_cli_sha256: 9ae181741c2e8a3f57bbb2a2e4c61ac2c9c7c844fad21c88ae3890c55a5cc66b
expected_cli_version: 1.0.0
remote_expected_cli_pin: VERIFIED_OFFICIAL_V1_0_0_RELEASE
```

## 3. 권위와 허용 역할

```yaml
role: LIVE_QA_AND_OBSERVABILITY_ONLY
persistent_source_mutation: FORBIDDEN
transport: LOCALHOST_ONLY
acceptance_source_delta: NONE
persistent_godot_authoring_authority: HIGODOT_ONLY
```

허용 범위는 status/instance, run/stop, runtime tree/UI inspect, input/click/input-log, assert, output/diagnostics, screenshot capture/diff, bounded smoke와 QA 관찰이다.

Persistent Scene/Node/Script/Resource/Theme write, `project.godot` 변경, main-scene 변경, filesystem persistent mutation은 Hera acceptance 범위에서 금지한다. 필요 persistent authoring은 HiGodot 위험도 분류와 권위 순서를 따른다.

## 4. 활성 plugin 상태의 역사적 정정

초기 Decision은 과거 `project.godot` 관찰을 기준으로 Hera가 disabled라고 기록했다. 이후 active-toolchain Decision `TEN-DEC-20260809-GODOT-AI313-GUT971-HERA100-ACTIVE-TOOLCHAIN-01`과 로컬 HiGodot L0 readback에서 Hera plugin이 이미 승인된 desired state로 enabled임이 확인됐다.

따라서 과거 `addon_enabled: false`, `PRESENT_DISABLED_PAIR_UNVERIFIED`, `HIGODOT_L2_ENABLE_HERA_PLUGIN_IF_ADOPTION_CONTINUES`는 **현재 상태 권위로는 superseded**다. 실제 acceptance 과정에서는 새 plugin-enable persistent write를 수행하지 않았다.

## 5. 2026-08-10 로컬 Hera v1.0.0 live-QA acceptance

사용자가 `UPLOAD_THIS_HERA_V1_RECOVERY_EVIDENCE.zip`을 제출했고, archive 내 JSON/status/smoke/wrong-token 로그를 readback했다.

확인된 사실:

```yaml
checkout: C:/Users/user/AppData/Local/Temp/ten-paces-hera-v1-20260810-005834/project
head: ce81eeba1af293061c17e4547fdd2364ec33f8c9
origin_main: ce81eeba1af293061c17e4547fdd2364ec33f8c9
godot_version: 4.7.1.stable.official.a13da4feb
hera_cli_version: v1.0.0
hera_addon_version: 1.0.0
windows_cli_sha256: 9ae181741c2e8a3f57bbb2a2e4c61ac2c9c7c844fad21c88ae3890c55a5cc66b
localhost_only: true
shared_token_value: REDACTED
shared_token_auth_enforced: true
normal_status_exit: 0
status_exact_target: true
wrong_token_exit: 1
wrong_token_result: UNAUTHORIZED_EXPECTED
smoke_skip_game_exit: 0
smoke_steps:
  - status: PASS
  - diagnostics: PASS
  - scene: PASS
pre_content_clean: true
post_content_clean: true
source_delta_canary: HERA_SOURCE_DELTA_NONE
verdict: PASS_HERA_V1_0_0_EXACT_PAIR_LIVE_QA_SOURCE_DELTA_NONE
```

`hera status`는 exact fresh Ten Paces checkout과 `res://scenes/combat/combat_board_preview.tscn`을 가리켰다. Shared-token 검증은 정상 token status PASS 뒤 의도적으로 잘못된 token을 사용해 exit 1 / unauthorized를 확인했다. Secret 원문은 canonical evidence에 저장하지 않는다.

`hera smoke --skip-game`은 `status`, `diagnostics`, `scene` 3단계 모두 `ok:true`로 PASS했다.

Post-run `git status --short`에는 Windows/Godot stat-only `.import`/`project.godot` M 표기가 남았지만, acceptance wrapper는 pre/post 실제 tracked/staged/untracked content를 별도로 확인했고 둘 다 clean이었다. 이 stat-only 현상은 PR #129에서 이미 분리 판정 계약으로 정합화했다. 따라서 Hera phase source delta는 `HERA_SOURCE_DELTA_NONE`으로 승인한다.

## 6. 현재 채택 상태

```yaml
addon_provenance: VERIFIED_EXACT_V1_0_0
addon_enabled: true
exact_local_cli_version: v1.0.0
cli_addon_pair: PASS_EXACT_V1_0_0_USER_LOCAL_EVIDENCE
live_editor_connection: PASS_EXACT_TARGET
full_editor_restart_after_enable: PASS_FRESH_EXACT_EDITOR_PROCESS
status_check: PASS_EXACT_TARGET
smoke_skip_game: PASS
shared_token_configuration: PASS_ENFORCED_REDACTED
source_delta_canary: HERA_SOURCE_DELTA_NONE
adoption_status: LOCAL_LIVE_QA_ACCEPTED
persistent_source_mutation: FORBIDDEN
```

Hera acceptance는 authoring 권한 승격이 아니다. Persistent Godot authoring 권위는 계속 HiGodot 하나다.

## 7. Export Gate와의 관계

현재 `export_presets.cfg` 관찰은 `export_filter="all_resources"`, `exclude_filter=""`다. 따라서 tooling export exclusion은 여전히 별도 blocker다.

- 필요한 exclusion persistent write는 HiGodot L2 authoring으로 수행한다.
- 이후 L1/L0 재관찰과 실제 export regression으로 검증한다.
- runtime-required addon을 추측으로 제외하지 않는다.
- Hera live-QA PASS가 export-exclusion PASS를 의미하지 않는다.

```yaml
export_exclusion_state: BLOCKED_REQUIRES_HIGODOT_L2_AUTHORING_THEN_L1_VALIDATION
```

## 8. 제품 구현 Gate

이번 Decision 승격은 governance/evidence 정합화이며 제품 visible/runtime diff는 없다.

```yaml
hera_live_qa_gate: PASS_HERA_V1_0_0_EXACT_PAIR_LIVE_QA_SOURCE_DELTA_NONE
product_visible_diff: NONE
product_runtime_change: NONE
new_visual_asset_required: false
local_android_device: BLOCKED_UNVERIFIED
human_validation: BLOCKED_NOT_RUN
windows_android_adapter_implementation: BLOCKED_BY_ENTRY_GATE
```

Hera gate는 닫혔지만 tooling export exclusion, Android/device, human validation과 기타 현행 Entry Gate blocker가 남아 있으므로 제품 구현은 이 Decision만으로 시작하지 않는다.

## 9. 다음 단계

1. `HIGODOT_L2_AUTHOR_APPROVED_GUT_TEST_PRODUCT_EXPORT_EXCLUSION` 범위에서 tooling export exclusion을 저작한다.
2. `HIGODOT_L1_VALIDATE_PRODUCT_EXPORT_EXCLUSION_WITH_EXPORT_REGRESSION`으로 실제 export 결과를 검증한다.
3. 로컬 Windows/Android/device/human gate를 검증한다.
4. 모든 current Work Entry Completeness Gate를 다시 읽고 제품 구현 진입 여부를 재판정한다.
