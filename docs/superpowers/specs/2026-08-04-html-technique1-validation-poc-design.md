# HTML 여섯 무공 기술1 구현 검증 PoC 설계

> Spec ID: `TEN-SPEC-20260804-HTML-TECHNIQUE1-VALIDATION-POC-01`  
> 상태: `SPEC_REVIEW`  
> 작업 모드: `PLAN`  
> 구현 담당: `Codex`  
> 기획·핵심 재미·UX·연출·아트 책임: `GPT`  
> 기준 기획 HEAD: `463a6cd7d6a94e7ee679ef653feabbc06ccbadb3`  
> 대상: `PC 16:9 / 정적 HTML·CSS·JavaScript`  
> 목적: 여섯 시작 무공의 3성 기술1이 최신 승인 기획대로 계산·판정·표현되는지 검증

## 1. 검증 목적

이 PoC는 전체 회차의 재미나 성장 속도를 검증하는 버티컬 슬라이스가 아니다.

핵심 질문은 다음 하나다.

> 플레이어와 공개 상태 기반 AI가 여섯 무공의 기술1을 모두 사용할 때 각 기술의 슬롯, 비용, 공식, 이동, 조건, 판정, 후속 효과, UX, 모션이 최신 승인 기획과 일치하는가?

전투에서 승리해도 구현 계약과 다르면 해당 기술은 `FAIL`이다. 기술 간 최종 밸런스와 장기 재미는 후속 사람 검증으로 남긴다.

## 2. 권위와 검토 범위

### 2.1 권위 순서

1. 최신 사용자 승인 Decision
2. 최신 approved planning JSON
3. `docs/02_COMBAT_RULES.md`
4. 연결된 Google Sheet의 `CURRENT_APPROVED_PLANNING`
5. 현행 Godot 런타임·데이터

현행 런타임이 최신 기획과 다르면 HTML PoC는 최신 기획을 따른다. 과거 런타임 값은 호환·연출·검증 fixture로만 사용한다.

### 2.2 직접 검토한 책임 원본

- `docs/02_COMBAT_RULES.md`
- `docs/decisions/2026-07-24_PREPARE_AND_AUTO_PLACEMENT_RULE_CHANGE.md`
- `docs/decisions/2026-07-31_COMBAT_ROUTE_AND_CHAMPION_DECISION.md`
- `docs/decisions/2026-08-01_MARTIAL_MANUAL_TECHNIQUE_TIMELINE_UX_DECISION.md`
- `docs/decisions/2026-08-02_OBSERVATION_STATS_MASTERY_DECISION.md`
- `docs/decisions/2026-08-02_BASIC_ACTIONS_PALM_CLASH_DECISION.md`
- `docs/decisions/2026-08-02_OUT_OF_RANGE_CLASH_REWARD_DECISION.md`
- `docs/decisions/2026-08-03_STARTING_MARTIAL_TECHNIQUE_1_BASE_EFFECTS_AND_BUDGETS_DECISION.md`
- `docs/planning-data/approved_20260801_martial_technique_timeline_ux_contract.json`
- `docs/planning-data/approved_20260803_starting_martial_technique_1_base_effects_and_budgets_contract.json`
- `docs/planning-data/poc_balance_budget.json`
- `data/combat/combat_board_poc.json`
- `data/combat/combat_hud_preview.json`
- `data/combat/combat_resolution_preview.json`
- `data/cards/ultimate_cards.json`
- `assets/ASSET_MANIFEST.json`
- Google Sheet tabs `00·02·12·15·40·60·70·80`

### 2.3 확인된 충돌과 적용 결론

| 항목 | 현행 런타임·과거 표현 | 최신 승인 기획 | HTML PoC |
|---|---|---|---|
| 기초 행동 | 8종 | 10종 | `[관찰]`, `[장풍]` 포함 10종 |
| 절초기세 획득 | 묶음·막기·회피·합 성공 +1 | 합 승리 공격 행동당 최대 +1, 준비된 명상 +1 | 묶음·막기·회피 자동 획득 금지 |
| 영구 능력치 | 공격력·방어력 레거시 | 외공·근골·신법·내공·심안 | 5종 공식 사용 |
| 장풍 | 미구현 또는 과거 저위력 제약 | `floor(3+내공×0.75)` | 최신 공식 사용 |
| 기술1 | 런타임 미구현 | 여섯 기술 승인 | 최신 계약으로 신규 구현 |
| 기술 중 이동 선택 | 과거 선택형 표현 | 확정 뒤 추가 선택 금지 | 고정 방향·경계 규칙 |
| 전투 등급 | 과거 점수·경계 | 5개 원자료만 승인, 산식 TBD | 원자료만 출력 |
| 10성 고유 절초 | 개별 효과 미승인 | 미확정 | 임의 제작 금지 |

