# 십보강호 기존 구조·구형 파일 감사

- 작업 계약: Issue #4와 사용자 승인 직접 요청
- 현재 Base: `ee265576da7f67d3278f8099dd97d4e714ef0651`
- 최초 대상 기준: `0ac66389ad6b1d10019680ebf1417d423fa1466e`
- 최신 Base 전수 처리표: `BASE_MAIN_SYNC_AUDIT.md`
- 사용자 작업 경로: `C:\Users\user\Documents\GitHub\Ninza\Ten-Paces-Hidden-Moves`
- 로컬 미커밋 상태: `[미검증]`

## 작업 절차

```text
PLAN: audit
→ reconcile-legacy 처리표
→ 목표 구조·보존·롤백
→ 사용자 승인
→ BUILD: 승인된 UPDATE·MERGE·STUB·ARCHIVE·DELETE·migrate
→ REVIEW: 보존·참조·파생본·복구 대조
→ reference-freshness
→ verify
```

## 보호 계약

- 기존 `docs/01~11`
- `docs/[백업]`, `docs/[보류]`, Plan, PR·Git 이력
- 프로젝트 고유 세계관·수치·용어·ID·Godot 경로
- 승인 UI·배경·카드·전투 구현
- 실행하지 않은 검증의 미검증 상태

사용자 승인 없이 대량 삭제·이동·통합·강제 개명을 하지 않는다.

## 현재 구조

```text
START_HERE.md
AGENTS.md
README.md
docs/
plans/
[기획서]/
skills/
data/
scenes/
src/
tests/
tools/
.github/
project.godot
```

초기 감사 당시 원격에서 확인하지 못했던 Godot·Registry·Workflow 파일은 현재 PR #5·#7에 존재한다. 초기 관찰을 현재 사실처럼 유지하지 않는다.

## 현행 책임 인벤토리

| 경로 | 역할 | 판정 |
|---|---|---|
| `README.md`, `START_HERE.md`, `AGENTS.md` | 루트 Entry Point·최상위 규칙 | `UPDATE_IN_PLACE` 완료 |
| `docs/01~11` | 제품·전투·UI·QA·아키텍처 책임 원본 | `CURRENT`, 내용 최신성 별도 감사 |
| `docs/BASE_RULES_VERSION.md` | Base SHA·프로젝트 차이 | `UPDATE_IN_PLACE` 완료 |
| `[기획서]/DESIGN_DOCUMENT_REGISTRY.json` | 기획 책임·경로·발행 정책 | `CURRENT`, 발행 대기 |
| `[기획서]/00_프로젝트_허브` | 상태·Skill·게이트·검증 라우터 | `UPDATE_IN_PLACE` 진행 |
| `skills/` 프로젝트 6개 Skill | 프로젝트 경로·규칙·검증 분화 | `UPDATE_IN_PLACE` 완료 |
| `skills/LEGACY_SKILL_ALIASES.md` | 제거된 Base Skill ID 호환 | `CURRENT` |
| `data/`, `scenes/`, `src/`, `tests/` | 전투 POC 실제 구현 | `CURRENT`, 최신 런타임 일부 미검증 |
| `docs/[백업]` | 역사·복구 | `ARCHIVE_HISTORY`, 기본 수정 제외 |
| `docs/[보류]` | 재개 승인 전 금지 | `KEEP_UNRESOLVED` |
| `plans/` | 과거·현행 실행 계약 | `CURRENT` 또는 역사, 삭제 안 함 |

## 구형·stale 상태

초기 운영 문서에는 다음 과거 표현이 현행 Entry Point에 남아 있었다.

- 행동 두 개·2수 잠금
- 기초 행동 7종
- STEP 1·2 또는 Godot 미설치 상태
- Base `eb40b9…`
- Skill `default_selection=none`

처리:

- 루트·허브·Skill Registry·활성 Skill은 현재 10수·8종·STEP 10.6·자동 라우팅으로 갱신한다.
- 과거 Changelog·Learning Log·Alias·Case는 역사 설명으로 보존할 수 있다.
- 제품 본책 `docs/01~10`의 과거 규칙은 별도 제품 정본 갱신 작업으로 추적하며 Base 운영 동기화에서 무리하게 전면 재작성하지 않는다.
- 현행 Entry Point의 stale 재등장은 canonical reference freshness 검사로 차단한다.

## 파일별 처리 상태

```text
CURRENT
UPDATE_IN_PLACE
MERGE_TO_CANONICAL
COMPATIBILITY_STUB
ARCHIVE_HISTORY
DELETE_APPROVED
KEEP_UNRESOLVED
```

현재 `DELETE_APPROVED` 항목은 없다.

## 보존 대조

- 핵심 경험·10칸·10수·10전: 보존
- 5전 데모·10전 전체판: 보존
- 무공·심법·절초: 보존
- UI·연출·아키텍처 경계: 보존
- QA 체크리스트와 Plan: 보존
- 백업·보류: 보존
- Godot 구현·사용자 확인: Active Context·PR #7에 연결
- Base 적용 학습: 최신 SHA와 Work Mode 계약으로 갱신

## 미검증

- 사용자 로컬 미커밋 파일과 원격 차이
- 백업·보류의 모든 외부 링크·고유 정보
- PDF·DOCX·다이어그램·Manifest 실제 발행
- RESPONSE 10.6 최신 Windows 런타임
- 접근성·성능·플레이테스트
- Branch protection Required Check 강제

## 다음 Cleanup 게이트

1. 삭제·이동 후보별 reconciliation 표
2. 고유 정보·활성 참조·파생본·복구 경로
3. 사용자 명시 승인
4. 승인된 처리만 같은 PR에서 수행
5. reference-freshness·회귀·콜드 스타트 검증
