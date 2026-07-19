# 십보강호 운영체계 Health Report

- 검사일: 2026-07-20.
- 기준 브랜치: `agent/base-full-11-migration`.
- Base 기준: `eb40b912e5f5a0e4d369105a4f0a770e0a6179a9`.
- 대상 기준: `0ac66389ad6b1d10019680ebf1417d423fa1466e`.
- 검사 범위: 원격 문서 운영체계와 PR Actions.
- Draft PR: `#5`.

## 종합 판정

`PARTIAL VERIFIED — Governance foundation·Registry·PR Actions 검증 완료 / 로컬·발행·런타임·Required Check 대기`

## 영역별 상태

| 영역 | 상태 | 증거 | 결함·위험 | 다음 행동 |
|---|---|---|---|---|
| 루트 START_HERE | VERIFIED | `START_HERE.md`·Actions | 없음 | 콜드 스타트 사람 검토 |
| 루트 `[기획서]` | VERIFIED | 프로젝트 허브·Actions | 분야별 PDF 폴더 미생성 | 발행 게이트에서 생성 |
| Active Context·Handoff·Roadmap | VERIFIED | 허브 문서·Actions | 로컬 상태 미반영 | Windows 작업본 감사 후 갱신 |
| Documentation Map·Gates·Update Matrix | VERIFIED | 허브 문서·Actions | Markdown 링크 전체 검사 범위는 제한적 | 후속 링크 검사 확장 |
| Design Document Registry | VERIFIED_SOURCE / PENDING_PUBLICATION | 11개 Markdown 본책 등록·경로 검사 통과 | PDF·Manifest 없음 | M4 발행 실행 |
| Skill Registry | VERIFIED_SOURCE / PENDING_PUBLICATION | 선택 분야 6개·진입 스킬·trigger 검사 통과 | PDF 스킬맵 없음 | M4 Skill Map 발행 |
| Learning Log | VERIFIED | `skills/SKILL_LEARNING_LOG.md` | 실제 반복 검증 적음 | 후속 호출 기록 |
| Interview Registry | VERIFIED | INT-2026-001·경로 검사 | 로컬 결정 미확인 항목 존재 | M5에서 보완 |
| Lifecycle | VERIFIED | 보존·보류·제거 후보 계약 | 백업 하위 파일별 감사 미완료 | 로컬·원격 상세 인벤토리 |
| PDF·Publication Manifest | MIGRATION_PENDING | Design Registry 목표 경로·Manifest 경계 | 도구·폰트·입력·렌더 미확인 | M4 사전점검 |
| Visual Source·Asset Manifest | NOT_INSTALLED | 원격 자산 없음 | 로컬 승인 이미지 여부 미확인 | M5에서 설치 판단 |
| GitHub Governance | VERIFIED | `documentation-governance` run `29707420087` 성공 | 첫 실패 후 파일명 수정 이력 | 회귀 유지 |
| Governance 진단 | VERIFIED | 실패 아티팩트로 `-v3-` 파일명 위반 확인·수정 | 없음 | 진단 아티팩트 7일 보존 |
| Required Check | NOT_RUN | 설정 변경 안 함 | Actions 성공과 강제 상태는 별개 | 별도 사용자 결정 후 설정 |
| Godot 프로젝트 | NOT_RUN | 원격에 파일 없음 | 로컬 작업본 미마운트 | M5 감사 |
| 테스트·빌드 | NOT_RUN | 체크리스트만 존재 | 실행 증거 없음 | 실제 테스트 환경 연결 |
| 콜드 스타트 | PARTIAL | 루트·허브 읽기 순서와 자동 경로 검사 | 독립 작업자 10분 실측 전 | PR 사람 검토 |

## Actions 검증 이력

1. 첫 실행에서 `documentation-governance` 실패.
2. Workflow가 `governance-diagnostics` 아티팩트를 업로드.
3. 실제 오류: 인터뷰·실행 계약 파일명에 포함된 `-v3-`가 활성 버전 복제본 금지 규칙에 걸림.
4. 내용의 schema v3 표기는 유지하고 파일명을 역할 중심으로 교체.
5. Interview Registry 참조를 함께 갱신.
6. 후속 run `29707420087`의 검사·진단 업로드·발행 경계 단계가 모두 성공.

## 콜드 스타트 질문

새 작업자는 저장소만 읽고 다음에 답해야 한다.

1. 십보강호의 핵심 재미와 5전 데모 범위는 무엇인가?
2. 현재 제품·운영 단계는 무엇인가?
3. 전투 규칙, UI, 아키텍처, 테스트의 책임 원본은 어디인가?
4. 지금 구현을 시작해도 되는가?
5. 로컬 Windows 작업본과 원격의 관계는 검증됐는가?
6. `[보류]`에서 구현하면 안 되는 내용은 무엇인가?
7. PDF·Actions·Godot의 실제 검증 상태는 무엇인가?
8. 프로젝트 교훈을 Base에 어떻게 제안하는가?

10분 안에 정확히 답하지 못하면 START_HERE·Active Context·Documentation Map·Registry를 보강한다.

## 보존 판정

- 기존 활성 본책 삭제: 없음.
- 기존 백업·보류 삭제: 없음.
- 기존 Plan 삭제: 없음.
- 기존 책임 원본 경로 이동: 없음.
- 제품 고유 결정 변경: 없음.
- 운영 계약 추가: 있음.
- 최신 Base 충돌 수정: AGENTS·Base 버전·README·제품 지도 갱신 완료.
- 이번 브랜치에서 생성 후 교체한 버전형 인터뷰 파일: Registry 동기화 후 역할형 파일명으로 대체.

## 현재 차단 요인

1. Windows 로컬 경로를 현재 실행 환경에서 직접 열 수 없음.
2. PDF 생성 도구·한글 폰트·LibreOffice·Poppler·Mermaid 실제 상태 미확인.
3. 원격에 Godot 프로젝트와 테스트가 노출되지 않음.
4. Branch protection 설정을 확인·변경하지 않음.

## 다음 Health Review

- 사용자 Windows 작업본 감사 후.
- 첫 기획서 PDF·스킬맵 발행 후.
- Branch protection Required Check 결정 후.
- Prototype 또는 Vertical Slice Greenlight 전.
