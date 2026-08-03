# 여섯 시작 무공 7성 기술2 기본 효과·틱 예산 결정

- Decision ID: `TEN-DEC-20260803-STARTING-MARTIAL-TECHNIQUE-2-BASE-EFFECTS-AND-BUDGETS-01`
- 승인일: 2026-08-03
- 상태: `CURRENT_APPROVED_PLANNING`
- 구현 권한: `PLANNING_ONLY`
- GrillMe 묶음: `6/10`
- 상세 계약: `docs/planning-data/approved_20260803_starting_martial_technique_2_base_effects_and_budgets_contract.json`

## 1. 승인 결론

권장 B안인 상태 전환형 7성 기술2를 채택한다. 기술2는 기술1의 단순 상위호환이 아니라, 이미 공개된 전투 상태·성공 조건·거리 상태를 고정된 후속 결과로 전환하는 고급 운용법이다.

추가 구현 제약:

- 승인·작성 예산 단위는 틱만 사용한다.
- 예산점 환산과 병기를 사용하지 않는다.
- 행동 묶음을 확정한 뒤 플레이어에게 추가 선택지를 요구하지 않는다.
- 전진·후퇴·회피 후 이동·적중 후 이동은 모두 고정 방향과 경계 규칙을 가진다.
- 선택형 이동·후속 행동은 별도 Decision 전까지 `DEFERRED`다.
- 제품 코드·Scene·런타임 데이터는 변경하지 않는다.

## 2. 틱 단독 예산 계약

```text
사용 가능 예산
= 슬롯 예산
+ 확정 지불하는 기력·내력 등 자원 소모 예산 추가분
+ 공개 조건 예산 추가분

편차
= 효과 원가 - 사용 가능 예산
```

기준:

- 1수 `20틱`
- 2수 `50틱`
- 3수 `80틱`
- 기력1 소모 `+4틱`
- 내력1 소모 `+7틱`
- 기력1+내력1 소모 `+11틱`
- 기존 방어 필요 `+4틱`
- 회피 성공 필요 `+5틱`
- 합 승리 필요 `+5틱`
- 엄격한 공개 저자원 조건 `+7틱`
- 허용 편차 `±5틱`

예시:

```text
낙영추검 사용 가능 예산
= 50틱(2수) + 7틱(내력1) + 4틱(기력1)
= 61틱
```

환불·면제되는 비용에는 완전한 예산 추가분을 주지 않는다. 자원 회복과 자원 소모는 별도 ledger 항목이다.

## 3. 승인된 여섯 7성 기술2

| 무공·기술 | 고정 실행 구조 | 기준 능력치4 효과 | 효과 원가 | 사용 가능 예산 | 편차 |
|---|---|---|---:|---:|---:|
| 유운검결 `낙영추검` | 2수·기력1·내력1·고정 전진1·거리1~2 공격 | 피해 `floor(5+외공×0.75)=8` | 56틱 | `50+4+7=61틱` | -5틱 |
| 금강호체공 `반진권` | 기존 방어 필요·2수·기력1·내력1·적중 후 방어·강건 | 피해8·방어4·강건1 | 66틱 | `50+4+7+4=65틱` | +1틱 |
| 태극유전검 `사량발천근` | 2수·기력1·내력1·합 승리 시 방어 획득 | 피해8·합 위력4·방어4 | 68틱 | `50+4+7+5=66틱` | +2틱 |
| 추풍창법 `연환쇄로` | 2수·기력1·내력1·거리1~2·2연격·적중 시 고정 후퇴1 | 피해 `5→4` | 65틱 | `50+4+7=61틱` | +4틱 |
| 청심양생공 `회기전맥` | 현재 기력+내력≤2·2수·기력1·회복·내력·방어·강건 | 체력4·내력2·방어2·강건1 | 60틱 | `50+4+7=61틱` | -1틱 |
| 무영십보 `십보환위` | 2수 반응·기력1·내력1·회피 성공 시 고정 후퇴2 후 거리1~2 반격 | 회피1·반격피해6 | 70틱 | `50+4+7+5=66틱` | +4틱 |

모든 기술은 허용 편차 `±5틱` 안에 있다.

## 4. 기술별 고정 실행 계약

### 유운검결 — 낙영추검

