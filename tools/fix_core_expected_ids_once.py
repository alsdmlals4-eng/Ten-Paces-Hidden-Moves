from __future__ import annotations
import json
from pathlib import Path
path=Path(__file__).resolve().parents[1]/'.github/reference-freshness.json'
data=json.loads(path.read_text(encoding='utf-8'))
extensions={'governing-legacy-retention-and-archives','evaluating-godot-assets-and-plugins-before-creation'}
data['expected_base_skill_ids']=[x for x in data['expected_base_skill_ids'] if x not in extensions]
path.write_text(json.dumps(data,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