## 3. 범위

### 3.1 반드시 포함

- 10칸 일자형 전장
- 플레이어 4번, AI 7번 시작
- 거리0 `[밀착]`
- 라운드 `3수→3수→4수`, 전체 10수 상시 표시
- 현재 묶음만 편집
- 플레이어 기초 행동 10종
- AI 기초 행동 9종: `[관찰]` 제외
- 양측 여섯 무공 기술1 모두 사용 가능
- 공개 상태 기반 검증형 AI
- 관찰량·AI 선잠금·종류 공개·이월
- 다중 수 연결 블록·비용 선지불·확정 전 이동/제거
- 순차 연격 합·사거리 밖 합·회피·방어도·중단·강건
- 절초기세 `0~5`, 획득·예약·환불·사용
- 기본 절초 3종을 절초기세 시스템 fixture로 사용
- 묶음 복기·기술 검증표·JSON replay
- UX·VFX·모션·정보성 SFX
- 재생·일시정지·사건 한 단계·1배속·2배속·건너뛰기
- 모션 감소·음소거·볼륨·키보드 포커스

### 3.2 제외

- 6중4 시작 무공 선택
- 시작 능력치 배분과 기술 잠금 과정
- 5성 기술1 patch
- 7성 기술2
- 9성 분기
- 여섯 무공의 10성 고유 절초
- 수련·성장·경로·노드·주요 비무 5전
- 저장·보상·영구재화·재도전 비용
- 온라인·랭킹·챔피언
- S/A/B/C 가중치·경계의 임의 산출
- 최종 상용 아트·오디오 폴리싱

## 4. 고정 검증 상태

성장·해금 변수를 제거하고 기술 규칙만 비교하기 위해 양측은 동일한 기준값을 사용한다.

```yaml
stats:
  외공: 4
  근골: 4
  신법: 4
  내공: 4
  심안: 4
health: [30, 30]
stamina: [5, 5]
internal: [4, 4]
ultimate_momentum: [0, 5]
defense: 0
evade_charges: 0
fortitude: 0
prepared: false
observation:
  player: 0
  enemy: disabled
position:
  player: 4
  enemy: 7
defense_cap: 10
```

- 기력 최대5, 내력 최대4
- 라운드 시작 시 기력 +1, 내력 자연 회복 없음
- 방어도는 피해 단위마다 고정 감산하되 피격으로 감소하지 않음
- 방어도는 라운드 종료 시0, 상한10
- 같은 타일은 거리0 `[밀착]`
- 현행 PoC 호환 규칙에 따라 밀착에서는 최소사거리1 이상 근접 공격을 유효 대상으로 처리한다. 이 예외는 `POC_ENGAGEMENT_COMPATIBILITY`로 기록한다.

## 5. 전투 행동 체계

```text
[기초]
[무공] → 무공서 6종 → 기술1
[절초] → 기본 절초 3종
```

무공서는 성장·분류 단위이며 타임라인에 직접 놓지 않는다. 배치 대상은 행동 또는 기술이다. 덱·손패·드로우·장착 제한을 사용하지 않는다.

### 5.1 기초 행동 10종

| 행동 | 슬롯 | 비용 | 기준 효과 |
|---|---:|---|---|
| 이동 | 1 | 없음 | 선택 방향 1칸 |
| 보법 | 1 | 내력1 | 선택 방향 1~2칸 |
| 막기 | 1 | 기력1 | PoC 기준 방어도5 |
| 회피 | 1 | 기력1 | 첫 회피 가능 피해 단위1개 제거 |
| 속공 | 1 | 기력1 | 거리1, `floor(3+외공×0.50)=5` |
| 강공 | 2 | 기력1·내력1 | 전조→실행, 거리1~2, `floor(7+외공×1.00)=11` |
| 관찰 | 1 | 없음 | 플레이어 전용, 관찰량+1 |
| 명상 | 1 | 없음 | 기력+1·내력+1 |
| 준비 | 1 | 내력1 | 다음 비이동 행동 강화 |
| 장풍 | 2 | 내력1 | 전조→실행, 거리1~3, `floor(3+내공×0.75)=6`, 밀치기 없음 |

`막기 방어도5`는 현행 PoC 기준값이다. 최신 근골 계수 자체를 새 정본으로 만들지 않으며 보고서에 `POC_REFERENCE_VALUE`로 표시한다.

### 5.2 전조와 준비

