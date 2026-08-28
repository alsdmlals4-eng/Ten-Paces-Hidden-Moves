# Issue #258 Phase 2 전투 정본 정합 실행 보고서

```yaml
issue: 258
baseline_main: 23277192175100fc784bb5c4010bbac7e9480388
branch: codex/issue-258-phase2-combat-canon
work_mode: BUILD
skill_mode: CODEX_GODOT_PRODUCT_IMPLEMENTATION_HANDOFF + combat UX/accessibility + verification
status: BRANCH_VALIDATION_PENDING
notion_mutation: NOT_PERFORMED_UNTIL_SAFE_MERGE_AND_MAIN_READBACK
```

## 수행과 결과

- 공개 시작 state를 내부 `4/6`, 플레이어-facing `거리 2`로 통일했다.
- 기초 행동 10종, 구조화 사거리/피해 공식, 오능력치 baseline, 명상 `+1/+1`, 강공 내력2, 장풍과 관찰을 구현·회귀화했다.
- 공개 state만 읽는 AI에 장풍 후보를 추가하고 플레이어 전용 관찰은 후보에서 배제했다.
- 실행 CTA를 `행동계획 실행`으로 통일하고 판정/복기 중 편집 불가 경계를 유지했다.
- 첫 패배의 Review → 동일 시드 1회 재시도 → 승리 1회 커밋 또는 두 번째 패배 Main 종료를 도메인으로 추가했다.

## 검증 증거

- JSON 및 focused Python/GDScript 회귀: PASS.
- Godot editor parse/headless focused scripts: PASS.
- Windows visible mouse/keyboard/gamepad, Human Player Experience, 접근성 사용자, Android 실기기, Release 성능: `NOT_RUN`.

## Incident / Solution / Lesson

**Incident:** Godot headless editor scan이 기존 자산·addon `.import`의 worktree 메타데이터를 갱신해 Issue 범위 밖 변경처럼 보였다.

**Solution:** 내용 diff가 0임을 확인했고 tracked `.import`은 명시적 PR staging에서 제외했으며, untracked visual/planning `.import` 4개를 제거했다.

**Lesson:** Godot headless 검증 뒤에는 asset/import status를 별도 분류하고, 제품 코드 PR에는 명시 path staging만 사용한다.

**Base promotion:** `NO_BASE_PROMOTION` — 이 현상은 이 저장소의 tracked Godot import 정책과 Windows checkout 줄바꿈 상태에 묶인 프로젝트별 운영 문제다.

## 남은 위험과 rollback

- 관찰 공개와 재시도 흐름의 실제 Windows 입력·가독성은 아직 사람 검증이 필요하다.
- rollback은 이 branch/PR의 단일 commit revert로 하며, data·runtime·tests·docs를 함께 되돌린다.
