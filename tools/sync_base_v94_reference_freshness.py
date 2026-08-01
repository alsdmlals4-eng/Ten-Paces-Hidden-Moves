#!/usr/bin/env python3
from __future__ import annotations

import json
from pathlib import Path

path = Path('.github/reference-freshness.json')
data = json.loads(path.read_text(encoding='utf-8'))

skill_id = 'optimizing-ai-model-and-prompt-costs'
expected = data['expected_base_skill_ids']
if skill_id not in expected:
    expected.append(skill_id)

required = data['required_current_tokens']['docs/BASE_RULES_VERSION.md']
if '27개' in required:
    required[required.index('27개')] = '28개'
elif '28개' not in required:
    raise SystemExit('Base skill count token missing')

path.write_text(json.dumps(data, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')