- `[전조]`는 다중 수 행동의 실행 전 점유 표시이며 독립 효과 없음
- 비용은 첫 전조에서 전액 선지불
- 중단·사거리 실패·방향 실패에도 비용·슬롯 환불 없음
- `[준비]`는 독립 1수 행동
- 이동·보법은 준비를 소비하지 않음
- 다음 공격은 원공격력+2와 강건1을 얻고 준비 소비
- 다음 명상은 기존 회복에 절초기세+1을 더하고 준비 소비
- 막기·회피·기타 비이동 행동은 처리 또는 유효 시도 뒤 준비 소비
- 새 준비는 기존 준비를 교체

### 5.3 해결 단계 매핑

기본 해결 순서는 기존 제품 계약을 유지한다.

```text
response → quick_attack → move → general
```

| 단계 | 행동 |
|---|---|
| `response` | 막기, 회피, 금강가세, 운수회신, 철각유영 |
| `quick_attack` | 속공, 십보 유파 |
| `move` | 이동, 보법 |
| `general` | 강공, 관찰, 명상, 준비, 장풍, 유운삼첩, 추풍일섬, 청심조식, 단악결, 파공검기 |

금강가세·철각유영의 최신 기술 계약에는 세부 phase 토큰이 없다. 방어·회피가 같은 수 공격보다 먼저 준비돼야 하므로 PoC에서 `response`로 매핑하고 `POC_RESOLUTION_MAPPING`으로 기록한다. 이는 새 제품 정본을 확정하지 않는다.

## 6. 여섯 기술1 계약

### 6.1 유운검결 — 유운삼첩

```yaml
manual_id: flowing_cloud_sword
technique_id: flowing_cloud_triple
slots: 2
cost: {stamina: 1, internal: 1}
range: 1
hits:
  - floor(3+외공*0.25) # 4
  - floor(2+외공*0.25) # 3
  - floor(2+외공*0.25) # 3
```

- 첫 슬롯 전조, 둘째 슬롯 실행
- 첫 전조에서 기력1·내력1 선지불
- `4→3→3`을 별도 피해 단위로 순차 처리
- 상대 연격과 현재 순번 피해 단위끼리 합
- 체력 피해 중단 시 미실행 후속타 취소
- 강건이 중단을 막으면 후속타 지속

### 6.2 금강호체공 — 금강가세

```yaml
manual_id: diamond_body_art
technique_id: vajra_guard
slots: 1
phase: response # POC_RESOLUTION_MAPPING
cost: {stamina: 1, internal: 1}
target: self
defense: floor(2+근골*0.75) # 5
fortitude: 1
```

- 방어도5·강건1 동시 부여
- 방어도는 매 피해 단위에 적용하지만 감소하지 않음
- 강건은 유효 중단1회만 방지하고 피해·상태·KO를 되돌리지 않음
- 방어도 총합 상한10

### 6.3 태극유전검 — 운수회신

```yaml
manual_id: taiji_flowing_sword
technique_id: cloud_hand_return
slots: 1
phase: response
cost: {stamina: 1, internal: 1}
evade: 1
on_evade_success:
  fixed_retreat: 1
  internal_gain: floor(내공*0.25) # 1
```

- 첫 회피 가능 피해 단위만 제거
- 실제 회피 성공 시에만 후퇴1·내력1 회수
- 공격 부재·회피 실패·필중 공격에는 후속 효과 없음
- 적에게서 멀어지는 방향으로 고정 후퇴
- 경계에서는 가능한 거리까지만 이동

### 6.4 추풍창법 — 추풍일섬

```yaml
manual_id: chasing_wind_spear
technique_id: pursuing_wind_thrust
slots: 1
cost: {stamina: 1, internal: 1}
movement:
  timing: before_attack
  direction: toward_enemy
  tiles: 1
range: 1..2
damage: floor(2+외공*0.50) # 4
```

- 공격 전에 적 방향 고정 전진1
- 전진·후퇴 선택 UI 없음
- 전진 불가 시 현재 위치에서 공격 판정 계속
- 이동 뒤 거리·방향 검사

### 6.5 청심양생공 — 청심조식

```yaml
manual_id: clear_heart_nourishing_art
technique_id: clear_heart_breath
slots: 1
cost: none
condition: once_per_bundle
stamina_gain: 1
internal_gain: floor(내공*0.25) # 1
defense: floor(1+근골*0.25) # 2
```

- 양측 각 묶음당1회
- 기력1→내력1→방어도2의 고정 사건 순서
- 자원 최대치 초과분은 소멸하며 다른 보상으로 전환하지 않음
- 같은 묶음 두 번째 선택은 불가 이유 표시

### 6.6 무영십보 — 철각유영

```yaml
manual_id: shadowless_ten_steps
technique_id: iron_step_drift
slots: 1
phase: response # POC_RESOLUTION_MAPPING
cost: {stamina: 1, internal: 1}
fixed_retreat: 2
evade: 1
```

