# 여섯 시작 무공 3성 기술1 기본 효과·예산 결정

- Decision ID: `TEN-DEC-20260803-STARTING-MARTIAL-TECHNIQUE-1-BASE-EFFECTS-AND-BUDGETS-01`
- 승인일: 2026-08-03
- 상태: `CURRENT_APPROVED_PLANNING`
- 구현 권한: `PLANNING_ONLY`
- GrillMe 묶음: `5/10`
- 선행 결정:
  - `TEN-DEC-20260802-TECHNIQUE-AUTHORING-TAG-FIXED-STAT-01`
  - `TEN-DEC-20260802-STAT-REFERENCE-PRICE-BASE4-01`
  - `TEN-DEC-20260802-RANGE-PRICE-BANDS-01`
  - `TEN-DEC-20260803-MARTIAL-TECHNIQUE-ROLE-AND-SCALING-MATRIX-01`

## 1. 승인 결론

여섯 시작 무공의 3성 기술1은 기존 PoC의 명칭과 핵심 이미지를 보존하되, 현재 승인된 역할 우선·선택적 배수·기준 능력치4·사거리 구간 가격으로 다시 작성한다.

- 기술1은 해당 무공의 기본 운용법을 제공한다.
- 구조값은 고정 또는 주 능력치4 해금 임계로 제공하며 능력치 점당 연속 증가하지 않는다.
- 연속 수치 효과만 승인된 주 또는 선택적 보조 능력치를 참조한다.
- 정확한 5성 patch는 이번 Decision에 포함하지 않는다.
- 제품 코드·Scene·런타임 데이터는 변경하지 않는다.

## 2. 예산 표시 규칙

사용자 검토 시 예산을 다음 순서로 반드시 분리해서 표시한다.

```text
효과 원가
+ 기력·내력·절초기세·체력 등 자원 소모 크레딧
+ 공개 조건 크레딧
= 최종 순예산
```

- `1틱 = 0.05 예산점`, `20틱 = 1.00 예산점`이다.
- 자원 소모로 얻는 예산은 음수 크레딧으로 표시한다.
- 기력1 소모는 `-4틱(-0.20점)`, 내력1 소모는 `-7틱(-0.35점)`이다.
- 기력1+내력1 소모는 합계 `-11틱(-0.55점)`이다.
- 조건 크레딧은 자원 소모와 별도 열에 표시한다.
- 최종 순예산만 보여 주고 자원 소모 크레딧을 숨기는 표는 이후 승인 자료로 사용할 수 없다.

## 3. 승인 기술과 예산

| 무공·기술 | 구조·비용 | 기준 능력치4 효과 | 효과 원가 | 자원 소모 크레딧 | 조건 크레딧 | 최종 순예산 | 목표·편차 |
|---|---|---|---:|---:|---:|---:|---:|
| 유운검결 `유운삼첩` | 2수, 기력1·내력1, 거리1, 3연격 | 외공 기반 `4→3→3` | 58틱·2.90점 | -11틱·-0.55점 | 0 | 47틱·2.35점 | 50틱·-3 |
| 금강호체공 `금강가세` | 1수, 기력1·내력1, 자신 | 방어도5·강건1 | 30틱·1.50점 | -11틱·-0.55점 | 0 | 19틱·0.95점 | 20틱·-1 |
| 태극유전검 `운수회신` | 1수 반응, 기력1·내력1 | 회피1; 성공 시 이동1·내력1 회수 | 33틱·1.65점 | -11틱·-0.55점 | -5틱·-0.25점 | 17틱·0.85점 | 20틱·-3 |
| 추풍창법 `추풍일섬` | 1수, 기력1·내력1, 거리1~2 | 축 이동1 뒤 피해4 | 36틱·1.80점 | -11틱·-0.55점 | 0 | 25틱·1.25점 | 20틱·+5 |
| 청심양생공 `청심조식` | 1수, 무비용, 묶음당1회 | 기력1·내력1·방어도2 | 23틱·1.15점 | 0 | -4틱·-0.20점 | 19틱·0.95점 | 20틱·-1 |
| 무영십보 `철각유영` | 1수 이동, 기력1·내력1 | 자유 이동2·회피1 | 30틱·1.50점 | -11틱·-0.55점 | 0 | 19틱·0.95점 | 20틱·-1 |

모든 기술은 슬롯 목표의 자동 허용 편차 `±5틱` 안에 있다. `추풍일섬`은 정확히 상한 `+5틱`이므로 후속 5성 patch가 기본 기술 예산을 무상으로 침범하지 않도록 별도 ledger를 유지한다.

## 4. 기술별 계약

### 4.1 유운검결 — 유운삼첩

```text
manual_id: flowing_cloud_sword
technique_id: flowing_cloud_triple
action_slots: 2
cost: stamina1 + internal1
range: 1
hit_count: 3
primary_binding: MOVEMENT4 unlocks fixed three-hit chain structure
secondary_formula:
  hit1 = floor(3 + EXTERNAL × 0.25)
  hit2 = floor(2 + EXTERNAL × 0.25)
  hit3 = floor(2 + EXTERNAL × 0.25)
```

- 신법은 3성 주 능력치4 해금과 연격 구조의 책임이다.
- 외공은 구분된 실제 타격 피해에만 적용한다.
- 신법이 이동거리와 피해를 동시에 연속 증가시키지 않는다.
- 기준 외공1/4/15의 총 원공격력은 각각 `7/10/16`이다.

