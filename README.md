> # 십보강호: 숨은 수의 비무
## Ten Paces: Hidden Moves

상대의 다음 행동 단서를 모아 가설을 세우고 여러 수의 계획으로 의도를 무너뜨리는 **무협 전술 로그라이트**입니다.

> 보이지 않는 상대의 수를 읽고, 준비한 계획으로 꺾는다.

## 시작

- [작업 시작](START_HERE.md)
- [현재 상태]([기획서]/00_프로젝트_허브/ACTIVE_CONTEXT.md)
- [v6 전체 결정 권한 원장](docs/decisions/2026-07-28_V6_DECISION_AUTHORITY_LEDGER.md)
- [PR #45 v6 통합 검수](docs/decisions/2026-07-28_V6_PR45_INTEGRATION_REVIEW.md)
- [문서 지도]([기획서]/00_프로젝트_허브/DOCUMENTATION_MAP.md)
- [게임 기획](docs/01_GAME_DESIGN.md)
- [전투 규칙](docs/02_COMBAT_RULES.md)
- [콘텐츠 카탈로그](docs/03_CONTENT_CATALOG.md)
- [무공·성장 자료](docs/06_STARTING_FACTION_MASTERY_DATA.md)
- [테스트 체크리스트](docs/08_TEST_CHECKLIST.md)
- [Base 적용 기준](docs/BASE_RULES_VERSION.md)
- [Base 동기화 감사]([기획서]/00_프로젝트_허브/BASE_MAIN_SYNC_AUDIT.md)

## 현재 작업 상태

```yaml
product_stage: CONCEPT_APPROVAL
work_mode: PLAN
execution_profile: PLANNING_ONLY_PROFILE
runtime_implementation: PROHIBITED_UNTIL_NEW_APPROVAL
planning_integration_pr: 45
human_validation: UNVERIFIED
base_commit: c987647d01ad2baa028a16e03d85ddfc1572a727
```

2026-07-26의 `BUILD_IN_PROGRESS`와 구현 인계 승인은 이후 v6 재설계 지시로 대체됐습니다. PR #45는 최신 결정 원장과 과거 감사·검증 자료를 정합화하는 계획 문서 통합이며 제품 런타임을 변경하지 않습니다.

## 프로젝트 코어

```text
상대의 공개 상태·해결 이력 관찰
→ 다음 행동에 대한 가설 수립
→ 3/3/4 행동 묶음 계획
→ 상대 의도 완화·거부·반전·응징
→ 결과 복기와 무공 성장
```

- 성장은 더 다양하고 강력한 파훼 방법을 제공합니다.
- 원시 수치 상승은 파훼 판단을 대체하지 않습니다.
- AI는 플레이어의 미확정 계획을 읽지 않습니다.
- 덱·손패·드로우·장착 기술 제한을 사용하지 않습니다.

## 현재 주요 기획 계약

- 한 라운드는 `3수 → 3수 → 4수`, 각 묶음 뒤 해결하며 총 10수입니다.
- 10칸 일자형 전장과 거리 0 `[밀착]`을 사용합니다.
- 버티컬 슬라이스는 핵심 결투 5개를 앵커로 하며 일반전·강적전·사건·수련·정보·회복·시장 노드를 포함합니다.
- `[연격 N]`은 최종 총피해를 N개의 피해 묶음으로 나눕니다. 첫 피해만 `[합]`에 참여하며 기본 회피는 피해 묶음 하나만 회피합니다.
- 방어와 보호막은 하나의 `[방어도]`로 통합되고 피해 묶음마다 개별 감산됩니다.
- 무공서는 16권, 1~10성입니다. 시작 시 해금된 무공서 4권을 3성으로 선택합니다.
- 수련 중앙 목표는 전체 전투 5회 40~50, 10회 90~100입니다.
- 전투 랭크는 `A / A+ / S / S+`, 수련 보너스는 `0 / 1 / 2 / 3`입니다.
- 절초는 무공서 10성에 해금되고 공유 절초기세 5를 소비하며 동일 슬롯 일반 기술보다 약 50% 높은 예산을 가집니다.

## `[보류]`

- Round 4 이후 전체 적대적 검토
- 16개 개별 절초 설계
- 2026-07-26 구현 계획 실행
- Godot 런타임·데이터·씬·자산 변경

## 구현 사실과 설계 권한

현재 `main`에는 기존 T0 전투 PoC의 STEP 0~13이 존재하며 플레이어 4번·상대 7번 시작을 포함합니다. 최신 v6 기획과는 완전히 일치하지 않습니다. 실제 코드·데이터는 현재 구현 사실의 근거이며, 최신 설계 권한은 v6 결정 원장이 소유합니다.

정적 검사·Actions 성공은 Godot 런타임, Windows 사용성, 접근성, 성능, 실제 플레이 재미를 증명하지 않습니다. 실행하지 않은 항목은 `UNVERIFIED`로 유지합니다.

## BCA v8 기획·이미지·Sheet 운영

- Base 기준: `alsdmlals4-eng/Base@c987647d01ad2baa028a16e03d85ddfc1572a727`
- 통합 실행문: `templates/prompts/VERTICAL_SLICE_INTEGRATED_EXECUTION_PROMPT_v8.md`
- 프로젝트 Sheet: `PROJECT_SHEET_CONFIGURED`; 구조 계약은 `docs/PROJECT_GOOGLE_SHEET_WORKBOOK.md`
- GPT 이미지·목업: `docs/GPT_IMAGE_GENERATION_AND_REVIEW_WORKFLOW.md`
- 적용 감사: `docs/BCA_VISUAL_SHEET_ADOPTION_AUDIT.md`
