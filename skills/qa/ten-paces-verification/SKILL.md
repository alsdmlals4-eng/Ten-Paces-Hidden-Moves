---
name: ten-paces-verification
description: Use when Ten Paces design, implementation, UI, data, save, build, publication, accessibility, performance, or player-understanding claims require observable evidence.
---

# 십보강호 검증

## Skill Modes

- `contract-check`: 작업 계약·정본·실제 diff 대조
- `static-validation`: 문법·경로·Registry·정본 최신성
- `runtime-validation`: Godot 파싱·headless·Windows 실행
- `accessibility-review`: 실제 플레이 장벽·대체 경로
- `performance-profile`: 목표 플랫폼 예산·baseline 비교
- `regression`: 정상·실패·경계·기존 동작 회귀
- `evidence-report`: 통과·실패·미실행 증거 보고

## 책임 원본

- 제품 체크리스트: `docs/08_TEST_CHECKLIST.md`
- 전투 규칙: `docs/02_COMBAT_RULES.md`
- POC 범위: `docs/05_COMBAT_POC_SPEC.md`
- 작업 게이트: `[기획서]/00_프로젝트_허브/DEVELOPMENT_GATES.md`
- 변경 검증 템플릿: `templates/quality/PROJECT_CHANGE_VALIDATION.md`
- 실제 데이터·코드·테스트: `data/`, `scenes/`, `src/`, `tests/`

## 검증 순서

```text
contract-check
→ reference-freshness
→ format·syntax·static
→ automated tests
→ runtime·render·build
→ 적용 시 accessibility-review
→ 적용 시 performance-profile
→ normal·failure·edge·counterexample
→ save·load·compatibility
→ adjacent regression
→ evidence-report
```

## 절차

1. 검증할 주장·실패 조건·필요 증거를 적는다.
2. 입력·환경·도구·권한·버전·명령을 확인한다.
3. 파일 존재·정적 검사·Actions·Godot·Windows·사람 검수를 분리한다.
4. 변경된 정본에서 데이터·코드·씬·자산·테스트·문서·Skill·Context까지 영향 지도를 만든다.
5. 변경된 파일뿐 아니라 갱신됐어야 할 untouched 소비자를 확인한다.
6. 정상 경로만이 아니라 실패·경계·원래 실패해야 하는 반례를 실행한다.
7. 수정 후 좁은 회귀부터 인접 범위로 확장한다.
8. 통과·실패·미실행을 분리 보고한다.

## 현재 주요 제품 검증

- 전장 10칸·플레이어 4번·상대 7번·시작 거리 3.
- BoardPreview 계약 누락 fallback도 4번·7번.
- 캐릭터 발 앵커와 배치 기준 SVG.
- 기본 이동 4→3/5, 보법 4→2/3/5/6.
- 고정 fixture 첫 이동 4→5·7→6.
- 시작 거리 3의 속공·강공 사거리 실패.
- `3수 → 3수 → 4수`와 1수부터 배치.
- 슬롯 범위 초과 차단.
- 8개 기초 행동·이동 목적지·공격 방향.
- `대응 → 속공 → 이동 → 일반 공격`.
- 같은 단계 동시 피해.
- 막기·회피·태세 연계와 자원 미리보기.
- 10수 뒤 다음 라운드.
- STEP 11 이후 중단·집중·강건.
- STEP 12 이후 AI 비공개 정보 미사용.
- STEP 13 이후 종료·4/7 재시작.
- T1 이후 저장·재도전·결정론.

## 정본 최신성 차단

다음은 병합 차단 결함이다.

- 활성 문서·Skill·Entry Point가 구형 시작 위치를 현행으로 설명.
- 전장 JSON은 4/7인데 코드 fallback·Godot fixture·SVG가 다른 값.
- 중복 Active Context가 독립 제품 사실을 보유.
- T1 이후 성장 가설이 T0 구현 완료처럼 표시.
- 백업·보류 파일을 활성 구현 기본 참조로 사용.

과거 PR·Git 이력·Change Log의 당시 표현은 `ALLOWED_LEGACY`로 구분한다.

## 접근성·성능

접근성은 텍스트·대비·정보 채널·입력·탐색·시간·난이도·모션 장벽과 대체 경로를 실제 플레이로 확인한다. 법적 준수 인증으로 표현하지 않는다.

성능은 목표 플랫폼·동일 빌드·대표·최악 장면에서 frame time·CPU·GPU·메모리·로딩을 baseline과 비교한다. 평균 FPS 하나로 통과시키지 않는다.

## 금지

- 체크리스트 존재를 테스트 통과로 간주.
- 파일 존재를 실제 실행 성공으로 간주.
- 정적 패턴만으로 UI 결함 확정.
- Actions 성공을 Windows·접근성·성능·Required Check 통과로 간주.
- 실행하지 않은 검증을 암묵적으로 통과 처리.
- 구형 fixture가 테스트를 통과한다는 이유로 사용자 확정값을 되돌림.

## 완료 기준

- 각 완료 주장에 재현 가능한 증거가 있다.
- 시작 위치가 데이터·fallback·state·test·SVG·문서·Skill에서 일치한다.
- 실패와 미검증이 다음 작업으로 연결된다.
- 변경 전후 결과를 비교할 수 있다.
- 사용자·플레이어 이해와 자동 테스트가 분리된다.
- 판정은 `PASS / PARTIAL / FAIL / NOT_RUN / BLOCKED` 중 하나다.
