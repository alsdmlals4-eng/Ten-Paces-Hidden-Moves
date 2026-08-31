# 태그·기획 정본 누락 감사

- Audit ID: `TEN-AUD-015`
- 날짜: 2026-08-02
- 시작 기준 main: `7082dab1c66e994ce3be1861640754f97080ed5c`
- 병합 전 최신 main: `07b3f15c50d9900321bcec3897b8d0b726bd174e`
- main 동기화 merge: `2e18396e86bb59408d809b57dc3b386020b69726`
- 작업 브랜치: `agent/2026-08-02-tag-planning-canon-audit`
- PR: `#72`
- 작업 성격: 문서 정본 유지보수와 GrillMe 승인 10건 체크포인트
- GrillMe 승인 카운트: `10/10`; PR 병합 뒤 다음 질문은 `0/10`에서 시작

## 1. 감사 목적

최신 태그·기초 행동·합·연격·전투 종료 등급·기술 작성·능력치 가격 결정이 활성 책임 문서와 planning JSON, Google Sheet에서 누락되거나 구형 표현으로 되살아나는지 확인한다.

병합 전에는 main·브랜치·PR 전체 diff·다른 열린 PR·정본 문서·planning JSON·Sheet·CI·리뷰 상태·head 이동을 다시 확인한다.

## 2. 이번 체크포인트 Decision

1. `TEN-DEC-20260802-BASIC-ACTIONS-PALM-CLASH-01`
2. `TEN-DEC-20260802-OUT-OF-RANGE-CLASH-REWARD-01`
3. `TEN-DEC-20260802-OUT-OF-RANGE-CLASH-GRADE-01`
4. `TEN-DEC-20260802-CLASH-THREAT-ATTENUATION-01`
5. `TEN-DEC-20260802-THREAT-ID-ACTION-01`
6. `TEN-DEC-20260802-MULTIHIT-COMPLETE-PARRY-01`
7. `TEN-DEC-20260802-COMPLETE-PARRY-HP-ONLY-01`
8. `TEN-DEC-20260802-BATTLE-GRADE-FIVE-METRICS-01`
9. `TEN-DEC-20260802-TECHNIQUE-AUTHORING-TAG-FIXED-STAT-01`
10. `TEN-DEC-20260802-STAT-REFERENCE-PRICE-BASE4-01`

## 3. 확정 정본 요약

### 기초 행동·태그

- 기초 행동 10종: 이동·보법·막기·회피·속공·강공·관찰·명상·준비·장풍.
- `[전조]`는 강화 없는 점유·표시 단계다.
- `[준비]`는 다음 비이동 행동에 고정 강화 효과를 주는 독립 행동이다.
- 장풍은 2수·내력1·사거리1~3·고정 피해+내공 참조이며 동일 조건 속공보다 낮은 피해다.

### 합·연격

```text
현재 순번 피해 단위끼리 합
→ 패자 현재 피해 단위 취소 / 동점 시 양측 현재 피해 단위 상쇄
→ 승자 피해 단위의 사거리·회피·방어·체력 피해 정산
→ 중단·강건 정산
→ 양측 공격이 유지되고 양쪽에 다음 피해 단위가 있으면 다음 순번 합
→ 한쪽만 남으면 잔여 단독 타격
```

- 연격의 첫 피해 단위만 합하는 규칙이 아니다.
- 현재 순번 정산 뒤 양측 체력 피해가 0이면 일반적으로 다음 순번 합이 이어진다.
- 체력 피해로 한쪽 공격이 중단되면 그쪽 후속 피해 단위가 취소된다.
- 강건이 중단을 막으면 공격이 유지되어 다음 합을 계속할 수 있다.
- 사거리 밖 합도 같은 순번 반복 구조를 사용한다.
- 여러 합 승리에도 절초기세는 공격 행동당 최대 +1이다.

### 전투 종료 등급

핵심 원자료:

- 회피 성공 횟수
- 합 승리 횟수
- 플레이어가 잃은 체력
- 전투 라운드 수
- 절초 사용 여부·횟수

연격 대 연격에서 여러 순번 합 승리가 발생하면 실제 사건 수를 기록한다. 정확한 상한·정규화·파밍 방지는 미확정이다.

기존 위협 대응30·전술 실행25·자원15·피해 관리15·공개 과제15, S85/A70/B55/C0, 동일 위협 100%→50%→0% 감쇠는 현재 활성 산식이 아니다.

### 기술 작성·능력치 가격

```text
구조·비용 → 태그 → 고정 기본치 → 주/보조 능력치 배수 → 5/9성 patch·임계
```

