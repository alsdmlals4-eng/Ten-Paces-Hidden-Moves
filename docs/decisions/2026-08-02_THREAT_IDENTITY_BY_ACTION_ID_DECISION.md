# 반복 파훼 위협 ID 판별 결정

- Decision ID: `TEN-DEC-20260802-THREAT-ID-ACTION-01`
- 승인일: 2026-08-02
- 상태: `CURRENT_APPROVED_PLANNING`
- 구현 권한: `PLANNING_ONLY`
- GrillMe 묶음: `5/10`
- 선행 결정: `TEN-DEC-20260802-CLASH-THREAT-ATTENUATION-01`

## 1. 승인 결론

전투 종료 `위협 대응` 반복 감쇠에서 `같은 위협`은 정확한 기초 행동 ID 또는 무공 기술 ID로 판별한다.

```text
기초 행동 → basic_action_id
무공 기술 → technique_id
절초 → ultimate_technique_id
```

- 같은 `속공` ID를 반복 파훼하면 같은 위협이다.
- 같은 `장풍` ID를 반복 파훼하면 같은 위협이다.
- 같은 무공 기술 ID를 반복 파훼하면 같은 위협이다.
- 서로 다른 기술 ID는 공개 행동 종류가 모두 `[공격]`이어도 다른 위협이다.
- 기초 속공과 속공 계열 무공 기술은 ID가 다르므로 다른 위협이다.

## 2. 위협 ID를 바꾸지 않는 요소

다음 차이는 같은 행동·기술 ID를 새로운 위협으로 만들지 않는다.

- 외공·내공 등 현재 스테이터스 차이
- `[준비]` 강화 적용 여부
- 일시적인 공격력·피해·사거리 강화
- 현재 거리·방향·대상 차이
- 자원 잔량과 비용 할인
- 무공서 성취 상승으로 같은 기술의 수치가 강화된 경우
- 임시 버프·디버프·상태 효과

같은 기술의 구조가 영구적으로 변경되어 별도 데이터 ID가 부여된 경우에만 다른 위협으로 계산할 수 있다.

## 3. 판별하면 안 되는 기준

다음 기준만으로 위협을 묶지 않는다.

- 공개 행동 종류 `[공격]`
- 사거리만 동일함
- 연격 수만 동일함
- 전조 수만 동일함
- 피해량이나 내공 비용만 동일함
- 같은 문파·무공서에서 파생됨

이 기준은 서로 다른 실제 기술을 과도하게 하나로 묶어 다양한 파훼를 감쇠시키므로 사용하지 않는다.

## 4. 반복 감쇠 연결

한 전투 안에서 같은 정규화 위협 ID의 합 파훼 성공 횟수에 다음 값을 적용한다.

| 성공 횟수 | 위협 대응 가치 |
|---:|---:|
| 1 | 100% |
| 2 | 50% |
| 3 이상 | 0% |

- 사거리 안·밖 성공은 같은 ID 카운트를 공유한다.
- 전투마다 카운트를 초기화한다.
- 전투 판정·절초기세·`ON_CLASH_WIN`·로그는 감쇠하지 않는다.

## 5. 데이터 계약

권장 필드:

```yaml
threat_identity:
  source_type: basic_action | technique | ultimate
  source_id: stable canonical id
  normalized_threat_id: source_type + ':' + source_id
```

표시명은 현지화·개명될 수 있으므로 감쇠 키로 사용하지 않는다. 동일한 안정 ID를 가진 기술의 이름이 바뀌어도 반복 카운트는 유지한다.

## 6. 미결정 경계

이 결정은 여러 피해 단위를 가진 한 번의 연격 행동이 반복 카운트를 몇 회 증가시키는지는 확정하지 않는다.

- 행동 1회당 1회로 계산할지
- 실제 합 승리 피해 단위마다 계산할지
- 서로 다른 파생 타격에 별도 하위 ID를 줄지

이 항목은 후속 GrillMe에서 정한다.

## 7. 검증 요구

1. 동일한 `basic_quick_attack` 파훼가 100%→50%→0%로 감쇠됨.
2. `basic_quick_attack`과 별도 무공 기술 `shadow_quick_strike`는 다른 위협으로 각각 첫 성공 100%를 가짐.
3. 같은 기술에 `[준비]` 강화가 붙어도 같은 위협으로 계산됨.
4. 같은 기술의 거리·피해·스테이터스가 달라도 같은 위협으로 계산됨.
5. 표시명 변경이 반복 카운트를 초기화하지 않음.
6. 모든 `[공격]`을 하나의 위협으로 묶지 않음.
7. 전투마다 위협 ID별 성공 횟수가 초기화됨.

## 8. 구현·증거 경계

```yaml
authority_status: CURRENT_APPROVED_PLANNING
scope_status: POC_PRIMARY
implementation_status: NOT_STARTED
identity_basis: EXACT_CANONICAL_ACTION_OR_TECHNIQUE_ID
name_used_as_identity: false
public_category_used_as_identity: false
temporary_modifiers_create_new_identity: false
multi_hit_counting_unit: TBD
static_validation: PENDING_DRAFT_PR
runtime_validation: NOT_RUN
godot_validation: NOT_RUN
windows_validation: NOT_RUN
human_validation: NOT_RUN
grillme_count: 5/10
```
