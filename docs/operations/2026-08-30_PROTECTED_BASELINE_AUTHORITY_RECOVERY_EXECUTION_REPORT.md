# 2026-08-30 · Protected Baseline Authority Recovery · Execution Report

```yaml
baseline_main: cde527a9c7e08ff09002f875966c7a0ba565e9f9
branch: codex/repair-protected-baseline-authority-20260830
work_mode: BUILD_TO_REVIEW
user_authorization: "2026-08-30 user explicit: 앞으로 자동으로 복구해, 작업 진행해"
skill_modes:
  - ten-paces-hidden-moves-workflow-router: verify
  - auditing-canonical-reference-freshness: impact-map/reference-scan/derivative-freshness/propagation-gap
  - reviewing-and-validating-project-changes: contract-check/reference-freshness/static-validation/regression/evidence-report
  - running-adversarial-review-and-refinement: attack/validate-critique/refine-approved-findings/regression-recheck/decision-report
product_mutation: NONE
protected_product_path_mutation: NONE
asset_mutation: NONE
notion_mutation: NONE
incremental_cost: ZERO
```

## 작업 전 문제

최신 `origin/main`은 `cde527a9c7e08ff09002f875966c7a0ba565e9f9`였지만, 정본 Adapter의 `protected_baseline.commit`은 조상 커밋 `afa152b985975a3f8e6292ca0298d22a95c03872`를 유지했다. 기존 표기 `FIRST_MIGRATION_LEGACY_SOURCE`는 Base validator가 원격 기준선과 **완전 동일**하다고 요구하게 만들어, 보호 경로를 수정하지 않은 문서 병합 뒤에도 스스로 실패하는 상태였다.

## Current-source relevance와 구현 가능성

| 항목 | 실제로 읽은 근거 | 판정 | 한계 |
| --- | --- | --- | --- |
| 현재 Base가 조상 기준선을 안전하게 지원하는가 | 최신 Base `tools/base_release_index.py`의 `_install_protected_baseline_ancestry`, `tests/test_project_protected_baseline_authority.py` | `FEASIBLE` — 정본 Adapter source일 때만 조상 검증을 허용하며, 누락·분기·명시 override는 fail-closed다. | Base 지원은 Windows/Android/Human 증거가 아니다. |
| 프로젝트 기준선이 실제 조상인가 | `git merge-base --is-ancestor afa152b... origin/main` | `FEASIBLE` — 결과 `TRUE`. | 원격 ref는 후속 병합마다 다시 fresh-read해야 한다. |
| 외부 공식/시장/플랫폼 조사가 결론을 바꾸는가 | 이 작업은 repository-local Base validator와 JSON provenance만 변경한다. | `NOT_APPLICABLE` — 외부 표준·시장·권리·엔진 기능 선택이 없다. | 외부 조사를 실행하지 않은 사실을 외부 사실로 대체하지 않는다. |

## 조사·비교와 채택

| 대안 | 장점 | 치명적 한계 | 판정 |
| --- | --- | --- | --- |
| 매 병합 뒤 `protected_baseline.commit`을 최신 `main`으로 다시 올린다 | 변경이 작고 과거 관행과 같다. | 병합 자체가 다음 불일치를 만들므로 반복 복구와 회귀가 필연이다. | `REJECT` |
| legacy source 표기를 유지하고 Base checker를 프로젝트별로 우회한다 | 기존 JSON 의미를 유지한다. | 최신 Base가 제공하는 fail-closed 경계를 약화하거나 Base 소유 코드를 프로젝트에서 복제하게 된다. | `DEFER_TO_BASE_OWNER` |
| 정본 Adapter source를 명시하고 현재 Base의 조상 검증을 사용한다 | 역사 기준선에서 보호 경로 diff를 계속 계산하면서, 비보호 후속 병합 때문에 자기 실패하지 않는다. | source type/path와 모든 generated view의 해시를 함께 갱신해야 한다. | `ADOPTED` |

