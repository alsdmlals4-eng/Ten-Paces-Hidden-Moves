# Vertical Slice 상대 후보 · Route · 텍스트 UX 승인 결정

- Decision ID: `TEN-DEC-20260820-VERTICAL-SLICE-OPPONENT-ROUTE-CONTENT-01`
- 부모 Decision: `TEN-DEC-20260820-JIANGHU-JOURNEY-VERTICAL-SLICE-01`
- 승인일: 2026-08-20
- 승인 근거: 사용자 `권장안 승인, 연속작업 진행해`에 따른 승인 범위 내 가역 콘텐츠 상세화
- 상태: `CURRENT_APPROVED_PLANNING`
- 구현 권한: `PLANNING_ONLY`
- 제품 런타임 변경: `NO`
- 책임 원본: `docs/13_VERTICAL_SLICE_OPPONENT_ROUTE_CONTENT.md`
- 구조화 계약: `docs/planning-data/approved_20260820_vertical_slice_opponent_route_content_contract.json`

## 1. 승인 결론

첫 Vertical Slice의 5개 주요 비무는 기존 슬롯별 기계 역할을 보호하면서 **각 슬롯 3명, 총 15명의 서로 다른 읽기 대상**으로 구성한다. 비무 사이 8개 Route 방문은 `회복/성장 → 정보/대비`의 정확히 2노드 구조를 유지하고 각 방문에서 2개의 의미 있는 선택을 제공한다.

이번 Decision은 다음을 고정한다.

- 슬롯 1~3의 과거 후보 ID·이름을 migration input으로 선별 재사용.
- 슬롯 4~5 후보 6명 추가.
- 후보 15명의 대표 무공 앵커·읽을 습관·반례·Briefing 훅·성격 훅.
- Route 8방문의 질문·선택 유형·정보 경계.
- Briefing / Combat Review Overlay / Duel Result / 완주 요약 텍스트 UX.
- 5회 전체 적대적 검토 + clean-exit 재공격.

이번 Decision은 다음을 고정하지 않는다.

- 적별 정확한 runtime loadout.
- 적별 정확한 성취도·해금 단계.
- AI 가중치·난이도 숫자.
- Route 회복량·성장량 숫자.
- 최종 대사 전 문구·성우·일러스트.

## 2. 후보 15명 승인 목록

| 슬롯 | ID | 이름 | 대표 무공 앵커 | 읽기 핵심 |
|---:|---|---|---|---|
| 1 | D01 | 연교 | 남궁세가 · 창궁무애검법 | 준비→큰 합 |
| 1 | D01_ALT_02 | 백소령 | 화산파 · 매화검결 | 접근→연격 |
| 1 | D01_ALT_03 | 진무백 | 하북팽가 · 팽가도결 | 방어파괴→중도 |
| 2 | D02 | 묵진 | 소림사 · 나한금강공 | 방어·강건 선행 |
| 2 | D02_ALT_02 | 하진강 | 개방 · 강룡장결 | 공격 성공→주도권 |
| 2 | D02_ALT_03 | 위청람 | 화산파 · 자하심법 | 저자원→회복 가치 |
| 3 | D03 | 설하 | 사천당문 · 천기암기록 | 원거리 유지 |
| 3 | D03_ALT_02 | 곽연산 | 양가 · 양가창결 | 1~2 거리 왕복 |
| 3 | D03_ALT_03 | 연비홍 | 화산파 · 매화검결 | 접근+합 |
| 4 | D04 | 청허 | 무당파 · 태극검결 | 접촉 공격 유도·조건 반격 |
| 4 | D04_ALT_02 | 소운하 | 소요파 · 소요보결 | 회피→반격→이탈 |
| 4 | D04_ALT_03 | 당소영 | 사천당문 · 천기암기록 | 원거리 압박→회피 보존 |
| 5 | D05 | 적우 | 화산파 · 매화검결 | 실제 HP 적중→연계 |
| 5 | D05_ALT_02 | 팽철산 | 하북팽가 · 팽가도결 | 방어 0→결착 |
| 5 | D05_ALT_03 | 당홍련 | 사천당문 · 천기암기록 | 독립 다단 지속 |

