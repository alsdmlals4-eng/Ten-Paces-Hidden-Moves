# 십보강호 남은 작업 · 설계 및 구현 명세

작성일 2026-09-14. 사용자 요청: 남은 작업과 해당 작업들의 구현·설계 명세 준비.
문서 상태: SPECIFIED_PROPOSAL. 이 문서는 다음 개발의 요구·인터페이스·인수 계약을 소유한다. 기존 규칙 owner를 대체하거나 새 수치·저장 버전을 승인하는 문서가 아니다.
실행자는 이 문서와 각 작업의 정본을 함께 읽고 `superpowers:executing-plans`로 작업별 RED→GREEN→검증을 진행한다. 이번 산출 범위는 명세이며 제품 코드는 변경하지 않는다.

## 1. 기준과 완료 범위

- 조사한 제품 HEAD: `fb565eb1d2fbc2e1896695c58e6be08c475577cc`, PR342 Draft. main: `ed2104d98872c63eac27999830aeae9c15a00bdc`.
- Base remote main: `d830c0f6967678eed3c208ac6b24f9cd1b262ec3`; 프로젝트 채택 9.4.4를 자동 교체하지 않았다.
- 기준 HEAD의 원격 검사34 SUCCESS. 이전 실행의 실제 입력 자동 캠페인10승·36행로는 해당 revision의 증거이며 이번 명세나 모든 보상 조합의 통과가 아니다.
- 출발점은 구현된 Windows 10전 여정이다. 시작4권, 가변 상대16명/160단계행, v1/v2 저장, 비무 제약, 3갈래 중4회 선택, 휴식/수련/정탐/사건, 완료 기록, 메뉴·설정·결과 탐색을 처음부터 재구현하지 않는다.
- 완료 목표는 승인된 단일 플레이 코어를 처음부터 끝까지 신뢰할 수 있게 연결하고 Windows·Android 설계 범위의 구현·검증을 닫는 것. 스토어 출시는 별도 실행 결정이다.
- 온라인 챔피언·시즌·서버·시장 장기경제·후보30명·추가 천하제일인전은 역사적 장기 가설이다. 현재 10전 종료를 임의로11전으로 늘리지 않는다. 후술 별도 결정 묶음에서 재산정한다.

### evidence와 실제 남은 문제

| 구분 | 현재 관찰 | 남은 것 |
|---|---|---|
| 전수 무공 | progression은 신규 무공을 owned 목록에 추가함 | RunState getter는 시작4권 반환; bridge/전투 codec은 정확히4권 강제. 새 무공의 실제 전투 연결 공백 |
| 자유 수련 | pool 누적·snapshot·완료 표시는 있음 | `src/run`에 pool 소비 연산 없음. 선택 보상이 다음 전투의 성장으로 연결되지 않음 |
| 플레이어 능력 | 전투 계산·상대 단계 수치·성수 효과는 존재 | 시작 자유분배·회차 영구 능력 지급을 하나의 run owner에서 전투/저장에 연결하는 작업과 대조가 필요 |
| 결과 | 원자료5종, 선택·확정·첫 선택 고정 있음 | `VerticalSliceResultModel.GRADE_STATUS=FORMULA_PENDING`; 중복 전수는 PENDING_DUPLICATE_POLICY |
| 행로 | 다섯 종류를 회전시켜3개 제시, 실제 효과 존재 | 사건은 단일 도움 행동, 영구 능력 보상 계약과36행로 공급량 조정 미해결 |
| 표현 | 승인 정적 원화47개와 모션 통합 있음 | 모션4장 final lock, 무기군 표현 커버리지, 작은 화면·사람 가독성 |
| 플랫폼 | 공통 Godot 코드·Windows export 있음 | `src`에 다섯 플랫폼 adapter 전체 구현을 확인하지 못함; Android preset 없음 |
| 번역 | 한국어 문구와 일부 key 기반 인물 데이터 있음 | 실제 UI 문자열 추출·번역 선택·fallback·폰트·전체 화면 검증 |
| 출시 | Profile/권리 원장/증거 pack 존재 | 실제 자산 권리 증거·대표 release build·실기기·Human 확인 |

`미구현`은 위 소비처를 확인한 범위다. 모든 과거 문서의 체크박스를 전수 실행 검증했다는 뜻이 아니다. 도메인 효과별 미세 결함은 P12/P13 인수 중 추가될 수 있다.

## 2. 설계 공통 계약

WHY: 얻은 무공과 수련이 실제 다음 판단을 바꾸고, 실패 이유를 이해하며, 중단·재개 후에도 같은 여정을 이어갈 수 있어야 한다.
HOW: 규칙/성장/저장은 단일 owner, UI는 허용된 view와 명령, 연출은 해결 사건만 소비한다.
WHAT: 아래 P00~P14의 작은 인수 단위로 연결하고 각 완료를 정본·자동·실행·Human·출시로 분리한다.

- 1대1 10칸, 시작거리2, 밀착0, 3/3/4, 공개 정보 AI, 덱/손패/드로우/장착 제한 없음을 보호한다.
- 시작4권 선택과 회차 중 보유 전체 사용을 분리한다. 화면 편의 때문에 보유권수 상한을 게임 규칙으로 만들지 않는다.
- 현재 저장은 엄격한 재구성 검사다. JSON 키가 같아도 성장 처리 의미를 바꾸면 저장 호환성 영향이다.
- UI click → `RunSessionCoordinator.transact(Callable)` → domain 변경 → immutable pending snapshot → 저장 readback → 진행 허용 순서를 재사용한다.
- 현재 transact는 쓰기 실패 때 domain을 즉시 되돌리지 않고 pending 상태에서 막고 retry한다. 새 작업도 이 의미를 유지한다. 실패 후 같은 보상을 다시 계산·가산하는 구현을 금지한다.
- 순수 invalid 명령은 domain 변경0. 저장 실패는 durable 원본 보존·새 명령 차단·동일 pending retry. 두 실패를 같은 bool 설명으로 혼동하지 않는다.
- 원화·수치·문구·효과 ID를 분리한다. 문서만으로 ASSET_READY/IMPLEMENTED/HUMAN_PASS를 만들지 않는다.
- 새 영구재화·상점·외부 SDK·유료 도구·서버 의존성을 기술 편의로 추가하지 않는다.