## 실제 변경

- `skills/PROJECT_BASE_ADAPTER.json`의 보호 정책 source를 정본 `skills/PROJECT_BASE_ADAPTER.json`과 `CANONICAL_ADAPTER_SOURCE`로 승격했다.
- 최신 Base `build_project_operating_artifacts.py --write`로 `BASE_V9_ADAPTER`, `PROJECT_BASE_SKILL_ADAPTER`, `PROJECT_SKILL_SNAPSHOT`, Dashboard를 재생성했다.
- 같은 source downgrade 또는 생성 뷰 해시 누락을 막는 `tests/test_canonical_adapter_protected_baseline_authority.py`를 추가했다.
- CI workflow는 이제 Adapter 파일의 변경 여부가 아니라 실제 `protected_baseline.commit`의 변경 여부로 PR base와 historical baseline을 구분한다. 이를 `tests/test_approved_protected_change_workflow.py`가 회귀 검사한다.
- 전체 Python suite에서 이번 branch 이전 `cde527a9...`에도 동일하게 재현된 세 가지 정합성 실패를 현재 정본에 맞게 복구했다. GitHub Actions의 현재 hosted-runner 정책을 검사하도록 fallback test를 고쳤고, repository-only current-truth owner를 검사하도록 resource saturation validator와 regression을 동기화했으며, 역사 계약 파일의 byte-exact 검증은 Windows checkout 줄바꿈 대신 Git `HEAD` blob을 읽도록 변경했다.
- Base reference-freshness scanner가 삭제된 Skill literal을 **금지 목록 그 자체**와 2026-08-28 historical incident report에서 오인하던 두 경로는 `allowed_legacy_globs`의 정확한 두 항목으로만 허용했다. 나머지 506개 스캔 파일과 모든 legacy alias 검사는 계속 fail-closed다.
- `data/`, `src/`, `scenes/`, `assets/`, `addons/`, `project.godot`와 모든 전투 규칙·저장·GDD·자산은 변경하지 않았다.

## TDD와 검증 증거

| 단계 | 명령 / 관찰 | 결과 |
| --- | --- | --- |
| RED | `python tests/test_canonical_adapter_protected_baseline_authority.py` | 예상대로 `FIRST_MIGRATION_LEGACY_SOURCE` 때문에 실패. |
| 최소 수정 | 정본 source type/path 변경 후 Base 생성기 실행 | 4개의 generated artifact가 갱신됨. |
| GREEN | `python tests/test_canonical_adapter_protected_baseline_authority.py` | PASS. |
| 원래 실패 반례 | `python Base/tools/check_project_operating_contract.py --project-root . --base-repository Base --check`의 동등한 절대 경로 실행 | PASS. |
| 파생본 | `python Base/tools/build_project_operating_artifacts.py --project-root . --base-repository Base --check`의 동등한 절대 경로 실행 | PASS. |
| 고정 CI validator | workflow와 같은 Base `2828a74f...`의 `check_approved_project_operating_contract.py --protected-base afa152b... --check` | PASS. metadata-only Adapter migration은 PR base가 아닌 historical baseline을 선택함을 실제 실행으로 확인. |
| 인접 회귀 | 프로젝트 운영 계약·Base shared adapter·v9.4.3 adoption 및 Base protected-baseline authority tests | PASS. |
| 전체 Python suite | `python -m unittest discover -s tests -v` | **419 tests PASS**. candidate 전용 recovery regression을 포함하며 failure/error 없음. |

`check_canonical_reference_freshness.py --base cde527a9... --head ce222a1...`는 처음 `REFERENCE FRESHNESS CHECK: FAIL`을 반환했다. 비교 결과 두 문자열은 모두 baseline `cde527a9...`에 이미 있었고 이번 diff에는 없다.

