# 십보강호 세력·핵심무공·심법 성장 가설

> 전투 판정 책임 원본: `docs/02_COMBAT_RULES.md`  
> 성장 Decision: `TEN-DEC-20260806-TEN-RECOGNIZABLE-MARTIAL-MANUALS-FULL-GROWTH-01`  
> 런타임 Decision: `TEN_MANUAL_RUNTIME_IMPLEMENTATION_GATE`

## 현재 상태

```yaml
status: T1 이후 가설 원본
active_batch: 10/10
current_decision: TEN_MANUAL_RUNTIME_IMPLEMENTATION_GATE
parent_growth_decision: TEN-DEC-20260806-TEN-RECOGNIZABLE-MARTIAL-MANUALS-FULL-GROWTH-01
next_decision: TEN_MANUAL_UI_AI_ADOPTION_GATE
implementation_authority: RUNTIME_FOUNDATION
human_validation: NOT_RUN
balance_validation: NOT_RUN
```

초기 10권의 문파·3/5/7/9/10성 효과와 계획 예산은 기획 승인됐고, manifest·무공서별 데이터·숙련 레지스트리·순차 효과 pipeline·명시적 loadout 어댑터까지 런타임 기반으로 구현됐다. 프로젝트 코어가 사용자 승인됐다는 사실이나 런타임 기반 구현은 전체 UI·AI·사람·밸런스 검증 완료를 뜻하지 않는다.

현행 성장 권위:

- 기술1 효과·5성: `approved_20260804_technique1_conditional_rework_star5_contract.json`
- 기술2 유효 비용·슬롯: `approved_20260804_existing_action_reprice_contract.json`
- 7성·9성 예산 부모: `approved_20260805_star7_star9_mastery_bonus_contract.json`
- 초기 10권 의미·능력치 적합성·성급별 효과: `approved_20260806_ten_recognizable_martial_manuals_contract.json`
- 초기 10권 기술2·절초 계획 예산: `approved_20260806_ten_manual_growth_budget_overlay_contract.json`
- 런타임 manifest: `data/cards/martial_manual_cards.json`
- 무공서별 런타임 데이터: `data/cards/martial_manuals/`
- 숙련 레지스트리: `src/combat/martial_manual_registry.gd`
- 순차 효과 pipeline: `src/combat/martial_effect_pipeline.gd`
- 전투 호환 어댑터: `src/combat/combat_resolution_engine_ten_manuals.gd`
- 등급 파밍 가드레일: `approved_20260805_grade_farming_guardrails_contract.json`
- `approved_20260803_starting_martial_technique_1_base_effects_and_budgets_contract.json`은 `[대체됨]` 역사 증거다.

## 현행 전투 계약과 연결 원칙

```text
가치 상위호환 + 역할 비대체
```

- 3성 기술1: 무공의 기본 초식.
- 5성: 기술1의 기존 역할을 무료로 강화.
- 7성 기술2: 같은 무공 원리를 다른 전술 역할로 응용.
- 9성: 기술2를 분기하지 않고 단일 완성 보너스 효과 하나 추가.
- 10성: 별도 고유 절초.

기술 카드는 `action_slots`, 기력·내력 비용, 거리·이동, `sure_hit` 등 승인 필드를 명시적으로 다룬다. 7성·9성·10성은 거리·순서·합·회피·중단 실패를 자동 삭제하지 않는다.

능력치 배정 원칙:

- 주·보조능력치별 무공서 권수·균등 분포·최소/최대 쿼터를 사용하지 않는다.
- 문파의 무학 철학, 기술 동작, 피해·방어·이동 방식과의 적합성만 판정한다.
- 같은 능력치가 여러 권에 반복되거나 특정 능력치가 적게 등장해도 자체로 결함이 아니다.

### 예산 공식

```text
star7_final_budget_ticks
= effective_technique2_available_budget_ticks + 10

star9_bonus_ticks
= 10 + floor(star7_final_budget_ticks × 0.20)

star9_total_budget_ticks
= star7_final_budget_ticks + star9_bonus_ticks
```

9성 | 기술2 단일 완성 보너스. 효과는 정확히 하나이며 분기·추가입력·추가비용이 없다.

## 다음 PoC 성장 실험

### 성장 단계

| 성급 | 보상 | 역할 |
|---:|---|---|
| 2성 | 주능력치 +1 | 기초 성장 |
| 3성 | 기술1 해금 | 기본 초식 |
| 4성 | 주+1·보조+1 | 기반 확장 |
| 5성 | 기술1 무료 patch | 같은 기술을 더 잘 사용 |
| 6성 | 주+2·보조+1 | 기술2 준비 |
| 7성 | 기술2 + 통합 예산10틱 | 같은 무공의 다른 전술 응용 |
| 8성 | 주+3·보조+2 | 절초 준비 |
| 9성 | 기술2 단일 완성 효과 | `10 + floor(7성 최종 예산×20%)` |
| 10성 | 고유 절초 | 무공 최종 경지 |

