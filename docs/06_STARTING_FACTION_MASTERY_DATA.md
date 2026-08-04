# 십보강호 세력·핵심무공·심법 성장 정본

> 책임: 시작 무공 후보·1~10성 성장·기술 역할·기술 예산·성장 검증  
> 전투 규칙: `docs/02_COMBAT_RULES.md`  
> 생명주기: `docs/CANON_LIFECYCLE_REGISTRY.md`  
> 역사 PoC 데이터: `docs/planning-data/poc_martial_arts.json`  
> 역사 호환 분류: `T1 이후 가설 원본`. 현재 승인 Decision·approved contract·Active Context가 우선한다.

## 1. 현재 상태

```yaml
authority_status: CURRENT_APPROVED_PLANNING
active_batch: 7/10
merged_checkpoint: 0ba841ff2e62b2f716466356dd9e7ffcf587d150
implementation_status: NOT_STARTED
product_code_changed: false
runtime_validation: NOT_RUN
godot_validation: NOT_RUN
windows_validation: NOT_RUN
human_validation: NOT_RUN
next_planning_decision: STAR9_PUBLIC_READ_BRANCH_TEMPLATE
```

프로젝트 코어가 사용자 승인된 상태에서 성장 골격과 시작 무공 기술을 구체화한다. 이 문서는 상세 수치를 복제하지 않고 현재 approved contract의 역할·관계·후속 Gate를 연결하는 성장 책임 원본이다.

## 2. 활성 승인 계약

성장·해금:

- `docs/planning-data/approved_20260802_observation_stats_mastery_contract.json`
- `docs/planning-data/approved_20260803_star10_ultimate_primary_stat12_contract.json`
- `docs/planning-data/approved_20260803_starting_martial_secondary_stats_contract.json`
- `docs/planning-data/approved_20260803_intermediate_node_permanent_stat_rewards_contract.json`
- `docs/planning-data/approved_20260803_martial_technique_role_and_scaling_matrix_contract.json`
- `docs/planning-data/approved_20260803_starting_martial_technique_2_base_effects_and_budgets_contract.json`

현재 전투·기술1:

- `docs/planning-data/approved_20260804_combat_pricing_interruption_recovery_contract.json`
- `docs/planning-data/approved_20260804_existing_action_reprice_contract.json`
- `docs/planning-data/approved_20260804_technique1_conditional_rework_star5_contract.json`
- `docs/planning-data/approved_20260804_postmerge_canon_adversarial_audit_contract.json`

`approved_20260803_starting_martial_technique_1_base_effects_and_budgets_contract.json`은 `[대체됨]` 역사 증거다. 현재 기술1을 생성할 때 읽으면 `CANON_CONFLICT`다.

## 3. 현재 승인 범위

- 시작 총합20·평균4.
- 후보6개 중 시작 무공4개를 3성으로 선택.
- 2·4·6·8성 고정 영구 스테이터스 지급.
- 3성 기술1 주4, 7성 기술2 주8, 10성 절초 주12.
- 여섯 시작 무공의 주·보조 벡터.
- 무상한 핵심 스테이터스와 실제 영구값 사용.
- 데모 회차 중간 노드 영구 스테이터스 최대+2.
- 역할 우선·선택적 보조 배수 기술 작성 원칙.
- 기술1 6종의 유효 비용·슬롯 repricing.
- 기술1 6종의 실패 저점·조건 성공 고점·5성 무료20% patch.
- 기술2 6종의 상태 전환형 고급 상호작용·틱 예산.
- 승인표는 틱만 사용하며 슬롯·자원·조건·사용 가능 예산·편차를 분리.
- 행동 묶음 확정 뒤 추가 플레이어 선택 금지.
- 기술 안 이동은 고정 방향과 경계·점유 폴백 사용.

현재 런타임에는 최신 성장·기술 계약이 반영되지 않았다. 별도 Build 승인 전 제품 코드·Scene·런타임 데이터를 변경하지 않는다.

## 4. 프로젝트 코어와 성장 원칙

성장은 다음 전투의 거리·순서·자원·대응 계획을 확장해야 한다.

- 단순 피해 증가만으로 성장 체감을 만들지 않는다.
- 높은 능력치가 잘못된 계획을 반복 자동 구제하면 실패다.
- 기술1은 기본 운용법, 기술2는 공개 상태를 활용하는 고급 상호작용이다.
- 기술2가 기술1을 전 상황에서 대체하면 실패다.
- 5성·9성은 원래 역할을 확장하며 무조건 피해 증가로 수렴하지 않는다.
- 9성은 공개 정보 기반 자동 분기이며 행동 해결 중 추가 선택을 만들지 않는다.
- 10성 절초는 강력하지만 거리·중단·비용·대응 규칙을 무시하지 않는다.

