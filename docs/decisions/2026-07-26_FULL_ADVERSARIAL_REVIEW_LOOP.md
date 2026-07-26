# 십보강호 PoC 통합 기획 전체 적대적 검토 루프

> Work Mode: `REVIEW`  
> Phase: `REVIEW_IN_PROGRESS`  
> 대상 PR: `#45`  
> 공격 기준 head: `1fea92e763f37d427ac2b28826fe4d4dc312edb8`  
> 승인 BUILD commit: `9e485472c3bb8cbb852267e08ed4b76075b5b3b3`  
> 최종 정적 검증 head: `eb06bd78316348bd3aa6027a8057575ee4dc9053`  
> 판정: `PASS_WITH_FOLLOWUP`

## 1. 검토 계약

목표는 승인된 PoC 기획이 실패했다고 가정하고 문서·planning JSON·검사기·현행 런타임 소비자 사이의 모순과 구현 공백을 공격하는 것이다. 공격에서 나온 비판도 다시 검증하고, 사실성과 필요성이 확인된 항목만 최소 수정했다.

Finding 분류:

- `TECHNICAL_REVIEW_PROPOSAL`: 사용자 결정이나 프로젝트 코어를 바꾸지 않고 기술적으로 교정 가능한 항목.
- `USER_DECISION_REQUIRED`: 게임 경험·경제·실패 비용이 달라져 사용자 결정이 필요한 항목.
- `BLOCKED_UNVERIFIED`: 정적 분석으로 닫을 수 없고 runtime·플랫폼·사람 증거가 필요한 항목.
- `NO_CHANGE`: 공격 뒤에도 현행 계약을 보호하거나 비판을 기각한 항목.

변경 권한:

- 공격·비판 재검증은 `REVIEW`에서 수행.
- 사용자 결정은 한 번에 하나씩 확정.
- 승인된 planning 정본·Schema·validator·테스트만 `BUILD`에서 최소 수정.
- 제품 runtime 경로는 수정하지 않음.
- BUILD 뒤 `REVIEW`로 복귀해 정적·참조·회귀 검증.

## 2. 검수 영향 범위 지도

| 층 | 책임·대상 | 주요 파일·증거 | 실패 시 영향 |
|---|---|---|---|
| A. 진입점 | 작업자가 먼저 읽는 현재 계약 | `AGENTS.md`, `README.md`, `START_HERE.md`, Active Context | 구형 규칙을 최신보다 우선 구현 |
| B. 승인 원장 | 사용자 승인과 대체 관계 | PR #42·#45 댓글, PoC 기준선 | 폐기 결정을 재도입하거나 최신 결정을 누락 |
| C. 책임 원본 | 게임·전투·콘텐츠·PoC·성장·UI·QA·아키텍처 | `docs/01~10` | 같은 개념을 문서마다 다르게 해석 |
| D. 편집 데이터 | 밸런스·무공·적·지도·보상·sanity·RunState | `docs/planning-data/*.json` | 실행 의미 상실·성장 경제 붕괴 |
| E. 데이터 검증 | ID·예산·참조·효과·노드·보상·상태 계약 | validator·unit test·CI | 잘못된 데이터가 PASS |
| F. 현행 소비자 | 실제 카드·전투·AI 구조 | `data/cards`, `src/combat`, T0 테스트 | 같은 기획을 서로 다른 런타임으로 구현 |
| G. 회차 상태 | 체력·성장·보상·재도전·노드 진행 | `RunState`와 `CombatState` | 보상 중복·체력 이월 실패·재시작 악용 |
| H. 표현·사용성 | 슬롯·타격·효과·성장·복기 | `docs/07`, `docs/10`, UI runtime | 규칙은 맞지만 원인을 이해하지 못함 |
| I. 플랫폼·증거 | Godot·Windows·성능·접근성·사람 | Full Validation, STEP 14 | 정적 PASS를 실제 사용 가능으로 오인 |
| J. 보호 경로 | 기존 제품 코드·씬·에셋·저장 | `data/`, `src/`, `scenes/`, `assets/`, `addons/`, `project.godot` | 검수 중 제품 회귀 또는 변경 유실 |

## 3. 적대적 공격 패스

### Pass 1 — 권위·정본·참조

실패 가정: 구현자가 최신 전투 규칙보다 상위 진입점의 구형 문구를 따른다.

