# 여섯 시작 무공 3성 기술1 기본 효과·예산 결정

- Decision ID: `TEN-DEC-20260803-STARTING-MARTIAL-TECHNIQUE-1-BASE-EFFECTS-AND-BUDGETS-01`
- 승인일: 2026-08-03
- 상태: `CURRENT_APPROVED_PLANNING`
- 구현 권한: `PLANNING_ONLY`
- GrillMe 묶음: `5/10`
- 상세 계약: `docs/planning-data/approved_20260803_starting_martial_technique_1_base_effects_and_budgets_contract.json`
- 표시·구현 단순화 개정: `TEN-DEC-20260803-STARTING-MARTIAL-TECHNIQUE-2-BASE-EFFECTS-AND-BUDGETS-01`

## 1. 승인 결론

여섯 시작 무공의 3성 기술1은 기존 PoC의 명칭과 핵심 이미지를 보존하되 현재 승인된 역할 우선·선택적 배수·기준 능력치4·사거리 구간 가격으로 다시 작성한다.

- 기술1은 해당 무공의 기본 운용법을 제공한다.
- 구조값은 고정 또는 주 능력치4 해금 임계로 제공하며 능력치 점당 연속 증가하지 않는다.
- 연속 수치 효과만 승인된 주 또는 선택적 보조 능력치를 참조한다.
- 5성 patch·9성 분기·10성 절초는 이번 범위가 아니다.
- 제품 코드·Scene·런타임 데이터는 변경하지 않는다.
- 현재 구현 범위에서는 행동 묶음을 확정한 뒤 플레이어에게 추가 선택지를 요구하지 않는다.

## 2. 틱 단독 예산 표시 규칙

예산점 표기는 폐기한다. 승인표는 틱만 사용하며 다음 항목을 분리한다.

```text
효과 원가
/ 사용 가능 예산 = 슬롯 예산 + 기력·내력 등 자원 소모 예산 추가분 + 조건 예산 추가분
/ 편차 = 효과 원가 - 사용 가능 예산
```

예시:

```text
61틱 = 50틱(2수) + 7틱(내력1) + 4틱(기력1)
```

- 기력1 소모는 사용 가능 예산에 `+4틱`.
- 내력1 소모는 사용 가능 예산에 `+7틱`.
- 기력1+내력1 소모는 `+11틱`.
- 조건 예산은 자원 소모 예산과 별도 항목으로 표시한다.
- 자원 소모를 숨기거나 예산점으로 환산한 표는 현재 승인 근거로 사용하지 않는다.
- 환불·면제될 수 있는 비용에는 완전한 예산 추가분을 부여하지 않는다.
- 허용 편차는 `±5틱`.

## 3. 승인 기술과 틱 예산

| 무공·기술 | 구조·비용 | 기준 능력치4 효과 | 효과 원가 | 사용 가능 예산 | 편차 |
|---|---|---|---:|---:|---:|
| 유운검결 `유운삼첩` | 2수, 기력1·내력1, 거리1, 3연격 | 외공 기반 `4→3→3` | 58틱 | `50+4+7=61틱` | -3틱 |
| 금강호체공 `금강가세` | 1수, 기력1·내력1, 자신 | 방어도5·강건1 | 30틱 | `20+4+7=31틱` | -1틱 |
| 태극유전검 `운수회신` | 1수 반응, 기력1·내력1 | 회피1; 성공 시 고정 후퇴1·내력1 회수 | 33틱 | `20+4+7+5=36틱` | -3틱 |
| 추풍창법 `추풍일섬` | 1수, 기력1·내력1, 거리1~2 | 고정 전진1 뒤 피해4 | 36틱 | `20+4+7=31틱` | +5틱 |
| 청심양생공 `청심조식` | 1수, 무비용, 묶음당1회 | 기력1·내력1·방어도2 | 23틱 | `20+4=24틱` | -1틱 |
| 무영십보 `철각유영` | 1수 이동, 기력1·내력1 | 고정 후퇴2·회피1 | 30틱 | `20+4+7=31틱` | -1틱 |

