# 십보강호 활성 컨텍스트

> 전투 규칙 책임 원본: `docs/02_COMBAT_RULES.md`

## 현재 기준

```yaml
project: 십보강호: 숨은 수의 비무
repository: alsdmlals4-eng/Ten-Paces-Hidden-Moves
main_canon_maintenance_merge: add26649717a0b1bdf6eee40ad0b6214c9738eb4
last_planning_checkpoint_merge: d9f38e6f3cacaf170d4b290e95b3645114639aff
runtime_work_mode: REVIEW
runtime_integration_pr: 65
active_planning_work_mode: PLAN
active_planning_pr: 84
active_approval_count: 2/10
active_decision_state: APPROVED_PENDING_MERGE
primary_platform: PC
future_platform: MOBILE_CONSIDERATION_ONLY
engine: Godot 4.7
product_stage: VERTICAL_SLICE_APP_FLOW_PLANNING
base_release_pinned: 9.4.3
runtime_implementation: ACTION_SELECTION_DOCK_IMPLEMENTED_PR65
latest_combat_planning_runtime: NOT_STARTED
automated_validation: PASS
windows_validation: NOT_RUN
human_validation: NOT_RUN
next_package: VERTICAL_SLICE_APP_FLOW_SHELL
next_planning_decision: INTERMEDIATE_NODE_PERMANENT_STAT_REWARDS
```

`automated_validation: PASS`는 병합된 런타임 기준선과 현재 정적 계약의 자동 검증 상태다. PR #84의 exact-head 세 검사는 별도로 재확인하며, Windows·접근성·성능·사람 검증을 대신하지 않는다.

PR #83은 활성 정본 신선도 결함을 교정해 main에 병합됐다. PR #82의 승인 2건은 archive Branch에 보존하고 새 main 기반 PR #84로 이전한다. 두 Decision은 제품 코드 권한이 없는 `CURRENT_APPROVED_PLANNING / APPROVED_PENDING_MERGE`다.

## 프로젝트 코어

> 공개 상태와 반복 습관을 읽고 서로의 현재 계획을 모른 채 10칸 전장에 `3수 → 3수 → 4수`로 수를 걸어 거리·순차 합·대응·중단으로 파훼하고, 복기로 다음 계획을 바꾸는 1대1 무협 심리 전술 로그라이트.

- AI는 공개 상태와 해결 이력만 사용하며 미확정 플레이어 계획을 읽지 않는다.
- 핵심 재미는 불완전한 정보에서 여러 가능성을 견디는 계획을 만들고, 결정적 원인을 이해해 다음 계획을 바꾸는 데 있다.
- 영구 전투 스테이터스는 외공·근골·신법·내공·심안이며 디자인 하드캡은 없다.
- GrillMe와 주요 기획은 정본 확인→적대적 검토→벤치마크·현업 비교→선택지·권장안→승인 동기화 순서를 따른다.

## 런타임 기준선

- `TEN-DEC-20260801-MARTIAL-TECHNIQUE-UX-01`: 현재 해금 기술을 배치하는 ActionSelectionDock UX.
- `TEN-DEC-20260801-SITUATION-SCREEN-01`: 상황 화면과 전투 진입 구조.
- `work_mode: REVIEW`, `integration_pr: 65`는 런타임 기준선이다.
- 최신 전투·성장 기획은 런타임에 아직 반영되지 않았다.

## 현재 활성 승인 — 2/10

1. `TEN-DEC-20260803-STAR10-ULTIMATE-PRIMARY-STAT12-01`
   - 10성 절초는 해당 무공의 주 영구 능력치12를 요구한다.
   - 보조 요구 없음, 임시 능력치 해금 불가, 미달 시 절초만 잠금.
2. `TEN-DEC-20260803-STARTING-MARTIAL-SECONDARY-STATS-01`
   - 유운검결 신법/외공
   - 금강호체공 근골/내공
   - 태극유전검 심안/내공
   - 추풍창법 외공/신법
   - 청심양생공 내공/근골
   - 무영십보 신법/심안
   - 시작3성에는2성 주+1만 적용하고 보조는4성부터 지급한다.

## 현재 정본 요약

- 기초 행동10종과 `3수→3수→4수`.
- 현재 순번 피해 단위끼리 합하고 양측 공격이 유지되면 다음 순번 합을 반복한다.
- 시작 능력치는 기본2×5+자유6+시작 무공 보너스4로 총합20·평균4다.
- 3성 첫 기술 주4, 7성 두 번째 기술 주8, 10성 절초 주12이며 보조 요구는 없다.
- 짝수 성 최초 도달 지급: 2성 주+1, 4성 주+1·보조+1, 6성 주+2·보조+1, 8성 주+3·보조+2.
- 전투 종료 등급 원자료는 회피 성공·합 승리·잃은 체력·라운드 수·절초 사용이다.

## 구현 차이

현재 런타임에는 관찰·장풍, 최신 시작 총합20, 무공 보너스, 기술 잠금, 짝수 성 지급, 3/7/10성 요구, 주요 비무5전·노드8개·새 결과 등급이 구현되지 않았다. 별도 Build 승인 전 제품 코드·Scene·런타임 데이터는 변경하지 않는다.

## 역사·회귀 추적

- `PR #7`은 T0 `STEP 0~13` 구현 계보의 역사 기준이다.
- `Issue #13`은 프로젝트 코어 검토와 PoC 검증 이력의 연결점이다.
- 과거 상태 `CORE_REVIEW_PENDING`은 사용자 승인 뒤 `CORE_CONFIRMED`로 종료됐으며 현재 상태가 아니다.
- `STEP 14`는 신규 플레이어 사람 검증 단계이며 현재 `NOT_RUN`이다.
- 위 역사 토큰은 최신 Decision이나 현재 Active Context보다 높은 권한을 갖지 않는다.

## 다음 작업 Gate

```text
중간 노드 영구 스테이터스 보상 GrillMe
→ 남은 승인 최대 10건
→ [기획 완료]
→ 전체 적대적 검토
→ [검토 완료]
→ 이미지·애니메이션·HX 생성·검수·승인
→ [이미지 완료]
→ VERTICAL_SLICE_APP_FLOW_SHELL Codex BUILD
```

남은 핵심 기획은 중간 노드 영구 스테이터스 보상, 기술 주/보조 배수와 5/9성 임계 효과, 전투 종료 등급과 파밍 방지, 절초 평가, 경쟁·관찰·사람 검증 계약이다.

## 검증 경계

```yaml
planning_checkpoint: ACTIVE_DRAFT_2_OF_10
product_code_changed: false
runtime_validation: NOT_RUN
godot_validation: NOT_RUN
windows_validation: NOT_RUN
network_validation: NOT_RUN
accessibility_validation: NOT_RUN
human_validation: NOT_RUN
demo_ready: NO
```