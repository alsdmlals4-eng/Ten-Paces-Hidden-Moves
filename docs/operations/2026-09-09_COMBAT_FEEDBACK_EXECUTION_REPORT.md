# 전투 결과·절초 피드백 교정 실행 기록

상태: MACHINE_VERIFIED_NATIVE_FIXTURE_CAPTURED_DELIVERY_IN_PROGRESS. 병합·전체 Blueprint 완료 보고가 아니다.

## 작업 전 문제와 조사

- 기준 제품 `fe720f5dce686ea5b2ff68a1ec078d53544a0e92`; Task1 `ad5385beac757fbb9168e3d8918c4221d7f416a3`; 최초 Task2 `648634ce9ec83fac4ab1f070096a1b2c6f7ef309`.
- Work Mode BUILD → REVIEW. project workflow router, combat-implementation-handoff BUILD, ten-paces-verification VERIFY, combat-ux-and-accessibility ui-contract, live-editor, TDD, subagent-driven-development, systematic-debugging, receiving-code-review 및 verification-before-completion을 적용했다.
- 승인 범위는 `TEN-DEC-20260909-COMBAT-FEEDBACK-CORRECTION-01`. root dirty main과 타 작업은 보존하고 격리 branch에서 구현했다. 현재 Base의 두 번 검토 정책과 프로젝트 다섯 번 full-scope 검토 요구는 구분하며, 프로젝트 요구를 유지했다. 채택 Base 버전은 변경하지 않았다.
- 현재-source relevance: `docs/reviews/2026-09-09_COMBAT_FEEDBACK_BENCHMARK.md`의 공식 10사례·Godot·음원 후보 검토를 채택했다. 별도 실행 순서 dimension의 10사례는 `docs/reviews/2026-09-09_MARTIAL_DOMAIN_INTEGRATION_PREFLIGHT.md`에서 재사용 범위·한계를 구분한다. 외부 제품 설명을 내부 코드 분석이나 사람 만족도 조사로 포장하지 않았다.
- 기존 board는 승리에도 defeat cue를 냈고, 실제 star10 무공은 분산된 ID-prefix 분류 때문에 승인 절초 효과에 제대로 연결되지 않았다. 대응 무공의 고유 효과 누락과 일반/무공의 방어 불일치는 native 진단으로 별도 발견했다.

## 채택 구조와 구현

전투 승패의 기존 bridge 공식을 순수 도메인 함수 한 곳으로 옮겨 board/bridge가 함께 사용한다. 실제 해당 전투원이 보유한 정의와 이미 확정된 사건을 작은 순수 profile로 분류해 motion·VFX·SFX·문구가 공유한다. 승인 이미지 원본은 바꾸지 않고 세 band를 재사용한다. 회복형은 자기 위치, 실제 공격/반격형은 타격 위치를 사용한다. 실패·방어·전조는 성공 효과와 구분한다.

승리·무승부·절초 발동의 코드 제작 합성음 세 가지를 추가했다. 기존 9개 PCM은 native same-host 비교에서 불변이며, 새 PCM은 합계49,392bytes이다. UI가 피해·비용·보상·상태를 다시 계산하지 않고, schema1·actor-bound 저장 의미·AI 입력·3/3/4·10전/36행로는 이 표시 변경에서 보존한다.

사용 예: 실제 승리 결과는 승리 문구와 victory cue를 사용한다. 자하 회복 절초는 상대에게 달려들지 않고 자기 위치에 표현한다. 실제 기본 방어 fallback인 소요/태극은 성공 반격으로 꾸미지 않는다. 전조→실행 전체 사건열을 검사해 준비 중 발동음을 막고, 실제 필중+막기 결과의 잔여 피해와 방어 사실을 함께 유지한다.

## 검증·교정 진행 증거

