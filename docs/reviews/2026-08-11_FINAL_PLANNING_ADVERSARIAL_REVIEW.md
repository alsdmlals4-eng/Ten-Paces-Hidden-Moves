# Phase B 최종 기획 적대 검토 — 2026-08-11

## 판정

사용자 `기획완료` 선언을 받아 v4.5 r2의 **Phase B**에 진입했다. 이 문서는 구현 시작 선언이 아니라, current 기획 정본·Google Sheet·Base current main·파생 consumer를 다시 공격해 `REVIEW_COMPLETE` 가능 여부를 판정하는 검토 기록이다.

```yaml
phase: FINAL_PLANNING_REVIEW
user_planning_complete_declared: true
review_complete: false
product_implementation_authorized: false
image_generation_allowed: false
next_gate: USER_APPROVE_ART_DIRECTION_AND_VISUAL_PRODUCTION_ORDER
blocking_p0: 0
blocking_p1: 1
HUMAN_USABILITY_EVIDENCE: NOT_RUN
PLAYER_EXPERIENCE_EVIDENCE: NOT_RUN
ANDROID_PHYSICAL_DEVICE_EVIDENCE: NOT_RUN
LOCAL_WINDOWS_VISIBLE_EVIDENCE: NOT_RUN
```

**이미지 생성은 아직 시작하지 않는다.** 사용자가 이미지 작업을 다시 요청한 사실은 Sheet에 반영했지만, `REVIEW_COMPLETE` 전에 새 생성 파일을 만드는 것은 현재 작업 계약과 맞지 않는다.

## Fresh authority recovery

- Project main at Phase-B entry: `b9a9db62f4fd860131561a11d2ddebf3d496f39a`.
- Base current main: `7ce96181d0a97930300fcc6d383dacc75ad08f6a`.
- Project open PR at work-start: 0.
- Base open PR at work-start: 0.
- Google Sheet 26개 관련 tab을 다시 읽었다.
- Base는 recursive tracked-file inventory를 먼저 복원한 뒤 `START_HERE → AGENTS → OPERATING_MODEL → WORK_MODE_AND_SKILL_ROUTING → DOCUMENTATION_MAP → SKILL_REGISTRY → generated active skill view`를 읽고, 현재 작업의 art/UI/adversarial owner를 깊게 읽었다.
- Base current Registry active skill count는 이 관측 시점에 30개이며, 숫자 자체를 설계 목표로 사용하지 않는다.

## 실제 사용한 Skill / external process overlay

Base primary review discipline은 `running-adversarial-review-and-refinement`로 두고, art/UI 및 current-state owner를 지원 경로로 사용했다. 외부 process overlay로 다음을 **실제로 실행**했다.

- `superpowers/brainstorming`
- `superpowers/test-driven-development`
- `superpowers/systematic-debugging`
- Base `running-adversarial-review-and-refinement`

이 overlay는 실행 방법만 강화하며 프로젝트/Base 정본 권한을 갖지 않는다.

## TDD RED

Phase-B review artifact가 실제 완료 조건임을 기존 CI가 실행하는 `tests/test_planning_completion_inventory.py`에 먼저 추가했다. PR Validation에서 다음 이유로 RED를 확인했다.

```text
missing Phase B JSON:
docs/planning-data/final_planning_adversarial_review_20260811.json
```

새로 만든 독립 테스트 파일은 중앙 PR Validation의 명시적 목록에 자동 포함되지 않았으므로 그 첫 실행을 RED 증거로 세지 않았다. 실제 CI consumer에 assertion을 붙인 뒤 누락 artifact 때문에 실패한 것만 TDD RED로 인정했다.

## 적대적 검토 — 확인된 drift와 처리

### 해결된 P1

1. **Sheet current-state drift** — #161 병합 뒤에도 Hub와 active tooling이 3.1.3 parent만 current처럼 보였고 TEN-IMG-001은 과거 `PAUSED_BY_USER` 상태를 유지했다. Godot AI 3.1.4 freshness overlay와 사용자 이미지 작업 재개/Review Gate를 Sheet에 반영하고 readback했다.
2. **플랫폼 derivative drift** — `05_GDD_요약`, `20_코어경험_데모목표`, `90_본제작_출시_사업`이 superseded PC-first/mobile-later 방향을 current처럼 표시했다. 기존 Windows·Android dual-target/shared-core Decision으로만 교정했다.
3. **묶음 자원 회복 drift** — `12`, `15`, `40`의 부모 +1/+1/+1 표현을 current `기력+1 / 내력+0 / 절초기세+1` overlay로 교정했다.
4. **관찰 표시 drift** — `[이동+공격]` 같은 synthetic composite token을 제거하고, 앞 슬롯부터 실제 행동 종류를 슬롯별 개별 태그로 표시하도록 current UI authority에 맞췄다.
5. **기술 작성 가격/상한 drift** — `41_성장_경제`에서 역사 `0/10/25/40` 가격을 current authoring처럼 표시하던 부분을 history-only로 격리하고 current `0/15/30/45`를 연결했다. core stat hardcap도 이미 `UNCAPPED` Decision으로 해결됐음을 반영했다.

