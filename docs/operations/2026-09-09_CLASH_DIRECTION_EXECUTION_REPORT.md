# 합 연출 작업 기준 교정 · 실행 기록

- 기준 main: `6ea28301029875fb9e606bab3b8bb5b61801822b`.
- Work Mode: BUILD/REVIEW, 범위는 운영·연출 명세이며 제품 코드/데이터/이미지 bytes 수정 없음.
- Skill: project workflow router(운영 검증), Base art technique-card/변경관리, 독립 requesting-code-review.
- 승인·조사·3대안·적용/비적용·consumer·남은 자산 제작은 `docs/decisions/2026-09-09_CLASH_STAGING_AND_OUTCOME_DIRECTION.md`가 소유한다.
- 기존 아트 owner, 로드맵, Active Context에서 해당 결정을 발견하도록 연결. Base adoption pin 무변경.
- 신규 2개 문서 연결 회귀 RED → GREEN. 독립 검토에서 사거리 밖/장풍 합을 검 접촉으로 오해할 가능성을 발견했고 회귀를 RED로 확장한 뒤 적용 범위를 검 대 검으로 교정했다.
- 운영 검사 PASS. 이 증거는 문서 연결 검사이며 모션 품질·Godot runtime·Human·Android·출시 검증이 아니다.
- 상단 접촉 핵심 자세 및 승패 반동 자산 제작/승인/연결은 NOT_RUN. 이전 오프라인 GIF의 수동 교차점은 게임 판정 정본이 아니다.
- Base 공용 원칙은 별도 Base current-task branch에서 수정하며 merge/CI/readback은 각 PR의 실제 결과를 따른다. 해당 Base 변경이 모든 프로젝트에 자동 도입됐다고 주장하지 않는다.
- 원래 checkout의 사용자 수정 8개는 보존했다. 되돌리기는 본 문서 변경의 bounded revert로 가능하며 승인 원본 삭제·게임 저장 이관 없음.

## 후속 사용자 요구 · 2회 검토 교정 (별도 변경 계보)

