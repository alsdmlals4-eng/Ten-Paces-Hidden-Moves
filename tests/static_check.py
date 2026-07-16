#!/usr/bin/env python3
from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parents[1]
checks = {
    "project main scene": 'run/main_scene="res://scenes/combat_playtest.tscn"' in (ROOT/"project.godot").read_text(),
    "scene script": 'res://src/ui/combat_playtest.gd' in (ROOT/"scenes/combat_playtest.tscn").read_text(),
    "simulator class": "class_name CombatSimulator" in (ROOT/"src/combat/combat_simulator.gd").read_text(),
    "momentum cap": "MOMENTUM_MAX := 6" in (ROOT/"src/combat/combat_simulator.gd").read_text(),
    "test runner": "extends SceneTree" in (ROOT/"tests/run_all.gd").read_text(),
}
failed = [name for name, ok in checks.items() if not ok]
for name, ok in checks.items(): print(("PASS" if ok else "FAIL"), "·", name)
sys.exit(1 if failed else 0)
