# Base current adapter · work-contract reconciliation execution report

## 기준 SHA · Work Mode · Skill · 범위

| 항목 | 값 |
| --- | --- |
| 기준 project `origin/main` | `4032cf550295da6d55646a8fb64fb27acaf1ddc3` |
| 관측한 Base `origin/main` | `19355b7ef065a21d0f2b685c7d9be64a4a3970f8` |
| 채택한 Base release | v9.4.4 (`210ec78292fa12ed7563ba743b322dd36103ae4a`), evidence `bb61e68dc3028421b60c11b87ba2abd297ee6f78`, finalization `5adc196c0185951f50e49ab5e51586eff8d60886` |
| Work Mode | `PLAN → BUILD → REVIEW` |
| 적용 Skill / Mode | `managing-project-intake-and-work-contract` / intake-and-contract, `managing-game-project-operating-system` / reconcile, `auditing-canonical-reference-freshness` / reference-freshness, `governing-legacy-retention-and-archives` / hygiene, `reviewing-and-validating-project-changes` / contract-check + static-validation + regression, `running-adversarial-review-and-refinement` / attack → validate-critique → regression-recheck |
| 승인 범위 | 최신 Base를 상세 fresh-read한 뒤, 십보강호에 맞춘 작업 순서·구조·계약 갱신. 게임 규칙·저장·UI·자산 의미 변경은 포함하지 않음. |
| 보호한 제품 경로 | `data/`, `src/`, `scenes/`, `assets/`, `addons/`, `project.godot` — 변경 0건 |
| receipt | `docs/operations/2026-09-01_BASE_CURRENT_ADAPTER_WORK_CONTRACT_RECEIPT.json` |

## 작업 전 문제

1. 프로젝트의 Base adapter와 생성 파생본은 v9.4.3 current-pin/first-prompt 모델을 계속 설명했으며, v9.4.4의 reuse-first receipt·scoped hygiene·조건부 Blueprint/capture 경계가 현재 작업 진입점에 없었다.
2. 일부 repository entrypoint에 historical Notion 또는 오래된 Base wording이 남아 repository-first current authority와 혼동될 여지가 있었다.
3. v9.4.3 only test/workflow는 새로운 v9.4.4 successor와 중복될 수 있었지만, 이름·날짜만으로는 삭제할 수 없었다.

## 조사·비교 결과과 채택 구조

### Base current delta의 프로젝트별 판정

| Base current 변화 | 판정 | 프로젝트 적용 |
| --- | --- | --- |
| feature-level contract / explicit feasibility | `ADOPT` | L1+ 작업에서 product owner, consumer, protected path, FEASIBLE/PARTIAL/BLOCKED를 receipt로 기록 |
| conditional Blueprint / wireframe | `ADAPT` | 실제 player-facing consumer가 바뀌는 기능에만 적용; 운영 계약만의 변경에는 생성하지 않음 |
| bounded runtime visual capture | `REUSE_EXISTING` | 화면/자산 소비처가 바뀔 때만 capture manifest를 재사용; 이번 변경은 `NOT_RUN_NOT_APPLICABLE` |
| benchmark-first intake | `ADAPT` | 게임·UX decision에는 project의 10-game packet을 유지; Base 운영계약 갱신 자체에는 Base/project actual source comparison receipt를 사용 |
| receipt, context/configuration hygiene | `ADOPT` | repository-owned receipt와 narrow inventory 도입, 무차별 파일 정리 금지 |
| active-surface verification | `ADOPT` | README, hub START_HERE, adapter-generated view, test, workflow까지 현재 pin 전파 확인 |

### 비교한 실질 대안

| 대안 | 판정 | 이유 |
| --- | --- | --- |
| Base 전체 문서·Skill을 프로젝트 안에 복사 | `REJECT` | shared owner의 update/validator와 분리되고, 십보강호의 repository-first·local skill 구조를 중복시킴 |
| v9.4.3를 계속 current pin으로 고정 | `REJECT` | current Base release의 receipt/hygiene·reuse-first 안전장치를 받지 못함 |
| release SHA만 바꾸고 current Base `main` 관측·consumer 검사를 생략 | `REJECT` | active entrypoint·generator·workflow에서 pin drift가 남을 수 있음 |
| v9.4.4 thin adapter + current-main audit + generated view + successor regression | `ADOPT` | 프로젝트 코어를 그대로 보존하면서 Base 변화 중 실제 trigger가 있는 안전장치만 소비함 |

