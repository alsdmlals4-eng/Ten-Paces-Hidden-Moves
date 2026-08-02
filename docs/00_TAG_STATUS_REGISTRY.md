# 십보강호 태그·상태 정본 등록부

> 책임: 제품 포지셔닝 태그, 플레이어 노출 규칙 태그, 내부 기획·범위·구현·검증 상태의 이름과 사용 경계  
> 게임 정체성: `docs/01_GAME_DESIGN.md`  
> 전투 태그 의미: `docs/02_COMBAT_RULES.md`  
> 콘텐츠 범위: `docs/03_CONTENT_CATALOG.md`  
> 검증 판정: `docs/08_TEST_CHECKLIST.md`  
> 최신 운영 결정: `docs/decisions/2026-08-02_RANKED_OBSERVATION_CONVERSION_DECISION.md`

이 문서는 새 규칙을 만드는 문서가 아니다. 이미 승인된 태그와 상태값을 한곳에 모아 문서·JSON·Google Sheet·UI가 서로 다른 뜻으로 같은 단어를 쓰는 일을 막는다.

## 1. 제품 포지셔닝 태그

### 핵심 태그

- `무협`
- `1대1 결투`
- `턴제 전술`
- `심리전·수읽기`
- `불완전 정보`
- `로그라이트`

### 보조 태그

- `거리·위치 전술`
- `동시 계획`
- `결정론적 판정`
- `전투 복기`
- `무공 성장`
- `절차형 상대·경로`

### 후속 콘텐츠 태그

- `천하제일인전`
- `비동기 챔피언 배틀`
- `시즌 랭킹`

후속 콘텐츠 태그는 승인된 미래 기획을 뜻하며 현재 데모·세로 슬라이스 구현 범위를 뜻하지 않는다.

### 사용 금지·오인 방지 태그

다음 표현은 현재 제품 구조를 잘못 전달하므로 핵심 장르·상점 태그로 사용하지 않는다.

- `덱빌딩`
- `카드 배틀러`
- `실시간 격투`
- `완전 정보 퍼즐`
- `PvP 중심`
- `방치형 성장`

카드 형태의 UI가 존재해도 덱·손패·드로우·장착 기술 제한은 없다. 비동기 경쟁은 후속 콘텐츠이며 제품의 1차 구조는 싱글플레이 1대1 무협 결투다.

## 2. 플레이어 노출 행동 종류 태그

`[관찰]`로 공개할 수 있는 행동 종류는 아래 8종만 사용한다.

- `[전조]`
- `[이동]`
- `[공격]`
- `[방어]`
- `[회피]`
- `[태세]`
- `[자원]`
- `[관찰]`

복합 기술은 `[이동+공격]`처럼 해당 수에서 실제 발생하는 종류를 모두 표시한다.

행동 종류 태그는 다음 정보를 공개하지 않는다.

- 기술명·무공서명
- 정확한 비용
- 방향·거리·사거리
- 피해·방어·회복 수치
- 대상
- AI 가중치·선호 행동·정답 파훼법

공식 랭킹전은 양측 `[관찰]` 행동을 사용하지 않지만, 본편의 행동 종류 태그 정의는 유지한다.

## 3. 전투 규칙 키워드 태그

아래 태그는 행동 종류가 아니라 판정·상태·UI 설명 키워드다.

| 태그 | 책임 의미 |
|---|---|
| `[밀착]` | 거리 0, 같은 칸 상태 |
| `[합]` | 같은 수의 유효 공격 피해 단위를 순서대로 비교하는 판정 |
| `[연격 N]` | 한 공격 행동의 피해를 N개 피해 단위로 분할 |
| `[필중]` | 실제 회피를 무시한 유효 타격에 소비되는 스택 |
| `[강화]` | 기술이 정의한 공격·효과 증폭 상태 |
| `[강건]` | 중단 1회를 방지하는 상태 |
| `[의료]` | 전투 후 회복량에 사용하는 0~4 계획 값 |
| `[실행]` | 다중 수 행동의 최종 발동 슬롯 UI 표기 |
| `[영구재화]` | 같은 전투 재도전 비용 등에 사용하는 메타 자원 자리표시자 |

정확한 수치·판정 순서는 `docs/02_COMBAT_RULES.md`가 소유한다. 이 등록부의 설명만으로 전투 계산을 구현하지 않는다.

## 4. 행동 출처 UI 태그

- `[기초]`: 항상 사용할 수 있는 공용 기초 행동.
- `[무공]`: 무공서에서 현재 해금된 기술.
- `[절초]`: 기본 절초 또는 무공서 10성 절초.

무공서는 성장·분류 단위이며 직접 수 슬롯에 배치하지 않는다. `[무공]` 탭에서 현재 해금 기술을 선택한다.

## 5. 권위 상태

문서·Decision·planning JSON의 `authority_status`는 아래 값 중 하나를 사용한다.

