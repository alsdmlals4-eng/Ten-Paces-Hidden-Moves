# 십보강호 활성 컨텍스트

> 현재 상태·다음 작업·위험을 압축한다. 제품 본책 전문은 복제하지 않는다.

## 현재 단계

- 운영 Work Mode: `PLAN → BUILD → REVIEW`
- 운영 주 Skill: `managing-game-project-operating-system`
- 운영 Skill Mode: `audit → reconcile-legacy → migrate → verify`
- Base 기준: `ee265576da7f67d3278f8099dd97d4e714ef0651`
- Base 비교: 이전 기준보다 155개 커밋·70개 파일 변경
- 운영 브랜치·PR: `agent/base-full-11-migration`, Draft PR #5
- 구현 브랜치·PR: `agent/t0-combat-poc-board`, 스택형 Draft PR #7
- 제품 단계: 전투 POC Prototype
- 구현 범위: STEP 0~10, TARGETING 10.5, RESPONSE 10.6, RESOURCE PREVIEW 10.6
- 정적 Actions: 최근 전투 계약·문서 검사 성공
- 사용자 Windows 확인: STEP 0~10·1수부터 배치·범위 초과 차단·이동 목적지·공격 방향
- 사용자 확인 대기: 최신 막기·회피·태세 연계와 배치 즉시 자원 표시
- Branch protection Required Check: 확인·변경하지 않음

## 제품 고정 방향

- 플레이어 정체성: `[강호낭인]`
- 전장: 정확히 10칸
- 시작 위치: 플레이어 3번, 상대 8번
- 라운드: `3수 → 3수 → 4수`, 총 10수
- 10수 완료: 다음 라운드 진입
- 판정 순서: `대응 → 속공 → 이동 → 일반 공격`
- 같은 판정 단계 공격: 동시 피해
- 기초 행동 8종: 이동·보법·막기·회피·속공·강공·명상·태세
- 절초 기세: 최대 5칸
- 카드 비용: 행동 슬롯·기력·내력
- 덱·손패·행동력·공통 `막기 경감` 없음
- 전투 시작 체력·기력·내력: 최대치, 시작 패널티가 있을 때만 감소
- UI·VFX·오디오는 전투 결과를 표현하고 직접 계산하지 않음

## 전투 규칙 보완

- 강공: 슬롯 2, 사거리 2, 기력 1·내력 1, 지정 방향 거리 1·2 공격
- 보법: 슬롯 1, 내력 1, 좌우 1칸 또는 2칸 선택
- 막기: 같은 수는 피해 50% 감소, 같은 묶음은 방어도 감소, 높은 감소량 적용
- 회피: 같은 수 공격 완전 회피
- 태세+막기: 같은 슬롯 결합, 묶음 전체 방어, 방어도 50% 증가
- 태세+회피: 같은 슬롯 결합, 묶음 전체 완전 회피
- 행동 배치: 실행 순서 기준 기력·내력 소모·명상 회복 예상치를 HUD에 즉시 반영
- 자원 부족 계획: 슬롯 표시와 진행 버튼 잠금

## 구현 책임 경로

- 카드 데이터: `data/cards/basic_cards.json`
- 전장·HUD·진행 데이터: `data/combat/`
- 전투 씬: `scenes/combat/`
- UI 씬: `scenes/ui/`
- 판정·전장 코드: `src/combat/`
- UI 코드: `src/ui/`
- 정적·Godot 검증: `tests/`
- Windows 검증 자동화: `tools/verify_and_commit_combat_foundation.ps1`

## Base 동기화 상태

완료:

- 최신 Base 시작 문서·운영 모델·Work Mode 라우팅·Documentation Map·Skill Registry 확인
- 이전 Base 기준 이후 70개 변경 파일 전수 처리표 작성
- Base 기준 SHA·루트 AGENTS·README·START_HERE 갱신

진행 중:

- 프로젝트 허브·Skill Registry·Learning Log 갱신
- Legacy Alias·실행 보고·reconciliation·검증 템플릿 추가
- 정본 최신성·Skill 패키지 무결성 검사와 Workflow 연결
- PR #5·#7 체크리스트 갱신

보류·미검증:

- PDF·Skill Map·Manifest 실제 발행
- 사용자 로컬 미커밋 파일 감사
- RESPONSE 10.6 최신 Windows 런타임
- 접근성 사용자 검수와 목표 플랫폼 성능 프로파일
- Branch protection Required Check 강제

## 즉시 다음 작업

1. Base 동기화 운영 파일과 정적 검사 완료
2. PR #5·#7 파일별 체크리스트와 검증 상태 갱신
3. 사용자 작업본에서 Fetch/Pull 후 Godot F5
4. RESPONSE 10.6 대응 판정과 자원 미리보기 확인
5. 통합 확인 후 STEP 11 피격 중단·집중·강건 진행

## 보호 범위

- 사용자 승인 제품 규칙·UI 방향·자산
- 10칸·3/3/4·8개 기초 행동·5칸 절초 기세
- 기존 `docs/01~11`, `docs/[백업]`, `docs/[보류]`, Plan, PR·Git 이력
- 실행하지 않은 검증의 미검증 상태
- 정상 동작 중인 사용자 변경

## 주요 위험

- 스택 PR #5와 #7의 운영 파일이 서로 달라질 수 있음
- 제품 본책 일부에 과거 `두 행동·2수` 표현이 남아 있을 수 있음
- 정적 Actions 성공은 Godot 런타임·접근성·성능·Required Check를 의미하지 않음
- PDF 발행 도구와 한글 폰트 환경은 아직 검증되지 않음

## 완료 판정

현재 전투 POC는 구현·정적 계약과 사용자 Windows 확인이 부분적으로 연결된 Prototype다. Base 동기화는 운영 파일·검사·두 PR 체크리스트가 최신 SHA와 일치하고 Actions가 성공한 뒤 `VERIFIED_WITH_UNVERIFIED_GATES`로 전환한다.
