# 십보강호 협업 규칙

이 파일은 `Ten-Paces-Hidden-Moves`의 최상위 프로젝트 작업 계약이다. Base 공용 절차는 복제하지 않고 프로젝트 고유 기준·경로·보호·검증 차이만 둔다.

## 1. 우선순위

1. 사용자의 최신 확정 지시.
2. 보안·플랫폼 제약과 이 `AGENTS.md`.
3. `[기획서]/00_프로젝트_허브/ACTIVE_CONTEXT.md`와 승인 작업 계약.
4. Design Registry가 등록한 질문별 책임 원본.
5. 실제 코드·데이터·씬·자산·테스트·런타임 증거.
6. `docs/BASE_RULES_VERSION.md`의 Base 기준과 프로젝트 차이.
7. 외부 사례·과거 대화·추정.

정상 동작 중인 사용자·Codex 변경을 임의로 되돌리지 않는다.

## 2. 기본 읽기

```text
최신 사용자 지시
→ AGENTS.md
→ [기획서]/00_프로젝트_허브/ACTIVE_CONTEXT.md
→ [기획서]/00_프로젝트_허브/DOCUMENTATION_MAP.md
→ 질문별 책임 원본
→ 실제 파일·테스트·PR·Issue
```

백업·보류·과거 Plan·닫힌 PR·전체 Skill 폴더를 기본 컨텍스트로 로드하지 않는다.

## 3. 현재 기준

- Base: `alsdmlals4-eng/Base@41a20584dd2ee51d917e5c9d7cab6838e1ceba7e`.
- Base 차이: `docs/BASE_RULES_VERSION.md`.
- Skill Registry: `[기획서]/00_프로젝트_허브/SKILL_REGISTRY.json`.
- 현재 구현 기준: PR #7 `agent/t0-combat-poc-board`.
- 기준 SHA: `147a031c75e96bff170d7f99016beb9e85b12066`.
- 최신 승인 범위: Issue #13 STEP 12~14.
- 전투 규칙: `docs/02_COMBAT_RULES.md`.
- 현재 범위: `docs/05_COMBAT_POC_SPEC.md`.
- 현재 증거: `docs/08_TEST_CHECKLIST.md`.

STEP 14의 기계 시나리오는 기록됐지만 실제 사용자 이해·보조기기·주관적 음향/모션 관찰은 `NOT_RUN`이다.

## 4. Work Mode·Skill Mode

- `PLAN`: 요구·정본·근거·대안·실행 순서. 승인 전 제품 변경 금지.
- `BUILD`: 승인된 범위의 코드·데이터·문서·자산 구현.
- `REVIEW`: 적대적 검토·반례·증거·판정. 수정이 필요하면 BUILD 후 다시 REVIEW.

한 시점의 주 Work Mode는 하나다.

Registry trigger가 최소 Skill·Skill Mode를 자동 선택한다.

```text
의도·현재 단계·위험
→ Work Mode
→ trigger·do_not_use_when
→ 최소 Skill·Skill Mode
→ 저장소 사실 조사
→ contract
→ 필요 시 decompose-and-sequence
→ 실행·검증
→ execution-report
```

- 사용자는 Skill 이름을 선언할 필요가 없다.
- `load_all_skills=false`를 유지한다.
- 주 책임 분야 Skill은 최대 하나다.
- 사용하지 않은 Skill을 실행 보고에 적지 않는다.

## 5. Skill 경계

Base 활성 Skill 25개는 공용 운영·기획·코어·검증·구조 최적화·연속성·유저리서치·디버깅을 책임진다.

프로젝트 고유 Skill은 4개다.

- `ten-paces-game-design`.
- `combat-ux-and-accessibility`.
- `combat-implementation-handoff`.
- `ten-paces-verification`.

현재 STEP 상태는 Skill 본문에 복제하지 않고 Active Context·본책·실제 파일에서 읽는다. 통합 전 ID는 `skills/LEGACY_SKILL_ALIASES.md`에서만 허용한다.

## 6. L1 이상 작업 계약

```yaml
work_level: L1 | L2 | L3 | L4
work_mode: PLAN | BUILD | REVIEW
primary_discipline:
affected_disciplines:
goal:
user_or_player_value:
scope:
out_of_scope:
baseline_branch:
baseline_sha:
protected_paths_decisions_assets:
required_sources_tools_permissions:
selected_skills_and_modes:
execution_steps:
acceptance_criteria:
validation:
stop_conditions:
rollback:
```