- 입력 main: `3a1a3e46939ed6977d1d8b07815c1f3482f5e242`; 분기 `codex/weapon-staging-coverage-20260909`.
- Work Mode: BUILD(회차 정책)/PLAN(적 요구 기록)/REVIEW. Skill/Mode: project workflow router; Base art/reuse 조사; adversarial `attack/validate-critique/regression-recheck`; verification-before-completion; systematic-debugging(테스트 환경 확인). 이 기록은 검토 계보와 상태를 소유하며 제품 기획을 복제하지 않는다.
- 사용자가 내부 검토를 5회→2회로 명시 변경했다. 최신 Base의 정확히 2회와 자동 세 번째 금지를 확인하고 프로젝트 AGENTS·통합 계약·현재 planning locator를 교정했다. 과거 수행/승인 기록과 Base adoption pin은 보존했다.
- 검 대표 제작, 다양한 적 타입, 새 게임 시작 시 10전 전체 상대 고정 추첨, 단계별 스탯/보유 무공/수련도/별호의 승인 요구를 책임 Decision과 Active Context/로드맵에 연결했다. 새 제품 기능과 이미지 생성은 수행하지 않았다. 새 적 생성 설계축의 비교·상세 수치·반복 정책·저장 호환은 미완료로 기록했다.
- 대안: 정책 문구만 일괄 치환(REJECT: 역사 왜곡), 새 공용 검토 프레임워크(REJECT: Base 기존 2회와 중복), 현재 owner/consumer만 교정 + 역사 보존(ADOPT).
- 열린 PR: #199 front-door Human/Device 안내는 AGENTS의 다른 섹션 변경이며 현재 검토 횟수/적 요구와 의미상 별개다. 실제 해당 diff를 확인하고 보존했다. #200은 별도 과거 Base adoption/파생본 변경이므로 흡수하지 않았다. 관련 신규 PR만 이 변경을 전달한다.
- 전체 검토 1: 최신 사용자 의도·현재 source·open diff·실제 적/저장/이미지 consumer·정본·비용·rollback을 대조했다. `OMISSION`: 통합 계약의 `slice_benchmark_and_adversarial_policy`에 FIVE_PLUS 잔존 → 현재 2회로 교정. `CONFLICT`: 현재 고정 상대/엄격 저장을 새 무작위 구현으로 오인할 위험 → NOT_IMPLEMENTED와 실제 소비자 목록 유지. 별호/인물과 개별 만남의 상태 구분을 요구 기록에 포함했다.
- 전체 검토 2: 교정된 AGENTS/계약/두 신규 Decision/기존 연출 결정/Active/현재 JSON/로드맵/테스트와 untouched 제품 경로를 재대조했다. 과거 5회 기록·정탐 비공개 경계·도겸의 맨손 계열·근접 비수 미지정·자산 final lock이 보존됐다. 검 대표 작업보다 새 적 타입 정의를 먼저 하도록 기존 연출 Decision에도 최신 우선순위 링크를 추가했다. 별도 세 번째 전체 검토 없이 이후 finding 영향 범위만 확인한다.
- 실제 검사: 회차 기대값 변경 뒤 기존 계약 회귀 `1 failed, 3 passed` RED → 교정 뒤 `7 passed`; 관련 통합/adapter 포함 `20 passed`; operating system/freshness/diff whitespace 검사 PASS. 문서 검사 결과이지 새 추첨·별호·모션 runtime PASS가 아니다.
- 전체 suite 첫 실행은 전역 스크립트 캐시가 없는 격리 worktree에서 Godot 타입 해석 실패. 중단 후 Godot 4.7.1 headless editor import, 해당 전투 피드백 `4 passed (21.60s)` 재검증. import 종료에서 ObjectDB 45개/리소스 22개 경고가 관측됐으며 무누수 PASS를 주장하지 않는다. 이후 전체 suite는 **502 passed / 328.51s**. 이는 기존 제품 회귀 포함 자동 검사이며 새 적 기능 구현 증거가 아니다.
- 현재 evidence ceiling: 정책/요구 문서 교정과 관련 검사 통과. 새 적 시스템·이미지·모션·GIF·Human/device/release는 미완료. 상세 기획/제품 작업 전체 완료나 CI/main 병합 완료를 이 로컬 기록만으로 선언하지 않는다.
- 재사용 교훈: 새 worktree는 엔진 import가 먼저이며, 생성 sidecar를 제품 diff에 섞지 않는다. 이미 알려진 로컬 실행 교훈을 재사용했으므로 새 Base 정책/프레임워크를 추가하지 않는다.

## 승인 수묵 합·먹 VFX 제품 적용 · 2026-09-25

