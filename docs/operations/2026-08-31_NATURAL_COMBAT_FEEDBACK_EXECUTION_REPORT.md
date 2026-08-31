# 자연스러운 전투 피드백 실행 보고

## 실행 기준

| 항목 | 값 |
| --- | --- |
| 기준 main / 작업 시작 HEAD | `b0b676450fe0a097bcccb38de51912b523dcd2ec` |
| 작업 branch | `codex/natural-combat-feedback-implementation-20260831` |
| Work Mode | `BUILD → REVIEW` |
| 적용 Skill / Mode | `combat-implementation-handoff` (`build`, `runtime-handoff`), `combat-ux-and-accessibility` (`ui-contract`, `accessibility-review`), `ten-paces-verification` (`contract-check`, `runtime-validation`, `regression`, `evidence-report`), Base review/sync (`attack → validate-critique → refine-approved-findings → regression-recheck → decision-report`; `preflight → publish → verify`) |
| 승인 | 사용자의 `권장안대로 진행해, 연출은 자연스럽게 이어져야해` 및 기존 같은 범위의 계속 진행 승인 |
| 보호 경로 | `src/combat/combat_board_preview.gd` 단 하나. 승인 manifest: `docs/operations/PROJECT_PROTECTED_CHANGE_APPROVAL.json` |
| 현재 source relevance | 같은 결투 결과 표현 차원을 위한 12개 게임 역공학 기록을 재사용하고, Godot 4.7의 Control pivot/scale 및 Tween 병렬·순차 property track 문서를 2026-08-31에 다시 대조했다. 새 전투 규칙·자산·정보 공개 범위는 만들지 않았다. |

## 작업 전 문제

평타·합·절초의 공개 결과는 이미 한 수씩 순서대로 제시했지만, 기존 구현은 캐릭터의 공격 이동과 동시에 결과 텍스트, 잉크 효과음, VFX를 시작했다. 원인과 결과가 같은 순간에 선행되어, 화면상으로는 "무엇이 닿아서 결과가 생겼는지"가 약했다.

이 문제는 게임 규칙 결함이 아니다. 해결 엔진이 만든 공개 `action_result` / `clash`를 UI가 어떻게 보여 줄지에만 해당한다. 10칸 논리, 공개 거리, 3/3/4, 순차 해결, AI의 미확정 계획 비열람, 저장 schema, 카드 정보와 확정 raster bytes는 보호 범위로 유지했다.

## 조사·비교 결과

| 검토 대상 | 채택 / 기각 | 근거와 경계 |
| --- | --- | --- |
| 기존 12개 유사·인접 게임의 결과 전달 원칙 | `ADAPT` | 한쪽의 준비 동작 → 중앙/목표 지점의 결과 → 짧은 정리 흐름은 공개된 원인·결과 판독을 돕는다. 기존 `docs/reviews/2026-08-30_TEN_PACES_BENCHMARK_REVERSE_ENGINEERING.md`의 같은 decision dimension을 재사용했다. |
| 적 계획을 미리 모두 보여 주는 합 연출 | `AVOID` | 연출을 위해 미래 수 또는 숨은 계획을 노출하면 십보강호의 공개 정보 경계를 위반한다. |
| 실시간 입력/별도 전투 상태기계/새 VFX 세트 | `AVOID` | 이미 확정된 자산과 authoritative event 순서만 사용하면 충분하다. 새 시스템·이미지·비용을 만들 이유가 없다. |
| Godot `Control` transform + Tween | `ADOPT` | 기존 `presentation_label`, `presentation_vfx`의 pivot/alpha/scale만 전환한다. 도메인 결과를 계산하거나 저장하지 않는다. |

## 채택한 구조와 이유

모든 공개 이벤트를 다음 단일 choreography로 통일했다.

```text
공개된 한 이벤트
  → windup: 해당 인물의 기존 lunge만 시작, 결과 글자와 VFX는 숨김
  → impact: 정확한 충돌 지점에서 결과 글자 + VFX + 기존 SFX를 함께 시작
  → settle: 짧게 fade/scale 회복 후 두 시각 요소를 지우고 다음 공개 이벤트로 이동
```

- 평타와 절초는 기존 공격 lunge의 peak 비율인 42%에 impact를 맞춘다.
- 합은 양측이 중앙으로 팽팽하게 모이는 짧은 준비(25%) 뒤 중앙 VFX를 보여 준다.
- 절초는 같은 리듬을 더 긴 총 길이로 사용한다. 독립된 절초 규칙이나 별도 카드/자산을 만들지 않는다.
- Fast Replay는 총 길이만 줄이고 비율을 유지한다. Reduced Motion은 인물 이동 없이 0.18초의 정적·읽을 수 있는 impact 결과를 보인다. Skip은 모든 Tween/VFX/label을 즉시 정리한다.

