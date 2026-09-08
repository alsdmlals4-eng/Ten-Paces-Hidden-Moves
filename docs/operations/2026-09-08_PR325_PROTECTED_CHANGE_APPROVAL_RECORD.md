# PR 325 보호 변경 승인 보존과 병합 후 검증 기록

```yaml
artifact_role: PROTECTED_CHANGE_APPROVAL_ARCHIVE_RECORD
implementation_pr: 325
implementation_merge_commit: 12fe75ca795c9af640a58eff975e2a6cbe02888d
implementation_exact_head: 99298f167f80e59732c42323e4cd6bde9f3c4d8d
approval_manifest_sha256: 9EB13150CF07AC0172959F334EAA187D0B0E63CC03FFE9B809FCDDE2B8A57786
approval_lifecycle: ARCHIVED_NOT_CURRENT_EXECUTION_AUTHORITY
active_authority: false
implementation_authority: NONE
```

## 문제·조사·채택 구조

병합이 완료됐지만 current 상태는 CI 대기이고 12경로의 일회성 승인이 활성 파일로 남았다.
이 승인 전체를 merged Git blob bytes와 의미상 동일한 JSON으로 보존한 뒤 활성 파일만 제거한다.
보호 기준점은 위 merge commit으로 이동한다. 원본은 Git 및 아래 base64로 byte 복구 가능하다.
현재 제품·자산·core·보상·저장·Base adoption은 변경하지 않는다.

CURRENT_SOURCE_RELEVANCE_CHECK: REUSED_EVIDENCE. 기존 PR 324 closeout과 채택 Base
`19355b7ef065a21d0f2b685c7d9be64a4a3970f8` approval-aware validator와 generator를 재사용한다.
새 설계가 없는 같은 Task 4 수명 closeout에 외부 게임 비교 추가는 NOT_APPLICABLE.
대안은 active 승인 유지(재사용 위험으로 REJECT), 승인 삭제만 수행(감사·상태 누락으로 REJECT),
전체 원문 archive와 baseline·current owner 동기화(ADOPT)다. FEASIBLE: existing validator,
generator, JSON/Active Context consumers와 archive byte regression으로 검증 가능하다.

## 원문 의미와 정확 bytes 보존

```json
{"schema_version":1,"artifact_role":"PROJECT_PROTECTED_CHANGE_APPROVAL","status":"APPROVED","protected_base_commit":"81ef0f0b2ede9cd63d6a2aba521a645efc1d4e5f","decision_ids":["TEN-DEC-20260908-BIMU-CONSTRAINT-RUNTIME-01","TEN-DEC-20260908-STANDING-PR-INTEGRATION-01"],"approved_paths":["data/run/bimu_constraints.json","src/combat/combat_board_preview.gd","src/run/bimu_constraint_model.gd","src/run/vertical_slice_combat_bridge.gd","src/run/vertical_slice_metrics_combat_resolution_engine.gd","src/run/vertical_slice_run_state.gd","src/run/vertical_slice_shell.gd","src/ui/action_selection/action_choice_card.gd","src/ui/action_selection/action_selection_dock.gd","src/ui/action_selection/martial_action_panel.gd","src/ui/action_selection/ultimate_action_panel.gd","src/ui/bimu_constraint_panel.gd"],"approval_source":"Latest explicit user implementation continuation, separately scoped by docs/implementation/BUILD_APPROVAL_2026-09-08.md and TEN-DEC-20260908-BIMU-CONSTRAINT-RUNTIME-01. Related PR integration is standing-authorized without bypass. This fresh manifest applies only to the bimu constraint runtime package; PR322 approval remains archived.","approval_time":"2026-09-08T00:00:00+09:00","scope_summary":"Nine optional constraints; zero to two selections within three points; frozen current-duel and identical retry receipt; authoritative manual-only seal and enemy overlay; native selection/preparation feedback and unchanged-panel rebuild reduction. No reward formula, save schema, core change, original asset replacement, Human final lock or release approval. Exact protected paths are derived from committed diff against protected baseline."}
```

