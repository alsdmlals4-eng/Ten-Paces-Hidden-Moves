# Base current main thin-adapter 검증 경로

## 기준

- Project baseline: `4032cf550295da6d55646a8fb64fb27acaf1ddc3`.
- Base v9.4.4 compatibility release: `5adc196c0185951f50e49ab5e51586eff8d60886`.
- Base current-main observation: `19355b7ef065a21d0f2b685c7d9be64a4a3970f8`.
- source audit/disposition: `BASE_MAIN_SYNC_AUDIT.md`.
- start/reuse/hygiene receipt: `docs/operations/2026-09-01_BASE_CURRENT_ADAPTER_WORK_CONTRACT_RECEIPT.json`.

## 검증 계약

1. canonical `skills/PROJECT_BASE_ADAPTER.json`이 v9.4.4 release lock/registry와 일치한다.
2. generated compatibility views, router, snapshot, dashboard가 canonical adapter에 정확히 결속된다.
3. current Base receipt gate가 프로젝트의 repository-first authority, 10-game player-facing benchmark gate, scoped hygiene/remove policy를 약화하지 않는다.
4. v9.4.3-only current-pin test/workflow 제거 뒤 `tests/`·`.github/` active executable reference가 남지 않으며 v9.4.4 successor regression이 실행된다.
5. product protected paths가 이번 diff에 없고, runtime/Human/device/release evidence를 상승시키지 않는다.

## 실행 명령

```text
python <Base>/tools/validate_work_contract_receipt.py --receipt docs/operations/2026-09-01_BASE_CURRENT_ADAPTER_WORK_CONTRACT_RECEIPT.json
python <Base>/tools/check_project_operating_contract.py --project-root . --base-repository <Base> --check
python tools/check_project_operating_system.py
python -m unittest tests.test_base_v9_adoption tests.test_base_v942_planning_first_adoption tests.test_base_v944_reuse_first_adoption tests.test_base_current_work_contract_adaptation tests.test_base_v94_ai_operations_adoption tests.test_base_shared_external_ai_adapter -v
```

원격 PR exact head의 required checks와 current Base checkout pin 검증은 local 결과와 별도 evidence다. 이번 범위에는 Godot 실행이나 시각 capture가 없으므로 runtime/Human/device/release는 `NOT_RUN`으로 남는다.
