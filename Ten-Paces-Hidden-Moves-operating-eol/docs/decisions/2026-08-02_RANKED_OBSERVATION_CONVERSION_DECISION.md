# 랭킹전 관찰 의존 효과 변환 승인 결정

- Decision ID: `TEN-DEC-20260802-RANKED-OBSERVATION-CONVERSION-01`
- 승인일: 2026-08-02
- 상태: `CURRENT_APPROVED_PLANNING`
- 구현 권한: `PLANNING_ONLY`
- 선행 정본: `TEN-DEC-20260802-FULLRUN-CHAMPION-RANKED-01`

## 1. 승인 결정

공식 `[랭킹전]`에서는 양측 모두 기본 행동 `[관찰]`을 사용할 수 없다. 관찰량 획득·소비·관찰 후 발동을 전제로 한 무공·기술은 그대로 비활성화하거나 공식 랭킹에서 배제하지 않고, 사전에 정의한 **랭킹전 전용 공식 변환표**를 적용한다.

이 결정은 `docs/decisions/2026-08-02_FULL_RUN_CHAMPION_RANKED_DECISION.md`의 “관찰 의존 무공·기술의 랭킹전 호환 방식은 미확정” 표현을 대체한다.

## 2. 공식 변환 원칙

- 모든 사용자와 AI 등록본에 동일한 변환표를 적용한다.
- 변환 결과는 경기 시작 전에 양쪽 모두에게 공개한다.
- 등록된 `Champion Build Snapshot` 원본은 수정하지 않는다.
- 랭킹전 전투 인스턴스에서만 데이터 버전에 고정된 변환을 적용한다.
- 정보 공개·적 계획 노출·미확정 계획 읽기 효과로 변환하지 않는다.
- 즉석 보정, 상대별 가변 보정, AI 전용 특혜, 숨은 승률 보정을 금지한다.
- 변환 효과는 원본 효과의 역할과 예산을 보존하되 자원·방어·위치·반격 조건처럼 대칭 검증 가능한 효과로 치환한다.

## 3. 변환 분류

| 원본 관찰 역할 | 랭킹전 변환 방향 |
|---|---|
| 관찰량 획득 | 동일 예산의 공개 자원 획득·회복 또는 다음 행동 비용 보조 |
| 관찰량 소비 | 동일 예산의 공개 자원 소비형 방어·이동·반격 강화 |
| 관찰 후 반격 | 상대의 실제 공개 행동·거리·피격 같은 검증 가능한 조건부 반격 |
| 관찰 슬롯 증가 | 행동 슬롯을 늘리지 않고 해당 기술의 자원·위치·방어 효율 보정 |
| 적 행동 종류 공개 | 정보 공개 없이 공개 상태 기반 대비 효과로 변환 |

기술별 정확한 수치와 변환표는 온라인 전투 데이터 패키지에서 별도 승인한다. 변환 전후 효과 예산의 자동 검증과 사람 플레이 검증 없이는 구현 완료로 간주하지 않는다.

## 4. 모드 경계

- 본편·천하제일인전: 기존 플레이어 전용 `[관찰]` 계약 유지.
- 공식 랭킹전: 양측 `[관찰]` 사용 불가 + 공식 변환표 적용.
- 친선전·자가 비무의 `[관찰]` 허용 여부는 별도 결정 전까지 미확정이다.

## 5. GrillMe 병합 체크포인트 강화

이 결정은 `TEN-DEC-20260802-OBSERVATION-STATS-MASTERY-01`의 GrillMe 병합 운영 규칙을 다음처럼 강화한다.

- 이번 승인안을 포함해 아직 병합되지 않은 살아 있는 GrillMe 승인은 즉시 정본화·병합한다.
- 이번 병합 이후 승인 카운트를 `0/10`으로 초기화한다.
- 이후 철회·정정되지 않은 최종 승인 10건마다 GrillMe 질문을 중단하고 병합 체크포인트를 실행한다.
- 병합 직전 GitHub main·작업 브랜치·PR 변경 파일·권위 문서·planning JSON·연결 Google Sheet를 새로 읽는다.
- 적대적 검토 루프로 누락, 상충 Decision ID, 구형 참조, 중복 권한, 구현 범위 누출, Sheet/GitHub 불일치, 검증 과장을 확인한다.
- PR 전체 diff, changed files, unresolved review thread, review 상태, exact-head CI를 검사한다.
- P0/P1 누락·충돌, CI 실패, Sheet 미동기화, PR head 이동이 하나라도 있으면 병합하지 않는다.
- 병합은 검증한 exact head SHA로만 수행한다.
- 병합 후 main 정본과 Sheet를 재조회하여 같은 Decision ID와 최종 merge SHA를 기록한다.
- 런타임·Windows·네트워크·사람 검증은 실제 실행 증거 없이는 완료 처리하지 않는다.

## 6. 이번 체크포인트 계산

- PR #69 체크포인트 이후 승인된 10건은 PR #70으로 이미 병합됐다.
- 그 뒤 승인된 본 결정 1건을 사용자 지시에 따라 즉시 후속 병합한다.
- 이 후속 병합이 완료되면 다음 GrillMe 승인 카운트는 `0/10`에서 시작한다.

## 7. 미결정

- 기술별 정확한 랭킹전 변환표와 수치 예산
- 친선전·자가 비무에서 관찰 허용 여부
- 데이터 버전 변경 시 기존 등록본의 변환표 마이그레이션
- 변환 전후 밸런스 허용 오차와 시즌 중 핫픽스 정책

## 8. 검증·구현 경계

```yaml
work_mode: PLAN
runtime_implementation: PROHIBITED
online_service_implementation: PROHIBITED
product_code_changes: NONE
server_changes: NONE
automated_validation: STATIC_CONTRACT_ONLY
godot_runtime: NOT_RUN
windows_human: NOT_RUN
network_validation: NOT_RUN
demo_ready: false
```