- 적에게서 멀어지는 방향으로 최대2칸 고정 후퇴
- 방향·도착 타일 추가 선택 없음
- 경계·점유 시 가능한 거리까지만 이동
- 회피1 부여

### 6.7 canonical ID

| 역사 alias | canonical manual ID |
|---|---|
| `vajra_body` | `diamond_body_art` |
| `taiji_flow` | `taiji_flowing_sword` |
| `pursuing_wind_spear` | `chasing_wind_spear` |
| `clear_heart_nurturing` | `clear_heart_nourishing_art` |
| `shadowless_steps` | `shadowless_ten_steps` |

새 로그·검증·replay는 canonical ID를 사용한다. 역사 alias는 입력 호환에만 사용한다.

## 7. 절초기세와 절초

### 7.1 자원 계약

```yaml
resource_id: ultimate_momentum
display_name: 절초기세
range: 0..5
```

허용 획득:

- 합 승리 시 공격 행동당 전투원별 최대+1
- 한 연격 행동에서 여러 순번 합을 이겨도 그 공격 행동 전체에서 최대+1
- 사거리 밖 합 승리도 정상 합 승리이므로+1
- 준비가 적용된 명상 실행 시+1
- 상한5

금지 획득:

- 묶음 시작 자동+1
- 막기 성공 자동+1
- 회피 성공 자동+1
- 피해 발생만으로+1

### 7.2 예약·환불

- 절초는 별도 `[절초]` 탭
- 기세5와 연속 빈 슬롯이 있어야 배치 가능
- 배치 성공 즉시 기세5 예약·차감
- 배치 실패 시 계획·기세 유지
- 진행 전 제거 시5 환불
- 진행 전 이동 시 기존 예약 환불 후 새 위치 재예약
- 확정 뒤 중단·사거리·방향 실패에는 환불 없음
- 기력·내력과 별도 게이지로 표시

### 7.3 기본 절초 fixture

여섯 무공의 10성 고유 절초는 임의 설계하지 않는다. 절초기세 시스템을 실제로 검증하기 위해 현행 기본 절초 3종만 `LEGACY_SYSTEM_FIXTURE`로 사용한다.

고정 레거시 공격력8 기준:

| ID | 이름 | 단계 | 슬롯 | 거리·이동 | 피해 | 태그 |
|---|---|---|---:|---|---:|---|
| `ultimate_ten_paces_wave` | 십보 유파 | quick | 1 | 전진1 후 거리1 | `8+floor(8×0.25)=10` | 절초·속공 |
| `ultimate_cleave_peak` | 단악결 | general | 2 | 거리2 | `14+floor(8×0.75)=20` | 절초 |
| `ultimate_void_sword_qi` | 파공검기 | general | 3 | 거리3 | `22+floor(8×1.50)=34` | 절초·필중 |

- 셋 모두 추가 기력·내력 비용 없음
- 절초 밸런스는 기술1 PASS/FAIL과 분리
- 결과에 `기본 절초 fixture: LEGACY` 표시

## 8. 관찰·계획·AI

### 8.1 묶음 순서

```text
직전 묶음 종료 상태 정산
→ AI가 공개 상태만으로 현재 묶음 확정·잠금
→ 보유 관찰량으로 앞 수 행동 종류 공개
→ 플레이어 계획·확정
→ 양측 해결
→ 묶음 복기
```

AI는 미래 묶음을 미리 만들지 않으며 관찰 공개 뒤 잠긴 묶음을 바꾸지 않는다.

### 8.2 관찰

- 플레이어 `[관찰]` 1회는 관찰량1
- 다음 AI 묶음 확정 때 앞 수부터 사용
- 공개·저장 상한 없음
- 남은 양은 묶음·라운드 이월
- 태그: `[전조]`, `[이동]`, `[공격]`, `[방어]`, `[회피]`, `[준비]`, `[자원]`, `[관찰]`
- 복합 행동은 `[이동+공격]`처럼 전체 종류 표시
- 기술명·무공서명·정확 비용·방향·거리·피해·대상·AI 가중치는 숨김
- AI는 관찰 사용 금지

### 8.3 검증형 AI

AI ID: `public_state_ai_technique1_coverage`

허용 입력:

- 공개 전투 상태
- 자신의 자원·위치·상태
- 양측 보유 행동의 공개 규칙
- 해결된 과거 사건
- 고정 seed
- 아직 충분히 검증되지 않은 자신의 기술 목록

금지 입력:

- 플레이어 미확정 슬롯·대상·방향
- hover·focus·포인터
- 관찰로 공개되지 않은 현재 계획

