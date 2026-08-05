# 십보강호 활성 컨텍스트

> 전투 규칙 책임 원본: `docs/02_COMBAT_RULES.md`  
> 정본 생명주기: `docs/CANON_LIFECYCLE_REGISTRY.md`  
> 초기 무공서 10권 성장 권위: `TEN-DEC-20260806-TEN-RECOGNIZABLE-MARTIAL-MANUALS-FULL-GROWTH-01`  
> 초기 무공서 10권 런타임 권위: `TEN_MANUAL_RUNTIME_IMPLEMENTATION_GATE`  
> 빌드 승인: `docs/implementation/BUILD_APPROVAL_2026-08-06.md`

## 현재 기준

```yaml
project: 십보강호: 숨은 수의 비무
repository: alsdmlals4-eng/Ten-Paces-Hidden-Moves
merged_planning_checkpoint: bbed0fd4d278ca0e0d52f4e6d9083aafa1997318
merged_pr_lineage: 84,86,87,88
runtime_work_mode: REVIEW
runtime_integration_pr: 65
active_planning_work_mode: BUILD
active_planning_pr: 92
active_planning_parent_pr: 91
active_approval_count: 10/10
active_decision_state: TEN_MANUAL_RUNTIME_FOUNDATION_IMPLEMENTED
primary_platform: PC
future_platform: MOBILE_CONSIDERATION_ONLY
engine: Godot 4.7
product_stage: VERTICAL_SLICE_APP_FLOW_PLANNING
base_release_pinned: 9.4.3
runtime_implementation: TEN_MANUAL_RUNTIME_FOUNDATION_PR92
latest_combat_planning_runtime: RUNTIME_FOUNDATION
runtime_ui_adoption: DEFERRED
runtime_ai_adoption: DEFERRED
automated_validation: PASS
windows_validation: NOT_RUN
human_validation: NOT_RUN
balance_validation: NOT_RUN
accessibility_validation: NOT_RUN
performance_validation: NOT_RUN
next_package: VERTICAL_SLICE_APP_FLOW_SHELL
next_planning_decision: TEN_MANUAL_UI_AI_ADOPTION_GATE
```

현재 체크포인트는 `DRAFT_PR92_TEN_MANUAL_RUNTIME_FOUNDATION_10_OF_10`이다. PR #92는 PR #91 위에 쌓인 Draft이므로 PR #91보다 먼저 독립 병합·Draft 해제·종료하지 않는다. PR #91도 PR #89보다 먼저 독립 병합하지 않는다. PR #90은 `[대체됨]`, PR #85 HTML PoC는 `[보류]`다.

자동 검증 통과는 Godot·Windows·접근성·성능·사람 플레이·밸런스 승인을 대신하지 않는다.

## 프로젝트 코어

공개 상태와 반복 습관을 읽고 서로의 현재 계획을 모른 채 10칸 전장에 `3수 → 3수 → 4수`로 수를 걸어 거리·순차 합·대응·중단으로 파훼하고, 복기로 다음 계획을 바꾸는 1대1 무협 심리 전술 로그라이트다.

```text
객관 정보 조사·관찰
→ 잠긴 상대 묶음 추론
→ 비공개 계획 확정
→ 거리·순서·합·회피·방어·중단 해결
→ 원인 복기
→ 다음 계획 변경
```

보호 규칙:

- AI는 미확정 플레이어 계획을 참조하지 않는다.
- 적은 관찰 공개 전에 현재 묶음을 잠그고 공개 뒤 교체하지 않는다.
- 행동 묶음 확정 뒤 추가 플레이어 선택을 요구하지 않는다.
- 기술 이동은 고정 방향·합법 타일 폴백을 사용한다.
- 이동으로 거리가 바뀌면 종속 공격 전에 사거리를 다시 검사한다.
- 성장 수치는 잘못된 계획을 자동 구제하지 않는다.
- 스탯 보정은 합법성·거리·순서·중단·성공 Gate 뒤에만 적용한다.
- 9성은 기술2에 단일·무분기 효과 하나만 추가한다.
- 능력치별 무공서 권수·균등 분포·최소/최대 쿼터는 사용하지 않는다.
- 주·보조능력치는 문파·무학·동작·피해 방식 적합성으로만 결정한다.

## 현재 런타임 권위

`TEN_MANUAL_RUNTIME_IMPLEMENTATION_GATE` 승인에 따라 다음 기반이 구현됐다.

- `data/cards/martial_manual_cards.json`: 10권 manifest와 호환 정책.
- `data/cards/martial_manuals/`: 무공서별 10개 런타임 파일.
- `MartialManualRegistry`: 3·5·7·9·10성 해금과 overlay 합성.
- `MartialEffectPipeline`: 상태 선행·이동·사거리 재검사·다단·조건부 후속·전투당 사용권의 결정적 실행.
- `TenManualCombatResolutionEngine`: 기존 엔진을 보존하는 명시적 loadout 어댑터.

