# 십보강호 활성 컨텍스트

> 전투 규칙 책임 원본: `docs/02_COMBAT_RULES.md`

## 현재 기준

```yaml
project: 십보강호: 숨은 수의 비무
repository: alsdmlals4-eng/Ten-Paces-Hidden-Moves
current_main_before_pr72_merge: 07b3f15c50d9900321bcec3897b8d0b726bd174e
current_checkpoint_pr: 72
checkpoint_state: PREMERGE_AUDIT_10_OF_10
primary_platform: PC
future_platform: MOBILE_CONSIDERATION_ONLY
engine: Godot 4.7
product_stage: VERTICAL_SLICE_APP_FLOW_PLANNING
work_mode: REVIEW
base_release_pinned: 9.4.1
runtime_implementation: ACTION_SELECTION_DOCK_IMPLEMENTED_MAIN_HUMAN_PENDING
latest_combat_planning_runtime: NOT_STARTED
automated_validation: PENDING_EXACT_HEAD
windows_validation: NOT_RUN
human_validation: NOT_RUN
next_package: VERTICAL_SLICE_APP_FLOW_SHELL
```

PR #73은 Base v9.4.1 공유 Skill Adapter만 변경해 main에 병합됐으며 PR #72의 게임 정본 파일과 변경 경로가 겹치지 않는다.

## 프로젝트 코어

> 공개 상태와 반복 습관을 읽고, 서로의 현재 계획을 모른 채 10칸 전장에 `3수 → 3수 → 4수`로 수를 걸어 거리·현재 순번 합·조건부 다음 순번 합·대응·중단으로 파훼하고 복기로 다음 계획을 바꾸는 1대1 무협 심리 전술 로그라이트.

- AI는 공개 상태와 해결 이력만 사용하며 미확정 플레이어 계획을 읽지 않는다.
- 영구 전투 스테이터스는 외공·근골·신법·내공·심안이다.
- 본편 관찰은 플레이어 전용이며 묶음·라운드 경계를 넘어 이월한다.
- 공식 챔피언 랭킹전은 양측 관찰을 금지하고 관찰 의존 효과에 공개·대칭·버전 고정 변환표를 적용한다.
- 태그·상태·범위·검증 어휘는 `docs/00_TAG_STATUS_REGISTRY.md`가 소유한다.

## 역사 연결과 현재 판정

- `Issue #13`은 프로젝트 코어 검토와 PoC 검증 이력을 연결하는 역사 참조다. 현재 작업 지시나 미해결 이슈를 뜻하지 않는다.
- 과거 상태 `CORE_REVIEW_PENDING`은 사용자 승인 뒤 `CORE_CONFIRMED`로 종료됐다.
- `STEP 14`는 신규 플레이어 사람 검증 단계이며 현재 `human_validation: NOT_RUN`이다.
- 과거 이력 토큰은 최신 정본보다 우선하지 않으며, 현재 단계·권한은 이 문서의 `현재 기준`과 최신 Decision이 소유한다.

## 이번 10개 승인 정본

1. `TEN-DEC-20260802-BASIC-ACTIONS-PALM-CLASH-01`
2. `TEN-DEC-20260802-OUT-OF-RANGE-CLASH-REWARD-01`
3. `TEN-DEC-20260802-OUT-OF-RANGE-CLASH-GRADE-01`
4. `TEN-DEC-20260802-CLASH-THREAT-ATTENUATION-01` — 현 등급 산식에서는 HOLD
5. `TEN-DEC-20260802-THREAT-ID-ACTION-01` — 로그·복기 안정 ID
6. `TEN-DEC-20260802-MULTIHIT-COMPLETE-PARRY-01`
7. `TEN-DEC-20260802-COMPLETE-PARRY-HP-ONLY-01`
8. `TEN-DEC-20260802-BATTLE-GRADE-FIVE-METRICS-01`
9. `TEN-DEC-20260802-TECHNIQUE-AUTHORING-TAG-FIXED-STAT-01`
10. `TEN-DEC-20260802-STAT-REFERENCE-PRICE-BASE4-01`

