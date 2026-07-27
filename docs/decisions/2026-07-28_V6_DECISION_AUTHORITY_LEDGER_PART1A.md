# 십보강호 v6 전체 결정 권한 원장 — Part 1A

- 작성일: 2026-07-28
- 대상 저장소: `alsdmlals4-eng/Ten-Paces-Hidden-Moves`
- 작업 단계: `CONCEPT_APPROVAL`
- Work Mode: `PLAN`
- 실행 프로필: `PLANNING_ONLY_PROFILE`
- 문서 상태: `PR45_INTEGRATED_CANONICAL / PLANNING_ONLY`
- 목적: 지금까지 접근 가능한 사용자 승인·대체·폐기·보류·미정 사항을 단일 권한 원장으로 연결하고 PR #45의 유효 내용을 중복 없이 통합한다.

> 이 문서는 Round 1~3 원장을 최신 사용자 결정으로 교정하고 PR #45를 계획 전용 통합 대상으로 재분류한 정본 후보이다. 전체 절초 설계와 후속 적대적 검토는 `[보류]`이며, 이 문서의 GitHub 반영은 런타임 구현 권한을 부여하지 않는다.

## 2026-07-28 최신 사용자 결정 및 PR #45 통합 요약

- 남은 전체 적대적 검토 라운드는 `[보류]`로 둔다. 현재 확정된 설계와 PR #45 정합화는 `PLAN` 범위에서 GitHub에 반영할 수 있으나 런타임 구현 권한은 계속 금지한다.
- 16권 절초의 개별 이름·효과·슬롯·태그·대응점은 `[보류]`다.
- `[연격 N]`의 N은 공격 총피해를 나누는 실제 피해 횟수다. `10 + [연격 2] → 5/5`, `10 + [연격 3] → 3/3/4`로 처리한다.
- 최종 총피해가 N보다 작으면 0 피해 묶음을 만들지 않고 유효 피해 횟수를 `min(N, 총피해)`로 축소한다. 총피해 0이면 피해 묶음과 적중이 없다.
- `방어`와 `보호막`은 별도 자원이 아니라 하나의 `[방어도]`로 통합한다. 각 피해 묶음은 현재 방어도만큼 개별 감산되며 방어도는 피격으로 소모되지 않고 효과의 지속시간이 끝날 때 제거된다.
- 교착 반복 감소, 슬롯 효과 예산, `PER_DAMAGE_PACKET` 예외는 아래 권장안으로 확정한다.
- PR #45의 BUILD 승인·구형 10전·구형 연격·구형 수련 비용은 대체한다. PR #45의 감사 기록·source-only planning 자료·테스트 도구는 역사·검증 자료로 유지하되 현재 권한 원본으로 중복 지정하지 않는다.

## Round 3 전투 판정 교정 요약

Round 3에서는 새 콘텐츠를 추가하지 않고 전투 판정, 태그 분류, 다중 슬롯, 비용, 연격, 후퇴, 자동 발동의 실행 가능성을 공격했다.

적용한 핵심 교정:

- 지속시간·중첩 선언 의무는 **지속형 상태·예약 효과 인스턴스**에 적용한다. `[전조]`, `[절초]`, `[연격 N]`, `[경공]`, 계통 태그처럼 구조·분류를 나타내는 즉시성 표식에는 지속시간을 요구하지 않는다.
- 다중 슬롯 행동은 첫 점유 슬롯에서 실제 자원을 재검증하고 비용을 지불한다. 부족하면 그 첫 슬롯에서 즉시 `fizzle`하며, 이후 점유 슬롯은 소비된 채 건너뛴다.
- `[연격 N]`은 최종 총피해를 N개 피해 묶음으로 뒤쪽 우선 배분한다. 첫 피해 묶음만 합에 참여하며 합 패배 또는 상쇄면 후속 묶음이 누락된다.
- 기본 회피 1회는 연격 피해 묶음 1개를 회피하고, 방어는 각 피해 묶음에 순서대로 적용한다. 연격은 공격 효과 수를 늘리지 않으므로 중단·일반 자동 발동·위치 후속 효과는 기본적으로 공격 효과당 한 번이다.
- `ON_HIT`과 `ON_HEALTH_DAMAGE`를 분리했다. `[후퇴 N]`은 한 피해 묶음 이상이 회피되지 않고 적중하면, 방어로 체력 피해가 0이어도 공격 효과 종료 후 한 번 발동한다.
- 치명타로 체력이 0이 되면 즉시 전투를 종료한다. 후퇴·밀치기·추격 같은 비필수 후속 이동과 일반 자동 발동은 실행하지 않는다.
- 절초기세 예약 소비는 일반 행동 비용의 예외다. 계획 확정 뒤에는 fizzle을 포함한 실패에도 환불하지 않는다.
- 기초 행동 이름은 `준비`로 유지한다. `강화`는 무공서 핵심 유형이며, `[준비]` 또는 범용 `[강화]` 상태 대신 구체적인 예약 효과 인스턴스를 사용한다.

---

## Round 2 권한 교정 요약

Round 2에서는 새 기능을 추가하지 않고 최신 사용자 지시, v6 계약, Round 1 원장의 상태·권한 표현만 공격했다.

적용한 핵심 교정:

