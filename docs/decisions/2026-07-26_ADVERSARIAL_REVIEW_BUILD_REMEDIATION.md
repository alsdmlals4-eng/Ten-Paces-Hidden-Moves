# 적대적 검토 승인안 BUILD 교정 기록

- 날짜: 2026-07-26
- 흐름: `REVIEW → 승인된 최소 BUILD → REVIEW`
- 대상: PR #45 planning 정본·Schema·validator·회귀 테스트
- 제품 런타임: 변경 없음
- Godot·Windows·사람 검증: `NOT_RUN / UNVERIFIED`

## 사용자 결정

1. 패배 시 전투 직전 `RunState` 복원 재도전.
2. 같은 전투 재도전 비용 `[영구재화]` 1→2→3, 3 상한, 다른 전투 진입 시 초기화.
3. `[필중]`은 스택형이며 실제 회피를 우회한 유효 타격마다 1스택 소비.
4. 주요 비무 보상은 자유6 / 지정 무공5+자유3 / 문파 무공3성.
5. 주요 비무5 진입 전 10성 경로는 집중32+노드6 또는 자유24+고효율 노드14.

## 최소 BUILD

- `poc_balance_budget.json`: effect condition·필중 스택·patch 허용 필드와 tick 정책.
- `poc_martial_arts.json`: 정규화 card contract, 중앙 tick ledger, patch 재계산, 습득·중복 계약, canonical pretty-print.
- `poc_enemy_duels.json`: option set 참조, AI score/weight/modifier/3수 template/fallback.
- `poc_map_rewards.json`: 보상 3선택, stable node catalog, 네 구간 최소·목표 수련 공급, 성과 산식.
- `poc_run_state_contract.json`: 회차/전투 상태·snapshot·승리 commit·유료 재도전.
- `poc_sanity_model.json`: 32+6과 24+14 성장 경로.
- `tools/check_poc_planning_data.py`: CE-01~08과 신규 계약 검증.
- `tests/test_poc_planning_data.py`: 24개 정상·실패·경계·회귀 테스트.

## 정적 검증

```text
python -m unittest tests.test_poc_planning_data -v
→ 24 tests / PASS

python tools/check_poc_planning_data.py --root .
→ PoC planning data: PASS
```

## REVIEW 복귀 경계

- 원격 CI·reference freshness·governance·기존 전투 계약 검사를 다시 실행한다.
- 제품 경로 미변경과 main 동기화를 확인한다.
- 실행하지 않은 runtime·Godot·Windows·접근성·성능·사람 검증은 `BLOCKED_UNVERIFIED`로 유지한다.
- 최종 판정은 `PASS_WITH_FOLLOWUP` 또는 `REVISE_AGAIN`으로 기록하며 사용자의 `검수 완료`를 대신하지 않는다.
