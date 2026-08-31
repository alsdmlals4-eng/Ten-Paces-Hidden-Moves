# TEN-DEC-20260820-VISUAL-COMPONENT-STYLE-SYSTEM-02

## 상태

`APPROVED`

## 사용자 승인

- 사용자 지시: `좋아 권장안대로 진행하자.`
- 추가 운영 지시: `깃허브,노션에도 항상 현재 작업 순서,승인사항 올리는거 잊지말고`

## 결정

첫 5전 Vertical Slice의 기존 `TEN-DEC-20260820-VISUAL-UX-SYSTEM-01`을 다음과 같이 구체화한다.

1. 그림체는 **비픽셀 2D · 수묵 선화 × 저채도 담채 × 제한된 금색 포인트 · 반실사 무협 일러스트**를 기준선으로 사용한다.
2. UI는 **먹색 구조판 + 밝은 종이 정보면 + 얇은 금 결정선 + 제한된 붓터치 accent**를 사용한다.
3. 캐릭터는 성인 `7~7.5등신`, 얼굴/머리·무기·자세·큰 의상 실루엣·지배 포인트색 1개 중심으로 구별한다.
4. 동일 Character Master에서 Portrait/Combat/Result/Thumbnail을 파생한다.
5. 기존 7 shared component를 폐기하지 않고 12 Component Family로 확장한다.
6. `1440×900` logical viewport를 디자인 기준, `1280×800`을 current desktop window check, `1280×720`을 compact regression 기준으로 사용한다.
7. Android orientation은 현재 정본 근거가 없으므로 임의 확정하지 않고 width/height responsive profile로 설계한다.
8. spacing/grid/type/component sizing baseline과 상태표는 `docs/18_VISUAL_ART_STYLE_COMPONENT_SYSTEM_SPEC.md`를 따른다.
9. exact color token은 기존 runtime 계보를 initial seed로 사용하되, 사용자가 이후 제공하는 원본 시안 review에서 chroma/재질 세부를 조정할 수 있다. semantic role은 유지한다.
10. 새 이미지 생성은 별도 사용자 명시 요청 전 진행하지 않는다.

## 12 Component Family

- `InkSurface`
- `InkFrame`
- `CharacterSlot`
- `IdentityHeader`
- `MartialActionCard`
- `ResourceStrip`
- `TacticalStateChip`
- `DecisionTile`
- `TimelineBundle`
- `CauseEventChip`
- `NextOpponentLockup`
- `CompletionMemoryCard`

## 보호 대상

이 결정은 다음을 변경하지 않는다.

- 논리 10칸 전장.
- `3 → 3 → 4` 계획.
- hidden current plans.
- AI anti-cheat.
- 거리·합·대응·중단·복기.
- 시작 6중4.
- 상대 15명 구조.
- Review overlay / Result separate Scene / Route separate Scene.
- Route locked-opponent no-reroll.
- player-only observation authority.
- existing ten manuals.
- no deck/hand/draw reinterpretation.

## Human evidence ceiling

- 디자인 baseline 승인: `PASS_BY_USER_DECISION`.
- final reference Human approval: `NOT_RUN`.
- Windows visible readability: `NOT_RUN`.
- Android device/layout: `NOT_RUN`.
- 15-character visual distinguishability: `NOT_RUN`.
- final VFX/audio: `NOT_RUN`.

## Reopen

다음에서만 세부 art/component baseline을 다시 연다.

- 1280×720 핵심 정보 손실.
- non-pixel battler가 전술 판독 방해.
- Character Master 파생 일관성 실패.
- 15명 식별성 실패.
- Review 코칭화.
- Route 메타게임 비대화.
- 사용자가 이후 제공하는 원본 시안이 현 방향보다 명백히 우수함.

## 현재 작업 순서

1. 이 Decision + 상세 spec + structured contract를 GitHub에 기록.
2. PR 검증/병합.
3. Notion `02 · 비주얼 바이블`, `03 · UI · 전투 Flow Map`, `04 · 에셋 라이브러리`, `13 · Handoff`, Project Home에 승인/작업순서를 동기화.
4. 이후 원본 시안 수령 시 비교 review.
5. 승인 reference 뒤 `TEN-VIS-A01~A06` 제작 및 구조화.
6. Windows visible/Human 검증.
7. Android 실기기에서 orientation/safe-area 최종화.
