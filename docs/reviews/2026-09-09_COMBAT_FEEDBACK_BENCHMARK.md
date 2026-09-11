# 전투 피드백 정합성 · 현재 근거와 재사용 조사

```yaml
CURRENT_SOURCE_RELEVANCE_CHECK: APPLICABLE
PREWORK_BENCHMARK_REVERSE_ENGINEERING_GATE: RESEARCHED
checked_at: 2026-09-09 Asia/Seoul
product_baseline: fe720f5dce686ea5b2ff68a1ec078d53544a0e92
decision_dimension: RESOLVED_ACTION_IDENTITY_OUTCOME_AND_ACCESSIBLE_FEEDBACK
feasibility: FEASIBLE
human_playtest: NOT_RUN
```

## 실제 문제와 조사 한계

### 2026-09-10 하단 카드·현재 계획·효과음 후속

현재 동일 작업본의 확정 행동/시각·음향 피드백 차원에서 아래 10사례를 재사용한다.
새 규칙이나 audio framework 없이 실제 GridContainer, LinkedActionBlock, CombatSoundBank를
보강한다. 사용자가 제공한 최신 두 이미지의 기능적 계층을 적용하며 픽셀 복제는 하지 않는다.
공식 GridContainer와 AudioStreamWAV 문서를 2026-09-10 재열람했다:
https://docs.godotengine.org/en/stable/classes/class_gridcontainer.html
https://docs.godotengine.org/en/stable/classes/class_audiostreamwav.html
남는 세로 공간의 grid 행 배분과 native PCM cache는 ADAPT. 장식 때문에 해금/기력/대상
정보를 지우거나 상단 전투60%를 축소하는 안은 REJECT. 선택 기술의 현재 삽화를 같은
linked action consumer에서 재사용하는 안은 ADOPT. 초상 세로 그림을 얇게 잘라내는 COVERED는
전체 동작 판독에 부적합해 KEEP_ASPECT_CENTERED로 교정한다.
음색은 단일 공통 발진음에서 바람/금속/타격의 서로 다른 envelope·inharmonic partial로
분리한다. 합성 원본이며 실제 검 녹음이나 청음 승인이라고 주장하지 않는다.
FEASIBLE: 기존 상태/신호/캐시 사용, 저장·AI·도메인 수치 불변, 자산/계정 추가 비용 없음.

### 2026-09-10 동일 판정→연출 차원 재사용

