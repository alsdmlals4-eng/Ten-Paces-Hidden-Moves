# 십보강호 운영 로드맵

> 제품 구현 순서의 책임 원본은 `../../../docs/04_ROADMAP.md`다. 이 문서는 Base 운영체계 마이그레이션과 제품 게이트의 연결만 책임진다.

## M0 — 기준선·보존 감사

목표: 구조를 바꾸기 전에 원격 책임 원본·백업·보류·Plan과 미검증 범위를 고정한다.

- [x] Base 기준 커밋 고정.
- [x] 대상 `main` 기준 커밋 고정.
- [x] Issue #4 작업 계약 생성.
- [x] 기존 11개 활성 본책·운영 문서·Plan 인벤토리.
- [x] 자동 Base 승격 등 최신 계약 충돌 식별.
- [ ] Windows 작업본 파일·Git 상태·원격 차이 감사.
- [ ] 백업·보류 하위 파일별 고유 정보·참조 감사.

**종료 기준**

- 기존 내용을 잃지 않고 현재 역할·상태·목표 처리를 찾을 수 있다.
- 원격에서 확인하지 못한 로컬·런타임 상태가 명확히 `[미검증]`이다.

## M1 — Governance foundation

목표: 저장소 루트에서 현재 상태·본책·스킬·게이트를 찾게 한다.

- [x] 루트 `START_HERE.md`.
- [x] `[기획서]/00_프로젝트_허브` 시작 구조.
- [ ] Documentation Map·Development Gates·Update Matrix.
- [ ] Active Context·Handoff·Decision Log·Changelog.
- [ ] AI Workflow·Lifecycle Areas·Health Report.
- [ ] README·AGENTS·Base Rules Version 최신화.

**종료 기준**

- 새 작업자가 10분 안에 핵심 경험, 현재 단계, 다음 작업, 보호 범위와 미검증을 설명한다.

## M2 — 책임 원본·스킬 Registry

목표: 기존 Markdown 본책과 프로젝트 스킬을 기계 판독 가능하게 연결한다.

- [ ] `DESIGN_DOCUMENT_REGISTRY.json`에 활성 본책 등록.
- [ ] 선택 책임 분야와 누락 분야를 명시.
- [ ] `SKILL_REGISTRY.json` 설치.
- [ ] 최소 Foundation·분야 진입 스킬 설치.
- [ ] `SKILL_LEARNING_LOG.md` 설치.
- [ ] 인터뷰 Registry와 사용자 확인 기록 경로 설치.

**종료 기준**

- 한 질문에 책임 원본이 하나다.
- 전체 스킬 자동 로드가 금지된다.
- 선택한 각 분야가 실제 원본·Plan·검증 경로를 가진다.

## M3 — GitHub Governance·정적 검증

목표: 구조·JSON·링크·금지 상태의 회귀를 자동 탐지한다.

- [ ] PR 템플릿.
- [ ] 문서 Governance 설정.
- [ ] 표준 라이브러리 기반 검사기.
- [ ] GitHub Actions Workflow.
- [ ] 원격 브랜치에서 검사 실행.
- [ ] Actions 성공 상태 확인.
- [ ] Branch protection Required Check 상태 확인.

**종료 기준**

파일 존재, 로컬 검사 통과, Actions 통과, Required Check 강제를 각각 독립 상태로 기록한다.

## M4 — 발행 파이프라인

목표: 각 등록 본책의 최신 PDF와 Manifest를 생성·검증한다.

- [ ] Windows/Linux 의존성 사전점검.
- [ ] 한글 폰트·LibreOffice·Poppler·Mermaid 실제 실행 확인.
- [ ] Markdown 책임 원본에서 PDF 생성.
- [ ] 필요한 경우 DOCX·다이어그램 생성.
- [ ] 전 페이지 렌더 자동 검수.
- [ ] 사람 시각 검수.
- [ ] Publication Manifest 해시 기록.
- [ ] 프로젝트 Skill Map PDF 생성.

**종료 기준**

- 모든 필수 PDF가 CURRENT다.
- 자동 렌더와 사람 시각 검수 상태가 분리돼 있다.
- 생성 실패 시 기존 정상 산출물을 보존한다.

## M5 — 로컬·구현 감사와 제품 인수

목표: Windows 작업본과 실제 Godot 프로젝트를 문서 계약에 연결한다.

- [ ] 사용자 제공 경로의 Git status·브랜치·remote 확인.
- [ ] 원격과 로컬 차이 분류.
- [ ] `project.godot`, 씬, GDScript, Resource, 데이터, 테스트 확인.
- [ ] 기존 6슬롯·1~5성·9전 등 폐기 구조 검색.
- [ ] 저장·ID·공개 인터페이스 보호 경로 확정.
- [ ] 실제 검증 명령과 중단 기준 작성.
- [ ] 제품 구현 Plan 갱신.

**종료 기준**

문서의 승인·미확정·구현·검증 상태가 실제 파일과 모순되지 않는다.

## M6 — Cleanup·Enforcement

목표: 완전히 흡수되고 참조가 없는 중복만 승인 후 정리한다.

- [ ] 변경 전후 보존 대조 통과.
- [ ] 제거 후보별 고유 정보·참조·복구 방법 확인.
- [ ] 사용자 삭제 승인.
- [ ] 이동·이름 변경과 모든 참조를 같은 PR에서 수정.
- [ ] 콜드 스타트·PDF·Actions·링크 재검증.

**종료 기준**

변경 전 존재했지만 변경 후 찾을 수 없는 고유 내용이 없다.

## 제품 로드맵 연결

운영 M0~M3은 제품 설계를 변경하지 않는다. 제품 구현은 `../../../docs/04_ROADMAP.md`의 단계 0A·0B 이후 승인을 따른다.

현재 제품 우선순위:

1. 절초 기세·상단 HUD UX 설계 승인.
2. 실제 Godot 저장소 상태 감사와 승인 Plan.
3. T0 전투 PoC.
4. T1 5전 데모 흐름.
5. 시작 6세력 검증 후 12세력·10전 확장.