L2 이상은 `outcome / inputs / files / dependencies / output / acceptance / validation / rollback`으로 분해한다.

## 7. 현재 제품 계약

세부 규칙은 `docs/02_COMBAT_RULES.md`를 따른다.

- `[강호낭인]`.
- 10칸·플레이어 4번·상대 7번·거리 3.
- 같은 칸 최대 2인, 거리 0 `[밀착]`.
- 라운드 `3수 → 3수 → 4수`.
- 기초 행동 8종·절초 3종.
- 같은 실행 수 공격의 `[합]`.
- 방어도 차감 뒤 같은 수 반감, 회피, 파공검기 `[필중]`.
- 같은 수 미실행 행동 중단과 태세 기반 `[강건]`.
- 공개 상태 기반 결정적 최소 AI.
- 승패·무승부·4/7 완전 재시작.
- UI·VFX·오디오는 판정·보상·저장을 재계산하지 않는다.
- 덱·손패·행동력·내공·`[집중]` 없음.

프로젝트 코어는 `CORE_REVIEW_PENDING`이며 정합화 뒤 PLAN 모드와 사용자 승인으로 확정한다.

## 8. 기준 SHA와 Codex 작업 보존

구조·문서 정합화는 exact PR #7 기준 SHA에서 새 브랜치를 만든다.

- force push·reset·rebase로 기준 브랜치를 덮어쓰지 않는다.
- `data/`, `src/`, `scenes/`, `assets/`, `addons/`, `project.godot`은 별도 승인 없는 구조 정리에서 수정하지 않는다.
- 작업 전후 `compare`로 changed 파일을 확인한다.
- 제품 경로 변경이 발견되면 즉시 중단하고 원인·복구를 보고한다.
- 사용자 로컬 미커밋 상태는 원격과 동일하다고 가정하지 않는다.

## 9. 책임 원본·발행

- 한 질문에 책임 원본 하나.
- 활성 본문에는 현재 계약만 둔다.
- 날짜별 최신화 절을 누적하지 않는다.
- 과거 전문은 Git 이력·Change Log·Learning Log에서 찾는다.
- Markdown은 서술, JSON은 Registry·상태·ID·경로·게임 데이터에 사용한다.
- `v2`, `final`, `latest`, `copy` 활성 복제본을 만들지 않는다.
- 현재 제품 문서와 Skill Registry는 `source_only`다.
- 실행 가능한 생성기·폰트·Manifest·렌더·검수 없이 `CURRENT` PDF나 `always_sync`를 선언하지 않는다.

## 10. 기존 구조·삭제

```text
PLAN: audit
→ reconcile-legacy
→ 고유 정보·참조·복구·승계 확인
→ 사용자 승인
→ BUILD: UPDATE·MERGE·STUB·ARCHIVE·DELETE
→ REVIEW: reference-freshness·회귀·복구
```

삭제·통합 전에 고유 정보, 활성 참조, 파생본, 복구 경로, 사용자 승인을 확인한다.

## 11. reference-freshness·검증

정본·경로·ID·Schema·Base SHA·Skill 변경 시 `reference-freshness`를 실행한다. changed 파일뿐 아니라 변경됐어야 할 untouched 소비자를 확인한다.

```text
contract-check
→ reference-freshness
→ syntax·static
→ automated tests
→ runtime·render·build
→ 적용 시 accessibility-review
→ 적용 시 performance-profile
→ normal·failure·edge·counterexample·regression
→ baseline diff
→ evidence-report
```

파일 존재·Workflow 존재·Actions 성공·Godot 실행·Windows 확인·사람 플레이·Required Check 강제는 서로 다른 증거다.

## 12. 작업 종료

1. 책임 원본과 실제 파일을 맞춘다.
2. Registry·Schema·Legacy Alias·Update Matrix 영향을 확인한다.
3. Active Context·Roadmap·필요 시 Handoff를 갱신한다.
4. stale 표현과 untouched 소비자를 검사한다.
5. 기준 SHA 대비 보호 경로 보존을 확인한다.
6. Governance·관련 제품 계약·런타임을 검증한다.
7. 다음 작업·중단·롤백을 남긴다.

```yaml
work_mode:
skill_id:
skill_mode:
selection: automatic | user-directed
reason:
baseline_sha:
work_performed:
result:
evidence:
status: PASS | PARTIAL | FAIL | UNVERIFIED
```

실행하지 않은 조사·테스트·렌더·접근성·성능·플레이테스트·브랜치 보호를 완료로 보고하지 않는다.
