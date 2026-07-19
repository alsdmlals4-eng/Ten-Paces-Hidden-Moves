# 십보강호 활성 컨텍스트

> 이 문서는 현재 상태·다음 작업·위험을 압축해 연결한다. 제품 본책의 전문을 복제하지 않는다.

## 현재 단계

- 운영: **Base schema v3 Governance foundation 설치·정적 검증 완료 / Draft PR #5 검토 중**.
- 제품: **전투·성장·대회·연출 승인 기획 정리와 구현 인수 준비**.
- 다음 제품 기획: **절초 기세·상단 HUD UX 승인안 검토**.
- 구현: 원격에서 Godot 프로젝트·코드·데이터·테스트를 확인하지 못함.
- 로컬: 사용자가 제공한 Windows 작업본이 현재 실행 환경에 연결되지 않아 `[미검증]`.
- 발행: PDF·Manifest·스킬맵은 생성 도구 사전점검 전이라 `MIGRATION_PENDING`.
- 자동화: PR #5의 `documentation-governance` Actions가 성공함.
- 강제 상태: Branch protection Required Check는 변경·확인하지 않음.

## 제품 고정 방향

- 10칸 전장.
- 라운드 행동 타이밍 10개.
- 2타이밍씩 행동 두 개를 비공개 잠금·동시 공개·순차 해상.
- 전체 대회 10전, 데모 1~5전과 5전 예선 결승.
- 같은 타이밍의 유효한 쌍방 공격은 `[합]`으로 판정.
- 내부 수치·성장·AI 프로필과 플레이어용 이명·풍문·전적·정탐 표현을 분리.
- 프레젠테이션은 전투·성장·저장 결과를 표현하며 직접 계산하지 않음.

세부 책임 원본은 `DOCUMENTATION_MAP.md`와 `../DESIGN_DOCUMENT_REGISTRY.json`을 따른다.

## 운영 고정 방향

- 기존 `docs/*.md`를 schema v3 Markdown 책임 원본으로 보존한다.
- 기존 파일을 루트 `[기획서]`에 복제하지 않는다.
- PDF는 항상 동기화 대상이지만 실제 생성 전에는 CURRENT로 표시하지 않는다.
- 기존 `docs/[백업]/`, `docs/[보류]/`, Plan을 삭제하거나 활성 범위에 혼입하지 않는다.
- 프로젝트 교훈은 Base에 자동 반영하지 않고 `[수정제안서]` 제안 PR과 사용자 승인을 거친다.
- Issue·직접 요청·Plan의 목표·범위·완료·검증을 작업 계약으로 남긴다.
- Workflow 파일 존재, Actions 성공, Required Check 강제를 서로 다른 상태로 관리한다.

## 완료한 운영 작업

1. 루트 START_HERE와 `[기획서]` 프로젝트 허브 설치.
2. Design Document Registry에 기존 11개 본책 등록.
3. Skill Registry·선택 분야 6개·진입 스킬·Learning Log 설치.
4. Development Gates·Update Matrix·Handoff·Decision·Changelog 설치.
5. README·AGENTS·Base 기준 버전·제품 문서 지도 최신화.
6. Interview Registry·확인 기록·실행 계약 설치.
7. Python 표준 라이브러리 Governance 검사기·Workflow·PR 템플릿 설치.
8. 첫 Actions 실패 원인을 진단 아티팩트로 회수하고 파일명 규칙을 수정.
9. 후속 `documentation-governance` Actions 성공 확인.

## 즉시 다음 작업

1. Draft PR #5의 사용자 검토와 병합 여부 결정.
2. Windows 작업본을 직접 연결해 Git 상태·원격 차이·Godot·자산·테스트를 감사.
3. 발행 의존성·한글 폰트를 확인하고 기획서 PDF·Manifest·Skill Map을 생성·검수.
4. Branch protection에서 `documentation-governance`를 Required Check로 강제할지 별도 결정.
5. 보존 대조 후에만 기존 경로 이동·중복 제거안을 별도 승인.

## 보호 범위

- 10-10-10 구조와 5전 데모.
- 기존 전투·성장·문파·UI·연출 수치와 미확정 상태.
- `docs/[백업]/`, `docs/[보류]/`, 기존 Plan·PR 이력.
- 구현·플레이테스트가 확인되지 않은 항목의 미검증 상태.

## 주요 위험

- 로컬 작업본에 원격보다 최신 파일 또는 미커밋 변경이 있을 수 있다.
- 문서 전용 원격과 실제 Godot 프로젝트가 분리됐을 수 있다.
- Base `main`은 정식 태그 이후 Unreleased 변경을 포함하므로 커밋 SHA를 재현 기준으로 사용해야 한다.
- PDF·DOCX·다이어그램을 생성하지 않고 구조만 설치하면 발행 게이트는 통과하지 않는다.
- Actions 성공은 Godot·PDF·플레이테스트 또는 Branch protection 강제를 의미하지 않는다.

## 완료 판정

이번 마이그레이션 브랜치는 문서 운영체계의 **설치·정적 Actions 검증**을 완료했다. Godot 실행, 플레이테스트, PDF 자동·사람 시각 검수, Branch protection 강제는 각각 별도 증거가 있어야 완료다.
