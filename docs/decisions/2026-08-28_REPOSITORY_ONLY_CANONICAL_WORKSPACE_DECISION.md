# TEN-DEC-20260828-REPOSITORY-ONLY-CANONICAL-WORKSPACE-01

## 결정

2026-08-28 사용자의 명시 지시에 따라 십보강호는 이후 Notion을 current authority, human-facing canon, 작업면, 승인 전달 대상 또는 closeout readback으로 사용하지 않는다. 프로젝트 고유 사실과 사람이 읽는 설명은 repository의 Markdown/JSON/asset/provenance/documentation map으로 소유한다.

## 범위

- **current authority:** GitHub `main`, open/draft PR metadata, repository structured owners, actual code/data/Scene/Resource/asset/test/runtime evidence.
- **human-facing canon:** repository Markdown과 tracked visual/asset records.
- **Notion:** historical migration input only. 새 페이지·database·attachment·sync·readback을 만들지 않는다.
- **Google Sheets:** existing policy대로 `MIGRATION_ONLY_UNTIL_REMOVAL`; Notion과 같은 current authority가 아니다.
- **historical Notion facts:** 이 결정을 적용하며 확인한 고유 정보는 `docs/design/PROJECT_AI_PRODUCTION_SPEC.md` §01, §03, §12 및 matching master GDD에 repository migration snapshot으로 기록한다. 이미 repository owner에 있는 중복 정보는 이관하지 않는다.

## 기존 계약과의 관계

`TEN-DEC-20260826-INTEGRATED-WORK-CONTRACT-V4-8-R5-4-01`의 Notion human-facing/domain-split 및 Notion destination readback 조항은 이 결정의 범위에서 **SUPERSEDED_FOR_CURRENT_EXECUTION**이다. r5.4의 나머지 product/platform/visual/implementation safety constraints는 변경하지 않는다.

## 영향과 안전 경계

| 영향 | 조치 |
|---|---|
| 새 채팅 fresh-read | AGENTS → Active Context/current JSON → GitHub metadata → repository owners → actual implementation 순서로 재구성 |
| 승인 Visual | repository source/provenance, exact consumer, user final lock으로 기록; Notion attachment는 과거 evidence일 뿐 |
| closeout | repository destination readback, exact-head checks, PR/merge/post-merge main readback으로 완료 |
| 기존 Notion URL·attachment | 삭제·수정하지 않음. historical locator로만 보존 |
| Notion-only unique content | 사용자 요청 시 repository owner 또는 this GDD에 migration; 중복/obsolete는 기록만 하고 current truth로 승격하지 않음 |

## 검증

- entry-point documents no longer require Notion as current source;
- current planning JSON no longer schedules Notion projection;
- no new Notion mutation was performed;
- actual code/data/Scene/test authority remains unchanged;
- repository-only GDD readback contains the unique Notion visual/flow state used in this transition.

## 상태

`CONFIRMED_BY_LATEST_USER_INSTRUCTION`. This is an operational canon decision, not a gameplay, runtime asset, release-rights, or Human UX PASS claim.