- `5전째 / 10전째`는 핵심 결투 번호가 아니라 **모든 전투의 누적 완료 횟수**로 확정한다.
- 복합 행동의 독립 공격 효과와 `[연격 N]`의 피해 묶음을 분리한다. 독립 공격 효과는 각각 합 후보가 될 수 있지만, 하나의 `[연격 N]` 공격 효과에서는 첫 피해 묶음만 합에 참여한다.
- 최신 결정이 구 결정을 대체한 핵심 행에는 `LATEST_OVERRIDE`를 사용한다.
- GitHub 반영 파일 경로·브랜치 구성처럼 사용자가 직접 확정하지 않은 실행 세부는 `PROPOSED_ONLY`로 낮춘다.
- 저장소 SHA·PR 상태·구현 여부는 설계 결정과 분리되는 `CONFIRMED_FACT / 구현 사실`로 취급해야 한다.
- 최종 GitHub 원장은 v6 형식에 맞춰 근거·영향 책임 원본·적용 빌드·재검토 조건과 주장 유형을 추가해야 한다.

---

## 0. 권한·상태 체계

### 0.1 적용 우선순위

1. 사용자의 최신 명시 지시
2. `VERTICAL_SLICE_MASTER_REFERENCE_v6.md`
3. `VERTICAL_SLICE_EXECUTION_PROMPT_SHORT_v6.md`
4. 프로젝트 운영 규칙·보호 경계
5. 이번 대화에서 새로 승인된 v6 기획 결정
6. 실제 코드·데이터·테스트가 증명하는 현재 구현 사실
7. 과거 기획 문서·PR·Issue
8. 외부 사례·모델 추론

### 0.2 결정 상태

- `CONFIRMED`: 사용자가 승인했으며 현재 유효
- `LATEST_OVERRIDE`: 이전 결정을 최신 사용자 지시가 대체
- `SUPERSEDED`: 과거에는 유효했으나 최신 결정으로 대체
- `REJECTED`: 명시적으로 폐기·금지
- `DEFERRED`: 후속 단계로 연기
- `PROPOSED_ONLY`: 제안되었으나 승인되지 않음
- `UNRESOLVED`: 접근 가능한 자료 안에서 결론이 나지 않음
- `UNVERIFIED_CONTEXT`: 과거 결정이 있었다는 흔적은 있으나 현재 접근 범위에서 원문 검증 불가
- `[보류]`: 사용자 표시용 표식이다. 결정 행에서는 `DEFERRED`, 게이트에서는 `HOLD`로 기록하며 런타임 구현 입력에서 제외한다.

### 0.3 구현 사실 상태

- `IMPLEMENTED`
- `PARTIALLY_IMPLEMENTED`
- `PLANNED`
- `PROPOSED_ONLY`
- `DEFERRED`
- `REMOVED`
- `UNVERIFIED`

## 0.4 연결 프로필

각 결정 행의 `연결 프로필`은 아래 표에 대한 외래키다. 이 방식으로 모든 결정을 주장 유형·근거·영향 책임 원본·적용 빌드·재검토 조건에 연결하면서 같은 문장을 수백 번 복제하지 않는다.

