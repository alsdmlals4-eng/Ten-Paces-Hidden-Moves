# 십보강호 PoC 통합 기획 전체 적대적 검토 루프

> Work Mode: `REVIEW`  
> Phase: `REVIEW_IN_PROGRESS`  
> 대상 PR: `#45`  
> 검토 기준 head: `1fea92e763f37d427ac2b28826fe4d4dc312edb8`  
> 상태: `REVIEW_PROPOSAL_COMPLETE / BUILD_NOT_AUTHORIZED`  
> 런타임·Godot·Windows·사람 증거: `NOT_RUN / UNVERIFIED`

## 1. 검토 계약

### 목표

승인된 PoC 기획을 실패했다고 가정하고, 문서·planning JSON·검사기·현행 런타임 소비자 사이의 모순과 구현 공백을 공격한다. 비판 자체도 재검증하고, 사실성이 확인된 항목만 다음 네 종류로 분류한다.

- `TECHNICAL_REVIEW_PROPOSAL`: 프로젝트 코어·사용자 결정의 변경 없이 기술적으로 최소 교정 가능한 항목.
- `USER_DECISION_REQUIRED`: 상충하는 게임 경험·경제·실패 정책 중 하나를 사용자가 선택해야 하는 항목.
- `BLOCKED_UNVERIFIED`: 정적 분석으로 닫을 수 없고 런타임·플레이·플랫폼 증거가 필요한 항목.
- `NO_CHANGE`: 공격 뒤에도 현행 승인 계약을 보호해야 하는 항목.

### 변경 권한

- REVIEW 산출물과 추적 기록 작성만 허용한다.
- 책임 원본·planning JSON·검사기·제품 런타임의 수정은 아직 허용하지 않는다.
- `USER_DECISION_REQUIRED`는 한 번에 하나씩 사용자에게 제시한다.
- 기술 검수안과 사용자 결정이 승인된 뒤에만 `BUILD`에서 최소 수정한다.
- 수정 뒤 다시 `REVIEW`로 돌아와 정적·참조·회귀 검증을 수행한다.

## 2. 검수 영향 범위 지도

| 층 | 책임·대상 | 주요 파일·증거 | 실패 시 영향 |
|---|---|---|---|
| A. 우선순위·진입점 | 작업자가 어떤 계약을 먼저 읽는가 | `AGENTS.md`, `README.md`, `START_HERE.md`, Active Context | 구형 규칙을 최신보다 우선 구현 |
| B. 승인·결정 원장 | 사용자 승인과 대체 관계 | PR #42·#45 댓글, PoC 기준선, REVIEW 교정 기록 | 폐기된 결정을 재도입하거나 최신 결정을 누락 |
| C. 질문별 책임 원본 | 게임·전투·콘텐츠·PoC·성장·UI·QA·아키텍처 | `docs/01~10` | 같은 개념을 문서마다 다르게 해석 |
| D. 편집 데이터 | 밸런스·무공·적·지도·보상·sanity | `docs/planning-data/*.json` | 편집값이 실행 의미를 잃거나 진행 경제 붕괴 |
| E. 데이터 검증 | ID·예산·참조·스테이지·효과 계약 | `tools/check_poc_planning_data.py`, unit tests, CI | 잘못된 데이터가 PASS |
| F. 현행 소비자 | 향후 어댑터가 연결할 실제 카드·전투·AI 구조 | `data/cards`, `src/combat`, 현행 T0 테스트 | 동일 기획을 서로 다른 런타임으로 구현 |
| G. 회차 상태 | 전투 간 체력·성장·보상·노드 진행 | 현재 책임 원본과 향후 `RunState` | 재시작 시 성장 소실, 보상 중복, 체력 이월 실패 |
| H. 표현·사용성 | 슬롯·타격·효과·성장·복기 | `docs/07`, `docs/10`, UI 런타임 | 규칙은 맞지만 플레이어가 원인을 이해하지 못함 |
| I. 플랫폼·증거 | Godot·Windows·성능·접근성·사람 검증 | Full Validation, STEP 14 | 정적 PASS를 실제 사용 가능으로 오인 |
| J. 보호 경로 | 기존 제품 코드·씬·에셋·저장 호환성 | `data/`, `src/`, `scenes/`, `assets/`, `project.godot` | 검수 중 제품 회귀 또는 사용자 변경 유실 |

## 3. 적대적 검토 패스

### Pass 1 — 권위·정본·참조 공격

