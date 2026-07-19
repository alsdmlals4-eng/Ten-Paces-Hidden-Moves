# 십보강호 기존 구조 마이그레이션 감사

- 작업 계약: Issue #4 / 사용자 승인 직접 요청
- Base 기준: `alsdmlals4-eng/Base@eb40b912e5f5a0e4d369105a4f0a770e0a6179a9`
- 대상 기준: `alsdmlals4-eng/Ten-Paces-Hidden-Moves@0ac66389ad6b1d10019680ebf1417d423fa1466e`
- 감사 수준: 원격 저장소 전수 감사 + 비파괴 Governance foundation
- 로컬 기준 경로: `C:\Users\user\Documents\바이브코딩\ten-paces-hidden-moves-base-full-11-migration`
- 로컬 접근: `[미검증]` — 현재 실행 환경에 마운트되지 않음

## 1. 작업 권한과 보호 계약

```yaml
target_repository: alsdmlals4-eng/Ten-Paces-Hidden-Moves
base_reference_commit: eb40b912e5f5a0e4d369105a4f0a770e0a6179a9
requested_level: audit/governance/migration
protected_paths:
  - docs/
  - plans/
  - docs/[백업]/
  - docs/[보류]/
protected_decisions:
  - 전장 10칸·라운드 10타이밍·대회 10전
  - 2수 비공개 잠금·동시 공개·순차 해상
  - 5전 예선 결승 데모
  - 합·수련·행운·상대 정보·제약의 현행 계약
protected_assets:
  - 원격에서 확인되지 않음
explicitly_approved_changes:
  - Base 최신 구조에 따른 정리·최신화·갱신
  - 비파괴 루트 기획 허브와 Registry 설치
  - 기존 책임 원본의 schema v3 등록
target_design_document_contract: preserve-current-markdown-sources
```

## 2. 저장소 구조 감사

원격 루트에서 확인한 활성 구조:

```text
AGENTS.md
README.md
docs/
plans/
```

원격에서 확인하지 못한 항목:

- `project.godot`.
- GDScript·씬·Resource·게임 데이터.
- 테스트 실행 파일과 빌드 설정.
- 승인 이미지·실제 캡처·자산 Manifest.
- 루트 `[기획서]`.
- Design Document Registry.
- Skill Registry와 Learning Log.
- Development Gates·Document Update Matrix·Handoff.
- PDF·Publication Manifest.
- GitHub Governance 검사와 Actions.

위 항목은 존재하지 않는다고 단정하지 않는다. 제공된 Windows 작업본에만 있을 가능성이 있으므로 `[로컬 확인 필요]`다.

## 3. 현행 책임 문서 인벤토리

| 현재 경로 | 현재 역할 | 상태 | 목표 처리 | 위험·검증 |
|---|---|---|---|---|
| `README.md` | 제품 소개·현재 방향·문서 링크 | 현행 입구 | 루트 START_HERE와 연결해 유지 | 설명 중복 검색 |
| `AGENTS.md` | 프로젝트 협업·보존·동기화 규칙 | 현행 운영 원본 | Base schema v3 계약으로 확장 | 프로젝트 고유 규칙 보존 |
| `docs/ACTIVE_CONTEXT.md` | 현재 방향·미확정·다음 작업 | 현행 책임 원본 | 허브에서 라우팅, 내용 유지 | 루트 허브와 장문 중복 금지 |
| `docs/DOCUMENTATION_MAP.md` | 기존 문서 읽기 순서 | 현행 책임 원본 | 허브 지도와 역할 분리 | 경로 변경 시 링크 검증 |
| `docs/01_GAME_DESIGN.md` | 전체 경험·범위 | 현행 Markdown 본책 | Registry 등록·PDF 발행 대기 | 고유 결정 보존 |
| `docs/02_COMBAT_RULES.md` | 전투 판정 | 현행 Markdown 본책 | Registry 등록·PDF 발행 대기 | 수치·예외 보존 |
| `docs/03_CONTENT_CATALOG.md` | 콘텐츠 목록 | 현행 Markdown 본책 | Registry 등록·PDF 발행 대기 | 보류 혼입 검사 |
| `docs/04_ROADMAP.md` | 제품 구현 순서·완료 기준 | 현행 제품 Roadmap | 운영 ROADMAP에서 참조 | 운영·제품 단계 혼동 방지 |
| `docs/05_COMBAT_POC_SPEC.md` | 데모·전체판 범위 | 현행 Markdown 본책 | Registry 등록·PDF 발행 대기 | 데모/전체판 경계 보존 |
| `docs/06_STARTING_FACTION_MASTERY_DATA.md` | 무공·심법 성장 | 현행 Markdown 본책 | Registry 등록·PDF 발행 대기 | 데이터 구현 상태 미검증 |
| `docs/07_COMBAT_UI_SPEC.md` | UI·카드·아트 정보 배치 | 현행 Markdown 본책 | Registry 등록·PDF 발행 대기 | 실제 렌더 없음 |
| `docs/08_TEST_CHECKLIST.md` | 관찰 가능한 검증 | 현행 QA 본책 | Registry 등록·실행 증거 대기 | 체크리스트와 실행 통과 분리 |
| `docs/09_COMBAT_SYSTEM_ARCHITECTURE.md` | 도메인·데이터·저장 경계 | 현행 Markdown 본책 | Registry 등록·실제 경로 감사 대기 | 구현 파일 미확인 |
| `docs/10_COMBAT_PRESENTATION_PLAN.md` | 전투·대회 연출 | 현행 Markdown 본책 | Registry 등록·렌더 검증 대기 | UI와 결과 소유 경계 유지 |
| `docs/11_BASE_ADOPTION_AND_LEARNING_LOG.md` | Base 적용·프로젝트 학습 | 현행 학습 기록 | 최신 Base 차이 추가 | Base 직접 자동 승격 규칙 폐기 필요 |
| `docs/BASE_RULES_VERSION.md` | 적용 Base 기준선 | 현행 버전 기록 | 최신 커밋·마이그레이션 상태 갱신 | Unreleased를 정식 버전으로 오표기 금지 |
| `docs/skills/TEN_PACES_PLANNING_HANDOFF_EXTENSION.md` | 기획·인수인계 프로젝트 확장 | 현행 통합 스킬 자료 | Skill Registry에 등록 | Foundation/분야 책임 분화 검토 |
| `plans/2026-07-16-combat-poc-plan.md` | 구현 인수 Plan | 현행 Plan | 유지·새 게이트와 연결 | 실제 파일 감사 전 실행 금지 |
| `docs/[백업]/` | 과거 기록·반례 | 백업 | 보존, 기본 읽기 제외 | 고유 정보·외부 참조 감사 필요 |
| `docs/[보류]/` | 재개 승인 전 구현 금지 | 보류 | 보존, Registry 기본 제외 | 재개 조건 메타데이터 보강 필요 |

