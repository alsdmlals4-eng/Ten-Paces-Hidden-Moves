# 십보강호 스킬 학습 기록

의미 있는 스킬 호출의 결과·실패·중요 결정·검증과 스킬 변경 필요를 기록한다. 사소한 성공은 기록을 강제하지 않으며 실제 근거 없이 스킬 본문을 갱신하지 않는다.

## 기록 형식

```yaml
date:
work_item:
skill_id:
trigger:
scope:
result: success/partial/failure/not-run
verification:
exceptions:
user_feedback:
learning_state: observation/hypothesis/pattern/verified
skill_change: none/proposed/applied
reason:
```

## 2026-07-20 — Base schema v3 마이그레이션

```yaml
date: 2026-07-20
work_item: Issue #4
skill_id: project-operations-and-handoff
trigger: base-migration, cold-start
scope: 원격 문서 저장소의 비파괴 Governance foundation
result: partial
verification:
  - Base 최신 START_HERE·마이그레이션 Method·Skill·schema v3 템플릿 대조
  - 대상 원격 main 구조와 기존 11개 본책 대조
exceptions:
  - 사용자 Windows 작업본 미마운트
  - gh CLI와 일반 네트워크 clone 사용 불가
  - Godot·PDF·Actions 미실행
user_feedback: Base 전체 구조와 기획에 따른 정리·최신화·갱신 요청
learning_state: observation
skill_change: applied
reason: 프로젝트 전용 최소 Registry·Handoff·Gates 계약을 신규 설치함
```

### 관찰

- 기존 문서의 제품 책임은 비교적 명확하지만 운영체계·Registry·발행 상태가 분리돼 있지 않았다.
- 최신 Base에서는 프로젝트 교훈의 자동 승격보다 제안 PR·사용자 승인·별도 구현 PR이 우선한다.
- 문서 전용 원격과 Windows Godot 작업본이 분리됐을 가능성이 있어 원격만으로 구현 상태를 판정하면 안 된다.

### 변경 없음

- 게임 규칙·밸런스·절초 기세 값은 이번 운영체계 마이그레이션에서 변경하지 않는다.
- 실제 반복 검증이 없으므로 신규 스킬의 지식 상태를 `VERIFIED`로 올리지 않는다.
