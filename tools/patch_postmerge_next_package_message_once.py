#!/usr/bin/env python3
from pathlib import Path

path = Path(__file__).resolve().parents[1] / "tools/check_postmerge_canon_lifecycle.py"
text = path.read_text(encoding="utf-8")
old = '        "active_decision_state": "active decision state differs",\n        "next_planning_decision": "next planning decision differs",\n'
new = '        "active_decision_state": "active decision state differs",\n        "next_package": "next package differs",\n        "next_planning_decision": "next planning decision differs",\n'
if old not in text:
    raise SystemExit("expected postmerge message mapping not found")
path.write_text(text.replace(old, new, 1), encoding="utf-8")
