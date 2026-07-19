# Base 규칙 적용 버전

## 기준 정보

- Base 저장소: `alsdmlals4-eng/Base`.
- 기준 브랜치: `main`.
- 기준 커밋: `eb40b912e5f5a0e4d369105a4f0a770e0a6179a9`.
- Base 기준 상태: `v2.1.0 이후 Unreleased schema v3 포함`.
- 프로젝트 동기화 날짜: `2026-07-20`.
- 적용 프로젝트: `alsdmlals4-eng/Ten-Paces-Hidden-Moves`.
- 대상 기준 커밋: `0ac66389ad6b1d10019680ebf1417d423fa1466e`.
- 마이그레이션 Issue: `#4 Base schema v3 운영체계 전면 마이그레이션`.
- 마이그레이션 단계: `Governance foundation / 발행·로컬 구현 감사 대기`.

정식 버전 이름만으로 최신 Unreleased 계약을 재현할 수 없으므로 위 Base 커밋 SHA를 기준선으로 사용한다.

## 적용한 최신 공용 구조

- 루트 `START_HERE.md`와 루트 `[기획서]` 프로젝트 허브.
- schema v3의 문서별 Markdown 또는 JSON 단일 책임 원본 선택.
- Design Document Registry를 통한 책임·경로·발행 상태 라우팅.
- PDF 상시 동기화와 선택 DOCX·다이어그램, Publication Manifest.
- Skill Registry의 선택적 호출, 분야 진입점과 Learning Log.
- Active Context·Handoff·Roadmap·Development Gates·Update Matrix.
- 딥인터뷰 Registry와 사용자 마지막 확인 후 실행 계약.
- 기존 프로젝트의 Audit only → Governance foundation → 승인 이관 → Cleanup 순서.
- 자동 검수와 사람 시각 검수, 파일 존재와 실제 실행 상태의 분리.
- 프로젝트 교훈의 `[수정제안서]` 제안 PR → 사용자 승인 → 별도 Base 구현 PR 계약.
- 필요한 도구·파일·폰트·인증·권한 부재를 정상 완료로 우회하지 않는 계약.

## 기존 v1.9.3에서 유지한 공용 원칙

- 학습형 Base와 프로젝트 전용 데이터의 책임 분리.
- 기획서·로드맵·Active Context·Documentation Map의 지속성 계약.
- 요청을 목적·맥락·경험·범위·제약·산출물·완료·검증으로 변환하는 절차.
- Vertical Slice와 데모의 범위·품질·제작성 검증.
- UI·연출과 도메인 상태 소유 경계.
- 검증 전 설계를 검증된 공용 스킬로 표시하지 않는 지식 상태 규칙.
- 내부 난도·성장 데이터와 세계관 표현의 의미 키 분리.
- 규칙·UI·연출·QA의 원인 추적.
- 대표 하이라이트의 보유·미보유 정상 완주 경로 검증.

## 프로젝트 구체화

십보강호의 실제 수치, 문파·무공·제약 이름, 10-10-10 구조, 5전 데모, Godot 경로, 구현 상태와 테스트 결과는 프로젝트 저장소가 책임진다.

현재 schema v3 적용 방식:

- 기존 `docs/01~11`을 Markdown 단일 책임 원본으로 보존한다.
- `[기획서]/DESIGN_DOCUMENT_REGISTRY.json`에 기존 본책을 등록한다.
- 루트 `[기획서]/00_프로젝트_허브`는 운영 라우터이며 제품 본책 전문을 복제하지 않는다.
- 선택 책임 분야는 게임 디자인, UX·UI·접근성, 개발·엔지니어링, QA, 프로덕션·PM, 통합검수다.
- 기존 본책·백업·보류·Plan은 보존 대조와 별도 승인 전 이동·삭제하지 않는다.

## Base에 이미 반영된 프로젝트 유래 사례

- `BASE_PROJECT_BIDIRECTIONAL_LEARNING_CASE.md`.
- `DIEGETIC_OPPONENT_INFORMATION_CASE.md`.
- `TEN_PACES_RULE_PRESENTATION_TRACEABILITY_CASE.md`.
- `TEN_PACES_OPTIONAL_HIGHLIGHT_VERTICAL_SLICE_CASE.md`.

기존 적용 기록:

- `docs/11_BASE_ADOPTION_AND_LEARNING_LOG.md`.
- `docs/skills/TEN_PACES_PLANNING_HANDOFF_EXTENSION.md`.

## 변경된 환류 계약

기존 프로젝트 규칙의 “안정적인 공용 규칙 자동 Base 승격”은 최신 Base 계약과 충돌하므로 폐기한다.

```text
프로젝트 관찰·검증
→ 프로젝트 고유 값 분리
→ 기존 Base 중복·충돌 확인
→ Base [수정제안서] 제안 전용 PR
→ 사용자 검토·구현 승인
→ 별도 Base 구현 PR
→ 프로젝트 학습 기록 갱신
```

사용자가 특정 Base 변경을 직접 승인한 경우에만 제안 단계를 생략할 수 있다.

## 검증 상태

### 확인됨

- Base 최신 START_HERE·Changelog·Documentation Map·Skill Registry·마이그레이션 Method·Skill·schema v3 Schema와 템플릿을 대조했다.
- 대상 원격의 기존 활성 본책과 Plan을 감사했다.
- 기존 본책을 제거하지 않고 Registry와 운영 허브를 설치했다.

### `MIGRATION_PENDING`

- 각 기획서 PDF·Publication Manifest.
- Project Skill Map PDF·다이어그램.
- 발행 도구·한글 폰트·LibreOffice·Poppler·Mermaid 사전점검.
- PDF 자동 렌더와 사람 시각 검수.

### `[미검증]`

- 사용자 로컬 경로 `C:\Users\user\Documents\바이브코딩\ten-paces-hidden-moves-base-full-11-migration`의 실제 Git 상태와 원격 차이.
- Godot 프로젝트·스크립트·씬·Resource·데이터·테스트·빌드.
- 승인 이미지·실제 캡처와 Asset Manifest.
- GitHub Actions 실제 성공과 Branch protection Required Check.
- 플레이어 문구 학습과 절초 보유·미보유 완주율.

## 갱신 조건

다음 경우 Base `main`의 START_HERE·Documentation Map·Changelog·Skill Registry와 프로젝트 차이를 다시 감사한다.

- Base 기준 커밋을 변경할 때.
- 프로젝트가 새 Base Method·Skill·Template·Schema를 적용할 때.
- 책임 원본·Registry·발행·인수인계·지식 승격 규칙이 바뀔 때.
- 프로젝트 교훈을 Base 제안으로 제출하거나 승인 구현한 뒤.
- 사례의 지식 상태가 관찰·가설·패턴·검증으로 바뀔 때.
- 새 작업자가 현재 Base 기준과 프로젝트 문서의 충돌을 보고할 때.

Base 원격과 프로젝트는 자동 동기화되지 않는다. 이 파일의 커밋 SHA와 프로젝트별 차이가 재현 가능한 기준이다.
