# 새 캐릭터·실제 자세 프레임 연결 — 작업 중

## 2026-09-10 현재 계획 삽화·카드 높이·무협 효과음 후속

최종 로컬 readback: 전체 Python 503 PASS / 407.42초. 실행 중 마지막 하단 여백
교정이 들어갔으므로 frozen exact-HEAD 병합 증거로 사용하지 않는다. 그 교정 이후
`verify_linked_action_blocks`, `verify_action_card_summary`,
`verify_combat_action_selection_integration`, `verify_preparation_art_fill` PASS.
기존 CI 버전 Godot 4.7.1에서도 15 native wrapper PASS / 46.42초.
최신 준비 PNG는 마지막 여백 교정 이후 GPU 재촬영했다. `git diff --check` PASS.
독립 targeted 검토는 계획 제목/흐름 겹침 finding을 닫았다. 커밋·PR·CI·병합은 미완료.

- 사용자 최신 참조에 맞춰 현재 계획을 삽화, 기술명, 소요 수 배지, 실행 상태가 있는
  연결 카드로 변경했다. 화살표와 `3수 → 해결 → 3수 → 해결 → 4수 → 해결`을 표시한다.
  기존 기술 정의·대상 지정·자원 검사·해결 규칙을 그대로 소비한다.
- 상단 전투 60%와 하단 3열을 유지한다. 선택 카드의 삽화는 비율을 유지해 전체를
  보여 주고 두 줄 그리드가 남는 높이를 사용한다. 신규 삽화를 제작한 것은 아니다.
- 실제 씬 최소 높이가 계획 제목/흐름 위에 카드를 겹치게 하던 문제를 교정했다.
  720p에서 카드 최소 높이로 패널 하단을 넘던 추가 회귀도 RED 후 교정했다.
- `test_visual_continuation.py`: 15개 native 항목, 50.48초 PASS. 계획 검사는
  1280×720, 1280×800, 1920×1080 및 3수/4수 묶음에서 수행했다.
- 실제 GPU 준비 화면: `C:/Users/user/.codex/visualizations/tenpaces-wuxia-ui-20260910/`.
  실행 버튼→카드 공개→VFX: `tenpaces-wuxia-ui-execution-20260910/`, 37개 원본 프레임,
  32프레임 GIF. GIF는 무음이며 최종 720p 최소 높이 교정 전 1280×800 캡처다.
- 금속 충돌은 비정수 배음과 짧은 접촉음, 검풍은 대역 제한 바람의 상승/감쇠로
  분리한 자체 PCM 합성이다. 12개 큐 캐시, 헤드룸, 시작/끝 클릭 억제 검사를 통과했다.
  WAV 샘플은 준비 캡처 경로의 `audio/`에 있다. 실사 녹음·청감 승인으로 주장하지 않는다.
- 같은 작업 계보의 전체 적대 검토 2회는 수행했다. 이후 사용자 추가 UI 범위는
  영향 검토에서 발견된 제목/흐름 겹침을 교정했다. 최종 전체 회귀·CI·병합은 별도다.
- Windows GPU 캡처는 Android, 접근성 사용자, 실제 오디오 장치, Human UX나 Release PASS가 아니다.

## 2026-09-10 합 불꽃 최종 확정 후 연결

사용자 `확정해서 진행해 / 네 권장안대로 다 승인해`를 방금 제시한 합 불꽃의
최종 lock으로 기록했다. 후보 원본과 동일 SHA-256의
`assets/vfx/clash_sparks_ink_gold_v2.png`를 등록하고 실제 합 consumer에 연결했다.
흰 중심광은 native alpha로 보존하며, 베기·절초는 기존 matte를 복원한다.
정사각형 비율과 상단 카드/하단 결과를 피하는 기존 VFX lane을 유지한다.
기존 이미지 원본과 다른 효과는 삭제하지 않았다.

