# 태그·기획 정본 누락 감사

- Audit ID: `TEN-AUD-015`
- 날짜: 2026-08-02
- 기준 main: `7082dab1c66e994ce3be1861640754f97080ed5c`
- 작업 브랜치: `agent/2026-08-02-tag-planning-canon-audit`
- 작업 성격: 문서 정본 유지보수 + GrillMe 승인 누적
- 현재 GrillMe 승인 카운트: `2/10`

## 1. 감사 목적

승인된 태그·관찰·성장·회차·천하제일인·챔피언·전투 평가 결정이 활성 문서·planning JSON·Google Sheet·런타임 증거에서 누락되거나 구형 표현으로 되살아나는지 확인한다.

## 2. 확인한 정본·구현

- `TEN-DEC-20260802-PLATFORM-SCOPE-01`
- `TEN-DEC-20260802-OBSERVATION-STATS-MASTERY-01`
- `TEN-DEC-20260802-FULLRUN-CHAMPION-RANKED-01`
- `TEN-DEC-20260802-RANKED-OBSERVATION-CONVERSION-01`
- `TEN-DEC-20260802-BASIC-ACTIONS-PALM-CLASH-01`
- `TEN-DEC-20260802-OUT-OF-RANGE-CLASH-REWARD-01`
- `docs/01~08` 책임 원본과 허브 문서 지도
- `src/ui/action_selection/basic_action_panel.gd`
- `src/ui/action_selection/action_view_model_adapter.gd`
- `data/cards/basic_cards.json`
- Google Sheet 01·02·04·05·10·15·40·50·60·90·99

## 3. 발견 사항

### P0

없음. 제품 코드·런타임 데이터는 변경하지 않았고 미실행 검증을 완료로 과장하지 않았다.

### P1 — 활성 정본·구현 충돌

1. 관찰 의존 무공의 랭킹전 변환이 승인됐는데도 일부 문서에는 미결정으로 남아 있었다.
2. Active Context·Roadmap·문서 지도에 과거 main SHA와 PR #65/#68 상태가 남아 있었다.
3. PoC·테스트 문서에 공격력·방어력 중심 성장, 공개 성향, 소모 방어도, 후보6명 표현이 남아 있었다.
4. Google Sheet 요약에 후보6명과 구형 동기화 상태가 남아 있었다.
5. 2026-07-24 승인 사용자 용어 `[준비]`가 일부 최신 문서에서 `[태세]`로 회귀했다.
6. 최신 기초 행동은 10종이지만 현재 `basic_cards.json`과 ActionSelectionDock은 `[관찰]`과 `[장풍]`이 없는 8종이다.
7. `랭크`가 온라인 시즌 랭킹과 전투 종료 S/A/B/C 평가 사이에서 혼동됐다. 이번 문맥의 `랭크`는 전투 종료 성과 등급이다.

### P2 — 태그·상태 구조 누락

1. 제품 포지셔닝·플레이어 노출 규칙·내부 상태 태그의 중앙 등록부가 없었다.
2. 권위·범위·구현·검증 상태가 하나의 문자열로 혼합됐다.
3. 카드형 UI 때문에 덱빌딩·카드 배틀러로 오인될 위험을 차단하는 경계가 없었다.

## 4. 교정 내용

- `docs/00_TAG_STATUS_REGISTRY.md` 신설.
- 핵심 제품 태그와 오인 방지 태그 분리.
- 권위·콘텐츠 범위·구현·검증 상태 필드 분리.
- Active Context·Roadmap·PoC·테스트·문서 지도 최신화.
- 기초 행동 10종 복원: 이동·보법·막기·회피·속공·강공·관찰·명상·준비·장풍.
- `[전조]`는 효과 없는 표시·점유 단계, `[준비]`는 독립 강화 행동으로 분리.
- 장풍을 2수·내력1·사거리1~3·속공보다 낮은 피해로 승인.
- 사거리 밖 합 승리를 정상 합 승리로 인정하고 절초기세 +1·`ON_CLASH_WIN`을 적용하되 적중·피해·상대 대상 효과는 개별 사거리 검사를 유지.
- 사거리 밖 합 승리를 전투 종료 `위협 대응` 평가에 반영하고 온라인 시즌 랭킹과 분리.

## 5. 의도적으로 변경하지 않은 것

- 제품 코드·Scene·런타임 데이터.
- 장풍의 정확한 기본 피해·내공 계수.
- 전투 종료 사건당 정확한 점수.
- 시즌 평점·매칭·서버·보안.
- Godot·Windows·네트워크·접근성·사람 검증 상태.

## 6. 후속 검증

- 활성 문서에서 `[태세]`, 기초 행동 8/9종을 현재 정본으로 오인하는 표현, 후보6명, 공개 성향, 신규 성장의 공격력·방어력 표현 재검색.
- planning JSON 파싱과 정적 계약 검사.
- exact-head Full Validation·PR Validation·Base v9 Adoption 확인.
- PR diff·review thread·head 이동 확인.
- 병합 뒤 main·Google Sheet 재조회.

## 7. 현재 판정

```yaml
authority_status: CURRENT_APPROVED_PLANNING_PRESERVED
scope_status: DOCUMENTATION_MAINTENANCE_AND_GRILLME_ACCUMULATION
implementation_status: NO_PRODUCT_CHANGE
static_validation: PENDING_DRAFT_PR
runtime_validation: NOT_RUN
human_validation: NOT_RUN
p0_open: 0
p1_document_drift_open: 0
p1_implemented_legacy_gap: BASIC_ACTIONS_8_VS_APPROVED_10
p2_open: 0
grillme_count: 2/10
```
