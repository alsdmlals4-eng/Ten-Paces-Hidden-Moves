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
- [x] Skill Registry를 `source_only`로 전환
- [x] 사용 불가능한 Skill Map PDF·Manifest 계약 제거
- [x] 컨셉·근거 템플릿 통합
- [x] 정본 최신성 양식을 변경 검증에 통합
- [x] Governance 회귀 테스트 단일화
- [x] 중복 검사기 제거
- [ ] 간소화 뒤 Actions 최종 성공

판정: `REVIEW_IN_PROGRESS`

## M3 정본·GitHub Governance

- [x] operating-system structure
- [x] canonical reference freshness
- [x] Skill package integrity
- [x] stale 전투·Skill·발행 경로 차단
- [x] PR #5·#7 스택 동기화 1차 완료
- [ ] 간소화 변경 PR #7 재동기화
- [ ] PR #5·#7 최신 Actions 성공
- [ ] Branch protection 강제 상태 확인

판정: `IN_PROGRESS_WITHOUT_ENFORCEMENT`

## M4 발행

- [x] 생성기 없는 현재 상태를 `source_only`로 정직하게 표현
- [x] 존재하지 않는 PDF·Manifest·Skill Map 의무 제거
- [ ] PDF가 필요한 마일스톤에서 생성기·폰트·렌더 환경 설치
- [ ] 필요한 문서만 `milestone_sync`로 전환
- [ ] 전 페이지 자동 렌더·사용자 시각 검수

판정: `NOT_INSTALLED_BY_DESIGN`

## M5 전투 POC

- [x] STEP 0~10
- [x] TARGETING 10.5
- [x] RESPONSE·RESOURCE PREVIEW 10.6 구현
- [x] Windows에서 STEP 0~10·대상 지정 확인
- [ ] RESPONSE·RESOURCE PREVIEW 10.6 사용자 확인

판정: `PROTOTYPE_PARTIALLY_VERIFIED`

## M6 다음 제품 단계

1. 간소화 Actions·PR 동기화 완료
2. 사용자 Fetch/Pull과 STEP 10.6 확인
3. STEP 11 피격 중단·집중·강건
4. STEP 12 AI
5. STEP 13 종료·재시작
6. STEP 14 POC 플레이테스트
7. T1 5전 데모

## M7 추가 Cleanup

고유 정보·참조·파생본·복구·사용자 승인을 확인한 항목만 추가로 통합·삭제한다. 변경 뒤 reference-freshness·회귀·콜드 스타트를 다시 실행한다.

파일 존재, Actions 성공, Godot 런타임, 사람 검수, 접근성·성능, Branch protection은 독립 상태다.
