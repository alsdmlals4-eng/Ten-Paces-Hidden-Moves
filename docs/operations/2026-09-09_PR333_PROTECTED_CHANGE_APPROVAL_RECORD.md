# PR 333 보호 변경 승인 보존과 병합 후 검증 기록

```yaml
archive_id: TEN-ARCHIVE-20260909-PR333-PROTECTED-APPROVAL
classification: EVIDENCE_RETENTION
original_path: docs/operations/PROJECT_PROTECTED_CHANGE_APPROVAL.json
current_path: docs/operations/2026-09-09_PR333_PROTECTED_CHANGE_APPROVAL_RECORD.md
implementation_pr: 333
implementation_merge_commit: fe720f5dce686ea5b2ff68a1ec078d53544a0e92
implementation_exact_head: baabfc7ae6a29f6ebc47ea5644a110bc7258fc38
approval_manifest_sha256: 4B0824549BE5CB5AECEC2EC7182C08C0D661789C3AFD45B0B081004678287154
approval_lifecycle: ARCHIVED_NOT_CURRENT_EXECUTION_AUTHORITY
archived_at: 2026-09-09
active_authority: false
implementation_authority: NONE
compatibility_consumers: []
rollback_ref: fe720f5dce686ea5b2ff68a1ec078d53544a0e92:docs/operations/PROJECT_PROTECTED_CHANGE_APPROVAL.json
validation_status: LOCAL_CLOSEOUT_VALIDATION_PASSED
```

## 작업 전 문제와 채택 구조

PR #333 전용 active approval manifest가 병합된 main에 남아 있으면 이후 보호 경로 변경이 종료된 승인을 재사용할 수 있다. PR #331에서 검증한 one-time lifecycle 구조를 같은 decision dimension에 재사용한다: merge commit의 Git blob 원문을 SHA-256·Base64·의미상 JSON으로 이 immutable record에 보존하고 active manifest만 제거하며, canonical adapter baseline을 exact merged main `fe720f5dce686ea5b2ff68a1ec078d53544a0e92`로 승격한다. 제품·자산·PDF·캡처 bytes는 변경하지 않는다.

`CURRENT_SOURCE_RELEVANCE_CHECK: REUSED_EVIDENCE`. PR #331 closeout과 adopted Base `19355b7ef065a21d0f2b685c7d9be64a4a3970f8` archive/lifecycle contracts가 동일한 승인 수명주기와 생성물 동기화 책임을 직접 소유한다. 새 게임 설계·외부 사례·유료 도구 조사는 `NOT_APPLICABLE`이다.

## 원문 의미와 정확 bytes

아래 JSON은 비교를 위한 의미상 compact view다. exact raw bytes 권위는 이어지는 Base64와 SHA-256이며, `git show fe720f5dce686ea5b2ff68a1ec078d53544a0e92:docs/operations/PROJECT_PROTECTED_CHANGE_APPROVAL.json`의 2,452 bytes 및 trailing LF를 그대로 보존한다.

```json
{"schema_version":1,"artifact_role":"PROJECT_PROTECTED_CHANGE_APPROVAL","status":"APPROVED","protected_base_commit":"bf161025b63edd7eb441b2c4f2ae9da5155f68da","decision_ids":["TEN-DEC-20260908-DURABLE-RUN-CONTINUE-01","TEN-DEC-20260909-MARTIAL-ACTOR-BINDING-CORRECTION-01"],"approved_paths":["src/run/vertical_slice_run_state.gd","src/run/vertical_slice_progression_state.gd","src/run/run_checkpoint_codec.gd","src/run/run_save_store.gd","src/combat/combat_board_preview.gd","src/combat/combat_resolution_engine.gd","src/run/vertical_slice_combat_bridge.gd","src/run/combat_checkpoint_codec.gd","src/ui/action_timing_panel.gd","src/run/run_session_coordinator.gd","src/run/vertical_slice_shell.gd","src/run/vertical_slice_shell_result_auto.gd","src/run/vertical_slice_shell_route_auto.gd","src/run/vertical_slice_shell_completion_auto.gd","src/ui/main_title_screen.gd","src/ui/bimu_constraint_panel.gd","src/combat/combat_resolution_engine_prepare.gd","src/combat/combat_resolution_engine_ten_manuals.gd","src/combat/martial_effect_pipeline.gd","src/run/vertical_slice_metrics_combat_resolution_engine.gd","src/validation/ten_manual_product_scenario_validator.gd"],"approval_source":"Current user-authorized continuous implementation and exact Codex durable-save handoff; Tasks 1-4 run/storage, combat boundaries, title/shell/lifecycle and bounded validation reuse; Task 5 named pre-publication actor/mastery/stat correction, including its actual structural validation fixture.","approval_time":"2026-09-08T00:00:00+09:00","scope_summary":"Implement schema-1 explicit run snapshot, fail-closed validation, recoverable local file storage, idempotent revision/generation retirement, deterministic combat DTOs and exact AI lock restore; connect title Continue, transactional run progression, save-failure freeze/retry, lifecycle pause and strict UI-to-domain checkpoint export. Task 5 corrects actor-owned mastery effects and canonical stat references, preserves revealed locks, and explicitly changes semantic content identity before first publication while retaining schema1 shape, authored IDs/numbers and incompatible old file bytes. No growth spending, rebalance, AI information-boundary, reward, route, retry, engine or asset change. Human/device/release and protected delivery remain separate gates."}
```