회귀 `verify_clash_alpha_vfx.gd`: 기존 처리에서
`CLASH_ALPHA_OR_ASPECT_NOT_PRESERVED` RED 확인 후 교정. 실제 실행 검증은 아래에 갱신한다.
Base remote는 이번 fresh-read에서 `b0638b12797f4bab09055309595bcd49fc072d6f`로
이동한 것을 확인했으며 프로젝트 채택 pin을 자동 교체하지 않았다.
전체 패키지 2회 검토는 이후 수행했다. exact HEAD CI·병합은 아직 미완료다.

## 직전 단계 검증 readback — 합 VFX 최종 확정 이전 이력

- 후속 전체 Python run: 503 PASS / 386.42초. 실행 중 마지막 pose prewarm 보강이
  들어갔으므로 이를 최종 frozen exact-HEAD 전체 증거로 주장하지 않는다.
- 기존 CI native 직접 검사에서 화면50%/초상숨김/왼쪽CTA의 낡은 fixture와 실제
  inline cause의 카드 침범, green 여백 포함 경계 측정을 분리했다. 60/40 계약,
  현재 원본 frame의 shader-key 가시 경계, 독립 source/hash/domain/move 검사를 유지하며
  이관했다. 화면분할 PASS; inline/keyboard/focus/bimu/atlas 실패 5항목 집중 교정 PASS.
- source-frame cold 비용 실측 15.5~93.7ms, warm 9~15µs. 프레임 23개를 전투 진입에
  한 번 준비하도록 변경: 미준비21개 RED → POSE_CACHE_READY_PASS.
  준비 비용을 없앤 것이 아니라 전투 진입으로 이동했다. 실제 Release/기기 성능은 NOT_RUN.
- 최신 keyed-bounds 준비 캡처 `tenpaces-keyed-bounds-20260910`, 실제 실행 캡처
  `tenpaces-current-execution-20260910` (Codex visualizations 아래). 생성 VFX 후보는
  최종 사용자 확정 전이며 실제 캡처는 기존 승인 VFX다. 최종2회/CI/병합 미완료.

- 독립 focused code review에서 도겸 HUD/전장 원본 불일치와 신규 9검사의 CI 실행
  누락을 발견했다. 도겸 실제 원본 기대값 RED 후 공용 battler_path/path-keyed cache로
  교정했고, 9검사+도겸 검사를 unittest wrapper와 기존 product CI에 연결했다.
  교정 후 집중 wrapper 10개 native subtest PASS (26.689초), 독립 재검토 finding 해소.
  이 focused 검토는 최종 2회 full-scope 검토에 산입하지 않는다.
- 기존 CI Godot pin은 4.7.1, 로컬 검증은 4.7.2다. 계약 변경 없이 CI pin을 조용히
  바꾸지 않았으며 현재 SHA의 CI 호환성 검증은 남아 있다.

- 명시 GODOT_BIN 4.7.2: `python -m pytest tests -q --tb=short` 502 PASS / 356.49초.
- 초상 HUD/도겸 현재 battler source, 준비 3해상도, battle-first native PASS.
- 실제 Execute command→default AI→resolver→카드/VFX GPU capture 38프레임 성공.
  `C:/Users/user/.codex/visualizations/tenpaces-hud-execution-20260910/`.
  해당 원본 타임스탬프로 GIF 패키징 1280×800 / 32프레임 / 25,224,200바이트.
- VFX 후보 alpha: 1254×1254, 투명 1,254,283 / 반투명 307,048 / 불투명 11,185 픽셀.
- 전체 회귀 PASS는 신규 후보 사용자 확정, 두 차례 전체 검토, CI/병합, 실기기,
  Human/Release PASS를 의미하지 않는다. 기존 아래 항목의 최초 실패 기록은 이력이다.

## 합 충돌 독립 VFX 후보 — 생성 당시 이력, 현재 확정·연결 완료

