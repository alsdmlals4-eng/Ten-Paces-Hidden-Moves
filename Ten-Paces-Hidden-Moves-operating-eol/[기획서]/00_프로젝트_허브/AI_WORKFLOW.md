# 십보강호 AI·GitHub 작업 흐름

## 기본 흐름

```text
Prompt
→ PLAN / BUILD / REVIEW
→ managing-project-intake-and-work-contract
→ Registry trigger 기반 최소 Skill·Skill Mode
→ 저장소·PR·Issue·기준 SHA 조사
→ Ready·실행 순서·보호 경로
→ 승인 범위 실행
→ reviewing-and-validating-project-changes
→ 필요 시 reference-freshness·accessibility·performance
→ baseline diff·책임 원본·Context·PR 동기화
→ execution-report·Learning Log
```

## 기본 읽기

```text
AGENTS.md
→ [기획서]/00_프로젝트_허브/ACTIVE_CONTEXT.md
→ [기획서]/00_프로젝트_허브/DOCUMENTATION_MAP.md
→ 질문별 책임 원본
→ 실제 파일·테스트·PR·Issue
```

백업·보류·제거 후보·과거 Plan·전체 Skill 폴더는 기본 읽기에서 제외한다.

## 라우팅

- 주 Work Mode 하나.
- 전체 Skill 로드 금지.
- 주 책임 분야 Skill 최대 하나.
- trigger·do_not_use_when 확인.
- 저장소에서 확인 가능한 사실을 사용자에게 반복 질문하지 않음.
- 정본·경로·ID·Schema·Base SHA·Skill 변경은 reference-freshness 실행.
- Handoff·발행·접근성·성능은 해당 게이트에서만 호출.

## Skill 구조

- Base 활성 Skill 28개: 공용 운영·코어·연구·검증·구조 최적화·동기화·디버깅.
- 프로젝트 고유 Skill 4개:
  - `ten-paces-game-design`.
  - `combat-ux-and-accessibility`.
  - `combat-implementation-handoff`.
  - `ten-paces-verification`.

새 로컬 Skill을 만들기 전에 Base Skill mode 또는 기존 로컬 Skill 확장으로 해결 가능한지 확인한다.

## 기준 SHA·파일 안전

```yaml
baseline_branch:
baseline_sha:
work_branch:
protected_paths:
allowed_change_prefixes:
stop_conditions:
rollback:
```

- exact 기준 SHA에서 분기한다.
- 사용자·Codex 변경을 reset·rebase·force push로 덮어쓰지 않는다.
- 변경 후 baseline compare로 모든 파일을 확인한다.
- 보호 경로에 예상 밖 변경이 있으면 중단한다.
- 로컬 미커밋 상태를 원격과 동일하다고 가정하지 않는다.

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

환경·권한 → 정본·Schema → 위험한 가설 → 핵심 경로 → 통합 → 정상·실패·경계·반례·회귀 → baseline diff → 사용자 검수 순서로 진행한다.

## 역할

- GPT·기획: 경험·범위·코어·완료·검증 계약과 책임 원본·Context.
- Codex·구현: 실제 저장소·Git·파일·테스트 확인 후 승인 범위 구현.
- 외부 AI: 격리된 검수 대기 입력.
- GitHub: Draft PR에 기준 SHA·목표·범위·보호·검증·미검증·롤백 기록.

## 검증

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

현재 등록 문서와 Skill Registry는 생성기가 없어 `source_only`다. 실행하지 않은 검증은 `NOT_RUN` 또는 `UNVERIFIED`다.

## 완료 보고

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

## Base v9.4 모델·지시·Context 계약

- `[모델 추천]` 요청 시 작업 위험·재작업 비용·속도를 기준으로 모델과 추론 단계를 제안하고, 실제 설정 변경은 사용자가 수행한 다음 checkpoint부터 적용한다.
- `HARD_CONSTRAINT`는 보안·권한·데이터 무결성·저장 호환성·불가역 변경에만 사용한다.
- 일반 기술 구조는 `RECOMMENDED_DEFAULT`, 표현·비파괴 초안은 `JUDGMENT_SPACE`로 구분한다.
- Prompt는 `problem / player_or_user_value / inputs / authority_and_source / output_contract / invariants / failure_conditions / validation`의 Interface-first 계약을 우선한다.
- `Example-as-Fixture`: 예시는 정답 권위가 아니라 정상·실패·경계·회귀 Fixture 또는 Golden Set으로 보존한다.
- Context는 `decision_question / include_criteria / exclude_criteria / authority_level / freshness / known_conflicts / progressive_load_trigger / refresh_trigger`를 기록한다.
- 화면·Schema·Fixture는 실제 Godot 런타임·사람 이해·접근성·성능을 자동 증명하지 않는다. 실행하지 않은 항목은 `NOT_RUN` 또는 `HUMAN_NOT_RUN`이다.

Base identity: payload `a728712cb776ec98f4875914a580fcf7d0156593`, evidence `ef1fba11167e4da0b298123b0c85ebd268191a42`, Registry `693a0dff3f054ecdd653079909e044211473838e73dd9aff07734d1ce5694c59`.