| 프로필 | 주장 유형 | 근거 | 영향 책임 원본 | 적용 빌드·Commit | 재검토 조건 |
|---|---|---|---|---|---|
| `AUTH-C` | DESIGN_DECISION | 현재 대화 최신 사용자 결정 및 v6 프로세스 계약 | [기획서]/00_프로젝트_허브/ACTIVE_CONTEXT.md | PLANNING_ONLY / runtime 미적용 | 상충하는 최신 사용자 결정 또는 플레이테스트 근거 발생 시 |
| `AUTH-L` | DESIGN_DECISION | 현재 대화 최신 사용자 결정 및 v6 프로세스 계약 | [기획서]/00_프로젝트_허브/ACTIVE_CONTEXT.md | PLANNING_ONLY / runtime 미적용 | 상충하는 최신 사용자 결정 또는 플레이테스트 근거 발생 시 |
| `AUTH-S` | DESIGN_DECISION | 현재 대화 최신 사용자 결정 및 v6 프로세스 계약 | [기획서]/00_프로젝트_허브/ACTIVE_CONTEXT.md | PLANNING_ONLY / runtime 미적용 | 사용자의 명시적 최신 재승인 시에만 |
| `AUTO-C` | DESIGN_DECISION | 현재 대화 최신 사용자 결정 및 v6 프로세스 계약 | docs/02_COMBAT_RULES.md | PLANNING_ONLY / runtime 미적용 | 상충하는 최신 사용자 결정 또는 플레이테스트 근거 발생 시 |
| `BAN-C` | DESIGN_DECISION | 현재 대화 최신 사용자 결정 및 v6 프로세스 계약 | docs/06_STARTING_FACTION_MASTERY_DATA.md | PLANNING_ONLY / runtime 미적용 | 상충하는 최신 사용자 결정 또는 플레이테스트 근거 발생 시 |
| `BAN-D` | DESIGN_HYPOTHESIS | 현재 대화 최신 사용자 결정 및 Round 1~3 적대적 검토 | docs/06_STARTING_FACTION_MASTERY_DATA.md | PLANNING_ONLY / runtime 미적용 | 사용자 재개·승인 또는 해당 후속 설계 라운드 |
| `BASIC-C` | DESIGN_DECISION | 현재 대화 최신 사용자 결정 및 v6 프로세스 계약 | docs/02_COMBAT_RULES.md | PLANNING_ONLY / runtime 미적용 | 상충하는 최신 사용자 결정 또는 플레이테스트 근거 발생 시 |
| `BASIC-D` | DESIGN_HYPOTHESIS | 현재 대화 최신 사용자 결정 및 Round 1~3 적대적 검토 | docs/02_COMBAT_RULES.md | PLANNING_ONLY / runtime 미적용 | 사용자 재개·승인 또는 해당 후속 설계 라운드 |
| `BASIC-L` | DESIGN_DECISION | 현재 대화 최신 사용자 결정 및 v6 프로세스 계약 | docs/02_COMBAT_RULES.md | PLANNING_ONLY / runtime 미적용 | 상충하는 최신 사용자 결정 또는 플레이테스트 근거 발생 시 |
| `BASIC-R` | DESIGN_DECISION | 현재 대화 최신 사용자 결정 및 v6 프로세스 계약 | docs/02_COMBAT_RULES.md | PLANNING_ONLY / runtime 미적용 | 사용자의 명시적 최신 재승인 시에만 |
| `BOARD-C` | DESIGN_DECISION | 현재 대화 최신 사용자 결정 및 v6 프로세스 계약 | docs/02_COMBAT_RULES.md | PLANNING_ONLY / runtime 미적용 | 상충하는 최신 사용자 결정 또는 플레이테스트 근거 발생 시 |
| `BOARD-L` | DESIGN_DECISION | 현재 대화 최신 사용자 결정 및 v6 프로세스 계약 | docs/02_COMBAT_RULES.md | PLANNING_ONLY / runtime 미적용 | 상충하는 최신 사용자 결정 또는 플레이테스트 근거 발생 시 |
| `BOARD-R` | DESIGN_DECISION | 현재 대화 최신 사용자 결정 및 v6 프로세스 계약 | docs/02_COMBAT_RULES.md | PLANNING_ONLY / runtime 미적용 | 사용자의 명시적 최신 재승인 시에만 |
| `BUDGET-C` | DESIGN_DECISION | 현재 대화 최신 사용자 결정 및 v6 프로세스 계약 | docs/02_COMBAT_RULES.md | PLANNING_ONLY / runtime 미적용 | 상충하는 최신 사용자 결정 또는 플레이테스트 근거 발생 시 |
| `COMBAT-C` | DESIGN_DECISION | 현재 대화 최신 사용자 결정 및 v6 프로세스 계약 | docs/02_COMBAT_RULES.md | PLANNING_ONLY / runtime 미적용 | 상충하는 최신 사용자 결정 또는 플레이테스트 근거 발생 시 |
| `COMBAT-L` | DESIGN_DECISION | 현재 대화 최신 사용자 결정 및 v6 프로세스 계약 | docs/02_COMBAT_RULES.md | PLANNING_ONLY / runtime 미적용 | 상충하는 최신 사용자 결정 또는 플레이테스트 근거 발생 시 |
| `COMBAT-R` | DESIGN_DECISION | 현재 대화 최신 사용자 결정 및 v6 프로세스 계약 | docs/02_COMBAT_RULES.md | PLANNING_ONLY / runtime 미적용 | 사용자의 명시적 최신 재승인 시에만 |
| `CORE-C` | DESIGN_DECISION | 현재 대화 최신 사용자 결정 및 v6 프로세스 계약 | docs/01_GAME_DESIGN.md | PLANNING_ONLY / runtime 미적용 | 상충하는 최신 사용자 결정 또는 플레이테스트 근거 발생 시 |
| `CORE-L` | DESIGN_DECISION | 현재 대화 최신 사용자 결정 및 v6 프로세스 계약 | docs/01_GAME_DESIGN.md | PLANNING_ONLY / runtime 미적용 | 상충하는 최신 사용자 결정 또는 플레이테스트 근거 발생 시 |
| `CORE-R` | DESIGN_DECISION | 현재 대화 최신 사용자 결정 및 v6 프로세스 계약 | docs/01_GAME_DESIGN.md | PLANNING_ONLY / runtime 미적용 | 사용자의 명시적 최신 재승인 시에만 |
| `COST-C` | DESIGN_DECISION | 현재 대화 최신 사용자 결정 및 v6 프로세스 계약 | docs/02_COMBAT_RULES.md | PLANNING_ONLY / runtime 미적용 | 상충하는 최신 사용자 결정 또는 플레이테스트 근거 발생 시 |
| `DEF-C` | DESIGN_DECISION | 현재 대화 최신 사용자 결정 및 v6 프로세스 계약 | docs/02_COMBAT_RULES.md | PLANNING_ONLY / runtime 미적용 | 상충하는 최신 사용자 결정 또는 플레이테스트 근거 발생 시 |
| `DEF-L` | DESIGN_DECISION | 현재 대화 최신 사용자 결정 및 v6 프로세스 계약 | docs/02_COMBAT_RULES.md | PLANNING_ONLY / runtime 미적용 | 상충하는 최신 사용자 결정 또는 플레이테스트 근거 발생 시 |
| `DEF-R` | DESIGN_DECISION | 현재 대화 최신 사용자 결정 및 v6 프로세스 계약 | docs/02_COMBAT_RULES.md | PLANNING_ONLY / runtime 미적용 | 사용자의 명시적 최신 재승인 시에만 |
| `GH-C` | CONFIRMED_FACT | GitHub 저장소·PR #45·현재 구현 파일 관찰 | [기획서]/00_프로젝트_허브/DOCUMENTATION_MAP.md · PR #45 | main@2a944fb40ff60d51b55d45a691942190f338da9f / PR #45 통합 브랜치 | 저장소·PR·구현 상태가 변경될 때 |
| `GH-L` | CONFIRMED_FACT | GitHub 저장소·PR #45·현재 구현 파일 관찰 | [기획서]/00_프로젝트_허브/DOCUMENTATION_MAP.md · PR #45 | main@2a944fb40ff60d51b55d45a691942190f338da9f / PR #45 통합 브랜치 | 저장소·PR·구현 상태가 변경될 때 |
| `GH-P` | CONFIRMED_FACT | GitHub 저장소·PR #45·현재 구현 파일 관찰 | [기획서]/00_프로젝트_허브/DOCUMENTATION_MAP.md · PR #45 | main@2a944fb40ff60d51b55d45a691942190f338da9f / PR #45 통합 브랜치 | 저장소·PR·구현 상태가 변경될 때 |
| `GLOBAL-C` | DESIGN_DECISION | 현재 대화 최신 사용자 결정 및 v6 프로세스 계약 | docs/06_STARTING_FACTION_MASTERY_DATA.md | PLANNING_ONLY / runtime 미적용 | 상충하는 최신 사용자 결정 또는 플레이테스트 근거 발생 시 |
| `GLOBAL-R` | DESIGN_DECISION | 현재 대화 최신 사용자 결정 및 v6 프로세스 계약 | docs/06_STARTING_FACTION_MASTERY_DATA.md | PLANNING_ONLY / runtime 미적용 | 사용자의 명시적 최신 재승인 시에만 |
| `IMPL-C` | CONFIRMED_FACT | GitHub 저장소·PR #45·현재 구현 파일 관찰 | data/ · src/ · tests/ | main@2a944fb40ff60d51b55d45a691942190f338da9f / PR #45 통합 브랜치 | 저장소·PR·구현 상태가 변경될 때 |
| `IMPL-X` | CONFIRMED_FACT | GitHub 저장소·PR #45·현재 구현 파일 관찰 | data/ · src/ · tests/ | main@2a944fb40ff60d51b55d45a691942190f338da9f / PR #45 통합 브랜치 | 저장소·PR·구현 상태가 변경될 때 |
| `MARTIAL-C` | DESIGN_DECISION | 현재 대화 최신 사용자 결정 및 v6 프로세스 계약 | docs/decisions/2026-07-28_V6_DECISION_AUTHORITY_LEDGER.md | PLANNING_ONLY / runtime 미적용 | 상충하는 최신 사용자 결정 또는 플레이테스트 근거 발생 시 |
| `MARTIAL-R` | DESIGN_DECISION | 현재 대화 최신 사용자 결정 및 v6 프로세스 계약 | docs/decisions/2026-07-28_V6_DECISION_AUTHORITY_LEDGER.md | PLANNING_ONLY / runtime 미적용 | 사용자의 명시적 최신 재승인 시에만 |
| `META-C` | DESIGN_DECISION | 현재 대화 최신 사용자 결정 및 v6 프로세스 계약 | docs/06_STARTING_FACTION_MASTERY_DATA.md | PLANNING_ONLY / runtime 미적용 | 상충하는 최신 사용자 결정 또는 플레이테스트 근거 발생 시 |
| `META-D` | DESIGN_HYPOTHESIS | 현재 대화 최신 사용자 결정 및 Round 1~3 적대적 검토 | docs/06_STARTING_FACTION_MASTERY_DATA.md | PLANNING_ONLY / runtime 미적용 | 사용자 재개·승인 또는 해당 후속 설계 라운드 |
| `META-R` | DESIGN_DECISION | 현재 대화 최신 사용자 결정 및 v6 프로세스 계약 | docs/06_STARTING_FACTION_MASTERY_DATA.md | PLANNING_ONLY / runtime 미적용 | 사용자의 명시적 최신 재승인 시에만 |
| `OBS-C` | DESIGN_DECISION | 현재 대화 최신 사용자 결정 및 v6 프로세스 계약 | docs/decisions/2026-07-28_V6_DECISION_AUTHORITY_LEDGER.md | PLANNING_ONLY / runtime 미적용 | 상충하는 최신 사용자 결정 또는 플레이테스트 근거 발생 시 |
| `OFFER-C` | DESIGN_DECISION | 현재 대화 최신 사용자 결정 및 v6 프로세스 계약 | docs/06_STARTING_FACTION_MASTERY_DATA.md | PLANNING_ONLY / runtime 미적용 | 상충하는 최신 사용자 결정 또는 플레이테스트 근거 발생 시 |
| `OLD-R` | DESIGN_DECISION | 현재 대화 최신 사용자 결정 및 v6 프로세스 계약 | docs/decisions/2026-07-28_V6_DECISION_AUTHORITY_LEDGER.md | PLANNING_ONLY / runtime 미적용 | 사용자의 명시적 최신 재승인 시에만 |
| `OLD-S` | DESIGN_DECISION | 현재 대화 최신 사용자 결정 및 v6 프로세스 계약 | docs/decisions/2026-07-28_V6_DECISION_AUTHORITY_LEDGER.md | PLANNING_ONLY / runtime 미적용 | 사용자의 명시적 최신 재승인 시에만 |
| `PACKET-C` | DESIGN_DECISION | 현재 대화 최신 사용자 결정 및 v6 프로세스 계약 | docs/02_COMBAT_RULES.md | PLANNING_ONLY / runtime 미적용 | 상충하는 최신 사용자 결정 또는 플레이테스트 근거 발생 시 |
| `PACKET-R` | DESIGN_DECISION | 현재 대화 최신 사용자 결정 및 v6 프로세스 계약 | docs/02_COMBAT_RULES.md | PLANNING_ONLY / runtime 미적용 | 사용자의 명시적 최신 재승인 시에만 |
| `POOL-C` | DESIGN_DECISION | 현재 대화 최신 사용자 결정 및 v6 프로세스 계약 | docs/decisions/2026-07-28_V6_DECISION_AUTHORITY_LEDGER.md | PLANNING_ONLY / runtime 미적용 | 상충하는 최신 사용자 결정 또는 플레이테스트 근거 발생 시 |
| `RANK-C` | DESIGN_DECISION | 현재 대화 최신 사용자 결정 및 v6 프로세스 계약 | docs/06_STARTING_FACTION_MASTERY_DATA.md | PLANNING_ONLY / runtime 미적용 | 상충하는 최신 사용자 결정 또는 플레이테스트 근거 발생 시 |
| `RANK-D` | DESIGN_HYPOTHESIS | 현재 대화 최신 사용자 결정 및 Round 1~3 적대적 검토 | docs/06_STARTING_FACTION_MASTERY_DATA.md | PLANNING_ONLY / runtime 미적용 | 사용자 재개·승인 또는 해당 후속 설계 라운드 |
| `RANK-L` | DESIGN_DECISION | 현재 대화 최신 사용자 결정 및 v6 프로세스 계약 | docs/06_STARTING_FACTION_MASTERY_DATA.md | PLANNING_ONLY / runtime 미적용 | 상충하는 최신 사용자 결정 또는 플레이테스트 근거 발생 시 |
| `ROSTER-C` | DESIGN_DECISION | 현재 대화 최신 사용자 결정 및 v6 프로세스 계약 | docs/decisions/2026-07-28_V6_DECISION_AUTHORITY_LEDGER.md | PLANNING_ONLY / runtime 미적용 | 상충하는 최신 사용자 결정 또는 플레이테스트 근거 발생 시 |
| `RUN-C` | DESIGN_DECISION | 현재 대화 최신 사용자 결정 및 v6 프로세스 계약 | docs/03_CONTENT_CATALOG.md | PLANNING_ONLY / runtime 미적용 | 상충하는 최신 사용자 결정 또는 플레이테스트 근거 발생 시 |
| `RUN-L` | DESIGN_DECISION | 현재 대화 최신 사용자 결정 및 v6 프로세스 계약 | docs/03_CONTENT_CATALOG.md | PLANNING_ONLY / runtime 미적용 | 상충하는 최신 사용자 결정 또는 플레이테스트 근거 발생 시 |
| `RUN-S` | DESIGN_DECISION | 현재 대화 최신 사용자 결정 및 v6 프로세스 계약 | docs/03_CONTENT_CATALOG.md | PLANNING_ONLY / runtime 미적용 | 사용자의 명시적 최신 재승인 시에만 |
| `SLOT-C` | DESIGN_DECISION | 현재 대화 최신 사용자 결정 및 v6 프로세스 계약 | docs/02_COMBAT_RULES.md | PLANNING_ONLY / runtime 미적용 | 상충하는 최신 사용자 결정 또는 플레이테스트 근거 발생 시 |
| `STACK-C` | DESIGN_DECISION | 현재 대화 최신 사용자 결정 및 v6 프로세스 계약 | docs/02_COMBAT_RULES.md | PLANNING_ONLY / runtime 미적용 | 상충하는 최신 사용자 결정 또는 플레이테스트 근거 발생 시 |
| `STACK-L` | DESIGN_DECISION | 현재 대화 최신 사용자 결정 및 v6 프로세스 계약 | docs/02_COMBAT_RULES.md | PLANNING_ONLY / runtime 미적용 | 상충하는 최신 사용자 결정 또는 플레이테스트 근거 발생 시 |
| `TAG-C` | DESIGN_DECISION | 현재 대화 최신 사용자 결정 및 v6 프로세스 계약 | docs/02_COMBAT_RULES.md | PLANNING_ONLY / runtime 미적용 | 상충하는 최신 사용자 결정 또는 플레이테스트 근거 발생 시 |
| `TAG-D` | DESIGN_HYPOTHESIS | 현재 대화 최신 사용자 결정 및 Round 1~3 적대적 검토 | docs/02_COMBAT_RULES.md | PLANNING_ONLY / runtime 미적용 | 사용자 재개·승인 또는 해당 후속 설계 라운드 |
| `TAG-L` | DESIGN_DECISION | 현재 대화 최신 사용자 결정 및 v6 프로세스 계약 | docs/02_COMBAT_RULES.md | PLANNING_ONLY / runtime 미적용 | 상충하는 최신 사용자 결정 또는 플레이테스트 근거 발생 시 |
| `TAG-R` | DESIGN_DECISION | 현재 대화 최신 사용자 결정 및 v6 프로세스 계약 | docs/02_COMBAT_RULES.md | PLANNING_ONLY / runtime 미적용 | 사용자의 명시적 최신 재승인 시에만 |
| `TRAIN-C` | DESIGN_DECISION | 현재 대화 최신 사용자 결정 및 v6 프로세스 계약 | docs/06_STARTING_FACTION_MASTERY_DATA.md | PLANNING_ONLY / runtime 미적용 | 상충하는 최신 사용자 결정 또는 플레이테스트 근거 발생 시 |
| `TRAIN-L` | DESIGN_DECISION | 현재 대화 최신 사용자 결정 및 v6 프로세스 계약 | docs/06_STARTING_FACTION_MASTERY_DATA.md | PLANNING_ONLY / runtime 미적용 | 상충하는 최신 사용자 결정 또는 플레이테스트 근거 발생 시 |
| `ULT-C` | DESIGN_DECISION | 현재 대화 최신 사용자 결정 및 v6 프로세스 계약 | docs/06_STARTING_FACTION_MASTERY_DATA.md | PLANNING_ONLY / runtime 미적용 | 상충하는 최신 사용자 결정 또는 플레이테스트 근거 발생 시 |
| `ULT-D` | DESIGN_HYPOTHESIS | 현재 대화 최신 사용자 결정 및 Round 1~3 적대적 검토 | docs/06_STARTING_FACTION_MASTERY_DATA.md | PLANNING_ONLY / runtime 미적용 | 사용자 재개·승인 또는 해당 후속 설계 라운드 |
| `ULT-P` | DESIGN_HYPOTHESIS | 현재 대화 최신 사용자 결정 및 Round 1~3 적대적 검토 | docs/06_STARTING_FACTION_MASTERY_DATA.md | PLANNING_ONLY / runtime 미적용 | 사용자 재개·승인 또는 해당 후속 설계 라운드 |
| `ULT-R` | DESIGN_DECISION | 현재 대화 최신 사용자 결정 및 v6 프로세스 계약 | docs/06_STARTING_FACTION_MASTERY_DATA.md | PLANNING_ONLY / runtime 미적용 | 사용자의 명시적 최신 재승인 시에만 |
| `ULT-S` | DESIGN_DECISION | 현재 대화 최신 사용자 결정 및 v6 프로세스 계약 | docs/06_STARTING_FACTION_MASTERY_DATA.md | PLANNING_ONLY / runtime 미적용 | 사용자의 명시적 최신 재승인 시에만 |

