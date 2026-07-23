# 십보강호 운영 로드맵

> 제품 구현 순서는 `docs/04_ROADMAP.md`가 책임진다.

## M0 — PR #7 기준선·보존

- [x] 구현 기준 PR #7 확인.
- [x] 기준 SHA `147a031c75e96bff170d7f99016beb9e85b12066` 고정.
- [x] exact SHA에서 `agent/pr7-canonical-skill-refresh` 분기.
- [x] force push·reset·rebase 금지.
- [ ] 최종 compare에서 제품 보호 경로 변경 0건 확인.
- [ ] 사용자 로컬 미커밋 파일 확인.

현재 판정: `REMOTE_BASELINE_FROZEN / LOCAL_UNVERIFIED`.

## M1 — Base·Skill 최신화

- [x] Base `41a20584dd2ee51d917e5c9d7cab6838e1ceba7e` 적용.
- [x] 이전 기준 이후 6개 커밋·43개 파일 재감사.
- [x] Base 활성 Skill 25개 route.
- [x] 프로젝트 고유 Skill 4개 유지.
- [x] 로컬 Skill의 진행 상태 복제를 제거.
- [x] Registry 전체 기본 로드 금지 유지.
- [ ] 최신 Skill·Schema·Governance Actions 통과.

현재 판정: `APPLIED_IN_REFRESH_BRANCH / CHECKS_PENDING`.

## M2 — 활성 정본 재작성

- [x] 전투 규칙을 Issue #11·#13 현행 계약으로 통합.
- [x] 밀착·합·순차 방어·필중·중단·강건·절초·AI·재시작 반영.
- [x] T0/T1/T2/전체판 범위 재분리.
- [x] 날짜별 보정 절 제거.
- [x] 프로젝트 코어 상태를 `CORE_REVIEW_PENDING`으로 분리.
- [x] QA 체크리스트를 현재 반례 기준으로 재구성.
- [ ] Design Registry required section과 최종 본문 대조.
- [ ] stale token 전체 검사 통과.

현재 판정: `CANON_REWRITTEN / VALIDATION_PENDING`.

## M3 — Governance 강화

- [x] board schema 16 기대값.
- [x] Base SHA·25 Skill 집합의 단일 freshness 설정.
- [x] 운영·Skill 검사기의 13개 하드코딩 제거.
- [x] stale 문장+하단 최신 보정 반례.
- [x] board schema drift 반례.
- [x] Base SHA drift·Skill route 누락/중복 반례.
- [x] Python cache ignore와 추적 캐시 3개 제거.
- [ ] `python -m unittest tests.test_project_governance` 통과.
- [ ] Documentation Governance Actions 통과.
- [ ] Card Component Contract Actions 통과.

현재 판정: `IMPLEMENTED / NOT_YET_EXECUTED`.

## M4 — GitHub 통합

1. 정합화 Draft PR을 `agent/t0-combat-poc-board` 대상으로 생성한다.
2. 기준 SHA·보호 경로·STEP 14 증거 경계를 PR 본문에 기록한다.
3. 최신 Actions 성공과 head SHA 불변을 확인한다.
4. 정합화 PR을 #7에 통합한다.
5. PR #7 제목·본문을 STEP 0~13·Issue #13 현행 상태로 갱신한다.
6. #7의 base를 `main`으로 전환할 수 있는 ancestry를 확인한다.
7. `main` 대비 전체 diff·Actions를 재검토한다.
8. 구형 PR은 고유 정보 보존 확인 뒤 superseded로 종료한다.

현재 판정: `NOT_STARTED`.

## M5 — 프로젝트 코어 PLAN

정합화 통합 뒤 다음 순서로 진행한다.

```text
핵심 컨셉 후보
→ 제약·조건
→ 뾰족한 재미
→ WHY/HOW/WHAT 정렬
→ 현재 POC 증거 대조
→ 기획 재조정
→ SWOT / VRIO
→ 적대적 검토
→ 사용자 승인으로 프로젝트 코어 확정
```

- [ ] 기존 구현에서 코어 후보를 읽기 전용 판정.
- [ ] 핵심 컨셉·뾰족한 재미 후보 비교.
- [ ] 제거·보류·강화 요소 결정.
- [ ] core loop와 보상·진척 정의.
- [ ] SWOT·VRIO·제작 현실 검토.
- [ ] 사용자 `CORE_CONFIRMED` 승인.

현재 판정: `NOT_STARTED`.

## M6 — STEP 14 실제 사용자 플레이

- [x] 개발자 기계 5시나리오 기록.
- [ ] 실제 사용자 규칙 이해.
- [ ] 실제 키보드·보조기기 사용성.
- [ ] 주관적 음향·모션 읽기성.
- [ ] 계획 수정·재도전 행동.
- [ ] 외부 POC 표본.
- [ ] Release 목표 장치 성능 위험.

현재 판정: `MECHANICAL_RECORDED / HUMAN_NOT_RUN`.

## M7 — T1 진입 판단

프로젝트 코어 승인과 STEP 14 사람 증거를 모두 요구한다.

- 통과: 최소 세로 슬라이스 제작.
- 부분 통과: 필요한 최소 규칙·UI만 재조정 후 재시험.
- 실패: 콘텐츠 확장을 중단하고 코어·3/3/4·정보 표현을 재검토.

## 독립 상태 원칙

파일 존재·Actions 성공·Godot 런타임·Windows 기술 증거·사람 검수·접근성 사용자 증거·Release 성능·Branch protection은 서로 독립이다.
