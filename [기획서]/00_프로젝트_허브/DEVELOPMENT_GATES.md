# 십보강호 개발 게이트

## 상태 축

상태 하나에 모든 의미를 섞지 않는다.

```yaml
lifecycle_status: ACTIVE | HOLD | BACKUP | REMOVAL_CANDIDATE
approval_status: UNCONFIRMED | CONFIRMED | REJECTED
implementation_status: NOT_STARTED | IN_PROGRESS | IMPLEMENTED
verification_status: NOT_RUN | PASSED | FAILED | PARTIAL
publication_status: NOT_BUILT | STALE | CURRENT | FAILED
```

추가 운영 상태:

- `READY`: 입력·범위·도구·권한·완료 기준 준비
- `BLOCKED`: 선행 조건·도구·권한·결정 부족
- `MIGRATION_PENDING`: 기존 구조 보존 상태의 이관·발행 대기
- `UNVERIFIED`: 파일은 있으나 요구한 실행 증거 없음

## 작업 게이트

```text
Intake·Context
→ Definition of Ready
→ Planning·Approval·Sequencing
→ Implementation
→ Verification
→ Documentation·Publication
→ Integration·Completion
→ Context·Learning
```

### G0 Intake·Context

- 사용자 요청 또는 Issue
- 저장소·브랜치·기준 SHA
- 현재 단계·Work Mode
- 책임 원본·실제 파일
- 보호 경로·결정·자산
- 로컬·원격·도구·권한 상태

현재: `VERIFIED`

### G1 Definition of Ready

- 주 책임 분야 하나와 영향 분야
- 범위·제외·보호 대상
- 필요한 문서·Skill·Skill Mode·도구·권한
- 사용자·플레이어 가치
- 완료·검증·중단·롤백
- 정본 변경 소비자와 발행 영향
- 접근성·성능·플레이테스트 영향

현재 Base 동기화: `READY`

### G2 Planning·Approval·Sequencing

- L2 이상은 저장소 조사 기반 Plan
- 사용자 결정이 필요한 구조·경험·워크플로는 마지막 확인
- 다중 의존성은 결과·의존성·게이트·롤백으로 분해
- 기존 프로젝트는 audit와 처리표
- 삭제·이동·통합은 명시 승인

현재 Base 동기화: 사용자 직접 요청으로 운영 파일 갱신 승인. 제품 본책 삭제·대규모 이동은 승인 범위 밖.

### G3 Implementation

- 승인 파일만 수정
- 가장 작은 검증 가능한 변경
- 사용자 변경·저장·공개 인터페이스 보호
- 보류 기능 구현 금지
- 기능 추가와 대규모 리팩터링 분리
- 정본·경로·ID·Schema 변경 시 소비자·테스트·파생본 동기화

현재: Base 운영 동기화 `IN_PROGRESS`, 전투 POC `IMPLEMENTED`.

### G4 Verification

```text
contract-check
→ reference-freshness
→ format·syntax·static
→ automated tests
→ runtime·render·build
→ accessibility-review when applicable
→ performance-profile when applicable
→ normal·failure·edge·counterexample
→ save·load·compatibility
→ adjacent regression
→ evidence-report
```

실행하지 않은 검증은 `NOT_RUN` 또는 `UNVERIFIED`다.

### G5 Documentation·Publication

- 책임 원본·Registry 동기화
- Active Context·Roadmap·Documentation Map 갱신
- Update Matrix 영향 확인
- Changelog·Decision Log·Learning Log
- Legacy Alias·정본 최신성
- 발행 정책에 따른 PDF·Manifest
- 필요 시 Handoff 스냅샷

### G6 Integration·Completion

- 승인 범위 전부 반영
- Required Checks와 리뷰 상태 확인
- 자동·수동·사용자·접근성·성능 검증 분리
- 미검증·보류·제거 후보·위험·롤백 명확
- 새 작업자가 저장소만으로 재개 가능
- Work Mode·Skill·Skill Mode의 이유와 결과 보고

## 제품 마일스톤

```text
Concept
→ Prototype
→ Graybox
→ First Playable
→ Vertical Slice
→ Production
→ Alpha
→ Feature Complete
→ Content Complete
→ Beta
→ Release Candidate
```

현재 제품 상태: `Prototype / PARTIALLY VERIFIED`.

## Prototype Greenlight

- [x] Godot 프로젝트·씬·데이터·테스트 기준선
- [x] 10칸 전장과 3번/8번 시작 위치
- [x] `3수 → 3수 → 4수` 행동 배치
- [x] 카드 8종과 방향·목적지 선택
- [x] `대응 → 속공 → 이동 → 일반 공격` 판정
- [x] 사용자 Windows에서 STEP 0~10·대상 지정 확인
- [ ] RESPONSE 10.6 사용자 런타임 확인
- [ ] STEP 11 피격 중단·집중·강건
- [ ] STEP 12 단순 AI
- [ ] STEP 13 종료·재시작
- [ ] STEP 14 POC 플레이테스트

## Vertical Slice Greenlight

- 1~5전 예선 결승 완주
- 절초 보유·미보유 양쪽 정상 경로
- 상대 정보→제약→전투→성과·행운→수련 연결
- 대표 세력 목표 품질·자산·제작 파이프라인
- 외부 플레이 증거
- 접근성 장벽과 대체 경로
- 목표 플랫폼 성능 예산

## 현재 게이트 판정

| 영역 | 상태 | 근거 |
|---|---|---|
| Base 최신 main 감사 | PASSED | `BASE_MAIN_SYNC_AUDIT.md` |
| Work Mode·Skill 라우팅 | IN_PROGRESS | 운영 문서·Registry 갱신 중 |
| Design Registry | PASSED_WITH_PUBLICATION_PENDING | 책임 원본 등록, 발행 미완료 |
| Skill Registry | IN_PROGRESS | 자동 라우팅·Alias·무결성 갱신 중 |
| 정본 최신성 | IN_PROGRESS | 검사기·Workflow 추가 중 |
| GitHub 정적 검사 | PARTIAL | 기존 Actions 성공, 최신 동기화 재실행 대기 |
| Required Check 강제 | NOT_RUN | 사용자 승인·권한 확인 없음 |
| PDF 발행 | MIGRATION_PENDING | 도구·렌더·시각 검수 전 |
| 전투 POC 구현 | IMPLEMENTED | PR #7 |
| 전투 POC 런타임 | PARTIAL | STEP 0~10 확인, RESPONSE 10.6 대기 |
| 접근성 | NOT_RUN | 실제 사용자 장벽 검수 전 |
| 성능 | NOT_RUN | 목표 플랫폼 프로파일 전 |
| 플레이테스트 | NOT_RUN | STEP 14 전 |
