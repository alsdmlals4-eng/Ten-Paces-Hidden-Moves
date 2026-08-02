from __future__ import annotations

import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
PATH = ROOT / "skills/PROJECT_BASE_ADAPTER.json"
PAYLOAD = "7dd1a4f80388bc5faca767ff74a3eb32dc9d0ac8"
EVIDENCE = "da33a350d61b8adc52df97fccc7001708a933370"
FINALIZATION = "0b7c94f38d959efc0fc9442274c60b2e268a3c97"
REGISTRY = "693a0dff3f054ecdd653079909e044211473838e73dd9aff07734d1ce5694c59"
SKILL = "managing-project-intake-and-work-contract"
COMMAND = "python tests/test_base_v943_first_prompt_adoption.py"

data = json.loads(PATH.read_text(encoding="utf-8"))
release = data.setdefault("base_release", {})
release.update({"repository": "alsdmlals4-eng/Base", "version": "9.4.3", "release_commit": PAYLOAD, "release_evidence_commit": EVIDENCE, "finalization_commit": FINALIZATION})
if "registry_sha256" in release:
    release["registry_sha256"] = REGISTRY
base_registry = data.get("skill_registry", {}).get("base")
if isinstance(base_registry, dict):
    base_registry["sha256"] = REGISTRY
contract = {"actual_project_instruction_execution": "NOT_RUN", "approval_reuse": "REUSE_EXACT_APPROVAL_REFERENCE", "base_contract_source": "skills/managing-project-intake-and-work-contract/SKILL.md", "base_release_finalization_commit": FINALIZATION, "base_release_lock": "base-v9.4.3.lock.json", "direction_anchor_reference": "skills/managing-project-intake-and-work-contract/references/first-prompt-direction-anchoring.md", "instruction_flow": ["route", "first-prompt", "contract", "clarify"], "l0_exceptions": ["TYPO", "OBVIOUS_FORMAT", "IDENTICAL_VALIDATION_RERUN"], "unconfirmed_state": "AWAITING_USER_CONFIRMATION"}
if "shared_overrides" in data:
    intake = data.setdefault("shared_overrides", {}).setdefault(SKILL, {})
    planning = intake.get("planning_first_governance")
    if isinstance(planning, dict):
        planning["base_release_finalization_commit"] = FINALIZATION
        planning["base_release_lock"] = "base-v9.4.3.lock.json"
    intake["first_prompt_governance"] = contract
else:
    data.setdefault("base_v94_contract", {})["first_prompt_governance"] = contract
validators = data.get("validators")
if isinstance(validators, list):
    commands = {item if isinstance(item, str) else item.get("command") for item in validators}
    if COMMAND not in commands:
        validators.append({"command": COMMAND, "status": "REQUIRED_ON_PULL_REQUEST", "evidence_commit": None} if validators and isinstance(validators[0], dict) else COMMAND)
else:
    data.setdefault("validation", {})["base_v943_first_prompt_adapter"] = "REQUIRED_ON_PULL_REQUEST"
PATH.write_text(json.dumps(data, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
print(f"updated {PATH.relative_to(ROOT)}")
