# 핵심 스테이터스 무상한·파생 효과 보호 정책 결정

- Decision ID: `TEN-DEC-20260803-UNCAPPED-CORE-STATS-01`
- 승인일: 2026-08-03
- 상태: `CURRENT_APPROVED_PLANNING`
- 구현 권한: `PLANNING_ONLY`
- GrillMe 묶음: `9/10`
- 선행 결정:
  - `TEN-DEC-20260802-OBSERVATION-STATS-MASTERY-01`
  - `TEN-DEC-20260802-EVEN-STAR-STAT-ESCALATION-01`

## 1. 승인 결론

외공·근골·신법·내공·심안의 영구 핵심 스테이터스에는 게임 디자인상의 하드캡을 두지 않는다.

기존 `1~15` 표현은 상한이 아니라 초기 밸런스 검증 구간으로 재정의한다. 합법적인 콘텐츠·무공·노드 조합으로 15를 넘더라도 값을 절단하거나 초과분을 다른 자원으로 변환하지 않으며, 실제 수치를 공식과 기술 요구치에 그대로 사용한다.

```yaml
designed_hard_cap: null
legacy_range_1_15_meaning: INITIAL_BALANCE_VALIDATION_BAND
clamp_at_15: false
overflow_conversion: NONE
requirement_checks_use_actual_permanent_stat: true
combat_formulas_use_actual_effective_stat: true
```

## 2. 무상한과 무제한 효율의 구분

핵심 스테이터스의 숫자는 제한하지 않지만, 핵심 전투 규칙을 무효화할 수 있는 파생 효과는 별도 계약으로 보호한다.

- 고정 피해·최대 체력·최대 자원처럼 수치가 커져도 규칙 자체가 사라지지 않는 값은 명시된 선형 또는 단계형 공식을 사용할 수 있다.
- 회피율·피해 감소율·발동 확률·재사용 대기시간 감소처럼 100%에 도달하면 상호작용을 제거하는 값은 핵심 스테이터스에 하드캡을 거는 대신 파생 효과 단계에서 다음 중 하나를 사용한다.
  - 점근·쌍곡선형 감소 효율
  - 명시된 파생 효과 최대치
  - 스테이터스 연속 증가가 아니라 기술별 임계 구간
- 이동거리·공격 사거리·관찰량·행동 슬롯·회피 횟수·전조 수 등 구조적 값은 기존 승인대로 스테이터스 1점마다 연속 증가하지 않으며 기술 임계 효과에서만 증가한다.

## 3. 콘텐츠 기반 검증 범위

상한을 두지 않는 대신 각 릴리스·콘텐츠 묶음은 현재 합법 경로에서 도달 가능한 최대치를 계산한다.

필수 검증점:

1. 최소 대표값 1
2. 시작 평균값 4
3. 기존 고성장 대표값 15
4. 현재 콘텐츠의 최대 합법 도달값
5. 새 콘텐츠 추가 후 갱신된 최대 합법 도달값

현재 PR #80 감사에서 확인된 신법 최대 예시는 20이며, 이는 상한이 아니라 현 콘텐츠 조합의 검증 사례다.

새 무공·보조 능력치 매핑·중간 노드·장비·영구 보상을 추가할 때는 최대 도달값을 다시 계산하고 공격·방어·자원·기술 요구치·AI·UI 표시를 함께 검증한다.

## 4. 획득과 저장 보호

- 능력치 획득처는 유한하고 추적 가능한 Decision·콘텐츠 데이터로만 추가한다.
- 짝수 성 보너스는 무공별·성취별·회차별 최초 1회 지급 계약을 유지한다.
- 중복 습득·저장 재로드·재계산으로 능력치가 중복 지급되지 않아야 한다.
- UI와 전투 로그는 저장 영구값, 전투 임시 보정, 최종 유효값을 구분해 표시한다.
- 구현 자료형의 오버플로·손상 저장 방지는 엔지니어링 안전 계약이며 게임 디자인상의 능력치 상한으로 취급하지 않는다.

## 5. 핵심 재미 보호 Gate

무상한 성장은 수읽기 코어를 대체해서는 안 된다.

사람 검증에서 다음을 측정한다.

- 동일 상대·동일 계획에서 능력치 4·15·현재 최대 합법값의 결과 차이
- 잘못된 거리·순서·방어 선택을 높은 능력치가 뒤집은 비율
- 낮은 능력치에서도 올바른 파훼가 작동하는 비율
- 한 능력치 집중과 분산 성장의 계획·기술 선택 다양성
- 공격 능력치 증가에 맞춰 적 체력만 비례 상승시키는 수치 인플레이션 여부

고능력치가 반복적으로 잘못된 계획을 덮는다면 핵심 스테이터스 상한을 신설하지 않고, 우선 기술 배수·보상 공급·상대 구성·파생 공식 중 원인을 수정한다.

## 6. 해결되는 충돌과 남은 순서

이번 결정으로 `TEN-AUD-032`의 능력치 15 상한·초과분 처리 충돌을 해소한다.

- 15에서 절단하지 않음
- 초과분 소실 없음
- 자유 재분배 없음
- 영구값과 전투 적용값의 이중 의미 없음

후속 순서:

1. 7성·10성 기술 요구치
2. 무공별 보조 능력치 매핑
3. 중간 노드 영구 스테이터스 지급 여부·량
4. 현재 최대 합법값을 포함한 전투 공식·사람 검증

## 7. 구현·검증 경계

```yaml
authority_status: CURRENT_APPROVED_PLANNING
implementation_status: NOT_STARTED
core_stat_hard_cap: null
legacy_15_is_cap: false
legacy_15_is_validation_reference: true
current_known_reachable_example:
  stat: MOVEMENT
  value: 20
release_validation_uses_reachable_max: true
derived_percentage_or_structural_effects_need_separate_guardrails: true
runtime_validation: NOT_RUN
godot_validation: NOT_RUN
windows_validation: NOT_RUN
human_validation: NOT_RUN
grillme_count: 9/10
```
