# P02 자유 수련 배분 구현 계획

기준1932e10b / Work Mode PLAN→BUILD→REVIEW / Skill brainstorming(architectural), writing-plans, test-driven-development, combat-implementation-handoff(build). 사용자 최신 지시는 권장 명세 순서대로 조사·구현·개선을 중간 재승인 없이 계속하는 것이다. 명세 owner는 `docs/implementation/REMAINING_GAME_IMPLEMENTATION_SPEC.md`6절이다. 이 계획은 같은 owner를 실제 파일·실행 순서에 연결하며 새 기획 정본을 만들지 않는다.

## 목적·구조·가능성

자유 수련을 보유 무공에 배분하고 실제 성수/기술 해금·다음 전투·재실행에 연결한다. 기존 progression 수치 계산과 session transaction/pending retry를 재사용한다. UI draft는 domain mutation과 분리하고 실제 적용은 원자적 명령 한 번이다. 신규 여정은 명시적 성장v3로 만들며 기존v1/v2 여정은 당시 규칙으로 계속한다. 강제 마이그레이션 없음.

FEASIBLE: `vertical_slice_progression_state.gd`에 누적수련/성수 산출, `vertical_slice_run_state.gd`에 보상/행로 이력, `run_session_coordinator.gd`에 변경후 불변 pending 재시도, `run_save_store.gd`에 내용 해시 기반 가변 여정 저장이 있다. 새 기능은 이 소비처들에 연결할 수 있다. PARTIAL: v3 ledger/codec/store와 실제 입력 UI의 통합 검증 전에는 사용자 기능 완료가 아니다. Godot4.7.1/JSON/기존Control만 사용하고 새 이미지·유료 의존성은 필요 없다.

## CURRENT_SOURCE_RELEVANCE_CHECK / 10개 공식 비교

2026-09-14 P01 적용 상태에서 원본문 재조회. 직접4/인접6, 문제 신호 포함. 아래 transfer는 설계 추론이다. 공식 제품 소개는 내부 구현·비용·흥행 성공 증거가 아니다. 플레이어 반응의 대표 표본 수집 NOT_RUN이며 각 사례의 배분/저장 내부 구현은 공개 공백이다.

