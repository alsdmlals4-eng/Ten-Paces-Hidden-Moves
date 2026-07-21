# 십보강호 협업 규칙

이 파일은 `Ten-Paces-Hidden-Moves`의 최상위 작업 계약이다. Base의 공용 절차는 재작성하지 않고 프로젝트 고유 규칙·경로·검증 차이만 둔다.

## 1. 우선순위

1. 사용자의 최신 확정 지시
2. 보안·플랫폼 제약과 이 `AGENTS.md`
3. `ACTIVE_CONTEXT.md`와 승인 작업 계약
4. Design Registry에 등록된 책임 원본
5. 실제 코드·데이터·자산·테스트·런타임 증거
6. `docs/BASE_RULES_VERSION.md`의 Base 기준과 프로젝트 차이
7. 외부 사례·과거 대화·추정

정상 동작 중인 사용자 변경을 임의로 되돌리지 않는다.

## 2. 기본 읽기

```text
최신 사용자 지시
→ AGENTS.md
→ [기획서]/00_프로젝트_허브/ACTIVE_CONTEXT.md
→ [기획서]/00_프로젝트_허브/DOCUMENTATION_MAP.md
→ 현재 책임 원본
→ 실제 파일·테스트·PR
```

Gates·Roadmap·Registry·Audit·Handoff는 Documentation Map이 지시할 때만 읽는다. `docs/[백업]`, `docs/[보류]`, 제거 후보, 전체 `skills/`, 과거 생성물을 기본 컨텍스트로 로드하지 않는다.

## 3. Base와 Skill 라우팅

- Base: `alsdmlals4-eng/Base@ee265576da7f67d3278f8099dd97d4e714ef0651`
- 적용 기록: `docs/BASE_RULES_VERSION.md`
- Skill Registry: `[기획서]/00_프로젝트_허브/SKILL_REGISTRY.json`
- 전수 감사: `[기획서]/00_프로젝트_허브/BASE_MAIN_SYNC_AUDIT.md`
- 최종 검증: `[기획서]/00_프로젝트_허브/BASE_MAIN_SYNC_VERIFICATION.md`

### Work Mode

- `PLAN`: 요구·정본·근거·실행 순서. 승인 전 제품 변경 금지.
- `BUILD`: 승인된 범위의 코드·데이터·문서·자산 구현.
- `REVIEW`: 적대적 검토·반례·증거·판정. 수정 시 BUILD 후 다시 REVIEW.

한 시점의 주 Work Mode는 하나다.

### 자동 선택

`managing-project-intake-and-work-contract`가 요청을 한 번 라우팅한다.

```text
의도·현재 단계·위험
→ Work Mode
→ Registry trigger·do_not_use_when
→ 최소 Skill·Skill Mode
→ 저장소 사실 조사
→ 필요한 사용자 확인
→ contract
→ 필요 시 decompose-and-sequence
→ 실행·검증
→ execution-report
```

- 사용자는 Skill 이름을 선언할 필요가 없다.
- `load_by_default=false`는 trigger가 없을 때 읽지 않는다는 뜻이다.
- 주 책임 분야 Skill은 최대 하나다.
- 전체 Skill 자동 로드, trigger 없는 호출, 사용하지 않은 Skill 보고를 금지한다.

### Skill 구조

Base 공유 Skill 13개는 요청 접수·운영체계·문서·상태·컨셉·검증·정본 최신성·아트·Base 제안을 책임진다.

로컬 Skill은 프로젝트 고유 판단만 둔다.

- `ten-paces-game-design`
- `combat-ux-and-accessibility`
- `combat-implementation-handoff`
- `ten-paces-verification`

통합 전 ID는 `skills/LEGACY_SKILL_ALIASES.md`에서만 허용한다.

## 4. L1 이상 작업 계약

```yaml
work_level: L1 | L2 | L3 | L4
work_mode: PLAN | BUILD | REVIEW
primary_discipline:
affected_disciplines:
goal:
user_or_player_value:
scope:
out_of_scope:
protected_paths_decisions_assets:
required_sources_tools_permissions:
selected_skills_and_modes:
execution_steps:
acceptance_criteria:
validation:
stop_conditions:
rollback:
```

L2 이상 또는 다중 의존성 작업은 활동명이 아니라 `outcome / inputs / files / dependencies / output / acceptance / validation / rollback`으로 분해한다. 같은 파일·Schema·자산 경계를 경쟁적으로 수정하지 않는다.

## 5. 제품 고정 계약