- 기준 SHA: `ca2ce2d7242913a775267343b54d87575b2c4375`, branch `codex/ink-combat-runtime-20260924`. Work Mode BUILD/REVIEW; Skill/Mode: project workflow router / verified routing; combat-implementation-handoff / scoped product implementation; combat-ux-and-accessibility / presentation readback; ten-paces-verification / native regression; Hera live-editor / exact project UI evidence; verification-before-completion. 원래 main checkout의45개 사용자 dirty와 코멘트 저장을 보호한다.
- 승인:2026-09-24 최신 “지금 느낌으로 전투쪽 이미지,연출등을 변경…먹 v.fx 연결”. 기존 준비/선택/배치/확정 보호와3/3/4전체 흐름을 재사용한다. 일회 보호 경로 manifest는 실제 변경 파일만 열거한다. 비용/AI/저장/계획 코어 변경 없음.
- CURRENT_SOURCE_RELEVANCE_CHECK/FEASIBLE: 최신 사용자 승인·원화/기하·도메인 사실·공식 CanvasItem textured polygon 자료를 대조했다. 상세 출처·경계는 기존 수묵 Decision. PR342 `d2e1edae7930c11e6c04cfbe269a06c4d3075f14`의 읽기 전용 `combat_motion_presets.gd`, `combat_motion_sequence.gd`, `data/presentation/combat_motion_presets.json` 및 사실/실패 검증만 재사용했다. 광범위한 성장/명단/저장 변경은 이번 수정에 합치지 않았다. #199/#200은 무관 범위로 보존한다.
- 실제 consumer: `CombatBoardPreview._present_ink_bundle` → `InkResolutionModel` → `InkCombatPresentation`/`InkCombatStage`. 승인 원화5개와 기존 crop/alpha 정리로18자세+3원본을 등록했다. 검끝을 따른 textured ink quads, 실제 검 대 검 합의 접점/근접 컷, 실제 회피/막기/실패, 이전 자세에서 다음 수로 연결을 사용한다. 다른 계열은 검 접촉을 꾸미지 않는다.
- 전체 검토1: 승인/정본·순수표시 PR342 diff·domain untouched·정보경계·장기자산/저장/비용을 대조했다. mirrored 합의 피해 중복·대응 비용 재지불·묶음 보상 혼합을 실제 state delta로 차단했다. 비검/identity 없는 합의 가짜 검 접촉을 압력 연출로 교정했고, 고정 capture의 JSON 실수 키 `1.0` 때문에 다른 상대 묶음이 선택되는 fixture 결함을 교정했다. 새 adapter 없는 RED를 먼저 확인했다.
- 전체 검토2: 교정된 제품/원화·data·UI·이벤트/실패·기존 사용자 조작·저장·export·승인 manifest·실행 근거와 문서를 다시 대조했다. Label 최소높이가 하단을 밀어내는 실제 화면 결함을 bounded text/tooltip으로 교정했다. 새 surface가 기존 소리/음량 조작을 가리는 것을 찾아 동일 adapter에 연결하고 키보드 포커스를 구성했다. 결정 접점보다 빠른 승패 공개를 늦췄고, 신규 자산 때문에 역사24개 보존 검사가 섞이는 것을 기존 해시 유지+신규21개 source/destination 해시 검증으로 교정했다. 이후는 이 finding의 집중 재검증이며 세 번째 전체 검토를 만들지 않는다.
- 실제 로컬: model44검사 및 기존 pure motion134검사, native3/3/4묶음·미래행동·준비 geometry복귀·모션감소·즉시skip·pause/restart 취소·기존소리/음량 PASS. 기존 checkpoint/terminal/actionselection/keyboard/1280×720·1280×800·1920×1080배치/판정·10절초/정보경계도 실행했다. 예전 partition 회귀가 구 renderer의 move/reveal 노드를 기대해2실패했고, 현재 실제 CTA consumer의 move/3수·resize·domain parity를 검사하도록 옮겨 PASS했다. 검증 요구를 삭제하지 않았다.
- Windows visible: exact Godot `4.7.1.stable.official.a13da4feb`, 새 worktree Hera editor29364 identity 확인, 실제 scene의 강공·명상·행동 실행 CTA로 새 overlay 진입과 준비 복귀 확인. `runtime-bundles.mp4`는 같은 실제 scene/판정기에 고정 계획을 넣은 무음 자동 촬영이며 일반 AI 플레이 영상이 아니다. 녹화의최종프레임·시간·해시는 runtime-capture/candidates.json을 따른다.
- 현재 한계: 기존2검객의 공통 무대 자세다. 모든 상대 인물/무기별 고유 중간 자세나 모든30기술 독자 안무, 사람의 멋·자연스러움·반복 피로, 실제 Android/접근성 사용자/출시 성능·권리는 완료가 아니다. 에디터 import/export 종료의 기존 ObjectDB45/resource22 경고는 별도로 관측했으며 무누수 PASS를 주장하지 않는다.
- 전달: 로컬 Windows 빌드/전체 회귀/원격 CI와 정상 병합은 아래 최종 readback에 갱신한다. 현재 원격 성공이나 main 반영을 추정하지 않는다.

집중 교정 기록: 전체 검사 도중 불필요한 생성 sidecar를 정리하면서 기존 배경의 미등록 import3개가 로딩 의존성임을 확인했다. 해당 최초 실행은 parse 실패/검사 중단으로 보존하고, 원본 해시가 같은 import/UID8개를 복원해 승인 범위에 명시·등록했다. 원화 bytes나 기존 소스는 바꾸지 않았다. 이후 native710프레임/29.58초 촬영과 신규6개 검사·canonical consumer 검사·승인 계약을 다시 PASS했다. 최초 전체 검사나 실패 촬영을 성공으로 취급하지 않는다. 현재 consumer로 바뀐 타이밍 snapshot 계약 검사는 새 consumer의 실제 state 복사를 확인하도록 갱신했다.

### 로컬 전달 검증 · PR361