### 대안 비교와 권장 구조

1. **기존 소비처를 연결하는 단계별 완성: ADOPT.** 기존 run/progression/codec/bridge를 확장하며 공백별 인수 테스트. 호환성·원인 추적 비용이 가장 낮다.
2. 전체 게임 shell/저장 시스템 재작성: REJECT. 동작 중인10전·저장·공개정보 경계를 다시 검증해야 하고 현재 공백보다 범위가 크다.
3. UI 설명·그림만 개선하며 도메인 공백 보류: REJECT. 수련·전수 선택이 실효성을 갖지 못한다. 표현 작업은 P01~P03과 병행 가능하되 대체하지 않는다.

## 3. 작업 순서와 상태

| ID | 인수 단위 | 우선순위 | 선행 | 준비/권한 경계 |
|---|---|---|---|---|
| P00 | 현재 문서·미완료 상태·통합 정합성 | P0 | 없음 | FEASIBLE, 문서 교정 |
| P01 | 전수받은 모든 무공의 실제 전투 연결 | P0 | P00 | FEASIBLE, 승인 코어와 현재 구현 충돌 교정 |
| P02 | 자유 수련 소비·저장·해금 연결 | P0 | P01, 저장 의미 결정 | PARTIAL, UI 시점/호환 Decision 초안 필요 |
| P03 | 시작 능력 분배·성장 영구 능력 | P0 | P02의 버전 계약 | PARTIAL, 승인 수치의 실제 consumer 정합성 |
| P04 | 중복 전수 보상 마무리 | P1 | P01/P02 | PARTIAL, 보상 의미 Decision 필요 |
| P05 | 등급 유효 입력·산식·표시 | P1 | P12 기초 측정 | PARTIAL, 집계는 승인 계약; 최종 산식은 후보 |
| P06 | 행로 사건·정탐·영구 능력 보상 | P1 | P02/P03 | PARTIAL, 36선택 공급량·콘텐츠 결정 필요 |
| P07 | 도감·조사·완주 기록의 회차 밖 보존 | P1 | P00, 별도 profile 계약 | PARTIAL, 범위 확정 후 구현 |
| P08 | 첫 플레이 이해·전체 화면·입력/확인창 | P1 | P01~P03 결과 반영 | FEASIBLE, 기존 화면 우선 |
| P09 | 모션·무기군·음향 마감 | P1 | 현재4장 검수/소비처 표 | PARTIAL, 이미지 최종 lock 별도 |
| P10 | 다국어·문구/폰트·접근성 표현 | P1 | P08 문구/상태키 | FEASIBLE 기반, 번역 Human 별도 |
| P11 | Windows/Android adapter·export·기기 | P1 | P08/P10, 도구/기기 확인 | PARTIAL, 실제 Android 증거 없음 |
| P12 | 성장·편성·전투 정책별 밸런스 | P0부터 반복 | 기준측정 즉시; 최종 P01~P06 | FEASIBLE 측정, 재미/최종수치 Human 별도 |
| P13 | 저장·안정성·성능·전체 플레이 인수 | P0부터 반복 | 각 구현 뒤; 최종 P01~P12 | FEASIBLE 자동; 물리검증 별도 |
| P14 | 배포물·권리·릴리스 인수 | P2 | P09~P13 | PARTIAL, 비용/제출/출시 결정 별도 |

직렬 경로: P00→P01→P02→P03→P06→P13→P14. P12 기준 측정, P08 진단, P09 상태표, P10 문자열 inventory, P11 도구 확인은 독립 준비 가능하다. 이 표는 여러 에이전트 실행이나 일정 예약 지시가 아니다.

## 4. P00 — 현재 정본과 통합 정합성

**수정 owner:** `docs/01_GAME_DESIGN.md`, `docs/03_CONTENT_CATALOG.md`, `docs/04_ROADMAP.md`, `docs/blueprint/IMPLEMENTATION_READINESS.md` 및 JSON, `docs/PLATFORM_RELEASE_AND_ASSET_RIGHTS_PROFILE.md`, current planning JSON/Active Context.
**설계:** 역사 문구를 지우지 않고 당시 범위 표시와 current successor를 붙인다. 5전/2노드,30명,온라인/유료 재도전 설명을 current10전/4회선택/1회재도전에 자동 합치지 않는다. Android 설계 타깃과 스토어 출시 타깃을 별도 필드로 구분한다.
**절차:** 최신 Decision→현재 코드→기존 검증을 항목별 대조; 중복 구현 후보 제거; 의미 충돌은 `CANON_CONFLICT`와 필요한 Decision으로 등록. PR342 이미 구현분은 latest-main reconciliation/필수check/final lock 조건 충족 뒤 통합한다. 무관한 PR199/200은 소유 경계를 보존한다.
**인수:** current owner에서 전수·성장·등급·Android 상태를 서로 모순 없이 찾을 수 있음. 승인 PDF112쪽 bytes 보존. reference freshness 검사 성공. 제품 PASS는 추가하지 않는다.

## 5. P01 — 전수 무공을 다음 전투에서 사용

