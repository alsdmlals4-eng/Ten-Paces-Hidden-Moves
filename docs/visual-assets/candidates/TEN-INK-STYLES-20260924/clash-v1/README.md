# 먹으로 잇는 합 · 움직임 시안 01

상태: **USER_REVISION_REQUIRED / SUPERSEDED_PREVIEW**. 사용자는 이 1차 시안의 멋과 무협 느낌이 부족하다고 평가했다. 현재 검토 대상은 [2차 시안](../clash-v2/README.md)이다. 아래는 1차 제작·기술 검증 이력이며 사용자 품질 승인을 뜻하지 않는다. 화풍은 사용자가 선택한 8번 인물·선, 3번 명암 대비, 9번 원경 안개를 따른다.

## 보기와 목적

상위 [비교 화면](../index.html#clash-preview)에서 처음부터 재생, 0.5배 재생, GIF 전환을 사용한다. 직접 보기: [GIF](ink-clash-v1.gif), [MP4](ink-clash-v1.mp4).

- 대각선 대치 → 접근/검 교환 → 합의 승패 → 공격 → 자세 회수의 연결과 먹 궤적을 평가한다.
- 왼쪽 검객의 검은 옷/붉은 띠와 오른쪽 검객의 회색 옷/청록 띠를 유지한다. 먹은 검끝 경로를 따라가고 접촉 순간에 갈라진다.
- 결과를 하단에 이어 표시한다. 이 시안은 고정된 한 상황이며 세 번의 검 교환이 세 번의 피해나 새 규칙을 뜻하지 않는다.
- 각 검객의 실제 생성 자세는 6개다. 자세 교체에 위치·회전 보간과 먹 효과를 더했다. 모든 중간 동작을 새로 그린 최종 애니메이션은 아니다.
- 무음 8.4초 / 25fps / 210프레임. GIF 960×540, H.264 MP4 1280×720. GIF는 반복되며 MP4는 정지·속도 조절이 가능하다.

## 조사와 적용 판단

2026-09-24 원문 및 공식 영상의 일부 구간을 확인했다. 아래의 표현 적용은 우리 시안의 판단이며 해당 게임의 프레임 시간이나 규칙을 재현했다는 뜻이 아니다.

| 1차 자료 | 확인한 사실·표현 | 이번 적용과 경계 |
|---|---|---|
| [Limbus Company 개발사 제품 설명](https://store.steampowered.com/app/1973530/Limbus_Company/) | 서로를 겨냥한 행동이 합으로 연결되며 승자가 상대 행동을 막고 공격으로 이어가는 구조를 설명한다. | 상대와 부딪치는 교환, 승패가 갈리는 순간, 후속 공격을 구별한다. 코인·위력·덱 규칙은 도입하지 않는다. |
| [ProjectMoon 공식 합 소개](https://www.youtube.com/watch?v=Jnn33aGz3UE) | 2023-02-03 공개된 출시 전 설명 영상. 약1:39/1:56 구간의 전진 자세·공격 잔향·교환 뒤 분리를 화면으로 확인했다. | 짧게 알아볼 수 있는 자세와 공격의 잔향을 참고한다. 현재 게임 수치, 정확한 정지 시간, 전체 동작의 검증 근거로 쓰지 않는다. |
| [Library of Ruina 공식 퍼블리셔 설명](https://www.arcsystemworks.com/game/library-of-ruina/) / [공식 플레이 영상](https://www.youtube.com/watch?v=YsrsO9Cdnso) | 계획한 행동과 서로 겨누는 합의 결과를 구분하는 구조. 플레이 영상에서는 전투 배치/계획 화면을 확인했다. | 행동설계와 전투진행의 두 화면 의미를 유지한다. 주사위·카드 경제는 가져오지 않는다. 영상의 합 전 구간을 측정한 것은 아니다. |
| [Nine Sols 개발사 소개](https://store.steampowered.com/app/1809540/Nine_Sols/) | 손그림 2D와 튕겨내기 중심 액션을 설명한다. | 준비·맞부딪침·회수의 자세를 읽히게 하는 방향을 참고한다. 실제 게임의 타이밍을 측정/복제했다고 주장하지 않는다. |

외부 게임 이미지·영상·음악을 내려받거나 자산으로 사용하지 않았다. 원화 3개는 기존 승인 방향 참조로 내장 이미지 도구에서 새로 생성했으며 프롬프트는 [prompts.json](prompts.json)에 기록했다. 후보 생성은 shipping 권리/최종 승인과 별개다.

## 제작·검수 근거

기준 SHA ec7240633e21aec448f9426781a7acbf294aa748. Work Mode BUILD/VISUAL_PROTOTYPE, REVIEW. Skill: project workflow router, imagegen(참조 기반 생성), skill-creator(별도 HTML 재사용 요청). CURRENT_SOURCE_RELEVANCE_CHECK=공식 자료 신규 조사+기존 화풍/전투 owner 재사용. FEASIBLE: 생성 PNG, 로컬 프레임 합성·인코딩, 기존 제한형 미리보기 서버를 재사용했다.

- [render-check.json](render-check.json): 프레임별 해시와 수동 등록한 검손잡이/검끝 기준의 세 접점 계산. 1.65 / 2.50 / 3.40초에 검선이 교차함을 확인했다. 자동 물리 또는 Godot 판정 검증이 아니다.
- [media-check.json](media-check.json): 실제 GIF 디코딩 결과 210프레임, 8,400ms, 반복0(무한), 전장 영역의 서로 다른 프레임210개. MP4/GIF/포스터의 크기·SHA256 포함.
- 전체 검토1/2(신규 모션·재사용 패키지): 사용자 의도, 원본·실제 표현, 파일/사용처, 비용·브라우저 부하를 대조했다. 먹 머리와 검끝의 시차, 인접 자세의 작은 조각, GIF 전환 후 영상 중복 표시를 확인해 교정했다. 생성 원화는 보존하며 표시용 셀만 정리했다.
- 전체 검토2/2: 정본·기존 consumer·출처·재사용성·실제 실행 근거와 비용을 대조했다. 정지 참조 단계의 NOT_RUN 문구를 현재 오프라인 GIF 근거와 구분하고, HTML 예시의 주소별 임시 저장 한계와 내보내기 대체 표시를 명시했다. 게임 보호 경로와 실제 사용자 리뷰 저장소를 건드리지 않는다.
- 이후는 위 결함의 집중 재검증만 수행한다. 브라우저와 관련 검사 결과는 상위 README 및 HTML 재사용 패키지 기록과 함께 읽는다.

## 재현

Node의 @napi-rs/canvas, Python의 Pillow, FFmpeg가 필요하다. 이미 있는 도구를 사용하며 설치/비용을 암묵적으로 추가하지 않는다. Node 모듈은 CANVAS_MODULE 환경변수로 선택할 수 있다.

1. 프로젝트에서 node docs/visual-assets/candidates/TEN-INK-STYLES-20260924/clash-v1/render.cjs 실행.
2. python docs/visual-assets/candidates/TEN-INK-STYLES-20260924/clash-v1/encode.py --ffmpeg <기존 FFmpeg 경로> 실행.
3. 다시 생성했다면 media-check.json의 출력 해시를 상위 candidates.json.motion.files에 반영한 뒤 open_preview.py로 새 발행본을 연다. 해시 검사를 생략하지 않는다.

Godot 연결·실제 판정과 모션 동기화·다른 무공/회피/중단·사람이 느끼는 자연스러움·Android·출시 성능·최종 자산 승인은 NOT_RUN/미확정이다. 다음 제품 적용은 실제 consumer와 PR342를 다시 대조하며 진행한다.
