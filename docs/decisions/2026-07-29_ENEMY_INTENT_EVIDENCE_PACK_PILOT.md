# 적 의도 단서·추론 Evidence Pack Pilot

```yaml
evidence_pack_id: TEN-PACES-EVP-001
project: 십보강호
baseline_branch: main
baseline_commit: 91d09010e5a583c829f2535caf5027016a20c2f1
created_at: 2026-07-29
work_mode: PLAN
status: PILOT_RECOMMENDATION
implementation_authority: NONE
human_validation: NOT_RUN
method_reference: Base dc9603595155989e13fb92edff347df5c725217e
```

> 이 문서는 v6 결정 원장을 대체하지 않는다. 제품 코드·데이터·Scene 변경을 승인하지 않으며, 적 의도 정보 설계의 다음 플레이테스트 질문을 좁히는 계획 입력이다.

## 1. 현재 코어와 보호 경계

- 플레이어 약속: 상대의 다음 행동 단서를 모아 가설을 세우고 여러 수의 계획으로 의도를 무너뜨린다.
- 한 라운드: `3수 → 해결 → 3수 → 해결 → 4수 → 해결`.
- AI는 플레이어의 미확정 계획을 읽지 않는다.
- 덱·손패·드로우·장착 기술 제한을 사용하지 않는다.
- 최신 설계 권한은 `docs/decisions/2026-07-28_V6_DECISION_AUTHORITY_LEDGER.md`가 소유한다.
- 정확한 다음 행동을 사전에 전부 공개해 추론을 제거하거나, 치명적 정보를 숨겨 찍기를 강요하지 않는다.

## 2. 결정 질문

> 플레이어가 상대의 숨은 수를 **읽었다고 느끼면서도**, 단순한 정답 아이콘을 따라 누르지 않게 하려면 각 3/3/4 계획 묶음 전에 어떤 적 의도 정보와 확신 수준을 제공해야 하는가?

### 성공 조건

- 신규 플레이어가 공개 정보만으로 하나 이상의 합리적인 가설을 말할 수 있다.
- 실패 뒤 `운이 없었다`보다 `내가 어떤 단서를 잘못 해석했다`를 설명한다.
- 숙련자는 동일 단서에서 복수 대응을 비교한다.
- 계획 시간이 과도하게 늘지 않는다.
- 사전 정보와 해결 후 설명이 실제 규칙과 일치한다.

### 실패 조건

- 정확 행동·피해·대응 정답이 한 아이콘에 사실상 확정된다.
- 핵심 단서가 장식·대사·과거 로그에만 숨어 있다.
- 해결 후 새 정보가 소급 등장해 플레이어 가설을 무효화한다.
- 단서 종류가 많아질수록 추론이 아니라 기억 시험이 된다.

## 3. 선택 Coverage

| Coverage | 상태 | 이유 |
|---|---|---|
| 프로젝트 코어·게임 기획 | EVIDENCED | 읽기와 파훼가 코어 자체다. |
| 플레이어 경험·난이도 | EVIDENCED | 추론감과 찍기감의 경계를 결정한다. |
| UX·UI·접근성 | EVIDENCED | 단서의 시각·텍스트 중복과 정보 위계가 필요하다. |
| 벤치마킹·GUR | EVIDENCED | 행동과 자기보고를 분리해 검증해야 한다. |
| 구현·밸런스 | NOT_APPLICABLE | 이번 Pilot은 런타임 수치·AI 로직을 변경하지 않는다. |

## 4. Evidence

| ID | 층 | 출처 | 확인된 활용점 | 한계 |
|---|---|---|---|---|
| EVD-TP-01 | T2_PROFESSIONAL_PRACTICE | Clint Hocking, GDC 2006, Designing to Promote Intentional Play | 플레이어가 게임 동학을 이해하고 목표와 수단을 세울 수 있어야 의도적 플레이가 가능하며, 높은 투명성에는 비용과 위험도 있다. | 십보강호의 구체 정보량을 직접 제시하지 않는다. |
| EVD-TP-02 | T2_PROFESSIONAL_PRACTICE | Matthew Davis, GDC 2019, Into the Breach Design Postmortem | 전술 게임의 난이도·RNG·기능 제거를 반복 설계 문제로 다룬다. | 적 의도 UI를 그대로 복제할 근거가 아니다. |
| EVD-TP-03 | T2_PROFESSIONAL_PRACTICE | Anthony Giovannetti, GDC 2019, Slay the Spire: Metrics Driven Design and Balance | 밸런스 판단을 실제 플레이 지표와 커뮤니티 피드백으로 반복 보정했다. | 카드·덱 구조와 십보강호의 무공 전면 사용 구조가 다르다. |
| EVD-TP-04 | T6_AI_INFERENCE | 본 Pilot 종합 | 단서 공개량보다 `가설 가능성`, `대응 다양성`, `해결 후 인과 설명`을 함께 측정해야 한다. | 사람 플레이 전에는 가설이다. |

## 5. 대안 비교

### A. 정확 행동 완전 공개

- 장점: 이해가 빠르고 억울함이 적다.
- 위험: 읽기보다 정답 대응 퍼즐이 되어 코어를 약화한다.
- 판정: `AVOID`.

