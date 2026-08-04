# 십보강호 세력·핵심무공·심법 성장 정본

> 책임: 시작 무공 후보·1~10성 성장·기술 역할·기술 예산·성장 검증  
> 전투 규칙: `docs/02_COMBAT_RULES.md`  
> 생명주기: `docs/CANON_LIFECYCLE_REGISTRY.md`  
> 역사 PoC 데이터: `docs/planning-data/poc_martial_arts.json`  
> 역사 호환 분류: `T1 이후 가설 원본`. 현재 Decision·approved contract·Active Context가 우선한다.

## 1. 현재 상태

```yaml
authority_status: CURRENT_APPROVED_PLANNING
active_batch: 7/10
merged_checkpoint: 0ba841ff2e62b2f716466356dd9e7ffcf587d150
implementation_status: NOT_STARTED
runtime_validation: NOT_RUN
godot_validation: NOT_RUN
windows_validation: NOT_RUN
human_validation: NOT_RUN
next_planning_decision: STAR9_PUBLIC_READ_BRANCH_TEMPLATE
```

프로젝트 코어가 사용자 승인된 상태에서 성장 골격과 시작 무공을 구체화한다. 상세 수치는 아래 활성 계약이 소유한다.

- `approved_20260803_star10_ultimate_primary_stat12_contract.json`
- `approved_20260803_starting_martial_secondary_stats_contract.json`
- `approved_20260803_intermediate_node_permanent_stat_rewards_contract.json`
- `approved_20260803_martial_technique_role_and_scaling_matrix_contract.json`
- `approved_20260803_starting_martial_technique_2_base_effects_and_budgets_contract.json`
- `approved_20260804_combat_pricing_interruption_recovery_contract.json`
- `approved_20260804_existing_action_reprice_contract.json`
- `approved_20260804_technique1_conditional_rework_star5_contract.json`
- `approved_20260804_postmerge_canon_adversarial_audit_contract.json`

`approved_20260803_starting_martial_technique_1_base_effects_and_budgets_contract.json`은 `[대체됨]` 역사 증거다. 현재 데이터 생성에 사용하면 `CANON_CONFLICT`다.

## 2. 현행 전투 계약과 연결 원칙

- 성장은 다음 전투의 거리·순서·자원·대응 계획을 확장해야 한다.
- 기술1은 기본 운용법, 기술2는 공개 상태 기반 고급 상호작용이다.
- 기술2가 기술1을 전 상황에서 대체하면 실패다.
- 5성·9성은 원래 역할을 확장하며 무조건 피해 증가로 수렴하지 않는다.
- 9성은 공개 정보 기반 자동 분기이며 행동 해결 중 추가 선택을 만들지 않는다.
- 10성 절초도 거리·합·회피·중단·자원 규칙을 따른다.
- 높은 능력치가 잘못된 계획을 반복 구제하면 성장 설계를 재검토한다.

공용 Schema:

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

- 한 효과는 주 능력치1개와 선택적 보조 능력치1개, 최대2개를 참조한다.
- 같은 출력에 주·보조 배수를 동시에 더하지 않는다.
- 이동거리·사거리·슬롯·타격/회피 횟수·전조 수는 능력치 점당 연속 증가하지 않는다.
- 기술 이동은 `ADVANCE|RETREAT` 고정 방향과 이동 불가 폴백을 명시한다.

## 3. 다음 PoC 성장 실험

- 시작 후보6개 중4개를3성으로 선택한다.
- 시작 총합20·평균4에서 전문화와 네 기술 동시 해금 경로를 비교한다.
- 주요 비무5 전 한 무공10성 경로의 수련 요구량과 노드 의존도를 검증한다.
- 데모 중간 노드8개 중 영구 스테이터스 보상 기회는 회차 최대2개다.
- 기술1/2 선택률과 기술2의 전 상황 대체율을 기록한다.
- 자원 상한률·자동 회복 낭비율·명상/준비 선택률을 기록한다.
- 조건 난도별 실제 성공률·실패 지점·고점/저점 체감을 기록한다.
- 높은 능력치가 잘못된 계획을 구제한 사례를 기록한다.

## 4. 장기 보유 구조 가설

- 한 회차에 여러 무공을 익힐 수 있다.
- 해금 기술은 덱·손패·장착 제한 없이 사용 후보다.
- 수련포인트·회차 길이·해금 요구치가 실제 사용 기술 수를 제한한다.
- 정확한 장기 보유 한도는 T1 이후 결정한다.
- 중복 습득은 지정 수련으로 변환하고 성취 보너스를 재지급하지 않는다.
- 영구 메타 해금은 시작 선택지·도감·서사·외형·편의 중심이다.
- 여러 무공 보유가 정답 기술 모음으로 수렴하면 보유 구조를 재검토한다.

## 5. 세력 정체성 후보

현재 T0에는 세력 선택 런타임이 없다. 아래 시작 무공은 세력·문파 확장을 위한 후보이며 공용 전투 규칙을 대체하지 않는다.