- `assets/vfx/candidates/clash_sparks_candidate_v2.png`
- SHA-256 `9f0f5a55eb09308a176c78b460d8c6fefac841b2bc911440f52603843a2a6e8f`.
- Built-in generation `exec-7380a131-26e2-4277-b70b-9e1ecdc8088f`, text-only brief:
  독립 투명 정사각 충돌 스프라이트, 밝은 상아색 접점·금빛/호박빛 날카로운 파편,
  절제된 먹 파편, 무협 애니메이션 톤, 문자/인물/검/배경/프레임 없음.
- Intended consumer: above-torso clash impact in `_show_feedback_vfx`.
  생성 당시 GENERATED_CANDIDATE였으며 현재는 상단 최종 lock 기록에 따라 등록·연결했다.
  기존 승인 VFX 원본은 보존했다.
- 흰색 matte 제거는 밝은 접점을 없앨 수 있으므로, 실제 alpha 보존 시 해당 shader를
  적용하지 않아야 한다. 후보 alpha 검사와 화면 검수는 최종 사용자 확정을 대신하지 않는다.

## 2026-09-10 현재 캐릭터 HUD 후속

- 기준 main 885c91ee 재조회 유지. BUILD / combat-ux-and-accessibility 및 regression continuation.
- 기존 서로 다른 인물 초상을 live HUD에서 분리하고 실제 승인 검 캐릭터의 첫 자세
  상반신을 AtlasTexture로 재사용한다. 원본 픽셀은 수정하지 않으며 역할별 캐시와
  기존 chroma material을 공유한다. 신규 인물/무기별 초상 확정은 별도 자산 범위다.
- 초상 누락 RED를 실제 보드에서 재현 후 초상 표시·자원 비중첩·적 수치 비공개 GREEN.
  준비 3해상도 열 배치와 battle-first 회귀도 PASS. GPU 화면에서 양쪽 실제 인물 확인.
- HUD 종이색/먹색 대비와 카드 삽화의 과도한 암색 tint를 교정했다.
- 현재 캡처: `C:/Users/user/.codex/visualizations/tenpaces-portrait-hud-20260910/`.
  색상 후속 변경의 재캡처와 전체 회귀, 최종 2회 full-scope 검토/CI/병합은 진행 중이다.

## 2026-09-10 준비 60/40 열 배치 후속

- 최신 main 재조회: 885c91ee, open PR 199/200은 별도 문서/Base 범위로 유지.
- Work Mode BUILD; combat-ux-and-accessibility ui-contract/runtime-review 및
  ten-paces-verification regression. 같은 승인 continuation이며 review 회차 재시작 없음.
- 하단을 가용 폭 52/23/25 비율의 계획·선택/상세/관찰 열로 배치하고 실행 버튼을
  관찰 아래로 이동했다. 상세와 관찰은 하단 시작점에서 정렬한다.
- 공통 카드 삽화 영역 확대, 이름의 수 점유와 본문 비용·거리/효과 두 줄로 중복을
  제거했다. 1280×720, 1280×800, 1920×1080에서 기초 5×2 경계 및 열 비중첩 검사 통과.
- 상세는 정의의 기존 삽화를 재사용한다. 넓은 패널에서 밝은 글자를 사용하던 대비
  오류를 고쳤다. 관찰은 현재 공개된 유형만 사용하며 미공개는 물음표; 미래 수에
  유형을 임의로 배정하거나 비공개 계획을 조회하지 않는다.
- 실제 GPU 준비 화면 기본/무공 캡처:
  `C:/Users/user/.codex/visualizations/tenpaces-preparation-art-lanes-20260910/`.
  준비 뒤 실제 Execute→resolver→카드 공개/VFX 재검증 38프레임 성공:
  `C:/Users/user/.codex/visualizations/tenpaces-preparation-to-execution-20260910/`.
- 관련 Python 22개 및 기존 카드 요약·상세, 신규 열 배치·상세·통합 무공,
  battle-first, presentation-controls Godot 검사가 통과했다.
