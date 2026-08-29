# PR #273 일회성 보호 변경 승인 아카이브

```yaml
record_role: IMMUTABLE_ARCHIVE_FOR_ONE_TIME_PROTECTED_CHANGE_APPROVAL
source_manifest: docs/operations/PROJECT_PROTECTED_CHANGE_APPROVAL.json
source_manifest_sha256: dd501d4a17f63f9a4367ab9ca5032401056bcaba3a96da732a18a7ba39303224
protected_base_commit: 2d42ffbb2572c66e3eb317e129fbf00036bbcdd7
merged_main_commit: 48b20da2948e6be7d3543c43814e865b975436a5
merged_pull_request: 273
decision: TEN-DEC-20260829-OPPONENT-RUNTIME-PERSONALITY-BINDING-01
approval_source: USER_EXPLICIT_ALL_REQUIRED_APPROVALS_AND_AUTO_RECOVERY_2026-08-30
approval_time: 2026-08-30T00:00:00+09:00
archive_intent: REMOVE_ACTIVE_MANIFEST_AND_PROMOTE_PROTECTED_BASELINE_TO_MERGED_MAIN
```

PR #273에서만 유효했던 active manifest를 이 기록으로 보존한다. 이 문서는 새 protected-path 변경을 승인하지 않으며, 미래 작업의 approval source로 재사용할 수 없다.

## 당시 승인된 정확한 경로

- `data/run/vertical_slice_opponent_archetypes.json`
- `data/run/vertical_slice_opponents.json`
- `src/combat/combat_ai_planner.gd`
- `src/combat/combat_resolution_engine.gd`
- `src/run/vertical_slice_combat_bridge.gd`
- `src/run/vertical_slice_metrics_combat_resolution_engine.gd`
- `src/run/vertical_slice_opponent_catalog.gd`
- `src/run/vertical_slice_opponent_runtime_binding.gd`
- `src/run/vertical_slice_opponent_runtime_binding.gd.uid`
- `src/run/vertical_slice_shell.gd`

## 범위와 증거 경계

승인은 첫 5전의 reusable opponent runtime personality binding으로 한정됐다: 다섯 archetype, 15 candidate mapping, deterministic derived stat, bounded public resolution history, public-information-only legal AI scheduling. deck, save schema, economy, Route, Scene, asset, Android 및 범위 밖 리팩터링은 승인하지 않았다.

PR #273은 remote CI를 통과한 뒤 `48b20da2948e6be7d3543c43814e865b975436a5`로 병합됐다. PR #274의 merge commit `7f973d949346a53e30e458bc4329bcf3d67052ac`은 active manifest를 제거하고 `skills/PROJECT_BASE_ADAPTER.json`의 protected baseline을 해당 merged-main commit으로 승격했으며, post-merge lifecycle readback도 통과했다. Windows-visible, Human, accessibility-user, Android device, release performance와 balance simulation evidence는 이 archive로 승격되지 않는다.