모든 위 변경은 새 게임 규칙이 아니라 **기존 승인 Decision의 stale consumer 교정**이다.

### 남은 비차단 P2 / 후속 Gate

- 슬롯4·5의 full opponent candidate pool은 아직 작성되지 않았다. 첫 visual program에서는 invent하지 않으며, full 5-duel content BUILD 전에 닫는다.
- save-slot 수와 exact retry-cost/recovery 값은 current approved product value가 아니다. visual에는 exact 숫자를 bake하지 않고 App Flow BUILD Definition of Ready에서 닫는다.
- `ACTIVE_CONTEXT`의 일부 live semantic pointer는 3.1.4 freshness/image-work resume를 직접 반영하지 못한 stale 가능성이 남아 있어 Review Complete 전 current-router freshness 보정 대상으로 둔다.
- 사람 사용성·플레이어 경험·Android physical device·local Windows visible evidence는 기획 텍스트 검토와 별개의 증거층이며 계속 `NOT_RUN`이다.

## 벤치마킹·현업 조사

### SOURCE FACT / PROFESSIONAL GUIDANCE에서 얻은 패턴

- 계획형 전술게임의 강한 사례는 **상대 의도/행동을 읽을 수 있게 하고, 계획/commit/resolve를 구분**한다.
- Godot의 Control/Container 및 multiple-resolution 접근은 화면마다 baked text 그림을 만드는 것보다 responsive layout rule과 editable UI를 유지하는 방향과 맞는다.
- Android 접근성의 48dp touch-target reference는 compact landscape UI에서 클릭 가능 영역을 시각 장식보다 우선해야 함을 뒷받침한다.
- 역사적 수묵화의 여백·명도군·먹 번짐·붓선 절약은 두 인물 사이 **거리의 긴장**을 시각화하는 데 유효한 참고 원리다.

### PROJECT RECOMMENDATION

가져올 것은 **의도 가독성, commit/resolve 분리, responsive layout, 여백을 이용한 거리 표현**이다. 가져오지 않을 것은 deck/hand/draw 문법, 확률 명중률, 경쟁작 exact UI, named contemporary artist style, 타 게임 규칙이다.

## 그림체 접근 3안

### A — 담묵 전술화 / Ink Tactical Layer — 권장

- 게임 플레이 영역은 동양 수묵의 먹선·담채·안개·큰 여백을 사용한다.
- 캐릭터는 얼굴 묘사보다 실루엣, 무기, 자세, 붓 방향으로 행동을 먼저 읽게 한다.
- 정보 UI는 그림에 굽지 않고 **선명한 editable UI layer**로 분리한다.
- 바탕은 먹/미색/갈색 계열, 강조는 절제된 주사색·낡은 금색을 사용하되 색만으로 상태를 구분하지 않는다.
- 전투 배경의 contrast는 카드/거리/계획판 아래에서 의도적으로 낮춘다.
- 키아트만 같은 문법 안에서 채색·붓질 밀도를 높인다.

장점: 현재 `거리 N`, anonymous duel, 3/3/4 정보 위계와 가장 잘 맞고 Windows/Android 양쪽에서 UI 분리를 유지하기 쉽다. 이전 chat generation의 한국어/규칙 hallucination을 구조적으로 피하기에도 가장 유리하다.

### B — 목판·인장 그래픽 전술화

검정/미색/주사색의 강한 blockprint·seal 문법. 작은 화면 가독성과 아이콘 통일은 좋지만, 무협 수묵 정서보다 목판 인상이 강해지고 전장 공간감이 평평해질 위험이 있다.

### C — 시네마틱 채색 무협 회화

풍부한 색과 광원, 역동적인 완전 채색 duel. 마케팅용 impact는 가장 강하지만 tactical UI noise와 제작비·일관성 비용이 크므로 core gameplay 전체 스타일로는 권장하지 않는다. **A의 문법을 유지한 key-art intensity**로 제한하는 것이 적절하다.

