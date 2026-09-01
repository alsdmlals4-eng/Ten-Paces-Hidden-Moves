from __future__ import annotations

import argparse
import hashlib
import json
import re
import shutil
import struct
import sys
import tempfile
from datetime import UTC, datetime, timedelta
from pathlib import Path
from typing import Any


CAPTURE_ID_RE = re.compile(r"^TEN-RVC-\d{8}-\d{3}$")
COMMIT_RE = re.compile(r"^[0-9a-f]{40}$", re.IGNORECASE)
PNG_SIGNATURE = b"\x89PNG\r\n\x1a\n"
MANIFEST_ROLE = "TEN_RUNTIME_VISUAL_CAPTURE_MANIFEST"
MAX_IMAGE_BYTES = 15 * 1024 * 1024
LAUNCHER_ID = "ISSUE54_HUMAN_VALIDATION_LAUNCHER"
FRESH_ARTIFACT_GATE = "FRESH_RUNTIME_ARTIFACT_GATE"
FRESHNESS_CLOCK_SKEW = timedelta(seconds=2)


class CaptureValidationError(ValueError):
    pass


def sha256_file(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def validate_relative_repository_path(value: str, *, label: str) -> str:
    candidate = Path(value)
    if not value or candidate.is_absolute() or ".." in candidate.parts:
        raise CaptureValidationError(f"{label} must be a non-empty repository-relative path")
    return candidate.as_posix()


def inspect_png(path: Path) -> tuple[int, int, int, str]:
    if not path.is_file():
        raise CaptureValidationError(f"source image does not exist: {path}")
    byte_count = path.stat().st_size
    if byte_count <= 0 or byte_count > MAX_IMAGE_BYTES:
        raise CaptureValidationError(f"source image size must be between 1 and {MAX_IMAGE_BYTES} bytes")

    with path.open("rb") as handle:
        header = handle.read(33)
    if len(header) < 33 or header[:8] != PNG_SIGNATURE:
        raise CaptureValidationError("source image must be a PNG with a valid signature and IHDR header")
    if header[12:16] != b"IHDR" or header[8:12] != b"\x00\x00\x00\x0d":
        raise CaptureValidationError("source image must be a PNG with a valid IHDR chunk")
    width, height = struct.unpack(">II", header[16:24])
    if width <= 0 or height <= 0:
        raise CaptureValidationError("source image must have positive PNG dimensions")
    return width, height, byte_count, sha256_file(path)


def load_manifest(path: Path) -> dict[str, Any]:
    if not path.exists():
        return {
            "schema_version": 1,
            "manifest_role": MANIFEST_ROLE,
            "retention_policy": "MINIMUM_REPRESENTATIVE_CAPTURE_SET",
            "captures": [],
        }
    try:
        manifest = json.loads(path.read_text(encoding="utf-8"))
    except json.JSONDecodeError as exc:
        raise CaptureValidationError(f"manifest is not valid JSON: {path}") from exc
    if not isinstance(manifest, dict) or manifest.get("manifest_role") != MANIFEST_ROLE:
        raise CaptureValidationError(f"manifest role mismatch: {path}")
    if manifest.get("schema_version") != 1 or not isinstance(manifest.get("captures"), list):
        raise CaptureValidationError(f"manifest schema mismatch: {path}")
    return manifest


def load_launch_manifest(
    root: Path,
    path: Path,
    *,
    expected_commit: str,
    source: Path,
) -> dict[str, Any]:
    resolved = path.resolve()
    expected = (
        root
        / "build"
        / "issue54-human-validation"
        / expected_commit
        / "issue54-human-validation-launch.json"
    ).resolve()
    if resolved != expected:
        raise CaptureValidationError(
            "launch manifest must be the exact project run manifest for the source commit"
        )
    if not resolved.is_file():
        raise CaptureValidationError(f"launch manifest does not exist: {resolved}")
    try:
        payload = json.loads(resolved.read_text(encoding="utf-8"))
    except json.JSONDecodeError as exc:
        raise CaptureValidationError(f"launch manifest is not valid JSON: {resolved}") from exc
    if not isinstance(payload, dict) or payload.get("schema_version") != 1:
        raise CaptureValidationError("launch manifest schema mismatch")
    if payload.get("launcher_id") != LAUNCHER_ID:
        raise CaptureValidationError("launch manifest launcher identity mismatch")
    if payload.get("fresh_artifact_gate") != FRESH_ARTIFACT_GATE:
        raise CaptureValidationError("launch manifest does not assert the fresh artifact gate")
    if str(payload.get("exact_git_commit", "")).lower() != expected_commit:
        raise CaptureValidationError("launch manifest source commit mismatch")
    manifest_root = payload.get("project_root")
    if not isinstance(manifest_root, str) or Path(manifest_root).resolve() != root:
        raise CaptureValidationError("launch manifest project root mismatch")
    raw_started = payload.get("created_at_utc")
    if not isinstance(raw_started, str):
        raise CaptureValidationError("launch manifest created_at_utc is required")
    try:
        started = datetime.fromisoformat(raw_started.replace("Z", "+00:00"))
    except ValueError as exc:
        raise CaptureValidationError("launch manifest created_at_utc must be ISO-8601") from exc
    if started.tzinfo is None:
        raise CaptureValidationError("launch manifest created_at_utc must include a timezone")
    started_utc = started.astimezone(UTC)
    source_mtime_utc = datetime.fromtimestamp(source.stat().st_mtime, UTC)
    if source_mtime_utc + FRESHNESS_CLOCK_SKEW < started_utc:
        raise CaptureValidationError(
            "source image is older than launch run; prior artifact existence is not fresh evidence"
        )
    return {
        "launcher_id": LAUNCHER_ID,
        "launch_manifest_path": resolved.relative_to(root).as_posix(),
        "launch_manifest_sha256": sha256_file(resolved),
        "launch_created_at_utc": started_utc.isoformat(),
        "source_mtime_utc": source_mtime_utc.isoformat(),
        "freshness_basis": "SOURCE_MTIME_AT_OR_AFTER_LAUNCH_CREATED_AT_WITH_2S_SKEW",
    }

def atomic_write_json(path: Path, payload: dict[str, Any]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with tempfile.NamedTemporaryFile(
        mode="w",
        encoding="utf-8",
        newline="\n",
        dir=path.parent,
        delete=False,
        prefix=f".{path.stem}.",
        suffix=".tmp",
    ) as temporary:
        json.dump(payload, temporary, ensure_ascii=False, indent=2)
        temporary.write("\n")
        temporary_path = Path(temporary.name)
    temporary_path.replace(path)


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        description="Register a repository-controlled Godot runtime visual capture without upgrading Human/device evidence."
    )
    parser.add_argument("--project-root", required=True, type=Path)
    parser.add_argument("--source-image", required=True, type=Path)
    parser.add_argument("--capture-id", required=True)
    parser.add_argument("--source-commit", required=True)
    parser.add_argument("--launch-manifest", required=True, type=Path)
    parser.add_argument("--scene-path", required=True)
    parser.add_argument("--capture-state", required=True)
    parser.add_argument("--entry-route", required=True)
    parser.add_argument("--work-item-id", required=True)
    parser.add_argument("--consumer", required=True, action="append")
    parser.add_argument("--diagnostics-errors", required=True, type=int)
    parser.add_argument("--diagnostics-warnings", required=True, type=int)
    parser.add_argument("--source-delta", default="NOT_RECORDED")
    parser.add_argument("--allow-additional-state", action="store_true")
    parser.add_argument("--additional-state-reason", default="")
    return parser


def register_capture(args: argparse.Namespace) -> dict[str, Any]:
    root = args.project_root.resolve()
    source = args.source_image.resolve()
    if not root.is_dir():
        raise CaptureValidationError(f"project root does not exist: {root}")
    if not CAPTURE_ID_RE.fullmatch(args.capture_id):
        raise CaptureValidationError("capture ID must match TEN-RVC-YYYYMMDD-NNN")
    if not COMMIT_RE.fullmatch(args.source_commit):
        raise CaptureValidationError("source commit must be an exact 40-character Git SHA")
    if not args.scene_path.startswith("res://") or ".." in Path(args.scene_path.removeprefix("res://")).parts:
        raise CaptureValidationError("scene path must be a safe res:// path")
    if not args.capture_state.strip() or not args.entry_route.strip() or not args.work_item_id.strip():
        raise CaptureValidationError("capture state, entry route, and work item ID are required")
    if args.diagnostics_errors < 0 or args.diagnostics_warnings < 0:
        raise CaptureValidationError("diagnostics counts cannot be negative")
    consumers = [validate_relative_repository_path(value, label="consumer") for value in args.consumer]
    for consumer in consumers:
        if not (root / consumer).is_file():
            raise CaptureValidationError(f"consumer does not exist as a repository file: {consumer}")
    width, height, byte_count, digest = inspect_png(source)
    producer_run = load_launch_manifest(
        root,
        args.launch_manifest,
        expected_commit=args.source_commit.lower(),
        source=source,
    )

    evidence_root = root / "docs" / "evidence"
    capture_dir = evidence_root / "runtime-captures"
    manifest_path = evidence_root / "RUNTIME_VISUAL_CAPTURE_MANIFEST.json"
    manifest = load_manifest(manifest_path)
    existing_ids = {entry.get("capture_id") for entry in manifest["captures"] if isinstance(entry, dict)}
    if args.capture_id in existing_ids:
        raise CaptureValidationError(f"capture ID already exists: {args.capture_id}")

    same_work_item = [
        entry for entry in manifest["captures"]
        if isinstance(entry, dict) and entry.get("work_item_id") == args.work_item_id
    ]
    if len(same_work_item) >= 2 and not args.allow_additional_state:
        raise CaptureValidationError(
            "a third capture for the same work item requires --allow-additional-state and --additional-state-reason"
        )
    if args.allow_additional_state and not args.additional_state_reason.strip():
        raise CaptureValidationError("--allow-additional-state requires --additional-state-reason")

    capture_dir.mkdir(parents=True, exist_ok=True)
    target = capture_dir / f"{args.capture_id}.png"
    if target.exists():
        raise CaptureValidationError(f"capture target already exists: {target}")
    try:
        source.relative_to(capture_dir.resolve())
    except ValueError:
        pass
    else:
        raise CaptureValidationError("source image cannot already be inside the runtime capture directory")

    entry: dict[str, Any] = {
        "capture_id": args.capture_id,
        "recorded_at_utc": datetime.now(UTC).isoformat(),
        "work_item_id": args.work_item_id,
        "source_commit": args.source_commit.lower(),
        "producer_run": producer_run,
        "runtime": {
            "scene_path": args.scene_path,
            "capture_state": args.capture_state,
            "entry_route": args.entry_route,
            "source_delta": args.source_delta,
        },
        "consumers": consumers,
        "diagnostics": {
            "error_count": args.diagnostics_errors,
            "warning_count": args.diagnostics_warnings,
        },
        "image": {
            "path": target.relative_to(root).as_posix(),
            "sha256": digest,
            "bytes": byte_count,
            "format": "PNG",
            "width": width,
            "height": height,
        },
        "evidence_level": "MACHINE_RUNTIME_CAPTURE",
        "evidence_ceiling": {
            "human_usability": "NOT_RUN",
            "android_actual_device": "NOT_RUN",
            "accessibility_user": "NOT_RUN",
            "release_performance": "NOT_RUN",
        },
    }
    if args.allow_additional_state:
        entry["additional_state_reason"] = args.additional_state_reason.strip()

    shutil.copyfile(source, target)
    try:
        if sha256_file(target) != digest:
            raise CaptureValidationError("copied capture hash does not match source hash")
        manifest["captures"].append(entry)
        atomic_write_json(manifest_path, manifest)
    except Exception:
        target.unlink(missing_ok=True)
        raise
    return entry


def main(argv: list[str] | None = None) -> int:
    args = build_parser().parse_args(argv)
    try:
        entry = register_capture(args)
    except CaptureValidationError as exc:
        print(f"runtime visual capture rejected: {exc}", file=sys.stderr)
        return 2
    print(json.dumps({"capture_id": entry["capture_id"], "image": entry["image"]}, ensure_ascii=False))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
