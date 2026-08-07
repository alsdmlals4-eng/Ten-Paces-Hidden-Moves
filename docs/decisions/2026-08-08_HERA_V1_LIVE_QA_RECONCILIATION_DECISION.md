# Hera v1 live QA 설치 정합화 결정

- Decision ID: `TEN-DEC-20260808-HERA-V1-LIVE-QA-RECONCILIATION-01`
- 승인일: 2026-08-08
- 상태: `CURRENT_APPROVED_RECONCILIATION`
- 기준 main: `8e06c3ed4b572d211aeb9447d5d0b1491b1b8467`
- 계약: `docs/planning-data/approved_20260808_hera_v1_live_qa_reconciliation.json`
- Base 역할 정본: `docs/knowledge/godot/HIGODOT_SINGLE_AUTHORITY_AND_SAFE_OPERATION.md`

## 1. 목적

`main`에 PR·Decision 계보 없이 추가된 `addons/hera_agent_godot/**`를 삭제하거나 활성 채택으로 간주하지 않고, 공식 upstream과 실제 프로젝트 상태를 대조해 역할·권위·남은 검증 Gate를 fail-closed로 정합화한다.

## 2. 확인된 현재 사실

```yaml
project_main: 8e06c3ed4b572d211aeb9447d5d0b1491b1b8467
installation_commit: b6a7a96778d7420c67829bb6ffa59b32d959dae2
project_addon_tree: 6cb87ac8ba768de1d924447f385fba6d80bcde68
official_source: NotNull92/hera-agent-godot
official_tag: v1.0.0
official_addon_tree: 6cb87ac8ba768de1d924447f385fba6d80bcde68
addon_tree_match: EXACT
plugin_manifest_version: 1.0.0
license: MIT
project_godot_enabled_plugins:
  - res://addons/godot_ai/plugin.cfg
hera_enabled_in_project_godot: false
```

공식 v1.0.0 tag의 addon tree와 프로젝트 addon tree가 같은 Git tree SHA를 사용하므로 vendored addon 파일 자체는 exact v1.0.0으로 확인한다.

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
exact_cli_version: BLOCKED_UNVERIFIED_LOCAL_ACCESS
cli_addon_pair: HERA_CLI_ADDON_PAIR_UNVERIFIED
live_editor_connection: NOT_RUN
full_editor_restart_after_pair_validation: NOT_RUN
status_check: NOT_RUN
smoke_skip_game: NOT_RUN
shared_token_configuration: NOT_RUN
source_delta_canary: NOT_RUN
adoption_status: PRESENT_DISABLED_PAIR_UNVERIFIED
```

파일이 존재한다는 사실만으로 `ADOPTED_ACTIVE` 또는 acceptance QA 가능 상태로 승격하지 않는다.

## 5. 활성화 전 Gate

로컬 Windows 환경에서 다음을 모두 확인해야 한다.

1. companion `hera` CLI exact version이 addon v1.0.0과 맞는지 확인한다.
2. addon과 CLI를 함께 v1.0.0 pair로 고정한다.
3. Godot Editor를 완전히 재시작한다.
4. `hera status`가 대상 프로젝트 instance를 정확히 가리키는지 확인한다.
5. `hera smoke --skip-game` 또는 동등한 bounded canary를 통과한다.
6. 채택 시 localhost-only와 shared token을 확인하고 secret을 로그에 남기지 않는다.
7. acceptance QA 전후 tracked source snapshot을 비교해 `Hera phase delta NONE`을 확인한다.

이 환경에서는 사용자 Windows checkout과 CLI 실행 경로에 접근할 수 없으므로 위 Gate를 PASS로 주장하지 않는다.

## 6. PR #109와 현재 main의 관계

Draft PR #109는 base/merge-base가 `956dc9b86ea99176ffc35568530137fbf9007736`이며 현재 main `8e06c3ed4b572d211aeb9447d5d0b1491b1b8467`보다 2 commit 뒤다. 따라서 PR #109는 최신 main을 반영하고 새 exact HEAD 검증을 통과하기 전 병합하지 않는다.

Hera 정합화는 PR #109의 GUT tree repair와 다른 Goal이므로 별도 변경으로 유지한다.

## 7. 제품 구현 Gate

이 Decision은 플레이어 기능·Scene·Resource·전투 데이터·`project.godot`을 변경하지 않는다.

```yaml
product_visible_diff: NONE
product_runtime_change: NONE
new_visual_asset_required: false
windows_android_adapter_implementation: BLOCKED_BY_ENTRY_GATE
```

`TEN-IMG-001`의 실제 이미지 검수 미완, 로컬 HiGodot/Windows/Android 검증 미실행, PR #109 stale-base 정합화가 남아 있으므로 Windows·Android Adapter 제품 구현은 아직 시작하지 않는다.

## 8. 다음 단계

1. GitHub·Sheet의 current main/Base SHA drift를 정정한다.
2. 이 Decision ID를 Sheet 결정 원장·감사·변경 이력에 동기화한다.
3. PR #109를 최신 main 기준으로 재정합화하고 exact-head GUT/JUnit 검증을 다시 실행한다.
4. 로컬 Windows에서 Hera CLI/addon pair와 live QA canary를 검증한다.
5. 위 Gate와 Visual Requirement Gate를 다시 읽은 뒤 `WINDOWS_ANDROID_ADAPTER_IMPLEMENTATION_GATE` 진입 여부를 재판정한다.
