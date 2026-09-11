# 십보강호 활성 컨텍스트

## 현재 재개 지점 · 2026-09-11 승인 설계 구현·병합 완료

최신 사용자 지시에 따라 다른 프로젝트 참고 대기를 해제하고112쪽 승인 검토본을 준비했다.
현재 전달 대상은 `output/pdf/TEN_PACES_HUMAN_BLUEPRINT_20260911_APPROVAL_REVIEW.pdf`다.
인물16명·160행의 가변 무공·고유 별호, 백무진 전용 초상 후보, 상세 SWOT와 구현·저장 인수 계약을 포함한다.
상세 결정은 `docs/decisions/2026-09-11_CHARACTER_VARIABLE_LOADOUT_APPROVAL_REVIEW.md`,
구현 진입점은 `docs/blueprint/IMPLEMENTATION_HANDOFF.md`, 검증 증거는 `docs/blueprint/FINAL_REVIEW.md`다.
2026-09-11 사용자가 상세 수치·별호·선정 원화를 최종 확정했다. 승인 revision은 c95ec7e6이며
정확한 PDF·선정47개 이미지 해시는 current_user_planning_status.json의 blueprint_final_approval을 따른다.
원래 승인 검토 PDF는 bytes를 보존한다. 가변 편성·별호·원화·v2 저장 제품 연결과 로컬 검증 및 원격34개 검사를 완료했다.
실행 기록: docs/operations/2026-09-11_VARIABLE_ROSTER_IMPLEMENTATION.md. 실제 입력10전10승·36행로 PASS, Human/Android NOT_RUN.
PR340은 main `201af9e99e4ce7e7b58e3ea63e6edc37d8c037ff`에 병합됐다. 이번 후속 변경은 일회 승인을 감사 기록으로 보존하고 활성 권한을 제거한다. 실제 제품 evidence와 Human 승인은 분리한다.
보존 초기 저장에서 실제 Continue로10승/36행로를 재현했다. 무작위 정책의 실제8전 패배도 보존하며 모든 조합의 밸런스 PASS로 확대하지 않는다.
다음 제품 범위는 별도 미완료 모션·화면 작업의 현재 변경을 보존한 채 검토하는 것이며, 이번 구현을 전체112쪽 기획의 출시 완료로 표현하지 않는다.
아래81/87/91/92쪽 상태는 편집 경과로 보존한 역사 기록이며 현재 전달 대상을 덮어쓰지 않는다.

## 최신 편집 지시 · 아틀라스 우선 / 유사 주제 인접 배치

SWOT·독창성·창의성은 삭제가 아니라 1부 앞쪽 배치라는 사용자 정정을 반영한다.
아틀라스 첫 페이지, 비무 브리핑+제약 연속 배치, 준비·합 실제 캡처의 관련 설명 인접 배치,
1부 강화·개선·보완 실행 항목을 추가한 최신 전달 대상은
`output/pdf/TEN_PACES_HUMAN_BLUEPRINT_20260910_ORGANIZED.pdf` 92쪽이다.
기존91쪽 판은 보존한다. 편집 구조 owner는 docs/blueprint/READING_STRUCTURE.md다.

## 최신 우선순위 · 2026-09-10 수정 블루프린트 우선 전달

사용자는 기존 저장 보존·새 여정부터 새 상대 편성을 적용하는 권장 방향을 승인했다.
이후 최신 지시로 제품 구현보다 수정 블루프린트 최신판 전달을 우선한다.
전달 대상은 `output/pdf/TEN_PACES_HUMAN_BLUEPRINT_20260910_REVISED.pdf` 91쪽이다.
87쪽 설명·시각자료를 유지하고 SWOT, 요소별 유지/개선/교체, 독창성과 연출 기준,
개발자 공개 자료 및 적용 순서를 추가했다. 실제 제품 연결·저장 호환·신규 원화
최종 채택·사람 밸런스는 여전히 별도 미완료다. 아래 전달 보류는 이전 요청 시점의 기록이다.

## 2026-09-10 사용자 추가 교정 · 통합판 재작업 중

81쪽 판은 최신 사용자 요구를 충족하지 않아 최종 전달·병합을 보류한다. PR #340은 Draft다.
주력+보조 2권의 단계별 예산, 설명용 화면 아틀라스/흐름/비무 브리핑 복원,
연격·회피 상세 복원, 불필요한 장식 이미지 제거, 기존 가면 검객의 실사용 인물화를 진행한다.
무공 예산은 성수 합계가 아니라 현행 3성 이후 누적 수련 비용을 사용한다.
81쪽 판의 과거 내용·렌더 PASS는 이 추가 요구의 완료 증거가 아니다.
현재87쪽 재편집·전체 재렌더·내용 검사까지 마쳤다.16명×10단계160행이며
주력10/보조7/보조5성의10전 기준 비용은57점이다. 새 PDF 해시는 FINAL_REVIEW.md에 기록했다.
제품의 한 권 제한·저장 identity·정보 경계 연결은 미완료다. PR340 외부 보호 승인 표시는
없음을 확인했으며 이를 자체 PASS로 만들지 않는다. 사용자가 요청한 최종본 전달·병합은 보류한다.

## 2026-09-10 블루프린트 통합 편집과 승인 복구

현재 문서 작업은 `codex/blueprint-organized-20260910`의 격리 문서 작업 공간에서 진행한다.
기존 `codex/character-motion-integration-20260909`의 미완료 제품 변경은 보존했다.
사용자 승인 복구 규칙은 생성 라우터 자체가 아닌 AGENTS의 상위 owner에 배치하여
채택 Base 생성물 검사를 보존한다. 동일 pinned Base 검사 PASS를 이 문서 작업 공간에서 확인했다.
제품 작업 공간의 보호 metadata 실패가 해결됐다는 뜻은 아니다.
통합 편집 구조는 `docs/blueprint/READING_STRUCTURE.md`, 상대별 150개 단계 권장안은
`docs/blueprint/OPPONENT_STAGE_TABLES.md`에서 읽는다. 150행의 자원 상한(30/5/4 유지)·별호 상세를
추가했다. 이는 상세 권장안이며 실제 게임 연결·사람 밸런스 검증과 구분한다.
17쪽 부분 편집본은 역사 비교용이며 최신 전달 대상이 아니다.
사용자가 매화검결 삽화 방향을 확정했다. 첫 그림의 검끝 여백 교정본을 생성·저장했다.
나한금강공 3성·7성·10성 삽화도 생성·직접 확인하여 제작 기록에 추가했다.
상대 도감은 인물별 삽화·10전 보유 무공/성수·능력치·관찰 포인트와 후속 10→1전 표를
한 쌍으로 구성한다. 첨부한 도겸 이미지는 레이아웃 참고일 뿐 실제 사용할 자산이 아니다.
부분 PDF는 더 전달하지 않고 전체 통합·대조·렌더 검수를 마친 완성본만 전달한다.
무공30종·상대15명 초상을 모두 생성·저장했다. 81쪽 통합 편집판은
`output/pdf/TEN_PACES_HUMAN_BLUEPRINT_20260910_COMPLETE.pdf`이며 전체 렌더·내용 검사와 최종 교정본 재검증을 마쳤다. 전달 증거는 `docs/blueprint/FINAL_REVIEW.md`다.
문서의 완료 상태와 신규 원화 최종 채택·게임 연결·병합은 별도다. 반격·재도전 제한 설명과 수치·캡처 provenance 누락을 표적 검토로 교정했다. 최종 기록은 `docs/operations/2026-09-10_BLUEPRINT_ORGANIZATION_RECOVERY.md`를 따른다.
최신 사용자 지시에 따라 여성 무인을 무공 삽화와 상대 도감에 포함한다. 여성 추혼표 시안을
제작·저장했고 묵직한 도법·장법·창법에도 여성을 포함했다. 상대 초상은 여성7·남성8이다.
연환쇄로는 창대와 창날 연결 오류를 교정한 `spear-star7-structure-v2.png`를 도감용으로 사용한다.
회마창은 사용자 손/팔 지적 후 `spear-star10-hands-v2.png`를 생성·직접 확인했다.
양팔의 어깨→팔꿈치→손목 연결과 앞손/뒷손 역할을 분리한 교정 후보이며 원본은 보존한다.
최신 사용자 지시: 무공 삽화를 먼저 완성한 뒤 해당 무공을 메인으로 쓰는 상대를
무기·복장·체형·자세·기운 색에 맞춰 새로 제작한다. 기존 적 이미지도 재제작 대상이다.
플레이어는 유지하며 기존 적 원본·모션은 새 연결 검증까지 보존한다.

2026-09-09 최신 사용자 지시로 내부 material 전체 검토는 5회에서 **정확히 2회**로 변경한다. `docs/decisions/2026-09-09_TWO_ROUND_INTERNAL_REVIEW.md`를 따른다. 동일 작업의 세션·커밋·병합 전후 회차를 초기화하지 않고 2회 뒤에는 결함별 교정·영향 검증만 한다. 과거 실제 5회 검토 기록은 당시 증거로 보존한다.

2026-09-09 적 제작/배치 최신 요구: 검을 대표 모션 제작군으로 삼되 여러 적 타입을 먼저 정의한다. **새 게임 시작 시 1~10전 상대를 한 번에 무작위 선정하고 회차 안에서 고정**한다. 인물 정체성과 이름은 유지하며 스테이지별 스탯·보유 무공/수련도·별호로 성장을 표현한다. 이는 최신 승인 방향이며 현재 `CAMPAIGN_ORDER` 고정 순서와 그에 의존한 저장 검증을 아직 대체하지 않았다. 2026-09-10 도감용 새 원화15장은 생성·검수했다. 새 전투 모션·배치·저장 구현은 `NOT_RUN`; 원화 생성 및 과거 완료 증거와 혼동하지 않는다.

위 요구와 실제 consumer 차이, 다음 검증은 `docs/decisions/2026-09-09_RUN_START_OPPONENT_ROSTER_AND_GROWTH.md`에서 이어간다. 인물 ID와 만남 ID, 타입/단계/별호를 분리한다. 상세 수치150행과 공식 사례11종의 제한 비교는 docs/blueprint에 보강했다. 반복 정책 확정·저장 호환·사람 밸런스 검증은 미완료다.

2026-09-09 무기별 연출 후속 작업: 같은 연출 결정의 `무기·기법별 제작 범위`에 창·근접 비수·투척 암기·권법/장법·장풍의 제작 누락 방지 기준을 보강 중이다. 현재 데이터와 고유 모션 구현을 구분하며, 근접 비수 등 미지정 기술 매핑은 임의로 기존 암기에 덮어씌우지 않는다. 새 자산·GIF·엔진 연결은 아직 `NOT_RUN`; 이 추가분은 작업 분기 검토 중이며 main 반영 완료가 아니다.

2026-09-09 연출 제작 기준 보강: 사용자가 조사 후 제작과 상단 합, 합 승자·패자의 후속 반응 분리를 승인했다. 책임 결정은 `docs/decisions/2026-09-09_CLASH_STAGING_AND_OUTCOME_DIRECTION.md`다. 다음 Visual 작업은 상단 접촉 핵심 자세 → 양쪽 결과 반응·회복 → 효과 off/on·역할 반전 검토다. 새 모션 자산·Godot 적용·Human 증거는 `NOT_RUN`이며 기존 코드·승인 원본·Base adoption pin은 변경하지 않는다.

