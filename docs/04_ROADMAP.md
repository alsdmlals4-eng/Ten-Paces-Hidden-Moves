# 십보강호 구현 로드맵과 검증 기준

> 책임: 현재 작업·PoC·T1·구현·검증 진입 순서  
> 전투 규칙: `docs/02_COMBAT_RULES.md`

## 1. 현재 단계

```yaml
phase: BUILD_IN_PROGRESS
planning: USER_CONFIRMED_COMPLETE
review: USER_CONFIRMED_COMPLETE
project_core: CORE_CONFIRMED
implemented_runtime: IMPLEMENTED_LEGACY
new_poc_runtime: NOT_STARTED
implementation_plan: AUTHORED
implementation_authorization: GRANTED
ui_ux_audio_asset_pipeline: AUTHORIZED_NOT_EXECUTED
human_step14: NOT_RUN
t1_greenlight: NOT_GRANTED
```

## 2. 현재 작업

- [x] 구형 규칙과 활성 소비자 감사.
- [x] 1~10 기획 데이터를 편집 가능한 JSON으로 작성.
- [x] PoC 범위를 주요 비무 1~5와 구간당 중간 노드 2~3개로 확정.
- [x] 전투·콘텐츠·성장·지도·UI·QA 책임 원본 동기화.
- [x] 전체 적대적 검토와 사용자 결정 완료.
- [x] planning Schema·validator·24개 반례 테스트 교정.
- [x] UI·UX·사운드 제작 순서 확정.
- [x] 사용자 명시적 `기획 완료`.
- [x] 사용자 명시적 `검수 완료`.
- [x] Codex 구현 프로그램과 하위 계획 작성.

## 3. 프로젝트 코어 확정

1대1·10칸·비공개 3/3/4·공개 정보 기반 상대 읽기·거리·합·대응·중단·복기는 불변이다. 로그라이트 성장은 다음 결투 판단을 바꾸는 보조 구조다.

## 4. 구현 프로그램

상세 프로그램: `docs/superpowers/plans/2026-07-26-poc-implementation-program.md`.

### P0-A — 런타임 기반

계획: `docs/superpowers/plans/2026-07-26-poc-runtime-foundation-implementation-plan.md`.

- [ ] 격리 branch·worktree와 baseline 검증.
- [ ] planning→runtime adapter.
- [ ] `RunState`/`CombatState` 분리와 유료 재도전.
- [ ] 속공4·강공10·방어도5·내력5·명상1/1.
- [ ] `[강화]`×1.5·중단1회 `[강건]`.
- [ ] 순차 연격 `[합]`, 잔여타, 스택형 `[필중]`.
- [ ] 효과 scope와 7개 trigger.
- [ ] 공개 상태 기반 3수 AI template.
- [ ] stable event stream·로그·복기.
- [ ] REVIEW 복귀와 runtime foundation 증거.

### P0-B — 캠페인·성장

계획: `docs/superpowers/plans/2026-07-26-poc-campaign-progression-implementation-plan.md`.

- [ ] 시작 무공 6개 중 4개 선택·3성 시작.
- [ ] 주요 비무 1~5와 네 gap의 deterministic route.
- [ ] gap당 중간 노드 2~3개, 총 방문 13~17개.
- [ ] 자유6 / 지정5+자유3 / 문파 무공3성 보상.
- [ ] 집중32+노드6·자유24+고효율14 성장 경로.
- [ ] 성과 등급 산식.
- [ ] 체력 이월·승리 회복·보상 1회 commit.
- [ ] 최소 RunState serialization.
- [ ] REVIEW 복귀와 campaign 증거.

### P0-C — UI·UX·사운드·에셋

계획: `docs/superpowers/plans/2026-07-26-poc-ui-audio-assets-implementation-plan.md`.

