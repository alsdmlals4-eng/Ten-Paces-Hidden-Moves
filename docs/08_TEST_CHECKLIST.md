# 십보강호 테스트 체크리스트

> 책임: 최신 승인 기획의 정적·자동·Godot·Windows·접근성·네트워크·사람 증거와 완료 주장  
> 태그·상태: `docs/00_TAG_STATUS_REGISTRY.md`  
> 규칙 원본: `docs/02_COMBAT_RULES.md`  
> PoC 범위: `docs/05_COMBAT_POC_SPEC.md`  
> 성장 원본: `docs/06_STARTING_FACTION_MASTERY_DATA.md`  
> 자동 제품 검증 증거 기준: 최신 상태는 GitHub `main`과 실제 검증 결과를 fresh-read한다. `7494f50c48573168542781e007eeab6af11dda7d`는 기존 자동 제품 검증의 역사 기준이며, 최신 첫 5전 Vertical Slice 증거를 뜻하지 않는다.

## 1. 판정 상태

검증 종류마다 `PASS / PARTIAL / FAIL / NOT_RUN / BLOCKED / UNVERIFIED`를 따로 기록한다. 파일 존재·정적 검사·자동 테스트·Godot·Windows·접근성·네트워크·사람 이해는 서로 대체하지 않는다.

## 2. 현재 증거 요약

```yaml
legacy_t0_runtime:
  implementation_status: IMPLEMENTED_LEGACY
  automated_validation: PASS
latest_planning_contract:
  authority_status: CURRENT_APPROVED_PLANNING
  implementation_status: FIRST_FIVE_DUEL_PHASE_I_VI_MERGED_AUTOMATED_GREEN
  automated_validation: PASS
  godot_validation: PASS
action_selection_dock:
  implementation_status: IMPLEMENTED_CURRENT
  automated_validation: PASS
  windows_validation: NOT_RUN
  human_validation: NOT_RUN
app_flow_shell:
  implementation_status: FIRST_FIVE_DUEL_PHASE_I_VI_MERGED_AUTOMATED_GREEN
  automated_validation: PASS
  godot_validation: PASS
  windows_visible_human_validation: NOT_RUN
opponent_runtime_personality_binding:
  implementation_status: IMPLEMENTED_AUTOMATED_GODOT_VERIFIED_AWAITING_ISSUE267_PR
  automated_validation: PASS
  godot_validation: PASS
  windows_visible_human_validation: NOT_RUN
  human_validation: NOT_RUN
  android_device_validation: NOT_RUN
ranked_online:
  scope_status: FUTURE_ONLINE
  implementation_status: BLOCKED_NOT_AUTHORIZED
  network_validation: NOT_RUN
human_step14: NOT_RUN
```

기존 T0의 체력·공격력·방어력·절대 원공격력 수치는 최신 기획 검증 기준이 아니다. 레거시 회귀 검사는 별도 fixture로 유지한다.

## 3. 정본·태그·범위

- [ ] 최신 Decision ID가 `docs/00~08`, Active Context, Roadmap, planning JSON, Google Sheet에 일치한다.
- [ ] 관찰 공개 종류가 `[전조] [이동] [공격] [방어] [회피] [준비] [자원] [관찰]`로 통일된다.
- [ ] 사용자 표시 `태세`가 신규 정본·UI에 남지 않는다.
- [ ] `[전조]`가 강화 효과 없는 점유·표시 단계로 처리된다.
- [ ] 개발용 AI archetype·fixture 태그가 사용자 화면에 노출되지 않는다.
- [ ] 권위·범위·구현·검증 상태를 한 문자열로 합치지 않는다.
- [ ] 기획 승인만으로 구현·사람 검증 완료를 주장하지 않는다.

## 4. BOARD-002 밀착·공동 목적지 — 전장·점유·대상

- [ ] 전장 1~10, 플레이어 4, 상대 6, 플레이어-facing 시작 공개 거리 2.
- [ ] 같은 칸 거리 0은 `[밀착]`.
- [ ] 공동 빈 목적지와 정지 상대 칸 진입 허용.
- [ ] 자리 교환·상대 통과·전장 밖 이동 금지.
- [ ] 방향·사거리·목적지 실패 이유가 구조화 이벤트와 UI에 남는다.
- [ ] 대상 부재·방향 실패·사거리 실패가 적중 이벤트를 생성하지 않는다.

