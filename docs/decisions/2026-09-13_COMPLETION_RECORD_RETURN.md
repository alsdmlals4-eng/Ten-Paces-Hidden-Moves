# Completed record and title return

Decision: TEN-DEC-20260913-COMPLETION-RECORD-RETURN-01
Status: SPECIFIED / BUILD_AUTHORIZED_BY_CURRENT_CONTINUOUS_IMPLEMENTATION_REQUEST; Human NOT_RUN.
Parent: TEN-DEC-20260908-DURABLE-RUN-CONTINUE-01.
Plan and ten-game comparison: ../operations/2026-09-13_PLAYABLE_FLOW_IMPROVEMENT.md.

The completed ten-duel journey remains terminal in the domain model. Its validated active checkpoint remains available until the player explicitly confirms the existing new-journey replacement. No reward, retry, roster or save schema changes.

The completed-record screen offers `제목으로 돌아가기`. The shell first verifies the last stable save and then replaces only the scene instance with the existing title entry point. A fresh shell uses the same configured save and presentation settings paths. Returning does not call the domain MAIN transition, which has an existing retirement meaning. Duplicate return requests and return while commands are blocked, suspended or outside completion are rejected.

The title labels a completed checkpoint `완주 기록 보기`. Reading it restores the existing record, with ten reward receipts and thirty-six route receipts unchanged. The notice says that a confirmed new journey replaces this record; it does not promise a permanent archive. The ordinary `새 여정` button and existing confirmation/store transaction remain the only replacement path. Cancel retains the current record. Confirm creates the existing new-generation initial checkpoint.

Missing, corrupt or incompatible files continue through the existing title/store policy. A failed stable-save flush retains the old scene and recovery feedback. This feature is not a new archive, save slot, cloud backup, meta progression or another chance within a duel.

Evidence: prospective native-input RED/GREEN; saved checkpoint equality; cancel/confirm/new generation; duplicate return and failure guards; settings-path preservation; Windows visible title/record view; existing v1/v2 continuation regressions and exact-head CI. Automated runtime does not claim Human/device/release approval.