## 5. 공용 기술 Schema

```text
action_slots
stamina_cost
internal_cost
range
move_range
hits
effects
sure_hit
category
resolution_phase
targeting_mode
skill_milestone
condition_trigger
condition_failure_scope
replay_reason_code
```

효과 scope는 `PER_HIT|ONCE_PER_ACTION`, trigger는 `ON_ACTION_START|ON_ACTION_RESOLVE|ON_CLASH_WIN|ON_EVADE_SUCCESS|ON_HIT|ON_HEALTH_DAMAGE|ON_ACTION_END` 중 하나를 명시한다.

- 한 효과는 주 능력치1개와 선택적 보조 능력치1개, 최대2개를 참조한다.
- 같은 출력값에 주·보조 배수를 동시에 더하지 않는다.
- 이동거리·사거리·관찰량·행동 슬롯·타격/회피 횟수·전조 수 같은 구조값은 능력치 점당 연속 증가하지 않는다.
- 행동 묶음이 확정된 뒤 추가 입력을 호출하지 않는다.
- 기술 이동은 `ADVANCE` 또는 `RETREAT`의 고정 방향과 이동 불가 폴백을 명시한다.

## 6. 시작 무공 6종

| canonical ID | 무공 | 주 | 보조 | 기술1 | 기술2 | 역사 PoC alias |
|---|---|---|---|---|---|---|
| `flowing_cloud_sword` | 유운검결 | 신법 | 외공 | 유운삼첩 | 낙영추검 | 동일 |
| `diamond_body_art` | 금강호체공 | 근골 | 내공 | 금강가세 | 반진권 | `vajra_body` |
| `taiji_flowing_sword` | 태극유전검 | 심안 | 내공 | 운수회신 | 사량발천근 | `taiji_flow` |
| `chasing_wind_spear` | 추풍창법 | 외공 | 신법 | 추풍일섬 | 연환쇄로 | `pursuing_wind_spear` |
| `clear_heart_nourishing_art` | 청심양생공 | 내공 | 근골 | 청심조식 | 회기전맥 | `clear_heart_nurturing` |
| `shadowless_ten_steps` | 무영십보 | 신법 | 심안 | 철각유영 | 십보환위 | `shadowless_steps` |

역사 ID는 `legacy_manual_alias`로만 보존한다. 새 Decision·Sheet·adapter는 canonical ID를 사용한다.

## 7. 시작 능력치

```text
기본2 × 5종 = 10
+ 자유 분배6 = 16
+ 선택 시작 무공4개의 2성 주 능력치 +1 = 20
```

- 최종 시작 총합20·평균4.
- 직접 분배 단계 각 능력치는2~6이며 이후 무공 보너스는6에서 잘리지 않는다.
- `[추천 배분]`은 네 첫 기술의 최소 해금 기준선을 보여주되 강제하지 않는다.
- 일부 기술을 잠근 전문화 배분은 경고 뒤 허용한다.

| 능력치 | 역할 |
|---|---|
| 외공 `EXTERNAL` | 외가 공격·강공·무기 위력·방어 파괴 |
| 근골 `CONSTITUTION` | 최대 체력·방어도·강건·버티기 |
| 신법 `MOVEMENT` | 이동·보법·회피·위치 조정 |
| 내공 `INTERNAL` | 최대 내력·내가 효과·호신·회복 |
| 심안 `INSIGHT` | 관찰·간파·반격·전조 대응 |

핵심 스테이터스에는 디자인 하드캡이 없다. 기존1~15는 초기 검증 구간이며 합법적인15 초과값을 실제 요구치와 공식에 사용한다.

## 8. 1~10성 성장 구조

| 성 | 신규 지급·판정 |
|---:|---|
| 1 | 고유 패시브 |
| 2 | 주 영구 능력치 +1 |
| 3 | 기술1 해금: 주 영구 능력치4, 기본 운용법 |
| 4 | 주 +1·보조 +1 |
| 5 | 기술1 기존 역할 무료20% 강화 |
| 6 | 주 +2·보조 +1 |
| 7 | 기술2 해금: 주 영구 능력치8, 고급 상호작용 |
| 8 | 주 +3·보조 +2 |
| 9 | 기술2 공개 정보 기반 자동 조건 분기 |
| 10 | 고유 절초 해금: 주 영구 능력치12 |

도달 비용은4성2, 5성3, 6성4, 7성5, 8성6, 9성8, 10성10이며 3→10 총38이다.

## 9. 기술1 현재 권위

유효 슬롯·기력·내력 비용은 `approved_20260804_existing_action_reprice_contract.json`을 읽는다. 효과·조건·5성 patch는 `approved_20260804_technique1_conditional_rework_star5_contract.json`을 읽는다.