**기존 파일:** `src/run/vertical_slice_run_state.gd`, `vertical_slice_progression_state.gd`, `vertical_slice_shell.gd`, `vertical_slice_combat_bridge.gd`, `combat_checkpoint_codec.gd`; `src/ui/action_selection/action_view_model_adapter.gd`와 `martial_action_panel.gd`.
**사실:** `get_player_manual_loadout()`는 시작 배열을 반환한다. `configure_vertical_slice_loadouts()`와 전투codec은4권을 요구한다. 시작 배열을 progression 전체로 덮어쓰면 `validate_snapshot()`의 시작4권 계약까지 깨진다.
**설계:** 시작 배열/시작성수는 불변 이력으로 남긴다. 별도 `get_owned_player_manuals() -> Array[String]` view를 progression owner에서 복사하여 bridge/선택도크/보상대상에 전달한다. `_player_manual_loadout`의 의미를 바꾸지 않는다. 보유 ID는 고유·registry 실재·성수집합과 일치. 승인 catalog의 전체10권은 검증 상한이고 장착 제한이 아니다.
**저장:** 전투 binding.player_loadout과 checkpoint의 run.progression.owned_manual_ids가 일치해야 한다. 단순 `!=4` 삭제나1~10길이만으로 검증을 끝내지 않는다. 전수 receipt에서 재구성한 보유집합이 아닌 임의 무공 삽입은 거부. 기존 v1/v2 identity·시작조건·resolved roster 고정 유지. 기존 상태로 이미 합법인 전수5권을 복구하는 validator 교정과 새 규칙 변경을 분리해 판단한다.
**RED/인수:**
- [ ] 기존 actual shell에서 미보유 대표무공 전수→확정→4행로→다음비무. 전수 기술이 도크에 존재하고 실제 합법 수에 배치되어 해결됨.
- [ ] 4/5/10권을 각각 실제 보상 이력으로 구성하여 save→새 프로세스 Continue→동일 기술/성수. UI stress fixture로 대체 금지.
- [ ] 중복/미등록/미취득 무공·성수 변조 거부, 시작3/5권 선택은 계속 거부.
- [ ] 봉인 제약·기력/내력·절초·AI 공개정보·v1/v2 회귀, 실제 전수 선택을 포함한10전 캠페인.
**검증 파일:** 기존 `tests/verify_variable_shell.gd`, `verify_variable_combat_codec.gd`, `verify_variable_save_compat.gd` 확장; 새 `tests/verify_acquired_manual_flow.gd` 제안.
**실패/롤백:** 새로운 checkpoint가 유효하지 않으면 진행 차단·원본 보존. 정상4권 경로를 유지하고 실패 증거를 기록한다. 새 이미지 없음.

## 6. P02 — 자유 수련 소비와 성장 화면

**기존 owner:** progression의 NEXT_STAR_COSTS, result model 보상6/3+5, run session/store/codec. 새 제안 파일 `src/ui/training_allocation_panel.gd`, `tests/verify_training_allocation.gd`.
**권장 UX:** 결과 보상 확정 뒤의 JIANGHU 또는 BRIEFING에서 보조 버튼 `무공 수련`. 단계 선택을 소모하지 않는 관리 패널이며 전투/보상 미확정/저장 실패 중에는 비활성. 보유 무공명·현재성수·누적수련·다음성까지 필요량·현재pool 표시. +1/-1, 다음성까지 배분, 모두취소, 적용. 미리보기는 local draft이며 화면 닫기는 무변경. 확정은 한 번만 domain 명령으로 처리한다.
**권장 계약(새 인터페이스):** `preview_training(allocations: Dictionary) -> Dictionary`, `commit_training(allocations: Dictionary, expected_revision: int) -> bool`. 키는 보유manual ID, 값은 양의 정수(bool 제외). 합계≤pool, 각투입≤38−누적수련; 10성에는0만 허용. 기존 집중수련의 초과분 정책은 별도 유지하고 이 수동 배분으로 소급 삭제하지 않는다.
**수치:** 3→4 비용2, 이후3/4/5/6/8/10, 3→10 누적38. 산출은 UI 복제가 아닌 progression 함수 재사용. pool6에서 한 권에2 적용하면 pool4·4성, 이후3 적용하면 pool1·5성. 이 예는 능력 요구를 만족했다는 뜻이 아니다.
**호환 권장안:** 기존 codec은 보상/행로 이력에서 progression을 재구성한다. 새 배분 ledger를 기존v2에 몰래 추가하지 않는다. 새 여정용 `schema_version=3`, `ruleset_id=ten-duel-growth-v3` 제안; v1/v2는 frozen compatibility 경로. 새v3는 기존 resolved_encounters10건을 그대로 가진다. 기존여정 즉시 강제변환 REJECT; 선택적마이그레이션은 후속 별도 검증.
**배분 receipt 제안:** `{id, progression_revision_before, duel_index, allocations, pool_before, pool_after}`. id는 run_id+단조증가번호, 같은id 재적용0. 숫자/키/크기/합계/순서 검사, receipt 재생 결과와 snapshot 대조. busy/suspended/blocked/stale revision 거부.

**이력 순서 보강:** 새 v3의 `progression_events`에는 보상·행로·수련 배분·능력 지급의 사건 순서를 공통 sequence로 기록한다. 기존 reward/route history는 화면용 파생 view이며 같은 효과를 두 번 적용하는 별도 ledger가 아니다. 검증기는 sequence 1부터 재생해 각 배분 당시 보유 무공·pool·성수를 검사한다. 미래 보상으로 과거의 초과 지출을 정당화할 수 없다. 새 순서 계약이 기존 정본을 중복 소유하지 않도록 v3에만 도입하며, 기존 v1/v2 재구성은 그대로 유지한다.
**인수:** 0/음수/소수/bool/초과pool/미보유/10성/오래된revision 거부; 취소 무변경; 연타1회; 쓰기실패 pending 재시도 가산0; 새 프로세스 복원; v1/v2 fixture bytes 보존; 실제 해금 기술 실행. version Decision과 관리 화면 의미를 확정하기 전 제품 적용은 하지 않는다.

## 7. P03 — 시작 능력·성수 보너스·기술 요구치

