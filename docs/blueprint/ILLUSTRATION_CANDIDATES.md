# 무공 삽화 제작 기록

생성일: 2026-09-10. 경로: built-in image_gen. 정확한 모델 버전·계정 약관은 확인되지 않아
출시 권리 검증 완료를 주장하지 않는다. 외부 작품 이미지는 입력하지 않았다.
용도: 무공 도감의 3성·7성·절초 전용 삽화. 2026-09-10 사용자의
“확정해줘 진행해”에 따라 제시한 삽화 방향을 확정했다. 런타임은 미연결이다.
이 승인은 아직 생성하지 않은 결과의 품질 검수나 출시 권리 검증을 대신하지 않는다.

## 매화검결

| 대상 | 파일 | 검토 |
|---|---|---|
| 매화삼첩 | output/blueprint-candidates/plum-star3-framing-v2.png | 연속 검로 표현. 원본 보존 후 여백 교정본 생성·직접 확인. 도감 교체 연결 대기 |
| 낙매추영 | output/blueprint-candidates/plum-star7-candidate.png | 전진 동작과 대각 검로. 검토 완료, 사용자 방향 확정 |
| 이십사수매화검법 | output/blueprint-candidates/plum-star10-candidate.png | 확대된 검로와 절초 강조. 검토 완료, 사용자 방향 확정 |

공통 프롬프트: original Korean wuxia strategy-game technique illustration, charcoal-blue
and ivory martial robes, anime-influenced face, hand-painted dark ink wash, pale-blue sword
trails, muted red plum petals, warm ivory paper, no text/UI/logos/blood/franchise character.
3성: three successive sword cuts. 7성: forward lunge and single rising diagonal sword trail.
절초: many fine sword paths arranged as overlapping plum blossoms with restrained old-gold accents.
이는 프롬프트 요약이다. 원 생성 호출의 상세 프롬프트와 결과는 현재 작업 대화에 보존된다.

플레이어 고정 원화는 바꾸지 않는다. 최신 사용자 지시에 따라 적 이미지는 무공 삽화 이후
재제작하되 기존 원본·모션은 새 연결 검증까지 보존한다. 단순 삽화는 애니메이션 프레임이나 VFX atlas가 아니다.

## 나한금강공

실제 무공 데이터 `data/cards/martial_manuals/shaolin_arhat_vajra_art.json`의
방어·강건, 장법 타격, 방어와 장법의 절초 구분을 읽고 각각 단일 생성했다.
세 이미지 모두 `GENERATED_CANDIDATE`이며 사용자 방향 확정과 개별 이미지 확정은 구분한다.

| 대상 | 파일 | 직접 검토 |
|---|---|---|
| 금강호체 · 3성 | output/blueprint-candidates/arhat-star3-candidate.png | 교차한 팔과 몸에 붙은 호체. 공격 그림과 구분됨 |
| 대력금강장 · 7성 | output/blueprint-candidates/arhat-star7-candidate.png | 전진 장법과 손 앞 충격파. 손과 효과 접점 확인 |
| 여래신장 · 10성 | output/blueprint-candidates/arhat-star10-candidate.png | 확대된 장력으로 절초 구분. 상단 효과 일부는 화면 밖으로 확장되므로 도감에서 추가 crop 금지 |

프롬프트 공통: single square premium original Korean wuxia technique encyclopedia,
shaved-head East Asian monk, charcoal and ochre robes, anime-influenced face,
hand-painted ink wash on ivory paper, old-gold qi, no text/UI/logo/weapon/deity.
3성은 rooted defensive stance / qi shell, 7성은 forward palm / short shockwave,
10성은 monumental palm-shaped pressure / broad force로 요청했다.
외부 이미지 입력 없이 built-in 도구로 생성했으며 런타임을 수정하지 않았다.

매화삼첩 여백 교정본 SHA-256:
`a952582b93f2aec38e7bff89f2c2ae79b8e093c348a403bcd1e4e403d69385e5`.
생성 원본은 보존하고 도감용 파일을 프로젝트 작업 공간에 복사했다.

## 태극검결

`output/blueprint-candidates/taiji-star3-candidate.png`: 운수검식 후보.
실제 데이터의 회피→후퇴 표현을 위해 뒤로 물러나는 검객과 청록 구름 검로를 요청했다.
생성 결과에 인물 잔상이 포함되어 있다. 이는 회피 표현이며 분신 생성 규칙이 아니다.
`output/blueprint-candidates/taiji-star7-candidate.png`: 사량발천근 후보.
고정된 축발과 가슴 높이 검 접점·소량 불꽃·청록 회전 검로를 직접 확인했다.
`output/blueprint-candidates/taiji-star10-candidate.png`: 태극혜검 후보.
쌍곡선 먹빛·청록 기류와 되돌려 찌르는 검을 직접 확인했다. 검끝 여백이 좁으므로 추가 crop 금지.
7성은 sword redirection / planted pivot / controlled blade contact,
10성은 ultimate counter-sword / paired ink currents / precise return cut로 요청했다.
세 종 모두 생성 후보이며 실제 모션·전투 적용은 아니다.