- 전체 Python 최초 실행은 501 PASS/1 FAIL. 실패는 이전 발 기준 VFX safe-lane 기대값;
  상체 접촉·하단 결과라는 승인 계약에 맞춰 기대값을 이관한 뒤 승인 4.7.2에서
  해당 Python/native 테스트 집중 재실행 PASS (11.16초). 수정 후 전체 일괄 재실행은 미수행.
  최초 전체 실행의 일부 native wrapper가 4.7.1을 선택한 점을 확인했으며 후속 실행은
  GODOT_BIN을 승인 4.7.2로 명시한다. 최초 결과를 4.7.2 전체 PASS로 부르지 않는다.
- 아직 미완료: 새 카드 삽화 전체/초상 HUD/참고 이미지 수준의 표면 아트, 강한 합 VFX,
  최종 전체 리뷰 2회, exact-head CI/PR/병합, Human/실기기. 종이색 UI 구조 교정은
  새로운 최종 이미지 자산의 제작·승인을 대체하지 않는다.

2026-09-10 후속 승인: 새 플레이어·적 캐릭터와 모션은 재생성하지 않고 보존한다.
이전 작업 정합성 복구와 연속 구현은 사용자 명시 승인됨. 기본 validator의
`Protected-path changes detected`는 변경 존재를 검출한 것이며 기능 실패가 아니다.
GitHub external approval은 아직 관측되지 않았고 이를 true로 가장하지 않는다.
실제 PR 전달 시 exact 변경 목록과 승인 메타데이터를 대조한다.

## 2026-09-10 사용자 범위 확대

기존 이미지 전체는 참조 자료이며 전투 UI, 배경, 도겸을 포함한 모든 캐릭터,
삽화·모션·VFX·아이콘 등 실제 시각 consumer를 새 방향에 맞게 개선한다.
전투 장면이 메인이며 첨부 전투 준비 화면의 정보 위계를 따른다.
이전 본문의 도겸·배경·UI 보존은 **이전 부분 교체 단계에서 실제로 보존했다는 이력**이지
앞으로 교체할 수 없다는 제약이 아니다. 범위 확대 뒤에도 실제 연결·검증 전 구형
원본을 일괄 삭제하거나 전체 아트 완료를 선언하지 않는다.
다음 구현은 전투 우선 화면 구성과 실제 크기/접지 검증을 먼저 확정하고,
그 consumer 규격에 맞춰 자산을 제작·연결한다. 기획·전투·저장 의미는 보존한다.

## 범위와 현재 상태

### 2026-09-10 충격 연출 연속 작업

- 사용자 추가 승인: 카메라 흔들림과 타격감 보강. 기존 source/main은 fresh fetch 뒤
  885c91ee로 동일했고 열린 PR199/200은 이 제품 변경과 직접 중복되지 않아 흡수하지 않았다.
- 전장 render-only 감쇠 흔들림, 캐릭터 로컬 타격 정지, 접근 가능한 모션 감소 버튼을 연결했다.
  캐릭터 원본 PNG는 변경하지 않았고 전투 결과/AI/save/전역 time_scale은 변경하지 않았다.
- `verify_combat_impact_camera.gd`에서 missing camera, missing hold,
  숨겨진 모션 감소 옵션, 합에서 양측 몸의 동일 좌표 겹침을 각각 RED로 확인했다.
  최소 교정 후 exit0 `COMBAT_IMPACT_CAMERA_PASS`를 확인했다.
- `verify_character_pose_animation.gd` PASS와 `verify_combat_presentation_controls.gd` PASS.
  이 두 실행은 마지막 합 간격 교정 전 증거이므로 이후 전체 회귀를 대체하지 않는다.
- 실제 1280×800 renderer에서 54장을 캡처했다. PNG 즉시 저장이 짧은 impact 표본을
  놓친 첫 시도를 보존하고, 메모리 표본 수집→후행 PNG 인코딩으로 교정했다.
  buffered 시도는 23개 nonzero shake 표본을 확보했다. 전체 사용자 입력/resolve가 아닌
  실제 Board의 seeded presentation event 경로이므로 실제 피해 감소/완주 증거가 아니다.
