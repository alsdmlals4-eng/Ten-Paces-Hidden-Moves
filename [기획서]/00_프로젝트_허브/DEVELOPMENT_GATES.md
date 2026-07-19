# 십보강호 개발 게이트

## 상태 언어

- `NOT_STARTED`: 시작 전.
- `READY`: 입력·범위·도구·권한·완료 기준이 준비됨.
- `IN_PROGRESS`: 승인 범위 실행 중.
- `BLOCKED`: 선행 조건·도구·권한·결정 부족.
- `MIGRATION_PENDING`: 기존 구조를 보존한 채 새 계약으로 이관·발행 대기.
- `IMPLEMENTED_UNVERIFIED`: 파일은 있으나 실제 실행 증거 없음.
- `VERIFIED`: 정의된 검증을 통과함.
- `HOLD`: 재개 승인 전 범위 제외.
- `REMOVAL_CANDIDATE`: 삭제 조건 검토 중.

## 작업 게이트

```text
Intake·Context
→ Definition of Ready
→ Planning·Approval
→ Implementation
→ Verification
→ Documentation
→ Integration·Completion
```

### G0 — Intake·Context

필수:

- 사용자 요청 또는 GitHub Issue.
- 대상 저장소·브랜치·기준 커밋.
- 현재 단계와 책임 원본.
- 보호 경로·결정·자산.
- 로컬·원격·도구·권한 상태.

현재 마이그레이션: `VERIFIED` — Issue #4와 기준 SHA가 존재한다.

### G1 — Definition of Ready

필수:

- 주 책임 분야 하나와 영향 분야.
- 범위·제외 범위.
- 필요한 본책·스킬·실제 파일.
- 사용자·플레이어 가치.
- 완료 기준·검증·중단 기준.
- 미확정 값의 처리.

현재 마이그레이션: `READY` — 비파괴 Governance foundation과 보존 기준이 확정됐다.

### G2 — Planning·Approval

필수:

- L2 이상은 저장소 조사에 근거한 Plan.
- 구조·워크플로 변경은 사용자 결정과 마지막 확인.
- 기존 프로젝트 마이그레이션은 Audit과 처리표.
- 삭제·이동·통합은 명시 승인.

현재 마이그레이션:

- Governance foundation: 사용자 직접 요청으로 승인.
- 기존 본책 이동·삭제: 승인되지 않음.
- 절초 기세 제품 값: 별도 Draft PR 검토 상태.

### G3 — Implementation

필수:

- 승인된 파일만 수정.
- 미확정 값을 임시 기준으로 굳히지 않음.
- 보류 기능 구현 금지.
- 사용자 변경 보호.
- UI·연출이 도메인 결과를 재계산하지 않음.

현재 마이그레이션: `IN_PROGRESS`.

### G4 — Verification

검증 층:

1. JSON·YAML 문법.
2. 필수 경로·내부 링크.
3. 단일 책임 원본·Registry 중복.
4. Skill trigger·진입점·Learning Log.
5. 변경 전후 보존 대조.
6. PDF 실제 생성·전 페이지 렌더.
7. 사람 시각 검수.
8. Godot headless·Windows 실행.
9. 플레이테스트·사용자 설명 가능성.

실행하지 않은 검증은 `[미검증]`으로 남긴다.

### G5 — Documentation

필수:

- 책임 원본과 Registry 동기화.
- Active Context·Roadmap·Handoff 갱신.
- Update Matrix 영향 확인.
- Changelog·Decision Log·Learning Log 기록.
- PDF·Manifest 최신성 확인.

### G6 — Integration·Completion

필수:

- 모든 승인 범위가 반영됨.
- 필수 검증 통과.
- 미검증·보류·제거 후보·다음 작업이 명확함.
- 새 작업자가 저장소만으로 재개 가능.
- PR·Actions·Required Check 상태를 구분해 보고.

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

현재 제품 상태: `Concept / 구현 인수 준비`.

문서에 상세 구현 계획이 존재하지만 원격에서 실제 Godot 프로젝트와 테스트를 확인하지 못했으므로 Prototype 또는 First Playable로 승격하지 않는다.

## 마일스톤 Greenlight

### Prototype Greenlight

- 실제 Godot 프로젝트·테스트 기준선.
- 10칸·2수 잠금·합의 결정론적 PoC.
- AI 사전 잠금 증거.
- 기본 UI와 구조화 로그.

### Vertical Slice Greenlight

- 1~5전 예선 결승 완주.
- 절초 보유·미보유 양쪽 정상 경로.
- 상대 정보→제약→전투→성과·행운→수련 연결.
- 최소 1개 시작 세력의 목표 품질·자산·파이프라인.
- 접근성·자산 누락 폴백.

### Production Greenlight

- 시작 6세력의 반복 가능한 제작 계약.
- 데이터·저장·테스트·발행 자동화.
- 성과·상대 생성·수련 알고리즘 검증.
- 문서·코드·자산·PDF·Manifest 일치.

## 현재 게이트 판정

| 영역 | 상태 | 근거 |
|---|---|---|
| 원격 구조 감사 | VERIFIED | SOURCE_AUDIT |
| 로컬 Windows 작업본 감사 | BLOCKED | 경로 미마운트 |
| Governance foundation | IN_PROGRESS | 마이그레이션 브랜치 |
| Design Registry | IN_PROGRESS | 설치 작업 |
| Skill Registry | NOT_STARTED | 후속 파일 |
| GitHub 정적 검사 | NOT_STARTED | 도구·Workflow 설치 전 |
| PDF 발행 | MIGRATION_PENDING | 도구·폰트·입력 감사 전 |
| Godot 구현 | IMPLEMENTED_UNVERIFIED 또는 NOT_INSTALLED 판정 불가 | 원격 파일 없음·로컬 미확인 |
| 플레이테스트 | NOT_STARTED | 증거 없음 |
