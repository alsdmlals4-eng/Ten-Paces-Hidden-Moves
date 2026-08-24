# Shared Player/AI Martial Pool Decision

- Decision ID: `TEN-DEC-20260824-SHARED-PLAYER-AI-MARTIAL-POOL-01`
- 날짜: 2026-08-24
- 상태: `APPROVED_BOUNDED_CORRECTION`
- 승인 근거: 사용자 명시 지시 — `좋아 진행해` + `Ai들은 새로운 무공을 쓰는게 아니라 사용자도 배우면 사용가능한 문파의 무공서의 기술을 쓰는 것 잊지말고`
- 상위 전투/무공 정본: `TEN-DEC-20260806-TEN-RECOGNIZABLE-MARTIAL-MANUALS-FULL-GROWTH-01`
- AI 적용 정본: `docs/planning/AI_INDIE_PATTERN_ADOPTION_2026-08-24.md`

## 결정

1. 상대 AI는 AI 전용 신규 무공서·무공 기술을 사용하지 않는다.
2. AI가 사용하는 문파 무공서는 플레이어도 해당 무공서를 습득하면 사용할 수 있는 `PLAYER_LEARNABLE_SHARED_WITH_AI` 공용 풀에 속해야 한다.
3. 같은 무공서와 같은 성급/해금 조건에서는 플레이어와 AI가 같은 martial card ID와 같은 기술 효과 정본을 사용한다.
4. 상대별 차이는 전용 기술 추가가 아니라 `loadout`, 숙련도/성급, 기초 행동 조합, `behavior_focus`, 공개된 과거 해결 이력에서 만든다.
5. AI는 계속 플레이어의 미확정 3/3/4 계획·숨은 배치·UI 의도 신호를 읽지 않는다.
6. 플레이어 전용 메타/정보 획득 효과를 적에게 억지로 적용하기 위한 적 전용 예외 규칙은 만들지 않는다. 이것은 동일 무공 기술 풀 원칙을 훼손하지 않는 역할별 시스템 경계다.

## 현행 10권 판정

현재 `data/cards/martial_manual_cards.json`에 등록된 10권 전체를 player-learnable shared martial pool로 분류한다. 현재 첫 Vertical Slice 시작 선택지는 이 중 6권이지만, 나머지 4권도 향후 적절한 획득 경로를 통해 플레이어가 배울 수 있어야 한다.

## 구현 경계

이번 bounded correction은 다음만 변경한다.

- shared-pool 구조화 metadata.
- opponent catalog의 player-learnable membership 회귀 테스트.
- AI 공정성 정본/Notion 설명.

변경하지 않는다.

- 기존 15명 상대 배정.
- 각 상대의 현재 mastery seed.
- 현재 martial card ID와 effect 값.
- 전투 판정/AI planner 알고리즘.
- 수치 밸런스.
- 신규 무공서/기술 생성.

## Evidence ceiling

현재 주장 가능:

- 현행 상대가 참조하는 `signature_manual_id`는 기존 10권 registry에 속한다.
- 현행 상대의 `available_manual_card_ids`는 해당 무공서의 동일 `MartialManualRegistry.build_unlocked_cards(manual_id, mastery)`에서 합법적으로 해금된다.
- 10권 전체를 player-learnable shared pool로 명시하고 AI 전용 무공서/기술을 금지한다.

현재 주장 불가:

- 첫 Vertical Slice 시작 선택지 밖 4권의 실제 플레이어 획득 콘텐츠가 이미 구현됨.
- Human fairness/fun PASS.
- Windows visible local / 실제 Android / 접근성 사용자 / Release performance PASS.

## 회귀 조건

다음 중 하나라도 발생하면 correctness defect다.

- opponent manual ID가 `player_learnable_manual_ids` 밖으로 나감.
- opponent card ID가 같은 manual/mastery의 shared registry unlock에 존재하지 않음.
- AI 전용 manual/technique flag를 허용함.
- AI가 비공개 플레이어 계획을 읽음.

이 Decision은 신규 제품 breadth 승인이 아니라 **기존 AI/무공 설계의 공정성 불변식 고정**이다.