- `.github/reference-freshness.json`의 `forbidden_active_paths`는 삭제된 Skill 경로를 **탐지하기 위해** 그 literal을 보유한다.
- `docs/operations/2026-08-28_ADVERSARIAL_RESEARCH_FEASIBILITY_GATE_EXECUTION_REPORT.md`는 같은 false positive를 historical incident로 보존한다.
- RED→GREEN: `tests.test_project_governance...allowlist_is_historical_and_scoped`를 먼저 실패시킨 뒤 두 exact path만 config에 추가했다. 최종 Base scanner는 `REFERENCE FRESHNESS CHECK: PASS` (`scanned_files: 506`, `legacy_aliases: 14`, `changed_files: 9`)를 반환했다.
- 판정: `ALLOWED_LEGACY / SCOPED_FALSE_POSITIVE_RECOVERED`. checker 또는 project 규칙을 약화하지 않았고, 이번 recovery의 활성 consumer 누락은 별도 검색과 generated-artifact check로 닫았다.

baseline `cde527a9...`과 candidate 양쪽에서 동일한 full-suite failures를 재현한 뒤, 각 failure의 실제 current owner를 fresh-read했다.

| 실패 계열 | 기준선의 실제 원인 | 복구 | 회귀 증거 |
| --- | --- | --- | --- |
| GitHub Actions budget fallback | 테스트가 superseded PR107 manual fallback field를 current reconciliation JSON에 요구했다. | 현재 `STANDARD_GITHUB_HOSTED_RUNNER_REQUIRED`, `HISTORICAL_PR107_ONLY_SUPERSEDED_FOR_FUTURE_HEADS`, `PASS_EXACT_HEAD_HOSTED_PR109`을 검사하고 과거 marker는 historical decision에서만 확인한다. | `tests.test_actions_budget_manual_validation_fallback` 3 PASS |
| Resource saturation current-truth authority | validator가 retired Notion live-read marker를 current active context에 요구했다. | repository human/structured/runtime owners marker로 synchronized하고 retired marker injection을 거부하는 negative test를 추가했다. | resource contract validator + 11 tests PASS |
| v4.5 R2 byte-exact history | Windows `core.autocrlf` worktree bytes가 historical Git blob hash와 달랐다. | history test가 `HEAD:<path>` Git blob bytes를 비교한다. | `tests.test_integrated_work_contract_v45r2` 7 PASS |

프로젝트 root에는 `tools/run_local_validation.py`가 없다. Base의 동명 도구는 Base repository 전용이며, 현재 Python 환경은 그 도구가 요구하는 `PIL`, `markdown_it`, `docx`, `pypdf`를 모두 갖추지 않아 `LOCAL_VALIDATION_DEPENDENCY_MISSING`으로 중단됐다. 패키지를 전역 설치하거나 이 결과를 PASS로 바꾸지 않았으며, 이번 범위의 실제 project-focused validators는 모두 별도로 실행했다.

## 열두 번의 전체 적대 검토

각 회차는 사용자 지시, 현재 Base·프로젝트 owner, 실제 diff, 보호 범위, generated consumer, 테스트, 비용, 롤백, GitHub/PR 상태, 장기 유지 비용과 evidence ceiling을 같은 범위로 다시 공격했다.