---

# 1. 작업 계약·GitHub 권한

| ID | 상태 | 결정 | 연결 프로필 |
|---|---|---|---|
| AUTH-01 | CONFIRMED | v6 마스터 참조문을 이번 작업의 최상위 프로세스 계약으로 사용한다. | `AUTH-C` |
| AUTH-02 | CONFIRMED | 축약 실행문은 v6 마스터를 대체하지 않고 실행 규칙을 보조한다. | `AUTH-C` |
| AUTH-03 | LATEST_OVERRIDE | 현재 제품 단계는 `CONCEPT_APPROVAL`, Work Mode는 `PLAN`이며 과거 BUILD 승인 상태를 대체한다. | `AUTH-L` |
| AUTH-04 | CONFIRMED | 실행 프로필은 `PLANNING_ONLY_PROFILE`이다. | `AUTH-C` |
| AUTH-05 | LATEST_OVERRIDE | 새 설계 승인 전 실제 Godot 런타임 구현과 Codex Build를 금지하며 과거 구현 승인 선언을 대체한다. | `AUTH-L` |
| AUTH-06 | CONFIRMED | 현재 작업은 설계·문서·벤치마킹·검수·Codex 계획 초안까지 허용한다. | `AUTH-C` |
| AUTH-07 | CONFIRMED | 사용자 승인 범위 밖 수정, 기본 브랜치 직접 수정, 승인 없는 병합을 금지한다. | `AUTH-C` |
| AUTH-08 | CONFIRMED | 실제로 실행하지 않은 빌드·테스트·플레이테스트는 PASS로 기록하지 않는다. | `AUTH-C` |
| AUTH-09 | CONFIRMED | Round 1에서는 새 아이디어를 질문하거나 추가하지 않고 결정만 추출한다. | `AUTH-C` |
| AUTH-10 | LATEST_OVERRIDE | 후속 전체 적대적 검토는 `[보류]`로 둔다. 현재 확정 결정과 PR #45 정합화는 `PLAN` 범위에서 GitHub에 반영할 수 있으나 런타임 구현 권한은 부여하지 않는다. | `AUTH-L` |
| AUTH-11 | CONFIRMED | 최종 GitHub 반영 전 사용자에게 주요 변경·남은 위험·미정 사항을 보고한다. | `AUTH-C` |
| AUTH-12 | CONFIRMED | 사용자에게는 주요 기획 결정만 묻고, 세부 기술·밸런스는 권장안 및 후속 백로그로 처리한다. | `AUTH-C` |
| AUTH-13 | CONFIRMED | 저장소에서 확인 가능한 사실·기술 세부값을 사용자에게 반복 질문하지 않는다. | `AUTH-C` |
| AUTH-14 | SUPERSEDED | PR #45의 `BUILD_IN_PROGRESS / implementation_authorization: GRANTED` 선언은 현재 v6 `PLAN / BUILD 금지` 지시에 의해 대체된다. | `AUTH-S` |
| AUTH-15 | SUPERSEDED | 과거 PR·문서의 `기획 완료`, `검수 완료`, `구현 인계 허용` 상태는 현재 작업의 권한 원본이 아니다. | `AUTH-S` |
| AUTH-16 | LATEST_OVERRIDE | PR #45는 최신 v6 원장과 중복되지 않도록 재분류·정합화하여 통합한다. BUILD 승인과 구형 규칙은 대체하고 감사·검증 자산은 역사 자료로 유지한다. | `AUTH-L` |
| AUTH-17 | CONFIRMED | 전체 결정 원장의 각 결정은 주장 유형·근거·영향 책임 원본·적용 빌드·재검토 조건에 연결한다. | `AUTH-C` |
| AUTH-18 | CONFIRMED | PR #45 통합 뒤에도 제품 단계 `CONCEPT_APPROVAL`, Work Mode `PLAN`, 실행 프로필 `PLANNING_ONLY_PROFILE`을 유지한다. | `AUTH-C` |

