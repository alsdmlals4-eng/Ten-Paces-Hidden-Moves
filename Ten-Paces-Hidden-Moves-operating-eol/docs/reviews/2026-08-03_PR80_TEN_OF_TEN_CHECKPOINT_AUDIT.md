# PR #80 10/10 기획 체크포인트 적대적 감사

- Audit ID: `TEN-AUD-034`
- 감사일: 2026-08-03
- 대상 PR: `#80`
- 기준 head 소유권: `PR #80 metadata + Google Sheet checkpoint row`
- 승인 누적: `10/10`
- 상태: `FINAL_VALIDATION_IN_PROGRESS`
- 제품 코드 변경: 없음

## 1. 감사 목적

이번 승인 묶음의 Decision·planning JSON·중앙 책임 문서·Google Sheet가 같은 의미를 가지는지 확인하고, 구형 문구·중복 권위·무단 런타임 구현·검증 과장·미승인 수치 유입을 병합 전에 차단한다.

tracked 문서 안에 자신의 최종 commit SHA를 직접 기록하지 않는다. 최종 exact head는 PR metadata와 Google Sheet 체크포인트 행이 소유하며, 병합 직전에 다시 읽어 고정한다.

## 2. 이번 10개 승인

1. `TEN-DEC-20260802-BASIC-ATTACK-FORMULAS-SLOT-BUDGET-01`
2. `TEN-DEC-20260802-RANGE-PRICE-BANDS-01`
3. `TEN-DEC-20260802-BASIC-PALM-DAMAGE-GROWTH-01`
4. `TEN-DEC-20260802-STARTING-STAT-ALLOCATION-FIVE-01` — 후속 Decision으로 대체된 역사 승인
5. `TEN-DEC-20260802-STARTING-STAT-TOTAL20-MANUAL-BONUS-01`
6. `TEN-DEC-20260802-STARTING-TECHNIQUE-PRIMARY-STAT4-01`
7. `TEN-DEC-20260802-STARTING-TECHNIQUE-SOFT-GUARANTEE-01`
8. `TEN-DEC-20260802-EVEN-STAR-STAT-ESCALATION-01`
9. `TEN-DEC-20260803-UNCAPPED-CORE-STATS-01`
10. `TEN-DEC-20260803-STAR7-TECHNIQUE-PRIMARY-STAT8-01`

## 3. 정본 동기화 범위

다음 중앙 책임 원본을 이번 Decision과 일치하도록 교정했다.

- `docs/01_GAME_DESIGN.md`
- `docs/02_COMBAT_RULES.md`
- `docs/04_ROADMAP.md`
- `docs/05_COMBAT_POC_SPEC.md`
- `docs/06_STARTING_FACTION_MASTERY_DATA.md`
- `[기획서]/00_프로젝트_허브/ACTIVE_CONTEXT.md`

해결한 구형 표현:

- 장풍은 속공보다 반드시 낮은 저위력 공격이라는 표현
- 속공·강공·장풍 공식이 `TBD`라는 표현
- 시작 총점·자유 분배가 미확정이라는 표현
- 핵심 스테이터스 `1~15`가 하드캡이라는 표현
- 2·4·6·8성 지급량이 미확정이라는 표현
- 7성 기술 요구치가 미확정이라는 표현
- 현재 승인 카운트가 0/10 또는 8/10이라는 활성 상태 표현

Google Sheet에는 Decision10·Audit34·핵심 시스템·성장 경제·변경이력과 `10/10_PENDING_MERGE` 상태를 기록한다. 마지막 tracked-file commit 뒤의 exact head로 교정하고 readback한다.

## 4. 7성 요구치 적대적 판정

7성 직전 무공 자체 성장만으로 주 능력치 최소6에 도달한다. 요구치8은 다음 특성을 가진다.

- 숙련도만으로 자동 해금되지 않음
- 추가 영구 투자2점이 필요함
- 보조 능력치 이중 Gate가 없음
- 미달 시 기술만 잠기고 무공 수련과 기존 보상은 유지됨
- 영구 주 능력치8 도달 시 자동 활성화됨
- 임시 능력치 감소로 재잠금되지 않음

판정: `KEEP_WITH_HUMAN_VALIDATION`.

잔여 위험:

- 같은 주 능력치 무공 시너지로 요구치가 쉽게 충족되는 조합과 어려운 조합의 격차
- 높은 능력치가 잘못된 거리·순서 계획을 피해량으로 덮는 현상
- 시작/성장 UI에서 잠금 원인과 자동 활성 조건이 불명확해지는 현상

이 위험은 하드캡이나 추가 보조 요구를 즉시 도입하지 않고 사람 검증과 후속 개별 무공 설계에서 측정한다.

## 5. 병합 가능한 범위와 금지 범위

이번 PR에서 허용:

- Decision 문서
- approved planning JSON
- 중앙 기획 책임 원본
- 적대적 감사·벤치마킹 절차
- Google Sheet 기획 원장 동기화

이번 PR에서 금지:

- 제품 코드·Scene·런타임 데이터 변경
- 10성 절초 요구치 추정
- 무공별 보조 능력치 매핑 추정
- 중간 노드 영구 스테이터스 보상량 추정
- 전투 종료 등급 산식 추정
- Godot·Windows·사람 검증 PASS 주장

## 6. 남은 후속 항목

다음 승인 묶음에서 순서대로 검토한다.

1. 10성 절초 요구치
2. 무공별 보조 능력치 매핑
3. 중간 노드 영구 스테이터스 보상 정책
4. 고능력치 공식·핵심 재미 사람 검증
5. 전투 종료 등급 가중치·정규화·파밍 방지

## 7. 최종 병합 Gate

다음을 모두 충족해야 병합 가능하다.

- Google Sheet Decision10·Audit34·변경이력과 exact head 동기화·readback
- PR 전체 diff에서 제품 코드·런타임 데이터 변경 없음
- 중앙 책임 문서에서 활성 구형 표현 없음
- PR Validation·Full Validation·Base v9 Adoption exact-head PASS
- main 대비 behind0
- 미해결 리뷰 스레드0·제출 리뷰 충돌0
- 병합 직전 head 고정 확인
- squash merge 후 main·Sheet 재조회
- 후속 상태 동기화에서 승인 카운트0/10 재설정

```yaml
audit_id: TEN-AUD-034
approval_count: 10/10
exact_head_source: PR_METADATA_AND_SHEET
p0_findings: 0
sheet_sync: COMPLETE_PENDING_FINAL_HEAD_READBACK
runtime_changed: false
runtime_validation: NOT_RUN
godot_validation: NOT_RUN
windows_validation: NOT_RUN
human_validation: NOT_RUN
merge_allowed_before_final_gate: false
```
