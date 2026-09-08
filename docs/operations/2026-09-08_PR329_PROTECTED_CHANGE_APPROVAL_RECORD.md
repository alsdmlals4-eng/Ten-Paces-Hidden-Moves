# PR 329 보호 변경 승인 보존과 병합 후 검증 기록

```yaml
artifact_role: PROTECTED_CHANGE_APPROVAL_ARCHIVE_RECORD
implementation_pr: 329
implementation_merge_commit: 30b854b657fa5f29904d05c77aad38c7b6e17072
implementation_exact_head: ee5dde81f9184958514f93b8cc7fbe721c57e189
approval_manifest_sha256: D504939CC600F031F527ABDE2F3E1FF427CE74BDB0E349BA4AB89994BC1C8011
approval_lifecycle: ARCHIVED_NOT_CURRENT_EXECUTION_AUTHORITY
active_authority: false
implementation_authority: NONE
```

## 문제·채택 구조·현재 결과

PR 329가 정상 병합됐지만 그 PR 전용 active manifest가 main에 남아 있었다. 실제 merge commit의 Git blob bytes와 의미상 동일한 JSON을 아래에 불변 보존하고 active 파일만 제거한다. protected baseline은 exact merged main으로 이동한다. `CURRENT_SOURCE_RELEVANCE_CHECK: REUSED_EVIDENCE`; PR 325의 검증된 lifecycle 구조를 같은 closeout dimension에 재사용하며 새 게임 설계·외부 연구는 `NOT_APPLICABLE`이다. 제품·art·core·capture bytes는 변경하지 않는다.

## 원문 의미와 정확 bytes

```json
{"schema_version":1,"artifact_role":"PROJECT_PROTECTED_CHANGE_APPROVAL","status":"APPROVED","protected_base_commit":"12fe75ca795c9af640a58eff975e2a6cbe02888d","decision_ids":["TEN-DEC-20260904-THREE-BRANCH-FOUR-CHOICE-JIANGHU-AND-HUMAN-BLUEPRINT-01"],"approved_paths":["src/combat/combat_board_preview.gd","src/combat/combat_board_preview_auto.gd","src/ui/combat_progress_button.gd","src/ui/action_selection/action_selection_dock.gd"],"approval_source":"Approved single-execute Blueprint continuation in section 1.2 of docs/decisions/2026-09-04_THREE_BRANCH_FOUR_CHOICE_JIANGHU_AND_HUMAN_BLUEPRINT_DECISION.md and the current user-directed Codex implementation handoff, including the same request's bounded measured action-dock optimization.","approval_time":"2026-09-08T00:00:00+09:00","scope_summary":"Replace the active two-click plan-lock/execute CTA with exactly one 행동 실행 activation that closes planning and starts exactly one existing bundle resolution, and avoid redundant manual view-model reconstruction when the dock receives identical owned loadout/mastery inputs. Preserve all dynamic context updates, 3/3/4 commitments, reservations, public-only AI, resolver mechanics, rewards, numerical rules, save schema, routes, audio and engine."}
```

