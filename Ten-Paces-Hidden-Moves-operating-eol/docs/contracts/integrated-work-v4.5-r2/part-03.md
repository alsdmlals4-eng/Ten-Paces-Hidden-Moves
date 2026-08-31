## 12. 승인·병합 권한

### 12.0 현재 대화의 병합 승인 계약

이 작업지시문을 작성한 **현재 대화에서 사용자가 이미 승인한 범위**는 권장안대로 자동 병합 승인된 것으로 취급한다.

```yaml
current_conversation_merge_approval:
  scope: ALREADY_USER_APPROVED_ITEMS_IN_THIS_CONVERSATION
  merge_reapproval: NOT_REQUIRED
  recommended_low_risk_pr_merge: AUTO_APPROVED_AFTER_ALL_GATES
  planning_conflict_auto_approval: FORBIDDEN
  scope_expansion_auto_approval: FORBIDDEN
```

이 권한은 다른 대화·미래 프로젝트에 영구 승계되지 않는다.
새 기획 충돌은 반드시 Grill Me로 승인받는다.

자동 병합에서 제외:

- proposal-only
- reference-only
- `DO_NOT_MERGE`
- 실험/PoC 보존 PR
- 필수 검증 미완료
- stale base / strict-up-to-date 미충족
- unresolved review thread
- 승인 범위 밖 diff
- P0/P1 적대적 finding 미해결
- 사용자 행동이 필요한 미검증 위험

### 12.1 같은 승인 범위

사용자의 명시 승인이 무엇을 가리키는지 명확하면:

```text
APPROVAL
→ BUILD
→ VERIFY
→ PR
→ exact current validation target
→ ci-gate
→ adversarial review
→ merge
→ readback
```

다시 묻지 않는다.

금지:

```text
같은 범위인데 “정말 진행할까요?”
같은 범위인데 “PR 올릴까요?”
같은 범위인데 “병합할까요?”
HEAD가 바뀌었다는 이유만으로 기획 승인 재요청
```

### 12.2 HEAD/base가 변경된 경우

사용자 승인은 유지될 수 있지만 기술 검증은 다시 만든다.

```yaml
validation_identity:
  review_head_sha:
  base_sha:
  merge_base_sha:
  test_merge_sha:
  merge_group_sha:
  ci_validation_target_sha:
```

현재 저장소가 실제로 요구하는 SHA를 검증한다.

---

## 13. BCP-020 PLAYER_EXPERIENCE_EVIDENCE_GATE

Base current의 플레이어 경험 계약을 프로젝트에 적용한다.

네 증거를 하나의 `validation passed`로 뭉뚱그리지 않는다.

| 증거 | 증명 | 증명하지 않음 |
|---|---|---|
| `TECH_EVIDENCE` | 코드·데이터·Schema·엔진 실행의 기술 상태 | 사람이 이해/재미/기억을 얻는지 |
| `UI_EVIDENCE` | 렌더·입력·포커스·해상도·시각 상태 | 처음 보는 사용자가 다음 행동을 찾는지 |
| `HUMAN_USABILITY_EVIDENCE` | 사람이 조작·정보 구조·다음 행동을 이해하는지 | 의도한 감정·고민·기억이 생기는지 |
| `PLAYER_EXPERIENCE_EVIDENCE` | 의도한 고민·감정·선택·보상·기억이 실제 플레이에 생기는지 | 장기 유지율·판매 성과 |

사람 관찰을 실행하지 않았으면:

```yaml
HUMAN_USABILITY_EVIDENCE: NOT_RUN
PLAYER_EXPERIENCE_EVIDENCE: NOT_RUN
```

자동 테스트·렌더 캡처·텍스트 검사로 위 두 상태를 `PASS`로 올리지 않는다.

사람 검증을 했다면:

```yaml
human_test:
  participant_context:
  prior_exposure:
  task:
  questions:
  observed_actions:
  answers:
  failure_points:
  sample_limitations:
```

---

## 14. FIRST SESSION / FIRST 10 MINUTES CONTRACT