각 대표 무공은 **content identity anchor**다. 최종 적 loadout은 후속 권위에서 결정한다. 구현 시에는 해당 슬롯 역할을 실제 현행 카드·공용 행동으로 표현할 수 있는 합법적인 loadout/성취도를 선택해야 하지만 이 Decision이 그 숫자를 선결하지 않는다.

## 3. 후보 제작 규칙

모든 후보:

```yaml
readable_habit_min: 1
ambiguity_or_counterexample_min: 1
minimum_differentiation_axes_within_slot: 2
future_locked_plan_reveal: forbidden
correct_counter_recommendation: forbidden
ai_weight_reveal: forbidden
```

같은 대표 무공이 다른 슬롯에 다시 등장할 수 있다. 단, 같은 전투 질문을 반복해서는 안 된다. 화산 매화검결은 `첫 연격 경험 / 거리 추격 / 최종 다단 조건`처럼 서로 다른 문법을 맡고, 당문 천기암기록은 `거리 유지 / 회피 유인 / 독립 다단`으로 역할을 분리한다.

## 4. Route 8방문 승인 구조

```text
Duel 1 → R1 첫 정비 → I1 객잔의 두 소문 → Duel 2
Duel 2 → R2 오래된 수련터 → I2 문하 밖의 목격담 → Duel 3
Duel 3 → R3 길 위의 맞수련 → I3 관전과 정찰 → Duel 4
Duel 4 → R4 해질녘 마지막 정비 → I4 오봉의 세 가지 풍문 → Duel 5
```

각 방문은 선택지 2개가 기본이다.

- R1: `RECOVERY_MEDIUM` vs `MASTERY_FOCUS_SMALL`.
- I1: `PUBLIC_MANUAL_FACT` vs `HABIT_CLUE`.
- R2: `RECOVERY_SMALL/자원 안정` vs `MASTERY_BREADTH_SMALL`.
- I2: `PUBLIC_TECHNIQUE_RANGE` vs `HABIT/RESPONSE_CONDITION_CLUE`.
- R3: `MASTERY_FOCUS_SMALL` vs `MASTERY_BREADTH_SMALL`.
- I3: `RESPONSE_CONDITION_CLUE` vs `PUBLIC_TECHNIQUE_RANGE`.
- R4: `RECOVERY_MEDIUM` vs `MASTERY_FOCUS_SMALL`.
- I4: `CHAIN_CONDITION_CLUE` vs `PUBLIC_TECHNIQUE_RANGE/거리 성향`.

이 토큰은 의미 계약이며 숫자 보상은 아니다.

## 5. 정보 경계

정보는 다음 세 층으로만 표시한다.

- `공개`: 무공·카드·사거리·규칙처럼 확정된 공개 사실.
- `목격`: 과거 행동에서 관측 가능한 정성적 습관.
- `미확인`: 미래 계획·추정. 사실처럼 표현하지 않는다.

첫 Slice에는 의도적으로 거짓인 소문 RNG를 넣지 않는다. 플레이어의 불확실성은 UI가 거짓말해서가 아니라 **상대가 습관과 반례 사이에서 실제로 선택하기 때문에** 생긴다.

## 6. Slot 4 `[필중]` 경계

현재 공용 절초 `파공검기`에는 `[필중]`이 존재한다. Duel 4는 회피를 상대할 때 `[필중]`이라는 선택지가 가치 있어지는 상황을 만들 수 있다.

그러나:

- Briefing은 `파공검기를 쓰라`고 추천하지 않는다.
- 상대가 회피를 반드시 쓸 미래 수를 공개하지 않는다.
- `[필중]`이 유일한 해답이 되도록 설계하지 않는다.
- 회피 자원 소진·거리·공격 보류·막기·다른 대응 등 여러 판단을 남긴다.

## 7. Slot 5 종합 시험 경계

세 후보는 다단이 계속되는 조건을 분리한다.

