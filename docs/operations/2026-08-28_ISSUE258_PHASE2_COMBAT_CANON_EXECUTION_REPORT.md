# Issue #258 Phase 2 전투 정본 정합 실행 보고서

```yaml
issue: 258
baseline_main: 18eea743a941a2669222708917ba4756a6301ef9
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

**Incident:** Issue #258의 manifest가 PR base `18eea743…`을 보호 기준으로 사용하도록 Base lifecycle을 활성화했지만, 기존 Adapter baseline은 과거 `d9ae822…`를 유지해 exact-head validator가 같은 실행에서 서로 다른 기준 SHA를 요구했다.

**Solution:** 사용자가 명시 승인한 required governance reconciliation으로 Adapter의 `protected_baseline.commit`을 PR base `18eea743a941a2669222708917ba4756a6301ef9`로 갱신하고, 고정 Base validator(`2828a74…`)가 생성한 네 파생 뷰를 재생성·readback했다. manifest의 `approved_paths`는 제품 보호 경로 15개만 유지하며 Adapter 자체는 포함하지 않는다.

**Lesson:** 새 one-time protected approval manifest가 PR에 추가되는 경우, Adapter baseline·manifest protected base·workflow-selected PR base의 세 SHA를 exact-head CI 전에 함께 대조해야 한다.

**Incident:** 구조화 `range`·`damage_formula`가 없는 기존 절초를 빈 Dictionary fallback으로 해석하면서, #258 공용 resolution path에서 절초 사거리와 피해가 각각 0으로 계산되어 Ubuntu Godot headless 회귀가 실패했다.

**Solution:** 구조화 필드는 key 존재 여부를 먼저 확인하고, 없으면 기존 절초의 `range_text`·`damage`/`attack_power_coefficient` 경로를 사용하도록 최소 수정했다. `[밀착]` 거리0의 기존 공격 가능성도 보존하고, 절초 회귀의 기본 행동 기대값은 #258 정본 피해 공식에 맞췄다.

**Lesson:** 공용 구조화 데이터 migration에서는 선택 필드의 default container와 실제 필드 존재를 구분하는 legacy-consumer regression을 함께 유지한다.

**Base promotion:** `NO_BASE_PROMOTION` — 이번 정합성은 기존 Base lifecycle을 프로젝트 PR에 적용한 것이며, Base policy 또는 validator 변경을 요구하는 재사용 가능한 결함은 확인되지 않았다.

## 남은 위험과 rollback

- 관찰 공개와 재시도 흐름의 실제 Windows 입력·가독성은 아직 사람 검증이 필요하다.
- rollback은 이 branch/PR의 단일 commit revert로 하며, data·runtime·tests·docs를 함께 되돌린다.
