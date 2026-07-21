# 십보강호 인수인계

> 현재 상태의 기본 원본은 `ACTIVE_CONTEXT.md`다. 이 문서는 Base 통합·최적화와 전투 POC STEP 10.6 이후의 경계 스냅샷이다.

## 첫 행동

1. 루트 `AGENTS.md`를 읽는다.
2. `ACTIVE_CONTEXT.md`와 `DOCUMENTATION_MAP.md`를 읽는다.
3. Map이 지시한 책임 원본과 실제 `data/`, `scenes/`, `src/`, `tests/`를 확인한다.
4. `SKILL_REGISTRY.json` trigger로 Work Mode·최소 Skill·Skill Mode를 자동 선택한다.
5. 구현 작업이면 PR #7의 최신 head와 Actions를 확인한다.

## 완료

- Base를 `ee265576da7f67d3278f8099dd97d4e714ef0651`로 갱신했다.
- 이전 기준 이후 155개 커밋·70개 변경 파일을 전수 판정했다.
- Work Mode·자동 Skill·Skill Mode·실행 보고를 적용했다.
- Base 공유 Skill 13개를 유지하고 로컬 Skill을 고유 4개로 축소했다.
- 제거한 로컬 Skill은 Base Skill·Legacy Alias로 승계했다.
- 문서·Skill Registry를 실행 가능한 `source_only`로 정렬했다.
- Skill Map·가짜 Manifest·중복 템플릿·checker·test를 통합·제거했다.
- Design Registry와 Schema 정책 충돌을 수정했다.
- 삭제 경로·stale 전투 표현·가짜 발행 상태의 재등장을 차단했다.
- PR #5 Documentation Governance run #371이 성공했다.
- PR #9로 최적화 운영체계를 PR #7에 동기화했다.
- PR #7 Documentation Governance run #370과 Card Component Contract run #399가 성공했다.
- 전투 POC STEP 0~10·TARGETING 10.5·RESPONSE/RESOURCE PREVIEW 10.6이 구현됐다.
- 사용자 Windows에서 STEP 0~10·행동 배치·대상 지정이 확인됐다.

## 확인 대기

- 사용자 작업본의 Fetch/Pull
- RESPONSE 10.6 막기·회피·태세 실제 판정
- RESOURCE PREVIEW 10.6 배치 즉시 자원 표시
- 최신 Windows 통합 검증 보고서

## 미완료·미검증

- 사용자 로컬 미커밋 파일·원격 차이
- PDF 발행 파이프라인과 전 페이지 시각 검수
- 접근성 사용자 검수
- 목표 플랫폼 성능 프로파일
- Branch protection Required Check 강제
- STEP 11 이후 전투 기능과 POC 플레이테스트

## 보호 범위

- 10칸·3수/3수/4수·8개 기초 행동·절초 기세 5칸
- 승인 UI·배경·카드 방향과 Godot 구현
- 기존 `docs/01~11`, 백업·보류·Plan·PR·Git 이력
- 프로젝트 고유 수치·세계관·경로
- 사용자 로컬 미커밋 변경
- 실행하지 않은 검증의 미검증 상태

## 금지

- Base 공용 Skill을 로컬에 다시 중복 복제
- 발행 생성기 없이 PDF·Manifest CURRENT 선언
- 보존 대조·사용자 승인 없는 제품 본책·자산 삭제
- `[보류]` 기능 구현
- 정적 Actions만으로 Godot·접근성·성능·Required Check 완료 주장
- 프로젝트 고유 값을 Base 공용 규칙으로 자동 승격

## 다음 작업

1. `agent/t0-combat-poc-board` Fetch/Pull
2. Godot F5로 RESPONSE·RESOURCE PREVIEW 10.6 확인
3. 결과를 PR #7·Active Context에 기록
4. STEP 11 피격 중단·집중·강건 작업 계약

## 중단 기준

- 원격과 충돌하는 사용자 로컬 변경
- 고유 정보·참조·복구를 확인할 수 없는 삭제·이동 요구
- 생성기·폰트·Manifest·렌더 없이 발행 정책 승격 요구
- 사용자 승인 범위를 넘는 제품 규칙·자산 변경
- Actions 또는 Godot 실패 원인을 확인하지 않은 변경 확대