---

# 2. 제품 코어·플레이어 약속

| ID | 상태 | 결정 | 연결 프로필 |
|---|---|---|---|
| CORE-01 | LATEST_OVERRIDE | 뾰족한 재미: `계획을 세워 상대의 숨은 수를 읽고 파훼한다`. 과거 성장 우선 코어 표현을 대체한다. | `CORE-L` |
| CORE-02 | CONFIRMED | 플레이어 약속: 상대의 다음 행동 단서를 모아 가설을 세우고 여러 수의 계획으로 의도를 무너뜨리는 무협 전술 로그라이트. | `CORE-C` |
| CORE-03 | CONFIRMED | 판매 문구: `보이지 않는 상대의 수를 읽고, 준비한 계획으로 꺾는다.` | `CORE-C` |
| CORE-04 | CONFIRMED | 성장의 역할은 더 다양하고 강력한 파훼 방법을 제공하는 것이다. | `CORE-C` |
| CORE-05 | CONFIRMED | 전투는 성장 결과를 시험하고 학습하는 장이다. | `CORE-C` |
| CORE-06 | CONFIRMED | 원시 수치 상승은 보조적이며 파훼 판단을 대체할 수 없다. | `CORE-C` |
| CORE-07 | CONFIRMED | 핵심 성공 조건은 상대가 의도한 핵심 결과를 얻지 못하게 하는 것이다. | `CORE-C` |
| CORE-08 | CONFIRMED | 파훼 성공에 피해를 필수 조건으로 두지 않는다. | `CORE-C` |
| CORE-09 | CONFIRMED | 파훼 결과 단계: `mitigated / denied / reversed / punished`. | `CORE-C` |
| CORE-10 | CONFIRMED | 단독 코어 PoC는 사용자 결정으로 건너뛰며 다음 제품 목표는 버티컬 슬라이스다. | `CORE-C` |
| CORE-11 | REJECTED | 덱·손패·드로우를 핵심 전투 구조로 도입하지 않는다. | `CORE-R` |
| CORE-12 | REJECTED | 실시간 입력 숙련·콤보 암기를 승부의 주요 기준으로 삼지 않는다. | `CORE-R` |
| CORE-13 | REJECTED | AI가 플레이어의 미확정 계획을 읽는 구조를 금지한다. | `CORE-R` |
| CORE-14 | REJECTED | 원시 영구 능력치로 판단 실패를 무력화하는 메타 성장을 금지한다. | `CORE-R` |

