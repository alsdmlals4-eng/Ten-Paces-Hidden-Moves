# TEN-DEC-20260828-ADVERSARIAL-RESEARCH-FEASIBILITY-GATE-01

## 결정

사용자의 2026-08-28 명시 지시에 따라 십보강호의 이후 작업은 항상 최신 외부 근거 확인, 구현 가능성 판정, 적대적 검토를 포함한다. 이 결정은 제품 규칙·Scene·Resource·asset을 바꾸지 않는 repository-only 운영 게이트다.

## 적용 규칙

### 1. 모든 작업의 조사 기록

모든 작업은 시작 전에 다음 `CURRENT_SOURCE_RELEVANCE_CHECK`를 남긴다.

```yaml
research_question:
decision_or_claim_changed_by_the_answer:
current_source_checked:
source_type: OFFICIAL_PRIMARY | FIRST_HAND_CASE | BENCHMARK | NOT_APPLICABLE
freshness:
relevance:
evidence_limit:
```

- 최신 기술·플랫폼·권리·시장·접근성·경쟁/벤치마크 사실이 결론을 바꿀 수 있으면 current official/primary source를 먼저 조사한다.
- 디자인에는 직접 관련된 성공·실패·혼합 사례를 구분해 조사하고, 표면 표현·고유 자산·상표를 복제하지 않는다.
- purely local formatting처럼 외부 사실이 결론을 바꾸지 않을 때만 `NOT_APPLICABLE`를 쓴다. 이 경우에도 왜 외부 근거가 결론을 바꾸지 않는지 적는다.
- `not invent external evidence`: 검색하지 않은 사실, 검색 result snippet, 오래된 reference, 모델의 자신감을 verified evidence나 project runtime truth로 승격하지 않는다.

### 2. 구현 가능성 판정

material mutation 전에는 다음을 하나의 feasibility record로 연결한다.

```text
approved intent
→ current source relevance check
→ actual repository path / dependency / consumer / test or CI route
→ target environment constraint
→ FEASIBLE | PARTIAL | BLOCKED_UNVERIFIED
→ scope / risk / rollback / next validation
```

`FEASIBLE`은 해당 변경을 검증할 실제 경로가 확인됐다는 뜻이며 Human usability, physical Android device, accessibility-user, release, market success를 자동 PASS로 만들지 않는다. 필요한 환경·권한·검증 경로가 없으면 `PARTIAL` 또는 `BLOCKED_UNVERIFIED`다.

### 3. 적대적 검토 루프

- 모든 작업·권장안·retained change는 최소 한 번 `EVERY_TASK_BASE_LOOP`를 수행한다.
- material 계획·구현·문서·PR 변경은 `running-adversarial-review-and-refinement`의 최소 5회 full-scope loop와 `CLEAN_REVIEW_EXIT`를 따른다.
- 각 full loop는 사용자 의도, current canon/Decision, actual diff/consumer/test/runtime, security/safety, player value, scope/cost, alternatives, long-term fit, rollback/evidence ceiling을 함께 재공격한다.
- 유효 finding만 최소 교정한다. 가짜 finding, 같은 finding의 표현만 바꾼 중복 계수, 불필요한 변경으로 loop 수를 채우지 않는다.

## 이번 적용의 외부 근거와 구현 가능성

| research_question | current source | verified observation | effect |
|---|---|---|---|
| Godot automated validation/export path is technically available for this project | [Godot Command line tutorial](https://docs.godotengine.org/en/stable/tutorials/editor/command_line_tutorial.html), checked 2026-08-28 | `--headless` and `--script` are documented; headless export is documented for CI environments | Existing headless validation remains feasible; visible/Human evidence is still separate |
| Windows CI can remain an independently hosted validation layer | [GitHub-hosted runners reference](https://docs.github.com/en/actions/reference/runners/github-hosted-runners), checked 2026-08-28 | Windows hosted runner labels and resource classes are currently documented | Current remote Windows evidence route is feasible; runner availability/version remains live-checked per PR |
| Game and menu input need the same input method | [Game Accessibility Guidelines](https://gameaccessibilityguidelines.com/ensure-that-all-areas-of-the-user-interface-can-be-accessed-using-the-same-input-method-as-the-gameplay/), checked 2026-08-28 | The guideline identifies a gameplay/menu input mismatch as a basic motor-accessibility risk | PC/gamepad/mobile input reviews must include menus and plan UI, not only combat controls |

Current operational feasibility: `FEASIBLE` for the repository’s source, test, Godot headless, and GitHub CI checks; `PARTIAL` for the player-facing Windows and Android/accessibility evidence path because those direct Human/device observations remain `NOT_RUN`.

## 대안 검토

| option | disposition | reason |
|---|---|---|
| A. Evidence-scaled research gate + every-task base loop + five loops for material work | ADOPT | User’s “always” direction is preserved without inventing irrelevant sources or fake review work. |
| B. Three external sources and five loops for every typo/format-only operation | REJECT | It would encourage boilerplate research and fake findings without improving correctness. |
| C. Research and adversarial review only for major product decisions | REJECT | It leaves documentation, migration, CI, and consumer-drift changes outside the requested safety net. |

## 영향과 경계

- current owner: `AGENTS.md`, `docs/PROJECT_TOTAL_PLANNING_IMPLEMENTATION_AND_DELIVERY_INSTRUCTION.md`, current planning JSON, this Decision.
- no Notion write/readback: Notion is historical migration input only under `TEN-DEC-20260828-REPOSITORY-ONLY-CANONICAL-WORKSPACE-01`.
- no automatic product mutation: a feasibility result is not an implementation approval.
- no Base promotion: `NO_BASE_PROMOTION`. Base already owns the generic adversarial/research discipline; this user-directed cadence and repository-only owner mapping are project-specific.

## 검증과 재개 조건

- regression: `tests/test_adversarial_research_feasibility_gate.py` verifies the entrypoint, current contract, Decision, and planning-state locator.
- source freshness: every future material task rechecks external sources instead of treating this 2026-08-28 sample as permanent truth.
- if a future task has no current primary source, record `BLOCKED_UNVERIFIED` or a reasoned `NOT_APPLICABLE`; do not replace it with an unsupported claim.

## 상태

`CONFIRMED_BY_USER_EXPLICIT_APPROVAL`. This governs how work is researched, attacked, validated, and reported; it does not claim new gameplay, runtime, Human, device, or release evidence.
