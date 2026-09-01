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
RUN_ID_RE = re.compile(r"^[A-Za-z0-9][A-Za-z0-9._:-]{0,127}$")
DIGEST_RE = re.compile(r"^[0-9a-f]{64}$")
PNG_SIGNATURE = b"\x89PNG\r\n\x1a\n"
MANIFEST_ROLE = "TEN_RUNTIME_VISUAL_CAPTURE_MANIFEST"
PRODUCER_RECEIPT_ROLE = "TEN_RUNTIME_VISUAL_CAPTURE_PRODUCER_RECEIPT"
MAX_IMAGE_BYTES = 15 * 1024 * 1024
FRESHNESS_CLOCK_TOLERANCE = timedelta(seconds=2)


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


def validate_relative_artifact_path(value: object) -> Path:
    if not isinstance(value, str) or not value:
        raise CaptureValidationError("producer receipt artifact path must be a non-empty relative path")
    candidate = Path(value)
    if candidate.is_absolute() or ".." in candidate.parts:
        raise CaptureValidationError("producer receipt artifact path must be a safe relative path")
    return candidate


def parse_aware_timestamp(value: object, *, label: str) -> datetime:
    if not isinstance(value, str) or not value.strip():
        raise CaptureValidationError(f"producer receipt {label} must be a timezone-aware timestamp")
    normalized = value.strip()
    if normalized.endswith("Z"):
        normalized = normalized[:-1] + "+00:00"
    try:
        parsed = datetime.fromisoformat(normalized)
    except ValueError as exc:
        raise CaptureValidationError(f"producer receipt {label} is not a valid ISO-8601 timestamp") from exc
    if parsed.tzinfo is None or parsed.utcoffset() is None:
        raise CaptureValidationError(f"producer receipt {label} must include a timezone")
    return parsed.astimezone(UTC)


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


def load_producer_receipt(
    receipt_path: Path,
    *,
    source: Path,
    expected_run_id: str,
    expected_source_commit: str,
    actual_byte_count: int,
    actual_digest: str,
) -> dict[str, Any]:
    receipt = receipt_path.resolve()
    if not receipt.is_file():
        raise CaptureValidationError(f"producer receipt does not exist: {receipt}")
    if receipt == source:
        raise CaptureValidationError("producer receipt cannot be the source image")
    try:
        payload = json.loads(receipt.read_text(encoding="utf-8"))
    except (OSError, UnicodeError, json.JSONDecodeError) as exc:
        raise CaptureValidationError(f"producer receipt is not valid UTF-8 JSON: {receipt}") from exc
    if not isinstance(payload, dict):
        raise CaptureValidationError("producer receipt must be a JSON object")
    if payload.get("schema_version") != 1 or payload.get("receipt_role") != PRODUCER_RECEIPT_ROLE:
        raise CaptureValidationError("producer receipt schema or role mismatch")

    producer_id = payload.get("producer_id")
    if not isinstance(producer_id, str) or not producer_id.strip():
        raise CaptureValidationError("producer receipt producer_id is required")
    if payload.get("producer_status") != "PASS":
        raise CaptureValidationError("producer status must be PASS before runtime evidence registration")

    run_id = payload.get("run_id")
    if not isinstance(run_id, str) or not RUN_ID_RE.fullmatch(run_id):
        raise CaptureValidationError("producer receipt run ID is missing or malformed")
    if run_id != expected_run_id:
        raise CaptureValidationError("producer receipt run ID mismatch")

    source_commit = payload.get("source_commit")
    if not isinstance(source_commit, str) or not COMMIT_RE.fullmatch(source_commit):
        raise CaptureValidationError("producer receipt source commit is missing or malformed")
    if source_commit.lower() != expected_source_commit.lower():
        raise CaptureValidationError("producer receipt source commit mismatch")

    started_at = parse_aware_timestamp(payload.get("started_at_utc"), label="started_at_utc")
    completed_at = parse_aware_timestamp(payload.get("completed_at_utc"), label="completed_at_utc")
    if completed_at < started_at:
        raise CaptureValidationError("producer receipt completion precedes producer start")

    artifact = payload.get("artifact")
    if not isinstance(artifact, dict):
        raise CaptureValidationError("producer receipt artifact object is required")
    artifact_relative_path = validate_relative_artifact_path(artifact.get("path"))
    receipt_artifact = (receipt.parent / artifact_relative_path).resolve()
    if receipt_artifact != source:
        raise CaptureValidationError("producer receipt artifact path does not resolve to the source image")

    expected_digest = artifact.get("sha256")
    if not isinstance(expected_digest, str) or not DIGEST_RE.fullmatch(expected_digest):
        raise CaptureValidationError("producer receipt artifact SHA-256 is missing or malformed")
    if expected_digest != actual_digest:
        raise CaptureValidationError("producer receipt artifact SHA-256 mismatch")

    expected_bytes = artifact.get("bytes")
    if not isinstance(expected_bytes, int) or isinstance(expected_bytes, bool) or expected_bytes <= 0:
        raise CaptureValidationError("producer receipt artifact bytes must be a positive integer")
    if expected_bytes != actual_byte_count:
        raise CaptureValidationError("producer receipt artifact bytes mismatch")

    expected_mtime_ns = artifact.get("mtime_ns")
    if not isinstance(expected_mtime_ns, int) or isinstance(expected_mtime_ns, bool) or expected_mtime_ns <= 0:
        raise CaptureValidationError("producer receipt artifact mtime_ns must be a positive integer")
    source_stat = source.stat()
    if expected_mtime_ns != source_stat.st_mtime_ns:
        raise CaptureValidationError("producer receipt artifact mtime mismatch")

    artifact_time = datetime.fromtimestamp(source_stat.st_mtime_ns / 1_000_000_000, UTC)
    if artifact_time < started_at - FRESHNESS_CLOCK_TOLERANCE:
        raise CaptureValidationError("source artifact predates producer run")
    if artifact_time > completed_at + FRESHNESS_CLOCK_TOLERANCE:
        raise CaptureValidationError("source artifact timestamp is later than producer completion")

    return {
        "receipt_role": PRODUCER_RECEIPT_ROLE,
        "producer_id": producer_id.strip(),
        "producer_status": "PASS",
        "run_id": run_id,
        "started_at_utc": started_at.isoformat(),
        "completed_at_utc": completed_at.isoformat(),
        "receipt_sha256": sha256_file(receipt),
        "artifact_mtime_ns": source_stat.st_mtime_ns,
    }


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
        description="Register a producer-bound Godot runtime visual capture without upgrading Human/device evidence."
    )
    parser.add_argument("--project-root", required=True, type=Path)
    parser.add_argument("--source-image", required=True, type=Path)
    parser.add_argument("--producer-receipt", required=True, type=Path)
    parser.add_argument("--run-id", required=True)
    parser.add_argument("--capture-id", required=True)
    parser.add_argument("--source-commit", required=True)
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
    if not isinstance(args.run_id, str) or not RUN_ID_RE.fullmatch(args.run_id):
        raise CaptureValidationError("run ID must be 1-128 safe identifier characters")
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
    producer_receipt = load_producer_receipt(
        args.producer_receipt,
        source=source,
        expected_run_id=args.run_id,
        expected_source_commit=args.source_commit,
        actual_byte_count=byte_count,
        actual_digest=digest,
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
        "producer_receipt": producer_receipt,
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
    print(
        json.dumps(
            {
                "capture_id": entry["capture_id"],
                "run_id": entry["producer_receipt"]["run_id"],
                "image": entry["image"],
            },
            ensure_ascii=False,
        )
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