---

# 3. 버티컬 슬라이스·강호행 구조

| ID | 상태 | 결정 | 연결 프로필 |
|---|---|---|---|
| RUN-01 | LATEST_OVERRIDE | 고정 핵심 결투 5개를 강호행의 앵커로 둔다. 이는 총 전투 수가 아니며 과거 필수 주요 비무 10개 구조를 대체한다. | `RUN-L` |
| RUN-02 | CONFIRMED | 핵심 결투 사이에 일반전·강적전·사건·수련·정보·회복·시장 등 중간 노드를 둔다. | `RUN-C` |
| RUN-03 | CONFIRMED | 경로는 결정론적으로 생성하며 재굴림을 허용하지 않는다. | `RUN-C` |
| RUN-04 | CONFIRMED | 경로 구간은 5개다. | `RUN-C` |
| RUN-05 | CONFIRMED | 구간별 중간 방문 노드 평균 3~4개, 최소 2개, 최대 5개다. | `RUN-C` |
| RUN-06 | CONFIRMED | 한 강호행에서 방문하는 중간 노드 총량 목표는 15~20개다. | `RUN-C` |
| RUN-07 | CONFIRMED | 핵심 결투를 포함한 총 방문 노드 목표는 20~25개다. | `RUN-C` |
| RUN-08 | CONFIRMED | 구간별 행은 3~4개, 행별 후보 노드는 2~3개다. | `RUN-C` |
| RUN-09 | CONFIRMED | 이동은 전진만 허용하며 역행·백트래킹을 금지한다. | `RUN-C` |
| RUN-10 | CONFIRMED | 분기 후 재합류는 허용한다. | `RUN-C` |
| RUN-11 | CONFIRMED | 노드 미리보기에는 노드 유형과 연결만 공개한다. | `RUN-C` |
| RUN-12 | CONFIRMED | 노드 미리보기에서 위험·보상·적 정체·세부 효과를 숨긴다. | `RUN-C` |
| RUN-13 | CONFIRMED | 거짓 노드 라벨은 사용하지 않는다. | `RUN-C` |
| RUN-14 | CONFIRMED | 핵심 결투 진입 전에는 짧은 무협식 별호·평판 문구를 보여줄 수 있다. | `RUN-C` |
| RUN-15 | CONFIRMED | 첫 완주 목표 시간은 120~150분이다. | `RUN-C` |
| RUN-16 | CONFIRMED | 숙련자 목표 시간은 90~120분이다. | `RUN-C` |
| RUN-17 | CONFIRMED | 하드 시간 제한은 없다. | `RUN-C` |
| RUN-18 | CONFIRMED | 저장 후 재개를 필수 지원한다. | `RUN-C` |
| RUN-19 | CONFIRMED | 노드·전투·보상·핵심 결투 경계에서 저장한다. | `RUN-C` |
| RUN-20 | CONFIRMED | 저장 불러오기로 경로·후보·보상을 재굴림하지 않는다. | `RUN-C` |
| RUN-21 | CONFIRMED | 초기 범위에서는 행동 묶음 도중 저장을 지원하지 않는다. | `RUN-C` |
| RUN-22 | SUPERSEDED | 과거 `필수 주요 비무 10개` 구조는 현재 5개 핵심 결투 앵커 구조의 권한 원본이 아니다. | `RUN-S` |
| RUN-23 | CONFIRMED | 수련도 체크포인트의 `5전째/10전째`는 핵심 결투 번호가 아니라 일반전·강적전·핵심 결투를 모두 포함한 전체 전투 완료 횟수다. | `RUN-C` |

