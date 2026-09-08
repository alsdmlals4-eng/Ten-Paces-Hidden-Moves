# 전투 피드백 실제 캡처 · 2026-09-09

분류: **MACHINE_RUNTIME_CAPTURE / SEEDED_FIXTURE**, 최종 UI·Human 승인 아님.
이7장은 supplemental 진단이다. 사전 freshness receipt를 사용한 최소 정본2장은 `docs/evidence/RUNTIME_VISUAL_CAPTURE_MANIFEST.json`의 `TEN-RVC-20260909-001/002`에 별도로 등록했다. 이7장에 사전receipt 통과를 소급 주장하지 않는다.
제품 기준: `6dded6f133e29a7deadfb3a623f23390439f1d4a`.
실제 `combat_board_preview.tscn`, `VerticalSliceMetricsCombatResolutionEngine`과 현재 승인 자산을 사용했다.
이미지 합성·그림 재생성·리사이즈·문구 덮어씌우기를 하지 않은 원본 viewport PNG다.

## 환경과 재현

- Windows, Godot 4.7.1 stable a13da4feb, Compatibility OpenGL, RTX3050.
- 논리 viewport1440×900 / 캡처1280×800. exact worktree editor28492와 고유 QA scene을 대조했다.
- 처음 두 캡처 game6796, 이후 game22980. 다른 프로젝트·다른 실행 게임에는 입력하지 않았다.
- 재현용 원문은 `capture_fixture.gd.txt`다. 격리 checkout의 ignored QA 폴더에 .gd로 놓고, Node인 `NativeFeedbackReview`에 이 script를 붙인 .tscn을 실행한다. runtime consumer/저장 형식은 수정하지 않는다.
- 진입 시 Peng을 실제 resolver로 해결한다. 이후 노출된 `qa_purple/qa_clash/qa_evade/qa_win/qa_loss/qa_draw`로 각 fixture를 재생성한다. `qa_snapshot.capture_ready=true`와 사건 사실을 읽은 뒤 viewport를 캡처한다.
- 동작 사례는 mastery10, actor영구능력치 각10, 높은 자원과 인접 위치를 직접 설정한다. 이는 정상 캠페인 성장/해금으로 도달한 증거가 아니다.
- 동일 위력 강공은 적 시작timing1, 플레이어 anchor1로 맞춰 실제timing2에서 합 상쇄한다. 처음 적 timing2로 작성한 잘못된 fixture는 서로 다른 시점에 공격해 합이 없었다. 그 캡처는 완료 집합에서 제외하고 ignored backup에 보존했다. 제품 규칙은 바꾸지 않았다.
- 종료3종은 기존 보드의 유효 체력값을 직접 지정하고 실제 `_finalize_resolved_bundle`을 호출한다. 보상 화면·10전 완주·재개 증거가 아니다.
- run coordinator/store를 생성하지 않으므로 사용자 저장을 읽거나 쓰지 않는다. 캡처 중 음소거 상태에서 cue metadata만 확인했다. 물리 청음은 NOT_RUN.

## 확인한 사실

| 이미지 | 실제 사건·표시 | 제한 |
|---|---|---|
| 01-peng-executed.png | 오호단문도 timing3 execution, 피해28, ultimate band1/release | 준비시점이 아닌 최종 실행 |
| 02-purple-executed.png | 자하신공 timing3 execution, 자가 위치 band0/release, 공격 모션 없음 | 회복의 실제 실행; 첫전조 once는 별도 도메인 누락 |
| 03-clash-verified.png | 강공17 대17, timing2 clash_draw, 피해0, metal_clash | 합 상쇄 사례; 합 승리 전체UX 아님 |
| 04-evade.png | 강공17 대 회피, timing2 defense_outcome=evade, 피해0, evade cue | 기본 회피이며 고유 무공 반격 실행 아님 |
| 05-win.png | 승리 · 결전 종료 / victory | 직접 종료 fixture |
| 06-loss.png | 패배 · 결전 종료 / defeat | 직접 종료 fixture |
| 07-draw.png | 무승부 · 결전 종료 / draw | 직접 종료 fixture |

## 실제 보이는 잔여 문제

전투/인물 영역이 작고, 해결 중 하단 계획을 숨긴 자리에 큰 검은 빈 공간이 남는다.
연출·카드·결과 문구와 VFX가 같은 중앙 영역에 겹친다. 캡처 분석의 edge/possible_clipping 신호도 보존한다.
따라서 이 집합은 **연출 사건 연결의 실제 확인**이며 승인 아틀라스 fidelity·가독성·완성된 플레이 화면 PASS가 아니다.
화면 배치·글자 위계·연출 상태별 영역 전환은 후속 구현에서 실제 셸/해상도와 함께 교정해야 한다.

## SHA-256

```text
F55D2735A1AEDC780909098008BFFF5FB9CC3EBEA5FA84B97CD4D81E0C4CD7A8  01-peng-executed.png
9BA9894AB5B346B2C06BDF6D2A9A4D93F38975AAE207FC7D65476B3C70954F3D  02-purple-executed.png
774C4F6E52371CB607187FC9A965C56FB08B1E6B8907BBCA119E335F84B83B02  03-clash-verified.png
C687EBE5D4ADFF533012562DCA8247F8B3B70C2F04D62E5FE4AD298B414A90C6  04-evade.png
E454B73BF6159BDDBCEDF4E736D001DA982A3A0C020E15717955CAF65F165E20  05-win.png
5250624F964115017C3CD5E16020F6A30D9A3C9600A6255D969F9EC7186401E0  06-loss.png
A40519E7773F56A29889F4DD500C1DD9DB956BD6C91BD149A02963C6232F26A5  07-draw.png
```