- 플레이어 정체성: `[강호낭인]`
- 전장: 정확히 10칸
- 시작 위치: 플레이어 3번, 상대 8번
- 캐릭터 발 중심을 타일 앵커에 정렬
- 라운드: `3수 → 3수 → 4수`, 총 10수
- 10수 뒤 다음 라운드
- 판정: `대응 → 속공 → 이동 → 일반 공격`
- 같은 단계 공격은 동시 피해
- 기초 행동 8종: 이동·보법·막기·회피·속공·강공·명상·태세
- 절초 기세 최대 5칸
- 비용: 행동 슬롯·기력·내력
- 덱·손패·행동력·공통 `막기 경감` 없음
- AI는 플레이어 비공개 행동을 읽지 않음
- UI·VFX·오디오는 판정·보상·저장을 재계산하지 않음
- `docs/[보류]` 기능은 재개 승인 전 구현 금지

상세 규칙은 `docs/02_COMBAT_RULES.md`와 실제 `data/`, `src/`, `scenes/`, `tests/`를 함께 확인한다.

## 6. 책임 원본·발행

- 한 질문에 Design Registry가 등록한 책임 원본 하나만 둔다.
- 서술 기획은 Markdown, Registry·상태·ID·경로·게임 데이터는 JSON.
- `v2`, `final`, `latest`, `copy` 활성 복제본을 만들지 않는다.
- PDF·DOCX·다이어그램은 파생본이며 독립 원본이 아니다.

현재 저장소에는 발행 생성기가 없으므로 기획 문서와 Skill Registry는 `source_only`다. PDF가 필요한 마일스톤에서 생성기·폰트·렌더·Manifest 검증을 함께 설치하고 필요한 문서만 `milestone_sync`로 전환한다. 실행 불가능한 `always_sync`를 선언하지 않는다.

## 7. 기존 구조·가지치기

```text
PLAN: audit
→ reconcile-legacy
→ 보존·롤백·승계 확인
→ 사용자 승인
→ BUILD: 승인된 UPDATE·MERGE·STUB·ARCHIVE·DELETE
→ REVIEW: reference-freshness·회귀·복구 검증
```

판정:

`CURRENT / UPDATE_IN_PLACE / MERGE_TO_CANONICAL / COMPATIBILITY_STUB / ARCHIVE_HISTORY / DELETE_APPROVED / KEEP_UNRESOLVED`

삭제·통합 전에 고유 정보, 활성 참조, 파생본, 복구 경로, 사용자 승인을 확인한다. 기능이 Base 공유 Skill에 완전히 승계된 로컬 복제만 제거한다.

## 8. 정본 최신성·변경 검증

정본·경로·ID·Schema·정책·생성기·Skill 변경 시 `auditing-canonical-reference-freshness`를 실행한다. 변경한 파일뿐 아니라 변경됐어야 할 untouched 소비자·테스트·Workflow·파생본을 확인한다.

일반 검증 순서:

```text
contract-check
→ reference-freshness
→ syntax·static
→ automated tests
→ runtime·render·build
→ 적용 시 accessibility-review
→ 적용 시 performance-profile
→ normal·failure·edge·regression
→ evidence-report
```

- 파일 존재와 실행 성공을 구분한다.
- Workflow 존재, Actions 성공, Required Check 강제를 구분한다.
- 접근성은 실제 정보·입력·탐색·시간·난이도·모션 장벽과 대체 경로로 검수한다.
- 성능은 목표 플랫폼·동일 빌드·대표/최악 장면의 frame time·CPU·GPU·메모리·로딩을 baseline과 비교한다.
- 실행하지 않은 검증은 `NOT_RUN` 또는 `UNVERIFIED`다.

## 9. 작업 종료

1. 책임 원본과 실제 파일을 맞춘다.
2. Registry·Legacy Alias·Update Matrix 영향을 확인한다.
3. Active Context·Roadmap을 갱신한다.
4. Handoff는 세션·브랜치·마일스톤 경계에서만 갱신한다.
5. Changelog·Decision Log·Learning Log에 필요한 기록을 남긴다.
6. Governance·정본 최신성·Skill 무결성·관련 런타임을 검증한다.
7. 다음 작업·선행 조건·중단 기준·롤백을 남긴다.

L1 이상 최종 보고:

```yaml
work_mode:
skill_id:
skill_mode:
selection: automatic | user-directed
reason:
work_performed:
result:
evidence:
status: PASS | PARTIAL | FAIL | UNVERIFIED
```

실행하지 않은 Skill·조사·테스트·렌더·접근성·성능·브랜치 보호를 완료로 보고하지 않는다.