- 관찰·이동·회피·준비 기본 효과는 고정 전용이다.
- 그 외 연속 수치 효과는 최소 1개 능력치 참조를 가진다.
- 기준 스테이터스 4, 초기 설계 중심 4 전후, 배수 단위 0.25.
- 주·보조 같은 가격, 보조 할인 없음.
- `배수 틱 = ceil(효과 1점 가격 × 배수 × 4)`.
- 실제 값은 고정치와 모든 능력치 항 합산 뒤 한 번 내림한다.

## 4. 적대적 검토 발견 사항

### P0

없음. 제품 코드·Scene·런타임 데이터는 변경하지 않았다.

### P1 — 교정 완료

1. `docs/01~08`·문서 지도·Active Context에 구형 태세, 기초 행동 수, 후보 수, 관찰·성장 표현이 남아 있었다.
2. 현재 구현은 기초 행동 8종으로 최신 승인 10종과 차이가 있다.
3. 기존 위협 대응 점수 체계가 후속 5지표 Decision과 동시에 활성인 것처럼 보이는 Decision·JSON이 있었다.
4. 중앙 기술 점수표에 능력치 배수 가격이 없었으나 10번째 Decision으로 기준 스테이터스4 가격표를 확정했다.
5. 감사 도중 main이 PR #73 병합으로 `07b3f15...`로 이동했다. PR #74에서 PR #73의 Base v9.4.1 Adapter 7개 파일만 검증한 뒤 merge 방식으로 작업 브랜치에 반영했다. 게임 정본 파일과 경로 충돌은 없었다.

### 감사 과정의 해석 오류와 복구

적대적 검토 중 기존 `현재 피해 단위끼리 순차 합`을 `첫 피해 단위만 합`으로 잘못 해석해 브랜치 문서 일부를 일시적으로 교정했다.

사용자 확인으로 정확한 의도를 재검증했다.

- 연격 대 연격은 현재 순번 정산 뒤 양측 공격이 유지되면 다음 순번도 합한다.
- 체력 피해·중단이 후속 합 지속 여부를 결정한다.
- 합 패배·동점 자체는 현재 피해 단위만 취소·상쇄한다.

잘못된 해석은 활성 정본·Decision·planning JSON·Google Sheet에서 모두 복구했다. 이 교정은 새 승인 1건으로 계산하지 않으며 기존 규칙의 의미 복구다.

## 5. Google Sheet 동기화

다음 탭의 쓰기와 readback을 완료했다.

- `01_작업순서`
- `02_현재_확정결정`
- `04_누락_충돌_감사`
- `05_GDD_요약`
- `15_조작_게임규칙`
- `40_핵심시스템_메인콘텐츠`
- `41_성장_경제`
- `99_변경이력`

Sheet는 현재 Draft PR Decision·순차 합·기준 스테이터스4를 반영한다. exact head가 확정되면 Draft SHA를 마지막으로 갱신하고, 병합 뒤 main SHA와 `SYNCED_MAIN`, 다음 승인 카운트 `0/10`을 기록한다.

## 6. 의도적으로 변경하지 않은 것

- 제품 코드·Scene·런타임 데이터.
- 현재 8개 기초 행동 데이터와 ActionSelectionDock.
- 속공·강공·장풍의 정확한 고정 피해·배수.
- 시작 스테이터스 총점·최저값·직접 분배 방식.
- 전투 종료 5지표 가중치·정규화·등급 경계.
- 다수 합 승리 상한·파밍 방지.
- 랭킹전 관찰 변환의 기술별 정확 수치.
- 평점·시즌·매칭·서버·보안.
- Godot·Windows·네트워크·접근성·사람 검증 상태.

## 7. 병합 차단 조건

다음 중 하나라도 남으면 병합하지 않는다.

- P0/P1 정본 충돌.
- Google Sheet Decision ID·내용 불일치.
- planning JSON 파싱·참조 실패.
- PR head가 검증 뒤 이동.
- 최신 main 미반영.
- CI 실패·취소·대기.
- 미해결 review thread.
- 제품 코드·런타임 데이터의 무단 변경.
- `첫 피해 단위만 합`, `후속타는 다시 합하지 않음`이 활성 정본에 남음.

## 8. 현재 판정

```yaml
authority_status: CURRENT_APPROVED_PLANNING_PRESERVED
scope_status: DOCUMENTATION_MAINTENANCE_AND_GRILLME_CHECKPOINT
implementation_status: NO_PRODUCT_CHANGE
static_validation: PENDING_EXACT_HEAD
runtime_validation: NOT_RUN
human_validation: NOT_RUN
p0_open: 0
p1_document_drift_open: 0
p1_implemented_legacy_gap: BASIC_ACTIONS_8_VS_APPROVED_10
main_sync_required: false
sheet_content_sync_required: false
sheet_exact_head_refresh_required: true
ci_required: true
review_thread_check_required: true
post_merge_grillme_count: 0/10
```
