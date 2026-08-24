# TEN-DEC-20260824-INTEGRATED-WORK-CONTRACT-V4-8-R2-01

```yaml
decision_id: TEN-DEC-20260824-INTEGRATED-WORK-CONTRACT-V4-8-R2-01
status: APPROVED_CURRENT
approval_source: "user explicit: 권장안대로 진행해"
decision_date: 2026-08-24
scope: PROJECT_OPERATING_AUTHORITY
canonical_document: docs/PROJECT_TOTAL_PLANNING_IMPLEMENTATION_AND_DELIVERY_INSTRUCTION.md
source_uploaded_sha256: 6f0541048e084746f6777223521361d0339dbfb2e223c70947f694f1c050f508
supersedes_decision_id: TEN-DEC-20260811-INTEGRATED-WORK-CONTRACT-V4-5-R2-01
runtime_mutation: NONE
product_core_mutation: NONE
```

## 결정

십보강호의 current project operating contract를 v4.8 r2 thin adapter로 승격한다.

핵심은 다음과 같다.

1. Base 상세 절차를 프로젝트에 다시 복제하지 않고 latest completed Base owner를 필요한 만큼 progressive-load한다.
2. 사람용 Project Home·Flow·Visual·편집 가능한 전체 그림은 Notion을 기본 human-facing canon으로 둔다.
3. Markdown·JSON·게임 데이터·코드·Scene·Resource·Test·runtime evidence는 repository가 소유한다.
4. Google Sheets는 `MIGRATION_ONLY_UNTIL_REMOVAL` compatibility source로 낮추고 신규 기획/승인/current state authority로 사용하지 않는다.
5. `ACTIVE_CONTEXT.md`와 current structured JSON, GitHub live metadata, exact Project Notion이 mutable state를 책임지며 stable router가 PR/SHA/stage/next-package를 복제하지 않는다.
6. pre-existing open PR은 read-only다. current-task PR만 normal gate 뒤 merge한다.
7. v4.5 r2 Decision/JSON/normative body는 historical evidence로 그대로 보존한다.

## 비변경 범위

이 Decision은 다음을 바꾸지 않는다.

- 10칸·3/3/4·거리·합·대응·중단·복기 전투 코어.
- AI public-information boundary.
- Phase I–VI 실제 runtime 구현.
- 무공/성장/경제 수치.
- Windows/Android 제품 구현 권한.
- 이미지 생성 승인 상태.
- Human/Android/local Windows/release-performance evidence ceiling.

## 승격/역사 경계

`TEN-DEC-20260811-INTEGRATED-WORK-CONTRACT-V4-5-R2-01`은 더 이상 current operating authority가 아니며 `SUPERSEDED_HISTORICAL_EVIDENCE`다. 그 Decision, structured JSON, `docs/contracts/integrated-work-v4.5-r2/` bytes는 삭제하지 않는다.

## 검증 조건

- v4.8 RED test가 migration 전 실패하고 migration 후 통과해야 한다.
- historical v4.5 byte-integrity test는 계속 통과해야 한다.
- current cold-start에서 Google Sheets current authority가 제거되어야 한다.
- protected product path 변경이 없어야 한다.
- exact-head PR CI와 postmerge main readback이 필요하다.