```text
manual_id: flowing_cloud_sword
technique_id: falling_petal_chasing_sword
category: attack
action_slots: 2
cost: stamina1 + internal1
before_attack:
  fixed_advance: 1
range: 1..2
damage = floor(5 + EXTERNAL × 0.75)
```

실행 순서:

```text
적 방향 전진1
→ 거리1~2 공격
```

전진할 수 없으면 현재 위치에서 공격 판정을 계속한다. 행동 도중 전진·후퇴를 다시 고르지 않는다. 기준 외공4에서 피해8이며 효과 원가는 `피해40+사거리10+전진6=56틱`이다.

```text
효과56 / 예산61 = 50(2수)+4(기력1)+7(내력1) / 편차-5틱
```

유운삼첩은 3연격 압박, 낙영추검은 고정 전진과 거리2 단일 공격으로 역할이 다르다.

### 금강호체공 — 반진권

```text
manual_id: diamond_body_art
legacy_manual_alias: vajra_body
technique_id: rebounding_vajra_fist
category: attack
action_slots: 2
cost: stamina1 + internal1
condition: current_defense >= 1
range: 1
damage = floor(4 + CONSTITUTION × 1.00)
on_hit:
  defense = floor(2 + INTERNAL × 0.50)
  fortitude = 1
```

기존 방어가 없으면 배치할 수 없다. 조건을 충족해 배치한 뒤에는 추가 선택 없이 공격하고, 적중하면 방어·강건을 고정 획득한다. 기준 능력치4에서 피해8·방어4·강건1이다.

```text
효과66 / 예산65 = 50(2수)+4(기력1)+7(내력1)+4(기존방어조건) / 편차+1틱
```

금강가세는 방어 준비, 반진권은 이미 준비한 방어를 공격 압박으로 전환한다.

### 태극유전검 — 사량발천근

```text
manual_id: taiji_flowing_sword
legacy_manual_alias: taiji_flow
technique_id: four_ounces_move_thousand_pounds
category: attack
action_slots: 2
cost: stamina1 + internal1
range: 1
damage = floor(4 + INSIGHT × 1.00)
clash_power_bonus = floor(2 + INSIGHT × 0.50)
on_clash_win:
  defense = floor(INTERNAL × 1.00)
```

합 승리 여부에 따라 자동으로 방어를 획득할 뿐, 합 뒤 별도 반격·방향·보상 선택 창을 호출하지 않는다. 기준 능력치4에서 피해8·합 위력4·방어4다.

```text
효과68 / 예산66 = 50(2수)+4(기력1)+7(내력1)+5(합승리조건) / 편차+2틱
```

운수회신은 회피 대응, 사량발천근은 합 대응이다.

### 추풍창법 — 연환쇄로

```text
manual_id: chasing_wind_spear
legacy_manual_alias: pursuing_wind_spear
technique_id: chained_road_lock
category: attack
action_slots: 2
cost: stamina1 + internal1
range: 1..2
hit1 = floor(2 + EXTERNAL × 0.75)
hit2 = floor(2 + EXTERNAL × 0.50)
after_at_least_one_hit:
  fixed_retreat: 1
```

한 타 이상 적중하면 적 반대 방향으로1칸 후퇴한다. 적중 후 전진·후퇴를 선택하지 않는다. 후퇴할 수 없으면 현재 위치를 유지한다. 기준 외공4에서 `5→4`다.

```text
효과65 / 예산61 = 50(2수)+4(기력1)+7(내력1) / 편차+4틱
```

추풍일섬은 공격 전 고정 전진, 연환쇄로는 적중 뒤 고정 후퇴다.

### 청심양생공 — 회기전맥

```text
manual_id: clear_heart_nourishing_art
legacy_manual_alias: clear_heart_nurturing
technique_id: returning_qi_meridian
category: recovery
action_slots: 2
cost: stamina1
condition: current_stamina + current_internal <= 2
target: self
health_heal = floor(2 + CONSTITUTION × 0.50)
internal_gain = 2
defense = floor(1 + INTERNAL × 0.25)
fortitude = 1
```

저자원 조건은 공개된 현재 자원만 사용한다. 발동 뒤 회복 종류나 배분을 다시 선택하지 않는다. 기준 능력치4에서 체력4·내력2·방어2·강건1이다.

```text
효과60 / 예산61 = 50(2수)+4(기력1)+7(엄격저자원조건) / 편차-1틱
```

청심조식은 평시 정비, 회기전맥은 저자원 위기 안정화다.

### 무영십보 — 십보환위