모든 기술은 사용 가능 예산의 허용 편차 `±5틱` 안에 있다. `추풍일섬`은 상한 `+5틱`이므로 후속 5성 강화가 기본 기술 예산을 무상 침범하지 않도록 별도 ledger를 사용한다.

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
효과58 / 예산61 = 50(2수)+4(기력1)+7(내력1) / 편차-3틱
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
효과30 / 예산31 = 20(1수)+4(기력1)+7(내력1) / 편차-1틱
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
  fixed_retreat: 1
  internal_gain = floor(INTERNAL × 0.25)
```

심안4 해금이 읽기·흘리기 구조를 제공하고 내공은 성공 뒤 별도 회수 효과에만 적용한다. 내공1/4/15의 회수량은 `0/1/3`이다.

```text
효과33 / 예산36 = 20(1수)+4(기력1)+7(내력1)+5(회피성공조건) / 편차-3틱
```

### 추풍창법 — 추풍일섬

```text
manual_id: chasing_wind_spear
legacy_manual_alias: pursuing_wind_spear
technique_id: pursuing_wind_thrust
action_slots: 1
cost: stamina1 + internal1
range: 1..2
before_attack_axis_move: fixed advance1
damage = floor(2 + EXTERNAL × 0.50)
```

외공1/4/15의 피해는 `2/4/9`다. 행동 묶음 중 전진·후퇴를 다시 선택하지 않으며 항상 적 방향으로1칸 전진한 뒤 공격한다. 전진할 수 없으면 현재 위치에서 공격 판정을 계속한다. 사거리2는 현재 총 구간 가격 `10틱`을 사용하고 신법은 고정 전진1을 점당 증가시키지 않는다.

```text
효과36 / 예산31 = 20(1수)+4(기력1)+7(내력1) / 편차+5틱
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
효과23 / 예산24 = 20(1수)+4(묶음당1회조건) / 편차-1틱
```

### 무영십보 — 철각유영

```text
manual_id: shadowless_ten_steps
legacy_manual_alias: shadowless_steps
technique_id: iron_step_drift
action_slots: 1
cost: stamina1 + internal1
fixed_retreat: 2
evade: 1
```

행동 묶음 중 이동 방향·도착 타일을 다시 선택하지 않는다. 적에게서 멀어지는 방향으로 최대2칸 후퇴하며 경계나 점유 때문에2칸을 이동할 수 없으면 가능한 거리까지만 이동한다. 신법4 해금이 고정 이동2·회피1 구조를 제공하며 심안 보조 배수는 기술1에 사용하지 않는다.

```text
효과30 / 예산31 = 20(1수)+4(기력1)+7(내력1) / 편차-1틱
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

- 승인표에 예산점을 병기함.
- 자원 소모 예산 추가분을 숨김.
- 환불·면제 비용에 완전한 예산 추가분을 적용함.
- 행동 묶음 확정 뒤 플레이어 선택 창을 호출함.
- 이동 방향·도착 타일이 결정되지 않은 채 구현 인계함.
- 구형 선형 사거리 가격을 현재 기술에 사용함.
- 같은 효과에 주·보조 배수를 중복함.
- 구조값을 능력치 점당 증가시킴.
- 청심조식을 묶음당 제한 없이 반복함.
- PoC 역사 ID와 canonical ID를 동시에 권위로 사용함.
- 승인된 `±5틱` 범위를 벗어나면서 별도 검토 없이 자동 수정함.

## 7. 후속 범위

아직 미확정:

- 여섯 무공의 5성 기술1 patch 실제 효과·5틱 ledger
- 9성 수읽기 조건부 분기
- 10성 고유 절초
- 현재 합법 최대 능력치에서 사람 밸런스 검증

7성 기술2는 `TEN-DEC-20260803-STARTING-MARTIAL-TECHNIQUE-2-BASE-EFFECTS-AND-BUDGETS-01`에서 확정한다.

## 8. 검증 경계

```yaml
product_code_changed: false
runtime_validation: NOT_RUN
godot_validation: NOT_RUN
windows_validation: NOT_RUN
accessibility_validation: NOT_RUN
human_validation: NOT_RUN
```