실패 가정: 작업자가 최신 `docs/02_COMBAT_RULES.md`가 아니라 더 높은 우선순위의 구형 진입점 문구를 따른다.

검사:

- `AGENTS.md`의 우선순위와 현재 제품 계약.
- `README.md`의 phase·기준 SHA·노드 범위·기준선 링크.
- PR 추적 댓글의 대체 관계.
- Design Registry와 freshness 감시 대상.

결과:

- `AGENTS.md`에는 구형 같은 수 반감·구형 강건이 현재형으로 남아 있다.
- `README.md`에는 `PLANNING_IN_PROGRESS`, 중간 노드 2~4개, 구형 기준선과 “02는 이후 갱신 대상”이 남아 있다.
- 과거 PR 댓글의 전역 비무 5 절초 해금은 이후 댓글이 명시적으로 대체하므로 추적 증거 자체는 삭제하지 않는다.

### Pass 2 — 규칙·Schema·데이터 공격

실패 가정: planning JSON을 서로 다른 두 구현자가 읽었을 때 둘 다 validator를 통과하지만 공격 순서·이동·피해·효과가 달라진다.

검사:

- 기존 카드의 `resolution_phase`, `dash_before_attack`, `attack_power_coefficient`, targeting과 신규 무공 데이터 비교.
- 효과 scope/trigger와 지속 범위.
- 5·9성 patch의 필드·비용·적용 결과.
- 중앙 가격표와 기술 budget components의 기계적 연결.

결과:

- 신규 기술은 `move_range`만 있고 공격 전·후 이동을 구분하지 않는다.
- `damage/hits`가 원공격력인지 최종 피해인지 계수 입력인지 명시되지 않는다.
- 중앙 가격표를 바꿔도 기술 예산은 자동 재계산되지 않는다.
- patch 필드 오타·999틱 추가도 현행 validator가 허용한다.
- 다타격 `[필중]`의 지속 범위는 별도 사용자 결정이 필요하다.

### Pass 3 — 성장·보상·지도 경제 공격

실패 가정: 38포인트 집중 경로가 문서상 존재하지만 실제 생성 경로에서는 불가능하거나, 이중 보상으로 과도하게 빨라진다.

검사:

- 주요 비무별 `reward.training_points`와 중앙 `training_rewards.major_duel`의 소유권.
- `context_reward`의 자유 텍스트와 가산·대체 여부.
- 중간 노드 8~12개가 집중 성장 14를 공급할 수 있는지.
- 성과 등급 dimension의 실제 계산식.
- 의료 source의 무공 데이터·지도 데이터 일치.

결과:

- 주요 비무 보상이 두 파일에 중복 정의돼 이중 지급 또는 과소 지급이 가능하다.
- 중간 노드는 이름과 질적 보상만 있고 숫자·등장 제약이 없다.
- 성과 등급은 가중치와 경계만 있고 차원별 점수 산식이 없다.
- 음수 평가축, 모든 주요 비무 성장 보상 0, 빈 node catalog도 validator를 통과한다.
- 의료 공급표는 교차 파일 드리프트를 검사하지 않는다.

### Pass 4 — AI·런타임·상태·UX 공격

실패 가정: 데이터가 유효해도 현행 런타임 구조가 PoC 회차와 3/3/4 적 계획을 표현하지 못한다.

검사:

- 현행 `CombatState` 소유 범위.
- HP 이월·전투 시작 자원 초기화·성장·보상·노드 진행의 상태 경계.
- 현행 AI의 후보·점수·묶음 행동 반환.
- UI의 기본 절초 3종 + 해금 기술 증가에 대한 판독성.

결과:

- 현재 저장소에는 독립 `RunState`가 없고 전투 화면은 단일 `combat_state`를 소유한다.
- 승인된 HP 이월·자원 초기화 계약이 현재 PoC 정본에서 구현 가능한 상태 전이로 표현되지 않는다.
- 현행 AI planner는 한 묶음에 정확히 한 행동만 반환한다. “이동 뒤 연격” 같은 3수 계획을 실행할 데이터 계약이 없다.
- AI planning 데이터에는 숫자 score window·weight·modifier·묶음 template가 없다.
- UI 인지 부하·다타격 로그 가독성은 사람 증거 없이 닫을 수 없다.

### Pass 5 — 회귀·범위·증거 공격

