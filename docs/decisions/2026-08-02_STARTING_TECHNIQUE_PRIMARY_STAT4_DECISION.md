# 시작 3성 기술 주 능력치 4 요구 결정

- Decision ID: `TEN-DEC-20260802-STARTING-TECHNIQUE-PRIMARY-STAT4-01`
- 승인일: 2026-08-02
- 상태: `CURRENT_APPROVED_PLANNING`
- 구현 권한: `PLANNING_ONLY`
- GrillMe 묶음: `6/10`
- 선행 결정:
  - `TEN-DEC-20260802-OBSERVATION-STATS-MASTERY-01`
  - `TEN-DEC-20260802-STARTING-STAT-TOTAL20-MANUAL-BONUS-01`

## 1. 승인 결론

시작 무공 6개 중 4개를 3성으로 선택하더라도, 각 무공의 첫 3성 기술은 해당 무공의 **주 능력치 4**를 요구한다.

요구치는 기본 능력치·자유 분배·선택 무공의 2성 고정 보너스를 모두 적용한 **최종 시작 영구 능력치**로 판정한다.

```text
최종 시작 능력치
= 기본 2
+ 자유 분배
+ 선택 무공 2성 고정 보너스
```

## 2. 무공별 3성 기술 요구치

| 무공 ID | 무공 | 3성 기술 요구치 |
|---|---|---:|
| `flowing_cloud_sword` | 유운검결 | 신법 4 |
| `vajra_body` | 금강호체공 | 근골 4 |
| `taiji_flow` | 태극유전검 | 심안 4 |
| `pursuing_wind_spear` | 추풍창법 | 외공 4 |
| `clear_heart_nurturing` | 청심양생공 | 내공 4 |
| `shadowless_steps` | 무영십보 | 신법 4 |

## 3. 미달 시 처리

주 능력치 4에 미달해도 무공 선택과 성취는 취소되지 않는다.

- 무공서는 3성으로 보유한다.
- 1성 패시브와 2성 고정 영구 능력치 보너스는 정상 적용한다.
- 3성 기술만 `LOCKED_STAT_REQUIREMENT` 상태가 된다.
- 이후 회차 중 영구 능력치가 4에 도달하면 별도 비용 없이 자동 활성화한다.
- 임시 능력치 감소는 이미 활성화된 기술을 다시 잠그지 않는다.
- 잠긴 기술 때문에 무공 수련이 중단되거나 해금 기회를 잃지 않는다.

## 4. 설계 의도

- 시작 무공 선택과 자유 능력치 분배가 서로 독립된 장식 선택이 아니라 실제 빌드 계획으로 연결된다.
- 평균 능력치 4를 기준으로 기술 예산과 시작 해금 문턱을 일치시킨다.
- 모든 시작 기술을 자동 활성화하지 않아 선택의 대가를 유지한다.
- 동시에 미달 시 무공 자체를 잃게 하지 않아 초기 선택 실수를 영구 실패로 만들지 않는다.

## 5. 적대적 위험과 보호 조건

### 인지·UX 위험

플레이어가 무공 4개를 선택한 뒤 기술이 잠긴 사실을 뒤늦게 알면 선택이 기만적으로 느껴질 수 있다.

따라서 구현 전 다음 UX가 필요하지만, 정확한 화면 흐름은 후속 승인 대상이다.

- 최종 확정 전 예상 영구 능력치 표시
- 각 선택 무공의 3성 기술 활성·잠금 미리보기
- 부족한 주 능력치와 필요한 점수 표시
- 시작 설정 확정 전 자유 분배 재조정 허용

이 UX는 `RECOMMENDED_REQUIRED_FOR_BUILD`, 아직 별도 구현 승인 전 `NOT_STARTED`다.

### 밸런스 위험

- 유운검결과 무영십보는 모두 신법 4를 요구해 함께 선택할 때 같은 투자로 두 기술이 열리는 시너지가 있다.
- 다른 네 무공은 서로 다른 주 능력치를 요구한다.
- 이 비대칭은 허용하지만 신법 계열이 시작 선택을 지배하는지 사람 검증에서 확인한다.

## 6. 대체·미확정 범위

이번에 확정:

- 시작 3성 기술의 주 능력치 요구값 4
- 무공별 주 능력치 매핑
- 미달 시 기술만 잠금·영구 능력치 충족 시 자동 활성화

아직 미확정:

- 7성 기술과 10성 절초의 정확한 요구치
- 보조 능력치 요구 여부
- 시작 분배·무공 선택 UX의 정확한 순서와 화면
- 선택한 4개 시작 기술을 모두 활성화하는 빌드를 시스템이 보장할지 여부

## 7. 구현·검증 경계

- 기획 Decision과 구조화 계약만 승인한다.
- 제품 코드·런타임 카드·UI는 별도 Build 승인 전 변경하지 않는다.

검증 요구:

1. 모든 시작 무공 첫 기술의 요구값이 주 능력치 4임.
2. 최종 시작 능력치로 요구치를 판정함.
3. 미달 시 무공·패시브·2성 보너스는 유지되고 기술만 잠김.
4. 영구 능력치 4 도달 시 추가 비용 없이 자동 활성화함.
5. 임시 능력치 감소가 활성 기술을 다시 잠그지 않음.
6. 무공별 canonical ID와 주 능력치 매핑이 일치함.
7. 시작 확정 전에 기술 잠금 상태를 예고하는 UX가 Build Gate에 포함됨.
8. 런타임 구현 완료로 오인하지 않음.

```yaml
authority_status: CURRENT_APPROVED_PLANNING
implementation_status: NOT_STARTED
starting_technique_requirement_type: PRIMARY_STAT
starting_technique_requirement_value: 4
requirement_evaluation_state: FINAL_STARTING_PERMANENT_STATS
manual_and_passive_retained_when_locked: true
star_2_bonus_retained_when_locked: true
auto_enable_on_permanent_requirement_met: true
temporary_stat_drop_relocks: false
preconfirm_unlock_preview: RECOMMENDED_REQUIRED_FOR_BUILD
runtime_validation: NOT_RUN
godot_validation: NOT_RUN
windows_validation: NOT_RUN
human_validation: NOT_RUN
grillme_count: 6/10
```
