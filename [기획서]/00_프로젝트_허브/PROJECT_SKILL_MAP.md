# 십보강호 프로젝트 스킬맵

> 파생 요약본. 책임 원본은 `SKILL_REGISTRY.json`이다. 필수 사람용 최신본 `PROJECT_SKILL_MAP.pdf`는 아직 `MIGRATION_PENDING`이다.

## 호출 흐름

```text
새 요청
→ project-operations-and-handoff
→ 주 책임 분야 1개 선택
   ├─ 게임 디자인: ten-paces-game-design
   ├─ UX·UI·접근성: combat-ux-and-accessibility
   ├─ 개발·엔지니어링: combat-implementation-handoff
   ├─ QA: ten-paces-verification
   └─ 통합검수: project-health-review
→ 작업 게이트에 도달할 때만 검증·Handoff 실행
→ Learning Log 기록
```

## 선택 분야

| 분야 | 진입 스킬 | 핵심 책임 원본 |
|---|---|---|
| 게임 디자인 | `ten-paces-game-design` | docs/01, 02, 03, 05, 06 |
| UX·UI·접근성 | `combat-ux-and-accessibility` | docs/07, 10 |
| 개발·엔지니어링 | `combat-implementation-handoff` | docs/09, 구현 Plan, 실제 파일 |
| QA | `ten-paces-verification` | docs/08, 실제 테스트·빌드 |
| 프로덕션·PM | `project-operations-and-handoff` | Active Context, Roadmap, Gates, Handoff |
| 통합검수 | `project-health-review` | Registry, Manifest, Health Report |

## 호출 제한

- 전체 자동 로드 금지.
- 주 책임 분야 스킬 최대 1개.
- Foundation 스킬 최대 3개.
- `[백업]`, `[보류]`, `[제거 후보]` 호출 금지.
- 발행·검증·Handoff는 해당 게이트에서만 호출.

## 발행 상태

- Markdown 파생본: `GENERATED_PROVISIONAL`.
- PDF: `MIGRATION_PENDING`.
- 다이어그램: `MIGRATION_PENDING`.
- 자동 렌더 검수: `NOT_RUN`.
- 사람 시각 검수: `NOT_RUN`.
