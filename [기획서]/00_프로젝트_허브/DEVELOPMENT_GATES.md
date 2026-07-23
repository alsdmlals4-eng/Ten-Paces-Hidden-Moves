# 십보강호 개발 게이트

## 1. 상태 축

```yaml
lifecycle: ACTIVE | HOLD | BACKUP | REMOVAL_CANDIDATE
approval: UNCONFIRMED | CONFIRMED | REJECTED
implementation: NOT_STARTED | IN_PROGRESS | IMPLEMENTED
verification: NOT_RUN | PASS | PARTIAL | FAIL | BLOCKED
publication: NOT_BUILT | STALE | CURRENT | FAILED
```

파일 존재·Actions·Godot·Windows·사람 플레이·접근성 사용자 검수·Release 성능·Required Check 강제는 독립 증거다.

## 2. 작업 게이트

### G0 — Intake·Baseline

- 사용자 요청·저장소·브랜치·PR·Issue 확인.
- 기준 branch·기준 SHA 고정.
- Work Mode·Skill·Skill Mode 자동 선택.
- 책임 원본·실제 파일·보호 경로 확인.
- 도구·권한·로컬 미커밋 상태의 확인 가능 범위 기록.

### G1 — Ready

- 목표·사용자/플레이어 가치.
- 범위·제외·보호 대상.
- 기준 SHA·허용 변경 prefix.
- 의존성·완료·검증·중단·롤백.
- 정본·Schema·발행·접근성·성능 영향.

### G2 — Plan·Approval

- L2 이상은 저장소 조사 기반 Plan.
- 다중 의존성은 결과·입력·파일·의존성·출력·게이트·롤백으로 분해.
- 삭제·이동·통합은 고유 정보·참조·복구·사용자 승인 확인.
- 프로젝트 코어 확정은 PLAN 모드와 사용자 승인을 요구.

### G3 — Build

- exact 기준 SHA의 격리 브랜치에서 승인 파일만 변경.
- 사용자·Codex 변경과 공개 인터페이스 보호.
- 보류·미승인 기능 구현 금지.
- 정본·경로·ID·Schema 변경은 소비자·테스트·Workflow 동기화.
- UI·연출은 도메인 결과를 재계산하지 않음.

### G4 — Review

```text
contract-check
→ reference-freshness
→ format·syntax·static
→ automated tests
→ runtime·render·build
→ 적용 시 accessibility-review
→ 적용 시 performance-profile
→ normal·failure·edge·counterexample·regression
→ baseline diff
→ evidence-report
```

실행하지 않은 검증은 `NOT_RUN` 또는 `UNVERIFIED`다.

### G5 — Documentation·Publication

- 책임 원본·Registry·Schema·Legacy Alias·Update Matrix.
- Active Context·Roadmap·필요 시 Handoff.
- 활성 본문은 현재 계약만 유지.
- 과거 전문은 Git 이력·Change Log·Learning Log.
- 현재 등록 문서·Skill Registry는 `source_only`.
- PDF는 생성기·폰트·Manifest·렌더·사용자 검수와 함께 필요한 문서만 정책 승격.

### G6 — Integration

- 승인 범위 전부 반영.
- 기준 SHA 대비 보호 경로 보존.
- 정적·자동·런타임·Windows·사람 증거 분리.
- 미검증·위험·롤백 명확.
- 새 작업자가 저장소만으로 재개 가능.
- 최신 head SHA의 Actions 확인.

## 3. Canonical Refresh Gate

- [x] PR #7 기준 SHA `659c57e7ffa588ad6a6471ed9b5394985b159eaf` 고정.
- [x] 정합화 브랜치와 PR #14 분리.
- [x] docs/01~11 현행 전투 계약 재작성.
- [x] Base `41a205...`·25 Skill route.
- [x] 프로젝트 고유 Skill 4개 유지·간소화.
- [x] board schema 16·Base SHA·Skill 집합 구조 검사.
- [x] stale 보정 절·Schema·Base route 반례.
- [x] Python 캐시 제거·재발 차단.
- [x] Design Registry required section 일치.
- [x] PR #14 Governance·Card Contract 통과.
- [x] PR #14 기준 제품 보호 경로 변경 0건.
- [x] PR #14를 PR #7에 병합.
- [ ] PR #15 최신 head의 Governance·Card Contract 재확인.
- [ ] PR #15 최신 head SHA와 최종 diff 고정.

현재 판정: `MERGED_TO_PR7 / PR15_CLOSEOUT_REVIEW`.

## 4. Prototype Greenlight

### 구현·기술

- [x] Godot 프로젝트·씬·데이터·테스트.
- [x] 10칸·4/7·거리 3·밀착.
- [x] `3수 → 3수 → 4수`.
- [x] 기초 행동 8종·절초 3종.
- [x] 합·방어·회피·필중.
- [x] 중단·강건.
- [x] 공개 상태 최소 AI.
- [x] 승패·무승부·재시작.
- [x] 순차 연출·키보드·모션 감소·음향 제어 기술 증거.

### 사람 증거

- [ ] 규칙 이해.
- [ ] AI 성향 발견과 공정성 신뢰.
- [ ] 실패 이유 복기.
- [ ] 계획 수정·재도전 행동.
- [ ] 보조기기 사용자 검수.
- [ ] 주관적 음향·모션 읽기성.

현재 판정: `IMPLEMENTED / HUMAN_STEP14_NOT_RUN`.

## 5. Project Core Gate

- [x] 기존 구현의 코어 후보를 읽기 전용 판정.
- [x] 핵심 컨셉 후보와 제약 정의.
- [x] 뾰족한 재미를 플레이어 행동·감정 변화로 정의.
- [x] core loop의 행동·보상·진척 정의.
- [x] 모든 요소의 WHY/HOW/WHAT 대조.
- [x] POC 증거와 반증 대조.
- [x] 제거·보류·강화·추가 최소 실험 결정.
- [x] SWOT·VRIO.
- [x] 적대적 검토와 최소 개선.
- [x] 사용자 `CORE_CONFIRMED` 승인.

현재 판정: `CORE_CONFIRMED / PRODUCT_GATE_REPEAT_POC`.

코어 확정은 Prototype 사람 증거 또는 T1 진입을 자동 승인하지 않는다.

## 6. Vertical Slice Greenlight

프로젝트 코어와 실제 사용자 STEP 14를 모두 통과한 뒤 검토한다.

- [ ] 플레이 스타일 2개.
- [ ] 성향이 다른 상대 3명·전투 3회.
- [ ] 상대 정보→가설→전투→복기→수평 보상 연결.
- [ ] 대표 콘텐츠 품질·제작 파이프라인.
- [ ] 외부 플레이 증거.
- [ ] 접근성 장벽·대체 경로.
- [ ] 목표 플랫폼 성능 위험·예산.

현재 판정: `NOT_GRANTED / REPEAT_POC`.
