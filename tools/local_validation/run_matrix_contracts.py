from __future__ import annotations

import argparse
import hashlib
import json
import os
import platform
import subprocess
import sys
import time
from datetime import datetime, timezone
from pathlib import Path
from typing import Any, Iterable, Sequence


def utc_now() -> str:
    return datetime.now(timezone.utc).isoformat()


def sha256_text(text: str) -> str:
    return hashlib.sha256(text.encode("utf-8", errors="replace")).hexdigest()


def run_capture(args: Sequence[str], cwd: Path) -> subprocess.CompletedProcess[str]:
    return subprocess.run(
        list(args),
        cwd=cwd,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        check=False,
        env=os.environ.copy(),
    )


def git_head(root: Path) -> str:
    result = run_capture(["git", "rev-parse", "HEAD"], root)
    if result.returncode != 0:
        raise RuntimeError(f"GIT_HEAD_UNAVAILABLE: {result.stdout.strip()}")
    return result.stdout.strip()


def git_status_porcelain(root: Path) -> str:
    result = run_capture(["git", "status", "--porcelain"], root)
    if result.returncode != 0:
        raise RuntimeError(f"GIT_STATUS_UNAVAILABLE: {result.stdout.strip()}")
    return result.stdout


def git_is_clean(root: Path) -> bool:
    return git_status_porcelain(root).strip() == ""


def require_python_version(expected: str, actual: Sequence[int] | None = None) -> None:
    version = tuple(actual if actual is not None else sys.version_info[:3])
    expected_tuple = tuple(int(part) for part in expected.split("."))
    if tuple(version[:2]) != expected_tuple:
        raise RuntimeError(
            "PYTHON_VERSION_MISMATCH: "
            f"expected={expected} actual={version[0]}.{version[1]}.{version[2]}"
        )


def load_manifest(path: Path) -> dict[str, Any]:
    payload = json.loads(path.read_text(encoding="utf-8"))
    if payload.get("schema_version") != 1:
        raise RuntimeError("UNSUPPORTED_COMMAND_MANIFEST_SCHEMA")
    return payload


def build_args(raw_args: Iterable[str], python_executable: str) -> list[str]:
    return [python_executable if value == "{python}" else value for value in raw_args]


def safe_id(value: str) -> str:
    return "".join(character if character.isalnum() or character in "-_" else "_" for character in value)


def write_json(path: Path, payload: dict[str, Any]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(payload, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")


def execute_commands(
    *,
    commands: Sequence[dict[str, Any]],
    root: Path,
    environment_id: str,
    log_root: Path,
) -> list[dict[str, Any]]:
    results: list[dict[str, Any]] = []
    for index, command in enumerate(commands, start=1):
        command_id = str(command["id"])
        args = build_args(command["args"], sys.executable)
        started = time.monotonic()
        process = run_capture(args, root)
        duration = round(time.monotonic() - started, 6)
        output = process.stdout
        log_path = log_root / safe_id(environment_id) / f"{index:02d}-{safe_id(command_id)}.log"
        log_path.parent.mkdir(parents=True, exist_ok=True)
        log_path.write_text(output, encoding="utf-8", errors="replace")
        record = {
            "id": command_id,
            "display": command["workflow_run"],
            "args": args,
            "exit_code": process.returncode,
            "duration_seconds": duration,
            "log_path": str(log_path.relative_to(root)).replace("\\", "/"),
            "log_sha256": sha256_text(output),
            "status": "PASS" if process.returncode == 0 else "FAIL",
        }
        results.append(record)
        if process.returncode != 0:
            break
    return results


def run_suite(args: argparse.Namespace) -> int:
    root = Path(args.root).resolve()
    output_root = (root / args.output_root).resolve() if not Path(args.output_root).is_absolute() else Path(args.output_root)
    result_path = output_root / "results" / f"{safe_id(args.environment_id)}.json"
    result: dict[str, Any] = {
        "schema_version": 1,
        "environment_id": args.environment_id,
        "status": "FAIL",
        "started_at_utc": utc_now(),
        "finished_at_utc": None,
        "expected_python": args.expected_python,
        "actual_python": platform.python_version(),
        "python_executable": sys.executable,
        "platform": platform.platform(),
        "expected_head": args.expected_head,
        "actual_head": None,
        "clean_before": False,
        "clean_after": False,
        "commands": [],
        "failure": None,
    }
    exit_code = 1
    try:
        require_python_version(args.expected_python)
        actual_head = git_head(root)
        result["actual_head"] = actual_head
        if actual_head != args.expected_head:
            raise RuntimeError(
                f"EXACT_HEAD_MISMATCH: expected={args.expected_head} actual={actual_head}"
            )
        result["clean_before"] = git_is_clean(root)
        if not result["clean_before"]:
            raise RuntimeError("DIRTY_TREE_BEFORE_VALIDATION")

        manifest = load_manifest((root / args.command_manifest).resolve())
        commands = list(manifest["pack_self_check_commands"]) + list(
            manifest["matrix_contract_commands"]
        )
        result["commands"] = execute_commands(
            commands=commands,
            root=root,
            environment_id=args.environment_id,
            log_root=output_root / "logs",
        )
        all_passed = len(result["commands"]) == len(commands) and all(
            item["status"] == "PASS" for item in result["commands"]
        )
        result["clean_after"] = git_is_clean(root)
        if not result["clean_after"]:
            raise RuntimeError("DIRTY_TREE_AFTER_VALIDATION")
        if not all_passed:
            raise RuntimeError("COMMAND_FAILURE")
        result["status"] = "PASS"
        exit_code = 0
    except Exception as exc:  # fail-closed evidence path
        result["failure"] = f"{type(exc).__name__}: {exc}"
    finally:
        result["finished_at_utc"] = utc_now()
        write_json(result_path, result)
    return exit_code


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description="Run one local matrix-contract environment")
    parser.add_argument("--root", required=True)
    parser.add_argument("--environment-id", required=True)
    parser.add_argument("--expected-python", required=True)
    parser.add_argument("--expected-head", required=True)
    parser.add_argument("--output-root", default="build/local-validation")
    parser.add_argument(
        "--command-manifest",
        default="tools/local_validation/matrix_contract_commands.json",
    )
    return parser


def main() -> int:
    return run_suite(build_parser().parse_args())


if __name__ == "__main__":
    raise SystemExit(main())