정책:

- 불법 행동 제거
- 합법 후보 중 미검증 기술 가중
- 자원 부족 시 명상·청심조식 고려
- 거리 불일치 시 이동·보법·철각유영·추풍일섬 고려
- 공격 예상 시 운수회신·금강가세 고려
- 기세5면 기본 절초 고려
- 공개 상태와 seed로 결정

한 전투에서 모든 기술을 억지로 쓰지 않는다. 실행되지 않은 기술은 `NOT_TESTED`이며 새 seed 또는 동일 seed 재현으로 추가 검증한다.

AI는 플레이어 편집 시작 전에 자신의 계획 JSON과 hash를 고정한다. 공개 뒤 hash가 달라지면 `AI_PUBLIC_STATE_NO_CHEAT=FAIL`이다.

## 9. 판정 계약

### 9.1 위치·거리

- 타일1~10
- 같은 빈 목적지와 정지 상대 칸 진입 허용
- 자리 교환·상대 통과·전장 밖 이동 금지
- 방향성 공격은 방향과 사거리 모두 검사
- 공간 부족 잔여 이동은 피해·절초기세·다른 효과로 변환하지 않음

### 9.2 사건 순서

```text
대응 상태 준비
→ 속공·위치 확정
→ 행동 시작 효과
→ 공격별 피해 단위 생성
→ 현재 순번 합
→ 합 승리 효과·절초기세
→ 사거리·방향
→ 회피
→ 방어도 고정 감산
→ 체력 피해
→ ON_HIT·ON_HEALTH_DAMAGE
→ 중단·강건
→ 다음 순번 합 또는 잔여 단독 타격
→ 공격 종료 효과
→ 이동·비공격 행동
```

VFX·UI·오디오는 판정 사건을 소비만 하며 상태를 다시 계산하지 않는다.

### 9.3 순차 합

- 현재 순번 피해 단위끼리 비교
- 높은 쪽 승리, 차이가 승자의 현재 원피해
- 패자 현재 피해 단위만 취소
- 동점은 현재 피해 단위끼리만 상쇄
- 양측 체력 피해0·공격 유지·다음 피해 단위 존재 시 다음 순번 합
- 한쪽만 남으면 상대 잔여 피해 단위 단독 해결
- 실제 체력 피해로 공격 행동 중단 시 미실행 후속타 취소
- 강건이 중단을 막으면 다음 순번 지속

### 9.4 사거리 밖 합

- 합 비교는 사거리보다 먼저 수행
- 승자는 합 승리·절초기세·`ON_CLASH_WIN` 획득
- 사거리·방향 무효면 체력 피해·`ON_HIT`·`ON_HEALTH_DAMAGE` 없음
- 양측 공격 유지 시 다음 순번 합 계속

### 9.5 방어·회피·필중·중단

```text
체력 피해=max(0, 원피해-현재 방어도)
```

- 방어도는 매 피해 단위에 적용, 자원 자체 비소모
- 회피1은 첫 회피 가능 피해 단위1개 제거
- 필중은 회피만 무시하고 합·방어·거리·방향·중단·KO는 무시하지 않음
- 유효 체력 피해가 발생하면 진행 중 공격 행동 중단
- 강건1은 중단1회만 방지하고 소모
- 체력0이면 남은 피해 단위·비필수 후속 효과 생략

### 9.6 결착 압력

1~3라운드는 정상 규칙. 4라운드 종료부터 세 번째 묶음·상태 정산과 승패 확인 뒤 적용한다.

```text
결착 피해=최대 체력10%+5×(라운드-3)
```

- 방어·회피·강건 무시
- 동시 KO: 직전 체력 비율 → 해당 라운드 유효 체력 피해 → 무승부

## 10. 계획 UX

### 10.1 화면 구조

```text
┌ 플레이어 상태·절초기세 ─ 라운드/묶음 ─ AI 절초기세·상태 ┐
├──────────────────────────────────────────────────────────────┤
│                       1~10 전장                              │
│             위치·거리·밀착·현재 판정                        │
├──────────────────────────────────────────────────────────────┤
│ 전체 10수 · 현재 묶음 확대 · [진행]                         │
├──────────────────────────────────────────────────────────────┤
│ [기초] [무공] [절초]                     행동 상세            │
├──────────────────────────────────────────────────────────────┤
│ 묶음 복기 / 구현 검증표 / 상세 사건 로그                    │
└──────────────────────────────────────────────────────────────┘
```

정보 위계:

```text
전장 → 현재 수·행동 → 상태·자원·절초기세
→ 전체 10수·현재 묶음 → 행동 선택·상세
→ 중앙 결과 → 복기·검증·로그
```

