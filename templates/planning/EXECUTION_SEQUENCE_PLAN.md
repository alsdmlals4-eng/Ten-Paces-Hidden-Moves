# 실행 순서 계획

## 작업 계약

```yaml
problem:
user_or_player_value:
work_mode:
primary_discipline:
affected_disciplines:
scope:
out_of_scope:
protected_paths_decisions_assets:
acceptance_criteria:
rollback:
```

## 단계

| ID | outcome | inputs | files | dependencies | output | acceptance | validation | rollback |
|---|---|---|---|---|---|---|---|---|

관계: `BLOCKS / INFORMS / USES_OUTPUT / SHARES_RESOURCE / VALIDATES / OPTIONAL_FOLLOWUP`

## 병렬 묶음

같은 파일·Schema·자산·결정 경계를 공유하면 병렬화하지 않는다.

## 게이트 실패·재계획

새 사실, 실패, 사용자 범위 변경, 정본 변경이 생기면 순서를 다시 계산한다.
