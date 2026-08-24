# 십보강호 · AI Indie Pattern Adoption — 2026-08-24

```yaml
status: USER_DIRECTED_ADAPTATION
work_mode: PLAN_REVIEW
runtime_mutation: SHARED_MARTIAL_POOL_METADATA_ONLY
source_base_merge: dff09d83c3892a70ba5fee86a59d36086889a6c5
core: hidden simultaneous planning + 3/3/4 resolve + public-information inference
runtime_ai: BOUNDED_EXISTING_AI_ONLY
martial_content_policy: PLAYER_LEARNABLE_SHARED_WITH_AI
human_validation: NOT_RUN
```

## 결론

십보강호의 핵심은 확률 보정이 아니라 **상대가 무엇을 계획했는지 모르는 상태에서 공개 정보와 과거 해결 이력으로 추론하는 것**이다. 따라서 `RNG_AGENCY_AND_RECOVERY`를 새 시스템으로 적용하지 않는다.

AI 관련 핵심 적용은 production workflow, **상대 AI 정보 방화벽**, 그리고 **플레이어와 AI의 공용 무공 풀**이다.

## 판정

| Pattern | 판정 | 적용 |
|---|---|---|
| HUMAN_DIRECTED_AI_BUILD_LOOP | ADOPT | 규칙/AI/UI 구현은 사람 기준 + RED/GREEN + replay review |
| SILENT_OMISSION_GATE | ADOPT_HIGH | hidden-plan/privacy/public-info/replay consumer 누락 검사 |
| CONTEXT_SCOPE_AND_ARCHITECTURE_BUDGET | ADOPT | CombatState/AI/UI/replay/save owner 분리 |
| BREADTH_AFTER_CORE_IDENTITY_LOCK | ADOPT | 대표 duel/app flow Human 검증 전 기술/상대 breadth 확대 금지 |
| PLAYER_FEEDBACK_REBUILD_LOOP | ADOPT_HIGH | “읽혔다/속았다/억울했다”를 정보 경계 기준으로 분석 |
| AI_VISIBLE_OUTPUT_QUALITY_GATE | ADOPT | 최종 무협 표현/정보 UI는 별도 quality/rights Gate |
| RNG_AGENCY_AND_RECOVERY | REJECT_CURRENT | hidden-plan 추론을 랜덤 최적화로 바꾸지 않음 |
| runtime generative AI | REJECT_CURRENT | 현재 opponent AI는 deterministic/public-info 경계를 우선 |

## AI_OPPONENT_INFORMATION_FIREWALL

어떤 AI 구현을 사용하더라도 상대는 플레이어의 미확정 계획을 읽을 수 없다.

```text
AI input allowed
= 공개 위치/거리
+ 공개 자원/상태
+ 이미 해결된 과거 행동/결과
+ 합법적으로 관측된 정보

AI input forbidden
= 현재 미확정 3/3/4 계획
+ 아직 공개되지 않은 기술 배치
+ UI hover/focus 같은 숨은 의도 신호
+ 플레이어 입력 버퍼/내부 객체 직접 열람
```

모델을 더 강하게 만드는 것보다 이 경계가 우선한다.

## SHARED_MARTIAL_POOL

상대 AI는 AI 전용 무공서나 AI 전용 기술을 받지 않는다.

```text
opponent martial techniques
= 플레이어도 습득 가능한 문파 무공서
+ 동일 무공서의 동일 card ID / effect_steps
+ 상대에게 설정된 합법적 숙련도에서 해금된 기술
```

- 현행 10권 무공서는 `PLAYER_LEARNABLE_SHARED_WITH_AI` 공용 풀이다.
- 플레이어가 같은 무공서를 습득하고 같은 성급·해금 조건을 만족하면 AI가 사용하는 같은 기술을 사용할 수 있어야 한다.
- `enemy_exclusive_manuals_allowed = false`.
- `enemy_exclusive_techniques_allowed = false`.
- 상대의 개성은 새 기술 생성이 아니라 **무공서 선택, 숙련도, 기초 행동 조합, `behavior_focus`, 공개된 과거 이력**에서 만든다.
- 현재 Vertical Slice 시작 선택지는 6권이다. 나머지 공용 무공서의 실제 플레이어 획득 경로가 모두 구현됐다는 뜻은 아니며, 해당 획득 콘텐츠는 별도 정본·구현 Gate를 따른다.
- 플레이어 전용 시스템 효과(예: `[관찰]` 획득)를 적에게 억지로 이식하는 식의 AI 전용 예외 규칙도 만들지 않는다.

