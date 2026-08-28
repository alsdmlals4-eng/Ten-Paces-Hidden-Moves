# TEN-DEC-20260828-OPENING-DISTANCE-RUNTIME-MAPPING-01

```yaml
decision_id: TEN-DEC-20260828-OPENING-DISTANCE-RUNTIME-MAPPING-01
status: APPROVED_CURRENT_IMPLEMENTATION_BINDING_REQUIRED
decision_date: 2026-08-28
approval_source: "user explicit: A.권장안대로 진행"
scope: OPENING_DISTANCE_RUNTIME_MAPPING
canonical_rule_owner: docs/02_COMBAT_RULES.md
human_facing_projection: Project Notion Home
runtime_mutation: NONE_IN_THIS_DECISION
implementation_evidence: NOT_RUN
human_player_evidence: NOT_RUN
```

## 결정

전투의 공개 시작 거리는 `2`다. 이후 구현은 시작 `CombatState`, 거리 계산, 공개 AI 입력, HUD, 접근성 이름, 전투 기록이 모두 그 하나의 공개 의미를 사용하게 만든다.

내부 좌표는 플레이어에게 두 번째 거리 규칙을 만들지 않는 기술 binding이다. 절대 좌표 쌍은 단일 구현계약에서 전장 경계, 점유, 이동, 사거리, AI 공정성, 기존 회귀를 함께 검증하며 정한다.

## 비교한 대안

| Alternative | Disposition | Reason |
| --- | --- | --- |
| A. 런타임을 공개 거리2에 맞춤 | `ADOPT` | 기획·UI·AI·로그가 한 공간 언어를 사용해 첫 판단을 보호한다. |
| B. 4/7 좌표는 유지하고 공개 거리만 별도 변환 | `REJECT` | 이중 공간 규칙이 디버그·표시·로그 drift를 만든다. |
| C. 정본을 거리3으로 변경 | `REJECT` | 현재 Player Promise·승인 UI·기획 정본을 불필요하게 다시 연다. |

## 보호·제외

- `3수 = 3슬롯`과 2슬롯 `[전조] → [실행]`은 변경하지 않는다.
- `행동계획 실행`의 계획→전투 해결 애니메이션 전환은 변경하지 않는다.
- AI의 비공개 플레이어 계획·UI 의도 미열람 경계는 변경하지 않는다.
- 이 Decision은 `data/`, `src/`, `scenes/`, `assets/`, `addons/`, `project.godot`을 변경하거나 제품 구현을 승인하지 않는다.

## 다음 조건

단일 구현계약은 다음을 수용 기준으로 가져야 한다.

1. 시작 상태, 거리 계산, 표시, 접근성 이름, 로그, AI 공개 입력이 공개 거리2에서 일치한다.
2. 내부 좌표 선택은 10칸 경계·점유·밀착·이동·사거리 회귀와 함께 검증한다.
3. 기존 4/7·거리3 fixture는 역사/legacy 증거로 보존하거나 명시적으로 갱신하며, 현행 제품 규칙처럼 남기지 않는다.
4. 자동 Godot 검증, Windows 가시 플레이, Human/Player·접근성·Android evidence를 서로 대체하지 않는다.