## 실제 반영 결과

- canonical adapter `skills/PROJECT_BASE_ADAPTER.json`을 v9.4.4 release/finalization/registry hash로 갱신하고, `reuse_first_governance`와 project-specific `current_work_contract_governance`를 추가했다.
- Base builder로 `BASE_V9_ADAPTER.json`, `PROJECT_BASE_SKILL_ADAPTER.json`, `PROJECT_SKILL_SNAPSHOT.json`, `PROJECT_OPERATING_DASHBOARD.html`을 다시 생성해 canonical adapter와 일치시켰다.
- `BASE_RULES_VERSION`, total planning instruction, README, Documentation Map, hub START_HERE/ACTIVE_CONTEXT/development gate/base audit/verification을 repository-first thin adaptation으로 동기화했다.
- v9.4.4 current-pin 회귀와 current work-contract 회귀를 추가했고, existing workflow/test가 current Base `19355b7…`을 검사하도록 업데이트했다.
- v9.4.3 only test/workflow는 successor coverage와 active executable reference 0을 확인한 뒤에만 제거했다. 기존 worktree와 PR #200/#305는 `UNKNOWN_UNVERIFIED`/read-only로 유지했다.

## 현재 상태 → 요청 이유 → 기대효과

| 구분 | 현재 상태 | 요청 이유 | 기대효과 |
| --- | --- | --- | --- |
| 작업 진입 | Base release/current observation/reuse receipt가 한 adapter에서 분리되어 명시됨 | fresh-read마다 구현과 과거 계약을 혼동하지 않기 위함 | 다음 작업이 actual project owner → current Base delta → project-specific receipt 순서로 진입 |
| 구조 | Base shared skill을 복사하지 않고 exact pin + generated adapter를 사용 | Base를 따르되 프로젝트에 맞춰 변형하라는 요구 | Base 업데이트 가능성과 project local skill/게임 코어의 독립성을 동시에 보존 |
| 계약 | consumer/feasibility/cleanup/conditional capture trigger가 명문화됨 | 문서-only 갱신이 제품 기능이나 불필요한 시안 생성으로 번지지 않게 하기 위함 | 실제 feature/UI work에서만 Blueprint, capture, 10-game preflight가 작동 |
| 회귀 | current pin workflow와 test가 동일한 Base SHA를 검사 | workflow가 최신 pin인데 회귀가 옛 SHA를 기대하는 false failure 제거 | pin drift를 CI에서 fail-closed로 탐지 |
| 폐기 | v9.4.3 only pair만 git-recoverable removal | 구형 파일 용량/혼선을 줄이되 복구 증거를 보존 | 중복 검사 없이 v9.4.4 successor만 유지, unrelated worktree/PR은 안전 보존 |

## 검토 mode · 5회 전체 개선 loop

각 회차는 범위·정본/consumer·코어 보호·동시성/PR·생성물·CI 비용·복구·장기 적합성·evidence ceiling을 함께 재공격했다. 렌즈 하나를 loop로 세지 않았으며, 유효한 finding만 최소 수정했다.

| loop | 공격 및 검증 | 검증된 finding / 처리 | 재검사 결과 |
| --- | --- | --- | --- |
| 1 | current Base release, project owner, actual diff, protected product paths를 비교 | workflow가 current Base `19355b7…`을 pin하지만 두 regression이 old pin을 기대한 `MUST_FIX` | 두 test expectation을 current pin으로 최소 변경, 3개 workflow-adapter regression PASS |
| 2 | README/hub/registry-required headings와 project operating checker를 재공격 | learning-log heading 변경이 existing checker의 required section token을 끊은 `MUST_FIX` | required historical substring을 보존하는 heading으로 교정, `check_project_operating_system.py` PASS |
| 3 | canonical adapter와 generator-derived artifacts/registry hash를 비교 | `DERIVATIVE_STALE` 가능성 제기; builder로 재생성 후 실제 check 필요 | builder `--check`, Base project operating contract, receipt validator 모두 PASS; 추가 finding 없음 |
| 4 | deletion candidate, active executable consumer, unrelated worktree/PR 및 rollback을 재공격 | v9.4.3 pair 외 broad cleanup은 evidence 부족으로 `BLOCKED_UNVERIFIED`; pair만 successor/zero-reference를 충족 | v9.4.4 successor test/workflow 유지, v9.4.3 pair 제거; archive governance와 reference freshness PASS |
| 5 | full regression, baseline/candidate counterfactual, current `main` 재현 및 core/visual scope를 재공격 | 전체 suite의 2 failures는 candidate와 untouched `main@4032cf5` 모두에서 재현하는 pre-existing failure | 이번 scope의 acceptance를 막지 않는 `DEFER`로 분리; product files/status를 몰래 수정하지 않음 |

