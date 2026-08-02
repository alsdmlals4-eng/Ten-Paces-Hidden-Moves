# 십보강호 활성 컨텍스트

## 현재 기준

```yaml
project: 십보강호: 숨은 수의 비무
repository: alsdmlals4-eng/Ten-Paces-Hidden-Moves
reviewed_main_before_this_audit: 7082dab1c66e994ce3be1861640754f97080ed5c
primary_platform: PC
future_platform: MOBILE_CONSIDERATION_ONLY
engine: Godot 4.7
product_stage: VERTICAL_SLICE_APP_FLOW_PLANNING
work_mode: REVIEW
latest_merged_operating_pr: 68
latest_merged_planning_pr: 71
runtime_implementation: ACTION_SELECTION_DOCK_IMPLEMENTED_MAIN_HUMAN_PENDING
full_app_flow_runtime: NOT_STARTED
automated_validation: PASS
windows_validation: NOT_RUN
human_validation: NOT_RUN
next_package: VERTICAL_SLICE_APP_FLOW_SHELL
base_release_pinned: 9.4.0
```

태그와 상태는 `docs/00_TAG_STATUS_REGISTRY.md`를 따른다. 기획 권위, 콘텐츠 범위, 구현 상태, 검증 상태를 한 문자열로 합치지 않는다.

## 프로젝트 코어

> 공개 상태와 반복 습관을 읽고, 서로의 현재 계획을 모른 채 10칸 전장에 `3수 → 3수 → 4수`로 수를 걸어 거리·합·대응·중단으로 파훼하고 복기로 다음 계획을 바꾸는 1대1 무협 심리 전술 로그라이트.

- AI는 공개 상태와 해결 이력만 사용하며 미확정 플레이어 계획을 읽지 않는다.
- 덱·손패·드로우·행동력·장착 기술 제한이 없다.
- 영구 전투 스테이터스는 외공·근골·신법·내공·심안이다.
- 본편 `[관찰]`은 플레이어 전용이며 관찰량은 묶음·라운드 경계를 넘어 이월한다.
- 공식 랭킹전은 양측 `[관찰]`을 금지하고 관찰 의존 효과에 동일·공개·버전 고정 변환표를 적용한다.

정본: `docs/01_GAME_DESIGN.md`, `docs/02_COMBAT_RULES.md`, `docs/00_TAG_STATUS_REGISTRY.md`.

## 최신 승인 Decision

- `TEN-DEC-20260802-PLATFORM-SCOPE-01`
- `TEN-DEC-20260802-OBSERVATION-STATS-MASTERY-01`
- `TEN-DEC-20260802-FULLRUN-CHAMPION-RANKED-01`
- `TEN-DEC-20260802-RANKED-OBSERVATION-CONVERSION-01`

위 Decision은 후보6명 고정, 천하제일인 사전 예고, 첫 후보 자동 배정, 공격력·방어력 중심 성장, 공개 성향, 관찰 의존 효과 미결정 표현보다 우선한다.

## 승인된 제품 흐름

```text
BOOT → MAIN → RUN_SETUP → ROUTE → NODE → DUEL_BRIEFING
→ COMBAT → COMBAT_REVIEW → DUEL_RESULT → REWARD_OR_RETRY
```

- Route와 Combat은 별도 Scene.
- Combat Review는 Overlay, Duel Result는 별도 Scene.
- P0 Autoload 후보는 `RunSession`, `SaveService`.
- 전체 제품 흐름 런타임은 `NOT_STARTED`다.

## 회차 계약

```yaml
demo:
  major_duel_slots: 5
  candidates_per_slot: 3
  intermediate_nodes: 8
  target_playtime: 15_to_22_minutes
full_run:
  major_duel_slots: 10
  candidates_per_slot: 3
  intermediate_nodes: 18
  target_playtime_before_finale: 30_to_40_minutes
finale:
  candidates_presented_after_duel_10: 2
  player_selects: 1
champion_battle:
  scope_status: FUTURE_ONLINE
  implementation_status: BLOCKED_NOT_AUTHORIZED
```

## 성장 계약

- 무공서 1~10성, 시작 3성.
- 2·4·6·8성: 고정 스테이터스.
- 3·7성: 신규 기술 해금 검사.
- 5·9성: 기본 강화와 임계 효과.
- 10성: 절초 해금 검사.
- 기술별 별도 수련도는 없다.

## 현재 다음 작업

`VERTICAL_SLICE_APP_FLOW_SHELL` 구현 Packet을 실제 저장소 기준으로 정밀화한다.

1. App Root·화면 상태·Scene 소유권.
2. `RunSession`·`SaveService` Schema·저장·복구.
3. 시작 무공 6중4 선택.
4. Route·Node·Briefing 상태·입출력·실패.
5. Combat 진입·복귀와 Result·Reward·Retry transaction.
6. 자동·Godot·Windows·접근성·성능·사람 검증.
7. 롤백 단위와 보호 경로.

## 이번 정본 감사에서 교정할 활성 드리프트

- `docs/01`·`docs/03`: 관찰 의존 랭킹 처리 미결정 표현.
- `docs/04`: 구형 main SHA·PR 상태.
- `docs/05`: 공격력·방어력·공개 성향·천하제일인 후보6명.
- `docs/08`: 소모 방어도·구형 시작 수치와 최신 승인 기획 혼합.
- Google Sheet `05_GDD_요약`: 후보6명과 구형 동기화 상태.

이 교정은 새 게임 규칙 승인이 아니므로 GrillMe 승인 카운트에 포함하지 않는다.

## 역사·보류

- PR #65: ActionSelectionDock·화면 구조.
- PR #68: Base v9.4 운영 계약.
- PR #69: 플랫폼·관찰·스테이터스·무공 성장.
- PR #70: 정식 회차·천하제일인·챔피언 랭킹.
- PR #71: 랭킹전 관찰 변환·병합 게이트.

보류:

- 기술별 정확한 랭킹전 변환 수치.
- 주요 비무 6~10 런타임.
- 천하제일인·챔피언 배틀 서버·런타임.
- 모바일 포팅·스토어·크로스 세이브.
- 최종 아트·오디오.

자동 검증은 Windows·네트워크·사람 검증을 대체하지 않는다.