공정성은 정보 대칭만이 아니라 **콘텐츠 자격의 대칭**도 포함한다. AI가 강해지는 방법은 플레이어에게 존재하지 않는 기술을 쓰는 것이 아니라, 같은 규칙 안에서 다른 무공 조합과 읽기 습관을 사용하는 것이다.

## Player Feedback Rebuild

Human duel feedback를 다음으로 분리한다.

```text
GOOD_READ
= 공개 정보에서 상대 의도를 추론해 맞춤

GOOD_DECEPTION
= 상대가 내 추론을 역이용했지만 규칙상 납득 가능

BAD_INFORMATION_LEAK
= AI가 알 수 없는 계획을 아는 것처럼 행동

BAD_CONTENT_ASYMMETRY
= 플레이어가 배울 수 없는 AI 전용 무공/기술/효과로 결과가 발생

BAD_OPACITY
= 결과는 규칙상 맞지만 왜 일어났는지 복기에서 이해 불가

CORE_MINDGAME_FAILURE
= 공개 정보가 실제 선택을 만들 만큼 충분하지 않음
```

`BAD_INFORMATION_LEAK`와 `BAD_CONTENT_ASYMMETRY`는 밸런스 문제가 아니라 즉시 correctness defect다.

## Explainable Replay와 Recovery

십보강호에서 실패 후 recovery는 보정 보너스가 아니라 **복기 가능성**이다.

```text
3/3/4 계획
→ 순차 해결
→ 어떤 공개 정보가 있었는지 기록
→ 어떤 기술/거리/방어/회피/중단이 작동했는지 표시
→ 다음 비무의 판단 수정
```

AI는 복기 설명을 도울 수 있어도 숨은 reasoning/canon을 새로 만들거나 실제 로그와 다른 원인을 지어내면 안 된다.

## Breadth Gate

대표 app flow와 duel에서 다음이 검증되기 전에는 상대/무공/절초를 대량 생성하지 않는다.

- 거리 N 표현 이해.
- 3/3/4 계획과 해결 차이 이해.
- `[전조] → [실행]` 연결 이해.
- 공개 정보 기반 읽기/속이기 경험 존재.
- 결과 복기로 패배 원인을 설명 가능.
- AI가 미확정 계획을 읽지 않는다는 테스트 evidence.
- AI가 player-learnable shared martial pool 밖의 기술을 사용하지 않는다는 테스트 evidence.

## 다음 Codex/QA 소비

1. opponent AI input surface를 machine-auditable allowlist로 검사.
2. 미확정 plan mutation/read 접근 회귀 테스트.
3. opponent `signature_manual_id`가 `player_learnable_manual_ids`에 속하는지 검사.
4. opponent card ID가 동일 `MartialManualRegistry.build_unlocked_cards(manual_id, mastery)`에서 해금되는지 검사.
5. replay packet에 public-information snapshot과 action provenance 보존.
6. Human duel에서 GOOD_READ/BAD_OPACITY/BAD_CONTENT_ASYMMETRY 구분 기록.
7. runtime generative AI는 별도 Player Value 증거 없이는 도입하지 않음.

## IRG

현재 주장 가능: AI-assisted workflow, opponent information firewall, player/AI shared martial pool이 프로젝트 코어에 맞게 정의됐고 현행 상대 기술 ID가 동일 무공서 registry의 합법적 해금 기술을 사용함.

현재 주장 불가: 나머지 비Starter 무공서의 플레이어 획득 경로 전체 구현, Human mindgame quality PASS, Android runtime PASS, generative AI opponent 구현.

## 적대적 검토 5회

1. RNG 기능 억지 추가 없음: PASS.
2. hidden-plan secrecy 보존: PASS.
3. AI 전용 무공서·기술·숨은 효과 추가 없음: PASS.
4. replay를 사실 기반으로 제한: PASS.
5. Human·획득 경로 evidence 과장 없음: PASS.

`CLEAN_REVIEW_EXIT`.