아래는 LF를 포함한 merged Git blob 원문 전체다. JSON 재직렬화 또는 Windows checkout
줄바꿈 변환본의 해시를 원본 해시로 오인하지 않는다.

```base64
ewogICJzY2hlbWFfdmVyc2lvbiI6IDEsCiAgImFydGlmYWN0X3JvbGUiOiAiUFJPSkVDVF9QUk9URUNURURfQ0hBTkdFX0FQUFJPVkFMIiwKICAic3RhdHVzIjogIkFQUFJPVkVEIiwKICAicHJvdGVjdGVkX2Jhc2VfY29tbWl0IjogIjgxZWYwZjBiMmVkZTljZDYzZDZhMmFiYTUyMWE2NDVlZmMxZDRlNWYiLAogICJkZWNpc2lvbl9pZHMiOiBbIlRFTi1ERUMtMjAyNjA5MDgtQklNVS1DT05TVFJBSU5ULVJVTlRJTUUtMDEiLCAiVEVOLURFQy0yMDI2MDkwOC1TVEFORElORy1QUi1JTlRFR1JBVElPTi0wMSJdLAogICJhcHByb3ZlZF9wYXRocyI6IFsKICAgICJkYXRhL3J1bi9iaW11X2NvbnN0cmFpbnRzLmpzb24iLAogICAgInNyYy9jb21iYXQvY29tYmF0X2JvYXJkX3ByZXZpZXcuZ2QiLAogICAgInNyYy9ydW4vYmltdV9jb25zdHJhaW50X21vZGVsLmdkIiwKICAgICJzcmMvcnVuL3ZlcnRpY2FsX3NsaWNlX2NvbWJhdF9icmlkZ2UuZ2QiLAogICAgInNyYy9ydW4vdmVydGljYWxfc2xpY2VfbWV0cmljc19jb21iYXRfcmVzb2x1dGlvbl9lbmdpbmUuZ2QiLAogICAgInNyYy9ydW4vdmVydGljYWxfc2xpY2VfcnVuX3N0YXRlLmdkIiwKICAgICJzcmMvcnVuL3ZlcnRpY2FsX3NsaWNlX3NoZWxsLmdkIiwKICAgICJzcmMvdWkvYWN0aW9uX3NlbGVjdGlvbi9hY3Rpb25fY2hvaWNlX2NhcmQuZ2QiLAogICAgInNyYy91aS9hY3Rpb25fc2VsZWN0aW9uL2FjdGlvbl9zZWxlY3Rpb25fZG9jay5nZCIsCiAgICAic3JjL3VpL2FjdGlvbl9zZWxlY3Rpb24vbWFydGlhbF9hY3Rpb25fcGFuZWwuZ2QiLAogICAgInNyYy91aS9hY3Rpb25fc2VsZWN0aW9uL3VsdGltYXRlX2FjdGlvbl9wYW5lbC5nZCIsCiAgICAic3JjL3VpL2JpbXVfY29uc3RyYWludF9wYW5lbC5nZCIKICBdLAogICJhcHByb3ZhbF9zb3VyY2UiOiAiTGF0ZXN0IGV4cGxpY2l0IHVzZXIgaW1wbGVtZW50YXRpb24gY29udGludWF0aW9uLCBzZXBhcmF0ZWx5IHNjb3BlZCBieSBkb2NzL2ltcGxlbWVudGF0aW9uL0JVSUxEX0FQUFJPVkFMXzIwMjYtMDktMDgubWQgYW5kIFRFTi1ERUMtMjAyNjA5MDgtQklNVS1DT05TVFJBSU5ULVJVTlRJTUUtMDEuIFJlbGF0ZWQgUFIgaW50ZWdyYXRpb24gaXMgc3RhbmRpbmctYXV0aG9yaXplZCB3aXRob3V0IGJ5cGFzcy4gVGhpcyBmcmVzaCBtYW5pZmVzdCBhcHBsaWVzIG9ubHkgdG8gdGhlIGJpbXUgY29uc3RyYWludCBydW50aW1lIHBhY2thZ2U7IFBSMzIyIGFwcHJvdmFsIHJlbWFpbnMgYXJjaGl2ZWQuIiwKICAiYXBwcm92YWxfdGltZSI6ICIyMDI2LTA5LTA4VDAwOjAwOjAwKzA5OjAwIiwKICAic2NvcGVfc3VtbWFyeSI6ICJOaW5lIG9wdGlvbmFsIGNvbnN0cmFpbnRzOyB6ZXJvIHRvIHR3byBzZWxlY3Rpb25zIHdpdGhpbiB0aHJlZSBwb2ludHM7IGZyb3plbiBjdXJyZW50LWR1ZWwgYW5kIGlkZW50aWNhbCByZXRyeSByZWNlaXB0OyBhdXRob3JpdGF0aXZlIG1hbnVhbC1vbmx5IHNlYWwgYW5kIGVuZW15IG92ZXJsYXk7IG5hdGl2ZSBzZWxlY3Rpb24vcHJlcGFyYXRpb24gZmVlZGJhY2sgYW5kIHVuY2hhbmdlZC1wYW5lbCByZWJ1aWxkIHJlZHVjdGlvbi4gTm8gcmV3YXJkIGZvcm11bGEsIHNhdmUgc2NoZW1hLCBjb3JlIGNoYW5nZSwgb3JpZ2luYWwgYXNzZXQgcmVwbGFjZW1lbnQsIEh1bWFuIGZpbmFsIGxvY2sgb3IgcmVsZWFzZSBhcHByb3ZhbC4gRXhhY3QgcHJvdGVjdGVkIHBhdGhzIGFyZSBkZXJpdmVkIGZyb20gY29tbWl0dGVkIGRpZmYgYWdhaW5zdCBwcm90ZWN0ZWQgYmFzZWxpbmUuIgp9Cg==
```

