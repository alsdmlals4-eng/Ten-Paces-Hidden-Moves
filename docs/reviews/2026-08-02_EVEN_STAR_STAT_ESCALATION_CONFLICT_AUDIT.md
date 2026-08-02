# 짝수 성 신규 스테이터스 지급량 충돌 감사

- Audit ID: `TEN-AUD-032`
- 감사일: 2026-08-02
- 최종 갱신: 2026-08-03
- 기준 PR: `#80`
- 기준 Decision:
  - `TEN-DEC-20260802-EVEN-STAR-STAT-ESCALATION-01`
  - `TEN-DEC-20260803-UNCAPPED-CORE-STATS-01`
- 승인 누적: `9/10`
- 상태: `PARTIAL_RESOLVED_REMAINING_REQUIREMENT_AND_GROWTH_GATES`
- 제품 코드 변경: 없음

## 1. 감사 대상

승인된 신규 지급 구조는 다음과 같다.

| 성취 | 새 지급 | 누적 |
|---:|---|---|
| 2성 | 주 +1 | 주 +1 / 총 1 |
| 4성 | 주 +1·보조 +1 | 주 +2·보조 +1 / 총 3 |
| 6성 | 주 +2·보조 +1 | 주 +4·보조 +2 / 총 6 |
| 8성 | 주 +3·보조 +2 | 주 +7·보조 +4 / 총 11 |

각 값은 해당 성까지의 표시값이 아니라 그 성에서 새로 지급되는 값이다.

## 2. 정량 재현

### 2.1 단일 무공 집중

- 일반 주 능력치 시작 최대 7 + 한 무공의 3→8성 추가 주 능력치 6 = 13
- 신법 시작 최대 8 + 한 무공 추가 주 능력치 6 = 14

### 2.2 동일 주 능력치 복수 무공

유운검결과 무영십보를 모두 8성까지 성장시키는 현재 최대 예시는 다음과 같다.

```text
시작 신법 최대 8
+ 유운검결 3→8성 추가 주 능력치 6
+ 무영십보 3→8성 추가 주 능력치 6
= 신법 20
```

### 2.3 기술 요구치 자동 도달 하한

| 시점 | 최소 주 능력치 | 최소 보조 능력치 |
|---|---:|---:|
| 7성 직전 | 6 | 4 |
| 10성 직전 | 9 | 6 |

7성 요구치를 주6·보조4 이하, 10성 요구치를 주9·보조6 이하로 두면 별도 투자 없이 자동 충족될 수 있다.

## 3. 해결된 충돌

### 3.1 반복 지급

- 무공별·성취별·회차별 최초 도달 한 번만 지급
- 저장 재로드·재계산·중복 습득으로 재지급하지 않음

판정: `RESOLVED_BY_IDEMPOTENT_GRANT_KEY`.

### 3.2 누적값 오독

4성 2점, 6성 3점, 8성 5점은 각각 새 지급이다.

판정: `RESOLVED_INCREMENTAL_NOT_SNAPSHOT`.

### 3.3 비짝수 성 중복 보상

5·7·9·10성은 별도 승인 전 영구 스테이터스를 추가 지급하지 않는다.

판정: `RESOLVED_NO_UNAPPROVED_STAT_GRANTS`.

### 3.4 능력치 15 상한·초과분

`TEN-DEC-20260803-UNCAPPED-CORE-STATS-01`로 다음을 확정했다.

- 외공·근골·신법·내공·심안에는 디자인 하드캡 없음
- 기존 1~15는 초기 밸런스 검증 구간
- 15 초과값 절단 없음
- 초과분 소실·재분배·별도 화폐 변환 없음
- 실제 영구값을 요구치와 전투 공식에 사용
- 콘텐츠별 최대 합법 도달값을 동적 검증점으로 사용

판정: `RESOLVED_BY_UNCAPPED_CORE_STATS_WITH_REACHABLE_MAX_VALIDATION`.

벤치마크에서 도출한 보완 원칙:

- 원천 스테이터스와 규칙을 무효화할 수 있는 파생 효과를 분리한다.
- 회피율·피해 감소율·확률·쿨다운 감소는 필요할 경우 파생 효과 단계에서 점근형·쌍곡선형·효과 한계·임계 구간을 사용한다.
- 구조적 값은 스테이터스 1점마다 연속 증가시키지 않는다.

## 4. 남은 병합·구현 Gate

### P1-1. 7성·10성 요구치

자동 도달 하한보다 높은 요구치 또는 다른 선택 조건을 사용해야 요구치가 빌드 선택으로 기능한다.

다음 Decision 순서:

1. 7성 기술 요구치
2. 10성 절초 요구치

### P1-2. 보조 능력치 매핑

상한은 없지만 특정 능력치로 모든 보조 보너스가 몰리면 수치 성장 지배와 단일 최적 빌드가 생길 수 있다. 모든 시작 무공 조합과 집중·분산 성장 경로를 비교해 매핑해야 한다.

### P1-3. 중간 노드 영구 스테이터스

무공 성장만으로 총량이 크게 증가하므로, 노드 영구 스테이터스는 핵심 재미에 필요한지 먼저 검증한다. 단순 수치 상승보다 다음 비무의 정보·기술·자원 계획을 바꾸는 보상을 우선한다.

### P1-4. 수읽기보다 수치 성장 지배

필수 사람 검증:

- 동일 상대·동일 계획에서 능력치 4·15·현재 최대 합법값 비교
- 잘못된 계획을 고능력치가 상쇄한 비율
- 올바른 파훼가 저능력치에서도 유효한지
- 집중 성장과 분산 성장의 기술·계획 다양성
- 적 체력만 비례 증가하는 수치 인플레이션 여부

## 5. 이후 GrillMe 벤치마킹 절차

`docs/reviews/2026-08-03_GRILLME_BENCHMARK_PROTOCOL.md`를 이후 질문에 적용한다.

- 내부 정본·충돌 확인
- 관련 유사 게임 또는 현업 패턴 최소 2개 비교
- 프로젝트에 채택할 원칙과 버릴 원칙 분리
- A/B/C 선택지, 권장안, 반대 논거, 검증 지표 제시
- 출처 없는 “현업에서는 보통” 표현 금지

## 6. 현재 판정

```yaml
audit_id: TEN-AUD-032
approved_grant_structure: true
incremental_grant_semantics: true
core_stat_hard_cap: null
legacy_15_is_validation_reference: true
current_known_reachable_example:
  stat: MOVEMENT
  value: 20
resolved_conflicts:
  - idempotent_milestone_grant
  - incremental_not_snapshot
  - no_stat_grant_at_5_7_9_10
  - stat_cap_and_overflow_policy
remaining_p1:
  - star_7_and_star_10_requirements
  - secondary_stat_mapping
  - route_node_permanent_stat_rewards
  - numerical_growth_overriding_core_reading_gameplay
merge_allowed: false
next_required_decision: STAR_7_TECHNIQUE_REQUIREMENT
runtime_changed: false
runtime_validation: NOT_RUN
godot_validation: NOT_RUN
windows_validation: NOT_RUN
human_validation: NOT_RUN
approval_count: 9/10
```
