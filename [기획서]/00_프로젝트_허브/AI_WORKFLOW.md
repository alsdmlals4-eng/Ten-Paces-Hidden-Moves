# 십보강호 AI·GitHub 작업 흐름

## 기본 흐름

```text
Prompt
→ PLAN / BUILD / REVIEW
→ managing-project-intake-and-work-contract
→ Registry trigger 기반 최소 Skill·Skill Mode
→ Ready·필요 시 실행 순서
→ 사용자 확인
→ 구현
→ reviewing-and-validating-project-changes
→ 필요 시 reference-freshness·accessibility·performance
→ 책임 원본·Context·PR 동기화
→ execution-report·Learning Log
```

## 기본 읽기

```text
../../../AGENTS.md
→ ACTIVE_CONTEXT.md
→ DOCUMENTATION_MAP.md
→ 현재 책임 원본
→ 실제 파일·테스트·PR
```

백업·보류·제거 후보와 전체 Skill 폴더는 기본 읽기에서 제외한다.

## 라우팅 원칙

- Work Mode의 주 상태는 하나
- 전체 Skill 로드 금지
- 주 책임 분야 Skill 최대 하나
- trigger·do_not_use_when 확인
- 저장소에서 확인할 사실을 사용자에게 재질문하지 않음
- 정본·경로·ID·Schema 변경은 reference-freshness 실행
- 발행·검증·Handoff는 해당 게이트에서만 호출

## Skill 구조

Base 공유 Skill 13개가 요청 접수, 운영체계, 문서, 상태 인수, 컨셉·연구, Vertical Slice, 외부 AI, 변경 검증, 정본 최신성, 아트, Base 제안을 책임진다.

프로젝트 고유 Skill 4개:

- `ten-paces-game-design`
- `combat-ux-and-accessibility`
- `combat-implementation-handoff`
- `ten-paces-verification`

새 로컬 Skill을 만들기 전에 기존 Base Skill의 mode 또는 현재 로컬 Skill 확장으로 해결 가능한지 확인한다.

## 실행 순서

각 단계:

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

기본 순서:

```text
환경·권한
→ 정본·Schema·인터페이스
→ 가장 위험한 가설
→ 핵심 사용자·플레이어 경로
→ 통합
→ 정상·실패·경계·회귀
→ 문서·발행·참조 최신성
→ 사용자 검수·인수
```

## 역할

### GPT·기획

요구·경험·범위·완료·검증을 계약으로 정리하고 책임 원본·Roadmap·Context를 갱신한다.

### Codex·구현

실제 저장소·Git·파일·테스트를 확인하고 승인 범위만 수정한다. 사용자 변경·저장·공개 인터페이스를 보호한다.

### 외부 AI

격리된 worktree의 검수 대기 입력이다. 실제 diff·근거·테스트 전에는 정본이 아니다.

### GitHub

Issue 또는 승인 요청을 계약으로 사용하고 Draft PR에 목표·범위·보호·검증·미검증·롤백을 기록한다. Workflow·Actions·Required Check를 구분한다.

## 검증

```text
contract-check
→ reference-freshness
→ static-validation
→ runtime-validation
→ 적용 시 accessibility-review
→ 적용 시 performance-profile
→ regression
→ evidence-report
```

제품 문서는 `milestone_sync`, 내부 운영 기록과 Skill Registry는 `source_only`다. 실행하지 않은 검증은 `NOT_RUN` 또는 `UNVERIFIED`다.

## 파일 안전

- 삭제·이동은 reconciliation·보존 대조·사용자 승인 필요
- 활성 버전 복제본 금지
- Markdown·JSON 이중 원본 금지
- PDF·DOCX를 독립 원본으로 수정 금지
- 변경된 정본과 untouched 소비자·테스트·Workflow 확인

## 완료 보고

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
