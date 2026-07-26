# 십보강호 세션 인수

## 현재 상태

```yaml
phase: BUILD_IN_PROGRESS
planning: USER_CONFIRMED_COMPLETE
review: USER_CONFIRMED_COMPLETE
adversarial_review: COMPLETE
review_decision: PASS_WITH_FOLLOWUP
implementation_authorization: GRANTED
implementation_plan: AUTHORED
technical_baseline_sha: 659c57e7ffa588ad6a6471ed9b5394985b159eaf
main_baseline: 48c26c02d53fe49a34b831f5bcf0924ae36f5dbd
planning_review_branch: agent/poc-planning-baseline-and-legacy-audit
implementation_branch: codex/p0-poc-runtime-foundation
project_core: CORE_CONFIRMED
runtime: IMPLEMENTED_LEGACY
new_poc_runtime_implementation: NOT_STARTED
asset_search_generation_integration: NOT_STARTED
static_planning_tests: PASS_24
human_validation: UNVERIFIED
t1_greenlight: NOT_GRANTED
```

최신 PR head와 CI는 PR #45 본문·Actions를 추적 원장으로 사용한다.

## 단계 전환

2026-07-26 사용자가 정확히 `검수 완료`를 선언했다. REVIEW 게이트는 종료됐고 승인된 PoC의 Codex 구현 인계가 허용됐다. 이 승인은 런타임 구현 완료, PR 병합, T1 진입을 의미하지 않는다.

결정 기록: `docs/decisions/2026-07-26_REVIEW_COMPLETE_AND_BUILD_ENTRY.md`.

## 반드시 읽을 파일

1. `docs/decisions/2026-07-26_POC_PLANNING_BASELINE.md`.
2. `docs/decisions/2026-07-26_FULL_ADVERSARIAL_REVIEW_LOOP.md`.
3. `docs/decisions/2026-07-26_REVIEW_COMPLETE_AND_BUILD_ENTRY.md`.
4. `docs/02_COMBAT_RULES.md`.
5. `docs/planning-data/README.md`와 JSON 6종.
6. `docs/05_COMBAT_POC_SPEC.md`.
7. `docs/08_TEST_CHECKLIST.md`.
8. `docs/superpowers/specs/2026-07-26-ui-ux-audio-asset-pipeline-design.md`.
9. 아래 구현계획 4종.
10. PR #45 최신 본문·댓글.

## 구현계획

- 프로그램: `docs/superpowers/plans/2026-07-26-poc-implementation-program.md`.
- 런타임 기반: `docs/superpowers/plans/2026-07-26-poc-runtime-foundation-implementation-plan.md`.
- 캠페인·성장: `docs/superpowers/plans/2026-07-26-poc-campaign-progression-implementation-plan.md`.
- UI·사운드·에셋: `docs/superpowers/plans/2026-07-26-poc-ui-audio-assets-implementation-plan.md`.

## 구현 순서

```text
1. branch·worktree·baseline
2. planning→runtime adapter
3. RunState·유료 재도전
4. 새 수치·연격·효과·필중·AI·event stream
5. REVIEW
6. 주요 비무1~5·노드·보상·성장·등급
7. REVIEW
8. UI/audio event matrix·asset gap map
9. 최신 에셋 검색·라이선스 감사
10. 부족분 생성·Godot 통합
11. REVIEW·Full Validation·Windows·STEP 14
```

## 핵심 사용자 결정

- 전투 패배 시 전투 직전 `RunState`와 같은 seed로 재도전.
- 같은 전투 영구재화 비용 1→2→3, 상한 3, 다른 전투 진입 시 초기화.
- `[필중]`은 실제 회피 우회 유효 타격마다 1스택 소비.
- 주요 비무 보상은 자유6 / 지정5+자유3 / 문파 무공3성.
- 주요 비무5 전 10성은 집중32+노드6 또는 자유24+고효율 노드14.
- UI·UX·사운드는 컨셉 정의 → 에셋 검색 → 부족분 생성 → 통합 검증.

## 첫 실행 행동

```bash
git fetch origin
git worktree add ../Ten-Paces-Hidden-Moves-p0 -b codex/p0-poc-runtime-foundation origin/agent/poc-planning-baseline-and-legacy-audit
cd ../Ten-Paces-Hidden-Moves-p0
python -m unittest tests.test_poc_planning_data -v
python tools/check_poc_planning_data.py --root .
godot --headless --path . --quit
```

기준선이 통과하면 `tests/verify_p0_runtime_adapter.gd`의 RED부터 시작한다.

## 금지

- planning JSON을 adapter 없이 runtime에서 직접 읽기.
- T0 개발용 `restart_combat()`과 유료 재도전을 같은 기능으로 구현.
- `[필중]`을 행동 전체 무제한 또는 취소 타격에서 소비.
- 주요 비무 중앙 보상과 적별 보상을 중복 지급.
- 주요 비무6~10·스테이지2·3·히든 선제 구현.
- 외부 에셋에 맞춰 전투 정보 구조 변경.
- 출처·라이선스 불명 에셋 사용.
- 사람 증거 없이 재미·밸런스·T1 통과 주장.
- BUILD 구간 종료 후 REVIEW 복귀 생략.
