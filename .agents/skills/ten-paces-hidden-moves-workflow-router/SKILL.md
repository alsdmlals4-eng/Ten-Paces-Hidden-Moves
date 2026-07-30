---
name: ten-paces-hidden-moves-workflow-router
description: Resolve this project's Base shared and project-local Skills through the released Base v9.3 and Vertical Slice v9 operating contracts.
---

# Project Workflow Router

Before selecting any route, validate this repository against its pinned Base
release and the machine-readable project contracts. On a nonzero result or pin
mismatch, stop; do not infer, repair, or execute a route.

Read only:

1. `skills/PROJECT_BASE_ADAPTER.json`
2. `skills/PROJECT_SKILL_SNAPSHOT.json`
3. `skills/SKILL_REGISTRY.json` for project-local packages

Resolve `effective_routes` exactly as generated. Project-local routes take
precedence over same-name Base routes. Base shared Skill bodies remain in Base;
this router contains no copied Base shared Skill body.

The active execution contract is
`templates/prompts/VERTICAL_SLICE_INTEGRATED_EXECUTION_PROMPT_v9.md` from the
pinned Base v9.3 release line. v8 and earlier adapters are compatibility inputs,
not active execution authority.
