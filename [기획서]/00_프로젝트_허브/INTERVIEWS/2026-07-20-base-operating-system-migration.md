# INT-2026-001 — Base schema v3 전면 마이그레이션

## 원 요청

사용자는 `alsdmlals4-eng/Base`를 전부 읽고 Base의 구조와 기획대로 `Ten-Paces-Hidden-Moves`를 정리·최신화·갱신하도록 요청했다. 로컬 작업본 경로로 다음을 제공했다.

`C:\Users\user\Documents\바이브코딩\ten-paces-hidden-moves-base-full-11-migration`

## 저장소 사실

- 대상 원격 `main`은 문서 중심 구조다.
- 루트 `[기획서]`, Design Registry, Skill Registry, Development Gates, PDF·Manifest, GitHub Governance가 없었다.
- 기존 `docs/01~11`은 프로젝트 고유 기획과 상태를 보존한 활성 Markdown 본책이다.
- 원격에서는 Godot 프로젝트·코드·테스트·자산을 확인하지 못했다.
- 현재 실행 환경에서는 제공된 Windows 경로가 마운트되지 않았다.
- Base 최신 `main`은 schema v3, Markdown/JSON 단일 책임 원본 선택, PDF 상시 동기화, 선택적 스킬, 딥인터뷰, 제안 승인, Governance·Health Review 계약을 포함한다.

## 사용자 결정으로 해석한 항목

- Base 최신 구조에 맞춘 전면 정리·최신화·갱신을 승인함.
- 기존 프로젝트 고유 기획과 작업 이력은 보존함.
- 로컬 폴더명 `base-full-11-migration`을 작업 브랜치·마이그레이션 식별에 반영함.
- 대규모 삭제보다 비파괴 이관·검증을 우선함.

## 실행 결정

- Issue #4와 전용 브랜치에서 작업한다.
- 기존 `docs` 본책은 schema v3 Markdown 책임 원본으로 등록한다.
- 루트 `[기획서]` 허브와 Registry·Gates·Handoff·Update Matrix를 설치한다.
- 최신 Base와 충돌하는 자동 승격 규칙을 제안·승인 계약으로 바꾼다.
- 로컬·Godot·PDF·Actions는 실제 검증 전 `[미검증]` 또는 `MIGRATION_PENDING`으로 남긴다.
- 기존 본책·백업·보류·Plan은 보존 대조와 별도 승인 전 삭제하지 않는다.

## 남은 모호성

- Windows 작업본의 실제 파일·Git 상태·원격 차이.
- PDF 생성에 사용할 한글 폰트·도구 환경.
- 기존 승인 이미지와 실제 캡처의 위치.
- Branch protection의 Required Check 강제 여부.

이 항목들은 현재 구조 설치를 막지 않지만 M4·M5 게이트를 막는다.

## 마지막 확인 근거

사용자가 명시적으로 Base 전체 구조와 기획에 따른 대상 저장소 정리·최신화·갱신을 요청했고 로컬 마이그레이션 경로를 제공했다. 이를 Governance foundation과 비파괴 이관 실행에 대한 최종 확인으로 기록한다.
