# P01 전수 무공 연결 — 구현 계획과 증거

기준 0fb63dbd / Work Mode PLAN→BUILD→REVIEW / Skill combat-implementation-handoff(build), test-driven-development, live-editor.
사용자 `좋아 권장안대로 작업진행해`에 따라 REMAINING_GAME_IMPLEMENTATION_SPEC의 P01을 실행한다. 승인 코어는 시작4권과 보유 전체 사용의 구분이다. 새 수련·능력·등급 정책을 이 교정에 섞지 않는다.

CURRENT_SOURCE_RELEVANCE_CHECK: 같은 날 작성한 명세의10개 공식 비교를 재사용. 같은 성장 선택 실효성/저장 복구 차원, 제품 HEAD는 문서 변경만 추가돼 동일하다. 새로운 외부 게임 규칙이나 엔진 의존성 없음. 조사 source·공개 공백·ADOPT/ADAPT/AVOID 경계는 명세20절을 따른다.
FEASIBLE: progression은 실제 전수 receipt로 보유 전체를 재구성한다. 시작4권 getter를 유지하고 owned view를 별도로 연결할 수 있다. 제약·bridge·전투codec·run cross-validation·보상대상·표시의 실제 소비처를 함께 바꾼다. 주요 envelope schema/content identity는 유지하되 구형 전투 binding과 신형 보유 binding의 호환 경로가 필요하다. 후속 검토에서 이를 확정했고 결정 문서에 기록했다.
대안: 별도 owned view ADOPT; 시작 배열 의미 변경 REJECT(구형 저장/초기 조건 파괴); UI만 확대 REJECT(실제 전투·저장 미연결).

순서: 유효한 v1/v2 보상 이력의5권/10권 fixture RED → 최소 domain view/consumer/codec GREEN → 위조·미보유·중복·mastery집합 검사 → 실제 shell/새 프로세스 저장 재개 및 native 전수 포함 플레이 → 기존 회귀/Windows/CI → 현재 owner 갱신.
초기 fixture의 terminal은 synthetic이며 실제 승리 증거와 분리한다. 현재 Hera editor는 다른 프로젝트이므로 연결하지 않는다. 기존 승인4.7.1 실행 파일로 대상 worktree만 지정해 검증한다. 생성 파일은 hash/원위치 기록으로 수동 삭제 대기에 반환한다.

기존 CI 진단: 문서 HEAD0fb63dbd의 vertical-slice-run-state가 Dogyeom 상태 초상 검사에서 실패했다. 실제 status panel은 해당 원화를 AtlasTexture로 crop하는데 테스트는 raw Texture2D resource_path를 요구한다. 결정된 원화 identity와 crop 상태를 대조하고 좁은 회귀로 교정한다. 무작위로 Dogyeom을 만나지 않아 통과하는 검증을 그대로 두지 않는다.

## 구현 및 두 차례 검토

- 구현: starter provenance getter 유지, 별도 owned view, bridge/codec/run cross-validation/보상/행로 표시/봉인 selector 및 cache 연결. 보상 이력은 시점별 owned 검증. `owned_binding_version=1`은 새 5권 이상 binding에만 붙인다.
- Round1 full scope: 기준/전체 diff/untouched consumer/실행 증거/비용/장기 적합성 검토. 독립 검토에서 전수 후 집중 수련 저장, 봉인 selector 누락, 구형 starter4+mastery5 저장 호환 손실을 확인했다. 각각 회귀·소비처 연결·검증 후 decode 변환으로 교정했다.
- Round2 full scope: 전체 변경과 cache/store/실행 흐름 재검토. 변환 payload digest를 원본 v2 pointer와 대조하는 추가 결함을 발견했다. `_read`/cache의 검증된 source digest와 runtime payload를 분리했다. 표적 clean-exit 재검토에서 추가 확정 결함0. 표적 재검토를 새 full-scope 회차로 세지 않는다.
- 실제 코드 호환 테스트: `verify_combat_checkpoint_resume`의 공유 무공 fixture가 교체 전 mastery 키를 남기는 오류를 stricter ownership 검사로 발견했다. 교체한 무공의 이전 키를 제거하여 합법 actor binding을 구성한다. 실게임 규칙 완화는 없다.
- CODEX_GODOT_PRODUCT_IMPLEMENTATION_HANDOFF: Codex가 exact baseline과 실제 consumer를 독립 fresh-read하고 해당 worktree에서 구현/검증했다.

## 검증 진행 기록

Evidence root: `C:/Users/user/.codex/visualizations/tenpaces-motion-integration-20260912/validation`.

