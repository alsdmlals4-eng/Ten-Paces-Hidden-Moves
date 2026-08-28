# TEN-DEC-20260829-OPPONENT-RUNTIME-PERSONALITY-BINDING-01

```yaml
decision_id: TEN-DEC-20260829-OPPONENT-RUNTIME-PERSONALITY-BINDING-01
status: USER_APPROVED_ARCHITECTURE_CONTRACT_REVIEW_REQUIRED
decision_date: 2026-08-29
approval_source: "user explicit: 좋아 권장안대로 진행하자"
implementation_issue: 267
scope: FIRST_FIVE_DUEL_OPPONENT_RUNTIME_PERSONALITY_AND_STAT_BINDING
canonical_rule_owners:
  - docs/02_COMBAT_RULES.md
  - docs/09_COMBAT_SYSTEM_ARCHITECTURE.md
  - docs/13_VERTICAL_SLICE_OPPONENT_ROUTE_TEXT_UX.md
  - data/run/vertical_slice_opponents.json
design_spec: docs/superpowers/specs/2026-08-29-opponent-runtime-personality-binding-design.md
runtime_mutation: NONE_IN_THIS_DECISION
automated_evidence: NOT_RUN
godot_runtime_evidence: NOT_RUN
windows_visible_evidence: NOT_RUN
human_player_evidence: NOT_RUN_DEFERRED_BY_USER_FOR_CURRENT_STAGE
```

## 결정

첫 5전의 15명 후보는 설명문만 다른 적이 아니다. 각 후보는 전투 진입 전에 하나의 재사용 가능한 런타임 성향 원형, 정렬된 기초 행동 선호, `final_stat_total_seed`에 맞는 결정론적 오능력치 분배를 받아야 한다.

이 binding은 후보가 잠긴 뒤부터 그 결투가 끝날 때까지 해당 전투 엔진 인스턴스에만 존재한다. 일반 Combat Preview의 기존 기본 라이벌 프로필은 유지하며, 후보가 전역 AI 설정을 바꾸거나 다음 결투로 누출되지 않는다.

상세 자료 구조, 다섯 원형, 후보 매핑, 공개 이력의 범위, 테스트 기준은 [설계 명세](../superpowers/specs/2026-08-29-opponent-runtime-personality-binding-design.md)가 소유한다. 이 Decision은 A안의 제품 방향을 승인하지만, 명세의 정확한 수치·파일 경계는 사용자 검토와 단일 구현계약 전까지 runtime truth가 아니다.

## 플레이어 약속

```text
Briefing의 습관 단서
→ 플레이어가 3/3/4의 이번 행동 묶음을 가설로 배치
→ 행동계획 실행
→ 잠긴 적의 실제 성향·행동 선호·능력치가 공개 전투 상태에서 작동
→ 합/거리/방어/중단/후속 행동의 실제 결과를 Review에서 복기
→ 다음 결투 또는 같은-seed 재도전에서 가설을 갱신
```

목표는 “소문을 믿고 정답을 외운다”가 아니라 “공개된 경향과 이미 해결된 이력을 근거로 내 세 슬롯의 위험을 조절한다”이다.

## 비교한 대안

| Alternative | Disposition | Player value | Cost / risk |
| --- | --- | --- | --- |
| A. 데이터 소유 재사용 원형 5개 + 후보 binding | `ADOPT` | Briefing의 차이가 실제 결투에서 관찰 가능해지고, 같은 원형을 다른 후보가 변주한다. | 중간. profile/state/test 경계가 필요하지만 수치 조정은 데이터 중심으로 되돌릴 수 있다. |
| B. 후보별 전용 GDScript 전투 로직 | `REJECT` | 한 명씩 강한 연출을 만들 수 있다. | 15개 규칙 분기, 회귀·밸런스·유지비가 급증하고 공유 resolver를 훼손한다. |
| C. 기존 텍스트 Briefing만 유지 | `REJECT` | 비용은 없다. | 후보의 습관·기본 행동·총 스탯이 런타임에 반영되지 않아 Player Promise와 실제 플레이가 분리된다. |

## 보호·제외

- `3수 = 3슬롯`, `3 → 해결 → 3 → 해결 → 4 → 해결`, 2슬롯 `[전조] → [실행]`, 그리고 **`행동계획 실행`** 뒤의 해결 애니메이션을 바꾸지 않는다.
- AI는 자신의 원형 설정과 이미 해결되어 공개된 전투 상태만 읽는다. 플레이어의 미확정 계획, 숨은 배치, pointer/hover/focus, UI 의도, 관찰 전용 답안 데이터는 절대 입력하지 않는다.
- 하나의 공유 resolver, player/AI shared martial-card pool, 현재 공개 시작 거리 `2`, 한 번의 동일-seed 재도전 경계를 유지한다.
- 이 Decision만으로 `data/`, `src/`, `scenes/`, `assets/`, `addons/`, `project.godot`의 제품 구현을 승인하지 않는다.
- 신규 무공, 적 전용 기술, 신규 자원, 경제/저장, Route 노드, 이미지/오디오/Visual 생산, Android 재설계, 사람 플레이 통과 주장을 추가하지 않는다.

## 구현 전 수용 기준

1. 후보 15명 모두가 유효한 원형 ID 하나와 유효한 기존 기초 행동 ID들을 갖고, 능력치 다섯 값의 합은 정확히 `final_stat_total_seed`다.
2. 원형은 후보별 전용 코드가 아니라 JSON 데이터와 공용 `CombatAiPlanner` scoring/bundle 경계로 구현된다.
3. 다음 묶음을 잠글 때 AI는 이전에 해결되어 공개된 행동 이력만 사용할 수 있으며, 같은 candidate/public state/seed는 같은 행동과 trace를 낸다.
4. range-control은 접근·후퇴 모두를 공용 이동 target 계약으로 표현하고, sequence-pressure는 현재 묶음 안에서 겹치지 않는 공용 action-slot 예약으로 표현한다.
5. 일반 Combat Preview의 전역 기본 profile, combat resolver, UI 계산 경계, retry/route 흐름은 후보 binding이 없을 때 기존 동작을 유지한다.
6. 자동 정적/Godot 검증과 Windows visible/Human/접근성/Android 증거는 서로 대체하지 않는다. 현 단계의 Human evidence는 `NOT_RUN`이다.

## 적대적 검토 기록

- **가짜 개성:** 이름만 후보별이고 행동은 하나의 global profile이면 실패다. `runtime_archetype_id`, focus, stat allocation을 bridge snapshot과 planner trace에서 테스트한다.
- **AI 치팅:** public-history 기능이 현재 결투의 플레이어 계획을 포함하면 실패다. 이력은 해결 완료 뒤 resolver가 append한 기록만 허용한다.
- **거리 원형 무효화:** 기존 AI 이동이 항상 접근 방향이면 거리 유지/후퇴 후보는 거짓이다. 공용 movement policy가 target direction을 결정해야 한다.
- **연계 원형 무효화:** 기존 planner가 action 하나만 반환하면 Slot 5의 순차 습관을 보장할 수 없다. 슬롯 예산을 소비하는 공용 bundle builder가 필요하다.
- **가짜 밸런스 검증:** binding 전 또는 human play 없이 승률/재미 PASS를 주장하지 않는다. binding 후의 별도 계측 계약이 필요하다.

## 다음 경계

Issue #267의 구현 계약은 이 Decision의 상세 명세를 사용자 검토 후에만 작성한다. 구현 완료 뒤에도 후보별 밸런스·난이도·재미는 자동 결정성 증거와 사람 플레이 증거를 분리해 다룬다.
