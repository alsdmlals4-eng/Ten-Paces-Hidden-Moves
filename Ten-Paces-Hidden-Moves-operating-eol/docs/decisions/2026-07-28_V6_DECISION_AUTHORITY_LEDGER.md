# 십보강호 v6 전체 결정 권한 원장

- 최초 작성일: `2026-07-28`
- 현재 역할: `HISTORICAL_DECISION_INDEX_WITH_LATEST_OVERRIDES`
- 현재 제품 단계: `VERTICAL_SLICE_APP_FLOW_PLANNING`
- 현재 Work Mode: `REVIEW`
- 현재 구현: `ACTION_SELECTION_DOCK_IMPLEMENTED_PR65`
- 사람 검증: `NOT_RUN`

이 원장은 2026-07-28 v6 결정과 당시 적대적 검토를 연결한다. 2026-07-31·2026-08-01의 최신 사용자 승인 Decision이 같은 질문을 갱신한 경우 최신 Decision이 우선한다.

## 1. v6 원장 구성

1. [Part 1A — 권한·코어·강호행·라운드·합](2026-07-28_V6_DECISION_AUTHORITY_LEDGER_PART1A.md)
2. [Part 1B — 전조·비용·중첩·자동 발동·기초 행동·관찰](2026-07-28_V6_DECISION_AUTHORITY_LEDGER_PART1B.md)
3. [Part 2 — 태그·방어도·무공서·성장·수련·랭크](2026-07-28_V6_DECISION_AUTHORITY_LEDGER_PART2.md)
4. [Part 3 — 절초 공통 계약·예산·메타·폐기안·구현 사실](2026-07-28_V6_DECISION_AUTHORITY_LEDGER_PART3.md)

Part 문서는 v6 당시 결정의 고유 ID·근거·연결 프로필을 보존한다. 현재 상태·구현 완료·후속 작업은 `ACTIVE_CONTEXT.md`가 소유한다.

## 2. 최신 Decision Override

| 질문 | 최신 현재 Decision | v6 원장 처리 |
|---|---|---|
| 공격·막기·연격 합·방어도·중단 | `TEN-DEC-20260731-COMBAT-ROUTE-01` | 관련 세부값 갱신 |
| 데모 5전·전체 10전·노드 수·천하제일인 | `TEN-DEC-20260731-COMBAT-ROUTE-01` | 구형 2~3노드·방문 수 대체 |
| 슬롯별 후보 3명·seed 선정·경로 종착점 | `TEN-DEC-20260731-PROCEDURAL-DUEL-POOL-01` | 고정 상대·고정 경로 대체 |
| 슬롯 3 거리·보법 학습 | `TEN-DEC-20260731-SLOT3-DISTANCE-01` | 신규 확장 |
| 1~3수 계획 편집 | `TEN-DEC-20260731-PLAN-EDITOR-01` | 제품 UX 구체화 |
| 해결·결정적 복기 | `TEN-DEC-20260731-COMBAT-REVIEW-01` | 제품 UX 구체화 |
| 무공서→해금 기술→수 자동 배치 | `TEN-DEC-20260801-MARTIAL-TECHNIQUE-UX-01` | 구현까지 승격 |
| 필수 화면·제품 흐름·Scene 소유권 | `TEN-DEC-20260801-SITUATION-SCREEN-01` | Vertical Slice 다음 단계 확정 |

최신 Decision 경로는 `[기획서]/00_프로젝트_허브/DOCUMENTATION_MAP.md`가 연결한다.

## 3. 현재 유지되는 코어

- 1대1 10칸 일자형 전장.
- 거리 0 `[밀착]`.
- `3수 → 해결 → 3수 → 해결 → 4수 → 해결`.
- 공개 상태·해결 이력 기반 상대 읽기.
- 미확정 플레이어 계획을 AI가 읽지 않음.
- 덱·손패·드로우·장착 기술 제한 없음.
- 거리·합·방어도·회피·중단·강건·복기.
- 성장은 판단을 대체하지 않고 파훼 선택지를 확장.

## 4. 현재 구현된 최신 결정

`TEN-DEC-20260801-MARTIAL-TECHNIQUE-UX-01`:

- `[기초] [무공] [절초]` 행동 선택.
- 무공서→현재 해금 기술.
- 가장 앞 유효 연속 수 자동 배치.
- `[전조] → [실행]` 연결 블록.
- 진행 전 이동·제거.
- 절초기세 예약·환불·재예약.
- 제품 P0의 가상 `준비+막기/회피` 제외.

자동 검증은 통과했으며 Windows 실제 Godot·사람 검증은 `NOT_RUN`이다.

## 5. 승인된 다음 제품 흐름

`TEN-DEC-20260801-SITUATION-SCREEN-01`:

```text
MAIN
→ RUN_SETUP
→ ROUTE
→ NODE
→ DUEL_BRIEFING
→ COMBAT
→ REVIEW
→ RESULT
→ REWARD_OR_RETRY
```

전체 화면 흐름의 런타임은 아직 시작하지 않았고 다음 패키지는 `VERTICAL_SLICE_APP_FLOW_SHELL`이다.

## 6. 대체·폐기·보류

### `SUPERSEDED`

- PR #45의 과거 BUILD 승인 선언.
- 고정형 연교→묵진 상대·경로 권한.
- 구형 2~3노드·13~17개 방문 계약.
- 무공서 직접 배치·평면 손패 표현.
- 다중 수 기술을 중복 카드로 표시하는 모델.

### `[보류] / DEFERRED`

- 16개 개별 절초 설계.
- 주요 비무 6~10 런타임.
- 천하제일인·비동기 기능.
- 최종 아트·오디오 폴리싱.

`[보류]`는 런타임 구현 입력에서 제외한다.

## 7. planning JSON 경계

`docs/planning-data/*.json`은 승인 내용을 구조화해 연결하지만 직접 런타임 권한은 갖지 않는다. 실제 런타임은 `data/`, `src/`, `scenes/`, `tests/`와 검증된 adapter가 책임진다.

## 8. 검증 경계

이 원장의 최신화는 다음을 의미하지 않는다.

- 전체 제품 화면 흐름 구현 완료.
- Windows 실제 Godot 사용성 통과.
- 게임패드·화면 읽기 도구 통과.
- 성능·최종 렌더 통과.
- 사람 플레이·재미 통과.
- 후보 15명 콘텐츠 완료.

실행하지 않은 검증은 `NOT_RUN`이다.