**정본:** `docs/02_COMBAT_RULES.md`, `docs/06_STARTING_FACTION_MASTERY_DATA.md`, `docs/planning-data/approved_20260802_starting_stat_total20_manual_bonus_contract.json`, `approved_20260802_even_star_stat_escalation_contract.json`, 현행10권 growth overlay와 registry. 구형6권 이름 매핑 재사용 금지.
**설계:** 시작 각2+자유6+시작4권의2성 주능력 각+1=총20. 분배 패널은 선택4권과 같은 setup owner를 사용한다. 모두4인 자동 시작을 유일한 설계로 고정하지 않는다. 영구는 '현재회차 내 영구'이며 계정영구가 아니다.
**구현:** 새 `src/run/player_growth_state.gd` 제안은 base allocation, manual milestone grants, route stat receipts에서 능력view를 계산한다. 2/4/6/8성 주·보조 지급은 승인 JSON을 소비하고 매 로드마다 가산하지 않는다. bridge는 이 view를 engine에 전달한다. 전투 임시감소는 영구 view와 분리한다. 주능력4/8/12 등의 기술 조건은 registry의 현행3/7/10성 계약으로 판정한다.
**저장:** P02 v3 ledger와 결합하되 수련 receipt와 능력 지급 원인을 구별. `grant_id=run:manual:star` 유일. 새 전수3성의2성 지급, 여러성 동시상승, 재도전·복원에서 한 번만. 이전 v1/v2에 새 보너스를 소급 지급하지 않는다.
**기존 경로:** `vertical_slice_shell.gd` setup, `vertical_slice_combat_bridge.gd`, `martial_manual_registry.gd`, `combat_resolution_engine_ten_manuals.gd`, 두 checkpoint codec.
**인수:** 시작합20·분배6정확, 잘못된키/음수/미소진 거부; 3→8 한 번/여러번 결과동일; 주/보조 매핑10권 전수대조; 조건미달 기술만 잠김·수련은 유지; 영구 충족 후 임시감소로 재잠금 안 됨; 현재코어 공식·상대능력 중복가산0. 새 `tests/verify_player_growth_flow.gd` + 기존 registry/codec 회귀.
**준비한 결정:** 지급 이벤트 순서는 시작분배→시작4권보너스→회차취득/성장→행로능력→전투임시효과. 충돌하는 effect를 실제엔진에서 발견하면 정본과 함께 CANON_CONFLICT로 승격한다.

## 8. P04 — 중복 전수 보상

**현재:** progression.pending_duplicate_transfers에 기록만 쌓인다. 새 효과를 지급하지 않는다.
**세 대안:** (A) 중복이면 선택불가, 이유와 다른2보상 유지 — 권장, 새 환율 없음. (B) 현행 자유수련6으로 대체 — 후보, 선택명/receipt와 경제 변경 필요. (C) 해당무공 수련으로 전환 — 보류, 환율·10성초과·효율 설계 비용 큼. 문파전수 비교가치10을 포인트10으로 사용하지 않는다.
**권장 구현:** result model에 `available:bool`, `unavailable_reason_key:String`을 view로 제공; shell은 `이미 보유한 무공`을 표시. domain receipt builder도 unavailable을 거부해 UI 우회 차단. 자유/집중 보상은 현재값 유지. 과거 pending receipt는 역사로 보존하고 소급보상0. 10권보유 상태에도 유효한 보상 존재.
**파일/검증:** `vertical_slice_result_model.gd`, `vertical_slice_shell_result_auto.gd`, progression, `tests/verify_vertical_slice_review_result.gd`. 중복전수 기존저장읽기, unavailable확정거부, 키보드disabled건너뛰기, 선택잠금, 명령중복,10권화면. 의미 변경 Decision 후 새여정 적용범위를 명시한다.

## 9. P05 — 등급 집계와 최종 산식

**현재:** raw5지표는 존재하며 S/A/B/C는 빈값이다. 최종가중치와컷은 승인되지 않았다.
**기존 owner:** `src/run/vertical_slice_battle_metrics.gd`, `vertical_slice_result_model.gd`, `src/combat/combat_review_summary_builder.gd`; `docs/02_COMBAT_RULES_GRADE_FARMING_GUARDRAILS_AMENDMENT.md`와 `approved_20260805_grade_farming_guardrails_contract.json`.
**먼저 가능한 구현 명세:** 새 `src/run/battle_grade_aggregator.gd`가 raw event 복사본을 읽고 `{raw, effective, reasons, formula_version, grade_status, grade}`를 산출. raw를 삭제하지 않는다. canonical source ID/적 행동instance 단위1→0.5→0, 한instance의합+회피총credit≤1, 합/회피각3상한, 기준round기본3, 첫유효절초1회 등 최신guardrail 사용. UI에서 집계하지 않는다.
**산식 선택:** A고정가중치(설명쉬움/빌드편향), B상대별정규화(공정성후보/기준자료필요), C학습모델(불투명·운영비 REJECT). 권장 A의 설명 가능한 버전별 함수를 P12 fixture에 offline 비교하고 필요 시 B로 교정. 측정 전 임의S컷을 확정하지 않는다. 과거85/70/55를 복원하지 않는다.
**인수:** 다단hit로source분할안됨, 사거리밖실제합포함, 지연파밍credit추가0, 무효절초가점0, 같은로그같은결과, raw건수보존, 피해비율0분모처리. 서로다른HP/장기전/회피불가/절초미해금 build에서 불가능한 S조건이 없는지 비교. 조건부 결과는 상세이유로 설명 가능해야 함.
**저장/릴리스:** 당시formula_version과 결과를 기록하고 로드 때 최신산식으로 등급을 바꾸지 않는다. 기존완료기록은 원자료만 표시. 등급과 보상경제 연결은 별도 Decision. 집계완료와 산식최종확정 상태를 분리한다.

## 10. P06 — 행로 사건·조사·능력 보상의 실효성