- 제품 구현 기준 `3aab20f0665fc97a7b8704edd26836efca35c119`: 전체 pytest **600 passed / 595.73초**, Windows release export 성공, 해당 실행 파일의 제품 시나리오 **50/50·실패0**. 실행 파일과 PCK는 작업 폴더 `build/windows/`에 함께 둔다. 로컬 로그는 `output/ink-validation/full-pytest-final.log`, `export-final.log`, `exported-product/`에 보존한다.
- 최초 PR361 CI에서 BUILD 승인 링크 파일 누락과 교체 전 `CombatActionRevealOverlay`만 찾는 회귀를 확인했다. 기존 사용자 승인 근거를 `docs/implementation/BUILD_APPROVAL_2026-09-25.md`에 연결하고, 같은 실제 CTA의 새 화면에서 미래 수 비공개·현재 사실·판정 전 상태·준비 숨김·서로 겹치지 않는 영역·skip/domain parity를 확인하도록 옮겼다. 6 viewport 실행과 구 직접 feedback consumer 회귀 모두 `COMBAT_ACTION_REVEAL_VERIFY_OK`. 검사 요구 삭제나 승인 범위 확대는 없다.
- 인앱 브라우저에서 실제 녹화29.583초가 끝까지 재생되고 오류 없이 종료됨을 확인했다. 첫 탭은 브라우저 renderer가 종료되어 새 검수 탭으로 복구했다. 녹화 후 제품 포커스 버튼의 글자색을 명확히 하는 미세 교정이 있으며 영상의 동작·수치는 동일하다.
- PR: https://github.com/alsdmlals4-eng/Ten-Paces-Hidden-Moves/pull/361. exact-head 원격 검사 및 정상 병합 여부는 GitHub live metadata를 따르며 아래 최종 main readback에서 확정한다.

추가 원격 full-validation의 실제 게임 회귀도 대조했다. 기존 5초 reveal 제한은 승인된 긴 안무의 전체 묶음을 기다리지 못해 RED였고 24초의 유한 한도로 교정했다. 구 절초 atlas 전용 playback 검사는 새 먹 consumer의 실제 card/actor/execution timing·계열·승인 붓·양의 표시 기하·결과 영역 분리를 검증하도록 옮겼다. 기존 예약·취소·기세·잠금 검사는 유지했다. full-validation의 native31종 중30종이 먼저 통과했고 남은 절초 회귀는 집중 교정 후 `ULTIMATE_UI_RESERVATION_VERIFY_OK`; 게임 제품 bytes 추가 변경 없이 모두 검증됐다. 정상 속도 실제 CTA와 별도 전용 소비자 회귀를 함께 유지하며 미래 행동/일반 자원 판정 요구를 낮추지 않는다.

### 최종 main readback · PR361

검토 HEAD `2bdf345f5110baccaab335994ec6475391be8602`, 원격 35SUCCESS/0FAIL/0PENDING, 미해결 검토0을 확인하고 2026-09-24T15:56:35Z에 main `53b007e3ad1b1dd7eb3b1ef574a2391bb7abf8cb`로 정상 병합했다. 전체 tracked tree가 검수 후보와 동일하다. 일회 승인 종료와 보호 기준선/파생본 동기화는 같은 날짜 PR361 승인 종료 기록에 연결한다. 제품 코드/원화/영상은 이 closeout에서 바꾸지 않는다. 원래 checkout45dirty와 사용자 리뷰 SHA256 `afd73518d7bf507728e500045733ef5b9c7a466dc3feeba3c62331455cdd2dac`은 보호했다.