`FIRST_10_MINUTES`는 고정 시간 제한이 아니라 **대표 경험의 압축판 기본값**이다.

장르·세션 길이에 따라 시간 창은 조정할 수 있지만 다음 흐름은 관찰 가능해야 한다.

```text
대표 문제
→ 대표 행동
→ 첫 의미 있는 선택
→ 첫 관찰 가능한 결과
→ 다음 질문
```

```yaml
first_session_contract:
  representative_problem:
  representative_action:
  first_meaningful_choice:
  first_observable_result:
  next_question_created:
  time_window: FIRST_10_MINUTES_DEFAULT | PROJECT_ADAPTED
```

공포·미스터리처럼 정보를 숨기는 것은 허용한다.
그러나 **지금 무엇을 시도할 수 있는지**까지 숨기지 않는다.

---

## 15. DECISION SCREEN COMPREHENSION GATE

핵심 의사결정 화면은 다음 네 질문을 답할 수 있어야 한다.

```text
현재 상황은 무엇인가
무엇을 선택할 수 있는가
선택에 필요한 정보는 무엇인가
선택하면 어떤 비용·위험·결과가 예상되는가
```

검증:

```yaml
decision_screen:
  current_situation_readable:
  available_choices_readable:
  needed_information_readable:
  cost_risk_result_readable:
  intentionally_hidden_information:
  hidden_information_does_not_hide_action_purpose:
```

장식·애니메이션 품질은 이 Gate를 대신하지 않는다.

---

## 16. MINIGAME_NARRATIVE_FUNCTION_GATE

**프로젝트 코어가 아닌 별도 미니게임 후보**에만 적용한다.

```yaml
minigame_narrative_function:
  main_game_information_used:
  player_decision_tested:
  narrative_or_system_result_changed:
  failure_learning:
  rule_learning_time:
  reusability:
  content_cost:
  flow_interrupt_cost:
```

통과 방향:

- 본편 정보·규칙이 실제 판단에 쓰인다.
- 성공/실패가 사건·자원·기록·다음 선택을 바꾼다.
- 실패가 다음 시도 학습을 남긴다.
- 공통 프레임/데이터 변형으로 재사용 가능성을 검토한다.
- 더 짧은 선택지/공통 상호작용이 같은 경험을 낼 수 있는지 비교한다.

**주의**

퍼즐·전투·제작 자체가 프로젝트 코어면 이를 미니게임으로 낮춰 평가하지 않는다.

```text
CORE PUZZLE / CORE COMBAT / CORE CRAFTING
→ CORE_INTERACTION_EVIDENCE
→ project core contract
```

---

## 17. Visual Requirement Gate

이미지를 만들기 전에 다음 순서로 판단한다.

```text
필요성
→ Delete Test
→ 기존 승인 자산 재사용 가능성
→ UI/게임플레이/서사에서의 역할
→ 중요도 P0~P3
→ 제작 방식
→ 승인
→ 프로젝트 Asset Vault promote
```

이미지가 없어도 경험·정보 구조가 유지되면 장식 자산일 수 있다.

`DRAFT`, `placeholder`, 임시 생성 이미지를 최종 승인 자산처럼 사용하지 않는다.

---

## 18. Asset Vault·Reference Library·Audio Vault

### 프로젝트 Asset Vault

```text
candidate
→ provenance
→ rights/license
→ technical validation
→ user/project approval
→ PROJECT_ASSET_APPROVED
→ tracked promotion
→ Godot res:// consumption
```

`res://assets/_vault_local/`은 local-only 후보 공간이다.
tracked Scene/Resource가 local-only 후보에 영구 의존하지 않는다.

### Local Godot Reference

```text
REFERENCE_ONLY
```

참고 자료의 발견은 active adoption이 아니다.

검증:

- upstream
- version/commit
- license
- Godot compatibility
- 실제 소비 경로
- 제거/rollback

### Shared Audio Vault

원본 Vault는 읽기 전용 source library로 취급한다.