> 전투 규칙 책임 원본: `docs/02_COMBAT_RULES.md`
> 이 문서는 **변동 상태의 단독 책임 원본**이다. 제품 규칙 전문을 복제하지 않고 현재 상태, 검증 상태, 미완료 Gate, 다음 실행 순서를 연결한다. 후속 Decision 뒤에도 회귀가 찾아야 하는 제품·플랫폼·관찰 권위의 발견 표식은 별도 섹션으로 보존한다.
> 핵심 결투 타이밍 discovery locator: `3/3/4`. 세부 전투 규칙은 `docs/02_COMBAT_RULES.md`가 책임진다.
> **2026-08-28 current override:** `TEN-DEC-20260828-REPOSITORY-ONLY-CANONICAL-WORKSPACE-01`에 따라 live 상태 판단은 GitHub `main` + repository human-facing/structured owner만 fresh-read한다. Notion은 migration/history input이고 새 sync·output·readback 대상이 아니다. Google Sheets는 `MIGRATION_ONLY_UNTIL_REMOVAL` compatibility source다.

## 현재 기준

2026-09-09 전투 화면 교정은 세 제품 파일과 실제 회귀/CI 연결을 source `eda26a97f25a931ac02ba739d5c4921720512d41`에 저장했다. 전체499검사315.57s, 별도5회 전체 소스 검토와720/800/1080 실제 Board 화면·이동·이번 수 비교·절초·skip·resize 검증을 마쳤고 보호 전달은 진행 중이다. 책임 Decision은 `TEN-DEC-20260909-COMBAT-LAYOUT-CORRECTION-01`, 실제 결과는 `docs/operations/2026-09-09_COMBAT_LAYOUT_EXECUTION_REPORT.md`, 캡처의 성공/실패와 provenance는 `docs/runtime-captures/TEN-COMBAT-LAYOUT-20260909/README.md`다. 캡처는 정상 RunSession 전체 여정이 아닌 실제 Board/CTA와 별도 resolver-seeded fixture다. 편집기 진단 버퍼0error/18warning과 작은 글자·부자연스러운 줄바꿈·인물 중첩/접지·계획 여백을 남겼으며 전체 Blueprint/Human 승인을 뜻하지 않는다. 후속은 ordered combat/v1완주호환 → 성장/사건/정탐·상태/보상 → 남은 아틀라스 품질이다.

2026-09-09 전투 피드백 교정은 PR #335 exact head `8509813e0b0bb3df8f69ae5fb4baf410d02df7aa`, 전체497PASS335.30s와 GitHub32SUCCESS 뒤 main `477697842bf14d95e670f01b0fe815e384b53658`에 정상 병합됐다. 실제 전조8건의 거짓 절초 발동을0건으로 교정하고 필중+막기 피해22→18→9를 보존한다. 정상진입/실제 Peng의freshness정본2장과 supplemental7장을 보존하며0error/17warning, 큰 빈 영역과 효과·글자 중첩을 기록했다. merged tree와 tested source는 동일하고 detached-main 비엔진484검사17.57s 및 clean checkout 보호wrapper가PASS했다. E import sidecar 포함 wrapper실패는 제품 결함과 구분해 보존한다. 현재 기록은 `docs/operations/2026-09-09_COMBAT_FEEDBACK_EXECUTION_REPORT.md`, 승인 보존은 `docs/operations/2026-09-09_PR335_PROTECTED_CHANGE_APPROVAL_RECORD.md`다. 고유 대응·공통방어와 기존v1여정 완주호환 명세 검토를 진행하고 이후 성장/사건/상태/보상과 아틀라스 품질을 보완한다. 전체Blueprint·Human·청음·기기·출시 완료는 아니다. 아래 병합 당시 다음작업 문구는 역사이며 현재 순서는 current JSON을 따른다.

2026-09-09 durable save/continue와 최초 저장 공개 전 성급·능력치 실행 교정은 PR #333 exact head `baabfc7ae6a29f6ebc47ea5644a110bc7258fc38`로 현재 remote check 32개를 통과하고 main `fe720f5dce686ea5b2ff68a1ec078d53544a0e92`에 정상 병합됐다. 첫 approval-label 누락 run `34265224533`의 실패는 역사 증거로 보존하고, `approved-protected-change` 적용 뒤 같은 exact head run `34265510529`의 PASS를 현재 승인 검사로 사용한다. 제목의 새 여정/이어하기, 전체 셸 복원, 행로·보상·패배/재도전·완주 저장과 저장 실패 재시도를 연결했다. 실제 선택 UI가 만든 정의와 각 전투원의 성급 정의를 대조하고, 한글 능력치 참조를 실제 영문 actor.stats에 대응시킨다. 공개된 적 계획은 재구성으로 교체할 수 없으며 COMMITTED 한 번 해결/RESOLVED 재실행 없음과 구형 QA 파일 무변경 거부를 검증했다. 실제 저장 실패·재시도·이어하기 캡처 5장을 보존한다. source `50cb8fe4` 전체 490건과 import 준비 뒤 post-merge `fe720f5d` 전체 490건은 서로 다른 실행 증거이며, fresh post-merge worktree의 첫 import 전 실행은 missing global class로 실패했다. 이 결과는 디버그 native/자동 검증이며 FPS·Human·Android·접근성 사용자·release와 전체 Blueprint 완료는 `NOT_RUN`이다. 다음 안전 작업은 battle presentation correctness의 star-10 actor classification과 victory/defeat cue이며, 그 뒤 성장 지출·영구 능력치 지급·해금 조건·보유 무공 전투 확장 및 사건/상태/보상 정본 공백을 다룬다. 책임 기록: `docs/operations/2026-09-08_DURABLE_SAVE_EXECUTION_REPORT.md`; 승인 archive: `docs/operations/2026-09-09_PR333_PROTECTED_CHANGE_APPROVAL_RECORD.md`; 실행 교정 Decision: `TEN-DEC-20260909-MARTIAL-ACTOR-BINDING-CORRECTION-01`.

이전 Task3 검증 당시 전체 Python487건/391.40초, 저장 캠페인10승·10보상·36행로·299입력,237회 저장 평균692ms/최대1144ms는 교정 전 역사 측정으로 보존한다. Task4·Task5 이후 성능의 현행 값으로 사용하지 않는다.

2026-09-08 inline combat results는 PR 331 exact head `0371f886daf83683130c81437a2e2e6132d27628`로 32개 remote check를 통과하고 main `bf161025b63edd7eb441b2c4f2ae9da5155f68da`에 병합됐다. 활성 standalone 복기 overlay/추가 click 없이 resolver cause를 bounded inline lane과 terminal Result가 소비하며, reveal과 action dock은 720/800/1080 actual rect 회귀 및 controller capture를 통과했다. detached-main Python 478건, protected lifecycle과 Base operating contract가 PASS했다. native ordinary-default 10전은 실제 UI 입력 경로로 10승·10보상·36행로·299활성화를 완료했다. 이는 machine/runtime capture evidence이며 Human·물리 입력·Android·접근성 사용자·release·전체 Blueprint 완료는 `NOT_RUN`. 다음 안전 surface는 durable save/continue와 event/status/reward canon gap의 별도 설계다. 책임 기록: `docs/operations/2026-09-08_INLINE_COMBAT_RESULTS_EXECUTION_REPORT.md`, `docs/operations/2026-09-08_PR331_PROTECTED_CHANGE_APPROVAL_RECORD.md`.

2026-09-08 병합된 10전 확장: 최신 사용자 지시는 10전과 비무 사이 4회 행로 선택,
인게임 캡처, Blueprint 아틀라스 기반의 대부분 이미지 교체다. 작업은
PR 322로 32개 검사를 통과하고 `81ef0f0b2ede9cd63d6a2aba521a645efc1d4e5f`에 병합됐다.
초기 연속 캠페인 검사의 자원 초기화 오류를 교정하고 당시 완주 판정을 철회했다.
교정 후 공개 정보 정책은 실제 resolver/AI로 10승·36회 행로·10회 보상을 완료했다.
매 비무 첫 해결 전 누적 자원 일치를 검사했고 controller와 독립 검토자가 재실행했다.
이는 headless 통합 검증이며 UI 입력 경로·사람 플레이·전체 정책 균형 증거는 아니다.
기존 2노드 회귀를 새 구조로 이관했고 누적 정탐 손실과 존재하지
않는 시작 무공 ID 수락도 교정했다. Python 472 PASS와 focused Godot 회귀 PASS.
주막 휴식 삽화 연결은 실제 1280×800 렌더 검수와 중복 회복 방지 검사를 통과했다.
PR 322 Windows/Linux 제품 CI와 전체 검사는 최종 exact head에서 PASS했으며,
별도 전체 검사에서 발견한 오래된 카드 크기 assertion과 실패 시 미종료를 추가 교정했다.
detached main Python 472건도 PASS했다. 이전 PR 321 승인 기록은 PR 323으로 보존·종료했다.
전체 Blueprint 기능 구현·최종 검수는 아직 진행 중이다.
책임 진행 기록: `docs/operations/2026-09-08_TEN_DUEL_CAMPAIGN_IMPLEMENTATION.md`.
새 공통 배경은 최신 사용자 연속 구현 지시에 따라 별도 경로로 런타임 연결했다.
원본 승인 자산을 덮어쓰지 않았고 Human 최종 검수/출시 권리 확인은 미완료다.
카드 비용·슬롯·사거리·주효과 요약을 연결하고 실제 렌더의 글자 넘침을 교정했다.
비무 제약 9종의 복수 선택·기법 제한·상대 강화는 별도 승인 Decision 아래 구현됐으며
로컬 기계 검증과 1280×800 실제 캡처를 확보했다. 720p는 headless만 검증했다.
PR 325는 exact head 34/34 SUCCESS 뒤 `12fe75ca795c9af640a58eff975e2a6cbe02888d`에 병합됐다.
merged main pytest 473건과 model/runtime/UI/실제 10전 probe가 통과했다.
다음 안전 작업은 native-input 전체 캠페인과 Blueprint 구현 공백 검증이다.
책임 증거: `docs/operations/2026-09-08_BIMU_CONSTRAINT_RUNTIME_EXECUTION_REPORT.md`.
PR 327은 22 SUCCESS / 3 정상 SKIPPED 뒤 `ae2c686cd09fd3c94a309b7fd8104673bf6c0c4d`에 병합됐다.
Godot 입력 이벤트로 실제 버튼을 작동시킨 전체 캠페인은 10승·10회 보상·36회 행로·387회
버튼 활성화를 통과했다. 병합본 Python 474건과 정본 수명주기·운영 검사도 PASS했다.
이는 실제 UI consumer를 통과한 headless 자동 입력이며 물리 키보드·사람 플레이 증거는 아니다.
종료 시 사운드 객체 2개 경고는 프로젝트 없는 최소 재현에서도 확인됐다. 미병합 엔진 수정안을
채택하거나 경고를 억제하지 않았다. 책임 증거와 재현 한계:
`docs/operations/2026-09-08_NATIVE_CAMPAIGN_FLOW_VERIFICATION_REPORT.md`.
사건 시각자료와 전체 Blueprint 대응·최종 검수는 남아 있다. 다음 package의 native-input 부분은
위 증거까지 완료됐고, Blueprint 공백 대조 부분은 진행 중이다.