```base64
ewogICJzY2hlbWFfdmVyc2lvbiI6IDEsCiAgImFydGlmYWN0X3JvbGUiOiAiUFJPSkVDVF9QUk9URUNURURfQ0hBTkdFX0FQUFJPVkFMIiwKICAic3RhdHVzIjogIkFQUFJPVkVEIiwKICAicHJvdGVjdGVkX2Jhc2VfY29tbWl0IjogIjEyZmU3NWNhNzk1YzlhZjY0MGE1OGVmZjk3NWUyYTZjYmUwMjg4OGQiLAogICJkZWNpc2lvbl9pZHMiOiBbIlRFTi1ERUMtMjAyNjA5MDQtVEhSRUUtQlJBTkNILUZPVVItQ0hPSUNFLUpJQU5HSFUtQU5ELUhVTUFOLUJMVUVQUklOVC0wMSJdLAogICJhcHByb3ZlZF9wYXRocyI6IFsKICAgICJzcmMvY29tYmF0L2NvbWJhdF9ib2FyZF9wcmV2aWV3LmdkIiwKICAgICJzcmMvY29tYmF0L2NvbWJhdF9ib2FyZF9wcmV2aWV3X2F1dG8uZ2QiLAogICAgInNyYy91aS9jb21iYXRfcHJvZ3Jlc3NfYnV0dG9uLmdkIiwKICAgICJzcmMvdWkvYWN0aW9uX3NlbGVjdGlvbi9hY3Rpb25fc2VsZWN0aW9uX2RvY2suZ2QiCiAgXSwKICAiYXBwcm92YWxfc291cmNlIjogIkFwcHJvdmVkIHNpbmdsZS1leGVjdXRlIEJsdWVwcmludCBjb250aW51YXRpb24gaW4gc2VjdGlvbiAxLjIgb2YgZG9jcy9kZWNpc2lvbnMvMjAyNi0wOS0wNF9USFJFRV9CUkFOQ0hfRk9VUl9DSE9JQ0VfSklBTkdIVV9BTkRfSFVNQU5fQkxVRVBSSU5UX0RFQ0lTSU9OLm1kIGFuZCB0aGUgY3VycmVudCB1c2VyLWRpcmVjdGVkIENvZGV4IGltcGxlbWVudGF0aW9uIGhhbmRvZmYsIGluY2x1ZGluZyB0aGUgc2FtZSByZXF1ZXN0J3MgYm91bmRlZCBtZWFzdXJlZCBhY3Rpb24tZG9jayBvcHRpbWl6YXRpb24uIiwKICAiYXBwcm92YWxfdGltZSI6ICIyMDI2LTA5LTA4VDAwOjAwOjAwKzA5OjAwIiwKICAic2NvcGVfc3VtbWFyeSI6ICJSZXBsYWNlIHRoZSBhY3RpdmUgdHdvLWNsaWNrIHBsYW4tbG9jay9leGVjdXRlIENUQSB3aXRoIGV4YWN0bHkgb25lIO2WieuPmSDsi6TtlokgYWN0aXZhdGlvbiB0aGF0IGNsb3NlcyBwbGFubmluZyBhbmQgc3RhcnRzIGV4YWN0bHkgb25lIGV4aXN0aW5nIGJ1bmRsZSByZXNvbHV0aW9uLCBhbmQgYXZvaWQgcmVkdW5kYW50IG1hbnVhbCB2aWV3LW1vZGVsIHJlY29uc3RydWN0aW9uIHdoZW4gdGhlIGRvY2sgcmVjZWl2ZXMgaWRlbnRpY2FsIG93bmVkIGxvYWRvdXQvbWFzdGVyeSBpbnB1dHMuIFByZXNlcnZlIGFsbCBkeW5hbWljIGNvbnRleHQgdXBkYXRlcywgMy8zLzQgY29tbWl0bWVudHMsIHJlc2VydmF0aW9ucywgcHVibGljLW9ubHkgQUksIHJlc29sdmVyIG1lY2hhbmljcywgcmV3YXJkcywgbnVtZXJpY2FsIHJ1bGVzLCBzYXZlIHNjaGVtYSwgcm91dGVzLCBhdWRpbyBhbmQgZW5naW5lLiIKfQo=
```

## 검증·증거 ceiling·적대 검토

- PR 329 exact head `ee5dde81f9184958514f93b8cc7fbe721c57e189`, merge `30b854b657fa5f29904d05c77aad38c7b6e17072`; no unresolved review threads, normal merge.
- Controller detached-main: `475 passed in 15.45s`. 최신 adapter run `34210727715` SUCCESS; initial missing-label failure `34210353792`는 역사 실패다. rollup은 `32 SUCCESS + historical failed run`, `33/33`이 아니다.
- 준비/해결 capture와 source revision은 원 execution report 그대로 보존한다. Human·physical input·Android·accessibility-user·release는 계속 `NOT_RUN`이다.
- Loop 1: Git blob hash/bytes와 checkout 재직렬화를 공격해 raw base64 보존을 채택했다.
- Loop 2: approval 재사용 위험을 공격해 active manifest만 제거하고 역사 record를 남겼다.
- Loop 3: baseline drift를 공격해 exact merged main으로만 승격하고 protected path policy/hash는 변경하지 않았다.
- Loop 4: current/history 및 CI rollup을 공격해 initial failure와 final success를 함께 기록하고 33/33 오표현을 금지했다.
- Loop 5: 전체 diff·capture provenance·제품/asset/core consumer를 공격해 docs/adapter/test 외 변경 0과 `CLEAN_REVIEW_EXIT`를 확인했다.

첫 committed lifecycle 검사는 PASS했지만 approval-aware operating validator가 baseline 변경에 따른 네 generated view stale 상태를 발견했다. 채택 generator `build_project_operating_artifacts.py --write`로 snapshot/dashboard/두 compatibility view만 재생성했다. 이는 제품 변경이 아니라 canonical adapter 파생본 동기화이며, 재생성 전 validator failure를 숨기지 않는다.

Controller가 이 closeout의 remote CI, merge와 postmerge readback을 수행한다.
