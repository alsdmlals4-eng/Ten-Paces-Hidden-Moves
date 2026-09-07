# Native 2D 표현 단계 흡수 결정 · 2026-09-03

```yaml
decision_id: TEN-DEC-20260903-NATIVE-2D-PRESENTATION-PHASE-ABSORPTION-01
status: USER_APPROVED_CURRENT
decision_owner: repository_human_facing_canon
extends:
  - TEN-DEC-20260903-MODULAR-DUEL-UI-AND-PRESENTATION-MOTION-01
  - TEN-DEC-20260902-SCREEN-PARTITION-AND-DISTANT-FRONTAL-DUEL-01
work_mode: BUILD
current_source_relevance_check: CURRENT_OFFICIAL_AND_RUNTIME_CHECKED
feasibility: FEASIBLE_WITH_EXISTING_FULL_BODY_ART
```

## 작업 전 문제

현재 전신 전투원은 접지선·공통 `[합]` 앵커·공격/회피/막기/피격/절초의 짧은 표현 모션을 가졌지만, 동작 내부의 `전조 → 발동 → 회복` 단계를 명시하지 않았다. 따라서 새 연출이 기존 동작을 중단할 때의 현재 상태, 화면 검수용 스냅샷, 향후 파츠 분리 원화로의 확장 경계가 불명확했다.

사용자는 전문 2D 리깅 도구의 설치가 아니라 그 도구에서 검증된 **기능 원리만 현재 작업에 흡수**하도록 명시했다. 이 결정은 그 범위만 소유한다.

## 조사와 판정

| 후보 | 판정 | 이유 |
| --- | --- | --- |
| Spine 편집기·런타임·GDExtension | `REJECTED_NO_INSTALL` | 새 유료/외부 의존성과 라이선스·export 결합을 만들며, 사용자가 설치를 요청하지 않았다. 현재 원화도 리깅용 파츠가 아니다. |
| Godot `Skeleton2D`/`Bone2D` | `DEFERRED` | Godot 기본 기능이라 후일 분리 원화가 준비되면 별도 1인 실험에는 적합하지만, 현 전신 PNG에 억지로 적용하지 않는다. |
| 현재 `Tween` 기반 표현을 단계 상태기로 보강 | `ADOPTED` | 기존 승인 전신 원화와 실제 소비처를 보존하면서 전조·발동·회복, 중단, 접지 검수를 제공한다. |
| 파츠 분리·피벗·언더랩 원화 계약 | `SPECIFIED_FOR_FUTURE` | 이후 실제 파츠 원화를 만들 때 필요한 입력 규격이다. 이번에는 자산 교체나 신규 원화 제작을 하지 않는다. |

공식 근거:

- Spine의 Godot GDExtension 통합은 기능·배포 경계가 있으며, 일부 AnimationPlayer/C# 경로에는 별도 custom module/export template가 필요하다: <https://us.esotericsoftware.com/spine-godot>.
- 평가판만으로 runtime 통합·배포 권리가 생기지 않으며 유효 편집기 라이선스가 필요하다: <https://us.esotericsoftware.com/spine-editor-license>.
- Godot 자체 `Skeleton2D`/`Bone2D`는 파츠와 weight를 전제로 하는 기본 2D cutout 경로다: <https://docs.godotengine.org/en/stable/tutorials/animation/2d_skeletons.html>, <https://docs.godotengine.org/en/stable/tutorials/animation/cutout_animation.html>.

## 채택 구조

### 1. 표현 전용 단계 상태

`CombatCharacterPlaceholder`는 전투 규칙과 별도로 아래의 화면 전용 상태를 제공한다.

```text
motion_state: idle | move | attack | evade | block | hit | ultimate | clash
motion_phase: idle | windup | active | recovery
```

- 공격·절초: `windup → active → recovery → idle`.
- 회피·막기·피격: 즉시 반응이므로 `active → recovery → idle`.
- 이동: `active → recovery → idle`.
- `[합]`: 공통 충돌점까지의 접근은 `windup`, 접촉 정지는 `active`, 원래 자리 복귀는 `recovery`다.
- 새 표현 요청은 실행 중 Tween만 중단하고 새 `motion_sequence_id`로 교체한다. 전투 resolver, 거리, 자원, 기세, AI, 저장, 잠긴 계획에는 쓰거나 읽지 않는다.

`get_motion_snapshot()`은 상태·단계·순번·시각 offset/scale·수평 접지 여부만 내보낸다. 이 값은 runtime 검사와 향후 연출 소비처를 위한 것이며 게임 규칙 정본이 아니다.

### 2. 접지와 현재 전신 원화

현재 `USER_FINAL_LOCKED`인 v2 전신 PNG는 교체하지 않는다. 확대/축소의 피벗을 그림의 바닥 중심으로 옮겨, 스케일이 변해도 발 끝이 바닥선에서 떠 보이지 않도록 한다. 표현 offset은 수평만 사용한다.

### 3. 차후 파츠 원화 계약

다음 자산 생성이 실제로 필요해질 때만 별도 후보로 만든다. 한 장의 합성 PNG를 자동 분해하거나 기존 최종 잠금 원화를 덮어쓰지 않는다.

- 몸통·머리·앞/뒤 팔·무기·외투·장식의 독립 레이어와 충분한 언더랩.
- 각 파츠의 동일한 기준 캔버스, 골반 root, 발바닥 ground pivot, 손/무기 소켓.
- draw order, 부착/탈착 무기, 공격·회피·막기·피격·절초에서 필요한 표정/실루엣 상태.
- 내보낸 파츠가 실제 `Skeleton2D` 또는 동일 목적의 native 소비처를 가질 때만 구현한다.

## 기대 효과

- 현재 전신 원화의 그림체·최종 잠금을 보존한 채 공격과 절초가 준비 없는 순간이동처럼 보이는 문제를 줄인다.
- `[합]`과 반응 모션을 전투 결과와 분리해, 연출이 AI나 숨은 계획을 바꾸거나 누설하지 않는다.
- 다음 행동이 중간에 시작돼도 이전 Tween이 남아 캐릭터를 공중이나 오프셋 상태에 남기는 위험을 줄인다.
- 향후 정식 리깅·파츠 분리로 옮길 때 필요한 입력 규격과 교체 경계를 이미 분리한다.

## 검증 경계

기계 검증은 단계 순서, 중단 후 새 상태, 종료 시 원래 발 앵커 복귀를 검사한다. 화면 캡처는 `MACHINE_RUNTIME_CAPTURE`이며, 사람 미학·플레이 감각, Android 실기기, 접근성 사용자, 출시 성능, 외부 자산 권리는 별도 증거 없이는 `NOT_RUN`이다.