- [ ] UI/audio event matrix와 asset gap map.
- [ ] 최신 에셋 스토어·라이브러리 검색.
- [ ] 출처·가격·라이선스·Godot 적합성 원장.
- [ ] `ADOPT / ADAPT / GENERATE / REJECT / DEFER` 판정.
- [ ] 부족분만 생성·편집.
- [ ] HUD·타격 로그·보상·재도전 UX.
- [ ] AudioEventRouter와 bus·polyphony 정책.
- [ ] Godot 통합·접근성·피로·성능 검증.
- [ ] REVIEW 복귀와 asset evidence.

## 5. PoC 구현 범위

- 주요 비무 1은 튜토리얼.
- 주요 비무 2~5는 스테이지 1 초반부.
- 기본 절초 3종은 시작부터 사용 가능.
- 무공별 절초는 해당 무공 10성 도달로 해금.
- 주요 비무 사이 네 구간마다 중간 노드 2~3개.
- 중간 노드 총 8~12개, 주요 비무 포함 총 방문 노드 13~17개.
- 시작 무공 6개 중 4개 선택.

### 주요 비무5 전 성장 구조

- 집중 보상: 주요 비무1~4에서 `지정5+자유3`을 같은 무공에 선택해 32.
- 최소 집중 노드: 네 구간 합계 6을 같은 무공에 투입 가능하도록 보장.
- 집중 경로 합계: 38.
- 자유 보상: 24 + 고효율 중간 노드 목표14 = 38이며 모든 경로 보장은 아니다.

## 6. 범위 제외

- 주요 비무 6~10 런타임 구현.
- 스테이지 2·3 런타임 구현.
- 천마·무림맹주 등 히든 전투.
- 전체 지도·영구 성장 트리·완성 상점 경제.
- 최종 아트·사운드·Release 성능 주장.

## 7. BUILD/REVIEW 루프

```text
BUILD: failing test → minimal implementation → focused tests
→ REVIEW: diff·정적·Godot·참조·회귀 증거
→ 승인 시 다음 BUILD
```

- 각 Task는 독립 커밋과 리뷰 가능한 결과를 만든다.
- 실패한 기준 테스트를 무시하고 새 기능을 진행하지 않는다.
- 실행하지 않은 검증은 `NOT_RUN`이다.
- 사람 증거 없이 UI 이해도·재미·사운드 선호를 PASS로 기록하지 않는다.

## 8. STEP 14

- 신규 플레이어 5명.
- 4명 이상 치명적 차단 없이 주요 비무 1~5 완료 또는 이탈 이유 기록.
- 4명 이상 3/3/4와 결정적 원인 설명.
- 3명 이상 상대 성향 발견.
- 3명 이상 중간 노드 선택 뒤 다음 전투 계획 변경.
- 3명 이상 재도전에서 계획 변경.
- 색·모션·음향 단일 채널 의존 없음.

현재 STEP 14는 `NOT_RUN`이다.

## 9. T1

PoC 자동·Godot·Windows·접근성·성능·사람 증거와 두 번째 콘텐츠 반복 제작 증거 뒤에만 진입한다. 현재 `t1_greenlight: NOT_GRANTED`.

## 10. 공통 검증 게이트

```text
계약·Schema
→ JSON·정적 검사
→ 자동 테스트
→ Godot runtime
→ 에셋 출처·라이선스·통합 검사
→ Windows·접근성·성능
→ 사람 플레이
→ 증거 보고
```

## 11. 중단·축소 조건

- 연격이 다른 공격을 지배한다.
- 성장·중간 노드 선택이 피해 증가만 만든다.
- 주요 비무 사이 노드가 반복 피로만 늘린다.
- 공개 성향 없이 정답 추측에 의존한다.
- 3/3/4가 이해되지 않는다.
- 두 번째 무공·적·노드를 같은 데이터 구조로 만들 수 없다.
- 플레이어 미확정 계획을 AI가 읽는다.
- 외부 에셋을 맞추기 위해 정보 구조나 전투 계약을 왜곡한다.
- 출처·라이선스가 불명확한 에셋에 핵심 기능이 의존한다.

판정 어휘: `KEEP / AMPLIFY / CHANGE / REMOVE / DEFER / RETEST`.