### 10.2 배치·편집

- 선택 즉시 가장 앞 유효 연속 빈 구간 자동 배치
- 2수 행동은 하나의 연결 블록으로 `전조→실행`
- 현재 묶음만 편집, 전체10수 상시 표시
- 확정 전 연결 블록 이동·제거 가능
- 무효 Drop은 원래 배치 보존
- 배치 실패는 계획·자원·기세 불변 + 이유 표시
- 빈 수는 명시적 `[대기]`로 확정 가능
- 대상·방향이 필요한 기초 행동은 확정 전 지정
- 무공 기술의 고정 이동·후속 효과는 확정 뒤 추가 입력 없음
- 확정 뒤 선택·탭·편집 잠금

### 10.3 카드·상세

카드 최소 정보:

- 출처
- 이름
- 슬롯
- 기력·내력·절초기세 비용
- 사거리 또는 이동 거리
- 핵심 태그 최대2개

상세 패널:

- canonical ID
- 공식·기준 스탯4 결과
- 전조·실행 구조
- 고정 이동 순서·경계 규칙
- 조건부 후속 효과
- 사용 가능 여부·불가 이유
- 개발자 검증 보기에서 틱 ledger

### 10.4 절초기세 HUD

- 양측 각각 5분절
- 기력·내력과 분리
- 합 승리 시 공격 행동당 한 분절만 점등
- 사거리 밖 승리: `합 승리 / 피해0 / 절초기세+1` 동시 표시
- 예약 시 5분절을 예약 상태로 전환
- 취소·이동 환불 애니메이션
- 확정 뒤 소비 상태로 전환

### 10.5 복기 3계층

1. 중앙 키워드: 합 승리·회피·방어·중단·강건·사거리 밖·절초기세
2. 슬롯 결과: 실행·취소·중단·대기·전조
3. 상세 로그: 공식 입력·출력·트리거·모션 사건

## 11. 아트·모션·오디오

### 11.1 승인 에셋

HTML PoC는 다음 활성 에셋을 복사 또는 정적 경로로 재사용한다.

- `assets/backgrounds/twilight_ink_duel_v1.png`
- `assets/characters/player_wanderer_battler_rgba_v1.png`
- `assets/characters/enemy_masked_battler_rgba_v1.png`
- `assets/vfx/ultimate_ink_gold_sprite_sheet_rgba.png`

방향:

- 수묵 석양 결투 전장
- 세피아·먹색·절제된 번트 오렌지
- 플레이어 숯색·청회색·작은 금빛 강조
- AI 먹색·어두운 적색 강조
- 낮은 대비 배경, 선명한 전투 정보
- 특정 IP·작가 표면 복제 금지
- 가짜 한글·무의미 문자 금지

기술1 궤적·잔상·방어막은 SVG/CSS로 구성한다. 에셋 실패 시 도형·텍스트 fallback으로 정보가 남아야 한다.

### 11.2 판정 사건 기반 연출

```text
action_start
movement_start / movement_end
telegraph / execute
clash_start / clash_win / clash_tie
range_check / direction_check
evade_success / evade_fail
defense_apply / health_damage
trigger_on_hit / trigger_on_health_damage
interrupt / fortitude_consumed
action_end
momentum_gain / momentum_reserve / momentum_refund / ultimate_use
```

연출 레이어는 사건 순서를 재생하며 계산 권한이 없다.

### 11.3 기술별 필수 모션

#### 유운삼첩

준비 자세 → 1타 검광·개별 숫자·짧은 hit stop → 2타 반대 궤적 → 3타 마무리 → 복귀.

- 세 타격 합산 표시 금지
- 중단된 후속타는 모션 생략·타임라인 취소선

#### 금강가세

중심 낮춤 → 먹금 방어 원형 확산 → 방어도+5 → 강건 인장 점등.

- 방어 감산과 체력 피해를 다른 숫자·아이콘으로 표시
- 강건 소비 시 인장 파열 후 행동 지속 표시

#### 운수회신

공격 도달 → 물 흐르는 잔상 회피 → `회피/MISS` → 성공한 경우만 후퇴1 → 내력 입자 HUD 이동.

#### 추풍일섬

전진1 → 창 준비 → 직선 찌르기 → 거리·방향 검사 → 적중 또는 끊어진 궤적.

- 전진과 공격을 단일 순간이동으로 합치지 않음
- 전진 불가 시 경계 피드백 후 현재 위치 공격

#### 청심조식

호흡 자세 → 원형 파동 → 기력+1 → 내력+1 → 방어도+2.

- 이번 묶음 사용 완료 인장
- 최대치 초과분은 `상한` 텍스트

#### 철각유영