실패 가정: 검수 수정을 하면서 코어를 바꾸거나, 정적 PASS를 런타임 완료로 잘못 승격한다.

검사:

- PoC 1~5와 확장 6~10·히든 경계.
- 비치팅 AI, 10칸·4/7·3/3/4, 연격 합·중단·강건 보호.
- 제품 경로 변경 여부.
- 현재 실행 가능한 검사와 실행하지 못한 검사 구분.
- PR branch가 main보다 1커밋 뒤인 상태.

결과:

- 프로젝트 코어와 확장 경계는 보호 가능하다.
- 기존 정적 CI 성공은 확인됐지만 신규 전체 Finding을 막는 검사는 아직 없다.
- Godot·Windows·사람·접근성·성능은 계속 `UNVERIFIED`다.
- 최종 회귀 전 main의 비충돌 1커밋을 branch에 동기화하고 baseline을 재고정해야 한다.

## 4. 비판 사실성·필요성 재검증

### 현재 validator가 거부하는 항목

현행 데이터와 9개 unit test는 다음을 실제로 거부한다.

- 예산 허용오차 초과.
- 알 수 없는 effect scope.
- 비공격 행동의 `ON_HIT`.
- 선적용 효과의 늦은 trigger.
- 중간 노드 수 범위 위반.
- 폐기된 비무 번호 절초 해금.

### 현재 validator가 잘못 허용하는 반례

동일 head 데이터를 임시 복제하고 아래 한 항목씩 변조한 뒤 validator를 재실행했다. 여덟 반례가 모두 `PASS`했다.

| 반례 | 변조 | 실제 결과 | 판정 |
|---|---|---|---|
| CE-01 | 존재하지 않는 patch 필드 + `added_budget_ticks=999` | PASS | 검사 공백 확인 |
| CE-02 | 알 수 없는 effect condition | PASS | 검사 공백 확인 |
| CE-03 | 지도 의료 공급량만 1→4로 변경 | PASS | 교차 파일 검사 공백 |
| CE-04 | AI phase condition/effect 오타 | PASS | 실행 어휘 검사 공백 |
| CE-05 | 주요 비무 보상 999, 금전 -100, 설명 `???` | PASS | 범위·형식 검사 공백 |
| CE-06 | 모든 주요 비무 수련포인트 0 | PASS | 성장 도달성 검사 공백 |
| CE-07 | 평가축 130/-30/0/0/0, 합계 100 | PASS | 개별 범위 검사 공백 |
| CE-08 | `node_types={}` | PASS | PoC node catalog 검사 공백 |

따라서 아래 기술 Finding은 “가능성”이 아니라 재현된 false pass와 실제 소비자 불일치에 근거한다.

## 5. Finding 분류

### 5.1 `TECHNICAL_REVIEW_PROPOSAL`