### 권장 조합

```text
CORE GAMEPLAY = A 담묵 전술화
KEY ART / MARKETING = A + controlled C-lite intensity
```

시각 pillar:

1. **거리의 긴장** — 여백 자체가 상대와의 거리 감각을 만든다.
2. **먹선으로 읽는 무공** — 이름보다 자세·무기·붓선 방향이 먼저 행동을 설명한다.
3. **종이 위의 전술** — 무공서·인장·한지 texture는 분위기를 만들고 실제 수치는 crisp UI가 소유한다.
4. **절제된 색의 의미** — 주사/금색은 강조일 뿐 유일한 상태 신호가 아니다.
5. **정본 텍스트는 UI layer** — 생성 이미지의 한국어를 규칙 권위로 사용하지 않는다.

## 제작 목록 — 우선순위 순

P0/P1부터 정리하고 key art는 visual system이 안정된 뒤 만든다.

1. **TEN-IMG-001 — Master Combat Planning Screen reference**: 익명 두 무인, 중앙 `거리 2`, 번호 발판 없음, 3|3|4 전체 계획, 현재 묶음, 행동계획 잠금, 카드/관찰 정보.
2. **TEN-IMG-002 — Combat Card + Detail Component Sheet**: 공격/비공격, 1수/2수, 비용, 실제 핵심효과, 상세창, state variants. deck/hand 인상 금지.
3. **TEN-IMG-004 — Responsive Combat Layout Sheet**: Wide / Standard / Compact landscape 비교. Android 48dp·safe area 포함.
4. **TEN-IMG-005 — Plan / Resolve / Review State Sheet**: unlocked→locked→전조→실행→중단→결정론적 복기.
5. **TEN-IMG-006 — Core Combat Icon / VFX Language Sheet**: 이동·공격·방어·회피·준비·자원·관찰·전조·밀착·합·중단. shape+label 병행.
6. **TEN-IMG-007 — Main / Run Setup UI reference**: 새 회차/계속/설정 + 시작 무공서 setup. 주인공 final portrait를 전제로 하지 않는다.
7. **TEN-IMG-008 — Route / Node / Briefing reference**: 절차 경로, 두 후보, 노드 정보, 비무 전 공개 정보 위계.
8. **TEN-IMG-009 — Duel Result / Review / Reward / Retry reference**: 인과 복기 우선, reward/commit/retry 분리. 미승인 exact retry 숫자 금지.
9. **TEN-IMG-010 — Martial Manual / Faction Visual Language Sheet**: 10권을 full portrait 10장 대신 인장·문양·무기·자세·종이 texture language로 구분.
10. **TEN-IMG-011 — Opponent Silhouette / Stance Production Sheet**: 현재 정본화된 슬롯1~3 원형부터. 슬롯4/5를 임의 창작하지 않는다.
11. **TEN-IMG-003 — Key Art / Steam capsule family**: visual system 안정 후 crop-safe master와 파생 규격 제작.
12. **TEN-IMG-012 — Optional hero combat splash**: Delete Test에서 실제 가치가 입증될 때만 제작.

## 이미지 production guardrail

- `TEN-IMG-001`의 과거 chat generation은 모두 `NOT_AN_ASSET` 상태를 유지한다.
- 논리10칸은 내부 규칙이지만 player-facing 번호 발판 strip은 만들지 않는다.
- 시작 공개 거리는 `2`, 거리0은 `[밀착]`.
- `[기절]`, `예상 명중률`, `% 명중률`, deck/hand/draw, 임의 무공명·세력명·수치 효과를 만들지 않는다.
- 정확한 한국어·수치·카드 규칙은 editable UI layer에서 작성한다.
- 생성 결과는 바로 제품 자산이 아니라 `GENERATED_EXPLORATION → IN_REVIEW`로 들어간다.

## 현재 Review Complete 차단점

P0는 0이다. 현재 P1은 **아트 프로그램 1건**뿐이다.

> 사용자 결정: A `담묵 전술화`를 core gameplay로, key art만 A+C-lite intensity로 두고 위 제작 순서대로 정본화할지 승인 필요.

이 결정이 닫히면 `ACTIVE_CONTEXT` freshness를 최소 보정하고, art program을 동일 Decision ID로 GitHub·Sheet에 기록한 뒤 exact-head CI와 적대적 검토를 통과시켜 `REVIEW_COMPLETE`를 판정한다. 그 뒤에야 이미지 제작 단계로 넘어간다.