| canonical ID | 무공 | 주 | 보조 | 기술1 | 기술2 | 역사 alias |
|---|---|---|---|---|---|---|
| `flowing_cloud_sword` | 유운검결 | 신법 | 외공 | 유운삼첩 | 낙영추검 | 동일 |
| `diamond_body_art` | 금강호체공 | 근골 | 내공 | 금강가세 | 반진권 | `vajra_body` |
| `taiji_flowing_sword` | 태극유전검 | 심안 | 내공 | 운수회신 | 사량발천근 | `taiji_flow` |
| `chasing_wind_spear` | 추풍창법 | 외공 | 신법 | 추풍일섬 | 연환쇄로 | `pursuing_wind_spear` |
| `clear_heart_nourishing_art` | 청심양생공 | 내공 | 근골 | 청심조식 | 회기전맥 | `clear_heart_nurturing` |
| `shadowless_ten_steps` | 무영십보 | 신법 | 심안 | 철각유영 | 십보환위 | `shadowless_steps` |

역사 ID는 `legacy_manual_alias`로만 보존한다.

시작 구조:

```text
기본2 × 5종 + 자유 분배6 + 선택 무공4개의 2성 주+1 = 총합20
```

| 성 | 성장 |
|---:|---|
| 1 | 고유 패시브 |
| 2 | 주+1 |
| 3 | 기술1·주4 요구 |
| 4 | 주+1·보조+1 |
| 5 | 기술1 무료20% 역할 강화 |
| 6 | 주+2·보조+1 |
| 7 | 기술2·주8 요구 |
| 8 | 주+3·보조+2 |
| 9 | 기술2 공개 정보 자동 분기 |
| 10 | 고유 절초·주12 요구 |

기술1 유효 비용은 `approved_20260804_existing_action_reprice_contract.json`, 효과·조건·5성은 `approved_20260804_technique1_conditional_rework_star5_contract.json`을 읽는다.

| 기술1 | 효과/예산/편차 | 5성 무료 예산 |
|---|---:|---:|
| 유운삼첩 | `58/61/-3` | 12 |
| 금강가세 | `31/31/0` | 6 |
| 운수회신 | `38/40/-2` | 8 |
| 추풍일섬 | `50/45/+5` | 9 |
| 청심조식 | `22/24/-2` | 5 |
| 철각유영 | `48/46/+2` | 9 |

유운삼첩은 총피해를 한 번 계산해 `40%/30%/나머지`로 분배하고 취소된 후속타 피해를 이월하지 않는다.

## 6. 기본 절초·10성 절초·진의

- 공용 절초 3종은 기존 T0 시스템 fixture이며 무공 10성 절초와 구분한다.
- 10성 절초는 해당 무공 주 영구 능력치12를 요구한다.
- 절초도 행동 슬롯·기력·내력·절초기세 비용을 가질 수 있다.
- 절초 비용은 일반 기술과 같은 자원 허용량 모델을 사용한다.
- 각 무공 절초의 효과·이동·사거리·조건·비용·예산은 아직 개별 승인되지 않았다.
- 진의는 T1 이후 장기 성장 가설이며 현재 제품 범위가 아니다.
- 절초가 거리·중단·회피·합을 무시하는 정답 행동이 되면 실패다.

## 7. 성장 진입 게이트

```text
STAR9_PUBLIC_READ_BRANCH_TEMPLATE
→ 여섯 개별 9성 자동 분기
→ 여섯 10성 고유 절초
→ 비스탯 노드 기대가치
→ 전투 종료 등급 산식·파밍 방지
→ 전체 핵심 재미 적대적 검토
→ 별도 Build 승인
```

9성 템플릿 필수:

- 공개 trigger.
- 자동 발동·추가 입력 없음.
- 실패 시 지급0 범위.
- 조건 가격·예상 성공률.
- 상대 대응 수단.
- 복기 성공·실패 문구.
- 기술1/2 대체율 측정.

Build 전에는 현재 repricing·기술1·기술2 계약, 승인될 9성·10성 계약, canonical ID migration, 조건 실패·연격·고정 이동 회귀 테스트가 필요하다.

## 8. 검증 기준

- 시작 총합20·평균4와 짝수 성 보상이 중복 지급되지 않는다.
- 요구치 미달 시 해당 기술만 잠기고 수련·기존 보상은 유지된다.
- 구형 기술1 계약을 현재 데이터 생성에 사용하지 않는다.
- 기술2는 기술1을 전 상황에서 대체하지 않는다.
- 9성은 공개 정보만 사용하고 추가 입력을 만들지 않는다.
- 10성 절초는 일반 거리·중단·자원 규칙을 따른다.
- `RESOURCE_SATURATION_RISK`, `CONDITION_CALIBRATION_RISK`, `WRONG_PLAN_RESCUE_RISK`, `OBSERVATION_ANSWER_LEAK_RISK`를 사람 검증에서 측정한다.
- 사람 검증 전 재미·밸런스 PASS를 주장하지 않는다.

생명주기:

- `[현행]`: 2026-08-04 전투·repricing·기술1 계약과 활성 성장 계약.
- `[대체됨]`: 2026-08-03 기술1 효과 Decision·contract.
- `[보류]`: PR #85 HTML Technique1 PoC.
- `[폐기]`: 현재 없음.

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