런타임 레지스트리는 숙련도 3·5·7·9·10에서 다음을 결정적으로 합성한다.

- 3성: star3 카드 1개.
- 5성: star3 카드에 star5 overlay.
- 7성: star3 + star7.
- 9성: star7에 정확히 한 단계의 star9 overlay.
- 10성: star3 + star7 + star10.

원본 JSON은 deep copy를 통해 보존한다.

## 장기 보유 구조 가설

- 플레이어는 회차 중 배운 무공과 상대 정보를 발견 기록으로 축적한다.
- 영구 성장은 전투 수치만 누적하지 않고 정보·시작 선택지·외형·서사를 확장한다.
- 같은 무공의 성급 상승은 동작 감각과 철학을 유지한다.
- 높은 성급은 낮은 성급보다 가치가 높아도 사용 시점과 역할은 달라야 한다.
- 7성 뒤 기술1 사용률이 사실상 0이 되면 `MASTERY_ROLE_REPLACEMENT_RISK`로 재검토한다.

## 세력 정체성 후보

현재 10권:

| 문파·유파 | 무공서 | 주 / 보조 | 10성 절초 |
|---|---|---|---|
| 화산파 | 매화검결 | 신법 / 외공 | 이십사수매화검법 |
| 소림사 | 나한금강공 | 외공 / 내공 | 여래신장 |
| 무당파 | 태극검결 | 심안 / 내공 | 태극혜검 |
| 양가 | 양가창결 | 외공 / 신법 | 회마창 |
| 화산파 | 자하심법 | 내공 / 근골 | 자하신공 |
| 소요파 | 소요보결 | 신법 / 심안 | 능파미보 |
| 개방 | 강룡장결 | 내공 / 근골 | 항룡십팔장 |
| 사천당문 | 천기암기록 | 심안 / 신법 | 만천화우 |
| 하북팽가 | 팽가도결 | 근골 / 외공 | 오호단문도 |
| 남궁세가 | 창궁무애검법 | 내공 / 심안 | 제왕검형 |

역사적 6권 역할표는 Git 기록과 이전 승인 계약에서 migration·회귀 목적으로만 보존한다. 현재 표시명·문파·능력치·성장 효과는 2026-08-06 10권 계약과 카탈로그를 따른다.

## 기본 절초·10성 절초·진의

현재 기본 엔진의 공용 절초 3종은 역사 PoC·호환 회귀 데이터로 유지된다. 초기 10권의 고유 절초는 런타임 데이터와 effect pipeline에 등록됐지만, 전체 행동 선택 UI와 AI에는 아직 자동 채택되지 않았다.

- 기본 절초: 공용 전투 회귀 검증용.
- 10성 절초: 무공별 최종 경지이며 명시적 loadout을 통해 런타임 실행 가능.
- 진의: 10성 이후 장기 확장 가설이며 현재 `DEFERRED`.

## 성장 진입 게이트

완료:

```text
TEN_MANUAL_RUNTIME_IMPLEMENTATION_GATE
→ RED 런타임 계약
→ 10권 manifest·분할 데이터
→ 숙련 레지스트리
→ 순차 효과 pipeline
→ 전투 호환 어댑터
→ exact-head 자동 검증
```

다음:

```text
TEN_MANUAL_UI_AI_ADOPTION_GATE
→ 행동 선택 UI 명시적 loadout 연결
→ 공개 상태 AI 후보 행동 연결
→ Godot·Windows·접근성·성능 검증
→ 사람·밸런스 검증
→ NON_STAT_NODE_EXPECTED_VALUE_AND_WEIGHT
```

## 검증 기준

자동 검증:

- exact 10권 roster·문파·능력치·성급 구조.
- stat quota 비활성.
- 5성 대상 star3, 9성 대상 star7·단일 단계.
- 자하신공 사용권 선소모·미환불·완료 기세.
- 나한금강공 상태 선행과 제한된 강건.
- 회마창 이동 뒤 사거리 재검사.
- 능파미보 반격 뒤 이동.
- 만천화우 독립 공격 4회.
- 기본 행동·공용 절초 카드 ID 호환.
- PR Validation·Full Validation·전용 runtime workflow.

사람 검증:

- 기술1/기술2 선택률과 7성 뒤 대체율.
- 문파·무공서와 주·보조능력치 적합성 체감.
- 9성 한 문장 효과 이해율.
- 자하 사용권·강건·회마창 실패 원인 이해도.
- 절초가 해당 무공서를 선택한 이유로 체감되는 비율.

현재 Windows·접근성·성능·사람·밸런스 검증은 `NOT_RUN`이다.
