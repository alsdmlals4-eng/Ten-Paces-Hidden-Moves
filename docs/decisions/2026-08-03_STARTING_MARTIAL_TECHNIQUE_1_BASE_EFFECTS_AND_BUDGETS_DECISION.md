# 여섯 시작 무공 3성 기술1 기본 효과·예산 결정

- Decision ID: `TEN-DEC-20260803-STARTING-MARTIAL-TECHNIQUE-1-BASE-EFFECTS-AND-BUDGETS-01`
- 승인일: 2026-08-03
- 상태: `CURRENT_APPROVED_PLANNING`
- 구현 권한: `PLANNING_ONLY`
- GrillMe 묶음: `5/10`
- 상세 계약: `docs/planning-data/approved_20260803_starting_martial_technique_1_base_effects_and_budgets_contract.json`

## 1. 승인 결론

여섯 시작 무공의 3성 기술1은 기존 PoC의 명칭과 핵심 이미지를 보존하되 현재 승인된 역할 우선·선택적 배수·기준 능력치4·사거리 구간 가격으로 다시 작성한다.

- 기술1은 해당 무공의 기본 운용법을 제공한다.
- 구조값은 고정 또는 주 능력치4 해금 임계로 제공하며 능력치 점당 연속 증가하지 않는다.
- 연속 수치 효과만 승인된 주 또는 선택적 보조 능력치를 참조한다.
- 5성 patch·7성 기술2·9성 분기·10성 절초는 이번 범위가 아니다.
- 제품 코드·Scene·런타임 데이터는 변경하지 않는다.

## 2. 예산 표시 규칙

모든 기술 승인표는 다음 항목을 분리 표시한다.

```text
효과 원가
+ 기력·내력·절초기세·체력 등 자원 소모 크레딧
+ 공개 조건 크레딧
= 최종 순예산
```

- `1틱 = 0.05 예산점`, `20틱 = 1.00 예산점`.
- 기력1 소모: `-4틱(-0.20점)`.
- 내력1 소모: `-7틱(-0.35점)`.
- 기력1+내력1 소모: `-11틱(-0.55점)`.
- 조건 크레딧은 자원 크레딧과 별도 열로 표시한다.
- 자원 크레딧을 숨기고 순예산만 표시한 표는 승인 근거로 사용할 수 없다.
- 환불·면제될 수 있는 비용에는 완전 크레딧을 부여하지 않는다.

## 3. 승인 기술과 투명 예산

| 무공·기술 | 구조·비용 | 기준 능력치4 효과 | 효과 원가 | 자원 소모 크레딧 | 조건 크레딧 | 최종 순예산 | 목표·편차 |
|---|---|---|---:|---:|---:|---:|---:|
| 유운검결 `유운삼첩` | 2수, 기력1·내력1, 거리1, 3연격 | 외공 기반 `4→3→3` | 58틱·2.90점 | -11틱·-0.55점 | 0 | 47틱·2.35점 | 50틱·-3 |
| 금강호체공 `금강가세` | 1수, 기력1·내력1, 자신 | 방어도5·강건1 | 30틱·1.50점 | -11틱·-0.55점 | 0 | 19틱·0.95점 | 20틱·-1 |
| 태극유전검 `운수회신` | 1수 반응, 기력1·내력1 | 회피1; 성공 시 이동1·내력1 회수 | 33틱·1.65점 | -11틱·-0.55점 | -5틱·-0.25점 | 17틱·0.85점 | 20틱·-3 |
| 추풍창법 `추풍일섬` | 1수, 기력1·내력1, 거리1~2 | 축 이동1 뒤 피해4 | 36틱·1.80점 | -11틱·-0.55점 | 0 | 25틱·1.25점 | 20틱·+5 |
| 청심양생공 `청심조식` | 1수, 무비용, 묶음당1회 | 기력1·내력1·방어도2 | 23틱·1.15점 | 0 | -4틱·-0.20점 | 19틱·0.95점 | 20틱·-1 |
| 무영십보 `철각유영` | 1수 이동, 기력1·내력1 | 자유 이동2·회피1 | 30틱·1.50점 | -11틱·-0.55점 | 0 | 19틱·0.95점 | 20틱·-1 |

모든 기술은 슬롯 목표의 자동 허용 편차 `±5틱` 안에 있다. `추풍일섬`은 상한 `+5틱`이므로 후속 강화가 기본 기술 예산을 무상 침범하지 않도록 별도 ledger를 사용한다.

## 4. 기술별 공식

### 유운검결 — 유운삼첩

```text
manual_id: flowing_cloud_sword
technique_id: flowing_cloud_triple
action_slots: 2
cost: stamina1 + internal1
range: 1
hit1 = floor(3 + EXTERNAL × 0.25)
hit2 = floor(2 + EXTERNAL × 0.25)
hit3 = floor(2 + EXTERNAL × 0.25)
```

신법4 해금이 고정 3연격 구조를 제공하고 외공은 별도 타격 피해에만 적용한다. 외공1/4/15의 총 원공격력은 `7/10/16`이다.

