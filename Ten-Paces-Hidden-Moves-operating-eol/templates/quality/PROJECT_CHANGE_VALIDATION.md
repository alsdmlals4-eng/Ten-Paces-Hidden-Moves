# 프로젝트 변경 검증

## 판정

`ACCEPT / ACCEPT_WITH_FOLLOWUP / REVISE / REJECT / UNVERIFIED`

## 계약·diff

```yaml
baseline_branch_and_commit:
head_branch_and_commit:
approved_goal_and_scope:
protected_paths_decisions_assets:
changed_files:
out_of_scope_changes:
rollback:
```

## 정본·참조 최신성

```yaml
changed_canonical_sources:
changed_ids_paths_schema_policies:
known_consumers:
untouched_consumers_checked:
legacy_aliases_and_history:
derived_outputs_and_manifests:
tests_generators_workflows:
```

| 소비자·참조 | 기대 변경 | 실제 상태 | finding | 심각도 | 조치 | 증거 |
|---|---|---|---|---|---|---|

Finding: `STALE_REFERENCE / ORPHANED_REFERENCE / MISSING_PROPAGATION / CONFLICTING_SOURCE / DERIVATIVE_STALE / DUPLICATE_ACTIVE_SOURCE / ALLOWED_LEGACY / UNVERIFIED_DEPENDENCY`.

## 포맷·문법·정적 검사

## 자동 테스트

## 런타임·렌더·빌드

## 접근성

- 텍스트·대비·정보 채널
- 키보드·마우스·컨트롤러·포커스
- 시간·난이도·탐색·모션
- 대체 경로

장벽 심각도: `BLOCKING / MAJOR / MODERATE / MINOR`.

## 성능

- 목표 플랫폼·빌드
- baseline
- 대표·최악 장면
- frame time·CPU·GPU·메모리·네트워크·로딩
- 같은 조건의 변경 전후 capture

## 정상·실패·경계·반례·회귀

## 저장·불러오기·호환성

## 실제 수정·유지·삭제·보류

## 미검증·위험·후속 작업

실행하지 않은 검증은 `NOT_RUN` 또는 `UNVERIFIED`로 기록한다.