2026-09-08 후속 로컬 구현: 승인된 단일 `행동 실행`으로 불필요한 확정 클릭을 제거했고,
동일 무공/수련도 context의 반복 재구성만 생략했다. 동적 자원·제약·기세 갱신은 유지한다.
두 변경을 포함한 controller native 재실행은 10승·10보상·36행로·343활성화, 실패 0이었다.
반복 갱신 100회 비용은 약 0.54초에서 0.0012초로 감소했지만 headless 부분 측정이며 FPS 증거가 아니다.
현재 분기 검증 단계로 아직 main 병합 완료가 아니다. 책임 기록:
`docs/operations/2026-09-08_SINGLE_EXECUTE_BLUEPRINT_EXECUTION_REPORT.md`.
실제 준비/해결 화면도 캡처했다. 해결 화면의 결과 텍스트 겹침은 다음 전투 화면 정리에서 교정해야 한다.
별도 복기 화면 제거, 정탐 공개 범위의 충돌 교정, 보상 산식 계약, 상태창과 사건 콘텐츠/삽화는 남아 있다.

2026-09-08 사용자 상시 승인: 관련 기존 open/draft/ready PR은 번호별 재승인 없이 검토·흡수·교정·검증·병합한다. 책임 결정은 `docs/decisions/2026-09-08_STANDING_PR_INTEGRATION_AUTHORIZATION.md`다. 기존 성공 CI만으로 병합하지 않고 최신 main·실제 diff·회귀·보호 규칙을 다시 확인한다. 이전 전투 UI 교정 증거는 `docs/operations/2026-09-08_PR_INTEGRATION_CORRECTIONS.md`를 참조한다. 당시 후속 범위였던 강호행로 4회 선택은 이후 PR 322로 구현·병합됐다.

