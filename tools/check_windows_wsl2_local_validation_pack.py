from __future__ import annotations

import json
import re
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
CONTRACT = ROOT / "docs/planning-data/approved_20260807_windows_wsl2_local_validation_pack.json"
MANIFEST = ROOT / "tools/local_validation/matrix_contract_commands.json"
WORKFLOW = ROOT / ".github/workflows/full-validation.yml"
EXPECTED_IDS = ["windows-py311", "windows-py312", "windows-py313", "wsl2-ubuntu-py312"]


def main() -> int:
    contract = json.loads(CONTRACT.read_text(encoding="utf-8"))
    manifest = json.loads(MANIFEST.read_text(encoding="utf-8"))
    ids = [item["id"] for item in contract["matrix"]]
    if ids != EXPECTED_IDS:
        raise SystemExit(f"MATRIX_DRIFT: expected={EXPECTED_IDS} actual={ids}")
    if not all(item.get("required") is True for item in contract["matrix"]):
        raise SystemExit("OPTIONAL_ENVIRONMENT_FORBIDDEN")

    workflow_text = WORKFLOW.read_text(encoding="utf-8")
    try:
        block = workflow_text.split("\n  matrix-contracts:\n", 1)[1].split(
            "\n  godot-headless:\n", 1
        )[0]
    except IndexError as exc:
        raise SystemExit("WORKFLOW_JOB_NOT_FOUND: matrix-contracts") from exc
    workflow_commands = re.findall(r"^\s+run:\s+(.+)$", block, re.MULTILINE)
    manifest_commands = [item["workflow_run"] for item in manifest["matrix_contract_commands"]]
    if workflow_commands != manifest_commands:
        raise SystemExit(
            "WORKFLOW_COMMAND_DRIFT: update local manifest before claiming parity"
        )
    if len(workflow_commands) != 15:
        raise SystemExit(f"UNEXPECTED_MATRIX_COMMAND_COUNT: {len(workflow_commands)}")

    print("WINDOWS_WSL2_LOCAL_VALIDATION_PACK_CONTRACT_OK")
    print(f"matrix={','.join(ids)}")
    print(f"matrix_contract_commands={len(workflow_commands)}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
