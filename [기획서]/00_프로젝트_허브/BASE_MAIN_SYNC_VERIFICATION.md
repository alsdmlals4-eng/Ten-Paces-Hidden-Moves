# Base main 통합·최적화 최종 검증

## 기준

- Base: `alsdmlals4-eng/Base@ee265576da7f67d3278f8099dd97d4e714ef0651`
- 이전 프로젝트 Base: `eb40b912e5f5a0e4d369105a4f0a770e0a6179a9`
- Base 변경 집합: 155개 커밋·70개 파일
- 파일별 판정: `BASE_MAIN_SYNC_AUDIT.md`
- 최적화 비교: `de9ad6ed482c850322839d209dcf3a63faf01db3` → `a26e212d00cf7e948c26053f6368aa7b2cca1b73`
- 운영 PR: #5, head `a26e212d…`
- 전투 PR: #7, head `d163da43…`, base `a26e212d…`
- 동기화 PR: #9 merged, merge commit `d163da4344bae5762bcf3ef7aaf6d2685b6d81dc`

## Work Mode·Skill

```yaml
work_mode: PLAN → BUILD → REVIEW
primary_skill: managing-game-project-operating-system
skill_modes: [audit, reconcile-legacy, migrate, verify]
followup_skills:
  - evolving-project-discipline-skills
  - auditing-canonical-reference-freshness
  - reviewing-and-validating-project-changes
selection: user-directed
```

## 최적화 변경 집합

`de9ad6e…→a26e212d…` 비교:

- 변경 파일 40개
- 수정 28개
- 추가 2개
- 제거 10개
- 전투 코드·데이터·씬·자산·제품 본책 변경 0개

| 영역 | 이전 | 현재 | 기능 승계 |
|---|---:|---:|---|
| Base 공유 Skill | 13 | 13 | 그대로 유지·고유 route 검사 |
| 프로젝트 로컬 Skill | 6 | 4 | Base intake·context·OS·validation·freshness |
| 운영 템플릿 | 7 | 5 | 컨셉·근거 통합, freshness→change validation |
| Governance 회귀 테스트 | 2 | 1 | 통합 unittest가 세 checker와 실패 반례 실행 |
| 운영 checker | 4 | 3 | 구형 중복 checker 제거 |
| Skill Map 파생본·Manifest | 2 | 0 | Registry 직접 읽기·source_only |
| 기본 콜드 스타트 | 다수 운영 문서 연쇄 읽기 | AGENTS→Context→Map→정본→실제 파일 | Map의 조건부 라우팅 |

## 기능 보존

### 공용 기능

- [x] Base 공유 Skill 13개가 `shared_skill_routes`에 모두 존재
- [x] route 값 13개가 중복되지 않음
- [x] Work Mode·trigger·do_not_use_when·execution-report 유지
- [x] 기존 프로젝트 audit·reconciliation·verify 유지
- [x] 문서·Context·Vertical Slice·외부 AI·아트·Base 제안 route 유지

### 프로젝트 고유 기능

- [x] 전투 디자인 Skill
- [x] 전투 UX·접근성 Skill
- [x] Godot 구현 Skill
- [x] 십보강호 QA Skill
- [x] 4개 SKILL.md·trigger·mode·Learning Log·entrypoint 검사

### 삭제 항목 승계

- [x] `project-operations-and-handoff` → Base intake + context/handoff
- [x] `project-health-review` → Base operating-system + validation + freshness
- [x] 두 ID 모두 Legacy Alias 등록
- [x] 제거 경로 재등장을 freshness checker가 실패 처리
- [x] 컨셉·벤치마크 정보는 통합 템플릿에 승계
- [x] freshness 보고 항목은 변경 검증 템플릿에 승계
- [x] 분리 회귀 테스트는 통합 unittest에 승계
- [x] Git 이력으로 삭제 파일 복구 가능

## 발행 계약 적대적 검토

발견:

1. Project Skill Map PDF 생성기가 없는데 PDF·Manifest를 기본 산출물처럼 선언함.
2. Design Registry가 PDF·Manifest·`tools/build_design_documents.py`를 선언했지만 생성기가 없음.
3. Registry를 `source_only`로 변경한 뒤에도 로컬 JSON Schema가 `always_sync`를 강제함.

개선:

- [x] Project Skill Map·Manifest 제거
- [x] 11개 Design 문서와 Skill Registry를 실행 가능한 `source_only`로 정렬
- [x] output·asset·Manifest·generator null, diagram none으로 정렬
- [x] Design Registry Schema를 세 정책 조건부 계약으로 수정
- [x] `source_only` 파생 필드 null을 Schema·checker 양쪽에서 검증
- [x] 발행 정책 승격 시 generator 파일 존재 검사
- [x] PDF가 필요한 마일스톤에서 생성기·폰트·Manifest·렌더·사용자 검수를 함께 설치

## 실패-개선 루프

| Run | 결과 | 발견 | 조치 |
|---:|---|---|---|
| #356 | FAIL | README Base 버전 링크 누락 | 링크 복구 |
| #357 | FAIL | 프로젝트 허브 Base 버전 경로 누락 | 경로 추가 |
| #358 | FAIL | 루트 START_HERE Skill Registry 경로 누락 | 기준 항목 추가 |
| #359 | FAIL | AGENTS Skill Registry 경로 누락 | 라우팅 경로 추가 |
| #360 | PASS | Entry Point·Registry·Skill 구조 통과 | 수동 적대 검토로 전환 |
| 수동 검토 | FAIL 발견 | Design Registry와 Schema 정책 충돌 | Schema·checker 수정 |
| #362 | PASS | Schema·Registry·generator 계약 통과 | 상태·이력 갱신 |
| #368 | PASS | PR #5 최종 운영 구조·회귀 통과 | PR #7 동기화 |
| #370 | PASS | PR #7 최적화 Governance 통과 | 전투 계약 확인 |
| Card #399 | PASS | 카드·전장·3/3/4·대상·대응·자원 유지 | 기능 손실 없음 |

## 자동 검증

PR #5 run #368:

- [x] Python compile
- [x] project operating-system structure
- [x] Design·Skill Registry Schema 계약
- [x] source_only shape·generator 존재 조건
- [x] canonical reference freshness
- [x] forbidden active paths
- [x] project Skill package integrity
- [x] 통합 Governance unittest와 stale-token 실패 반례

PR #7:

- [x] Documentation Governance run #370
- [x] Card Component Contract run #399
- [x] mergeable `true`
- [x] base `a26e212d…`
- [x] head `d163da43…`

## 보존 대조

- [x] `docs/01~11` 삭제·내용 변경 없음
- [x] 백업·보류·Plan 삭제 없음
- [x] 전투 코드·데이터·씬·테스트 덮어쓰기 없음
- [x] 승인 이미지·배경·카드 자산 제거 없음
- [x] 10칸·3/3/4·8개 기초 행동·절초 5칸 유지
- [x] STEP 0~10.6 구현 유지
- [x] 사용자 확인·미확인 상태 유지
- [x] Branch protection 변경 없음

## 판정

`PASS_WITH_UNVERIFIED_RUNTIME_AND_RELEASE_GATES`

Base 공용 기능은 13개 route로 유지됐고 프로젝트 고유 기능은 4개 Skill로 압축됐다. 삭제 항목은 Base Skill·통합 템플릿·Legacy Alias·Git 이력·자동 재등장 차단으로 승계됐다. 운영 Governance와 전투 계약 Actions가 모두 성공했으며 PR #7은 mergeable 상태다.

## 미검증

- 사용자 Windows 로컬 미커밋 파일·원격 차이
- RESPONSE·RESOURCE PREVIEW 10.6 최신 Godot 파싱·포인터·판정·HUD
- PDF 발행 파이프라인·전 페이지 시각 검수
- 접근성 실제 사용자 검수
- 목표 플랫폼 성능 프로파일
- STEP 14 외부 POC 플레이테스트
- Branch protection Required Check 강제
