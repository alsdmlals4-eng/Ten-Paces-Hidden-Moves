# Base current main 상세 동기화·프로젝트식 적용 감사

## 1. 기준과 범위

| 항목 | 확인한 값 | 역할 |
|---|---|---|
| Project baseline | `main@4032cf550295da6d55646a8fb64fb27acaf1ddc3` | 이번 작업 전 exact project truth |
| Base compatibility release | `v9.4.4@5adc196c0185951f50e49ab5e51586eff8d60886` | 재현 가능한 adapter/registry pin |
| Base current main observed | `19355b7ef065a21d0f2b685c7d9be64a4a3970f8` | 2026-09-01 fresh-read 관측; permanent pin 아님 |
| current-task branch | `codex/base-current-adapter-reconciliation-20260901` | latest Project main에서 분리한 작업공간 |
| pre-existing workstreams | PR #200, PR #305 및 기존 `.worktrees/` | read-only·보존 |

이 작업은 **운영 구조·작업순서·계약 갱신만** 다룬다. `data/`, `src/`, `scenes/`, `assets/`, `addons/`, `project.godot`, 전투 규칙, 저장 의미, AI 정보 경계, 승인된 Visual, 실제 Godot runtime을 변경하지 않는다.

Base v9.4.4 호환 pin은 current main 전체를 자동으로 채택한다는 뜻이 아니다. 매 fresh-read에서 current Base owner를 읽고, 아래처럼 십보강호의 repository-first 정본과 실제 소비처에 맞는 부분만 반영한다.

## 2. current-source relevance와 reuse 판단

이번 요청은 player-facing 시스템/화면/자산을 새로 설계하지 않는 L1 operating-contract package다. 따라서 무관한 게임 10종을 새로 조사하지 않고, Base current work-contract 사례와 정확한 프로젝트 entrypoint·consumer를 `REUSED_EVIDENCE`로 대조했다. 반대로 이후 전투·UI·카드·연출·Visual package는 프로젝트의 `TEN-DEC-20260830-PREWORK-BENCHMARK-REVERSE-ENGINEERING-GATE-01`에 따라 10개 이상의 동종·인접 게임 역공학을 계속 요구한다.

정식 receipt: `docs/operations/2026-09-01_BASE_CURRENT_ADAPTER_WORK_CONTRACT_RECEIPT.json`.

## 3. Base delta별 프로젝트 판정

| Base current change | 판정 | 십보강호 적용 | 적용하지 않는 것 |
|---|---|---|---|
| v9.4.4 reuse-first (`210ec782`, `5adc196c`) | `ADOPT` | Base pin·registry·reuse-first/learning handoff를 canonical adapter와 regression에 연결 | Base Skill 본문 복사·자동 Base 승격 |
| 기능별 code/contract (`56dce2ac`) | `ADAPT` | 새/변경 feature는 owner·contract·consumer·test를 같은 package로 추적 | 현 전투 코어 일괄 리팩터링 |
| 조건부 Blueprint/wireframe (`a54966fc`) | `ADAPT` | player-facing 연결 시스템의 이해/구현 위험에만 trigger | 이번 문서 작업용 장식 wireframe |
| bounded runtime capture (`19fb7b43`, `5f22096c`) | `REUSE_EXISTING` | 기존 project runtime visual evidence/manifest owner를 계속 소비 | 화면 변화 없는 문서 작업의 새 Godot capture |
| benchmark-first soft-coded intake (`781dfe8f`) | `ADAPT` | repository-owned receipt와 기존 10-game gate를 분리 유지 | 운영 문서 변경에 무관한 게임 사례 채우기 |
| receipt·hygiene·stale audit (`d060ffab`) | `ADOPT` | exact Base validator receipt, scoped inventory, no-name/no-age deletion | broad cleanup·unverified legacy/worktree 삭제 |
| final active-surface verification (`19355b7e`) | `ADAPT` | active README/entrypoint/Base routing의 stale Notion·v9.4.3 wording을 최소 교정 | historical evidence·old PR을 지우기 |

## 4. 갱신한 프로젝트 구조와 작업 순서

```text
latest user instruction
→ Project AGENTS + Project current canon/implementation/open workstreams
→ latest Base main + adopted release compatibility check
→ repository-owned benchmark/reuse receipt + scoped hygiene inventory
→ current owner conflict/stale entrypoint correction
→ approval-bound work sequence and feature contract
→ implementation with actual consumer/test/capture when applicable
→ exact-head verification + 5 adversarial loops
→ project-only learning handoff / Base promotion only on repeated evidence
```

프로젝트의 current authority는 계속 repository다. Notion과 Google Sheets는 고유 미이관 자료가 실제로 확인될 때만 migration/history source로 읽는다. 게임 코어·카드 semantics·전투 화면·Visual direction은 Base가 아닌 해당 project Decision/owner가 소유한다.

## 5. 추가·개선·폐기 판단

| 분류 | 현재 상태 | 요청 이유 | 기대효과 |
|---|---|---|---|
| 추가 | 작업 시작 근거가 여러 문서·대화에 흩어질 수 있었다 | repository-owned receipt를 Base validator로 검사 | 새 세션에서도 무엇을 읽고 어떤 범위에서 재사용했는지 재현 가능 |
| 개선 | Base release pin은 있었지만 current-main 후속 규칙과 project adaptation 경계가 명시적이지 않았다 | `ADOPT / ADAPT / REJECT` audit와 thin adapter 추가 | Base를 따르되 십보강호 고유 코어가 평탄화되지 않음 |
| 개선 | 구형 Notion current-authority 표현이 README/문서 지도에 남아 있었다 | repository-first current route와 일치시킴 | 새 작업자가 잘못된 정본으로 시작할 위험 감소 |
| 폐기 | v9.4.3만을 current pin으로 가정하는 test/workflow | v9.4.4 reuse-first test가 동등·확장 successor | obsolete current-version false failure 제거, Git history로 회복 가능 |
| 보류 | 기존 worktree·open PR·historical audit 대량 삭제 | active consumer/owner를 이번 scope에서 완전히 증명하지 못함 | 다른 작업의 복구·검토 evidence 보존 |
| 보류 | 신규 wireframe·runtime capture·Godot implementation | 이번 변경에 player-facing consumer/화면 변경이 없음 | 증거와 작업량을 실제 변화에만 연결 |

## 6. 검증·증거 ceiling

- Base release lock, project adapter schema, generated views, work receipt validator, project operating-system validator, focused regression, reference freshness, and exact-head CI are required.
- 이 작업의 static/CI PASS는 운영 계약의 정합성만 증명한다.
- Windows visible Godot, Android device, accessibility user, Human/player experience, release performance는 **이번 범위에서 실행하지 않았고 PASS가 아니다**.

## 7. 정리·복구 경계

`tests/test_base_v943_first_prompt_adoption.py`와 대응 workflow만 v9.4.4 successor가 coverage를 제공하고 `tests/`·`.github/`의 active executable reference가 0임을 확인한 뒤 제거한다. 그 외 구형 문서·worktree·PR·asset·cache는 이름이나 날짜가 아니라 consumer/readback/rollback evidence가 확인될 때까지 보존한다. 모든 이번 변경은 dedicated branch commit을 revert하여 복구할 수 있다.