- 프레임 직접 검토로 합의 몸 겹침을 발견해 발 간격을 보존하도록 교정하고,
  impact를 실제 접근 완료(0.38 duration)에 맞췄다. 기존 작은 화면/단일 PNG 경계 검사,
  VFX 접점·최종 아트·2회 전체 검토·CI/병합은 아직 남아 있으며 전체 PASS가 아니다.
- 기록/수정은 연속 작업의 부분 검증이다. 새 전체 검토 회차를 세션마다 시작하지 않는다.

### 2026-09-10 전투 우선 배치 — 현재 로컬 검증

- 전투 배경을 화면 상단부터 약 60%까지 확장하고 상태 HUD를 그 위에 배치했다.
  새 플레이어·적 원본과 자세 프레임은 교체하지 않았으며 표시 크기와 바닥 위치를 조정했다.
- 실제 1280×800 실행 캡처에서 계획 슬롯 잘림을 발견했다. 작은 패널에서도
  제목 위에 28px을 예약하던 구조가 원인이므로 작은 패널만 제목·슬롯 가로 배치로 바꿨다.
- `verify_battle_first_layout.gd`: 슬롯 영역 회귀 RED(exit 1)를 확인한 뒤
  GREEN(exit 0, 1280×720 / 1280×800 / 1920×1080)을 확인했다.
- 실제 실행 캡처: `C:/Users/user/.codex/visualizations/tenpaces-battle-first-corrected-20260910.png`.
  해당 이미지를 직접 열어 새 캐릭터 표시 및 계획 슬롯 잘림 해소를 확인했다.
- `verify_frontal_duel_screen_partition.gd`: FAIL, 16 assertions. 기존 50% 분할,
  46% 캐릭터 높이, HUD와 전장의 분리 기준은 최신 사용자 방향과 충돌한다.
  이와 별개로 시트 전환 후 독립 경계 계산 및 버튼 정렬 항목도 확인이 필요하다.
  실패를 무시하거나 전체 회귀 PASS로 승격하지 않았다.
- 도겸·배경·장식 프레임의 신규 제작/교체, 최신 화면의 전체 모션 GIF,
  전체 회귀·2회 전체 검토·보호된 PR 병합은 아직 완료되지 않았다.

- 기준 main: `885c91ee934a6f096c79c7d0cfb5f31db4de7f5c`.
- 작업 분기: `codex/character-motion-integration-20260909`.
- Work Mode: BUILD / REVIEW. 프로젝트 workflow-router, combat implementation,
  ten-paces-verification(regression/runtime-validation), imagegen,
  designing-art-prompts-and-technique-cards(final-visual-candidate/visual QA).
- 사용자 최신 요청: 새 캐릭터와 이미 만든 공격 프레임을 실제 Godot에 연결하고
  양쪽 공격·피격·회피·방어·합을 확인해 GIF를 남기며 구형 런타임 이미지를 삭제.
- 원래 checkout의 사용자 미커밋 8개 제품 파일은 변경하지 않았다.
- 현재는 격리 작업본이다. main 병합, 전체 Blueprint 구현 완료, 최종 Human 승인을 뜻하지 않는다.

## 실제 수정

`character_pose_library.gd`가 원본 시트의 AtlasTexture 영역을 제공한다.
캐릭터는 공격 진행에 따라 실제 원본 프레임을 바꾸며, 반응은 별도 반응 시트의
block/hit/evade/clash 핵심 자세를 소비한 뒤 대기로 돌아간다. 기존 이동·회복 Tween은
추가 연출로 유지한다. 새 반응은 아직 다중 중간 프레임 애니메이션이 아니다.
도겸 고유 이미지와 역할별 방향은 보존한다. 제목 화면도 새 공격 시트의 대기를 사용한다.

RGB 녹색 원본을 수정하지 않고 CanvasItem shader가 런타임 알파를 계산한다.
원본 PNG 자체가 투명하다고 주장하지 않는다. 반응 시트 가로세로 비율을 보존하며,
프레임의 녹색 외 픽셀 하단을 읽어 발 앵커를 저장한다. 판정·피해·저장·AI 변경은 없다.

