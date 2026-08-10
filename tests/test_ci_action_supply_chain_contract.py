from __future__ import annotations

import re
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
WORKFLOWS = ROOT / ".github" / "workflows"
FULL_SHA = re.compile(r"^[0-9a-f]{40}$")
USES = re.compile(r"^\s*(?:-\s*)?uses:\s*([^\s#]+)", re.MULTILINE)

BASE_CURRENT_PINS = {
    "actions/checkout": "3d3c42e5aac5ba805825da76410c181273ba90b1",  # v7.0.1
    "actions/setup-python": "5fda3b95a4ea91299a34e894583c3862153e4b97",  # v7.0.0
    "actions/upload-artifact": "043fb46d1a93c77aae656e7c1c64a875d1fc6a0a",  # v7.0.1
}


class CiActionSupplyChainContractTests(unittest.TestCase):
    def test_remote_action_uses_are_immutable_and_base_owned_pins_match(self) -> None:
        violations: list[str] = []
        seen_base_actions: set[str] = set()

        for workflow in sorted(WORKFLOWS.glob("*.y*ml")):
            text = workflow.read_text(encoding="utf-8")
            for target in USES.findall(text):
                if target.startswith("./"):
                    continue
                if target.startswith("docker://"):
                    violations.append(
                        f"{workflow.relative_to(ROOT)}: docker use needs an explicit digest policy: {target}"
                    )
                    continue
                if "@" not in target:
                    violations.append(
                        f"{workflow.relative_to(ROOT)}: remote use has no ref: {target}"
                    )
                    continue

                action, ref = target.rsplit("@", 1)
                if not FULL_SHA.fullmatch(ref):
                    violations.append(
                        f"{workflow.relative_to(ROOT)}: mutable remote ref {target}"
                    )
                    continue

                if action in BASE_CURRENT_PINS:
                    seen_base_actions.add(action)
                    expected = BASE_CURRENT_PINS[action]
                    if ref != expected:
                        violations.append(
                            f"{workflow.relative_to(ROOT)}: {action} pin {ref} != Base current {expected}"
                        )

        self.assertEqual(
            set(BASE_CURRENT_PINS),
            seen_base_actions,
            "The active workflow fleet must exercise every Base-owned action family in this contract.",
        )
        self.assertFalse(
            violations,
            "Mutable/stale remote action refs found:\n" + "\n".join(violations),
        )


if __name__ == "__main__":
    unittest.main()