- 최초 유효 RED: `acquired-red-valid.log`, 12검사 중 owned view 부재2실패. 1차 fixture의 잘못된 starter 구성 실패는 별도 `acquired-red.log`로 보존하고 제품 결함으로 세지 않는다.
- 검토 회귀 RED: `acquired-review-red.log`, 456검사 중 집중 수련/봉인7실패. 교정 후 baseline codec 검증 포함 `acquired-legacy.log`464검사0실패; 최신 flow는 `acquired-final-flow.log`462검사0실패.
- 구형 v1/v2 실제 저장소/캐시/Enter Continue/후속 save-readback/전수 기술 배치·해결: `store-native-acquired-legacy-v1.log`, `store-native-acquired-legacy-v2.log`, 각21검사0실패. 단순 session.available 주입 검증을 실제 pointer/primary 파일 경로로 강화했다.
- Windows GPU 실행: `acquired-visible.log`22검사0실패, stderr 비어 있음. 실제 캡처 `../acquired-fixtures/acquired-technique-native.png`를 열어 전수 철검십식의 선택도크/1수 배치와 기존 화면 소비를 확인했다. 이미지 최종승인/Human QA가 아니다.
- 검증 중 복원한184 sidecar 때문에 보호 경로 검사에서 추가 경로가 감지됐다. 이는 제품 승인 범위 확대 사유가 아니며 검증 종료 후 원래 삭제대기 위치로 반환하고 재검사한다.

- 새 형식 v1 5권/v2 5권/v2 10권: `final-native-acquired-*.log` 각21검사0실패. 각 새 프로세스에서 real file/pointer/cache/Continue/기술 배치·해결/후속저장까지 검증했다.
- 기존 회귀9종: combat bridge, review/result, variable combat codec160rows, variable save compatibility, variable shell, enemy information, route state, save cache, combat checkpoint resume 모두 exit0. 마지막 공유무공 fixture의 최초 실패와 교정 성공을 별도 보존한다.
- 첫 native 전수 캠페인은10승/10보상/36행로/286입력/보유7권으로 실제 완주했으나 기존 집중수련 경로 전용 Shaolin7 사용 검사를 잘못 적용해 exit1이었다. `acquired-native-campaign.log`452267ms와 실패를 보존한다. 기존 focused 경로의 기술 사용 인수를 유지하면서 acquired 모드에는 실제 전수 receipt/확장 보유/시작이력 불변 인수를 적용했다. 교정 후 독립 새 여정 재실행 중이다.

- 봉인 선택 추가 인수: `acquired-seal-final.log`472검사0실패. 실제 selector의 다섯 번째 무공 선택→native 확인→다음 전투의 봉인 실행→저장 검증을 v1/v2 각각 확인했다.
- Python `pytest tests/test_project_governance.py tests/test_current_discovery_contract.py tests/test_durable_save_contract.py -q`:41PASS/710.39초/exit0. 여러 실제 프로세스의 planning/committed/resolved/result/pending_reward/route/retry/completion/martial/ultimate/terminal-gap write/read, cache/recovery와 governance를 포함한다. canonical reference freshness 별도 PASS.

- 최종 native 전수 캠페인: `acquired-native-campaign-final.log` exit0, failures0, ordinary defaults,10승/10보상/36행로/286실제 입력,416495ms. 서로 다른 전수3권을 얻어 보유7권으로 완주했다.10권 보유는 별도의 실제 reward-history fixture와 새 프로세스 native 기술 실행에서 검증한 범위다. 자동 플레이는 Human 재미 평가를 대체하지 않는다.
- 정리: 복원했던184 sidecar 모두 원래 삭제대기 위치로 SHA-256 대조 후 반환. 새 task 임시42파일은 `C:/Users/user/Documents/삭제대기/십보강호_모션통합_20260912_064614/acquired-manual-20260914/files.csv`에 원래/현재 경로·hash를 기록해 이동했다. 원본·실패 로그·GPU 캡처·tracked compatibility fixtures는 보존했다. 정리 작업은 이동만 수행했다.
- 정리 후 approved project operating contract 및 canonical reference freshness PASS. latest main은 ed2104d98872c63eac27999830aeae9c15a00bdc이고, 통합 branch가 main을 모두 포함함(behind0)을 확인했다. PR342 기존0fb63dbd는 portrait 회귀1FAIL/33SUCCESS였다. 이번 교정의 remote 결과와 섞지 않는다.

로컬 제품/회귀 검증은 완료했다. 새 HEAD 원격 CI는 push 후 직접 읽으며 아직 PASS로 기록하지 않는다.

## 자동화와 제한

신규 전수 이력/구형 저장/실제 저장소/native 입력 회귀를 기존 run-state CI에 연결했다. 원본 저장 identity와 변환 gameplay identity를 별도 검증한다는 교훈을 cache/pointer 회귀에 반영했다. Base 공용 정책을 수정하지 않았다. 다른 프로젝트 editor/작업트리와 원본 파일을 보존한다.

Human 재미·접근성/Android/실물 입력/음향 장치/출시 NOT_RUN. 네 모션 이미지 최종 lock은 그대로 남으며 PR342는 Draft다. 다음 구현 단위는 P02이며 자유 수련 소비와 새 저장 의미를 명시적 Decision으로 연결한 뒤 수행한다.
