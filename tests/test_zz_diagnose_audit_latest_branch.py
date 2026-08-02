from __future__ import annotations

import inspect
import json
import unittest
from pathlib import Path

import tests.test_audit_latest_branch as target


class AuditLatestBranchDiagnosticTests(unittest.TestCase):
    def test_expose_audit_module_contract(self) -> None:
        globals_snapshot: dict[str, str] = {}
        for name, value in vars(target).items():
            if name.startswith("__"):
                continue
            if isinstance(value, (str, int, float, bool, type(None), Path, list, tuple, dict, set)):
                globals_snapshot[name] = repr(value)

        payload = {
            "module_file": str(Path(target.__file__).resolve()),
            "globals": globals_snapshot,
            "class_source": inspect.getsource(target.AuditLatestBranchTests),
        }
        self.fail("AUDIT_LATEST_BRANCH_DIAGNOSTIC=" + json.dumps(payload, ensure_ascii=False, sort_keys=True))