## 양가창결

실제 데이터 `data/cards/martial_manuals/yang_family_spear.json`을 대조하여 제작했다.

| 기술 | 도감용 파일 | 직접 검토 |
|---|---|---|
| 추풍일섬 · 3성 | output/blueprint-candidates/spear-star3-candidate.png | 전진 찌르기, 두 손의 창대 파지, 긴 사거리 강조 |
| 연환쇄로 · 7성 | output/blueprint-candidates/spear-star7-structure-v2.png | 창대가 창날까지 연속되도록 교정. 술은 창날 아래로 이동, 두 번째 창날은 추상 궤적으로 교체 |
| 회마창 · 10성 | output/blueprint-candidates/spear-star10-hands-v2.png | 사용자 손/팔 지적에 따라 앞팔은 창끝 방향으로 뻗고 뒷팔은 허리 옆에서 굽히도록 교정. 두 어깨에서 손까지 연결을 직접 확인. 최종 확정 전 교정 후보 |

세 종은 단일 이미지 생성 도구로 제작했다. 공통 요청은 navy/ivory robes, burgundy sash,
continuous wooden spear shaft, red tassel, anime-influenced ink wash on ivory paper다.
3성은 advancing thrust, 7성은 two thrust trajectories and withdrawal,
10성은 turning-back thrust on foot로 구분했다. 7성 원본의 물리 창대/기운 궤적 혼동은
정밀 편집으로 교정했다. 원본 `spear-star7-candidate.png`는 비교용으로 보존하며 채택하지 않는다.
현재 생성 후보이며 최종 도감 배치와 런타임 연결 검증은 별도다. 긴 무기 끝의 추가 crop을 금지한다.

회마창 교정: 사용자는 추풍일섬이 아닌 회마창의 손 문제로 대상을 정정했다.
추풍일섬은 수정하지 않았다. 기존 회마창의 양팔이 포개진 자세를 양손 역할이 보이는
앞손 유도·뒷손 추진 자세로 편집하고 창 높이를 낮췄다. 얼굴·복장·하체·배경은 유지했다.
원본 회마창은 보존하되 도감용 채택에서 제외한다. 프롬프트는 두 팔의
shoulder→elbow→wrist continuity, opposed thumb grip, forward guiding hand,
rear driving hand, no mirrored duplicate hands를 명시했다.

## 자하심법·소요보결 후속 생성

`mist-star3-candidate.png`, `mist-star7-candidate.png`, `mist-star10-candidate.png`는
`output/blueprint-candidates/`에 저장했다. 자하토납은 앉은 호흡, 자하회천은 선 자세의
자원 순환, 자하신공은 몸 전체를 감싸는 확장된 자줏빛 회복 기운으로 제작·직접 확인했다.
실제 자하심법 데이터의 회복 분류를 읽었으며 공격 광선이나 피해 효과로 표현하지 않았다.

같은 폴더의 `foot-star3-candidate.png`, `foot-star7-candidate.png`,
`foot-star10-candidate.png`는 소요보결의 후퇴, 회피 반격, 큰 거리 이탈을 표현했다.
연녹·상아 복장과 발의 옅은 궤적을 공통 요청했다. 바닥 궤적은 UI 좌표나 이동 판정이 아니다.
소요환위의 장법은 시각적 반격 표현이며 무기/공격 판정 변경을 뜻하지 않는다.

## 강룡장결·천기암기록 진행

`output/blueprint-candidates/dragon-star3-candidate.png`: 견룡재전. 거친 여행 복장,
수염이 있는 성인 남성, 전진 장력과 금빛 용 형태의 기운을 생성·직접 확인했다.
용은 연출이며 실제 소환 개체가 아니다. 아래 후속 기록에서 7성·10성 제작을 완료했다.

`output/blueprint-candidates/tang-star3-candidate.png`: 추혼표. 최신 사용자 지시에 따라
성인 여성 무인, 짙은 청록·먹빛 실전 복장, 땋아 묶은 머리와 암기 주머니, 단일 투척 궤적으로
생성·직접 확인했다. 팔과 손의 투척 방향, 노출에 의존하지 않는 전투 복장을 요청했다.
여성은 암기·회피에만 제한하지 않는다. 아래 후속 기록에서 7성·10성 제작을 완료했다.

## 전체 30종 및 상대 15명 후속 제작

