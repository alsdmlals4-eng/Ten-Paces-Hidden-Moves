---
name: project-health-review
description: Use after migration, publication, major gates, or cold-start failures to audit Ten Paces documentation, registries, skills, publications, automation, and actual implementation evidence as one operating system.
---

# 십보강호 운영체계 Health Review

## 사용 시점

- 운영체계 설치·마이그레이션 직후.
- 본책·Registry·스킬·생성기·자동화의 큰 변경 후.
- Prototype·Vertical Slice·Production 등 주요 Greenlight 전.
- 새 작업자가 책임 원본이나 다음 작업을 찾지 못할 때.
- 문서·구현·자산·PDF·검증 불일치가 의심될 때.

## 감사 영역

1. 루트 START_HERE와 `[기획서]` 위치.
2. Active Context·Handoff·Roadmap·Gates.
3. Design Document Registry와 단일 책임 원본.
4. Skill Registry·진입점·Learning Log.
5. PDF·Manifest·자동 렌더·사람 시각 검수.
6. Visual Source·Asset Manifest·실제 캡처.
7. GitHub Workflow 파일·Actions 결과·Required Check.
8. 실제 코드·데이터·테스트·저장 경로.
9. 백업·보류·제거 후보 수명주기.
10. 콜드 스타트 질문과 다음 행동 재현.

## 판정 원칙

- 파일 존재와 실행 성공을 분리한다.
- 자동 검사와 사람 검수를 분리한다.
- 원격과 로컬 작업본을 분리한다.
- 계획·구현·검증·미검증을 분리한다.
- 누락을 발견하면 관련 책임 원본과 다음 게이트를 연결한다.

## 결과 형식

| 영역 | 상태 | 증거 | 결함·위험 | 다음 행동 |
|---|---|---|---|---|
|  | VERIFIED/PARTIAL/BLOCKED/NOT_RUN |  |  |  |

## 실패 조건

- 저장소 접근 없이 완료 주장.
- PDF가 없는데 발행 CURRENT 판정.
- Actions 파일만 보고 CI 통과 판정.
- 구현 파일 없이 Prototype 이상 판정.
- 보존 대조 없이 기존 본책 제거.
- 콜드 스타트 실패를 문서 수 증가로만 해결.

## 완료 기준

- 새 작업자가 10분 안에 목적·현재 상태·다음 작업·보호 범위·책임 원본·검증을 찾는다.
- Registry와 실제 경로가 일치한다.
- 발행·자동화·구현의 미검증이 숨겨지지 않는다.
- 발견된 결함에 책임자·선행 조건·검증이 연결된다.