## 4. 중복·충돌·누락

### 구조 누락

- 루트에서 활성 기획 진입점을 찾을 수 없었다.
- 기획 문서·스킬·발행 상태를 기계 판독할 Registry가 없었다.
- 문서 갱신 영향, Development Gates, Handoff와 운영 Health Review가 분리돼 있지 않았다.
- PDF·Manifest·자동/사람 검수 상태가 없었다.
- GitHub Actions 파일 존재·실행·Required Check 강제 상태를 구분할 구조가 없었다.

### 계약 충돌

- 기존 `AGENTS.md`의 프로젝트 교훈 **자동 Base 승격** 규칙은 최신 Base의 `[수정제안서] → 사용자 승인 → 별도 구현 PR` 계약과 충돌한다.
- 기존 Base 버전 `v1.9.3`은 최신 `main`의 schema v3·인터뷰·제안서·발행 계약을 포함하지 않는다.
- 기존 문서 지도는 `AGENTS → docs/ACTIVE_CONTEXT → docs/DOCUMENTATION_MAP`을 시작점으로 사용하지만 최신 Base는 루트 `START_HERE → [기획서] 허브`를 요구한다.

### 미검증

- 원격 문서와 Windows 작업본의 차이.
- Godot 4.7.1 프로젝트 실제 존재와 실행 가능 여부.
- PDF/DOCX 생성 도구, 한글 폰트, LibreOffice·Poppler·Mermaid 상태.
- 기존 링크의 전체 정적 검사.
- GitHub Actions와 Branch protection.

## 5. 목표 구조

```text
START_HERE.md
AGENTS.md
README.md
[기획서]/
├─ DESIGN_DOCUMENT_REGISTRY.json
└─ 00_프로젝트_허브/
   ├─ START_HERE.md
   ├─ ACTIVE_CONTEXT.md
   ├─ HANDOFF.md
   ├─ ROADMAP.md
   ├─ DOCUMENTATION_MAP.md
   ├─ DEVELOPMENT_GATES.md
   ├─ DOCUMENT_UPDATE_MATRIX.md
   ├─ SKILL_REGISTRY.json
   ├─ INTERVIEW_REGISTRY.json
   ├─ DECISION_LOG.md
   ├─ CHANGELOG.md
   ├─ AI_WORKFLOW.md
   ├─ SOURCE_AUDIT.md
   ├─ LIFECYCLE_AREAS.md
   └─ OPERATING_SYSTEM_HEALTH_REPORT.md
skills/
├─ SKILL_LEARNING_LOG.md
├─ foundation/
├─ game-design/
├─ ux-ui-accessibility/
├─ engineering/
├─ qa/
└─ integrated-review/
.github/
tools/
```

기존 `docs` 책임 원본은 Registry 발행과 보존 검증이 끝날 때까지 현재 경로에 유지한다.

## 6. 보존 대조

| 기존 내용 | 기존 위치 | 새 라우팅 위치 | 보존 | 검증 상태 |
|---|---|---|---|---|
| 핵심 경험·10-10-10 | README·01 | Registry·허브 지도 | 예 | 정적 확인 |
| 전투 규칙·합 | 02 | Registry | 예 | 정적 확인 |
| 5전 데모·10전 전체판 | 01·04·05 | Registry·Roadmap | 예 | 정적 확인 |
| 무공·심법·절초 | 06 | Registry | 예 | 정적 확인 |
| UI·연출·아키텍처 경계 | 07·09·10 | Registry | 예 | 정적 확인 |
| QA 체크리스트 | 08 | Registry·Gates | 예 | 실행 미검증 |
| Base 적용 학습 | 11 | Registry·Changelog | 예 | 최신 계약 갱신 필요 |
| 백업·보류 | 하위 폴더 | Lifecycle Areas | 예 | 파일별 로컬/원격 감사 필요 |
| 구현 Plan | plans | 허브 Documentation Map | 예 | 실제 파일 미검증 |

변경 전 존재한 활성 책임 원본은 이 단계에서 삭제하지 않는다.

## 7. 다음 게이트

1. Governance foundation 파일 설치와 링크 검증.
2. 기존 Markdown 본책의 Registry 등록.
3. 프로젝트 스킬 분화와 Learning Log 설치.
4. 원격 정적 Governance 검사 실행.
5. Windows 작업본을 연결해 원격 차이·코드·자산·테스트 감사.
6. PDF 발행 도구 사전점검과 실제 생성·전 페이지 렌더.
7. 보존 대조 뒤에만 이동·정리·제거 후보를 제안.