**기존:** `vertical_slice_route_model.gd`의5종 rotation, run_state.select_jianghu_node, `vertical_slice_shell_route_auto.gd`, `bimu_constraint_model.gd`와 `src/ui/bimu_constraint_panel.gd`.
**보호:** 10전 사이9구간×4선택=36, 매회3갈래. 휴식25%/+1/+1, 수련+3, 사건+2/내력1, 조사+1 등 기존효과는 fixture로 잠근다. 기존작동효과를 미구현으로 분류하지 않는다.
**콘텐츠 설계:** 첫 단계는 existing5종의 표시·이유·현재상태 대비효과를 완성. `event_id/title_key/body_key/effect_id/allowed_stage`를 가진 authored view를 새 `data/run/jianghu_events.json` 제안에 둔다. 문구변형은 원효과동일, 새수치·플롯·조건은별도Decision. 선택전 비용/효과, 선택후 적용량/상한손실/얻은정보를 domain receipt로 표시한다.
**정보:** candidate ID만으로 누적된 이력과 현재 encounter ID의 단서를 구분. 허용무공/보법 단서만 표시; 다음상대전체배열·정답계획·AI가중치 노출0. 이미공개된단서 반복은 중복임을 알리되 자동다른보상변환0.
**영구능력:** 기존8노드 데모의최대2점 공급 계약을36선택에 비례해9점으로 늘리지 않는다. 권장후보는10전전체 최대2회+각1점, 같은구간1회이하, 서로다른2능력중1선택. 이는 공급량 확장 Decision 후보다. 등장단계/확률은 P12로 비교하며 확정 전신규노드 off. 회복/수련/재화복합자동지급금지.
**저장:** 현재 frozen route선택/효과receipt 재사용. authored선택결과와 stat reward id를저장; Continue에서선택지재추첨0. v3까지제약선택·전투효과와상대버프는같은frozenreceipt검사.
**인수:** 각5종실제선택+36경계, 예상/실제증가량일치, 만자원휴식상한, 정보중복, step/stale/연타/저장실패, 동일인물재등장정보격리,10전후추가행로0. 기존 `tests/verify_vertical_slice_route_state.gd`, `verify_variable_recon.gd` 및 새eventcatalog검사.

## 11. P07 — 회차 밖 기록과 도감

**현재:** 완주기록은 현재checkpoint를다시읽는방식이며 새여정교체뒤 무제한기록보관이 아니다. 조사정보도run내부에있다. 영구도감/시작해금/챔피언기록전체가 구현됐다고 주장하지 않는다.
**권장구조:** 초기범위는 로컬발견도감+최근완주요약. 새 `src/profile/player_profile_store.gd` 제안은 run과분리된 `user://profile.json` 및검증백업을관리. `{schema_version:1, revision, discovered_manual_ids, encountered_candidate_ids, completed_run_summaries}`. profile권한은진행중미공개상대명단에접근하지않는다.
**범위결정후 구현:** 완료요약은 run_id 중복방지로 append, 최근20개를 첫 페이지로 제시하는 안을 비교한다. 원본진행run을복제해프로필전체저장하지않는다. profile실패가유효run을삭제/retire시키지않으며 다음안전경계에서같은요약재시도.

20개는 우선 화면 한 페이지 표시량으로만 사용한다. 한도에 도달했다는 이유로 기존 기록을 자동 삭제하지 않는다. 저장 크기 상한·분할 보관이 필요하면 원본 보존과 읽기 경로를 포함해 먼저 결정한다. 현재 사용자 직접 삭제 원칙을 유지한다.
**소비처:** `src/ui/main_title_screen.gd`, `vertical_slice_completion_model.gd`, `vertical_slice_shell_completion_auto.gd`, `approved_blueprint_art.gd`. 새 도감뷰는기존47개원화/인물ID/무공registry재사용. 미발견항목에미공개고유정보를노출하지않는다.
**인수:** 새여정후기존요약열람,동일완주중복0,손상프로필원본보존,정렬안정,새버전거부,시작선택범위/전투능력불변. 영구능력/유료재도전/영구재화는이작업에서추가하지않는다.

## 12. P08 — 첫 플레이 이해·화면·입력 마감

**기존 파일:** `src/ui/game_menu.gd`, `main_title_screen.gd`, `action_selection/action_selection_dock.gd`, `action_detail_panel.gd`, `action_timing_panel.gd`, `combat_review_panel.gd`, `wuxia_ui_style.gd`, run shell전체.
**상태표:** 제목/새여정확인/시작4권·능력/브리핑/준비3·3·4/해결/일시정지/저장오류/패배·재도전/결과/수련/행로/완료/기록. 각상태에서 진입초점·주행동·취소·back·화면복귀·오류문구를한행으로기록한다.
**설계:** 기존선택형규칙안내를첫비무에서필요할때열수있게연결. 원인설명은관찰→실패조건→실제결과, 미래정답추천없음. 키보드·마우스·터치·gamepad는동일domain명령. rawkey와UIaccept중복처리0. 이동·기술배치의취소는확정계획규칙안에서만.
**확인창 진단:** `main_title_screen`의기존embedded ConfirmationDialog에서도발생한focus진단을좁은fixture로재현; same-engine기본dialog와대조. 대안1포커스/수명순서교정 우선, 대안2동일의미Control overlay는순서교정실패때, 대안3엔진버전변경은REJECT(이문제로전체도구변경금지). 취소/확정/반복열기/중단·복귀/창종료해제검증.
**인수:** 960×640,1280×720,1920×1080,2560×1080 및mobilelandscape에서핵심텍스트·버튼겹침0,키보드deadend0,현재초점테두리보임,모든모달닫으면유효초점복귀,소리off에서도판정이해가능. 최소touch48dp의실제물리규모는P11에서측정.
**Human:** 기존목표5명중4명이3사례중2개원인설명. 파일럿목표이며통계적재미검증아님. 자동전투완주시간을사람플레이시간으로쓰지않는다.

## 13. P09 — 모션·무기군·음향

**기존:** `src/combat/character_pose_library.gd`, `combat_character_placeholder.gd`, `src/ui/combat_presentation_profile.gd`, `combat_sound_bank.gd`, `docs/10_COMBAT_PRESENTATION_PLAN.md`, `docs/decisions/2026-09-09_CLASH_STAGING_AND_OUTCOME_DIRECTION.md`.
**순서:** 현재4장실제consumer·출처·상태·크기검수→최종lock→검대표행동군→도/창/맨손/장풍/투척에서기존자산으로표현불가한상태만제작. 인물16×모든기술의전용시트를기본범위로곱하지않는다.
**상태계약:** idle→windup→active→outcome→recovery. 해결event가actor/action/outcome을소유. 합승자/패자,피해/방어/회피/사거리밖/중단/비무종료를구분. 사거리밖합·장풍에검접촉을강제하지않는다. logical이동없으면발이칸을넘는것처럼움직이지않는다.
**자산:** asset_id/state/frame_rect/pivot/source_sha/approval/consumer/fallback을현재catalog에등록. 47개승인원화bytes보호. 이미지모델로필요상태군생성후사용자final lock; 후보성공은정본승격아님. 소리기존bank재사용,중복event재생0·mute/volume/reducedmotion재시작유지. 새음원권리는P14.
**인수:** 양쪽역할반전,효과off/on·motion감소에서판정/저장digest동일; 중단·메뉴·새전투후잔상/음향누적0; 발접지·얼굴식별·720p가림·pivot검사. 기존 `tests/verify_motion_roster_integration.gd` 확장과상태별Windows캡처. 실물출력장치·최종미감은별도검수.