## 현재 전투 정본 요약

- 기초 행동 10종: 이동·보법·막기·회피·속공·강공·관찰·명상·준비·장풍.
- 전조는 강화 없는 점유·표시 단계이고 준비가 고정 강화 행동이다.
- 연격 대 연격은 현재 순번 피해 단위끼리 앞에서부터 합한다.
- 현재 순번 정산 뒤 양측 체력 피해가 0이고 두 공격 행동이 유지되며 다음 피해 단위가 모두 있으면 다음 순번도 다시 합한다.
- 체력 피해로 한쪽 공격이 중단되면 그쪽 후속 피해 단위를 취소하고 상대 잔여타는 단독으로 해결한다. 강건이 중단을 막으면 다음 합을 계속할 수 있다.
- 사거리 밖 합 승리도 절초기세와 `ON_CLASH_WIN`을 얻지만 해당 피해 단위의 적중·체력 피해 효과는 발생하지 않는다. 양측 공격이 유지되면 다음 순번 합도 진행한다.
- 완전 파훼는 해당 공격 행동의 체력 피해 0인 로그·복기 사건이며 부가효과가 남을 수 있다.
- 전투 종료 등급 핵심 원자료는 회피 성공·합 승리·잃은 체력·라운드 수·절초 사용이다.
- 여러 순번 합 승리는 실제 사건 수를 기록하되 정확한 상한·정규화·파밍 방지는 미확정이다.
- 기존 위협 대응30 체계와 동일 위협 100→50→0 감쇠는 현 등급 산식에서 비활성이다.

## 기술 작성·능력치 가격

```text
구조·비용 → 태그 → 고정 기본치 → 주/보조 능력치 배수 → 5/9성 patch·임계
```

- 관찰·이동·회피·준비 기본 효과는 고정 전용이다.
- 그 외 연속 수치 효과는 최소 1개 능력치 참조를 가진다.
- 능력치 배수 기준 스테이터스는 4, 배수 단위는 0.25다.
- `배수 틱 = ceil(효과 1점 가격 × 배수 × 4)`.
- 실제 값은 고정치와 모든 능력치 항을 합산한 뒤 한 번 내림한다.
- 초기 스테이터스 설계 중심은 4 전후이며 정확한 시작 총점·분배는 미확정이다.

## 구현 차이

현재 main 런타임은 다음이 최신 기획과 다르다.

- 관찰·장풍이 없는 기초 행동 8종.
- 일부 레거시 데이터의 절대 원공격력.
- 주요 비무 5전·노드8개·성장·새 결과 등급 미구현.

별도 Build 승인 전 제품 코드·Scene·런타임 데이터는 변경하지 않는다.

## 다음 제품 작업

현재 구현 우선 패키지는 `VERTICAL_SLICE_APP_FLOW_SHELL`이다.

1. App Root·Scene·화면 상태.
2. `RunSession`·`SaveService`.
3. 시작 무공 6중4.
4. Route·Node·Briefing.
5. Combat 진입·복귀.
6. Result·Reward·Retry transaction.
7. 자동·Godot·Windows·접근성·성능·사람 검증.

## 남은 기획

- 시작 스테이터스 총점·최저값·직접 분배 방식.
- 속공·강공·장풍의 정확한 고정 피해와 배수.
- 5개 전투 종료 지표의 가중치·정규화·등급 경계.
- 한 공격 행동 안의 다수 합 승리 상한·정규화·파밍 방지.
- 절초 사용의 평가 방식과 패배 전투 등급.
- 챔피언 등록 슬롯·시즌·매칭·어뷰징·친선전 관찰 규칙.

## 검증 경계

```yaml
planning_checkpoint: 10/10
product_code_changed: false
runtime_validation: NOT_RUN
godot_validation: NOT_RUN
windows_validation: NOT_RUN
network_validation: NOT_RUN
accessibility_validation: NOT_RUN
human_validation: NOT_RUN
human_step14: NOT_RUN
demo_ready: NO
```