## 실제 구현 또는 준비 결과

1. `CombatBoardPreview`에 `_present_resolved_event_feedback()`를 두어 현재 공개 이벤트만 `windup → impact → settled` 순서로 표시하게 했다.
2. 결과 글자와 VFX를 직접 시작하던 호출을 preparation과 impact로 분리했다. 기존 `_show_feedback_vfx(event, kind)` 및 `_show_ultimate_vfx(event)` 호출은 optional duration 기본값으로 계속 호환된다.
3. VFX/label Tween을 소유하고, 재시작·skip·다음 이벤트 시작 시 kill/clear한다. 이전 이벤트의 fade가 다음 이벤트에 남지 않는다.
4. `get_layout_snapshot()`과 메타데이터에 phase/visibility history를 추가했다. 이는 플레이어에게 새 정보를 노출하지 않는 기계 검증용 관찰면이며 `presentation_future_action_exposed=false`를 유지한다.
5. `verify_combat_action_reveal.gd`에 평타·합·절초 각각의 숨은 windup, 동시 impact, 숨김 settle을 검사하는 RED→GREEN 회귀를 추가했다.
6. 프로젝트 보호 기준이 과거 archived approval을 다시 요구하지 않도록 `skills/PROJECT_BASE_ADAPTER.json`의 protected baseline을 현재 clean lifecycle 기준 `b0b676…`으로 교정하고, Base 생성기가 만든 네 파생 view와 byte-for-byte 대조했다. 이 변경은 전투 코어가 아닌 PR lifecycle contract 복구다.

## 사용 예

플레이어가 `속공`을 공개하면 먼저 검객이 짧게 전진한다. 그 동안 화면 중앙에는 피해 글자나 잉크 베기가 없다. 검끝이 목표 지점에 닿는 순간 `속공 · 피해 6`, 공격 VFX, 기존 타격음이 함께 나타나고 바로 정리된다. 이어진 합은 양쪽 움직임 뒤 중앙에만 합 VFX/결과를 보이며, 절초는 같은 규칙을 더 긴 호흡으로 유지한다.

## 기대효과

| 현재 상태 | 요청 이유 | 기대효과 |
| --- | --- | --- |
| 결과가 공격 이동과 같은 프레임에 시작 | 행동이 서로 겨룬다는 감각이 약함 | 준비와 적중의 인과가 읽혀 전투가 한 수씩 이어짐 |
| 평타·합·절초의 표시 종료가 분산될 수 있음 | 다음 공개 수에 잔상이 섞이면 정보가 흐려짐 | 공통 settle/clear로 다음 수의 시작점이 깨끗해짐 |
| Fast Replay·Reduced Motion·Skip이 각자 다른 시간 경로 | 접근성/재생 속도에서 의미가 사라질 위험 | 같은 결과 의미를 유지하며 시간/모션만 조절 |
| 보호 기준점이 archived manifest 이전에 머묾 | 다음 보호 PR이 이미 삭제된 파일을 요구할 수 있음 | active approval은 한 PR에만 존재하고 뒤 PR에서 archive하는 lifecycle을 다시 유지 |

## 검증 증거

### RED → GREEN

- 변경 전 focused choreography assertion은 windup phase와 impact-only visibility가 없어 12개 실패로 RED였다.
- 변경 후 Godot 4.7.1 headless에서 `tests/verify_combat_action_reveal.gd`가 `COMBAT_ACTION_REVEAL_VERIFY_OK`로 GREEN이다.

### 실행한 검사

- `verify_combat_action_reveal.gd` — 평타/합/절초 phase·visibility·private future boundary
- `verify_combat_presentation_controls.gd` — Fast Replay, Reduced Motion, Skip cleanup
- `verify_combat_terminal_presentation.gd`, `verify_combat_sfx_presentation.gd`, `verify_combat_presentation_liveness.gd`
- `verify_ink_paper_combat_presentation.gd`, `verify_combat_character_art.gd`, `verify_combat_keyboard_accessibility.gd`, `verify_combat_assistive_labels.gd`
- `verify_combat_performance_headless.gd`, `verify_ultimate_ui.gd`
- Godot 4.7.1 `--headless --editor --quit` parse/scene scan — exit `0`; 종료 시 ObjectDB/resource warning은 관측됐으나 PASS로 승격하지 않음
- `tools/check_one_time_protected_change_lifecycle.py --base-sha b0b676…` — PASS
- Base `check_approved_project_operating_contract.py --external-approval true --check` — PASS
- Base generator output은 clean temporary worktree에서 생성하고 현재 작업트리의 5개 contract/view bytes가 정확히 일치함을 readback했다. protected source가 있는 현재 worktree에서 generator `--check`가 중단되는 것은 의도된 fail-closed 동작이다.