## 14. P10 — 다국어와 읽기 접근성

**기존:** `presentation_preferences.gd`, `game_menu.gd`, `wuxia_ui_style.gd`, run/UI의직접한국어문자열, 인물epithet_key, Godot project.godot.
**새 제안:** `data/localization/ui.csv`, `src/ui/localization_service.gd`, `tests/verify_localization_flow.gd`. stableUI키(`result.reward.confirm`, `route.rest.applied`등)→GodotTranslationServer→문구; 키와파라미터를domain결과에서전달,화면만문자열화한다.
**범위:** ko/en/ja기반, zh-*슬롯은유지하되간체/번체선택확정전완료번역으로표시하지않는다. 한국어fallback,누락키는기계검사에서실패. `%d/%s`등placeholder수/타입과단복수·문장결합을검사한다. 언어설정은run과별도저장.
**변경순서:** 제목/메뉴→setup/briefing→전투/기술상세→결과/행로→완료/도감. 각단계원문동일성검사후pseudo-locale로길이확장.폰트자산은권리확인후추가,글리프누락/줄바꿈/혼합숫자/키보드힌트검사.
**접근성:** 색에만의존하지않는선택/봉인/자원부족·피해구분,글자확대100/125/150%후보를현재responsive와대조,소리/흔들림off대체피드백. 스크린리더전체지원은실제focus/name/readingorder기기검증전주장하지않는다.
**인수:** 언어변경중여정/계획/현재자원불변,재시작설정유지,10권목록/긴영문/한일문구화면범위,번역목록완전성,모든공개ID/savehash불변. 번역품질은각언어Human별도.

## 15. P11 — 플랫폼 adapter와 Android

**정본:** `docs/decisions/2026-08-06_WINDOWS_ANDROID_ADAPTER_ARCHITECTURE_DECISION.md`. 과거의'RunSession없음'문구는현재 `run_session_coordinator.gd` 구현으로갱신한다.
**5경계:** INPUT(logical명령), RESPONSIVE_UI(safearea/layout), APP_LIFECYCLE(pause/back), PLATFORM_SERVICES(필요없는SDK는null), QUALITY_EXPORT(동일renderer와기기별quality).
**새 경로 제안:** `src/platform/input_adapter.gd`, `responsive_adapter.gd`, `lifecycle_adapter.gd`; services/quality는실제필요시추가. 공유코어에OS분기를넣지않는다. `project.godot` InputMap·`export_presets.cfg` Androiddebug추가. 서명비밀은저장소밖.
**인터페이스:** 입력은 `command_requested(command:String,payload:Dictionary)` signal→현재controller; 안전영역 `get_safe_content_rect()->Rect2`; lifecycle은현재session.accepts_commands/suspended/flush_stable을소비. Godotlogicalpx와Androiddp변환을동일숫자로가정하지않는다.
**back 우선순위:** 최상위설명/설정닫기→미확정편집취소→명시pause/종료확인. 이미확정한보상·전투를back으로환불하지않는다. 홈/화면잠금/포커스이탈때안전checkpoint·명령차단,복귀후임의확정0.
**인수:** SDK/JDK/템플릿exact버전진단→debugAPK export→실제설치/콜드스타트→터치로한전과전체여정→back·홈·프로세스종료·복원→노치/시스템바→성능. 기기명/OS/해상도/DPI/빌드SHA와영상기록. emulator/headless/Windows뷰포트는AndroidPASS대체불가. 물리기기부재시PARTIAL로남김.
**호환/롤백:** 동일runDTO/수치/AI결과. 새adapter끄고Windows기존입력회귀. 저장폴더는OS표준user://,PC경로하드코딩금지. 스토어서명·업로드는P14결정뒤.

## 16. P12 — 밸런스 측정과 수정 계약

**기존:** `data/validation/vertical_slice_balance_instrumentation_matrix.json`, `src/validation/vertical_slice_balance_report_runner.gd`, `vertical_slice_balance_public_policy.gd`, `tests/check_vertical_slice_balance_report.py`, `tests/probe_native_ten_duel_campaign.gd`.
**설계:** 새측정프레임워크대신기존report에dimension추가. 인물16×단계10, 보유4/5/10권, 성수해금경계, 자유/집중/전수,회복/정보/수련/사건,방어/회피/공격/절초정책을계층별측정한다. 모든조합전수실행을요구하지않고160기획행검사+각경계fixture+고정seed100개회차캠페인을초기계획으로한다. 실행비용은첫10개로측정해100개완료시간을추정한다.
**출력:** seed/정책버전/인물·단계/보유권수/전투수/승패/소요round/자원잔량/수련입수·소비/선택효과/실패원인。AI정책은공개정보만사용. 무작위정책패배도보존한다.
**판정:** 목표승률을자료없이확정하지않는다. 특정정책이모든문제를우회하거나정보선택이항상무가치한반례를우선조사. 숫자수정은정본데이터·fallback·fixture·content identity·옛저장경로를함께변경. 이작업에서등급보상경제자동연결금지.
**Human인수:** 초심자/전술숙련자를구분해관찰; 원인이해·실수복구·선택이유·플레이시간수집. 자동10승은엔진/흐름증거다. 재미나전체밸런스PASS로확대하지않는다.

## 17. P13 — 저장·안정성·성능·최종 여정

