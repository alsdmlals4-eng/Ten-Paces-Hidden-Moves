# 십보강호 운영 로드맵

> 제품 구현 순서의 책임 원본은 `../../../docs/04_ROADMAP.md`다.

## M0 기준선·보존 감사

- [x] 최초 대상·Base 기준 SHA 고정
- [x] 기존 11개 본책·백업·보류·Plan 보존
- [x] 최신 Base `ee265576...` 고정
- [x] 155개 커밋·70개 변경 파일 전수 처리표
- [ ] 사용자 로컬 미커밋 파일 확인

판정: `PARTIAL`

## M1 최신 Base 운영 계약

- [x] Work Mode `PLAN / BUILD / REVIEW`
- [x] Skill·Skill Mode 자동 라우팅 계약
- [x] L1 이상 실행 보고 계약
- [x] `audit → reconcile-legacy → migrate → verify`
- [x] 정책 기반 발행·독립 상태 축
- [x] 접근성·성능 조건부 검증
- [ ] 최종 정적 검사

판정: `IN_PROGRESS`

## M2 책임 원본·Skill Registry

- [x] 11개 Markdown 책임 원본 Registry
- [x] 프로젝트 선택 분야 6개와 진입 Skill
- [x] Learning Log
- [ ] 자동 trigger 선택 정책
- [ ] Base 통합 Skill·mode 연결
- [ ] Legacy Skill Alias
- [ ] Skill 패키지 무결성 검사

판정: `IN_PROGRESS`

## M3 정본 최신성·GitHub Governance

- [x] Documentation Governance 검사·Workflow
- [x] 기존 Actions 성공 이력
- [ ] 정본·경로·ID·Schema 최신성 검사
- [ ] 현행 `2수·두 행동·7개 기초 행동` stale 표현 차단
- [ ] PR #5·#7 체크리스트 최신화
- [ ] 최종 Actions 성공
- [ ] Required Check 강제 상태 확인

판정: `IN_PROGRESS_WITHOUT_ENFORCEMENT`

## M4 정책 기반 발행

- [ ] 문서별 발행 정책 확인
- [ ] 폰트·LibreOffice·Poppler·Mermaid 실행
- [ ] 정책 대상 PDF·Manifest 생성
- [ ] 전 페이지 자동 렌더·사용자 시각 검수
- [ ] Skill Map 발행

판정: `MIGRATION_PENDING`

## M5 전투 POC

- [x] STEP 0~10
- [x] TARGETING 10.5
- [x] Windows에서 STEP 0~10·대상 지정 확인
- [ ] RESPONSE 10.6 사용자 확인
- [ ] RESOURCE PREVIEW 10.6 사용자 확인

판정: `PROTOTYPE_PARTIALLY_VERIFIED`

## M6 다음 제품 단계

1. RESPONSE 10.6 확인
2. STEP 11 피격 중단·집중·강건
3. STEP 12 단순 AI
4. STEP 13 전투 종료·재시작
5. STEP 14 POC 플레이테스트
6. T1 5전 데모

## M7 Cleanup·Enforcement

- [ ] 고유 정보·참조·파생본·복구 확인
- [ ] 사용자 삭제 승인
- [ ] 승인 항목만 UPDATE·MERGE·STUB·ARCHIVE·DELETE
- [ ] reference-freshness·회귀·콜드 스타트 재검증

판정: `NOT_READY`

파일 존재, 정적 검사, Actions 성공, 실제 런타임, 사용자 시각 검수, 접근성·성능 검증, Required Check 강제는 독립 상태다.