## 5. 라운드·계획 잠금

- [ ] 한 라운드가 `3수 → 3수 → 4수`로 분할된다.
- [ ] 현재 묶음만 편집하고 `[행동계획 실행]` 뒤 전투·해결 애니메이션으로 전환하며, 실행한 묶음은 다시 편집하지 않는다.
- [ ] 다중 수 행동은 앞 슬롯 `[전조]`, 마지막 슬롯 `[실행]`이다.
- [ ] 첫 전조에서 비용을 선지불하고 중단·실패에도 환불하지 않는다.
- [ ] 적은 현재 묶음만 계획하며 미래 묶음을 미리 생성하지 않는다.
- [ ] 적 계획은 관찰 공개 전에 확정·잠금된다.
- [ ] 공개 뒤 적이 행동을 교체하지 않는다.
- [ ] 적 AI 입력에 플레이어 미확정 슬롯·대상·방향·UI 상태가 없다.

## 6. `[관찰]`

- [ ] 본편 기본 관찰 1회가 고정 관찰량 1을 제공한다.
- [ ] 관찰량 저장·획득 상한이 없다.
- [ ] 남은 관찰량이 다음 묶음·다음 라운드로 이월된다.
- [ ] 미래 묶음을 관찰 때문에 미리 생성하지 않는다.
- [ ] 공개는 앞 수부터 적용된다.
- [ ] 복합 기술은 실제 구성 종류를 모두 표시한다.
- [ ] 기술명·무공서명·비용·방향·거리·피해·사거리·대상·AI 가중치를 누출하지 않는다.
- [ ] 적 AI는 관찰을 사용하지 않는다.

## 7. 스테이터스·기술 작성

- [ ] 영구 스테이터스가 외공·근골·신법·내공·심안 5종이며 범위 1~15다.
- [ ] 초기 스테이터스와 기술 배수의 밸런스 기준이 4다.
- [ ] 시작 총점·직접 분배량은 미확정으로 표시된다.
- [ ] 기술 작성 순서가 구조·비용→태그→고정 기본치→주/보조 능력치 배수→5/9성 patch·임계다.
- [ ] 관찰·이동·회피·준비의 기본 효과는 고정 전용이다.
- [ ] 그 외 연속 수치 효과는 최소 1개 능력치 참조를 가진다.
- [ ] 한 효과의 능력치 참조는 최대 주1·보조1이다.
- [ ] 태그·고정치·능력치 배수·조건·비용이 별도 ledger 행이다.
- [ ] 배수 단위가 0.25다.
- [ ] 배수 틱이 `ceil(효과1점가격 × 배수 × 4)`로 계산된다.
- [ ] 주·보조 능력치에 할인 차이가 없다.
- [ ] 실제 값이 고정치와 모든 능력치 항을 합산한 뒤 한 번 내림된다.
- [ ] 기술을 스테이터스 1·4·15에서 sanity 검사한다.
- [ ] 중앙 가격 변경이 기존 기술을 자동 수정하지 않는다.

## 8. 기초 행동·자원

- [ ] 최신 기초 행동이 이동·보법·막기·회피·속공·강공·관찰·명상·준비·장풍 10종이다.
- [ ] 현재 런타임 8종과 최신 기획 10종을 완료 상태로 혼동하지 않는다.
- [ ] 속공·강공은 고정 피해+외공 참조다.
- [ ] 장풍은 2수·내력1·사거리1~3·밀치기 없음이며 `floor(3 + 내공 × 0.75)`를 사용한다. 동일 능력치에서 속공보다 반드시 낮아야 한다는 구형 제약은 없다.
- [ ] 속공 `floor(3 + 외공 × 0.50)`, 강공 `floor(7 + 외공 × 1.00)`, 장풍 `floor(3 + 내공 × 0.75)`의 fixed/계수는 최신 승인 정본과 runtime structured data가 모두 같은 값을 사용한다.
- [ ] 기력은 라운드 시작 +1, 내력은 자연 회복하지 않는다.
- [ ] 비용 부족·연속 슬롯 부족·대상 부재가 진행 전에 설명된다.
- [ ] UI가 비용·피해·방어·회복을 독립 계산하지 않는다.