---

# 4. 전투 라운드·종료·교착

| ID | 상태 | 결정 | 연결 프로필 |
|---|---|---|---|
| COMBAT-01 | CONFIRMED | 한 라운드는 `3수 → 해결 → 3수 → 해결 → 4수 → 해결`, 총 10수다. | `COMBAT-C` |
| COMBAT-02 | CONFIRMED | 각 묶음 단위로 계획하며 라운드 전체를 한 번에 사전 계획하지 않는다. | `COMBAT-C` |
| COMBAT-03 | CONFIRMED | 양측은 서로의 현재 확정 전 계획을 모른다. | `COMBAT-C` |
| COMBAT-04 | CONFIRMED | 체력이 0이 되면 즉시 승리·패배가 확정된다. | `COMBAT-C` |
| COMBAT-05 | CONFIRMED | 표준 전투는 약 3라운드 종료를 목표로 하지만 하드 라운드 상한은 없다. | `COMBAT-C` |
| COMBAT-06 | REJECTED | 판정 승리, 시간 초과 승리, 급사형 sudden death를 도입하지 않는다. | `COMBAT-R` |
| COMBAT-07 | CONFIRMED | 양측이 생존하면 다음 라운드로 진행한다. | `COMBAT-C` |
| COMBAT-08 | CONFIRMED | 한 라운드 동안 양측 유효 체력 피해가 0이면 교착 1회를 기록한다. | `COMBAT-C` |
| COMBAT-09 | CONFIRMED | 동일한 방어·회복 반복에는 효율 감소를 적용하는 방향을 유지한다. | `COMBAT-C` |
| COMBAT-10 | CONFIRMED | 유효 체력 피해가 발생하면 교착 누적을 초기화한다. | `COMBAT-C` |
| COMBAT-11 | LATEST_OVERRIDE | 교착 1회는 경고만 남긴다. 연속 교착 2회에는 직전 라운드와 같은 순수 방어·회복 행동의 효과를 75%로, 연속 교착 3회 이상에는 50%로 낮춘다. 공격·이동·관찰은 감소하지 않으며 유효 체력 피해가 발생하면 즉시 100%로 초기화한다. | `COMBAT-L` |