### Finding disposition

- `MUST_FIX` 완료: current Base workflow pin과 regression expectation 불일치, required document heading token 불일치.
- `DEFER` (pre-existing baseline):
  1. `test_action_card_source_unification_contract...test_common_card_renderer_exposes_category_effect_and_assistive_description` — test가 inline expression을 기대하지만 renderer는 `_range_fact_text()` helper로 이미 동작을 소유한다.
  2. `test_pc_first_vertical_slice_implementation_gate...test_current_user_status_preserves_pc_slice_history_and_current_visual_readback` — expected legacy visual status string과 current user-planning status가 다르다.

  두 failure는 product main `4032cf550295da6d55646a8fb64fb27acaf1ddc3`에서 동일하게 재현했다. 이 운영계약 작업은 `src/`와 current visual status owner를 변경하지 않았으므로, 별도 product/test reconciliation package에서 source-of-truth를 선택해야 한다.
- `ALLOWED_LEGACY`: historical Base / r5.4 references and the hub compatibility registry. Current authority는 root `skills/SKILL_REGISTRY.json`과 v9.4.4 adapter이며 legacy facts are retained only as compatibility evidence.
- `BLOCKED_UNVERIFIED`: unrelated old worktrees and pre-existing PR #200/#305의 cleanup/takeover. 삭제·수정하지 않았다.

## 검증 증거

| 검증 | 결과 |
| --- | --- |
| Base work-contract receipt validator | `WORK CONTRACT RECEIPT: PASS` |
| Base generated-artifact builder (`--check`) | current |
| Base project operating contract checker | PASS |
| project operating system | PASS |
| canonical reference freshness | PASS |
| skill package integrity | PASS |
| archive governance | PASS |
| `tests.test_project_governance` | 13/13 PASS |
| v9.4.4/current-contract focused Base regressions | 26/26 PASS |
| current Base workflow pin regressions | 3/3 PASS |
| full Python suite | 438/440 PASS; above two unchanged baseline failures are `DEFER` |
| `git diff --check` | PASS |
| protected product-path diff | 0 files |
| runtime / renderer / device / accessibility / human UX | `NOT_RUN_NOT_APPLICABLE_TO_OPERATING_CONTRACT_ONLY_CHANGE`; no player-facing runtime consumer changed |

## 자동화·학습 반영

- 다음 L1+ 작업은 `PROJECT_BASE_ADAPTER.json`의 current route와 receipt를 통해 reuse-first preflight, scoped hygiene, feature-contract, conditional Blueprint/capture 조건을 먼저 판정한다.
- actual player-facing feature/UX/content change에만 프로젝트의 10-game benchmark packet과 renderer capture evidence를 요구한다. 단순 운영계약 갱신에 새 게임 benchmark나 장식용 wireframe을 만들지 않는다.
- 공용 Base 승격 후보는 없다. 이번 결과는 existing Base v9.4.4 practice의 project-specific adaptation이며, 새 일반화 학습을 주장하지 않는다.

## 남은 위험 · 재개 조건 · CLEAN_REVIEW_EXIT

- 이번 승인 범위의 actionable work는 0이다. product regression two failures는 기준 main에 이미 존재했고 scope 밖이라 current contract changes의 completion claim을 대체하지 않는다.
- PR 생성 뒤에는 exact head의 remote CI를 읽어야 한다. remote CI가 새 failure를 내면 해당 failure를 current head/diff 기준으로 재분류한다.
- PR #200과 #305는 read-only로 보존한다. 이 branch와 동일 goal이라고 해도 takeover/merge/cleanup하지 않는다.
- `CLEAN_REVIEW_EXIT` candidate: five full-scope loops completed, new scope-owned `MUST_FIX` is resolved and rechecked, no protected product path changed, and no new valid omission/conflict/complement gap remains. This is a pre-merge candidate only; post-push exact-head CI remains required.