## 9. `[준비]`·`[강화]`

- [ ] 준비가 독립 행동이고 전조와 구분된다.
- [ ] 이동·보법은 준비 상태를 소비하지 않는다.
- [ ] 다음 공격에 원공격력 +2와 강건을 적용한다.
- [ ] 다음 명상에 절초기세 +1을 추가한다.
- [ ] 막기·회피·기타 비이동 행동은 준비 상태를 소비한다.
- [ ] 준비 기본 강화는 연속 스테이터스 배수를 사용하지 않는다.

## 10. CLASH-001 기본 합 — 합·방어·회피·필중

### `[합]`·연격

- [ ] `[연격 N]`이 최종 총피해를 N개 피해 단위로 분할한다.
- [ ] 총피해가 N보다 작으면 0 피해 단위 없이 유효 횟수를 축소한다.
- [ ] 양측 유효 공격의 현재 순번 피해 단위끼리 앞에서부터 합한다.
- [ ] 합 패배는 패자의 현재 피해 단위만 취소하고 동점은 양측 현재 피해 단위만 상쇄한다.
- [ ] 현재 순번 정산 뒤 양측 체력 피해가 0이고 두 공격 행동이 유지되며 다음 피해 단위가 있으면 다음 순번도 합한다.
- [ ] 체력 피해로 한쪽 공격이 중단되면 그쪽 미실행 후속 피해 단위를 취소한다.
- [ ] 강건이 중단을 막아 공격을 유지하면 다음 순번 합을 계속할 수 있다.
- [ ] 한쪽 피해 단위 목록이 끝나면 상대의 유지된 잔여 피해 단위가 단독 타격으로 해결된다.
- [ ] 비교값은 방어·회피 전 원공격력이다.
- [ ] 합 승리 절초기세는 여러 합 승리와 무관하게 공격 행동당 전투원별 최대 +1이다.
- [ ] 사거리 밖에서도 현재 순번 합은 진행한다.
- [ ] 사거리 밖 합 승자는 절초기세와 `ON_CLASH_WIN`을 얻지만 해당 피해 단위의 체력 피해·`ON_HIT`·`ON_HEALTH_DAMAGE`는 발생하지 않는다.
- [ ] 사거리 밖에서 양측 체력 피해가 0이고 두 공격이 유지되면 다음 순번도 합한다.
- [ ] 예시 `[8,5,7]` 대 `[6,7,4]`에서 방어로 체력 피해가 계속 0이면 1·2·3타가 순차 합한다.

### 방어·회피·`[필중]`

- [ ] 방어도는 피해 단위마다 고정 감산하고 피격으로 소모되지 않는다.
- [ ] 방어도는 라운드 종료 시 0이다.
- [ ] 방어도로 체력 피해가 0이면 피해 기반 중단이 없다.
- [ ] 기본 회피 1회가 피해 단위 1개를 제거한다.
- [ ] 회피가 해당 피해 단위의 회피 가능 부가효과도 무효화한다.
- [ ] 밀치기는 방어로 피해 0이어도 적중이면 적용될 수 있다.
- [ ] 밀치기 피해 단위를 회피하면 밀치기가 적용되지 않는다.
- [ ] 필중은 회피만 무시한다.
- [ ] 예약 필중은 실제 회피를 우회한 유효 공격 효과에만 소비한다.

## 11. AI-001 공개 정보 입력

- [ ] AI는 공개 상태·보유 기술·해결 이력·결정적 seed만 사용한다.
- [ ] 플레이어 미확정 계획·UI 상태·hover·포커스를 읽지 않는다.
- [ ] 관찰 공개 뒤 잠긴 묶음을 교체하지 않는다.
- [ ] AI 가중치·선호 행동·정답 파훼법을 자동 공개하지 않는다.
- [ ] 고정 bundle fixture는 AI 비활성 테스트 경로에서만 허용한다.
- [x] 15 candidate→5 reusable profile mapping, deterministic total-preserving stats, invalid binding fail-closed (`verify_vertical_slice_opponent_runtime_binding.gd`, static contract).
- [x] resolver public history가 execution-only approved six fields만 oldest-to-newest 최대 6개 보존하고, counter profile이 최신 player record 둘만 읽는다 (`verify_phase2_combat_resolution.gd`, AI/binding verifiers).
- [x] bound AI의 legal focus bonus, range retreat/approach, 3/3/4 non-overlap sequence, unbound default regression, private plan/UI/observation input exclusion.
- [x] retry rebuild와 second combat engine 사이 candidate/stats/planner trace 격리.
- [ ] Windows-visible behavior readability, accessibility-user fairness, Android device, Human Player Experience, release performance, balance simulation.