```yaml
project: 십보강호: 숨은 수의 비무
repository: alsdmlals4-eng/Ten-Paces-Hidden-Moves
current_work_contract: TEN-DEC-20260828-REPOSITORY-ONLY-CANONICAL-WORKSPACE-01
product_safety_contract_baseline: TEN-DEC-20260826-INTEGRATED-WORK-CONTRACT-V4-8-R5-4-01
current_truth_source: GITHUB_MAIN_PLUS_REPOSITORY_HUMAN_STRUCTURED_RUNTIME_OWNERS_LIVE_READ
legacy_discovery_compatibility: "current_truth_source: GITHUB_MAIN_PLUS_SHEET_LIVE_READ"
legacy_sheet_migration_locator: "03_무공서_무학"
current_main_policy: ALWAYS_REFETCH_GITHUB_MAIN
base_remote_main_policy: ALWAYS_REFETCH_CURRENT_MAIN
live_exact_sha_authority: NONE_REFETCH_REQUIRED
active_project_pr: GITHUB_PR_METADATA_REFETCH_REQUIRED
product_stage: COMBAT_LAYOUT_SOURCE_AND_BOUNDED_RUNTIME_VERIFIED_DELIVERY_PENDING
runtime_work_mode: BUILD
historical_runtime_integration_pr: 65
active_planning_work_mode: BUILD
active_planning_pr: 337
active_planning_parent_pr: NONE
active_approval_count: SCOPED_BUILD_AUTHORIZED_HUMAN_FINAL_NOT_RUN
active_decision_state: COMBAT_LAYOUT_SOURCE_AND_BOUNDED_RUNTIME_VERIFIED_DELIVERY_PENDING
source_decision: TEN-DEC-20260909-COMBAT-LAYOUT-CORRECTION-01
product_gate: PARTIAL_AUTOMATED_COMPLETE
platform_decision: TEN-DEC-20260806-WINDOWS-ANDROID-DUAL-TARGET-01
platform_adapter_decision: TEN-DEC-20260806-WINDOWS-ANDROID-ADAPTER-ARCHITECTURE-01
design_platforms: WINDOWS_ANDROID
platform_core_architecture: SINGLE_CORE_PLATFORM_ADAPTERS
windows_validation: BIMU_CONSTRAINT_VISIBLE_1280X800_CAPTURED_720_HEADLESS_ONLY_MERGED_CI_PASS
android_validation: NOT_RUN
engine: Godot 4.7
historical_runtime_implementation: TEN_MANUAL_PRODUCT_VALIDATION_MERGED_PR92
runtime_implementation: COMBAT_FEEDBACK_PR335_PLUS_ACTOR_BOUND_DURABLE_PR333_MAIN_MERGED_VERIFIED
latest_combat_planning_runtime: PRODUCT_VALIDATION_AUTOMATED
automated_validation: PASS
human_validation: NOT_RUN
accessibility_validation: AUTOMATED_PASS_USER_NOT_RUN
performance_validation: BASELINE_CAPTURED_RELEASE_NOT_RUN
phase_i_vi_implementation: AUTHORIZED_AND_MERGED
future_product_mutation_authorized: false_NEW_PRODUCT_MUTATION_REQUIRES_FRESH_APPROVED_CONTRACT
next_package: COMBAT_LAYOUT_PROTECTED_DELIVERY_THEN_ORDERED_COMBAT_V1_COMPATIBILITY_GROWTH_EVENTS_STATUS_REWARDS
next_planning_decision: TEN-DEC-20260909-COMBAT-LAYOUT-CORRECTION-01
user_directed_planning_work_mode: REVIEW_MACHINE_RUNTIME_READBACK_HUMAN_PLAYER_COMPARISON_DEFERRED
user_directed_planning_decision: TEN-DEC-20260828-REPOSITORY-ONLY-CANONICAL-WORKSPACE-01
user_directed_planning_next_package: COMBAT_LAYOUT_PROTECTED_DELIVERY_THEN_ORDERED_COMBAT_V1_COMPATIBILITY_GROWTH_EVENTS_STATUS_REWARDS
user_directed_planning_next_decision: TEN-DEC-20260909-COMBAT-LAYOUT-CORRECTION-01
user_directed_planning_status: THREE_BRANCH_FOUR_CHOICE_JIANGHU_USER_APPROVED_CURRENT_DOCUMENTATION_AND_CANDIDATE_ATLAS_MACHINE_VERIFIED_RUNTIME_ROUTE_SINGLE_EXECUTE_INLINE_CAUSAL_AND_TERMINAL_RESULT_SURFACES_MAIN_MERGED_VERIFIED_HUMAN_ANDROID_ACCESSIBILITY_RELEASE_NOT_RUN
user_directed_planning_single_execute_status: IMPLEMENTED_MERGED_MAIN_PR329_REMOTE_CI_32_SUCCESS_POSTMERGE_APPROVAL_LIFECYCLE_IN_PROGRESS_HUMAN_ANDROID_ACCESSIBILITY_RELEASE_NOT_RUN
user_directed_planning_current_direction: FRONTAL_SHARED_GROUND_DUEL_NO_VISIBLE_LOGICAL_BOARD_PLUS_3_BRANCH_4_PICK_JIANGHU_ROUTE_PLUS_SINGLE_PLAYER_FACING_ACTION_EXECUTE_CTA_PLUS_CURRENT_CARD_VS_COMPARE_RAIL_PLUS_INLINE_CAUSAL_RECAP_PLUS_UNIFIED_BLUE_GRAY_HANJI_INK_CANDIDATE_STYLE_WITHOUT_SPINE_RUNTIME
user_directed_planning_human_blueprint_publication: exports/ten-paces-hidden-moves_HUMAN_GAME_BLUEPRINT_20260904.pdf
user_directed_planning_human_blueprint_source_builder: tools/build_human_game_blueprint_20260904_pdf.py
user_directed_planning_human_blueprint_incremental_revision_receipt: docs/operations/2026-09-04_THREE_BRANCH_HUMAN_BLUEPRINT_WORK_CONTRACT_RECEIPT.json
user_directed_planning_human_blueprint_incremental_revision_execution_report: docs/operations/2026-09-04_THREE_BRANCH_HUMAN_BLUEPRINT_EXECUTION_REPORT.md
user_directed_planning_human_blueprint_incremental_revision_status: DERIVED_24_PAGE_CURRENT_PUBLICATION_ATLAS_FLOW_WIREFRAME_PM_AND_HANDOFF_MACHINE_DOCUMENT_AND_VISUAL_VERIFIED_RUNTIME_HUMAN_DEVICE_ACCESSIBILITY_RELEASE_NOT_RUN
user_directed_planning_human_blueprint_visual_production_scope: WHOLE_SCENE_CANDIDATE_THEN_ACTUAL_CONSUMER_BOUND_SEPARATED_MODULE_BRIEFS_THEN_USER_FINAL_LOCK_PROVENANCE_AND_GODOT_COMPOSITION_NO_SILENT_REPLACEMENT_OF_FINAL_LOCKED_MODULES
user_directed_planning_latest_decision: TEN-DEC-20260904-THREE-BRANCH-FOUR-CHOICE-JIANGHU-AND-HUMAN-BLUEPRINT-01
user_directed_planning_modular_duel_ui_presentation_decision: docs/decisions/2026-09-03_MODULAR_DUEL_UI_AND_PRESENTATION_MOTION_DECISION.md
user_directed_planning_modular_duel_ui_presentation_execution_report: docs/operations/2026-09-03_MODULAR_DUEL_UI_AND_PRESENTATION_EXECUTION_REPORT.md
user_directed_planning_modular_duel_ui_presentation_status: USER_FINAL_LOCKED_CANON_REGISTERED_IMPLEMENTED_MACHINE_VERIFIED_WINDOWS_REFERENCE_LAYOUT_HOVER_DETAIL_PLAN_LOCK_AND_CURRENT_ACTION_REVEAL_RUNTIME_CAPTURED_TEN_RVC_20260903_001_003_004_005_006_HUMAN_ANDROID_ACCESSIBILITY_RELEASE_NOT_RUN
user_directed_planning_modular_duel_ui_reference_layout_capture_manifest: docs/evidence/RUNTIME_VISUAL_CAPTURE_MANIFEST.json#TEN-RVC-20260903-003-through-006
user_directed_planning_modular_duel_ui_presentation_scope: FOUR_FINAL_LOCKED_DYNAMIC_UI_FRAMES_TYPE_ONLY_OBSERVATION_CURRENT_BUNDLE_ONLY_REVEAL_AND_SIX_PRESENTATION_ONLY_MOTIONS_NO_CORE_AI_SAVE_OR_LOCKED_V2_BATTLER_BYTE_CHANGE
user_directed_planning_native_2d_presentation_phase_decision: docs/decisions/2026-09-03_NATIVE_2D_PRESENTATION_PHASE_ABSORPTION_DECISION.md
user_directed_planning_native_2d_presentation_phase_status: USER_APPROVED_IMPLEMENTED_LOCAL_MACHINE_VERIFIED_CURRENT_ACTION_REVEAL_RUNTIME_CAPTURED_TEN_RVC_20260903_006_HUMAN_ANDROID_ACCESSIBILITY_RELEASE_NOT_RUN
user_directed_planning_native_2d_presentation_phase_scope: PRESENTATION_ONLY_IDLE_WINDUP_ACTIVE_RECOVERY_SNAPSHOT_INTERRUPT_AND_GROUNDED_SCALE_PIVOT_NO_SPINE_INSTALL_RUNTIME_DEPENDENCY_OR_LOCKED_V2_BATTLER_BYTE_CHANGE
user_directed_planning_native_2d_presentation_phase_external_tool_disposition: SPINE_EDITOR_RUNTIME_GDEXTENSION_REJECTED_NO_INSTALL_GODOT_SKELETON2D_DEFERRED_UNTIL_REAL_PARTED_ART_CONSUMER
user_directed_planning_canon_conflict: CANON_CONFLICT_REMOTE_MAIN_1509317D_REINTRODUCES_DIAGONAL_HYPOTHESIS_AND_TEXT_FIRST_SURFACES_CONTRARY_TO_LATEST_USER_FINAL_LOCK; NO_AUTOMATIC_REBASE_OR_MAIN_MUTATION
user_directed_planning_opening_distance: PUBLIC_DISTANCE_2_RUNTIME_BINDING_IMPLEMENTED_MERGED_MAIN_PR_261
user_directed_planning_failure_retry: ONE_FREE_SAME_SEED_RETRY_PER_DUEL_THEN_END_RUN_IMPLEMENTED_MERGED_MAIN_PR_261
user_directed_planning_pending_material_decision: HUMAN_PLAYER_COMPARISON_DEFERRED_MACHINE_EVIDENCE_INSUFFICIENT_FOR_SEPARATE_NUMERICAL_DECISION
user_directed_planning_balance_instrumentation_decision: docs/decisions/2026-08-30_BALANCE_INSTRUMENTATION_CONTRACT_DECISION.md
user_directed_planning_balance_instrumentation_design_spec: docs/superpowers/specs/2026-08-30-balance-instrumentation-design.md
user_directed_planning_balance_instrumentation_design_execution_report: docs/operations/2026-08-30_BALANCE_INSTRUMENTATION_DESIGN_EXECUTION_REPORT.md
user_directed_planning_balance_instrumentation_execution_report: docs/operations/2026-08-30_BALANCE_INSTRUMENTATION_IMPLEMENTATION_EXECUTION_REPORT.md
user_directed_planning_balance_instrumentation_status: IMPLEMENTED_MERGED_MAIN_PR280_REMOTE_CI_PASS_PROTECTED_APPROVAL_ARCHIVED_PR281_POSTMERGE_READBACK
user_directed_planning_balance_measurement_policy_coverage_decision: docs/decisions/2026-08-30_BALANCE_MEASUREMENT_POLICY_COVERAGE_EXTENSION_DECISION.md
user_directed_planning_balance_measurement_policy_coverage_design_spec: docs/superpowers/specs/2026-08-30-balance-measurement-policy-coverage-extension-design.md
user_directed_planning_balance_measurement_policy_coverage_execution_report: docs/operations/2026-08-30_BALANCE_MEASUREMENT_POLICY_COVERAGE_EXTENSION_IMPLEMENTATION_EXECUTION_REPORT.md
user_directed_planning_balance_measurement_policy_coverage_status: IMPLEMENTED_MERGED_MAIN_PR289_REMOTE_CI_PASS_PROTECTED_APPROVAL_ARCHIVED_PR290_POSTMERGE_READBACK_4500_SCENARIOS_TWO_BYTE_IDENTICAL_REPORTS
user_directed_planning_balance_measurement_policy_coverage_report_sha256: B311E75470063A96A382356C55C03E107CDF23316EB8035C360298B0DF7B4D5D
user_directed_planning_balance_measurement_policy_coverage_approval_archive: docs/operations/2026-08-30_PR289_PROTECTED_CHANGE_APPROVAL_RECORD.md
user_directed_planning_balance_measurement_policy_coverage_postmerge_readback: docs/operations/2026-08-30_PR290_BALANCE_MEASUREMENT_POLICY_COVERAGE_POSTMERGE_READBACK.md
user_directed_planning_balance_measurement_representative_policy_coverage_decision: docs/decisions/2026-08-30_BALANCE_MEASUREMENT_REPRESENTATIVE_POLICY_COVERAGE_DECISION.md
user_directed_planning_balance_measurement_representative_policy_coverage_design_spec: docs/superpowers/specs/2026-08-30-balance-measurement-representative-policy-coverage-design.md
user_directed_planning_balance_measurement_representative_policy_coverage_result_review: docs/operations/2026-08-30_BALANCE_MEASUREMENT_REPRESENTATIVE_POLICY_COVERAGE_RESULT_REVIEW.md
user_directed_planning_balance_measurement_representative_policy_coverage_result_review_execution_report: docs/operations/2026-08-30_BALANCE_MEASUREMENT_REPRESENTATIVE_POLICY_COVERAGE_RESULT_REVIEW_EXECUTION_REPORT.md
user_directed_planning_balance_measurement_representative_policy_coverage_execution_report: docs/operations/2026-08-30_BALANCE_MEASUREMENT_REPRESENTATIVE_POLICY_COVERAGE_IMPLEMENTATION_EXECUTION_REPORT.md
user_directed_planning_balance_measurement_representative_policy_coverage_status: IMPLEMENTED_MERGED_MAIN_PR292_REMOTE_CI_PASS_PROTECTED_APPROVAL_ARCHIVED_PR293_POSTMERGE_READBACK_6750_SCENARIOS_TWO_BYTE_IDENTICAL_REPORTS_SCHEMA_3_RESULT_REVIEW_MERGED_MAIN_PR295_REMOTE_CI_PASS_POSTMERGE_READBACK_NO_NUMERICAL_MUTATION_RECOMMENDED
user_directed_planning_balance_measurement_representative_policy_coverage_report_sha256: A0669A0727C9608B6A240910CE529263C1982C510E4B3C376BD58D8AB5F66558
user_directed_planning_balance_measurement_representative_policy_coverage_approval_archive: docs/operations/2026-08-30_PR292_PROTECTED_CHANGE_APPROVAL_RECORD.md
user_directed_planning_balance_measurement_representative_policy_coverage_postmerge_readback: docs/operations/2026-08-30_PR293_REPRESENTATIVE_POLICY_COVERAGE_POSTMERGE_READBACK.md
user_directed_planning_machine_runtime_readback_execution_report: docs/operations/2026-08-30_MACHINE_RUNTIME_READBACK_HUMAN_PLAYER_COMPARISON_DEFERRED_EXECUTION_REPORT.md
user_directed_planning_machine_runtime_readback_status: PARTIAL_CURRENT_MAIN_GODOT_4_7_1_VISIBLE_COMBAT_SCREEN_AND_6750_ROW_REPORT_SHA_MATCHED_HUMAN_PLAYER_COMPARISON_DEFERRED
user_directed_planning_machine_runtime_readback_report_sha256: A0669A0727C9608B6A240910CE529263C1982C510E4B3C376BD58D8AB5F66558
user_directed_planning_prework_benchmark_gate: TEN-DEC-20260830-PREWORK-BENCHMARK-REVERSE-ENGINEERING-GATE-01
user_directed_planning_prework_benchmark_status: IMPLEMENTED_MERGED_MAIN_PR287_REMOTE_CI_PASS_EXACT_MAIN_POSTMERGE_READBACK
user_directed_planning_prework_benchmark_postmerge_evidence: PR287_SQUASH_ba4fed201f4c2e37f9ed5fbc32027344ccb9a56d
user_directed_planning_prework_benchmark_report: docs/reviews/2026-08-30_TEN_PACES_BENCHMARK_REVERSE_ENGINEERING.md
user_directed_planning_prework_benchmark_evidence_ceiling: DESK_RESEARCH_ONLY_NO_TEN_PACES_RUNTIME_HUMAN_PLAYER_VALIDATION
user_directed_planning_long_horizon_direction: IMPLEMENT_GDD_BY_APPROVED_VERIFIED_GODOT_PACKAGES_WITHOUT_SILENT_CORE_SCOPE_EXPANSION
user_directed_planning_opponent_runtime_personality_issue: 267
user_directed_planning_opponent_runtime_personality_design_spec: docs/superpowers/specs/2026-08-29-opponent-runtime-personality-binding-design.md
user_directed_planning_opponent_runtime_personality_implementation_contract: docs/implementation/2026-08-29_OPPONENT_RUNTIME_PERSONALITY_BINDING_IMPLEMENTATION_CONTRACT.md
user_directed_planning_opponent_runtime_personality_implementation_plan: docs/superpowers/plans/2026-08-29-opponent-runtime-personality-binding.md
user_directed_planning_opponent_runtime_personality_handoff: docs/handoffs/2026-08-29_OPPONENT_RUNTIME_PERSONALITY_CODEX_GODOT_IMPLEMENTATION_HANDOFF.md
user_directed_planning_opponent_runtime_personality_status: IMPLEMENTED_MERGED_MAIN_PR273_POSTMERGE_READBACK
user_directed_planning_frontal_duel_presentation_decision: docs/decisions/2026-08-31_FRONTAL_DUEL_PRESENTATION_AND_ILLUSTRATED_CARD_POLICY_DECISION.md
user_directed_planning_frontal_duel_presentation_status: USER_FINAL_LOCKED_IMPLEMENTED_MACHINE_RUNTIME_VERIFIED_20260831
user_directed_planning_frontal_duel_presentation_execution_report: docs/operations/2026-08-31_FRONTAL_DUEL_PRESENTATION_EXECUTION_REPORT.md
user_directed_planning_card_illustration_decision: TEN-DEC-20260831-ACTION-CARD-ILLUSTRATION-EXTENSION-01
user_directed_planning_card_illustration_status: MARTIAL_AND_ULTIMATE_ATLAS_USER_FINAL_LOCKED_CANON_REGISTERED_IMPLEMENTED_MACHINE_RUNTIME_VERIFIED_20260831
user_directed_planning_card_illustration_candidate: docs/visual-assets/candidates/MARTIAL_AND_ULTIMATE_CARD_ILLUSTRATION_ATLAS_01_v1.png
user_directed_planning_card_illustration_approved: docs/visual-assets/approved/MARTIAL_AND_ULTIMATE_CARD_ILLUSTRATION_ATLAS_01_v1.png
user_directed_planning_card_illustration_runtime: res://assets/ui/cards/martial_ultimate_card_illustration_atlas_01_v1.png
user_directed_planning_title_feedback_status: TITLE_LOGO_01_AND_ATTACK_CLASH_ATLAS_01_USER_FINAL_LOCKED_CANON_REGISTERED_IMPLEMENTED_AUTOMATED_GODOT_VERIFIED_20260831
user_directed_planning_natural_combat_feedback_execution_report: docs/operations/2026-08-31_NATURAL_COMBAT_FEEDBACK_EXECUTION_REPORT.md
user_directed_planning_natural_combat_feedback_postmerge_readback: docs/operations/2026-08-31_PR301_NATURAL_COMBAT_FEEDBACK_POSTMERGE_READBACK.md
user_directed_planning_natural_combat_feedback_approval_archive: docs/operations/2026-08-31_PR301_PROTECTED_CHANGE_APPROVAL_RECORD.md
user_directed_planning_natural_combat_feedback_status: IMPLEMENTED_MERGED_MAIN_PR301_REMOTE_CI_PASS_PROTECTED_APPROVAL_ARCHIVE_RECORD_RETAINED_MANIFEST_REMOVED_BY_THIS_CLEANUP_COMMIT_VISIBLE_TEN_PACES_RUNTIME_NOT_RUN
user_directed_planning_natural_combat_feedback_scope: PUBLIC_RESOLVED_EVENT_WINDUP_IMPACT_SETTLE_ONLY_NO_CORE_AI_SAVE_CARD_OR_ASSET_BYTE_CHANGE
user_directed_planning_title_logo_runtime: res://assets/ui/logo/ten_paces_hidden_moves_title_logo_01_v1.png
user_directed_planning_attack_clash_vfx_runtime: res://assets/vfx/attack_clash_ink_gold_atlas_rgba_v1.png
user_directed_planning_action_card_source_unification_decision: TEN-DEC-20260830-ACTION-CARD-SOURCE-UNIFICATION-01
user_directed_planning_action_card_source_unification_status: USER_APPROVED_IMPLEMENTED_LOCAL_MACHINE_RUNTIME_OBSERVED_INDEPENDENT_REVIEW_CLOSED_COMMITTED_478AA03B_PENDING_PR
user_directed_planning_action_card_source_unification_handoff: docs/handoffs/2026-08-30_ACTION_CARD_SOURCE_UNIFICATION_CODEX_GODOT_IMPLEMENTATION_HANDOFF.md
user_directed_planning_action_card_source_unification_execution_report: docs/operations/2026-08-30_ACTION_CARD_SOURCE_UNIFICATION_EXECUTION_REPORT.md
user_directed_planning_unified_implementation_contract: TEN-IMP-20260828-PHASE2-COMBAT-CANON-RECONCILIATION-01
user_directed_planning_unified_implementation_contract_status: IMPLEMENTED_MERGED_MAIN_PR_261
user_directed_planning_unified_implementation_issue: 258
user_directed_planning_unified_implementation_issue_status: CLOSED_POSTMERGE_READBACK_20260829
user_directed_planning_pr_authority: GITHUB_PR_METADATA
planning_execution_surface: REPOSITORY_ONLY_GPT_WORK
planning_work_handoff: docs/handoffs/2026-08-26_GPT_WORK_HANDOFF.md
planning_visual_next: WHOLE_SCENE_ATLAS_CANDIDATE_GENERATED_ACTUAL_RUNTIME_CONSUMER_BOUND_SPLIT_BRIEFS_REQUIRE_SEPARATE_GODOT_BUILD_PACKAGE_AND_USER_FINAL_LOCK
planning_visual_generation: SCOPED_SINGLE_RESULT_GENERATED_CANDIDATE_SEPARATE_FINAL_USER_LOCK_REQUIRED
planning_visual_review: FRONTAL_COURTYARD_DUEL_BACKGROUND_01_MARTIAL_ULTIMATE_CARD_ATLAS_TITLE_LOGO_01_AND_ATTACK_CLASH_ATLAS_01_USER_FINAL_LOCKED_IMPLEMENTED_AUTOMATED_GODOT_VERIFIED
planning_visual_martial_manual_presentation: SHARED_SEMANTIC_CARD_ILLUSTRATION_USER_FINAL_LOCKED_CANON_REGISTERED_IMPLEMENTED_RUNTIME_VERIFIED_TEN-DEC-20260831-ACTION-CARD-ILLUSTRATION-EXTENSION-01
planning_visual_state: docs/planning-data/current_visual_production_handoff_20260826.json
planning_visual_historical_state: docs/planning-data/current_visual_production_handoff_20260825.json
planning_visual_authority: TEN-DEC-20260820-VISUAL-UX-SYSTEM-01
planning_visual_production_decision: TEN-DEC-20260827-WARM-DUSK-TEN-STEP-VISUAL-DIRECTION-01
planning_visual_planning_anchor_decision: TEN-DEC-20260828-WARM-DUSK-V2-PLANNING-ANCHOR-01
planning_visual_cadence_decision: TEN-DEC-20260828-CORE-SCENE-VISUAL-BOARD-FINAL-LOCK-CADENCE-01
planning_visual_requirement_status: COMPLETE
planning_visual_overlay: TEN-DEC-20260811-COMBAT-UI-INFORMATION-HIERARCHY-01
ci_supply_chain_followup: RESOLVED_ISSUE_140
base_release_pinned: 9.4.4
base_remote_observation: CURRENT_REMOTE_REQUIRES_LIVE_REFETCH_NO_AUTOMATIC_PROJECT_ADOPTION
```

