# Issue #258 Phase 2 전투 정본 정합 실행 보고서

```yaml
issue: 258
baseline_main: 18eea743a941a2669222708917ba4756a6301ef9
branch: codex/issue-258-phase2-combat-canon
work_mode: BUILD
skill_mode: CODEX_GODOT_PRODUCT_IMPLEMENTATION_HANDOFF + combat UX/accessibility + verification
status: IMPLEMENTED_MERGED_PR_261_POSTMERGE_MAIN_READBACK
implementation_pr: 261
implementation_merge_commit: 6baf817b5f86baa3fe7df193832bd4f7bc4b2abf
postmerge_main_readback: 2026-08-29
notion_mutation: SUPERSEDED_BY_REPOSITORY_ONLY_CANONICAL_WORKSPACE
```

## Post-merge closeout

- The isolated implementation merged as PR #261 at `6baf817b5f86baa3fe7df193832bd4f7bc4b2abf`; its required checks reported success.
- The current repository-only workspace records mutable completion/evidence in `[기획서]/00_프로젝트_허브/ACTIVE_CONTEXT.md` and `docs/planning-data/current_user_planning_status.json`. This report preserves the implementation-time branch evidence rather than acting as a live handoff.
- The later repository-only workspace decision retires the original Notion delivery sentence. Notion remains migration/history input only; no current Notion mutation or readback is required.

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

**Incident:** terminal presentation의 기존 재시작 회귀가 과거 `4/7` 시작 타일을 기대하여, #258의 기술 매핑 `4/6`·공개 거리 2 정본과 충돌해 Ubuntu Godot headless가 실패했다.

**Solution:** 실패를 먼저 로컬 Godot headless에서 재현한 뒤, 런타임의 `4/6` 초기화는 유지하고 회귀 기대값만 public 거리 2에 맞게 수정했다.

**Lesson:** 공개 거리 변경은 초기 전투뿐 아니라 terminal restart·retry 등 초기 state를 복원하는 모든 소비자 회귀에서 함께 검증한다.

**Incident:** 준비 후 속공 회귀가 #258 이전의 속공 기본 피해 6에 준비 보너스 2를 더한 8을 기대하여, 새 기본 피해 5 기준의 실제 결과 7과 달라 Ubuntu Godot headless가 실패했다.

**Solution:** 준비 보너스 `+2` 동작은 유지하고, 회귀 기대값만 #258의 기본 행동 재가격에 맞춘 7로 갱신했다.

**Lesson:** 기본 행동 수치 변경은 해당 행동을 간접적으로 사용하는 legacy 상태·보너스 회귀의 절대값도 함께 audit한다.

**Incident:** action view model·기초 행동 패널 회귀가 #258 전의 기초 행동 8종을 고정 기대하여, 정본상 10종을 제공하는 UI 소비자에서 assertion이 실패했다.

**Solution:** UI 동작은 변경하지 않고, 회귀의 기초 행동 수와 ID 순서 기대값을 10종 정본으로 갱신했다.

**Lesson:** 콘텐츠 개수 변경은 data contract뿐 아니라 UI view-model의 legacy smoke expectation까지 consumer inventory에 포함한다.

**Incident:** 5결투 completion 회귀가 세 번째 패배 뒤 곧바로 Result/보상으로 진행한다고 가정하여, #258의 Review → 1회 무료 재도전 경계에서 duel history를 읽기 전에 비어 있는 배열에 접근했다.

**Solution:** 동일 회귀에 첫 패배의 `FAILURE_RETRY` 및 같은 전투 재시도 승리 흐름을 넣고, 승리 시에만 duel history가 정확히 한 번 기록되는 것을 검증하도록 수정했다.

**Lesson:** 실패 흐름의 새 중간 화면은 completion 시나리오처럼 기존 happy-path를 재사용하는 종단 간 회귀에도 명시적으로 모델링해야 한다.

**Incident:** base 전투 엔진의 잠긴 관찰 계획 보정이 실제 `TenManualCombatResolutionEngine` override와 TenManual 전투판의 교체된 engine 초기화 경로까지 닿지 않아, 복합 행동 유형이 단일 카테고리로 축약되고 planning 시작 잠금도 base-only 상태가 되었다. 이 consumer drift는 protected approval manifest의 감지 경로와도 불일치를 만들었다.

**Solution:** TenManual override에 동일한 `action_types` 보존을 추가하고, TenManual engine 생성 직후 planning bundle을 잠갔다. 관찰 UI는 누적 공개 기록을 앞→뒤로 표시하며, approval manifest에는 실제 보호 consumer 두 경로를 정확히 추가했다. base·Prepare·TenManual·VerticalSliceMetrics와 실제 전투판 2회 관찰 회귀를 실행했다.

**Lesson:** protected runtime 규칙을 base class에 추가할 때는 실제 subclass override·engine 교체 scene·vertical consumer를 함께 inventory하고, approval manifest는 exact protected diff와 동기화해야 한다.

**Base promotion:** `NO_BASE_PROMOTION` — 이번 정합성은 기존 Base lifecycle을 프로젝트 PR에 적용한 것이며, Base policy 또는 validator 변경을 요구하는 재사용 가능한 결함은 확인되지 않았다.

## 남은 위험과 rollback

- preview 명상 회복은 이제 실행과 동일하게 카드 `restore`를 사용하며, 적 계획은 각 planning 묶음 시작에 public-AI/fixture로 한 번만 고정한다. 관찰과 해결은 이 저장 계획을 같이 소비하고, 복합 행동 유형과 누적 공개 기록은 앞→뒤 순서를 보존한다. 관찰 UI payload에는 행동 유형만 기록하며, 기술명·ID·타이밍·대상·피해·AI 사유/시드는 포함하지 않는다.
- 관찰 공개와 재시도 흐름의 실제 Windows 입력·가독성은 `NOT_RUN`이다. 사용자는 2026-08-29 현재 단계의 사람 플레이 검수를 명시적으로 보류했으며, 이 보류는 Human PASS 주장이 아니다.
- rollback은 이 branch/PR의 단일 commit revert로 하며, data·runtime·tests·docs를 함께 되돌린다.