```text
shared vault
→ rights/hash review
→ approved copy
→ project res://
→ import/loop/volume validation
```

production runtime에서 외부 절대 경로를 참조하지 않는다.

---

## 19. UI 컴포넌트 Gate

UI 변경은 최소 다음을 정의한다.

```yaml
component:
  purpose:
  states:
    - default
    - hover_or_focus
    - pressed
    - disabled
    - loading_when_applicable
    - error_when_applicable
  input:
    keyboard_mouse:
    gamepad:
    touch:
    android_back:
  focus_behavior:
  accessibility:
  responsive_behavior:
  motion:
  audio_haptic_feedback:
```

체크:

- 정보 우선순위
- 다음 행동 발견 가능성
- 입력 장벽
- 해상도/비율
- 한글/CJK
- reduced motion
- 오류/빈 상태/복구
- focus
- touch target

---

## 20. HiGodot·GUT·Hera 책임 분리

이 섹션은 v4.4의 프로젝트 고유 채택 정책을 보존한다.
실제 프로젝트 adoption record가 다르면 프로젝트 정본이 우선한다.

### HiGodot

```text
SOLO PERSISTENT GODOT AUTHORING AUTHORITY
```

채택된 경우 persistent Godot 변경:

- Scene
- Node
- Script
- Resource
- Theme
- Animation
- Signal
- Project settings
- Input Map
- Autoload

를 다른 도구가 우회 저작하지 않는다.

### GUT

Godot 4.7.x에서 formal adoption이 있을 때:

```text
GUT 9.7.1 / godot_4_7
→ deterministic GDScript test authority
```

GUT은 production authoring 권위가 아니다.

### Hera

```text
LIVE_QA_AND_OBSERVABILITY_ONLY
```

- persistent source mutation 금지
- acceptance 후 tracked source delta = NONE
- exact CLI/addon pair 검증
- localhost transport 정책 확인

---

## 21. Godot 버전·실행

버전을 추측하지 않는다.

확인:

```text
project.godot
Godot binary
CI
export presets
project docs
plugin compatibility
```

v4.5 작성 시 외부 기준:

```yaml
godot:
  target_family_from_project_contract: 4.7.x
  observed_stable_reference: 4.7.1-stable
  observed_release_date: 2026-07-14
  current_4_8_archive_state_when_v4_5_written: dev
```

업그레이드 전 백업/Git 복구 경로를 유지한다.

---

## 22. Windows·Android Shared Core

게임 로직과 데이터를 플랫폼별로 복제하지 않는다.

```text
SINGLE GAME LOGIC / DATA CORE
├─ Windows adapter
│  ├─ keyboard/mouse
│  ├─ gamepad
│  └─ desktop delivery
└─ Android adapter
   ├─ touch
   ├─ android back
   ├─ lifecycle
   └─ mobile delivery
```

분리할 것:

- input
- UI layout/responsive
- platform integration
- export/delivery
- performance profile

공유할 것:

- 게임 규칙
- 상태 모델
- 핵심 데이터
- 세이브 의미
- 보상/경제의 기본 의미

---

## 23. Build Size·체감 품질

각각 따로 측정한다.

```yaml
size:
  download:
  installed:
  runtime_memory:
  patch_delta:
```

최적화는 다음을 보호한다.

- 핵심 화면 품질
- 오디오 식별성
- 텍스트 가독성
- CJK/emoji/fallback
- startup latency
- 모바일 발열
- patch size

금지:

```text
모든 texture 동일 해상도
모든 audio 동일 압축
font 파일 하나로 강제
설치 크기만 줄이고 first-session download/runtime 악화
```

---

## 24. 구현 준비 Gate

BUILD 전에:

```yaml
implementation_ready:
  approved_scope:
  approval_reference:
  protected_items:
  exact_baseline_sha:
  existing_solution_disposition:
  acceptance_criteria:
  rollback:
  affected_consumers:
  test_plan:
  applicable_human_or_player_evidence:
  godot_authoring_route:
```

불완전하면 BUILD로 넘어가지 않는다.

---
