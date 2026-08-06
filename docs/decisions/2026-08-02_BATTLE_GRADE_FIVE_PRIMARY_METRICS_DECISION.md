# 전투 종료 등급의 5개 핵심 지표 결정

- Decision ID: `TEN-DEC-20260802-BATTLE-GRADE-FIVE-METRICS-01`
- 승인일: 2026-08-02
- 상태: `CURRENT_APPROVED_PLANNING`
- 구현 권한: `PLANNING_ONLY`
- GrillMe 묶음: `8/10`

## 1. 승인 결론

전투 종료 `S/A/B/C` 성과 등급은 우선 아래 5개 지표를 핵심 입력으로 사용한다.

1. `[회피]` 성공 횟수
2. `[합]` 승리 횟수
3. 감소한 체력
4. 전투 라운드 수
5. 절초 사용 여부·횟수

정확한 가중치·정규화·최대점·등급 컷은 후속 밸런스 작업에서 확정한다.

## 2. 지표 의미

### 2.1 회피 성공 횟수

- 적의 유효 공격을 `[회피]`로 피한 사건을 기록한다.
- 피해와 회피로 무효화되는 부가효과가 모두 적용되지 않은 정상 회피를 성공으로 본다.
- 단순 회피 행동 사용 횟수가 아니라 실제 성공 횟수다.

### 2.2 합 승리 횟수

- 실제 `[합]` 승리 사건을 기록한다.
- 사거리 밖에서 합을 이겨 상대 공격을 취소한 경우도 합 승리 횟수에 포함한다.
- 연격·다단 공격에서는 기존 규칙대로 공격 행동당 절초기세 획득은 최대 +1이지만, 정확한 등급 산식의 합 승리 카운트 단위는 후속 데이터 계약에서 검증한다.

### 2.3 감소한 체력

- 플레이어가 전투 중 잃은 체력량을 기록한다.
- 적게 잃을수록 좋은 성과로 평가하는 방향이다.
- 최대 체력이 다른 빌드 사이의 공정성을 위해 절대량·최대 체력 대비 비율 중 어떤 정규화를 사용할지는 후속 확정한다.

### 2.4 라운드 수

- 승리까지 소요된 총 라운드 수를 기록한다.
- 적은 라운드가 일반적으로 유리하지만, 무조건 속전속결만 강제하지 않도록 상대·전투 슬롯별 기준 라운드 또는 완만한 감쇠를 후속 검토한다.
- 결착 압력으로 종료된 전투도 실제 종료 라운드를 기록한다.

### 2.5 절초 사용

- 전투 중 절초 사용 여부와 사용 횟수를 기록한다.
- 절초를 사용했다는 이유만으로 항상 가점할지, 적절한 사용·적중·승리 기여를 볼지는 후속 확정한다.
- 절초기세 획득량 자체는 별도 핵심 지표로 추가하지 않는다.

## 3. 이전 성과 체계와의 관계

기존의 아래 5개 점수 축은 전투 종료 등급의 현재 핵심 산식에서 제외한다.

- 위협 대응 30
- 전술 실행 25
- 자원 운용 15
- 피해 관리 15
- 공개 과제 15

기존 `S85 / A70 / B55 / C0` 경계도 새 5개 지표의 산식이 확정될 때까지 활성 기준으로 사용하지 않는다.

다음 선행 Decision의 전투 사건 정의는 유지하지만, 그 사건을 `위협 대응` 점수로 환산하는 조항은 이 Decision으로 대체한다.

- `TEN-DEC-20260802-OUT-OF-RANGE-CLASH-REWARD-01`
- `TEN-DEC-20260802-OUT-OF-RANGE-CLASH-GRADE-01`
- `TEN-DEC-20260802-CLASH-THREAT-ATTENUATION-01`
- `TEN-DEC-20260802-THREAT-ID-ACTION-01`
- `TEN-DEC-20260802-MULTIHIT-COMPLETE-PARRY-01`
- `TEN-DEC-20260802-COMPLETE-PARRY-HP-ONLY-01`

유지되는 내용:

- 합 승리·완전 파훼·부분 파훼·회피·밀치기 등의 전투 판정과 로그·복기 사건
- 절초기세와 `ON_CLASH_WIN`
- 사거리 안·밖 합 판정

보류되는 내용:

- 위협 대응 사건당 점수
- 같은 위협 100%→50%→0% 감쇠를 등급 점수에 적용하는 방식
- 위협 ID별 등급 점수 누적

필요하면 후속 성과 산식에서 5개 핵심 지표의 파밍 방지·정규화 규칙으로 다시 채택할 수 있으나 자동 승계하지 않는다.

## 4. 결과 화면

결과 화면은 최소 아래 원자료를 표시할 수 있어야 한다.

```text
회피 성공: N회
합 승리: N회
잃은 체력: N 또는 N%
전투 라운드: N
절초 사용: N회
최종 등급: S/A/B/C
```

세부 점수와 계산식을 공개할지는 후속 UX 결정으로 남긴다.

## 5. 미결정 경계

- 각 지표의 가중치와 최대점
- 절대값·비율·상대 기준 정규화
- 라운드 수의 적정 기준과 감쇠 곡선
- 절초 사용의 단순 사용·적중·승리 기여 판정
- S/A/B/C 경계
- 반복 합·회피 파밍 방지 방식
- 패배 전투의 등급 제공 여부

## 6. 구현·증거 경계

```yaml
authority_status: CURRENT_APPROVED_PLANNING
scope_status: POC_PRIMARY
implementation_status: NOT_STARTED
primary_metrics:
  - successful_dodges
  - clash_wins
  - player_health_lost
  - rounds_elapsed
  - ultimate_uses
legacy_weighted_categories_active: false
legacy_grade_thresholds_active: false
exact_weights: TBD
normalization: TBD
grade_thresholds: TBD
static_validation: PENDING_DRAFT_PR
runtime_validation: NOT_RUN
godot_validation: NOT_RUN
windows_validation: NOT_RUN
human_validation: NOT_RUN
grillme_count: 8/10
```