**기존:** run_session/store/두codec, `tests/verify_run_save_store.gd`, `verify_save_entry_isolation.gd`, `verify_variable_save_compat.gd`, `verify_completion_return.gd`, `verify_game_menu.gd`.
**검증설계:** 각stable경계(새여정/준비/확정/해결/보상선택/보상확정/행로선택/완료)마다새프로세스복원. 쓰기실패/손상/unknownversion/정전유사중단/중복terminal/늦은pause/오래된UIcommand를주입. 기대값은원본보존·중복해결/보상0·미공개정보불변.
**진단마감:** 알려진Windows확인창focus(P08),편집기종료ObjectDB/resource로그를재현fixture별로구분. 고의손상fixture의예상parseerror와실제누수오류를따로기록. warning0문구를검사성공으로조작하지않는다.
**성능:** 승인엔진동일빌드,대표기기에서coldstart/화면전환/저장시간p50·p95·최대/메모리/프레임시간을측정. 임시합격목표는주요조작프레임연속멈춤없음과10전반복후메모리증가추세없음; 최종ms/MB예산은P11대표기기측정후결정.16장원화동시decode를기본구조로하지않는다.
**최종인수:** Windows native한회차에미보유전수·수련소비·정탐·휴식·실제실패/재도전·저장오류복구·완료→제목→기록을포함. 입력별/Android별/Human별상태를따로기록. 코드checkPASS→runtimePASS→HumanPASS→releasePASS를합치지않는다.

## 18. P14 — 배포·권리·출시 준비

**owner:** `docs/PLATFORM_RELEASE_AND_ASSET_RIGHTS_PROFILE.md`, `docs/ASSET_RIGHTS_AND_PROVENANCE_RECORD.md`, `docs/GAME_RELEASE_COMPLIANCE_EVIDENCE_PACK.md`, `export_presets.cfg`.
**구현/자료:** 실제export파일목록과hash에서사용이미지/폰트/음악/효과음/plugin/license를추적. 생성일·서비스·약관증거·입력reference·출력사용권·attribution을asset단위연결. 빈원장/승인원화선정은권리확보증거가아니다.
**배포물:** 버전표시/오류로그위치/저장경로/기본조작/credits·license/복구설명. 테스트fixture·debug전용파일노출을확인. 현재Windows artifact는제품검증빌드로표시하고release후보와구별.
**출시 인수:** 대표빌드와스토어이미지/설명/등급설문/AI사용공개가동일콘텐츠를설명. 실제제출직전에플랫폼공식요건재조회. 이명세는현재법률판단·등급확정·스토어제출행위가아니다.
**의존/실패:** 권리UNKNOWN자산은교체후재검증하거나릴리스차단. 파일직접삭제대신사용자삭제대기로보관. 비용·서명키발급·외부공개·스토어제출은명시결정후실행.

## 19. 분리해 준비한 결정 묶음

| 결정 | 권장안 | 확정 전 가능한 작업 | 필요한 확정 근거 |
|---|---|---|---|
| 수련 관리시점/저장 | JIANGHU·BRIEFING 관리, 새여정v3 | P01회귀·v1/v2fixture보존·배분preview명세 | 기존저장재구성대조,UI확인,version Decision |
| 중복전수 | 중복선택불가+다른보상유지 | 현재pending역사보존·화면반례 | A/B/C효율·플레이어이해 비교 |
| 등급 | raw/유효집계분리 후설명가능산식 | 승인guardrail집계·offline비교 | 정책별편향/파밍반례/컷명세 |
| 능력보상36행로 | 공급확장없이전체최대2점후보 | 현재노드효과완성 | 8노드원계약과신규공급결정 |
| 회차밖보존 | 발견도감+최근20요약 첫 페이지 후보, 기존기록보존 | run/profile경계·복원fixture | 기록보관범위·사용성 |
| 중국어 | zh-*준비,variant확정후번역 | 키/폰트coverage검사 | 실제대상독자·번역검수 |
| 장기확장 | 온라인/시즌/추가보스/시장별도보류 | 가설별기존owner연결 | 현재10전Human결과·비용·새core범위 |

새로운판단이필요한항목을감추지않되,이표의결정대기때문에P01·검증·가독성교정을멈추지않는다. 제작완료를수치선택이나final lock승인으로간주하지않는다.

## 20. 이번 명세의 외부 조사

CURRENT_SOURCE_RELEVANCE_CHECK: REQUIRED. 2026-09-14 공식본문재조회. 비교차원은성장선택의실효성,원인학습,가독성,저장복구,입력·플랫폼마감이다. 외부게임의내부코드·밸런스성공원인을검증했다고주장하지않는다. 공식소개는제품사실만,패치/FAQ는제한된문제신호다. 사용자리뷰대표표본수집은NOT_RUN. 각행의원리/전이는본프로젝트설계추론이다.