현재 source 885c91ee + character-motion 작업본의 사용자 타격감 요청에 대해 아래
10개 비교의 확정 사건/접근성 피드백 경계를 재사용한다. 새로운 전투 규칙·카메라 시스템
도입이 아니라 기존 impact 소비자의 작은 연출 보강이다. fresh 공식 검토:
[CanvasItem](https://docs.godotengine.org/en/stable/classes/class_canvasitem.html)의
부모 변환 전파, [Tween](https://docs.godotengine.org/en/stable/classes/class_tween.html)의
pause/play를 확인했다. 별도 접근성 지침 페이지는 열기 실패로 증거에서 제외했다.
전체 viewport/Camera2D 흔들림은 HUD 영향으로 REJECT, 전장 render-only 변환은 ADAPT,
새 카메라/후처리 프레임워크는 현 범위 대비 비용 때문에 REJECT한다.
전역 time_scale/SceneTree 정지는 REJECT하고 실제 캐릭터 Tween·자세만 짧게 유지한다.
UI/도메인/AI/save 변경 없이 구현 가능하며 가청 선호·멀미·실기기 성능은 미측정이다.
Base remote fresh 관측 580a362db07b4b1a91a87300402969793784acff; 기존 adoption pin은 보존했다.

`combat_board_preview.gd`는 모든 terminal 상태에 `defeat`를 요청한다. 실제 승리 회귀도 그 잘못된 cue를 기대한다. 같은 파일의 절초 판별은 `ultimate_` 접두사만 사용하지만, 실제 열 무공서의 10성 정의는 `<manual>_star10`과 actor-owned `source_kind=ultimate`다. 7개 공격·2개 대응·1개 회복 절초를 모두 공격으로 가정할 수도 없다. `combat_resolution_engine.gd`의 presentation projection은 이미 계산된 martial detail 일부를 버린다.

아래는 제품 제작자의 설명/개발 기록을 직접 연 사례 비교이며, 게임 코드를 역공학하거나 플레이 테스트를 수행했다는 주장이 아니다. 기존 9월 1일 frontal-duel 비교의 같은 화면 책임을 재확인하되, 이번에는 **확정 사건과 음향·동작의 불일치**를 별도 검증 축으로 삼았다. 개별 플레이어 인터뷰·사용성/사운드 선호 표본은 전부 미수집이다. 판매 페이지의 평점은 해당 표현 방법의 인과 증거로 사용하지 않는다.

## 10개 사례 비교

| 사례/분류 · 직접 열어 확인한 1차 자료 | 공식 제품 사실 · 기전 | 전이 원칙 / 판단 | 복사 금지 · 반응 증거/실행 검증 |
|---|---|---|---|
| [Your Only Move Is HUSTLE](https://store.steampowered.com/app/2212330/Your_Only_Move_Is_HUSTLE/) · 직접 | 턴 단위 계획을 격투 동작/리플레이로 표현 | 계획과 연출을 분리하고 확정 사건만 재생 · ADAPT | 자유 시간선/상대 숨은 계획 예측 복사 금지. 반응 표본 미수집. skip 전후 전투 상태 동일 검사 |
| [Shogun Showdown](https://goblinzstudio.com/game/shogun-showdown/) · 직접 | 위치와 실행 시점이 중요한 턴 전투 | 카드 분류·실제 실행 결과의 일치 · ADAPT | 덱·드로우·타일 쿨다운 도입 금지. 반응 표본 미수집. 3/3/4와 거리 보호 |
| [Fights in Tight Spaces](https://store.steampowered.com/app/1265820/) 및 [개발사 패치 기록](https://roadmap.groundshatter.com/home) · 직접/혼합 | 전술 선택을 싸움 연출로 보여줌. 과거 패치가 회피 시 충격음과 피해 없는 공격 아이콘을 별도 교정 | 외형보다 사건별 의미 검증 우선 · ADOPT | 해당 패치는 역사 사례이지 최신 버전 품질 보증이 아님. 덱/핸드 복사 금지. 직접 반응 미수집; 실패·회피에 성공 타격음 없는지 검사 |
| [Hellish Quart](https://www.hellishquart.com/) · 직접/혼합 | 검의 물리 충돌과 방어를 동작으로 표현 | 바닥 접점·접촉 방향 유지 · ADAPT | 물리 기반 판정·즉사/실시간 난도 복사 금지. 반응 표본 미수집. 기존 공유 합 anchor/피격 동작 회귀 |
| [For Honor · The Art of Battle](https://www.ubisoft.com/en-ca/game/for-honor/news-updates/3i9GE9e7XGWHqKQH2wUtZc/for-honor-the-art-of-battle) · 인접 | 방향/자세를 전투 제어의 읽을 수 있는 신호로 사용 | 위협·방어·성공 의미를 분리 · ADAPT | 3방향 입력·반사신경 시험 도입 금지. 반응 표본 미수집. 모션 감소/음소거에서도 결과 텍스트 유지 |
| [Into the Breach](https://subsetgames.com/itb.html) · 인접/혼합 | 적 공격 예고를 전술 문제의 정보로 제공 | 공개된 결과의 정확성 · ADAPT | 모든 미래 적 행동 공개는 REJECT. 반응 표본 미수집. 아직 해결되지 않은 수는 표시/오디오 금지 |
| [Phantom Brigade](https://braceyourselfgames.com/phantom-brigade/) · 인접 | 시간선에서 계획하고 실행하는 전술 구조 | 실행과 관찰의 단계 분리 · ADAPT | 전체 미래 시간선 예측/분대 구조 복사 금지. 반응 표본 미수집. COMMITTED/RESOLVED 복원에서 재판정·재보상 금지 |
| [Marvel’s Midnight Suns · Firaxis 설명](https://blog.playstation.com/2022/10/26/marvels-midnight-suns-super-heroic-turn-based-combat-and-card-tactics-explained/) · 인접 | 강력한 기술과 지원 능력을 구분한 턴제 영웅 전술 | 절초도 공격·대응·회복의 실제 역할을 표현 · ADAPT | 덱/드로우/영웅 연출 자산 복사 금지. 반응 표본 미수집. 회복 절초가 적을 때리는 동작이 되지 않는지 검사 |
| [Inkulinati](https://store.steampowered.com/app/957960/Inkulinati/) · 인접 | 필사본 회화 스타일의 턴제 전략 | 스타일과 기능 식별을 함께 유지 · ADAPT | 중세 삽화·특정 캐릭터 모사 금지. 반응 표본 미수집. 기존 승인 수묵 원본 유지 |
| [Slay the Spire](https://store.steampowered.com/app/646570/Slay_the_Spire/) · 인접/부정 전이 | 덱 구성·반복 도전·갈림길의 결합 | 선택 결과와 비용 판독만 참고 · TEST | 덱/손패/드로우와 자유 분기 횟수 복사는 REJECT. 반응 표본 미수집. 이 수정으로 성장·보상·행로 규칙을 건드리지 않음 |

## 엔진·자산·실무 조사

- [Godot AudioStreamPlayer](https://docs.godotengine.org/en/stable/classes/class_audiostreamplayer.html): 자연 종료의 `finished`는 `stop()`/tree exit 때 발생하지 않는다. 음향 검증은 멈춘 player에 `finished`를 무한 대기하지 않는다. 기존 두 player의 동시 재생 상한과 음소거/음량 경로를 보존한다.
- [AudioServer](https://docs.godotengine.org/en/stable/classes/class_audioserver.html): `get_time_since_last_mix()`는 마지막 mix 이후 시간을 제공한다. exact 4.7.1 인과 probe에서 재생 중 즉시 stop/free/quit할 때만 두 오디오 객체 경고가 발생했다. 실제 mix 경계가 지난 뒤(관측 7,799µs) 또는 자연 종료 뒤에는 사라졌다. 이는 제한된 테스트 종료 조건 증거이지 모든 device/scene churn의 무누수 증명이 아니다. 제품 cache 삭제·고정 sleep·로그 억제는 REJECT.
- [Godot Tween](https://docs.godotengine.org/en/stable/classes/class_tween.html): node-bound tween/명시적 종료를 사용한다. 새 motion system이나 재사용 tween을 만들지 않고 기존 취소·reduced-motion 경로를 재사용한다.
- [Godot 일반 최적화 지침](https://docs.godotengine.org/en/stable/tutorials/performance/general_optimization.html): 병목 측정→제한된 수정→재측정. 저장 latency 개선을 평균 FPS 개선으로 보고하지 않는다.
- [Kenney Impact Sounds](https://kenney.nl/assets/impact-sounds): 무료 CC0, 130개, 2019 v1.0으로 게시된 충격/foley 후보. 이번 빈칸은 결과 의미/절초 연결이며 범용 충격음 팩이 이 문제를 해결하지 않는다. **DEFER**, 다운로드/취득/가청 선호 평가 안 함. 현재 원본 결정적 synthesis와 승인 VFX를 **EXISTING_ADAPT**한다. 유료 도구·외부 코드·플러그인 추가 없음.

## 최소 3개 대안과 선택

| 대안 | 장점 | 비용/실패 위험 | 판정 |
|---|---|---|---|
| prefix에 `_star10` 문자열 추가, 승리만 무음 | 작은 diff | 다른 actor/가짜 ID 오분류, 회복을 공격으로 처리, 무음이 누락을 숨김 | REJECT |
| actor-owned 정의와 기존 확정 사건을 소비하는 공용 presentation profile; 도메인 terminal outcome 단일 함수 | 저장/판정 변경 없이 일관된 분류, 모든 실제 consumer에서 검증 가능 | 작은 helper/회귀 추가, 기존 오류를 고정한 테스트 이관 필요 | ADOPT |
| 새 animation graph·별도 audio middleware·전면 자산 재생성 | 장기 제작 도구의 가능성 | 현 결함보다 훨씬 큰 비용/권리/통합 위험, 근거 없는 추상화 | REJECT for this correction |

## 정본·consumer 영향과 구현 가능성

도메인 terminal 결과 함수 → board 종료 텍스트/음향 + bridge 결과 DTO. actor-owned card definition + transient resolved event → presentation profile → 기존 VFX/동작/label/두 오디오 player. UI는 피해·방어·합·보상을 재계산하지 않는다. 기존 저장 schema/semantic identity·AI lock·3/3/4·기세·10전/36행로를 보존한다. Godot 4.7.1에서 현재 경로/씬/자산이 존재하고 headless/visible 실행 가능하다. 분류·PCM·상태 동일성은 자동 검증 가능, 가청 품질/사람 이해/Android/출시 성능은 별도 미검증이다.

Base remote `2fbb934d987b297f1fc967f0e117f303c8aa1861`의 current 공용 loop는 2회 상한이다. 프로젝트 AGENTS의 명시적 5회 요구와 차이를 확인했다. 이번에는 상위 프로젝트 지시를 유지하며 Base v9.4.4/채택19355 payload를 교체하지 않는다. 이를 이미 동기화된 것으로 보고하지 않는다.

이 자료는 성장 지출·사건 세부 선택·정탐 단계·등급 보상·대부분 적 캐릭터 고유 art의 미구현을 닫지 않는다. 그 항목은 다음 실제 구현 계약의 대상이다.
