# 십보강호 적 의도 합성 검증 종료·인계

```yaml
closure_id: TEN-PACES-SYNTH-CLOSURE-001
closed_at: 2026-07-29
validation_method: SYNTHETIC_TESTER_SIMULATION
evidence_tier: T6_AI_INFERENCE
synthetic_session_result: PROMISING_DIRECTION
human_validation: NOT_RUN
runtime_causality: NOT_RUN
actual_fun: NOT_RUN
product_code_changed: false
product_data_changed: false
canon_changed: false
implementation_authority: NONE
```

## 1. 완료된 계보

1. Evidence Pilot: `docs/decisions/2026-07-29_ENEMY_INTENT_EVIDENCE_PACK_PILOT.md`
2. 사람 검증 Artifact: `docs/superpowers/plans/2026-07-29-enemy-intent-human-validation-artifact.md`
3. 합성 구조 분석: `docs/research/2026-07-29_SYNTHETIC_TESTER_STRUCTURE_ANALYSIS.md`
4. 1차 합성 위험 검토: `docs/research/2026-07-29_ENEMY_INTENT_SYNTHETIC_TESTER_REPORT.md`
5. 교정된 Artifact 합성 세션: `docs/research/2026-07-29_ENEMY_INTENT_SYNTHETIC_SESSION_EXECUTION.md`

## 2. 최종 잠정 판정

유지할 방향:

- 공개 상태만 본 `pre_signal_plan`과 단서 후 `post_signal_plan` 분리.
- 행동명을 직접 번역하지 않는 자세·리듬·자원 변화 단서.
- 동일 공개 상태에 경쟁 hidden intent를 배정하는 `C-U / C-H` fixture.
- 주 가설과 차선 가설을 함께 유지하는 기록 계약.

남은 위험:

- `방어 → 간보기 → 반격` 같은 범용 3수 계획.
- 계획은 바꾸지 않고 설명만 단서에 맞추는 사후 합리화.
- 카드 결과 공개 순서를 학습해 hidden key를 추정하는 메타 대응.
- 실제 전투에서 단서 활용 계획이 결과 차이를 만드는지 미확인.

따라서 `PROMISING_DIRECTION`은 제품·전투 통과가 아니라 다음 정적 검증을 작성할 근거다.

## 3. 다음 진입점

```text
cue-informed plan
vs
cue-agnostic plan
→ 같은 공개 상태·같은 적 의도·같은 자원 조건의 정적 결과 행렬
→ 범용 계획의 기회비용 확인
→ runtime fixture 또는 결정적 seed가 생기기 전까지 인과 검증은 TEST_REQUIRED
```

권장 다음 문서 작업:

`AUTHOR_CUE_INFORMED_VS_AGNOSTIC_STATIC_OUTCOME_MATRIX`

이 작업은 연구용 비교표까지만 허용하며 v6 원장·AI 규칙·전투 데이터·Scene·Script를 변경하지 않는다.

## 4. 검증·통합 기록

- 실행 PR: #57
- 자동 검증: `PR Validation` 성공
- squash merge: `00c415b9f13715faae87040e635f1b1c9b999192`
- 최종 권한 branch: `main`
- 미해결 리뷰 스레드: 0

초기 오류 branch `gpt/enemy-intent-synthetic-session-20260729`에는 병합되지 않은 placeholder 이력이 있다. 해당 branch는 `ABANDONED_NOT_MERGED / NO_AUTHORITY`이며 어떤 문서·제품 판단의 근거로 사용하지 않는다.

## 5. 재개 시 금지

- 합성 페르소나를 실제 참가자 행동으로 기록하지 않는다.
- `PROMISING_DIRECTION`을 `VALIDATED`, `PLAYTEST_PASSED`, `CORE_LOOP_PROVEN`으로 바꾸지 않는다.
- 실제 fixture·seed 없이 scripted hidden intent를 runtime 사실로 주장하지 않는다.
- 사용자 승인 없이 구현·정본·제품 데이터를 변경하지 않는다.
