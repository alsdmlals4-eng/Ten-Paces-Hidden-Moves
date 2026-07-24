# Base schema v3 전면 마이그레이션 실행 계약

## 목적

십보강호의 승인 기획·상태·백업·보류·Plan을 잃지 않고 Base 최신 `main`의 프로젝트 운영체계로 비파괴 이관한다.

## 맥락

- Base 기준: `eb40b912e5f5a0e4d369105a4f0a770e0a6179a9`.
- 대상 기준: `0ac66389ad6b1d10019680ebf1417d423fa1466e`.
- 로컬 경로: `C:\Users\user\Documents\바이브코딩\ten-paces-hidden-moves-base-full-11-migration`.
- 로컬 접근과 Godot 상태는 현재 미검증.

## 사용자·작업자 가치

새 채팅·새 GPT·새 Codex가 저장소만 읽고 프로젝트 목적, 현재 상태, 책임 원본, 필요한 최소 스킬, 다음 작업, 보호 범위와 검증 상태를 재현한다.

## 범위

- 원격 구조·문서·Plan 감사.
- 루트 START_HERE와 `[기획서]` 허브.
- Design Document Registry·Skill Registry.
- Active Context·Handoff·Roadmap·Gates·Update Matrix.
- 인터뷰·Decision·Changelog·Learning Log.
- GitHub Governance 정적 검사 기반.
- 기존 README·AGENTS·Base 버전 최신화.

## 제외·보호

- 기존 본책·백업·보류·Plan 삭제.
- 제품 규칙·밸런스·세계관 임의 변경.
- Godot 코드·씬·Resource·저장 포맷의 추정 수정.
- PDF·Actions·플레이테스트 미실행 상태의 완료 선언.
- 프로젝트 교훈의 Base 자동 반영.

## 산출물

- Issue #4.
- `agent/base-full-11-migration` 브랜치.
- 루트·허브 운영 문서.
- schema v3 Registry와 프로젝트 스킬.
- Source Audit·Health Report.
- Governance 검사·Workflow.
- Draft PR과 검증·미검증 보고.

## 완료 기준

- 기존 활성 본책이 Registry에 한 번씩 등록된다.
- 한 질문에 책임 원본 하나가 연결된다.
- 전체 스킬 자동 로드가 금지된다.
- 새 작업자가 10분 안에 현재 상태와 다음 행동을 설명한다.
- 기존 파일을 제거하지 않고 보존 대조가 남는다.
- 정적 검사가 필수 파일·JSON·경로·금지 상태를 검사한다.
- 로컬·Godot·PDF·Actions·Required Check의 미검증이 명시된다.

## 검증

- GitHub 비교로 추가·수정·삭제 파일 확인.
- JSON 파싱과 Registry 중복·경로 확인.
- Markdown 상대 링크 확인.
- 기존 `docs`·`plans` 삭제 여부 확인.
- 콜드 스타트 질문 검토.
- 실제 실행하지 못한 검증은 별도 기록.

## 중단 기준

- 원격과 로컬의 최신 사용자 변경이 충돌함.
- 기존 고유 정보나 외부 참조를 보존할 수 없음.
- 승인 범위를 넘어서는 삭제·대규모 이동이 필요함.
- 도구·폰트·권한 부재를 우회 결과로 숨겨야만 완료 가능함.