```text
피해50 + 추가타8 - 기력4 - 내력7 = 47틱
```

### 금강호체공 — 금강가세

```text
manual_id: diamond_body_art
legacy_manual_alias: vajra_body
technique_id: vajra_guard
action_slots: 1
cost: stamina1 + internal1
defense = floor(2 + CONSTITUTION × 0.75)
fortitude = 1
```

근골1/4/15의 방어도는 `2/5/13`이다. 강건은 고정 구조값이다.

```text
방어20 + 강건10 - 기력4 - 내력7 = 19틱
```

### 태극유전검 — 운수회신

```text
manual_id: taiji_flowing_sword
legacy_manual_alias: taiji_flow
technique_id: cloud_hand_return
action_slots: 1
resolution_phase: response
cost: stamina1 + internal1
evade: 1
on_evade_success:
  free_move: 1
  internal_gain = floor(INTERNAL × 0.25)
```

심안4 해금이 읽기·흘리기 구조를 제공하고 내공은 성공 뒤 별도 회수 효과에만 적용한다. 내공1/4/15의 회수량은 `0/1/3`이다.

```text
회피18 + 이동6 + 내력회수9 - 기력4 - 내력7 - 회피성공조건5 = 17틱
```

### 추풍창법 — 추풍일섬

```text
manual_id: chasing_wind_spear
legacy_manual_alias: pursuing_wind_spear
technique_id: pursuing_wind_thrust
action_slots: 1
cost: stamina1 + internal1
range: 1..2
before_attack_axis_move: choose advance1 or retreat1
damage = floor(2 + EXTERNAL × 0.50)
```

외공1/4/15의 피해는 `2/4/9`다. 사거리2는 현재 총 구간 가격 `10틱`을 사용하고 신법은 고정 축 이동1을 점당 증가시키지 않는다.

```text
피해20 + 사거리10 + 이동6 - 기력4 - 내력7 = 25틱
```

### 청심양생공 — 청심조식

```text
manual_id: clear_heart_nourishing_art
legacy_manual_alias: clear_heart_nurturing
technique_id: clear_heart_breath
action_slots: 1
cost: none
condition: once_per_bundle
stamina_gain: 1
internal_gain = floor(INTERNAL × 0.25)
defense = floor(1 + CONSTITUTION × 0.25)
```

능력치1/4/15에서 내력 회수는 `0/1/3`, 방어도는 `1/2/4`다. 무비용 반복 지연을 막기 위해 묶음당1회로 제한한다.

```text
기력회수6 + 내력회수9 + 방어8 - 묶음당1회조건4 = 19틱
```

### 무영십보 — 철각유영

```text
manual_id: shadowless_ten_steps
legacy_manual_alias: shadowless_steps
technique_id: iron_step_drift
action_slots: 1
cost: stamina1 + internal1
free_move: 2
evade: 1
```

신법4 해금이 고정 이동2·회피1 구조를 제공하며 심안 보조 배수는 기술1에 사용하지 않는다. 태극유전검은 성공 뒤 반응 이동, 무영십보는 선제적 능동 재배치다.

```text
이동12 + 회피18 - 기력4 - 내력7 = 19틱
```

## 5. canonical ID와 역사 alias

| 역사 PoC ID | canonical ID |
|---|---|
| `vajra_body` | `diamond_body_art` |
| `taiji_flow` | `taiji_flowing_sword` |
| `pursuing_wind_spear` | `chasing_wind_spear` |
| `clear_heart_nurturing` | `clear_heart_nourishing_art` |
| `shadowless_steps` | `shadowless_ten_steps` |

역사 ID는 `legacy_manual_alias`로만 보존하고 새 Decision·Sheet·향후 adapter는 canonical ID를 사용한다.

## 6. 병합 차단 조건

- 자원 소모 크레딧을 숨김.
- 환불·면제 비용에 완전 크레딧을 적용함.
- 구형 선형 사거리 가격을 현재 기술에 사용함.
- 같은 효과에 주·보조 배수를 중복함.
- 구조값을 능력치 점당 증가시킴.
- 청심조식을 묶음당 제한 없이 반복함.
- PoC 역사 ID와 canonical ID를 동시에 권위로 사용함.
- 승인된 `±5틱` 범위를 벗어나면서 별도 검토 없이 자동 수정함.

## 7. 후속 범위

아직 미확정:

- 여섯 무공의 7성 기술2 정확 효과·비용·계수
- 여섯 무공의 5성 기술1 patch 실제 효과·5틱 ledger
- 9성 수읽기 조건부 분기
- 10성 고유 절초
- 현재 합법 최대 능력치에서 사람 밸런스 검증

다음 우선 Decision은 `STARTING_MARTIAL_TECHNIQUE_2_BASE_EFFECTS_AND_BUDGETS`다.

## 8. 검증 경계

```yaml
product_code_changed: false
runtime_validation: NOT_RUN
godot_validation: NOT_RUN
windows_validation: NOT_RUN
accessibility_validation: NOT_RUN
human_validation: NOT_RUN
```