확인된 문제:

- root 진입점에 구형 phase·노드 범위·전투 표현이 현재형으로 남아 있었다.
- 과거 댓글의 전역 비무 5 절초 해금은 역사 증거로 보존하되 최신 댓글과 정본이 대체 관계를 명시해야 했다.
- Registry·freshness 감시 토큰이 현재 문서 제목과 드리프트할 수 있었다.

### Pass 2 — 규칙·Schema·데이터

실패 가정: 두 구현자가 같은 planning JSON을 읽고 서로 다른 이동 순서·피해·효과를 구현해도 validator를 통과한다.

확인된 문제:

- 기술의 `resolution_phase`, 공격 전후 이동, targeting, 원공격력 입력이 불완전했다.
- 중앙 tick 가격표와 개별 기술 budget이 수동 숫자로 분리돼 있었다.
- 5·9성 patch의 허용 필드와 추가 tick을 위조할 수 있었다.
- 다타격 `[필중]`의 적용 단위가 미결정이었다.

### Pass 3 — 성장·보상·지도 경제

실패 가정: 문서상 38포인트 경로가 실제 생성에서는 불가능하거나 이중 보상으로 성장 속도가 폭주한다.

확인된 문제:

- 주요 비무 보상이 duel과 중앙 공식에 중복 소유됐다.
- 중간 노드가 이름만 있고 stable ID·숫자 보상·구간 제약이 없었다.
- 등급은 가중치와 경계만 있고 차원별 점수 산식이 없었다.
- 무공과 지도 사이 `[의료]` 공급 드리프트를 교차 검사하지 않았다.

### Pass 4 — AI·런타임·상태·UX

실패 가정: planning 데이터가 유효해도 현행 구조가 5전 회차와 3수 적 계획을 표현하지 못한다.

확인된 문제:

- 독립 `RunState`가 없고 현행 전투 화면은 단일 `combat_state`만 소유한다.
- 체력 이월·전투 자원 초기화·보상 commit·재도전 rollback 경계가 명세되지 않았다.
- 현행 AI는 한 묶음에 한 행동만 반환하며 이동 뒤 연격 같은 3수 계획 데이터가 없었다.
- UI 인지 부하와 다타격 로그 가독성은 사람 증거 없이는 닫을 수 없다.

### Pass 5 — 회귀·범위·증거

실패 가정: 검수 교정이 프로젝트 코어·확장 경계·기존 제품을 바꾸거나 정적 PASS를 런타임 완료로 승격한다.

확인 결과:

- 1대1·10칸·4/7·3/3/4·순차 합·비치팅 AI·PoC 1~5·확장 6~10/히든 경계는 보호 가능했다.
- 제품 경로를 건드리지 않고 planning 계약만 교정할 수 있었다.
- Godot·Windows·접근성·성능·사람 검증은 계속 별도 증거가 필요하다.

## 4. 비판 사실성·필요성 재검증

공격 기준 데이터를 임시 복제하고 한 항목씩 변조한 뒤 validator를 실행했다. 다음 여덟 반례가 모두 잘못 `PASS`하여 검사 공백이 사실로 확인됐다.

| 반례 | 변조 | 공격 기준 결과 | BUILD 후 결과 |
|---|---|---|---|
| CE-01 | 존재하지 않는 patch 필드 + `added_budget_ticks=999` | PASS | REJECT |
| CE-02 | 알 수 없는 effect condition | PASS | REJECT |
| CE-03 | 지도 의료 공급만 1→4로 변경 | PASS | REJECT |
| CE-04 | AI phase condition/effect 오타 | PASS | REJECT |
| CE-05 | 주요 비무 수련 999·금전 -100·설명 `???` | PASS | REJECT |
| CE-06 | 모든 주요 비무 수련 보상 0 | PASS | REJECT |
| CE-07 | 평가축 130/-30/0/0/0 | PASS | REJECT |
| CE-08 | `node_types={}` | PASS | REJECT |

따라서 TRP-01~13은 취향성 개선이 아니라 재현된 false pass와 실제 소비자 불일치에 근거한 교정으로 판정했다.

## 5. Finding 분류와 처리

### 5.1 `TECHNICAL_REVIEW_PROPOSAL`

