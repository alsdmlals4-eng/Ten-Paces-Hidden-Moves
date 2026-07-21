# Base 규칙 적용 버전

## 기준

- Base: `alsdmlals4-eng/Base@ee265576da7f67d3278f8099dd97d4e714ef0651`
- 이전 기준: `eb40b912e5f5a0e4d369105a4f0a770e0a6179a9`
- 비교: 155개 커밋·70개 변경 파일
- 동기화 날짜: `2026-07-21`
- 운영 PR: #5
- 전투 POC PR: #7
- 파일별 감사: `[기획서]/00_프로젝트_허브/BASE_MAIN_SYNC_AUDIT.md`
- 최종 검증: `[기획서]/00_프로젝트_허브/BASE_MAIN_SYNC_VERIFICATION.md`

정식 버전명보다 commit SHA를 재현 가능한 기준으로 사용한다. 일상 작업은 프로젝트에 동기화된 규칙을 우선하고 Base 원격은 업데이트 감사 때만 다시 비교한다.

## 적용한 공용 계약

### 작업·Skill

- Work Mode: `PLAN / BUILD / REVIEW`
- Registry trigger 기반 최소 Skill·Skill Mode 자동 선택
- 주 책임 분야 Skill 최대 1개
- L1 이상 `execution-report`
- 기존 프로젝트 `audit → reconcile-legacy → 승인된 migrate → verify`

Base 공유 Skill 13개:

1. `managing-project-intake-and-work-contract`
2. `managing-game-project-operating-system`
3. `managing-design-documents`
4. `evolving-project-discipline-skills`
5. `maintaining-project-context-and-handoff`
6. `analyzing-and-refining-game-concepts`
7. `designing-vertical-slices`
8. `orchestrating-deepseek-worktrees`
9. `reviewing-and-validating-project-changes`
10. `auditing-canonical-reference-freshness`
11. `designing-art-prompts-and-technique-cards`
12. `auditing-and-refining-ui-art`
13. `managing-base-change-proposals`

프로젝트 로컬 Skill은 Base에 없는 십보강호 고유 판단만 유지한다.

- `ten-paces-game-design`
- `combat-ux-and-accessibility`
- `combat-implementation-handoff`
- `ten-paces-verification`

통합 전 ID는 `skills/LEGACY_SKILL_ALIASES.md`에서 새 Skill·mode로 연결한다.

### 책임 원본·발행

- 한 질문에 Markdown 또는 JSON 책임 원본 하나
- PDF·DOCX·다이어그램은 파생본
- 제품 기획 문서: `milestone_sync`
- 내부 Base 학습 기록·Skill Registry: `source_only`
- 생성 실패 시 기존 정상 산출물 보존
- `CURRENT`, 자동 렌더, 사용자 시각 검수는 독립 상태

### 검증

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

파일 존재, Workflow 존재, Actions 성공, 런타임, 사람 검수, Required Check 강제를 구분한다. 실행하지 않은 검증은 `NOT_RUN` 또는 `UNVERIFIED`다.

## 십보강호 고유 계약

- `[강호낭인]`
- 전장 10칸, 플레이어 3번·상대 8번
- 라운드 `3수 → 3수 → 4수`, 총 10수
- 판정 `대응 → 속공 → 이동 → 일반 공격`
- 기초 행동 8종
- 절초 기세 최대 5칸
- 5전 데모·10전 전체판
- Godot 코드·데이터·씬·자산·테스트·런타임 상태

기존 `docs/01~11`, 백업·보류·Plan·PR·Git 이력은 별도 승인 전 삭제·이동하지 않는다.

## 최적화 결과

- 공용 운영 기능을 로컬 Skill로 중복하지 않음
- 로컬 Skill 6개 → 프로젝트 고유 4개
- 사용 불가능한 Skill Map PDF·Manifest 계약 제거
- 컨셉·벤치마크 템플릿 통합
- 정본 최신성 양식을 변경 검증 양식에 통합
- Governance 회귀 테스트를 표준 라이브러리 단일 파일로 통합
- 중복 검사기 제거
- 기본 읽기 문서 축소

기능 삭제가 아니라 Base 공유 Skill·Registry·Legacy Alias·자동 검사로 책임을 승계했다.

## 검증 상태

확인:

- Base canonical 읽기 순서와 13개 Skill
- 70개 변경 파일 처리표
- 운영 구조·발행 정책 형태·정본 최신성·Skill 무결성 검사
- 기존 제품 본책·Godot 구현·자산 비삭제

미검증:

- 사용자 로컬 미커밋 파일
- RESPONSE 10.6 최신 Godot 런타임
- 마일스톤 PDF·Manifest와 전 페이지 시각 검수
- 접근성 사용자 검수
- 목표 플랫폼 성능 프로파일
- 외부 POC 플레이테스트
- Branch protection Required Check 강제

## 재감사 조건

- Base SHA·Skill Registry·Schema 변경
- 책임 원본·경로·ID·발행 정책·생성기 변경
- 운영체계 통합·삭제·대규모 검증
- 동일 stale reference·Skill 중복·콜드 스타트 실패 반복