## 12. 적중·중단·강건

- [ ] `ON_CLASH_WIN`, `ON_HIT`, `ON_HEALTH_DAMAGE`가 분리된다.
- [ ] 여러 순번 합 승리가 발생할 때 합 승리 사건은 모두 기록하고 절초기세는 공격 행동당 최대 +1이다.
- [ ] 방어로 체력 피해 0이어도 회피되지 않은 유효 공격은 `ON_HIT`이다.
- [ ] 체력 피해 1 이상일 때만 `ON_HEALTH_DAMAGE`다.
- [ ] 효과 scope·trigger·condition의 정상·중복·취소 경계를 검사한다.
- [ ] 체력 피해를 동반한 유효 중단이 미실행 후속 피해 단위를 취소한다.
- [ ] 강건은 중단 1회만 막고 피해·효과·KO를 되돌리지 않는다.
- [ ] 체력 0 이후 남은 피해 단위와 비필수 후속 효과를 생략한다.

## 13. RESTART-001 완전 초기화 — 종료·재시작

- [ ] 라운드 1~3에는 결착 피해가 없다.
- [ ] 라운드 4 종료부터 양측 동시 피해가 적용된다.
- [ ] 피해가 `최대 체력×10% + 5×(라운드-3)`과 일치한다.
- [ ] 방어·회피·피해 감소·무적·일반 반격을 무시한다.
- [ ] 3묶음 해결→상태 정산→승리 판정→결착 피해→승리 판정 순서다.
- [ ] 동시 KO는 결착 직전 체력 비율→해당 라운드 유효 체력 피해→무승부 순서다.
- [ ] 패배 시 전투 직전 `RunState`와 같은 seed를 복원한다.
- [ ] 같은 전투 재도전 비용 1→2→3, 3 상한이다.
- [ ] 다른 전투 진입 시 비용 단계가 초기화된다.
- [ ] 피해·임시 자원·미획득 보상은 롤백된다.
- [ ] 영구재화 지불은 롤백되지 않는다.
- [ ] 보상·저장·재도전 transaction이 이중 commit되지 않는다.

## 14. 전투 종료 등급

- [ ] 핵심 원자료가 회피 성공·합 승리·플레이어가 잃은 체력·라운드 수·절초 사용 5개다.
- [ ] 연격 대 연격에서 발생한 실제 순번별 합 승리 사건을 기록한다.
- [ ] 사거리 밖 합 승리도 합 승리 횟수에 포함한다.
- [ ] 기존 위협 대응30·전술 실행25·자원15·피해 관리15·공개 과제15가 비활성이다.
- [ ] 기존 S85/A70/B55/C0이 비활성이다.
- [ ] 동일 위협 100%→50%→0% 감쇠가 새 등급 산식에 자동 적용되지 않는다.
- [ ] 합 승리 원자료의 상한·정규화·파밍 방지가 미확정으로 표시된다.
- [ ] 전투 종료 등급과 온라인 시즌 랭킹을 혼용하지 않는다.

## 15. 무공서·성장

- [ ] 무공서는 1~10성, 시작 무공은 3성이다.
- [ ] 3→10 비용 2/3/4/5/6/8/10, 총 38이다.
- [ ] 2·4·6·8성 고정 스테이터스 보너스가 무공별로 고정된다.
- [ ] 3·7성 신규 기술, 5·9성 기본 강화+임계, 10성 절초 구조가 일치한다.
- [ ] 기술별 별도 수련도·수련포인트가 없다.
- [ ] 신규 기술 요구 스테이터스가 최대 2종이다.
- [ ] 스테이터스 미달 기술만 잠기고 수련은 계속된다.
- [ ] 조건 충족 시 추가 비용 없이 자동 활성화된다.
- [ ] 전투 중 임시 스테이터스 감소가 이미 익힌 기술을 재잠금하지 않는다.
- [ ] 집중 경로에서 주요 비무 5 전 10성 도달 가능성을 검증한다.