| ID | 심각도 | 검증된 문제 | 처리 |
|---|---|---|---|
| TRP-01 | HIGH | root 진입점의 구형 규칙·phase·범위 | BUILD 반영·검증 완료 |
| TRP-02 | HIGH | `RunState`와 `CombatState` 책임 부재 | BUILD 반영·검증 완료 |
| TRP-03 | HIGH | 기술 실행 순서·이동·대상·피해 공식 불완전 | BUILD 반영·검증 완료 |
| TRP-04 | HIGH | 중앙 가격표와 기술 예산 분리 | BUILD 반영·검증 완료 |
| TRP-05 | HIGH | 5·9성 patch 오타·위조 tick 허용 | BUILD 반영·검증 완료 |
| TRP-06 | HIGH | 주요 비무 보상 이중 소유 | BUILD 반영·검증 완료 |
| TRP-07 | HIGH | 성과 등급 차원별 산식 부재 | BUILD 반영·검증 완료 |
| TRP-08 | HIGH | AI score·modifier·3수 template 부재 | BUILD 반영·검증 완료 |
| TRP-09 | HIGH | stable node·숫자 보상·38포인트 생성 제약 부재 | BUILD 반영·검증 완료 |
| TRP-10 | MEDIUM | 의료 source 교차 드리프트 | BUILD 반영·검증 완료 |
| TRP-11 | MEDIUM | 시작 passive·신규 무공·중복 처리 불명확 | BUILD 반영·검증 완료 |
| TRP-12 | HIGH | CE-01~08 false pass | BUILD 반영·검증 완료 |
| TRP-13 | MEDIUM | 무공 JSON 한 줄 저장·diff 불가 | BUILD 반영·검증 완료 |
| TRP-14 | MEDIUM | branch가 main 역사보다 1커밋 뒤 | `NO_CHANGE / BASE_PRESERVED_BY_PR_MERGE`로 재분류 |

TRP-14 재검증:

- PR base는 `main@48c26c02d53fe49a34b831f5bcf0924ae36f5dbd`다.
- main 전용 1커밋의 변경은 승인 BUILD 경로와 겹치지 않는다.
- PR 가상 병합은 `mergeable=true`로 base를 보존한다.
- 별도 merge commit은 동일 base 내용을 branch 역사에 중복하므로 만들지 않았다.

### 5.2 `USER_DECISION_REQUIRED`

| ID | 사용자 확정 | BUILD 계약 |
|---|---|---|
| UDR-01 | 패배 시 전투 직전 `RunState` 복원 재도전 | 같은 seed·전투 결과 rollback·영구재화 지불 비rollback |
| UDR-01B | 같은 전투 재도전 비용 1→2→3, 상한 3 | 다른 전투 진입 시 1로 초기화, 잔액 부족 시 재도전 금지 |
| UDR-02 | 스택형 `[필중]` | 실제 회피를 우회한 유효 타격마다 1스택 소비 |
| UDR-03 | 자유6 / 지정5+자유3 / 문파 무공3성 | 자유도 제한이 강할수록 가치 증가, 보상 중복 금지 |
| 성장 경로 | 주요 비무 5 진입 전 10성 가능 | 집중32+노드6 또는 자유24+고효율 노드14 = 38 |

### 5.3 `BLOCKED_UNVERIFIED`

| ID | 미검증 항목 | 필요한 증거 |
|---|---|---|
| BUV-01 | 일반전 대부분 3라운드 이내 체감 | 새 엔진 자동 시뮬레이션 + 플레이 로그 |
| BUV-02 | 38포인트 집중 경로의 실제 빈도·강제성 | 생성 seed 대량 시뮬레이션 + 분산 빌드 비교 |
| BUV-03 | 체력 이월·의료 0~4 attrition | 5전 연속 플레이·회복 선택 데이터 |
| BUV-04 | 13~17노드 시간·피로·이탈 | 사람 PoC 세션 |
| BUV-05 | 행동·절초·무공 증가의 UI 인지 부하 | UI prototype·초견 과제 성공률 |
| BUV-06 | 순차 연격·효과 로그 접근성 | 모션 감소·키보드·저시력 사람 검증 |
| BUV-07 | 공개 상태 AI 공정성·재현성 | Godot trace·seed replay |
| BUV-08 | Windows·Godot·성능·저장 호환성 | Full Validation·Windows·migration test |
| BUV-09 | 재미·재도전 의향·시장 적합성 | STEP 14 사람 증거·외부 비교 플레이 |