예산:

```text
피해50 + 추가타8 - 기력4 - 내력7 = 47틱
```

### 4.2 금강호체공 — 금강가세

```text
manual_id: diamond_body_art
legacy_manual_alias: vajra_body
technique_id: vajra_guard
action_slots: 1
cost: stamina1 + internal1
target: self
defense = floor(2 + CONSTITUTION × 0.75)
fortitude = 1
```

- 내공 보조 배수는 사용하지 않는다.
- 기준 근골1/4/15의 방어도는 `2/5/13`이다.
- 강건은 고정 구조값이며 점당 증가하지 않는다.

예산:

```text
방어20 + 강건10 - 기력4 - 내력7 = 19틱
```

### 4.3 태극유전검 — 운수회신

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

- 심안4 해금이 읽기·흘리기 반응 구조를 제공한다.
- 내공은 성공 뒤 별도 자원 회수 효과에만 적용한다.
- 기준 내공1/4/15의 회수량은 `0/1/3`이다.
- 공격 성공 전에는 이동·내력 회수를 얻지 않는다.

예산:

```text
회피18 + 이동6 + 내력회수9 - 기력4 - 내력7 - 회피성공조건5 = 17틱
```

### 4.4 추풍창법 — 추풍일섬

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

- 외공은 찌르기 피해에 적용한다.
- 신법은 고정 축 이동1의 보조 구조 책임이며 점당 이동거리를 늘리지 않는다.
- 기준 외공1/4/15의 피해는 `2/4/9`다.
- 최대 사거리2는 현재 구간 가격 `10틱`을 사용한다.

예산:

```text
피해20 + 사거리10 + 이동6 - 기력4 - 내력7 = 25틱
```

### 4.5 청심양생공 — 청심조식

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

- 내공은 내력 회수, 근골은 구분된 방어 안정 효과에 적용한다.
- 기준 능력치1/4/15에서 내력 회수는 `0/1/3`, 방어도는 `1/2/4`다.
- 무비용 반복 지연을 막기 위해 묶음당1회로 제한한다.

예산:

```text
기력회수6 + 내력회수9 + 방어8 - 묶음당1회조건4 = 19틱
```

### 4.6 무영십보 — 철각유영

```text
manual_id: shadowless_ten_steps
legacy_manual_alias: shadowless_steps
technique_id: iron_step_drift
action_slots: 1
cost: stamina1 + internal1
free_move: 2
evade: 1
```

- 신법4 해금이 이동2·회피1의 고정 보법 구조를 제공한다.
- 심안 보조 배수는 기술1에 사용하지 않는다.
- 신법 증가로 이동거리나 회피 횟수가 점당 늘지 않는다.
- 태극유전검은 성공 뒤 반응 이동, 무영십보는 선제적 능동 재배치로 역할을 구분한다.

예산:

```text
이동12 + 회피18 - 기력4 - 내력7 = 19틱
```

## 5. canonical ID와 역사 alias

새 승인 계약은 다음 canonical 무공 ID를 사용한다.

| 역사 PoC ID | canonical ID |
|---|---|
| `vajra_body` | `diamond_body_art` |
| `taiji_flow` | `taiji_flowing_sword` |
| `pursuing_wind_spear` | `chasing_wind_spear` |
| `clear_heart_nurturing` | `clear_heart_nourishing_art` |
| `shadowless_steps` | `shadowless_ten_steps` |

- 역사 ID는 `legacy_manual_alias`로만 보존한다.
- 새 Decision·Sheet·런타임 adapter는 canonical ID를 사용한다.
- 과거 PoC 파일의 역사 가설을 현재 승인값으로 오인하지 않는다.

## 6. 적대적 검토와 병합 차단 조건

- 자원 소모 크레딧을 숨기고 순예산만 표시함.
- 환불·면제될 수 있는 비용에 완전 크레딧을 적용함.
- 구형 `range_per_tile_beyond_one` 선형 가격을 현재 기술에 사용함.
- 유운검결의 신법이 이동거리와 피해를 동시에 점당 증가시킴.
- 금강가세가 무조건 무적 또는 모든 계획 실패를 구제함.
- 운수회신이 회피 성공 전 이동·회수를 제공하거나 숨은 계획을 읽음.
- 추풍일섬이 사거리2·이동·피해를 예산 상한보다 더 확장함.
- 청심조식이 묶음당 제한 없이 무비용 반복됨.
- 철각유영의 이동거리·회피 횟수가 신법 점당 증가함.
- PoC 역사 ID와 canonical ID가 동시에 권위로 사용됨.

## 7. 아직 미확정

- 여섯 무공의 5성 기술1 patch 실제 효과·5틱 ledger
- 여섯 무공의 7성 기술2 정확 효과·비용·계수
- 9성 수읽기 조건부 분기
- 10성 고유 절초
- 현재 합법 최대 능력치에서 사람 밸런스 검증

다음 우선 Decision은 `STARTING_MARTIAL_TECHNIQUE_1_STAR5_ROLE_PATCHES`다. 7성 기술2보다 먼저 기술1의 완성 성장선을 고정해 시작 기술의 사용감과 예산 상한을 닫는다.

## 8. 검증 경계

```yaml
product_code_changed: false
runtime_validation: NOT_RUN
godot_validation: NOT_RUN
windows_validation: NOT_RUN
accessibility_validation: NOT_RUN
human_validation: NOT_RUN
```