## 아트 제작·교정

기존 player 3×3 / enemy 4×3 공격 시트를 재사용했다. 파일 해시·생성 output ID와
실제 소비처는 `assets/ASSET_MANIFEST.json`이 소유한다.

반응 제작 최종 프롬프트 계약: 기존 얼굴·검·머리·의상·성숙한 애니메이션 수묵 표현을 유지;
2×2 동일 크기 칸, 방어/피격/낮은 회피/상체 앞 합 순서; 플레이어 오른쪽·적 왼쪽;
녹색 단색 배경; 문자·불꽃·검기 없음; 전신과 검을 칸 안에 보존.
첫 시안의 플레이어 회피 시선과 칸 경계 여백을 검수해 두 번째 편집에서 교정했다.
교정 프롬프트는 각 인물을 15% 축소해 칸 안쪽에 두고 발을 칸 높이 90% 부근에
정렬하며, 플레이어 회피의 머리·눈만 오른쪽을 보게 했다.
내장 이미지 생성 도구를 사용했으며 유료 CLI/API로 전환하지 않았다.

교정 전 v1은 생성 기록에 남기고 제품 소비처는 v2만 사용한다.
반응 후보 최종 Human lock과 출시 권리 검토는 미완료다.

## 조사 적용

- 현재 `2026-09-09_COMBAT_FEEDBACK_BENCHMARK.md`의 동일 전투 피드백 차원은 재사용한다.
  새 전투 규칙이나 무기군 설계의 10게임 조사 완료로 확대 해석하지 않는다.