| loop | 검증한 공격 가설 | 검증·판정 | 수정 / 결과 |
| --- | --- | --- | --- |
| 1 | 최신 `main`과 오래된 기준선의 불일치가 단순 stale pin인가 | 기준선은 실제 조상이고 최신 Base는 canonical source에 한해 ancestry를 허용한다. | `MUST_FIX`: legacy source 표기를 canonical source로 교정. |
| 2 | source만 바꾸면 호환 뷰·snapshot·dashboard 해시가 stale일 수 있다 | Base 생성기가 4개 파생본을 갱신했고 check mode가 일치성을 확인한다. | generated artifacts를 재생성. |
| 3 | 조상 허용이 보호 경로 변경을 숨길 수 있다 | 최신 Base authority test가 historical baseline부터 protected-path diff를 계속 탐지함을 검증한다. | 기존 fail-closed 보호 강도 보존. |
| 4 | 새 표기가 future regression 없이 다시 legacy로 내려갈 수 있다 | project-local RED→GREEN regression이 source type/path와 두 compatibility view hash를 고정한다. | 회귀 테스트 추가. |
| 5 | CI가 Adapter 파일 변경 자체를 protected-baseline promotion으로 오인하지 않는가 | 기존 workflow는 PR base를 선택해 고정 validator의 exact override와 `afa152b...`가 충돌했다. | `MUST_FIX`: baseline commit 변경 여부로 선택 기준을 좁히고 RED→GREEN workflow regression을 추가. |
| 6 | workflow 보정이 신규 승인 manifest나 실제 baseline promotion을 약화하지 않는가 | 새 approval은 여전히 PR base를 선택하고, baseline commit이 바뀌면 PR base를 선택한다. metadata-only migration은 historical baseline을 선택하며 고정 validator 실행도 통과한다. | `CLEAN_REVIEW_EXIT_CANDIDATE`: 새 유효 finding 없음. |
| 7 | initial full suite의 추가 오류가 이번 recovery가 만든 회귀인가 | `cde527a9...` clean worktree에서도 같은 9 failures + 1 error를 재현했다. | 이번 branch가 만든 실패로 오인하지 않고 current owner별 bounded recovery로 분리. |
| 8 | Actions fallback test를 고치면 historical audit evidence를 current state로 되살리거나 CI의 hosted-route 약속을 약화하는가 | reconciliation JSON·current Decision·historical fallback decision을 교차 read했고 역할을 분리했다. | current hosted-runner state와 historical marker를 각각 검사하도록 regression을 교정. |
| 9 | resource saturation validator가 current repository-only Decision을 위반하거나 Notion을 current source로 복귀시키는가 | active context와 `TEN-DEC-20260828-REPOSITORY-ONLY-CANONICAL-WORKSPACE-01`을 비교했다. | current repository owner marker만 수용, retired Notion marker는 negative test로 차단. |
| 10 | byte-exact historic test가 worktree payload 검증을 포기하는가 | 대상 파일이 모든 history commit에서 같은 Git object bytes를 유지하고 CRLF checkout만 달라짐을 확인했다. | actual immutable Git blob을 검증; file existence도 별도 보존. |
| 11 | freshness allowlist가 삭제된 Skill을 다른 활성 consumer에서 허용할 수 있는가 | Base scanner의 full-path glob semantics와 scan set을 read했다. | 두 exact historical paths만 허용하고 config regression 및 actual 506-file scanner PASS를 확보. |
| 12 | 모든 recovery가 프로젝트 코어·runtime·assets·GDD 또는 external authority를 조용히 바꾸는가 | diff·protected product paths·generator output·focused suite를 다시 확인했다. | product mutation 없음. 다음은 full suite·remote CI·PR review/merge와 post-merge main readback. |

## 롤백·미검증·다음 안전 작업

- 롤백은 이 recovery PR 하나를 revert하면 된다. 단, 그 경우 원래의 자기 실패가 되돌아온다.
- Windows visible, Android, 접근성 사용자, Human play, 릴리스 성능은 이 운영 JSON 변경의 대상이 아니며 기존 `NOT_RUN` 상태를 유지한다.
- 정확한 PR head의 remote CI·review·merge와 post-merge `main` readback은 아직 실행 전이다. 병합 전 완료로 표현하지 않는다.
- Base Issue #777은 이 반복 failure의 Base 차원 관찰 기록으로 열린 상태를 유지한다. 이번 프로젝트 복구는 Base 파일을 변경하지 않는다.

## Base 환류

`NO_BASE_MUTATION`. 최신 Base에는 안전한 canonical ancestry mechanism과 regression이 이미 존재한다. 프로젝트는 legacy migration marker만 이 current mechanism에 맞게 완료했다.