후퇴1보 → 잔상 → 후퇴2보 → 잔상·회피 인장.

- 경계에서는 실제 보폭만 재생
- 이동0이어도 회피 부여 사건은 별도 표시

### 11.4 공통 연출

- 합: 현재 피해 단위 궤적 중앙 충돌
- 합 승리: 승자 방향 충격, 패자 현재타 소거
- 사거리 밖 합 승리: 궤적이 목표 전 끊기고 `피해0`, 기세 점등
- 회피: 잔상+텍스트
- 방어: 원형/방패 아이콘+감산 숫자
- 체력 피해: 별도 숫자·체력바 충격
- 중단: 행동 프레임 파열·후속타 취소선
- 필중: 회피 아이콘 관통, 합·방어는 정상
- 이동 전후 타일 번호·형태 강조
- 절초: 먹금 VFX·기세5 소비를 일반 기술보다 명확히 표현

### 11.5 재생·접근성

- 재생/일시정지
- 사건 한 단계
- 1배속/2배속
- 묶음 연출 건너뛰기
- 모션 감소
- 음소거·볼륨
- 키보드 focus outline
- hover 없이 클릭·포커스로 동일 정보
- 색 외 텍스트·아이콘·형태로 상태 구분

모션 감소:

- 카메라 흔들림·긴 잔상·parallax·hit stop 제거
- 위치는 짧은 페이드 또는 즉시 변경
- 핵심 텍스트·아이콘·숫자는 유지

오디오는 합·연격·방어·회피·절초를 구분하지만 음향만으로 정보를 전달하지 않는다.

## 12. 구현 검증

### 12.1 기술별 사건 검증

```yaml
identity:
  manual_id: MATCH
  technique_id: MATCH
placement:
  slots: MATCH
  contiguous: MATCH
  telegraph_execute: MATCH
cost:
  paid_at_first_telegraph: MATCH
  stamina: MATCH
  internal: MATCH
formula:
  stat_inputs: MATCH
  packet_values: MATCH
resolution:
  phase: MATCH_OR_POC_MAPPING
  movement: MATCH
  range: MATCH
  hit_count: MATCH
  clash_packets: MATCH
  triggers: MATCH
presentation:
  required_events: MATCH
  reduced_motion_fallback: MATCH
verdict: PASS | PARTIAL | FAIL | NOT_TESTED
```

- `PASS`: 필수 규칙·수치·사건·모션 확인
- `PARTIAL`: 기술은 실행했으나 조건부 후속 효과 미발생
- `FAIL`: 슬롯·비용·공식·이동·조건·판정·필수 연출 중 불일치
- `NOT_TESTED`: 미실행

### 12.2 기술별 최소 PASS

| 기술 | 최소 확인 |
|---|---|
| 유운삼첩 | 2수·선지불·4/3/3·세 피해 단위·세 모션 |
| 금강가세 | 방어5·강건1·비소모 방어 적용 |
| 운수회신 | 실제 회피·후퇴1·내력1·성공 전용 모션 |
| 추풍일섬 | 선전진1·공격4·거리1~2·전진 불가 규칙 |
| 청심조식 | 묶음당1회·기력1·내력1·방어2 |
| 철각유영 | 고정 후퇴 최대2·경계 축소·회피1 |

### 12.3 시스템 검증 ID

- `TIMELINE_3_3_4`
- `FULL_TEN_TIMING_CONTEXT`
- `MULTI_SLOT_LINKED_BLOCK`
- `COST_PREPAY_AND_NO_POST_COMMIT_REFUND`
- `OBSERVATION_LOCK_REVEAL_CARRY`
- `AI_PUBLIC_STATE_NO_CHEAT`
- `SEQUENTIAL_MULTI_HIT_CLASH`
- `OUT_OF_RANGE_CLASH_MOMENTUM_NO_HIT`
- `DEFENSE_NON_CONSUMPTIVE_CAP_AND_ROUND_RESET`
- `EVADE_ONE_PACKET`
- `INTERRUPT_AND_FORTITUDE`
- `ULTIMATE_MOMENTUM_GAIN_CAP`
- `ULTIMATE_RESERVE_MOVE_REFUND_COMMIT`
- `NO_LEGACY_BUNDLE_GUARD_EVADE_MOMENTUM`
- `WAIT_SLOT_ALLOWED`
- `NO_POST_COMMIT_TECHNIQUE_CHOICE`
- `POC_ENGAGEMENT_COMPATIBILITY`
- `REDUCED_MOTION_INFORMATION_PARITY`

## 13. 기록·재현

각 전투에서 다음을 HTML 복기와 JSON replay로 제공한다.