## 16. 강호행로·콘텐츠

- [ ] 데모 주요 비무 5슬롯, 슬롯당 후보 3명이다.
- [ ] 첫 비무는 후보 3명 중 1명 seed 선정이다.
- [ ] 이후는 후보 3명 중 2명을 경로 종착점으로 제시한다.
- [ ] 각 구간 실제 방문 노드가 정확히 2개다.
- [ ] 네 구간 중간 노드 총 8개다.
- [ ] 같은 seed가 같은 후보·노드 그래프를 재현한다.
- [ ] 노드가 다음 비무 계획을 바꿀 회복·성장·정보·위험을 제공한다.
- [ ] 5번째 비무 뒤 데모 결과 화면으로 종료한다.
- [ ] 15~22분 목표와 피로·이탈을 기록한다.

## 17. App Flow Shell·ActionSelectionDock

- [ ] BOOT→MAIN→RUN_SETUP→ROUTE→NODE→BRIEFING→COMBAT→REVIEW→RESULT→REWARD/RETRY 흐름.
- [ ] App Root가 화면 전환과 입력 잠금을 소유한다.
- [ ] `RunSession`과 `SaveService` 책임이 분리된다.
- [ ] `CombatState`는 Combat Scene이 소유한다.
- [ ] 시작 무공 6중4 선택의 취소·확정·불가 이유가 명확하다.
- [ ] Route·Node·Briefing에서 빈 데이터·죽은 경로·seed 불일치를 복구한다.
- [ ] Combat 진입·복귀가 회차 상태를 중복 적용하지 않는다.
- [ ] `[기초] [무공] [절초]` 출처가 분리된다.
- [ ] 무공서는 직접 배치하지 않고 해금 기술만 배치한다.
- [ ] 가장 앞 유효 연속 수 자동 배치와 연결 블록 이동·제거가 동작한다.
- [ ] 절초기세 예약·진행 전 환불·진행 뒤 무환불이 일치한다.
- [ ] 키보드·마우스·게임패드 focus가 복원된다.
- [ ] 1280×800·1440×900·16:9 safe area를 확인한다.

## 18. 천하제일인·챔피언 배틀 기획 검증

- [ ] 주요 비무 10전 뒤 후보 2명을 처음 공개하고 1명을 선택한다.
- [ ] 회차 중 후보를 미리 예고하지 않는다.
- [ ] 천하제일인 승리 시 고정 `Champion Build Snapshot`을 만든다.
- [ ] 등록 AI는 해당 천하제일인전 한 경기만 학습하고 고정된다.
- [ ] 공식 랭킹전 양측 관찰이 비활성화된다.
- [ ] 관찰 의존 효과에 동일·공개·버전 고정 공식 변환표를 적용한다.
- [ ] 등록 스냅샷 원본을 수정하지 않는다.
- [ ] 정보 공개·상대별 가변 보정·AI 전용 특혜·숨은 승률 보정이 없다.
- [ ] 변환 누락·버전 불일치는 공식 랭킹 진입을 fail closed한다.
- [ ] 자기 등록본·친선전은 공식 평점에 반영하지 않는다.

정확한 변환 수치·평점 공식·시즌 길이·매칭·서버·보안은 별도 승인 전 `NOT_RUN / BLOCKED_NOT_AUTHORIZED`다.

## 19. 정적·자동 검사

