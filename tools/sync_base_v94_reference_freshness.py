#!/usr/bin/env python3
from __future__ import annotations

import json
from pathlib import Path

skill_id = 'optimizing-ai-model-and-prompt-costs'

config_path = Path('.github/reference-freshness.json')
config = json.loads(config_path.read_text(encoding='utf-8'))
expected = config['expected_base_skill_ids']
if skill_id not in expected:
    expected.append(skill_id)
required = config['required_current_tokens']['docs/BASE_RULES_VERSION.md']
if '27개' in required:
    required[required.index('27개')] = '28개'
elif '28개' not in required:
    raise SystemExit('Base skill count token missing')
config_path.write_text(json.dumps(config, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')

registry_path = Path('[기획서]/00_프로젝트_허브/SKILL_REGISTRY.json')
registry = json.loads(registry_path.read_text(encoding='utf-8'))
routes = registry['base_integration']['shared_skill_routes']
routes.setdefault('model_prompt_cost_optimization', skill_id)
registry_path.write_text(json.dumps(registry, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')
