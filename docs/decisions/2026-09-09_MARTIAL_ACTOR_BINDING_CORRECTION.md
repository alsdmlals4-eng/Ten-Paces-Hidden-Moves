# 무공 성급·능력치 실행 일치 — 최초 저장 공개 전 교정

Decision: TEN-DEC-20260909-MARTIAL-ACTOR-BINDING-CORRECTION-01
Status: SPECIFIED / BUILD_AUTHORIZED_BY_CURRENT_CONTINUOUS_CORRECTION_REQUEST; implementation verification pending, Human final NOT_RUN.
Parents: TEN-DEC-20260806-TEN-RECOGNIZABLE-MARTIAL-MANUALS-FULL-GROWTH-01; TEN-DEC-20260908-DURABLE-RUN-CONTINUE-01.
Research and actual paths: `../operations/2026-09-09_MARTIAL_ACTOR_BINDING_RESEARCH.md`.

## WHY / HOW / WHAT

보유 무공의 표시 성급과 실제로 쓰는 기술이 일치해야 수련의 의미와 전투 결과를 설명할 수 있다. 같은 무공을 가진 상대의 높은 성급이 플레이어에게 적용되거나, 플레이어의 높은 성급 효과가 상대의 낮은 성급으로 사라져서는 안 된다. 기술이 참조하는 내공 등은 실제 전투원의 해당 능력치를 사용한다.

양측은 같은 무공 원본과 카드 ID를 사용하되, 각자의 성급으로 합성한 정의를 별도로 소유한다. UI·AI·실행·저장 검증이 같은 전투원 정의를 소비한다. 기초 행동·기존 공용 절초·피해/자원/비용/성급 수치·3/3/4·정보 공개·재도전·보상 규칙은 바꾸지 않는다. 이는 새 밸런스가 아니라 승인된 데이터와 실제 consumer 간 CANON_CONFLICT의 교정이다.

## Exact engine contract

- Introduce `get_actor_card_definition(card_id: String, actor_key: String) -> Dictionary` and `get_actor_cards_by_id(actor_key: String) -> Dictionary`. Valid actors are player/enemy. Returned definitions/maps are owned deep copies; unknown actor or unavailable martial ID returns empty. Basic/generic ultimate availability preserves existing rules.
- Ten-manual engine stores independent normalized effective dictionaries for player and enemy. Registry JSON is unchanged. Reconfiguration clears old actor maps and stale actor-derived IDs. Existing `cards_by_id` remains a compatibility/discovery union, preferring player definition on a shared ID; no actor-sensitive execution may use the union as authority.
- `configure_martial_loadout(s)` returns bool. With an existing enemy lock, an identical effective binding is an idempotent true/no-op; a changed binding returns false without changing maps, lock, seed or resources. Do not clear a revealed enemy lock to permit reconfiguration. Fresh engine initialization and validated checkpoint reconstruction remain the normal configuration boundaries.
- Player action construction, enemy action generation and AI candidates, preparation bookkeeping, direct martial execution, checkpoint export and checkpoint plan/lock verification use the appropriate actor definition. Canonical IDs are never suffixed by actor or mastery. Preserve the existing AI public-input whitelist and exact locking time; this correction does not let AI inspect player-owned private plans.
- UI-decorated definitions remain accepted only through the existing exact canonical-or-authoritative-adapter producer rule. File input remains strict. Do not strip arbitrary fields or repair a forged saved definition.
- Before preview or resolution mutates anything, reject unavailable martial IDs and disagreeing placement/definition IDs as a whole plan (`valid=false`, `rejected=true` for resolution, reason `MARTIAL_ACTOR_DEFINITION_MISMATCH`). Identify martial IDs from registry/actor maps, not a caller's source label. Do not silently omit a rejected player action and run the enemy. For valid IDs, engine execution and prepare bookkeeping use actor canonical definitions regardless of UI decoration; UI producer exact acceptance stays in the bridge, not a new UI dependency inside the domain engine. Preserve standalone non-martial fixture support. Metrics must return a rejected result unchanged rather than accumulating it.
- SPECIAL_CLASH resolves authored stat labels through one explicit mapping: 외공→external, 근골→constitution, 신법→agility, 내공→internal_power, 심안→insight. The five canonical English keys are accepted as references too. Actor state remains canonical English only; do not add Korean shadow keys to saves.
- Before effect execution, validate every SPECIAL_CLASH stat reference in the program, even a conditional step. A nonempty reference must be recognized and have a finite numeric actor value. An empty reference is valid only for a zero coefficient/fixed-only clash. A missing, unknown or malformed reference returns `INVALID_STAT_REFERENCE`, completed=false and the unchanged original state, with no applied effect events. Coefficients must be finite numeric values; no string/bool coercion. Do not change authored fixed powers or coefficients, conditions, ordering or costs.
- Valid clashes retain the authored fixed power plus floored stat contribution. Example Nangong star3 with internal_power4 produces12, not8. Unknown values are failures, not valid zero.

## Save compatibility ruling

Schema shape remains1. Change `RunCheckpointCodec.SEMANTIC_CONTRACT_VERSION` from `ten-duel-four-route-one-retry-bimu-save-v1` to `ten-duel-four-route-one-retry-bimu-actor-bound-save-v1`, which participates in existing content identity. This is a declared execution-semantic change, not a save-neutral bugfix. The initial public save feature must use the corrected identity. Before code mutation, preserve a representative old-codec test fixture with source/hash provenance; use isolated test storage only.

Earlier unpublished QA or unknown identity files remain intact and load as INCOMPATIBLE. No automatic migration, deletion, user-directory search, free reroll or forced fresh start. Existing explicit player replacement flow still preserves incompatible evidence. COMMITTED replays the validated actor-bound plan/lock once; RESOLVED restores authoritative saved output without replay. Cached validation context cannot cross the semantic change.

## Boundary / validation

No new growth spending, first-reach permanent-stat grants, stat-based unlock gates, all-owned battle expansion, art, PDF regeneration, grade economy, new motion or platform change in this correction. Those Blueprint gaps remain subsequent approved design/implementation work, not done here.

Required RED/GREEN: player3/enemy7 and player5/enemy3 same-manual overlays; both actor orders, different star9 overlays, unavailable actor ID, reconfigure cleanup and copy isolation; actual English-stat engine states at1/4/15 and nonuniform values; invalid alias and missing-stat atomicity; real UI-decorated player plan and enemy lock export/import at unequal mastery; fresh-process COMMITTED equivalence; RESOLVED no replay; old-identity bytes preserved; existing cost/ultimate/observation/prepare/AI regressions; optimized persistent ten-duel flow and full test suite. Exact-head independent review and protected merge/readback remain required. Automated and visible capture evidence never means Human, Android, accessibility-user or release PASS.
