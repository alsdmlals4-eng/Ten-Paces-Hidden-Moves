# 십보강호 운영 로드맵

> 제품 구현 순서는 `docs/04_ROADMAP.md`가 책임진다.

## M0 — PR #7 기준선·보존

- [x] 구현 기준 PR #7 확인.
- [x] 기준 SHA `659c57e7ffa588ad6a6471ed9b5394985b159eaf` 고정.
- [x] PR #14 정합화 작업을 독립 브랜치에서 수행.
- [x] force push·reset·rebase 금지.
- [x] PR #14 기준 제품 보호 경로 변경 0건 확인.
- [ ] 사용자 로컬 미커밋 파일 확인.

현재 판정: `REMOTE_BASELINE_CONFIRMED / LOCAL_UNVERIFIED`.

## M1 — Base·Skill 최신화

- [x] Base `41a20584dd2ee51d917e5c9d7cab6838e1ceba7e` 적용.
- [x] 이전 기준 이후 6개 커밋·43개 파일 재감사.
- [x] Base 활성 Skill 25개 route.
- [x] 프로젝트 고유 Skill 4개 유지.
- [x] 로컬 Skill의 진행 상태 복제를 제거.
- [x] Registry 전체 기본 로드 금지 유지.
- [x] PR #14 Skill·Schema·Governance Actions 통과.
- [x] PR #14를 PR #7에 병합.

현재 판정: `MERGED_TO_PR7`.

## M2 — 활성 정본과 운영체계

- [x] 전투 규칙을 Issue #11·#13 현행 계약으로 통합.
- [x] 밀착·합·순차 방어·필중·중단·강건·절초·AI·재시작 반영.
- [x] T0/T1/T2/전체판 범위 재분리.
- [x] 날짜별 보정 절 제거.
- [x] 프로젝트 코어 PLAN과 실제 사용자 증거를 독립 상태로 분리.
- [x] QA 체크리스트를 현재 반례 기준으로 재구성.
- [x] Design Registry required section과 본문 대조.
- [x] stale token 검사와 반례 통과.

현재 판정: `CANON_CURRENT_AT_PR7_659C`.

## M3 — 프로젝트 코어 확정

- [x] 기존 구현에서 코어 후보를 읽기 전용 판정.
- [x] 핵심 컨셉·뾰족한 재미 후보 비교.
- [x] 제거·보류·강화 요소 결정.
- [x] core loop와 보상·진척 정의.
- [x] SWOT·VRIO·제작 현실 검토.
- [x] 적대적 검토와 최소 개선.
- [x] 사용자 `CORE_CONFIRMED` 승인.
- [x] 코어 확정과 T1 시작 승인을 분리.

현재 판정: `CORE_CONFIRMED / PRODUCT_GATE_REPEAT_POC`.

## M4 — PR #15 최종 마감

1. 접근 가능한 대화 결정 원장과 `UNVERIFIED_CONTEXT`를 기록한다.
2. AGENTS·START_HERE·Base 버전·Gates·Roadmap·Handoff를 현행 상태로 동기화한다.
3. 5회 적대적 검토 finding을 `MUST_FIX / SHOULD_FIX / DEFER / REJECT / UNVERIFIED`로 판정한다.
4. reference-freshness가 현재 기준 SHA·코어 상태·운영 소비자를 검사하도록 보강한다.
5. 최신 PR #15 head의 Governance·Card/Combat Contract를 확인한다.
6. 기준 SHA 대비 보호 경로 변경 0건을 재확인한다.
7. PR #7·#15 설명을 최신 계약과 검증 경계로 정렬한다.
8. 사용자용 PDF를 저장소 정본과 분리해 생성·전 페이지 검수한다.

현재 판정: `IN_PROGRESS`.

## M5 — 코어 검증 POC 반복

### 결정적 복기 최소안

```text
플레이어가 실제로 세운 가설
→ 내 확정 계획
→ 상대의 실제 계획
→ 승부를 가른 거리·합·대응·중단
→ 다음에 검토할 선택 차원
```

새 판정 규칙과 정답 추천은 추가하지 않는다.

### 읽을 수 있는 라이벌 성향

- 같은 공개 상태에서 복수의 합리적 후보.
- 라이벌별 2~3개 관찰 가능한 성향.
- seed 기반 재현 가능성.
- 미확정 슬롯·대상·절초 예약 입력 금지.
- 고정 스크립트와 근거 없는 완전 랜덤 모두 금지.

### 범위 통제

- 새 기초 행동·세력·경제·캠페인 추가 금지.
- 사람 테스트 전에 12세력·10성·10전 선제 제작 금지.
- 연구 기록은 로컬·익명·실패 비차단 최소안.

현재 판정: `PLANNED / IMPLEMENTATION_NOT_STARTED`.

## M6 — STEP 14 실제 사용자 플레이

- [x] 개발자 기계 5시나리오 기록.
- [ ] 신규 플레이어 5명 동일 빌드.
- [ ] 한 판 치명 차단 없이 완료.
- [ ] 3/3/4와 결정적 원인 설명.
- [ ] 상대 성향 발견.
- [ ] 재도전에서 계획 변경.
- [ ] 자발적 재도전 또는 구체적 다음 수.
- [ ] 실제 키보드·보조기기 사용성.
- [ ] 주관적 음향·모션 읽기성.
- [ ] Release 목표 장치 성능 위험.

현재 판정: `MECHANICAL_RECORDED / HUMAN_NOT_RUN`.

## M7 — T1 진입 판단

프로젝트 코어 승인과 STEP 14 사람 증거를 모두 요구한다.

- 통과: `T1_GREENLIGHT_REVIEW`에서 최소 세로 슬라이스 제작을 검토.
- 부분 통과: 필요한 최소 규칙·UI·AI만 재조정 후 `REPEAT_POC`.
- 실패: 콘텐츠 확장을 중단하고 코어·3/3/4·정보 표현을 재검토.

T1 후보 범위:

- 플레이 스타일 2개.
- 성향이 다른 상대 3명.
- 전투 3회.
- 전투 전 상대 정보.
- 수평 보상 1회 이상.
- 최종 라이벌 1회.

현재 판정: `NOT_GRANTED`.

## 독립 상태 원칙

파일 존재·Actions 성공·Godot 런타임·Windows 기술 증거·사람 검수·접근성 사용자 증거·Release 성능·Branch protection은 서로 독립이다.
