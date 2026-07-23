from __future__ import annotations

import argparse
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]

PR_VERIFIERS = [
    "res://tests/verify_step0.gd",
    "res://tests/verify_combat_board.gd",
    "res://tests/verify_response_rules.gd",
    "res://tests/verify_ultimate_interrupt_engagement.gd",
    "res://tests/verify_ultimate_ui.gd",
    "res://tests/verify_combat_presentation_liveness.gd",
    "res://tests/verify_combat_terminal_presentation.gd",
    "res://tests/verify_combat_sfx_presentation.gd",
    "res://tests/verify_combat_character_art.gd",
    "res://tests/verify_combat_focus_visuals.gd",
    "res://tests/verify_combat_focus_order.gd",
    "res://tests/verify_combat_assistive_labels.gd",
    "res://tests/verify_combat_pointer_lock.gd",
    "res://tests/verify_combat_presentation_controls.gd",
    "res://tests/verify_combat_keyboard_accessibility.gd",
    "res://tests/verify_combat_layout_accessibility.gd",
]
FULL_ONLY_VERIFIERS = ["res://tests/verify_combat_performance_headless.gd"]


def run(label: str, command: list[str]) -> None:
    print(f"\n== {label} ==", flush=True)
    subprocess.run(command, cwd=ROOT, check=True)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Run Godot headless project and combat verifiers.")
    parser.add_argument("--godot", required=True)
    parser.add_argument("--profile", choices=("pr", "full"), default="pr")
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    godot = str(Path(args.godot).resolve())
    run("Godot version", [godot, "--version"])
    run("Import and parse project", [godot, "--headless", "--editor", "--path", str(ROOT), "--quit"])
    verifiers = [*PR_VERIFIERS]
    if args.profile == "full":
        verifiers.extend(FULL_ONLY_VERIFIERS)
    for verifier in verifiers:
        run(verifier, [godot, "--headless", "--path", str(ROOT), "--script", verifier])
    run("Verify tracked files unchanged", ["git", "diff", "--exit-code"])
    print(f"\nGODOT_CI_OK profile={args.profile}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