| 기술 | 유효 구조 | 실패 저점·성공 고점 요약 | 효과/예산/편차 |
|---|---|---|---:|
| 유운삼첩 | 2수·기력1·내력1 | 1타→조건부 2·3타→완주 후퇴 | `58/61/-3` |
| 금강가세 | 1수·기력1·내력1 | 기본 방어→완전 방어 보상 | `31/31/0` |
| 운수회신 | 1수·기력2·내력1 | 회피 시도→성공 후퇴·회복·방어 | `38/40/-2` |
| 추풍일섬 | 1수·기력1·내력3 | 전진·기본 피해→창끝 고점 | `50/45/+5` |
| 청심조식 | 1수·무비용 | 기본 내력→저자원 회복 고점 | `22/24/-2` |
| 철각유영 | 1수·기력3·내력2 | 후퇴·회피→완전 탈출 보상 | `48/46/+2` |

5성 무료 예산은 각각 `12/6/8/9/5/9틱`이며 별도 슬롯·기력·내력 비용이 없다. 조건 실패 시 조건부 5성 patch도 전부0이다.

유운삼첩은 총피해를 한 번 계산한 뒤 `40% / 30% / 나머지`로 분배한다. 취소·실패한 후속타 피해는 재분배·이월하지 않는다.

## 10. 기술2 현재 권위

7성 기술2의 상세 공식·조건·고정 이동·틱 ledger는 `approved_20260803_starting_martial_technique_2_base_effects_and_budgets_contract.json`이 소유한다.

| 기술2 | 역할 |
|---|---|
| 낙영추검 | 고정 전진·공격으로 압박 전환 |
| 반진권 | 방어 상태를 반격 기회로 전환 |
| 사량발천근 | 합 결과를 위치·피해 전환으로 활용 |
| 연환쇄로 | 적중과 고정 후퇴로 거리 재설정 |
| 회기전맥 | 저자원 상태를 안정화 기회로 전환 |
| 십보환위 | 회피·위치 교환 계열의 고급 상호작용 |

기술2는 기술1의 단순 상위호환이 아니다. 기술1/2 선택률과 기술2의 전 상황 대체율을 사람 검증에서 기록한다.

## 11. 중간 노드 성장

- 데모 중간 노드8개 중 영구 스테이터스 보상 기회는 회차 최대2개다.
- 같은 구간에 영구 스테이터스 노드를 둘 이상 배치하지 않는다.
- 하나의 노드가 수련·회복·정보를 자동으로 모두 지급하지 않는다.
- 비스탯 노드의 기대가치·배치·가중치는 후속 Decision 전까지 제품 최종값이 아니다.

## 12. 적대적 성장 위험

### `WRONG_PLAN_RESCUE_RISK`

필수 측정:

- 잘못된 계획의 생존·승리 구제율.
- 올바른 읽기와 잘못된 읽기의 기대 성과 차이.
- 고능력치 단순 반복 승리율.
- 성장 전후 계획 다양성.

### `CONDITION_CALIBRATION_RISK`

필수 측정:

- 기술별 조건 성공률.
- 선언 난도 성공 범위 이탈률.
- 실패 지점 분포.
- 성공 고점 만족도와 실패 저점 수용도.

### `RESOURCE_SATURATION_RISK`

필수 측정:

- 묶음 종료 자원 상한 도달률.
- 자동 회복 낭비율.
- 명상·준비 선택률.
- 고비용 기술 연속 사용률.

실측 전 승인 수치를 임의 조정하지 않는다.

## 13. 다음 기획 Gate

```text
STAR9_PUBLIC_READ_BRANCH_TEMPLATE
→ 여섯 개별 9성 자동 분기
→ 여섯 10성 고유 절초
→ 비스탯 노드 기대가치
→ 전투 종료 등급 산식·파밍 방지
```

9성 템플릿은 공개 trigger, 자동 발동, 실패 0 범위, 조건 가격, 대응 수단, 복기 문구, 성공률 측정을 필수로 한다.

## 14. 생명주기 경계

- `[현행]`: 이 문서가 열거한 2026-08-04 전투·기술1 계약과 활성 성장 계약.
- `[대체됨]`: 2026-08-03 기술1 기본 효과 Decision·contract.
- `[보류]`: PR #85 HTML Technique1 PoC.
- `[폐기]`: 현재 없음.

구형 상세 자료는 Git 역사에서 재현하고 현재 제품 데이터 생성에는 사용하지 않는다.

## 15. 검증 경계

```yaml
product_code_changed: false
runtime_data_changed: false
runtime_validation: NOT_RUN
godot_validation: NOT_RUN
windows_validation: NOT_RUN
accessibility_validation: NOT_RUN
human_validation: NOT_RUN
balance_validation: NOT_RUN
```
