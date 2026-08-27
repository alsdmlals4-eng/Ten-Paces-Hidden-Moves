# Issue #240 · VisualReferenceStatus 문구 교정 실행 기록

## 범위와 기준

- 기준 Project `main`: `cd44796c74d4958dbd96c213ecac5b7dbbf18afe`.
- Issue: [#240](https://github.com/alsdmlals4-eng/Ten-Paces-Hidden-Moves/issues/240).
- 변경: `VerticalSliceShell/VisualReferenceStatus`의 문구와 그 정확한 Godot 회귀만 교정.
- 제외: 레이아웃, Scene hierarchy, 전투·Route 규칙, 자산 승격, 이미지 생성, 시각 통합.

## RED → GREEN

- RED: `tests/verify_vertical_slice_shell.gd`의 기대 문구를 승인 상태에 맞게 바꾼 뒤, 기존 문구 때문에 예상대로 실패했다.
- GREEN: `src/run/vertical_slice_shell.gd`가 `승인 전투 레퍼런스 확인됨 · 현재 UI는 기능/정보 위계 검증용`을 표시하도록 최소 교정했고 focused shell verifier가 PASS했다.
- 인접 회귀: `tests/verify_default_vertical_slice_entry.gd` PASS.

## 증거와 한계

- Godot: `4.7.1.stable.official.a13da4feb`, clean worktree에서 import/parse 후 headless verifier 실행. `--editor --quit`은 exit `0`이었고, 종료 시 `ObjectDB instances were leaked`/`resources still in use` 진단은 변경 전 baseline에서도 동일하게 관찰된 환경성 메시지다.
- `final_visual_reference_pending`은 계속 `false`다.
- Hera live editor는 이번 worktree에서 열려 있지 않았으므로 live UI 관찰은 수행하지 않았다.
- Windows visible human usability, Android actual device, 접근성 사용자, Human readability/fun은 `NOT_RUN`이다.

## Incident · Solution · Lesson

- 원인: 승인 Reference의 존재와 full visual integration 미완료를 구분하려던 기존 문구가 “반영 전”으로 읽혀, 이미 false인 pending metadata와 충돌했다.
- 해결: approval pending을 뜻하지 않는 문구로 교체하고, 실제 Label의 text를 읽는 회귀를 보존했다.
- Protected-path lifecycle: `docs/operations/PROJECT_PROTECTED_CHANGE_APPROVAL.json`은 이 PR의 `src/run/vertical_slice_shell.gd` 한 파일만 승인하며, 병합 뒤 archive cleanup PR에서 제거한다.
- CI gate 교정: runtime protected-path gate가 요구한 one-time approval과 기준 SHA `cd44796c74d4958dbd96c213ecac5b7dbbf18afe`로 adapter baseline 및 파생 operating views를 동기화했다. 계약 validator와 lifecycle validator가 모두 PASS했다.
- Base 승격: `NO_NEW_REUSABLE_LESSON`; 단일 프로젝트 사례이므로 반복·독립 evidence 전에는 Base 정책을 변경하지 않는다.
