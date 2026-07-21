# 통합 전 Skill ID 별칭

과거 문서·Learning Log·Git 이력에서 발견되는 구형 Base 또는 프로젝트 Skill ID를 현재 통합 Skill과 Skill Mode로 해석한다. 새 Registry·작업 계약·Active Context·PR에는 현재 ID만 사용한다.

| 구형 Skill ID | 현재 Skill | Skill Mode |
|---|---|---|
| `conducting-deep-requirement-interviews` | `managing-project-intake-and-work-contract` | `clarify` |
| `routing-project-work-by-discipline` | `managing-project-intake-and-work-contract` | `route` |
| `transforming-requests-into-prompts` | `managing-project-intake-and-work-contract` | `contract` |
| `installing-game-project-operating-system` | `managing-game-project-operating-system` | `install` |
| `migrating-existing-game-project-structure` | `managing-game-project-operating-system` | `audit` / `migrate` |
| `verifying-game-project-operating-system` | `managing-game-project-operating-system` | `verify` |
| `writing-game-design-documents` | `managing-design-documents` | `author` / `update` |
| `publishing-discipline-bibles` | `managing-design-documents` | `publish` / `validate` |
| `reviewing-external-ai-drafts` | `reviewing-and-validating-project-changes` | `external-source-review` |
| `promoting-project-knowledge` | `managing-base-change-proposals` | `extract` / `submit` |
| `reviewing-and-implementing-base-change-proposals` | `managing-base-change-proposals` | `review` / `implement` / `verify` |
| `project-operations-and-handoff` | `managing-project-intake-and-work-contract` + `maintaining-project-context-and-handoff` | `route` / `execution-report` + context·handoff |
| `project-health-review` | `managing-game-project-operating-system` + `reviewing-and-validating-project-changes` | `verify` + `contract-check` / `evidence-report` |

현재 프로젝트 고유 Skill:

- `ten-paces-game-design`
- `combat-ux-and-accessibility`
- `combat-implementation-handoff`
- `ten-paces-verification`

## 검증

- 활성 Entry Point와 Registry에 구형 ID가 있으면 실패다.
- 이 파일, Learning Log, Changelog, 과거 Audit·Plan에서 역사 설명으로 언급하는 것은 허용한다.
- 통합 뒤 경로·ID·template·test·Workflow 소비자는 canonical reference freshness로 확인한다.