| 출처·분류 | 확인 사실 / mechanism→transfer / 판정 / DO_NOT_COPY |
|---|---|
| [Shogun Showdown](https://store.steampowered.com/app/2084000/Shogun_Showdown/) 직접 | 공격 업그레이드와 조합→수련후 실제기술 선택변화 표시 ADAPT. 타일덱/일본풍 코어 복제 AVOID. |
| [Tactical Breach Wizards](https://store.steampowered.com/app/1043810/Tactical_Breach_Wizards/) 직접 | 레벨에 따른 기술 perk와 실험/rewind→확정 전 배분 draft와 해금 미리보기 ADAPT. 확정전투 되감기 AVOID. |
| [Into the Breach](https://store.steampowered.com/app/590380/Into_the_Breach/) 직접 | 무기/파일럿 획득과 공격전조→성장의 실제 다음전투 가치 TEST. 적계획 전면공개 AVOID. |
| [Fights in Tight Spaces](https://store.steampowered.com/app/1265820/Fights_in_Tight_Spaces/) 직접 | 사건·향상/부상·다음 전투를 위한 업그레이드→보상 이후 관리 진입 ADAPT. 손패/덱/부상 규칙 복제 AVOID. |
| [Knights in Tight Spaces](https://store.steampowered.com/app/2315400/Knights_in_Tight_Spaces/) 인접 | 업그레이드·장비·팀 시너지→현재 보유 목록과 변경효과 비교 TEST. 파티/장비 슬롯/팀공격 AVOID. |
| [Slay the Spire](https://store.steampowered.com/app/646570/Slay_the_Spire/) 인접 | 위험/안전 경로와 선택별 조합→배분전후 선택 가치 측정 ADAPT. 카드덱/유물 경제 AVOID. |
| [Celeste 변경기록](https://www.celestegame.com/changelog.html) 인접·문제 | 긴 바인딩 메뉴에서 안내 가시성·스크롤 복구→수련 목록과 적용/취소 분리 배치 ADAPT. 플랫폼 이동 규칙 AVOID. |
| [Hades 지원](https://www.supergiantgames.com/faqs/hades/) 인접·문제 | 저장 실패·별도 저장 위치 안내→저장 실패를 적용 완료로 표시하지 않고 기존 pending 재시도 ADAPT. 클라우드 의존/보안 비활성화 조언 AVOID. |
| [The Last of Us II 접근성](https://www.playstation.com/en-us/games/the-last-of-us-part-ii/accessibility/) 인접 | HUD크기·배경·색·점멸 설정→숫자/텍스트 변화와 읽기 위계 ADAPT. 난도/자동조준 추가 AVOID. |
| [Ratchet & Clank 접근성](https://support.insomniac.games/hc/en-us/articles/46716208107795-What-Accessibility-options-does-Ratchet-Clank-Rift-Apart-feature) 인접 | 고대비·shortcut→배분/취소의 명확한 포커스와 상태 TEST. 별도3D shader체계 AVOID. |

기술: [Godot 저장 안내](https://docs.godotengine.org/en/stable/tutorials/io/saving_games.html)는 JSON을 읽기 쉬운 단순 상태 저장으로 설명하며 제한된 타입/사용자 인코딩 필요를 명시한다. 기존 엄격한 JSON codec 유지 ADOPT. 예시의 손상 row 건너뛰기는 게임 재화 보존 요구와 맞지 않아 AVOID; 전체 검증 실패시 기존 복구 owner 사용. 공식 stable 설명만으로 exact4.7.1 PASS를 주장하지 않는다.

## 계약과 대안

- 기존v2에 필드를 몰래 추가 REJECT: 과거 decoder/재생 의미가 바뀐다. 전 여정 강제변환 REJECT: 기존 실전 저장·pointer·재도전 위험. 새v3만 명시적 배분 도입 ADOPT.
- `preview_training(allocations)`는 무변경이며 보유ID·양의 정수·pool한도·누적38상한을 검사한다. bool/소수/0/음수/미보유/빈배분 거부. 기존 집중수련 초과 누적은 보존한다.
- `commit_training(allocations, expected_revision)`은 BRIEFING 또는 보상 확정 후 JIANGHU에서만 허용한다. 전투/보상 미확정/재도전의 동결된 prebattle에서는 거부한다. session busy/blocked/suspended는 기존 gate로 차단한다. 미리보기 후 취소는 상태 변화0.
- v3는 `ruleset_id=ten-duel-growth-v3`, `schema_version=3`, 기존 상대10건·roster version을 그대로 쓴다. 기존v1/v2 content identity는 유지한다. 수련 기능만v3에서 활성화하고 기존 여정에는 호환 안내를 제공한다.
- `progression_events`는 보상/행로의 기존 receipt index 및 배분 receipt를 시간순으로 연결하는 단일 순서 원본이다. reward/route 내용은 기존 목록에서 참조하고 같은 효과를 중복 재생하지 않는다. seq1부터 보상→해당4행로→다음보상 순서와 당시 owned/pool을 검증한다. 모든 기존 receipt는 정확히 한 번 참조돼야 한다. pending 행로는 이미 효과가 적용된 경계임을 포함한다.
- 수련 receipt에는 seq, 당시 duel/route 위치, allocations, pool_before/after를 둔다. 단조 revision은 이 event 순서이며 오래된 draft를 거부한다. 쓰기 실패시 같은 pending snapshot을 재시도해 수련을 중복 적용하지 않는다.
- 실제 UI는 목록·현재/예상성수·잔여pool·+1/-1·다음성·취소/적용을 표시한다. 계산은 progression preview를 소비한다.10성/수련불가 사유를 텍스트로 알린다. 새 게임 core나 P03 능력 수치를 도입하지 않는다.

## 순서·완료 증거

- [x] P02-01: `tests/verify_training_allocation.gd`에서 현재 소비 함수 부재 RED. progression의 preview/commit과 원자성·입력형식·38상한·미변경 자원 검사 GREEN(32검사).
- [x] P02-02: run_state 신규v3 시작/배분 gate/event순서와 codec/store v3 roundtrip RED→GREEN. 구형v1/v2 fixture bytes와 identity 불변, 조작된 과거지출/미래보상/중복sequence 거부.
- [x] P02-03: `src/ui/training_allocation_panel.gd`와 shell 연결. 실제 입력으로 배분/취소/연타/720p 목록·포커스, session 저장 실패재시도, 새 프로세스 이어하기. 다음 실제 전투의 해금 기술 실행. Human/실물 입력 기기 검증과 구분한다.
- [ ] 관련 보상·행로·구형/신형 저장·P01·재도전·전체 여정 회귀, Windows GPU, exact HEAD CI. 계획/Decision/Active Context/검증 owner 갱신.

위 파일의 실제 경로를 fresh-read했다. 신규 panel/test와 필요시 ledger helper는 생성 제안이다. 롤백은v3 신규생성을 중지하고v1/v2 경로 유지; 기존v3 파일은 INCOMPATIBLE로 보존하며 삭제하거나 구형으로 해석하지 않는다. 불필요한 파일 이동·삭제·외부배포는 없다. 기존 두 차례 full-scope 검토 계보는 초기화하지 않고 새 변경의 결함별 영향 검토와 실제 증거를 기록한다.

## 진행 증거

- 1932e10b 원격34 checks SUCCESS를 확인했다. 이 기준은 P01+증빙 문서이며 아래 새 P02의 원격 통과를 뜻하지 않는다.
- `training-allocation-red.log`3검사1실패→`training-allocation-green.log`32검사0실패. 초과pool·잘못된형식·미보유·10성·기존 집중수련 초과량 보존을 검사했다.
- `training-growth-red.log` 신규v3 entry 부재1실패. 실제decode에서 JSON정수의 float 표현과 enum array membership 차이로 envelope shape 검사가 실패했다. 엄격한 정수검증 후 schema version만 정규화하여 기존v1/v2의 canonical hash 산출을 유지했다. `training-growth-ordered.log`40검사0실패. 최초 테스트의 매 행로 training 강제 선택은 실제3지선다와 맞지 않아 당시 실제 선택지로 교정했다.
- `training-store-red.log` 구형 primary가 바뀌고v3 pointer가 없는2실패→새v3 pointer/내용주소 저장/구형원본 보존/실패재시도 연결 뒤 `training-store-green.log`51검사0실패. 기존v2 pointer bytes 형식과내용identity를 유지한다. 새v3는 명시적으로pointer3/slot v3를 사용한다.
- `training-ui-red.log` 실제패널부재1실패→`training-ui-green.log`43검사0실패. domain계산 기반미리보기/취소/원자적적용/실제키입력/720p·1080p경계/포커스순환/행로소모0을 확인했다. `training-ui-unlock.log`54검사0실패는 실제보상·행로pool로7성까지배분→다음전투의새기술native배치→실제resolver실행→checkpoint검증을 포함한다. 앞선승리는 명시적인 회계fixture이며 실제10전승리증거와 구분한다.
- requesting-code-review의 독립 표적검토는 새재화/순서/codec/store 경로에 확정P1/P2없음, 실패여정종료때event만남는P3한건을 확인했다. `training-failure-reset-red.log`45검사2실패로 재현하고 기존종료reset에event초기화를 추가했다. 후속영향검사중이다. 기존전체검토횟수를 초기화하지 않는다.
- Godot실행을위해 기존manifest의184sidecar를 hash대조후 다시복원했다. 검증종료시 원래삭제대기에반환한다. 새저장검증폴더 training-store-red/green은 task전용이므로 hash/복원목록과함께별도정리한다.

### 재개 후 실행 결과

증거 root는 `C:/Users/user/.codex/visualizations/tenpaces-motion-integration-20260912/validation`이다. 위 실패여정 reset은 `training-failure-reset-green.log`45검사0실패로 닫았다.

- `training-ui-gpu.log`: Windows/NVIDIA Compatibility 실제 renderer, 55검사0실패, stderr 비어 있음. `training-ui-720p.png`를 직접 열어 배분 전후 pool/4→7성/네 보유 무공/적용·취소·스크롤 경계를 확인했다. 앞선 승리는 회계 fixture이며 사람 플레이 승인이나 native10승 증거가 아니다.
- `training-process-store.log`: 별도 저장 위치의 실제 저장/이전 원문 보존/실패 재시도56검사0실패. 이후 독립 Godot 프로세스의 `training-process-resume.log`14검사0실패: 실제 shell Continue, 전체 snapshot 일치, 5성 유지, session 실패 입력 차단, immutable pending retry, flush, v3 retirement/idempotence.
- `training-full-accounting.log`: 227검사0실패. 자유/집중/전수 보상과 배분을 섞어 10전·36행로의 pending/확정 ledger와 완주 codec을 검증했다. 승패는 명시적인 synthetic terminal이며 native 전투 승률/성능 증거가 아니다.
- `p02-verify_*.log`: variable shell, vertical slice shell, game menu60, save store, save cache, completion return33, acquired flow472, combat checkpoint resume의8묶음 모두 exit0. 새 계산으로 구형 저장·메뉴·전수·복원 회귀가 검출되지 않았다.
- 기존 run-state CI에 새 단위/실제 저장/독립 프로세스 이어하기/UI 입력 검사를 추가했다. remote exact HEAD 결과는 아직 별도 확인 대상이다.

수련의 단일 progression 계산/순서 ledger를 실제 UI와 session에 연결했다. 계획된 P03 시작 능력 분배·성수 능력 보너스, P04 중복 전수 정책은 이 결과로 구현됐다고 간주하지 않는다. 다음 직렬 구현은 P03 owner와 실제 능력 소비처 대조다. 네 모션 final lock, Human, Android, 실물 입력/접근성, release는 NOT_RUN/대기 상태를 유지한다. 월간 증빙 v1.0은 P02 전 발행본이므로 이 결과를 포함했다고 주장하지 않는다.

### 확장 저장 회귀 교정

기존 Python durable suite 확장 실행에서 초기 실패가 발생해 해당 작업의 테스트 프로세스만 종료했다. 이 중단 실행은 UNVERIFIED이며 통과 수에 포함하지 않는다. sidecar를 복원하고 exact4.7.1 실행 경로를 명시하여 영향 범위를 분리했다. `p02-durable-full.log`의 첫 lifecycle 실패 후 원인은 v2 슬롯만 공유 `write_primary` 실패 gate를 호출하는 저장 경로로 좁혔다. 새 v3 저장도 같은 gate를 사용해야 하며 기존 슬롯별 gate는 유지한다.

`training-write-guard-red.log`239검사1실패→공유 gate에 v3를 추가→`training-write-guard-green.log`239검사0실패, stderr 비어 있음. 별도 표적 readback에서 이 교정/종료 reset/CI 연결에 추가 확정 결함 없음. 검토자의 독립 재실행으로 과장하지 않는다. 거버넌스·기획·보호 변경 Python47검사 PASS. 실제 여러 프로세스의 전체 durable lifecycle/Continue 영향 회귀는 `p02-durable-full-green.log`에서 최종 exit를 확인한다.

테스트 저장5폴더23파일은 `C:/Users/user/Documents/삭제대기/십보강호_모션통합_20260912_064614/training-allocation-20260914`로 옮기고 원본/목적지/SHA-256 manifest를 검증했다. 사용자 저장/월간 증빙/승인 원화를 이동하지 않았다. 실행 로그와 실제 화면은 증거 root에 유지한다.


## 2026-09-20 P03 시작 능력·영구 성장 구현

기준 f6bdebb7 / Work Mode BUILD→REVIEW / Skill executing-plans, combat-implementation-handoff(build), live-editor, systematic-debugging. 기존 P02 기록에 날짜별로 이어 쓴다. 사전 계획은 남은 구현 명세 §7의 P03 실행 계획, 호환 결정은 `docs/decisions/2026-09-20_PERMANENT_PLAYER_GROWTH_V4.md`다. CURRENT_SOURCE_RELEVANCE_CHECK=REUSED_EVIDENCE: 같은 승인 수치와 기존 §20의 성장/선택 비교 차원을 재사용한다. 새 조사나 사람 검증을 했다고 주장하지 않는다.

변경: 새 여정 v4만 시작 배분6점/총20, 현재10권의 짝수성 증분, 영구 주능력 요구치4/8/12를 적용한다. 유효 성수/보유에서 순수 계산하므로 전수·여러성 상승·복원 때 중복 지급이 없다. 실제 setup·briefing·수련 preview·전투 선택/판정·strict checkpoint·독립 프로세스 Continue에 연결했다. 수련 preview가 영구 능력 변화와 새 사용 가능 기술을 보여준다. v1/v2/v3의 identity와 세이브 원문, 기존 HP/기력/내력 최대치·AI/보상/행로 경제·승인 자산은 보존한다.

RED/교정: 최초 explicit v4 entry 검사1실패와 영구 능력 전투 consumer 부재1실패를 확인했다. 실제 저장 검사에서 v4 pointer 전환이 실패했고, 쓰기 경로의 v2/v3 정규식 및 공통 write_primary 실패 gate에 v4가 빠진 원인을 교정했다. 구형 v3와 같은 엄격한 경로 규칙을 유지하며 검사 약화/강제 성공을 하지 않았다. 엔진 getter 확장 때 기존 enemy 정보보호 override와 중복 선언한 parse 오류를 확인해 하나의 override로 합치고 재실행했다.

검증 root: `C:/Users/user/.codex/visualizations/tenpaces-motion-integration-20260912/player-growth-20260920`. 초기 지역 결과: 성장/실제 저장87검사, 독립프로세스 Continue·session 실패/재시도15검사, Windows GPU setup/전투22검사, headless 수련/새7성 기술 실제 실행58검사 통과. v3 회계227검사 통과. setup720p/1080p 경계와720p PNG를 확인했다. 완료 숫자는 후속 최종 로그로 대조한다.

Hera editor7432의 exact4.7.1와 작업 경로를 확인했고 실제 script 게임PID도 발견했다. 설치 CLI가 문서의 --pid 옵션을 지원하지 않아 다른 게임으로 자동 우회하지 않았다. native script의 실제 InputEvent/renderer/스크린샷/도메인 readback으로 확인하며 Hera 게임별 UI검사 성공을 주장하지 않는다. 전역/플러그인 변경은 없다.

남은 마감: 관련 회귀·전체 검토2회·보호 경로 manifest·exact HEAD CI·기존 월간 PDF의9월20일 요약 누적. PR342의 네 모션 시트 final lock 전 Draft 경계 유지. 사용자 재미/Android/실물 입력/출시 NOT_RUN. 첫 비무 승리는 회계 fixture이므로 native10승 증거로 표시하지 않는다.


### P03 검토·마감 결과

1. 전체 검토1(독립 fresh context): 현재 정본·전체 변경·미변경 ledger/session/registry/선택 UI·저장/복원·비용·장기 호환·실제 증거를 대조했다. binding은 정상이어도 실제 전투 `state.player.stats`를999로 바꾸면 복원되는 P2를 발견했다. 당시 후보는 CLEAN이 아니었다. actual state와 committed source state 모두 binding의 영구값과 대조하도록 교정하고 원 재현 거부·원본5 유지까지 독립 재확인했다. 현재 임시효과는 status_counts 등 별도 상태를 사용하므로 영구 stats 대조와 충돌하지 않는다. 새 UI/test 단독 변경의 CI 누락 경로도 보강했다.
2. 전체 검토2(root 교정본): 시작 배분·모든 시작 조합·10권 매핑/15초과 성장·3/7/10 기술 문턱·전수/수련 ledger·상대 정보 격리·v1/v2/v3 호환·v4 pointer/cache/tombstone·미변경 resource carry/session/완주·실제 UI·문서/월간 PDF·보호 범위·비용을 다시 대조했다. 최신 main의 정적 테스트가 예전 단일 계산식 문자열에 고정된 불일치는 PR342의 기존 native-font 계산식에 맞추고 실제 카드의 높이/내용 경계 native 검사 PASS를 유지했다. 새 resolved 검사는 마지막 checkpoint가 다음 PLANNING으로 바뀌는 시점을 잘못 가정해 실패했다. 실제 committed/resolved signal의 DTO를 보존한 뒤 두 필드를 각각 검사하도록 교정했고 native66검사가 통과했다. 추가 확정 P1/P2는 남지 않았다. 이후 변경은 이 결함들의 영향 확인이며 전체 검토 횟수를 초기화하지 않는다.

최종 지역 증거: `static-final.log`485검사 실패0; `native-regression.json`14개 관련 Godot 회귀 모두 PASS(구형 v3 회계227, 전수472, 메뉴60, 완주33 포함); 추가 성장 단위157검사(모든 시작4권 조합·기술 요구 경계·10권 최대 합126 포함); `training-native-corrected.log`Windows GPU66검사(실제 새7성 선택/해결·committed/resolved 양쪽 위조 거부); `growth-ui-final.log`headless22검사; `setup-native.log`Windows22검사와 stderr 비어 있음; `card-summary-final.log`실제 renderer 카드 경계 PASS. 초기 저장/독립 프로세스87/15검사도 통과했다. 실제 native setup·수련 PNG를 직접 확인했다. 이전 실패/timeout 로그는 성공에 포함하지 않고 보존했다.

운영 검사 중 오래된 Base checkout에 finalization index가 없고 editor가 생성한 미추적 sidecar가 보호 경로에 잡혔다. 승인된 RECOVERY_ONLY로 task editor만 종료하고190개 생성 sidecar를 SHA-256/복원 목록과 함께 기존 삭제대기에 이동했다. latest completed Base23ecad5(v9.4.4 재현 index 포함)로 동일 exact protected 검사 PASS를 확인했다. 제품 승인 범위에 생성 sidecar를 무차별 추가하지 않았다. 실제 UI 재검사를 위해3개 background sidecar만 검증 후 잠시 복원했고 마지막에 같은 위치로 반환한다.

기존 월간 PDF의9월20일 항목에 Base 작업을 보존하며 P03을 추가했다. 요약1쪽+기존 상세11쪽=12쪽, 상세 content stream 동일, 요약과 다음 역사 첫쪽 직접 렌더 확인. 원본 근거 `monthly-update.json`과 내부 복원본을 유지한다. GitHub exact HEAD 결과는 PR342 live checks가 책임 원본이며 작업 branch 구현을 main 병합으로 표시하지 않는다. 네 모션 final lock 전 Draft 유지.
