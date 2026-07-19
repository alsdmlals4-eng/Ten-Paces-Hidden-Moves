# 십보강호 인수인계

## 첫 행동

1. 루트 `START_HERE.md`를 읽는다.
2. `AGENTS.md`와 이 허브의 `ACTIVE_CONTEXT.md`를 읽는다.
3. `SOURCE_AUDIT.md`에서 원격·로컬 감사 범위와 보호 대상을 확인한다.
4. `../DESIGN_DOCUMENT_REGISTRY.json`에서 현재 질문의 책임 원본을 찾는다.
5. `SKILL_REGISTRY.json`에서 trigger가 일치하는 최소 스킬만 선택한다.
6. 구현 작업이라면 실제 Godot 파일·테스트 존재 여부부터 확인한다.

## 현재 완료

- Base 최신 `main` 기준 커밋과 대상 기준 커밋을 고정했다.
- 마이그레이션 Issue #4와 전용 브랜치를 만들었다.
- 루트 시작 지점, 프로젝트 허브와 원격 구조 감사 보고서를 설치했다.
- 기존 활성 본책을 삭제·이동하지 않았다.

## 현재 진행

- Design Document Registry.
- Skill Registry·Learning Log·분야 진입 스킬.
- Development Gates·Update Matrix·AI Workflow.
- README·AGENTS·Base 버전 최신화.
- GitHub Governance 정적 검사.

## 미완료·미검증

- Windows 작업본과 원격의 차이.
- Godot 프로젝트·코드·씬·데이터·테스트.
- 승인 이미지·실제 캡처·자산 Manifest.
- PDF·DOCX·다이어그램 생성과 전 페이지 렌더.
- GitHub Actions 실제 성공과 Branch protection Required Check.
- 절초 기세·상단 HUD UX의 사용자 승인과 제품 본책 동기화.

## 금지

- 기존 `docs` 본책을 Registry·PDF·보존 대조 전에 제거하지 않는다.
- `[보류]` 기능을 구현하지 않는다.
- 로컬 작업본을 확인하지 않고 원격이 전체 프로젝트라고 단정하지 않는다.
- 구조 설치를 Godot 구현 완료로 보고하지 않는다.
- 프로젝트 고유 수치·세계관·경로를 Base 공용 규칙으로 자동 승격하지 않는다.
- 검증·발행 스킬을 해당 게이트 전에 호출하지 않는다.

## 다음 작업의 중단 기준

다음 중 하나가 발생하면 변경을 확대하지 않고 위험을 기록한다.

- 로컬 작업본에 원격과 충돌하는 최신 사용자 변경이 존재함.
- 기존 문서·코드·외부 링크를 새 경로로 안전하게 수정할 수 없음.
- PDF 생성 도구·폰트·입력 파일이 없어 정상 발행을 검증할 수 없음.
- 기존 책임 원본의 고유 결정·표·예외·보류를 승계했는지 확인할 수 없음.
- 사용자 승인 범위를 넘어서는 삭제·대규모 이름 변경이 필요함.