| ID | 심각도 | 검증된 문제 | 최소 검수안 | 승인 전 상태 |
|---|---|---|---|---|
| TRP-01 | HIGH | `AGENTS.md`·`README.md`가 구형 규칙·phase·노드 범위·기준선을 현재형으로 노출 | root entrypoint를 현재 REVIEW 기준과 2~3노드·최신 정본으로 갱신하고 freshness 금지 토큰 추가 | 미반영 |
| TRP-02 | HIGH | 승인된 체력 이월·성장·보상과 전투 상태가 분리되지 않음 | `RunState`와 `CombatState` 책임·전투 전후 변환·재시작 경계를 명세 | 미반영; 패배 정책은 UDR-01 대기 |
| TRP-03 | HIGH | 무공 기술의 실행 순서·이동 전후·대상·피해 공식이 불완전 | 정규화 card contract: `resolution_phase`, movement timing/mode, targeting, raw powers/coefficient policy | 미반영 |
| TRP-04 | HIGH | 중앙 가격표와 기술 예산이 수동 숫자로 분리 | `price_id + quantity + derived_ticks` ledger로 재계산, 중앙 가격 변경 diff 생성 | 미반영 |
| TRP-05 | HIGH | 5·9성 patch가 오타·999틱·허용 범위 초과를 허용 | patch 허용 필드·대상 타입·전후 계산·+5틱 정책을 Schema와 validator로 강제 | 미반영 |
| TRP-06 | HIGH | 주요 비무 보상이 duel과 map에 이중 소유 | 중앙 공식 단일 소유, duel은 구조화된 override/선택 보상 ID만 소유 | 미반영; 선택 의미는 UDR-03 대기 |
| TRP-07 | HIGH | 성과 등급이 가중치만 있고 산식이 없음 | 각 dimension 0~100 산식·부분점수·공개 과제 판정·clamp·설명 event 정의 | 미반영 |
| TRP-08 | HIGH | AI 데이터가 점수·modifier·3수 계획을 실행하지 못함 | score window·weights·조건 modifier·bundle template·timing/targeting·fallback을 구조화 | 미반영 |
| TRP-09 | HIGH | 중간 노드가 숫자·ID·등장 제약 없이 38포인트 도달성을 주장 | stable node ID, numeric choices, gap constraints, seed, 집중 성장 최소 공급 검증 | 미반영 |
| TRP-10 | MEDIUM | 의료 공급이 무공·지도 두 파일에서 드리프트 가능 | 누적 의료 파생값과 source delta를 교차 검증 | 미반영 |
| TRP-11 | MEDIUM | 시작 3성 무공의 1성 passive 활성과 신규 무공·중복 처리 불명확 | 시작 passive 활성, 신규 manual 초기 성급, duplicate conversion을 구조화 | 미반영 |
| TRP-12 | HIGH | validator가 재현 반례 8개를 허용 | CE-01~08 및 정상·경계 반례를 unit test와 CI에 추가 | 미반영 |
| TRP-13 | MEDIUM | 가장 큰 무공 JSON이 한 줄로 저장돼 편집성과 review diff가 나쁨 | canonical pretty-print, stable key/order, formatter check | 미반영 |
| TRP-14 | MEDIUM | PR branch가 main보다 1커밋 뒤이며 최종 baseline이 오래됨 | 승인 BUILD 직전 main merge 동기화, 충돌·보호 경로·baseline SHA 재고정 | 미반영 |

### 5.2 `USER_DECISION_REQUIRED`

아래 항목은 기술적으로 한 답을 고르면 게임 경험·실패 비용·전술 가치가 달라지므로 임의로 확정하지 않는다. 사용자에게 한 번에 하나씩 제시한다.

| 순서 | ID | 결정 주제 | 현재 상태 |
|---:|---|---|---|
| 1 | UDR-01 | 전투 패배 시 회차 종료·재도전·체크포인트 정책 | 첫 질의 대상 |
| 2 | UDR-02 | 다타격 기술의 `[필중]`이 전체 행동에 유지되는지 첫 유효 타격 1회만 보호하는지 | 대기 |
| 3 | UDR-03 | 주요 비무의 문파/지정 수련 `또는` 보상이 중앙 기본·등급 수련포인트에 추가인지 대체인지 | 대기 |

### 5.3 `BLOCKED_UNVERIFIED`

| ID | 미검증 항목 | 필요한 증거 |
|---|---|---|
| BUV-01 | 일반전 대부분 3라운드 이내 체감 | 실제 새 엔진 자동 시뮬레이션 + 플레이 로그 |
| BUV-02 | 주요 비무 5 전 38포인트 집중 경로의 실제 빈도·강제성 | 생성 seed 대량 시뮬레이션 + 분산 빌드 비교 |
| BUV-03 | 체력 이월·의료 0~4의 attrition 적합성 | 5전 연속 플레이·회복 선택 데이터 |
| BUV-04 | 13~17노드의 시간·피로·중도 이탈 | 사람 PoC 세션 |
| BUV-05 | 기초 8 + 기본 절초 3 + 무공 기술 증가의 UI 인지 부하 | UI prototype·초견 과제 성공률 |
| BUV-06 | 순차 연격·효과 로그의 가독성·접근성 | 모션 감소·키보드·저시력 포함 사람 검증 |
| BUV-07 | 공개 상태 AI의 공정성·성향 판독·재현성 | Godot runtime trace·seed replay |
| BUV-08 | Windows·Godot·성능·저장 호환성 | Full Validation·Windows 실행·migration test |
| BUV-09 | 재미·재도전 의향·시장 적합성 | STEP 14 사람 증거·외부 비교 플레이 |

### 5.4 `NO_CHANGE`

공격 뒤에도 다음은 현행 승인 상태를 보호한다.