`legacy_discovery_compatibility`와 `legacy_sheet_migration_locator`의 Sheet 문자열은 기존 회귀·발견 도구가 과거 상태·콘텐츠 표를 찾기 위한 호환 토큰일 뿐이다. 실제 current truth는 `GITHUB_MAIN_PLUS_REPOSITORY_OWNER_LIVE_READ`이며 신규 기획 입력·Decision 동기화는 repository를 사용하고 Google Sheets는 migration-only다.

`active_planning_*`, `active_decision_state`, `next_package`, `next_planning_decision`은 `docs/planning-data/current_operating_state.json`의 현재 승인 실행 패키지와 동기화한다. 과거 플랫폼 Adapter 기획은 역사 계보이며 Android 구현 승인으로 승격하지 않는다. 상세 기획/Visual production은 `docs/planning-data/current_user_planning_status.json`, `docs/planning-data/current_visual_production_handoff_20260826.json`, `user_directed_planning_*`·`planning_visual_*` overlay가 소유한다.

플랫폼 Adapter 구현 Gate는 향후 플랫폼 확장 경계로 계속 유효하다. 첫 5전 PC-first Vertical Slice Phase I–VI와 `TEN-IMP-20260828-PHASE2-COMBAT-CANON-RECONCILIATION-01`은 `main`에 병합된 역사 근거다. `WARM_DUSK_TEN_STEP_COMBAT_ANCHOR_01_v2_NO_FLOOR_GRID`와 `PROJECT_CORE_SCENE_VISUAL_BOARD_20260828_R2`는 planning-only다. 최신 사용자 final lock으로 `FRONTAL_COURTYARD_DUEL_BACKGROUND_01`과 `MARTIAL_AND_ULTIMATE_CARD_ILLUSTRATION_ATLAS_01`은 각각 실제 소비처에 등록·구현되고 Godot 4.7.1 visible runtime에서 검증됐다. 카드 atlas는 `ActionViewModelAdapter`의 source-kind semantic mapping을 통해 하나의 `ActionChoiceCard` renderer로 전달되며 전투 규칙·AI·저장 schema를 바꾸지 않는다. 이전 ink-mist/diagonal runtime binaries는 현재 tree에서 제거됐으며 Git history로 복구 가능하다. Codex는 GitHub + repository owners fresh-read를 current authority로 사용한다.

이 live block에는 current main SHA나 열린 PR 번호를 저장하지 않는다. 새 세션·post-merge에서는 GitHub `main`, 열린 PR, repository current operating/visual/entry owner를 다시 읽고 의미 상태만 판정한다. exact SHA/run ID·PR 번호는 아래의 명시적 역사·관측 증거로만 취급한다.

## 관측 증거 스냅샷

다음 값은 당시 확인된 **역사/관측 증거**이며 live current authority가 아니다.

```yaml
historical_project_main_at_handoff: 43841d3cc6667d821c10df75272b239f314f3df0
historical_base_main_at_handoff: 637dad32c773c56a27d44d847518580848dee493
merged_planning_checkpoint: 023385d372d127044d48afcb50e6f232ab9ffaa1
merged_pr_lineage: 84,86,87,88,89,91,92,100,101,102
product_implementation_merge_commit: a839cd724d0d3ca60c8066abe5a1e2a5e0b78e90
merged_product_pr: 92
evidence_source_head: 0a8bf577b936ddac5cb7130a0cc58e519ea6eff6
platform_adapter_merge_commit: 023385d372d127044d48afcb50e6f232ab9ffaa1
merged_platform_adapter_pr: 102
observed_project_main_2026_08_11: 0a9e74b09816be891b3fb1cccca5e700a9ead064
observed_base_main_2026_08_11: 315c66eea9614c284b9c11c4d522141065dfa4b0
observed_recent_canon_reconciliation_prs: 137,138,139
planning_pr_2026_08_20: 165
planning_detail_prs_2026_08_20: 166,168,170
planning_review_ready_sync_pr_2026_08_20: 171
planning_complete_prs_2026_08_20: 172,173
planning_pr_2026_08_20_base: 0e9955afe791c43255176a4e89d89cf58be9b76a
historical_pre_phase_i_vi_product_stage: VERTICAL_SLICE_VISUAL_UX_REQUIREMENT_COMPLETE_HANDOFF_READY
historical_pre_phase_i_vi_product_implementation_authorized: false
phase_i_vi_completion_pr: 183
phase_i_vi_completion_merge_commit: dfe25dec47f02229ecc5c92cdad7b6e1929525c8
authority_bootstrap_pr: 186
authority_bootstrap_merge_commit: 43a6e625c57c6f3e50b562e494fec074be553457
```

위 `observed_*` 값과 planning PR base도 다음 merge 뒤 자동 current가 되지 않는다. current 여부는 항상 live refetch로 다시 판정한다.

## 현재 권위와 보호 결정

