# 태그·기획 정본 누락 감사

- Audit ID: `TEN-AUD-015`
- 날짜: 2026-08-02
- 기준 main: `7082dab1c66e994ce3be1861640754f97080ed5c`
- 작업 브랜치: `agent/2026-08-02-tag-planning-canon-audit`
- 작업 성격: 문서 정본 유지보수; 새 게임 규칙 승인 아님
- GrillMe 승인 카운트 영향: 없음, `0/10` 유지

## 1. 감사 목적

이미 승인된 게임 태그·상태·관찰·성장·회차·천하제일인·챔피언 랭킹 결정이 활성 책임 문서와 Google Sheet에서 누락되거나 구형 표현으로 되살아나는지 확인한다.

## 2. 확인한 정본

- `TEN-DEC-20260802-PLATFORM-SCOPE-01`
- `TEN-DEC-20260802-OBSERVATION-STATS-MASTERY-01`
- `TEN-DEC-20260802-FULLRUN-CHAMPION-RANKED-01`
- `TEN-DEC-20260802-RANKED-OBSERVATION-CONVERSION-01`
- `docs/01_GAME_DESIGN.md`
- `docs/02_COMBAT_RULES.md`
- `docs/03_CONTENT_CATALOG.md`
- `docs/04_ROADMAP.md`
- `docs/05_COMBAT_POC_SPEC.md`
- `docs/08_TEST_CHECKLIST.md`
- 허브 Active Context·Documentation Map
- Google Sheet 01·05·10·90 및 감사·변경 이력

## 3. 발견 사항

### P0

없음. 제품 코드·런타임 데이터는 변경하지 않았고 현재 main의 실행 상태를 완료로 과장하지 않았다.

### P1 — 활성 정본 충돌

1. `docs/01`·`docs/03`에 관찰 의존 무공의 랭킹전 처리가 미결정으로 남아 있었다.
2. `docs/04`·허브 Active Context·허브 Documentation Map에 main SHA와 PR #65/#68 중심 상태가 남아 있었다.
3. `docs/05`에 공격력·방어력 중심 신규 성장, 공개 성향, 소모 방어도, 천하제일인 후보6명 표현이 남아 있었다.
4. `docs/08`에 구형 시작 수치·소모 방어도 검사가 최신 완료 기준과 섞여 있었다.
5. Google Sheet `05_GDD_요약`에 후보6명·구형 정본·구형 동기화 상태가 남아 있었다.

### P2 — 태그·상태 구조 누락

1. 제품 포지셔닝 태그, 플레이어 노출 전투 태그, 내부 상태 태그를 한곳에서 소유하는 등록부가 없었다.
2. `CURRENT`, `PARTIAL`, `PLANNED`, `FUTURE_ONLINE_APPROVED_PLANNING_IMPLEMENTATION_BLOCKED`처럼 서로 다른 축이 혼합됐다.
3. 카드형 UI 때문에 `덱빌딩`·`카드 배틀러`로 오인될 가능성을 명시적으로 차단하는 제품 태그 경계가 없었다.

## 4. 교정 내용

- `docs/00_TAG_STATUS_REGISTRY.md` 신설.
- 제품 태그를 무협·1대1 결투·턴제 전술·심리전·불완전 정보·로그라이트로 정리.
- 덱빌딩·카드 배틀러·실시간 격투·PvP 중심을 오인 방지 태그로 분리.
- 관찰 공개 종류 8종과 판정 키워드·행동 출처 태그를 분리.
- 권위·콘텐츠 범위·구현·검증 상태를 별도 필드로 분리.
- `docs/01`·`docs/03`에 공식 랭킹전 변환 결정을 반영.
- Active Context·Roadmap·두 Documentation Map을 최신 PR #69~#71 이력과 App Flow Shell 기준으로 갱신.
- PoC 명세를 5종 스테이터스·적 계획 잠금·관찰 이월·비소모 방어도·후보30명/전설 후보군 구조로 교정.
- 테스트 체크리스트에서 레거시 증거와 최신 승인 기획 검증을 분리.

## 5. 의도적으로 변경하지 않은 것

- 제품 코드·Scene·런타임 데이터.
- 정확한 기술별 수치.
- 정확한 랭킹전 관찰 변환표.
- 평점 공식·시즌 길이·매칭·서버·보안.
- Godot·Windows·네트워크·접근성·사람 검증 상태.
- GrillMe 승인 카운트.

## 6. 후속 검증

- 변경 파일 목록과 diff가 문서·Sheet 정본 범위를 벗어나지 않는지 확인.
- 모든 활성 문서에서 `관찰 의존 ... 미결정`, `후보6명`, `공개 성향`, 신규 성장의 `공격력·방어력` 표현 재검색.
- planning JSON 파싱과 정적 계약 검사.
- exact-head Full Validation·PR Validation·Base v9 Adoption 확인.
- PR review thread와 head 이동 확인.
- 병합 뒤 main·Google Sheet 재조회.

## 7. 현재 판정

```yaml
authority_status: CURRENT_APPROVED_PLANNING_PRESERVED
scope_status: DOCUMENTATION_MAINTENANCE
implementation_status: NO_PRODUCT_CHANGE
static_validation: PENDING_PR
runtime_validation: NOT_RUN
human_validation: NOT_RUN
p0_open: 0
p1_open: 0
p2_open: 0
```