- seed
- 초기 상태
- AI 잠금 계획 hash
- 양측 확정 계획
- 관찰 공개 스냅샷
- 판정 사건 전체
- 프레젠테이션 사건 전체
- 기술별 검증표
- 시스템 검증표
- 원자료: 회피 성공, 합 승리, 플레이어 체력 손실, 라운드 수, 절초 사용 횟수

S/A/B/C 산식은 만들지 않는다. 동일 seed와 동일 계획은 동일 상태·사건 순서를 재현해야 한다.

## 14. Codex 구현 구조

빌드 도구·외부 CDN·네트워크 연결 없이 로컬 정적 서버에서 실행되는 단일 페이지 앱으로 만든다.

```text
web-poc/technique1-validation/
├─ index.html
├─ styles/
├─ src/
│  ├─ data/
│  ├─ engine/
│  ├─ ai/
│  ├─ presentation/
│  ├─ ui/
│  └─ validation/
├─ assets/
└─ tests/
```

원칙:

- 판정 엔진은 DOM 참조 금지
- AI는 UI 상태 참조 금지
- 프레젠테이션은 판정 사건만 소비
- 검증기는 같은 사건으로 계약 일치 판단
- 최신 승인 계약은 단일 데이터 모듈에 저장
- UI 문자열에 수치 중복 금지
- 외부 서비스 없이 실행

## 15. 적대적 검토 결과

### 위험 1: AI가 조건 재현을 위해 플레이어 계획을 읽음

AI 계획을 플레이어 편집 전에 hash로 잠그고 변경 시 시스템 FAIL.

### 위험 2: 한 판에 여섯 기술을 강제로 넣어 불법 행동 선택

미검증 기술 가중은 합법 후보 안에서만 적용. 미사용은 정직하게 NOT_TESTED.

### 위험 3: 연출이 피해·위치를 다시 계산

판정 사건과 최종 상태만 연출 입력으로 허용. 프레젠테이션 상태 변경 금지.

### 위험 4: 레거시 절초기세 획득 복제

묶음·막기·회피 자동 기세 획득 금지 테스트 필수.

### 위험 5: 미승인 고유 절초 발명

기본 절초 3종만 LEGACY fixture. 여섯 10성 절초 제외.

### 위험 6: 개발자 검증 로그가 게임 UX를 압도

전장·타임라인·행동 선택 우선. 검증표·로그는 접이식 하단 패널.

### 위험 7: 화려한 모션이 인과를 숨김

텍스트·아이콘·슬롯 결과 병기. 모션 감소에서도 정보 동등.

### 위험 8: 불명확한 phase·막기 계수를 구현자가 정본으로 오인

`POC_RESOLUTION_MAPPING`, `POC_REFERENCE_VALUE`, `LEGACY_SYSTEM_FIXTURE`, `POC_ENGAGEMENT_COMPATIBILITY`를 결과·데이터에 명시.

## 16. 완료 기준

1. 브라우저에서 플레이어 대 공개 상태 기반 AI 전투 시작·종료 가능
2. 양측이 여섯 기술1과 허용 기초 행동·기본 절초를 합법적으로 사용
3. 전체10수와 현재3/3/4 묶음 동시 표시
4. 관찰·AI 잠금에서 미확정 계획 누출 없음
5. 여섯 기술 공식·비용·슬롯·이동·조건이 계약과 일치
6. 순차 합·사거리 밖 합·방어·회피·중단·강건이 기술과 연결
7. 절초기세가 승인 경로로만 증가하고 예약·환불·확정 규칙 준수
8. 각 기술 필수 모션과 모션 감소 fallback 존재
9. 기술별 PASS/PARTIAL/FAIL/NOT_TESTED 근거 확인 가능
10. 동일 seed·계획 재현과 JSON replay 가능
11. 자동 테스트가 확인된 레거시 충돌을 보호
12. 사람 검증 전 재미·가독성·접근성을 PASS로 주장하지 않음

## 17. 구현 후 사람 검증

- 여섯 기술 역할을 이름 없이 모션과 결과로 구분할 수 있는가
- 유운삼첩의 세 타격과 순차 합을 이해하는가
- 방어도 비소모와 강건 소모를 구분하는가
- 운수회신 후속 효과가 회피 성공 조건임을 이해하는가
- 추풍일섬의 전진→공격 순서를 이해하는가
- 청심조식의 묶음당 제한을 이해하는가
- 철각유영의 경계 축소 이동을 이해하는가
- 사거리 밖 합의 `합 승리지만 피해0`를 납득하는가
- 절초기세 획득·예약·환불을 설명할 수 있는가
- 모션 감소에서도 같은 정보를 얻는가

자동 테스트 통과는 위 사람 이해도와 전투 재미를 증명하지 않는다.
