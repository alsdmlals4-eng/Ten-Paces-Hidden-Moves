# 십보강호 AI·GitHub 작업 흐름

## 1. 기본 흐름

```text
사용자 Prompt
→ 의도·현재 단계·위험
→ PLAN / BUILD / REVIEW Work Mode
→ managing-project-intake-and-work-contract
→ Registry trigger 기반 최소 Skill·Skill Mode
→ Definition of Ready
→ 필요 시 decompose-and-sequence
→ 사용자 확인·승인
→ 구현·제작
→ reviewing-and-validating-project-changes
→ 필요 시 reference-freshness·accessibility-review·performance-profile
→ 책임 원본·발행·Active Context 동기화
→ PR Checks·리뷰
→ execution-report·Learning Log
```

## 2. 공통 읽기 순서

```text
최신 사용자 지시
→ ../../../AGENTS.md
→ ../../../docs/BASE_RULES_VERSION.md
→ START_HERE.md
→ ACTIVE_CONTEXT.md·DOCUMENTATION_MAP.md·DEVELOPMENT_GATES.md
→ ROADMAP.md
→ ../DESIGN_DOCUMENT_REGISTRY.json·현재 책임 원본
→ SKILL_REGISTRY.json·필요한 Skill·Skill Mode
→ Issue·Goal·Plan·실행 순서
→ 실제 코드·데이터·자산·테스트
```

백업·보류·제거 후보와 전체 skills 폴더는 기본 읽기에서 제외한다.

## 3. Work Mode

- `PLAN`: 요구·정본·근거·순서. 승인 전 제품 변경 금지.
- `BUILD`: 승인 범위의 코드·데이터·문서·자산 변경.
- `REVIEW`: 적대적 검토·반례·검증. 수정이 승인되면 BUILD 후 다시 REVIEW.

한 시점의 주 Work Mode는 하나다.

## 4. 자동 Skill 라우팅

```text
route
→ 저장소 사실 조사
→ 필요한 경우 clarify
→ 사용자 마지막 확인
→ contract
→ 필요한 경우 decompose-and-sequence
→ 실행·검증
→ execution-report
```

- 전체 Skill 로드 금지
- 주 책임 분야 Skill 최대 하나
- trigger·do_not_use_when 확인
- 검증·발행·Handoff는 해당 단계에서만 실행
- 저장소에서 확인할 사실을 사용자에게 다시 묻지 않음
- 큰 작업은 결과·의존성·게이트·롤백으로 분해
- 정본·경로·ID·Schema 변경은 reference-freshness 보류 등록
- 구현된 Godot UI 감사는 `auditing-and-refining-ui-art`

## 5. 주요 Skill·Skill Mode

| 작업 | Skill·Skill Mode |
|---|---|
| 요청 접수·계약·보고 | `managing-project-intake-and-work-contract` |
| 기존 운영체계 | `managing-game-project-operating-system: audit/reconcile-legacy/migrate/verify` |
| 기획 책임 원본·발행 | `managing-design-documents` |
| 프로젝트 Skill 학습·통합 | `evolving-project-discipline-skills` |
| 현재 상태·Handoff | `maintaining-project-context-and-handoff` |
| 핵심 컨셉·DDD·PoC | `analyzing-and-refining-game-concepts` |
| 벤치마크·플레이어 증거 | 위 Skill `benchmark-and-player-research` |
| 플레이테스트·실험 | 위 Skill `playtest-and-experiment` |
| Vertical Slice | `designing-vertical-slices` |
| 외부 AI 격리 | `orchestrating-deepseek-worktrees` |
| 변경 검증 | `reviewing-and-validating-project-changes` |
| 정본 최신성 | `auditing-canonical-reference-freshness` |
| 이미지 프롬프트 | `designing-art-prompts-and-technique-cards` |
| 구현 UI 감사 | `auditing-and-refining-ui-art` |
| Base 제안 | `managing-base-change-proposals` |

프로젝트 고유 전투·UI·구현·QA Skill은 `SKILL_REGISTRY.json`의 진입점을 사용한다.

## 6. 실행 순서 계약

각 단계는 다음을 가진다.

```yaml
outcome:
inputs:
files:
dependencies:
output:
acceptance:
validation:
rollback:
```

관계는 `BLOCKS / INFORMS / USES_OUTPUT / SHARES_RESOURCE / VALIDATES / OPTIONAL_FOLLOWUP`으로 구분한다.

기본 순서:

```text
환경·권한
→ 정본·인터페이스·Schema
→ 가장 위험한 가설
→ 핵심 사용자·플레이어 경로
→ 통합
→ 정상·실패·경계·회귀
→ 문서·발행·참조 최신성
→ 사용자 검수·인수인계
```

## 7. 역할

### GPT·기획

- 사용자 의도·경험·범위·제약·완료·검증을 계약으로 정리
- 책임 원본·Roadmap·Context 갱신
- 구현되지 않은 기능을 완료로 쓰지 않음

### Codex·구현

- 실제 저장소·Git 상태·파일·테스트 감사
- 승인 범위의 파일·데이터 계약·테스트만 수정
- 사용자 변경·저장·공개 인터페이스 보호
- 구현·검증 결과를 문서와 Context에 반영

### 외부 AI

- 격리된 worktree에서 대량 초안·분류
- 결과는 검수 대기 입력
- 실제 diff·근거·테스트 확인 전 정본으로 인정하지 않음

### GitHub

- Issue 또는 승인 직접 요청을 작업 계약으로 사용
- 브랜치·Draft PR에서 변경 격리
- PR에 목표·범위·보호·검증·미검증·롤백·다음 게이트 기록
- Workflow 존재·Actions 성공·Required Check 강제 분리

## 8. 검증

```text
contract-check
→ 필요한 경우 external-source-review
→ reference-freshness
→ static-validation
→ runtime-validation
→ 적용 시 accessibility-review
→ 적용 시 performance-profile
→ regression
→ evidence-report
```

접근성은 실제 정보·입력·탐색·시간·난이도·모션 장벽과 대안을 검수한다. 성능은 목표 플랫폼·동일 빌드·대표·최악 장면의 frame time·CPU·GPU·메모리·로딩을 baseline과 비교한다.

## 9. 파일 안전

- 혼합 작업트리에서는 관련 파일만 stage
- 기존 파일 삭제·이동은 reconciliation·보존 대조·승인 필요
- 활성 `v2`·`final`·`latest` 복제본 금지
- 같은 책임의 Markdown·JSON 이중 원본 금지
- PDF·DOCX를 독립 원본으로 수동 수정 금지
- 생성 실패 시 기존 정상 산출물 보존
- 변경된 정본뿐 아니라 untouched 소비자·테스트·파생본 확인

## 10. 완료 보고

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

실제 변경, 유지한 결정·자산, 검증 결과, 미검증, 접근성·성능 상태, 위험·롤백, Context·Roadmap·Skill 최신화, 다음 작업을 분리한다.
