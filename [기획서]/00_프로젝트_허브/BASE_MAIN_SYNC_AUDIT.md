# Base current main 상세 동기화·프로젝트식 적용 감사

## 2026-09-20 승인된 경량화 적용 — 진행 중

사용자 승인: 현재 대화의 “승인할게”; 앞서 제시한 관련 owner·스킬·검사 동시 교정안 전체. 기준 Project main ed2104d98872c63eac27999830aeae9c15a00bdc. Base는 다시 fetch한 main 23ecad5a3084f97c4e5d1e39a9a6d70d1eeb37ef이며 #883 병합 ebfc6c80을 포함한다. #885의 경험→효과·시각·UI 명세는 해당 기능 작업에만 조건부 참조한다. 이 SHA는 관측·재현 증거이며 영구 current authority가 아니다. v9.4.4 release lock bytes는 보존한다.

PLAN→BUILD→REVIEW / Skill: project operating audit, simplifying-skill-bodies, reference-freshness, verification-before-completion / mode: reconcile-legacy + validate-disclosure. 승인 후 순서: 기존 지침 반례 RED → 활성 owner와 로컬 Skill 교정 → 같은 소비처 검사 GREEN → generated view 재생성·검사 → 동일 계약 전체검토2회 → exact-head CI·정상 PR 병합·main readback. 새 게임 구현은 제외한다.

범위: AGENTS·양쪽 START_HERE·통합 실행 계약·Base version/audit·프로젝트4개 Skill·adapter/generated views·직접 연결된 current JSON/테스트/CI. 보호: data/src/scenes/assets/addons/project.godot, 엔진·저장·게임 의미·승인 자산, 기본 checkout의45개 변경, PR342 제품 delta, 설치 플러그인·전역 설정. PR199의 유효한 Human 검증 연결과 PR200의 이미 채택된 v9.4.4 delta를 비교하되 오래된 base/Notion 지시를 되살리지 않는다.

CURRENT_SOURCE_RELEVANCE_CHECK: 직접 읽은 Base #883/main owner 및 실제 프로젝트 소비처를 재사용한다. 신규 게임 설계가 아니므로 무관한10게임 사례 추가는 NOT_APPLICABLE. 비교: 문구만 수정(REJECT: 검사/라우팅 drift 유지), owner+consumer 함께 정비(ADOPT), Base 전체 이식(REJECT: 제품·도구 범위 확대). FEASIBLE: 기존 JSON adapter, generator, Python 검증과 격리 Git 작업 사용. 외부 비용·플러그인 설치 없음.

적용: UNIFIED_WORK_EXECUTION, 승인 재사용, 조건부 상세 로드·인계·Godot 검사, 국소 source blocker, 유효 benchmark 재사용. 고정10게임 gate는 역사로 보존하고 새 판단에 필요한 비교를 수행한다. 검토2회는 같은 후보 계보에서 공유한다. 생성 라우터 bytes는 Base 생성기를 유지하며 프로젝트 복구 예외는 AGENTS owner가 소유한다.

검증 기준: 읽기 순서 일치, 같은 승인 재개/문서 작업/실제 Godot/근거 미확인 시나리오의 필요한 참조 발견, 과거 필수 인계·고정10게임 active 전파 제거, 역사 증거 보존, protected diff0, 테스트/CI 통과. 문서 검증을 Godot/Human/device/release PASS로 주장하지 않는다. 실행 결과는 아래에 누적한다.

### 실행·검토 기록 (동일 승인 계약)

- 사용자 추가 승인: Base #885 재미 검증 생명주기를 기존 통합 계약 §6.1 및 기획/UX/QA 스킬에 연결했다. 공개 거리·해결 이력으로 다음 선택을 바꾸는 가설과 반례, 판정 엔진/전투 preview/action dock의 실제 파일을 연결한다. 인간 재미·최종 자산·기기·출시 증거는 이번 작업 범위가 아니다.
- RED: 최초 경량화 회귀6개 중5실패/1오류로 구형 인계·quota·연결 누락을 확인했다. 추가 재미/고정quota 재도입 반례2개도 교정 전 실패했다. GREEN: 새 계약 회귀10개 및 비런타임 Python 회귀484개 통과. 프로젝트 운영·참조 freshness·스킬 무결성·work governance·Base23ecad5 승인계약 validator PASS. generated views는 공식 생성기로 재생성, adapter LF bytes 일치. protected path diff0.
- 확대 discover는 임포트 준비 없는 격리 폴더에서 native Godot 테스트를 함께 실행하여 지연/실패했고 task-owned 실행만 중단했다. 이 실행은 PASS가 아니다. 후속484개는 native runtime 모듈2개를 제외한 문서/정책/정적 회귀이며 Godot·Human PASS로 사용하지 않는다. Windows 출력 인코딩 오류는 이번 검사 프로세스 UTF-8로 재실행했고 전역 설정은 바꾸지 않았다.
- 전체 독립 검토1/2: P0/P1 없음, P2 3건(START_HERE 강제 인계, 새 Decision에 옛 PR287 증거 귀속, 문서-only 변경에서 새 회귀 제외)을 발견·교정했다. 시작 문서 전체 블록을 교체하고 역사7필드를 분리했으며 새 회귀는 항상 실행되는 governance 단계로 옮겼다. 관련 반례를 추가했다. 플랫폼·복구 보호 문구는 유지하고 예전 제목에 의존한 검사만 새 위치로 교정했다.
- 전체 독립 검토2/2 완료: P0/P1 없음. P2 2건(본문과 다른 PowerShell YAML, current benchmark gate가 옛 Decision을 가리킴)을 발견했고 두 owner·연계 검사의 effective 값과 회귀를 교정했다. 이후는 결함별 readback/검사로 종료하며 전체 회차를 초기화하지 않는다. exact-head 원격 검사·main readback은 후속 확인한다.
- PR199 유효 delta(Human/device packet 라우팅/준비≠PASS)는 양쪽 시작 문서와 AGENTS에 반영했다. PR200 v9.4.4 채택은 이미 main에 존재한다. 두 역사 draft는 원본을 보존하며 이번 PR에서 대체 의미를 기록한다. PR342 제품·저장·모션 작업은 이 운영 변경에 흡수하지 않는다.

## 1. 이전 2026-09-01 기준과 범위

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