- 현행 프로젝트 실행 계약: `TEN-DEC-20260826-INTEGRATED-WORK-CONTRACT-V4-8-R5-4-01`, `docs/PROJECT_TOTAL_PLANNING_IMPLEMENTATION_AND_DELIVERY_INSTRUCTION.md`.
- 첫 5전 Vertical Slice 기획 완료 승인: `TEN-DEC-20260820-VERTICAL-SLICE-PLANNING-COMPLETE-01`, `docs/planning-data/current_user_planning_status.json`.
- Visual/UX Requirement 승인: `TEN-DEC-20260820-VISUAL-UX-SYSTEM-01`, `docs/17_VERTICAL_SLICE_VISUAL_UX_REQUIREMENT_SPEC.md`, `docs/planning-data/approved_20260820_vertical_slice_visual_ux_contract.json`.
- Consumer-first Visual production 승인: `TEN-DEC-20260826-VISUAL-CONSUMER-ASSET-PRODUCTION-01`, `docs/decisions/2026-08-26_VISUAL_CONSUMER_ASSET_PRODUCTION_DECISION.md`.
- 무공 기술서 표현 승인: `TEN-DEC-20260830-MARTIAL-MANUAL-TEXT-FIRST-PRESENTATION-01` — `MartialActionPanel`의 무공 기술은 삽화 없이 텍스트·태그·수치로 표현하며 기초 카드/전장/절초 연출은 유지한다.
- 새 L1+ package 사전 벤치마크: `TEN-DEC-20260830-PREWORK-BENCHMARK-REVERSE-ENGINEERING-GATE-01` — 사용자 지시에 따라 plan/mutation 전에 10개 이상 유사·인접 게임을 공식 제품 사실과 `DO_NOT_COPY` 경계로 역공학한다. 초기 12개 packet은 `docs/reviews/2026-08-30_TEN_PACES_BENCHMARK_REVERSE_ENGINEERING.md`이며, 이는 제품/사람 플레이 검증이나 core 변경이 아니다.
- 현재 Visual production Gate: `docs/19_VISUAL_PRODUCTION_CURRENT_GATE_2026-08-26.md`, `docs/planning-data/current_visual_production_handoff_20260826.json`.
- GPT Work 인수인계: `docs/handoffs/2026-08-26_GPT_WORK_HANDOFF.md`; historical Notion handoff는 migration/history input이다.
- 2026-08-25 승인 Reference Set: `docs/18_VISUAL_PRODUCTION_HANDOFF_2026-08-25.md`, `docs/planning-data/current_visual_production_handoff_20260825.json` — 승인 Reference와 당시 max-three cadence의 역사 evidence이며 current execution owner가 아니다.
- 구현 Gate: `TEN-DEC-20260820-PC-FIRST-VERTICAL-SLICE-IMPLEMENTATION-GATE-01`, `docs/planning-data/current_vertical_slice_implementation_gate_20260820.json`.
- Phase I–VI 상태: `AUTHORIZED_AND_MERGED`; exact PR/SHA는 위 관측 증거 스냅샷에서만 역사 증거로 보존한다.
- 구현 Handoff: `docs/16_VERTICAL_SLICE_IMPLEMENTATION_HANDOFF_PLAN.md`.
- 강호 비무행·플레이어 역할·5전 감정곡선·비전투 App Flow: `TEN-DEC-20260904-THREE-BRANCH-FOUR-CHOICE-JIANGHU-AND-HUMAN-BLUEPRINT-01`, `docs/12_VERTICAL_SLICE_JIANGHU_JOURNEY.md`. `TEN-DEC-20260820-JIANGHU-JOURNEY-VERTICAL-SLICE-01`의 구간당 2노드는 historical baseline이다.
- 15명 후보·8개 Route·Briefing/Review/Result 텍스트 UX: `TEN-DEC-20260820-VERTICAL-SLICE-CONTENT-DETAIL-01`, `docs/13_VERTICAL_SLICE_OPPONENT_ROUTE_TEXT_UX.md`.
- 후보 무공 배정·Route Seed·비전투 Wire: `TEN-DEC-20260820-VERTICAL-SLICE-LOADOUT-ROUTE-WIRE-01`, `docs/14_VERTICAL_SLICE_LOADOUT_ROUTE_BUDGET_WIREFRAME.md`.
- 난이도 Seed·AI 공정성·검증 계약·aggregate 시간 예산·Planning Review Ready: `TEN-DEC-20260820-VERTICAL-SLICE-REVIEW-READY-01`, `docs/15_VERTICAL_SLICE_REVIEW_READY_CONTRACT.md`.
- 플랫폼 범위: `TEN-DEC-20260806-WINDOWS-ANDROID-DUAL-TARGET-01`.
- 플랫폼 Adapter 아키텍처: `TEN-DEC-20260806-WINDOWS-ANDROID-ADAPTER-ARCHITECTURE-01`.
- 행동 선택 UX: `TEN-DEC-20260801-MARTIAL-TECHNIQUE-UX-01`.
- 상황 화면 구조: `TEN-DEC-20260801-SITUATION-SCREEN-01`.
- 전투 UI 정보 위계·거리·카드·관찰 표시 오버레이: `TEN-DEC-20260811-COMBAT-UI-INFORMATION-HIERARCHY-01`.
- 시작 공개 거리 런타임 매핑: `TEN-DEC-20260828-OPENING-DISTANCE-RUNTIME-MAPPING-01` — 시작 state·거리 계산·AI 입력·HUD·접근성 이름·로그가 공개 거리2를 단일 의미로 사용한다. 내부 좌표는 단일 구현계약의 기술 binding이며 현재 제품 evidence는 `NOT_RUN`.
- 관찰 정답 누출 방지: `TEN-DEC-20260805-OBSERVATION-ANSWER-LEAK-GUARDRAILS-01`.
- 초기 무공서 런타임 기반 권위: `TEN_MANUAL_RUNTIME_IMPLEMENTATION_GATE`.
- 초기 무공서 UI·AI 채택 권위: `TEN_MANUAL_UI_AI_ADOPTION_GATE`.
- 초기 무공서 자동 제품 검증 권위: `TEN_MANUAL_PRODUCT_VALIDATION_GATE`.
- GUT 9.7.1 reconciliation/export boundary: `TEN-DEC-20260807-GUT-9-7-1-RECONCILIATION-01`.
- Hera v1 live QA: `TEN-DEC-20260808-HERA-V1-LIVE-QA-RECONCILIATION-01`.
- 활성 Godot toolchain: `TEN-DEC-20260809-GODOT-AI313-GUT971-HERA100-ACTIVE-TOOLCHAIN-01`.
- TEN-IMG-001 exploration 권한: `TEN-DEC-20260808-TEN-IMG-001-VISUAL-REQUIREMENT-APPROVAL-01`; chat exploration은 수행됐지만 제품 자산 승격 없이 `NOT_AN_ASSET`이다. 현재 새 이미지는 actual consumer와 scoped brief 뒤 pre-generation 승인 없이 정확히 한 결과를 만들고 adversarial review 후 사용자 final lock을 받는다.
- CI 공급망 follow-up: Issue #140은 `RESOLVED / CLOSED_COMPLETED`이며 active 후속 작업이 아니다.
- 과거 v6 인덱스는 `docs/decisions/2026-07-28_V6_DECISION_AUTHORITY_LEDGER.md`이며 최신 Decision보다 높은 권한을 갖지 않는다.

제품 코어·전투 규칙·성장·UI·저장 의미는 해당 분야 책임 원본을 따른다. 이 문서는 그 전문을 대체하지 않는다.

## 선행 UX·앱 흐름 권위

- `TEN-DEC-20260820-VERTICAL-SLICE-PLANNING-COMPLETE-01` — 아래 첫 5전 Vertical Slice 기획 계보를 사용자 완료 승인한다.
- `TEN-DEC-20260820-VISUAL-UX-SYSTEM-01` — 통합 수묵 전술 화폭, 화면별 정보 위계, 재사용 컴포넌트, 최소 신규 자산 요구사항을 승인하고 당시 명시적 자산/구현 요청 대기로 전환했다. 이후 2026-08-25 사용자가 Visual 작업을 명시 재개했고, 2026-08-28 현행 cadence는 scoped 한 결과 생성 뒤 user final lock을 소유한다.
- `TEN-DEC-20260826-VISUAL-CONSUMER-ASSET-PRODUCTION-01` — 설명용/스타일 검증용 이미지를 current production 대상으로 만들지 않고 실제 게임 소비처가 확인된 자산만 생성한다. 도겸 Character Master와 실제 전장 consumer용 `DOGYEOM_COMBAT_BATTLER_01`은 사용자 승인 완료이며, 상태 패널 consumer용 `DOGYEOM_STATUS_PORTRAIT_01`도 새 원화 1장으로 사용자 승인·historical Notion binary delivery evidence 후 상태 패널에 구현됐다. 도겸 ID만 승인 초상으로 라우팅하며 다른 상대는 generic fallback을 유지한다. 다음 Visual은 자동 시작하지 않지만 concrete consumer가 있으면 pre-generation 승인 없이 scoped 결과를 만들고 final lock만 사용자에게 요청한다.
- `TEN-DEC-20260820-JIANGHU-JOURNEY-VERTICAL-SLICE-01` — historical baseline: Main→시작 6중4→비무행 도입→Briefing→Combat Review Overlay→Duel Result/Reward 별도 Scene→Route 2노드→다음 비무→5전 완주. 화면/route/CTA 경계는 2026-09-04 successor가 대체한다.
- `TEN-DEC-20260904-THREE-BRANCH-FOUR-CHOICE-JIANGHU-AND-HUMAN-BLUEPRINT-01` — `비무 결과 → 3갈래 중 1개 × 정확히 4회 → 다음 Briefing`, 단일 `행동 실행`, 현재 카드 `VS`, 별도 Review 없음의 현재 문서 계약과 24-page 사람용 Blueprint 후보 atlas의 정본 연결. Godot route/CTA/review surface는 `IMPLEMENTED_LEGACY`; 새 계약 runtime은 `NOT_RUN`이다.
- `TEN-DEC-20260820-VERTICAL-SLICE-CONTENT-DETAIL-01` — 후보 15명·8개 Route·텍스트 UX.
- `TEN-DEC-20260820-VERTICAL-SLICE-LOADOUT-ROUTE-WIRE-01` — 기존 10권 재사용·다음 후보 선잠금·Route 수치 Seed·비전투 Wire.
- `TEN-DEC-20260820-VERTICAL-SLICE-REVIEW-READY-01` — 난이도/AI/검증/시간 예산과 최종 기획 검토 준비.
- `TEN-DEC-20260801-MARTIAL-TECHNIQUE-UX-01`.
- `TEN-DEC-20260801-SITUATION-SCREEN-01`.
- 역사 구현 표식: `runtime_implementation: ACTION_SELECTION_DOCK_IMPLEMENTED_PR65`.
- V6 원장: `2026-07-28_V6_DECISION_AUTHORITY_LEDGER.md`.

위 App Flow·상세 계약·Visual/UX 요구사항은 계획 권위다. 사용자 `기획완료`와 후속 Visual/UX 승인 자체는 제품 mutation 권한이 아니었고, 이후 `TEN-DEC-20260820-PC-FIRST-VERTICAL-SLICE-IMPLEMENTATION-GATE-01`이 첫 5전 Phase I–VI bounded implementation을 별도로 승인했다. PR #65와 `TEN_MANUAL_PRODUCT_VALIDATION_MERGED_PR92`는 선행 런타임/자동검증 계보로 보존하고, 현재 전체 Phase I–VI 구현 상태는 상단 `phase_i_vi_implementation: AUTHORIZED_AND_MERGED`가 라우팅한다. `DOGYEOM_STATUS_PORTRAIT_01`은 승인 결과를 실제 상태 패널 소비처에 연결했고, focused Godot 자동 검증과 Vertical Slice bridge 회귀가 통과했다. Windows human visual review와 Android evidence는 여전히 별도다.
위 App Flow·상세 계약·Visual/UX 요구사항은 계획 권위다. 사용자 `기획완료`와 후속 Visual/UX 승인 자체는 제품 mutation 권한이 아니었고, 이후 `TEN-DEC-20260820-PC-FIRST-VERTICAL-SLICE-IMPLEMENTATION-GATE-01`이 첫 5전 Phase I–VI bounded implementation을 별도로 승인했다. PR #65와 `TEN_MANUAL_PRODUCT_VALIDATION_MERGED_PR92`는 선행 런타임/자동검증 계보로 보존하고, 현재 전체 Phase I–VI 구현 상태는 상단 `phase_i_vi_implementation: AUTHORIZED_AND_MERGED`가 라우팅한다. `DOGYEOM_STATUS_PORTRAIT_01`은 승인 Master PNG를 복구하지 못한 뒤 사용자 명시 승인으로 새 원화 정확히 1장을 생성·검토·승인했고 historical Notion actual attachment/readback evidence 뒤 상태 패널 소비처에 연결됐다. focused Godot 자동 검증과 Vertical Slice bridge 회귀가 통과했으며 Windows human visual review와 Android evidence는 여전히 별도다.

## 제품 연결·성장 보호 표식

