# PR 301 자연스러운 전투 피드백 병합 후 Readback

## 병합 확인

| 항목 | 확인값 |
| --- | --- |
| PR | [#301](https://github.com/alsdmlals4-eng/Ten-Paces-Hidden-Moves/pull/301) |
| merge commit | `8d0f401f42431e78f78f26067f3dfc0309ddda9e` |
| main readback | local `main`과 `origin/main`을 fast-forward 후 같은 SHA로 확인 |
| PR head | `e302c404a0dc4c87ca66263dd009cfb8342cc2ad` |
| remote CI | Full Validation의 Ubuntu Godot headless 3m44s와 action-selection smoke, product evidence, Windows/Python validation을 포함한 보고된 check PASS |

## 병합 후 전체 재공격 요약

1. **승인·코어:** 바뀐 protected path가 `CombatBoardPreview` 하나인지, 10칸/3·3·4/AI privacy/save/card/raster bytes가 untouched인지 다시 비교한다.
2. **소비자·회귀:** public event feedback, Fast Replay/Reduced Motion/Skip, terminal/review, card panels, frontal assets를 CI와 local Godot evidence에 다시 연결한다.
3. **승인 수명주기:** active manifest의 exact SHA와 scope를 archive record에 보존하고 manifest는 이 cleanup commit에서만 제거한다.
4. **동기화·중복:** PR #301은 merged, remote feature branch는 삭제되었으며 이후 작업은 새 baseline에서만 시작한다.
5. **증거 ceiling:** CI/headless PASS를 visible Ten Paces, Human UX, accessibility-user, Android device, release performance PASS로 승격하지 않는다.

현재 cleanup branch는 위 3번을 실제 파일과 lifecycle validator로 닫는 후속 작업이다. archive merge 뒤 `main`을 다시 fresh-read해 manifest 부재와 archive record 보존을 확인한다.
