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

## 라우팅

- Work Mode 하나
- 전체 Skill 로드 금지
- 주 책임 분야 Skill 최대 하나
- trigger·do_not_use_when 확인
- 저장소 사실을 사용자에게 재질문하지 않음
- 정본·경로·ID·Schema 변경은 reference-freshness 실행
- 발행·검증·Handoff는 해당 게이트에서만 호출

## Skill 구조

Base 공유 Skill 13개가 공용 절차를 책임진다. 프로젝트 고유 Skill은 다음 4개다.

- `ten-paces-game-design`
- `combat-ux-and-accessibility`
- `combat-implementation-handoff`
- `ten-paces-verification`

새 로컬 Skill을 만들기 전에 기존 Base Skill의 mode 또는 현재 로컬 Skill 확장으로 해결 가능한지 확인한다.

## 실행 순서

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

환경·권한 → 정본·Schema → 위험한 가설 → 핵심 경로 → 통합 → 정상·실패·경계·회귀 → 문서·참조 최신성 → 사용자 검수 순서로 진행한다.

## 역할

- GPT·기획: 요구·경험·범위·완료·검증 계약과 책임 원본·Context 갱신
- Codex·구현: 실제 저장소·Git·파일·테스트 확인 후 승인 범위 구현
- 외부 AI: 격리된 검수 대기 입력
- GitHub: Draft PR에 목표·범위·보호·검증·미검증·롤백 기록

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

현재 등록 문서와 Skill Registry는 발행 생성기가 없어 `source_only`다. PDF가 필요한 마일스톤에서 생성기·폰트·렌더·Manifest 검증을 함께 설치한다. 실행하지 않은 검증은 `NOT_RUN` 또는 `UNVERIFIED`다.

## 파일 안전

- 삭제·이동은 reconciliation·보존 대조·사용자 승인 필요
- 활성 버전 복제본·Markdown/JSON 이중 원본 금지
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