### 5.4 `NO_CHANGE`

- 1대1 무협 비무, 10칸, 시작 4/7, 비공개 `3→3→4`.
- 순차 타격쌍 `[합]`, 체력 피해 중단, `[강건]` 1회, 승자 잔여타.
- 공격 행동당 전투원별 합 기세 최대 +1.
- PoC 주요 비무 1~5, 네 구간 2~3노드, 총 13~17노드.
- 스테이지 2·3과 히든은 확장 범위.
- 기본 절초 3종 시작 가용, 무공별 10성 절초 성급 해금.
- 0.05=1tick 정수 예산과 기존 기술 자동 변경 금지.
- planning JSON은 source-only/non-runtime.
- AI는 플레이어 미확정 계획을 읽지 않음.
- 덱·손패·장착 제한 없음.
- 과거 PR 댓글은 역사 증거로 보존.
- PR base 보존을 위해 불필요한 branch merge commit을 만들지 않음.

## 6. 승인 BUILD

승인 범위는 planning 정본·JSON·validator·테스트에 한정했다.

- 정규화 card contract: phase·movement timing/mode·targeting·raw hit power.
- 중앙 tick price ledger와 derived tick 재계산.
- 5·9성 patch 허용 필드·대상·전후 값·추가 tick 검사.
- 구조화된 AI score window·weight·condition modifier·3수 template·fallback.
- stable node ID·숫자 reward·gap constraint·seed 결정성.
- 자유6 / 지정5+자유3 / 문파 무공3성 option set.
- 집중32+노드6, 자유24+고효율 노드14 경로.
- 등급 dimension 0~100 산식·가중합·반올림·clamp.
- `poc_run_state_contract.json`: 상태 소유·snapshot·승리 commit·유료 재도전.
- 의료·성장·ID·참조 교차 검증.
- CE-01~08과 malformed·boundary 회귀 테스트.
- planning JSON canonical pretty-print.

제품 `data/`, `src/`, `scenes/`, `assets/`, `addons/`, `project.godot`은 변경하지 않았다.

## 7. REVIEW 복귀와 검증

로컬:

```text
python -m unittest tests.test_poc_planning_data -v
→ 24/24 PASS

python tools/check_poc_planning_data.py --root .
→ PoC planning data: PASS
```

원격 PR Validation #775:

- project operating system: PASS.
- canonical reference freshness: PASS.
- Skill package·archive·governance: PASS.
- planning data 24개 테스트: PASS.
- canonical combat impact map: PASS.
- card/combat/rival/A2/A3/prepare 기존 계약: PASS.
- PowerShell parse: PASS.

## 8. 회귀 재검토

- CE-01~08 원래 실패 사례: 차단됨.
- 프로젝트 코어·PoC 1~5·확장 경계: 유지됨.
- 기본 절초·10성 절초·성장 경로: 최신 사용자 결정과 정렬됨.
- planning JSON의 ID·Schema·참조·canonical formatting: 검사됨.
- 제품 runtime 경로: 변경 없음.
- 신규 runtime·Godot·Windows·저장 migration·접근성·성능·사람: 실행하지 않았으며 미검증으로 유지.

## 9. 최종 판정

```yaml
review_attack: COMPLETE
critique_revalidation: COMPLETE
technical_review_proposals: 14
technical_findings_applied: 13
technical_finding_reclassified_no_change: 1
user_decisions_required: 3
user_decisions_resolved: 3
blocked_unverified: 9
protected_no_change: 12
planning_build: APPLIED
static_validation: PASS
reference_validation: PASS
regression_validation: PASS
protected_runtime_paths: PASS_UNCHANGED
runtime_validation: NOT_RUN
human_validation: UNVERIFIED
final_review_decision: PASS_WITH_FOLLOWUP
phase: REVIEW_IN_PROGRESS
```

`PASS_WITH_FOLLOWUP`은 planning 구현 계약의 정합성과 정적 검수 통과 판정이다. 신규 Godot runtime·Windows·저장 migration·접근성·성능·사람 플레이는 계속 `BLOCKED_UNVERIFIED`다. 사용자의 정확한 `검수 완료` 전에는 Codex 구현 인계로 전환하지 않는다.