- 적 AI는 자기 명시적 loadout과 공개 상태만 사용하며 **플레이어 비공개 계획·미확정 배치·포인터는 참조하지 않는다**.
- 능력치별 무공서 권수·균등 분포·최소/최대 쿼터는 사용하지 않는다.
- 무공서·무학 사용자-facing 동기화는 repository의 확정 기획 작업면과 해당 GitHub 권위 문서의 Decision ID를 대조한다. Google Sheets는 신규 입력이 아니라 migration-only다.

이 세 표식은 후속 플랫폼·handoff 정리로 제품 권위가 사라졌다고 오인하지 않기 위한 discovery contract다.

## 자동 제품 검증 권위

```yaml
product_gate: PARTIAL_AUTOMATED_COMPLETE
evidence_source_head: 0a8bf577b936ddac5cb7130a0cc58e519ea6eff6
workflow_run_id: 31074079068
windows_artifact_id: 8956790279
windows_export: PASS
windows_ci_runtime: PASS
scenario_matrix: 50/50 PASS
local_windows_visible_render: NOT_RUN
release_performance: NOT_RUN
human_step14: NOT_RUN
balance_validation: NOT_RUN
```

Windows CI 기준 runtime은 약 2344.67ms, peak working set은 188571648 bytes, exe+pck는 123037256 bytes였다. runner 또는 Godot 버전이 바뀌면 직접 baseline 비교를 금지한다.

이 자동 제품 증거는 Windows CI export/runtime·합성 입력·자동 접근성·성능 baseline 범위다. 로컬 visible render, 실물 입력, 접근성 사용자, Release 성능, 실제 Android, 사람 플레이를 대신하지 않는다.

## 관찰 권위

`TEN-DEC-20260805-OBSERVATION-ANSWER-LEAK-GUARDRAILS-01`은 후속 무공·런타임·UI·AI·강호행로 Decision 뒤에도 유지된다.

관찰은 행동1수→관찰량1→적 선잠금 뒤 앞 슬롯 실제 행동 종류 직접 공개를 유지한다.

- 적은 공개 전에 현재 묶음을 잠근다.
- 공개 뒤 적 계획을 교체하지 않는다.
- 정답 카드·정확한 대응 추천·숨은 AI 가중치는 공개하지 않는다.
- 관찰 약화나 자동 비용 인상은 사람 측정과 별도 Decision 전까지 금지한다.
- `OBSERVATION_ANSWER_LEAK_RISK`: `PENDING_HUMAN_MEASUREMENT`.

## 역사적 발견·회귀 호환 표식

다음 문자열은 과거 계보와 구형 회귀의 **발견용 표식일 뿐 현행 mutable state가 아니다**.

- 초기 T0 계보: `PR #7`, `Issue #13`.
- 초기 코어 검토 상태: `CORE_REVIEW_PENDING`.
- PR #92 병합 전 관찰 승인 스냅샷: `active_planning_pr: 92`.
- 제품 병합 전 상태: `active_decision_state: TEN_MANUAL_PRODUCT_VALIDATION_AUTOMATED`.
- 제품 병합 전 다음 Gate: `next_planning_decision: TEN_MANUAL_LOCAL_WINDOWS_ACCESSIBILITY_PERFORMANCE_GATE`.
- 플랫폼 전용 operating-state 표식: `WINDOWS_ANDROID_ADAPTER_ARCHITECTURE_MERGED`, `WINDOWS_ANDROID_ADAPTER_IMPLEMENTATION_GATE`.

현행 실행 패키지는 문서 상단 YAML과 current operating JSON에서 읽는다. 위 플랫폼 전용 표식은 과거 Adapter 설계와 미실행 플랫폼 Gate의 발견용이다. 기획/Visual 세부는 current planning/visual JSON에서 읽는다. `merged_product_pr: 92`, `product_implementation_merge_commit`, `TEN_MANUAL_PRODUCT_VALIDATION_MERGED_PR92`는 과거 제품 병합 계보이며 현재 구현 상태를 대체하지 않는다.

## 완료·검증됨

```yaml
completed_verified:
  gut_9_7_1_reconciliation: PASS
  godot_4_7_1_local_gut_junit: PASS
  hera_v1_exact_pair_live_qa: PASS
  higodot_l2_export_exclusion_authoring: PASS
  higodot_l1_export_readback: PASS
  windows_product_export_regression: PASS
  pck_tooling_exclusion_probe: PASS
  pr_133_export_preset_merge: PASS
  pr_134_canon_closeout_merge: PASS
  pr_137_platform_cold_start_canon: PASS
  pr_138_combat_reprice_canon: PASS
  pr_139_internal_recovery_canon: PASS
```

승인된 product export exclusion은 다음 셋뿐이다.

```text
addons/gut/**
tests/**
.gutconfig.json
```

`addons/godot_ai/runtime/game_helper.gd`를 포함한 Godot AI runtime은 export에 보존됐다. 다른 addon family exclusion은 승인되지 않았다.

## 역사 Entry Gate · 2026-08-08

`docs/planning-data/current_entry_gate_20260808.json`은 Phase I–VI 구현 승인 이전의 플랫폼/제품 pre-implementation Gate다. 후속 `docs/planning-data/current_vertical_slice_implementation_gate_20260820.json`이 첫 5전 Phase I–VI 범위의 current implementation authority를 소유하므로, 이 8월 8일 Gate를 현재 구현 미승인 근거로 재사용하지 않는다. Android/device/Human readiness의 역사 evidence ceiling은 계속 보존한다.

```yaml
status: SUPERSEDED_FOR_PHASE_I_VI_IMPLEMENTATION
local_windows_core: PASS_GODOT_GUT_HERA_EXPORT_CORE
local_android_device: BLOCKED_UNVERIFIED
human_validation: BLOCKED_NOT_RUN
windows_android_adapter_implementation_gate: BLOCKED_BY_ENTRY_GATE
product_implementation_authorized: false
allowed_next_actions:
  - REVIEW_VISUAL_UX_REQUIREMENTS_AND_REFERENCES_WITHOUT_IMAGE_GENERATION
  - PREPARE_VERTICAL_SLICE_IMPLEMENTATION_HANDOFF_WITHOUT_PRODUCT_MUTATION
  - START_PRODUCT_IMPLEMENTATION_ONLY_AFTER_EXPLICIT_USER_REQUEST_AND_FRESH_GATE
  - VERIFY_LOCAL_WINDOWS_ANDROID_DEVICE_AND_HUMAN_GATES_WHEN_REAUTHORIZED
```

이 2026-08-08 Entry Gate는 당시 제품/플랫폼 구현 경계를 기록한 역사 증거다. 이후 2026-08-20 PC-first Vertical Slice 구현 Gate가 Phase I–VI를 별도로 승인했고 해당 bounded 구현은 병합되었다. 따라서 여기의 `product_implementation_authorized: false`는 **당시 pre-implementation 상태**로만 읽는다. 새 이미지 생성과 향후 추가 제품 mutation은 여전히 별도 명시 요청/fresh Gate가 필요하며, Android 실제 기기·Windows visible Human·사람 검증은 실제 실행 전 PASS로 승격하지 않는다.

## 역사 플랫폼 preflight 중단 상태 · 2026-08-10

사용자가 2026-08-10에 `VERIFY_LOCAL_WINDOWS_ANDROID_DEVICE_AND_HUMAN_GATES` 작업을 나중에 다시 수행하기로 연기하고 인수인계를 우선했다. 이 이력은 역사 증거로 보존하며 현재 사용자 지시가 새로 들어오면 다시 current truth를 읽고 재판정한다.

가장 최근 로컬 collector 시도에서 확인된 사실:

```yaml
collector_version: V2_NO_COLLECTION_LENGTH_PROPERTY
expected_project_head: 43841d3cc6667d821c10df75272b239f314f3df0
initial_repository_content_delta: 0
head_equals_origin_main: true
reached_phase: GODOT_DISCOVERY
collector_result: FAIL_OR_BLOCKED_COLLECTOR
failure_class: POWERSHELL_NATIVE_CAPTURE_NULL_HANDLING_BUG
error_summary: null stream value was trimmed/called as an object
windows_export_in_this_attempt: NOT_RUN
windows_50_scenario_runtime_in_this_attempt: NOT_RUN
android_sdk_adb_device_result: NOT_RUN
android_product_result: NOT_RUN
human_validation: NOT_RUN
user_disposition: DEFERRED_BY_USER
```

이 실패는 Android 제품 실패가 아니다. `GODOT_DISCOVERY`에서 collector 구현이 중단됐으므로 플랫폼 결과는 `BLOCKED_UNVERIFIED / NOT_RUN`으로 유지한다. 위 `expected_project_head`도 당시 collector의 역사 입력값일 뿐 current authority가 아니다.

## 다음 재개 절차

새 채팅·제품 구현·플랫폼·Visual 작업을 다시 시작할 때 과거 채팅의 SHA·스크립트를 current truth로 사용하지 않는다. 현재 사용자 지시로 Visual continuation의 기본 실행 surface는 GPT Work다.

```text
1. GPT Work에서 새 세션 시작
2. Base 최신 main/root/Registry/open PR 재조회
3. Project 최신 main/open PR/관련 Decision 재조회
4. current r5.4 product-safety baseline + repository human-facing/structured owner 재조회
5. current_user_planning_status + current_visual_production_handoff_20260826 + docs/handoffs/2026-08-26_GPT_WORK_HANDOFF.md + current_operating_state + current_vertical_slice_implementation_gate_20260820 재조회
6. 플랫폼/device 재인가 작업일 때만 current_entry_gate_20260808을 역사 비교 근거로 추가 확인
7. live context 의미 상태와 fresh truth 차이 교정
8. 다음 Visual 요청이면 실제 게임 소비처와 사용자 결정을 먼저 확인한다. `DOGYEOM_STATUS_PORTRAIT_01`은 구현·자동 검증 완료 상태로 재생성하지 않는다.
9. 실제 Godot 제품 구현 요청이면 r5.4 `CODEX_GODOT_PRODUCT_IMPLEMENTATION_HANDOFF`로 전환하고 Codex가 Project GitHub + repository owner를 독립 fresh-read
10. PowerShell은 Godot local 실행·검증이 실제 필요할 때만 사용하며 local Codex launcher로 사용하지 않음
11. 실제 결과와 evidence ceiling을 분류하고 허용된 다음 Gate만 진행
```

자동화되지 않는 항목은 계속 `NOT_RUN`으로 남긴다.

- Windows visible local render.
- physical keyboard/mouse usability observation.
- physical gamepad.
- accessibility-user validation.
- release-device performance judgment.
- Android 실제 APK/AAB install/launch, touch/back/safe-area/lifecycle/performance.
- STEP 14 신규 플레이어 5명.

## Base 관찰

Base remote `main`의 exact SHA는 이 live router에 current 값으로 저장하지 않는다. 매 resume/post-merge마다 `ALWAYS_REFETCH_CURRENT_MAIN`으로 다시 읽고, 프로젝트의 Base 적용 권위는 current r5.4 project contract와 `docs/BASE_RULES_VERSION.md`·`skills/PROJECT_BASE_ADAPTER.json`의 compatibility pin을 구분한다. current Base 기능은 `BASE_MAIN_SYNC_AUDIT.md`의 `ADOPT / ADAPT / REJECT` 판정과 repository-owned work receipt를 거친 경우에만 project thin adapter로 적용한다.