| 단계 | 실제 결과 | 범위/한계 |
|---|---|---|
| Task1 prospective RED | 실제 승리의 defeat cue 및 미존재 새 cue 검사가 실패 | 테스트 설정 오류와 구분 |
| Task1 focused/독립 검토 | 구현2PASS12.81s; 별도 reviewer2PASS13.67s 및 native PCM/checkpoint PASS | Human 청음 아님 |
| 최초 Task2 focused | 4PASS16.34s; 별도 E4PASS17.68s | 마지막 실행만 고른 검사가 전조 누락을 놓침 |
| 최초 whole pytest | **495PASS / 2FAIL**,361.85s, 총497 | exact648634ce 제품; 두 FAIL은 roadmap의 current Decision 연결 누락 |
| roadmap 교정 | 기존 실패한 동일2검사 → 2PASS0.07s | assertion을 완화하지 않고 두 실제 owner 연결 보완 |
| 독립 Task2 actual-sequence 진단 | **CHANGES_REQUIRED R1/R2** | 네 무공의8전조 false-release; 실제 파공검기 sure_hit_block 방어표시 누락 |
| controller native 재현 | 실제 Peng 준비 timing1에서 ultimate VFX/release 확인 | 원본1280×800 capture; fixture 고성급·고자원이며 일반 성장 플레이 아님 |
| R1/R2 제품 교정 | `6dded6f133e29a7deadfb3a623f23390439f1d4a`; 실제 전조 포함 RED75건 → native GREEN; focused4PASS14.07s | profile/board/test 세 경로만, 판정·저장 불변 |
| 독립 exact 재검토 | APPROVED_NO_BLOCKERS; 원래 실제 전조 probe8→0; sure_hit_block22→18→9와 무방어22 보존; focused4PASS15.97s | raw 경계8종은 별도 합성 payload; 실제 caller settle 후 검사 |
| 최종 제품 whole pytest | **496PASS / 1FAIL**,354.30s, 총497 | controller roadmap 정리 중 PR333 증거 링크가 누락된 문서 회귀 |
| 문서 교정 재검증 | 실제 링크 복구, 현재 과장 보장문구 제한, current JSON/Active 순서 동기화; 관련31PASS0.59s | 497건 한 번의 완전 PASS라고 합산·재표시하지 않음 |
| controller 실제7장 | 공격 절초/회복 절초/합 상쇄/회피/승·패·무승부 | supplemental seeded/native 증거. 최소 정상/impact freshness 정본 등록은 별도 진행 |
| 보호 wrapper | current Base wrapper, 채택pin·승인5경로 유지, exit0 | 실제 제품 diff 기준. 후속 exact CI/main readback 필요 |

독립 reviewer는 기존 두 worker 중 구현자와 다른 사람 역할의 agent를 재사용했다. 새 worker 할당 한계로 fresh-context review는 아니며, 독립 파일 검토·실행과 이를 구분한다. Controller는 제품 수정 대신 task/spec/owner/검증을 맡았다. 두 신규 native 회귀는 기존 automated-product-evidence CI job의 Godot import 뒤 명시 연결했다. 기존 workflow는 자동 발견 구조가 아니어서 local-only 검사를 그대로 두지 않았다.

## full-scope 검토 기록

아래는 controller가 정본·실제 변경·untouched consumer·실행 증거·비용/장기 적합성까지 다시 검토하는 전체 회차다. 구현자 보고서의 주제별 다섯 목록은 이 요구를 대신하지 않는다.