```base64
ewogICJzY2hlbWFfdmVyc2lvbiI6IDEsCiAgImFydGlmYWN0X3JvbGUiOiAiUFJPSkVDVF9QUk9URUNURURfQ0hBTkdFX0FQUFJPVkFMIiwKICAic3RhdHVzIjogIkFQUFJPVkVEIiwKICAicHJvdGVjdGVkX2Jhc2VfY29tbWl0IjogImJmMTYxMDI1YjYzZWRkN2ViNDQxYjJjNGYyYWU5ZGE1MTU1ZjY4ZGEiLAogICJkZWNpc2lvbl9pZHMiOiBbIlRFTi1ERUMtMjAyNjA5MDgtRFVSQUJMRS1SVU4tQ09OVElOVUUtMDEiLCAiVEVOLURFQy0yMDI2MDkwOS1NQVJUSUFMLUFDVE9SLUJJTkRJTkctQ09SUkVDVElPTi0wMSJdLAogICJhcHByb3ZlZF9wYXRocyI6IFsKICAgICJzcmMvcnVuL3ZlcnRpY2FsX3NsaWNlX3J1bl9zdGF0ZS5nZCIsCiAgICAic3JjL3J1bi92ZXJ0aWNhbF9zbGljZV9wcm9ncmVzc2lvbl9zdGF0ZS5nZCIsCiAgICAic3JjL3J1bi9ydW5fY2hlY2twb2ludF9jb2RlYy5nZCIsCiAgICAic3JjL3J1bi9ydW5fc2F2ZV9zdG9yZS5nZCIsCiAgICAic3JjL2NvbWJhdC9jb21iYXRfYm9hcmRfcHJldmlldy5nZCIsCiAgICAic3JjL2NvbWJhdC9jb21iYXRfcmVzb2x1dGlvbl9lbmdpbmUuZ2QiLAogICAgInNyYy9ydW4vdmVydGljYWxfc2xpY2VfY29tYmF0X2JyaWRnZS5nZCIsCiAgICAic3JjL3J1bi9jb21iYXRfY2hlY2twb2ludF9jb2RlYy5nZCIsCiAgICAic3JjL3VpL2FjdGlvbl90aW1pbmdfcGFuZWwuZ2QiLAogICAgInNyYy9ydW4vcnVuX3Nlc3Npb25fY29vcmRpbmF0b3IuZ2QiLAogICAgInNyYy9ydW4vdmVydGljYWxfc2xpY2Vfc2hlbGwuZ2QiLAogICAgInNyYy9ydW4vdmVydGljYWxfc2xpY2Vfc2hlbGxfcmVzdWx0X2F1dG8uZ2QiLAogICAgInNyYy9ydW4vdmVydGljYWxfc2xpY2Vfc2hlbGxfcm91dGVfYXV0by5nZCIsCiAgICAic3JjL3J1bi92ZXJ0aWNhbF9zbGljZV9zaGVsbF9jb21wbGV0aW9uX2F1dG8uZ2QiLAogICAgInNyYy91aS9tYWluX3RpdGxlX3NjcmVlbi5nZCIsCiAgICAic3JjL3VpL2JpbXVfY29uc3RyYWludF9wYW5lbC5nZCIsCiAgICAic3JjL2NvbWJhdC9jb21iYXRfcmVzb2x1dGlvbl9lbmdpbmVfcHJlcGFyZS5nZCIsCiAgICAic3JjL2NvbWJhdC9jb21iYXRfcmVzb2x1dGlvbl9lbmdpbmVfdGVuX21hbnVhbHMuZ2QiLAogICAgInNyYy9jb21iYXQvbWFydGlhbF9lZmZlY3RfcGlwZWxpbmUuZ2QiLAogICAgInNyYy9ydW4vdmVydGljYWxfc2xpY2VfbWV0cmljc19jb21iYXRfcmVzb2x1dGlvbl9lbmdpbmUuZ2QiLAogICAgInNyYy92YWxpZGF0aW9uL3Rlbl9tYW51YWxfcHJvZHVjdF9zY2VuYXJpb192YWxpZGF0b3IuZ2QiCiAgXSwKICAiYXBwcm92YWxfc291cmNlIjogIkN1cnJlbnQgdXNlci1hdXRob3JpemVkIGNvbnRpbnVvdXMgaW1wbGVtZW50YXRpb24gYW5kIGV4YWN0IENvZGV4IGR1cmFibGUtc2F2ZSBoYW5kb2ZmOyBUYXNrcyAxLTQgcnVuL3N0b3JhZ2UsIGNvbWJhdCBib3VuZGFyaWVzLCB0aXRsZS9zaGVsbC9saWZlY3ljbGUgYW5kIGJvdW5kZWQgdmFsaWRhdGlvbiByZXVzZTsgVGFzayA1IG5hbWVkIHByZS1wdWJsaWNhdGlvbiBhY3Rvci9tYXN0ZXJ5L3N0YXQgY29ycmVjdGlvbiwgaW5jbHVkaW5nIGl0cyBhY3R1YWwgc3RydWN0dXJhbCB2YWxpZGF0aW9uIGZpeHR1cmUuIiwKICAiYXBwcm92YWxfdGltZSI6ICIyMDI2LTA5LTA4VDAwOjAwOjAwKzA5OjAwIiwKICAic2NvcGVfc3VtbWFyeSI6ICJJbXBsZW1lbnQgc2NoZW1hLTEgZXhwbGljaXQgcnVuIHNuYXBzaG90LCBmYWlsLWNsb3NlZCB2YWxpZGF0aW9uLCByZWNvdmVyYWJsZSBsb2NhbCBmaWxlIHN0b3JhZ2UsIGlkZW1wb3RlbnQgcmV2aXNpb24vZ2VuZXJhdGlvbiByZXRpcmVtZW50LCBkZXRlcm1pbmlzdGljIGNvbWJhdCBEVE9zIGFuZCBleGFjdCBBSSBsb2NrIHJlc3RvcmU7IGNvbm5lY3QgdGl0bGUgQ29udGludWUsIHRyYW5zYWN0aW9uYWwgcnVuIHByb2dyZXNzaW9uLCBzYXZlLWZhaWx1cmUgZnJlZXplL3JldHJ5LCBsaWZlY3ljbGUgcGF1c2UgYW5kIHN0cmljdCBVSS10by1kb21haW4gY2hlY2twb2ludCBleHBvcnQuIFRhc2sgNSBjb3JyZWN0cyBhY3Rvci1vd25lZCBtYXN0ZXJ5IGVmZmVjdHMgYW5kIGNhbm9uaWNhbCBzdGF0IHJlZmVyZW5jZXMsIHByZXNlcnZlcyByZXZlYWxlZCBsb2NrcywgYW5kIGV4cGxpY2l0bHkgY2hhbmdlcyBzZW1hbnRpYyBjb250ZW50IGlkZW50aXR5IGJlZm9yZSBmaXJzdCBwdWJsaWNhdGlvbiB3aGlsZSByZXRhaW5pbmcgc2NoZW1hMSBzaGFwZSwgYXV0aG9yZWQgSURzL251bWJlcnMgYW5kIGluY29tcGF0aWJsZSBvbGQgZmlsZSBieXRlcy4gTm8gZ3Jvd3RoIHNwZW5kaW5nLCByZWJhbGFuY2UsIEFJIGluZm9ybWF0aW9uLWJvdW5kYXJ5LCByZXdhcmQsIHJvdXRlLCByZXRyeSwgZW5naW5lIG9yIGFzc2V0IGNoYW5nZS4gSHVtYW4vZGV2aWNlL3JlbGVhc2UgYW5kIHByb3RlY3RlZCBkZWxpdmVyeSByZW1haW4gc2VwYXJhdGUgZ2F0ZXMuIgp9Cg==
```

