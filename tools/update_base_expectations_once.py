from __future__ import annotations
import json
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
BASE_SHA="c987647d01ad2baa028a16e03d85ddfc1572a727"
OLD="41a20584dd2ee51d917e5c9d7cab6838e1ceba7e"
config_path=ROOT/".github/reference-freshness.json"
config=json.loads(config_path.read_text(encoding="utf-8"))
config["expected_base_commit"]=BASE_SHA
for skill in ("governing-legacy-retention-and-archives","evaluating-godot-assets-and-plugins-before-creation"):
    if skill not in config["expected_base_skill_ids"]:
        config["expected_base_skill_ids"].append(skill)
for path in ("README.md","docs/BASE_RULES_VERSION.md","[기획서]/00_프로젝트_허브/SKILL_REGISTRY.json"):
    tokens=config.get("required_current_tokens",{}).get(path)
    if tokens:
        config["required_current_tokens"][path]=[BASE_SHA if token==OLD else "27개" if token=="25개" else token for token in tokens]
config_path.write_text(json.dumps(config,ensure_ascii=False,indent=2)+"\n",encoding="utf-8")
readme=ROOT/"README.md"
t=readme.read_text(encoding="utf-8").replace(f"base_commit: {OLD}",f"base_commit: {BASE_SHA}")
readme.write_text(t,encoding="utf-8")
version=ROOT/"docs/BASE_RULES_VERSION.md"
t=version.read_text(encoding="utf-8")
t=t.replace("코어 25개 Skill 집합","전체 ACTIVE 27개 Skill 집합")
t=t.replace("### Base 활성 Skill 25개","### Base 활성 Skill 27개")
t=t.replace("이 extension은 코어 25개 집합","이 extension은 전체 ACTIVE 27개 집합")
t=t.replace("Base 활성 Skill 25개","Base 활성 Skill 27개")
t=t.replace(f"Base 코어 commit `{OLD}`",f"Base 현재 commit `{BASE_SHA}`")
t=t.replace("### 코어 25개 Skill 동기화","### 전체 ACTIVE 27개 Skill 동기화")
anchor="25. `diagnosing-game-engine-runtime-failures`"
if "26. `governing-legacy-retention-and-archives`" not in t:
    t=t.replace(anchor,anchor+"\n26. `governing-legacy-retention-and-archives`\n27. `evaluating-godot-assets-and-plugins-before-creation`")
version.write_text(t,encoding="utf-8")
