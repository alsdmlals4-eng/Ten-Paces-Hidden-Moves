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
- 작업 게이트: `[기획서]/00_프로젝트_허브/DEVELOPMENT_GATES.md`
- 변경 검증 템플릿: `templates/quality/PROJECT_CHANGE_VALIDATION.md`
- 관련 규칙·범위·아키텍처·UI·연출 본책과 실제 테스트

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
3. 파일 존재·정적 검사·Actions·런타임·사람 검수를 분리한다.
4. 변경된 정본뿐 아니라 untouched 소비자·테스트·파생본을 확인한다.
5. 예상 결과와 실제 결과를 기록한다.
6. 정상 경로만이 아니라 실패·경계·원래 실패해야 하는 반례를 실행한다.
7. 수정 후 좁은 회귀부터 인접 범위로 확장한다.
8. 통과·실패·미실행을 분리 보고한다.

## 현재 주요 제품 검증

- 10칸·3번/8번·발 앵커
- `3수 → 3수 → 4수`와 1수부터 배치
- 슬롯 범위 초과 차단
- 8개 기초 행동·이동 목적지·공격 방향
- `대응 → 속공 → 이동 → 일반 공격`
- 같은 단계 동시 피해
- 막기·회피·태세 연계와 자원 미리보기
- 10수 뒤 다음 라운드
- AI 비공개 정보 미사용
- 저장·재도전·결정론
- 절초 보유·미보유 5전 완주

## 접근성·성능

접근성은 텍스트·대비·정보 채널·입력·탐색·시간·난이도·모션 장벽과 대체 경로를 실제 플레이로 확인한다. 법적 준수 인증으로 표현하지 않는다.

성능은 목표 플랫폼·동일 빌드·대표·최악 장면에서 frame time·CPU·GPU·메모리·로딩을 baseline과 비교한다. 평균 FPS 하나로 통과시키지 않는다.

## 금지

- 체크리스트 존재를 테스트 통과로 간주
- 파일 존재를 실제 실행 성공으로 간주
- 정적 패턴만으로 UI 결함 확정
- Actions 성공을 Windows·접근성·성능·Required Check 통과로 간주
- 실행하지 않은 검증을 암묵적으로 통과 처리

## 완료 기준

- 각 완료 주장에 재현 가능한 증거가 있다.
- 실패와 미검증이 다음 작업으로 연결된다.
- 변경 전후 결과를 비교할 수 있다.
- 사용자·플레이어 이해와 자동 테스트가 분리된다.
- 판정은 `PASS / PARTIAL / FAIL / NOT_RUN` 중 하나다.