1. **기준·설계 전체 검토:** 실제 승패 owner, actor definition, 기존 저장/bridge/summary, 승인 image bytes, 반복 합성 비용과 공식 비교를 대조했다. 새로운 음향 middleware 대신 기존 cache를 유지하고, domain 변화 없이 표시 수정으로 한정했다. native 도메인 진단을 반영해 대응 성공 검증을 실제 fallback과 합성 counterexample로 분리했다.
2. **Task1 + Task2 통합 전체 검토:** Task1의 원 PCM/terminal guard/receipt와 Task2의 actor별 정의·실패 우선순위·정본/실제 gaps·CI consumer·성능 범위를 재검토했다. 비절초 대응 fallback과 all-blocked defender motion, 신규 회귀의 CI 연결 누락을 발견해 교정했다. 깊은 복사 범위는 확정 사실 다섯 필드로 제한했다.
3. **최초 구현 exact-head 전체 검토:** E clean checkout 운영 검사, full diff, 실제 독립 native probe와 D full497검사·실제 화면을 대조했다. 통과 marker만으로 전조/필중막기까지 성공이라 주장하지 않고 R1/R2를 반려했다. 로드맵 Decision 연결, 문서의 미존재 클래스·낡은 NOT_STARTED도 실제 consumer에 맞게 교정한다. 고유 대응/공통 방어는 여전히 별도 실행 계약이며, 이미 공개된 저장의 호환 비용을 명시했다.
4. **R1/R2 교정 후 전체 재검토:** exact6dd 제품 전체 diff와 독립 unchanged actual probe, original PCM/terminal/checkpoint 소비자, native7장, full497실행을 대조했다. 전조 identity는 유지하면서 성공 표지만 제거됐고 actual sure_hit_block의 피해는 보존됐다. source-only 표시 변경에 저장 family나 새게임규칙이 섞이지 않았다. 단, 전체 검사에서 controller의 PR333 링크 회귀와 문서 감사의 오래된 무공 실행 보장·다음 단계 누락을 발견했다. 실제 owner를 교정했고31관련검사가 통과했다. 새 profile은 bounded 사건열만 읽고 이미 생성한 세 VFX/캐시12cue를 재사용하며 추가 middleware·외부비용·자산 변경은 없다.
5. **전달 전 전체 clean-exit 검토:** actual Product5경로 diff/한글 owner/current JSON/기존 저장·AI·actor·CI consumers를 다시 대조했다. 원 PCM9종·13band대응·준비 및 방어우선순위·strict checkpoint불변과 테스트 caller를 확인했다. 생존 중인 다른 editor/worktree는 보존하고 본인D editor/game 종료 후 generated90경로를 SHA일치 backup하고 제품 diff에서 제거했다. current/adopted 운영 wrapper PASS와31owner검사 PASS, 제품 독립 승인과 실패 이력 보존을 확인했다. 캡처정본 사전receipt 미적용을 추가 발견했으므로 기존7장은 supplemental로 한정하고 정상진입/impact 최소2장은 기존 prepare/register 경로로 별도 생성한다. 이 등록과 exact-head CI/main readback을 마치기 전 delivery complete는 주장하지 않는다. 화면의 검은 빈 영역·중첩, 실제 대응 판정·v1호환·성장/사건은 다음 안전 작업으로 남겼다.

## 도구·실패·재사용 교훈

- fresh Godot worktree는 import가 선행되어야 한다. import 부재의 missing PNG loader·global class 오류를 행동 RED로 세지 않는다. import metadata를 검증 중 미리 제거하면 같은 오류가 돌아오므로 모든 native 실행 뒤 exact generated paths만 정리한다. source image를 삭제하지 않는다.
- import exit0과 teardown45 ObjectDB/22resources 경고를 함께 기록한다. 원인 미확인 경고이며 native 테스트의 깨끗한 종료와 혼동하지 않는다. 기존 liveness 검사2ObjectDB 경고도 보존한다.
- 어떤 missing-import native 시도는 SCRIPT ERROR 뒤 OK marker를 출력했다. Python runner는 nonzero뿐 아니라 SCRIPT ERROR도 거부하므로 그 시도는 GREEN에서 제외했다.
- 설치된 Hera CLI v1.0.0은 새 skill 문서의 game --pid 인자를 받지 않는다. 해당 인자는 실패했고 다른 게임으로 fallback하지 않았다. 실제 addon의 `_target_game`을 읽어 exact editor의 playing_scene과 유일하게 일치하는 runtime만 선택하며, 일치0/복수는 실패한다는 것을 확인했다. D editor28492/고유 QA scene/runtime22640을 원본 capture의 반환 pid·scene과 교차 확인했다. 콘솔 launcher32028은 실제 editor PID가 아니어서 live inventory로 교정했다. 이 호환 한계는 도구 업데이트 후보이며 이번 게임 제품에 addon/CLI를 임의 교체하지 않았다.
- 기본 output 도구의 빈0줄 로그는 실행 오류 없음 증거가 아니다. explicit log/actual probe 출력을 구분한다. scoped test fixture에는 run store를 만들지 않았고, 사용자 저장을 읽거나 쓰지 않았다.
- 프로젝트 학습: 앞으로 무공 테스트는 마지막 execution만 고르지 말고 actual 전체 timing event열과 모든 domain defense outcome을 교차 검사한다. 공용 후보: generation cache 제거 시점·native marker/error 동시 검사·실제 CLI 기능과 skill drift. 검증 없이 Base 자체를 수정하지 않았다.
- capture QA의 첫 합 fixture는 적 시작timing과 실행timing을 혼동해 합이 없었다. 실제 상대 시작1수로 교정한 뒤 timing2 합 상쇄를 확인했다. 실패 이미지는 삭제하지 않고 ignored backup에 보존했다. Hera heartbeat 한 번의 일시적 editor 미발견은 실패로 남기고 inventory를 재확인한 다음 고유 scene/pid로 재시도했다.
- controller 문서 정리도 기존 증거 링크를 깨뜨릴 수 있다. 전체 검사 실패를 보존하고 owner 연결을 복구했다. 현재 README의 보이는 문제와 engine/import 경고를 정상 runtime/가독성 PASS로 숨기지 않는다.

