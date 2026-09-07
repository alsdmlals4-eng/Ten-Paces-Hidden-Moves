# 2026-09-03 · Native 2D 표현 단계 흡수 실행 보고

## 실행 영수증

| 항목 | 기록 |
| --- | --- |
| 기준 | 현재 프로젝트 owner·실제 `CombatCharacterPlaceholder`·기존 최종 잠금 v2 전신 원화·PR #321 작업 경로를 fresh-read했다. |
| Work Mode | `BUILD → REVIEW` |
| 적용 원칙 | 외부 2D 리깅 도구를 설치하지 않고, 단계 상태·중단·접지·향후 파츠 계약만 native Godot 표현 계층에 흡수한다. |
| 변경 소비처 | `src/combat/combat_character_placeholder.gd`, `src/ui/action_timing_slot.gd` 및 두 focused Godot verifier. |
| 비범위 | Spine editor/runtime/GDExtension, Skeleton2D 구현, 신규/교체 캐릭터 원화, resolver·AI·저장·행동 경제 변경. |

## 작업 전 문제 → 원인

원격 Full Validation은 `verify_linked_action_blocks.gd:29`에서 실패한 뒤 종료하지 못해 두 Linux Godot job이 약 6시간 점유된 후 취소됐다. 원인은 최근 프레임 추가 중 개별 수 슬롯의 표시가 기존 계약인 `[전조]`/`[실행]`에서 `[전조] 기술명`으로 회귀한 것이다. 연결 행동 블록은 이미 기술명을 소유하므로 중복 표시는 화면 구조와 자동 계약 모두에 맞지 않았다.

## 채택 결과

- 개별 수 슬롯은 다시 단계만 표시하고, 연결 행동 묶음 하나가 기술명·출처·전체 단계를 소유한다.
- 연결 행동 묶음 검사에 10초 fail-safe 종료를 추가했다. assertion 또는 장래 로딩 결함이 생겨도 CI가 무한 대기하지 않고 실패로 끝난다.
- 전투원 표현은 `idle / windup / active / recovery` 단계와 monotonic `motion_sequence_id`를 갖는다.
- 공격·절초는 전조→발동→회복, 반응 모션은 발동→회복, `[합]`은 접근→접촉→복귀로 표현한다.
- 새 표현 요청은 기존 Tween만 중단하고 다음 상태를 시작한다. 전투 규칙 데이터에는 접근하지 않는다.
- 전신 PNG 확대·축소의 피벗을 바닥 중심에 놓고 시각 offset을 수평으로 제한해, 모션 중에도 발이 바닥선에 붙어 보이도록 보강했다.

## RED → GREEN 증거

| 순서 | 결과 |
| --- | --- |
| 연결 행동 회귀 재현 | 현 head에서 `막기`가 개별 슬롯 표시문자열에 포함돼 기존 assertion이 실패함을 원격 log와 source diff로 확인했다. 실패 뒤 `quit()`에 이르지 못하는 경로도 재현했다. |
| 최소 수정 | 슬롯 표시를 단계 전용으로 되돌리고 실패 watchdog을 추가했다. `verify_linked_action_blocks.gd`: `PASS`, exit `0`. |
| 단계 표현 RED | `verify_combat_character_art.gd`에 `get_motion_snapshot()`과 공격 단계 순서·중단·발 앵커 복귀 요구를 먼저 추가했다. 기존 구현에서 예상대로 `motion-state snapshot` 부재로 exit `1`을 확인했다. |
| 단계 표현 GREEN | native Tween 표현에 상태·단계·순번·중단 경로와 바닥 pivot을 추가했다. 동일 verifier는 `COMBAT_CHARACTER_ART_VERIFY_OK`, exit `0`. |

## 검증과 증거 한계

| 검증 | 결과 |
| --- | --- |
| `verify_linked_action_blocks.gd` | `PASS` |
| `verify_combat_character_art.gd` | `PASS` — 공격 단계 순서, 중단 후 피격 단계, 원래 발 앵커 및 기존 `[합]` 접지 회귀 포함 |
| exact-worktree live editor | 실행 중. runtime screenshot/diagnostics는 이 보고의 후속 capture patch에서 source commit과 함께 등록한다. |
| 사람 플레이·미학 판단 | `NOT_RUN` |
| Android 실기기·접근성 사용자·출시 성능 | `NOT_RUN` |

## 재사용·학습 반영

```yaml
external_tool_disposition:
  spine_editor_runtime_gdextension: REJECTED_NO_INSTALL
  godot_skeleton2d: DEFERRED_UNTIL_PARTED_ART_HAS_A_REAL_CONSUMER
  native_godot_phase_presentation: ADOPTED
base_promotion: NONE
reason: one project-specific presentation consumer and one locked full-body art route are insufficient cross-project evidence
rollback: revert only the phase-state and slot-label changes; retain final-locked v2 PNGs and their provenance unchanged
```

## 다음 안전 작업

1. checkpoint commit 뒤 exact-worktree running scene에서 machine runtime screenshot과 diagnostics를 수집·등록한다.
2. exact PR-head Full Validation이 다시 통과하는지 확인한다.
3. 파츠 분리 원화가 실제로 필요해질 때만 별도 asset brief와 `Skeleton2D` 1인 실험을 연다. 전문 리깅 도구 설치는 이 작업의 다음 단계가 아니다.