강룡7·10성은 은빛 머리가 섞인 중년 여성 장법 고수, 천기7·10성은 청록 실전복 여성의
침·표 확장 궤적, 팽가3·7·10성은 붉은 옷 여성 도객의 중량 베기, 창궁3·7·10성은
남청·상아 복장의 여성 검객과 푸른 검기를 표현했다. 팽가3·10성은 양손 그립을 교정했고
창궁3성은 굽어 보이던 금속 검끝을 교정했다. 채택 파일 목록은 ART_SELECTION.json이며
선택 원본의 SHA-256은 통합 PDF receipt의 source_sha256에 기록된다. 고친 원본도 보존한다.

상대15명은 OPPONENT_PRESENTATION.json의 인물별 성별·연령 인상·주력 무공에 맞춰
각각 단일 built-in 이미지 호출로 생성했다. 기존 플레이어·전투 모션·제품 파일은 변경하지 않았다.
공통 프롬프트: original wuxia opponent encyclopedia portrait; head to mid-thigh or knees;
refined expressive anime face, hand-painted ink wash on warm ivory rice paper; practical historical
robes; anatomically correct hands; no text/UI/logos/extra limbs/sexualized armor; no combat VFX.
인물별 요청 요약: 연교(28 여성, 매화·검·남청), 도겸(46 남성, 묵직한 맨손·올리브),
채령(25 여성, 단발·창궁 직검·청색), 묵진(52 남성, 삭발·염주·황토),
석무(43 여성, 강한 어깨·눈썹 흉터·붉은 중량 도), 단소(34 남성, 자줏빛·차분한 호신),
설하(48 여성, 은빛 땋은 머리·장법), 우람(38 남성, 직선 창·붉은 술·장병기),
비연(27 여성, 땋은 머리·암기 주머니), 청허(64 남성, 은발·수염·태극 직검),
담월(36 여성, 연녹·소요보법·열린 자세), 진려(32 남성, 날카로운 표정·창궁 직검),
적우(44 남성, 가는 수염·매화 직검·낡은 붉은 끈), 풍목(41 남성, 넓은 체형·도·박자감),
라진(31 여성, 긴 묶은 머리·양가창·보법).

원화15장을 직접 열람했고 도감에 각각 연결했다. 도감용 신규 원화는 최종 사용자 시각
확정 전 후보이며, 투명 전신·파츠·모션·VFX 제작 또는 게임 연결 완료가 아니다.

위 후속 생성은 모두 built-in 이미지 도구를 사용했으며 실제 데이터 효과를 먼저 확인했다.
파일명은 아직 후보이며 게임 연결·출시 권리 검증 완료를 의미하지 않는다.
# 최종 추가 교정 · 2026-09-10

`clash-keyscene-v1.png`: built-in image generation. 기존 player/enemy sword sequence를 인물 일관성 참고로 사용했다. 두 사람만, 좌우 공간 유지, 상체 높이 검 교차점의 금속 불꽃, 젖은 석조 마당과 청색 산수, 글자·UI 없는 구도를 요청했다. 실행 화면 배치와 합 설명용 **생성 원화 후보**이며 실제 게임 촬영·모션 프레임이 아니다. 원본 생성 파일은 `exec-7b77aeee-13b8-4a00-9bff-1285b3070ff5.png`로 보존한다.

최종 팽가도결 10성은 `saber-star10-grip-v2.png`를 사용한다. 양손 그립·손목 분리를 교정했고 이전 파일은 보존했다. PDF 내부 JPEG 인코딩은 파생 문서 최적화일 뿐 선택 PNG를 교체하지 않는다. 새 원화의 최종 사용자 lock·runtime 등록은 아직 별도다.

## 2026-09-11 백무진 전용 초상 후보

`opponent-baekmujin-v1.png`:1024×1536, 검은 천 가면·붉은 띠·먹색 장포의 전용 전신 도감 원화.
기존 진려 원화와 역사 가면 검객 화면을 참고하여 built-in 이미지 모델로 제작하고 직접 시각 검토했다.
도감/브리핑용 후보이며 전투 스프라이트·모션은 아니다. 사용자 final lock과 runtime 연결은 미완료다.
SHA-256·원본/참고 입력·소비처·상태군·승격 경로는 `ASSET_READINESS.json`이 소유한다.
이전 저해상도 이미지와 승인된 제품 자산은 보존한다.

## 2026-09-11 최종 승인 후 등록 readback

이전 문단의 final lock 대기는 제작 당시 기록이다. 현재47개 선정 원화는
`current_user_planning_status.json`의 `blueprint_final_approval`로 사용자 승인됐으며,
`assets/blueprint/APPROVED_ART_MANIFEST.json`에 원본 SHA-256과 byte-identical 제품 경로를 등록했다.
무공30개·도감16명·합 설명1개를 구분하고, 기존 후보·참고·플레이어·전투 모션을 보존한다.
실제 표시 함수는 `src/ui/approved_blueprint_art.gd`;47개 texture 조회 검사는 PASS다.
도감·브리핑 화면 검증과 최종 배포 권리 검증은 별도이며 전체 구현 실행 기록을 따른다.