## 구현 결과·사용 예·기대효과

current 운영 JSON·planning JSON·Active Context·Decision·execution report는
MAIN_MERGED_VERIFIED로 맞춘다. 다음 담당자는 native-input 전체 캠페인과 Blueprint gap
검증을 계속한다. 이 기록으로 새 제품 변경을 승인하거나 전체 Blueprint 완료를 주장하지 않는다.
시작 자원 +1은 기존 최대치에 제한되므로 가득 찼을 때 실제 delta가 0일 수 있다.
이는 승인된 semantics를 보존한 판정이다. 의미 있는 강화가 항상 필요하다는 새 요구는
향후 balance Decision으로 다루며 이 closeout에서 최대치를 바꾸지 않는다.

## 검증 provenance와 검토

Work Mode REVIEW / Skill Mode contract-check, regression, evidence-report.
Skills: ten-paces-verification, running-adversarial-review-and-refinement.
기준 SHA는 위 merge commit. 아래 원격/런타임 결과는 controller가 exact revision에서
실행해 전달한 evidence이며 이 문서 작업자가 별도 실행했다고 주장하지 않는다.

- PR 325 exact head 34/34 SUCCESS 뒤 정상 병합; 독립 최종 review 승인.
- detached merged main 전체 pytest 473 PASS, 17.94s.
- merged model 45 cases, runtime, UI, public-policy 10-duel probe 모두 exit 0, script errors 0.
- visible1280×800의 기존 3 captures는 이전 source-bound 관찰을 재사용한다.
  merged head에서 새 visible 캡처는 NOT_RUN, visible720도 NOT_RUN.
- 독립 bridge의 expected run/duel identity 보강은 외부 receipt consumer가 없는 현재 경로에서
  DEFER_NONBLOCKING. 실제 shell은 RunState receipt를 직접 공급하고 retry는 동일 snapshot을 복원한다.
- unlock registry의 exact ID 집합 minor finding은 구현 PR에서 해결됐다.
- 이 closeout RED: 새 archive regression이 기록 부재로 1 FAILED. GREEN 및 전체 검증은 아래 closeout 결과를 참조한다.