| 상태 | 의미 |
|---|---|
| `CURRENT_APPROVED_PLANNING` | 사용자가 승인한 현재 기획 정본 |
| `POC_HYPOTHESIS` | 비교·편집·검증용 가설이며 제품 약속이 아님 |
| `IMPLEMENTED_LEGACY` | main에서 작동하지만 최신 기획과 다른 구현 |
| `SUPERSEDED` | 후속 Decision으로 대체됨 |
| `HOLD` | 별도 승인 전 활성 작업에서 제외 |

`CURRENT`, `PARTIAL`, `PLANNED`처럼 문맥에 따라 의미가 달라지는 단독 값은 신규 정본에서 사용하지 않는다.

## 6. 콘텐츠 범위 상태

콘텐츠가 어느 제품 단계에 속하는지는 `scope_status`로 분리한다.

| 상태 | 의미 |
|---|---|
| `CURRENT_T0` | 현재 기술 PoC·레거시 실행 범위 |
| `POC_PRIMARY` | 다음 데모 핵심 범위: 주요 비무 1~5 |
| `PLANNED_T1` | 사람 PoC 통과 뒤 검토할 최소 세로 슬라이스 |
| `POC_EXPANSION` | 정식판 주요 비무 6~10 |
| `FUTURE_FINALE` | 주요 비무 10전 이후 천하제일인전 |
| `FUTURE_ONLINE` | 챔피언 배틀·시즌 랭킹 |
| `T2_PLUS_HYPOTHESIS` | PoC·T1 증거 뒤 재검토할 장기 확장 가설 |

`FUTURE_ONLINE_APPROVED_PLANNING_IMPLEMENTATION_BLOCKED`처럼 여러 축을 한 문자열로 합치지 않는다. 예:

```yaml
authority_status: CURRENT_APPROVED_PLANNING
scope_status: FUTURE_ONLINE
implementation_status: NOT_STARTED
validation_status: NOT_RUN
```

## 7. 구현 상태

`implementation_status`는 다음 값만 사용한다.

- `NOT_STARTED`
- `IN_PROGRESS`
- `IMPLEMENTED_LEGACY`
- `IMPLEMENTED_CURRENT`
- `BLOCKED_NOT_AUTHORIZED`
- `DEFERRED`

기획 승인과 구현 승인은 별개다. `CURRENT_APPROVED_PLANNING`이더라도 별도 Build Decision이 없으면 구현 상태는 `NOT_STARTED` 또는 `BLOCKED_NOT_AUTHORIZED`다.

## 8. 검증 상태

`validation_status`는 증거 종류별로 각각 기록한다.

- `PASS`
- `PARTIAL`
- `FAIL`
- `NOT_RUN`
- `BLOCKED`
- `UNVERIFIED`

권장 필드:

```yaml
static_validation:
automated_validation:
godot_validation:
windows_validation:
network_validation:
accessibility_validation:
human_validation:
```

정적 검사나 CI 통과는 Godot·Windows·네트워크·사람 검증을 대신하지 않는다.

## 9. Decision·문서 우선순위

1. 최신 사용자 승인 Decision과 승인 planning JSON.
2. `docs/01~11` 책임 원본.
3. 허브 `ACTIVE_CONTEXT`·`ROADMAP`·Google Sheet 요약.
4. 구현 코드·런타임 데이터. 최신 기획과 다르면 `IMPLEMENTED_LEGACY`로 표시.
5. 과거 PR·Issue·백업·날짜별 역사 문서.

하위 문서가 상위 Decision과 충돌하면 하위 문장을 임의로 해석하지 않고 정본을 갱신한다.

## 10. 개발 전용 태그와 사용자 노출

- 내부 AI archetype·테스트 fixture·개발용 상대 태그는 플레이어에게 직접 노출하지 않는다.
- 사용자 화면에는 무림식 이름·객관 정보·규칙 키워드만 표시한다.
- 내부 태그를 노출해야 할 때는 사용자용 현지화·설명 필드를 별도로 둔다.
- UI가 새로운 태그 의미를 만들거나 전투 판정을 재계산하지 않는다.

## 11. 갱신 체크리스트

새 규칙·콘텐츠·화면·상태를 추가할 때 다음을 확인한다.

- 기존 태그로 표현 가능한가.
- 새 태그가 행동 종류·판정 키워드·제품 범위·검증 상태 중 어느 축인가.
- 동일 의미의 다른 이름이 이미 존재하는가.
- GitHub Decision·책임 원본·planning JSON·Google Sheet가 같은 값을 쓰는가.
- 구현·검증되지 않은 내용을 `PASS`나 `IMPLEMENTED_CURRENT`로 표시하지 않았는가.
- 개발용 태그가 사용자 화면에 노출되지 않는가.

새 태그가 플레이 판단이나 규칙을 바꾸면 별도 GrillMe 승인 Decision이 필요하다. 단순 명칭 정규화와 구형 참조 제거는 문서 유지보수로 처리한다.