```text
manual_id: shadowless_ten_steps
legacy_manual_alias: shadowless_steps
technique_id: ten_paces_position_reversal
category: response
action_slots: 2
cost: stamina1 + internal1
evade: 1
on_evade_success:
  fixed_retreat: up_to_2_away_from_enemy
  counter_range: 1..2
  counter_damage = floor(2 + INSIGHT × 1.00)
```

회피 성공 시 적에게서 멀어지는 방향으로 최대2칸 후퇴하고 즉시 반격한다. 도착 타일이나 반격 여부를 다시 선택하지 않는다. 경계·점유 때문에2칸을 이동할 수 없으면 가능한 거리까지만 이동한 뒤 반격 가능 거리를 판정한다. 기준 심안4에서 반격 피해6이다.

```text
효과70 / 예산66 = 50(2수)+4(기력1)+7(내력1)+5(회피성공조건) / 편차+4틱
```

철각유영은 선제 회피·후퇴, 십보환위는 회피 성공 뒤 고정 후퇴·반격이다.

## 5. 기술1과 기술2의 비대체성

| 무공 | 기술1 | 기술2 | 대체 방지 이유 |
|---|---|---|---|
| 유운검결 | 유운삼첩: 3연격 | 낙영추검: 전진·거리2 단타 | 연격 합 압박과 접근 단타가 다름 |
| 금강호체공 | 금강가세: 방어 준비 | 반진권: 기존 방어 요구 공격 | 준비와 전환의 순서가 다름 |
| 태극유전검 | 운수회신: 회피 대응 | 사량발천근: 합 대응 | 대응하는 적 행동군이 다름 |
| 추풍창법 | 추풍일섬: 공격 전 전진 | 연환쇄로: 적중 후 후퇴 | 진입과 간격 회수 역할이 다름 |
| 청심양생공 | 청심조식: 평시 정비 | 회기전맥: 저자원 위기 안정 | 발동 조건과 사용 시점이 다름 |
| 무영십보 | 철각유영: 선제 후퇴·회피 | 십보환위: 성공 뒤 반격 | 안전 확보와 반격 전환이 다름 |

## 6. 현재 구현 단순화

이번 범위에서 금지:

- 행동 묶음 해결 도중 선택 창 표시
- 공격 뒤 전진·후퇴 선택
- 회피 뒤 도착 타일 선택
- 다수 후속 효과 중 하나 선택
- 조건 충족 뒤 효과 수령 여부 선택

현재 고정 방향:

- `ADVANCE`: 적 방향
- `RETREAT`: 적 반대 방향
- 경계·점유 충돌 시 가능한 거리까지만 이동
- 이동 불가 시 현재 위치 유지
- 공격·반격은 승인된 거리와 대상 유효성 규칙으로 자동 판정

향후 선택형 기술은 입력 UX·중단/재개·AI·저장·복기 계약을 별도 승인한 뒤에만 추가한다.

## 7. 병합 차단 조건

- 예산점을 승인표에 병기함.
- 효과 원가와 사용 가능 예산을 구분하지 않음.
- 자원 소모 예산 추가분을 숨김.
- 환불·면제 비용에 완전한 예산 추가분을 적용함.
- 행동 묶음 해결 중 추가 입력을 요구함.
- 이동 방향·경계 규칙이 결정되지 않음.
- 기술2가 모든 상황에서 기술1을 대체함.
- 미공개 계획·AI 가중치·정답 대응표를 참조함.
- 같은 효과에 주·보조 배수를 중복함.
- 구조값을 능력치 점당 증가시킴.
- `±5틱` 범위를 벗어나면서 별도 검토 없이 승인함.

## 8. 후속 범위

다음 우선 Decision:

`STARTING_MARTIAL_TECHNIQUE_1_STAR5_ROLE_PATCHES`

후속:

- 여섯 5성 기술1 역할 강화 patch와 각 `5틱` ledger
- 여섯 9성 공개 정보 기반 자동 조건 분기
- 무공별 10성 고유 절초
- 비스탯 노드 기대가치·배치
- 고능력치·반복 사용·기술1/2 선택률 사람 검증

## 9. 검증 경계

```yaml
product_code_changed: false
runtime_validation: NOT_RUN
godot_validation: NOT_RUN
windows_validation: NOT_RUN
accessibility_validation: NOT_RUN
human_validation: NOT_RUN
```