- 적우 / 매화검결: 실제 체력 적중 수가 연계 확장의 조건.
- 팽철산 / 팽가도결: 상대 방어 0이 결착도의 조건.
- 당홍련 / 천기암기록: 정해진 독립 다단을 순차 처리하며 공통 사거리·중단 규칙을 우회하지 않음.

따라서 최종전은 `연격 N` 한 규칙만 재시험하지 않고 **연계 조건을 읽고 자기 3/3/4 계획을 버티게 만드는 종합 시험**으로 사용한다.

## 8. 텍스트 UX 승인 원칙

### Briefing

- 이름·이명·한 문장 인상.
- 확인된 정보 1~2개.
- Route에서 얻은 단서 1개.
- 상대 대사 2~4줄.
- 정답 추천 금지.

### Combat Review Overlay

- 실제 발생 사건 1~3개.
- `원인 → 판정 → 결과`.
- 미래 추천·미실행 분기 금지.
- CTA `결과 보기`.

### Duel Result 별도 Scene

- 승패.
- 상대 반응 1~3줄.
- 보상 선택/결과.
- Route 또는 완주 요약으로 이동.

### 완주 요약

- 실제 만난 5명.
- 실제 결정적 사건 1~3개.
- 공개 행동/무공 사용 기록.
- Route 선택 분포.
- 최종 성장 상태.
- 반복 또래 무인의 마지막 반응.
- 심리 진단·정답 빌드 판정 금지.

## 9. 콘텐츠 비용 상한

- 후보 Briefing 대사: 기본 2~4줄.
- 후보 Result 반응: 기본 1~3줄.
- Route 상황문: 기본 1~2문장.
- Route 선택지: 2개.
- Review: 결정적 사건 1~3개.
- 후보마다 장편 퀘스트·전용 Scene·전용 시스템을 만들지 않는다.

부모 시간 예산 `Briefing 15~30초`, `Route 20~40초`, `Review+Result 20~45초`를 유지한다.

## 10. 적대적 검토 결론

5회 전체 루프와 clean-exit 재공격을 수행했다.

1. 후보 15명 튜토리얼 스킨화 → 슬롯 내 최소 2축 차별화.
2. 구형 후보 계약의 정본 오염 → ID/이름/역할만 migration, 현재 10권으로 재결합.
3. 정보 노드 정답 누출 → 공개/목격/미확인 경계와 후보별 반례.
4. Route 지배 선택 → 숫자 고정 보류, 의미 토큰과 기회비용만 승인.
5. 텍스트가 전투를 잠식 → 짧은 모듈 예산과 2-choice.

Clean Exit에서 `[필중]` 강제정답, 반복 무공, 거짓 소문, Scene 경계, 미확인 숫자를 다시 공격했다.

```yaml
must_fix_remaining: 0
route_numeric_balance: NOT_RUN
human_ux_validation: NOT_RUN
```

## 11. 보호·제외

보호:

- 10칸 / 시작 거리2 / 3·3·4.
- 비공개 계획 / AI 미확정 계획 열람 금지.
- 관찰 정답 누출 방지.
- 5개 주요 비무의 기계 역할.
- 슬롯당 후보 3명.
- 비무 사이 정확히 2노드.
- Combat Review Overlay / Duel Result separate Scene / Route separate Scene.
- 시작 무공 6중4.

제외:

- 제품 코드·Scene·runtime data 변경.
- 최종 적 loadout·성취도·AI 확률.
- Route 정확 숫자 밸런스.
- 이미지·최종 아트·오디오.
- Android/Human PASS.
- 비무 6~10 완성.

## 12. 재검토 조건

- 동일 슬롯 3명이 같은 계획을 반복 유도.
- 정보 Route가 자동 정답 버튼이 됨.
- Route 한 선택이 측정에서 80% 이상 고정 선택.
- Slot 4에서 `[필중]`이 유일 정답화.
- Slot 5 후보 리듬이 실제 플레이에서 구분되지 않음.
- 텍스트 시간이 부모 UX 예산을 지속 초과.
- 최종 loadout 설계에서 대표 무공 앵커와 난이도 곡선이 충돌.