- Godot 공식 [AtlasTexture](https://docs.godotengine.org/en/stable/classes/class_atlastexture.html):
  영역 분리와 filter_clip 적용(ADOPT), 엔진 원본 프레임 소비에 적합.
- 공식 [CanvasItem shader](https://docs.godotengine.org/en/stable/tutorials/shaders/shader_reference/canvas_item_shader.html):
  출력 alpha를 통한 기존 RGB 시트 합성(ADAPT), 실제 PNG alpha와 구분.
- 조사일 2026-09-09. 외부 캐릭터 픽셀이나 프랜차이즈 디자인은 새 자산에 복사하지 않았다.

## 검증 증거와 한계

- 새 회귀: 기존 단일 texture에서 `POSE_ANIMATION_MISSING` RED → 공격 프레임/회복 GREEN.
- 반응 확장: `REACTION_POSE_MISSING` RED → 양쪽 4반응/회복 GREEN.
- 화면 비율: `REACTION_ASPECT_DISTORTED` RED → 원본 비율 유지 GREEN.
- `verify_combat_character_art.gd`, `verify_frontal_duel_assets.gd`,
  `verify_dogyeom_combat_battler.gd`, `check_combat_board_contract.py` 각각 PASS.
- Godot 4.7.2 Windows 실제 Board 1280×800, runtime PID 24356에서 5동작 각각 10캡처.
  로컬 증거: `C:/Users/user/.codex/visualizations/tenpaces-new-motion-v2-20260909/`.
  GIF는 실제 화면 표본을 묶었으며 확인용 동작 길이를 3초로 늘렸다. 원속도/60fps 영상이 아니다.
- 직접 모션 호출 검증이다. 정상 전투 입력→판정→승패 전체 연결 검증을 대신하지 않는다.
- 계획 화면에서 캐릭터가 작고 접지·가독성이 약한 문제는 남았다.
- headless editor import 종료에서 ObjectDB 45개/resource 22개 잔류 메시지가 있었다.
  별도 focused 게임 검사는 종료 코드 0. 이를 전체 무오류로 합치지 않는다.
- 전체 회귀·2회 전체 검토·exact-head CI·main 병합·Android·접근성·Release 성능은 아직 미완료.

## 구형 이미지 정리

구형 player_wanderer/enemy_masked의 chroma_v1, rgba_v1, rgba_v2 런타임 PNG 6개와
각 .import 6개를 사용자 명시 지시에 따라 작업본에서 제거했다. 제거 전에 HEAD의
각 복구 object와 작업본 절대 경로를 확인했다. manifest는 퇴역과 복구 기준을 기록한다.
도겸·배경·UI·승인 이력 원본·PDF는 삭제하지 않았다.

## 다음 실행

반응 시트 최종 화면 크기/접지 → 정상 해결 경로·역할 반전/중단 → 2회 전체 검토,
회귀와 보호 전달. 새 원화 생성만으로 완료 처리하지 않는다. VFX 접점과 합 승패 후속은
기존 연출 Decision을 따라 별도 실제 이벤트·카메라 검증이 필요하다.
# 2026-09-10 actual execute capture and follow-up UI (local, unmerged)

Baseline: 885c91ee934a6f096c79c7d0cfb5f31db4de7f5c. Work Mode BUILD;
Skill combat-ux-and-accessibility, ui-contract/runtime-review. Same approved
continuation; full-review loop count is not restarted.

- Actual button command → default AI/real resolver → per-timing reveal capture
  now observes cards and VFX together. Previous isolated-motion GIF is not proof
  of that workflow. Capture script: `tests/capture_executed_combat_vfx.gd`.
- Found VFX anchored to feet; moved it toward raised weapon/upper-body contact
  and separated lower result label from the middle VFX lane. Existing atlas
  retained. Visually observed: spark remains too faint for the target reference;
  stronger authored impact asset remains pending, not marked final quality.
- Public event illustration data now feeds the execution cards. Future enemy
  actions are still excluded. Hidden round-panel duplicate removed during execution.
- Martial grid aggregates unlocked techniques from all owned manuals, deduplicates
  IDs, preserves temporary constraint locks, and supports overflow scrolling.
  Five columns implemented; exact two-row fit in the new preparation layout is pending.
- Detail removes duplicate source/category/payment rows and the extra detailed-effect
  section, retaining one complete effect text plus individual resource/slot facts.
- Distance projection previously saturated at distance 4. Distances 0–9 now have
  strictly increasing visual spacing; domain positions/rules unchanged. Existing
  timing-snapshot movement interpolation consumes these visual destinations.
- RED→GREEN observed for execution visual contract, flat martial grid, compact
  detail, and distance spacing. Impact camera and 720/800/1080 battle-first layout
  regressions passed. Whole-suite, two final whole-candidate reviews, CI, merge,
  Android, physical inputs and Human approval remain NOT_RUN for this candidate.

Latest user layout target: retain top 60% battle area; lower 40% left plan + 5×2
technique cards, middle large illustrated detail, right substantial observation
panel + execute. Existing approved battlers/motions remain unchanged. Whole layout
and new card-art family remain in progress; current code is not a completed match.

New artwork: `assets/ui/cards/candidates/quick_attack_ink_candidate_v2.png`,
SHA256 `ff53f1cf9d1d7f034fa960935966b155e788745de10a672cdaeb32a033cd3a24`.
Built-in image generation output `exec-acd852b7-8a4d-4626-9cb6-b261a32cbda9`.
Status GENERATED_CANDIDATE / not canon-registered / no production consumer yet.
Intended consumer: basic_quick_attack illustration shared by selection, detail and
execution. Brief: single rapid sword cut, mature anime-influenced ink wuxia,
charcoal/off-white robes and restrained crimson, pale parchment, landscape 3:2,
one character/one blade, no text/numbers/badges/frame. Generated from text, not a
third-party character. Final visual and release-rights review remain pending.

## 2026-09-12 최신 main 통합 후속

이전 source는 그대로 보존하고 최신 ed2104d9 기반의 격리 작업본에 통합했다. 현재 상태·충돌 교정·실행 증거·자산 확정 경계는 `docs/operations/2026-09-12_MOTION_UI_INTEGRATION.md`를 따른다. 위 과거 시점의 PASS/미완료/경로는 이력이다.