원격 native 입력 검사는 일반 연출 속도 `ordinary_defaults`에서 453094ms 동안 295번의 실제 버튼 입력으로 비무10승·보상10회·행로36회를 완료했다. 실패0이며 공개 정책으로 선택한12종 행동을 사용했다. 근거는 [PR361 제품 검사](https://github.com/alsdmlals4-eng/Ten-Paces-Hidden-Moves/actions/runs/36022075768/job/107709315719)의 `NATIVE_CAMPAIGN_SUMMARY`다. import 종료 때 자원22개 경고는 남아 있으며 실행 실패나 누수 없음으로 바꾸어 보고하지 않는다.


## 화면별 수묵 이미지·하단 확대 · 2026-09-25 추가 승인

- 기준 SHA `7f549217ea4b2496613b9b4cf3176bccfede2c58`; Work Mode BUILD/REVIEW; Skill/Mode: 프로젝트 router·imagegen·HTML blueprint·Hera live/UI·전투 UX·reference-freshness/verification, 같은 승인 continuation. 최신 제작·게임 연결·HTML·직접 폐기 지시를 BUILD 승인/기존 Decision에 연결했다.
- 생성9회: 배경6장·복면9자세·복면 접점1장·도겸 맨손9자세. 신규 runtime25파일+기존 stable ID 초상2파일 교체, 플레이어 승인 원화 재사용. 구13파일/import 실제 삭제, PDF 역사·해시 ledger만 유지. 변경 전후 사용자 코멘트 해시는 별도 확인한다.
- RED: 새 하단 검사가 폰트/결과 영역/배경13항목에서 실패했다. 최소 구현 뒤 네 화면 크기에서 GREEN. 1차 전체 pytest는584통과/16실패였으며 실패 대부분은 삭제된 초상 원본을 여전히 부르는 HTML/역사 기대값이다. 구 파일을 복구하지 않고 현재 manifest consumer와 해시 있는 명시 폐기 계약으로 교정했다.
- 전체 검토1: 정본/승인·제품 전체 diff·규칙/AI/저장 미변경·untouched 적14명·준비 조작·원본/파생/삭제·HTML·실행 증거·비용·재사용을 대조했다. 실제 여정이 무작위여서 미리보기 배외검객만 교체하면 도겸이 옛 그림으로 나오는 결함, 밝은 브리핑 위 저대비 글자, 자동 tooltip의 결과 가림, HTML의 옛 시작/준비 이미지 override를 확인해 교정했다. 촬영 실패의 빈 save_id/seed 재현은 fixture에서만 고쳤다. 새 게임 규칙·전역 도구 설치는 없다.
- Windows native 캡처: 실제 Godot4.7.1,1440×900. 메인/시작/브리핑/준비는 격리 정상 이동, 결과/행로/휴식은 명시 UI fixture다. 전투 녹화는 실제 resolver 고정3/3/4계획,706프레임/24fps/29.417초·서로 다른 전체 프레임491개·오류0. 일반 AI 대전 녹화나 승리 증명으로 과장하지 않는다.
- 현재 적/투명 alpha/배경/인물 비율/준비 구획/휴식/도감 소비자·브리지가 native8종 PASS. 사용자 시각 품질·반복 관람 체감·Android·출시 성능/권리는 NOT_RUN/기존 미확정이다. 전체 검토2와 전달 결과는 아래에 누적한다.

- 전체 검토2: 수정된 전체 후보의 정본/실제 diff/기존 preparation·resolver·AI·save·14명 미변경/생성 source/동작/HTML/비용과 유지보수를 대조했다. 옛 flow·briefing·preparation 예시가 일부 남는 연결, 4수 링크가 회피 구 영상으로 가는 연결, 이전 영상 해시/710프레임 metadata, byte-identical 구 이미지3중복을 추가 발견했다. 현재 native 예시/정확한3/3/4영상/706프레임 해시로 고치고 중복3개도 명시 ledger 뒤 삭제했다. 상태창/행로 와이어프레임과 역사 회피 설명은 현재 영상인 것처럼 바꾸지 않는다. 전체 검토는 정확히2회; 이후 확인은 이 결함들의 영향 검사다.
- 최종 로컬: pytest **602 passed / 583.45초**; 확대·상대 binding 포함 focused native8종 PASS; Windows export와 내보낸 실행 파일 제품 시나리오 **50/50·실패0**. export 종료의 기존 resource22 경고는 남아 있으며 무경고로 주장하지 않는다. 공개 게임의 첫 상대는 계속 무작위다.
- 인앱 브라우저: 새 화면 목록3열·종류/안정 번호/용도/inline 코멘트 확인, 로딩 완료 이미지 깨짐0. native MP41440×900/29.416667초가 실제로 끝까지 재생되어 ended=true/readyState4/error없음; 브라우저 오류로그0. 기존 자동 저장 코드는 미수정이고 사용자 코멘트 원본 SHA256 `afd73518d7bf507728e500045733ef5b9c7a466dc3feeba3c62331455cdd2dac` 동일함을 확인했다.
- 실제 사용자 시각 검수·키보드/마우스 체감·반복 관람의 멋·Android·실기기·출시 권리/성능은 별도다. 이번 정상 PR/원격 exact-head/merge 및 일회 승인 종료는 아래 전달 readback에 기록한다.

- 검토2 영향 교정: 상대 export 정본 재생성 검사에서 배외검객 portrait의 상위 ADDITIONAL_OPPONENTS owner가 구 삭제 파일을 가리키는 실제 drift를 발견했다. owner를 현재 등록 초상으로 연결하고 export --check 회귀를 추가했다. 기존 제품 data의 동일 경로를 재생성해 일치시켰으며 능력치·명칭·로스터·저장 ID는 바꾸지 않았다.

- PR363 CI의 영향 교정: 표시용 초상 경로까지 과거 저장 fingerprint에 포함된 탓에 schema2/5/6 고정 저장 회귀가 RED였다. 명시된 배외검객 신·구 경로 한 쌍만 identity 계산에서 호환 처리해 과거 bytes를 유지하며 live 경로·나머지 필드 검사는 보존했다. 기존 pending/applied 저장 decode와 게임 내용 변경 거부가 GREEN이다. HTML 링크 검사는 fragment를 파일명으로 취급하던 오류 및 구319 정지화면 기대값을 현재 실제 캡처로 교정했고 **1266 views / 21590 local links PASS**, 자동 저장/충돌·리뷰 동기화·검색3종도 PASS. native terminal 검사는 긴 묶음의 완료를 최대20초의 실제 시간 제한 내 기다리도록 교정했다. 실제 연출 속도·종료 규칙은 변경하지 않았다.

- 저장 호환 교정 후 `9d555ffbfde6fafda7707ba9f641492eb777419a`에서 Windows 빌드를 다시 만들어50/50 PASS했다. terminal/event checks/event run/legacy giyun run/variable save compat도 PASS했다. 전체 소스 해시가 교정 전 상태로 남지 않도록 native9화면과3/3/4 영상을 재촬영했다. **현재 전달 영상은686프레임/24fps/28.583초**, distinct491·runtime오류0이다. 위706프레임 기록은 교정 전 촬영 이력이며 현재 clip/manifest는 새 촬영으로 갱신했다.

### 최종 전달 readback · PR363

추가 저장/상위 owner 회귀12개는517.69초에 모두 PASS했다. 메인 촬영 도구는 실행마다 별도 임시 저장을 써 오래된 테스트 저장 안내가 예시에 섞이지 않게 했다. 새 여정 화면 재촬영7장 중 실제 변화는 메인1장이며 전투 영상/제품 bytes는 동일하다.

검토 HEAD `0af72791199b41bbefdcbdf2bd43de4920eb8f26`, 최신 workflow별 34SUCCESS/실패0/진행0, 미해결 검토0을 확인하고 2026-09-24T19:49:31Z에 main `df3b7538f16e66208e29f4f4c04c85567c34ff5c`로 정상 병합했다. 전체 tracked tree가 동일하다. 최종 HTML1266화면/21595내부링크 PASS와 브라우저28.583333초 ended=true/error없음을 확인했다. Windows 검수 ZIP의 실행 파일/PCK bytes와 CRC를 검증했다. 기존 사용자 코멘트 SHA256 `afd73518d7bf507728e500045733ef5b9c7a466dc3feeba3c62331455cdd2dac`은 동일하다. 일회 승인 종료는 `docs/operations/2026-09-25_PR363_PROTECTED_CHANGE_APPROVAL_RECORD.md`로 연결한다.

원격 ordinary_defaults native 캠페인은447829ms 동안295회 실제 입력으로 비무10승·보상10회·행로36회를 완료했고 실패0이다. [원격 제품 검사](https://github.com/alsdmlals4-eng/Ten-Paces-Hidden-Moves/actions/runs/36049087231/job/107800173797)의 NATIVE_CAMPAIGN_SUMMARY를 근거로 한다. 사람 플레이의 재미나 최종 시각 승인을 대신하지 않는다.

## 실제 실행·메뉴·준비 구도 후속 · 2026-09-25

- 기준 SHA `549dc3aaed9781c02d9c9915ea5f294689c3038c`; Work Mode BUILD/REVIEW, Skill Mode implementation/runtime-validation/reference-freshness. 프로젝트 router·combat UX/구현·검증, HTML blueprint, Godot live-editor의 기존 접수와 승인을 재사용한다.
- 범위: 저장 오류로 잠긴 전투 실행 복구, 삽화 6종 중 4권 시작 선택, 이어하기/도감/감상 설정/종료의 실제 동작, 대각선 준비 구도, 연속 합·반격·회피와 확대 컷의 연결. 3/3/4·행동 선택/취소/확정·공유 판정·숨은 상대 정보·AI·저장 schema는 유지한다. 새 라이브러리·설치·원화 생성 비용은 없다.
- CURRENT_SOURCE_RELEVANCE_CHECK / FEASIBLE: 기존 승인 수묵 원화·Project Moon 조사·실제 consumer를 REUSED_EVIDENCE로 사용했다. 공식 [Tween](https://docs.godotengine.org/en/stable/classes/class_tween.html)·[Control](https://docs.godotengine.org/en/stable/classes/class_control.html) 문서를 대조했으며 실제 채택 Godot4.7.1에서 입력·좌표·캡처·회귀를 확인했다. 외부 문서를 현재 작품의 재미/아트 승인으로 쓰지 않는다.
- 실제 사용자 저장의 읽기 전용 복사본에서 이동→회피→준비 해결 후 `[강건]`의 정상 문자열 `description`을 codec이 거부하는 RED를 재현했다. 선택 문자열만 허용하고 숫자/객체 description·알 수 없는 필드는 계속 거부하는 GREEN을 확인했다. 기존 schema6 bytes나 게임 규칙 변경 없음.
- 업데이트 Godot AI4.2.3을 정확한 `ink-screen-refresh-20260925` editor/session에 연결했다. 사용자가 수정한 addon은 보존하고 hash-guard로 승인 src만 복사해 검증했다. 원본 저장에는 쓰지 않았다. 실제 Continue→2번째 묶음 복구, 마우스 막기3개 배치→실행→3번째 묶음/SAVED/blocked=false, 공개된 3수 결과, 도감 삽화·탭·Esc, 설정·Esc, 종료 버튼으로 game stopped를 확인했다. 읽기용 eval에서 잘못된 속성 접근으로 발생한 도구 검수 오류2건은 제품 오류와 분리하고 재실행했다.
- 전체 검토1: 다섯 요청과 정본·전체 diff·미변경 resolver/AI/save/다른 화면·비용/유지보수를 대조했다. 기초 도감의 누락 삽화, 작은 창의 잘린 카드, Esc에서 제거된 viewport 접근을 발견해 실제 atlas/두 줄 높이/닫기 순서로 교정했다. 실제 native 화면과 RED→GREEN 및 기존 입력 회귀를 함께 확인했다.
- 전체 검토2: 교정된 전체 후보와 열린 PR342의 겹치는 표시 모듈, 브리핑/보상/행로/기존 저장·HTML 번호/코멘트·검증·장기 책임을 다시 대조했다. 종이 테마를 상속한 계획 글자가 검은 바탕에서 사라지는 문제와 확대 원화의 양옆 직사각형 경계를 발견했다. 계획 글자 색상을 고정하고 확대 화면을 영역 전체에 맞추며 회귀 RED→GREEN을 확인했다. 미생성 상대는 공통 수묵 자세를 사용하고 고유 외형 완성으로 주장하지 않는다. 전체 검토는 정확히2회이며 이후는 이 결함들의 영향 검사다.
- 교체 완료된 구 일반 적 원화의 runtime/approved/candidate 동일 PNG3개를 SHA256 확인 후 실제 삭제했다. 번호와 승인 이력은 기존 폐기 ledger에 남겼다. 승인47삽화와 기존21개 자산 기록의 hash, 상대별 고유 기존 초상은 별도 보호한다.
- 로컬 증거: unittest579 PASS, 저장 준비 회귀/새 UI/모션 연속성/기존 카드·배치·키보드·초점·전투 정보·저장 검증 PASS. 최종 native11화면과 실제 resolver 고정계획3/3/4 녹화723프레임/24fps/30.125초/서로 다른511프레임을 HTML source manifest에 연결했다. 도감·설정은 실제 title consumer이며 결과/행로/휴식 촬영은 명시 UI fixture다.
- 검증의 한계: 새 연출의 멋·자연스러움에 대한 사용자 최종 검수, 모든 적의 고유 수묵 자세, Android·실기기·출시 성능/권리는 별도다. editor import 종료에 기존 resource22 정리 경고가 남아 있으므로 무경고라 주장하지 않는다. 최종 pytest/Windows 빌드/HTML 브라우저/PR 체크와 main readback은 아래에 누적한다.

- 집중 영향 확인: 전체 pytest603개 중601통과/2실패를 먼저 기록했다. 하나는 촬영/발행 중 manifest의 resolution이 아직 결합되지 않은 시점, 하나는 화면 목록을9개로 고정한 옛 기대값이었다. 최종11화면 발행 후 도감/설정 menu분류·중복없는 경로까지 확인하도록 교정하고 해당2파일11검사가 모두 PASS했다. 전체603개를 마지막 상태에서 한 번에 재실행했다고 주장하지 않는다.
- HTML1268 view/21499 local link PASS. 인앱 브라우저에서30.125초 MP4가 readyState4, ended=true, media error없음으로 끝까지 재생됐다. 브라우저 error log0. 구조도 하단에 남던 옛 준비 참고안/합 삽화 표기도 현재 촬영 근거를 읽도록 교정했다.

- PR365 원격 영향 교정: full-validation의 기존 카드 상단 band/양 검객 동일 높이·같은 바닥선 검사가 승인된 좌측 삽화/대각선3:2구도와 충돌했다. 실제 source-alpha 독립 측정 및80% 축소 negative control은 유지하고 새3:2비율·깊이·모션 envelope90%상한·카드 내부 영역/글자 비중첩으로 검사했다. 해당 workflow native31종 전부 로컬 PASS; 제품 bytes는 추가 변경하지 않았다. Windows50/50·ZIP해시/CRC PASS, 최종 HTML1270view/21563local link PASS.

- 같은 원격 제품 job의 일반속도 캠페인은452225ms/실제 입력295회/비무10승/보상10회/행로36회/실패0으로 완료됐다. 근거는 [PR365 native 캠페인](https://github.com/alsdmlals4-eng/Ten-Paces-Hidden-Moves/actions/runs/36077007132/job/107890430945)의 NATIVE_CAMPAIGN_SUMMARY다. 이후 Linux에서 네 무공이 모두 들어가는데도 스크롤을 필수로 기대한 구 검사가 실패했다. 전부 보이는 상태를 검사하고 시험용 넓은 버튼으로 실제 overflow/마지막 항목 접근/키보드 자동 스크롤을 강제 검증하도록 고쳤다. 강제 overflow의 경계 좌표 오차0.00005px는 다른 기하 검사와 같은0.5px 허용으로 다뤘다. 세 viewport를 포함한 해당 검사와 휴식/atlas 후속 검사는 PASS이며 제품 bytes는 그대로다. 원격 job 전체 성공은 새 exact-head 결과에서 확인한다.

### 최종 전달 readback · PR365

검토 HEAD `92be01fb1385ab8373f06ad27117268acc538fd7`의 최신 workflow별 33SUCCESS/실패0/진행0, 미해결 검토0, 최신 main을 확인하고 2026-09-25T00:54:47Z에 main `9f0ce7ddf3a7aad95e82b725d99bbd5248bdd60d`로 정상 병합했다. 전체 tracked tree가 동일하다. 원본 사용자 저장8개와 사용자 코멘트 SHA256 `afd73518d7bf507728e500045733ef5b9c7a466dc3feeba3c62331455cdd2dac` 동일함을 확인했다. Windows 실행 파일/PCK/설명서 ZIP의 해시와 CRC 검증 PASS. 로컬 실제 실행·자동 CI·사용자 시각 승인·출시를 구분한다. 일회 승인 종료는 `docs/operations/2026-09-25_PR365_PROTECTED_CHANGE_APPROVAL_RECORD.md`.

최종 exact-head의 [일반 속도 native 입력 캠페인](https://github.com/alsdmlals4-eng/Ten-Paces-Hidden-Moves/actions/runs/36078610083/job/107895307586)은451114ms/입력295회/비무10승/보상10회/행로36회/실패0이며 이후 저장·카드·휴식 검사까지 전부 통과했다. 승인 종료 파생본은 adapter를 commit한 뒤 Git의 정규 bytes 기준으로 재생성해 Windows 줄바꿈 해시 차이를 예방했다.
