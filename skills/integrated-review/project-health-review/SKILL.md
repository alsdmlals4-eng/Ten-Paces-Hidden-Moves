---
name: project-health-review
description: Use after migration, publication, major gates, canonical-reference changes, Skill changes, or cold-start failures to audit Ten Paces documentation, registries, skills, publications, automation, and implementation evidence as one operating system.
---

# 십보강호 운영체계 Health Review

## Skill Modes

- `contract-review`: 사용자 요청·작업 계약·실제 변경 대조
- `reference-freshness`: 정본·경로·ID·Schema·정책 소비자 감사
- `health-review`: 운영체계 전체 연결 검수
- `evidence-report`: 상태·증거·위험·다음 행동 보고

## 사용 시점

- 운영체계 설치·마이그레이션·Base SHA 변경 후
- 본책·Registry·Skill·생성기·자동화의 큰 변경 후
- Prototype·Vertical Slice·Production Greenlight 전
- 새 작업자가 책임 원본이나 다음 작업을 찾지 못할 때
- 문서·구현·자산·발행·검증 불일치가 의심될 때

## 감사 영역

1. 루트 START_HERE·AGENTS·Base Rules Version
2. Active Context·Handoff·Roadmap·Gates
3. Design Registry와 단일 책임 원본·발행 정책
4. Skill Registry·Work Mode·Skill Mode·진입점·Learning Log·Legacy Alias
5. 정본·경로·ID·Schema 소비자와 untouched 파일
6. PDF·Manifest·자동 렌더·사용자 시각 검수
7. Visual Source·Asset Manifest·실제 캡처
8. Workflow·Actions·Required Check
9. 실제 코드·데이터·테스트·저장·런타임
10. 접근성 장벽·목표 플랫폼 성능
11. 백업·보류·제거 후보 reconciliation
12. 콜드 스타트와 다음 행동 재현

## 판정 원칙

- 파일 존재와 실행 성공 분리
- 자동 검사와 사람 검수 분리
- 원격과 로컬 작업본 분리
- 계획·구현·검증·미검증 분리
- Work Mode·Skill·Skill Mode 사용 이유와 결과 확인
- changed 파일뿐 아니라 expected-but-untouched 소비자 확인
- 발견 결함을 책임 원본·선행 조건·검증·롤백에 연결

## 결과 형식

| 영역 | 상태 | 증거 | 결함·위험 | 다음 행동 |
|---|---|---|---|---|
|  | PASS/PARTIAL/FAIL/NOT_RUN |  |  |  |

## 실패 조건

- 저장소 접근 없이 완료 주장
- 발행본이 없거나 stale인데 CURRENT 판정
- Workflow 파일만 보고 CI 통과 판정
- Godot 실행 증거 없이 런타임 완료 판정
- 보존 대조·사용자 승인 없이 기존 본책·자산 제거
- 정본 변경 뒤 소비자·테스트·파생본 누락
- 콜드 스타트 실패를 문서 수 증가만으로 해결
- 접근성·성능 미실행을 통과로 보고

## 완료 기준

- 새 작업자가 10분 안에 목적·현재 상태·다음 작업·보호 범위·책임 원본·검증을 찾는다.
- Registry와 실제 경로·Skill 패키지가 일치한다.
- 현재 제품 규칙과 Entry Point에 stale 표현이 없다.
- 발행·자동화·런타임·접근성·성능 미검증이 숨겨지지 않는다.
- 발견 결함에 책임자·선행 조건·검증·롤백이 연결된다.