## 병합·CI·post-merge 증거

- GitHub live metadata: PR #333 exact head `baabfc7ae6a29f6ebc47ea5644a110bc7258fc38`, base `27f7d922e8ec36e038c6dc943b069161b8b53536`, normal merge `fe720f5dce686ea5b2ff68a1ec078d53544a0e92` at `2026-09-08T18:55:45Z`.
- 현재 rollup은 `32 SUCCESS / 0 current FAIL / 0 PENDING`이다. initial approval-label 누락 run `34265224533`의 FAIL은 숨기지 않는다. authorized `approved-protected-change` label 적용 뒤 exact same head run `34265510529`이 PASS했다.
- Controller의 clean post-merge approval-aware wrapper는 editor import 전에 PASS했다. 이 closeout의 manifest 제거/baseline 승격 뒤 lifecycle·generated-view·operating 검사는 아래 local 검증으로 별도 확인한다.
- Source exact `50cb8fe4146597804d89214efc351fed409c49f5`의 전체 Python은 `490 passed in 321.70s`였다. Post-merge `fe720f5d`의 첫 fresh worktree 실행은 import 전 missing global class로 실패했다. `Godot_v4.7.1-stable_win64_console.exe --headless --editor --import --quit` exit 0 뒤 재시도한 전체 Python은 `490 passed in 329.82s`였다. import 종료의 `45 ObjectDB / 22 resource` 경고는 별도 editor teardown 관측이며 clean-import 진단으로 해석하지 않는다.
- 위 자동 증거는 product bytes·저장 동작의 병합 readback을 지지하지만 Human play, 물리 입력/청음, Android actual device/lifecycle, accessibility user, Release performance/rights/store와 whole Blueprint completion을 증명하지 않는다.