`RUNTIME_FOUNDATION`은 10권 데이터를 로드하고 구조적 효과를 실행할 수 있다는 뜻이다. 현재 Scene·행동 선택 UI·적 AI가 10권을 자동 채택했다는 뜻은 아니다.

기존 기본 행동과 공용 절초 3종은 회귀·호환 기준으로 유지된다. 무공 카드는 명시적 loadout을 설정할 때만 추가된다.

## 초기 무공서 10권

| 문파·유파 | 무공서 | 주 / 보조 | 10성 절초 | 런타임 역할 |
|---|---|---|---|---|
| 화산파 | 매화검결 | 신법 / 외공 | 이십사수매화검법 | 이동형 적중 연격 |
| 소림사 | 나한금강공 | 외공 / 내공 | 여래신장 | 강건·방어·근접 장격 |
| 무당파 | 태극검결 | 심안 / 내공 | 태극혜검 | 흘리기·합·반격 |
| 양가 | 양가창결 | 외공 / 신법 | 회마창 | 창끝 거리·재반격 |
| 화산파 | 자하심법 | 내공 / 근골 | 자하신공 | 자원 순환·위기 복귀 |
| 소요파 | 소요보결 | 신법 / 심안 | 능파미보 | 회피·반격·변위 |
| 개방 | 강룡장결 | 내공 / 근골 | 항룡십팔장 | 중후한 장력·정면 돌파 |
| 사천당문 | 천기암기록 | 심안 / 신법 | 만천화우 | 원거리 독립 다단 압박 |
| 하북팽가 | 팽가도결 | 근골 / 외공 | 오호단문도 | 방어 파괴·결착 |
| 남궁세가 | 창궁무애검법 | 내공 / 심안 | 제왕검형 | 준비형 검압·합 결착 |

성장 구조는 `3성 기술1 → 5성 기술1 추가 효과 → 7성 기술2 → 9성 기술2 단일 완성 효과 → 10성 대표 절초`다.

## 특수 불변조건

### 자하신공

- 전투당 1회 사용권을 프로그램 시작 시 소모한다.
- 중단·전투불능에도 사용권을 환불하지 않는다.
- 전체 프로그램 완료 시에만 절초기세 +1을 지급한다.

### 나한금강공

- 방어와 `[강건]`을 공격 전에 생성한다.
- `[강건]`은 현행 중단 1회 방지 범위만 사용한다.
- 무적·피해 무시·절대 중단 면역은 없다.

### 회마창·능파미보·만천화우

- 회마창: 공격 → 후퇴 → 사거리 재검사 → 두 번째 공격.
- 능파미보: 회피 성공 → 이동 전 반격 → 후퇴 → 준비 상태.
- 만천화우: 무작위 타수가 아니라 독립 공격 4회를 결정적으로 처리한다.

## 검증 상태

RED 증거:

- runtime manifest·레지스트리·pipeline 부재 실패: workflow `31049328495`.
- combat adapter 부재 실패: workflow `31050666862`.

GREEN 범위:

- Python 정적 계약과 적대적 변조 테스트.
- Godot 4.7.1 import·레지스트리·효과 pipeline 검증.
- PR Validation과 Full Validation.
- 기존 전투·관찰·등급·숙련·예산·Base 회귀.

사람·밸런스·Windows·접근성·성능 검증은 `NOT_RUN`이다.

## 현재 위험과 다음 순서

| 위험 | 상태 | 다음 조치 |
|---|---|---|
| `RUNTIME_AUTHORITY_GAP` | `MITIGATED_RUNTIME_FOUNDATION` | UI·AI 명시적 채택 검토 |
| `MASTERY_ROLE_REPLACEMENT_RISK` | `PENDING_HUMAN_MEASUREMENT` | 기술1/2 선택률·대체율 측정 |
| `RESOURCE_SATURATION_RISK` | `PENDING_HUMAN_MEASUREMENT` | 회복 세금·고갈 측정 |
| `OBSERVATION_ANSWER_LEAK_RISK` | `PENDING_HUMAN_MEASUREMENT` | 직접 공개 유지·사람 측정 |
| `GRADE_FARMING_RISK` | `PENDING_HUMAN_MEASUREMENT` | 원시/유효 등급 비율 측정 |

```text
TEN_MANUAL_UI_AI_ADOPTION_GATE
→ 행동 선택 UI에 명시적 loadout 연결
→ AI 공개 상태 정책에 10권 후보 행동 연결
→ Godot·Windows·접근성·성능 검증
→ STEP 14 사람 플레이·밸런스 검증
→ NON_STAT_NODE_EXPECTED_VALUE_AND_WEIGHT
→ FULL_CORE_FUN_CANON_ADVERSARIAL_REVIEW
```

## 정본 동기화 원칙

주요 승인과 구현 상태는 GitHub 권위 문서와 연결된 Google Sheet에 같은 Decision ID와 exact SHA로 기록한다. 현재 PR #92는 Draft·stacked 상태를 유지하며 병합 권한은 별도 사용자 승인에 속한다.