## 미검증과 다음 안전 작업

### 전달 직전 교정 readback

정상 진입/실제 Peng execution 최소2장은 `docs/evidence/RUNTIME_VISUAL_CAPTURE_MANIFEST.json`의 `TEN-RVC-20260909-001/002`에 등록했다. 두 producer 실행 전 source-absent receipt를 만들고 등록 직전 fresh source `6dded6f1`을 독립 대조했다. 기존7장에 freshness를 소급 부여하지 않았다. 새 등록은 E `ff732f5f`에서 D `7dff0c6a`로 evidence3경로만 흡수했다. 정상1280×800과 Peng1280×800을 직접 검수했고, 실제run log/Debugger의0ERROR·17GDScriptWARN을 manifest에도0/17로 유지했다. 기존 경고의 수정이나 warning-free 실행은 주장하지 않는다. 캡처계약9검사PASS2.75s, 새 manifest 포함 보호wrapperPASS. 제품/스키마/승인원화/기존캡처는 불변이다.

Controller의 마지막 전체 검사는496PASS1문서FAIL이며, 그 뒤 실제 owner 교정과 관련31PASS0.59s, 엔진 의존 두 모듈을 제외한 전체484PASS17.58s를 별도 기록한다. 독립 exact 제품 focused4PASS와 checkpoint/실제준비·방어probe를 보완 증거로 사용한다. 이들을 한 번의497PASS로 합쳐 쓰지 않는다. 최종 전달 exact checkout에서 전체검사·CI와 병합 후readback을 추가 확인한다.

R5에서 발견한 캡처 등록 공백까지 해결한 후 정본/current순서·제품5경로·untouched v1 저장/AI/원화·비용·증거ceiling을 다시 검토했다. 범위 안 미해결 blocker는 없다. 등록 경고와 실제화면 배치 부족, domain execution공백은 기록된 후속이며 narrow feedback PASS로 덮지 않는다. 최소5회 전체 검토의 clean exit는 이 확인까지다.

post-correction native/독립 코드검토와 정본2장/supplemental7캡처는 완료했고, 로컬 whole496PASS1문서FAIL 뒤 해당 owner/관련31검사 교정도 확인했다. exact-head CI·정상 병합·main readback은 아직 PENDING이다. 사람 플레이·청음·실물 입력·Android·접근성 사용자·Release 성능·출시 권리는 NOT_RUN이다. UI 인물/카드 크기·빈 영역과 전체 승인 아틀라스 fidelity도 완료가 아니다.

표시 교정 뒤에는 별도 실행 계약으로 고유 대응·공통 피해/방어·첫 전조 비용/once/강건과 v1 저장 완주 호환을 교정한다. 그 다음 성장 지출/수련/해금, 사건표·선택·조건, 정탐/상태/보상과 적별 콘텐츠·아트/음향 완성도를 계속 다룬다. 이 보고서는 정의 분류나 자동10전 결과를 전체 Blueprint 구현 완료로 확대하지 않는다.