- NC-01: 1대1 무협 비무, 10칸, 시작 4/7, 비공개 `3→3→4`.
- NC-02: 순차 타격쌍 `[합]`, 체력 피해 중단, `[강건]` 1회, 승자 잔여타.
- NC-03: 공격 행동당 전투원별 합 기세 최대 +1.
- NC-04: PoC 주요 비무 1~5, 네 구간 2~3노드, 총 13~17노드.
- NC-05: 스테이지 2·3과 히든은 확장 범위이며 첫 구현에서 제외.
- NC-06: 기본 절초 3종 시작 가용, 무공별 10성 절초 성급 해금.
- NC-07: 0.05=1틱 정수 예산과 기존 기술 자동 변경 금지 원칙.
- NC-08: planning JSON은 source-only/non-runtime이며 어댑터·검증 없이 직접 런타임 사용 금지.
- NC-09: AI는 플레이어 미확정 계획을 읽지 않는 공개 상태 기반 경계.
- NC-10: 덱·손패·장착 제한 없이 해금 기술을 항상 사용 가능.
- NC-11: 과거 PR 댓글은 역사 증거로 보존하고 최신 대체 댓글·책임 원본을 현재 계약으로 사용.

## 6. 기술 판단 가능 항목 일괄 검수안

사용자 결정과 충돌하지 않는 기술 항목은 다음 한 묶음으로 제안한다. 아직 BUILD 승인은 아니다.

1. root entrypoint·Active Context·문서 지도의 최신 기준 정렬.
2. `RunState`/`CombatState` 명세와 전투 전후 데이터 변환 경계.
3. 무공 card 실행 Schema와 5·9성 patch Schema 정규화.
4. 중앙 tick ledger의 기계적 재계산과 condition/effect 어휘 통제.
5. 보상·등급·node catalog·AI profile의 구조화된 ID와 숫자 계약.
6. 의료·성장 도달성·참조를 교차 검증하는 validator 확장.
7. CE-01~08 회귀 테스트와 malformed/edge/boundary 반례 추가.
8. planning JSON pretty-print와 deterministic formatting.
9. main 동기화 뒤 보호 경로·baseline diff 재검증.

보호 대상:

- 프로젝트 코어와 PoC 범위.
- 현행 런타임 파일과 사용자/Codex 변경.
- 기존 ID는 가능하면 유지하고 migration mapping을 명시.
- 확장 6~10·히든을 첫 구현에 끌어오지 않음.

## 7. 첫 번째 사용자 결정 — UDR-01 대기

전투 패배 뒤 회차의 상태와 재도전 정책이 승인 원장에 없다. HP 이월과 5전 attrition을 구현하려면 이 결정이 먼저 필요하다. 선택지는 사용자에게 별도 메시지에서 한 번에 하나의 질문으로 제시한다.

## 7.1 사용자 결정 종료와 BUILD 승인 범위

- UDR-01: 전투 직전 `RunState` 유료 재도전. 같은 전투 `[영구재화]` 1→2→3, 다른 전투에서 초기화.
- UDR-02: 스택형 `[필중]`; 실제 회피 우회 유효 타격당 1스택 소비.
- UDR-03: 자유6 / 지정5+자유3 / 문파 무공3성. 제한이 강할수록 총 가치가 높음.
- 38포인트: 집중32+최소 노드6, 자유24+고효율 노드14.

위 결정과 `TECHNICAL_REVIEW_PROPOSAL`의 planning 정본·Schema·validator·회귀 테스트 교정만 BUILD 승인 범위다. 제품 runtime 변경은 승인 범위가 아니다.

## 8. 다음 상태 전이

```text
현재 REVIEW
→ UDR-01부터 사용자 결정 순차 확정
→ 기술 검수안 + 확정된 사용자 결정의 BUILD 범위 승인
→ BUILD에서 최소 수정
→ REVIEW 복귀
→ project operating system
→ reference freshness
→ planning validator + 회귀 테스트
→ 실제 어댑터가 있으면 Godot runtime/replay/save migration
→ Windows·접근성·성능·사람 검증은 실행한 것만 증거화
→ PASS / PASS_WITH_FOLLOWUP / REVISE_AGAIN / UNVERIFIED 최종 판정
```

## 9. 현재 판정

```yaml
review_attack: COMPLETE_FOR_CURRENT_SOURCES
critique_revalidation: COMPLETE
technical_review_proposals: 14
user_decisions_required: 3
blocked_unverified: 9
protected_no_change: 11
build_authorized: false
runtime_validation: NOT_RUN
human_validation: UNVERIFIED
final_review_decision: AWAITING_USER_DECISIONS_AND_BUILD_APPROVAL
phase: REVIEW_IN_PROGRESS
```