## 다음 안전 작업과 범위

다음 안전 작업은 battle presentation correctness의 `star-10 actor classification`과 `victory/defeat cue`다. actor-owned definition API와 저장된 `BUNDLE_RESOLVED`의 no-replay 의미를 보존해야 한다. 그 뒤 `growth/events/status/reward` 정본 공백을 다룬다. 새 audio parameter, VFX mapping, 성장 규칙 또는 전체 Blueprint 완료는 이 closeout이 승인하거나 구현하지 않는다.

## Local closeout 검증·5회 적대 검토

Prospective owner/archive RED `python -m pytest -q tests/test_pr333_protected_change_approval_archive.py`는 archive 부재, stale active planning PR, roadmap successor 누락을 각각 검출해 **3 failed in 0.30s**였다. 최소 owner/archive 변경 뒤 첫 집중 묶음은 오래된 `product_stage` assertion 하나를 추가로 검출해 **1 failed, 33 passed in 1.83s**였고, 해당 중복 consumer를 현행 owner와 맞춘 동일 명령은 **34 passed in 1.66s**였다. 더 넓은 비-durable 회귀 `python -m pytest -q --ignore=tests/test_durable_save_contract.py`는 **484 passed in 18.64s**였다. 이미 controller가 실행한 merged-main 전체 490건을 이 closeout에서 중복 실행하지 않았다.

채택 Base 경로의 `build_project_operating_artifacts.py ... --write`는 기존 다섯 산출물을 모두 평가해 **4 changed**를 기록했다. 생성 router는 byte-identical이어서 변경되지 않았고 adapter hash를 소비하는 snapshot/두 compatibility view/dashboard 네 파일만 갱신됐다. 이어진 동일 generator `--check`는 `Project operating generated artifacts are current`였다. `check_project_operating_system.py --root .`, `check_canonical_reference_freshness.py --root .`, `check_archive_governance.py`는 각각 PASS했다. JSON parse, `git diff --check`, exact product/asset/project path diff-empty, archive secret-marker scan도 PASS했다.