과거 handoff에서 관측한 Base SHA는 위 `historical_base_main_at_handoff`에 증거 스냅샷으로 보존한다.

## 먼저 읽을 것

1. `AGENTS.md`.
2. `docs/PROJECT_TOTAL_PLANNING_IMPLEMENTATION_AND_DELIVERY_INSTRUCTION.md` / `TEN-DEC-20260826-INTEGRATED-WORK-CONTRACT-V4-8-R5-4-01`.
3. `docs/BASE_RULES_VERSION.md`와 `skills/PROJECT_BASE_ADAPTER.json`.
4. `[기획서]/00_프로젝트_허브/ACTIVE_CONTEXT.md`.
5. `docs/planning-data/current_user_planning_status.json`.
6. `docs/planning-data/current_visual_production_handoff_20260826.json`.
7. `docs/handoffs/2026-08-26_GPT_WORK_HANDOFF.md`.
8. `docs/planning-data/current_operating_state.json`.
9. `docs/planning-data/current_vertical_slice_implementation_gate_20260820.json`.
10. repository의 `PROJECT_AI_PRODUCTION_SPEC.md` Appendix C에 기록한 historical Notion migration inventory. 이것은 누락 점검용이며 새 채팅의 필수 입력이 아니다.
11. `docs/16_VERTICAL_SLICE_IMPLEMENTATION_HANDOFF_PLAN.md`, `docs/17_VERTICAL_SLICE_VISUAL_UX_REQUIREMENT_SPEC.md`, `docs/19_VISUAL_PRODUCTION_CURRENT_GATE_2026-08-26.md`.
12. 질문별 분야 책임 원본과 실제 코드·테스트·GitHub PR metadata.
13. `[기획서]/00_프로젝트_허브/HANDOFF.md`와 `docs/planning-data/current_entry_gate_20260808.json`은 필요한 역사/플랫폼 비교 범위에서만 읽는다.

Google Sheets는 신규 기획 입력 경로로 사용하지 않으며 migration 잔존 정보를 확인해야 할 때만 보조 증거로 읽는다.

## 현재 위험·미검증

- 2026-09-01 사용자 지시에 따라 player-visible 디자인·시각 변경은 `TEN-DEC-20260901-RUNTIME-VISUAL-CAPTURE-EVIDENCE-01`의 repository-controlled runtime PNG capture를 남긴다. 첫 normal/combat record `TEN-RVC-20260901-001`은 `docs/evidence/RUNTIME_VISUAL_CAPTURE_MANIFEST.json`과 `docs/operations/2026-09-01_RUNTIME_VISUAL_CAPTURE_POLICY_EXECUTION_REPORT.md`에 source commit, scene/state, SHA-256, diagnostics와 함께 등록됐다. 이는 `MACHINE_RUNTIME_CAPTURE`이며 Human usability, Android device, accessibility-user, release performance는 계속 별도 `NOT_RUN`이다.
- 첫 5전 PC-first Vertical Slice Phase I–VI는 승인 범위가 구현·병합됐다. 다만 Windows visible Human usability, Android 실기기, Human 재미·가독성·몰입, 최종 Visual/VFX/Audio는 계속 `NOT_RUN`이며 완료로 승격하지 않는다.
- 2026-08-25 승인 Reference Set(`TEN-IMG-001`, `TEN-VIS-CHAR-MASTER-001`, `TEN-VIS-A07-CANDIDATE`, `TEN-VIS-A01`)은 Visual continuation 기준으로 승인됐지만 runtime/shipping asset PASS가 아니다. `OPPONENT_CHARACTER_MASTER_01`은 도겸 정체성 reference로 보존한다. `DOGYEOM_STATUS_PORTRAIT_01`은 `USER_APPROVED_2026_08_26` 상태로 사용자 명시 승인 후 정확히 1장의 새 원화를 생성·승인했고 로컬 정본은 `docs/visual-assets/approved/DOGYEOM_STATUS_PORTRAIT_01_v1.png`이며, Asset Library record의 historical Notion PNG attachment/destination readback은 `PASS_20260826`이다. 이 PNG는 `res://assets/portraits/dogyeom_status_portrait_01_v1.png`로 저장되어 `CombatantStatusPanel`에 구현됐고 상태 초상 routing의 기존 증거는 `AUTOMATED_GODOT_PASS_20260826`이다. `DOGYEOM_COMBAT_BATTLER_01`의 `slot1_dogyeom` 상태 초상·전신 Battler routing 및 runtime art integration은 `AUTOMATED_GODOT_PASS_20260827_STATUS_PORTRAIT_AND_COMBAT_BATTLER`이다. Windows human usability와 Android 실기기 evidence는 계속 `NOT_RUN`이다.
- `TEN-VIS-A02`는 도겸 상태 초상을 다음으로 두고 나머지 상대 14인의 초상이 미제작이다. `TEN-VIS-A03`은 도겸 Battler source와 `slot1_dogyeom` runtime routing까지 완료됐지만, 나머지 14인 Battler는 미제작·미라우팅이다. `TEN-VIS-A04` Route 8아이콘, `TEN-VIS-A05` Result/Completion 표식, `TEN-VIS-A06` 추가 전투 배경도 실제 consumer 확인 뒤에만 제작한다.
- 후보 영구 스테이터스 총량 `20/22/24/26/28`, 성급 `3/7/7/7/9`, Route 회복 `최대 체력25% + 기력1 + 내력1`은 `REVERSIBLE_*_SEED`이며 실제 밸런스 PASS가 아니다.
- 대량 밸런스 시뮬레이션은 아직 실행하지 않았다. Issue #267 implementation은 candidate `runtime_archetype_id`·`basic_action_focus_ids`·`final_stat_total_seed`를 per-combat runtime binding으로 소비하고 execution-only public history/AI trace까지 automated/Godot으로 검증했다. profile weight와 20/22/24/26/28 total의 실제 난이도·승률은 별도 deterministic instrumentation contract 전까지 `NOT_RUN`이다.
- 반복 또래 무인과 후보 15명의 정확한 이름·성별·외형·세부 소속·말투는 `REVERSIBLE_CONTENT_DETAIL`이다.
- aggregate 비전투 예산은 기획상 교정됐지만 실제 15~22분/가독성/몰입 Human 증거는 `NOT_RUN`이다.
- Android export preset 및 제품 Adapter 구현은 별도의 fresh platform Entry Gate가 허용하고 실제 검증하기 전 완료로 승격하지 않는다.
- Android 실제 기기·터치·back·safe area·lifecycle·저장·성능 증거는 `NOT_RUN / BLOCKED_UNVERIFIED`다.
- Windows visible local render·실물 입력·접근성 사용자·Release 성능은 자동 제품 검증과 별개다.
- STEP 14 사람 검증은 `NOT_RUN`이며 사용자가 2026-08-29 현재 단계에서 명시적으로 보류했다. 이는 Human PASS, fun/readability PASS 또는 release gate 통과를 뜻하지 않는다.
- CI 공급망 mutable/stale action-pin 후속은 Issue #140에서 `RESOLVED / CLOSED_COMPLETED`; 현재 미해결 위험이 아니다.
- `OBSERVATION_ANSWER_LEAK_RISK`는 직접 공개를 바꾸지 않은 채 사람 측정을 기다린다.
- Issue #258 구현은 PR #261로 병합됐다. Issue #267 구현은 PR #273으로 `main`에 병합됐고 local automated/Godot 및 remote CI readback을 마쳤다. PR #273의 one-time protected-change manifest는 PR #274에서 archive·merged-main baseline promotion·post-merge lifecycle readback까지 완료됐다. 그 외 제품 mutation은 새 명시 요청과 fresh Gate가 필요하다.
- 공개 거리2, 10개 기초 행동, 행동계획 실행 CTA, 공개 상태 AI·관찰 가드, 첫 패배 동일 시드 1회 재시도 경계는 기존 자동 회귀로 보호된다. Issue #267은 그 위에 candidate personality/stat binding을 추가했을 뿐 Windows visible, Human, 접근성 사용자, Android 실기기, Release 성능 evidence를 대체하지 않는다.

## 상태 표현 규칙

- 완료 증거가 없으면 `PASS`로 쓰지 않는다.
- live current state는 exact SHA나 열린 PR 번호를 내장하지 않고 GitHub + repository owner를 다시 읽어 판정한다.
- exact SHA/run ID/PR 번호는 `관측 증거 스냅샷`, Decision, evidence 문서처럼 역사·관측 역할이 명확한 곳에만 둔다.
- 과거 PR/branch/Handoff가 GitHub current truth와 충돌하면 current GitHub + 현재 책임 원본을 우선하고 live router만 교정한다.
- HANDOFF는 명시적 session snapshot이므로 자동 current화하지 않는다.
- PR #82와 그 SHA는 역사 자료이지 현재 active planning PR이 아니다.
- 사용자 최신 지시로 중단된 작업은 실패로 승격하지 않고 `DEFERRED_BY_USER`와 실제 검증 ceiling을 함께 기록한다.

## 역사 LOCAL_EXECUTOR_HANDOFF_CHECKPOINT — 2026-08-12 · CURRENT EXECUTION SUPERSEDED

`TEN-DEC-20260811-LOCAL-EXECUTOR-BOOTSTRAP-01`의 로컬 실행환경 작업은 당시 사용자의 인수인계 우선 지시로 checkpoint에서 멈췄다. 실행 산출물은 `tools/start_ten_paces_local_executor.ps1`이며, 아래 값은 당시 환경/학습/회귀를 보존하는 역사 evidence다. r5.4 current execution route가 아니다.

```yaml
local_executor_launcher: tools/start_ten_paces_local_executor.ps1
launcher_generation: v5
launcher_sha256_observed: db7717ad7fda58a43aaf42c930d6c27a2b70d8862db894208c3ae2a861f9db7c
windows_powershell_parser_install: PASS
dedicated_godot_4_7_1: RUNTIME_OBSERVED
higodot_godot_ai_3_1_4_http_8003_ws_9503: RUNTIME_OBSERVED
hera_exact_project_auth: RUNTIME_OBSERVED_SHARED_TOKEN_NO_SECRET_SAVED
codex_project_specific_home_login: COMPLETED_TO_INTERACTIVE_SESSION
codex_exact_project_sandbox_ready: RUNTIME_OBSERVED
IN_CODEX_FRESH_READINESS: NOT_RUN
FRESH_POWERSHELL_REPEAT_RUN: NOT_RUN
product_mutation_after_checkpoint: NOT_AUTHORIZED_BY_READINESS_EVIDENCE
```

historical PID/port/session, `IN_CODEX_FRESH_READINESS_GATE`, `FRESH_POWERSHELL_REPEAT_RUN_GATE`, project-specific `CODEX_HOME`, dedicated 8003/9503 port route는 current readiness 선행조건이 아니다. 현재는 r5.4에 따라 local Godot 실행·검증이 실제 필요할 때만 PowerShell을 사용하고, 실제 Godot 제품 구현은 `CODEX_GODOT_PRODUCT_IMPLEMENTATION_HANDOFF` 뒤 Codex가 Project GitHub + repository owner를 독립 fresh-read해 자신의 구현환경에서 수행한다. 과거 launcher/process/listening-port 존재를 current readiness PASS로 승격하지 않는다.
