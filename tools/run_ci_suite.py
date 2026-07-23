from __future__ import annotations

import argparse
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]

DOC_COMPILE = [
    "tools/check_project_operating_system.py",
    "tools/check_canonical_reference_freshness.py",
    "tools/check_skill_package_integrity.py",
    "tests/test_project_governance.py",
    "tests/check_canonical_combat_docs.py",
]
CODE_COMPILE = [
    "tests/check_card_component_contract.py",
    "tests/check_combat_board_contract.py",
    "tests/test_ci_scope.py",
    "tests/test_ci_policy.py",
]


def run(label: str, args: list[str]) -> None:
    print(f"\n== {label} ==", flush=True)
    subprocess.run(args, cwd=ROOT, check=True)


def run_docs() -> None:
    run("Compile documentation validators", [sys.executable, "-m", "py_compile", *DOC_COMPILE])
    run(
        "Validate project operating system",
        [
            sys.executable,
            "tools/check_project_operating_system.py",
            "--root",
            ".",
            "--config",
            ".github/documentation-governance.json",
        ],
    )
    run(
        "Validate canonical reference freshness",
        [
            sys.executable,
            "tools/check_canonical_reference_freshness.py",
            "--root",
            ".",
            "--config",
            ".github/reference-freshness.json",
        ],
    )
    run("Validate Skill package integrity", [sys.executable, "tools/check_skill_package_integrity.py"])
    run(
        "Run governance regression tests",
        [sys.executable, "-m", "unittest", "discover", "-s", "tests", "-p", "test_project_governance.py"],
    )
    run("Validate canonical combat impact map", [sys.executable, "tests/check_canonical_combat_docs.py"])


def run_code() -> None:
    run_docs()
    run("Compile code contract validators", [sys.executable, "-m", "py_compile", *CODE_COMPILE])
    run("Validate card component contract", [sys.executable, "tests/check_card_component_contract.py"])
    run("Validate combat board contract", [sys.executable, "tests/check_combat_board_contract.py"])
    run(
        "Run CI policy regression tests",
        [sys.executable, "-m", "unittest", "discover", "-s", "tests", "-p", "test_ci_*.py"],
    )


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Run the shared static CI contract suite.")
    parser.add_argument("scope", choices=("docs", "code", "full"))
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    if args.scope == "docs":
        run_docs()
    else:
        run_code()
    print(f"\nCI_SUITE_OK scope={args.scope}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
