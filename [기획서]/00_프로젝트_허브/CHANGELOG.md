# 십보강호 운영 변경 기록

## Unreleased — Base schema v3 비파괴 마이그레이션

### 추가

- 루트 `START_HERE.md`와 `[기획서]/00_프로젝트_허브`.
- Source Audit·Active Context·Handoff·운영 Roadmap.
- Documentation Map·Development Gates·Document Update Matrix.
- schema v3 Design Document Registry와 로컬 JSON Schema.
- schema v3 Skill Registry, 선택 분야 진입 스킬과 Learning Log.
- 딥인터뷰 Registry·확인 기록·실행 계약.
- Decision Log·AI Workflow·Lifecycle Areas·Health Report.
- GitHub Governance 정적 검사와 Workflow 기반.

### 변경

- 기존 `docs/01~11`을 schema v3 Markdown 단일 책임 원본으로 등록.
- Base 기준을 v1.9.3에서 최신 `main` 커밋 SHA 기준으로 갱신.
- 프로젝트 교훈의 자동 Base 승격을 제안·사용자 승인·별도 구현 PR 계약으로 변경.
- README·AGENTS·Documentation Map의 최초 읽기 순서를 루트 START_HERE와 기획 허브 중심으로 변경.

### 보존

- 기존 활성 본책·백업·보류·Plan과 Git 이력.
- 10-10-10 구조, 5전 데모, 전투·성장·문파·UI·연출의 승인 결정.
- 구현·플레이테스트가 확인되지 않은 항목의 미검증 상태.

### 검증

- Base 최신 START_HERE, 마이그레이션 Method·Skill, schema v3 템플릿·Schema와 대조.
- 대상 원격 `main`의 루트·활성 본책·운영 문서·Plan 책임 감사.
- JSON 문법·경로·중복을 Governance 검사 대상으로 추가.

### 미검증

- 사용자 Windows 작업본의 Git 상태와 원격 차이.
- Godot 프로젝트·코드·씬·데이터·테스트.
- PDF·DOCX·Mermaid 생성 도구와 한글 폰트.
- PDF 전 페이지 렌더와 사람 시각 검수.
- GitHub Actions 실제 성공과 Branch protection Required Check.
- 플레이테스트와 사용자 이해도.
