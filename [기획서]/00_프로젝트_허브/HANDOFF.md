# 십보강호 인수인계

> Base 최신 main 동기화와 전투 POC STEP 10.6 구현 이후의 경계 스냅샷이다. 현재 상태의 기본 원본은 `ACTIVE_CONTEXT.md`다.

## 첫 행동

1. 루트 `START_HERE.md`와 `AGENTS.md`를 읽는다.
2. `docs/BASE_RULES_VERSION.md`, `BASE_MAIN_SYNC_AUDIT.md`, `BASE_MAIN_SYNC_VERIFICATION.md`를 확인한다.
3. `ACTIVE_CONTEXT.md`, `DOCUMENTATION_MAP.md`, `DEVELOPMENT_GATES.md`, `ROADMAP.md`를 읽는다.
4. `../DESIGN_DOCUMENT_REGISTRY.json`에서 현재 질문의 책임 원본을 찾는다.
5. `SKILL_REGISTRY.json` trigger로 Work Mode·최소 Skill·Skill Mode를 자동 선택한다.
6. 구현 작업이면 PR #7과 `data/`, `scenes/`, `src/`, `tests/`를 확인한다.

## 완료

- Base 기준을 `ee265576da7f67d3278f8099dd97d4e714ef0651`로 갱신했다.
- 이전 기준 이후 155개 커밋·70개 변경 파일을 전수 판정했다.
- Work Mode·자동 Skill·Skill Mode·실행 보고를 반영했다.
- Legacy Skill Alias와 운영·계획·검증 템플릿을 추가했다.
- 정본 최신성·Skill 패키지 무결성 검사와 Workflow를 추가했다.
- PR #5 Documentation Governance run #298이 성공했다.
- PR #8로 운영 파일 44개를 PR #7에 동기화했다.
- PR #7 Documentation Governance run #299와 Card Component Contract run #395가 성공했다.
- PR #7은 다시 mergeable 상태다.
- 전투 POC STEP 0~10·TARGETING 10.5·RESPONSE/RESOURCE PREVIEW 10.6이 구현됐다.
- 사용자 Windows에서 STEP 0~10·행동 배치·대상 지정이 확인됐다.

## 확인 대기

- 사용자 작업본의 Fetch/Pull
- RESPONSE 10.6 막기·회피·태세 판정
- RESOURCE PREVIEW 10.6 배치 즉시 자원 표시
- 최신 Windows 통합 검증 보고서

## 미완료·미검증

- 사용자 로컬 미커밋 파일·원격 차이
- PDF·DOCX·다이어그램·Manifest 발행과 전 페이지 시각 검수
- 접근성 사용자 검수
- 목표 플랫폼 성능 프로파일
- Branch protection Required Check 강제
- STEP 11 이후 전투 기능과 POC 플레이테스트

## 보호 범위

- 10칸·3수/3수/4수·8개 기초 행동·절초 기세 5칸
- 승인 UI·배경·카드 방향과 Godot 구현
- 기존 `docs/01~11`, 백업·보류·Plan·PR·Git 이력
- 프로젝트 고유 수치·세계관·경로
- 실행하지 않은 검증의 미검증 상태

## 금지

- Base 템플릿·Skill 폴더 전체 복사
- 보존 대조·사용자 승인 없는 삭제·대규모 이동
- `[보류]` 기능 구현
- 정적 Actions만으로 Godot·PDF·접근성·성능·Required Check 완료 주장
- 프로젝트 고유 값을 Base 공용 규칙으로 자동 승격

## 다음 작업

1. 사용자 작업본에서 `agent/t0-combat-poc-board` Fetch/Pull
2. Godot F5로 RESPONSE 10.6·RESOURCE PREVIEW 10.6 확인
3. 결과를 PR #7·Active Context에 기록
4. STEP 11 피격 중단·집중·강건 작업 계약

## 중단 기준

- 원격과 충돌하는 사용자 로컬 변경
- 고유 정보·참조·복구를 확인할 수 없는 삭제·이동 요구
- 생성 도구·폰트·입력 없이 PDF CURRENT 요구
- 사용자 승인 범위를 넘는 제품 규칙·자산 변경
- Actions 또는 Godot 파싱 실패 원인을 확인하지 않은 변경 확대