실제 5회 full-scope loop는 매회 authority, 전체 diff, untouched consumer, 실행 증거, 실패/rollback, 비용, 장기 승인 경계를 함께 다시 확인했다. Loop 1은 GitHub merge/check identity와 merge-commit Git blob 2,452 bytes/SHA/Base64/semantic equality를 확인했다. Loop 2는 active approval 제거, archived non-authority, merged baseline 및 이전 PR #331 lifecycle consumer를 확인했다. Loop 3은 Active Context·두 current JSON·두 roadmap·durable report의 중복 mutable key와 다섯 생성 산출물을 확인해 stale `product_stage` test consumer를 교정했다. Loop 4는 `data/src/scenes/assets/addons/project.godot`, PDF, capture가 diff-empty임과 Draft #199/#200 비간섭, import 전 실패/import teardown 경고/두 전체490 실행의 서로 다른 evidence identity를 확인했다. Loop 5는 전체 owned diff, manifest 재사용 불가, 다음 작업 순서와 모든 Human/device/accessibility/release/whole-Blueprint ceiling을 재확인했다. 가짜 finding 없이 검출된 하나의 중복 assertion을 교정했고, committed candidate의 `check_one_time_protected_change_lifecycle.py --project-root . --base-sha fe720f5dce686ea5b2ff68a1ec078d53544a0e92`는 `Protected approval lifecycle validation passed`였다.

같은 committed candidate에서 adopted Base `check_approved_project_operating_contract.py --project-root . --base-repository <adopted-19355-checkout> --protected-base fe720f5dce686ea5b2ff68a1ec078d53544a0e92 --external-approval false --check`는 active approval 없이 `Approved project operating contract validation passed`였다. 이 결과는 종료된 PR #333 승인을 재사용한 PASS가 아니라 exact merged baseline 이후 closeout-only diff의 PASS다. 최종 amend 뒤 동일 content validators를 다시 읽었으며, 이 기록의 완료 상태는 제품/Human/device/release 완료를 뜻하지 않는다.

## 독립 검토 교정 round 1

독립 검토는 closeout 결과가 아니라 회귀의 장기 수명과 보고 정확성에서 세 가지 문제를 찾았다. 첫째, 신규 PR #333 test와 이 closeout에서 함께 바꾼 PR #331/current-discovery/PC-first tests가 `active_planning_pr`, live state, successor package/Decision 문자열을 현재 값으로 중복 고정해 다음 합법적 phase 전환에도 test rewrite를 요구했다. 해당 검사는 immutable PR #331/#333 merge/head/run/hash 증거만 exact 값으로 유지하고, mutable 값은 `current_operating_state.json` → Active Context 및 `current_user_planning_status.json` 사이의 관계를 검사하도록 바꿨다. generic remaining 문구에서 `review`/`merge` 단어를 금지하던 assertion도 제거했다.

둘째, 보고서 전체에서 `post-merge 490 PASS` 또는 `whole Blueprint complete` 같은 문자열을 금지하는 검사는 동의어를 놓치면서 정당한 역사 문구까지 막을 수 있었다. 대체 검사는 PR #333 closeout 섹션의 정확한 문단을 나눠, import 전 missing-global-class 실패·종료와 non-PASS 판정, import 후 merged-main `490 tests in 329.82s`, 45/22 teardown 경고를 한 실행 증거로 확인한다. 별도 evidence-ceiling 문단에서 Human/physical/audio와 whole Blueprint completion이 `NOT_RUN`임을 positive assertion으로 확인한다.

셋째, durable 보고서가 실제 adapter key `protected_baseline.commit`을 `protected_paths_merged_baseline.commit`으로 잘못 적었다. 제품·JSON을 바꾸지 않고 보고서 식별자만 실제 `skills/PROJECT_BASE_ADAPTER.json`과 일치시켰다.

이 교정은 이미 서로 일치하던 current JSON/Active Context를 대상으로 test 구조를 단단하게 만든 것이므로 snapshot behavior에 대한 새 prospective RED를 발명하지 않았다. 첫 refactor 실행은 test 자체의 hub→detailed-roadmap 간접 링크 기대와 한 함수의 local `operating` load 누락을 정직하게 **2 failed, 32 passed in 1.94s**로 드러냈다. 두 test 구현 문제를 고친 focused governance 묶음은 **34 passed in 2.26s**였다. 이 round는 새 제품 의미, current successor 값, archived PR bytes 또는 승인 수명주기를 변경하지 않는다.