## 미검증·남은 위험

native-input 전체 캠페인, Human balance/UX, Android 실기기, 게임패드, 접근성 사용자,
Release 성능·권리·출시, 전체 Blueprint gap 해소는 NOT_RUN/미완료다.
이번 closeout PR의 원격 검사·병합·main readback은 controller 후속 책임이다.
## Closeout 전체 범위 적대 검토·자동화 학습

각 loop는 승인·정본·전체 diff·untouched consumer·파생본·복구·비용·장기 적합성·
evidence ceiling을 함께 재검토했다. 대표 finding은 검토 범위를 분할한 목록이 아니다.

1. 입력 merged main: 완료된 manifest와 CI 대기 상태의 충돌을 확인했다.
   archive RED 1 FAILED 후 정확 blob bytes/hash, active 제거, current owners와 derived views를
   함께 수정했다. focused 22 PASS. 승인 유지·삭제만의 대안보다 provenance 보존을 채택했다.
   제품 paths는 무변경, 비용·core·Human 승격 없음. 결과를 다시 공격해 archive test의 미래 경직성을 발견했다.
2. 입력 첫 GREEN 상태: current approval의 영구 부재·baseline 고정 assertion은 다음 정상
   승인까지 막을 수 있어 현재 완료 검증과 불변 역사 회귀를 분리했다. 기존 PR321/322 패턴과
   비교하여 새 test는 원문 bytes/의미/해시/비활성 authority만 고정했다. focused 22 PASS.
   전체 owner·diff·untouched consumers·보호·복구·비용을 재공격했고 새 제품 위험은 없었다.
3. 입력 durable archive regression: full pytest 474 PASS (17.45s), canonical lifecycle OK,
   project operating system PASS, exact Base operating contract PASS를 대조했다.
   current/history 문구, visible source와 merged head 증거, cap +1 의미와 deferred bridge를 재검토했다.
   더 넓은 balance/bridge 수정은 현재 docs scope 밖으로 판정했다. 제품 무변경과 adoption
   불변을 diff로 재확인했고 전체 Blueprint 완료 주장을 발견하지 않았다.
4. 입력 위 검증 상태: 전체 diff와 dashboard/기존 discovery 회귀·archive bytes를 재공격했다.
   one-time lifecycle CLI가 uncommitted archive를 보지 못해 실패했다. 실제 checker는
   base...HEAD committed diff를 읽으므로 검사를 약화하지 않고 commit 뒤 재실행으로 해결한다.
   이 실패를 제품·권한 실패와 구분했다. long-term 대안은 기존 committed evidence 경로 유지다.
   추가 비용/도구/제품 mutation 없이 정확 commit 검증을 다음 loop 입력으로 삼는다.
5. 입력 committed `1fc748c3`: 전체 승인·실제 committed diff·untouched consumer·archive
   복구와 current/history·비용·장기 적합성을 다시 검토했다. one-time lifecycle PASS,
   전체 pytest 474 PASS (16.16s), CANON_LIFECYCLE_OK, exact Base contract PASS였다.
   15개 변경 경로는 docs/skills/tests와 Active Context이며 제품 경로 변화는 0이다.
   원격 검증은 controller 위임 경계를 유지한다. 추가 MUST_FIX/승인 SHOULD_FIX 0,
   NO_MATERIAL_FOLLOWUP / 로컬 closeout 범위 CLEAN_REVIEW_EXIT.

REMAINING_WORK_RECALCULATION_REQUIRED: docs closeout의 남은 작업은 exact committed
lifecycle readback 및 controller의 remote delivery다. 제품 native-input/Blueprint gap은
현재 next-package로 남기며 closeout 완료와 제품 전체 완료를 분리한다.
재사용 학습: Git blob hash와 Windows checkout hash를 구분하고 byte archive를 회귀화한다.
archive 회귀에 미래 current stage를 고정하지 않는다. committed-diff validator는 commit 뒤
검사한다. Base 공용 변경은 하지 않았고 이 검증된 후보만 프로젝트 기록에 보존한다.