| 사례/분류 | 공식사실·공개공백 | mechanism→전이 / 판정 / DO_NOT_COPY |
|---|---|---|
| [Shogun Showdown](https://store.steampowered.com/app/2084000/Shogun_Showdown/) 직접 | 위치·타이밍·공격업그레이드, 다국어지원표 | 성장으로실제선택변화→P01/P02 ADAPT; 덱/타일/일본배경복제금지 |
| [Tactical Breach Wizards](https://store.steampowered.com/app/1043810/Tactical_Breach_Wizards/) 직접 | 자유rewind와조합실험 | 결과를보고학습→P08복기 ADAPT; 우리확정계획rewind도입 AVOID |
| [Into the Breach](https://store.steampowered.com/app/590380/Into_the_Breach/) 직접 | 적공격전조와대응,무기/파일럿 | 정보와선택관계→P06공개단서 TEST; 적계획전면공개 AVOID |
| [Fights in Tight Spaces](https://store.steampowered.com/app/1265820/Fights_in_Tight_Spaces/) 직접 | 턴전술·애니메이션·사건·향상/부상 | 사건선택이다음전투에영향→P06 ADAPT; 카드덱/부상규칙복제금지 |
| [Knights in Tight Spaces](https://store.steampowered.com/app/2315400/Knights_in_Tight_Spaces/) 인접 | 전술·강한연출·팀시너지 | 의미식별연출→P09 TEST; 파티/팀공격추가 AVOID,내부모션계약공개공백 |
| [Slay the Spire](https://store.steampowered.com/app/646570/Slay_the_Spire/) 인접 | 위험/안전경로와조합선택 | 상태별가치차→P12선택측정 ADAPT; 덱/손패/드로우/유물경제 AVOID |
| [Celeste 변경기록](https://www.celestegame.com/changelog.html) 인접·혼합 | 메뉴키중복규칙,스크롤중조작힌트가시성수정 | 재매핑후탈출경로보존→P08/P11 ADAPT; 플랫폼게임이동규칙금지 |
| [Hades FAQ](https://www.supergiantgames.com/faqs/hades/) 인접·문제신호 | 설정/진행분리·저장실패·복구·controller문제안내 | 내구성/복구검증→P07/P13 ADAPT; 보안비활성화조언·실시간전투·클라우드의존 AVOID |
| [The Last of Us II 접근성](https://www.playstation.com/en-us/games/the-last-of-us-part-ii/accessibility/) 인접 | HUD크기/배경/색/점멸·고대비선택 | 중요정보대체표현→P10 ADAPT; 자동조준/난도변경복제금지 |
| [Ratchet & Clank 접근성](https://support.insomniac.games/hc/en-us/articles/46716208107795-What-Accessibility-options-does-Ratchet-Clank-Rift-Apart-feature) 인접 | 배경/상호작용요소고대비·shortcut | 입력/정보접근→P08/P10 TEST; 대규모3Dshader체계 AVOID |

직접4·인접6·혼합/문제신호2. 성공률/흥행은이번비교로추론하지않는다. 신규등급수치·경제·온라인설계는이표만으로RESEARCHED최종확정이되지않는다.

기술근거: [Godot 국제화](https://docs.godotengine.org/en/stable/tutorials/i18n/internationalizing_games.html), [Android export](https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_android.html), [controller 입력](https://docs.godotengine.org/en/stable/tutorials/inputs/controllers_gamepads_joysticks.html). stable설명은프로젝트exact4.7.1의실행성공이나기기검증이아니다. 각작업실행전최신요건과설치도구를다시확인한다.

## 21. 실행 기록과 문서 인수

기준SHA fb565eb1 / Work Mode PLAN→REVIEW / Skill `combat-implementation-handoff` / Mode implementation-contract; 설계/계획스킬과 Base adversarial-review 적용.
수행: 최신AGENTS·계약·currentowner·실제consumer·PRmetadata·10개공식게임자료대조,기존완료/실제공백/신규결정/기기검증분리. 결과: 이명세와currententrypoint연결. 제품수정·새asset·엔진실행 없음.
새 코드의runtime/Human/Android/release는 NOT_RUN. 명세 준비가 각 작업의 구현 승인·완료를 뜻하지 않는다.

### 두 차례 전체 명세 검토

현재 작업 위치의 최신 AGENTS와 2026-09-09 결정은 정확히2회 전체 검토를 지정한다. 바깥 구형 checkout의5회 문구를 현재 계약으로 사용하지 않았다. 이번에는 제품 개선의 과거 회차를 재명명하지 않고, 새 사용자 요청인 '남은 작업 명세' 전체를 검토했다.

1. **초안 전체→교정안:** P00~P14, current owner, 실제 run/bridge/codec/progression, UI·자산·플랫폼·출시 경계, 세 구조 대안, 기존34 CI의 증거 범위를 모두 대조했다. 재구성 저장에 수련 배분만 추가하면 지급과 소비의 시간 순서가 유실되는 누락을 확인해 v3 공통 사건 순서 명세를 보강했다. 기록20개 제한은 자동 삭제로 이어질 수 있어 표시 페이지량으로 바꾸었다. 다른 제품 코드 변경 없이 원칙·인터페이스를 수정하고 전체 범위에 같은 순서·보존 계약을 적용했다.
2. **교정안 전체→인수본:** 전체15개 작업의 의존성·정본·실재/제안 파일·수치/승인 경계·예외·저장·UI·자산·기기/출시 인수·비용·롤백·미변경 제품을 재검토했다. 확인한45개 전체 경로 중 부재12개는 모두 명시적인 신규 제안이었다. P01은 시작이력 유지, P02/P03/P06은 v3 의미 결정, P04/P05는 후보 정책, P07은 원본 보존, P08~P14는 기계와Human/권리 경계를 유지한다. 전체 재작성·새 SDK·전용16인 전체모션 확대보다 기존 owner 연결이 적합하다. 명세 자체에 추가 차단 결함은 발견하지 못했으며 제품 미완료는 작업표에 남겼다.

문서 검사: canonical reference freshness PASS, governance/retry-save22개 PASS, JSON parse PASS, git diff whitespace 검사 PASS. 운영 계약 진입 검사 PASS. 이들은 명세/기존 계약 검사이고 새 P01~P14 제품의 실행 검증이 아니다. 이번 제품·자산 보호 경로 diff는0이다.

후속 원격 검사에서 current JSON의 새 priority 배열을 한 줄로 작성한 형식 오류가 검출됐다. 규칙/값 변경 없이 기존 canonical pretty-print 형식으로 교정하고 `tests.test_poc_planning_data`의 동일 검사를 재실행한다. 이 교정은 전체 검토 회차를 초기화하지 않는 문서 형식 회귀이며, 이후 JSON owner 편집의 필수 관련 검사에 포함한다.

### 구현자가 공통으로 실행할 검증

```text
python -X utf8 tools/check_canonical_reference_freshness.py
python -X utf8 -m unittest tests.test_project_governance tests.test_poc_retry_save_contract
<approved Godot binary> --headless --path . --script res://tests/<해당 작업에 명시한 검사>.gd
```

Godot경로/해당검사실재성은실행시확인한다. RED는원결함을실제로재현해야하며파일미존재/parse실패를제품결함RED로대체하지않는다. narrow회귀→인접저장/도메인→Windows실제입력→exactHEADCI→권한/자산조건충족시merge→mainreadback. 테스트산출물은소유·참조·복구경로·hash확인후삭제대기로옮기고직접삭제하지않는다.