### 증거 층 구분

| 층 | 상태 |
| --- | --- |
| 정적 / focused automated / headless Godot | `PASS` |
| local visible Ten Paces runtime | `NOT_RUN` — HERA가 발견한 실행 editor는 다른 프로젝트 `OMENWARD Prototype`이므로 조작하지 않았다. |
| Human UX·사람 플레이·보조기기 사용자 | `NOT_RUN` |
| Android actual device / release performance / release | `NOT_RUN` |

## 자동화·학습 반영

- `presentation_feedback_phase_history`와 실제 VFX/label visibility history를 회귀 관찰면으로 추가해, 시간 지연만 측정하던 검사가 아닌 "결과가 windup 뒤에만 보인다"는 계약을 자동 검사한다.
- 기존 public-event metadata와 optional method signature를 보존해, 카드/AI/저장/다른 VFX consumer에 새 결합을 만들지 않았다.
- contract baseline의 stale lifecycle defect는 Base generator output을 깨끗한 temp worktree에서 만들고 byte readback 후 적용하는 회복 절차로 기록했다.

## 적대적 전체 개선 loop

각 loop는 사용자 승인, 코어/정보 경계, 실제 diff, active consumer, 자산/권리, 입력/접근성, 동기화·PR 수명주기, 비용, 검증 ceiling과 장기 유지성을 전부 다시 공격했다.

| loop | validated finding / 판정 | 최소 조치와 재검사 | 더 나은 대안·장기 적합성 |
| --- | --- | --- | --- |
| 1 | 결과 VFX/글자가 lunge보다 먼저 생기는 유효 `MUST_FIX` | state history RED를 만든 뒤 `windup → impact → settled`로 분리, action reveal GREEN | 새 state machine보다 existing presenter의 작은 helper가 더 안전 |
| 2 | 대기 시간이 줄어도 impact 비율이 깨질 수 있는 유효 finding | effective duration을 character motion과 impact에 함께 전달, Fast/Reduced/Skip controls GREEN | Fast Replay를 결과 생략으로 바꾸는 안은 기각 |
| 3 | direct VFX/ultimate caller가 새 파라미터로 깨질 수 있는 유효 finding | optional default signature 유지, ultimate UI·performance headless GREEN | 절초 전용 renderer 분기는 기각 |
| 4 | 잔류 Tween이 다음 공개 수/skip/restart에 남을 수 있는 유효 finding | owned tween kill/clear와 liveness/terminal/SFX controls GREEN | 자연 종료에만 의존하는 안은 기각 |
| 5 | archived manifest 기준의 stale baseline이 새 protected PR을 막는 유효 `COMPLEMENT_GAP` | canonical adapter + Base-generated views를 exact readback, lifecycle/approved-contract GREEN | manifest를 영구 보존하거나 protected check를 약화하는 안은 기각 |

`FULL_LOOP_COUNT=5`의 local clean candidate를 만들었다. PR 병합 뒤 새 `main`과 approval archive lifecycle에서 같은 전체 재공격을 다시 수행한다.

## 미검증·남은 위험

- 현재 이 host의 HERA editor는 이 프로젝트가 아니라 `OMENWARD Prototype`이므로, 실제 십보강호의 visible screenshot/input/자연스러운 체감은 아직 증명하지 않았다. 다른 프로젝트를 침범하지 않는 것이 우선이다.
- Tween 기반 headless tests는 표시 순서와 cleanup을 검증하지만, 실제 해상도·프레임 타임·사람의 읽기 속도/타격감/접근성 보조기기 사용성을 대체하지 않는다.
- Remote CI, PR merge, post-merge main readback, approval archive PR은 아직 실행 전이다. 이 보고서는 local machine evidence까지만 주장한다.

## 롤백

문제가 발견되면 이 branch의 `src/combat/combat_board_preview.gd`와 `tests/verify_combat_action_reveal.gd` 두 변경만 되돌리면 된다. 게임 데이터, scene, save, raster asset은 변경하지 않았다. 보호 approval manifest는 구현 PR merge 후 별도 lifecycle PR에서 archive한다.
