# 십보강호 개발 게이트

## 상태 축

```yaml
lifecycle: ACTIVE | HOLD | BACKUP | REMOVAL_CANDIDATE
approval: UNCONFIRMED | CONFIRMED | REJECTED
implementation: NOT_STARTED | IN_PROGRESS | IMPLEMENTED
verification: NOT_RUN | PASSED | FAILED | PARTIAL
publication: NOT_BUILT | STALE | CURRENT | FAILED
```

파일 존재, Actions 성공, Godot 런타임, 사람 검수, 접근성·성능, Branch protection은 독립 증거다.

## 작업 게이트

### G0 Intake·Context

사용자 요청·저장소·브랜치·기준 SHA, Work Mode, 책임 원본, 실제 파일, 보호 대상, 도구·권한을 확인한다.

### G1 Ready

- 주 책임 분야 하나와 영향 분야
- 범위·제외·보호 대상
- 필요한 Skill·Skill Mode·도구·권한
- 완료·검증·중단·롤백
- 정본·발행·접근성·성능 영향

### G2 Plan·Approval

- L2 이상은 저장소 조사 기반 Plan
- 다중 의존성은 결과·파일·의존성·게이트·롤백으로 분해
- 삭제·이동·통합은 고유 정보·참조·복구와 사용자 승인을 확인

### G3 Build

- 승인 파일만 작은 검증 단위로 변경
- 사용자 변경·저장·공개 인터페이스 보호
- 보류 기능 구현 금지
- 정본·경로·ID·Schema 변경은 소비자·테스트·Workflow 동기화

### G4 Review

```text
contract-check
→ reference-freshness
→ syntax·static
→ automated tests
→ runtime·render·build
→ 적용 시 accessibility-review
→ 적용 시 performance-profile
→ normal·failure·edge·regression
→ evidence-report
```

실행하지 않은 검증은 `NOT_RUN` 또는 `UNVERIFIED`다.

### G5 Documentation·Publication

- 책임 원본·Registry·Schema·Legacy Alias·Update Matrix
- Active Context·Roadmap·필요 시 Handoff
- 현재 등록 문서·Skill Registry는 `source_only`
- PDF가 필요한 마일스톤에서 생성기·폰트·렌더 검증과 함께 필요한 문서만 정책 승격
- Changelog·Decision Log·Learning Log

### G6 Integration

- 승인 범위 전부 반영
- 정적·자동·런타임·사용자 검증 분리
- 미검증·위험·롤백 명확
- 새 작업자가 저장소만으로 재개 가능
- Work Mode·Skill·Skill Mode 실행 보고

## Prototype Greenlight

- [x] Godot 프로젝트·씬·데이터·테스트
- [x] 10칸·3번/8번
- [x] `3수 → 3수 → 4수`
- [x] 기초 행동 8종·대상 지정
- [x] `대응 → 속공 → 이동 → 일반 공격`
- [x] 사용자 Windows STEP 0~10·대상 지정
- [x] PR #7 Card Component Contract run #399
- [ ] RESPONSE·RESOURCE PREVIEW 10.6 사용자 확인
- [ ] STEP 11 피격 중단·집중·강건
- [ ] STEP 12 AI
- [ ] STEP 13 종료·재시작
- [ ] STEP 14 POC 플레이테스트

## Vertical Slice Greenlight

- 1~5전 예선 결승 완주
- 절초 보유·미보유 정상 경로
- 상대 정보→제약→전투→성과·행운→수련 연결
- 대표 세력 목표 품질·제작 파이프라인
- 외부 플레이 증거
- 접근성 장벽·대체 경로
- 목표 플랫폼 성능 예산

## 현재 판정

| 영역 | 상태 |
|---|---|
| Base 70파일 감사 | PASSED |
| Base 공유 13·로컬 4 Skill | PASSED |
| Design·Skill Registry Schema | PASSED |
| 정본 최신성·Skill 무결성·회귀 | PASSED |
| PR #5 Governance run #371 | PASSED |
| PR #7 Governance #370·Card #399 | PASSED |
| Branch protection | NOT_RUN |
| 발행 파이프라인 | NOT_INSTALLED_BY_DESIGN |
| 전투 POC 구현 | IMPLEMENTED |
| 전투 POC 런타임 | PARTIAL |
| 접근성·성능·플레이테스트 | NOT_RUN |
