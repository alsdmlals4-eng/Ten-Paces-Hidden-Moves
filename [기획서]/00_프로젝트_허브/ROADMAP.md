# 십보강호 운영 로드맵

> 제품 구현 순서는 `../../../docs/04_ROADMAP.md`가 책임진다.

## M0 기준선·보존

- [x] Base `ee265576...` 고정
- [x] 155개 커밋·70개 변경 파일 감사
- [x] 본책·백업·보류·Plan·Godot 자산 보존
- [ ] 사용자 로컬 미커밋 파일 확인

판정: `PASS_REMOTE / LOCAL_UNVERIFIED`

## M1 운영 계약

- [x] `PLAN / BUILD / REVIEW`
- [x] 자동 Skill·Skill Mode 라우팅
- [x] L1 이상 실행 보고
- [x] reconciliation·정본 최신성·접근성·성능 계약

판정: `PASS`

## M2 Skill·구조 간소화

- [x] Base 공유 Skill 13개 연결
- [x] 로컬 Skill을 프로젝트 고유 4개로 축소
- [x] 제거된 로컬·Base ID Legacy Alias
- [x] Skill Registry `source_only`
- [x] 사용 불가능한 Skill Map PDF·Manifest 제거
- [x] 컨셉·근거 템플릿 통합
- [x] 정본 최신성을 변경 검증에 통합
- [x] Governance 회귀 테스트 단일화
- [x] 중복 checker 제거
- [x] Design·Skill Registry Schema 계약 검증
- [x] PR #5 Governance run #371 성공

판정: `PASS`

## M3 정본·GitHub Governance

- [x] operating-system structure
- [x] canonical reference freshness
- [x] Skill package integrity
- [x] stale 전투·Skill·발행 경로 차단
- [x] PR #9 최적화 동기화 merged
- [x] PR #7 Governance run #370 성공
- [x] PR #7 Card Component Contract run #399 성공
- [ ] Branch protection 강제 상태 확인

판정: `PASS_WITHOUT_ENFORCEMENT`

## M4 발행

- [x] 생성기 없는 현재 상태를 `source_only`로 표현
- [x] 존재하지 않는 PDF·Manifest·Skill Map 의무 제거
- [x] 정책 승격 시 generator 존재 검사
- [ ] PDF가 필요한 마일스톤에서 생성기·폰트·렌더 환경 설치
- [ ] 필요한 문서만 `milestone_sync`로 전환
- [ ] 전 페이지 자동 렌더·사용자 시각 검수

판정: `NOT_INSTALLED_BY_DESIGN`

## M5 전투 POC

- [x] STEP 0~10
- [x] TARGETING 10.5
- [x] RESPONSE·RESOURCE PREVIEW 10.6 구현
- [x] Windows에서 STEP 0~10·대상 지정 확인
- [x] 정적 Card Component Contract 유지
- [ ] RESPONSE·RESOURCE PREVIEW 10.6 사용자 확인

판정: `PROTOTYPE_PARTIALLY_VERIFIED`

## M6 다음 제품 단계

1. STEP 12 공개 상태 최소 AI 구현·MCP 런타임 확인
2. STEP 13 종료·재시작 구현·MCP 런타임 확인
3. STEP 14 기계적 5시나리오 기록, 실제 사용자/보조기기/Release 검수 대기
4. T1 5전 데모 진입 여부 결정

## M7 추가 Cleanup

고유 정보·참조·파생본·복구·사용자 승인을 확인한 항목만 추가로 통합·삭제한다. 변경 뒤 reference-freshness·회귀·콜드 스타트를 다시 실행한다.

파일 존재, Actions 성공, Godot 런타임, 사람 검수, 접근성·성능, Branch protection은 독립 상태다.
# Issue #11 상태 갱신 (2026-07-23)

절초 3종, 강건, 밀착, 구조화 연출 이벤트는 구현됐다. Focus는 제거됐다. 자동·Windows 런타임·성능·UI Automation 접근성 증거까지 마감됐고, 이후 주관적 플레이테스트는 STEP 14의 별도 품질 검수다.
