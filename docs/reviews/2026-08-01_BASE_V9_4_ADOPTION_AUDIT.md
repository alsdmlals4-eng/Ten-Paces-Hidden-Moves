# Base v9.4 프로젝트 적용 감사 — 십보강호

## 판정

```yaml
decision_id: DEC-2026-08-01-001
issue: 67
baseline_commit: 2d8b9fc2a435322ba26860421eecadf356f53a4b
base_version: 9.4.0
base_payload: a728712cb776ec98f4875914a580fcf7d0156593
base_evidence: ef1fba11167e4da0b298123b0c85ebd268191a42
base_finalization: 87a0b54c2847ce4b685879209205957c170cc1cd
base_registry_sha256: 693a0dff3f054ecdd653079909e044211473838e73dd9aff07734d1ce5694c59
adoption_scope: OPERATING_CONTRACT_ONLY
product_paths_changed: false
gdd_sheet_written: false
runtime_validation: NOT_RUN
human_validation: HUMAN_NOT_RUN
```

## 적용

- canonical `PROJECT_BASE_ADAPTER.json`과 generated snapshot·compatibility view를 v9.4 payload/evidence에 맞췄다.
- 공용 route `optimizing-ai-model-and-prompt-costs`를 추가하고 프로젝트 고유 Skill 4개를 보존했다.
- AI Workflow에 `[모델 추천]`, 지시 권위, Interface-first Prompt, Example-as-Fixture, Context 큐레이션, Artifact 주장 상한을 연결했다.
- UX/UI 정본에 입력 접수·처리 중·도메인 결과·결과 표현, 중단·즉시 완료·연타·재진입·Reduced Motion·mute·haptic-off 계약을 연결했다.

## 보호 확인

변경 금지 경로:

```text
data/
src/
scenes/
assets/
addons/
project.godot
```

무공 카드 규칙, 문파, 사거리, 비용, 행동 슬롯, 기력·내력, 전투 코어, 저장 Schema, 승인 아트 방향은 변경하지 않는다.

## 적대적 검토 질문

1. 모션 완료가 전투 판정·비용·보상·저장의 권위 시점이 되었는가.
2. 중단·즉시 완료·빠른 반복·재진입에서 결과가 중복되는가.
3. Context 큐레이션이 반대 근거·실패 사례·보호 규칙을 제거하는가.
4. `[모델 추천]`이 실제 모델 설정 변경을 완료했다고 오인시키는가.
5. 문서·Fixture만으로 Godot 런타임·사람 이해·성능을 PASS 처리하는가.

## 증거 상한

- adapter·snapshot·문서·정적 계약: 자동 검증 대상.
- Godot 실제 화면·Windows·실물 입력·성능: `NOT_RUN`.
- 신규 플레이어 이해·반복 피로·재미: `HUMAN_NOT_RUN`.
- provider 실제 비용·cache hit·절감률: `NOT_RUN`.