- [ ] 모든 planning JSON 파싱·canonical pretty-print.
- [ ] ID 고유성과 참조 무결성.
- [ ] 허용 태그·상태 enum 검사.
- [ ] Decision ID와 책임 원본 교차 참조.
- [ ] 레거시 수치가 최신 승인 필드로 오인되지 않는다.
- [ ] 현재 순번 피해 단위 합→체력 피해·중단 정산→다음 순번 합의 조건이 모든 활성 문서에 일치한다.
- [ ] `첫 피해 단위만 합`, `첫 합 실패 시 후속타 전부 취소`, `후속타는 다시 합하지 않음`이 활성 정본에 남지 않는다.
- [ ] 관찰 공개 토큰에 태세가 남지 않는다.
- [ ] 능력치 배수 가격 기준 4와 배수 단위 0.25가 JSON·문서·Sheet에 일치한다.
- [ ] AI 입력 경계·동일 snapshot/seed 결정성.
- [ ] 성장 비용·도달 경로·임계 효과 재계산.
- [ ] false-pass 회귀 차단.
- [ ] PR exact-head에서 Full Validation·PR Validation·Base Adoption을 확인한다.
- [x] Issue #267 local exact implementation head `e5631e8b0e324020fa82c36aac04882f1b250f5d`에서 static checks, Python 419, affected Godot 19 scripts, headless editor parse를 수행했다. PR CI/review/merge/readback은 아직 수행 전이다.

## 19A. 초기 10권 자동 제품 검증

- [x] 계약·validator 변조 테스트.
- [x] 10권 × 3·5·7·9·10성 = 50개 시나리오.
- [x] Windows x86_64 Release export.
- [x] export된 실행 파일 Windows CI runtime.
- [x] 1280×800·1440×900·1920×1080.
- [x] 키보드·마우스 합성 입력.
- [x] 포커스·레이아웃·자동 접근성.
- [x] 성능 baseline 캡처.
- [x] evidence SHA와 artifact metadata 검증.
- [ ] 로컬 Windows 렌더.
- [ ] 실물 게임패드.
- [ ] 접근성 사용자.
- [ ] Release 성능.
- [ ] STEP 14 참가자 5명.

현재 판정: `PARTIAL_AUTOMATED_COMPLETE`; `7494f50c48573168542781e007eeab6af11dda7d` / workflow `31068098197` / artifact `8954602789`.

## 20. STEP 14 사람 플레이

- [ ] 신규 플레이어 5명.
- [ ] 4명 이상 치명적 차단 없이 데모 흐름 완료 또는 이탈 이유 기록.
- [ ] 4명 이상 3/3/4와 결정적 원인을 설명.
- [ ] 3명 이상 상대 가능 행동을 조사·추론.
- [ ] 3명 이상 노드 선택 뒤 다음 계획 변경.
- [ ] 3명 이상 재도전에서 계획 변경.
- [ ] 순차 합·중단·잔여 단독타의 원인을 설명.
- [ ] 색·모션·음향 단일 채널 의존 없음.
- [ ] 행동 관찰과 인터뷰 응답을 분리한다.
- [ ] 결과를 본 뒤 성공 기준을 변경하지 않는다.

현재 `human_validation: NOT_RUN`이다.

## 21. T1 진입 게이트

- [ ] App Flow Shell 자동·Godot 검증.
- [ ] Windows 실제 실행.
- [ ] 접근성·해상도·성능 검증.
- [ ] STEP 14 사람 플레이.
- [ ] 두 번째 상대·노드 반복 제작 증거.

현재 `t1_greenlight: NOT_GRANTED`다.

## 22. 종료 보고

```yaml
authority_status:
scope_status:
implementation_status:
static_validation:
automated_validation:
godot_validation:
windows_validation:
network_validation:
accessibility_validation:
human_validation:
exact_head_sha:
remaining_gaps:
```

체크박스 존재를 실행 증거로 사용하지 않는다. Demo Ready는 Godot·Windows·접근성·성능·사람 검증 전까지 `NO`다.

## 23. Issue #258 Phase 2 자동 검증 (병합 전)

- [x] `4/6 → 거리2`, 3/3/4, 10종 기초 행동, 구조화 사거리/오능력치 피해 공식.
- [x] `행동계획 실행` CTA와 실행 중 계획 편집 불가.
- [x] 공개 상태 AI의 장풍 후보 및 관찰 제외.
- [x] 관찰점·행동 유형만 공개·비공개 필드 누출 금지.
- [x] 첫 패배의 실제 복기 원인·동일 시드 1회 재시도·승리 1회 커밋·두 번째 패배 무보상 종료.
- [ ] Windows visible 마우스/키보드/게임패드, 긴 한국어, reduced motion 실제 검증 (`NOT_RUN`).
- [ ] 접근성 사용자, Android 실기기, Human Player Experience, Release 성능 (`NOT_RUN`).