---

# 5. 전장·판정 파이프라인·합

| ID | 상태 | 결정 | 연결 프로필 |
|---|---|---|---|
| BOARD-01 | CONFIRMED | 전장은 10칸 일자형이다. | `BOARD-C` |
| BOARD-02 | CONFIRMED | 거리 0의 동일 칸 점유 상태 `[밀착]`을 유지한다. | `BOARD-C` |
| BOARD-03 | CONFIRMED | 기본 판정 파이프라인은 `대응 → 속공 → 이동 → 일반 공격`이다. | `BOARD-C` |
| BOARD-04 | CONFIRMED | 같은 시점에 대립하는 공격 효과는 사거리와 무관하게 `[합]` 후보가 된다. | `BOARD-C` |
| BOARD-05 | CONFIRMED | 사거리는 합 승자에게 실제 체력 피해를 줄 수 있는지 결정한다. | `BOARD-C` |
| BOARD-06 | CONFIRMED | 사거리 밖 합 승자는 `CLASH_WIN`, 상대 공격 취소, 체력 피해 0, `ON_CLASH_WIN` 발동을 얻는다. | `BOARD-C` |
| BOARD-07 | CONFIRMED | 사거리 밖 합 승리에는 `ON_HIT`·`ON_HEALTH_DAMAGE`가 발동하지 않는다. | `BOARD-C` |
| BOARD-08 | CONFIRMED | 이후 추격·이동이 발생하면 위치·사거리를 다시 검사한다. | `BOARD-C` |
| BOARD-09 | LATEST_OVERRIDE | 복합 행동에 여러 독립 공격 효과가 있으면 각 공격 효과는 독립적으로 합 후보가 된다. 단, 하나의 `[연격 N]` 공격 효과가 만든 N개 피해 묶음은 별도 공격 효과가 아니며 첫 피해 묶음만 합에 참여한다. | `BOARD-L` |
| BOARD-10 | CONFIRMED | 하나의 대립 공격은 최대 한 번만 합에 참여한다. | `BOARD-C` |
| BOARD-11 | CONFIRMED | 합 매칭은 단계·행동 순서·효과 순서에 따른 안정적 1대1 순서 매칭이다. | `BOARD-C` |
| BOARD-12 | REJECTED | 가장 강한 공격 우선 매칭과 수동 합 대상 선택을 사용하지 않는다. | `BOARD-R` |
| BOARD-13 | CONFIRMED | 효과는 순차 즉시 해결하고 각 효과 뒤 상태를 갱신한다. | `BOARD-C` |
| BOARD-14 | CONFIRMED | 각 공격은 해결 직전에 생존·위치·사거리·방향·자원을 다시 검사한다. | `BOARD-C` |
| BOARD-15 | CONFIRMED | 체력 0은 즉시 전투를 끝내며 이후 불필요 효과를 건너뛴다. | `BOARD-C` |

---