### B. 방향성 단서 + 공개 상태 + 해결 후 인과 공개

- 사전에는 행동 범주·거리 변화·기세·준비 흔적 등 **복수 해석 가능한 방향성 단서**를 제공한다.
- 현재 거리·자원·최근 해결 기록은 항상 접근 가능하게 유지한다.
- 해결 후에는 실제 행동과 단서의 연결, 플레이어 계획이 무엇을 막고 무엇을 허용했는지 공개한다.
- 판정: `ADAPT`.

### C. 최소 정보·로그 추론 중심

- 장점: 높은 숙련 천장과 긴장감.
- 위험: 신규 플레이어에게 기억·암기·찍기 문제로 보일 수 있다.
- 판정: 기본 난이도 `AVOID`, 별도 숙련 변형은 `TEST` 후보.

## 6. Pilot 권장안

최종 판정: **`ADAPT` — B안을 검증용 기본안으로 사용한다.**

### 정보 4층

1. **항상 공개:** 거리, 자원, 상태, 최근 해결 결과.
2. **이번 묶음 단서:** 최대 2~3개의 방향성 단서. 색상만으로 구분하지 않고 아이콘·짧은 문구를 병행한다.
3. **플레이어 메모:** 선택 행동을 추가하지 않는 가벼운 예상 표시. 보상·벌점과 연결하지 않는다.
4. **해결 후 설명:** 실제 의도, 단서 근거, 계획과 결과의 인과.

### 금지

- `다음 행동: 돌진`처럼 정확 정답을 기본 UI에서 확정 표시.
- 해결 전 보이지 않던 조건으로 결과를 뒤집기.
- 단서 하나와 대응 하나를 고정 연결해 암기표로 만들기.
- 상대가 플레이어 미확정 계획을 읽는 연출.

## 7. 플레이테스트 계약

```yaml
build_or_artifact: paper_or_clickable_combat_readability_prototype
tester_segment:
  - 신규 전술 게임 플레이어 3명 이상
  - 유사 장르 경험자 3명 이상
tasks:
  - 단서 확인 후 상대 행동 가설 말하기
  - 3수 계획 이유 말하기
  - 해결 후 실패 원인 설명하기
primary_metrics:
  - 합리적 가설 형성률
  - 단서 기반 실패 원인 설명률
  - 계획 수정 횟수
  - 묶음당 계획 시간
guardrails:
  - 정확 행동 추정률이 지나치게 높아 정답화되지 않는가
  - 정보 미확인·색각 의존·텍스트 과밀이 없는가
success:
  - 대부분의 참가자가 공개 정보로 가설을 만들고 실패 원인을 단서와 연결한다
failure:
  - 신규 참가자 다수가 찍기라고 평가하거나 숙련자가 단일 정답만 반복한다
stop:
  - 단서가 실제 전투 규칙과 불일치하면 즉시 중단
```

행동 관찰과 자기보고를 분리한다. `재미있다`는 응답만으로 통과시키지 않는다.

## 8. 적대적 검토

| Finding | 공격 | 판정 | 대응 |
|---|---|---|---|
| ADV-TP-01 | Into the Breach의 표면 UI를 복제한다. | REJECT | 원리만 참고하고 십보강호의 3/3/4 가설 구조로 변형한다. |
| ADV-TP-02 | 단서가 많을수록 깊다는 착각. | MUST_FIX | 묶음당 신규 단서 종류를 제한하고 항상 공개 정보와 분리한다. |
| ADV-TP-03 | 예상 표시가 별도 미니게임이 된다. | MUST_FIX | 보상·벌점 없는 메모로만 시험한다. |
| ADV-TP-04 | 해결 설명이 정답 강의가 된다. | SHOULD_FIX | 대안 계획의 장단점까지 보여 단일 해법화를 피한다. |
| ADV-TP-05 | 문서 통과를 재미 검증으로 주장한다. | MUST_FIX | 사람 테스트 전 `VALIDATED` 금지. |

## 9. 현재 결정에 미치는 영향

- v6 코어·전투 수치·AI 계약: `NO_CHANGE`.
- 후속 UI·전투 가독성 설계 입력: `PILOT_RECOMMENDATION`.
- 구현 인계: `NOT_AUTHORIZED`.
- 사람 검증 뒤 가능한 판정: `ADOPT / ADAPT / REWORK / REJECT`.

## 10. 원출처

- https://www.gdcvault.com/play/1013427/Designing-to-Promote-Intentional
- https://www.gdcvault.com/play/1025772/-Into-the-Breach-Design
- https://www.gdcvault.com/play/1025731/-Slay-the-Spire-Metrics

게시일·영상 접근 범위·세부 발언은 실제 적용 직전에 다시 확인한다.

## 11. 실행 보고

```yaml
selected_skills:
  - managing-project-intake-and-work-contract
  - analyzing-and-refining-game-concepts
  - governing-game-user-research-coverage
  - running-adversarial-review-and-refinement
work_modes_used: PLAN -> REVIEW
product_paths_changed: false
runtime_validation: NOT_APPLICABLE
human_validation: NOT_RUN
rollback: remove this planning-input document and its Documentation Map link
```